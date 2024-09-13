//===------ SemaKVX.cpp ------ PowerPC target-specific routines -----------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
//  This file implements semantic analysis functions specific to PowerPC.
//
//===----------------------------------------------------------------------===//

#include "clang/AST/Type.h"
#include "clang/Basic/DiagnosticSema.h"
#include "clang/Basic/SourceLocation.h"
#include "clang/Sema/Sema.h"
#include "clang/Sema/SemaKVX.h"

namespace clang {

SemaKVX::SemaKVX(Sema &S) : SemaBase(S) {}

bool SemaKVX::CheckKVXTCAType(QualType Type, SourceLocation TypeLoc) {
  if (Type->isPointerType() || Type->isArrayType())
    return false;

  auto &Context = getASTContext();
  QualType CoreType = Type.getCanonicalType().getUnqualifiedType();
#define KVX_TCA_VECTOR_TYPE(Name, Id, Size) || CoreType == Context.Id##Ty
  if (false
#include "clang/Basic/KVXTypes.def"
  ) {
    Diag(TypeLoc, diag::err_kvx_invalid_use_tca_type);
    return true;
  }
  return false;
}

} // namespace clang
