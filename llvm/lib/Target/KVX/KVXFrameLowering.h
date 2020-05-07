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
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_KVX_KVXFRAMELOWERING_H
#define LLVM_LIB_TARGET_KVX_KVXFRAMELOWERING_H

#include "KVX.h"
#include "MCTargetDesc/KVXMCTargetDesc.h"
#include "llvm/CodeGen/TargetFrameLowering.h"

namespace llvm {
class KVXSubtarget;

class KVXFrameLowering : public TargetFrameLowering {
public:
  explicit KVXFrameLowering(const KVXSubtarget &STI)
      : TargetFrameLowering(StackGrowsUp,
                            /*StackAlignment=*/Align(32),
                            /*LocalAreaOffset=*/0),
        STI(STI) {}

  void emitPrologue(MachineFunction &MF, MachineBasicBlock &MBB) const override;
  void emitEpilogue(MachineFunction &MF, MachineBasicBlock &MBB) const override;

  int getFrameIndexReference(const MachineFunction &MF, int FI,
                             unsigned &FrameReg) const override;

  void determineCalleeSaves(MachineFunction &MF, BitVector &SavedRegs,
                            RegScavenger *RS) const override;

  void processFunctionBeforeFrameFinalized(MachineFunction &MF,
                                           RegScavenger *RS) const override;

  bool spillCalleeSavedRegisters(MachineBasicBlock &MBB,
                                 MachineBasicBlock::iterator MI,
                                 const std::vector<CalleeSavedInfo> &CSI,
                                 const TargetRegisterInfo *TRI) const override;

  bool restoreCalleeSavedRegisters(MachineBasicBlock &MBB,
                                   MachineBasicBlock::iterator MI,
                                   std::vector<CalleeSavedInfo> &CSI,
                                   const TargetRegisterInfo *TRI) const
      override;

  bool hasFP(const MachineFunction &MF) const override;
  bool isLeafProc(MachineFunction &MF) const;

  bool hasReservedCallFrame(const MachineFunction &MF) const override;
  MachineBasicBlock::iterator
  eliminateCallFramePseudoInstr(MachineFunction &MF, MachineBasicBlock &MBB,
                                MachineBasicBlock::iterator MI) const override;

protected:
  const KVXSubtarget &STI;

private:
  unsigned GetStackOpCode(uint64_t StackSize) const {
    return GetImmOpCode(StackSize, KVX::ADDDri10, KVX::ADDDri37, KVX::ADDDri64);
  }

  void adjustStack(MachineFunction &MF) const;
  void adjustReg(MachineBasicBlock &MBB, MachineBasicBlock::iterator MBBI,
                 const DebugLoc &DL, unsigned OpCode, unsigned DestReg,
                 unsigned SrcReg, int64_t Val, MachineInstr::MIFlag) const;

  void realignStack(MachineFunction &MF, MachineBasicBlock &MBB,
                    MachineBasicBlock::iterator MBBI, const DebugLoc &DL,
                    unsigned ScratchReg) const;
};

} // namespace llvm

#endif
