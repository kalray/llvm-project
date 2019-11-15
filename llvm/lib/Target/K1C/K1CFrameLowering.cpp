//===- K1CFrameLowering.cpp - K1C Frame Lowering ---------------*- C++ -*-====//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the K1C implementation of TargetFrameLowering class.
//
// On K1C, stack frames are structured as follows:
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

#include "K1CFrameLowering.h"
#include "K1CMachineFunctionInfo.h"
#include "K1CSubtarget.h"
#include "MCTargetDesc/K1CMCTargetDesc.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/RegisterScavenging.h"

using namespace llvm;

void K1CFrameLowering::adjustStack(MachineFunction &MF) const {
  MachineFrameInfo &MFI = MF.getFrameInfo();
  const K1CRegisterInfo *RI = STI.getRegisterInfo();
  auto *K1CFI = MF.getInfo<K1CMachineFunctionInfo>();

  // Get the real stack size.
  uint64_t StackSize = MFI.getStackSize();
  StackSize += K1CFI->getVarArgsSaveSize();
  StackSize -= K1CFI->getMemArgsSaveSize();

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

void K1CFrameLowering::adjustReg(MachineBasicBlock &MBB,
                                 MachineBasicBlock::iterator MBBI,
                                 const DebugLoc &DL, unsigned OpCode,
                                 unsigned DestReg, unsigned SrcReg, int64_t Val,
                                 MachineInstr::MIFlag Flag) const {

  const K1CInstrInfo *TII = STI.getInstrInfo();
  BuildMI(MBB, MBBI, DL, TII->get(OpCode), DestReg)
      .addReg(SrcReg)
      .addImm(Val)
      .setMIFlag(Flag);
}

void K1CFrameLowering::emitPrologue(MachineFunction &MF,
                                    MachineBasicBlock &MBB) const {
  assert(&MF.front() == &MBB && "Shrink-wrapping not yet supported");

  MachineBasicBlock::iterator MBBI = MBB.begin();
  MachineFrameInfo &MFI = MF.getFrameInfo();
  auto *K1CFI = MF.getInfo<K1CMachineFunctionInfo>();

  adjustStack(MF);

  int64_t StackSize = (int64_t)MFI.getStackSize();

  if (StackSize == 0 && !MFI.adjustsStack())
    return;

  DebugLoc DL;
  unsigned SPReg = getSPReg();

  adjustReg(MBB, MBBI, DL, GetStackOpCode((uint64_t)StackSize), SPReg, SPReg,
            -StackSize, MachineInstr::FrameSetup);

  int CFAOffset = -StackSize + K1CFI->getVarArgsSaveSize();
  unsigned CFIIndex =
      MF.addFrameInst(MCCFIInstruction::createDefCfaOffset(nullptr, CFAOffset));

  const K1CInstrInfo *TII = STI.getInstrInfo();

  BuildMI(MBB, MBBI, DL, TII->get(TargetOpcode::CFI_INSTRUCTION))
      .addCFIIndex(CFIIndex)
      .setMIFlags(MachineInstr::FrameSetup);
}

bool K1CFrameLowering::isLeafProc(MachineFunction &MF) const {
  MachineFrameInfo &MFI = MF.getFrameInfo();

  return !(MFI.hasCalls());
}

void K1CFrameLowering::emitEpilogue(MachineFunction &MF,
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

  const K1CInstrInfo *TII = STI.getInstrInfo();

  BuildMI(MBB, MBBI, DL, TII->get(TargetOpcode::CFI_INSTRUCTION))
      .addCFIIndex(CFIIndex)
      .setMIFlags(MachineInstr::FrameDestroy);
}

int K1CFrameLowering::getFrameIndexReference(const MachineFunction &MF, int FI,
                                             unsigned &FrameReg) const {
  const MachineFrameInfo &MFI = MF.getFrameInfo();
  auto *K1CFI = MF.getInfo<K1CMachineFunctionInfo>();
  FrameReg = getSPReg();
  auto const &indices = K1CFI->getCSRIndices();

  if (hasFP(MF) && (indices.first > FI || FI > indices.second))
    FrameReg = getFPReg();

  int Offset = MFI.getObjectOffset(FI) - getOffsetOfLocalArea() +
               MFI.getOffsetAdjustment();

  int OffsetAdjust = -K1CFI->getMemArgsSaveSize();
  if (FI < 0)
    OffsetAdjust = MFI.getStackSize();
  else if (!hasFP(MF))
    OffsetAdjust += K1CFI->getOutgoingArgsMaxSize();

  return Offset + OffsetAdjust;
}

void K1CFrameLowering::determineCalleeSaves(MachineFunction &MF,
                                            BitVector &SavedRegs,
                                            RegScavenger *RS) const {
  TargetFrameLowering::determineCalleeSaves(MF, SavedRegs, RS);

  // Unconditionally spill RA and FP only if the function uses a frame
  // pointer.
  if (hasFP(MF)) {
    SavedRegs.set(K1C::RA);
    SavedRegs.set(getFPReg());
  }
}

void
K1CFrameLowering::processFunctionBeforeFrameFinalized(MachineFunction &MF,
                                                      RegScavenger *RS) const {}

bool K1CFrameLowering::spillCalleeSavedRegisters(
    MachineBasicBlock &MBB, MachineBasicBlock::iterator MI,
    const std::vector<CalleeSavedInfo> &CSI,
    const TargetRegisterInfo *TRI) const {
  const K1CInstrInfo *TII = STI.getInstrInfo();
  MachineFunction *MF = MBB.getParent();

  if (hasFP(*MBB.getParent())) {
    DebugLoc DL = MI->getDebugLoc();
    BuildMI(MBB, MI, DL, TII->get(K1C::COPYD), getFPReg()).addReg(getSPReg());
  }

  MI = MBB.begin();
  for (const CalleeSavedInfo &CS : CSI) {
    // Insert the spill to the stack frame.
    unsigned Reg = CS.getReg();
    const TargetRegisterClass *RC = TRI->getMinimalPhysRegClass(Reg);
    TII->storeRegToStackSlot(MBB, MI, Reg, true, CS.getFrameIdx(), RC, TRI);
  }

  auto *K1CFI = MF->getInfo<K1CMachineFunctionInfo>();
  K1CFI->setCSRIndices({ CSI.front().getFrameIdx(), CSI.back().getFrameIdx() });

  return true;
}

bool K1CFrameLowering::restoreCalleeSavedRegisters(
    MachineBasicBlock &MBB, MachineBasicBlock::iterator MI,
    std::vector<CalleeSavedInfo> &CSI, const TargetRegisterInfo *TRI) const {
  const K1CInstrInfo *TII = STI.getInstrInfo();

  if (hasFP(*MBB.getParent())) {
    DebugLoc DL = MI->getDebugLoc();
    BuildMI(MBB, MI, DL, TII->get(K1C::COPYD), getSPReg()).addReg(getFPReg());
  }

  return false;
}

bool K1CFrameLowering::hasFP(const MachineFunction &MF) const {
  const MachineFrameInfo &MFI = MF.getFrameInfo();
  return MFI.hasVarSizedObjects();
}

bool K1CFrameLowering::hasReservedCallFrame(const MachineFunction &MF) const {
  return !hasFP(MF);
}

MachineBasicBlock::iterator K1CFrameLowering::eliminateCallFramePseudoInstr(
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

      if (MI->getOpcode() == K1C::ADJCALLSTACKDOWN)
        Amount = -Amount;

      adjustReg(MBB, MI, DL, GetStackOpCode(Amount), getSPReg(), getSPReg(),
                Amount, MachineInstr::NoFlags);
    }
  }

  return MBB.erase(MI);
}
