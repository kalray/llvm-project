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
    if (ID >= Intrinsic::kvx_abdd)
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
      return (!I.isFast()) || (I.getType()->getScalarSizeInBits() == 64);
    case Instruction::FRem:
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
                                         TTI::UnrollingPreferences &UP) {
  BaseT::getUnrollingPreferences(L, SE, UP);
  auto OptLvl = TM->getOptLevel();
  UP.PartialOptSizeThreshold = 15;
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

unsigned KVXTTIImpl::getNumberOfRegisters(unsigned ClassID) const { return 64; }

bool KVXTTIImpl::isLSRCostLess(TargetTransformInfo::LSRCost &C1,
                               TargetTransformInfo::LSRCost &C2) {
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
