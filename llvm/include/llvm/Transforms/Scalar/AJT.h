//===- AJT.h - Aggressive jump threading ------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//
//===----------------------------------------------------------------------===//
//
// This file provides the interface for the Aggressive jump threading pass.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_TRANSFORMS_SCALAR_AJT_H
#define LLVM_TRANSFORMS_SCALAR_AJT_H

#include "llvm/IR/PassManager.h"

namespace llvm {

class Function;

// SDCOMP-28505
struct AJTPass : PassInfoMixin<AJTPass> {
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &);
};

} // end namespace llvm

#endif // LLVM_TRANSFORMS_SCALAR_AJT_H
