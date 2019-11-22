//===--- K1C.h - Declare K1C target feature support -------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares K1C TargetInfo objects.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_LIB_BASIC_TARGETS_K1C_H
#define LLVM_CLANG_LIB_BASIC_TARGETS_K1C_H

#include "clang/Basic/TargetInfo.h"
#include "clang/Basic/TargetOptions.h"
#include "clang/Basic/TargetBuiltins.h"
#include "llvm/ADT/Triple.h"
#include "llvm/Support/Compiler.h"

namespace clang {
namespace targets {

class LLVM_LIBRARY_VISIBILITY K1CTargetInfo : public TargetInfo {
  static const Builtin::Info BuiltinInfo[];

public:
  K1CTargetInfo(const llvm::Triple &Triple, const TargetOptions &)
      : TargetInfo(Triple) {
    NoAsmVariants = true;

    HasLegalHalfType = true;
    HasFloat16 = true;
    HalfWidth = HalfAlign = 16;
    FloatWidth = FloatAlign = 32;
    DoubleWidth = DoubleAlign = 64;
    LongDoubleWidth = LongDoubleAlign = 64;

    HalfFormat = &llvm::APFloat::IEEEhalf();
    FloatFormat = &llvm::APFloat::IEEEsingle();
    DoubleFormat = &llvm::APFloat::IEEEdouble();
    LongDoubleFormat = &llvm::APFloat::IEEEdouble();

    LongWidth = LongAlign = PointerWidth = PointerAlign = 64;
    MaxAtomicPromoteWidth = MaxAtomicInlineWidth = 64;
    resetDataLayout(
        "e-m:e-p:64:64-i64:64-i128:128-f16:16-f32:32-f64:64-n64-S128");
  }

  void getTargetDefines(const LangOptions &Opts, MacroBuilder &Builder) const
      override;

  ArrayRef<Builtin::Info> getTargetBuiltins() const override {
    return llvm::makeArrayRef(BuiltinInfo, clang::K1C::LastTSBuiltin -
                                               Builtin::FirstTSBuiltin);
  }

  BuiltinVaListKind getBuiltinVaListKind() const override {
    return TargetInfo::VoidPtrBuiltinVaList;
  }

  const char *getClobbers() const override { return ""; }

  ArrayRef<const char *> getGCCRegNames() const override;

  ArrayRef<TargetInfo::GCCRegAlias> getGCCRegAliases() const override {
    return None;
  }

  bool validateAsmConstraint(const char *&Name,
                             TargetInfo::ConstraintInfo &Info) const override {
    return false;
  }

  bool hasProtectedVisibility() const override { return false; }
};

} // namespace targets
} // namespace clang
#endif // LLVM_CLANG_LIB_BASIC_TARGETS_K1C_H
