//===--- KVX.cpp - Implement KVX target feature support -------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements KVX TargetInfo objects.
//
//===----------------------------------------------------------------------===//

#include "KVX.h"
#include "Targets.h"
#include "clang/Basic/Builtins.h"
#include "clang/Basic/MacroBuilder.h"
#include "clang/Basic/TargetBuiltins.h"

using namespace clang;
using namespace clang::targets;

ArrayRef<const char *> KVXTargetInfo::getGCCRegNames() const {
  static const char *const GCCRegNames[] = {
      "$r0",   "$r1",   "$r2",   "$r3",   "$r4",   "$r5",   "$r6",   "$r7",
      "$r8",   "$r9",   "$r10",  "$r11",  "$r12",  "$r13",  "$r14",  "$r15",
      "$r16",  "$r17",  "$r18",  "$r19",  "$r20",  "$r21",  "$r22",  "$r23",
      "$r24",  "$r25",  "$r26",  "$r27",  "$r28",  "$r29",  "$r30",  "$r31",
      "$r32",  "$r33",  "$r34",  "$r35",  "$r36",  "$r37",  "$r38",  "$r39",
      "$r40",  "$r41",  "$r42",  "$r43",  "$r44",  "$r45",  "$r46",  "$r47",
      "$r48",  "$r49",  "$r50",  "$r51",  "$r52",  "$r53",  "$r54",  "$r55",
      "$r56",  "$r57",  "$r58",  "$r59",  "$r60",  "$r61",  "$r62",  "$r63",
      "$pc",   "$ps",   "$spc",  "$sps",  "$sspc", "$ssps", "$sr3",  "$sr4",
      "$cs",   "$ra",   "$pcr",  "$ls",   "$le",   "$lc",   "$ea",   "$ev",
      "$res0", "$res1", "$res2", "$res3", "$ev4",  "$men",  "$pmsa", "$aepc",
      "$pm0",  "$pm1",  "$pm2",  "$pm3",  "$pmc",  "$sr0",  "$sr1",  "$sr2",
      "$t0v",  "$t1v",  "$tcr",  "$wdc",  "$wdr",  "$ill",  "$ile",  "$ilh",
      "$mmc",  "$tel",  "$teh",  "$dv",   "$oce0", "$oce1", "$ocec", "$ocea",
      "$es",   "$ilr",  "$ws",   "$mes"};
  return llvm::makeArrayRef(GCCRegNames);
}

const TargetInfo::GCCRegAlias KVXTargetInfo::GCCRegAliases[] = {
    {{"r0"}, "$r0"},   {{"r1"}, "$r1"},   {{"r2"}, "$r2"},   {{"r3"}, "$r3"},
    {{"r4"}, "$r4"},   {{"r5"}, "$r5"},   {{"r6"}, "$r6"},   {{"r7"}, "$r7"},
    {{"r8"}, "$r8"},   {{"r9"}, "$r9"},   {{"r10"}, "$r10"}, {{"r11"}, "$r11"},
    {{"r12"}, "$r12"}, {{"r13"}, "$r13"}, {{"r14"}, "$r14"}, {{"r15"}, "$r15"},
    {{"r16"}, "$r16"}, {{"r17"}, "$r17"}, {{"r18"}, "$r18"}, {{"r19"}, "$r19"},
    {{"r20"}, "$r20"}, {{"r21"}, "$r21"}, {{"r22"}, "$r22"}, {{"r23"}, "$r23"},
    {{"r24"}, "$r24"}, {{"r25"}, "$r25"}, {{"r26"}, "$r26"}, {{"r27"}, "$r27"},
    {{"r28"}, "$r28"}, {{"r29"}, "$r29"}, {{"r30"}, "$r30"}, {{"r31"}, "$r31"},
    {{"r32"}, "$r32"}, {{"r33"}, "$r33"}, {{"r34"}, "$r34"}, {{"r35"}, "$r35"},
    {{"r36"}, "$r36"}, {{"r37"}, "$r37"}, {{"r38"}, "$r38"}, {{"r39"}, "$r39"},
    {{"r40"}, "$r40"}, {{"r41"}, "$r41"}, {{"r42"}, "$r42"}, {{"r43"}, "$r43"},
    {{"r44"}, "$r44"}, {{"r45"}, "$r45"}, {{"r46"}, "$r46"}, {{"r47"}, "$r47"},
    {{"r48"}, "$r48"}, {{"r49"}, "$r49"}, {{"r50"}, "$r50"}, {{"r51"}, "$r51"},
    {{"r52"}, "$r52"}, {{"r53"}, "$r53"}, {{"r54"}, "$r54"}, {{"r55"}, "$r55"},
    {{"r56"}, "$r56"}, {{"r57"}, "$r57"}, {{"r58"}, "$r58"}, {{"r59"}, "$r59"},
    {{"r60"}, "$r60"}, {{"r61"}, "$r61"}, {{"r62"}, "$r62"}, {{"r63"}, "$r63"},
};

ArrayRef<TargetInfo::GCCRegAlias> KVXTargetInfo::getGCCRegAliases() const {
  return llvm::makeArrayRef(GCCRegAliases);
}

void KVXTargetInfo::getTargetDefines(const LangOptions &Opts,
                                     MacroBuilder &Builder) const {
  DefineStd(Builder, "unix", Opts);
  defineCPUMacros(Builder, "kvx", /*Tuning=*/false);
  Builder.defineMacro("__ELF__");
  Builder.defineMacro("__k1__");
  Builder.defineMacro("__K1__");
  Builder.defineMacro("__K1_64__");
  Builder.defineMacro("__k1c__");
  Builder.defineMacro("__K1C__");
}

const Builtin::Info KVXTargetInfo::BuiltinInfo[] = {
#define BUILTIN(ID, TYPE, ATTRS)                                               \
  { #ID, TYPE, ATTRS, nullptr, ALL_LANGUAGES, nullptr }                        \
  ,
#include "clang/Basic/BuiltinsKVX.def"
};

bool KVXTargetInfo::isValidCPUName(StringRef Name) const {
  if (Name == "kv3" || Name == "kv3v1")
    return true;

  return false;
}

bool KVXTargetInfo::setCPU(const std::string &Name) {
  if (!isValidCPUName(Name))
    return false;

  CPU = Name;
  return true;
}

void KVXTargetInfo::fillValidCPUList(SmallVectorImpl<StringRef> &Values) const {
  Values.push_back("kv3");
  Values.push_back("kv3v1");
}
