//===-- KVXInstrInfo.td - Target Description for KVX Target ---------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file describes the KVX instructions in TableGen format.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Instruction format superclass
//===----------------------------------------------------------------------===//

// This file was automatically generated,
//   *DO NOT EDIT*,
//   please contact code owner.
// Last generated: 2020-09-16 15:58:51.230203.

include "KVXOperandInfo.td"
include "KVXInstrFormats.td"


// multiclass MC_00 is used by:
//   defm SCALL
multiclass MC_00<string OpcStr> {
  def r : REGISTERZ_SIMPLE
    <(outs), (ins SingleReg:$a1),
     !strconcat (OpcStr, " $a1"),
     [/* no straightforward pattern */],
     ALL>;
  def s : SYSNUMBER_SIMPLE
    <(outs), (ins Sysnumber:$a1),
     !strconcat (OpcStr, " $a1"),
     [/* no straightforward pattern */]>;
}

// multiclass MC_01 is used by:
//   defm WFXL
//   defm WFXM
multiclass MC_01<string OpcStr> {
  def rst2 : SYSTEMT2_REGISTERZ_SIMPLE
    <(outs OnlyfxReg:$a1), (ins SingleReg:$a2),
     !strconcat (OpcStr, " $a1, $a2"),
     [/* no straightforward pattern */]>;
  def rsa : SYSTEMALONE_REGISTERZ_SIMPLE
    <(outs AloneReg:$a1), (ins SingleReg:$a2),
     !strconcat (OpcStr, " $a1, $a2"),
     [/* no straightforward pattern */]>;
  def rst4 : SYSTEMT4_REGISTERZ_SIMPLE
    <(outs SystemReg:$a1), (ins SingleReg:$a2),
     !strconcat (OpcStr, " $a1, $a2"),
     [/* no straightforward pattern */]>;
}

// multiclass MC_02 is used by:
//   defm GET
multiclass MC_02<string OpcStr> {
  def ss2 : REGISTERZ_SYSTEMS2_SIMPLE
    <(outs SingleReg:$a1), (ins OnlygetReg:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */]>;
  def ss3 : REGISTERZ_SYSTEMS3_SIMPLE
    <(outs SingleReg:$a1), (ins SystemReg:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */]>;
}

// multiclass MC_03 is used by:
//   defm SET
multiclass MC_03<string OpcStr> {
  def rst3 : SYSTEMT3_REGISTERZ_SIMPLE
    <(outs OnlysetReg:$a1), (ins SingleReg:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */]>;
  def rsa : SYSTEMALONE_REGISTERZ_SIMPLE
    <(outs AloneReg:$a1), (ins SingleReg:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */]>;
  def rsra : SYSTEMRA_REGISTERZ_SIMPLE
    <(outs OnlyraReg:$a1), (ins SingleReg:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */]>;
  def rst4 : SYSTEMT4_REGISTERZ_SIMPLE
    <(outs SystemReg:$a1), (ins SingleReg:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */]>;
}

// multiclass MC_04 is used by:
//   defm RSWAP
multiclass MC_04<string OpcStr> {
  let Constraints = "$a1 = $a1o, $a2 = $a2o" in
  def ss4 : REGISTERZ_SYSTEMS4_SIMPLE
    <(outs SingleReg:$a1o, OnlyswapReg:$a2o), (ins SingleReg:$a1, OnlyswapReg:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */]>;
  let Constraints = "$a1 = $a1o, $a2 = $a2o" in
  def sa : REGISTERZ_SYSTEMALONE_SIMPLE
    <(outs SingleReg:$a1o, AloneReg:$a2o), (ins SingleReg:$a1, AloneReg:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */]>;
  let Constraints = "$a1 = $a1o, $a2 = $a2o" in
  def ss3 : REGISTERZ_SYSTEMS3_SIMPLE
    <(outs SingleReg:$a1o, SystemReg:$a2o), (ins SingleReg:$a1, SystemReg:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */]>;
}

// multiclass MC_05 is used by:
//   defm LBZ
//   defm LBS
//   defm LHZ
//   defm LHS
//   defm LWZ
//   defm LWS
//   defm LD
let mayLoad = 1 in
multiclass MC_05<string OpcStr> {
  let isPredicable = 1 in {
  def ri10 : VARIANT_REGISTERW_SIGNED10_REGISTERZ_SIMPLE
    <(outs SingleReg:$a2), (ins Signed10:$a3, SingleReg:$a4, VariantMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3[$a4]"),
     [/* no straightforward pattern */]>;
  def ri37 : VARIANT_REGISTERW_UPPER27_LOWER10_REGISTERZ_DOUBLE
    <(outs SingleReg:$a2), (ins Signed37:$a3, SingleReg:$a4, VariantMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3[$a4]"),
     [/* no straightforward pattern */]>;
  def ri64 : VARIANT_REGISTERW_EXTEND27_UPPER27_LOWER10_REGISTERZ_TRIPLE
    <(outs SingleReg:$a2), (ins Wrapped64:$a3, SingleReg:$a4, VariantMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3[$a4]"),
     [/* no straightforward pattern */]>;
  }
  let Constraints = "$a4in = $a4" in {
  def rrc : VARIANT_LSUCOND_REGISTERY_REGISTERW_REGISTERZ_SIMPLE
    <(outs SingleReg:$a4), (ins SingleReg:$a5, VariantMod:$a1, ScalarcondMod:$a2, SingleReg:$a3, SingleReg:$a4in),
     !strconcat (OpcStr, "$a1$a2 $a3 ? $a4 = [$a5]"),
     [/* no straightforward pattern */]>;
  def ri27c : VARIANT_LSUCOND_REGISTERY_REGISTERW_OFFSET27_REGISTERZ_DOUBLE
    <(outs SingleReg:$a4), (ins Signed27:$a5, SingleReg:$a6, VariantMod:$a1, ScalarcondMod:$a2, SingleReg:$a3, SingleReg:$a4in),
     !strconcat (OpcStr, "$a1$a2 $a3 ? $a4 = $a5[$a6]"),
     [/* no straightforward pattern */]>;
  def ri54c : VARIANT_LSUCOND_REGISTERY_REGISTERW_EXTEND27_OFFSET27_REGISTERZ_TRIPLE
    <(outs SingleReg:$a4), (ins Signed54:$a5, SingleReg:$a6, VariantMod:$a1, ScalarcondMod:$a2, SingleReg:$a3, SingleReg:$a4in),
     !strconcat (OpcStr, "$a1$a2 $a3 ? $a4 = $a5[$a6]"),
     [/* no straightforward pattern */]>;
  }
  let isPredicable = 1 in
  def rr : VARIANT_DOSCALE_REGISTERW_REGISTERY_REGISTERZ_SIMPLE
    <(outs SingleReg:$a3), (ins SingleReg:$a4, SingleReg:$a5, VariantMod:$a1, DoscaleMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4[$a5]"),
     [/* no straightforward pattern */]>;
}

// multiclass MC_06 is used by:
//   defm LQ
let mayLoad = 1 in
multiclass MC_06<string OpcStr> {
  let isPredicable = 1 in {
  def ri10 : VARIANT_REGISTERM_SIGNED10_REGISTERZ_SIMPLE
    <(outs PairedReg:$a2), (ins Signed10:$a3, SingleReg:$a4, VariantMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3[$a4]"),
     [/* no straightforward pattern */]>;
  def ri37 : VARIANT_REGISTERM_UPPER27_LOWER10_REGISTERZ_DOUBLE
    <(outs PairedReg:$a2), (ins Signed37:$a3, SingleReg:$a4, VariantMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3[$a4]"),
     [/* no straightforward pattern */]>;
  def ri64 : VARIANT_REGISTERM_EXTEND27_UPPER27_LOWER10_REGISTERZ_TRIPLE
    <(outs PairedReg:$a2), (ins Wrapped64:$a3, SingleReg:$a4, VariantMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3[$a4]"),
     [/* no straightforward pattern */]>;
  }
  let Constraints = "$a4 = $a4o" in
  def rrc : VARIANT_LSUCOND_REGISTERY_REGISTERM_REGISTERZ_SIMPLE
    <(outs PairedReg:$a4o), (ins SingleReg:$a5, VariantMod:$a1, ScalarcondMod:$a2, SingleReg:$a3, PairedReg:$a4),
     !strconcat (OpcStr, "$a1$a2 $a3 ? $a4 = [$a5]"),
     [/* no straightforward pattern */]>;
  let Constraints = "$a4 = $a4o" in
  def ri27c : VARIANT_LSUCOND_REGISTERY_REGISTERM_OFFSET27_REGISTERZ_DOUBLE
    <(outs PairedReg:$a4o), (ins Signed27:$a5, SingleReg:$a6, VariantMod:$a1, ScalarcondMod:$a2, SingleReg:$a3, PairedReg:$a4),
     !strconcat (OpcStr, "$a1$a2 $a3 ? $a4 = $a5[$a6]"),
     [/* no straightforward pattern */]>;
  let Constraints = "$a4 = $a4o" in
  def ri54c : VARIANT_LSUCOND_REGISTERY_REGISTERM_EXTEND27_OFFSET27_REGISTERZ_TRIPLE
    <(outs PairedReg:$a4o), (ins Signed54:$a5, SingleReg:$a6, VariantMod:$a1, ScalarcondMod:$a2, SingleReg:$a3, PairedReg:$a4),
     !strconcat (OpcStr, "$a1$a2 $a3 ? $a4 = $a5[$a6]"),
     [/* no straightforward pattern */]>;
  let isPredicable = 1 in {
  def rr : VARIANT_DOSCALE_REGISTERM_REGISTERY_REGISTERZ_SIMPLE
    <(outs PairedReg:$a3), (ins SingleReg:$a4, SingleReg:$a5, VariantMod:$a1, DoscaleMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4[$a5]"),
     [/* no straightforward pattern */]>;
  }
}

// multiclass MC_07 is used by:
//   defm LO
let mayLoad = 1 in
multiclass MC_07<string OpcStr> {
  let isPredicable = 1 in {
  def ri10 : VARIANT_REGISTERN_SIGNED10_REGISTERZ_SIMPLE
    <(outs QuadReg:$a2), (ins Signed10:$a3, SingleReg:$a4, VariantMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3[$a4]"),
     [/* no straightforward pattern */]>;
  def ri37 : VARIANT_REGISTERN_UPPER27_LOWER10_REGISTERZ_DOUBLE
    <(outs QuadReg:$a2), (ins Signed37:$a3, SingleReg:$a4, VariantMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3[$a4]"),
     [/* no straightforward pattern */]>;
  def ri64 : VARIANT_REGISTERN_EXTEND27_UPPER27_LOWER10_REGISTERZ_TRIPLE
    <(outs QuadReg:$a2), (ins Wrapped64:$a3, SingleReg:$a4, VariantMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3[$a4]"),
     [/* no straightforward pattern */]>;
  }
  let Constraints = "$a4 = $a4o" in
  def rrc : VARIANT_LSUCOND_REGISTERY_REGISTERN_REGISTERZ_SIMPLE
    <(outs QuadReg:$a4o), (ins SingleReg:$a5, VariantMod:$a1, ScalarcondMod:$a2, SingleReg:$a3, QuadReg:$a4),
     !strconcat (OpcStr, "$a1$a2 $a3 ? $a4 = [$a5]"),
     [/* no straightforward pattern */]>;
  let Constraints = "$a4 = $a4o" in
  def ri27c : VARIANT_LSUCOND_REGISTERY_REGISTERN_OFFSET27_REGISTERZ_DOUBLE
    <(outs QuadReg:$a4o), (ins Signed27:$a5, SingleReg:$a6, VariantMod:$a1, ScalarcondMod:$a2, SingleReg:$a3, QuadReg:$a4),
     !strconcat (OpcStr, "$a1$a2 $a3 ? $a4 = $a5[$a6]"),
     [/* no straightforward pattern */]>;
  let Constraints = "$a4 = $a4o" in
  def ri54c : VARIANT_LSUCOND_REGISTERY_REGISTERN_EXTEND27_OFFSET27_REGISTERZ_TRIPLE
    <(outs QuadReg:$a4o), (ins Signed54:$a5, SingleReg:$a6, VariantMod:$a1, ScalarcondMod:$a2, SingleReg:$a3, QuadReg:$a4),
     !strconcat (OpcStr, "$a1$a2 $a3 ? $a4 = $a5[$a6]"),
     [/* no straightforward pattern */]>;
  let isPredicable = 1 in {
  def rr : VARIANT_DOSCALE_REGISTERN_REGISTERY_REGISTERZ_SIMPLE
    <(outs QuadReg:$a3), (ins SingleReg:$a4, SingleReg:$a5, VariantMod:$a1, DoscaleMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4[$a5]"),
     [/* no straightforward pattern */]>;
  }
}

// multiclass MC_08 is used by:
//   defm LV
let mayLoad = 1 in
multiclass MC_08<string OpcStr> {
  let isPredicable = 1 in {
  def ri10 : SPECULATE_REGISTERA_SIGNED10_REGISTERZ_SIMPLE
    <(outs VectorReg:$a2), (ins Signed10:$a3, SingleReg:$a4, SpeculateMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3[$a4]"),
     [/* no straightforward pattern */]>;
  def ri37 : SPECULATE_REGISTERA_UPPER27_LOWER10_REGISTERZ_DOUBLE
    <(outs VectorReg:$a2), (ins Signed37:$a3, SingleReg:$a4, SpeculateMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3[$a4]"),
     [/* no straightforward pattern */]>;
  def ri64 : SPECULATE_REGISTERA_EXTEND27_UPPER27_LOWER10_REGISTERZ_TRIPLE
    <(outs VectorReg:$a2), (ins Wrapped64:$a3, SingleReg:$a4, SpeculateMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3[$a4]"),
     [/* no straightforward pattern */]>;
  }
  let Constraints = "$a4 = $a4o" in
  def rrc : SPECULATE_LSUCOND_REGISTERY_REGISTERA_REGISTERZ_SIMPLE
    <(outs VectorReg:$a4o), (ins SingleReg:$a5, VectorReg:$a4, SpeculateMod:$a1, ScalarcondMod:$a2, SingleReg:$a3),
     !strconcat (OpcStr, "$a1$a2 $a3 ? $a4 = [$a5]"),
     [/* no straightforward pattern */]>;
  let Constraints = "$a4 = $a4o" in
  def ri27c : SPECULATE_LSUCOND_REGISTERY_REGISTERA_OFFSET27_REGISTERZ_DOUBLE
    <(outs VectorReg:$a4o), (ins Signed27:$a5, SingleReg:$a6, VectorReg:$a4, SpeculateMod:$a1, ScalarcondMod:$a2, SingleReg:$a3),
     !strconcat (OpcStr, "$a1$a2 $a3 ? $a4 = $a5[$a6]"),
     [/* no straightforward pattern */]>;
  let Constraints = "$a4 = $a4o" in
  def ri54c : SPECULATE_LSUCOND_REGISTERY_REGISTERA_EXTEND27_OFFSET27_REGISTERZ_TRIPLE
    <(outs VectorReg:$a4o), (ins Signed54:$a5, SingleReg:$a6, VectorReg:$a4, SpeculateMod:$a1, ScalarcondMod:$a2, SingleReg:$a3),
     !strconcat (OpcStr, "$a1$a2 $a3 ? $a4 = $a5[$a6]"),
     [/* no straightforward pattern */]>;
  let isPredicable = 1 in {
  def rr : SPECULATE_DOSCALE_REGISTERA_REGISTERY_REGISTERZ_SIMPLE
    <(outs VectorReg:$a3), (ins SingleReg:$a4, SingleReg:$a5, SpeculateMod:$a1, DoscaleMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4[$a5]"),
     [/* no straightforward pattern */]>;
  def ri10cs : COLUMN_SPECULATE_REGISTERAQ_SIGNED10_REGISTERZ_SIMPLE
    <(outs MatrixReg:$a3), (ins Signed10:$a4, SingleReg:$a5, ColumnMod:$a1, SpeculateMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4[$a5]"),
     [/* no straightforward pattern */]>;
  def ri37cs : COLUMN_SPECULATE_REGISTERAQ_UPPER27_LOWER10_REGISTERZ_DOUBLE
    <(outs MatrixReg:$a3), (ins Signed37:$a4, SingleReg:$a5, ColumnMod:$a1, SpeculateMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4[$a5]"),
     [/* no straightforward pattern */]>;
  def ri64cs : COLUMN_SPECULATE_REGISTERAQ_EXTEND27_UPPER27_LOWER10_REGISTERZ_TRIPLE
    <(outs MatrixReg:$a3), (ins Wrapped64:$a4, SingleReg:$a5, ColumnMod:$a1, SpeculateMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4[$a5]"),
     [/* no straightforward pattern */]>;
  }
  def rrccs : COLUMN_SPECULATE_LSUCOND_REGISTERY_REGISTERAQ_REGISTERZ_SIMPLE
    <(outs MatrixReg:$a5), (ins SingleReg:$a6, ColumnMod:$a1, SpeculateMod:$a2, ScalarcondMod:$a3, SingleReg:$a4),
     !strconcat (OpcStr, "$a1$a2$a3 $a4 ? $a5 = [$a6]"),
     [/* no straightforward pattern */]>;
  def ri27ccs : COLUMN_SPECULATE_LSUCOND_REGISTERY_REGISTERAQ_OFFSET27_REGISTERZ_DOUBLE
    <(outs MatrixReg:$a5), (ins Signed27:$a6, SingleReg:$a7, ColumnMod:$a1, SpeculateMod:$a2, ScalarcondMod:$a3, SingleReg:$a4),
     !strconcat (OpcStr, "$a1$a2$a3 $a4 ? $a5 = $a6[$a7]"),
     [/* no straightforward pattern */]>;
  def ri54ccs : COLUMN_SPECULATE_LSUCOND_REGISTERY_REGISTERAQ_EXTEND27_OFFSET27_REGISTERZ_TRIPLE
    <(outs MatrixReg:$a5), (ins Signed54:$a6, SingleReg:$a7, ColumnMod:$a1, SpeculateMod:$a2, ScalarcondMod:$a3, SingleReg:$a4),
     !strconcat (OpcStr, "$a1$a2$a3 $a4 ? $a5 = $a6[$a7]"),
     [/* no straightforward pattern */]>;
  let isPredicable = 1 in {
  def rrcs : COLUMN_SPECULATE_DOSCALE_REGISTERAQ_REGISTERY_REGISTERZ_SIMPLE
    <(outs MatrixReg:$a4), (ins SingleReg:$a5, SingleReg:$a6, ColumnMod:$a1, SpeculateMod:$a2, DoscaleMod:$a3),
     !strconcat (OpcStr, "$a1$a2$a3 $a4 = $a5[$a6]"),
     [/* no straightforward pattern */]>;
  }
}

// multiclass MC_09 is used by:
//   defm SB
//   defm SH
//   defm SW
//   defm SD
let mayStore = 1 in
multiclass MC_09<string OpcStr> {
  let isPredicable = 1 in {
  def ri10 : SIGNED10_REGISTERZ_REGISTERT_SIMPLE
    <(outs), (ins Signed10:$a1, SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [/* no straightforward pattern */],
     LSU_AUXR_STORE>;
  def ri37 : UPPER27_LOWER10_REGISTERZ_REGISTERT_DOUBLE
    <(outs), (ins Signed37:$a1, SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [/* no straightforward pattern */],
     LSU_AUXR_X_STORE>;
  def ri64 : EXTEND27_UPPER27_LOWER10_REGISTERZ_REGISTERT_TRIPLE
    <(outs), (ins Wrapped64:$a1, SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [/* no straightforward pattern */],
     LSU_AUXR_Y_STORE>;
  def rr : DOSCALE_REGISTERY_REGISTERZ_REGISTERT_SIMPLE
    <(outs), (ins SingleReg:$a2, SingleReg:$a3, SingleReg:$a4, DoscaleMod:$a1),
     !strconcat (OpcStr, "$a1 $a2[$a3] = $a4"),
     [/* no straightforward pattern */],
     LSU_AUXR_STORE>;
  }
  def rrc : LSUCOND_REGISTERY_REGISTERZ_REGISTERT_SIMPLE
    <(outs), (ins SingleReg:$a3, SingleReg:$a4, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? [$a3] = $a4"),
     [/* no straightforward pattern */],
     LSU_AUXR_STORE>;

  def ri27c : LSUCOND_REGISTERY_OFFSET27_REGISTERZ_REGISTERT_DOUBLE
    <(outs), (ins Signed27:$a3, SingleReg:$a4, SingleReg:$a5, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? $a3[$a4] = $a5"),
     [/* no straightforward pattern */],
     LSU_AUXR_X_STORE>;
  def ri54c : LSUCOND_REGISTERY_EXTEND27_OFFSET27_REGISTERZ_REGISTERT_TRIPLE
    <(outs), (ins Signed54:$a3, SingleReg:$a4, SingleReg:$a5, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? $a3[$a4] = $a5"),
     [/* no straightforward pattern */],
     LSU_AUXR_Y_STORE>;
}

// multiclass MC_0A is used by:
//   defm SQ
let mayStore = 1 in
multiclass MC_0A<string OpcStr> {
  let isPredicable = 1 in {
  def ri10 : SIGNED10_REGISTERZ_REGISTERU_SIMPLE
    <(outs), (ins Signed10:$a1, SingleReg:$a2, PairedReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [/* no straightforward pattern */],
     LSU_AUXR_STORE>;
  def ri37 : UPPER27_LOWER10_REGISTERZ_REGISTERU_DOUBLE
    <(outs), (ins Signed37:$a1, SingleReg:$a2, PairedReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [/* no straightforward pattern */],
     LSU_AUXR_X_STORE>;
  def ri64 : EXTEND27_UPPER27_LOWER10_REGISTERZ_REGISTERU_TRIPLE
    <(outs), (ins Wrapped64:$a1, SingleReg:$a2, PairedReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [/* no straightforward pattern */],
     LSU_AUXR_Y_STORE>;
  def rr : DOSCALE_REGISTERY_REGISTERZ_REGISTERU_SIMPLE
    <(outs), (ins SingleReg:$a2, SingleReg:$a3, PairedReg:$a4, DoscaleMod:$a1),
     !strconcat (OpcStr, "$a1 $a2[$a3] = $a4"),
     [/* no straightforward pattern */],
     LSU_AUXR_STORE>;
  }
  def rrc : LSUCOND_REGISTERY_REGISTERZ_REGISTERU_SIMPLE
    <(outs), (ins SingleReg:$a3, PairedReg:$a4, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? [$a3] = $a4"),
     [/* no straightforward pattern */],
     LSU_AUXR_STORE>;
  def ri27c : LSUCOND_REGISTERY_OFFSET27_REGISTERZ_REGISTERU_DOUBLE
    <(outs), (ins Signed27:$a3, SingleReg:$a4, PairedReg:$a5, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? $a3[$a4] = $a5"),
     [/* no straightforward pattern */],
     LSU_AUXR_X_STORE>;
  def ri54c : LSUCOND_REGISTERY_EXTEND27_OFFSET27_REGISTERZ_REGISTERU_TRIPLE
    <(outs), (ins Signed54:$a3, SingleReg:$a4, PairedReg:$a5, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? $a3[$a4] = $a5"),
     [/* no straightforward pattern */],
     LSU_AUXR_Y_STORE>;
}

// multiclass MC_0B is used by:
//   defm SO
let mayStore = 1 in
multiclass MC_0B<string OpcStr> {
  let isPredicable = 1 in {
  def ri10 : SIGNED10_REGISTERZ_REGISTERV_SIMPLE
    <(outs), (ins Signed10:$a1, SingleReg:$a2, QuadReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [/* no straightforward pattern */]>;
  def ri37 : UPPER27_LOWER10_REGISTERZ_REGISTERV_DOUBLE
    <(outs), (ins Signed37:$a1, SingleReg:$a2, QuadReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [/* no straightforward pattern */]>;
  def ri64 : EXTEND27_UPPER27_LOWER10_REGISTERZ_REGISTERV_TRIPLE
    <(outs), (ins Wrapped64:$a1, SingleReg:$a2, QuadReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [/* no straightforward pattern */]>;
  def rr : DOSCALE_REGISTERY_REGISTERZ_REGISTERV_SIMPLE
    <(outs), (ins SingleReg:$a2, SingleReg:$a3, QuadReg:$a4, DoscaleMod:$a1),
     !strconcat (OpcStr, "$a1 $a2[$a3] = $a4"),
     [/* no straightforward pattern */]>;
  }
  def rrc : LSUCOND_REGISTERY_REGISTERZ_REGISTERV_SIMPLE
    <(outs), (ins SingleReg:$a3, QuadReg:$a4, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? [$a3] = $a4"),
     [/* no straightforward pattern */]>;
  def ri27c : LSUCOND_REGISTERY_OFFSET27_REGISTERZ_REGISTERV_DOUBLE
    <(outs), (ins Signed27:$a3, SingleReg:$a4, QuadReg:$a5, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? $a3[$a4] = $a5"),
     [/* no straightforward pattern */]>;
  def ri54c : LSUCOND_REGISTERY_EXTEND27_OFFSET27_REGISTERZ_REGISTERV_TRIPLE
    <(outs), (ins Signed54:$a3, SingleReg:$a4, QuadReg:$a5, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? $a3[$a4] = $a5"),
     [/* no straightforward pattern */]>;
}

// multiclass MC_0C is used by:
//   defm SV
let mayStore = 1 in
multiclass MC_0C<string OpcStr> {
  let isPredicable = 1 in {
  def ri10 : SIGNED10_REGISTERZ_REGISTERE_SIMPLE
    <(outs), (ins Signed10:$a1, SingleReg:$a2, VectorReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [/* no straightforward pattern */]>;
  def ri37 : UPPER27_LOWER10_REGISTERZ_REGISTERE_DOUBLE
    <(outs), (ins Signed37:$a1, SingleReg:$a2, VectorReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [/* no straightforward pattern */]>;
  def ri64 : EXTEND27_UPPER27_LOWER10_REGISTERZ_REGISTERE_TRIPLE
    <(outs), (ins Wrapped64:$a1, SingleReg:$a2, VectorReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [/* no straightforward pattern */]>;
  def rr : DOSCALE_REGISTERY_REGISTERZ_REGISTERE_SIMPLE
    <(outs), (ins SingleReg:$a2, SingleReg:$a3, VectorReg:$a4, DoscaleMod:$a1),
     !strconcat (OpcStr, "$a1 $a2[$a3] = $a4"),
     [/* no straightforward pattern */]>;
  }
  def rrc : LSUCOND_REGISTERY_REGISTERZ_REGISTERE_SIMPLE
    <(outs), (ins SingleReg:$a3, VectorReg:$a4, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? [$a3] = $a4"),
     [/* no straightforward pattern */]>;
  def ri27c : LSUCOND_REGISTERY_OFFSET27_REGISTERZ_REGISTERE_DOUBLE
    <(outs), (ins Signed27:$a3, SingleReg:$a4, VectorReg:$a5, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? $a3[$a4] = $a5"),
     [/* no straightforward pattern */]>;
  def ri54c : LSUCOND_REGISTERY_EXTEND27_OFFSET27_REGISTERZ_REGISTERE_TRIPLE
    <(outs), (ins Signed54:$a3, SingleReg:$a4, VectorReg:$a5, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? $a3[$a4] = $a5"),
     [/* no straightforward pattern */]>;
}

// multiclass MC_0D is used by:
//   defm ACSWAPW
//   defm ACSWAPD
// TODO: can't differentiate registerU from registerZ in OperandLatencies
let mayLoad = 1, mayStore = 1 in
multiclass MC_0D<string OpcStr> {
  let isPredicable = 1 in {
  let Constraints = "$a3 = $a3o" in
  def ri10 : SIGNED10_REGISTERZ_REGISTERU_SIMPLE
    <(outs PairedReg:$a3o), (ins Signed10:$a1, SingleReg:$a2, PairedReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [/* no straightforward pattern */],
     LSU_AUXR_AUXW_LOAD>;
  let Constraints = "$a3 = $a3o" in
  def ri37 : UPPER27_LOWER10_REGISTERZ_REGISTERU_DOUBLE
    <(outs PairedReg:$a3o), (ins Signed37:$a1, SingleReg:$a2, PairedReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [/* no straightforward pattern */],
     LSU_AUXR_AUXW_X_LOAD>;
  let Constraints = "$a3 = $a3o" in
  def ri64 : EXTEND27_UPPER27_LOWER10_REGISTERZ_REGISTERU_TRIPLE
    <(outs PairedReg:$a3o), (ins Wrapped64:$a1, SingleReg:$a2, PairedReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [/* no straightforward pattern */],
     LSU_AUXR_AUXW_Y_LOAD>;
  let Constraints = "$a4 = $a4o" in
  def rr : DOSCALE_REGISTERY_REGISTERZ_REGISTERU_SIMPLE
    <(outs PairedReg:$a4o), (ins SingleReg:$a2, SingleReg:$a3, PairedReg:$a4, DoscaleMod:$a1),
     !strconcat (OpcStr, "$a1 $a2[$a3] = $a4"),
     [/* no straightforward pattern */],
     LSU_AUXR_AUXW_LOAD>;
  }
  let Constraints = "$a4 = $a4o" in
  def rrc : LSUCOND_REGISTERY_REGISTERZ_REGISTERU_SIMPLE
    <(outs PairedReg:$a4o), (ins SingleReg:$a3, PairedReg:$a4, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? [$a3] = $a4"),
     [/* no straightforward pattern */],
     LSU_AUXR_AUXW_LOAD>;
  let Constraints = "$a5 = $a5o" in
  def ri27c : LSUCOND_REGISTERY_OFFSET27_REGISTERZ_REGISTERU_DOUBLE
    <(outs PairedReg:$a5o), (ins Signed27:$a3, SingleReg:$a4, PairedReg:$a5, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? $a3[$a4] = $a5"),
     [/* no straightforward pattern */],
     LSU_AUXR_AUXW_X_LOAD>;
  let Constraints = "$a5 = $a5o" in
  def ri54c : LSUCOND_REGISTERY_EXTEND27_OFFSET27_REGISTERZ_REGISTERU_TRIPLE
    <(outs PairedReg:$a5o), (ins Signed54:$a3, SingleReg:$a4, PairedReg:$a5, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? $a3[$a4] = $a5"),
     [/* no straightforward pattern */],
     LSU_AUXR_AUXW_Y_LOAD>;
}

// multiclass MC_0E is used by:
//   defm ALCLRW
//   defm ALCLRD
let mayLoad = 1, mayStore = 1 in
multiclass MC_0E<string OpcStr> {
  let isPredicable = 1 in {
  def ri10 : REGISTERW_SIGNED10_REGISTERZ_SIMPLE
    <(outs SingleReg:$a1), (ins Signed10:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2[$a3]"),
     [/* no straightforward pattern */]>;
  def ri37 : REGISTERW_UPPER27_LOWER10_REGISTERZ_DOUBLE
    <(outs SingleReg:$a1), (ins Signed37:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2[$a3]"),
     [/* no straightforward pattern */]>;
  def ri64 : REGISTERW_EXTEND27_UPPER27_LOWER10_REGISTERZ_TRIPLE
    <(outs SingleReg:$a1), (ins Wrapped64:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2[$a3]"),
     [/* no straightforward pattern */]>;
  def rr : DOSCALE_REGISTERW_REGISTERY_REGISTERZ_SIMPLE
    <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, DoscaleMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3[$a4]"),
     [/* no straightforward pattern */]>;
  }
  let Constraints = "$a3 = $a3o" in
  def rrc : LSUCOND_REGISTERY_REGISTERW_REGISTERZ_SIMPLE
    <(outs SingleReg:$a3o), (ins SingleReg:$a4, SingleReg:$a3, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? $a3 = [$a4]"),
     [/* no straightforward pattern */]>;
  let Constraints = "$a3 = $a3o" in
  def ri27c : LSUCOND_REGISTERY_REGISTERW_OFFSET27_REGISTERZ_DOUBLE
    <(outs SingleReg:$a3o), (ins Signed27:$a4, SingleReg:$a5, SingleReg:$a3, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? $a3 = $a4[$a5]"),
     [/* no straightforward pattern */]>;
  let Constraints = "$a3 = $a3o" in
  def ri54c : LSUCOND_REGISTERY_REGISTERW_EXTEND27_OFFSET27_REGISTERZ_TRIPLE
    <(outs SingleReg:$a3o), (ins Signed54:$a4, SingleReg:$a5, SingleReg:$a3, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? $a3 = $a4[$a5]"),
     [/* no straightforward pattern */]>;
}

// multiclass MC_0F is used by:
//   defm ALADDW
//   defm ALADDD
// TODO: cannot differentiate OperandLatencies for regT and regZ
let mayLoad = 1, mayStore = 1 in
multiclass MC_0F<string OpcStr> {
  let isPredicable = 1 in {
  let Constraints = "$a3 = $a3o" in
  def ri10 : SIGNED10_REGISTERZ_REGISTERT_SIMPLE
    <(outs SingleReg:$a3o), (ins Signed10:$a1, SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [/* no straightforward pattern */],
     LSU_AUXR_AUXW_LOAD>;
  let Constraints = "$a3 = $a3o" in
  def ri37 : UPPER27_LOWER10_REGISTERZ_REGISTERT_DOUBLE
    <(outs SingleReg:$a3o), (ins Signed37:$a1, SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [/* no straightforward pattern */],
     LSU_AUXR_AUXW_X_LOAD>;
  let Constraints = "$a3 = $a3o" in
  def ri64 : EXTEND27_UPPER27_LOWER10_REGISTERZ_REGISTERT_TRIPLE
    <(outs SingleReg:$a3o), (ins Wrapped64:$a1, SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [/* no straightforward pattern */],
     LSU_AUXR_AUXW_Y_LOAD>;
  let Constraints = "$a4 = $a4o" in
  def rr : DOSCALE_REGISTERY_REGISTERZ_REGISTERT_SIMPLE
    <(outs SingleReg:$a4o), (ins SingleReg:$a2, SingleReg:$a3, SingleReg:$a4, DoscaleMod:$a1),
     !strconcat (OpcStr, "$a1 $a2[$a3] = $a4"),
     [/* no straightforward pattern */],
     LSU_AUXR_AUXW_LOAD>;
  }
  let Constraints = "$a4 = $a4o" in
  def rrc : LSUCOND_REGISTERY_REGISTERZ_REGISTERT_SIMPLE
    <(outs SingleReg:$a4o), (ins SingleReg:$a3, SingleReg:$a4, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? [$a3] = $a4"),
     [/* no straightforward pattern */],
     LSU_AUXR_AUXW_LOAD>;
  let Constraints = "$a5 = $a5o" in
  def ri27c : LSUCOND_REGISTERY_OFFSET27_REGISTERZ_REGISTERT_DOUBLE
    <(outs SingleReg:$a5o), (ins Signed27:$a3, SingleReg:$a4, SingleReg:$a5, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? $a3[$a4] = $a5"),
     [/* no straightforward pattern */],
     LSU_AUXR_AUXW_X_LOAD>;
  let Constraints = "$a5 = $a5o" in
  def ri54c : LSUCOND_REGISTERY_EXTEND27_OFFSET27_REGISTERZ_REGISTERT_TRIPLE
    <(outs SingleReg:$a5o), (ins Signed54:$a3, SingleReg:$a4, SingleReg:$a5, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? $a3[$a4] = $a5"),
     [/* no straightforward pattern */],
     LSU_AUXR_AUXW_Y_LOAD>;
}

// multiclass MC_10 is used by:
//   defm DTOUCHL
//   defm DINVALL
//   defm DZEROL
//   defm IINVALS
multiclass MC_10<string OpcStr> {
  let isPredicable = 1 in {
  def ri10 : SIGNED10_REGISTERZ_SIMPLE
    <(outs), (ins Signed10:$a1, SingleReg:$a2),
     !strconcat (OpcStr, " $a1[$a2]"),
     [/* no straightforward pattern */]>;
  def ri37 : UPPER27_LOWER10_REGISTERZ_DOUBLE
    <(outs), (ins Signed37:$a1, SingleReg:$a2),
     !strconcat (OpcStr, " $a1[$a2]"),
     [/* no straightforward pattern */]>;
  def ri64 : EXTEND27_UPPER27_LOWER10_REGISTERZ_TRIPLE
    <(outs), (ins Wrapped64:$a1, SingleReg:$a2),
     !strconcat (OpcStr, " $a1[$a2]"),
     [/* no straightforward pattern */]>;
  def rr : REGISTERY_REGISTERZ_SIMPLE
    <(outs), (ins SingleReg:$a1, SingleReg:$a2),
     !strconcat (OpcStr, " $a1[$a2]"),
     [/* no straightforward pattern */]>;
  }
  def rrc : LSUCOND_REGISTERY_REGISTERZ_SIMPLE
    <(outs), (ins SingleReg:$a3, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? [$a3]"),
     [/* no straightforward pattern */]>;
  def ri27c : LSUCOND_REGISTERY_OFFSET27_REGISTERZ_DOUBLE
    <(outs), (ins Signed27:$a3, SingleReg:$a4, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? $a3[$a4]"),
     [/* no straightforward pattern */]>;
  def ri54c : LSUCOND_REGISTERY_EXTEND27_OFFSET27_REGISTERZ_TRIPLE
    <(outs), (ins Signed54:$a3, SingleReg:$a4, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? $a3[$a4]"),
     [/* no straightforward pattern */]>;
}

// multiclass MC_11 is used by:
//   defm ADDD
//   defm SBFD
//   defm MIND
//   defm MINUD
//   defm MAXD
//   defm MAXUD
//   defm ANDD
//   defm NANDD
//   defm ORD
//   defm NORD
//   defm XORD
//   defm NXORD
//   defm ANDND
//   defm ORND
multiclass MC_11<string OpcStr> {
  let isAsCheapAsAMove = 1 in
  def rr : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_TINY>;
  let isAsCheapAsAMove = 1 in
  def ri10 : REGISTERW_REGISTERZ_SIGNED10_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed10:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_TINY>;
  def ri37 : REGISTERW_REGISTERZ_UPPER27_LOWER10_DOUBLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed37:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_TINY_X>;
  def ri64 : REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Wrapped64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_TINY_Y>;
}

// multiclass MC_12 is used by:
//   defm ABDD
//   defm SBMM8
//   defm SBMMT8
//   defm ADDSD
//   defm SBFSD
multiclass MC_12<string OpcStr> {
  def rr : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_LITE>;
  def ri10 : REGISTERW_REGISTERZ_SIGNED10_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed10:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_LITE>;
  def ri37 : REGISTERW_REGISTERZ_UPPER27_LOWER10_DOUBLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed37:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_LITE_X>;
  def ri64 : REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Wrapped64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_LITE_Y>;
}

// multiclass MC_13 is used by:
//   defm ADDWD
//   defm SBFWD
//   defm ADDUWD
//   defm SBFUWD
//   defm LANDD
//   defm LNANDD
//   defm LORD
//   defm LNORD
//   defm ADDSW
//   defm SBFSW
//   defm ADDX2W
//   defm ADDX4W
//   defm ADDX8W
//   defm ADDX16W
//   defm ADDX32W
//   defm ADDX64W
//   defm SBFX2W
//   defm SBFX4W
//   defm SBFX8W
//   defm SBFX16W
//   defm SBFX32W
//   defm SBFX64W
//   defm AVGW
//   defm AVGUW
//   defm AVGRW
//   defm AVGRUW
//   defm LANDW
//   defm LNANDW
//   defm LORW
//   defm LNORW
//   defm ADDX2WD
//   defm ADDX4WD
//   defm ADDX8WD
//   defm ADDX16WD
//   defm ADDX32WD
//   defm ADDX64WD
//   defm SBFX2WD
//   defm SBFX4WD
//   defm SBFX8WD
//   defm SBFX16WD
//   defm SBFX32WD
//   defm SBFX64WD
//   defm ADDX2UWD
//   defm ADDX4UWD
//   defm ADDX8UWD
//   defm ADDX16UWD
//   defm ADDX32UWD
//   defm ADDX64UWD
//   defm SBFX2UWD
//   defm SBFX4UWD
//   defm SBFX8UWD
//   defm SBFX16UWD
//   defm SBFX32UWD
//   defm SBFX64UWD
multiclass MC_13<string OpcStr> {
  def rr : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_LITE>;
  def ri : REGISTERW_REGISTERZ_UPPER27_LOWER5_DOUBLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Wrapped32:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_LITE_X>;
}

// multiclass MC_14 is used by:
//   defm ADDW
//   defm SBFW
//   defm MINW
//   defm MINUW
//   defm MAXW
//   defm MAXUW
//   defm ANDW
//   defm NANDW
//   defm ORW
//   defm NORW
//   defm XORW
//   defm NXORW
//   defm ANDNW
//   defm ORNW
multiclass MC_14<string OpcStr> {
  let isAsCheapAsAMove = 1 in
  def ri10 : REGISTERW_REGISTERZ_SIGNED10_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed10W:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_TINY>;
  def ri37 : REGISTERW_REGISTERZ_UPPER27_LOWER10_DOUBLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed37W:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_TINY_X>;
  let isAsCheapAsAMove = 1 in
  def rr : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_TINY>;
}

// multiclass MC_15 is used by:
//   defm ABDW
multiclass MC_15<string OpcStr> {
  def ri10 : REGISTERW_REGISTERZ_SIGNED10_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed10W:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_LITE>;
  def ri37 : REGISTERW_REGISTERZ_UPPER27_LOWER10_DOUBLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed37W:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_LITE_X>;
  def rr : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_LITE>;
}

// multiclass MC_16 is used by:
//   defm ADDBO
//   defm ADDHQ
//   defm ADDWP
//   defm MAXBO
//   defm MAXHQ
//   defm MAXUBO
//   defm MAXUHQ
//   defm MAXUWP
//   defm MAXWP
//   defm MINBO
//   defm MINHQ
//   defm MINUBO
//   defm MINUHQ
//   defm MINUWP
//   defm MINWP
//   defm SBFBO
//   defm SBFHQ
//   defm SBFWP
multiclass MC_16<string OpcStr> {
  let isAsCheapAsAMove = 1 in
  def rr : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_TINY>;
  def ri : SPLAT32_REGISTERW_REGISTERZ_UPPER27_LOWER5_DOUBLE
    <(outs SingleReg:$a2), (ins SingleReg:$a3, Wrapped32:$a4, Splat32Mod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [/* no straightforward pattern */],
     ALU_TINY_X>;
}

// multiclass MC_17 is used by:
//   defm ADDUSD
//   defm ADDUSW
//   defm ADDUSWP
//   defm ABDWP
//   defm ADDCWC
//   defm SBFCWC
//   defm ADDSWP
//   defm SBFSWP
//   defm ADDX2D
//   defm ADDX2WP
//   defm ADDX4D
//   defm ADDX4WP
//   defm ADDX8D
//   defm ADDX8WP
//   defm ADDX16D
//   defm ADDX16WP
//   defm ADDX32D
//   defm ADDX64D
//   defm SBFSBO
//   defm SBFUSBO
//   defm SBFUSD
//   defm SBFUSHQ
//   defm SBFUSW
//   defm SBFUSWP
//   defm SBFX2D
//   defm SBFX2WP
//   defm SBFX4D
//   defm SBFX4WP
//   defm SBFX8D
//   defm SBFX8WP
//   defm SBFX16D
//   defm SBFX16WP
//   defm SBFX32D
//   defm SBFX64D
//   defm AVGWP
//   defm AVGUWP
//   defm AVGRWP
//   defm AVGRUWP
//   defm LANDWP
//   defm LNANDWP
//   defm LORWP
//   defm LNORWP
//   defm ABDBO
//   defm ABDHQ
//   defm ABDSBO
//   defm ABDSHQ
//   defm ABDSD
//   defm ABDSW
//   defm ABDSWP
//   defm ADDCHCP
//   defm SBFCHCP
//   defm ADDSBO
//   defm ADDUSBO
//   defm ADDUSHQ
//   defm ADDSHQ
//   defm SBFSHQ
//   defm ADDX2BO
//   defm ADDX2HQ
//   defm ADDX4BO
//   defm ADDX4HQ
//   defm ADDX8BO
//   defm ADDX8HQ
//   defm ADDX16BO
//   defm ADDX16HQ
//   defm SBFX2BO
//   defm SBFX2HQ
//   defm SBFX4BO
//   defm SBFX4HQ
//   defm SBFX8BO
//   defm SBFX8HQ
//   defm SBFX16BO
//   defm SBFX16HQ
//   defm AVGBO
//   defm AVGHQ
//   defm AVGRBO
//   defm AVGUHQ
//   defm AVGRBO
//   defm AVGRHQ
//   defm AVGRUBO
//   defm AVGRUHQ
//   defm LANDHQ
//   defm LNANDHQ
//   defm LORHQ
//   defm LNORHQ
multiclass MC_17<string OpcStr> {
  def rr : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_LITE>;
  def ri : SPLAT32_REGISTERW_REGISTERZ_UPPER27_LOWER5_DOUBLE
    <(outs SingleReg:$a2), (ins SingleReg:$a3, Wrapped32:$a4, Splat32Mod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [/* no straightforward pattern */],
     ALU_LITE_X>;
}

// multiclass MC_18 is used by:
//   defm SATD
//   defm SRSD
//   defm SLSD
//   defm SRSW
//   defm SLSW
//   defm ROLW
//   defm RORW
//   defm SRSWPS
//   defm SLLWPS
//   defm SRAWPS
//   defm SRLWPS
//   defm SLSWPS
//   defm ROLWPS
//   defm RORWPS
//   defm SRSHQS
//   defm SLLBOS
//   defm SLLHQS
//   defm SRABOS
//   defm SRAHQS
//   defm SRBOQS
//   defm SRLHQS
//   defm SLSHQS
//   defm SLSBOS
//   defm SLUSBOS
//   defm SLUSD
//   defm SLUSW
//   defm SLUSWPS
//   defm SLUSHQS
//   defm SRSBOS
multiclass MC_18<string OpcStr> {
  def rr : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_LITE>;
  def ri : REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Unsigned6:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_LITE>;
}

// multiclass MC_19 is used by:
//   defm SLLD
//   defm SRAD
//   defm SRLD
//   defm SLLW
//   defm SRAW
//   defm SRLW
let isAsCheapAsAMove = 1 in
multiclass MC_19<string OpcStr> {
  def ri : REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Unsigned6:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_TINY>;
  def rr : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_TINY>;
}

// multiclass MC_1A is used by:
//   defm COMPD
multiclass MC_1A<string OpcStr> {
  def ri10 : COMPARISON_REGISTERW_REGISTERZ_SIGNED10_SIMPLE
    <(outs SingleReg:$a2), (ins SingleReg:$a3, Signed10:$a4, ComparisonMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [/* no straightforward pattern */]>;
  def ri37 : COMPARISON_REGISTERW_REGISTERZ_UPPER27_LOWER10_DOUBLE
    <(outs SingleReg:$a2), (ins SingleReg:$a3, Signed37:$a4, ComparisonMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [/* no straightforward pattern */]>;
  def ri64 : COMPARISON_REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
    <(outs SingleReg:$a2), (ins SingleReg:$a3, Wrapped64:$a4, ComparisonMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [/* no straightforward pattern */]>;
  def rr : COMPARISON_REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, ComparisonMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [/* no straightforward pattern */],
     ALU_TINY>;
}

// multiclass MC_1B is used by:
//   defm COMPND
//   defm COMPNW
//   defm COMPW
multiclass MC_1B<string OpcStr> {
  def rr : COMPARISON_REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, ComparisonMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [/* no straightforward pattern */],
     ALU_TINY>;
  def ri : COMPARISON_REGISTERW_REGISTERZ_UPPER27_LOWER5_DOUBLE
    <(outs SingleReg:$a2), (ins SingleReg:$a3, Wrapped32:$a4, ComparisonMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [/* no straightforward pattern */]>;
}

// multiclass MC_1C is used by:
//   defm CMOVED
let isAsCheapAsAMove = 1 in
multiclass MC_1C<string OpcStr> {
  let Constraints = "$a3 = $a3o", isMoveImm = 1, isReMaterializable = 1 in {
  def ri10 : SCALARCOND_REGISTERZ_REGISTERW_SIGNED10_SIMPLE
    <(outs SingleReg:$a3o), (ins SingleReg:$a2, SingleReg:$a3, Signed10:$a4, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 ? $a3 = $a4"),
     [/* no straightforward pattern */]>;
  def ri37 : SCALARCOND_REGISTERZ_REGISTERW_UPPER27_LOWER10_DOUBLE
    <(outs SingleReg:$a3o), (ins SingleReg:$a2, SingleReg:$a3, Signed37:$a4, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 ? $a3 = $a4"),
     [/* no straightforward pattern */]>;
  def ri64 : SCALARCOND_REGISTERZ_REGISTERW_EXTEND27_UPPER27_LOWER10_TRIPLE
    <(outs SingleReg:$a3o), (ins SingleReg:$a2, SingleReg:$a3, Wrapped64:$a4, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 ? $a3 = $a4"),
     [/* no straightforward pattern */]>;
  }
  let Constraints = "$a3 = $a3o", isMoveReg = 1 in
  def rr : SCALARCOND_REGISTERZ_REGISTERW_REGISTERY_SIMPLE
    <(outs SingleReg:$a3o), (ins SingleReg:$a2, SingleReg:$a3, SingleReg:$a4, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 ? $a3 = $a4"),
     [/* no straightforward pattern */]>;
}

// multiclass MC_1D is used by:
//   defm MAKE
multiclass MC_1D<string OpcStr> {
  def i16 : REGISTERW_SIGNED16_SIMPLE
    <(outs SingleReg:$a1), (ins Signed16:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */],
     ALU_TINY>;
  def i43 : REGISTERW_EXTEND6_UPPER27_LOWER10_DOUBLE
    <(outs SingleReg:$a1), (ins Signed43:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */],
     ALU_TINY_X>;
  def i64 : REGISTERW_EXTEND27_UPPER27_LOWER10_TRIPLE
    <(outs SingleReg:$a1), (ins Wrapped64:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */],
     ALU_TINY_Y>;
}

// multiclass MC_1E is used by:
//   defm PCREL
multiclass MC_1E<string OpcStr> {
  def i16 : REGISTERW_SIGNED16_SIMPLE
    <(outs SingleReg:$a1), (ins Signed16:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */],
     ALU_FULL>;
  def i43 : REGISTERW_EXTEND6_UPPER27_LOWER10_DOUBLE
    <(outs SingleReg:$a1), (ins Signed43:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */],
     ALU_FULL_X>;
  def i64 : REGISTERW_EXTEND27_UPPER27_LOWER10_TRIPLE
    <(outs SingleReg:$a1), (ins Wrapped64:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */],
     ALU_FULL_Y>;
}

// multiclass MC_1F is used by:
//   defm FCOMPW
//   defm FCOMPNW
multiclass MC_1F<string OpcStr> {
  def rr : FLOATCOMP_REGISTERW_REGISTERZ_REGISTERY_SIMPLE_BINARY32
    <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, FloatcompMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [/* no straightforward pattern */]>;
  def ri : FLOATCOMP_REGISTERW_REGISTERZ_UPPER27_LOWER5_DOUBLE_BINARY32
    <(outs SingleReg:$a2), (ins SingleReg:$a3, Binary32:$a4, FloatcompMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [/* no straightforward pattern */]>;
}

// multiclass MC_20 is used by:
//   defm MADDD
//   defm MADDWP
//   defm MADDHQ
multiclass MC_20<string OpcStr> {
  let Constraints = "$a1 = $a1o" in
  def ri10 : REGISTERW_REGISTERZ_SIGNED10_SIMPLE
    <(outs SingleReg:$a1o), (ins SingleReg:$a1, SingleReg:$a2, Signed10:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR>;
  let Constraints = "$a1 = $a1o" in
  def ri37 : REGISTERW_REGISTERZ_UPPER27_LOWER10_DOUBLE
    <(outs SingleReg:$a1o), (ins SingleReg:$a1, SingleReg:$a2, Signed37:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR_X>;
  let Constraints = "$a1 = $a1o" in
  def ri64 : REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
    <(outs SingleReg:$a1o), (ins SingleReg:$a1, SingleReg:$a2, Wrapped64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR_Y>;
  let Constraints = "$a1 = $a1o" in
  def rr : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a1o), (ins SingleReg:$a1, SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR>;
}

// multiclass MC_21 is used by:
//   defm MADDDT
//   defm MADDUDT
//   defm MADDSUDT
//   defm MADDUZDT
multiclass MC_21<string OpcStr> {
  let Constraints = "$a1 = $a1o" in
  def ri10 : REGISTERM_REGISTERZ_SIGNED10_SIMPLE
    <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, Signed10:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR>;
  let Constraints = "$a1 = $a1o" in
  def ri37 : REGISTERM_REGISTERZ_UPPER27_LOWER10_DOUBLE
    <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, Signed37:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR_X>;
  let Constraints = "$a1 = $a1o" in
  def ri64 : REGISTERM_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
    <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, Wrapped64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR_Y>;
  let Constraints = "$a1 = $a1o" in
  def rr : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
    <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR>;
}

// multiclass MC_22 is used by:
//   defm MULD
//   defm DOT2WD
//   defm DOT2UWD
//   defm DOT2SUWD
//   defm DOT2W
//   defm MULWP
//   defm MULHQ
//   defm MULWC
multiclass MC_22<string OpcStr> {
  def ri10 : REGISTERW_REGISTERZ_SIGNED10_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed10:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU>;
  def ri37 : REGISTERW_REGISTERZ_UPPER27_LOWER10_DOUBLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed37:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_X>;
  def ri64 : REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Wrapped64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_Y>;
  def rr : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU>;
}

// multiclass MC_23 is used by:
//   defm MULDT
//   defm MULUDT
//   defm MULSUDT
//   defm CMULDT
multiclass MC_23<string OpcStr> {
  def ri10 : REGISTERM_REGISTERZ_SIGNED10_SIMPLE
    <(outs PairedReg:$a1), (ins SingleReg:$a2, Signed10:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU>;
  def ri37 : REGISTERM_REGISTERZ_UPPER27_LOWER10_DOUBLE
    <(outs PairedReg:$a1), (ins SingleReg:$a2, Signed37:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_X>;
  def ri64 : REGISTERM_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
    <(outs PairedReg:$a1), (ins SingleReg:$a2, Wrapped64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_Y>;
  def rr : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
    <(outs PairedReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU>;
}

// multiclass MC_24 is used by:
//   defm CRCBELMW
//   defm CRCBELLW
//   defm CRCLELMW
//   defm CRCLELLW
//   defm MADDWD
//   defm MADDUWD
//   defm MADDSUWD
//   defm MADDW
//   defm MSBFWD
//   defm MSBFUWD
//   defm MSBFSUWD
//   defm MSBFW
multiclass MC_24<string OpcStr> {
  let Constraints = "$a1 = $a1o" in
  def rr : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a1o), (ins SingleReg:$a1, SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR>;
  let Constraints = "$a1 = $a1o" in
  def ri : REGISTERW_REGISTERZ_UPPER27_LOWER5_DOUBLE
    <(outs SingleReg:$a1o), (ins SingleReg:$a1, SingleReg:$a2, Wrapped32:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR_X>;
}

// multiclass MC_25 is used by:
//   defm MULWD
//   defm MULUWD
//   defm MULSUWD
//   defm MULW
multiclass MC_25<string OpcStr> {
  def rr : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU>;
  def ri : REGISTERW_REGISTERZ_UPPER27_LOWER5_DOUBLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Wrapped32:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_X>;
}

// multiclass MC_26 is used by:
//   defm FFMAD
//   defm FFMSD
//   defm FFMAWD
//   defm FFMSWD
multiclass MC_26<string OpcStr> {
  let Constraints = "$a1 = $a1o" in
  def ri : REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE_BINARY64
    <(outs SingleReg:$a1o), (ins SingleReg:$a1, SingleReg:$a2, Binary64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR_Y_FP>;
  let Constraints = "$a3 = $a3o" in
  def rr : ROUNDING_SILENT_REGISTERW_REGISTERZ_REGISTERY_SIMPLE_BINARY64
    <(outs SingleReg:$a3o), (ins SingleReg:$a3, SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4, $a5"),
     [/* no straightforward pattern */],
     MAU_AUXR_FP>;
}

// multiclass MC_27 is used by:
//   defm FFMAWP
//   defm FFMSWP
multiclass MC_27<string OpcStr> {
  let Constraints = "$a1 = $a1o" in
  def ri : REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE_BINARY32X2
    <(outs SingleReg:$a1o), (ins SingleReg:$a1, SingleReg:$a2, Binary32x2:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR_Y_FP>;
  let Constraints = "$a3 = $a3o" in
  def rr : ROUNDING_SILENT_REGISTERW_REGISTERZ_REGISTERY_SIMPLE_BINARY32X2
    <(outs SingleReg:$a3o), (ins SingleReg:$a3, SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4, $a5"),
     [/* no straightforward pattern */],
     MAU_AUXR_FP>;
}

// multiclass MC_28 is used by:
//   defm FFMAHQ
//   defm FFMSHQ
multiclass MC_28<string OpcStr> {
  let Constraints = "$a1 = $a1o" in
  def ri : REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE_BINARY16X4
    <(outs SingleReg:$a1o), (ins SingleReg:$a1, SingleReg:$a2, Binary16x4:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR_Y_FP>;
  let Constraints = "$a3 = $a3o" in
  def rr : ROUNDING_SILENT_REGISTERW_REGISTERZ_REGISTERY_SIMPLE_BINARY16X4
    <(outs SingleReg:$a3o), (ins SingleReg:$a3, SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4, $a5"),
     [/* no straightforward pattern */],
     MAU_AUXR_FP>;
}

// multiclass MC_29 is used by:
//   defm FMULD
//   defm FADDD
//   defm FSBFD
//   defm FMULWD
//   defm FDOT2WD
multiclass MC_29<string OpcStr> {
  def ri : REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE_BINARY64
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Binary64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_Y_FP>;
  def rr : ROUNDING_SILENT_REGISTERW_REGISTERZ_REGISTERY_SIMPLE_BINARY64
    <(outs SingleReg:$a3), (ins SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4, $a5"),
     [/* no straightforward pattern */],
     MAU_FP>;
}

// multiclass MC_2A is used by:
//   defm FDOT2W
//   defm FMULWP
multiclass MC_2A<string OpcStr> {
  def ri : REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE_BINARY32X2
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Binary32x2:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_Y_FP>;
  def rr : ROUNDING_SILENT_REGISTERW_REGISTERZ_REGISTERY_SIMPLE_BINARY32X2
    <(outs SingleReg:$a3), (ins SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4, $a5"),
     [/* no straightforward pattern */],
     MAU_FP>;
}

// FIXME: For coolidge, this class should hold ri10,ri37,ri64 variants.
// multiclass MC_2A is used by:
//   defm FADDWP
//   defm FMULWC
//   defm FSBFWP
multiclass MC_2AM<string OpcStr> {
  def ri : REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE_BINARY32X2
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Binary32x2:$a3, ConjugateMod:$a4),
     !strconcat (OpcStr, "$a4 $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_Y_FP>, Requires<[IsV1]>;

  def rr : ROUNDING_SILENT_REGISTERW_REGISTERZ_REGISTERY_SIMPLE_BINARY32X2
    <(outs SingleReg:$a3), (ins SingleReg:$a4, SingleReg:$a5, ConjugateMod:$a6, RoundingMod:$a1, SilentMod:$a2),
     !strconcat (OpcStr, "$a6$a1$a2 $a3 = $a4, $a5"),
     [/* no straightforward pattern */],
     MAU_FP>;
}

// multiclass MC_2B is used by:
//   defm FMULHQ
//   defm FADDHQ
//   defm FSBFHQ
multiclass MC_2B<string OpcStr> {
  def ri : REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE_BINARY16X4
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Binary16x4:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_Y_FP>;
  def rr : ROUNDING_SILENT_REGISTERW_REGISTERZ_REGISTERY_SIMPLE_BINARY16X4
    <(outs SingleReg:$a3), (ins SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4, $a5"),
     [/* no straightforward pattern */],
     MAU_FP>;
}

// multiclass MC_2C is used by:
//   defm FMULWDP
//   defm FMULWDC
//   defm FMULCWDC
multiclass MC_2C<string OpcStr> {
  def ri : REGISTERM_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE_BINARY32X2
    <(outs PairedReg:$a1), (ins SingleReg:$a2, Binary32x2:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_Y_FP>;
  def rr : ROUNDING_SILENT_REGISTERM_REGISTERZ_REGISTERY_SIMPLE_BINARY32X2
    <(outs PairedReg:$a3), (ins SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4, $a5"),
     [/* no straightforward pattern */],
     MAU_FP>;
}

// multiclass MC_2D is used by:
//   defm FMULHWQ
multiclass MC_2D<string OpcStr> {
  def ri : REGISTERM_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE_BINARY16X4
    <(outs PairedReg:$a1), (ins SingleReg:$a2, Binary16x4:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_Y_FP>;
  def rr : ROUNDING_SILENT_REGISTERM_REGISTERZ_REGISTERY_SIMPLE_BINARY16X4
    <(outs PairedReg:$a3), (ins SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4, $a5"),
     [/* no straightforward pattern */],
     MAU_FP>;
}

// multiclass MC_2E is used by:
//   defm FFMAW
//   defm FFMSW
multiclass MC_2E<string OpcStr> {
  let Constraints = "$a1 = $a1o" in
  def ri : REGISTERW_REGISTERZ_UPPER27_LOWER10_DOUBLE_BINARY32
    <(outs SingleReg:$a1o), (ins SingleReg:$a1, SingleReg:$a2, Binary32:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR_X_FP>;
  let Constraints = "$a3 = $a3o" in
  def rr : ROUNDING_SILENT_REGISTERW_REGISTERZ_REGISTERY_SIMPLE_BINARY32
    <(outs SingleReg:$a3o), (ins SingleReg:$a3, SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4, $a5"),
     [/* no straightforward pattern */],
     MAU_AUXR_FP>;
}

// multiclass MC_2E_2 is used by:
//   defm FFMAHW
//   defm FFMSHW
multiclass MC_2E_2<string OpcStr> {
  let Constraints = "$a1 = $a1o" in
  def ri : REGISTERW_REGISTERZ_UPPER27_LOWER10_DOUBLE_BINARY32
    <(outs SingleReg:$a1o), (ins SingleReg:$a1, SingleReg:$a2, Binary32:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR_X_FP>;
  let Constraints = "$a3 = $a3o" in
  def rr : ROUNDING_SILENT_REGISTERW_REGISTERZ_REGISTERY_SIMPLE_BINARY32
    <(outs SingleReg:$a3o), (ins SingleReg:$a3, SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4, $a5"),
     [/* no straightforward pattern */],
     MAU_AUXR_FP>;
}

// multiclass MC_2F is used by:
//   defm FFMAWDP
//   defm FFMSWDP
multiclass MC_2F<string OpcStr> {
  let Constraints = "$a1 = $a1o" in
  def ri : REGISTERM_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE_BINARY32X2
    <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, Binary32x2:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR_Y_FP>;
  let Constraints = "$a3 = $a3o" in
  def rr : ROUNDING_SILENT_REGISTERM_REGISTERZ_REGISTERY_SIMPLE_BINARY32X2
    <(outs PairedReg:$a3o), (ins PairedReg:$a3, SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4, $a5"),
     [/* no straightforward pattern */],
     MAU_AUXR_FP>;
}

// multiclass MC_30 is used by:
//   defm FFMAHWQ
//   defm FFMSHWQ
multiclass MC_30<string OpcStr> {
  let Constraints = "$a1 = $a1o" in
  def ri : REGISTERM_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE_BINARY16X4
    <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, Binary16x4:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR_Y_FP>;
  let Constraints = "$a3 = $a3o" in
  def rr : ROUNDING_SILENT_REGISTERM_REGISTERZ_REGISTERY_SIMPLE_BINARY16X4
    <(outs PairedReg:$a3o), (ins PairedReg:$a3, SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4, $a5"),
     [/* no straightforward pattern */],
     MAU_AUXR_FP>;
}

// multiclass MC_31 is used by:
//   defm FADDW
//   defm FSBFW
//   defm FMULW
multiclass MC_31<string OpcStr> {
  def ri : REGISTERW_REGISTERZ_UPPER27_LOWER10_DOUBLE_BINARY32
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Binary32:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_X_FP>;
  def rr : ROUNDING_SILENT_REGISTERW_REGISTERZ_REGISTERY_SIMPLE_BINARY32
    <(outs SingleReg:$a3), (ins SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4, $a5"),
     [/* no straightforward pattern */],
     MAU_FP>;
}

// multiclass MC_31_2 is used by:
//   defm FMULHW
multiclass MC_31_2<string OpcStr> {
  def ri : REGISTERW_REGISTERZ_UPPER27_LOWER10_DOUBLE_BINARY32
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Binary32:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_X_FP>;
  def rr : ROUNDING_SILENT_REGISTERW_REGISTERZ_REGISTERY_SIMPLE_BINARY32
    <(outs SingleReg:$a3), (ins SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4, $a5"),
     [/* no straightforward pattern */],
     MAU_FP>;
}

// multiclass MC_32 is used by:
//   defm MOVETQ
multiclass MC_32<string OpcStr> {
  def rrbe : REGISTERAL_REGISTERZ_REGISTERY_SIMPLE
    <(outs BlockRegE:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */]>;
  def rrbo : REGISTERAH_REGISTERZ_REGISTERY_SIMPLE
    <(outs BlockRegO:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */]>;
}

// multiclass MC_33 is used by:
//   defm ALIGNO
multiclass MC_33<string OpcStr> {
  def reroi : REGISTERN_REGISTERBE_REGISTERCO_BYTESHIFT_SIMPLE
    <(outs QuadReg:$a1), (ins VectorRegE:$a2, VectorRegO:$a3, Unsigned6:$a4),
     !strconcat (OpcStr, " $a1 = $a2, $a3, $a4"),
     [/* no straightforward pattern */]>;
  def rorei : REGISTERN_REGISTERBO_REGISTERCE_BYTESHIFT_SIMPLE
    <(outs QuadReg:$a1), (ins VectorRegO:$a2, VectorRegE:$a3, Unsigned6:$a4),
     !strconcat (OpcStr, " $a1 = $a2, $a3, $a4"),
     [/* no straightforward pattern */]>;
  def reror : REGISTERN_REGISTERBE_REGISTERCO_REGISTERZ_SIMPLE
    <(outs QuadReg:$a1), (ins VectorRegE:$a2, VectorRegO:$a3, SingleReg:$a4),
     !strconcat (OpcStr, " $a1 = $a2, $a3, $a4"),
     [/* no straightforward pattern */]>;
  def rorer : REGISTERN_REGISTERBO_REGISTERCE_REGISTERZ_SIMPLE
    <(outs QuadReg:$a1), (ins VectorRegO:$a2, VectorRegE:$a3, SingleReg:$a4),
     !strconcat (OpcStr, " $a1 = $a2, $a3, $a4"),
     [/* no straightforward pattern */]>;
}

// multiclass MC_34 is used by:
//   defm ALIGNV
multiclass MC_34<string OpcStr> {
  def reroi : REGISTERA_REGISTERBE_REGISTERCO_BYTESHIFT_SIMPLE
    <(outs VectorReg:$a1), (ins VectorRegE:$a2, VectorRegO:$a3, Unsigned6:$a4),
     !strconcat (OpcStr, " $a1 = $a2, $a3, $a4"),
     [/* no straightforward pattern */]>;
  def rorei : REGISTERA_REGISTERBO_REGISTERCE_BYTESHIFT_SIMPLE
    <(outs VectorReg:$a1), (ins VectorRegO:$a2, VectorRegE:$a3, Unsigned6:$a4),
     !strconcat (OpcStr, " $a1 = $a2, $a3, $a4"),
     [/* no straightforward pattern */]>;
  def reror : REGISTERA_REGISTERBE_REGISTERCO_REGISTERZ_SIMPLE
    <(outs VectorReg:$a1), (ins VectorRegE:$a2, VectorRegO:$a3, SingleReg:$a4),
     !strconcat (OpcStr, " $a1 = $a2, $a3, $a4"),
     [/* no straightforward pattern */]>;
  def rorer : REGISTERA_REGISTERBO_REGISTERCE_REGISTERZ_SIMPLE
    <(outs VectorReg:$a1), (ins VectorRegO:$a2, VectorRegE:$a3, SingleReg:$a4),
     !strconcat (OpcStr, " $a1 = $a2, $a3, $a4"),
     [/* no straightforward pattern */]>;
}

// multiclass MC_35 is used by:
//   defm COPYV
let isMoveReg = 1 in
multiclass MC_35<string OpcStr> {
  def re : REGISTERA_REGISTERBE_SIMPLE
    <(outs VectorReg:$a1), (ins VectorRegE:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */]>;
  def ro : REGISTERA_REGISTERBO_SIMPLE
    <(outs VectorReg:$a1), (ins VectorRegO:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */]>;
}

// multiclass MC_36 is used by:
//   defm MOVEFO
multiclass MC_36<string OpcStr> {
  def re : REGISTERN_REGISTERBE_SIMPLE
    <(outs QuadReg:$a1), (ins VectorRegE:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */]>;
  def ro : REGISTERN_REGISTERBO_SIMPLE
    <(outs QuadReg:$a1), (ins VectorRegO:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */]>;
}

// def FMM222W
class FP_PairedReg_PairedReg_PairedReg_Transp_Round_Silent <string OpcStr, InstrItinClass It>
: ROUNDING_SILENT_TRANSPOSE_REGISTERM_REGISTERO_REGISTERP
    <(outs PairedReg:$M), (ins PairedReg:$O, PairedReg:$P, TransposeMod:$t, RoundingMod:$r, SilentMod:$s),
     !strconcat (OpcStr, "$t$r$s $M = $O, $P"), It>
{}

// def FMMA222W
// def FMMS222W
class FP_PairedReg_PairedReg_PairedReg_Transp_Round_Silent_Accumulate <string OpcStr, InstrItinClass It>
: ROUNDING_SILENT_TRANSPOSE_REGISTERM_REGISTERO_REGISTERP
    <(outs PairedReg:$M_Out), (ins PairedReg:$O, PairedReg:$P, PairedReg:$M_In, TransposeMod:$t, RoundingMod:$r, SilentMod:$s),
     !strconcat (OpcStr, "$t$r$s $M_Out = $O, $P"), It>
{
  let Constraints = "$M_Out = $M_In";
}


def AWAIT : SIMPLE
  <(outs), (ins),
   "await",
   [/* no straightforward pattern */],
   ALL>;

def SLEEP : SIMPLE
  <(outs), (ins),
   "sleep",
   [/* no straightforward pattern */],
   ALL>;

def STOP : SIMPLE
  <(outs), (ins),
   "stop",
   [/* no straightforward pattern */],
   ALL>;

def BARRIER : SIMPLE
  <(outs), (ins),
   "barrier",
   [/* no straightforward pattern */],
   ALL>;

def TLBREAD : SIMPLE
  <(outs), (ins),
   "tlbread",
   [/* no straightforward pattern */],
   ALL>;

def TLBPROBE : SIMPLE
  <(outs), (ins),
   "tlbprobe",
   [/* no straightforward pattern */],
   ALL>;

def TLBWRITE : SIMPLE
  <(outs), (ins),
   "tlbwrite",
   [/* no straightforward pattern */],
   ALL>;

def TLBDINVAL : SIMPLE
  <(outs), (ins),
   "tlbdinval",
   [/* no straightforward pattern */],
   ALL>;

def TLBIINVAL : SIMPLE
  <(outs), (ins),
   "tlbiinval",
   [/* no straightforward pattern */],
   ALL>;

def ERROP : SIMPLE
  <(outs), (ins),
   "errop",
   [/* no straightforward pattern */],
   ALL>;

let Uses = [RA], isBarrier = 1, isReturn = 1, isTerminator = 1 in
def RET : SIMPLE
  <(outs), (ins),
   "ret",
   [/* no straightforward pattern */],
   BCU>;

def RFE : SIMPLE
  <(outs), (ins),
   "rfe",
   [/* no straightforward pattern */],
   ALL>;

let isBarrier = 1, isBranch = 1, isIndirectBranch = 1, isTerminator = 1 in
def IGOTO : REGISTERZ_SIMPLE
  <(outs), (ins SingleReg:$a1),
   "igoto $a1",
   [(brind i64:$a1)],
   BCU>;

let Defs = [RA], isCall = 1, isIndirectBranch = 1 in
def ICALL : REGISTERZ_SIMPLE
  <(outs), (ins SingleReg:$a1),
   "icall $a1",
   [/* no straightforward pattern */],
   BCU>;

defm SCALL : MC_00<"scall">;

let isTerminator=1, hasSideEffects=1, isNotDuplicable=1, Defs = [LC,LE,LS] in
def LOOPDO : REGISTERZ_PCREL17_SIMPLE
  <(outs), (ins SingleReg:$a1, Pcrel17:$a2),
   "loopdo $a1, $a2",
   [/* no straightforward pattern */]>;

defm WFXL : MC_01<"wfxl">;

defm WFXM : MC_01<"wfxm">;

defm GET : MC_02<"get">;

let Constraints = "$a1 = $a1o" in
def IGET : REGISTERZ_SIMPLE
  <(outs SingleReg:$a1o), (ins SingleReg:$a1),
   "iget $a1",
   [/* no straightforward pattern */],
   BCU_TINY_TINY_MAU_XNOP>;

defm SET : MC_03<"set">;

defm RSWAP : MC_04<"rswap">;

let Constraints = "$a1 = $a1o" in
def WAITIT : REGISTERZ_SIMPLE
  <(outs SingleReg:$a1o), (ins SingleReg:$a1),
   "waitit $a1",
   [/* no straightforward pattern */],
   BCU_TINY_TINY_MAU_XNOP>;

def SYNCGROUP : REGISTERZ_SIMPLE
  <(outs), (ins SingleReg:$a1),
   "syncgroup $a1",
   [/* no straightforward pattern */],
   BCU>;

let isBarrier = 1, isBranch = 1, isTerminator = 1 in
def GOTO : PCREL27_SIMPLE
  <(outs), (ins Pcrel27:$a1),
   "goto $a1",
   [(br bb:$a1)]>;

let Defs = [RA], isCall = 1 in
def CALL : PCREL27_SIMPLE
  <(outs), (ins Pcrel27:$a1),
   "call $a1",
   [/* no straightforward pattern */]>;

let isBranch = 1, isTerminator = 1 in
def CB : BRANCHCOND_REGISTERZ_PCREL17_SIMPLE
  <(outs), (ins SingleReg:$a2, Pcrel17:$a3, ScalarcondMod:$a1),
   "cb$a1 $a2 ? $a3",
   [/* no straightforward pattern */]>;

defm LBZ : MC_05<"lbz">;

defm LBS : MC_05<"lbs">;

defm LHZ : MC_05<"lhz">;

defm LHS : MC_05<"lhs">;

defm LWZ : MC_05<"lwz">;

defm LWS : MC_05<"lws">;

defm LD : MC_05<"ld">;

defm LQ : MC_06<"lq">;

defm LO : MC_07<"lo">;

defm LV : MC_08<"lv">;

defm SB : MC_09<"sb">;

defm SH : MC_09<"sh">;

defm SW : MC_09<"sw">;

defm SD : MC_09<"sd">;

defm SQ : MC_0A<"sq">;

defm SO : MC_0B<"so">;

defm SV : MC_0C<"sv">;

defm ACSWAPW : MC_0D<"acswapw">;

defm ACSWAPD : MC_0D<"acswapd">;

defm ALCLRW : MC_0E<"alclrw">;

defm ALCLRD : MC_0E<"alclrd">;

defm ALADDW : MC_0F<"aladdw">;

defm ALADDD : MC_0F<"aladdd">;

let mayLoad = 1 in
defm DTOUCHL : MC_10<"dtouchl">;

let hasSideEffects = 1 in
defm DINVALL : MC_10<"dinvall">;

let mayStore = 1 in
defm DZEROL : MC_10<"dzerol">;

let hasSideEffects = 1 in
defm IINVALS : MC_10<"iinvals">;

let hasSideEffects = 1 in
def DINVAL : SIMPLE
  <(outs), (ins),
   "dinval",
   [/* no straightforward pattern */],
   LSU_LOAD>;

def IINVAL : SIMPLE
  <(outs), (ins),
   "iinval",
   [/* no straightforward pattern */],
   LSU_LOAD>;

let hasSideEffects = 1 in
def FENCE : SIMPLE
  <(outs), (ins),
   "fence",
   [/* no straightforward pattern */],
   LSU_LOAD>;

def NOP : SIMPLE
  <(outs), (ins),
   "nop",
   [/* no straightforward pattern */],
   ALU_NOP>;

def STSUD : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "stsud $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   ALU_LITE>;

let isAdd = 1 in
defm ADDD : MC_11<"addd">;

defm SBFD : MC_11<"sbfd">;

defm ABDD : MC_12<"abdd">;

defm MIND : MC_11<"mind">;

defm MINUD : MC_11<"minud">;

defm MAXD : MC_11<"maxd">;

defm MAXUD : MC_11<"maxud">;

defm ANDD : MC_11<"andd">;

defm NANDD : MC_11<"nandd">;

defm ORD : MC_11<"ord">;

defm NORD : MC_11<"nord">;

defm XORD : MC_11<"xord">;

defm NXORD : MC_11<"nxord">;

defm ANDND : MC_11<"andnd">;

defm ORND : MC_11<"ornd">;

defm SBMM8 : MC_12<"sbmm8">;

defm SBMMT8 : MC_12<"sbmmt8">;

let isAdd = 1 in
defm ADDSD : MC_12<"addsd">;

let isAdd = 1 in {
defm ADDUSBO : MC_17<"addusbo">, Requires<[IsV2]>;
defm ADDUSD : MC_17<"addusd">, Requires<[IsV2]>;
defm ADDUSHQ : MC_17<"addushq">, Requires<[IsV2]>;
defm ADDUSW : MC_17<"addusw">, Requires<[IsV2]>;
defm ADDUSWP : MC_17<"adduswp">, Requires<[IsV2]>;
}

defm SBFSD : MC_12<"sbfsd">;
def SBFSDri : SPLAT32_REGISTERW_REGISTERZ_UPPER27_LOWER5_DOUBLE
    <(outs SingleReg:$out), (ins SingleReg:$rhs, Wrapped32:$lhs, Splat32Mod:$s),
    "sbfsd$s $out = $rhs, $lhs",
     [], ALU_LITE_X>, Requires<[IsV2]>;

defm ADDX2D : MC_17<"addx2d">;

defm ADDX4D : MC_17<"addx4d">;

defm ADDX8D : MC_17<"addx8d">;

defm ADDX16D : MC_17<"addx16d">;

defm ADDX32D : MC_17<"addx32d">, Requires<[IsV2]>;

defm ADDX64D : MC_17<"addx64d">, Requires<[IsV2]>;

defm SBFX2D : MC_17<"sbfx2d">;

defm SBFX4D : MC_17<"sbfx4d">;

defm SBFX8D : MC_17<"sbfx8d">;

defm SBFX16D : MC_17<"sbfx16d">;

defm SBFX32D : MC_17<"sbfx32d">, Requires<[IsV2]>;

defm SBFX64D : MC_17<"sbfx64d">, Requires<[IsV2]>;

let isAdd = 1 in
defm ADDWD : MC_13<"addwd">;

defm SBFWD : MC_13<"sbfwd">;

let isAdd = 1 in
defm ADDUWD : MC_13<"adduwd">;

defm SBFUWD : MC_13<"sbfuwd">;

defm LANDD : MC_13<"landd">;

defm LNANDD : MC_13<"lnandd">;

defm LORD : MC_13<"lord">;

defm LNORD : MC_13<"lnord">;

def STSUW : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "stsuw $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   ALU_LITE>;

let isAdd = 1 in
defm ADDW : MC_14<"addw">;

defm SBFW : MC_14<"sbfw">;

defm ABDW : MC_15<"abdw">;

defm MINW : MC_14<"minw">;

defm MINUW : MC_14<"minuw">;

defm MAXW : MC_14<"maxw">;

defm MAXUW : MC_14<"maxuw">;

defm ANDW : MC_14<"andw">;

defm NANDW : MC_14<"nandw">;

defm ORW : MC_14<"orw">;

defm NORW : MC_14<"norw">;

defm XORW : MC_14<"xorw">;

defm NXORW : MC_14<"nxorw">;

defm ANDNW : MC_14<"andnw">;

defm ORNW : MC_14<"ornw">;

let isAdd = 1 in
defm ADDSW : MC_13<"addsw">;

defm SBFSW : MC_13<"sbfsw">;

defm ADDX2W : MC_13<"addx2w">;

defm ADDX4W : MC_13<"addx4w">;

defm ADDX8W : MC_13<"addx8w">;

defm ADDX16W : MC_13<"addx16w">;

defm ADDX32W : MC_13<"addx32w">, Requires<[IsV2]>;

defm ADDX64W : MC_13<"addx64w">, Requires<[IsV2]>;

defm SBFX2W : MC_13<"sbfx2w">;

defm SBFX4W : MC_13<"sbfx4w">;

defm SBFX8W : MC_13<"sbfx8w">;

defm SBFX16W : MC_13<"sbfx16w">;

defm SBFX32W : MC_13<"sbfx32w">, Requires<[IsV2]>;

defm SBFX64W : MC_13<"sbfx64w">, Requires<[IsV2]>;

defm AVGW : MC_13<"avgw">;

defm AVGUW : MC_13<"avguw">;

defm AVGRW : MC_13<"avgrw">;

defm AVGRUW : MC_13<"avgruw">;

defm LANDW : MC_13<"landw">;

defm LNANDW : MC_13<"lnandw">;

defm LORW : MC_13<"lorw">;

defm LNORW : MC_13<"lnorw">;

let isAdd = 1 in
defm ADDWP : MC_16<"addwp">;

defm SBFWP : MC_16<"sbfwp">;

defm ABDWP : MC_17<"abdwp">;

defm MINWP : MC_16<"minwp">;

defm MINUWP : MC_16<"minuwp">;

defm MAXWP : MC_16<"maxwp">;

defm MAXUWP : MC_16<"maxuwp">;

let isAdd = 1 in
defm ADDCWC : MC_17<"addcwc">;

defm SBFCWC : MC_17<"sbfcwc">;

let isAdd = 1 in
defm ADDSWP : MC_17<"addswp">;

defm SBFSWP : MC_17<"sbfswp">;

defm ADDX2WP : MC_17<"addx2wp">;

defm ADDX4WP : MC_17<"addx4wp">;

defm ADDX8WP : MC_17<"addx8wp">;

defm ADDX16WP : MC_17<"addx16wp">;

defm SBFX2WP : MC_17<"sbfx2wp">;

defm SBFX4WP : MC_17<"sbfx4wp">;

defm SBFX8WP : MC_17<"sbfx8wp">;

defm SBFX16WP : MC_17<"sbfx16wp">;

defm AVGWP : MC_17<"avgwp">;

defm AVGUWP : MC_17<"avguwp">;

defm AVGRWP : MC_17<"avgrwp">;

defm AVGRUWP : MC_17<"avgruwp">;

defm LANDWP : MC_17<"landwp">;

defm LNANDWP : MC_17<"lnandwp">;

defm LORWP : MC_17<"lorwp">;

defm LNORWP : MC_17<"lnorwp">;

let isAdd = 1 in
defm ADDHQ : MC_16<"addhq">;

let isAdd = 1 in
defm ADDBO : MC_16<"addbo">, Requires<[IsV2]>;

defm SBFBO : MC_16<"sbfbo">, Requires<[IsV2]>;

defm SBFHQ : MC_16<"sbfhq">;

defm ABDBO : MC_17<"abdbo">, Requires<[IsV2]>;

defm ABDHQ : MC_17<"abdhq">;

defm MINBO : MC_16<"minbo">, Requires<[IsV2]>;

defm MINHQ : MC_16<"minhq">;

defm MINUBO : MC_16<"minubo">, Requires<[IsV2]>;

defm MINUHQ : MC_16<"minuhq">;

defm MAXBO : MC_16<"maxbo">, Requires<[IsV2]>;

defm MAXHQ : MC_16<"maxhq">;

defm MAXUBO : MC_16<"maxubo">, Requires<[IsV2]>;

defm MAXUHQ : MC_16<"maxuhq">;

let isAdd = 1 in
defm ADDCHCP : MC_17<"addchcp">;

defm SBFCHCP : MC_17<"sbfchcp">;

let isAdd = 1 in {
defm ADDSHQ : MC_17<"addshq">;
defm ADDSBO : MC_17<"addsbo">, Requires<[IsV2]>;
}

defm SBFSBO : MC_17<"sbfsbo">;

defm SBFSHQ : MC_17<"sbfshq">;

defm ADDX2BO : MC_17<"addx2bo">, Requires<[IsV2]>;

defm ADDX2HQ : MC_17<"addx2hq">;

defm ADDX4BO : MC_17<"addx4bo">, Requires<[IsV2]>;

defm ADDX4HQ : MC_17<"addx4hq">;

defm ADDX8BO : MC_17<"addx8bo">, Requires<[IsV2]>;

defm ADDX8HQ : MC_17<"addx8hq">;

defm ADDX16BO : MC_17<"addx16bo">, Requires<[IsV2]>;

defm ADDX16HQ : MC_17<"addx16hq">;

defm SBFX2BO : MC_17<"sbfx2bo">, Requires<[IsV2]>;

defm SBFX2HQ : MC_17<"sbfx2hq">;

defm SBFX4BO : MC_17<"sbfx4bo">, Requires<[IsV2]>;

defm SBFX4HQ : MC_17<"sbfx4hq">;

defm SBFX8BO : MC_17<"sbfx8bo">, Requires<[IsV2]>;

defm SBFX8HQ : MC_17<"sbfx8hq">;

defm SBFX16BO : MC_17<"sbfx16bo">, Requires<[IsV2]>;

defm SBFX16HQ : MC_17<"sbfx16hq">;

defm AVGBO : MC_17<"avgbo">, Requires<[IsV2]>;

defm AVGHQ : MC_17<"avghq">;

defm AVGUBO : MC_17<"avgubo">, Requires<[IsV2]>;

defm AVGUHQ : MC_17<"avguhq">;

defm AVGRBO : MC_17<"avgrbo">, Requires<[IsV2]>;

defm AVGRHQ : MC_17<"avgrhq">;

defm AVGRUBO : MC_17<"avgrubo">, Requires<[IsV2]>;

defm AVGRUHQ : MC_17<"avgruhq">;

defm LANDHQ : MC_17<"landhq">;

defm LNANDHQ : MC_17<"lnandhq">;

defm LORHQ : MC_17<"lorhq">;

defm LNORHQ : MC_17<"lnorhq">;

defm ADDX2WD : MC_13<"addx2wd">;

defm ADDX4WD : MC_13<"addx4wd">;

defm ADDX8WD : MC_13<"addx8wd">;

defm ADDX16WD : MC_13<"addx16wd">;

defm ADDX32WD : MC_13<"addx32wd">, Requires<[IsV2]>;

defm ADDX64WD : MC_13<"addx64wd">, Requires<[IsV2]>;

defm SBFX2WD : MC_13<"sbfx2wd">;

defm SBFX4WD : MC_13<"sbfx4wd">;

defm SBFX8WD : MC_13<"sbfx8wd">;

defm SBFX16WD : MC_13<"sbfx16wd">;

defm SBFX32WD : MC_13<"sbfx32wd">, Requires<[IsV2]>;

defm SBFX64WD : MC_13<"sbfx64wd">, Requires<[IsV2]>;

defm ADDX2UWD : MC_13<"addx2uwd">;

defm ADDX4UWD : MC_13<"addx4uwd">;

defm ADDX8UWD : MC_13<"addx8uwd">;

defm ADDX16UWD : MC_13<"addx16uwd">;

defm ADDX32UWD : MC_13<"addx32uwd">, Requires<[IsV2]>;

defm ADDX64UWD : MC_13<"addx64uwd">, Requires<[IsV2]>;

defm SBFX2UWD : MC_13<"sbfx2uwd">;

defm SBFX4UWD : MC_13<"sbfx4uwd">;

defm SBFX8UWD : MC_13<"sbfx8uwd">;

defm SBFX16UWD : MC_13<"sbfx16uwd">;

defm SBFX32UWD : MC_13<"sbfx32uwd">, Requires<[IsV2]>;

defm SBFX64UWD : MC_13<"sbfx64uwd">, Requires<[IsV2]>;

defm SBFUSBO : MC_17<"sbfusbo">, Requires<[IsV2]>;

defm SBFUSD : MC_17<"sbfusd">, Requires<[IsV2]>;

defm SBFUSHQ : MC_17<"sbfushq">, Requires<[IsV2]>;

defm SBFUSW : MC_17<"sbfusw">, Requires<[IsV2]>;

defm SBFUSWP : MC_17<"sbfuswp">, Requires<[IsV2]>;

let Defs = [CS], Uses = [CS] in
def ADDCD : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "addcd $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   ALU_FULL>;

let Defs = [CS] in
def SBFCD : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "sbfcd $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   ALU_FULL>;

let Defs = [CS], Uses = [CS] in
def ADDCDI : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "addcd.i $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   ALU_FULL>;

let Defs = [CS] in
def SBFCDI : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "sbfcd.i $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   ALU_FULL>;

def FNEGD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fnegd $a1 = $a2",
   [(set f64:$a1, (fneg f64:$a2))],
   ALU_LITE>;

def FABSD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fabsd $a1 = $a2",
   [(set f64:$a1, (fabs f64:$a2))],
   ALU_LITE>;

def FSRECD : SILENT2_REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SilentMod:$a1),
   "fsrecd$a1 $a2 = $a3",
   [/* no straightforward pattern */]>;

def FSRSRD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fsrsrd $a1 = $a2",
   [/* no straightforward pattern */],
   ALU_LITE>;

def FWIDENLWD : SILENT2_REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SilentMod:$a1),
   "fwidenlwd$a1 $a2 = $a3",
   [/* no straightforward pattern */]>;

def FWIDENMWD : SILENT2_REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SilentMod:$a1),
   "fwidenmwd$a1 $a2 = $a3",
   [/* no straightforward pattern */]>;

def FNARROWDW : ROUNDING2_SILENT2_REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a3), (ins SingleReg:$a4, RoundingMod:$a1, SilentMod:$a2),
   "fnarrowdw$a1$a2 $a3 = $a4",
   [/* no straightforward pattern */],
   ALU_FULL>;

def FNEGW : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fnegw $a1 = $a2",
   [(set f32:$a1, (fneg f32:$a2))],
   ALU_LITE>;

def FABSW : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fabsw $a1 = $a2",
   [(set f32:$a1, (fabs f32:$a2))],
   ALU_LITE>;

def FRECW : ROUNDING2_SILENT2_REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a3), (ins SingleReg:$a4, RoundingMod:$a1, SilentMod:$a2),
   "frecw$a1$a2 $a3 = $a4",
   [/* no straightforward pattern */],
   SFU>;

def FRSRW : ROUNDING2_SILENT2_REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a3), (ins SingleReg:$a4, RoundingMod:$a1, SilentMod:$a2),
   "frsrw$a1$a2 $a3 = $a4",
   [/* no straightforward pattern */],
   SFU>;

def FSRECW : SILENT2_REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SilentMod:$a1),
   "fsrecw$a1 $a2 = $a3",
   [/* no straightforward pattern */]>;

def FSRSRW : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fsrsrw $a1 = $a2",
   [/* no straightforward pattern */],
   ALU_LITE>;

def FWIDENLHW : SILENT2_REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SilentMod:$a1),
   "fwidenlhw$a1 $a2 = $a3",
   [/* no straightforward pattern */]>;

def FWIDENMHW : SILENT2_REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SilentMod:$a1),
   "fwidenmhw$a1 $a2 = $a3",
   [/* no straightforward pattern */]>;

def FNARROWWH : ROUNDING2_SILENT2_REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a3), (ins SingleReg:$a4, RoundingMod:$a1, SilentMod:$a2),
   "fnarrowwh$a1$a2 $a3 = $a4",
   [/* no straightforward pattern */],
   ALU_LITE>;

def FNEGWP : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fnegwp $a1 = $a2",
   [(set v2f32:$a1, (fneg v2f32:$a2))],
   ALU_LITE>;

def FABSWP : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fabswp $a1 = $a2",
   [(set v2f32:$a1, (fabs v2f32:$a2))],
   ALU_LITE>;

def FSRECWP : SILENT2_REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SilentMod:$a1),
   "fsrecwp$a1 $a2 = $a3",
   [/* no straightforward pattern */]>;

def FSRSRWP : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fsrsrwp $a1 = $a2",
   [/* no straightforward pattern */],
   ALU_LITE>;

def FWIDENLHWP : SILENT2_REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SilentMod:$a1),
   "fwidenlhwp$a1 $a2 = $a3",
   [/* no straightforward pattern */]>;

def FWIDENMHWP : SILENT2_REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SilentMod:$a1),
   "fwidenmhwp$a1 $a2 = $a3",
   [/* no straightforward pattern */]>;

def FNARROWDWP : ROUNDING2_SILENT2_REGISTERW_REGISTERP_SIMPLE
  <(outs SingleReg:$a3), (ins PairedReg:$a4, RoundingMod:$a1, SilentMod:$a2),
   "fnarrowdwp$a1$a2 $a3 = $a4",
   [/* no straightforward pattern */],
   ALU_FULL>;

def FNEGHQ : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fneghq $a1 = $a2",
   [(set v4f16:$a1, (fneg v4f16:$a2))],
   ALU_LITE>;

def FABSHQ : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fabshq $a1 = $a2",
   [(set f16:$a1, (fabs f16:$a2))],
   ALU_LITE>;

def FNARROWWHQ : ROUNDING2_SILENT2_REGISTERW_REGISTERP_SIMPLE
  <(outs SingleReg:$a3), (ins PairedReg:$a4, RoundingMod:$a1, SilentMod:$a2),
   "fnarrowwhq$a1$a2 $a3 = $a4",
   [/* no straightforward pattern */],
   ALU_LITE>;

let Constraints = "$a1 = $a1o" in
def INSF : REGISTERW_REGISTERZ_STOPBIT2_STOPBIT4_STARTBIT_SIMPLE
  <(outs SingleReg:$a1o), (ins SingleReg:$a1, SingleReg:$a2, Unsigned6:$a3, Unsigned6:$a4),
   "insf $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */]>;

def EXTFZ : REGISTERW_REGISTERZ_STOPBIT2_STOPBIT4_STARTBIT_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, Unsigned6:$a3, Unsigned6:$a4),
   "extfz $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */]>;

def EXTFS : REGISTERW_REGISTERZ_STOPBIT2_STOPBIT4_STARTBIT_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, Unsigned6:$a3, Unsigned6:$a4),
   "extfs $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */]>;

def CLRF : REGISTERW_REGISTERZ_STOPBIT2_STOPBIT4_STARTBIT_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, Unsigned6:$a3, Unsigned6:$a4),
   "clrf $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */]>;

defm SATD : MC_18<"satd">;

defm SRSD : MC_18<"srsd">;

defm SLLD : MC_19<"slld">;

defm SRAD : MC_19<"srad">;

defm SRLD : MC_19<"srld">;

defm SLSD : MC_18<"slsd">;

defm SRSW : MC_18<"srsw">;

defm SLLW : MC_19<"sllw">;

defm SRAW : MC_19<"sraw">;

defm SRLW : MC_19<"srlw">;

defm SLSW : MC_18<"slsw">;

defm ROLW : MC_18<"rolw">;

defm RORW : MC_18<"rorw">;

defm SRSWPS : MC_18<"srswps">;

defm SLLWPS : MC_18<"sllwps">;

defm SRAWPS : MC_18<"srawps">;

defm SRLWPS : MC_18<"srlwps">;

defm SLSWPS : MC_18<"slswps">;

defm ROLWPS : MC_18<"rolwps">;

defm RORWPS : MC_18<"rorwps">;

defm SRSBOS : MC_18<"srsbos">, Requires<[IsV2]>;

defm SRSHQS : MC_18<"srshqs">;

defm SLLBOS : MC_18<"sllbos">, Requires<[IsV2]>;

defm SLLHQS : MC_18<"sllhqs">;

defm SRABOS : MC_18<"srabos">, Requires<[IsV2]>;

defm SRAHQS : MC_18<"srahqs">;

defm SRLBOS : MC_18<"srlbos">, Requires<[IsV2]>;

defm SRLHQS : MC_18<"srlhqs">;

defm SLSHQS : MC_18<"slshqs">;

defm COMPD : MC_1A<"compd">;

defm COMPW : MC_1B<"compw">;

defm COMPND : MC_1B<"compnd">, Requires<[IsV2]>;

defm COMPNW : MC_1B<"compnw">, Requires<[IsV2]>;

def COMPWD : COMPARISON_REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, ComparisonMod:$a1),
   "compwd$a1 $a2 = $a3, $a4",
   [/* no straightforward pattern */],
   ALU_LITE>;

def COMPUWD : COMPARISON_REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, ComparisonMod:$a1),
   "compuwd$a1 $a2 = $a3, $a4",
   [/* no straightforward pattern */],
   ALU_LITE>;

def COMPNWP : COMPARISON_REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, ComparisonMod:$a1),
   "compnwp$a1 $a2 = $a3, $a4",
   [/* no straightforward pattern */],
   ALU_TINY>;

def COMPNBO : COMPARISON_REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, ComparisonMod:$a1),
   "compnbo$a1 $a2 = $a3, $a4",
   [/* no straightforward pattern */],
   ALU_TINY>, Requires<[IsV2]>;

def COMPNHQ : COMPARISON_REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, ComparisonMod:$a1),
   "compnhq$a1 $a2 = $a3, $a4",
   [/* no straightforward pattern */],
   ALU_TINY>;

defm CMOVED : MC_1C<"cmoved">;

let Constraints = "$a3 = $a3o" in
def CMOVEWP : SIMDCOND_REGISTERZ_REGISTERW_REGISTERY_SIMPLE
  <(outs SingleReg:$a3o), (ins SingleReg:$a2, SingleReg:$a3, SingleReg:$a4, SimplecondMod:$a1),
   "cmovewp$a1 $a2 ? $a3 = $a4",
   [/* no straightforward pattern */]>;

let isAsCheapAsAMove = 1, isReMaterializable = 1, isMoveImm = 1, isPredicable = 1 in
defm MAKE : MC_1D<"make">;

defm PCREL : MC_1E<"pcrel">;

def CLZW : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "clzw $a1 = $a2",
   [(set i32:$a1, (ctlz i32:$a2))],
   ALU_LITE>;

def CLSW : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "clsw $a1 = $a2",
   [/* no straightforward pattern */],
   ALU_LITE>;

def CBSW : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "cbsw $a1 = $a2",
   [(set i32:$a1, (ctpop i32:$a2))],
   ALU_LITE>;

def CTZW : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "ctzw $a1 = $a2",
   [(set i32:$a1, (cttz i32:$a2))],
   ALU_LITE>;

def CLZD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "clzd $a1 = $a2",
   [(set i64:$a1, (ctlz i64:$a2))],
   ALU_LITE>;

def CLSD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "clsd $a1 = $a2",
   [/* no straightforward pattern */],
   ALU_LITE>;

def CBSD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "cbsd $a1 = $a2",
   [(set i64:$a1, (ctpop i64:$a2))],
   ALU_LITE>;

def CTZD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "ctzd $a1 = $a2",
   [(set i64:$a1, (cttz i64:$a2))],
   ALU_LITE>;

def CLZWP : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "clzwp $a1 = $a2",
   [(set v2i32:$a1, (ctlz v2i32:$a2))],
   ALU_LITE>;

def CLSWP : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "clswp $a1 = $a2",
   [/* no straightforward pattern */],
   ALU_LITE>;

def CBSWP : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "cbswp $a1 = $a2",
   [(set v2i32:$a1, (ctpop v2i32:$a2))],
   ALU_LITE>;

def CTZWP : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "ctzwp $a1 = $a2",
   [(set v2i32:$a1, (cttz v2i32:$a2))],
   ALU_LITE>;

def SXLHWP : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "sxlhwp $a1 = $a2",
   [/* no straightforward pattern */],
   ALU_LITE>;

def SXMHWP : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "sxmhwp $a1 = $a2",
   [/* no straightforward pattern */],
   ALU_LITE>;

def SXLBHQ : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "sxlbhq $a1 = $a2",
   [/* no straightforward pattern */],
   ALU_LITE>;

def SXMBHQ : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "sxmbhq $a1 = $a2",
   [/* no straightforward pattern */],
   ALU_LITE>;

let Constraints = "$a3 = $a3o" in
def CMOVEHQ : SIMDCOND_REGISTERZ_REGISTERW_REGISTERY_SIMPLE
  <(outs SingleReg:$a3o), (ins SingleReg:$a2, SingleReg:$a3, SingleReg:$a4, SimplecondMod:$a1),
   "cmovehq$a1 $a2 ? $a3 = $a4",
   [/* no straightforward pattern */]>;

let Constraints = "$a3 = $a3o" in
def CMOVEBO : SIMDCOND_REGISTERZ_REGISTERW_REGISTERY_SIMPLE
  <(outs SingleReg:$a3o), (ins SingleReg:$a2, SingleReg:$a3, SingleReg:$a4, SimplecondMod:$a1),
   "cmovebo$a1 $a2 ? $a3 = $a4",
   [/* no straightforward pattern */]>;

defm FCOMPNW : MC_1F<"fcompnw">, Requires<[IsV2]>;

defm FCOMPW : MC_1F<"fcompw">;

def FCOMPD : FLOATCOMP_REGISTERW_REGISTERZ_REGISTERY_SIMPLE_BINARY64
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, FloatcompMod:$a1),
   "fcompd$a1 $a2 = $a3, $a4",
   [/* no straightforward pattern */]>;

def FCOMPNWP : FLOATCOMP_REGISTERW_REGISTERZ_REGISTERY_SIMPLE_BINARY32X2
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, FloatcompMod:$a1),
   "fcompnwp$a1 $a2 = $a3, $a4",
   [/* no straightforward pattern */]>;

def FCOMPNHQ : FLOATCOMP_REGISTERW_REGISTERZ_REGISTERY_SIMPLE_BINARY16X4
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, FloatcompMod:$a1),
   "fcompnhq$a1 $a2 = $a3, $a4",
   [/* no straightforward pattern */]>;

def FSDIVD : SILENT2_REGISTERW_REGISTERP_SIMPLE
  <(outs SingleReg:$a2), (ins PairedReg:$a3, SilentMod:$a1),
   "fsdivd$a1 $a2 = $a3",
   [/* no straightforward pattern */]>;

def FCDIVD : SILENT2_REGISTERW_REGISTERP_SIMPLE
  <(outs SingleReg:$a2), (ins PairedReg:$a3, SilentMod:$a1),
   "fcdivd$a1 $a2 = $a3",
   [/* no straightforward pattern */]>;

def FSDIVW : SILENT2_REGISTERW_REGISTERP_SIMPLE
  <(outs SingleReg:$a2), (ins PairedReg:$a3, SilentMod:$a1),
   "fsdivw$a1 $a2 = $a3",
   [/* no straightforward pattern */]>;

def FCDIVW : SILENT2_REGISTERW_REGISTERP_SIMPLE
  <(outs SingleReg:$a2), (ins PairedReg:$a3, SilentMod:$a1),
   "fcdivw$a1 $a2 = $a3",
   [/* no straightforward pattern */]>;

def FSDIVWP : SILENT2_REGISTERW_REGISTERP_SIMPLE
  <(outs SingleReg:$a2), (ins PairedReg:$a3, SilentMod:$a1),
   "fsdivwp$a1 $a2 = $a3",
   [/* no straightforward pattern */]>;

def FCDIVWP : SILENT2_REGISTERW_REGISTERP_SIMPLE
  <(outs SingleReg:$a2), (ins PairedReg:$a3, SilentMod:$a1),
   "fcdivwp$a1 $a2 = $a3",
   [/* no straightforward pattern */]>;

let Predicates = [IsV2] in {
def FFDMAW : ROUNDING_SILENT_BINOP_MAU_FP<"ffdmaw", SingleReg, SingleReg>;

def FFMAWQ : ROUNDING_SILENT_TERNARY_AUXR_FP<"ffmawq", PairedReg, PairedReg>;
def FFMSWQ : ROUNDING_SILENT_TERNARY_AUXR_FP<"ffmswq", PairedReg, PairedReg>;

def FFDMDAW : ROUNDING_SILENT_TERNARY_AUXR_FP<"ffdmdaw", SingleReg, SingleReg>;
def FFDMDAWP : ROUNDING_SILENT_TERNARY_AUXR_FP<"ffdmdawp", SingleReg, PairedReg>;

def FFDMDSW : ROUNDING_SILENT_TERNARY_AUXR_FP<"ffdmdsw", SingleReg, SingleReg>;
def FFDMDSWP : ROUNDING_SILENT_TERNARY_AUXR_FP<"ffdmdswp", SingleReg, PairedReg>;

def FFDMASW : ROUNDING_SILENT_TERNARY_AUXR_FP<"ffdmasw", SingleReg, SingleReg>;
def FFDMASWP : ROUNDING_SILENT_TERNARY_AUXR_FP<"ffdmaswp", SingleReg, PairedReg>;

def FFDMSAW : ROUNDING_SILENT_TERNARY_AUXR_FP<"ffdmsaw", SingleReg, SingleReg>;
def FFDMSAWP : ROUNDING_SILENT_TERNARY_AUXR_FP<"ffdmsawp", SingleReg, PairedReg>;
}

def FMIND : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "fmind $a1 = $a2, $a3",
   [(set f64:$a1, (fminnum f64:$a2, f64:$a3))],
   ALU_LITE>;

def FMAXD : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "fmaxd $a1 = $a2, $a3",
   [(set f64:$a1, (fmaxnum f64:$a2, f64:$a3))],
   ALU_LITE>;

def FMINW : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "fminw $a1 = $a2, $a3",
   [(set f32:$a1, (fminnum f32:$a2, f32:$a3))],
   ALU_LITE>;

def FMAXW : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "fmaxw $a1 = $a2, $a3",
   [(set f32:$a1, (fmaxnum f32:$a2, f32:$a3))],
   ALU_LITE>;

def FMINWP : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "fminwp $a1 = $a2, $a3",
   [(set v2f32:$a1, (fminnum v2f32:$a2, v2f32:$a3))],
   ALU_LITE>;

def FMAXWP : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "fmaxwp $a1 = $a2, $a3",
   [(set v2f32:$a1, (fmaxnum v2f32:$a2, v2f32:$a3))],
   ALU_LITE>;

def FMINHQ : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "fminhq $a1 = $a2, $a3",
   [(set v4f16:$a1, (fminnum v4f16:$a2, v4f16:$a3))],
   ALU_LITE>;

def FMAXHQ : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "fmaxhq $a1 = $a2, $a3",
   [(set v4f16:$a1, (fmaxnum v4f16:$a2, v4f16:$a3))],
   ALU_LITE>;

def FLOATD : ROUNDING_SILENT_REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE_BINARY64
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "floatd$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */]>;

def FLOATWP : ROUNDING_SILENT_REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE_BINARY32X2
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "floatwp$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */]>;

def FLOATW : ROUNDING_SILENT_REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE_BINARY32
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "floatw$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */]>;

def FLOATUD : ROUNDING_SILENT_REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE_BINARY64
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "floatud$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */]>;

def FLOATUWP : ROUNDING_SILENT_REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE_BINARY32X2
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "floatuwp$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */]>;

def FLOATUW : ROUNDING_SILENT_REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE_BINARY32
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "floatuw$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */]>;

def FIXEDD : ROUNDING_SILENT_REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE_BINARY64
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fixedd$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */]>;

def FIXEDWP : ROUNDING_SILENT_REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE_BINARY32X2
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fixedwp$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */]>;

def FIXEDW : ROUNDING_SILENT_REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE_BINARY32
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fixedw$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */]>;

def FIXEDUD : ROUNDING_SILENT_REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE_BINARY64
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fixedud$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */]>;

def FIXEDUWP : ROUNDING_SILENT_REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE_BINARY32X2
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fixeduwp$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */]>;

def FIXEDUW : ROUNDING_SILENT_REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE_BINARY32
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fixeduw$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */]>;

defm MADDD : MC_20<"maddd">;

let Constraints = "$a1 = $a1o" in
def MSBFD : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1o), (ins SingleReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "msbfd $a1 = $a2, $a3",
   [(set i64:$a1o, (sub i64:$a1, (mul i64:$a2, i64:$a3)))],
   MAU_AUXR>;

defm MADDWP : MC_20<"maddwp">;

let Constraints = "$a1 = $a1o" in
def MSBFWP : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1o), (ins SingleReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "msbfwp $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR>;

defm MADDHQ : MC_20<"maddhq">;

let Constraints = "$a1 = $a1o" in
def MSBFHQ : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1o), (ins SingleReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "msbfhq $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR>;

let Constraints = "$a1 = $a1o" in
def MADDHWQ : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "maddhwq $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR>;

let Constraints = "$a1 = $a1o" in
def MSBFHWQ : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "msbfhwq $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR>;

let Constraints = "$a1 = $a1o" in
def MADDUHWQ : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "madduhwq $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR>;

let Constraints = "$a1 = $a1o" in
def MSBFUHWQ : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "msbfuhwq $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR>;

let Constraints = "$a1 = $a1o" in
def MADDSUHWQ : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "maddsuhwq $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR>;

let Constraints = "$a1 = $a1o" in
def MSBFSUHWQ : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "msbfsuhwq $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR>;

defm MADDDT : MC_21<"madddt">;

defm MADDUDT : MC_21<"maddudt">;

defm MADDSUDT : MC_21<"maddsudt">;

defm MADDUZDT : MC_21<"madduzdt">;

let Constraints = "$a1 = $a1o" in
def MSBFDT : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "msbfdt $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR>;

let Constraints = "$a1 = $a1o" in
def MSBFUDT : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "msbfudt $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR>;

let Constraints = "$a1 = $a1o" in
def MSBFSUDT : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "msbfsudt $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR>;

let Constraints = "$a1 = $a1o" in
def MSBFUZDT : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "msbfuzdt $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR>;

defm MULD : MC_22<"muld">;

defm MULDT : MC_23<"muldt">;

defm MULUDT : MC_23<"muludt">;

defm MULSUDT : MC_23<"mulsudt">;

defm CMULDT : MC_23<"cmuldt">;

let Constraints = "$a1 = $a1o" in
def CMULXDT : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "cmulxdt $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR>;

let Constraints = "$a1 = $a1o" in
def CMULGLXDT : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "cmulglxdt $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR>;

let Constraints = "$a1 = $a1o" in
def CMULGMXDT : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "cmulgmxdt $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR>;

let Constraints = "$a1 = $a1o" in
def CMULGHXDT : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "cmulghxdt $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR>;

defm CRCBELMW : MC_24<"crcbelmw">;

defm CRCBELLW : MC_24<"crcbellw">;

defm CRCLELMW : MC_24<"crclelmw">;

defm CRCLELLW : MC_24<"crclellw">;

defm DOT2WD : MC_22<"dot2wd">;

defm DOT2UWD : MC_22<"dot2uwd">;

defm DOT2SUWD : MC_22<"dot2suwd">;

defm DOT2W : MC_22<"dot2w">;

def DOT2WDP : REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <(outs PairedReg:$a1), (ins PairedReg:$a2, PairedReg:$a3),
   "dot2wdp $a1 = $a2, $a3",
   [/* no straightforward pattern */]>;

def DOT2UWDP : REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <(outs PairedReg:$a1), (ins PairedReg:$a2, PairedReg:$a3),
   "dot2uwdp $a1 = $a2, $a3",
   [/* no straightforward pattern */]>;

def DOT2SUWDP : REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <(outs PairedReg:$a1), (ins PairedReg:$a2, PairedReg:$a3),
   "dot2suwdp $a1 = $a2, $a3",
   [/* no straightforward pattern */]>;

def MULWQ : REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <(outs PairedReg:$a1), (ins PairedReg:$a2, PairedReg:$a3),
   "mulwq $a1 = $a2, $a3",
   [(set v4i32:$a1, (mul v4i32:$a2, v4i32:$a3))]>;

def DOT2WZP : REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <(outs PairedReg:$a1), (ins PairedReg:$a2, PairedReg:$a3),
   "dot2wzp $a1 = $a2, $a3",
   [/* no straightforward pattern */]>;

defm MULWP : MC_22<"mulwp">;

defm MULHQ : MC_22<"mulhq">;

defm MULWC : MC_22<"mulwc">;

def MULCWC : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "mulcwc $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU>;

def MULWDC : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "mulwdc $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU>;

def MULCWDC : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "mulcwdc $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU>;

def MULHWQ : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "mulhwq $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU>;

def MULUHWQ : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "muluhwq $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU>;

def MULSUHWQ : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "mulsuhwq $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU>;

defm MADDWD : MC_24<"maddwd">;

defm MADDUWD : MC_24<"madduwd">;

defm MADDSUWD : MC_24<"maddsuwd">;

defm MADDW : MC_24<"maddw">;

defm MSBFWD : MC_24<"msbfwd">;

defm MSBFUWD : MC_24<"msbfuwd">;

defm MSBFSUWD : MC_24<"msbfsuwd">;

defm MSBFW : MC_24<"msbfw">;

defm MULWD : MC_25<"mulwd">;

defm MULUWD : MC_25<"muluwd">;

defm MULSUWD : MC_25<"mulsuwd">;

defm MULW : MC_25<"mulw">;

let Constraints = "$a1 = $a1o" in
def MADDWDP : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "maddwdp $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR>;

let Constraints = "$a1 = $a1o" in
def MADDUWDP : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "madduwdp $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR>;

let Constraints = "$a1 = $a1o" in
def MADDSUWDP : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "maddsuwdp $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR>;

let Constraints = "$a1 = $a1o" in
def MMA212W : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "mma212w $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR>;

let Constraints = "$a1 = $a1o" in
def MSBFWDP : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "msbfwdp $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR>;

let Constraints = "$a1 = $a1o" in
def MSBFUWDP : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "msbfuwdp $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR>;

let Constraints = "$a1 = $a1o" in
def MSBFSUWDP : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "msbfsuwdp $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR>;

let Constraints = "$a1 = $a1o" in
def MMS212W : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "mms212w $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR>;

def MULWDP : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "mulwdp $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU>;

def MULUWDP : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "muluwdp $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU>;

def MULSUWDP : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "mulsuwdp $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU>;

def MM212W : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "mm212w $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU>;

defm FFMAD : MC_26<"ffmad">;

defm FFMAWP : MC_27<"ffmawp">;

defm FFMAHQ : MC_28<"ffmahq">;

defm FFMSD : MC_26<"ffmsd">;

defm FFMSWP : MC_27<"ffmswp">;

defm FFMSHQ : MC_28<"ffmshq">;

defm FMULD : MC_29<"fmuld">;

defm FMULWP : MC_2A<"fmulwp">;

defm FMULHQ : MC_2B<"fmulhq">;

defm FMULWDP : MC_2C<"fmulwdp">;

defm FMULHWQ : MC_2D<"fmulhwq">;

def FMULWQ : ROUNDING_SILENT_REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <(outs PairedReg:$a3), (ins PairedReg:$a4, PairedReg:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fmulwq$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */]>;

defm FMULWC : MC_2AM<"fmulwc">;

defm FMULWDC : MC_2C<"fmulwdc">;

defm FMULCWDC : MC_2C<"fmulcwdc">;

let isAdd = 1 in
defm FADDD : MC_29<"faddd">;

let isAdd = 1 in
defm FADDWP : MC_2AM<"faddwp">;

let isAdd = 1 in
defm FADDHQ : MC_2B<"faddhq">;

def FADDDP : ROUNDING_SILENT_REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <(outs PairedReg:$a3), (ins PairedReg:$a4, PairedReg:$a5, ConjugateMod:$a6, RoundingMod:$a1, SilentMod:$a2),
   "fadddp$a6$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */]>;

def FADDWQ : ROUNDING_SILENT_REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <(outs PairedReg:$a3), (ins PairedReg:$a4, PairedReg:$a5, ConjugateMod:$a6, RoundingMod:$a1, SilentMod:$a2),
   "faddwq$a6$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */]>;

defm FSBFD : MC_29<"fsbfd">;

defm FSBFWP : MC_2AM<"fsbfwp">;

defm FSBFHQ : MC_2B<"fsbfhq">;

def FSBFDP : ROUNDING_SILENT_REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <(outs PairedReg:$a3), (ins PairedReg:$a4, PairedReg:$a5, ConjugateMod:$a6, RoundingMod:$a1, SilentMod:$a2),
   "fsbfdp$a6$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */]>;

def FSBFWQ : ROUNDING_SILENT_REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <(outs PairedReg:$a3), (ins PairedReg:$a4, PairedReg:$a5, ConjugateMod:$a6, RoundingMod:$a1, SilentMod:$a2),
   "fsbfwq$a6$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */]>;

defm FFMAHW : MC_2E_2<"ffmahw">;

defm FFMAW : MC_2E<"ffmaw">;

defm FFMAWD : MC_26<"ffmawd">;

defm FFMAWDP : MC_2F<"ffmawdp">;

defm FFMAHWQ : MC_30<"ffmahwq">;

defm FFMSHW : MC_2E_2<"ffmshw">;

defm FFMSW : MC_2E<"ffmsw">;

defm FFMSWD : MC_26<"ffmswd">;

defm FFMSWDP : MC_2F<"ffmswdp">;

defm FFMSHWQ : MC_30<"ffmshwq">;

let isAdd = 1 in
defm FADDW : MC_31<"faddw">;

defm FSBFW : MC_31<"fsbfw">;

defm FMULHW : MC_31_2<"fmulhw">;

defm FMULW : MC_31<"fmulw">;

defm FMULWD : MC_29<"fmulwd">;

defm FDOT2W : MC_2A<"fdot2w">;

defm FDOT2WD : MC_29<"fdot2wd">;

def FDOT2WZP : ROUNDING_SILENT_REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <(outs PairedReg:$a3), (ins PairedReg:$a4, PairedReg:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fdot2wzp$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */]>;

def FDOT2WDP : ROUNDING_SILENT_REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <(outs PairedReg:$a3), (ins PairedReg:$a4, PairedReg:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fdot2wdp$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */]>;

let Constraints = "$a3 = $a3o" in
def FMMA212W : ROUNDING_SILENT_REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a3o), (ins PairedReg:$a3, SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fmma212w$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */],
   MAU_AUXR_FP>;

let Constraints = "$a3 = $a3o" in
def FMMS212W : ROUNDING_SILENT_REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a3o), (ins PairedReg:$a3, SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fmms212w$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */],
   MAU_AUXR_FP>;

def FMM212W : ROUNDING_SILENT_REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a3), (ins SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fmm212w$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */],
   MAU>;

let isMoveReg = 1 in
def COPYQ : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "copyq $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU>;

let isMoveReg = 1 in
def COPYO : REGISTERN_REGISTERQ_SIMPLE
  <(outs QuadReg:$a1), (ins QuadReg:$a2),
   "copyo $a1 = $a2",
   [/* no straightforward pattern */]>;

defm MOVETQ : MC_32<"movetq">;

defm ALIGNO : MC_33<"aligno">;

defm ALIGNV : MC_34<"alignv">;

let Uses = [PCR] in {
def MT44D : REGISTERAQ_REGISTERBQ_SIMPLE
  <(outs MatrixReg:$a1), (ins MatrixReg:$a2),
   "mt44d $a1 = $a2",
   [/* no straightforward pattern */]>;

def MMA484BW : REGISTERAP_REGISTERBP_REGISTERC_REGISTERD_SIMPLE
  <(outs WideReg:$a1), (ins WideReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "mma484bw $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */]>;

def MMA484UBW : REGISTERAP_REGISTERBP_REGISTERC_REGISTERD_SIMPLE
  <(outs WideReg:$a1), (ins WideReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "mma484ubw $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */]>;

def MMA484SUBW : REGISTERAP_REGISTERBP_REGISTERC_REGISTERD_SIMPLE
  <(outs WideReg:$a1), (ins WideReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "mma484subw $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */]>;

def MMA484USBW : REGISTERAP_REGISTERBP_REGISTERC_REGISTERD_SIMPLE
  <(outs WideReg:$a1), (ins WideReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "mma484usbw $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */]>;

def MMA444HBD0 : REGISTERAQ_REGISTERBQ_REGISTERC_REGISTERD_SIMPLE
  <(outs MatrixReg:$a1), (ins MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "mma444hbd0 $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */]>;

def MMA444UHBD0 : REGISTERAQ_REGISTERBQ_REGISTERC_REGISTERD_SIMPLE
  <(outs MatrixReg:$a1), (ins MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "mma444uhbd0 $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */]>;

def MMA444SUHBD0 : REGISTERAQ_REGISTERBQ_REGISTERC_REGISTERD_SIMPLE
  <(outs MatrixReg:$a1), (ins MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "mma444suhbd0 $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */]>;

def MMA444USHBD0 : REGISTERAQ_REGISTERBQ_REGISTERC_REGISTERD_SIMPLE
  <(outs MatrixReg:$a1), (ins MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "mma444ushbd0 $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */]>;

def MMA444HBD1 : REGISTERAQ_REGISTERBQ_REGISTERC_REGISTERD_SIMPLE
  <(outs MatrixReg:$a1), (ins MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "mma444hbd1 $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */]>;

def MMA444UHBD1 : REGISTERAQ_REGISTERBQ_REGISTERC_REGISTERD_SIMPLE
  <(outs MatrixReg:$a1), (ins MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "mma444uhbd1 $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */]>;

def MMA444SUHBD1 : REGISTERAQ_REGISTERBQ_REGISTERC_REGISTERD_SIMPLE
  <(outs MatrixReg:$a1), (ins MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "mma444suhbd1 $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */]>;

def MMA444USHBD1 : REGISTERAQ_REGISTERBQ_REGISTERC_REGISTERD_SIMPLE
  <(outs MatrixReg:$a1), (ins MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "mma444ushbd1 $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */]>;

def MMA444HD : REGISTERAQ_REGISTERBQ_REGISTERC_REGISTERD_SIMPLE
  <(outs MatrixReg:$a1), (ins MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "mma444hd $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */]>;

def MMA444UHD : REGISTERAQ_REGISTERBQ_REGISTERC_REGISTERD_SIMPLE
  <(outs MatrixReg:$a1), (ins MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "mma444uhd $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */]>;

def MMA444SUHD : REGISTERAQ_REGISTERBQ_REGISTERC_REGISTERD_SIMPLE
  <(outs MatrixReg:$a1), (ins MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "mma444suhd $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */]>;

def MMA444USHD : REGISTERAQ_REGISTERBQ_REGISTERC_REGISTERD_SIMPLE
  <(outs MatrixReg:$a1), (ins MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "mma444ushd $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */]>;

def FMMA242HW0 : REGISTERA0_REGISTERBP_REGISTERC_REGISTERD_SIMPLE
  <(outs BlockReg0M4:$a1), (ins WideReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "fmma242hw0 $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */]>;

def FMMA242HW1 : REGISTERA1_REGISTERBP_REGISTERC_REGISTERD_SIMPLE
  <(outs BlockReg1M4:$a1), (ins WideReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "fmma242hw1 $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */]>;

def FMMA242HW2 : REGISTERA2_REGISTERBP_REGISTERC_REGISTERD_SIMPLE
  <(outs BlockReg2M4:$a1), (ins WideReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "fmma242hw2 $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */]>;

def FMMA242HW3 : REGISTERA3_REGISTERBP_REGISTERC_REGISTERD_SIMPLE
  <(outs BlockReg3M4:$a1), (ins WideReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "fmma242hw3 $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */]>;

def CONVDHV0 : ROUNDINT_SATURATE_REGISTERAL_REGISTERBQ_SIMPLE
  <(outs BlockRegE:$a3), (ins MatrixReg:$a4, RoundintMod:$a1, SaturateMod:$a2),
   "convdhv0$a1$a2 $a3 = $a4",
   [/* no straightforward pattern */]>;

def CONVDHV1 : ROUNDINT_SATURATE_REGISTERAH_REGISTERBQ_SIMPLE
  <(outs BlockRegO:$a3), (ins MatrixReg:$a4, RoundintMod:$a1, SaturateMod:$a2),
   "convdhv1$a1$a2 $a3 = $a4",
   [/* no straightforward pattern */]>;

def CONVWBV0 : ROUNDINT_SATURATE_REGISTERAX_REGISTERBQ_SIMPLE
  <(outs CoproReg0M4:$a3), (ins MatrixReg:$a4, RoundintMod:$a1, SaturateMod:$a2),
   "convwbv0$a1$a2 $a3 = $a4",
   [/* no straightforward pattern */]>;

def CONVWBV1 : ROUNDINT_SATURATE_REGISTERAY_REGISTERBQ_SIMPLE
  <(outs CoproReg1M4:$a3), (ins MatrixReg:$a4, RoundintMod:$a1, SaturateMod:$a2),
   "convwbv1$a1$a2 $a3 = $a4",
   [/* no straightforward pattern */]>;

def CONVWBV2 : ROUNDINT_SATURATE_REGISTERAZ_REGISTERBQ_SIMPLE
  <(outs CoproReg2M4:$a3), (ins MatrixReg:$a4, RoundintMod:$a1, SaturateMod:$a2),
   "convwbv2$a1$a2 $a3 = $a4",
   [/* no straightforward pattern */]>;

def CONVWBV3 : ROUNDINT_SATURATE_REGISTERAT_REGISTERBQ_SIMPLE
  <(outs CoproReg3M4:$a3), (ins MatrixReg:$a4, RoundintMod:$a1, SaturateMod:$a2),
   "convwbv3$a1$a2 $a3 = $a4",
   [/* no straightforward pattern */]>;

def FSCALEWV : XROUNDING_SILENT2_RECTIFY_REGISTERA_REGISTERB_SIMPLE
  <(outs VectorReg:$a4), (ins VectorReg:$a5, RoundingMod:$a1, SilentMod:$a2, RectifyMod:$a3),
   "fscalewv$a1$a2$a3 $a4 = $a5",
   [/* no straightforward pattern */]>;

def FNARROWWHV : XROUNDING_SILENT2_REGISTERA_REGISTERBP_SIMPLE
  <(outs VectorReg:$a3), (ins WideReg:$a4, RoundingMod:$a1, SilentMod:$a2),
   "fnarrowwhv$a1$a2 $a3 = $a4",
   [/* no straightforward pattern */]>;
}

let isPredicable = 1 in
def COPYD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "copyd $a1 = $a2",
   [/* no straightforward pattern */],
   ALU_TINY>;

def NOTD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "notd $a1 = $a2",
   [(set i64:$a1, (not i64:$a2))],
   ALU_TINY>;

def NEGD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "negd $a1 = $a2",
   [(set i64:$a1, (ineg i64:$a2))],
   ALU_TINY>;

def ABSD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "absd $a1 = $a2",
   [(set i64:$a1, (abs i64:$a2))],
   ALU_LITE>;

def ZXBD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "zxbd $a1 = $a2",
   [(set i64:$a1, (zext i8:$a2))],
   ALU_TINY>;

def SXBD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "sxbd $a1 = $a2",
   [(set i64:$a1, (sext i8:$a2))],
   ALU_LITE>;

def ZXHD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "zxhd $a1 = $a2",
   [(set i64:$a1, (zext i16:$a2))],
   ALU_LITE>;

def SXHD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "sxhd $a1 = $a2",
   [(set i64:$a1, (sext i16:$a2))],
   ALU_LITE>;

def ZXWD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "zxwd $a1 = $a2",
   [(set i64:$a1, (zext i32:$a2))],
   ALU_TINY>;

def SXWD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "sxwd $a1 = $a2",
   [(set i64:$a1, (sext i32:$a2))],
   ALU_LITE>;

def SATDH : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "satdh $a1 = $a2",
   [/* no straightforward pattern */],
   ALU_LITE>;

def SATDW : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "satdw $a1 = $a2",
   [/* no straightforward pattern */],
   ALU_LITE>;

def COPYW : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "copyw $a1 = $a2",
   [/* no straightforward pattern */],
   ALU_TINY>;

def NOTW : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "notw $a1 = $a2",
   [(set i32:$a1, (not i32:$a2))],
   ALU_TINY>;

def NEGW : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "negw $a1 = $a2",
   [(set i32:$a1, (ineg i32:$a2))],
   ALU_TINY>;

def ABSW : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "absw $a1 = $a2",
   [(set i32:$a1, (abs i32:$a2))],
   ALU_LITE>;

def NEGWP : REGISTERW_REGISTERZ_DOUBLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "negwp $a1 = $a2",
   [(set v2i32:$a1, (vineg v2i32:$a2))],
   ALU_TINY_X>;

def ABSWP : REGISTERW_REGISTERZ_DOUBLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "abswp $a1 = $a2",
   [(set v2i32:$a1, (abs v2i32:$a2))],
   ALU_LITE_X>;

def NEGHQ : REGISTERW_REGISTERZ_DOUBLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "neghq $a1 = $a2",
   [(set v4i16:$a1, (vineg v4i16:$a2))],
   ALU_TINY_X>;

def NEGBO : REGISTERW_REGISTERZ_DOUBLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "negbo $a1 = $a2",
   [(set v8i8:$a1, (vineg v8i8:$a2))],
   ALU_TINY_X>, Requires<[IsV2]>;

def ABSHQ : REGISTERW_REGISTERZ_DOUBLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "abshq $a1 = $a2",
   [(set v4i16:$a1, (abs v4i16:$a2))],
   ALU_LITE_X>;

def ABSBO : REGISTERW_REGISTERZ_DOUBLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "absbo $a1 = $a2",
   [(set v8i8:$a1, (abs v8i8:$a2))],
   ALU_TINY_X>, Requires<[IsV2]>;

defm COPYV : MC_35<"copyv">;

defm MOVEFO : MC_36<"movefo">;

// TODO: Marking as commutable should allow patterns to
// match rhs or lhs immediates, but that does not seem
// to work as it does with isAdd attribute.
let isCommutable = 1 in {
defm ABDSBO : MC_17<"abdsbo">, Requires<[IsV2]>;
defm ABDSHQ : MC_17<"abdshq">, Requires<[IsV2]>;
defm ABDSW  : MC_17<"abdsw">,  Requires<[IsV2]>;
defm ABDSWP : MC_17<"abdswp">, Requires<[IsV2]>;
defm ABDSD : MC_17<"abdsd">, Requires<[IsV2]>;
}

def FMM222W : FP_PairedReg_PairedReg_PairedReg_Transp_Round_Silent
  <"fmm222w", MAU_FP>;

def FMMA222W : FP_PairedReg_PairedReg_PairedReg_Transp_Round_Silent_Accumulate
  <"fmma222w", MAU_AUXR_FP>;

def FMMS222W : FP_PairedReg_PairedReg_PairedReg_Transp_Round_Silent_Accumulate
  <"fmms222w", MAU_AUXR_FP>;

defm SLSBOS : MC_18<"slsbos">, Requires<[IsV2]>;
defm SLUSBOS : MC_18<"slusbos">, Requires<[IsV2]>;
defm SLUSD : MC_18<"slusd">, Requires<[IsV2]>;
defm SLUSHQS : MC_18<"slushqs">, Requires<[IsV2]>;
defm SLUSW : MC_18<"slusw">, Requires<[IsV2]>;
defm SLUSWPS : MC_18<"sluswps">, Requires<[IsV2]>;

def NEGSBO : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$o), (ins SingleReg:$i),
   "negsbo $o = $i", [(set v8i8:$o, (vineg_ssat v8i8:$i))], ALU_LITE_X>, Requires<[IsV2]>;

def NEGSD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$o), (ins SingleReg:$i),
  "negsd $o = $i", [(set i64:$o, (ssubsat 0, i64:$i))], ALU_LITE_X>, Requires<[IsV2]>;

def NEGSHQ : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$o), (ins SingleReg:$i),
   "negshq $o = $i", [(set v4i16:$o, (vineg_ssat v4i16:$i))], ALU_LITE_X>, Requires<[IsV2]>;

def NEGSW : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$o), (ins SingleReg:$i),
  "negsw $o = $i", [(set i32:$o, (ssubsat 0, i32:$i))], ALU_LITE_X>, Requires<[IsV2]>;

def NEGSWP : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$o), (ins SingleReg:$i),
   "negswp $o = $i", [(set v2i32:$o, (vineg_ssat v2i32:$i))], ALU_LITE_X>, Requires<[IsV2]>;
