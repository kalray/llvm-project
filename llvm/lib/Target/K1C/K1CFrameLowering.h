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
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_K1C_K1CFRAMELOWERING_H
#define LLVM_LIB_TARGET_K1C_K1CFRAMELOWERING_H

#include "llvm/CodeGen/TargetFrameLowering.h"
#include "MCTargetDesc/K1CMCTargetDesc.h"

namespace llvm {
class K1CSubtarget;

class K1CFrameLowering : public TargetFrameLowering {
public:
  explicit K1CFrameLowering(const K1CSubtarget &STI)
      : TargetFrameLowering(StackGrowsUp,
                            /*StackAlignment=*/8,
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
  const K1CSubtarget &STI;

private:
  unsigned GetStackOpCode(uint64_t StackSize) const {
    if (isInt<10>(StackSize))
      return K1C::ADDDd1;
    else if (isInt<37>(StackSize))
      return K1C::ADDDd2;
    else
      return K1C::ADDDd3;
  }

  void adjustStack(MachineFunction &MF) const;
  void adjustReg(MachineBasicBlock &MBB, MachineBasicBlock::iterator MBBI,
                 const DebugLoc &DL, unsigned OpCode, unsigned DestReg,
                 unsigned SrcReg, int64_t Val, MachineInstr::MIFlag) const;
};

} // namespace llvm

#endif
