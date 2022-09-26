//===-- KVXInstrInfoMan.td - Target Description for KVX Target ------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
multiclass MC_1Em<string OpcStr> {
  def i16 : KVX_INSTRUCTION
    <(outs SingleReg:$a1), (ins Signed16:$a2),
     !strconcat (OpcStr, " $a1 = @pcrel( $a2 )"),
     [/* no straightforward pattern */],
     ALU_FULL>;
  def i43 : KVX_INSTRUCTION_X
    <(outs SingleReg:$a1), (ins Signed43:$a2),
     !strconcat (OpcStr, " $a1 = @pcrel( $a2 )"),
     [/* no straightforward pattern */],
     ALU_FULL_X_>;
  def i64 : KVX_INSTRUCTION_Y
    <(outs SingleReg:$a1), (ins Wrapped64:$a2),
     !strconcat (OpcStr, " $a1 = @pcrel( $a2 )"),
     [/* no straightforward pattern */],
     ALU_FULL_Y_>;
}

defm PCRELm : MC_1Em<"pcrel">;
