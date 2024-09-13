//===----- SemaKVX.h ------- KVX target-specific routines -----*- C++ -*---===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
/// \file
/// This file declares semantic analysis functions specific to KVX targets.
///
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_SEMA_SEMAKVX_H
#define LLVM_CLANG_SEMA_SEMAKVX_H

#include "clang/Sema/SemaBase.h"

namespace clang {
class SemaKVX : public SemaBase {
  public:
    SemaKVX(Sema &S);

    bool CheckKVXTCAType(QualType Type, SourceLocation TypeLoc);
};
} // namespace clang

#endif // LLVM_CLANG_SEMA_SEMAKVX_H
