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
    StackAlign = MaxAlign ? MaxAlign : StackAlign;
  }

  // Align the stack.
  StackSize = alignTo(StackSize, StackAlign);

  // Update with the aligned stack.
  MFI.setStackSize(StackSize);
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

  int CFAOffset = -StackSize + KVXFI->getVarArgsSaveSize();
  unsigned CFIIndex =
      MF.addFrameInst(MCCFIInstruction::createDefCfaOffset(nullptr, CFAOffset));

  const KVXInstrInfo *TII = STI.getInstrInfo();

  BuildMI(MBB, MBBI, DL, TII->get(TargetOpcode::CFI_INSTRUCTION))
      .addCFIIndex(CFIIndex)
      .setMIFlags(MachineInstr::FrameSetup);
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

  // Deallocate stack
  adjustReg(MBB, MBBI, DL, GetStackOpCode(StackSize), getSPReg(), getSPReg(),
            StackSize, MachineInstr::FrameDestroy);

  unsigned CFIIndex =
      MF.addFrameInst(MCCFIInstruction::createDefCfaOffset(nullptr, 0));

  const KVXInstrInfo *TII = STI.getInstrInfo();

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

  for (unsigned i = 0; i < RegSaved.size(); ++i)
    TII->storeRegToStackSlot(MBB, MI, RegSaved[i], true, FrameIdxSaved[i],
                             RCSaved[i], TRI);

  auto *KVXFI = MF->getInfo<KVXMachineFunctionInfo>();
  KVXFI->setCSRIndices({ CSI.front().getFrameIdx(), CSI.back().getFrameIdx() });

  return true;
}

bool KVXFrameLowering::restoreCalleeSavedRegisters(
    MachineBasicBlock &MBB, MachineBasicBlock::iterator MI,
    std::vector<CalleeSavedInfo> &CSI, const TargetRegisterInfo *TRI) const {
  const KVXInstrInfo *TII = STI.getInstrInfo();

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
