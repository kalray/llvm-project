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
#include "K1CSubtarget.h"
#include "MCTargetDesc/K1CMCTargetDesc.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/RegisterScavenging.h"

using namespace llvm;

static unsigned getSPReg(const K1CSubtarget &STI) { return K1C::R12; }

void K1CFrameLowering::adjustStack(MachineFunction &MF) const {
  MachineFrameInfo &MFI = MF.getFrameInfo();
  const K1CRegisterInfo *RI = STI.getRegisterInfo();

  // Get the real stack size.
  uint64_t StackSize = MFI.getStackSize();

  // Get the alignment.

  uint64_t StackAlign = RI->needsStackRealignment(MF) ? MFI.getMaxAlignment()
                                                      : getStackAlignment();

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

  adjustStack(MF);

  int64_t StackSize = (int64_t)MFI.getStackSize();

  if (StackSize == 0 && !MFI.adjustsStack())
    return;

  DebugLoc DL;
  unsigned SPReg = getSPReg(STI);

  adjustReg(MBB, MBBI, DL, GetStackOpCode((uint64_t)StackSize), SPReg, SPReg,
            -StackSize, MachineInstr::FrameSetup);
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

  unsigned SPReg = getSPReg(STI);
  if (StackSize == 0)
    return;

  DebugLoc DL = MBBI->getDebugLoc();

  // Deallocate stack
  adjustReg(MBB, MBBI, DL, GetStackOpCode(StackSize), SPReg, SPReg, StackSize,
            MachineInstr::FrameDestroy);
}

int K1CFrameLowering::getFrameIndexReference(const MachineFunction &MF, int FI,
                                             unsigned &FrameReg) const {
  const MachineFrameInfo &MFI = MF.getFrameInfo();
  const TargetRegisterInfo *RI = MF.getSubtarget().getRegisterInfo();
  FrameReg = RI->getFrameRegister(MF);
  int Offset = MFI.getObjectOffset(FI) - getOffsetOfLocalArea() +
               MFI.getOffsetAdjustment();

  Offset += MF.getFrameInfo().getStackSize();

  return Offset;
}

void K1CFrameLowering::determineCalleeSaves(MachineFunction &MF,
                                            BitVector &SavedRegs,
                                            RegScavenger *RS) const {
  TargetFrameLowering::determineCalleeSaves(MF, SavedRegs, RS);

  // Unconditionally spill RA and FP only if the function uses a frame
  // pointer.
  if (hasFP(MF)) {
    SavedRegs.set(K1C::R14);
  }
}

void
K1CFrameLowering::processFunctionBeforeFrameFinalized(MachineFunction &MF,
                                                      RegScavenger *RS) const {}

bool K1CFrameLowering::hasFP(const MachineFunction &MF) const {
  // TODO : FP is not used at the moment
  return false;
}

bool K1CFrameLowering::hasReservedCallFrame(const MachineFunction &MF) const {
  return !MF.getFrameInfo().hasVarSizedObjects();
}

MachineBasicBlock::iterator K1CFrameLowering::eliminateCallFramePseudoInstr(
    MachineFunction &MF, MachineBasicBlock &MBB,
    MachineBasicBlock::iterator MI) const {

  unsigned SPReg = K1C::R12;
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

      adjustReg(MBB, MI, DL, GetStackOpCode(Amount), SPReg, SPReg, Amount,
                MachineInstr::NoFlags);
    }
  }

  return MBB.erase(MI);
}
