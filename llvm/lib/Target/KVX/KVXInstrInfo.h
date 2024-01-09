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

#include "llvm/CodeGen/TargetInstrInfo.h"

#define GET_INSTRINFO_HEADER
#include "KVXGenInstrInfo.inc"

namespace llvm {

class KVXSubtarget;

namespace KVX {
enum class ComparisonMod {
  NE = 0,
  EQ = 1,
  LT = 2,
  GE = 3,
  LE = 4,
  GT = 5,
  LTU = 6,
  GEU = 7,
  LEU = 8,
  GTU = 9,
  ALL = 10,
  NALL = 11,
  ANY = 12,
  NONE = 13
};

enum class ScalarcondMod {
  DNEZ = 0,
  DEQZ = 1,
  DLTZ = 2,
  DGEZ = 3,
  DLEZ = 4,
  DGTZ = 5,
  ODD = 6,
  EVEN = 7,
  WNEZ = 8,
  WEQZ = 9,
  WLTZ = 10,
  WGEZ = 11,
  WLEZ = 12,
  WGTZ = 13
};
} // namespace KVX

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

  ScheduleHazardRecognizer *
  CreateTargetMIHazardRecognizer(const InstrItineraryData *II,
                                 const ScheduleDAGMI *DAG) const override;

  bool analyzeBranch(MachineBasicBlock &MBB, MachineBasicBlock *&TBB,
                     MachineBasicBlock *&FBB,
                     SmallVectorImpl<MachineOperand> &Cond,
                     bool AllowModify) const override;

  bool analyzeBranchPipeliner(MachineBasicBlock &MBB, MachineBasicBlock *&TBB,
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

  bool isSoloInstruction(const MachineInstr &MI) const override;

  bool isSchedulingBoundary(const MachineInstr &MI,
                            const MachineBasicBlock *MBB,
                            const MachineFunction &MF) const override;

  bool isSchedulingBoundaryPostRA(const MachineInstr &MI,
                                  const MachineBasicBlock *MBB,
                                  const MachineFunction &MF) const override;

  bool getBaseAndOffsetPosition(const MachineInstr &MI, unsigned &BasePos,
                                unsigned &OffsetPos) const override;

  bool getMemOperandsWithOffsetWidth(
      const MachineInstr &MI, SmallVectorImpl<const MachineOperand *> &BaseOps,
      int64_t &Offset, bool &OffsetIsScalable, unsigned &Width,
      const TargetRegisterInfo *TRI) const override;

  bool areMemAccessesTriviallyDisjoint(const MachineInstr &MIa,
                                       const MachineInstr &MIb) const override;

  bool getIncrementValue(const MachineInstr &MI, int &Value) const override;

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

  unsigned getInstSizeInBytes(const MachineInstr &MI) const override;
  bool isProfitableToDupForIfCvt(MachineBasicBlock &MBB, unsigned NumCycles,
                                 BranchProbability Probability) const override;

  bool SubsumesPredicate(ArrayRef<MachineOperand> Pred1,
                         ArrayRef<MachineOperand> Pred2) const override;

  bool isProlog(const MachineInstr *MI) const;
  bool isEpilog(const MachineInstr *MI) const;

  const KVXSubtarget &getSubtarget() const;

  bool isBranchOffsetInRange(unsigned, int64_t) const override;

  virtual void insertIndirectBranch(MachineBasicBlock &MBB,
                                    MachineBasicBlock &NewDestBB,
                                    MachineBasicBlock &RestoreBB,
                                    const DebugLoc &DL, int64_t BrOffset = 0,
                                    RegScavenger *RS = nullptr) const override;

  bool isSafeToMoveRegClassDefs(const TargetRegisterClass *RC) const override;

  std::unique_ptr<PipelinerLoopInfo>
  analyzeLoopForPipelining(MachineBasicBlock *LoopBB) const override;

  int getPipelinerMaxMII() const override { return 100; }
  size_t getBBSizeInBytes(const MachineBasicBlock &BB) const;
  size_t getFuncSizeInBytes(const MachineFunction &MF) const;
  bool isUnconditionalTailCall(const MachineInstr &MI) const override;
  bool canMakeTailCallConditional(SmallVectorImpl<MachineOperand> &Cond,
                                  const MachineInstr &TailCall) const override;
};

} // namespace llvm

#endif
