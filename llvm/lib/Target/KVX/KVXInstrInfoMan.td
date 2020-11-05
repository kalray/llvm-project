//===-- KVXInstrInfoMan.td - Target Description for KVX Target ------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

multiclass MC_13m<string OpcStr> {
  def rr : REGISTERW_REGISTERZ_REGISTERY_SIMPLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_LITE>;
  def ri : REGISTERW_REGISTERZ_UPPER27_LOWER5_DOUBLE
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Wrapped64W:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_LITE_X>;
}

multiclass MC_1Em<string OpcStr> {
  def i16 : REGISTERW_SIGNED16_SIMPLE
    <(outs SingleReg:$a1), (ins Signed16:$a2),
     !strconcat (OpcStr, " $a1 = @pcrel( $a2 )"),
     [/* no straightforward pattern */],
     ALU_FULL>;
  def i43 : REGISTERW_EXTEND6_UPPER27_LOWER10_DOUBLE
    <(outs SingleReg:$a1), (ins Signed43:$a2),
     !strconcat (OpcStr, " $a1 = @pcrel( $a2 )"),
     [/* no straightforward pattern */],
     ALU_FULL_X>;
  def i64 : REGISTERW_EXTEND27_UPPER27_LOWER10_TRIPLE
    <(outs SingleReg:$a1), (ins Wrapped64:$a2),
     !strconcat (OpcStr, " $a1 = @pcrel( $a2 )"),
     [/* no straightforward pattern */],
     ALU_FULL_Y>;
}

// This holds only the changed part from MC_08
multiclass MC_08m<string OpcStr> {
  let Constraints = "$a3 = $a3i" in {
  def ri10cs : COLUMN_SPECULATE_REGISTERAQ_SIGNED10_REGISTERZ_SIMPLE
    <(outs MatrixReg:$a3), (ins MatrixReg:$a3i, Signed10:$a4, SingleReg:$a5, ColumnMod:$a1, SpeculateMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4[$a5]"),
     [/* no straightforward pattern */]>;
  def ri37cs : COLUMN_SPECULATE_REGISTERAQ_UPPER27_LOWER10_REGISTERZ_DOUBLE
    <(outs MatrixReg:$a3), (ins MatrixReg:$a3i, Signed37:$a4, SingleReg:$a5, ColumnMod:$a1, SpeculateMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4[$a5]"),
     [/* no straightforward pattern */]>;
  def ri64cs : COLUMN_SPECULATE_REGISTERAQ_EXTEND27_UPPER27_LOWER10_REGISTERZ_TRIPLE
    <(outs MatrixReg:$a3), (ins MatrixReg:$a3i, Wrapped64:$a4, SingleReg:$a5, ColumnMod:$a1, SpeculateMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4[$a5]"),
     [/* no straightforward pattern */]>;
  }
  let Constraints = "$a5 = $a5i" in {
  def rrccs : COLUMN_SPECULATE_LSUCOND_REGISTERY_REGISTERAQ_REGISTERZ_SIMPLE
    <(outs MatrixReg:$a5), (ins MatrixReg:$a5i, SingleReg:$a4, SingleReg:$a6, ColumnMod:$a1, SpeculateMod:$a2, ScalarcondMod:$a3),
     !strconcat (OpcStr, "$a1$a2$a3 $a4 ? $a5 = [$a6]"),
     [/* no straightforward pattern */]>;
  def ri27ccs : COLUMN_SPECULATE_LSUCOND_REGISTERY_REGISTERAQ_OFFSET27_REGISTERZ_DOUBLE
    <(outs MatrixReg:$a5), (ins MatrixReg:$a5i, SingleReg:$a4, Signed27:$a6, SingleReg:$a7, ColumnMod:$a1, SpeculateMod:$a2, ScalarcondMod:$a3),
     !strconcat (OpcStr, "$a1$a2$a3 $a4 ? $a5 = $a6[$a7]"),
     [/* no straightforward pattern */]>;
  def ri54ccs : COLUMN_SPECULATE_LSUCOND_REGISTERY_REGISTERAQ_EXTEND27_OFFSET27_REGISTERZ_TRIPLE
    <(outs MatrixReg:$a5), (ins MatrixReg:$a5i, SingleReg:$a4, Signed54:$a6, SingleReg:$a7, ColumnMod:$a1, SpeculateMod:$a2, ScalarcondMod:$a3),
     !strconcat (OpcStr, "$a1$a2$a3 $a4 ? $a5 = $a6[$a7]"),
     [/* no straightforward pattern */]>;
  }
  let Constraints = "$a4 = $a4i" in
  def rrcs : COLUMN_SPECULATE_DOSCALE_REGISTERAQ_REGISTERY_REGISTERZ_SIMPLE
    <(outs MatrixReg:$a4), (ins  MatrixReg:$a4i, SingleReg:$a5, SingleReg:$a6, ColumnMod:$a1, SpeculateMod:$a2, DoscaleMod:$a3),
     !strconcat (OpcStr, "$a1$a2$a3 $a4 = $a5[$a6]"),
     [/* no straightforward pattern */]>;
}


defm ADDX16Dm : MC_13m<"addx16d">;
defm ADDX8Dm  : MC_13m<"addx8d">;
defm ADDX4Dm  : MC_13m<"addx4d">;
defm ADDX2Dm  : MC_13m<"addx2d">;
defm SBFX16Dm : MC_13m<"sbfx16d">;
defm SBFX8Dm  : MC_13m<"sbfx8d">;
defm SBFX4Dm  : MC_13m<"sbfx4d">;
defm SBFX2Dm  : MC_13m<"sbfx2d">;

defm ADDX16UWDm : MC_13m<"addx16uwd">;
defm ADDX8UWDm  : MC_13m<"addx8uwd">;
defm ADDX4UWDm  : MC_13m<"addx4uwd">;
defm ADDX2UWDm  : MC_13m<"addx2uwd">;
defm SBFX16UWDm : MC_13m<"sbfx16uwd">;
defm SBFX8UWDm  : MC_13m<"sbfx8uwd">;
defm SBFX4UWDm  : MC_13m<"sbfx4uwd">;
defm SBFX2UWDm  : MC_13m<"sbfx2uwd">;

defm ADDX16WDm : MC_13m<"addx16wd">;
defm ADDX8WDm  : MC_13m<"addx8wd">;
defm ADDX4WDm  : MC_13m<"addx4wd">;
defm ADDX2WDm  : MC_13m<"addx2wd">;
defm SBFX16WDm : MC_13m<"sbfx16wd">;
defm SBFX8WDm  : MC_13m<"sbfx8wd">;
defm SBFX4WDm  : MC_13m<"sbfx4wd">;
defm SBFX2WDm  : MC_13m<"sbfx2wd">;

defm PCRELm : MC_1Em<"pcrel">;

defm LVm : MC_08m<"lv">;
