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

using namespace llvm;
#define DEBUG_TYPE "KVXTTI"

static cl::opt<bool> DisableKvxHardwareLoops(
    "disable-kvx-loopdo", cl::Hidden, cl::init(false),
    cl::desc("Disable the generation of kvx hardware loops"));

bool KVXTTIImpl::isLoweredToCall(const Function *F) {
  if (F->isIntrinsic()) {
    auto ID = F->getIntrinsicID();
    // KVX instrinsics turn into instructions
    if (ID >= Intrinsic::kvx_abdd)
      return false;
  }

  StringRef Name = F->getName();
  switch (F->getIntrinsicID()) {
  case Intrinsic::sadd_sat:
  case Intrinsic::ssub_sat:
  case Intrinsic::fabs:
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

  if (DisableKvxHardwareLoops || !SE.hasLoopInvariantBackedgeTakenCount(L))
    return false;

  const SCEV *BackedgeTakenCount = SE.getBackedgeTakenCount(L);
  if (isa<SCEVCouldNotCompute>(BackedgeTakenCount))
    return false;

  const SCEV *TripCountSCEV = SE.getAddExpr(
      BackedgeTakenCount, SE.getOne(BackedgeTakenCount->getType()));

  if (SE.getUnsignedRangeMax(TripCountSCEV).getBitWidth() > 64)
    return false;

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
      if (const Function *F = Call->getCalledFunction()) {
        bool Ret = isLoweredToCall(F);
        LLVM_DEBUG(dbgs() << "It is intrinsic call, and it "
                          << (Ret ? "does" : "doesn't")
                          << " lower to a call!\n");
        return Ret;
      }
      LLVM_DEBUG(dbgs() << "Don't know the function name.\n");
      return true;
    }

    // Filter instructions we know it will be lowered to a libcall
    switch (I.getOpcode()) {
    default:
      break;
    case Instruction::FDiv:
      return !I.isFast();
    case Instruction::InlineAsmVal:
      return true;
    case Instruction::SRem:
    case Instruction::URem:
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
  // call or if this loop is already a hardware loop.
  auto ScanLoop = [&](Loop *L) {
    for (auto *BB : L->getBlocks()) {
      for (auto &I : *BB) {
        if (MaybeCall(I) || IsHardwareLoopIntrinsic(I))
          return false;
      }
    }
    return true;
  };

  // Visit inner loops.
  for (auto *Inner : *L)
    if (!ScanLoop(Inner))
      return false;

  if (!ScanLoop(L))
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

  LLVM_DEBUG(dbgs() << "Can be optimized to a hardware loop.\n");
  return true;
}

void KVXTTIImpl::getUnrollingPreferences(Loop *L, ScalarEvolution &SE,
                                         TTI::UnrollingPreferences &UP) {
  BaseT::getUnrollingPreferences(L, SE, UP);
  if (TM->getOptLevel() < CodeGenOpt::Aggressive)
    return;

  UP.Partial = true;
  UP.Runtime = true;

  UP.PartialThreshold = 2000;
  // For inner loop, try to unroll more loops.
  if (L->getLoopDepth() > 1)
    UP.PartialThreshold *= 2;

  UP.MaxCount = 8;
  UP.UnrollRemainder = true;
  UP.AllowExpensiveTripCount = true;
  UP.Force = true;

  // Disable partial & runtime unrolling on -Os.
  UP.PartialOptSizeThreshold = 0;
}

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
