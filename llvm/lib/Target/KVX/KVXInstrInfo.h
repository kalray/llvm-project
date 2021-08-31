//===- KVXInstrInfo.h - KVX Instruction Information -------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the KVX implementation of the TargetInstrInfo class.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_KVX_KVXINSTRINFO_H
#define LLVM_LIB_TARGET_KVX_KVXINSTRINFO_H

#include "KVXRegisterInfo.h"
#include "llvm/CodeGen/TargetInstrInfo.h"

#define GET_INSTRINFO_HEADER
#include "KVXGenInstrInfo.inc"

namespace llvm {

class KVXSubtarget;

class KVXInstrInfo : public KVXGenInstrInfo {

  const KVXSubtarget &Subtarget;

public:
  explicit KVXInstrInfo(KVXSubtarget &ST);

  void copyPhysReg(MachineBasicBlock &MBB, MachineBasicBlock::iterator MBBI,
                   const DebugLoc &DL, MCRegister DstReg, MCRegister SrcReg,
                   bool KillSrc) const override;

  void loadRegFromStackSlot(MachineBasicBlock &MBB,
                            MachineBasicBlock::iterator MI, Register DestReg,
                            int FrameIndex, const TargetRegisterClass *RC,
                            const TargetRegisterInfo *TRI) const override;

  void storeRegToStackSlot(MachineBasicBlock &MBB,
                           MachineBasicBlock::iterator MBBI, Register SrcReg,
                           bool IsKill, int FrameIndex,
                           const TargetRegisterClass *RC,
                           const TargetRegisterInfo *TRI) const override;

  DFAPacketizer *CreateTargetScheduleState(const TargetSubtargetInfo &STI) const
      override;

  bool analyzeBranch(MachineBasicBlock &MBB, MachineBasicBlock *&TBB,
                     MachineBasicBlock *&FBB,
                     SmallVectorImpl<MachineOperand> &Cond,
                     bool AllowModify) const override;

  unsigned insertBranch(MachineBasicBlock &MBB, MachineBasicBlock *TBB,
                        MachineBasicBlock *FBB, ArrayRef<MachineOperand> Cond,
                        const DebugLoc &DL, int *BytesAdded = nullptr) const
      override;

  unsigned removeBranch(MachineBasicBlock &MBB,
                        int *BytesRemoved = nullptr) const override;

  bool
  reverseBranchCondition(SmallVectorImpl<MachineOperand> &Cond) const override;

  bool isSchedulingBoundary(const MachineInstr &MI,
                            const MachineBasicBlock *MBB,
                            const MachineFunction &MF) const override;

  MachineBasicBlock *getBranchDestBlock(const MachineInstr &MI) const override;

  bool isPredicable(const MachineInstr &MI) const override;
  bool isPredicated(const MachineInstr &MI) const override;
  bool canInsertSelect(const MachineBasicBlock &MBB,
                       ArrayRef<MachineOperand> Cond, Register DstReg,
                       Register TrueReg, Register FalseReg, int &CondCycles,
                       int &TrueCycles, int &FalseCycles) const override;
  void insertSelect(MachineBasicBlock &MBB, MachineBasicBlock::iterator I,
                    const DebugLoc &DL, Register DstReg,
                    ArrayRef<MachineOperand> Cond, Register TrueReg,
                    Register FalseReg) const override;
  unsigned getPredicationCost(const MachineInstr &MI) const override;
  bool isProfitableToIfCvt(MachineBasicBlock &MBB, unsigned NumCycles,
                           unsigned ExtraPredCycles,
                           BranchProbability Probability) const override;
  bool PredicateInstruction(MachineInstr &MI,
                            ArrayRef<MachineOperand> Pred) const override;
};

} // namespace llvm

#endif
