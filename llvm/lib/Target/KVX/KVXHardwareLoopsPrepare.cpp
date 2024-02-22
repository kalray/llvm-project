//===-- KVXHardwareLoopsPrepare.cpp - Hardware loops step 2 -*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
/// \file
/// This file contains the pass implementation that converts the generic
/// hardware loop decrement to a intrinsic generated a i64 value plus a
/// icmp instruction, as to simplify the lowering.
//===----------------------------------------------------------------------===//

#include "KVXHardwareLoopsPrepare.h"
#include "KVX.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/IntrinsicsKVX.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

using namespace llvm;

#define DEBUG_TYPE "hardware-loops"

#define KVX_HW_LOOPS_PREPARE_NAME "kvx-hardware-loops-prepare"
#define KVX_HW_LOOPS_PREPARE_DESC "KVX Hardware loops Prepare"

char KVXHardwareLoopsPrepare::ID = 0;

INITIALIZE_PASS_BEGIN(KVXHardwareLoopsPrepare, KVX_HW_LOOPS_PREPARE_NAME,
                      KVX_HW_LOOPS_PREPARE_DESC, false, false)
INITIALIZE_PASS_END(KVXHardwareLoopsPrepare, KVX_HW_LOOPS_PREPARE_NAME,
                    KVX_HW_LOOPS_PREPARE_DESC, false, false)

FunctionPass *llvm::createKVXHardwareLoopsPreparePass() {
  return new KVXHardwareLoopsPrepare();
}

KVXHardwareLoopsPrepare::KVXHardwareLoopsPrepare() : FunctionPass(ID) {
  auto *PR = PassRegistry::getPassRegistry();
  initializeKVXHardwareLoopsPreparePass(*PR);
}

bool KVXHardwareLoopsPrepare::runOnFunction(Function &F) {
  if (skipFunction(F)) {
    LLVM_DEBUG(dbgs() << "Skiping function " << F.getName() << ".\n");
    return false;
  }
  bool Changed = false;

  DominatorTree &DT = getAnalysis<DominatorTreeWrapperPass>().getDomTree();
  LoopInfo &LI = getAnalysis<LoopInfoWrapperPass>().getLoopInfo();

  for (auto &BB : F) {
    for (Instruction &I : BB) {
      if (!isa<CallInst>(I))
        continue;

      CallInst &CI = cast<CallInst>(I);
      Function *CF = CI.getCalledFunction();
      if (!(CF != nullptr && CF->isIntrinsic() &&
            CF->getIntrinsicID() == Intrinsic::loop_decrement))
        continue;

      LLVM_DEBUG(dbgs() << "Found latch intrinsic call: " << CI << ".\n");

      ConstantInt *Dec = dyn_cast<ConstantInt>(CI.getArgOperand(0));
      if (!Dec)
        report_fatal_error(
            "Loop hardware should have a constant decrement value "
            "per iteration.");
      if (Dec->getZExtValue() != 1)
        report_fatal_error("Loop decrement per iteration should be 1.");

      Instruction *Ins = I.getNextNode();
      if (!Ins)
        report_fatal_error("Expected instruction after intrinsic.");

      BranchInst *BRIns = dyn_cast<BranchInst>(Ins);
      if (!BRIns)
        report_fatal_error("Unexpected instruction, should be a branch.");

      Function *DecFunc =
          Intrinsic::getDeclaration(F.getParent(), Intrinsic::kvx_loopdoexit);

      IRBuilder<> Builder(&CI);
      auto *R = Builder.CreateCall(DecFunc);
      auto *Cond = Builder.CreateICmpULT(R, CI.getArgOperand(0));
      BRIns->setCondition(Cond);
      CI.eraseFromParent();

      SplitBlock(R->getParent(), R, &DT, &LI);

      Changed = true;
      break;
    }
  }

  // If found any, now split the edge for inserting the loop-header
  if (Changed)
    for (Loop *L : LI)
      runOnLoop(L, LI, DT);

  return Changed;
}

void KVXHardwareLoopsPrepare::runOnLoop(Loop *L, LoopInfo &LI,
                                        DominatorTree &DT) const {
  if (!L)
    return;
  for (Loop *SubL : *L)
    runOnLoop(SubL, LI, DT);

  auto *Preheader = L->getLoopPreheader();
  if (!Preheader)
    return;

  auto *Header = L->getHeader();
  if (!Header)
    return;

  for (Instruction &I : *Preheader) {
    if (!isa<CallInst>(I))
      continue;

    CallInst &CI = cast<CallInst>(I);
    Function *CF = CI.getCalledFunction();
    if (!(CF != nullptr && CF->isIntrinsic() &&
          CF->getIntrinsicID() == Intrinsic::set_loop_iterations))
      continue;

    CI.moveBefore(*Header, Header->getFirstInsertionPt());
    return;
  }
}
