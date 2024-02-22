//===-- KVXHardwareLoopsPrepare.cpp - Hardware loops step 2 -*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Header file to the pass that converts the generic intrinsics generated
// by hardware-loops to KVX specific intrinsics, that pattern match directly
// to pseudo-instructions.
//
//===----------------------------------------------------------------------===//

#ifndef KVX_KVXHardwareLoopsPrepare_H
#define KVX_KVXHardwareLoopsPrepare_H

#include "llvm/Analysis/LoopInfo.h"
#include "llvm/IR/Dominators.h"

using namespace llvm;

struct KVXHardwareLoopsPrepare : public FunctionPass {
public:
  static char ID;

  KVXHardwareLoopsPrepare();
  bool runOnFunction(Function &F) override;

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addRequired<LoopInfoWrapperPass>();
    AU.addRequired<DominatorTreeWrapperPass>();
    FunctionPass::getAnalysisUsage(AU);
  }

private:
  void runOnLoop(Loop *L, LoopInfo &LI, DominatorTree &DT) const;
};

#endif // KVX_KVXHardwareLoopsPrepare_H
