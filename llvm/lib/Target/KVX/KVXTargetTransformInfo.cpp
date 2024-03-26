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
#include "llvm/IR/Intrinsics.h"
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
  if (OptLvl < CodeGenOptLevel::Default)
    return;

  UP.UnrollRemainder = true;
  UP.Runtime = true;
  UP.Force = true;

  UP.DefaultUnrollRuntimeCount = 8;
  UP.MaxCount = 8;
  UP.FullUnrollMaxCount = 4;
  if (OptLvl < CodeGenOptLevel::Aggressive)
    return;

  UP.Partial = true;
  UP.UnrollAndJam = true;
  UP.UnrollAndJamInnerLoopThreshold = 60;
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
  case CodeGenOptLevel::Aggressive:
    return 3;
  case CodeGenOptLevel::Default:
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
    REG(Single);
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
    REGNAME(Single);
  }
}

unsigned KVXTTIImpl::getRegisterClassForType(bool Vector, Type *Ty) const {
  if (!Ty)
    return Vector ? KVX::QuadRegRegClassID : KVX::SingleRegRegClassID;

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

  return TargetTransformInfoImplBase::getRegisterClassForType(Vector, Ty);
}

InstructionCost
KVXTTIImpl::getArithmeticReductionCost(unsigned Opcode, VectorType *Ty,
                                       std::optional<FastMathFlags> FMF,
                                       TTI::TargetCostKind CostKind) {

  if (CostKind != TTI::TCK_RecipThroughput)
    return BaseT::getArithmeticReductionCost(Opcode, Ty, FMF, CostKind);

  if (Ty->getScalarSizeInBits() < 8) {
    LLVM_DEBUG(dbgs() << "Invalid, reduction: " << Opcode << ", ";
               Ty->print(dbgs()); dbgs() << '\n');
    return InstructionCost::getInvalid();
  }
  unsigned Sz = Ty->getPrimitiveSizeInBits();
  // Fixme: FP costs are really wrong
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
KVXTTIImpl::getMinMaxReductionCost(Intrinsic::ID IID, VectorType *Ty,
                                         FastMathFlags FMF,
                                         TTI::TargetCostKind CostKind) {
  if (CostKind != TTI::TCK_RecipThroughput)
    return BaseT::getMinMaxReductionCost(IID, Ty, FMF, CostKind);
  // Hack: we can simply use the cost of an And reduction for the type.
  InstructionCost IC = getArithmeticReductionCost(
      Instruction::And, VectorType::getInteger(Ty), FastMathFlags(), CostKind);
  if (Ty->isFPOrFPVectorTy() || ST->isV1())
    IC += Log2_32(Ty->getPrimitiveSizeInBits() / Ty->getScalarSizeInBits()) - 1;

  // CV1 has a fmin/fmax bug.
  if (Ty->isFPOrFPVectorTy() && ST->isV1()) {
    IC *= 2;
  }
  return IC;
}

InstructionCost KVXTTIImpl::getVectorInstrCost(unsigned Opcode, Type *Ty,
                                     TTI::TargetCostKind CostKind,
                                     unsigned Index, Value *Op0, Value *Op1) const {
  auto EltSz = Ty->getScalarSizeInBits();
  if (EltSz < 8) {
    LLVM_DEBUG(dbgs() << "Invalid, bit-vector operation\n");
    return InstructionCost::getInvalid();
  }
  const static unsigned M = std::numeric_limits<unsigned>::max();
  unsigned TypeSize;
  switch (Opcode) {
  // TODO: This only treats unhandled cases of ShuffleVector
  // that are not treated by ShuffleKind that uses the
  // getShuffleCost hook. It will return a negative value which
  // should mean don't know, but I'm not sure the vectorizer is
  // considering like that.
  case ISD::VECTOR_SHUFFLE:
    return Ty->getPrimitiveSizeInBits() / Ty->getScalarSizeInBits();

  case ISD::INSERT_VECTOR_ELT:
  case ISD::INSERT_SUBVECTOR:
    return (Index == M) ? 3 : 1;

  case ISD::EXTRACT_SUBVECTOR:
    TypeSize = Ty->getPrimitiveSizeInBits();
    break;
  default:
    TypeSize = Ty->getScalarSizeInBits();
    break;
  }

  auto SingleRegWidth = getRegisterBitWidth(false);
  // Probably an variable index
  if (Index == M)
    return 3;

  return ((Index * TypeSize) % SingleRegWidth) ? 1 : 0;
}

InstructionCost KVXTTIImpl::getArithmeticInstrCost(
      unsigned Opcode, Type *Ty, TTI::TargetCostKind CostKind,
      TTI::OperandValueInfo Op1Info, TTI::OperandValueInfo Op2Info,
      ArrayRef<const Value *> Args, const Instruction *CxtI) {
  if (CostKind != TTI::TCK_RecipThroughput)
    return BaseT::getArithmeticInstrCost(Opcode, Ty, CostKind, Op1Info,
                                         Op2Info, Args, CxtI);
  // Legalize the type.
  std::pair<InstructionCost, MVT> LT = getTypeLegalizationCost(Ty);

  if (Ty->isVectorTy() && (Ty->getScalarSizeInBits() < 8) &&
      !Ty->isPtrOrPtrVectorTy()) {
    LLVM_DEBUG(dbgs() << "Invalid arithmetic instruction: " << Opcode << ", "
                      << *Ty << '\n');
    return InstructionCost::getInvalid();
  }
  if (LT.first == 0)
    LT.first = 1;

  int ISDi = TLI->InstructionOpcodeToISD(Opcode);
  if (!ISDi)
    return BaseT::getArithmeticInstrCost(Opcode, Ty, CostKind, Op1Info,
                                         Op2Info, Args, CxtI);

  static CostTblEntry CV1[] = {
      {ISD::FDIV, MVT::f16, 17},        {ISD::FDIV, MVT::f32, 65},
      {ISD::FDIV, MVT::f64, 80},        {ISD::SDIV, MVT::i32, 15},
      {ISD::SDIV, MVT::i64, 12},        {ISD::SDIV, MVT::v16i16, 188},
      {ISD::SDIV, MVT::v4i16, 57},      {ISD::SDIV, MVT::v4i32, 90},
      {ISD::SDIV, MVT::v8i16, 101},     {ISD::SDIV, MVT::v8i32, 166},
      {ISD::SDIVREM, MVT::i32, 26},     {ISD::SDIVREM, MVT::i64, 26},
      {ISD::SDIVREM, MVT::v16i16, 194}, {ISD::SDIVREM, MVT::v4i16, 59},
      {ISD::SDIVREM, MVT::v4i32, 94},   {ISD::SDIVREM, MVT::v8i16, 104},
      {ISD::SDIVREM, MVT::v8i32, 175},  {ISD::SREM, MVT::i32, 18},
      {ISD::SREM, MVT::i64, 18},        {ISD::SREM, MVT::v16i16, 191},
      {ISD::SREM, MVT::v4i16, 59},      {ISD::SREM, MVT::v4i32, 91},
      {ISD::SREM, MVT::v8i16, 102},     {ISD::SREM, MVT::v8i32, 166},
      {ISD::UDIV, MVT::i32, 24},        {ISD::UDIV, MVT::i64, 24},
      {ISD::UDIV, MVT::v16i16, 182},    {ISD::UDIV, MVT::v4i16, 54},
      {ISD::UDIV, MVT::v4i32, 84},      {ISD::UDIV, MVT::v8i16, 96},
      {ISD::UDIV, MVT::v8i32, 157},     {ISD::UDIVREM, MVT::i32, 22},
      {ISD::UDIVREM, MVT::i64, 24},     {ISD::UDIVREM, MVT::v16i16, 191},
      {ISD::UDIVREM, MVT::v4i16, 56},   {ISD::UDIVREM, MVT::v4i32, 88},
      {ISD::UDIVREM, MVT::v8i16, 99},   {ISD::UDIVREM, MVT::v8i32, 163},
      {ISD::UREM, MVT::i32, 21},        {ISD::UREM, MVT::i64, 21},
      {ISD::UREM, MVT::v16i16, 186},    {ISD::UREM, MVT::v4i16, 54},
      {ISD::UREM, MVT::v4i32, 85},      {ISD::UREM, MVT::v8i16, 97},
      {ISD::UREM, MVT::v8i32, 158},
  };
  static CostTblEntry CV2[] = {
      {ISD::FDIV, MVT::f16, 17},       {ISD::FDIV, MVT::f32, 65},
      {ISD::FDIV, MVT::f64, 80},       {ISD::SDIV, MVT::i32, 15},
      {ISD::SDIV, MVT::i64, 12},       {ISD::SDIV, MVT::v16i16, 70},
      {ISD::SDIV, MVT::v4i16, 37},     {ISD::SDIV, MVT::v4i32, 58},
      {ISD::SDIV, MVT::v8i16, 42},     {ISD::SDIV, MVT::v8i32, 101},
      {ISD::SDIVREM, MVT::i32, 26},    {ISD::SDIVREM, MVT::i64, 26},
      {ISD::SDIVREM, MVT::v16i16, 73}, {ISD::SDIVREM, MVT::v4i16, 39},
      {ISD::SDIVREM, MVT::v4i32, 62},  {ISD::SDIVREM, MVT::v8i16, 45},
      {ISD::SDIVREM, MVT::v8i32, 110}, {ISD::SREM, MVT::i32, 18},
      {ISD::SREM, MVT::i64, 18},       {ISD::SREM, MVT::v16i16, 73},
      {ISD::SREM, MVT::v4i16, 39},     {ISD::SREM, MVT::v4i32, 91},
      {ISD::SREM, MVT::v8i16, 43},     {ISD::SREM, MVT::v8i32, 101},
      {ISD::UDIV, MVT::i32, 24},       {ISD::UDIV, MVT::i64, 24},
      {ISD::UDIV, MVT::v16i16, 64},    {ISD::UDIV, MVT::v4i16, 34},
      {ISD::UDIV, MVT::v4i32, 84},     {ISD::UDIV, MVT::v8i16, 37},
      {ISD::UDIV, MVT::v8i32, 92},     {ISD::UDIVREM, MVT::i32, 22},
      {ISD::UDIVREM, MVT::i64, 24},    {ISD::UDIVREM, MVT::v16i16, 73},
      {ISD::UDIVREM, MVT::v4i16, 36},  {ISD::UDIVREM, MVT::v4i32, 88},
      {ISD::UDIVREM, MVT::v8i16, 40},  {ISD::UDIVREM, MVT::v8i32, 98},
      {ISD::UREM, MVT::i32, 21},       {ISD::UREM, MVT::i64, 21},
      {ISD::UREM, MVT::v16i16, 68},    {ISD::UREM, MVT::v4i16, 34},
      {ISD::UREM, MVT::v4i32, 85},     {ISD::UREM, MVT::v8i16, 39},
      {ISD::UREM, MVT::v8i32, 93},
  };

  auto VT = TLI->getValueType(DL, Ty);
  if (VT.isSimple())
    if (const auto *Entry =
            CostTableLookup(ST->isV1() ? CV1 : CV2, ISDi, VT.getSimpleVT()))
      return Entry->Cost;

  unsigned BitWidth = 256;
  unsigned ElementSize = LT.second.getScalarSizeInBits();
  bool IsVector = LT.second.isVector();
  if (LT.second.isFloatingPoint()) {
    BitWidth = ST->isV1() ? 64 : 128;

    if (ElementSize == 16 && LT.second.getSizeInBits() < 64 &&
        ISD::FNEG != ISDi)
      LT.first++;

    switch (ISDi) {
    default:
      return BaseT::getArithmeticInstrCost(Opcode, Ty, CostKind, Op1Info,
                                           Op2Info, Args, CxtI);
    case ISD::FNEG:
    case ISD::FABS:
    case ISD::FGETSIGN:
      BitWidth = 256;
      break;
    case ISD::FADD:
    case ISD::FSUB:
      break;
    case ISD::FREM:
    case ISD::FDIV: {
      auto BaseCst = 50;
      // Can this division be lowered to frecw ?
      if (CxtI && CxtI->getFastMathFlags().allowReciprocal() &&
          (ElementSize <= 32))
        BaseCst = 15 + (2 * (ElementSize != 32));
      if (IsVector)
        return BaseCst * LT.second.getVectorMinNumElements();
      return BaseCst;
    }
    case ISD::FMA:
    case ISD::FMUL:
      if (ElementSize == 64)
        BitWidth = 64;
      break;
    }
    return LT.first * std::max(1ul, LT.second.getFixedSizeInBits() / BitWidth);
  }
  if (!IsVector)
    return BaseT::getArithmeticInstrCost(Opcode, Ty, CostKind, Op1Info,
                                         Op2Info, Args, CxtI);
  switch (ISDi) {
  default:
    return BaseT::getArithmeticInstrCost(Opcode, Ty, CostKind, Op1Info,
                                         Op2Info, Args, CxtI);
  case ISD::ROTL:
  case ISD::ROTR:
    if (ElementSize != 32)
      LT.first *= 3;
    LLVM_FALLTHROUGH;
  case ISD::SHL:
  case ISD::SRA:
  case ISD::SRL: {
    const Value *Shift = nullptr;
    if (Args.size() > 1)
      Shift = Args[1];
    else if (CxtI)
      Shift = CxtI->getOperand(1);
    if (Shift) {
      if (!Shift->getType()->isVectorTy())
        break;
      if (ElementSize < 16 && ST->isV1())
        LT.first += 2; // vNi8 -> vNi16 -> vNi8 conversions
      auto *V = dyn_cast<ShuffleVectorInst>(Shift);
      if (V && V->isZeroEltSplat())
        break;
      auto *C = dyn_cast<Constant>(Shift);
      if (C && C->getSplatValue(true)) {
        if (TLI->isOperationLegal(ISDi, LT.second))
          LT.first = 1;
        break;
      }
    }
    LT.first *= (LT.second.getVectorMinNumElements() - 1);
    break;
  }
  case ISD::SDIV:
  case ISD::SDIVREM:
  case ISD::SREM:
  case ISD::UDIV:
  case ISD::UDIVREM:
  case ISD::UREM: {
    if (Args.size() < 2)
      return 25;

    auto *C = dyn_cast<Constant>(Args[1]);

    if (C && C->getType()->isVectorTy())
      C = C->getSplatValue(true);

    if (C) {
      auto I = C->getUniqueInteger();
      if (I.isPowerOf2())
        break;

      if (I.isNegatedPowerOf2()) {
        LT.first++;
        break;
      }
    }
    if (IsVector)
      return 25 * LT.second.getVectorMinNumElements();
    return 25;
  }
  case ISD::MUL: {
    BitWidth = 64;
    break;
  }
  }
  return LT.first * std::max(1ul, LT.second.getFixedSizeInBits() / BitWidth);
}

InstructionCost KVXTTIImpl::getScalarizationOverhead(VectorType *Ty,
                                                  const APInt &DemandedElts,
                                                  bool Insert, bool Extract,
                                                  TTI::TargetCostKind CostKind) {
  unsigned Size, ScalarSize = Ty->getScalarSizeInBits(),
                 RegWidth = getRegisterBitWidth(false);

  if (ScalarSize == 1)
    return InstructionCost::getInvalid(0xDEAD);

  // non-complex insert/extract cases
  auto *FVTy = dyn_cast<FixedVectorType>(Ty);
  Size = ScalarSize * (FVTy ? FVTy->getNumElements() : 1);
  if (Size == RegWidth || Size == RegWidth * 2 || Size == RegWidth * 4)
    return 1;

  return BaseT::getScalarizationOverhead(Ty, DemandedElts, Insert, Extract, CostKind);
}

InstructionCost
KVXTTIImpl::getIntrinsicInstrCost(const IntrinsicCostAttributes &ICA,
                                  TTI::TargetCostKind CostKind) {

#define REDUCTION(op, Type)                                                    \
  case Intrinsic::vector_reduce_##op:                                          \
    return getArithmeticReductionCost(                                         \
        Instruction::Type, static_cast<VectorType *>(ICA.getArgTypes()[0]),    \
        FastMathFlags::getFast(), CostKind)

#define MINMAXRED(op, U)                                                       \
  case Intrinsic::vector_reduce_##op:                                          \
    return getMinMaxReductionCost(                                             \
        static_cast<VectorType *>(ICA.getArgTypes()[0]), nullptr, U, CostKind)

#define CV1_CV2_BITWIDTH(op, CV1, OTHER)                                       \
  case Intrinsic::op:                                                          \
    BitWidth = ST->isV1() ? CV1 : OTHER

#define LITE_TINY(op)                                                          \
  CV1_CV2_BITWIDTH(op, 128, 256);                                              \
  break

#define CV1_EXTENDED(op, CF)                                                   \
  case Intrinsic::op:                                                          \
    if (ST->isV1())                                                            \
      CostFactor *= CF;                                                        \
    break

#define FP_64_128(op)                                                          \
  CV1_CV2_BITWIDTH(op, 64, 128);                                               \
  break

  unsigned BitWidth = 256;
  unsigned CostFactor = 1;
  unsigned LegalizeCost = 0;
  auto Opcode = ICA.getID();

  switch (Opcode) {
    REDUCTION(add, Add);
    REDUCTION(and, And);
    REDUCTION(or, Or);
    REDUCTION(xor, Xor);

    LITE_TINY(sadd_sat);
    LITE_TINY(ssub_sat);

    CV1_EXTENDED(uadd_sat, 3);
    CV1_EXTENDED(usub_sat, 3);

    FP_64_128(fmuladd);
    FP_64_128(fma);
  case Intrinsic::fabs:
    BitWidth = 256;
    break;
  case Intrinsic::fshl:
  case Intrinsic::fshr: {
    // Requires 2 shift + or. The shifts take 2 TINY, so bitwidth / 2.
    // It requires an extra bundle for the or.
    CostFactor = 2;
    BitWidth = 128;
    // If the shift amount is not a splat value it must split the vectors.
    if (ICA.getReturnType()->isVectorTy()) {
      VectorType *VT = cast<VectorType>(ICA.getReturnType());
      const IntrinsicInst *I = ICA.getInst();
      if (I)
        if (auto *Shift = dyn_cast<ShuffleVectorInst>(I->getOperand(2))) {
          auto *V = dyn_cast<ShuffleVectorInst>(Shift);
          if (V && V->isZeroEltSplat()) {
            // From a register value, must compute left/right shift amount
            if (!isa<Constant>(V))
              CostFactor += 1;
            break;
          }
          auto *C = dyn_cast<Constant>(Shift);
          if (C && C->getSplatValue(true))
            break;
        }
      CostFactor *= VT->getElementCount().getKnownMinValue();
    }
    break;
  }
  default:
    LLVM_DEBUG(errs() << "KVX untreated intrinsic: " << ICA.getID() << '\n');
    return BaseT::getIntrinsicInstrCost(ICA, CostKind);
    break;
  }

  Type *Ty = ICA.getReturnType();
  const unsigned VecSize = Ty->getPrimitiveSizeInBits();

  if (ST->isV1() && Ty->getScalarSizeInBits() == 8) {
    BitWidth /= 2;
    // It is possible to extend 64 to 128 bits from vNi8 to vNi16 per cycle,
    // it is also possible to reduce 128 to 64 bits per cycle, so just in type
    // conversion cost the penalty is:
    LegalizeCost += (ICA.getArgs().size() + 1) * std::max(1u, VecSize / 64) +
                    // we also need to count the number of sub-vector insertions
                   // to be done, we can generate 64 bits per cycle, if it is
                   // required. However this can be pipelined with other
                   // operations, so it will not penalize more than 3 cycles.
                   std::min(3u, VecSize / 64);
    // usually there aren't i8 to i16 patterns implementing immediates, if the
    // last operand is immediate, we need to materialize it.
    if (isa<Constant>(ICA.getArgs().back()))
      LegalizeCost += std::max(1u, VecSize / 128);
  }

  return LegalizeCost + CostFactor * std::max(1u, VecSize / BitWidth);
}

InstructionCost KVXTTIImpl::getExtractWithExtendCost(unsigned Opcode, Type *Dst,
                                                     VectorType *VecTy,
                                                     unsigned Index) {
  const static unsigned M = std::numeric_limits<unsigned>::max();
  if (Index == M)
    return 3;

  if (Dst->isVectorTy())
    BaseT::getExtractWithExtendCost(Opcode, Dst, VecTy, Index);

  return 1;
}

bool KVXTTIImpl::isTypeLegal(Type *Ty) const {
  if (!Ty->isSized())
    return true;

  const unsigned EltSize = Ty->getScalarSizeInBits();
  const unsigned Size = Ty->getPrimitiveSizeInBits();

  return (EltSize <= 64 && (EltSize >= 8 || EltSize == 1) && (Size <= 256));
}

InstructionCost KVXTTIImpl::getCmpSelInstrCost(unsigned Opcode, Type *ValTy,
                                               Type *CondTy,
                                               CmpInst::Predicate VecPred,
                                               TTI::TargetCostKind CostKind,
                                               const Instruction *I) {
  if (!ValTy->isVectorTy() || CostKind != TTI::TCK_RecipThroughput)
    return BaseT::getCmpSelInstrCost(Opcode, ValTy, CondTy, VecPred, CostKind,
                                     I);

  // It is possible to compare up to 256 bits per cycle. It takes log2
  // (vector_size_bits / 64) to lower it to 64 bits.
  // If a condition vector type holds less thant 32 bits, it will be
  // required to clear the upper bits of the comparison.
  unsigned BaseCost = 1;
  unsigned PrimSz = ValTy->getPrimitiveSizeInBits();
  if (ST->isV1() && (!ValTy || ValTy->getScalarSizeInBits() == 8)) {
    if (!(CondTy && !CondTy->isVectorTy())) {
      PrimSz *= 2;
      BaseCost += (Instruction::Select != Opcode);
    }
  }
  switch (Opcode) {
  case Instruction::FCmp:
    break;
  case Instruction::Select:
    if (CondTy && !CondTy->isVectorTy())
      break;
    LLVM_FALLTHROUGH;
  case Instruction::ICmp: {
    if (!ValTy || ValTy->getScalarSizeInBits() < 8) {
      LLVM_DEBUG(dbgs() << "Invalid, ICmp/select: "; if (I) I->print(dbgs());
                 dbgs() << "\n");
      return InstructionCost::getInvalid();
    }
  } break;
  default:
    return BaseT::getCmpSelInstrCost(Opcode, ValTy, CondTy, VecPred, CostKind,
                                     I);
  }

  return BaseCost * std::max(1u, PrimSz / 256);
}

unsigned KVXTTIImpl::getNumberOfParts(Type *Tp) {
  // vXi1 vectors are produced from control flow operations.
  // Always scalaryze them.
  if (Tp->isVectorTy()) {
    if (Tp->getScalarSizeInBits() == 1)
      return Tp->getPrimitiveSizeInBits().getKnownMinValue();
  }

  return BasicTTIImplBase::getNumberOfParts(Tp);
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
    assert(false && TXT);                                                      \
    report_fatal_error(TXT);                                                   \
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
  case Instruction::BitCast: {
    if (Dst->getScalarSizeInBits() >= 8)
      return 0; // bitcasts are free

    // Cast to scalar, or vector with elements, of size smaller than 8 bits are
    // illegal, with the exception of a bitcast of result of a vector
    // comparison.
    if (!I) {
      LLVM_DEBUG(dbgs() << "Invalid, Bitcast, no instruction\n");
      return InstructionCost::getInvalid();
    }
    if (auto *Cmp = dyn_cast<Instruction>(I->getOperand(0))) {
      auto Op = Cmp->getOpcode();
      bool Ok = (Op == Instruction::FCmp || Op == Instruction::ICmp);
      if (Ok)
        return 0;
    }
    LLVM_DEBUG(dbgs() << "Invalid, Bitcast invalid, does not come from Cmp\n");
    return InstructionCost::getInvalid();
  }

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
  case Instruction::ZExt: {
    // 4 x TINY -> 256
    if (Src->isVectorTy() && Src->getScalarSizeInBits() == 1) {
      if (!I)
        return InstructionCost::getInvalid();

      auto *Cmp = dyn_cast<Instruction>(I->getOperand(0));
      if (!Cmp)
        return InstructionCost::getInvalid();

      auto Op = Cmp->getOpcode();
      bool Ok = (Op == Instruction::FCmp || Op == Instruction::ICmp);
      if (!Ok)
        return InstructionCost::getInvalid();

      if (Cmp->getOperand(0)->getType()->getScalarSizeInBits() !=
          Dst->getScalarSizeInBits())
        return InstructionCost::getInvalid();

      if (Opcode == ISD::SIGN_EXTEND)
        return 0;

      return std::max(1ul, Dst->getPrimitiveSizeInBits() / 256);
    }
    break;
  }
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

InstructionCost KVXTTIImpl::getCFInstrCost(unsigned Opcode,
                                           TTI::TargetCostKind CostKind,
                                           const Instruction *I) {
  // TODO: Bit-vectors phis can be promoted to i8-vector
  if (Opcode != Instruction::PHI || !I)
    return BaseT::getCFInstrCost(Opcode, CostKind, I);

  auto *VT = I->getType();
  if (VT->isVectorTy() && VT->getScalarSizeInBits() == 1)
    return InstructionCost::getInvalid(404);

  return 0;
}
