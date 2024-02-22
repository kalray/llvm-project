//===-- KVXCodeGenPrepare.cpp - Hardware loops step 2 -*- C++ -*-===//
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

#ifndef KVX_KVXCodeGenPrepare_H
#define KVX_KVXCodeGenPrepare_H

#include "llvm/CodeGen/TargetPassConfig.h"
#include "llvm/Pass.h"

using namespace llvm;

struct KVXCodeGenPrepare : public FunctionPass {
  KVXCodeGenPrepare(bool V1 = false);
  bool runOnFunction(Function &F) override;

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesCFG();
    AU.addRequired<TargetPassConfig>();
  }
  static char ID;
  const bool IsV1;
};

#endif // KVX_KVXCodeGenPrepare_H
