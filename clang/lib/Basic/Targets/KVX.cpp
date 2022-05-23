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
#include "clang/AST/ASTContext.h"
#include "clang/Basic/Builtins.h"
#include "clang/Basic/MacroBuilder.h"
#include "clang/Basic/TargetBuiltins.h"
#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "KVX-target"

using namespace clang;
using namespace clang::targets;

ArrayRef<const char *> KVXTargetInfo::getGCCRegNames() const {
  static const char *const GCCRegNames[] = {
      /* GPR registers */
      "$r0", "$r1", "$r2", "$r3", "$r4", "$r5", "$r6", "$r7", "$r8", "$r9",
      "$r10", "$r11", "$r12", "$r13", "$r14", "$r15", "$r16", "$r17", "$r18",
      "$r19", "$r20", "$r21", "$r22", "$r23", "$r24", "$r25", "$r26", "$r27",
      "$r28", "$r29", "$r30", "$r31", "$r32", "$r33", "$r34", "$r35", "$r36",
      "$r37", "$r38", "$r39", "$r40", "$r41", "$r42", "$r43", "$r44", "$r45",
      "$r46", "$r47", "$r48", "$r49", "$r50", "$r51", "$r52", "$r53", "$r54",
      "$r55", "$r56", "$r57", "$r58", "$r59", "$r60", "$r61", "$r62", "$r63",
      /* Pair registers */
      "$r0r1", "$r2r3", "$r4r5", "$r6r7", "$r8r9", "$r10r11", "$r12r13",
      "$r14r15", "$r16r17", "$r18r19", "$r20r21", "$r22r23", "$r24r25",
      "$r26r27", "$r28r29", "$r30r31", "$r32r33", "$r34r35", "$r36r37",
      "$r38r39", "$r40r41", "$r42r43", "$r44r45", "$r46r47", "$r48r49",
      "$r50r51", "$r52r53", "$r54r55", "$r56r57", "$r58r59", "$r60r61",
      "$r62r63",
      /* Quad registers */
      "$r0r1r2r3", "$r4r5r6r7", "$r8r9r10r11", "$r12r13r14r15", "$r16r17r18r19",
      "$r20r21r22r23", "$r24r25r26r27", "$r28r29r30r31", "$r32r33r34r35",
      "$r36r37r38r39", "$r40r41r42r43", "$r44r45r46r47", "$r48r49r50r51",
      "$r52r53r54r55", "$r56r57r58r59", "$r60r61r62r63",
      /* TCA 64-bit */
      "$a0.x", "$a0.y", "$a0.z", "$a0.t", "$a1.x", "$a1.y", "$a1.z", "$a1.t",
      "$a2.x", "$a2.y", "$a2.z", "$a2.t", "$a3.x", "$a3.y", "$a3.z", "$a3.t",
      "$a4.x", "$a4.y", "$a4.z", "$a4.t", "$a5.x", "$a5.y", "$a5.z", "$a5.t",
      "$a6.x", "$a6.y", "$a6.z", "$a6.t", "$a7.x", "$a7.y", "$a7.z", "$a7.t",
      "$a8.x", "$a8.y", "$a8.z", "$a8.t", "$a9.x", "$a9.y", "$a9.z", "$a9.t",
      "$a10.x", "$a10.y", "$a10.z", "$a10.t", "$a11.x", "$a11.y", "$a11.z",
      "$a11.t", "$a12.x", "$a12.y", "$a12.z", "$a12.t", "$a13.x", "$a13.y",
      "$a13.z", "$a13.t", "$a14.x", "$a14.y", "$a14.z", "$a14.t", "$a15.x",
      "$a15.y", "$a15.z", "$a15.t", "$a16.x", "$a16.y", "$a16.z", "$a16.t",
      "$a17.x", "$a17.y", "$a17.z", "$a17.t", "$a18.x", "$a18.y", "$a18.z",
      "$a18.t", "$a19.x", "$a19.y", "$a19.z", "$a19.t", "$a20.x", "$a20.y",
      "$a20.z", "$a20.t", "$a21.x", "$a21.y", "$a21.z", "$a21.t", "$a22.x",
      "$a22.y", "$a22.z", "$a22.t", "$a23.x", "$a23.y", "$a23.z", "$a23.t",
      "$a24.x", "$a24.y", "$a24.z", "$a24.t", "$a25.x", "$a25.y", "$a25.z",
      "$a25.t", "$a26.x", "$a26.y", "$a26.z", "$a26.t", "$a27.x", "$a27.y",
      "$a27.z", "$a27.t", "$a28.x", "$a28.y", "$a28.z", "$a28.t", "$a29.x",
      "$a29.y", "$a29.z", "$a29.t", "$a30.x", "$a30.y", "$a30.z", "$a30.t",
      "$a31.x", "$a31.y", "$a31.z", "$a31.t", "$a32.x", "$a32.y", "$a32.z",
      "$a32.t", "$a33.x", "$a33.y", "$a33.z", "$a33.t", "$a34.x", "$a34.y",
      "$a34.z", "$a34.t", "$a35.x", "$a35.y", "$a35.z", "$a35.t", "$a36.x",
      "$a36.y", "$a36.z", "$a36.t", "$a37.x", "$a37.y", "$a37.z", "$a37.t",
      "$a38.x", "$a38.y", "$a38.z", "$a38.t", "$a39.x", "$a39.y", "$a39.z",
      "$a39.t", "$a40.x", "$a40.y", "$a40.z", "$a40.t", "$a41.x", "$a41.y",
      "$a41.z", "$a41.t", "$a42.x", "$a42.y", "$a42.z", "$a42.t", "$a43.x",
      "$a43.y", "$a43.z", "$a43.t", "$a44.x", "$a44.y", "$a44.z", "$a44.t",
      "$a45.x", "$a45.y", "$a45.z", "$a45.t", "$a46.x", "$a46.y", "$a46.z",
      "$a46.t", "$a47.x", "$a47.y", "$a47.z", "$a47.t", "$a48.x", "$a48.y",
      "$a48.z", "$a48.t", "$a49.x", "$a49.y", "$a49.z", "$a49.t", "$a50.x",
      "$a50.y", "$a50.z", "$a50.t", "$a51.x", "$a51.y", "$a51.z", "$a51.t",
      "$a52.x", "$a52.y", "$a52.z", "$a52.t", "$a53.x", "$a53.y", "$a53.z",
      "$a53.t", "$a54.x", "$a54.y", "$a54.z", "$a54.t", "$a55.x", "$a55.y",
      "$a55.z", "$a55.t", "$a56.x", "$a56.y", "$a56.z", "$a56.t", "$a57.x",
      "$a57.y", "$a57.z", "$a57.t", "$a58.x", "$a58.y", "$a58.z", "$a58.t",
      "$a59.x", "$a59.y", "$a59.z", "$a59.t", "$a60.x", "$a60.y", "$a60.z",
      "$a60.t", "$a61.x", "$a61.y", "$a61.z", "$a61.t", "$a62.x", "$a62.y",
      "$a62.z", "$a62.t", "$a63.x", "$a63.y", "$a63.z", "$a63.t",
      /* TCA 128-bit */
      "$a0.lo", "$a0.hi", "$a1.lo", "$a1.hi", "$a2.lo", "$a2.hi", "$a3.lo",
      "$a3.hi", "$a4.lo", "$a4.hi", "$a5.lo", "$a5.hi", "$a6.lo", "$a6.hi",
      "$a7.lo", "$a7.hi", "$a8.lo", "$a8.hi", "$a9.lo", "$a9.hi", "$a10.lo",
      "$a10.hi", "$a11.lo", "$a11.hi", "$a12.lo", "$a12.hi", "$a13.lo",
      "$a13.hi", "$a14.lo", "$a14.hi", "$a15.lo", "$a15.hi", "$a16.lo",
      "$a16.hi", "$a17.lo", "$a17.hi", "$a18.lo", "$a18.hi", "$a19.lo",
      "$a19.hi", "$a20.lo", "$a20.hi", "$a21.lo", "$a21.hi", "$a22.lo",
      "$a22.hi", "$a23.lo", "$a23.hi", "$a24.lo", "$a24.hi", "$a25.lo",
      "$a25.hi", "$a26.lo", "$a26.hi", "$a27.lo", "$a27.hi", "$a28.lo",
      "$a28.hi", "$a29.lo", "$a29.hi", "$a30.lo", "$a30.hi", "$a31.lo",
      "$a31.hi", "$a32.lo", "$a32.hi", "$a33.lo", "$a33.hi", "$a34.lo",
      "$a34.hi", "$a35.lo", "$a35.hi", "$a36.lo", "$a36.hi", "$a37.lo",
      "$a37.hi", "$a38.lo", "$a38.hi", "$a39.lo", "$a39.hi", "$a40.lo",
      "$a40.hi", "$a41.lo", "$a41.hi", "$a42.lo", "$a42.hi", "$a43.lo",
      "$a43.hi", "$a44.lo", "$a44.hi", "$a45.lo", "$a45.hi", "$a46.lo",
      "$a46.hi", "$a47.lo", "$a47.hi", "$a48.lo", "$a48.hi", "$a49.lo",
      "$a49.hi", "$a50.lo", "$a50.hi", "$a51.lo", "$a51.hi", "$a52.lo",
      "$a52.hi", "$a53.lo", "$a53.hi", "$a54.lo", "$a54.hi", "$a55.lo",
      "$a55.hi", "$a56.lo", "$a56.hi", "$a57.lo", "$a57.hi", "$a58.lo",
      "$a58.hi", "$a59.lo", "$a59.hi", "$a60.lo", "$a60.hi", "$a61.lo",
      "$a61.hi", "$a62.lo", "$a62.hi", "$a63.lo", "$a63.hi",
      /* TCA base 256-bit */
      "$a0", "$a1", "$a2", "$a3", "$a4", "$a5", "$a6", "$a7", "$a8", "$a9",
      "$a10", "$a11", "$a12", "$a13", "$a14", "$a15", "$a16", "$a17", "$a18",
      "$a19", "$a20", "$a21", "$a22", "$a23", "$a24", "$a25", "$a26", "$a27",
      "$a28", "$a29", "$a30", "$a31", "$a32", "$a33", "$a34", "$a35", "$a36",
      "$a37", "$a38", "$a39", "$a40", "$a41", "$a42", "$a43", "$a44", "$a45",
      "$a46", "$a47", "$a48", "$a49", "$a50", "$a51", "$a52", "$a53", "$a54",
      "$a55", "$a56", "$a57", "$a58", "$a59", "$a60", "$a61", "$a62", "$a63",
      "$a0a1", "$a2a3", "$a4a5", "$a6a7",
      /* TCA 512-bit */
      "$a8a9", "$a10a11", "$a12a13", "$a14a15", "$a16a17", "$a18a19", "$a20a21",
      "$a22a23", "$a24a25", "$a26a27", "$a28a29", "$a30a31", "$a32a33",
      "$a34a35", "$a36a37", "$a38a39", "$a40a41", "$a42a43", "$a44a45",
      "$a46a47", "$a48a49", "$a50a51", "$a52a53", "$a54a55", "$a56a57",
      "$a58a59", "$a60a61", "$a62a63",
      /* TCA 1024-bit */
      "$a0a1a2a3", "$a4a5a6a7", "$a8a9a10a11", "$a12a13a14a15", "$a16a17a18a19",
      "$a20a21a22a23", "$a24a25a26a27", "$a28a29a30a31", "$a32a33a34a35",
      "$a36a37a38a39", "$a40a41a42a43", "$a44a45a46a47", "$a48a49a50a51",
      "$a52a53a54a55", "$a56a57a58a59", "$a60a61a62a63",
      /* System registers */
      "$pc", "$ps", "$spc", "$sps", "$sspc", "$ssps", "$sr3", "$sr4", "$cs",
      "$ra", "$pcr", "$ls", "$le", "$lc", "$ea", "$ev", "$res0", "$res1",
      "$res2", "$res3", "$ev4", "$men", "$pmsa", "$aepc", "$pm0", "$pm1",
      "$pm2", "$pm3", "$pmc", "$sr0", "$sr1", "$sr2", "$t0v", "$t1v", "$tcr",
      "$wdc", "$wdr", "$ill", "$ile", "$ilh", "$mmc", "$tel", "$teh", "$dv",
      "$oce0", "$oce1", "$ocec", "$ocea", "$es", "$ilr", "$ws", "$mes"};

  return llvm::makeArrayRef(GCCRegNames);
}

const TargetInfo::GCCRegAlias KVXTargetInfo::GCCRegAliases[] = {
  /* Single registers */
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
  /* Paired registers */
  {{"r0r1"}, "$r0r1"}, {{"r2r3"}, "$r2r3"}, {{"r4r5"}, "$r4r5"}, {{"r6r7"}, "$r6r7"}, {{"r8r9"}, "$r8r9"}, {{"r10r11"}, "$r10r11"}, {{"r12r13"}, "$r12r13"},
  {{"r14r15"}, "$r14r15"}, {{"r16r17"}, "$r16r17"}, {{"r18r19"}, "$r18r19"}, {{"r20r21"}, "$r20r21"}, {{"r22r23"}, "$r22r23"}, {{"r24r25"}, "$r24r25"},
  {{"r26r27"}, "$r26r27"}, {{"r28r29"}, "$r28r29"}, {{"r30r31"}, "$r30r31"}, {{"r32r33"}, "$r32r33"}, {{"r34r35"}, "$r34r35"}, {{"r36r37"}, "$r36r37"},
  {{"r38r39"}, "$r38r39"}, {{"r40r41"}, "$r40r41"}, {{"r42r43"}, "$r42r43"}, {{"r44r45"}, "$r44r45"}, {{"r46r47"}, "$r46r47"}, {{"r48r49"}, "$r48r49"},
  {{"r50r51"}, "$r50r51"}, {{"r52r53"}, "$r52r53"}, {{"r54r55"}, "$r54r55"}, {{"r56r57"}, "$r56r57"}, {{"r58r59"}, "$r58r59"}, {{"r60r61"}, "$r60r61"},
  {{"r62r63"}, "$r62r63"},
  /* Quad registers */
  {{"r0r1r2r3"}, "$r0r1r2r3"}, {{"r4r5r6r7"}, "$r4r5r6r7"}, {{"r8r9r10r11"}, "$r8r9r10r11"}, {{"r12r13r14r15"}, "$r12r13r14r15"}, {{"r16r17r18r19"}, "$r16r17r18r19"},
  {{"r20r21r22r23"}, "$r20r21r22r23"}, {{"r24r25r26r27"}, "$r24r25r26r27"}, {{"r28r29r30r31"}, "$r28r29r30r31"}, {{"r32r33r34r35"}, "$r32r33r34r35"},
  {{"r36r37r38r39"}, "$r36r37r38r39"}, {{"r40r41r42r43"}, "$r40r41r42r43"}, {{"r44r45r46r47"}, "$r44r45r46r47"}, {{"r48r49r50r51"}, "$r48r49r50r51"},
  {{"r52r53r54r55"}, "$r52r53r54r55"}, {{"r56r57r58r59"}, "$r56r57r58r59"}, {{"r60r61r62r63"}, "$r60r61r62r63"},
  /* TCA 64-bit */
  {{"a0.x"}, "$a0.x"}, {{"a0.y"}, "$a0.y"}, {{"a0.z"}, "$a0.z"}, {{"a0.t"}, "$a0.t"}, {{"a1.x"}, "$a1.x"}, {{"a1.y"}, "$a1.y"}, {{"a1.z"}, "$a1.z"}, {{"a1.t"}, "$a1.t"},
  {{"a2.x"}, "$a2.x"}, {{"a2.y"}, "$a2.y"}, {{"a2.z"}, "$a2.z"}, {{"a2.t"}, "$a2.t"}, {{"a3.x"}, "$a3.x"}, {{"a3.y"}, "$a3.y"}, {{"a3.z"}, "$a3.z"}, {{"a3.t"}, "$a3.t"},
  {{"a4.x"}, "$a4.x"}, {{"a4.y"}, "$a4.y"}, {{"a4.z"}, "$a4.z"}, {{"a4.t"}, "$a4.t"}, {{"a5.x"}, "$a5.x"}, {{"a5.y"}, "$a5.y"}, {{"a5.z"}, "$a5.z"}, {{"a5.t"}, "$a5.t"},
  {{"a6.x"}, "$a6.x"}, {{"a6.y"}, "$a6.y"}, {{"a6.z"}, "$a6.z"}, {{"a6.t"}, "$a6.t"}, {{"a7.x"}, "$a7.x"}, {{"a7.y"}, "$a7.y"}, {{"a7.z"}, "$a7.z"}, {{"a7.t"}, "$a7.t"},
  {{"a8.x"}, "$a8.x"}, {{"a8.y"}, "$a8.y"}, {{"a8.z"}, "$a8.z"}, {{"a8.t"}, "$a8.t"}, {{"a9.x"}, "$a9.x"}, {{"a9.y"}, "$a9.y"}, {{"a9.z"}, "$a9.z"}, {{"a9.t"}, "$a9.t"},
  {{"a10.x"}, "$a10.x"}, {{"a10.y"}, "$a10.y"}, {{"a10.z"}, "$a10.z"}, {{"a10.t"}, "$a10.t"}, {{"a11.x"}, "$a11.x"}, {{"a11.y"}, "$a11.y"}, {{"a11.z"}, "$a11.z"},
  {{"a11.t"}, "$a11.t"}, {{"a12.x"}, "$a12.x"}, {{"a12.y"}, "$a12.y"}, {{"a12.z"}, "$a12.z"}, {{"a12.t"}, "$a12.t"}, {{"a13.x"}, "$a13.x"}, {{"a13.y"}, "$a13.y"},
  {{"a13.z"}, "$a13.z"}, {{"a13.t"}, "$a13.t"}, {{"a14.x"}, "$a14.x"}, {{"a14.y"}, "$a14.y"}, {{"a14.z"}, "$a14.z"}, {{"a14.t"}, "$a14.t"}, {{"a15.x"}, "$a15.x"},
  {{"a15.y"}, "$a15.y"}, {{"a15.z"}, "$a15.z"}, {{"a15.t"}, "$a15.t"}, {{"a16.x"}, "$a16.x"}, {{"a16.y"}, "$a16.y"}, {{"a16.z"}, "$a16.z"}, {{"a16.t"}, "$a16.t"},
  {{"a17.x"}, "$a17.x"}, {{"a17.y"}, "$a17.y"}, {{"a17.z"}, "$a17.z"}, {{"a17.t"}, "$a17.t"}, {{"a18.x"}, "$a18.x"}, {{"a18.y"}, "$a18.y"}, {{"a18.z"}, "$a18.z"},
  {{"a18.t"}, "$a18.t"}, {{"a19.x"}, "$a19.x"}, {{"a19.y"}, "$a19.y"}, {{"a19.z"}, "$a19.z"}, {{"a19.t"}, "$a19.t"}, {{"a20.x"}, "$a20.x"}, {{"a20.y"}, "$a20.y"},
  {{"a20.z"}, "$a20.z"}, {{"a20.t"}, "$a20.t"}, {{"a21.x"}, "$a21.x"}, {{"a21.y"}, "$a21.y"}, {{"a21.z"}, "$a21.z"}, {{"a21.t"}, "$a21.t"}, {{"a22.x"}, "$a22.x"},
  {{"a22.y"}, "$a22.y"}, {{"a22.z"}, "$a22.z"}, {{"a22.t"}, "$a22.t"}, {{"a23.x"}, "$a23.x"}, {{"a23.y"}, "$a23.y"}, {{"a23.z"}, "$a23.z"}, {{"a23.t"}, "$a23.t"},
  {{"a24.x"}, "$a24.x"}, {{"a24.y"}, "$a24.y"}, {{"a24.z"}, "$a24.z"}, {{"a24.t"}, "$a24.t"}, {{"a25.x"}, "$a25.x"}, {{"a25.y"}, "$a25.y"}, {{"a25.z"}, "$a25.z"},
  {{"a25.t"}, "$a25.t"}, {{"a26.x"}, "$a26.x"}, {{"a26.y"}, "$a26.y"}, {{"a26.z"}, "$a26.z"}, {{"a26.t"}, "$a26.t"}, {{"a27.x"}, "$a27.x"}, {{"a27.y"}, "$a27.y"},
  {{"a27.z"}, "$a27.z"}, {{"a27.t"}, "$a27.t"}, {{"a28.x"}, "$a28.x"}, {{"a28.y"}, "$a28.y"}, {{"a28.z"}, "$a28.z"}, {{"a28.t"}, "$a28.t"}, {{"a29.x"}, "$a29.x"},
  {{"a29.y"}, "$a29.y"}, {{"a29.z"}, "$a29.z"}, {{"a29.t"}, "$a29.t"}, {{"a30.x"}, "$a30.x"}, {{"a30.y"}, "$a30.y"}, {{"a30.z"}, "$a30.z"}, {{"a30.t"}, "$a30.t"},
  {{"a31.x"}, "$a31.x"}, {{"a31.y"}, "$a31.y"}, {{"a31.z"}, "$a31.z"}, {{"a31.t"}, "$a31.t"}, {{"a32.x"}, "$a32.x"}, {{"a32.y"}, "$a32.y"}, {{"a32.z"}, "$a32.z"},
  {{"a32.t"}, "$a32.t"}, {{"a33.x"}, "$a33.x"}, {{"a33.y"}, "$a33.y"}, {{"a33.z"}, "$a33.z"}, {{"a33.t"}, "$a33.t"}, {{"a34.x"}, "$a34.x"}, {{"a34.y"}, "$a34.y"},
  {{"a34.z"}, "$a34.z"}, {{"a34.t"}, "$a34.t"}, {{"a35.x"}, "$a35.x"}, {{"a35.y"}, "$a35.y"}, {{"a35.z"}, "$a35.z"}, {{"a35.t"}, "$a35.t"}, {{"a36.x"}, "$a36.x"},
  {{"a36.y"}, "$a36.y"}, {{"a36.z"}, "$a36.z"}, {{"a36.t"}, "$a36.t"}, {{"a37.x"}, "$a37.x"}, {{"a37.y"}, "$a37.y"}, {{"a37.z"}, "$a37.z"}, {{"a37.t"}, "$a37.t"},
  {{"a38.x"}, "$a38.x"}, {{"a38.y"}, "$a38.y"}, {{"a38.z"}, "$a38.z"}, {{"a38.t"}, "$a38.t"}, {{"a39.x"}, "$a39.x"}, {{"a39.y"}, "$a39.y"}, {{"a39.z"}, "$a39.z"},
  {{"a39.t"}, "$a39.t"}, {{"a40.x"}, "$a40.x"}, {{"a40.y"}, "$a40.y"}, {{"a40.z"}, "$a40.z"}, {{"a40.t"}, "$a40.t"}, {{"a41.x"}, "$a41.x"}, {{"a41.y"}, "$a41.y"},
  {{"a41.z"}, "$a41.z"}, {{"a41.t"}, "$a41.t"}, {{"a42.x"}, "$a42.x"}, {{"a42.y"}, "$a42.y"}, {{"a42.z"}, "$a42.z"}, {{"a42.t"}, "$a42.t"}, {{"a43.x"}, "$a43.x"},
  {{"a43.y"}, "$a43.y"}, {{"a43.z"}, "$a43.z"}, {{"a43.t"}, "$a43.t"}, {{"a44.x"}, "$a44.x"}, {{"a44.y"}, "$a44.y"}, {{"a44.z"}, "$a44.z"}, {{"a44.t"}, "$a44.t"},
  {{"a45.x"}, "$a45.x"}, {{"a45.y"}, "$a45.y"}, {{"a45.z"}, "$a45.z"}, {{"a45.t"}, "$a45.t"}, {{"a46.x"}, "$a46.x"}, {{"a46.y"}, "$a46.y"}, {{"a46.z"}, "$a46.z"},
  {{"a46.t"}, "$a46.t"}, {{"a47.x"}, "$a47.x"}, {{"a47.y"}, "$a47.y"}, {{"a47.z"}, "$a47.z"}, {{"a47.t"}, "$a47.t"}, {{"a48.x"}, "$a48.x"}, {{"a48.y"}, "$a48.y"},
  {{"a48.z"}, "$a48.z"}, {{"a48.t"}, "$a48.t"}, {{"a49.x"}, "$a49.x"}, {{"a49.y"}, "$a49.y"}, {{"a49.z"}, "$a49.z"}, {{"a49.t"}, "$a49.t"}, {{"a50.x"}, "$a50.x"},
  {{"a50.y"}, "$a50.y"}, {{"a50.z"}, "$a50.z"}, {{"a50.t"}, "$a50.t"}, {{"a51.x"}, "$a51.x"}, {{"a51.y"}, "$a51.y"}, {{"a51.z"}, "$a51.z"}, {{"a51.t"}, "$a51.t"},
  {{"a52.x"}, "$a52.x"}, {{"a52.y"}, "$a52.y"}, {{"a52.z"}, "$a52.z"}, {{"a52.t"}, "$a52.t"}, {{"a53.x"}, "$a53.x"}, {{"a53.y"}, "$a53.y"}, {{"a53.z"}, "$a53.z"},
  {{"a53.t"}, "$a53.t"}, {{"a54.x"}, "$a54.x"}, {{"a54.y"}, "$a54.y"}, {{"a54.z"}, "$a54.z"}, {{"a54.t"}, "$a54.t"}, {{"a55.x"}, "$a55.x"}, {{"a55.y"}, "$a55.y"},
  {{"a55.z"}, "$a55.z"}, {{"a55.t"}, "$a55.t"}, {{"a56.x"}, "$a56.x"}, {{"a56.y"}, "$a56.y"}, {{"a56.z"}, "$a56.z"}, {{"a56.t"}, "$a56.t"}, {{"a57.x"}, "$a57.x"},
  {{"a57.y"}, "$a57.y"}, {{"a57.z"}, "$a57.z"}, {{"a57.t"}, "$a57.t"}, {{"a58.x"}, "$a58.x"}, {{"a58.y"}, "$a58.y"}, {{"a58.z"}, "$a58.z"}, {{"a58.t"}, "$a58.t"},
  {{"a59.x"}, "$a59.x"}, {{"a59.y"}, "$a59.y"}, {{"a59.z"}, "$a59.z"}, {{"a59.t"}, "$a59.t"}, {{"a60.x"}, "$a60.x"}, {{"a60.y"}, "$a60.y"}, {{"a60.z"}, "$a60.z"},
  {{"a60.t"}, "$a60.t"}, {{"a61.x"}, "$a61.x"}, {{"a61.y"}, "$a61.y"}, {{"a61.z"}, "$a61.z"}, {{"a61.t"}, "$a61.t"}, {{"a62.x"}, "$a62.x"}, {{"a62.y"}, "$a62.y"},
  {{"a62.z"}, "$a62.z"}, {{"a62.t"}, "$a62.t"}, {{"a63.x"}, "$a63.x"}, {{"a63.y"}, "$a63.y"}, {{"a63.z"}, "$a63.z"}, {{"a63.t"}, "$a63.t"},
  /* TCA 128-bit */
  {{"a0.lo"}, "$a0.lo"}, {{"a0.hi"}, "$a0.hi"}, {{"a1.lo"}, "$a1.lo"}, {{"a1.hi"}, "$a1.hi"}, {{"a2.lo"}, "$a2.lo"}, {{"a2.hi"}, "$a2.hi"}, {{"a3.lo"}, "$a3.lo"},
  {{"a3.hi"}, "$a3.hi"}, {{"a4.lo"}, "$a4.lo"}, {{"a4.hi"}, "$a4.hi"}, {{"a5.lo"}, "$a5.lo"}, {{"a5.hi"}, "$a5.hi"}, {{"a6.lo"}, "$a6.lo"}, {{"a6.hi"}, "$a6.hi"},
  {{"a7.lo"}, "$a7.lo"}, {{"a7.hi"}, "$a7.hi"}, {{"a8.lo"}, "$a8.lo"}, {{"a8.hi"}, "$a8.hi"}, {{"a9.lo"}, "$a9.lo"}, {{"a9.hi"}, "$a9.hi"}, {{"a10.lo"}, "$a10.lo"},
  {{"a10.hi"}, "$a10.hi"}, {{"a11.lo"}, "$a11.lo"}, {{"a11.hi"}, "$a11.hi"}, {{"a12.lo"}, "$a12.lo"}, {{"a12.hi"}, "$a12.hi"}, {{"a13.lo"}, "$a13.lo"},
  {{"a13.hi"}, "$a13.hi"}, {{"a14.lo"}, "$a14.lo"}, {{"a14.hi"}, "$a14.hi"}, {{"a15.lo"}, "$a15.lo"}, {{"a15.hi"}, "$a15.hi"}, {{"a16.lo"}, "$a16.lo"},
  {{"a16.hi"}, "$a16.hi"}, {{"a17.lo"}, "$a17.lo"}, {{"a17.hi"}, "$a17.hi"}, {{"a18.lo"}, "$a18.lo"}, {{"a18.hi"}, "$a18.hi"}, {{"a19.lo"}, "$a19.lo"},
  {{"a19.hi"}, "$a19.hi"}, {{"a20.lo"}, "$a20.lo"}, {{"a20.hi"}, "$a20.hi"}, {{"a21.lo"}, "$a21.lo"}, {{"a21.hi"}, "$a21.hi"}, {{"a22.lo"}, "$a22.lo"},
  {{"a22.hi"}, "$a22.hi"}, {{"a23.lo"}, "$a23.lo"}, {{"a23.hi"}, "$a23.hi"}, {{"a24.lo"}, "$a24.lo"}, {{"a24.hi"}, "$a24.hi"}, {{"a25.lo"}, "$a25.lo"},
  {{"a25.hi"}, "$a25.hi"}, {{"a26.lo"}, "$a26.lo"}, {{"a26.hi"}, "$a26.hi"}, {{"a27.lo"}, "$a27.lo"}, {{"a27.hi"}, "$a27.hi"}, {{"a28.lo"}, "$a28.lo"},
  {{"a28.hi"}, "$a28.hi"}, {{"a29.lo"}, "$a29.lo"}, {{"a29.hi"}, "$a29.hi"}, {{"a30.lo"}, "$a30.lo"}, {{"a30.hi"}, "$a30.hi"}, {{"a31.lo"}, "$a31.lo"},
  {{"a31.hi"}, "$a31.hi"}, {{"a32.lo"}, "$a32.lo"}, {{"a32.hi"}, "$a32.hi"}, {{"a33.lo"}, "$a33.lo"}, {{"a33.hi"}, "$a33.hi"}, {{"a34.lo"}, "$a34.lo"},
  {{"a34.hi"}, "$a34.hi"}, {{"a35.lo"}, "$a35.lo"}, {{"a35.hi"}, "$a35.hi"}, {{"a36.lo"}, "$a36.lo"}, {{"a36.hi"}, "$a36.hi"}, {{"a37.lo"}, "$a37.lo"},
  {{"a37.hi"}, "$a37.hi"}, {{"a38.lo"}, "$a38.lo"}, {{"a38.hi"}, "$a38.hi"}, {{"a39.lo"}, "$a39.lo"}, {{"a39.hi"}, "$a39.hi"}, {{"a40.lo"}, "$a40.lo"},
  {{"a40.hi"}, "$a40.hi"}, {{"a41.lo"}, "$a41.lo"}, {{"a41.hi"}, "$a41.hi"}, {{"a42.lo"}, "$a42.lo"}, {{"a42.hi"}, "$a42.hi"}, {{"a43.lo"}, "$a43.lo"},
  {{"a43.hi"}, "$a43.hi"}, {{"a44.lo"}, "$a44.lo"}, {{"a44.hi"}, "$a44.hi"}, {{"a45.lo"}, "$a45.lo"}, {{"a45.hi"}, "$a45.hi"}, {{"a46.lo"}, "$a46.lo"},
  {{"a46.hi"}, "$a46.hi"}, {{"a47.lo"}, "$a47.lo"}, {{"a47.hi"}, "$a47.hi"}, {{"a48.lo"}, "$a48.lo"}, {{"a48.hi"}, "$a48.hi"}, {{"a49.lo"}, "$a49.lo"},
  {{"a49.hi"}, "$a49.hi"}, {{"a50.lo"}, "$a50.lo"}, {{"a50.hi"}, "$a50.hi"}, {{"a51.lo"}, "$a51.lo"}, {{"a51.hi"}, "$a51.hi"}, {{"a52.lo"}, "$a52.lo"},
  {{"a52.hi"}, "$a52.hi"}, {{"a53.lo"}, "$a53.lo"}, {{"a53.hi"}, "$a53.hi"}, {{"a54.lo"}, "$a54.lo"}, {{"a54.hi"}, "$a54.hi"}, {{"a55.lo"}, "$a55.lo"},
  {{"a55.hi"}, "$a55.hi"}, {{"a56.lo"}, "$a56.lo"}, {{"a56.hi"}, "$a56.hi"}, {{"a57.lo"}, "$a57.lo"}, {{"a57.hi"}, "$a57.hi"}, {{"a58.lo"}, "$a58.lo"},
  {{"a58.hi"}, "$a58.hi"}, {{"a59.lo"}, "$a59.lo"}, {{"a59.hi"}, "$a59.hi"}, {{"a60.lo"}, "$a60.lo"}, {{"a60.hi"}, "$a60.hi"}, {{"a61.lo"}, "$a61.lo"},
  {{"a61.hi"}, "$a61.hi"}, {{"a62.lo"}, "$a62.lo"}, {{"a62.hi"}, "$a62.hi"}, {{"a63.lo"}, "$a63.lo"}, {{"a63.hi"}, "$a63.hi"},
  /* TCA base 256-bit */
  {{"a0"}, "$a0"}, {{"a1"}, "$a1"}, {{"a2"}, "$a2"}, {{"a3"}, "$a3"}, {{"a4"}, "$a4"}, {{"a5"}, "$a5"}, {{"a6"}, "$a6"}, {{"a7"}, "$a7"}, {{"a8"}, "$a8"}, {{"a9"}, "$a9"},
  {{"a10"}, "$a10"}, {{"a11"}, "$a11"}, {{"a12"}, "$a12"}, {{"a13"}, "$a13"}, {{"a14"}, "$a14"}, {{"a15"}, "$a15"}, {{"a16"}, "$a16"}, {{"a17"}, "$a17"}, {{"a18"}, "$a18"},
  {{"a19"}, "$a19"}, {{"a20"}, "$a20"}, {{"a21"}, "$a21"}, {{"a22"}, "$a22"}, {{"a23"}, "$a23"}, {{"a24"}, "$a24"}, {{"a25"}, "$a25"}, {{"a26"}, "$a26"}, {{"a27"}, "$a27"},
  {{"a28"}, "$a28"}, {{"a29"}, "$a29"}, {{"a30"}, "$a30"}, {{"a31"}, "$a31"}, {{"a32"}, "$a32"}, {{"a33"}, "$a33"}, {{"a34"}, "$a34"}, {{"a35"}, "$a35"}, {{"a36"}, "$a36"},
  {{"a37"}, "$a37"}, {{"a38"}, "$a38"}, {{"a39"}, "$a39"}, {{"a40"}, "$a40"}, {{"a41"}, "$a41"}, {{"a42"}, "$a42"}, {{"a43"}, "$a43"}, {{"a44"}, "$a44"}, {{"a45"}, "$a45"},
  {{"a46"}, "$a46"}, {{"a47"}, "$a47"}, {{"a48"}, "$a48"}, {{"a49"}, "$a49"}, {{"a50"}, "$a50"}, {{"a51"}, "$a51"}, {{"a52"}, "$a52"}, {{"a53"}, "$a53"}, {{"a54"}, "$a54"},
  {{"a55"}, "$a55"}, {{"a56"}, "$a56"}, {{"a57"}, "$a57"}, {{"a58"}, "$a58"}, {{"a59"}, "$a59"}, {{"a60"}, "$a60"}, {{"a61"}, "$a61"}, {{"a62"}, "$a62"}, {{"a63"}, "$a63"},
  {{"a0a1"}, "$a0a1"}, {{"a2a3"}, "$a2a3"}, {{"a4a5"}, "$a4a5"}, {{"a6a7"}, "$a6a7"},
  /* TCA 512-bit */
  {{"a8a9"}, "$a8a9"}, {{"a10a11"}, "$a10a11"}, {{"a12a13"}, "$a12a13"}, {{"a14a15"}, "$a14a15"}, {{"a16a17"}, "$a16a17"}, {{"a18a19"}, "$a18a19"}, {{"a20a21"}, "$a20a21"},
  {{"a22a23"}, "$a22a23"}, {{"a24a25"}, "$a24a25"}, {{"a26a27"}, "$a26a27"}, {{"a28a29"}, "$a28a29"}, {{"a30a31"}, "$a30a31"}, {{"a32a33"}, "$a32a33"},
  {{"a34a35"}, "$a34a35"}, {{"a36a37"}, "$a36a37"}, {{"a38a39"}, "$a38a39"}, {{"a40a41"}, "$a40a41"}, {{"a42a43"}, "$a42a43"}, {{"a44a45"}, "$a44a45"},
  {{"a46a47"}, "$a46a47"}, {{"a48a49"}, "$a48a49"}, {{"a50a51"}, "$a50a51"}, {{"a52a53"}, "$a52a53"}, {{"a54a55"}, "$a54a55"}, {{"a56a57"}, "$a56a57"},
  {{"a58a59"}, "$a58a59"}, {{"a60a61"}, "$a60a61"}, {{"a62a63"}, "$a62a63"},
  /* TCA 1024-bit */
  {{"a0a1a2a3"}, "$a0a1a2a3"}, {{"a4a5a6a7"}, "$a4a5a6a7"}, {{"a8a9a10a11"}, "$a8a9a10a11"}, {{"a12a13a14a15"}, "$a12a13a14a15"}, {{"a16a17a18a19"}, "$a16a17a18a19"},
  {{"a20a21a22a23"}, "$a20a21a22a23"}, {{"a24a25a26a27"}, "$a24a25a26a27"}, {{"a28a29a30a31"}, "$a28a29a30a31"}, {{"a32a33a34a35"}, "$a32a33a34a35"},
  {{"a36a37a38a39"}, "$a36a37a38a39"}, {{"a40a41a42a43"}, "$a40a41a42a43"}, {{"a44a45a46a47"}, "$a44a45a46a47"}, {{"a48a49a50a51"}, "$a48a49a50a51"},
  {{"a52a53a54a55"}, "$a52a53a54a55"}, {{"a56a57a58a59"}, "$a56a57a58a59"}, {{"a60a61a62a63"}, "$a60a61a62a63"},
  /* System registers */
  {{"pc"}, "$pc"}, {{"ps"}, "$ps"}, {{"spc"}, "$spc"}, {{"sps"}, "$sps"}, {{"sspc"}, "$sspc"}, {{"ssps"}, "$ssps"}, {{"sr3"}, "$sr3"}, {{"sr4"}, "$sr4"}, {{"cs"}, "$cs"},
  {{"ra"}, "$ra"}, {{"pcr"}, "$pcr"}, {{"ls"}, "$ls"}, {{"le"}, "$le"}, {{"lc"}, "$lc"}, {{"ea"}, "$ea"}, {{"ev"}, "$ev"}, {{"res0"}, "$res0"}, {{"res1"}, "$res1"},
  {{"res2"}, "$res2"}, {{"res3"}, "$res3"}, {{"ev4"}, "$ev4"}, {{"men"}, "$men"}, {{"pmsa"}, "$pmsa"}, {{"aepc"}, "$aepc"}, {{"pm0"}, "$pm0"}, {{"pm1"}, "$pm1"},
  {{"pm2"}, "$pm2"}, {{"pm3"}, "$pm3"}, {{"pmc"}, "$pmc"}, {{"sr0"}, "$sr0"}, {{"sr1"}, "$sr1"}, {{"sr2"}, "$sr2"}, {{"t0v"}, "$t0v"}, {{"t1v"}, "$t1v"}, {{"tcr"}, "$tcr"},
  {{"wdc"}, "$wdc"}, {{"wdr"}, "$wdr"}, {{"ill"}, "$ill"}, {{"ile"}, "$ile"}, {{"ilh"}, "$ilh"}, {{"mmc"}, "$mmc"}, {{"tel"}, "$tel"}, {{"teh"}, "$teh"}, {{"dv"}, "$dv"},
  {{"oce0"}, "$oce0"}, {{"oce1"}, "$oce1"}, {{"ocec"}, "$ocec"}, {{"ocea"}, "$ocea"}, {{"es"}, "$es"}, {{"ilr"}, "$ilr"}, {{"ws"}, "$ws"}, {{"mes"}, "$mes"}
};

ArrayRef<TargetInfo::GCCRegAlias> KVXTargetInfo::getGCCRegAliases() const {
  return llvm::makeArrayRef(GCCRegAliases);
}

bool KVXTargetInfo::validateAsmConstraint(
    const char *&Name, TargetInfo::ConstraintInfo &Info) const {
  if (*Name == 'x') { // TCA vector registers
    Info.setAllowsRegister();
    return true;
  }

  return false;
}

void KVXTargetInfo::adjust(LangOptions &Opts) {
  TargetInfo::adjust(Opts);

  // Keep vector aligned to its size.
  if (Opts.OpenCL)
    MaxVectorAlign = 0;
}

void KVXTargetInfo::getTargetDefines(const LangOptions &Opts,
                                     MacroBuilder &Builder) const {
  Builder.defineMacro("__ELF__", "1");
  Builder.defineMacro("__KVX__", "3");
  Builder.defineMacro("__kvx__", "3");
  Builder.defineMacro("__KV3_64__", "1");

  if (CPU == "kv3-2") {
    Builder.defineMacro("__KV3__", "2");
    Builder.defineMacro("__kv3__", "2");
    Builder.defineMacro("__kv3_2__", "1");
    Builder.defineMacro("__kvxarch_kv3_2", "1");
  } else { // kv3-1
    Builder.defineMacro("__KV3__", "1");
    Builder.defineMacro("__kv3__", "1");
    Builder.defineMacro("__kv3_1__", "1");
    Builder.defineMacro("__kvxarch_kv3_1", "1");
  }

  Builder.defineMacro("__bypass", "__attribute__((address_space(256)))");
  Builder.defineMacro("__preload", "__attribute__((address_space(257)))");
  Builder.defineMacro("__speculate", "__attribute__((address_space(258)))");
}

const Builtin::Info KVXTargetInfo::BuiltinInfo[] = {
#define BUILTIN(ID, TYPE, ATTRS)                                               \
  { #ID, TYPE, ATTRS, nullptr, ALL_LANGUAGES, nullptr }                        \
  ,
#include "clang/Basic/BuiltinsKVX.def"
};

bool KVXTargetInfo::isValidCPUName(StringRef Name) const {
  if (Name == "kv3-1" || Name == "kv3-2")
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
  Values.push_back("kv3-1");
  Values.push_back("kv3-2");
}

bool KVXTargetInfo::DecodeTargetTypeFromStr(const char *&Str,
                                            const ASTContext &Context,
                                            bool &AllowTypeModifiers,
                                            QualType &Type) const {
  switch (*Str++) {
  case 'x': { // TCA vector type, should be of size 256, 512 or 1024
    AllowTypeModifiers = true;
    char *End;
    unsigned Size = strtoul(Str, &End, 10);
    assert(End != Str && "Missing tca vector size");
    Str = End;
    switch (Size) {
    case 256:
      Type = Context.KVXTCAVectorTy;
      return false;
    case 512:
      Type = Context.KVXTCAWideTy;
      return false;
    case 1024:
      Type = Context.KVXTCAMatrixTy;
      return false;
    default:
      llvm::errs() << "TCA vector size: " << Size << '\n';
      llvm_unreachable("Got unknow tca size");
      return true;
    }
  }
  default:
    llvm_unreachable("Got unknow target type");
    break;
  }
  return true;
};

void KVXTargetInfo::setSupportedOpenCLOpts() {
  auto &Opts = getSupportedOpenCLOpts();

  Opts["cl_khr_byte_addressable_store"];
  Opts["cl_khr_global_int32_base_atomics"];
  Opts["cl_khr_global_int32_extended_atomics"];
  Opts["cl_khr_local_int32_base_atomics"];
  Opts["cl_khr_local_int32_extended_atomics"];
  Opts["cl_khr_fp16"];
  Opts["cl_khr_fp64"];
  Opts["cl_khr_int64_base_atomics"];
  Opts["cl_khr_int64_extended_atomics"];
  Opts["cles_khr_int64"];
}
