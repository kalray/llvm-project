//===-- KVXTargetTransformInfo.h - KVX specific TTI -------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file a TargetTransformInfo::Concept conforming object specific
// to the KVX target machine. It uses the target's detailed
// information to provide more precise answers to certain TTI queries,
// while letting the target independent and default TTI
// implementations handle the rest.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_KVX_KVXTARGETTRANSFORMINFO_H
#define LLVM_LIB_TARGET_KVX_KVXTARGETTRANSFORMINFO_H

#include "KVX.h"
#include "KVXTargetMachine.h"
#include "llvm/Analysis/TargetTransformInfo.h"
#include "llvm/CodeGen/BasicTTIImpl.h"
#include "llvm/CodeGen/TargetLowering.h"

namespace llvm {

class KVXTTIImpl : public BasicTTIImplBase<KVXTTIImpl> {
  using BaseT = BasicTTIImplBase<KVXTTIImpl>;
  using TTI = TargetTransformInfo;

  friend BaseT;

  const TargetMachine *TM;
  const KVXSubtarget *ST;
  const KVXTargetLowering *TLI;
  const KVXSubtarget *getST() const { return ST; }
  const KVXTargetLowering *getTLI() const { return TLI; }

public:
  explicit KVXTTIImpl(const KVXTargetMachine *TM, const Function &F)
      : BaseT(TM, F.getParent()->getDataLayout()), TM(TM),
        ST(TM->getSubtargetImpl(F)), TLI(ST->getTargetLowering()) {}

  void getUnrollingPreferences(Loop *L, ScalarEvolution &SE,
                               TTI::UnrollingPreferences &UP,
                               OptimizationRemarkEmitter *ORE);

  bool isHardwareLoopProfitable(Loop *L, ScalarEvolution &SE,
                                AssumptionCache &AC, TargetLibraryInfo *LibInfo,
                                HardwareLoopInfo &HWLoopInfo);
  bool shouldAddRemainderMetaData();
  bool isLoweredToCall(const Function *F);
  bool isLoweredToCall(const CallInst &CI);
  bool isLSRCostLess(const TargetTransformInfo::LSRCost &C1,
                     const TargetTransformInfo::LSRCost &C2) const;
  unsigned getInliningThresholdMultiplier() const;

  TargetTransformInfo::PopcntSupportKind
  getPopcntSupport(unsigned IntTyWidthInBit) const;

  bool shouldExpandReduction(const IntrinsicInst *II) const;

  bool preferInLoopReduction(unsigned Opcode, Type *Ty,
                             TTI::ReductionFlags Flags) const;

  InstructionCost getArithmeticReductionCost(
      unsigned Opcode, VectorType *Ty, Optional<FastMathFlags> FMF,
      TTI::TargetCostKind CostKind = TTI::TCK_RecipThroughput);

  bool
  shouldMaximizeVectorBandwidth(TargetTransformInfo::RegisterKind K) const {
    return true;
  };
  bool enableAggressiveInterleaving(bool LoopHasReductions) const {
    return true;
  }
  bool enableInterleavedAccessVectorization() const { return true; }

  unsigned getNumberOfRegisters(unsigned ClassID) const;
  TypeSize getRegisterBitWidth(bool Vector) const {
    return TypeSize::Fixed(Vector ? 256 : 64);
  }

  const char *getRegisterClassName(unsigned ClassID) const;

  unsigned getRegisterClassForType(bool Vector, Type *Ty) const;

  unsigned getMaxInterleaveFactor(unsigned VF) const { return 3; }

  unsigned getRegUsageForType(Type *Ty) const {
    return Ty->getPrimitiveSizeInBits() / 64;
  }

  InstructionCost getVectorInstrCost(unsigned Opcode, Type *Ty,
                                     unsigned Index) const {
    if (Opcode == Instruction::ShuffleVector)
      return TargetTransformInfoImplBase::getVectorInstrCost(Opcode, Ty, Index);

    return 1;
  }

  InstructionCost getScalarizationOverhead(VectorType *Ty,
                                           const APInt &DemandedElts,
                                           bool Insert, bool Extract);

  bool isTypeLegal(Type *Ty) const { return true; }

  InstructionCost getArithmeticInstrCost(
      unsigned Opcode, Type *Ty, TTI::TargetCostKind CostKind,
      TTI::OperandValueKind Opd1Info = TTI::OK_AnyValue,
      TTI::OperandValueKind Opd2Info = TTI::OK_AnyValue,
      TTI::OperandValueProperties Opd1PropInfo = TTI::OP_None,
      TTI::OperandValueProperties Opd2PropInfo = TTI::OP_None,
      ArrayRef<const Value *> Args = ArrayRef<const Value *>(),
      const Instruction *CxtI = nullptr);


  InstructionCost getIntrinsicInstrCost(const IntrinsicCostAttributes &ICA,
                                        TTI::TargetCostKind CostKind);

  InstructionCost getExtractWithExtendCost(unsigned Opcode, Type *Dst,
                                           VectorType *VecTy,
                                           unsigned Index = -1);
  InstructionCost
  getCastInstrCost(unsigned Opcode, Type *Dst, Type *Src,
                   TTI::CastContextHint CCH,
                   TTI::TargetCostKind CostKind = TTI::TCK_SizeAndLatency,
                   const Instruction *I = nullptr);

  InstructionCost getCmpSelInstrCost(unsigned Opcode, Type *ValTy, Type *CondTy,
                                     CmpInst::Predicate VecPred,
                                     TTI::TargetCostKind CostKind,
                                     const Instruction *I = nullptr);

private:
  bool isHardwareLoopProfitableCheck(Loop *L, ScalarEvolution &SE);
};

} // end namespace llvm

#endif // LLVM_LIB_TARGET_KVX_KVXTARGETTRANSFORMINFO_H
