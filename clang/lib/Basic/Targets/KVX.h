//===--- KVX.h - Declare KVX target feature support -------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares KVX TargetInfo objects.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_LIB_BASIC_TARGETS_KVX_H
#define LLVM_CLANG_LIB_BASIC_TARGETS_KVX_H

#include "clang/Basic/TargetBuiltins.h"
#include "clang/Basic/TargetInfo.h"
#include "clang/Basic/TargetOptions.h"
#include "llvm/Support/Compiler.h"
#include "llvm/TargetParser/Triple.h"

namespace clang {
namespace targets {

class LLVM_LIBRARY_VISIBILITY KVXTargetInfo : public TargetInfo {
  static const Builtin::Info BuiltinInfo[];
  static const TargetInfo::GCCRegAlias GCCRegAliases[];
  std::string CPU;


public:
  KVXTargetInfo(const llvm::Triple &Triple, const TargetOptions &Opts)
      : TargetInfo(Triple) {
    NoAsmVariants = true;

    PointerWidth = PointerAlign = 64;
    BoolWidth = BoolAlign = 8;
    IntWidth = IntAlign = 32;
    LongWidth = LongAlign = 64;
    LongLongWidth = LongLongAlign = 64;

    HasLegalHalfType = true;
    HasFloat16 = true;
    HasFloat128 = false;
    HalfWidth = HalfAlign = 16;
    FloatWidth = FloatAlign = 32;
    DoubleWidth = DoubleAlign = 64;
    LongDoubleWidth = LongDoubleAlign = 64;

    SizeType = UnsignedLong;
    PtrDiffType = SignedLong;
    IntMaxType = SignedLong;
    IntPtrType = SignedLong;
    WCharType = SignedInt;
    WIntType = UnsignedInt;
    Char16Type = UnsignedShort;
    Char32Type = UnsignedInt;
    Int64Type = SignedLong;
    SigAtomicType = SignedInt;

    HalfFormat = &llvm::APFloat::IEEEhalf();
    FloatFormat = &llvm::APFloat::IEEEsingle();
    DoubleFormat = &llvm::APFloat::IEEEdouble();
    LongDoubleFormat = &llvm::APFloat::IEEEdouble();

    MaxVectorAlign = NewAlign = SuitableAlign = 256;
    MaxAtomicPromoteWidth = MaxAtomicInlineWidth = 64;
    resetDataLayout("e-S256-p:64:64-i1:8-i8:8-i16:16-i32:32-i64:64-"
                    "v64:64-v128:128-v256:256-v512:256-v1024:256-"
                    "f16:16-f32:32-f64:64-a:0:64-m:e-n32:64");
    CPU = "kv3-1"; // Set the default cpu as kv3-1
  }

  void adjust(DiagnosticsEngine &Diags, LangOptions &Opts) override;
  void getTargetDefines(const LangOptions &Opts,
                        MacroBuilder &Builder) const override;

  ArrayRef<Builtin::Info> getTargetBuiltins() const override {
    return llvm::ArrayRef(BuiltinInfo, clang::KVX::LastTSBuiltin -
                                               Builtin::FirstTSBuiltin);
  }

  BuiltinVaListKind getBuiltinVaListKind() const override {
    return TargetInfo::VoidPtrBuiltinVaList;
  }

  std::string_view getClobbers() const override { return ""; }

  ArrayRef<const char *> getGCCRegNames() const override;

  ArrayRef<TargetInfo::GCCRegAlias> getGCCRegAliases() const override;

  void setSupportedOpenCLOpts() override;

  bool validateAsmConstraint(const char *&Name,
                             TargetInfo::ConstraintInfo &Info) const override;

  bool hasProtectedVisibility() const override { return false; }

  bool isValidCPUName(StringRef Name) const override;
  bool setCPU(const std::string &Name) override;
  bool validateCpuIs(StringRef Name) const override { return CPU == Name; };
  StringRef getCPUstr() const override { return CPU; }

  void fillValidCPUList(SmallVectorImpl<StringRef> &Values) const override;
  bool DecodeTargetTypeFromStr(const char *&Str, const ASTContext &Context,
                               bool &AllowTypeModifiers,
                               QualType &Type) const override;

  bool hasSjLjLowering() const override { return true; }

  bool isCLZForZeroUndef() const override { return false; }

  bool isSPRegName(StringRef R) const override {
    return R == "$sp" || R == "$r12";
  }

  bool useFP16ConversionIntrinsics() const override {
    return false;
  }
};

} // namespace targets
} // namespace clang
#endif // LLVM_CLANG_LIB_BASIC_TARGETS_KVX_H
