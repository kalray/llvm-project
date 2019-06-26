//===-- K1InstrInfo.td - Target Description for K1 Target -----------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file describes the K1 instructions in TableGen format.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Instruction format superclass
//===----------------------------------------------------------------------===//

// This file was automatically generated, DO NOT EDIT.
// Last generated: 2019-03-18 11:14:10.983261.

include "K1CInstruction.td"
include "K1CInstrFormats.td"


// multiclass MC_00 is used by:
//   defm SCALL
multiclass MC_00<string OpcStr> {
  def d0 : REGISTERZ_SIMPLE
    <(outs), (ins SingleReg:$a1),
     !strconcat (OpcStr, " $a1"),
     [], // pattern missing
     NoItinerary>;
  def d1 : SYSNUMBER_SIMPLE
    <(outs), (ins Sysnumber:$a1), // Sysnumber ?!?
     !strconcat (OpcStr, " $a1"),
     []>; // pattern missing

}

// multiclass MC_01 is used by:
//   defm FXLW
//   defm FXMW
multiclass MC_01<string OpcStr> {
  def d0 : SYSTEMT2_REGISTERZ_SIMPLE
    <(outs NopcpsReg:$a1), (ins NopcpsReg:$a11, SingleReg:$a2),
     !strconcat (OpcStr, " $a1, $a2"),
     []>; //
  // ?!? PS unknown  created PSReg
  def d1 : SYSTEMPS_REGISTERZ_SIMPLE
    <(outs PSReg:$a1), (ins PSReg:$a11, SingleReg:$a2),
     !strconcat (OpcStr, " $a1, $a2"),
     []>; // PATTERN
}

// multiclass MC_02 is used by:
//   defm SET
multiclass MC_02<string OpcStr> {
  def d0 : SYSTEMT2_REGISTERZ_SIMPLE
    <(outs NopcpsReg:$a1), (ins NopcpsReg:$a11, SingleReg:$a2),
     !strconcat (OpcStr, " $a1, $a2"),
     []>;
  // ?!? PS unknown created PSReg
  def d1 : SYSTEMPS_REGISTERZ_SIMPLE
    <(outs PSReg:$a1), (ins PSReg:$a11, SingleReg:$a2),
     !strconcat (OpcStr, " $a1, $a2"),
     []>;
  // ?!? RA unknown created RAReg
  def d2 : SYSTEMRA_REGISTERZ_SIMPLE
    <(outs RAReg:$a1), (ins SingleReg:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     []>;
}

// multiclass MC_03 is used by:
//   defm LBZ
//   defm LBS
//   defm LHZ
//   defm LHS
//   defm LWZ
//   defm LWS
//   defm LD
multiclass MC_03<string OpcStr> {
  def d0 : VARIANT_REGISTERW_SIGNED10_REGISTERZ_SIMPLE
    <(outs SingleReg:$a2), (ins Signed10_64:$a3, SingleReg:$a4, VariantMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3[$a4]"),
     [ ]>;
  def d1 : VARIANT_REGISTERW_UPPER27_LOWER10_REGISTERZ_DOUBLE
    <(outs SingleReg:$a2), (ins Signed37_64:$a3, SingleReg:$a4, VariantMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3[$a4]"),
     [ ]>;
  def d2 : VARIANT_REGISTERW_EXTEND27_UPPER27_LOWER10_REGISTERZ_TRIPLE
    <(outs SingleReg:$a2), (ins Wrapped64:$a3, SingleReg:$a4, VariantMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3[$a4]"),
     [ ]>;
  def d3 : VARIANT_LSUCOND_REGISTERY_REGISTERW_REGISTERZ_SIMPLE
    <(outs SingleReg:$a4), (ins SingleReg:$a3, SingleReg:$a5, SingleReg:$a44, VariantMod:$a1, ScalarcondMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3? $a4 = [$a5]"),
     [ ]>;
  def d4 : VARIANT_LSUCOND_REGISTERY_REGISTERW_OFFSET27_REGISTERZ_DOUBLE
    <(outs SingleReg:$a4), (ins SingleReg:$a3, Signed27:$a5, SingleReg:$a6, SingleReg:$a44, VariantMod:$a1, ScalarcondMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3? $a4 = $a5[$a6]"),
     [ ]>;
  def d5 : VARIANT_LSUCOND_REGISTERY_REGISTERW_EXTEND27_OFFSET27_REGISTERZ_TRIPLE
    <(outs SingleReg:$a4), (ins SingleReg:$a3, Signed54:$a5, SingleReg:$a6, SingleReg:$a44, VariantMod:$a1, ScalarcondMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3? $a4 = $a5[$a6]"),
     [ ]>;
  def d6 : VARIANT_SCALING_REGISTERW_REGISTERY_REGISTERZ_SIMPLE
    <(outs SingleReg:$a3), (ins SingleReg:$a4, SingleReg:$a5, VariantMod:$a1, ScalingMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4[$a5]"),
     [ ]>;
}

// multiclass MC_04 is used by:
//   defm LQ
multiclass MC_04<string OpcStr> {
  def d0 : VARIANT_REGISTERM_SIGNED10_REGISTERZ_SIMPLE
    <(outs PairedReg:$a2), (ins Signed10_64:$a3, SingleReg:$a4, VariantMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3[$a4]"),
     [ ]>;
  def d1 : VARIANT_REGISTERM_UPPER27_LOWER10_REGISTERZ_DOUBLE
    <(outs PairedReg:$a2), (ins Signed37_64:$a3, SingleReg:$a4, VariantMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3[$a4]"),
     [ ]>;
  def d2 : VARIANT_REGISTERM_EXTEND27_UPPER27_LOWER10_REGISTERZ_TRIPLE
    <(outs PairedReg:$a2), (ins Wrapped64:$a3, SingleReg:$a4, VariantMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3[$a4]"),
     [ ]>;
  def d3 : VARIANT_LSUCOND_REGISTERY_REGISTERM_REGISTERZ_SIMPLE
    <(outs PairedReg:$a4), (ins SingleReg:$a3, SingleReg:$a5, PairedReg:$a44, VariantMod:$a1, ScalarcondMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3? $a4 = [$a5]"),
     [ ]>;
  def d4 : VARIANT_LSUCOND_REGISTERY_REGISTERM_OFFSET27_REGISTERZ_DOUBLE
    <(outs PairedReg:$a4), (ins SingleReg:$a3, Signed27:$a5, SingleReg:$a6, PairedReg:$a44, VariantMod:$a1, ScalarcondMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3? $a4 = $a5[$a6]"),
     [ ]>;
  def d5 : VARIANT_LSUCOND_REGISTERY_REGISTERM_EXTEND27_OFFSET27_REGISTERZ_TRIPLE
    <(outs PairedReg:$a4), (ins SingleReg:$a3, Signed54:$a5, SingleReg:$a6, PairedReg:$a44, VariantMod:$a1, ScalarcondMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3? $a4 = $a5[$a6]"),
     [ ]>;
  def d6 : VARIANT_SCALING_REGISTERM_REGISTERY_REGISTERZ_SIMPLE
    <(outs PairedReg:$a3), (ins SingleReg:$a4, SingleReg:$a5, VariantMod:$a1, ScalingMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4[$a5]"),
     [ ]>;
}

// multiclass MC_05 is used by:
//   defm LO
multiclass MC_05<string OpcStr> {
  def d0 : VARIANT_REGISTERN_SIGNED10_REGISTERZ_SIMPLE
    <(outs QuadReg:$a2), (ins Signed10_64:$a3, SingleReg:$a4, VariantMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3[$a4]"),
     [ ]>;
  def d1 : VARIANT_REGISTERN_UPPER27_LOWER10_REGISTERZ_DOUBLE
    <(outs QuadReg:$a2), (ins Signed37_64:$a3, SingleReg:$a4, VariantMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3[$a4]"),
     [ ]>;
  def d2 : VARIANT_REGISTERN_EXTEND27_UPPER27_LOWER10_REGISTERZ_TRIPLE
    <(outs QuadReg:$a2), (ins Wrapped64:$a3, SingleReg:$a4, VariantMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3[$a4]"),
     [ ]>;
  def d3 : VARIANT_LSUCOND_REGISTERY_REGISTERN_REGISTERZ_SIMPLE
    <(outs QuadReg:$a4), (ins SingleReg:$a3, SingleReg:$a5, QuadReg:$a44, VariantMod:$a1, ScalarcondMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3? $a4 = [$a5]"),
     [ ]>;
  def d4 : VARIANT_LSUCOND_REGISTERY_REGISTERN_OFFSET27_REGISTERZ_DOUBLE
    <(outs QuadReg:$a4), (ins SingleReg:$a3, Signed27:$a5, SingleReg:$a6, QuadReg:$a44, VariantMod:$a1, ScalarcondMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3? $a4 = $a5[$a6]"),
     [ ]>;
  def d5 : VARIANT_LSUCOND_REGISTERY_REGISTERN_EXTEND27_OFFSET27_REGISTERZ_TRIPLE
    <(outs QuadReg:$a4), (ins SingleReg:$a3, Signed54:$a5, SingleReg:$a6, QuadReg:$a44, VariantMod:$a1, ScalarcondMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3? $a4 = $a5[$a6]"),
     [ ]>;
  def d6 : VARIANT_SCALING_REGISTERN_REGISTERY_REGISTERZ_SIMPLE
    <(outs QuadReg:$a3), (ins SingleReg:$a4, SingleReg:$a5, VariantMod:$a1, ScalingMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4[$a5]"),
     [ ]>;
}

// multiclass MC_06 is used by:
//   defm LV
multiclass MC_06<string OpcStr> {
  def d0 : SPECULATE_REGISTERA_SIGNED10_REGISTERZ_SIMPLE
    <(outs AccelReg:$a2), (ins Signed10_64:$a3, SingleReg:$a4, SpeculateMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3[$a4]"),
     [ ]>;
  def d1 : SPECULATE_REGISTERA_UPPER27_LOWER10_REGISTERZ_DOUBLE
    <(outs AccelReg:$a2), (ins Signed37_64:$a3, SingleReg:$a4, SpeculateMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3[$a4]"),
     [ ]>;
  def d2 : SPECULATE_REGISTERA_EXTEND27_UPPER27_LOWER10_REGISTERZ_TRIPLE
    <(outs AccelReg:$a2), (ins Wrapped64:$a3, SingleReg:$a4, SpeculateMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3[$a4]"),
     [ ]>;
  def d3 : SPECULATE_LSUCOND_REGISTERY_REGISTERA_REGISTERZ_SIMPLE
    <(outs AccelReg:$a4), (ins SingleReg:$a3, SingleReg:$a5, AccelReg:$a44, SpeculateMod:$a1, ScalarcondMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3? $a4 = [$a5]"),
     [ ]>;
  def d4 : SPECULATE_LSUCOND_REGISTERY_REGISTERA_OFFSET27_REGISTERZ_DOUBLE
    <(outs AccelReg:$a4), (ins SingleReg:$a3, Signed27:$a5, SingleReg:$a6, AccelReg:$a44, SpeculateMod:$a1, ScalarcondMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3? $a4 = $a5[$a6]"),
     [ ]>;
  def d5 : SPECULATE_LSUCOND_REGISTERY_REGISTERA_EXTEND27_OFFSET27_REGISTERZ_TRIPLE
    <(outs AccelReg:$a4), (ins SingleReg:$a3, Signed54:$a5, SingleReg:$a6, AccelReg:$a44, SpeculateMod:$a1, ScalarcondMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3? $a4 = $a5[$a6]"),
     [ ]>;
  def d6 : SPECULATE_SCALING_REGISTERA_REGISTERY_REGISTERZ_SIMPLE
    <(outs AccelReg:$a3), (ins SingleReg:$a4, SingleReg:$a5, SpeculateMod:$a1, ScalingMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4[$a5]"),
     [ ]>;
  def d7 : COLUMNSEL_SPECULATE_REGISTERAQ_SIGNED10_REGISTERZ_SIMPLE
    <(outs ExtendReg:$a3), (ins Signed10_64:$a4, SingleReg:$a5, ColumnselMod:$a1, SpeculateMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4[$a5]"),
     [ ]>;
  def d8 : COLUMNSEL_SPECULATE_REGISTERAQ_UPPER27_LOWER10_REGISTERZ_DOUBLE
    <(outs ExtendReg:$a3), (ins Signed37_64:$a4, SingleReg:$a5, ColumnselMod:$a1, SpeculateMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4[$a5]"),
     [ ]>;
  def d9 : COLUMNSEL_SPECULATE_REGISTERAQ_EXTEND27_UPPER27_LOWER10_REGISTERZ_TRIPLE
    <(outs ExtendReg:$a3), (ins Wrapped64:$a4, SingleReg:$a5, ColumnselMod:$a1, SpeculateMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4[$a5]"),
     [ ]>;
  def da : COLUMNSEL_SPECULATE_LSUCOND_REGISTERY_REGISTERAQ_REGISTERZ_SIMPLE
    <(outs ExtendReg:$a5), (ins SingleReg:$a4, SingleReg:$a6, ColumnselMod:$a1, SpeculateMod:$a2, ScalarcondMod:$a3),
     !strconcat (OpcStr, "$a1$a2$a3 $a4? $a5 = [$a6]"),
     [ ]>;
  def db : COLUMNSEL_SPECULATE_LSUCOND_REGISTERY_REGISTERAQ_OFFSET27_REGISTERZ_DOUBLE
    <(outs ExtendReg:$a5), (ins SingleReg:$a4, Signed27:$a6, SingleReg:$a7, ColumnselMod:$a1, SpeculateMod:$a2, ScalarcondMod:$a3),
     !strconcat (OpcStr, "$a1$a2$a3 $a4? $a5 = $a6[$a7]"),
     [ ]>;
  def dc : COLUMNSEL_SPECULATE_LSUCOND_REGISTERY_REGISTERAQ_EXTEND27_OFFSET27_REGISTERZ_TRIPLE
    <(outs ExtendReg:$a5), (ins SingleReg:$a4, Signed54:$a6, SingleReg:$a7, ColumnselMod:$a1, SpeculateMod:$a2, ScalarcondMod:$a3),
     !strconcat (OpcStr, "$a1$a2$a3 $a4? $a5 = $a6[$a7]"),
     [ ]>;
  def dd : COLUMNSEL_SPECULATE_SCALING_REGISTERAQ_REGISTERY_REGISTERZ_SIMPLE
    <(outs ExtendReg:$a4), (ins SingleReg:$a5, SingleReg:$a6, ColumnselMod:$a1, SpeculateMod:$a2, ScalingMod:$a3),
     !strconcat (OpcStr, "$a1$a2$a3 $a4 = $a5[$a6]"),
     [ ]>;
}

// multiclass MC_07 is used by:
//   defm SB
//   defm SH
//   defm SW
//   defm SD
multiclass MC_07<string OpcStr> { // $a1=12, $a2=$r12, $a3=$r0
  def d0 : SIGNED10_REGISTERZ_REGISTERT_SIMPLE
    <(outs), (ins Signed10_64:$a1, SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d1 : UPPER27_LOWER10_REGISTERZ_REGISTERT_DOUBLE
    <(outs), (ins Signed37_64:$a1, SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d2 : EXTEND27_UPPER27_LOWER10_REGISTERZ_REGISTERT_TRIPLE
    <(outs), (ins Wrapped64:$a1, SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d3 : SCALING_REGISTERY_REGISTERZ_REGISTERT_SIMPLE
    <(outs), (ins SingleReg:$a2, SingleReg:$a3, SingleReg:$a4, ScalingMod:$a1),
     !strconcat (OpcStr, "$a1 $a2[$a3] = $a4"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d4 : LSUCOND_REGISTERY_REGISTERZ_REGISTERT_SIMPLE
    <(outs), (ins SingleReg:$a2, SingleReg:$a3, SingleReg:$a4, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2? [$a3] = $a4"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d5 : LSUCOND_REGISTERY_OFFSET27_REGISTERZ_REGISTERT_DOUBLE
    <(outs), (ins SingleReg:$a2, Signed27:$a3, SingleReg:$a4, SingleReg:$a5, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2? $a3[$a4] = $a5"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d6 : LSUCOND_REGISTERY_EXTEND27_OFFSET27_REGISTERZ_REGISTERT_TRIPLE
    <(outs), (ins SingleReg:$a2, Signed54:$a3, SingleReg:$a4, SingleReg:$a5, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2? $a3[$a4] = $a5"),
     [ ],
     __UNKNOWN_ITIN__>;
}

// multiclass MC_08 is used by:
//   defm SQ
multiclass MC_08<string OpcStr> {
  def d0 : SIGNED10_REGISTERZ_REGISTERU_SIMPLE
    <(outs), (ins Signed10_64:$a1, SingleReg:$a2, PairedReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d1 : UPPER27_LOWER10_REGISTERZ_REGISTERU_DOUBLE
    <(outs), (ins Signed37_64:$a1, SingleReg:$a2, PairedReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d2 : EXTEND27_UPPER27_LOWER10_REGISTERZ_REGISTERU_TRIPLE
    <(outs), (ins Wrapped64:$a1, SingleReg:$a2, PairedReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [ ]>;
  def d3 : SCALING_REGISTERY_REGISTERZ_REGISTERU_SIMPLE
    <(outs), (ins SingleReg:$a2, SingleReg:$a3, PairedReg:$a4, ScalingMod:$a1),
     !strconcat (OpcStr, "$a1 $a2[$a3] = $a4"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d4 : LSUCOND_REGISTERY_REGISTERZ_REGISTERU_SIMPLE
    <(outs), (ins SingleReg:$a2, SingleReg:$a3, PairedReg:$a4, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2? [$a3] = $a4"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d5 : LSUCOND_REGISTERY_OFFSET27_REGISTERZ_REGISTERU_DOUBLE
    <(outs), (ins SingleReg:$a2, Signed27:$a3, SingleReg:$a4, PairedReg:$a5, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2? $a3[$a4] = $a5"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d6 : LSUCOND_REGISTERY_EXTEND27_OFFSET27_REGISTERZ_REGISTERU_TRIPLE
    <(outs), (ins SingleReg:$a2, Signed54:$a3, SingleReg:$a4, PairedReg:$a5, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2? $a3[$a4] = $a5"),
     [ ],
     __UNKNOWN_ITIN__>;
}

// multiclass MC_09 is used by:
//   defm SO
multiclass MC_09<string OpcStr> {
  def d0 : SIGNED10_REGISTERZ_REGISTERV_SIMPLE
    <(outs), (ins Signed10_64:$a1, SingleReg:$a2, QuadReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [ ]>;
  def d1 : UPPER27_LOWER10_REGISTERZ_REGISTERV_DOUBLE
    <(outs), (ins Signed37_64:$a1, SingleReg:$a2, QuadReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [ ]>;
  def d2 : EXTEND27_UPPER27_LOWER10_REGISTERZ_REGISTERV_TRIPLE
    <(outs), (ins Wrapped64:$a1, SingleReg:$a2, QuadReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [ ]>;
  def d3 : SCALING_REGISTERY_REGISTERZ_REGISTERV_SIMPLE
    <(outs), (ins SingleReg:$a2, SingleReg:$a3, QuadReg:$a4, ScalingMod:$a1),
     !strconcat (OpcStr, "$a1 $a2[$a3] = $a4"),
     [ ]>;
  def d4 : LSUCOND_REGISTERY_REGISTERZ_REGISTERV_SIMPLE
    <(outs), (ins SingleReg:$a2, SingleReg:$a3, QuadReg:$a4, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2? [$a3] = $a4"),
     [ ]>;
  def d5 : LSUCOND_REGISTERY_OFFSET27_REGISTERZ_REGISTERV_DOUBLE
    <(outs), (ins SingleReg:$a2, Signed27:$a3, SingleReg:$a4, QuadReg:$a5, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2? $a3[$a4] = $a5"),
     [ ]>;
  def d6 : LSUCOND_REGISTERY_EXTEND27_OFFSET27_REGISTERZ_REGISTERV_TRIPLE
    <(outs), (ins SingleReg:$a2, Signed54:$a3, SingleReg:$a4, QuadReg:$a5, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2? $a3[$a4] = $a5"),
     [ ]>;
}

// multiclass MC_0A is used by:
//   defm SV
multiclass MC_0A<string OpcStr> {
  def d0 : SIGNED10_REGISTERZ_REGISTERE_SIMPLE
    <(outs), (ins Signed10_64:$a1, SingleReg:$a2, AccelReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [ ]>;
  def d1 : UPPER27_LOWER10_REGISTERZ_REGISTERE_DOUBLE
    <(outs), (ins Signed37_64:$a1, SingleReg:$a2, AccelReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [ ]>;
  def d2 : EXTEND27_UPPER27_LOWER10_REGISTERZ_REGISTERE_TRIPLE
    <(outs), (ins Wrapped64:$a1, SingleReg:$a2, AccelReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [ ]>;
  def d3 : SCALING_REGISTERY_REGISTERZ_REGISTERE_SIMPLE
    <(outs), (ins SingleReg:$a2, SingleReg:$a3, AccelReg:$a4, ScalingMod:$a1),
     !strconcat (OpcStr, "$a1 $a2[$a3] = $a4"),
     [ ]>;
  def d4 : LSUCOND_REGISTERY_REGISTERZ_REGISTERE_SIMPLE
    <(outs), (ins SingleReg:$a2, SingleReg:$a3, AccelReg:$a4, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2? [$a3] = $a4"),
     [ ]>;
  def d5 : LSUCOND_REGISTERY_OFFSET27_REGISTERZ_REGISTERE_DOUBLE
    <(outs), (ins SingleReg:$a2, Signed27:$a3, SingleReg:$a4, AccelReg:$a5, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2? $a3[$a4] = $a5"),
     [ ]>;
  def d6 : LSUCOND_REGISTERY_EXTEND27_OFFSET27_REGISTERZ_REGISTERE_TRIPLE
    <(outs), (ins SingleReg:$a2, Signed54:$a3, SingleReg:$a4, AccelReg:$a5, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2? $a3[$a4] = $a5"),
     [ ]>;
}

// multiclass MC_0B is used by:
//   defm ACSWAPW
//   defm ACSWAPD
multiclass MC_0B<string OpcStr> {
  def d0 : SIGNED10_REGISTERZ_REGISTERU_SIMPLE
    <(outs), (ins Signed10_64:$a1, SingleReg:$a2, PairedReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d1 : UPPER27_LOWER10_REGISTERZ_REGISTERU_DOUBLE
    <(outs), (ins Signed37_64:$a1, SingleReg:$a2, PairedReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d2 : SCALING_REGISTERY_REGISTERZ_REGISTERU_SIMPLE
    <(outs), (ins SingleReg:$a2, SingleReg:$a3, PairedReg:$a4, ScalingMod:$a1),
     !strconcat (OpcStr, "$a1 $a2[$a3] = $a4"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d3 : LSUCOND_REGISTERY_REGISTERZ_REGISTERU_SIMPLE
    <(outs), (ins SingleReg:$a2, SingleReg:$a3, PairedReg:$a4, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2? [$a3] = $a4"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d4 : LSUCOND_REGISTERY_OFFSET27_REGISTERZ_REGISTERU_DOUBLE
    <(outs), (ins SingleReg:$a2, Signed27:$a3, SingleReg:$a4, PairedReg:$a5, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2? $a3[$a4] = $a5"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d5 : LSUCOND_REGISTERY_EXTEND27_OFFSET27_REGISTERZ_REGISTERU_TRIPLE
    <(outs), (ins SingleReg:$a2, Signed54:$a3, SingleReg:$a4, PairedReg:$a5, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2? $a3[$a4] = $a5"),
     [ ],
     __UNKNOWN_ITIN__>;
}

// multiclass MC_0C is used by:
//   defm ALCLRW
//   defm ALCLRD
multiclass MC_0C<string OpcStr> {
  def d0 : REGISTERW_SIGNED10_REGISTERZ_SIMPLE
    <(outs SingleReg:$a1), (ins Signed10_64:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2[$a3]"),
     [ ]>;
  def d1 : REGISTERW_UPPER27_LOWER10_REGISTERZ_DOUBLE
    <(outs SingleReg:$a1), (ins Signed37_64:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2[$a3]"),
     [ ]>;
  def d2 : REGISTERW_EXTEND27_UPPER27_LOWER10_REGISTERZ_TRIPLE
    <(outs SingleReg:$a1), (ins Wrapped64:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2[$a3]"),
     [ ]>;
  def d3 : SCALING_REGISTERW_REGISTERY_REGISTERZ_SIMPLE
    <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, ScalingMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3[$a4]"),
     [ ]>;
  def d4 : LSUCOND_REGISTERY_REGISTERW_REGISTERZ_SIMPLE
    <(outs SingleReg:$a3), (ins SingleReg:$a2, SingleReg:$a4, SingleReg:$a33, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2? $a3 = [$a4]"),
     [ ]>;
  def d5 : LSUCOND_REGISTERY_REGISTERW_OFFSET27_REGISTERZ_DOUBLE
    <(outs SingleReg:$a3), (ins SingleReg:$a2, Signed27:$a4, SingleReg:$a5, SingleReg:$a33, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2? $a3 = $a4[$a5]"),
     [ ]>;
  def d6 : LSUCOND_REGISTERY_REGISTERW_EXTEND27_OFFSET27_REGISTERZ_TRIPLE
    <(outs SingleReg:$a3), (ins SingleReg:$a2, Signed54:$a4, SingleReg:$a5, SingleReg:$a33, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2? $a3 = $a4[$a5]"),
     [ ]>;
}

// multiclass MC_0D is used by:
//   defm AFADDW
//   defm AFADDD
multiclass MC_0D<string OpcStr> {
  def d0 : SIGNED10_REGISTERZ_REGISTERT_SIMPLE
    <(outs), (ins Signed10_64:$a1, SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d1 : UPPER27_LOWER10_REGISTERZ_REGISTERT_DOUBLE
    <(outs), (ins Signed37_64:$a1, SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d2 : EXTEND27_UPPER27_LOWER10_REGISTERZ_REGISTERT_TRIPLE
    <(outs), (ins Wrapped64:$a1, SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d3 : SCALING_REGISTERY_REGISTERZ_REGISTERT_SIMPLE
    <(outs), (ins SingleReg:$a2, SingleReg:$a3, SingleReg:$a4, ScalingMod:$a1),
     !strconcat (OpcStr, "$a1 $a2[$a3] = $a4"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d4 : LSUCOND_REGISTERY_REGISTERZ_REGISTERT_SIMPLE
    <(outs), (ins SingleReg:$a2, SingleReg:$a3, SingleReg:$a4, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2? [$a3] = $a4"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d5 : LSUCOND_REGISTERY_OFFSET27_REGISTERZ_REGISTERT_DOUBLE
    <(outs), (ins SingleReg:$a2, Signed27:$a3, SingleReg:$a4, SingleReg:$a5, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2? $a3[$a4] = $a5"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d6 : LSUCOND_REGISTERY_EXTEND27_OFFSET27_REGISTERZ_REGISTERT_TRIPLE
    <(outs), (ins SingleReg:$a2, Signed54:$a3, SingleReg:$a4, SingleReg:$a5, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2? $a3[$a4] = $a5"),
     [ ],
     __UNKNOWN_ITIN__>;
}

// multiclass MC_0E is used by:
//   defm DTOUCHL
//   defm DINVALL
//   defm DZEROL
//   defm IINVALS
multiclass MC_0E<string OpcStr> {
  def d0 : SIGNED10_REGISTERZ_SIMPLE
    <(outs), (ins Signed10_64:$a1, SingleReg:$a2),
     !strconcat (OpcStr, " $a1[$a2]"),
     [ ]>;
  def d1 : UPPER27_LOWER10_REGISTERZ_DOUBLE
    <(outs), (ins Signed37_64:$a1, SingleReg:$a2),
     !strconcat (OpcStr, " $a1[$a2]"),
     [ ]>;
  def d2 : EXTEND27_UPPER27_LOWER10_REGISTERZ_TRIPLE
    <(outs), (ins Wrapped64:$a1, SingleReg:$a2),
     !strconcat (OpcStr, " $a1[$a2]"),
     [ ]>;
  def d3 : REGISTERY_REGISTERZ_SIMPLE
    <(outs), (ins SingleReg:$a1, SingleReg:$a2),
     !strconcat (OpcStr, " $a1[$a2]"),
     [ ]>;
  def d4 : LSUCOND_REGISTERY_REGISTERZ_SIMPLE
    <(outs), (ins SingleReg:$a2, SingleReg:$a3, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2? [$a3]"),
     [ ]>;
  def d5 : LSUCOND_REGISTERY_OFFSET27_REGISTERZ_DOUBLE
    <(outs), (ins SingleReg:$a2, Signed27:$a3, SingleReg:$a4, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2? $a3[$a4]"),
     [ ]>;
  def d6 : LSUCOND_REGISTERY_EXTEND27_OFFSET27_REGISTERZ_TRIPLE
    <(outs), (ins SingleReg:$a2, Signed54:$a3, SingleReg:$a4, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2? $a3[$a4]"),
     [ ]>;
}

// multiclass MC_0F is used by:
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
multiclass MC_0F<string OpcStr> {
  def d0 : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d1 : REGISTERW_REGISTERZ_SIGNED10_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed10_64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d2 : REGISTERW_REGISTERZ_UPPER27_LOWER10_DOUBLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed37_64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d3 : REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Wrapped64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
}

// multiclass MC_10 is used by:
//   defm ABDD
//   defm SBMM8
//   defm SBMMT8
//   defm ADDSD
//   defm SBFSD
multiclass MC_10<string OpcStr> {
  def d0 : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [],
     __UNKNOWN_ITIN__>;
  def d1 : REGISTERW_REGISTERZ_SIGNED10_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed10_64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d2 : REGISTERW_REGISTERZ_UPPER27_LOWER10_DOUBLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed37_64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d3 : REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Wrapped64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
}

// multiclass MC_11 is used by:
//   defm ADDX2D
//   defm ADDX4D
//   defm ADDX8D
//   defm ADDX16D
//   defm SBFX2D
//   defm SBFX4D
//   defm SBFX8D
//   defm SBFX16D
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
//   defm SBFX2W
//   defm SBFX4W
//   defm SBFX8W
//   defm SBFX16W
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
//   defm SBFX2WD
//   defm SBFX4WD
//   defm SBFX8WD
//   defm SBFX16WD
//   defm ADDX2UWD
//   defm ADDX4UWD
//   defm ADDX8UWD
//   defm ADDX16UWD
//   defm SBFX2UWD
//   defm SBFX4UWD
//   defm SBFX8UWD
//   defm SBFX16UWD
multiclass MC_11<string OpcStr> {
  def d0 : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d1 : REGISTERW_REGISTERZ_UPPER27_LOWER5_DOUBLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Wrapped32:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
}

// multiclass MC_12 is used by:
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
multiclass MC_12<string OpcStr> {
  def d0 : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d1 : REGISTERW_REGISTERZ_SIGNED10_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed10_32:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d2 : REGISTERW_REGISTERZ_UPPER27_LOWER10_DOUBLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed37_32:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
}

// multiclass MC_13 is used by:
//   defm ABDW
multiclass MC_13<string OpcStr> {
  def d0 : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d1 : REGISTERW_REGISTERZ_SIGNED10_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed10_32:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d2 : REGISTERW_REGISTERZ_UPPER27_LOWER10_DOUBLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed37_32:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
}

// multiclass MC_14 is used by:
//   defm ADDWP
//   defm SBFWP
//   defm MINWP
//   defm MINUWP
//   defm MAXWP
//   defm MAXUWP
//   defm ADDHQ
//   defm SBFHQ
//   defm MINHQ
//   defm MINUHQ
//   defm MAXHQ
//   defm MAXUHQ
multiclass MC_14<string OpcStr> {
  def d0 : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d1 : SPLAT32_REGISTERW_REGISTERZ_UPPER27_LOWER5_DOUBLE
    <(outs SingleReg:$a2), (ins SingleReg:$a3, Wrapped32:$a4, Splat32Mod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [ ],
     __UNKNOWN_ITIN__>;
}

// multiclass MC_15 is used by:
//   defm ABDWP
//   defm ADDCWC
//   defm SBFCWC
//   defm ADDSWP
//   defm SBFSWP
//   defm ADDX2WP
//   defm ADDX4WP
//   defm ADDX8WP
//   defm ADDX16WP
//   defm SBFX2WP
//   defm SBFX4WP
//   defm SBFX8WP
//   defm SBFX16WP
//   defm AVGWP
//   defm AVGUWP
//   defm AVGRWP
//   defm AVGRUWP
//   defm LANDWP
//   defm LNANDWP
//   defm LORWP
//   defm LNORWP
//   defm ABDHQ
//   defm ADDCHCP
//   defm SBFCHCP
//   defm ADDSHQ
//   defm SBFSHQ
//   defm ADDX2HQ
//   defm ADDX4HQ
//   defm ADDX8HQ
//   defm ADDX16HQ
//   defm SBFX2HQ
//   defm SBFX4HQ
//   defm SBFX8HQ
//   defm SBFX16HQ
//   defm AVGHQ
//   defm AVGUHQ
//   defm AVGRHQ
//   defm AVGRUHQ
//   defm LANDHQ
//   defm LNANDHQ
//   defm LORHQ
//   defm LNORHQ
multiclass MC_15<string OpcStr> {
  def d0 : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d1 : SPLAT32_REGISTERW_REGISTERZ_UPPER27_LOWER5_DOUBLE
    <(outs SingleReg:$a2), (ins SingleReg:$a3, Wrapped32:$a4, Splat32Mod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [ ],
     __UNKNOWN_ITIN__>;
}

// multiclass MC_16 is used by:
//   defm SATD
//   defm SATUD
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
//   defm SLLHQS
//   defm SRAHQS
//   defm SRLHQS
//   defm SLSHQS
multiclass MC_16<string OpcStr> {
  def d0 : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d1 : REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Unsigned6:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
}

// multiclass MC_17 is used by:
//   defm SLLD
//   defm SRAD
//   defm SRLD
//   defm SLLW
//   defm SRAW
//   defm SRLW
multiclass MC_17<string OpcStr> {
  def d0 : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d1 : REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Unsigned6:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
}

// multiclass MC_18 is used by:
//   defm COMPD
multiclass MC_18<string OpcStr> {
  def d0 : COMPARISON_REGISTERW_REGISTERZ_SIGNED10_SIMPLE
    <(outs SingleReg:$a2), (ins SingleReg:$a3, Signed10_64:$a4, ComparisonMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [ ]>;
  def d1 : COMPARISON_REGISTERW_REGISTERZ_UPPER27_LOWER10_DOUBLE
    <(outs SingleReg:$a2), (ins SingleReg:$a3, Signed37_64:$a4, ComparisonMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [ ]>;
  def d2 : COMPARISON_REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
    <(outs SingleReg:$a2), (ins SingleReg:$a3, Wrapped64:$a4, ComparisonMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [ ]>;
  def d3 : COMPARISON_REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, ComparisonMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [ ],
     __UNKNOWN_ITIN__>;
}

// multiclass MC_19 is used by:
//   defm COMPW
multiclass MC_19<string OpcStr> {
  def d0 : COMPARISON_REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, ComparisonMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d1 : COMPARISON_REGISTERW_REGISTERZ_UPPER27_LOWER5_DOUBLE
    <(outs SingleReg:$a2), (ins SingleReg:$a3, Wrapped32:$a4, ComparisonMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [ ]>;
}

// multiclass MC_1A is used by:
//   defm CMOVED
multiclass MC_1A<string OpcStr> {
  def d0 : SCALARCOND_REGISTERZ_REGISTERW_SIGNED10_SIMPLE
    <(outs SingleReg:$a3), (ins SingleReg:$a2, Signed10_64:$a4, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2? $a3 = $a4"),
     [ ]>;
  def d1 : SCALARCOND_REGISTERZ_REGISTERW_UPPER27_LOWER10_DOUBLE
    <(outs SingleReg:$a3), (ins SingleReg:$a2, Signed37_64:$a4, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2? $a3 = $a4"),
     [ ]>;
  def d2 : SCALARCOND_REGISTERZ_REGISTERW_EXTEND27_UPPER27_LOWER10_TRIPLE
    <(outs SingleReg:$a3), (ins SingleReg:$a2, Wrapped64:$a4, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2? $a3 = $a4"),
     [ ]>;
  def d3 : SCALARCOND_REGISTERZ_REGISTERW_REGISTERY_SIMPLE
    <(outs SingleReg:$a3), (ins SingleReg:$a2, SingleReg:$a4, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2? $a3 = $a4"),
     [ ]>;
}

// multiclass MC_1B is used by:
//   defm MAKE
multiclass MC_1B<string OpcStr> {
  def d0 : REGISTERW_SIGNED16_SIMPLE
    <(outs SingleReg:$SingleReg), (ins Signed16_64:$Signed16),
     !strconcat (OpcStr, " $SingleReg = $Signed16"),
     [/*(set i32:$SingleReg, Signed16:$Signed16)*/],
     __UNKNOWN_ITIN__>;
  def d1 : REGISTERW_EXTEND6_UPPER27_LOWER10_DOUBLE
    <(outs SingleReg:$a1), (ins Signed43:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [ /*(set i64:$a1, Signed43:$a2)*/],
     __UNKNOWN_ITIN__>;
  def d2 : REGISTERW_EXTEND27_UPPER27_LOWER10_TRIPLE
    <(outs SingleReg:$SingleReg), (ins Wrapped64:$Wrapped64),
     !strconcat (OpcStr, " $SingleReg = $Wrapped64"),
     [ /*(set i64:$SingleReg, Wrapped64:$Wrapped64)*/],
     __UNKNOWN_ITIN__>;
}

// multiclass MC_1C is used by:
//   defm PCREL
multiclass MC_1C<string OpcStr> {
  def d0 : REGISTERW_SIGNED16_SIMPLE
    <(outs SingleReg:$a1), (ins Signed16_64:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d1 : REGISTERW_EXTEND6_UPPER27_LOWER10_DOUBLE
    <(outs SingleReg:$a1), (ins Signed43:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d2 : REGISTERW_EXTEND27_UPPER27_LOWER10_TRIPLE
    <(outs SingleReg:$a1), (ins Wrapped64:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [ ],
     __UNKNOWN_ITIN__>;
}

// multiclass MC_1DW is used by:
//   defm FCOMPW
multiclass MC_1DW<string OpcStr> {
  def rr : FLOATCOMP_REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, FloatcompMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [/* no direct match, see K1CFloatingPoint.td */]>;
  def ri : FLOATCOMP_REGISTERW_REGISTERZ_UPPER27_LOWER5_DOUBLE
    <(outs SingleReg:$a2), (ins SingleReg:$a3, Binary32Imm:$a4, FloatcompMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [/* no direct match, see K1CFloatingPoint.td */]>;
}

// multiclass MC_1DD is used by:
//   defm FCOMPD
multiclass MC_1DD<string OpcStr> {
  def rr : FLOATCOMP_REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, FloatcompMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [/* no direct match, see K1CFloatingPoint.td */]>;
}

// multiclass MC_1E is used by:
//   defm MADDD
//   defm MADDWP
//   defm MADDHQ
multiclass MC_1E<string OpcStr> {
  def d0 : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d1 : REGISTERW_REGISTERZ_SIGNED10_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed10_64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d2 : REGISTERW_REGISTERZ_UPPER27_LOWER10_DOUBLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed37_64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d3 : REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Wrapped64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
}

// multiclass MC_1F is used by:
//   defm MADDDT
//   defm MADDUDT
//   defm MADDSUDT
//   defm MADDUZDT
multiclass MC_1F<string OpcStr> {
  def d0 : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
    <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d1 : REGISTERM_REGISTERZ_SIGNED10_SIMPLE
    <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, Signed10_64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d2 : REGISTERM_REGISTERZ_UPPER27_LOWER10_DOUBLE
    <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, Signed37_64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d3 : REGISTERM_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
    <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, Wrapped64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
}

// multiclass MC_20 is used by:
//   defm MULD
//   defm DOT2WD
//   defm DOT2UWD
//   defm DOT2SUWD
//   defm DOT2W
//   defm MULWP
//   defm MULHQ
//   defm MULWC
multiclass MC_20<string OpcStr> {
  def d0 : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d1 : REGISTERW_REGISTERZ_SIGNED10_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed10_64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d2 : REGISTERW_REGISTERZ_UPPER27_LOWER10_DOUBLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed37_64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d3 : REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Wrapped64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
}

// multiclass MC_21 is used by:
//   defm MULDT
//   defm MULUDT
//   defm MULSUDT
//   defm CMULDT
multiclass MC_21<string OpcStr> {
  def d0 : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
    <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d1 : REGISTERM_REGISTERZ_SIGNED10_SIMPLE
    <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, Signed10_64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d2 : REGISTERM_REGISTERZ_UPPER27_LOWER10_DOUBLE
    <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, Signed37_64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d3 : REGISTERM_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
    <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, Wrapped64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
}

// multiclass MC_22 is used by:
//   defm CRCBELMW
//   defm CRCBELLW
//   defm CRCLELMW
//   defm CRCLELLW
//   defm MULWD
//   defm MULUWD
//   defm MULSUWD
//   defm MULW
multiclass MC_22<string OpcStr> {
  def d0 : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d1 : REGISTERW_REGISTERZ_UPPER27_LOWER5_DOUBLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Wrapped32:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
}

// multiclass MC_23 is used by:
//   defm MADDWD
//   defm MADDUWD
//   defm MADDSUWD
//   defm MADDW
//   defm MSBFWD
//   defm MSBFUWD
//   defm MSBFSUWD
//   defm MSBFW
multiclass MC_23<string OpcStr> {
  def d0 : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d1 : REGISTERW_REGISTERZ_UPPER27_LOWER5_DOUBLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Wrapped32:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
}

// multiclass MC_24 is used by:
//   defm FFMAD
//   defm FFMAWP
//   defm FFMAHQ
//   defm FFMSD
//   defm FFMSWP
//   defm FFMSHQ
//   defm FFMAHW
//   defm FFMAW
//   defm FFMAWD
//   defm FFMSHW
//   defm FFMSW
//   defm FFMSWD
multiclass MC_24<string OpcStr> {
  def d0 : REGISTERW_REGISTERZ_SIGNED10_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed10_64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d1 : REGISTERW_REGISTERZ_UPPER27_LOWER10_DOUBLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed37_64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d2 : REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Wrapped64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d3 : ROUNDING_SILENT_REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a3), (ins SingleReg:$a33, SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4, $a5"),
     [ ],
     __UNKNOWN_ITIN__>;
}

// multiclass MC_25 is used by:
//   defm FMULWP
//   defm FMULWC
//   defm FMULCWC
//   defm FADDWP
//   defm FADDCWC
//   defm FSBFD
//   defm FSBFWP
//   defm FSBFHQ
//   defm FSBFCWC
//   defm FSBFW
//   defm FMULHW
//   defm FMULWD
//   defm FDOT2W
//   defm FDOT2WD
multiclass MC_25<string OpcStr> {
  def d0 : REGISTERW_REGISTERZ_SIGNED10_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed10_64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d1 : REGISTERW_REGISTERZ_UPPER27_LOWER10_DOUBLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Binary32Imm:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d2 : REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Binary64Imm:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d3 : ROUNDING_SILENT_REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a3), (ins SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4, $a5"),
     [ ],
     __UNKNOWN_ITIN__>;
}

// multiclass MC_25H is used by:
//   defm FADDHQ
//   defm FMULHQ
multiclass MC_25H<string OpcStr, SDNode OpNode = fadd> {
  def ri : REGISTERW_REGISTERZ_UPPER27_LOWER10_DOUBLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Binary16Imm:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [(set f16:$a1, (OpNode f16:$a2, Binary16Imm:$a3))],
     __UNKNOWN_ITIN__>;
  def rr : ROUNDING_SILENT_REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a3), (ins SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4, $a5"),
     [/* no direct match, see K1CFloatingPoint.td */],
     __UNKNOWN_ITIN__>;
}

// multiclass MC_25W is used by:
//   defm FADDW
//   defm FMULW
multiclass MC_25W<string OpcStr, SDNode OpNode = fadd> {
  def ri : REGISTERW_REGISTERZ_UPPER27_LOWER10_DOUBLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Binary32Imm:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [(set f32:$a1, (OpNode f32:$a2, Binary32Imm:$a3))],
     __UNKNOWN_ITIN__>;
  def rr : ROUNDING_SILENT_REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a3), (ins SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4, $a5"),
     [/* no direct match, see K1CFloatingPoint.td */],
     __UNKNOWN_ITIN__>;
}

// multiclass MC_25D is used by:
//   defm FADDD
//   defm FMULD
multiclass MC_25D<string OpcStr, SDNode OpNode = fadd> {
  def ri : REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Binary64Imm:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [(set f64:$a1, (OpNode f64:$a2, Binary64Imm:$a3))],
     __UNKNOWN_ITIN__>;
  def rr : ROUNDING_SILENT_REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a3), (ins SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4, $a5"),
     [/* no direct match, see K1CFloatingPoint.td */],
     __UNKNOWN_ITIN__>;
}

// multiclass MC_26 is used by:
//   defm FMULWDP
//   defm FMULHWQ
//   defm FMULWDC
//   defm FMULCWDC
multiclass MC_26<string OpcStr> {
  def d0 : REGISTERM_REGISTERZ_SIGNED10_SIMPLE
    <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, Signed10_64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d1 : REGISTERM_REGISTERZ_UPPER27_LOWER10_DOUBLE
    <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, Signed37_64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d2 : REGISTERM_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
    <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, Wrapped64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d3 : ROUNDING_SILENT_REGISTERM_REGISTERZ_REGISTERY_SIMPLE
    <(outs PairedReg:$a3), (ins SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4, $a5"),
     [ ],
     __UNKNOWN_ITIN__>;
}

// multiclass MC_27 is used by:
//   defm FFMAWDP
//   defm FFMAHWQ
//   defm FFMSWDP
//   defm FFMSHWQ
multiclass MC_27<string OpcStr> {
  def d0 : REGISTERM_REGISTERZ_SIGNED10_SIMPLE
    <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, Signed10_64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d1 : REGISTERM_REGISTERZ_UPPER27_LOWER10_DOUBLE
    <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, Signed37_64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d2 : REGISTERM_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
    <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, Wrapped64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ],
     __UNKNOWN_ITIN__>;
  def d3 : ROUNDING_SILENT_REGISTERM_REGISTERZ_REGISTERY_SIMPLE
    <(outs PairedReg:$a3), (ins SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4, $a5"),
     [ ],
     __UNKNOWN_ITIN__>;
}

// multiclass MC_28 is used by:
//   defm MOVETQ
multiclass MC_28<string OpcStr> {
  def d0 : REGISTERAL_REGISTERZ_REGISTERY_SIMPLE
    <(outs BlockRegE:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ]>;
  def d1 : REGISTERAH_REGISTERZ_REGISTERY_SIMPLE
    <(outs BlockRegO:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [ ]>;
}

// multiclass MC_29 is used by:
//   defm ALIGNO
multiclass MC_29<string OpcStr> {
  def d0 : REGISTERN_REGISTERBE_REGISTERCO_BYTESHIFT_SIMPLE
    <(outs QuadReg:$a1), (ins AccelRegE:$a2, AccelRegO:$a3, Unsigned6:$a4),
     !strconcat (OpcStr, " $a1 = $a2, $a3, $a4"),
     [ ]>;
  def d1 : REGISTERN_REGISTERBO_REGISTERCE_BYTESHIFT_SIMPLE
    <(outs QuadReg:$a1), (ins AccelRegO:$a2, AccelRegE:$a3, Unsigned6:$a4),
     !strconcat (OpcStr, " $a1 = $a2, $a3, $a4"),
     [ ]>;
  def d2 : REGISTERN_REGISTERBE_REGISTERCO_REGISTERZ_SIMPLE
    <(outs QuadReg:$a1), (ins AccelRegE:$a2, AccelRegO:$a3, SingleReg:$a4),
     !strconcat (OpcStr, " $a1 = $a2, $a3, $a4"),
     [ ]>;
  def d3 : REGISTERN_REGISTERBO_REGISTERCE_REGISTERZ_SIMPLE
    <(outs QuadReg:$a1), (ins AccelRegO:$a2, AccelRegE:$a3, SingleReg:$a4),
     !strconcat (OpcStr, " $a1 = $a2, $a3, $a4"),
     [ ]>;
}

// multiclass MC_2A is used by:
//   defm ALIGNV
multiclass MC_2A<string OpcStr> {
  def d0 : REGISTERA_REGISTERBE_REGISTERCO_BYTESHIFT_SIMPLE
    <(outs AccelReg:$a1), (ins AccelRegE:$a2, AccelRegO:$a3, Unsigned6:$a4),
     !strconcat (OpcStr, " $a1 = $a2, $a3, $a4"),
     [ ]>;
  def d1 : REGISTERA_REGISTERBO_REGISTERCE_BYTESHIFT_SIMPLE
    <(outs AccelReg:$a1), (ins AccelRegO:$a2, AccelRegE:$a3, Unsigned6:$a4),
     !strconcat (OpcStr, " $a1 = $a2, $a3, $a4"),
     [ ]>;
  def d2 : REGISTERA_REGISTERBE_REGISTERCO_REGISTERZ_SIMPLE
    <(outs AccelReg:$a1), (ins AccelRegE:$a2, AccelRegO:$a3, SingleReg:$a4),
     !strconcat (OpcStr, " $a1 = $a2, $a3, $a4"),
     [ ]>;
  def d3 : REGISTERA_REGISTERBO_REGISTERCE_REGISTERZ_SIMPLE
    <(outs AccelReg:$a1), (ins AccelRegO:$a2, AccelRegE:$a3, SingleReg:$a4),
     !strconcat (OpcStr, " $a1 = $a2, $a3, $a4"),
     [ ]>;
}

// multiclass MC_2B is used by:
//   defm COPYV
multiclass MC_2B<string OpcStr> {
  def d0 : REGISTERA_REGISTERBE_SIMPLE
    <(outs AccelReg:$a1), (ins AccelRegE:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [ ]>;
  def d1 : REGISTERA_REGISTERBO_SIMPLE
    <(outs AccelReg:$a1), (ins AccelRegO:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [ ]>;
}

// multiclass MC_2C is used by:
//   defm MOVEFO
multiclass MC_2C<string OpcStr> {
  def d0 : REGISTERN_REGISTERBE_SIMPLE
    <(outs QuadReg:$a1), (ins AccelRegE:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [ ]>;
  def d1 : REGISTERN_REGISTERBO_SIMPLE
    <(outs QuadReg:$a1), (ins AccelRegO:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [ ]>;
}


// 1 insns: ['AWAIT']
def AWAIT : SIMPLE
  <(outs), (ins),
   "await",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['SLEEP']
def SLEEP : SIMPLE
  <(outs), (ins),
   "sleep",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['STOP']
let Uses=[PS] in
def STOP : SIMPLE
  <(outs), (ins),
   "stop",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['BARRIER']
def BARRIER : SIMPLE
  <(outs), (ins),
   "barrier",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['TLBREAD']
def TLBREAD : SIMPLE
  <(outs), (ins),
   "tlbread",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['TLBPROBE']
def TLBPROBE : SIMPLE
  <(outs), (ins),
   "tlbprobe",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['TLBWRITE']
let Uses=[PS] in
def TLBWRITE : SIMPLE
  <(outs), (ins),
   "tlbwrite",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['TLBDINVAL']
def TLBDINVAL : SIMPLE
  <(outs), (ins),
   "tlbdinval",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['TLBIINVAL']
def TLBIINVAL : SIMPLE
  <(outs), (ins),
   "tlbiinval",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['ERROP']
def ERROP : SIMPLE
  <(outs), (ins),
   "errop",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['BREAK']
def BREAK : SIMPLE
  <(outs), (ins),
   "break",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['RET']
let Uses=[RA],isBarrier = 1, isReturn = 1, isTerminator = 1 in
def RET : SIMPLE
  <(outs), (ins),
   "ret",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['RFE']
let Uses=[PS, SPC, SSPC], Defs=[SPC] in
def RFE : SIMPLE
  <(outs), (ins),
   "rfe",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['IGOTO']
def IGOTO : REGISTERZ_SIMPLE
  <(outs), (ins SingleReg:$a1),
   "igoto $a1",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['ICALL']
let Defs=[RA] in
def ICALL : REGISTERZ_SIMPLE
  <(outs), (ins SingleReg:$a1),
   "icall $a1",
   [ ],
   __UNKNOWN_ITIN__>;

// 2 insns: ['SCALL', 'SCALL']
defm SCALL : MC_00<"scall">;

// 1 insns: ['LOOPDO']
let Uses=[PS], Defs=[LC, LE, LS] in
def LOOPDO : REGISTERZ_PCREL17_SIMPLE
  <(outs), (ins SingleReg:$a1, Pcrel17:$a2),
   "loopdo $a1, $a2",
   [ ]>;

// 2 insns: ['FXLW', 'FXLW']
defm FXLW : MC_01<"fxlw">;

// 2 insns: ['FXMW', 'FXMW']
defm FXMW : MC_01<"fxmw">;

// 1 insns: ['GET']
def GET : REGISTERZ_SYSTEMS2_SIMPLE
  <(outs SingleReg:$a1), (ins SystemReg:$a2),
   "get $a1 = $a2",
   [ ]>;

// 1 insns: ['IGET']
def IGET : REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a11),
   "iget $a1",
   [ ],
   __UNKNOWN_ITIN__>;

// 3 insns: ['SET', 'SET', 'SET']
defm SET : MC_02<"set">;

// 1 insns: ['WAITIT']
def WAITIT : REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a11),
   "waitit $a1",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['SYNCGROUP']
def SYNCGROUP : REGISTERZ_SIMPLE
  <(outs), (ins SingleReg:$a1),
   "syncgroup $a1",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['GOTO']
let isBranch=1, isTerminator=1 in
def GOTO : PCREL27_SIMPLE
  <(outs), (ins Pcrel27:$a1),
   "goto $a1",
   [ ]>;

// 1 insns: ['CALL']
let Defs=[RA], isCall=1 in
def CALL : PCREL27_SIMPLE
  <(outs), (ins Pcrel27:$a1),
   "call $a1",
   [ ]>;

// 1 insns: ['CB']
let isBranch=1, isTerminator=1 in
def CB : BRANCHCOND_REGISTERZ_PCREL17_SIMPLE
  <(outs), (ins SingleReg:$a2, Pcrel17:$a3, ScalarcondMod:$a1),
   "cb$a1 $a2? $a3",
   [ ]>;

// 7 insns: ['LBZ', 'LBZ', 'LBZ', 'LBZ', 'LBZ', 'LBZ', 'LBZ']
defm LBZ : MC_03<"lbz">;

// 7 insns: ['LBS', 'LBS', 'LBS', 'LBS', 'LBS', 'LBS', 'LBS']
defm LBS : MC_03<"lbs">;

// 7 insns: ['LHZ', 'LHZ', 'LHZ', 'LHZ', 'LHZ', 'LHZ', 'LHZ']
defm LHZ : MC_03<"lhz">;

// 7 insns: ['LHS', 'LHS', 'LHS', 'LHS', 'LHS', 'LHS', 'LHS']
defm LHS : MC_03<"lhs">;

// 7 insns: ['LWZ', 'LWZ', 'LWZ', 'LWZ', 'LWZ', 'LWZ', 'LWZ']
defm LWZ : MC_03<"lwz">;

// 7 insns: ['LWS', 'LWS', 'LWS', 'LWS', 'LWS', 'LWS', 'LWS']
defm LWS : MC_03<"lws">;

// 7 insns: ['LD', 'LD', 'LD', 'LD', 'LD', 'LD', 'LD']
defm LD : MC_03<"ld">;

// 7 insns: ['LQ', 'LQ', 'LQ', 'LQ', 'LQ', 'LQ', 'LQ']
defm LQ : MC_04<"lq">;

// 7 insns: ['LO', 'LO', 'LO', 'LO', 'LO', 'LO', 'LO']
defm LO : MC_05<"lo">;

// 14 insns: ['LV', 'LV', 'LV', 'LV', 'LV', 'LV', 'LV', 'LV', 'LV', 'LV', 'LV', 'LV', 'LV', 'LV']
defm LV : MC_06<"lv">;

// 7 insns: ['SB', 'SB', 'SB', 'SB', 'SB', 'SB', 'SB']
defm SB : MC_07<"sb">;

// 7 insns: ['SH', 'SH', 'SH', 'SH', 'SH', 'SH', 'SH']
defm SH : MC_07<"sh">;

// 7 insns: ['SW', 'SW', 'SW', 'SW', 'SW', 'SW', 'SW']
defm SW : MC_07<"sw">;

// 7 insns: ['SD', 'SD', 'SD', 'SD', 'SD', 'SD', 'SD']
defm SD : MC_07<"sd">;

// 7 insns: ['SQ', 'SQ', 'SQ', 'SQ', 'SQ', 'SQ', 'SQ']
defm SQ : MC_08<"sq">;

// 7 insns: ['SO', 'SO', 'SO', 'SO', 'SO', 'SO', 'SO']
defm SO : MC_09<"so">;

// 7 insns: ['SV', 'SV', 'SV', 'SV', 'SV', 'SV', 'SV']
defm SV : MC_0A<"sv">;

// 6 insns: ['ACSWAPW', 'ACSWAPW', 'ACSWAPW', 'ACSWAPW', 'ACSWAPW', 'ACSWAPW']
defm ACSWAPW : MC_0B<"acswapw">;

// 6 insns: ['ACSWAPD', 'ACSWAPD', 'ACSWAPD', 'ACSWAPD', 'ACSWAPD', 'ACSWAPD']
defm ACSWAPD : MC_0B<"acswapd">;

// 7 insns: ['ALCLRW', 'ALCLRW', 'ALCLRW', 'ALCLRW', 'ALCLRW', 'ALCLRW', 'ALCLRW']
defm ALCLRW : MC_0C<"alclrw">;

// 7 insns: ['ALCLRD', 'ALCLRD', 'ALCLRD', 'ALCLRD', 'ALCLRD', 'ALCLRD', 'ALCLRD']
defm ALCLRD : MC_0C<"alclrd">;

// 7 insns: ['AFADDW', 'AFADDW', 'AFADDW', 'AFADDW', 'AFADDW', 'AFADDW', 'AFADDW']
defm AFADDW : MC_0D<"afaddw">;

// 7 insns: ['AFADDD', 'AFADDD', 'AFADDD', 'AFADDD', 'AFADDD', 'AFADDD', 'AFADDD']
defm AFADDD : MC_0D<"afaddd">;

// 7 insns: ['DTOUCHL', 'DTOUCHL', 'DTOUCHL', 'DTOUCHL', 'DTOUCHL', 'DTOUCHL', 'DTOUCHL']
defm DTOUCHL : MC_0E<"dtouchl">;

// 7 insns: ['DINVALL', 'DINVALL', 'DINVALL', 'DINVALL', 'DINVALL', 'DINVALL', 'DINVALL']
defm DINVALL : MC_0E<"dinvall">;

// 7 insns: ['DZEROL', 'DZEROL', 'DZEROL', 'DZEROL', 'DZEROL', 'DZEROL', 'DZEROL']
defm DZEROL : MC_0E<"dzerol">;

// 7 insns: ['IINVALS', 'IINVALS', 'IINVALS', 'IINVALS', 'IINVALS', 'IINVALS', 'IINVALS']
defm IINVALS : MC_0E<"iinvals">;

// 1 insns: ['DINVAL']
def DINVAL : SIMPLE
  <(outs), (ins),
   "dinval",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['IINVAL']
def IINVAL : SIMPLE
  <(outs), (ins),
   "iinval",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['FENCE']
def FENCE : SIMPLE
  <(outs), (ins),
   "fence",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['NOP']
def NOP : SIMPLE
  <(outs), (ins),
   "nop",
   [ ],
   __UNKNOWN_ITIN__>;
/*
def NOTRUNC : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "nop",
   [ ],
   __UNKNOWN_ITIN__>;
*/
// 1 insns: ['STSUD']
def STSUD : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "stsud $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 4 insns: ['ADDD', 'ADDD', 'ADDD', 'ADDD']
defm ADDD : MC_0F<"addd">;

// 4 insns: ['SBFD', 'SBFD', 'SBFD', 'SBFD']
defm SBFD : MC_0F<"sbfd">;

// 4 insns: ['ABDD', 'ABDD', 'ABDD', 'ABDD']
defm ABDD : MC_10<"abdd">;

// 4 insns: ['MIND', 'MIND', 'MIND', 'MIND']
defm MIND : MC_0F<"mind">;

// 4 insns: ['MINUD', 'MINUD', 'MINUD', 'MINUD']
defm MINUD : MC_0F<"minud">;

// 4 insns: ['MAXD', 'MAXD', 'MAXD', 'MAXD']
defm MAXD : MC_0F<"maxd">;

// 4 insns: ['MAXUD', 'MAXUD', 'MAXUD', 'MAXUD']
defm MAXUD : MC_0F<"maxud">;

// 4 insns: ['ANDD', 'ANDD', 'ANDD', 'ANDD']
defm ANDD : MC_0F<"andd">;

// 4 insns: ['NANDD', 'NANDD', 'NANDD', 'NANDD']
defm NANDD : MC_0F<"nandd">;

// 4 insns: ['ORD', 'ORD', 'ORD', 'ORD']
defm ORD : MC_0F<"ord">;

// 4 insns: ['NORD', 'NORD', 'NORD', 'NORD']
defm NORD : MC_0F<"nord">;

// 4 insns: ['XORD', 'XORD', 'XORD', 'XORD']
defm XORD : MC_0F<"xord">;

// 4 insns: ['NXORD', 'NXORD', 'NXORD', 'NXORD']
defm NXORD : MC_0F<"nxord">;

// 4 insns: ['ANDND', 'ANDND', 'ANDND', 'ANDND']
defm ANDND : MC_0F<"andnd">;

// 4 insns: ['ORND', 'ORND', 'ORND', 'ORND']
defm ORND : MC_0F<"ornd">;

// 4 insns: ['SBMM8', 'SBMM8', 'SBMM8', 'SBMM8']
defm SBMM8 : MC_10<"sbmm8">;

// 4 insns: ['SBMMT8', 'SBMMT8', 'SBMMT8', 'SBMMT8']
defm SBMMT8 : MC_10<"sbmmt8">;

// 4 insns: ['ADDSD', 'ADDSD', 'ADDSD', 'ADDSD']
defm ADDSD : MC_10<"addsd">;

// 4 insns: ['SBFSD', 'SBFSD', 'SBFSD', 'SBFSD']
defm SBFSD : MC_10<"sbfsd">;

// 2 insns: ['ADDX2D', 'ADDX2D']
defm ADDX2D : MC_11<"addx2d">;

// 2 insns: ['ADDX4D', 'ADDX4D']
defm ADDX4D : MC_11<"addx4d">;

// 2 insns: ['ADDX8D', 'ADDX8D']
defm ADDX8D : MC_11<"addx8d">;

// 2 insns: ['ADDX16D', 'ADDX16D']
defm ADDX16D : MC_11<"addx16d">;

// 2 insns: ['SBFX2D', 'SBFX2D']
defm SBFX2D : MC_11<"sbfx2d">;

// 2 insns: ['SBFX4D', 'SBFX4D']
defm SBFX4D : MC_11<"sbfx4d">;

// 2 insns: ['SBFX8D', 'SBFX8D']
defm SBFX8D : MC_11<"sbfx8d">;

// 2 insns: ['SBFX16D', 'SBFX16D']
defm SBFX16D : MC_11<"sbfx16d">;

// 2 insns: ['ADDWD', 'ADDWD']
defm ADDWD : MC_11<"addwd">;

// 2 insns: ['SBFWD', 'SBFWD']
defm SBFWD : MC_11<"sbfwd">;

// 2 insns: ['ADDUWD', 'ADDUWD']
defm ADDUWD : MC_11<"adduwd">;

// 2 insns: ['SBFUWD', 'SBFUWD']
defm SBFUWD : MC_11<"sbfuwd">;

// 2 insns: ['LANDD', 'LANDD']
defm LANDD : MC_11<"landd">;

// 2 insns: ['LNANDD', 'LNANDD']
defm LNANDD : MC_11<"lnandd">;

// 2 insns: ['LORD', 'LORD']
defm LORD : MC_11<"lord">;

// 2 insns: ['LNORD', 'LNORD']
defm LNORD : MC_11<"lnord">;

// 1 insns: ['STSUW']
def STSUW : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "stsuw $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 3 insns: ['ADDW', 'ADDW', 'ADDW']
defm ADDW : MC_12<"addw">;

// 3 insns: ['SBFW', 'SBFW', 'SBFW']
defm SBFW : MC_12<"sbfw">;

// 3 insns: ['ABDW', 'ABDW', 'ABDW']
defm ABDW : MC_13<"abdw">;

// 3 insns: ['MINW', 'MINW', 'MINW']
defm MINW : MC_12<"minw">;

// 3 insns: ['MINUW', 'MINUW', 'MINUW']
defm MINUW : MC_12<"minuw">;

// 3 insns: ['MAXW', 'MAXW', 'MAXW']
defm MAXW : MC_12<"maxw">;

// 3 insns: ['MAXUW', 'MAXUW', 'MAXUW']
defm MAXUW : MC_12<"maxuw">;

// 3 insns: ['ANDW', 'ANDW', 'ANDW']
defm ANDW : MC_12<"andw">;

// 3 insns: ['NANDW', 'NANDW', 'NANDW']
defm NANDW : MC_12<"nandw">;

// 3 insns: ['ORW', 'ORW', 'ORW']
defm ORW : MC_12<"orw">;

// 3 insns: ['NORW', 'NORW', 'NORW']
defm NORW : MC_12<"norw">;

// 3 insns: ['XORW', 'XORW', 'XORW']
defm XORW : MC_12<"xorw">;

// 3 insns: ['NXORW', 'NXORW', 'NXORW']
defm NXORW : MC_12<"nxorw">;

// 3 insns: ['ANDNW', 'ANDNW', 'ANDNW']
defm ANDNW : MC_12<"andnw">;

// 3 insns: ['ORNW', 'ORNW', 'ORNW']
defm ORNW : MC_12<"ornw">;

// 2 insns: ['ADDSW', 'ADDSW']
defm ADDSW : MC_11<"addsw">;

// 2 insns: ['SBFSW', 'SBFSW']
defm SBFSW : MC_11<"sbfsw">;

// 2 insns: ['ADDX2W', 'ADDX2W']
defm ADDX2W : MC_11<"addx2w">;

// 2 insns: ['ADDX4W', 'ADDX4W']
defm ADDX4W : MC_11<"addx4w">;

// 2 insns: ['ADDX8W', 'ADDX8W']
defm ADDX8W : MC_11<"addx8w">;

// 2 insns: ['ADDX16W', 'ADDX16W']
defm ADDX16W : MC_11<"addx16w">;

// 2 insns: ['SBFX2W', 'SBFX2W']
defm SBFX2W : MC_11<"sbfx2w">;

// 2 insns: ['SBFX4W', 'SBFX4W']
defm SBFX4W : MC_11<"sbfx4w">;

// 2 insns: ['SBFX8W', 'SBFX8W']
defm SBFX8W : MC_11<"sbfx8w">;

// 2 insns: ['SBFX16W', 'SBFX16W']
defm SBFX16W : MC_11<"sbfx16w">;

// 2 insns: ['AVGW', 'AVGW']
defm AVGW : MC_11<"avgw">;

// 2 insns: ['AVGUW', 'AVGUW']
defm AVGUW : MC_11<"avguw">;

// 2 insns: ['AVGRW', 'AVGRW']
defm AVGRW : MC_11<"avgrw">;

// 2 insns: ['AVGRUW', 'AVGRUW']
defm AVGRUW : MC_11<"avgruw">;

// 2 insns: ['LANDW', 'LANDW']
defm LANDW : MC_11<"landw">;

// 2 insns: ['LNANDW', 'LNANDW']
defm LNANDW : MC_11<"lnandw">;

// 2 insns: ['LORW', 'LORW']
defm LORW : MC_11<"lorw">;

// 2 insns: ['LNORW', 'LNORW']
defm LNORW : MC_11<"lnorw">;

// 2 insns: ['ADDWP', 'ADDWP']
defm ADDWP : MC_14<"addwp">;

// 2 insns: ['SBFWP', 'SBFWP']
defm SBFWP : MC_14<"sbfwp">;

// 2 insns: ['ABDWP', 'ABDWP']
defm ABDWP : MC_15<"abdwp">;

// 2 insns: ['MINWP', 'MINWP']
defm MINWP : MC_14<"minwp">;

// 2 insns: ['MINUWP', 'MINUWP']
defm MINUWP : MC_14<"minuwp">;

// 2 insns: ['MAXWP', 'MAXWP']
defm MAXWP : MC_14<"maxwp">;

// 2 insns: ['MAXUWP', 'MAXUWP']
defm MAXUWP : MC_14<"maxuwp">;

// 2 insns: ['ADDCWC', 'ADDCWC']
defm ADDCWC : MC_15<"addcwc">;

// 2 insns: ['SBFCWC', 'SBFCWC']
defm SBFCWC : MC_15<"sbfcwc">;

// 2 insns: ['ADDSWP', 'ADDSWP']
defm ADDSWP : MC_15<"addswp">;

// 2 insns: ['SBFSWP', 'SBFSWP']
defm SBFSWP : MC_15<"sbfswp">;

// 2 insns: ['ADDX2WP', 'ADDX2WP']
defm ADDX2WP : MC_15<"addx2wp">;

// 2 insns: ['ADDX4WP', 'ADDX4WP']
defm ADDX4WP : MC_15<"addx4wp">;

// 2 insns: ['ADDX8WP', 'ADDX8WP']
defm ADDX8WP : MC_15<"addx8wp">;

// 2 insns: ['ADDX16WP', 'ADDX16WP']
defm ADDX16WP : MC_15<"addx16wp">;

// 2 insns: ['SBFX2WP', 'SBFX2WP']
defm SBFX2WP : MC_15<"sbfx2wp">;

// 2 insns: ['SBFX4WP', 'SBFX4WP']
defm SBFX4WP : MC_15<"sbfx4wp">;

// 2 insns: ['SBFX8WP', 'SBFX8WP']
defm SBFX8WP : MC_15<"sbfx8wp">;

// 2 insns: ['SBFX16WP', 'SBFX16WP']
defm SBFX16WP : MC_15<"sbfx16wp">;

// 2 insns: ['AVGWP', 'AVGWP']
defm AVGWP : MC_15<"avgwp">;

// 2 insns: ['AVGUWP', 'AVGUWP']
defm AVGUWP : MC_15<"avguwp">;

// 2 insns: ['AVGRWP', 'AVGRWP']
defm AVGRWP : MC_15<"avgrwp">;

// 2 insns: ['AVGRUWP', 'AVGRUWP']
defm AVGRUWP : MC_15<"avgruwp">;

// 2 insns: ['LANDWP', 'LANDWP']
defm LANDWP : MC_15<"landwp">;

// 2 insns: ['LNANDWP', 'LNANDWP']
defm LNANDWP : MC_15<"lnandwp">;

// 2 insns: ['LORWP', 'LORWP']
defm LORWP : MC_15<"lorwp">;

// 2 insns: ['LNORWP', 'LNORWP']
defm LNORWP : MC_15<"lnorwp">;

// 2 insns: ['ADDHQ', 'ADDHQ']
defm ADDHQ : MC_14<"addhq">;

// 2 insns: ['SBFHQ', 'SBFHQ']
defm SBFHQ : MC_14<"sbfhq">;

// 2 insns: ['ABDHQ', 'ABDHQ']
defm ABDHQ : MC_15<"abdhq">;

// 2 insns: ['MINHQ', 'MINHQ']
defm MINHQ : MC_14<"minhq">;

// 2 insns: ['MINUHQ', 'MINUHQ']
defm MINUHQ : MC_14<"minuhq">;

// 2 insns: ['MAXHQ', 'MAXHQ']
defm MAXHQ : MC_14<"maxhq">;

// 2 insns: ['MAXUHQ', 'MAXUHQ']
defm MAXUHQ : MC_14<"maxuhq">;

// 2 insns: ['ADDCHCP', 'ADDCHCP']
defm ADDCHCP : MC_15<"addchcp">;

// 2 insns: ['SBFCHCP', 'SBFCHCP']
defm SBFCHCP : MC_15<"sbfchcp">;

// 2 insns: ['ADDSHQ', 'ADDSHQ']
defm ADDSHQ : MC_15<"addshq">;

// 2 insns: ['SBFSHQ', 'SBFSHQ']
defm SBFSHQ : MC_15<"sbfshq">;

// 2 insns: ['ADDX2HQ', 'ADDX2HQ']
defm ADDX2HQ : MC_15<"addx2hq">;

// 2 insns: ['ADDX4HQ', 'ADDX4HQ']
defm ADDX4HQ : MC_15<"addx4hq">;

// 2 insns: ['ADDX8HQ', 'ADDX8HQ']
defm ADDX8HQ : MC_15<"addx8hq">;

// 2 insns: ['ADDX16HQ', 'ADDX16HQ']
defm ADDX16HQ : MC_15<"addx16hq">;

// 2 insns: ['SBFX2HQ', 'SBFX2HQ']
defm SBFX2HQ : MC_15<"sbfx2hq">;

// 2 insns: ['SBFX4HQ', 'SBFX4HQ']
defm SBFX4HQ : MC_15<"sbfx4hq">;

// 2 insns: ['SBFX8HQ', 'SBFX8HQ']
defm SBFX8HQ : MC_15<"sbfx8hq">;

// 2 insns: ['SBFX16HQ', 'SBFX16HQ']
defm SBFX16HQ : MC_15<"sbfx16hq">;

// 2 insns: ['AVGHQ', 'AVGHQ']
defm AVGHQ : MC_15<"avghq">;

// 2 insns: ['AVGUHQ', 'AVGUHQ']
defm AVGUHQ : MC_15<"avguhq">;

// 2 insns: ['AVGRHQ', 'AVGRHQ']
defm AVGRHQ : MC_15<"avgrhq">;

// 2 insns: ['AVGRUHQ', 'AVGRUHQ']
defm AVGRUHQ : MC_15<"avgruhq">;

// 2 insns: ['LANDHQ', 'LANDHQ']
defm LANDHQ : MC_15<"landhq">;

// 2 insns: ['LNANDHQ', 'LNANDHQ']
defm LNANDHQ : MC_15<"lnandhq">;

// 2 insns: ['LORHQ', 'LORHQ']
defm LORHQ : MC_15<"lorhq">;

// 2 insns: ['LNORHQ', 'LNORHQ']
defm LNORHQ : MC_15<"lnorhq">;

// 2 insns: ['ADDX2WD', 'ADDX2WD']
defm ADDX2WD : MC_11<"addx2wd">;

// 2 insns: ['ADDX4WD', 'ADDX4WD']
defm ADDX4WD : MC_11<"addx4wd">;

// 2 insns: ['ADDX8WD', 'ADDX8WD']
defm ADDX8WD : MC_11<"addx8wd">;

// 2 insns: ['ADDX16WD', 'ADDX16WD']
defm ADDX16WD : MC_11<"addx16wd">;

// 2 insns: ['SBFX2WD', 'SBFX2WD']
defm SBFX2WD : MC_11<"sbfx2wd">;

// 2 insns: ['SBFX4WD', 'SBFX4WD']
defm SBFX4WD : MC_11<"sbfx4wd">;

// 2 insns: ['SBFX8WD', 'SBFX8WD']
defm SBFX8WD : MC_11<"sbfx8wd">;

// 2 insns: ['SBFX16WD', 'SBFX16WD']
defm SBFX16WD : MC_11<"sbfx16wd">;

// 2 insns: ['ADDX2UWD', 'ADDX2UWD']
defm ADDX2UWD : MC_11<"addx2uwd">;

// 2 insns: ['ADDX4UWD', 'ADDX4UWD']
defm ADDX4UWD : MC_11<"addx4uwd">;

// 2 insns: ['ADDX8UWD', 'ADDX8UWD']
defm ADDX8UWD : MC_11<"addx8uwd">;

// 2 insns: ['ADDX16UWD', 'ADDX16UWD']
defm ADDX16UWD : MC_11<"addx16uwd">;

// 2 insns: ['SBFX2UWD', 'SBFX2UWD']
defm SBFX2UWD : MC_11<"sbfx2uwd">;

// 2 insns: ['SBFX4UWD', 'SBFX4UWD']
defm SBFX4UWD : MC_11<"sbfx4uwd">;

// 2 insns: ['SBFX8UWD', 'SBFX8UWD']
defm SBFX8UWD : MC_11<"sbfx8uwd">;

// 2 insns: ['SBFX16UWD', 'SBFX16UWD']
defm SBFX16UWD : MC_11<"sbfx16uwd">;

// 1 insns: ['ADDCD']
let Uses=[CS], Defs=[CS] in
def ADDCD : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "addcd $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['SBFCD']
let Uses=[CS], Defs=[CS] in
def SBFCD : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "sbfcd $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['ADDCID']
let Uses=[CS], Defs=[CS] in
def ADDCID : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "addcid $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['SBFCID']
let Uses=[CS], Defs=[CS] in
def SBFCID : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "sbfcid $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['FNEGD']
def FNEGD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fnegd $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['FABSD']
def FABSD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fabsd $a1 = $a2",
   [(set f64:$a1, (fabs f64:$a2))],
   __UNKNOWN_ITIN__>;

// 1 insns: ['FSINVD']
let Uses=[CS], Defs=[CS] in
def FSINVD : SILENT2_REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SilentMod:$a1),
   "fsinvd$a1 $a2 = $a3",
   [ ]>;

// 1 insns: ['FSISRD']
def FSISRD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fsisrd $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['FWIDENLWD']
let Defs=[CS] in
def FWIDENLWD : SILENT2_REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SilentMod:$a1),
   "fwidenlwd$a1 $a2 = $a3",
   [/* no direct match, see K1CFloatingPoint.td */]>;

// 1 insns: ['FWIDENMWD']
let Uses=[CS], Defs=[CS] in
def FWIDENMWD : SILENT2_REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SilentMod:$a1),
   "fwidenmwd$a1 $a2 = $a3",
   [ ]>;

// 1 insns: ['FNARROWDW']
let Defs=[CS] in
def FNARROWDW : ROUNDING2_SILENT2_REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a3), (ins SingleReg:$a4, RoundingMod:$a1, SilentMod:$a2),
   "fnarrowdw$a1$a2 $a3 = $a4",
   [/* no direct match, see K1CFloatingPoint.td */],
   __UNKNOWN_ITIN__>;

// 1 insns: ['FNEGW']
def FNEGW : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fnegw $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['FABSW']
def FABSW : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fabsw $a1 = $a2",
   [(set f32:$a1, (fabs f32:$a2))],
   __UNKNOWN_ITIN__>;

// 1 insns: ['FINVW']
let Uses=[CS], Defs=[CS] in
def FINVW : ROUNDING2_SILENT2_REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a3), (ins SingleReg:$a4, RoundingMod:$a1, SilentMod:$a2),
   "finvw$a1$a2 $a3 = $a4",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['FISRW']
let Uses=[CS], Defs=[CS] in
def FISRW : ROUNDING2_SILENT2_REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a3), (ins SingleReg:$a4, RoundingMod:$a1, SilentMod:$a2),
   "fisrw$a1$a2 $a3 = $a4",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['FSINVW']
let Uses=[CS], Defs=[CS] in
def FSINVW : SILENT2_REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SilentMod:$a1),
   "fsinvw$a1 $a2 = $a3",
   [ ]>;

// 1 insns: ['FSISRW']
def FSISRW : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fsisrw $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['FWIDENLHW']
let Defs=[CS] in
def FWIDENLHW : SILENT2_REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SilentMod:$a1),
   "fwidenlhw$a1 $a2 = $a3",
   [/* no direct match, see K1CFloatingPoint.td */]>;

// 1 insns: ['FWIDENMHW']
let Uses=[CS], Defs=[CS] in
def FWIDENMHW : SILENT2_REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SilentMod:$a1),
   "fwidenmhw$a1 $a2 = $a3",
   [ ]>;

// 1 insns: ['FNARROWWH']
let Defs=[CS] in
def FNARROWWH : ROUNDING2_SILENT2_REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a3), (ins SingleReg:$a4, RoundingMod:$a1, SilentMod:$a2),
   "fnarrowwh$a1$a2 $a3 = $a4",
   [/* no direct match, see K1CFloatingPoint.td */],
   __UNKNOWN_ITIN__>;

// 1 insns: ['FNEGWP']
def FNEGWP : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fnegwp $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['FABSWP']
def FABSWP : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fabswp $a1 = $a2",
   [(set v2f32:$a1, (fabs v2f32:$a2))],
   __UNKNOWN_ITIN__>;

// 1 insns: ['FSINVWP']
let Uses=[CS], Defs=[CS] in
def FSINVWP : SILENT2_REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SilentMod:$a1),
   "fsinvwp$a1 $a2 = $a3",
   [ ]>;

// 1 insns: ['FSISRWP']
def FSISRWP : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fsisrwp $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['FWIDENLHWP']
let Uses=[CS], Defs=[CS] in
def FWIDENLHWP : SILENT2_REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SilentMod:$a1),
   "fwidenlhwp$a1 $a2 = $a3",
   [ ]>;

// 1 insns: ['FWIDENMHWP']
let Uses=[CS], Defs=[CS] in
def FWIDENMHWP : SILENT2_REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SilentMod:$a1),
   "fwidenmhwp$a1 $a2 = $a3",
   [ ]>;

// 1 insns: ['FNARROWDWP']
let Uses=[CS], Defs=[CS] in
def FNARROWDWP : ROUNDING2_SILENT2_REGISTERW_REGISTERP_SIMPLE
  <(outs SingleReg:$a3), (ins PairedReg:$a4, RoundingMod:$a1, SilentMod:$a2),
   "fnarrowdwp$a1$a2 $a3 = $a4",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['FNEGHQ']
def FNEGHQ : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fneghq $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['FABSHQ']
def FABSHQ : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fabshq $a1 = $a2",
   [(set f16:$a1, (fabs f16:$a2))],
   __UNKNOWN_ITIN__>;

// 1 insns: ['FNARROWWHQ']
let Uses=[CS], Defs=[CS] in
def FNARROWWHQ : ROUNDING2_SILENT2_REGISTERW_REGISTERP_SIMPLE
  <(outs SingleReg:$a3), (ins PairedReg:$a4, RoundingMod:$a1, SilentMod:$a2),
   "fnarrowwhq$a1$a2 $a3 = $a4",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['INSF']
def INSF : REGISTERW_REGISTERZ_STOPBIT2_STOPBIT4_STARTBIT_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a11, SingleReg:$a2, Unsigned6:$a3, Unsigned6:$a4),
   "insf $a1 = $a2, $a3, $a4",
   [ ]>;

// 1 insns: ['EXTFZ']
def EXTFZ : REGISTERW_REGISTERZ_STOPBIT2_STOPBIT4_STARTBIT_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, Unsigned6:$a3, Unsigned6:$a4),
   "extfz $a1 = $a2, $a3, $a4",
   [ ]>;

// 1 insns: ['EXTFS']
def EXTFS : REGISTERW_REGISTERZ_STOPBIT2_STOPBIT4_STARTBIT_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, Unsigned6:$a3, Unsigned6:$a4),
   "extfs $a1 = $a2, $a3, $a4",
   [ ]>;

// 1 insns: ['CLRF']
def CLRF : REGISTERW_REGISTERZ_STOPBIT2_STOPBIT4_STARTBIT_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, Unsigned6:$a3, Unsigned6:$a4),
   "clrf $a1 = $a2, $a3, $a4",
   [ ]>;

// 2 insns: ['SATD', 'SATD']
defm SATD : MC_16<"satd">;

// 2 insns: ['SATUD', 'SATUD']
defm SATUD : MC_16<"satud">;

// 2 insns: ['SRSD', 'SRSD']
defm SRSD : MC_16<"srsd">;

// 2 insns: ['SLLD', 'SLLD']
defm SLLD : MC_17<"slld">;

// 2 insns: ['SRAD', 'SRAD']
defm SRAD : MC_17<"srad">;

// 2 insns: ['SRLD', 'SRLD']
defm SRLD : MC_17<"srld">;

// 2 insns: ['SLSD', 'SLSD']
defm SLSD : MC_16<"slsd">;

// 2 insns: ['SRSW', 'SRSW']
defm SRSW : MC_16<"srsw">;

// 2 insns: ['SLLW', 'SLLW']
defm SLLW : MC_17<"sllw">;

// 2 insns: ['SRAW', 'SRAW']
defm SRAW : MC_17<"sraw">;

// 2 insns: ['SRLW', 'SRLW']
defm SRLW : MC_17<"srlw">;

// 2 insns: ['SLSW', 'SLSW']
defm SLSW : MC_16<"slsw">;

// 2 insns: ['ROLW', 'ROLW']
defm ROLW : MC_16<"rolw">;

// 2 insns: ['RORW', 'RORW']
defm RORW : MC_16<"rorw">;

// 2 insns: ['SRSWPS', 'SRSWPS']
defm SRSWPS : MC_16<"srswps">;

// 2 insns: ['SLLWPS', 'SLLWPS']
defm SLLWPS : MC_16<"sllwps">;

// 2 insns: ['SRAWPS', 'SRAWPS']
defm SRAWPS : MC_16<"srawps">;

// 2 insns: ['SRLWPS', 'SRLWPS']
defm SRLWPS : MC_16<"srlwps">;

// 2 insns: ['SLSWPS', 'SLSWPS']
defm SLSWPS : MC_16<"slswps">;

// 2 insns: ['ROLWPS', 'ROLWPS']
defm ROLWPS : MC_16<"rolwps">;

// 2 insns: ['RORWPS', 'RORWPS']
defm RORWPS : MC_16<"rorwps">;

// 2 insns: ['SRSHQS', 'SRSHQS']
defm SRSHQS : MC_16<"srshqs">;

// 2 insns: ['SLLHQS', 'SLLHQS']
defm SLLHQS : MC_16<"sllhqs">;

// 2 insns: ['SRAHQS', 'SRAHQS']
defm SRAHQS : MC_16<"srahqs">;

// 2 insns: ['SRLHQS', 'SRLHQS']
defm SRLHQS : MC_16<"srlhqs">;

// 2 insns: ['SLSHQS', 'SLSHQS']
defm SLSHQS : MC_16<"slshqs">;

// 4 insns: ['COMPD', 'COMPD', 'COMPD', 'COMPD']
defm COMPD : MC_18<"compd">;

// 2 insns: ['COMPW', 'COMPW']
defm COMPW : MC_19<"compw">;

// 1 insns: ['COMPWD']
def COMPWD : COMPARISON_REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, ComparisonMod:$a1),
   "compwd$a1 $a2 = $a3, $a4",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['COMPUWD']
def COMPUWD : COMPARISON_REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, ComparisonMod:$a1),
   "compuwd$a1 $a2 = $a3, $a4",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['COMPNWP']
def COMPNWP : COMPARISON_REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, ComparisonMod:$a1),
   "compnwp$a1 $a2 = $a3, $a4",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['COMPNHQ']
def COMPNHQ : COMPARISON_REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, ComparisonMod:$a1),
   "compnhq$a1 $a2 = $a3, $a4",
   [ ],
   __UNKNOWN_ITIN__>;

// 4 insns: ['CMOVED', 'CMOVED', 'CMOVED', 'CMOVED']
defm CMOVED : MC_1A<"cmoved">;

// 1 insns: ['CMOVEWP']
def CMOVEWP : SIMDCOND_REGISTERZ_REGISTERW_REGISTERY_SIMPLE
  <(outs SingleReg:$a3), (ins SingleReg:$a2, SingleReg:$a33, SingleReg:$a4, SimplecondMod:$a1),
   "cmovewp$a1 $a2? $a3 = $a4",
   [ ]>;

// 3 insns: ['MAKE', 'MAKE', 'MAKE']
defm MAKE : MC_1B<"make">;

// 3 insns: ['PCREL', 'PCREL', 'PCREL']
defm PCREL : MC_1C<"pcrel">;

// 1 insns: ['CLZW']
def CLZW : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "clzw $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['CLSW']
def CLSW : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "clsw $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['CBSW']
def CBSW : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "cbsw $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['CTZW']
def CTZW : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "ctzw $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['CLZD']
def CLZD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "clzd $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['CLSD']
def CLSD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "clsd $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['CBSD']
def CBSD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "cbsd $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['CTZD']
def CTZD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "ctzd $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['CLZWP']
def CLZWP : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "clzwp $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['CLSWP']
def CLSWP : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "clswp $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['CBSWP']
def CBSWP : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "cbswp $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['CTZWP']
def CTZWP : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "ctzwp $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['SXLHWP']
def SXLHWP : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "sxlhwp $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['SXMHWP']
def SXMHWP : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "sxmhwp $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['SXLBHQ']
def SXLBHQ : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "sxlbhq $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['SXMBHQ']
def SXMBHQ : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "sxmbhq $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['CMOVEHQ']
def CMOVEHQ : SIMDCOND_REGISTERZ_REGISTERW_REGISTERY_SIMPLE
  <(outs SingleReg:$a3), (ins SingleReg:$a2, SingleReg:$a33, SingleReg:$a4, SimplecondMod:$a1),
   "cmovehq$a1 $a2? $a3 = $a4",
   [ ]>;

// 2 insns: ['FCOMPW', 'FCOMPW']
defm FCOMPW : MC_1DW<"fcompw">;

// 2 insns: ['FCOMPD', 'FCOMPD']
defm FCOMPD : MC_1DD<"fcompd">;

// 1 insns: ['FCOMPNWP']
def FCOMPNWP : FLOATCOMP_REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, FloatcompMod:$a1),
   "fcompnwp$a1 $a2 = $a3, $a4",
   [ ]>;

// 1 insns: ['FCOMPNHQ']
def FCOMPNHQ : FLOATCOMP_REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, FloatcompMod:$a1),
   "fcompnhq$a1 $a2 = $a3, $a4",
   [/* no direct match, see K1CFloatingPoint.td */]>;

// 1 insns: ['FSDIVD']
let Uses=[CS], Defs=[CS] in
def FSDIVD : SILENT2_REGISTERW_REGISTERP_SIMPLE
  <(outs SingleReg:$a2), (ins PairedReg:$a3, SilentMod:$a1),
   "fsdivd$a1 $a2 = $a3",
   [ ]>;

// 1 insns: ['FCDIVD']
let Uses=[CS], Defs=[CS] in
def FCDIVD : SILENT2_REGISTERW_REGISTERP_SIMPLE
  <(outs SingleReg:$a2), (ins PairedReg:$a3, SilentMod:$a1),
   "fcdivd$a1 $a2 = $a3",
   [ ]>;

// 1 insns: ['FSDIVW']
let Uses=[CS], Defs=[CS] in
def FSDIVW : SILENT2_REGISTERW_REGISTERP_SIMPLE
  <(outs SingleReg:$a2), (ins PairedReg:$a3, SilentMod:$a1),
   "fsdivw$a1 $a2 = $a3",
   [ ]>;

// 1 insns: ['FCDIVW']
let Uses=[CS], Defs=[CS] in
def FCDIVW : SILENT2_REGISTERW_REGISTERP_SIMPLE
  <(outs SingleReg:$a2), (ins PairedReg:$a3, SilentMod:$a1),
   "fcdivw$a1 $a2 = $a3",
   [ ]>;

// 1 insns: ['FSDIVWP']
let Uses=[CS], Defs=[CS] in
def FSDIVWP : SILENT2_REGISTERW_REGISTERP_SIMPLE
  <(outs SingleReg:$a2), (ins PairedReg:$a3, SilentMod:$a1),
   "fsdivwp$a1 $a2 = $a3",
   [ ]>;

// 1 insns: ['FCDIVWP']
let Uses=[CS], Defs=[CS] in
def FCDIVWP : SILENT2_REGISTERW_REGISTERP_SIMPLE
  <(outs SingleReg:$a2), (ins PairedReg:$a3, SilentMod:$a1),
   "fcdivwp$a1 $a2 = $a3",
   [ ]>;

// 1 insns: ['FMIND']
def FMIND : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "fmind $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['FMAXD']
def FMAXD : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "fmaxd $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['FMINW']
def FMINW : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "fminw $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['FMAXW']
def FMAXW : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "fmaxw $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['FMINWP']
def FMINWP : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "fminwp $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['FMAXWP']
def FMAXWP : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "fmaxwp $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['FMINHQ']
def FMINHQ : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "fminhq $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['FMAXHQ']
def FMAXHQ : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "fmaxhq $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['FLOATD']
def FLOATD : ROUNDING_SILENT_REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "floatd$a1$a2 $a3 = $a4, $a5",
   [ ]>;

// 1 insns: ['FLOATWP']
def FLOATWP : ROUNDING_SILENT_REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "floatwp$a1$a2 $a3 = $a4, $a5",
   [ ]>;

// 1 insns: ['FLOATW']
def FLOATW : ROUNDING_SILENT_REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "floatw$a1$a2 $a3 = $a4, $a5",
   [ ]>;

// 1 insns: ['FLOATUD']
def FLOATUD : ROUNDING_SILENT_REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "floatud$a1$a2 $a3 = $a4, $a5",
   [ ]>;

// 1 insns: ['FLOATUWP']
def FLOATUWP : ROUNDING_SILENT_REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "floatuwp$a1$a2 $a3 = $a4, $a5",
   [ ]>;

// 1 insns: ['FLOATUW']
def FLOATUW : ROUNDING_SILENT_REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "floatuw$a1$a2 $a3 = $a4, $a5",
   [ ]>;

// 1 insns: ['FIXEDD']
def FIXEDD : ROUNDING_SILENT_REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fixedd$a1$a2 $a3 = $a4, $a5",
   [ ]>;

// 1 insns: ['FIXEDWP']
def FIXEDWP : ROUNDING_SILENT_REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fixedwp$a1$a2 $a3 = $a4, $a5",
   [ ]>;

// 1 insns: ['FIXEDW']
def FIXEDW : ROUNDING_SILENT_REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fixedw$a1$a2 $a3 = $a4, $a5",
   [ ]>;

// 1 insns: ['FIXEDUD']
def FIXEDUD : ROUNDING_SILENT_REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fixedud$a1$a2 $a3 = $a4, $a5",
   [ ]>;

// 1 insns: ['FIXEDUWP']
def FIXEDUWP : ROUNDING_SILENT_REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fixeduwp$a1$a2 $a3 = $a4, $a5",
   [ ]>;

// 1 insns: ['FIXEDUW']
def FIXEDUW : ROUNDING_SILENT_REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fixeduw$a1$a2 $a3 = $a4, $a5",
   [ ]>;

// 4 insns: ['MADDD', 'MADDD', 'MADDD', 'MADDD']
defm MADDD : MC_1E<"maddd">;

// 1 insns: ['MSBFD']
def MSBFD : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a11, SingleReg:$a2, SingleReg:$a3),
   "msbfd $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 4 insns: ['MADDWP', 'MADDWP', 'MADDWP', 'MADDWP']
defm MADDWP : MC_1E<"maddwp">;

// 1 insns: ['MSBFWP']
def MSBFWP : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a11, SingleReg:$a2, SingleReg:$a3),
   "msbfwp $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 4 insns: ['MADDHQ', 'MADDHQ', 'MADDHQ', 'MADDHQ']
defm MADDHQ : MC_1E<"maddhq">;

// 1 insns: ['MSBFHQ']
def MSBFHQ : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a11, SingleReg:$a2, SingleReg:$a3),
   "msbfhq $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['MADDHWQ']
def MADDHWQ : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, SingleReg:$a3),
   "maddhwq $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['MSBFHWQ']
def MSBFHWQ : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, SingleReg:$a3),
   "msbfhwq $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['MADDUHWQ']
def MADDUHWQ : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, SingleReg:$a3),
   "madduhwq $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['MSBFUHWQ']
def MSBFUHWQ : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, SingleReg:$a3),
   "msbfuhwq $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['MADDSUHWQ']
def MADDSUHWQ : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, SingleReg:$a3),
   "maddsuhwq $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['MSBFSUHWQ']
def MSBFSUHWQ : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, SingleReg:$a3),
   "msbfsuhwq $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 4 insns: ['MADDDT', 'MADDDT', 'MADDDT', 'MADDDT']
defm MADDDT : MC_1F<"madddt">;

// 4 insns: ['MADDUDT', 'MADDUDT', 'MADDUDT', 'MADDUDT']
defm MADDUDT : MC_1F<"maddudt">;

// 4 insns: ['MADDSUDT', 'MADDSUDT', 'MADDSUDT', 'MADDSUDT']
defm MADDSUDT : MC_1F<"maddsudt">;

// 4 insns: ['MADDUZDT', 'MADDUZDT', 'MADDUZDT', 'MADDUZDT']
defm MADDUZDT : MC_1F<"madduzdt">;

// 1 insns: ['MSBFDT']
def MSBFDT : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, SingleReg:$a3),
   "msbfdt $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['MSBFUDT']
def MSBFUDT : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, SingleReg:$a3),
   "msbfudt $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['MSBFSUDT']
def MSBFSUDT : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, SingleReg:$a3),
   "msbfsudt $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['MSBFUZDT']
def MSBFUZDT : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, SingleReg:$a3),
   "msbfuzdt $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 4 insns: ['MULD', 'MULD', 'MULD', 'MULD']
defm MULD : MC_20<"muld">;

// 4 insns: ['MULDT', 'MULDT', 'MULDT', 'MULDT']
defm MULDT : MC_21<"muldt">;

// 4 insns: ['MULUDT', 'MULUDT', 'MULUDT', 'MULUDT']
defm MULUDT : MC_21<"muludt">;

// 4 insns: ['MULSUDT', 'MULSUDT', 'MULSUDT', 'MULSUDT']
defm MULSUDT : MC_21<"mulsudt">;

// 4 insns: ['CMULDT', 'CMULDT', 'CMULDT', 'CMULDT']
defm CMULDT : MC_21<"cmuldt">;

// 1 insns: ['CMULXDT']
def CMULXDT : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, SingleReg:$a3),
   "cmulxdt $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['CMULGLXDT']
def CMULGLXDT : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, SingleReg:$a3),
   "cmulglxdt $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['CMULGMXDT']
def CMULGMXDT : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, SingleReg:$a3),
   "cmulgmxdt $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['CMULGHXDT']
def CMULGHXDT : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, SingleReg:$a3),
   "cmulghxdt $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 2 insns: ['CRCBELMW', 'CRCBELMW']
defm CRCBELMW : MC_22<"crcbelmw">;

// 2 insns: ['CRCBELLW', 'CRCBELLW']
defm CRCBELLW : MC_22<"crcbellw">;

// 2 insns: ['CRCLELMW', 'CRCLELMW']
defm CRCLELMW : MC_22<"crclelmw">;

// 2 insns: ['CRCLELLW', 'CRCLELLW']
defm CRCLELLW : MC_22<"crclellw">;

// 4 insns: ['DOT2WD', 'DOT2WD', 'DOT2WD', 'DOT2WD']
defm DOT2WD : MC_20<"dot2wd">;

// 4 insns: ['DOT2UWD', 'DOT2UWD', 'DOT2UWD', 'DOT2UWD']
defm DOT2UWD : MC_20<"dot2uwd">;

// 4 insns: ['DOT2SUWD', 'DOT2SUWD', 'DOT2SUWD', 'DOT2SUWD']
defm DOT2SUWD : MC_20<"dot2suwd">;

// 4 insns: ['DOT2W', 'DOT2W', 'DOT2W', 'DOT2W']
defm DOT2W : MC_20<"dot2w">;

// 1 insns: ['DOT2WDP']
def DOT2WDP : REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <(outs PairedReg:$a1), (ins PairedReg:$a2, PairedReg:$a3),
   "dot2wdp $a1 = $a2, $a3",
   [ ]>;

// 1 insns: ['DOT2UWDP']
def DOT2UWDP : REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <(outs PairedReg:$a1), (ins PairedReg:$a2, PairedReg:$a3),
   "dot2uwdp $a1 = $a2, $a3",
   [ ]>;

// 1 insns: ['DOT2SUWDP']
def DOT2SUWDP : REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <(outs PairedReg:$a1), (ins PairedReg:$a2, PairedReg:$a3),
   "dot2suwdp $a1 = $a2, $a3",
   [ ]>;

// 1 insns: ['MULWQ']
def MULWQ : REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <(outs PairedReg:$a1), (ins PairedReg:$a2, PairedReg:$a3),
   "mulwq $a1 = $a2, $a3",
   [ ]>;

// 1 insns: ['DOT2WZP']
def DOT2WZP : REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <(outs PairedReg:$a1), (ins PairedReg:$a2, PairedReg:$a3),
   "dot2wzp $a1 = $a2, $a3",
   [ ]>;

// 4 insns: ['MULWP', 'MULWP', 'MULWP', 'MULWP']
defm MULWP : MC_20<"mulwp">;

// 4 insns: ['MULHQ', 'MULHQ', 'MULHQ', 'MULHQ']
defm MULHQ : MC_20<"mulhq">;

// 4 insns: ['MULWC', 'MULWC', 'MULWC', 'MULWC']
defm MULWC : MC_20<"mulwc">;

// 1 insns: ['MULCWC']
def MULCWC : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "mulcwc $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['MULWDC']
def MULWDC : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "mulwdc $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['MULCWDC']
def MULCWDC : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "mulcwdc $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['MULHWQ']
def MULHWQ : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "mulhwq $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['MULUHWQ']
def MULUHWQ : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "muluhwq $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['MULSUHWQ']
def MULSUHWQ : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "mulsuhwq $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 2 insns: ['MADDWD', 'MADDWD']
defm MADDWD : MC_23<"maddwd">;

// 2 insns: ['MADDUWD', 'MADDUWD']
defm MADDUWD : MC_23<"madduwd">;

// 2 insns: ['MADDSUWD', 'MADDSUWD']
defm MADDSUWD : MC_23<"maddsuwd">;

// 2 insns: ['MADDW', 'MADDW']
defm MADDW : MC_23<"maddw">;

// 2 insns: ['MSBFWD', 'MSBFWD']
defm MSBFWD : MC_23<"msbfwd">;

// 2 insns: ['MSBFUWD', 'MSBFUWD']
defm MSBFUWD : MC_23<"msbfuwd">;

// 2 insns: ['MSBFSUWD', 'MSBFSUWD']
defm MSBFSUWD : MC_23<"msbfsuwd">;

// 2 insns: ['MSBFW', 'MSBFW']
defm MSBFW : MC_23<"msbfw">;

// 2 insns: ['MULWD', 'MULWD']
defm MULWD : MC_22<"mulwd">;

// 2 insns: ['MULUWD', 'MULUWD']
defm MULUWD : MC_22<"muluwd">;

// 2 insns: ['MULSUWD', 'MULSUWD']
defm MULSUWD : MC_22<"mulsuwd">;

// 2 insns: ['MULW', 'MULW']
defm MULW : MC_22<"mulw">;

// 1 insns: ['MADDWDP']
def MADDWDP : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, SingleReg:$a3),
   "maddwdp $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['MADDUWDP']
def MADDUWDP : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, SingleReg:$a3),
   "madduwdp $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['MADDSUWDP']
def MADDSUWDP : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, SingleReg:$a3),
   "maddsuwdp $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['MM2AWQ']
def MM2AWQ : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, SingleReg:$a3),
   "mm2awq $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['MSBFWDP']
def MSBFWDP : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, SingleReg:$a3),
   "msbfwdp $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['MSBFUWDP']
def MSBFUWDP : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, SingleReg:$a3),
   "msbfuwdp $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['MSBFSUWDP']
def MSBFSUWDP : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, SingleReg:$a3),
   "msbfsuwdp $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['MM2SWQ']
def MM2SWQ : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins PairedReg:$a11, SingleReg:$a2, SingleReg:$a3),
   "mm2swq $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['MULWDP']
def MULWDP : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "mulwdp $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['MULUWDP']
def MULUWDP : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "muluwdp $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['MULSUWDP']
def MULSUWDP : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "mulsuwdp $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['MM2WQ']
def MM2WQ : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "mm2wq $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 4 insns: ['FFMAD', 'FFMAD', 'FFMAD', 'FFMAD']
defm FFMAD : MC_24<"ffmad">;

// 4 insns: ['FFMAWP', 'FFMAWP', 'FFMAWP', 'FFMAWP']
defm FFMAWP : MC_24<"ffmawp">;

// 4 insns: ['FFMAHQ', 'FFMAHQ', 'FFMAHQ', 'FFMAHQ']
defm FFMAHQ : MC_24<"ffmahq">;

// 4 insns: ['FFMSD', 'FFMSD', 'FFMSD', 'FFMSD']
defm FFMSD : MC_24<"ffmsd">;

// 4 insns: ['FFMSWP', 'FFMSWP', 'FFMSWP', 'FFMSWP']
defm FFMSWP : MC_24<"ffmswp">;

// 4 insns: ['FFMSHQ', 'FFMSHQ', 'FFMSHQ', 'FFMSHQ']
defm FFMSHQ : MC_24<"ffmshq">;

// 4 insns: ['FMULD', 'FMULD', 'FMULD', 'FMULD']
defm FMULD : MC_25D<"fmuld", fmul>;

// 4 insns: ['FMULWP', 'FMULWP', 'FMULWP', 'FMULWP']
defm FMULWP : MC_25<"fmulwp">;

// 4 insns: ['FMULHQ', 'FMULHQ', 'FMULHQ', 'FMULHQ']
defm FMULHQ : MC_25H<"fmulhq", fmul>;

// 4 insns: ['FMULWDP', 'FMULWDP', 'FMULWDP', 'FMULWDP']
defm FMULWDP : MC_26<"fmulwdp">;

// 4 insns: ['FMULHWQ', 'FMULHWQ', 'FMULHWQ', 'FMULHWQ']
defm FMULHWQ : MC_26<"fmulhwq">;

// 1 insns: ['FMULWQ']
def FMULWQ : ROUNDING_SILENT_REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <(outs PairedReg:$a3), (ins PairedReg:$a4, PairedReg:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fmulwq$a1$a2 $a3 = $a4, $a5",
   [ ]>;

// 4 insns: ['FMULWC', 'FMULWC', 'FMULWC', 'FMULWC']
defm FMULWC : MC_25<"fmulwc">;

// 4 insns: ['FMULWDC', 'FMULWDC', 'FMULWDC', 'FMULWDC']
defm FMULWDC : MC_26<"fmulwdc">;

// 4 insns: ['FMULCWC', 'FMULCWC', 'FMULCWC', 'FMULCWC']
defm FMULCWC : MC_25<"fmulcwc">;

// 4 insns: ['FMULCWDC', 'FMULCWDC', 'FMULCWDC', 'FMULCWDC']
defm FMULCWDC : MC_26<"fmulcwdc">;

// 4 insns: ['FADDD', 'FADDD', 'FADDD', 'FADDD']
defm FADDD : MC_25D<"faddd", fadd>;

// 4 insns: ['FADDWP', 'FADDWP', 'FADDWP', 'FADDWP']
defm FADDWP : MC_25<"faddwp">;

// 4 insns: ['FADDHQ', 'FADDHQ', 'FADDHQ', 'FADDHQ']
defm FADDHQ : MC_25H<"faddhq">;

// 1 insns: ['FADDDP']
def FADDDP : ROUNDING_SILENT_REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <(outs PairedReg:$a3), (ins PairedReg:$a4, PairedReg:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fadddp$a1$a2 $a3 = $a4, $a5",
   [ ]>;

// 1 insns: ['FADDWQ']
def FADDWQ : ROUNDING_SILENT_REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <(outs PairedReg:$a3), (ins PairedReg:$a4, PairedReg:$a5, RoundingMod:$a1, SilentMod:$a2),
   "faddwq$a1$a2 $a3 = $a4, $a5",
   [ ]>;

// 4 insns: ['FADDCWC', 'FADDCWC', 'FADDCWC', 'FADDCWC']
defm FADDCWC : MC_25<"faddcwc">;

// 1 insns: ['FADDCDC']
def FADDCDC : ROUNDING_SILENT_REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <(outs PairedReg:$a3), (ins PairedReg:$a4, PairedReg:$a5, RoundingMod:$a1, SilentMod:$a2),
   "faddcdc$a1$a2 $a3 = $a4, $a5",
   [ ]>;

// 1 insns: ['FADDCWCP']
def FADDCWCP : ROUNDING_SILENT_REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <(outs PairedReg:$a3), (ins PairedReg:$a4, PairedReg:$a5, RoundingMod:$a1, SilentMod:$a2),
   "faddcwcp$a1$a2 $a3 = $a4, $a5",
   [ ]>;

// 4 insns: ['FSBFD', 'FSBFD', 'FSBFD', 'FSBFD']
defm FSBFD : MC_25<"fsbfd">;

// 4 insns: ['FSBFWP', 'FSBFWP', 'FSBFWP', 'FSBFWP']
defm FSBFWP : MC_25<"fsbfwp">;

// 4 insns: ['FSBFHQ', 'FSBFHQ', 'FSBFHQ', 'FSBFHQ']
defm FSBFHQ : MC_25<"fsbfhq">;

// 1 insns: ['FSBFDP']
def FSBFDP : ROUNDING_SILENT_REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <(outs PairedReg:$a3), (ins PairedReg:$a4, PairedReg:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fsbfdp$a1$a2 $a3 = $a4, $a5",
   [ ]>;

// 1 insns: ['FSBFWQ']
def FSBFWQ : ROUNDING_SILENT_REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <(outs PairedReg:$a3), (ins PairedReg:$a4, PairedReg:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fsbfwq$a1$a2 $a3 = $a4, $a5",
   [ ]>;

// 4 insns: ['FSBFCWC', 'FSBFCWC', 'FSBFCWC', 'FSBFCWC']
defm FSBFCWC : MC_25<"fsbfcwc">;

// 1 insns: ['FSBFCDC']
def FSBFCDC : ROUNDING_SILENT_REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <(outs PairedReg:$a3), (ins PairedReg:$a4, PairedReg:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fsbfcdc$a1$a2 $a3 = $a4, $a5",
   [ ]>;

// 1 insns: ['FSBFCWCP']
def FSBFCWCP : ROUNDING_SILENT_REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <(outs PairedReg:$a3), (ins PairedReg:$a4, PairedReg:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fsbfcwcp$a1$a2 $a3 = $a4, $a5",
   [ ]>;

// 4 insns: ['FFMAHW', 'FFMAHW', 'FFMAHW', 'FFMAHW']
defm FFMAHW : MC_24<"ffmahw">;

// 4 insns: ['FFMAW', 'FFMAW', 'FFMAW', 'FFMAW']
defm FFMAW : MC_24<"ffmaw">;

// 4 insns: ['FFMAWD', 'FFMAWD', 'FFMAWD', 'FFMAWD']
defm FFMAWD : MC_24<"ffmawd">;

// 4 insns: ['FFMAWDP', 'FFMAWDP', 'FFMAWDP', 'FFMAWDP']
defm FFMAWDP : MC_27<"ffmawdp">;

// 4 insns: ['FFMAHWQ', 'FFMAHWQ', 'FFMAHWQ', 'FFMAHWQ']
defm FFMAHWQ : MC_27<"ffmahwq">;

// 4 insns: ['FFMSHW', 'FFMSHW', 'FFMSHW', 'FFMSHW']
defm FFMSHW : MC_24<"ffmshw">;

// 4 insns: ['FFMSW', 'FFMSW', 'FFMSW', 'FFMSW']
defm FFMSW : MC_24<"ffmsw">;

// 4 insns: ['FFMSWD', 'FFMSWD', 'FFMSWD', 'FFMSWD']
defm FFMSWD : MC_24<"ffmswd">;

// 4 insns: ['FFMSWDP', 'FFMSWDP', 'FFMSWDP', 'FFMSWDP']
defm FFMSWDP : MC_27<"ffmswdp">;

// 4 insns: ['FFMSHWQ', 'FFMSHWQ', 'FFMSHWQ', 'FFMSHWQ']
defm FFMSHWQ : MC_27<"ffmshwq">;

// 4 insns: ['FADDW', 'FADDW', 'FADDW', 'FADDW']
defm FADDW : MC_25W<"faddw", fadd>;

// 4 insns: ['FSBFW', 'FSBFW', 'FSBFW', 'FSBFW']
defm FSBFW : MC_25<"fsbfw">;

// 4 insns: ['FMULHW', 'FMULHW', 'FMULHW', 'FMULHW']
defm FMULHW : MC_25<"fmulhw">;

// 4 insns: ['FMULW', 'FMULW', 'FMULW', 'FMULW']
defm FMULW : MC_25W<"fmulw", fmul>;

// 4 insns: ['FMULWD', 'FMULWD', 'FMULWD', 'FMULWD']
defm FMULWD : MC_25<"fmulwd">;

// 4 insns: ['FDOT2W', 'FDOT2W', 'FDOT2W', 'FDOT2W']
defm FDOT2W : MC_25<"fdot2w">;

// 4 insns: ['FDOT2WD', 'FDOT2WD', 'FDOT2WD', 'FDOT2WD']
defm FDOT2WD : MC_25<"fdot2wd">;

// 1 insns: ['FDOT2WZP']
def FDOT2WZP : ROUNDING_SILENT_REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <(outs PairedReg:$a3), (ins PairedReg:$a4, PairedReg:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fdot2wzp$a1$a2 $a3 = $a4, $a5",
   [ ]>;

// 1 insns: ['FDOT2WDP']
def FDOT2WDP : ROUNDING_SILENT_REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <(outs PairedReg:$a3), (ins PairedReg:$a4, PairedReg:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fdot2wdp$a1$a2 $a3 = $a4, $a5",
   [ ]>;

// 1 insns: ['FMM2AWQ']
def FMM2AWQ : ROUNDING_SILENT_REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a3), (ins PairedReg:$a33, SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fmm2awq$a1$a2 $a3 = $a4, $a5",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['FMM2SWQ']
def FMM2SWQ : ROUNDING_SILENT_REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a3), (ins PairedReg:$a33, SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fmm2swq$a1$a2 $a3 = $a4, $a5",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['FMM2WQ']
def FMM2WQ : ROUNDING_SILENT_REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a3), (ins SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fmm2wq$a1$a2 $a3 = $a4, $a5",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['COPYQ']
def COPYQ : REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <(outs PairedReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "copyq $a1 = $a2, $a3",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['COPYO']
def COPYO : REGISTERN_REGISTERQ_SIMPLE
  <(outs QuadReg:$a1), (ins QuadReg:$a2),
   "copyo $a1 = $a2",
   [ ]>;

// 2 insns: ['MOVETQ', 'MOVETQ']
defm MOVETQ : MC_28<"movetq">;

// 4 insns: ['ALIGNO', 'ALIGNO', 'ALIGNO', 'ALIGNO']
defm ALIGNO : MC_29<"aligno">;

// 4 insns: ['ALIGNV', 'ALIGNV', 'ALIGNV', 'ALIGNV']
defm ALIGNV : MC_2A<"alignv">;

// 1 insns: ['MT4X4D']
def MT4X4D : REGISTERAQ_REGISTERBQ_SIMPLE
  <(outs ExtendReg:$a1), (ins ExtendReg:$a2),
   "mt4x4d $a1 = $a2",
   [ ]>;

// 1 insns: ['MM4ABW']
def MM4ABW : REGISTERAP_REGISTERBP_REGISTERC_REGISTERD_SIMPLE
  <(outs WideReg:$a1), (ins WideReg:$a2, AccelReg:$a3, AccelReg:$a4),
   "mm4abw $a1 = $a2, $a3, $a4",
   [ ]>;

// 1 insns: ['MM4AUBW']
def MM4AUBW : REGISTERAP_REGISTERBP_REGISTERC_REGISTERD_SIMPLE
  <(outs WideReg:$a1), (ins WideReg:$a2, AccelReg:$a3, AccelReg:$a4),
   "mm4aubw $a1 = $a2, $a3, $a4",
   [ ]>;

// 1 insns: ['MM4ASUBW']
def MM4ASUBW : REGISTERAP_REGISTERBP_REGISTERC_REGISTERD_SIMPLE
  <(outs WideReg:$a1), (ins WideReg:$a2, AccelReg:$a3, AccelReg:$a4),
   "mm4asubw $a1 = $a2, $a3, $a4",
   [ ]>;

// 1 insns: ['MM4AUSBW']
def MM4AUSBW : REGISTERAP_REGISTERBP_REGISTERC_REGISTERD_SIMPLE
  <(outs WideReg:$a1), (ins WideReg:$a2, AccelReg:$a3, AccelReg:$a4),
   "mm4ausbw $a1 = $a2, $a3, $a4",
   [ ]>;

// 1 insns: ['MM4AHBD0']
def MM4AHBD0 : REGISTERAQ_REGISTERBQ_REGISTERC_REGISTERD_SIMPLE
  <(outs ExtendReg:$a1), (ins ExtendReg:$a2, AccelReg:$a3, AccelReg:$a4),
   "mm4ahbd0 $a1 = $a2, $a3, $a4",
   [ ]>;

// 1 insns: ['MM4AUHBD0']
def MM4AUHBD0 : REGISTERAQ_REGISTERBQ_REGISTERC_REGISTERD_SIMPLE
  <(outs ExtendReg:$a1), (ins ExtendReg:$a2, AccelReg:$a3, AccelReg:$a4),
   "mm4auhbd0 $a1 = $a2, $a3, $a4",
   [ ]>;

// 1 insns: ['MM4ASUHBD0']
def MM4ASUHBD0 : REGISTERAQ_REGISTERBQ_REGISTERC_REGISTERD_SIMPLE
  <(outs ExtendReg:$a1), (ins ExtendReg:$a2, AccelReg:$a3, AccelReg:$a4),
   "mm4asuhbd0 $a1 = $a2, $a3, $a4",
   [ ]>;

// 1 insns: ['MM4AUSHBD0']
def MM4AUSHBD0 : REGISTERAQ_REGISTERBQ_REGISTERC_REGISTERD_SIMPLE
  <(outs ExtendReg:$a1), (ins ExtendReg:$a2, AccelReg:$a3, AccelReg:$a4),
   "mm4aushbd0 $a1 = $a2, $a3, $a4",
   [ ]>;

// 1 insns: ['MM4AHBD1']
def MM4AHBD1 : REGISTERAQ_REGISTERBQ_REGISTERC_REGISTERD_SIMPLE
  <(outs ExtendReg:$a1), (ins ExtendReg:$a2, AccelReg:$a3, AccelReg:$a4),
   "mm4ahbd1 $a1 = $a2, $a3, $a4",
   [ ]>;

// 1 insns: ['MM4AUHBD1']
def MM4AUHBD1 : REGISTERAQ_REGISTERBQ_REGISTERC_REGISTERD_SIMPLE
  <(outs ExtendReg:$a1), (ins ExtendReg:$a2, AccelReg:$a3, AccelReg:$a4),
   "mm4auhbd1 $a1 = $a2, $a3, $a4",
   [ ]>;

// 1 insns: ['MM4ASUHBD1']
def MM4ASUHBD1 : REGISTERAQ_REGISTERBQ_REGISTERC_REGISTERD_SIMPLE
  <(outs ExtendReg:$a1), (ins ExtendReg:$a2, AccelReg:$a3, AccelReg:$a4),
   "mm4asuhbd1 $a1 = $a2, $a3, $a4",
   [ ]>;

// 1 insns: ['MM4AUSHBD1']
def MM4AUSHBD1 : REGISTERAQ_REGISTERBQ_REGISTERC_REGISTERD_SIMPLE
  <(outs ExtendReg:$a1), (ins ExtendReg:$a2, AccelReg:$a3, AccelReg:$a4),
   "mm4aushbd1 $a1 = $a2, $a3, $a4",
   [ ]>;

// 1 insns: ['MM4AHD']
def MM4AHD : REGISTERAQ_REGISTERBQ_REGISTERC_REGISTERD_SIMPLE
  <(outs ExtendReg:$a1), (ins ExtendReg:$a2, AccelReg:$a3, AccelReg:$a4),
   "mm4ahd $a1 = $a2, $a3, $a4",
   [ ]>;

// 1 insns: ['MM4AUHD']
def MM4AUHD : REGISTERAQ_REGISTERBQ_REGISTERC_REGISTERD_SIMPLE
  <(outs ExtendReg:$a1), (ins ExtendReg:$a2, AccelReg:$a3, AccelReg:$a4),
   "mm4auhd $a1 = $a2, $a3, $a4",
   [ ]>;

// 1 insns: ['MM4ASUHD']
def MM4ASUHD : REGISTERAQ_REGISTERBQ_REGISTERC_REGISTERD_SIMPLE
  <(outs ExtendReg:$a1), (ins ExtendReg:$a2, AccelReg:$a3, AccelReg:$a4),
   "mm4asuhd $a1 = $a2, $a3, $a4",
   [ ]>;

// 1 insns: ['MM4AUSHD']
def MM4AUSHD : REGISTERAQ_REGISTERBQ_REGISTERC_REGISTERD_SIMPLE
  <(outs ExtendReg:$a1), (ins ExtendReg:$a2, AccelReg:$a3, AccelReg:$a4),
   "mm4aushd $a1 = $a2, $a3, $a4",
   [ ]>;

// 1 insns: ['FMM4AHW0']
let Uses=[CS], Defs=[CS] in
def FMM4AHW0 : REGISTERA0_REGISTERBP_REGISTERC_REGISTERD_SIMPLE
  <(outs BlockReg0M4:$a1), (ins WideReg:$a2, AccelReg:$a3, AccelReg:$a4),
   "fmm4ahw0 $a1 = $a2, $a3, $a4",
   [ ]>;

// 1 insns: ['FMM4AHW1']
let Uses=[CS], Defs=[CS] in
def FMM4AHW1 : REGISTERA1_REGISTERBP_REGISTERC_REGISTERD_SIMPLE
  <(outs BlockReg1M4:$a1), (ins WideReg:$a2, AccelReg:$a3, AccelReg:$a4),
   "fmm4ahw1 $a1 = $a2, $a3, $a4",
   [ ]>;

// 1 insns: ['FMM4AHW2']
let Uses=[CS], Defs=[CS] in
def FMM4AHW2 : REGISTERA2_REGISTERBP_REGISTERC_REGISTERD_SIMPLE
  <(outs BlockReg2M4:$a1), (ins WideReg:$a2, AccelReg:$a3, AccelReg:$a4),
   "fmm4ahw2 $a1 = $a2, $a3, $a4",
   [ ]>;

// 1 insns: ['FMM4AHW3']
let Uses=[CS], Defs=[CS] in
def FMM4AHW3 : REGISTERA3_REGISTERBP_REGISTERC_REGISTERD_SIMPLE
  <(outs BlockReg3M4:$a1), (ins WideReg:$a2, AccelReg:$a3, AccelReg:$a4),
   "fmm4ahw3 $a1 = $a2, $a3, $a4",
   [ ]>;

// 1 insns: ['CONVDHV0']
let Uses=[CS] in
def CONVDHV0 : ROUNDINT_SATURATE_REGISTERAL_REGISTERBQ_SIMPLE
  <(outs BlockRegE:$a3), (ins ExtendReg:$a4, RoundintMod:$a1, SaturateMod:$a2),
   "convdhv0$a1$a2 $a3 = $a4",
   [ ]>;

// 1 insns: ['CONVDHV1']
let Uses=[CS] in
def CONVDHV1 : ROUNDINT_SATURATE_REGISTERAH_REGISTERBQ_SIMPLE
  <(outs BlockRegO:$a3), (ins ExtendReg:$a4, RoundintMod:$a1, SaturateMod:$a2),
   "convdhv1$a1$a2 $a3 = $a4",
   [ ]>;

// 1 insns: ['CONVWBV0']
let Uses=[CS] in
def CONVWBV0 : ROUNDINT_SATURATE_REGISTERAX_REGISTERBQ_SIMPLE
  <(outs CoproReg0M4:$a3), (ins ExtendReg:$a4, RoundintMod:$a1, SaturateMod:$a2),
   "convwbv0$a1$a2 $a3 = $a4",
   [ ]>;

// 1 insns: ['CONVWBV1']
let Uses=[CS] in
def CONVWBV1 : ROUNDINT_SATURATE_REGISTERAY_REGISTERBQ_SIMPLE
  <(outs CoproReg1M4:$a3), (ins ExtendReg:$a4, RoundintMod:$a1, SaturateMod:$a2),
   "convwbv1$a1$a2 $a3 = $a4",
   [ ]>;

// 1 insns: ['CONVWBV2']
let Uses=[CS] in
def CONVWBV2 : ROUNDINT_SATURATE_REGISTERAZ_REGISTERBQ_SIMPLE
  <(outs CoproReg2M4:$a3), (ins ExtendReg:$a4, RoundintMod:$a1, SaturateMod:$a2),
   "convwbv2$a1$a2 $a3 = $a4",
   [ ]>;

// 1 insns: ['CONVWBV3']
let Uses=[CS] in
def CONVWBV3 : ROUNDINT_SATURATE_REGISTERAT_REGISTERBQ_SIMPLE
  <(outs CoproReg3M4:$a3), (ins ExtendReg:$a4, RoundintMod:$a1, SaturateMod:$a2),
   "convwbv3$a1$a2 $a3 = $a4",
   [ ]>;

// 1 insns: ['FSCALEWV']
let Uses=[CS], Defs=[CS] in
def FSCALEWV : XROUNDING_SILENT2_RECTIFY_REGISTERA_REGISTERB_SIMPLE
  <(outs AccelReg:$a4), (ins AccelReg:$a5, RoundingMod:$a1, SilentMod:$a2, RectifyMod:$a3),
   "fscalewv$a1$a2$a3 $a4 = $a5",
   [ ]>;

// 1 insns: ['FNARROWWHV']
let Uses=[CS], Defs=[CS] in
def FNARROWWHV : XROUNDING_SILENT2_REGISTERA_REGISTERBP_SIMPLE
  <(outs AccelReg:$a3), (ins WideReg:$a4, RoundingMod:$a1, SilentMod:$a2),
   "fnarrowwhv$a1$a2 $a3 = $a4",
   [ ]>;

// 1 insns: ['COPYD']
def COPYD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "copyd $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['NOTD']
def NOTD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "notd $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['NEGD']
def NEGD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "negd $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['ABSD']
def ABSD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "absd $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['ZXBD']
def ZXBD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "zxbd $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['SXBD']
def SXBD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "sxbd $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['ZXHD']
def ZXHD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "zxhd $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['SXHD']
def SXHD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "sxhd $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['ZXWD']
def ZXWD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "zxwd $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['SXWD']
def SXWD : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "sxwd $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['SATDH']
def SATDH : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "satdh $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['SATUDH']
def SATUDH : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "satudh $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['SATDW']
def SATDW : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "satdw $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['SATUDW']
def SATUDW : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "satudw $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['COPYW']
def COPYW : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "copyw $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['NOTW']
def NOTW : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "notw $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['NEGW']
def NEGW : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "negw $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['ABSW']
def ABSW : REGISTERW_REGISTERZ_SIMPLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "absw $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['NEGWP']
def NEGWP : REGISTERW_REGISTERZ_DOUBLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "negwp $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['ABSWP']
def ABSWP : REGISTERW_REGISTERZ_DOUBLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "abswp $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['NEGHQ']
def NEGHQ : REGISTERW_REGISTERZ_DOUBLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "neghq $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 1 insns: ['ABSHQ']
def ABSHQ : REGISTERW_REGISTERZ_DOUBLE
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "abshq $a1 = $a2",
   [ ],
   __UNKNOWN_ITIN__>;

// 2 insns: ['COPYV', 'COPYV']
defm COPYV : MC_2B<"copyv">;

// 2 insns: ['MOVEFO', 'MOVEFO']
defm MOVEFO : MC_2C<"movefo">;
