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
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/RegisterScavenging.h"

using namespace llvm;

void K1CFrameLowering::emitPrologue(MachineFunction &MF,
                                    MachineBasicBlock &MBB) const {}

void K1CFrameLowering::emitEpilogue(MachineFunction &MF,
                                    MachineBasicBlock &MBB) const {}

int K1CFrameLowering::getFrameIndexReference(const MachineFunction &MF, int FI,
                                             unsigned &FrameReg) const {
  return 0;
}

void K1CFrameLowering::determineCalleeSaves(MachineFunction &MF,
                                            BitVector &SavedRegs,
                                            RegScavenger *RS) const {}

void
K1CFrameLowering::processFunctionBeforeFrameFinalized(MachineFunction &MF,
                                                      RegScavenger *RS) const {}

bool K1CFrameLowering::hasFP(const MachineFunction &MF) const { return false; }

bool K1CFrameLowering::hasReservedCallFrame(const MachineFunction &MF) const {
  return false;
}

MachineBasicBlock::iterator K1CFrameLowering::eliminateCallFramePseudoInstr(
    MachineFunction &MF, MachineBasicBlock &MBB,
    MachineBasicBlock::iterator MI) const {
  return MBB.erase(MI);
}
