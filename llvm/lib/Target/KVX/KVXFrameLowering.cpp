//===- KVXFrameLowering.cpp - KVX Frame Lowering ---------------*- C++ -*-====//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the KVX implementation of TargetFrameLowering class.
//
// On KVX, stack frames are structured as follows:
//
// The stack grows downward. Stack layout is as follows.
//
//                  +---------------+
//                  | Varargs       |
//                  |               |
//                  |               |
//                  +---------------+
//      Virt. FP--->| [Static chain]|
//                  +---------------+
//                  | Local         |
//                  | Variable      |
//                  |               |
//                  +---------------+
//                  |               |
//                  | Register      |
//                  | Save          |
//                  |               |
//                  | $ra           | (if frame_pointer_needed)
//       Hard FP--->| caller FP     | (if frame_pointer_needed)
//                  +---------------+
//                  |               |
//                  | Outgoing      |
//                  | Args          |
//            SP--->|               |
//                  +---------------+
//
//===----------------------------------------------------------------------===//

#include "KVXFrameLowering.h"
#include "KVXMachineFunctionInfo.h"
#include "KVXSubtarget.h"
#include "MCTargetDesc/KVXMCTargetDesc.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/RegisterScavenging.h"
#include "llvm/MC/MCDwarf.h"
#include "llvm/Support/LEB128.h"

using namespace llvm;

static unsigned getNumOfSingleRegsPacked(unsigned Opcode) {
  switch (Opcode) {
  default:
    llvm_unreachable("Unknown Opcode");
  case KVX::SDp:
    return 1;
  case KVX::SQp:
    return 2;
  case KVX::SOp:
    return 4;
  }
}

void KVXFrameLowering::adjustStack(MachineFunction &MF) const {
  MachineFrameInfo &MFI = MF.getFrameInfo();
  const KVXRegisterInfo *RI = STI.getRegisterInfo();
  auto *KVXFI = MF.getInfo<KVXMachineFunctionInfo>();

  // Get the real stack size.
  uint64_t StackSize = MFI.getStackSize();
  StackSize += KVXFI->getVarArgsSaveSize();
  StackSize -= KVXFI->getMemArgsSaveSize();

  // Get the alignment.
  uint64_t StackAlign = getStackAlignment();
  if (RI->needsStackRealignment(MF)) {
    const uint64_t MaxAlign = MFI.getMaxAlignment();
    uint64_t MaxStackAlign = MaxAlign > StackAlign ? MaxAlign : StackAlign;

    // Reserve space for stack realignment
    StackSize += (MaxStackAlign - StackAlign);

    StackAlign = MaxStackAlign;
  }

  // Align the stack.
  StackSize = alignTo(StackSize, StackAlign);

  // Update with the aligned stack.
  MFI.setStackSize(StackSize);
}

void KVXFrameLowering::realignStack(MachineFunction &MF, MachineBasicBlock &MBB,
                                    MachineBasicBlock::iterator MBBI,
                                    const DebugLoc &DL,
                                    unsigned ScratchReg) const {
  const KVXRegisterInfo *TRI =
      (const KVXRegisterInfo *)MF.getSubtarget().getRegisterInfo();

  if (TRI->needsStackRealignment(MF)) {
    MachineFrameInfo &MFI = MF.getFrameInfo();
    const KVXInstrInfo *TII = STI.getInstrInfo();

    // save the value of SPReg to a ScratchReg
    // ScratchReg will be copied to FPReg after CSR
    BuildMI(MBB, MBBI, DL, TII->get(KVX::COPYD), ScratchReg)
        .addReg(getSPReg())
        .setMIFlag(MachineInstr::FrameSetup);

    const MCRegisterInfo *MRI = MF.getMMI().getContext().getRegisterInfo();

    // emit cfi instruction to set CFA to ScratchReg
    // .cfi_def_cfa_register ScratchReg
    BuildMI(MBB, MBBI, DL, TII->get(TargetOpcode::CFI_INSTRUCTION))
        .addCFIIndex(MF.addFrameInst(MCCFIInstruction::createDefCfaRegister(
            nullptr, MRI->getDwarfRegNum(ScratchReg, true))))
        .setMIFlags(MachineInstr::FrameSetup);

    if (MFI.getMaxAlignment() > getStackAlignment()) {
      // realign the stack
      BuildMI(MBB, MBBI, DL, TII->get(KVX::ADDDri64), getSPReg())
          .addReg(getSPReg())
          .addImm(MFI.getMaxAlignment() - getStackAlignment())
          .setMIFlag(MachineInstr::FrameSetup);
      BuildMI(MBB, MBBI, DL, TII->get(KVX::ANDDri64), getSPReg())
          .addReg(getSPReg())
          .addImm(-(int)MFI.getMaxAlignment())
          .setMIFlag(MachineInstr::FrameSetup);
    }
  }
}

void KVXFrameLowering::adjustReg(MachineBasicBlock &MBB,
                                 MachineBasicBlock::iterator MBBI,
                                 const DebugLoc &DL, unsigned OpCode,
                                 unsigned DestReg, unsigned SrcReg, int64_t Val,
                                 MachineInstr::MIFlag Flag) const {

  const KVXInstrInfo *TII = STI.getInstrInfo();
  BuildMI(MBB, MBBI, DL, TII->get(OpCode), DestReg)
      .addReg(SrcReg)
      .addImm(Val)
      .setMIFlag(Flag);
}

unsigned findScratchRegister(MachineBasicBlock &MBB, bool UseAtEnd,
                             unsigned DefaultReg);

void KVXFrameLowering::emitPrologue(MachineFunction &MF,
                                    MachineBasicBlock &MBB) const {
  assert(&MF.front() == &MBB && "Shrink-wrapping not yet supported");

  MachineBasicBlock::iterator MBBI = MBB.begin();
  MachineFrameInfo &MFI = MF.getFrameInfo();

  adjustStack(MF);

  int64_t StackSize = (int64_t)MFI.getStackSize();

  if (StackSize == 0 && !MFI.adjustsStack())
    return;

  DebugLoc DL;
  unsigned SPReg = getSPReg();

  adjustReg(MBB, MBBI, DL, GetStackOpCode((uint64_t)StackSize), SPReg, SPReg,
            -StackSize, MachineInstr::FrameSetup);

  unsigned CFIIndex = MF.addFrameInst(
      MCCFIInstruction::createDefCfaOffset(nullptr, -StackSize));

  const KVXInstrInfo *TII = STI.getInstrInfo();

  BuildMI(MBB, MBBI, DL, TII->get(TargetOpcode::CFI_INSTRUCTION))
      .addCFIIndex(CFIIndex)
      .setMIFlags(MachineInstr::FrameSetup);

  unsigned ScratchReg = findScratchRegister(MBB, false, KVX::R32);

  realignStack(MF, MBB, MBBI, DL, ScratchReg);

  const KVXRegisterInfo *TRI =
      (const KVXRegisterInfo *)MF.getSubtarget().getRegisterInfo();

  const std::vector<CalleeSavedInfo> &CSI = MFI.getCalleeSavedInfo();
  if (!CSI.empty()) {
    const MCRegisterInfo *MRI = MF.getMMI().getContext().getRegisterInfo();

    if (TRI->needsStackRealignment(MF) && hasFP(MF)) {
      ++MBBI; // skip copyd $r14 = scratch
      ++MBBI; // skip copyd $r14 = $r12
    }

    if (MBBI->getOpcode() == KVX::GETss2) {
      ++MBBI; // skip get
    }

    std::vector<CalleeSavedInfo>::const_iterator I = CSI.begin();
    std::vector<CalleeSavedInfo>::const_iterator E = CSI.end();
    while (I != E) {
      // Get the number of CSR packed
      unsigned numSingleRegs = getNumOfSingleRegsPacked(MBBI->getOpcode());
      ++MBBI;

      // Build CFI instrunction for each single register after the store
      while (numSingleRegs--) {
        unsigned DwarfReg = MRI->getDwarfRegNum(I->getReg(), true);

        if (TRI->needsStackRealignment(MF)) {
          // If stack realignment is needed then cfa cannot be used for dwarf
          // locations, as stack realignment is performed at runtime. In such
          // case the cfi escape instruction is used.

          // The cfi escape instruction syntax is:
          // .cfi_escape DW_CFA_EXPRESSION <reg> <1 + length of SLEB128 offset>
          //   <0x70 + regSP> <offset in SLEB128>

          // This will tell that the value of register <reg> can be found at the
          // an offset from the stack, given as offset + regSP.

          unsigned DwarfSPReg = 0x70;
          if (TRI->needsStackRealignment(MF) && hasFP(MF))
            DwarfSPReg += MRI->getDwarfRegNum(getFPReg(), true);
          else
            DwarfSPReg += MRI->getDwarfRegNum(getSPReg(), true);

          int64_t Offset = MFI.getObjectOffset(I->getFrameIdx());
          SmallString<128> Tmp;
          raw_svector_ostream OSE(Tmp);
          unsigned int slebsize = encodeSLEB128(Offset, OSE);
          const char *sleb128 = Tmp.c_str();
          char CFIInst[8];
          CFIInst[0] = dwarf::DW_CFA_expression;
          CFIInst[1] = static_cast<char>(DwarfReg);
          CFIInst[2] = 1 + slebsize;
          CFIInst[3] = static_cast<char>(DwarfSPReg);
          strncpy(&CFIInst[4], sleb128, slebsize);
          unsigned CFIIndex = MF.addFrameInst(MCCFIInstruction::createEscape(
              nullptr, StringRef(CFIInst, 4 + slebsize)));
          BuildMI(MBB, MBBI, DL, TII->get(TargetOpcode::CFI_INSTRUCTION))
              .addCFIIndex(CFIIndex)
              .setMIFlag(MachineInstr::FrameSetup);
        } else {
          // emit .cfi_offset <DwarfReg> <Offset> telling the debugger that
          // the value of reg can be found at cfa + Offset
          int64_t Offset = MFI.getObjectOffset(I->getFrameIdx()) - StackSize;
          BuildMI(MBB, MBBI, DL, TII->get(TargetOpcode::CFI_INSTRUCTION))
              .addCFIIndex(MF.addFrameInst(
                  MCCFIInstruction::createOffset(nullptr, DwarfReg, Offset)))
              .setMIFlags(MachineInstr::FrameSetup);
        }

        ++I;
      }
    }
  }

  if (TRI->needsStackRealignment(MF)) {
    // ScrachReg contains the SPReg value before realignment
    BuildMI(MBB, MBBI, DL, TII->get(KVX::COPYD),
            hasFP(MF) ? KVX::R31 : getFPReg())
        .addReg(ScratchReg, RegState::Kill)
        .setMIFlag(MachineInstr::FrameSetup);

    const MCRegisterInfo *MRI = MF.getMMI().getContext().getRegisterInfo();

    // emit .cfi_def_cfa_register $r31 (alloca case) or $r14
    BuildMI(MBB, MBBI, DL, TII->get(TargetOpcode::CFI_INSTRUCTION))
        .addCFIIndex(MF.addFrameInst(MCCFIInstruction::createDefCfaRegister(
            nullptr,
            MRI->getDwarfRegNum(hasFP(MF) ? KVX::R31 : getFPReg(), true))))
        .setMIFlags(MachineInstr::FrameSetup);
  }
}

bool KVXFrameLowering::isLeafProc(MachineFunction &MF) const {
  MachineFrameInfo &MFI = MF.getFrameInfo();

  return !(MFI.hasCalls());
}

void KVXFrameLowering::emitEpilogue(MachineFunction &MF,
                                    MachineBasicBlock &MBB) const {
  MachineBasicBlock::iterator MBBI = MBB.getLastNonDebugInstr();
  MachineFrameInfo &MFI = MF.getFrameInfo();
  uint64_t StackSize = MFI.getStackSize();

  if (StackSize == 0)
    return;

  DebugLoc DL = MBBI->getDebugLoc();

  const KVXInstrInfo *TII = STI.getInstrInfo();

  const KVXRegisterInfo *TRI =
      (const KVXRegisterInfo *)MF.getSubtarget().getRegisterInfo();

  if (TRI->needsStackRealignment(MF)) {
    auto *KVXFI = MF.getInfo<KVXMachineFunctionInfo>();
    // Restore SPReg from ScrachReg which is copied from FPReg before
    // CSR restore
    BuildMI(MBB, MBBI, DL, TII->get(KVX::COPYD), getSPReg())
        .addReg(KVXFI->getScratchReg(), RegState::Kill)
        .setMIFlag(MachineInstr::FrameSetup);

    const MCRegisterInfo *MRI = MF.getMMI().getContext().getRegisterInfo();

    BuildMI(MBB, MBBI, DL, TII->get(TargetOpcode::CFI_INSTRUCTION))
        .addCFIIndex(MF.addFrameInst(MCCFIInstruction::createDefCfaRegister(
            nullptr, MRI->getDwarfRegNum(getSPReg(), true))))
        .setMIFlags(MachineInstr::FrameDestroy);
  }

  // Deallocate stack
  adjustReg(MBB, MBBI, DL, GetStackOpCode(StackSize), getSPReg(), getSPReg(),
            StackSize, MachineInstr::FrameDestroy);

  unsigned CFIIndex =
      MF.addFrameInst(MCCFIInstruction::createDefCfaOffset(nullptr, 0));

  BuildMI(MBB, MBBI, DL, TII->get(TargetOpcode::CFI_INSTRUCTION))
      .addCFIIndex(CFIIndex)
      .setMIFlags(MachineInstr::FrameDestroy);
}

int KVXFrameLowering::getFrameIndexReference(const MachineFunction &MF, int FI,
                                             unsigned &FrameReg) const {
  const MachineFrameInfo &MFI = MF.getFrameInfo();
  auto *KVXFI = MF.getInfo<KVXMachineFunctionInfo>();
  FrameReg = getSPReg();
  auto const &indices = KVXFI->getCSRIndices();

  if (hasFP(MF) && (indices.first > FI || FI > indices.second))
    FrameReg = getFPReg();

  int Offset = MFI.getObjectOffset(FI) - getOffsetOfLocalArea() +
               MFI.getOffsetAdjustment();

  int OffsetAdjust = -KVXFI->getMemArgsSaveSize();
  if (FI < 0)
    OffsetAdjust = MFI.getStackSize();
  else if (!hasFP(MF))
    OffsetAdjust += KVXFI->getOutgoingArgsMaxSize();

  const KVXRegisterInfo *TRI =
      (const KVXRegisterInfo *)MF.getSubtarget().getRegisterInfo();
  if (!TRI->needsStackRealignment(MF))
    Offset -= MFI.getStackSize();

  return Offset + OffsetAdjust;
}

void KVXFrameLowering::determineCalleeSaves(MachineFunction &MF,
                                            BitVector &SavedRegs,
                                            RegScavenger *RS) const {
  TargetFrameLowering::determineCalleeSaves(MF, SavedRegs, RS);

  const KVXRegisterInfo *TRI =
      (const KVXRegisterInfo *)MF.getSubtarget().getRegisterInfo();

  // if stack needs realignment, the FPReg will be used to keep the
  // unaligned value of SPReg
  // R31 will be used in the case FPReg is needed for varsized objects on the
  // stack
  if (TRI->needsStackRealignment(MF)) {
    SavedRegs.set(getFPReg());
    if (hasFP(MF))
      SavedRegs.set(KVX::R31);
  }

  // Unconditionally spill RA and FP only if the function uses a frame
  // pointer.
  if (hasFP(MF)) {
    SavedRegs.set(KVX::RA);
    SavedRegs.set(getFPReg());
  }
}

void
KVXFrameLowering::processFunctionBeforeFrameFinalized(MachineFunction &MF,
                                                      RegScavenger *RS) const {}

bool KVXFrameLowering::spillCalleeSavedRegisters(
    MachineBasicBlock &MBB, MachineBasicBlock::iterator MI,
    const std::vector<CalleeSavedInfo> &CSI,
    const TargetRegisterInfo *TRI) const {
  const KVXInstrInfo *TII = STI.getInstrInfo();

  MachineFunction &MF = *MBB.getParent();
  const MCRegisterInfo *MRI = MF.getMMI().getContext().getRegisterInfo();

  unsigned FPScratch = 0;

  DebugLoc DL = MI->getDebugLoc();

  if (hasFP(*MBB.getParent())) {
    if (!TRI->needsStackRealignment(MF)) {
      BuildMI(MBB, MI, DL, TII->get(KVX::COPYD), getFPReg()).addReg(getSPReg());

      // $r14 is fixed, $r12 is modified by alloca
      // tell the debugger to use cfa $r14

      // emit .cfi_def_cfa_register $r14
      BuildMI(MBB, MI, DL, TII->get(TargetOpcode::CFI_INSTRUCTION))
          .addCFIIndex(MF.addFrameInst(MCCFIInstruction::createDefCfaRegister(
              nullptr, MRI->getDwarfRegNum(getFPReg(), true))))
          .setMIFlags(MachineInstr::FrameSetup);
    } else {
      // a scratch register is used to save FPreg value and store FPreg value
      // from the scratch register in order to have correct backtrack info
      // for all prologue instructions
      FPScratch = findScratchRegister(MBB, false, KVX::R33);
    }
  }

  MI = MBB.begin();

  SmallVector<unsigned, 8> RegSaved;
  SmallVector<const TargetRegisterClass *, 8> RCSaved;
  SmallVector<int, 8> FrameIdxSaved;

  for (const CalleeSavedInfo &CS : CSI) {
    unsigned Reg = CS.getReg();
    const TargetRegisterClass *RC = TRI->getMinimalPhysRegClass(Reg);

    // Try to merge single regs into paired regs
    unsigned PairedReg =
        TRI->getMatchingSuperReg(Reg, 1, &KVX::PairedRegRegClass);
    if (!RegSaved.empty() && PairedReg && RegSaved.back() - 1 == Reg &&
        FrameIdxSaved.back() + 1 == CS.getFrameIdx()) {
      if (RCSaved.back() == &KVX::SingleRegRegClass) {
        RegSaved.pop_back();
        RCSaved.pop_back();
        FrameIdxSaved.pop_back();

        // Try to merge paired regs into quad regs
        unsigned QuadReg =
            TRI->getMatchingSuperReg(Reg, 1, &KVX::QuadRegRegClass);
        if (!RegSaved.empty() && RCSaved.back() == &KVX::PairedRegRegClass &&
            QuadReg && RegSaved.back() - 1 == PairedReg) {
          Reg = QuadReg;
          RC = &KVX::QuadRegRegClass;
          RegSaved.pop_back();
          RCSaved.pop_back();
          FrameIdxSaved.pop_back();
        } else {
          Reg = PairedReg;
          RC = &KVX::PairedRegRegClass;
        }
      }
    }

    if (Reg == getFPReg() && FPScratch != 0)
      RegSaved.push_back(FPScratch); // FP is stored from scratch register copy
    else
      RegSaved.push_back(Reg);
    RCSaved.push_back(RC);
    FrameIdxSaved.push_back(CS.getFrameIdx());
  }

  if (FPScratch != 0) {
    // make a copy of FPreg into a scratch reg and set FP to SP
    BuildMI(MBB, MI, DL, TII->get(KVX::COPYD), FPScratch).addReg(getFPReg());
    BuildMI(MBB, MI, DL, TII->get(KVX::COPYD), getFPReg()).addReg(getSPReg());
  }
  for (unsigned i = 0; i < RegSaved.size(); ++i) {
    TII->storeRegToStackSlot(MBB, MI, RegSaved[i], true, FrameIdxSaved[i],
                             RCSaved[i], TRI);
  }

  auto *KVXFI = MBB.getParent()->getInfo<KVXMachineFunctionInfo>();
  KVXFI->setCSRIndices({ CSI.front().getFrameIdx(), CSI.back().getFrameIdx() });

  return true;
}

bool KVXFrameLowering::restoreCalleeSavedRegisters(
    MachineBasicBlock &MBB, MachineBasicBlock::iterator MI,
    std::vector<CalleeSavedInfo> &CSI, const TargetRegisterInfo *TRI) const {
  const KVXInstrInfo *TII = STI.getInstrInfo();
  DebugLoc DL = MI->getDebugLoc();
  MachineFunction *MF = MBB.getParent();
  auto *KVXFI = MF->getInfo<KVXMachineFunctionInfo>();
  const MCRegisterInfo *MRI = MF->getMMI().getContext().getRegisterInfo();

  if (TRI->needsStackRealignment(*MBB.getParent())) {
    KVXFI->setScratchReg(findScratchRegister(MBB, true, KVX::R32));
    DebugLoc DL = MI->getDebugLoc();
    BuildMI(MBB, MI, DL, TII->get(KVX::COPYD), KVXFI->getScratchReg())
        .addReg(hasFP(*MF) ? KVX::R31 : getFPReg(), RegState::Kill)
        .setMIFlag(MachineInstr::FrameDestroy);

    MachineFunction *MF = MBB.getParent();
    const MCRegisterInfo *MRI = MF->getMMI().getContext().getRegisterInfo();

    // .cfi_def_cfa_register ScratchReg
    BuildMI(MBB, MI, DL, TII->get(TargetOpcode::CFI_INSTRUCTION))
        .addCFIIndex(MF->addFrameInst(MCCFIInstruction::createDefCfaRegister(
            nullptr, MRI->getDwarfRegNum(KVXFI->getScratchReg(), true))))
        .setMIFlags(MachineInstr::FrameDestroy);
  }

  if (hasFP(*MBB.getParent())) {
    BuildMI(MBB, MI, DL, TII->get(KVX::COPYD), getSPReg()).addReg(getFPReg());

    if (!TRI->needsStackRealignment(*MF)) {
      // $r12 is restored from $r14, tell the debugger to use $r12 as cfa

      // .cfi_def_cfa_register $r12
      BuildMI(MBB, MI, DL, TII->get(TargetOpcode::CFI_INSTRUCTION))
          .addCFIIndex(MF->addFrameInst(MCCFIInstruction::createDefCfaRegister(
              nullptr, MRI->getDwarfRegNum(getSPReg(), true))))
          .setMIFlags(MachineInstr::FrameDestroy);
    }
  }

  MI = MBB.getFirstTerminator();

  SmallVector<unsigned, 8> RegSaved;
  SmallVector<const TargetRegisterClass *, 8> RCSaved;
  SmallVector<int, 8> FrameIdxSaved;
  for (const CalleeSavedInfo &CS : reverse(CSI)) {
    unsigned Reg = CS.getReg();
    const TargetRegisterClass *RC = TRI->getMinimalPhysRegClass(Reg);

    if (MI->getOpcode() == KVX::ITAIL && MI->getOperand(0).getReg() == Reg) {
      unsigned ScratchReg = findScratchRegister(MBB, true, KVX::R0);
      BuildMI(MBB, MI, DL, TII->get(KVX::COPY), ScratchReg).addReg(Reg);
      MI->getOperand(0).setReg(ScratchReg);
      MBB.addLiveIn(ScratchReg);
    }

    // Try to merge single regs into paired regs
    unsigned PairedReg =
        TRI->getMatchingSuperReg(Reg, 2, &KVX::PairedRegRegClass);
    if (!RegSaved.empty() && PairedReg && RegSaved.back() + 1 == Reg &&
        FrameIdxSaved.back() - 1 == CS.getFrameIdx()) {
      if (RCSaved.back() == &KVX::SingleRegRegClass) {
        RegSaved.pop_back();
        RCSaved.pop_back();

        // Try to merge paired regs into quad regs
        unsigned QuadReg =
            TRI->getMatchingSuperReg(Reg, 4, &KVX::QuadRegRegClass);
        if (!RegSaved.empty() && RCSaved.back() == &KVX::PairedRegRegClass &&
            QuadReg && RegSaved.back() + 1 == PairedReg) {
          Reg = QuadReg;
          RC = &KVX::QuadRegRegClass;
          RegSaved.pop_back();
          RCSaved.pop_back();
          FrameIdxSaved.pop_back();
        } else {
          Reg = PairedReg;
          RC = &KVX::PairedRegRegClass;
        }
      }
    } else {
      FrameIdxSaved.push_back(CS.getFrameIdx());
    }

    RegSaved.push_back(Reg);
    RCSaved.push_back(RC);
  }

  // restore all CSR but FP in order to have correct backtrack info for all
  // bundles in the generated code
  int FPIndex = -1;
  for (unsigned i = 0; i < RegSaved.size(); ++i) {
    if (RegSaved[i] == getFPReg()) {
      FPIndex = i;
      continue;
    }
    TII->loadRegFromStackSlot(MBB, MI, RegSaved[i], FrameIdxSaved[i],
                              RCSaved[i], TRI);
    if (TRI->needsStackRealignment(*MBB.getParent()) &&
        RegSaved[i] == KVX::RA) {
      BuildMI(MBB, MI, DL, TII->get(TargetOpcode::CFI_INSTRUCTION))
          .addCFIIndex(MF->addFrameInst(MCCFIInstruction::createRestore(
              nullptr, MRI->getDwarfRegNum(RegSaved[i], true))))
          .setMIFlags(MachineInstr::FrameDestroy);
    }
  }

  // restore FP
  if (FPIndex != -1)
    TII->loadRegFromStackSlot(MBB, MI, RegSaved[FPIndex],
                              FrameIdxSaved[FPIndex], RCSaved[FPIndex], TRI);

  return true;
}

bool KVXFrameLowering::hasFP(const MachineFunction &MF) const {
  const MachineFrameInfo &MFI = MF.getFrameInfo();
  return MFI.hasVarSizedObjects();
}

bool KVXFrameLowering::hasReservedCallFrame(const MachineFunction &MF) const {
  return !hasFP(MF);
}

MachineBasicBlock::iterator KVXFrameLowering::eliminateCallFramePseudoInstr(
    MachineFunction &MF, MachineBasicBlock &MBB,
    MachineBasicBlock::iterator MI) const {

  DebugLoc DL = MI->getDebugLoc();

  if (!hasReservedCallFrame(MF)) {
    // If space has not been reserved for a call frame, ADJCALLSTACKDOWN and
    // ADJCALLSTACKUP must be converted to instructions manipulating the stack
    // pointer. This is necessary when there is a variable length stack
    // allocation (e.g. alloca), which means it's not possible to allocate
    // space for outgoing arguments from within the function prologue.
    int64_t Amount = MI->getOperand(0).getImm();

    if (Amount != 0) {
      // Ensure the stack remains aligned after adjustment.
      Amount = alignSPAdjust(Amount);

      if (MI->getOpcode() == KVX::ADJCALLSTACKDOWN)
        Amount = -Amount;

      adjustReg(MBB, MI, DL, GetStackOpCode(Amount), getSPReg(), getSPReg(),
                Amount, MachineInstr::NoFlags);
    }
  }

  return MBB.erase(MI);
}
