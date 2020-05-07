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
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/RegisterScavenging.h"
#include "llvm/MC/MCDwarf.h"

using namespace llvm;

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
  auto *KVXFI = MF.getInfo<KVXMachineFunctionInfo>();

  adjustStack(MF);

  int64_t StackSize = (int64_t)MFI.getStackSize();

  if (StackSize == 0 && !MFI.adjustsStack())
    return;

  DebugLoc DL;
  unsigned SPReg = getSPReg();

  adjustReg(MBB, MBBI, DL, GetStackOpCode((uint64_t)StackSize), SPReg, SPReg,
            -StackSize, MachineInstr::FrameSetup);

  unsigned ScratchReg = findScratchRegister(MBB, false, KVX::R32);

  realignStack(MF, MBB, MBBI, DL, ScratchReg);

  int CFAOffset = -StackSize + KVXFI->getVarArgsSaveSize();
  unsigned CFIIndex =
      MF.addFrameInst(MCCFIInstruction::createDefCfaOffset(nullptr, CFAOffset));

  const KVXInstrInfo *TII = STI.getInstrInfo();

  BuildMI(MBB, MBBI, DL, TII->get(TargetOpcode::CFI_INSTRUCTION))
      .addCFIIndex(CFIIndex)
      .setMIFlags(MachineInstr::FrameSetup);

  const KVXRegisterInfo *TRI =
      (const KVXRegisterInfo *)MF.getSubtarget().getRegisterInfo();

  if (TRI->needsStackRealignment(MF)) {
    // Skip CSR save instructions
    std::advance(MBBI, KVXFI->getCSRInstrCount());

    // ScrachReg contains the SPReg value before realignment
    BuildMI(MBB, MBBI, DL, TII->get(KVX::COPYD),
            hasFP(MF) ? KVX::R31 : getFPReg())
        .addReg(ScratchReg, RegState::Kill)
        .setMIFlag(MachineInstr::FrameSetup);
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
  MachineFunction *MF = MBB.getParent();

  if (hasFP(*MBB.getParent())) {
    DebugLoc DL = MI->getDebugLoc();
    BuildMI(MBB, MI, DL, TII->get(KVX::COPYD), getFPReg()).addReg(getSPReg());
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

    RegSaved.push_back(Reg);
    RCSaved.push_back(RC);
    FrameIdxSaved.push_back(CS.getFrameIdx());
  }

  unsigned InstrCount = (unsigned)RegSaved.size();
  for (unsigned i = 0; i < RegSaved.size(); ++i) {
    TII->storeRegToStackSlot(MBB, MI, RegSaved[i], true, FrameIdxSaved[i],
                             RCSaved[i], TRI);
    if (RegSaved[i] == KVX::RA)
      InstrCount++;
  }

  auto *KVXFI = MF->getInfo<KVXMachineFunctionInfo>();
  KVXFI->setCSRIndices({ CSI.front().getFrameIdx(), CSI.back().getFrameIdx() });

  KVXFI->setCSRInstrCount(InstrCount);

  return true;
}

bool KVXFrameLowering::restoreCalleeSavedRegisters(
    MachineBasicBlock &MBB, MachineBasicBlock::iterator MI,
    std::vector<CalleeSavedInfo> &CSI, const TargetRegisterInfo *TRI) const {
  const KVXInstrInfo *TII = STI.getInstrInfo();

  if (TRI->needsStackRealignment(*MBB.getParent())) {
    MachineFunction *MF = MBB.getParent();
    auto *KVXFI = MF->getInfo<KVXMachineFunctionInfo>();
    KVXFI->setScratchReg(findScratchRegister(MBB, true, KVX::R32));
    DebugLoc DL = MI->getDebugLoc();
    BuildMI(MBB, MI, DL, TII->get(KVX::COPYD), KVXFI->getScratchReg())
        .addReg(hasFP(*MF) ? KVX::R31 : getFPReg(), RegState::Kill)
        .setMIFlag(MachineInstr::FrameSetup);
  }

  if (hasFP(*MBB.getParent())) {
    DebugLoc DL = MI->getDebugLoc();
    BuildMI(MBB, MI, DL, TII->get(KVX::COPYD), getSPReg()).addReg(getFPReg());
  }

  MI = MBB.getFirstTerminator();

  SmallVector<unsigned, 8> RegSaved;
  SmallVector<const TargetRegisterClass *, 8> RCSaved;
  SmallVector<int, 8> FrameIdxSaved;
  for (const CalleeSavedInfo &CS : reverse(CSI)) {
    unsigned Reg = CS.getReg();
    const TargetRegisterClass *RC = TRI->getMinimalPhysRegClass(Reg);

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

  for (unsigned i = 0; i < RegSaved.size(); ++i)
    TII->loadRegFromStackSlot(MBB, MI, RegSaved[i], FrameIdxSaved[i],
                              RCSaved[i], TRI);

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
