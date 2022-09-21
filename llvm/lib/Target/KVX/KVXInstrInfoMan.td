//===-- KVXInstrInfoMan.td - Target Description for KVX Target ------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
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

defm PCRELm : MC_1Em<"pcrel">;
