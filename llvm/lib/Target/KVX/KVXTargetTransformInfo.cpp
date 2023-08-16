//===-- KVXTargetTransformInfo.cpp - KVX specific TTI ---------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "KVXTargetTransformInfo.h"
#include "llvm/Analysis/TargetTransformInfo.h"
#include "llvm/CodeGen/BasicTTIImpl.h"
#include "llvm/CodeGen/CostTable.h"
#include "llvm/CodeGen/TargetLowering.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/IntrinsicsKVX.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Transforms/Utils/UnrollLoop.h"

using namespace llvm;
#define DEBUG_TYPE "KVXTTI"

static cl::opt<unsigned> MinHwLoopTripCount(
    "min-hwloop-trip-count", cl::Hidden, cl::init(5),
    cl::desc("Set the minimum trip count for a profitable hardware loop"));

bool KVXTTIImpl::isLoweredToCall(const CallInst &CI) {
  if (const Function *F = CI.getCalledFunction()) {
    if (!F->isIntrinsic())
      return isLoweredToCall(F);

    // Some intrinsics won't lower to call in given circumstances
    if (isa<FPMathOperator>(CI) && CI.getFastMathFlags().noNaNs()) {
      switch (F->getIntrinsicID()) {
      case Intrinsic::maxnum:
      case Intrinsic::minnum:
        return false;
      }
    }
    return isLoweredToCall(F);
  }
  LLVM_DEBUG(dbgs() << "Don't know the function name.\n");
  return true;
}

bool KVXTTIImpl::isLoweredToCall(const Function *F) {
  if (F->isIntrinsic()) {
    auto ID = F->getIntrinsicID();
    // KVX instrinsics turn into instructions
    if (ID >= Intrinsic::kvx_abd)
      return false;
  }

  StringRef Name = F->getName();
  switch (F->getIntrinsicID()) {
  case Intrinsic::bitreverse:
  case Intrinsic::bswap:
  case Intrinsic::ctlz:
  case Intrinsic::ctpop:
  case Intrinsic::dbg_addr:
  case Intrinsic::dbg_declare:
  case Intrinsic::dbg_label:
  case Intrinsic::dbg_value:
  case Intrinsic::donothing:
  case Intrinsic::fabs:
  case Intrinsic::fma:
  case Intrinsic::fmuladd:
  case Intrinsic::lifetime_end:
  case Intrinsic::lifetime_start:
  case Intrinsic::sadd_sat:
  case Intrinsic::ssub_sat:
    return false;
  default:
    break;
  }

  if (Name == "fabs" || Name == "fabsf" || Name == "fabsl" || Name == "abs" ||
      Name == "labs" || Name == "llabs")
    return false;
  return true;
}

bool KVXTTIImpl::isHardwareLoopProfitableCheck(Loop *L, ScalarEvolution &SE) {
  if (L->getLoopLatch() == nullptr || L->getExitBlock() == nullptr ||
      L->getLoopPreheader() == nullptr || L->getHeader() == nullptr) {
    LLVM_DEBUG(
        dbgs() << "Not a well formed loop. Can't turn it to hardware loop.\n");
    return false;
  }

  LLVM_DEBUG(dbgs() << "Checking if loop of header block "
                    << L->getHeader()->getName()
                    << " can be optimized as hardware loop.\n");

  if (!SE.hasLoopInvariantBackedgeTakenCount(L))
    return false;

  const SCEV *BackedgeTakenCount = SE.getBackedgeTakenCount(L);
  if (isa<SCEVCouldNotCompute>(BackedgeTakenCount))
    return false;

  const SCEV *TripCountSCEV = SE.getAddExpr(
      BackedgeTakenCount, SE.getOne(BackedgeTakenCount->getType()));

  if (SE.getUnsignedRangeMax(TripCountSCEV).getBitWidth() > 64)
    return false;

  // Avoid hardware loops if tripcount is known at compile time and is less or
  // equal than 5 in which case a conventional loop using a compare and a branch
  // instruction would cost less than a loopdo instruction which takes 5 cycles
  // to initialize
  if ((TripCountSCEV->getSCEVType() == scConstant) &&
      (!cast<SCEVConstant>(TripCountSCEV)
            ->getValue()
            ->uge(MinHwLoopTripCount))) {
    LLVM_DEBUG(dbgs() << "This loop has a Trip Count smaller than "
                      << MinHwLoopTripCount
                      << ". It will "
                         "not be profitable to make a hardware loop of it : "
                      << *TripCountSCEV << ".\n");
    return false;
  }
  // Avoid hardware loops if there is a call inside
  auto MaybeCall = [this](Instruction &I) {
    LLVM_DEBUG(dbgs() << "Looking at inst: " << I << ".\n");
    const KVXTargetLowering *TLI = getTLI();
    unsigned ISD = TLI->InstructionOpcodeToISD(I.getOpcode());
    EVT VT = TLI->getValueType(DL, I.getType(), true);
    if (TLI->getOperationAction(ISD, VT) == TargetLowering::LibCall) {
      LLVM_DEBUG(dbgs() << "It may call!\n");
      return true;
    }

    if (auto *Call = dyn_cast<CallInst>(&I)) {
      bool Ret = isLoweredToCall(*Call);
      LLVM_DEBUG(dbgs() << "It is intrinsic call, and it "
                        << (Ret ? "does" : "doesn't") << " lower to a call!\n");
      return Ret;
    }

    // Filter instructions we know it will be lowered to a libcall
    switch (I.getOpcode()) {
    default:
      break;
    case Instruction::FDiv:
    case Instruction::FRem:
      return (!I.hasAllowReciprocal()) ||
             (I.getType()->getScalarSizeInBits() == 64);
    case Instruction::AtomicCmpXchg:
      return cast<AtomicCmpXchgInst>(I).getPointerAddressSpace() == 1;
    case Instruction::AtomicRMW:
      return cast<AtomicRMWInst>(I).getPointerAddressSpace() == 1;
    case Instruction::UIToFP:
    case Instruction::SIToFP:
      return (I.getType()->getScalarSizeInBits() == 32);
    case Instruction::SRem:
    case Instruction::URem:
    case Instruction::UDiv:
    case Instruction::SDiv:
      if (ConstantInt *CI = dyn_cast<ConstantInt>(I.getOperand(1))) {
        if (isPowerOf2_64(CI->getZExtValue()))
          return false;
      }
      return true;
    }
    return false;
  };

  // Check for inner hardware loops
  auto IsHardwareLoopIntrinsic = [](Instruction &I) {
    if (auto *Call = dyn_cast<IntrinsicInst>(&I)) {
      switch (Call->getIntrinsicID()) {
      default:
        break;
      case Intrinsic::set_loop_iterations:
      case Intrinsic::test_set_loop_iterations:
      case Intrinsic::loop_decrement:
      case Intrinsic::loop_decrement_reg:
        return true;
      }
    }
    return false;
  };

  // Scan the instructions to see if there's any that we know will turn into a
  // call or if this loop is already a hardware loop  or if the number of
  // instructions in the loop are too few.
  auto ScanLoop = [&](Loop *L, bool TestMinLoopSize) {
    int Count = 0;
    for (auto *BB : L->getBlocks()) {
      for (auto &I : *BB) {
        // Count Non debug, Non Pseudo and Non PHI instructions
        if (!I.isDebugOrPseudoInst() && (I.getOpcode() != Instruction::PHI))
          Count++;
        if (MaybeCall(I) || IsHardwareLoopIntrinsic(I))
          return false;
      }
    }
    if (Count <= 3) {
      LLVM_DEBUG(dbgs() << "Empty loop detected. Would be inefficient to "
                           "optimize to a hardware loop\n");
    }
    return (Count > 3) || !TestMinLoopSize;
  };

  // Visit inner loops.
  for (auto *Inner : *L)
    if (!ScanLoop(Inner, false))
      return false;

  if (!ScanLoop(L, true))
    return false;

  if (!L->getUniqueExitBlock())
    return false;

  bool CanFallThroughToExit = false;
  for (auto *BB : successors(L->getLoopLatch())) {
    if (BB == L->getUniqueExitBlock()) {
      CanFallThroughToExit = true;
      break;
    }
  }
  if (!CanFallThroughToExit)
    return false;

  if (MDNode *LoopID = L->getLoopID())
    return !GetUnrollMetadata(LoopID, "llvm.loop.remainder");

  LLVM_DEBUG(dbgs() << "Can be optimized to a hardware loop.\n");
  return true;
}

// TODO: Are there any reasons we would require twiking the enabled
//       features or the cost (e.g. ARMTargetTransformInfo.cpp)?
//       Unrolling may prevent hwloops, e.g.
void KVXTTIImpl::getUnrollingPreferences(Loop *L, ScalarEvolution &SE,
                                         TTI::UnrollingPreferences &UP,
                                         OptimizationRemarkEmitter *ORE) {
  BaseT::getUnrollingPreferences(L, SE, UP, ORE);
  auto OptLvl = TM->getOptLevel();
  // Disable loop unrolling for Os.
  UP.OptSizeThreshold = 0;
  UP.PartialOptSizeThreshold = 0;
  if (OptLvl < CodeGenOpt::Default)
    return;

  UP.Partial = true;
  UP.Runtime = true;
  if (TM->getOptLevel() < CodeGenOpt::Aggressive)
    return;

  UP.UnrollRemainder = true;
  UP.Force = true;
}
bool KVXTTIImpl::shouldAddRemainderMetaData() { return true; }
bool KVXTTIImpl::isHardwareLoopProfitable(Loop *L, ScalarEvolution &SE,
                                          AssumptionCache &AC,
                                          TargetLibraryInfo *LibInfo,
                                          HardwareLoopInfo &HWLoopInfo) {

  if (!isHardwareLoopProfitableCheck(L, SE))
    return false;

  // TODO: Check if the trip count calculation is expensive. If L is the
  // inner loop but we know it has a low trip count, calculating that trip
  // count (in the parent loop) may be detrimental. Perhaps it's better to
  // unroll it.
  LLVMContext &C = L->getHeader()->getContext();
  HWLoopInfo.CounterInReg = false;
  HWLoopInfo.IsNestingLegal = false;
  HWLoopInfo.PerformEntryTest = false;
  HWLoopInfo.CountType = Type::getInt64Ty(C);
  HWLoopInfo.LoopDecrement = ConstantInt::get(HWLoopInfo.CountType, 1);
  return true;
}

unsigned KVXTTIImpl::getInliningThresholdMultiplier() const {
  switch (TM->getOptLevel()) {
  case CodeGenOpt::Aggressive:
    return 3;
  case CodeGenOpt::Default:
    return 2;
  default:
    return 1;
  }
}

bool KVXTTIImpl::isLSRCostLess(const TargetTransformInfo::LSRCost &C1,
                               const TargetTransformInfo::LSRCost &C2) const {
  // Care first for num-regs then number of inst.
  // Care last for ImmCost and scale.
  // TODO: Check if NumRegs really matches the actual use of registers.
  // We might be able to invert NumRegs and Insns if we know that reg
  // pressure is low or that it won't spill.
  return std::tie(C1.NumRegs, C1.Insns, C1.AddRecCost, C1.NumIVMuls,
                  C1.SetupCost, C1.NumBaseAdds, C1.ImmCost, C1.ScaleCost) <
         std::tie(C2.NumRegs, C2.Insns, C2.AddRecCost, C2.NumIVMuls,
                  C2.SetupCost, C2.NumBaseAdds, C2.ImmCost, C2.ScaleCost);
}

TargetTransformInfo::PopcntSupportKind
KVXTTIImpl::getPopcntSupport(unsigned IntTyWidthInBit) const {
  switch (IntTyWidthInBit) {
  case 32:
  case 64:
    return TargetTransformInfo::PSK_FastHardware;
  default:
    return TargetTransformInfo::PSK_Software;
  }
}

bool KVXTTIImpl::shouldExpandReduction(const IntrinsicInst *II) const {

  Type *OpTyp = II->getOperand(0)->getType();
  if (OpTyp->isFloatTy())
    return true;

  switch (II->getIntrinsicID()) {
  default:
  case Intrinsic::vector_reduce_add:
  case Intrinsic::vector_reduce_and:
  case Intrinsic::vector_reduce_or:
  case Intrinsic::vector_reduce_smax:
  case Intrinsic::vector_reduce_smin:
  case Intrinsic::vector_reduce_umax:
  case Intrinsic::vector_reduce_umin:
  case Intrinsic::vector_reduce_xor:
    return false;
  // These reductions are not present in KVX
  case Intrinsic::vector_reduce_fadd:
  case Intrinsic::vector_reduce_fmax:
  case Intrinsic::vector_reduce_fmin:
  case Intrinsic::vector_reduce_fmul:
  case Intrinsic::vector_reduce_mul:
    return true;
  }
}

bool KVXTTIImpl::preferInLoopReduction(unsigned Opcode, Type *Ty,
                                       TTI::ReductionFlags Flags) const {

  if (Ty->isFloatTy())
    return false;

  switch (Opcode) {
  case ISD::ADD:
    return true;
  // These reductions haven't been implemented:
  case ISD::AND:
  case ISD::OR:
  case ISD::XOR:
  case ISD::SMAX:
  case ISD::SMIN:
  case ISD::UMAX:
  case ISD::UMIN:
  // Any other is not supported.
  default:
    return false;
  }
}

unsigned KVXTTIImpl::getNumberOfRegisters(unsigned ClassID) const {
  #define REG(X) \
  case KVX::X ## RegRegClassID: \
    return KVX::X ## RegRegClass.getNumRegs()

  switch (ClassID) {
    REG(Copro);
    REG(Block);
    REG(Vector);
    REG(Wide);
    REG(Matrix);
    REG(Buffer8);
    REG(Buffer16);
    REG(Paired);
    REG(Quad);
    REG(System);
    default:
      return 64;
  }
}

const char *KVXTTIImpl::getRegisterClassName(unsigned ClassID) const {
  #define REGNAME(X) \
  case KVX::X ## RegRegClassID: \
    return "KVX::" # X  "RegRegClass"

  switch (ClassID) {
    REGNAME(Copro);
    REGNAME(Block);
    REGNAME(Vector);
    REGNAME(Wide);
    REGNAME(Matrix);
    REGNAME(Buffer8);
    REGNAME(Buffer16);
    REGNAME(Paired);
    REGNAME(Quad);
    REGNAME(System);
    default:
      return "KVX::SingleRegRegClass";
  }
}

unsigned KVXTTIImpl::getRegisterClassForType(bool Vector, Type *Ty) const {
  if (!Ty) {
    if (!Vector)
      return KVX::SingleRegRegClassID;
    return KVX::QuadRegRegClassID;
  }

  if (Ty->isVectorTy() && Ty->getScalarSizeInBits() == 1) {
    switch (Ty->getPrimitiveSizeInBits()) {
    case 64:
      return KVX::CoproRegRegClassID;
    case 128:
      return KVX::BlockRegRegClassID;
    case 256:
      return KVX::VectorRegRegClassID;
    case 512:
      return KVX::WideRegRegClassID;
    case 1024:
      return KVX::MatrixRegRegClassID;
    case 2048:
      return KVX::Buffer8RegRegClassID;
    case 4096:
      return KVX::Buffer16RegRegClassID;
    default:
      return KVX::SingleRegRegClassID;
    }
  }

  unsigned Size = Ty->getPrimitiveSizeInBits();
  if (Size <= 64)
    return KVX::SingleRegRegClassID;

  if (Size <= 128)
    return KVX::PairedRegRegClassID;

  if (Size <= 256)
    return KVX::QuadRegRegClassID;

  return KVX::SingleRegRegClassID;
}

InstructionCost
KVXTTIImpl::getArithmeticReductionCost(unsigned Opcode, VectorType *Ty,
                                       Optional<FastMathFlags> FMF,
                                       TTI::TargetCostKind CostKind) {

  auto Sz = Ty->getPrimitiveSizeInBits().getFixedSize();
  // Fixme: FP and V1 costs are really wrong
  if (Ty->isFPOrFPVectorTy() || Sz > 512)
    return BaseT::getArithmeticReductionCost(Opcode, Ty, FMF, CostKind);

  switch (Opcode) {
  case Instruction::Add:
  case Instruction::And:
  case Instruction::Or:
  case Instruction::Xor:
    break;
  default:
    return BaseT::getArithmeticReductionCost(Opcode, Ty, FMF, CostKind);
  }
  if (Sz < 64)
    return 2 + ST->isV1();

  auto Ret = Log2_32(Sz / 32);

  if (ST->isV1() && !(Ty->getScalarSizeInBits() == 64))
    Ret += Ty->getElementCount().getFixedValue();

  return Ret;
}

InstructionCost
KVXTTIImpl::getMinMaxReductionCost(VectorType *Ty, VectorType *CondTy,
                                   bool IsUnsigned,
                                   TTI::TargetCostKind CostKind) {
  // Fixme: FP and V1 costs are really wrong
  if (Ty->isFPOrFPVectorTy() || ST->isV1())
    return BaseT::getMinMaxReductionCost(Ty, CondTy, IsUnsigned, CostKind);

  // V2 Hack: we can simply use the cost of an And reduction for the type.
  return getArithmeticReductionCost(Instruction::And, Ty, FastMathFlags(),
                                    CostKind);
}

InstructionCost KVXTTIImpl::getArithmeticInstrCost(
    unsigned Opcode, Type *Ty, TTI::TargetCostKind CostKind,
    TTI::OperandValueKind Opd1Info, TTI::OperandValueKind Opd2Info,
    TTI::OperandValueProperties Opd1PropInfo,
    TTI::OperandValueProperties Opd2PropInfo, ArrayRef<const Value *> Args,
    const Instruction *CxtI) {
  if (CostKind != TTI::TCK_RecipThroughput)
    return BaseT::getArithmeticInstrCost(Opcode, Ty, CostKind, Opd1Info,
                                         Opd2Info, Opd1PropInfo, Opd2PropInfo,
                                         Args, CxtI);
  // Legalize the type.
  std::pair<InstructionCost, MVT> LT = TLI->getTypeLegalizationCost(DL, Ty);

  auto *FVTy = dyn_cast<FixedVectorType>(Ty);
  unsigned Cost, TypeSize = Ty->getScalarSizeInBits(),
                 NumElems = FVTy ? FVTy->getNumElements() : 1;

  int ISD = TLI->InstructionOpcodeToISD(Opcode);
  assert(ISD && "Invalid opcode");

  switch (ISD) {
  case ISD::FMUL:
  case ISD::FADD:
    Cost = (TypeSize * NumElems) / getRegisterBitWidth(false); // bitwidth/64
    Cost = Cost ? Cost : 1;
    return LT.first * 2 * Cost;
  }
  return BaseT::getArithmeticInstrCost(Opcode, Ty, CostKind, Opd1Info, Opd2Info,
                                       Opd1PropInfo, Opd2PropInfo, Args, CxtI);
}

InstructionCost KVXTTIImpl::getScalarizationOverhead(VectorType *Ty,
                                                     const APInt &DemandedElts,
                                                     bool Insert,
                                                     bool Extract) {
  unsigned Size, ScalarSize = Ty->getScalarSizeInBits(),
                 RegWidth = getRegisterBitWidth(false);

  // non-complex insert/extract cases
  auto *FVTy = dyn_cast<FixedVectorType>(Ty);
  Size = ScalarSize * (FVTy ? FVTy->getNumElements() : 1);
  if (Size == RegWidth || Size == RegWidth * 2 || Size == RegWidth * 4) {
    return 1;
  }

  return BaseT::getScalarizationOverhead(Ty, DemandedElts, Insert, Extract);
}

InstructionCost
KVXTTIImpl::getIntrinsicInstrCost(const IntrinsicCostAttributes &ICA,
                                  TTI::TargetCostKind CostKind) {

#define REDUCTION(type, Type)                                                  \
  case Intrinsic::vector_reduce_##type:                                        \
    return getArithmeticReductionCost(                                         \
        Instruction::Type, static_cast<VectorType *>(ICA.getArgTypes()[0]),    \
        FastMathFlags::getFast(), CostKind);

#define MINMAXRED(type, Type)                                                  \
  case Intrinsic::vector_reduce_##type:                                        \
    return getMinMaxReductionCost
  auto Opcode = ICA.getID();
  switch (Opcode) {
    REDUCTION(add, Add)
    REDUCTION(and, And)
    REDUCTION(or, Or)
    REDUCTION(xor, Xor)
  default:
    break;
  }
  auto Cost = BaseT::getIntrinsicInstrCost(ICA, CostKind);
  return Cost;
}

InstructionCost KVXTTIImpl::getExtractWithExtendCost(unsigned Opcode, Type *Dst,
                                                     VectorType *VecTy,
                                                     unsigned Index) {
  auto IC = BaseT::getExtractWithExtendCost(Opcode, Dst, VecTy, Index);
  LLVM_DEBUG(dbgs() << "getExtractWithExtendCost: " << IC << Opcode << ' '
                    << *Dst << ' ' << Index << '\n');
  return IC;
}

InstructionCost KVXTTIImpl::getCmpSelInstrCost(unsigned Opcode, Type *ValTy,
                                               Type *CondTy,
                                               CmpInst::Predicate VecPred,
                                               TTI::TargetCostKind CostKind,
                                               const Instruction *I) {
  if (!ValTy->isVectorTy())
    return BaseT::getCmpSelInstrCost(Opcode, ValTy, CondTy, VecPred, CostKind,
                                     I);

  // FIXME: Make vector select / compare costs absurd blocking until properly
  // handled during lowering.
  return InstructionCost(70000);
}

InstructionCost KVXTTIImpl::getCastInstrCost(unsigned Opcode, Type *Dst,
                                             Type *Src,
                                             TTI::CastContextHint CCH,
                                             TTI::TargetCostKind CostKind,
                                             const Instruction *I) {
#define assertM(COND, TXT)                                                     \
  if (!(COND)) {                                                               \
    errs() << TXT << ":" << *Src << " == (" << Opcode << ") ==> " << *Dst      \
           << '\n';                                                            \
    abort();                                                                   \
  }
  // Sanity check
  assertM(Dst->isSized() && Src->isSized(), "Cast with non-sized types");

  switch (Opcode) {
  case Instruction::BitCast:
    assertM(Dst->getPrimitiveSizeInBits() == Src->getPrimitiveSizeInBits(),
            "Bitcast of types of different size.") break;
  case Instruction::FPTrunc:
  case Instruction::Trunc:
    assertM(Dst->getPrimitiveSizeInBits() < Src->getPrimitiveSizeInBits(),
            "Truncated type is not smaller than original.") break;
  case Instruction::SExt:
  case Instruction::ZExt:
  case Instruction::FPExt:
    assertM(Dst->getPrimitiveSizeInBits() > Src->getPrimitiveSizeInBits(),
            "Extended type is not larger than original.") break;
  default:
    break;
  }

  if (!(isPowerOf2_32(Src->getScalarSizeInBits()) &&
        isPowerOf2_32(Dst->getScalarSizeInBits())))
    return BaseT::getCastInstrCost(Opcode, Dst, Src, CCH, CostKind, I);

  // How many bits of the output can we generate per bundle?
  unsigned BitWidth = 256;
  bool IsFP = false;
  switch (Opcode) {
  default:
    return BaseT::getCastInstrCost(Opcode, Dst, Src, CCH, CostKind, I);
  // FIXME: Forbid bitvector casts until properly handled in backend during
  // lowering.
  case Instruction::BitCast:
    if (Src->isVectorTy() && !Dst->isVectorTy() &&
        Src->getScalarSizeInBits() == 1)
      return 70000;
    return 0;

  case Instruction::FPExt:
    IsFP = true;
    BitWidth = 128; // 2 x LITLE
    break;

  case Instruction::FPTrunc:
    IsFP = true;
    BitWidth = 64; // 2 x LITLE
    std::swap(Src, Dst);
    break;

  case Instruction::Trunc:
    BitWidth = 128; // 4 x TINY 2X -> 2X
    std::swap(Src, Dst);
    break;

  case Instruction::SExt:
  case Instruction::ZExt:
    // 4 x TINY -> 256
    break;
  }

  if (!IsFP && !Dst->isVectorTy())
    return 1;

  unsigned Cost = 0;
  for (unsigned SrcSz = Src->getPrimitiveSizeInBits(),
                DstSz = Dst->getPrimitiveSizeInBits();
       SrcSz < DstSz; DstSz /= 2)
    Cost += std::max(1u, DstSz / BitWidth);

  if (IsFP || Dst->getScalarSizeInBits() != 64)
    return Cost;

  if (!Dst->isVectorTy())
    return 1;

  return std::min(
      static_cast<VectorType *>(Dst)->getElementCount().getKnownMinValue(),
      Cost);
}
