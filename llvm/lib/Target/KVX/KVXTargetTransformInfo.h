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
      unsigned Opcode, VectorType *Ty, std::optional<FastMathFlags> FMF,
      TTI::TargetCostKind CostKind = TTI::TCK_RecipThroughput);

  bool
  shouldMaximizeVectorBandwidth(TargetTransformInfo::RegisterKind K) const {
    return true;
  };
  bool enableAggressiveInterleaving(bool LoopHasReductions) const {
    return !ST->isV1();
  }

  bool enableInterleavedAccessVectorization() const { return !ST->isV1(); }

  unsigned getNumberOfRegisters(unsigned ClassID) const;
  TypeSize getRegisterBitWidth(bool Vector) const {
    return TypeSize::getFixed(Vector ? 256 : 64);
  }

  const char *getRegisterClassName(unsigned ClassID) const;

  unsigned getRegisterClassForType(bool Vector, Type *Ty) const;

  unsigned getMaxInterleaveFactor(ElementCount VF) const {
    // FIXME: Workaround for VPPlan + InsCombine bugs.
    // Enforcing interleave when no vectorization is done (VF = 1)
    // generates a useless runtime test for this code, for
    // InterleaveCount (IC = 2), as iteration count is known to be
    // a multiple of 2. It also generates redundant code.
    // Appart from that, it creates a useless operation %0 = %index + 0
    // which InstructionCombiner bug breaks the code.
    // Input C code:
    // int my_parityl(unsigned long x) {
    //   int i;
    //   int count = 0;
    //   for (i = 0; i < 8 * sizeof(unsigned long); i++)
    //     if (x & ((unsigned long)1 << i))
    //       count++;
    //   return count & 1;
    // };
    // Once the InstCombine bug is fixed, as well the useless intruction
    // generation in VPlan, we should reconsider the performance impact
    // of this, and perhaps prevent useless code duplication.
    if (VF.isScalar())
      return 1;

    // Not knowing the largest element size is rather limiting,
    // so let's assume we operate with 32 bit values. We would
    // like to operate in 8 x 32 elements per iteration so we
    // compute:
    return std::max(1u, 8u / VF.getKnownMinValue());
  }

  unsigned getRegUsageForType(Type *Ty) const {
    if (!Ty->isSized())
      return 0;

    return std::max(1ul, Ty->getPrimitiveSizeInBits() / 64);
  }

  InstructionCost getVectorInstrCost(unsigned Opcode, Type *Val,
                                     TTI::TargetCostKind CostKind,
                                     unsigned Index = -1, Value *Op0 = nullptr,
                                     Value *Op1 = nullptr) const;

  InstructionCost getVectorInstrCost(const Instruction &I, Type *Val,
                                     TTI::TargetCostKind CostKind,
                                     unsigned Index = -1) {
  return getVectorInstrCost(I.getOpcode(), Val, CostKind, Index);
}


  InstructionCost getScalarizationOverhead(VectorType *Ty,
                                           const APInt &DemandedElts,
                                           bool Insert, bool Extract,
                                           TTI::TargetCostKind CostKind);

  bool isTypeLegal(Type *Ty) const;

  InstructionCost getArithmeticInstrCost(
      unsigned Opcode, Type *Ty, TTI::TargetCostKind CostKind,
      TTI::OperandValueInfo Op1Info = {TTI::OK_AnyValue, TTI::OP_None},
      TTI::OperandValueInfo Op2Info = {TTI::OK_AnyValue, TTI::OP_None},
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

  InstructionCost getMinMaxReductionCost(Intrinsic::ID IID, VectorType *Ty,
                                         FastMathFlags FMF,
                                         TTI::TargetCostKind CostKind);

  InstructionCost getCFInstrCost(unsigned Opcode, TTI::TargetCostKind CostKind,
                                 const Instruction *I = nullptr);

private:
  bool isHardwareLoopProfitableCheck(Loop *L, ScalarEvolution &SE);
};

} // end namespace llvm

#endif // LLVM_LIB_TARGET_KVX_KVXTARGETTRANSFORMINFO_H
