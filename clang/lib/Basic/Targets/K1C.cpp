//===--- K1C.cpp - Implement K1C target feature support -------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements K1C TargetInfo objects.
//
//===----------------------------------------------------------------------===//

#include "K1C.h"
#include "Targets.h"
#include "clang/Basic/Builtins.h"
#include "clang/Basic/MacroBuilder.h"
#include "clang/Basic/TargetBuiltins.h"

using namespace clang;
using namespace clang::targets;

void K1CTargetInfo::getTargetDefines(const LangOptions &Opts,
                                     MacroBuilder &Builder) const {
  DefineStd(Builder, "unix", Opts);
  defineCPUMacros(Builder, "k1c", /*Tuning=*/false);
  Builder.defineMacro("__ELF__");
  Builder.defineMacro("__k1__");
  Builder.defineMacro("__K1__");
  Builder.defineMacro("__K1_64__");
  Builder.defineMacro("__k1c__");
  Builder.defineMacro("__K1C__");
}

const Builtin::Info K1CTargetInfo::BuiltinInfo[] = {
#define BUILTIN(ID, TYPE, ATTRS)                                               \
  { #ID, TYPE, ATTRS, nullptr, ALL_LANGUAGES, nullptr }                        \
  ,
#include "clang/Basic/BuiltinsK1C.def"
};
