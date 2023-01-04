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

include "KVXOperandInfo.td"
include "KVXInstrFormats.td"


// multiclass MC_00 is used by:
//   defm SCALL
multiclass MC_00<string OpcStr> {
  def r : KVX_INSTRUCTION
    <(outs), (ins SingleReg:$a1),
     !strconcat (OpcStr, " $a1"),
     [/* no straightforward pattern */],
     ALL_ID>;
  def s : KVX_INSTRUCTION
    <(outs), (ins Sysnumber:$a1),
     !strconcat (OpcStr, " $a1"),
     [/* no straightforward pattern */],
     ALL_ID>;
}

// multiclass MC_03 is used by:
//   defm SET
multiclass MC_03<string OpcStr> {
  def rst3 : KVX_INSTRUCTION
    <(outs SetReg:$a1), (ins SingleReg:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */],
     BCU>;
  def rsa : KVX_INSTRUCTION
    <(outs AloneReg:$a1), (ins SingleReg:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */],
     ALL_ID>;
}

// multiclass MC_04 is used by:
//   defm RSWAP
multiclass MC_04<string OpcStr> {
  let Constraints = "$a1 = $a1o, $a2 = $a2o" in
  def ss4 : KVX_INSTRUCTION
    <(outs SingleReg:$a1o, SwapReg:$a2o), (ins SingleReg:$a1, SwapReg:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */],
     BCU_TINY_TINY_MAU_XNOP_RR>;
  let Constraints = "$a1 = $a1o, $a2 = $a2o" in
  def sa : KVX_INSTRUCTION
    <(outs SingleReg:$a1o, AloneReg:$a2o), (ins SingleReg:$a1, AloneReg:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */],
     ALL_RR>;
}


multiclass ACSWAPQ_MC <string Opc = "acswapq"> {
  defm r : I </*asm=*/Opc, /*itin=*/LSU_AUXR_AUXW_LOAD, /*Ops=*/[QuadReg], /*Mods=*/[BoolcasMod, CoherencyMod],
              /*MemOps=*/[SingleReg], /*CC=*/[], /*Out=*/[PairedReg], /*inplace =*/ 0, /*pattern =*/ [], /*IsAtomicSwap = */ 1>;
  defm ri27 : I </*asm=*/Opc, /*itin=*/LSU_AUXR_AUXW_LOAD_X_, /*Ops=*/[QuadReg], /*Mods=*/[BoolcasMod, CoherencyMod],
                 /*MemOps=*/[Signed27, SingleReg], /*CC=*/[], /*Out=*/[PairedReg], /*inplace =*/ 0, /*pattern =*/ [], /*IsAtomicSwap = */ 1>;
  defm ri54 : I </*asm=*/Opc, /*itin=*/LSU_AUXR_AUXW_LOAD_Y_, /*Ops=*/[QuadReg], /*Mods=*/[BoolcasMod, CoherencyMod],
                 /*MemOps=*/[Signed54, SingleReg], /*CC=*/[], /*Out=*/[PairedReg], /*inplace =*/ 0, /*pattern =*/ [], /*IsAtomicSwap = */ 1>;
}
// multiclass MC_0D is used by:
//   defm ACSWAPW
//   defm ACSWAPD
// TODO: can't differentiate registerU from registerZ in OperandLatencies
let mayLoad = 1, mayStore = 1 in
multiclass MC_0D<string OpcStr> {
  let isPredicable = 1 in {
  let Constraints = "$a3 = $a3o" in
  def ri10 : KVX_INSTRUCTION
    <(outs PairedReg:$a3o), (ins Signed10:$a1, SingleReg:$a2, PairedReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [/* no straightforward pattern */],
     LSU_AUXR_AUXW_LOAD_SV3>;
  let Constraints = "$a3 = $a3o" in
  def ri37 : KVX_INSTRUCTION_X
    <(outs PairedReg:$a3o), (ins Signed37:$a1, SingleReg:$a2, PairedReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [/* no straightforward pattern */],
     LSU_AUXR_AUXW_LOAD_SV3_X_>;
  let Constraints = "$a3 = $a3o" in
  def ri64 : KVX_INSTRUCTION_Y
    <(outs PairedReg:$a3o), (ins Wrapped64:$a1, SingleReg:$a2, PairedReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [/* no straightforward pattern */],
     LSU_AUXR_AUXW_LOAD_SV3_Y_>;
  let Constraints = "$a4 = $a4o" in
  def rr : KVX_INSTRUCTION
    <(outs PairedReg:$a4o), (ins SingleReg:$a2, SingleReg:$a3, PairedReg:$a4, DoscaleMod:$a1),
     !strconcat (OpcStr, "$a1 $a2[$a3] = $a4"),
     [/* no straightforward pattern */],
     LSU_AUXR_AUXW_LOAD_SV3>;
  }
  let Constraints = "$a4 = $a4o" in
  def rrc : KVX_INSTRUCTION
    <(outs PairedReg:$a4o), (ins SingleReg:$a3, PairedReg:$a4, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? [$a3] = $a4"),
     [/* no straightforward pattern */],
     LSU_AUXR_AUXW_LOAD_SV2>;
  let Constraints = "$a5 = $a5o" in
  def ri27c : KVX_INSTRUCTION_X
    <(outs PairedReg:$a5o), (ins Signed27:$a3, SingleReg:$a4, PairedReg:$a5, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? $a3[$a4] = $a5"),
     [/* no straightforward pattern */],
     LSU_AUXR_AUXW_LOAD_SV3_X_>;
  let Constraints = "$a5 = $a5o" in
  def ri54c : KVX_INSTRUCTION_Y
    <(outs PairedReg:$a5o), (ins Signed54:$a3, SingleReg:$a4, PairedReg:$a5, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? $a3[$a4] = $a5"),
     [/* no straightforward pattern */],
     LSU_AUXR_AUXW_LOAD_SV3_Y_>;

  // CV2 formats.
  def r : KVX_INSTRUCTION
    <(outs SingleReg:$regout), (ins SingleReg:$addr, PairedReg:$regin, BoolcasMod:$bcm, CoherencyMod:$com),
     !strconcat (OpcStr, "$bcm$com $regout, [$addr] = $regin"),
     [/* no straightforward pattern */],
     LSU_AUXR_AUXW_LOAD_SV2>;
  def ri27 : KVX_INSTRUCTION_X
    <(outs SingleReg:$regout), (ins Signed27:$off, SingleReg:$addr, PairedReg:$regin, BoolcasMod:$bcm, CoherencyMod:$com),
     !strconcat(OpcStr, "$bcm$com $regout, $off[$addr] = $regin"),
     [/* no straightforward pattern */],
     LSU_AUXR_AUXW_LOAD_SV3_X_>;
  def ri54 : KVX_INSTRUCTION_Y
    <(outs SingleReg:$regout), (ins Signed54:$off, SingleReg:$addr, PairedReg:$regin, BoolcasMod:$bcm, CoherencyMod:$com),
     !strconcat(OpcStr, "$bcm$com $regout, $off[$addr] = $regin"),
     [/* no straightforward pattern */],
     LSU_AUXR_AUXW_LOAD_SV3_Y_>;
}

// multiclass MC_0E is used by:
//   defm ALCLRW
//   defm ALCLRD
multiclass MC_0E<string OpcStr, ValueType vt, int shsz> {
  let mayLoad = 1, mayStore = 1, isPredicable = 1 in {
  def ri10 : KVX_INSTRUCTION
    <(outs SingleReg:$a1), (ins Signed10:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2[$a3]"),
     [(set vt:$a1, (int_kvx_alclr (add i64:$a3, Signed10:$a2)))],
     LSU_AUXW_ALCLR>;
  def ri37 : KVX_INSTRUCTION_X
    <(outs SingleReg:$a1), (ins Signed37:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2[$a3]"),
     [(set vt:$a1, (int_kvx_alclr (add i64:$a3, Signed37:$a2)))],
     LSU_AUXW_ALCLR_X_>;
  def ri64 : KVX_INSTRUCTION_Y
    <(outs SingleReg:$a1), (ins Wrapped64:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2[$a3]"),
     [(set vt:$a1, (int_kvx_alclr (add i64:$a3, Wrapped64:$a2)))],
     LSU_AUXW_ALCLR_Y_>;
  def rr : KVX_INSTRUCTION
    <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, DoscaleMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3[$a4]"),
     [/* no straightforward pattern */],
     LSU_AUXW_ALCLR>;
  }
  defvar rr = !cast<Instruction>(NAME # "rr");
  def : Pat <(vt (int_kvx_alclr (add i64:$a4, (shl i64:$a3, (i32 shsz))))),
             (vt (rr SingleReg:$a3, SingleReg:$a4, scale_xs))>, Requires<[IsV1]>;

  def : Pat <(vt (int_kvx_alclr (add i64:$a4, i64:$a3))),
             (vt (rr SingleReg:$a3, SingleReg:$a4, scale_))>, Requires<[IsV1]>;

  let mayLoad = 1, mayStore = 1, Constraints = "$a3 = $a3o" in {
  def rrc : KVX_INSTRUCTION
    <(outs SingleReg:$a3o), (ins SingleReg:$a4, SingleReg:$a3, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? $a3 = [$a4]"),
     [/* no straightforward pattern */],
     LSU_AUXW_ALCLR>;
  def ri27c : KVX_INSTRUCTION_X
    <(outs SingleReg:$a3o), (ins Signed27:$a4, SingleReg:$a5, SingleReg:$a3, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? $a3 = $a4[$a5]"),
     [/* no straightforward pattern */],
     LSU_AUXW_ALCLR_X_>;
  def ri54c : KVX_INSTRUCTION_Y
    <(outs SingleReg:$a3o), (ins Signed54:$a4, SingleReg:$a5, SingleReg:$a3, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? $a3 = $a4[$a5]"),
     [/* no straightforward pattern */],
     LSU_AUXW_ALCLR_Y_>;
  }
}

// multiclass MC_0F is used by:
//   defm ALADDW
//   defm ALADDD
// TODO: cannot differentiate OperandLatencies for regT and regZ
let mayLoad = 1, mayStore = 1 in
multiclass MC_0F<string OpcStr> {
  let isPredicable = 1 in {
  let Constraints = "$a3 = $a3o" in
  def ri10 : KVX_INSTRUCTION
    <(outs SingleReg:$a3o), (ins Signed10:$a1, SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [/* no straightforward pattern */],
     LSU_AUXR_AUXW_LOAD_SV3>;
  let Constraints = "$a3 = $a3o" in
  def ri37 : KVX_INSTRUCTION_X
    <(outs SingleReg:$a3o), (ins Signed37:$a1, SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [/* no straightforward pattern */],
     LSU_AUXR_AUXW_LOAD_SV3_X_>;
  let Constraints = "$a3 = $a3o" in
  def ri64 : KVX_INSTRUCTION_Y
    <(outs SingleReg:$a3o), (ins Wrapped64:$a1, SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1[$a2] = $a3"),
     [/* no straightforward pattern */],
     LSU_AUXR_AUXW_LOAD_SV3_Y_>;
  let Constraints = "$a4 = $a4o" in
  def rr : KVX_INSTRUCTION
    <(outs SingleReg:$a4o), (ins SingleReg:$a2, SingleReg:$a3, SingleReg:$a4, DoscaleMod:$a1),
     !strconcat (OpcStr, "$a1 $a2[$a3] = $a4"),
     [/* no straightforward pattern */],
     LSU_AUXR_AUXW_LOAD_SV3>;
  }
  let Constraints = "$a4 = $a4o" in
  def rrc : KVX_INSTRUCTION
    <(outs SingleReg:$a4o), (ins SingleReg:$a3, SingleReg:$a4, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? [$a3] = $a4"),
     [/* no straightforward pattern */],
     LSU_AUXR_AUXW_LOAD_SV2>;
  let Constraints = "$a5 = $a5o" in
  def ri27c : KVX_INSTRUCTION_X
    <(outs SingleReg:$a5o), (ins Signed27:$a3, SingleReg:$a4, SingleReg:$a5, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? $a3[$a4] = $a5"),
     [/* no straightforward pattern */],
     LSU_AUXR_AUXW_LOAD_SV3_X_>;
  let Constraints = "$a5 = $a5o" in
  def ri54c : KVX_INSTRUCTION_Y
    <(outs SingleReg:$a5o), (ins Signed54:$a3, SingleReg:$a4, SingleReg:$a5, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? $a3[$a4] = $a5"),
     [/* no straightforward pattern */],
     LSU_AUXR_AUXW_LOAD_SV3_Y_>;
}

// multiclass MC_10 is used by:
//   defm DTOUCHL
//   defm DINVALL
//   defm DZEROL
//   defm I1INVALS
multiclass MC_10<string OpcStr> {
  let isPredicable = 1 in {
  def ri10 : KVX_INSTRUCTION
    <(outs), (ins Signed10:$a1, SingleReg:$a2),
     !strconcat (OpcStr, " $a1[$a2]"),
     [/* no straightforward pattern */],
     LSU_LOAD>;
  def ri37 : KVX_INSTRUCTION_X
    <(outs), (ins Signed37:$a1, SingleReg:$a2),
     !strconcat (OpcStr, " $a1[$a2]"),
     [/* no straightforward pattern */],
     LSU_LOAD_X_>;
  def ri64 : KVX_INSTRUCTION_Y
    <(outs), (ins Wrapped64:$a1, SingleReg:$a2),
     !strconcat (OpcStr, " $a1[$a2]"),
     [/* no straightforward pattern */],
     LSU_LOAD_Y_>;
  def rr : KVX_INSTRUCTION
    <(outs), (ins SingleReg:$a1, SingleReg:$a2),
     !strconcat (OpcStr, " $a1[$a2]"),
     [/* no straightforward pattern */],
     LSU_LOAD>;
  }
  def rrc : KVX_INSTRUCTION
    <(outs), (ins SingleReg:$a3, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? [$a3]"),
     [/* no straightforward pattern */],
     LSU_LOAD>;
  def ri27c : KVX_INSTRUCTION_X
    <(outs), (ins Signed27:$a3, SingleReg:$a4, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? $a3[$a4]"),
     [/* no straightforward pattern */],
     LSU_LOAD_X_>;
  def ri54c : KVX_INSTRUCTION_Y
    <(outs), (ins Signed54:$a3, SingleReg:$a4, ScalarcondMod:$a1, SingleReg:$a2),
     !strconcat (OpcStr, "$a1 $a2 ? $a3[$a4]"),
     [/* no straightforward pattern */],
     LSU_LOAD_Y_>;
}

// multiclass MC_BINOP_64 is used by:
//   defm ANDD
//   defm ORD
//   defm NORD
//   defm XORD
//   defm NXORD
//   defm ANDND
//   defm ORND
multiclass MC_BINOP_64<string OpcStr, PatFrag p> {
  defm rr : I <OpcStr, /*itin=*/ALU_TINY, /*Ops=*/[SingleReg, SingleReg], /*Mods=*/[],
              /*MemOps=*/[], /*CC=*/[], /*Out=*/[SingleReg], /*InPlace=*/0, /*pattern=*/
              [(set i64:$r, (p i64:$op0, i64:$op1))]>;

  defm ri10 : I <OpcStr, /*itin=*/ALU_TINY, /*Ops=*/[SingleReg, Signed10], /*Mods=*/[],
              /*MemOps=*/[], /*CC=*/[], /*Out=*/[SingleReg], /*InPlace=*/0, /*pattern=*/
              [(set i64:$r, (p i64:$op0, Signed10:$op1))], /*IsAtomicSwap*/ 0, /*added complexity*/ 2>;

  defm ri32s: I <OpcStr # ".@", /*itin=*/ALU_TINY_X_, /*Ops=*/[SingleReg, Wrapped32], /*Mods=*/[],
              /*MemOps=*/[], /*CC=*/[], /*Out=*/[SingleReg], /*InPlace=*/0, /*pattern=*/
              []>;

  defm ri37 : I <OpcStr, /*itin=*/ALU_TINY_X_, /*Ops=*/[SingleReg, Signed37], /*Mods=*/[],
              /*MemOps=*/[], /*CC=*/[], /*Out=*/[SingleReg], /*InPlace=*/0, /*pattern=*/
              [(set i64:$r, (p i64:$op0, Signed37:$op1))]>;

  defm ri64 : I <OpcStr, /*itin=*/ALU_TINY_Y_, /*Ops=*/[SingleReg, Wrapped64], /*Mods=*/[],
              /*MemOps=*/[], /*CC=*/[], /*Out=*/[SingleReg], /*InPlace=*/0, /*pattern=*/
              [(set i64:$r, (p i64:$op0, Wrapped64:$op1))]>;
  defvar ri32s = !cast<Instruction>(NAME # "ri32s");
  defvar ri64 = !cast<Instruction>(NAME # "ri64");
  defvar rr = !cast<Instruction>(NAME # "rr");

  def : Pat<(i64 (p i64:$op0, UnsignedSplat32Imm:$op1)),
            (ri32s SingleReg:$op0, (trunc_imm_32 $op1))>;

  foreach vtype = [ v8i8, v4i16, v2i32 ] in {
    def : Pat<(p vtype:$op0, (vtype (is_imm_vec_kvx_splat32_at:$op1))),
              (ri32s SingleReg:$op0, (build_imm_vec $op1))>;

    def : Pat<(p vtype:$op0, (vtype (is_imm_vec:$op1))),
              (ri64 SingleReg:$op0, (build_imm_vec $op1))>;

    def : Pat<(p vtype:$op0, vtype:$rs2),
              (rr SingleReg:$op0, SingleReg:$rs2)>;
  }
}

// multiclass MC_11 is used by:
//   defm ADDD
//   defm SBFD
//   defm NANDD
//   defm MIND
//   defm MINUD
//   defm MAXD
//   defm MAXUD
multiclass MC_11<string OpcStr> {
  let isAsCheapAsAMove = 1 in
  def rr : KVX_INSTRUCTION
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_TINY>;
  let isAsCheapAsAMove = 1 in
  def ri10 : KVX_INSTRUCTION
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed10:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_TINY>;
  def ri37 : KVX_INSTRUCTION_X
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed37:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_TINY_X_>;
  def ri64 : KVX_INSTRUCTION_Y
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Wrapped64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_TINY_Y_>;
  def ri32s: KVX_INSTRUCTION_X
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Wrapped32:$a3),
     !strconcat (OpcStr, ".@ $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_TINY_X_>;
}

// multiclass MC_12_SWITCH is used by:
//   defm ABDD
//   defm SBMM8
//   defm SBMMT8
multiclass MC_12_SWITCH<string OpcStr> {
  def rr : KVX_INSTRUCTION
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"), [],
     ALU_SWITCH_LITE_TINY>;
  def ri10 : KVX_INSTRUCTION
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed10:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"), [],
     ALU_SWITCH_LITE_TINY>;
  def ri32s : KVX_INSTRUCTION_X
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Wrapped32:$a3),
     !strconcat (OpcStr, ".@ $a1 = $a2, $a3"), [],
     ALU_SWITCH_LITE_TINY_X_>;
  def ri37 : KVX_INSTRUCTION_X
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed37:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"), [],
     ALU_SWITCH_LITE_TINY_X_>;
  def ri64 : KVX_INSTRUCTION_Y
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Wrapped64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"), [],
     ALU_SWITCH_LITE_TINY_Y_>;
}

// multiclass ADD_SBF_SD_FAMILY is used by:
//   defm ADDSD
//   defm SBFSD
multiclass ADD_SBF_SD_FAMILY<string OpcStr> {
  // Common
  def rr : KVX_INSTRUCTION
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_SWITCH_LITE_TINY>;

  // Only CV1
  def ri10 : KVX_INSTRUCTION
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed10:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_LITE>, Requires<[IsV1]>;
  def ri37 : KVX_INSTRUCTION_X
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed37:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_LITE_X_>, Requires<[IsV1]>;
  def ri64 : KVX_INSTRUCTION_Y
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Wrapped64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_LITE_Y_>, Requires<[IsV1]>;

  // Only CV2
  def ri_cv2 : KVX_INSTRUCTION_X
    <(outs SingleReg:$a2), (ins SingleReg:$a3, Wrapped32:$a4, Splat32Mod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [/* no straightforward pattern */],
     ALU_TINY_X_>, Requires<[IsV2]>;
}

// multiclass MC_13 is used by:
//   defm LANDD
//   defm LNANDD
//   defm LORD
//   defm LNORD
//   defm LANDW
//   defm LNANDW
//   defm LORW
//   defm LNORW
//   defm SBFX32WD
//   defm SBFX64WD
multiclass MC_13<string OpcStr> {
  def rr : KVX_INSTRUCTION
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_LITE>;
  def ri : KVX_INSTRUCTION_Y
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Wrapped32:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_LITE_X_>;
}

// multiclass MC_13_SWITCH is used by:
//   defm ADDWD
//   defm SBFWD
//   defm ADDUWD
//   defm SBFUWD
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
//   defm ADDX2WD
//   defm ADDX4WD
//   defm ADDX8WD
//   defm ADDX16WD
//   defm AVGRW
//   defm AVGRUW
//   defm AVGUW
//   defm AVGW
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
//   defm STSUW : ri variant is CV2 only
multiclass MC_13_SWITCH<string OpcStr> {
  def rr : KVX_INSTRUCTION
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_SWITCH_LITE_TINY>;
  def ri : KVX_INSTRUCTION_X
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Wrapped32:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_SWITCH_LITE_TINY_X_>;
}

// multiclass MC_13_TINY is used by:
//   defm ADDX32UWD
//   defm ADDX32W
//   defm ADDX32WD
//   defm ADDX64UWD
//   defm ADDX64W
//   defm ADDX64WD
//   defm SBFX32W
//   defm SBFX64W
//   defm SBFX32UWD
//   defm SBFX64UWD
multiclass MC_13_TINY<string OpcStr> {
  let isAsCheapAsAMove = 1 in
    def rr : KVX_INSTRUCTION
      <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
      !strconcat (OpcStr, " $a1 = $a2, $a3"),
      [/* no straightforward pattern */],
      ALU_TINY>;
    def ri : KVX_INSTRUCTION_Y
      <(outs SingleReg:$a1), (ins SingleReg:$a2, Wrapped32:$a3),
      !strconcat (OpcStr, " $a1 = $a2, $a3"),
      [/* no straightforward pattern */],
      ALU_TINY_X_>;
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
  def ri10 : KVX_INSTRUCTION
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed10W:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_TINY>;
  def ri37 : KVX_INSTRUCTION_X
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed37W:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_TINY_X_>;
  let isAsCheapAsAMove = 1 in
  def rr : KVX_INSTRUCTION
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_TINY>;
}

// multiclass MC_15 is used by:
//   defm ABDW
multiclass MC_15<string OpcStr> {
  def ri10 : KVX_INSTRUCTION
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed10W:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_SWITCH_LITE_TINY>;
  def ri37 : KVX_INSTRUCTION_X
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed37W:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_SWITCH_LITE_TINY_X_>;
  def rr : KVX_INSTRUCTION
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_SWITCH_LITE_TINY>;
}

// multiclass MC_17 is used by:
//   defm ADDCWC
//   defm SBFCWC
//   defm SBFSBO
//   defm LANDWP
//   defm LNANDWP
//   defm LORWP
//   defm LNORWP
//   defm ABDSBO
//   defm ABDSHQ
//   defm ABDSD
//   defm ABDSW
//   defm ABDSWP
//   defm ADDCHCP
//   defm SBFCHCP
//   defm AVGBO
//   defm AVGUBO
//   defm AVGRBO
//   defm AVGRUBO
//   defm LANDHQ
//   defm LNANDHQ
//   defm LORHQ
//   defm LNORHQ
multiclass MC_17<string OpcStr> {
  def rr : KVX_INSTRUCTION
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_LITE>;
  def ri : KVX_INSTRUCTION_X
    <(outs SingleReg:$a2), (ins SingleReg:$a3, Wrapped32:$a4, Splat32Mod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [/* no straightforward pattern */],
     ALU_LITE_X_>;
}

// multiclass MC_17_TINY is used by:
//   defm ABDBO
//   defm ADDBO
//   defm ADDHQ
//   defm ADDSBO
//   defm ADDUSBO
//   defm ADDUSD
//   defm ADDUSHQ
//   defm ADDUSW
//   defm ADDUSWP
//   defm ADDWP
//   defm ADDX2BO
//   defm ADDX16BO
//   defm ADDX32D
//   defm ADDX4BO
//   defm ADDX64D
//   defm ADDX8BO
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
//   defm SBFUSBO
//   defm SBFUSD
//   defm SBFUSHQ
//   defm SBFUSW
//   defm SBFUSWP
//   defm SBFWP
//   defm SBFX2BO
//   defm SBFX4BO
//   defm SBFX8BO
//   defm SBFX16BO
//   defm SBFX32D
//   defm SBFX64D
multiclass MC_17_TINY<string OpcStr, list<dag> patrr = []> {
  defm rr : I <OpcStr, /*itin=*/ALU_TINY, /*Ops=*/[SingleReg, SingleReg], /*Mods=*/[],
               /*MemOps=*/[], /*CC=*/[], /*Out=*/[SingleReg], /*InPlace=*/0, /*pattern=*/ patrr>;

  defm ri : I <OpcStr, /*itin=*/ALU_TINY_X_, /*Ops=*/[SingleReg, Wrapped32], /*Mods=*/[Splat32Mod],
               /*MemOps=*/[], /*CC=*/[], /*Out=*/[SingleReg]>;
}

let Predicates = [IsV2], isCommutable = 1 in {
defm ABDUD:  MC_17_TINY<"abdud", []>;
defm ABDUW:  MC_17_TINY<"abduw", []>;
defm ABDUWP: MC_17_TINY<"abduwp", []>;
defm ABDUHQ: MC_17_TINY<"abduhq", []>;
defm ABDUBO: MC_17_TINY<"abdubo", []>;
}

// multiclass MC_17_SWITCH is used by:
//   defm ABDHQ
//   defm ABDWP
//   defm ADDSHQ
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
//   defm AVGHQ
//   defm AVGRHQ
//   defm AVGRUHQ
//   defm AVGRUWP
//   defm AVGRWP
//   defm AVGUHQ
//   defm AVGUWP
//   defm AVGWP
//   defm SBFX2D
//   defm SBFX2WP
//   defm SBFX4D
//   defm SBFSHQ
//   defm ADDX2HQ
//   defm ADDX4HQ
//   defm ADDX8HQ
//   defm ADDX16HQ
//   defm SBFX2HQ
//   defm SBFX4HQ
//   defm SBFX8HQ
//   defm SBFX16HQ
//   defm STSUD
multiclass MC_17_SWITCH<string OpcStr> {
  def rr : KVX_INSTRUCTION
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_SWITCH_LITE_TINY>;
  def ri : KVX_INSTRUCTION_X
    <(outs SingleReg:$a2), (ins SingleReg:$a3, Wrapped32:$a4, Splat32Mod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [/* no straightforward pattern */],
     ALU_SWITCH_LITE_TINY_X_>;
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
//   defm SLSWPS
//   defm ROLWPS
//   defm RORWPS
//   defm SRSHQS
//   defm SRBOQS
//   defm SLSHQS
//   defm SLSBOS
//   defm SLUSBOS
//   defm SLUSD
//   defm SLUSW
//   defm SLUSWPS
//   defm SLUSHQS
//   defm SRSBOS
multiclass MC_18<string OpcStr> {
  def rr : KVX_INSTRUCTION
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_LITE>;
  def ri : KVX_INSTRUCTION
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Unsigned6W:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_LITE>;
}

// multiclass MC_18_TINY is used by:
//   defm SLLD
//   defm SRAD
//   defm SRLD
//   defm SLLW
//   defm SRAW
//   defm SRLW
//   defm SRABOS
//   defm SLLBOS
//   defm SRLBOS
let isAsCheapAsAMove = 1 in
multiclass MC_18_TINY<string OpcStr> {
  def ri : KVX_INSTRUCTION
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Unsigned6W:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_TINY>;
  def rr : KVX_INSTRUCTION
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_TINY>;
}

// multiclass MC_18_SWITCH is used by:
//   defm SRAHQS
//   defm SLLWPS
//   defm SRAWPS
//   defm SRLWPS
//   defm SLLHQS
//   defm SRLHQS
multiclass MC_18_SWITCH<string OpcStr> {
  def ri : KVX_INSTRUCTION
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Unsigned6W:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_SWITCH_LITE_TINY>;
  def rr : KVX_INSTRUCTION
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     ALU_SWITCH_LITE_TINY>;
}

// multiclass MC_1A is used by:
//   defm COMPD
multiclass MC_1A<string OpcStr> {
  def ri10 : KVX_INSTRUCTION
    <(outs SingleReg:$a2), (ins SingleReg:$a3, Signed10:$a4, ComparisonMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [/* no straightforward pattern */],
     ALU_TINY>;
  def ri37 : KVX_INSTRUCTION_X
    <(outs SingleReg:$a2), (ins SingleReg:$a3, Signed37:$a4, ComparisonMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [/* no straightforward pattern */],
     ALU_TINY_X_>;
  def ri64 : KVX_INSTRUCTION_Y
    <(outs SingleReg:$a2), (ins SingleReg:$a3, Wrapped64:$a4, ComparisonMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [/* no straightforward pattern */],
     ALU_TINY_Y_>;
  def rr : KVX_INSTRUCTION
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
  def rr : KVX_INSTRUCTION
    <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, ComparisonMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [/* no straightforward pattern */],
     ALU_TINY>;
  def ri : KVX_INSTRUCTION_X
    <(outs SingleReg:$a2), (ins SingleReg:$a3, Wrapped32:$a4, ComparisonMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [/* no straightforward pattern */],
     ALU_TINY_X_>;
}

// multiclass MC_1C is used by:
//   defm CMOVED
multiclass MC_1C<string OpcStr> {
  let Constraints = "$a3 = $a3o", isMoveImm = 1, isReMaterializable = 1 in {
  def ri10 : KVX_INSTRUCTION
    <(outs SingleReg:$a3o), (ins SingleReg:$a2, SingleReg:$a3, Signed10:$a4, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 ? $a3 = $a4"),
     [/* no straightforward pattern */],
     ALU_SWITCH_LITE_TINY>;
  def ri37 : KVX_INSTRUCTION_X
    <(outs SingleReg:$a3o), (ins SingleReg:$a2, SingleReg:$a3, Signed37:$a4, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 ? $a3 = $a4"),
     [/* no straightforward pattern */],
     ALU_SWITCH_LITE_TINY_X_>;
  def ri64 : KVX_INSTRUCTION_Y
    <(outs SingleReg:$a3o), (ins SingleReg:$a2, SingleReg:$a3, Wrapped64:$a4, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 ? $a3 = $a4"),
     [/* no straightforward pattern */],
     ALU_SWITCH_LITE_TINY_Y_>;
  }
  let Constraints = "$a3 = $a3o", isMoveReg = 1 in
  def rr : KVX_INSTRUCTION
    <(outs SingleReg:$a3o), (ins SingleReg:$a2, SingleReg:$a3, SingleReg:$a4, ScalarcondMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 ? $a3 = $a4"),
     [/* no straightforward pattern */],
     ALU_SWITCH_LITE_TINY>;
}

// multiclass MC_1D is used by:
//   defm MAKE
multiclass MC_1D<string OpcStr> {
  def i16 : KVX_INSTRUCTION
    <(outs SingleReg:$a1), (ins Signed16:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */],
     ALU_TINY>;
  def i43 : KVX_INSTRUCTION_X
    <(outs SingleReg:$a1), (ins Signed43:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */],
     ALU_TINY_X_>;
  def i64 : KVX_INSTRUCTION_Y
    <(outs SingleReg:$a1), (ins Wrapped64:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */],
     ALU_TINY_Y_>;
}

// multiclass MC_1E is used by:
//   defm PCREL
multiclass MC_1E<string OpcStr> {
  def i16 : KVX_INSTRUCTION
    <(outs SingleReg:$a1), (ins Signed16:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */],
     ALU_FULL>;
  def i43 : KVX_INSTRUCTION_X
    <(outs SingleReg:$a1), (ins Signed43:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */],
     ALU_FULL_X_>;
  def i64 : KVX_INSTRUCTION_Y
    <(outs SingleReg:$a1), (ins Wrapped64:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */],
     ALU_FULL_Y_>;
}

// multiclass MC_1F is used by:
//   defm FCOMPW
multiclass MC_1F<string OpcStr> {
  def rr : KVX_INSTRUCTION
    <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, FloatcompMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [/* no straightforward pattern */],
     ALU_SWITCH_LITE_TINY>;
  def ri : KVX_INSTRUCTION_X
    <(outs SingleReg:$a2), (ins SingleReg:$a3, Binary32:$a4, FloatcompMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [/* no straightforward pattern */],
     ALU_SWITCH_LITE_TINY_X_>;
}

//    defm FCOMPNW
multiclass MC_1F_TINY<string OpcStr> {
  def rr : KVX_INSTRUCTION
    <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, FloatcompMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [/* no straightforward pattern */],
     ALU_TINY>;
  def ri : KVX_INSTRUCTION_X
    <(outs SingleReg:$a2), (ins SingleReg:$a3, Binary32:$a4, FloatcompMod:$a1),
     !strconcat (OpcStr, "$a1 $a2 = $a3, $a4"),
     [/* no straightforward pattern */],
     ALU_TINY_X_>;
}

// multiclass MC_20 is used by:
//   defm MADDD
//   defm MADDWP
//   defm MADDHQ
multiclass MC_20<string OpcStr> {
  let Constraints = "$a1 = $a1o" in
  def ri10 : KVX_INSTRUCTION
    <(outs SingleReg:$a1o), (ins SingleReg:$a1, SingleReg:$a2, Signed10:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR_INT_AV1>;
  let Constraints = "$a1 = $a1o" in
  def ri37 : KVX_INSTRUCTION_X
    <(outs SingleReg:$a1o), (ins SingleReg:$a1, SingleReg:$a2, Signed37:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR_INT_AV1_X_>;
  let Constraints = "$a1 = $a1o" in
  def ri64 : KVX_INSTRUCTION_Y
    <(outs SingleReg:$a1o), (ins SingleReg:$a1, SingleReg:$a2, Wrapped64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR_INT_AV1_Y_>;
  let Constraints = "$a1 = $a1o" in
  def rr : KVX_INSTRUCTION
    <(outs SingleReg:$a1o), (ins SingleReg:$a1, SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR_INT_AV1>;
}

// multiclass MC_21 is used by:
//   defm MADDDT
//   defm MADDUDT
//   defm MADDSUDT
//   defm MADDUZDT
multiclass MC_21<string OpcStr> {
  let Constraints = "$a1 = $a1o" in
  def ri10 : KVX_INSTRUCTION
    <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, Signed10:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR_INT_AV1>, Requires<[IsV1]>;
  let Constraints = "$a1 = $a1o" in
  def ri37 : KVX_INSTRUCTION_X
    <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, Signed37:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR_INT_AV1_X_>, Requires<[IsV1]>;
  let Constraints = "$a1 = $a1o" in
  def ri64 : KVX_INSTRUCTION_Y
    <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, Wrapped64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR_INT_AV1_Y_>, Requires<[IsV1]>;
  let Constraints = "$a1 = $a1o" in
  def rr : KVX_INSTRUCTION
    <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR_INT_AV1>;
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
  def ri10 : KVX_INSTRUCTION
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed10:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_INT>;
  def ri37 : KVX_INSTRUCTION_X
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Signed37:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_INT_X_>;
  def ri64 : KVX_INSTRUCTION_Y
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Wrapped64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_INT_Y_>;
  def rr : KVX_INSTRUCTION
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_INT>;
}

// multiclass MC_23 is used by:
//   defm MULDT
//   defm MULUDT
//   defm MULSUDT
//   defm CMULDT
multiclass MC_23<string OpcStr> {
  def ri10 : KVX_INSTRUCTION
    <(outs PairedReg:$a1), (ins SingleReg:$a2, Signed10:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_INT>;
  def ri37 : KVX_INSTRUCTION_X
    <(outs PairedReg:$a1), (ins SingleReg:$a2, Signed37:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_INT_X_>;
  def ri64 : KVX_INSTRUCTION_Y
    <(outs PairedReg:$a1), (ins SingleReg:$a2, Wrapped64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_INT_Y_>;
  def rr : KVX_INSTRUCTION
    <(outs PairedReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_INT>;
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
  def rr : KVX_INSTRUCTION
    <(outs SingleReg:$a1o), (ins SingleReg:$a1, SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR_INT_AV1>;
  let Constraints = "$a1 = $a1o" in
  def ri : KVX_INSTRUCTION_X
    <(outs SingleReg:$a1o), (ins SingleReg:$a1, SingleReg:$a2, Wrapped32:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR_INT_AV1_X_>;
}

// multiclass MC_25 is used by:
//   defm MULWD
//   defm MULUWD
//   defm MULSUWD
//   defm MULW
multiclass MC_25<string OpcStr> {
  def rr : KVX_INSTRUCTION
    <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_INT>;
  def ri : KVX_INSTRUCTION_X
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Wrapped32:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_INT_X_>;
}

// multiclass MC_26 is used by:
//   defm FFMAD
//   defm FFMSD
//   defm FFMAWD
//   defm FFMSWD
multiclass MC_26<string OpcStr> {
  let Constraints = "$a1 = $a1o" in
  def ri : KVX_INSTRUCTION_CV1_Y
    <(outs SingleReg:$a1o), (ins SingleReg:$a1, SingleReg:$a2, Binary64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR_FP_Y_>;
  let Constraints = "$a3 = $a3o" in
  def rr : KVX_INSTRUCTION
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
  def ri : KVX_INSTRUCTION_CV1_Y
    <(outs SingleReg:$a1o), (ins SingleReg:$a1, SingleReg:$a2, Binary32x2:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR_FP_Y_>;
  let Constraints = "$a3 = $a3o" in
  def rr : KVX_INSTRUCTION
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
  def ri : KVX_INSTRUCTION_CV1_Y
    <(outs SingleReg:$a1o), (ins SingleReg:$a1, SingleReg:$a2, Binary16x4:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR_FP_Y_>;
  let Constraints = "$a3 = $a3o" in
  def rr : KVX_INSTRUCTION
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
  def ri : KVX_INSTRUCTION_CV1_Y
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Binary64:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_FP_Y_>;
  def rr : KVX_INSTRUCTION
    <(outs SingleReg:$a3), (ins SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4, $a5"),
     [/* no straightforward pattern */],
     MAU_FP>;
}

multiclass MC_2A<string OpcStr, list<dag> RRpat = []> {
  defm ri : I </*asm=*/OpcStr, /*itin=*/MAU_FP_Y_, /*Ops=*/[SingleReg, Binary32x2], /*Mods=*/[], /*MemOps=*/[], /*CC=*/[],
               /*Out=*/[SingleReg], /*InPlace=*/0, /*pattern=*/[]>, Requires<[IsV1]>;

  defm rr : I </*asm=*/OpcStr, /*itin=*/MAU_FP, /*Ops=*/[SingleReg, SingleReg], /*Mods=*/[RoundingMod, SilentMod], /*MemOps=*/[], /*CC=*/[],
               /*Out=*/[SingleReg], /*InPlace=*/0, /*pattern=*/RRpat>;
}

defm FADDWC : MC_2A<"faddwc.c", [(set v2f32:$r, (int_kvx_faddc v2f32:$op0, v2f32:$op1, conjugate_c, RoundingMod:$mod0, SilentMod:$mod1))]>;
let isAdd = 1 in {
defm FADDWP : MC_2A<"faddwp", [(set v2f32:$r, (int_kvx_fadd v2f32:$op0, v2f32:$op1, RoundingMod:$mod0, SilentMod:$mod1))]>;
}
defm FDOT2W : MC_2A<"fdot2w">;
defm FMULWP : MC_2A<"fmulwp">;
defm FSBFWC : MC_2A<"fsbfwc.c", [(set v2f32:$r, (int_kvx_fsbfc v2f32:$op0, v2f32:$op1, conjugate_c, RoundingMod:$mod0, SilentMod:$mod1))]>;
defm FSBFWP : MC_2A<"fsbfwp", [(set v2f32:$r, (int_kvx_fsbf v2f32:$op0, v2f32:$op1, RoundingMod:$mod0, SilentMod:$mod1))]>;

// FIXME: For coolidge, this class should hold ri10,ri37,ri64 variants.
// multiclass MC_2AM is used by:
//   defm FMULWC
multiclass MC_2AM<string OpcStr> {
  def ri : KVX_INSTRUCTION_CV1_Y
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Binary32x2:$a3, ConjugateMod:$a4),
     !strconcat (OpcStr, "$a4 $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_FP_Y_>, Requires<[IsV1]>;

  def rr : KVX_INSTRUCTION
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
  def ri : KVX_INSTRUCTION_CV1_Y
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Binary16x4:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_FP_Y_>;
  def rr : KVX_INSTRUCTION
    <(outs SingleReg:$a3), (ins SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4, $a5"),
     [/* no straightforward pattern */],
     MAU_FP>;
}

// multiclass MC_2C is used by:
//   defm FMULWDC.C
//   defm FMULWDC
//   defm FMULWDP
multiclass MC_2C<string OpcStr> {
  def ri : KVX_INSTRUCTION_CV1_Y
    <(outs PairedReg:$a1), (ins SingleReg:$a2, Binary32x2:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_FP_Y_>;
  def rr : KVX_INSTRUCTION
    <(outs PairedReg:$a3), (ins SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4, $a5"),
     [/* no straightforward pattern */],
     MAU_FP>;
}

// multiclass MC_2D is used by:
//   defm FMULHWQ
multiclass MC_2D<string OpcStr> {
  def ri : KVX_INSTRUCTION_CV1_Y
    <(outs PairedReg:$a1), (ins SingleReg:$a2, Binary16x4:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_FP_Y_>;
  def rr : KVX_INSTRUCTION
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
  def ri : KVX_INSTRUCTION_CV1_X
    <(outs SingleReg:$a1o), (ins SingleReg:$a1, SingleReg:$a2, Binary32:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR_FP_X_>;
  let Constraints = "$a3 = $a3o" in
  def rr : KVX_INSTRUCTION
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
  def ri : KVX_INSTRUCTION_CV1_X
    <(outs SingleReg:$a1o), (ins SingleReg:$a1, SingleReg:$a2, Binary32:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR_FP_X_>;
  let Constraints = "$a3 = $a3o" in
  def rr : KVX_INSTRUCTION
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
  def ri : KVX_INSTRUCTION_CV1_Y
    <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, Binary32x2:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR_FP_Y_>;
  let Constraints = "$a3 = $a3o" in
  def rr : KVX_INSTRUCTION
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
  def ri : KVX_INSTRUCTION_CV1_Y
    <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, Binary16x4:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_AUXR_FP_Y_>;
  let Constraints = "$a3 = $a3o" in
  def rr : KVX_INSTRUCTION
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
  def ri : KVX_INSTRUCTION_CV1_X
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Binary32:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_FP_X_>;
  def rr : KVX_INSTRUCTION
    <(outs SingleReg:$a3), (ins SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4, $a5"),
     [/* no straightforward pattern */],
     MAU_FP>;
}

// multiclass MC_31_2 is used by:
//   defm FMULHW
multiclass MC_31_2<string OpcStr> {
  def ri : KVX_INSTRUCTION_CV1_X
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Binary32:$a3),
     !strconcat (OpcStr, " $a1 = $a2, $a3"),
     [/* no straightforward pattern */],
     MAU_FP_X_>;
  def rr : KVX_INSTRUCTION
    <(outs SingleReg:$a3), (ins SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
     !strconcat (OpcStr, "$a1$a2 $a3 = $a4, $a5"),
     [/* no straightforward pattern */],
     MAU_FP>;
}

// multiclass MC_33 is used by:
//   defm ALIGNO
multiclass MC_33<string OpcStr> {
  def reroi : KVX_INSTRUCTION
    <(outs QuadReg:$a1), (ins VectorRegE:$a2, VectorRegO:$a3, Unsigned6:$a4),
     !strconcat (OpcStr, " $a1 = $a2, $a3, $a4"),
     [/* no straightforward pattern */],
     BCU_TINY_AUXW_CRRP_RR>;
  def rorei : KVX_INSTRUCTION
    <(outs QuadReg:$a1), (ins VectorRegO:$a2, VectorRegE:$a3, Unsigned6:$a4),
     !strconcat (OpcStr, " $a1 = $a2, $a3, $a4"),
     [/* no straightforward pattern */],
     BCU_TINY_AUXW_CRRP_RR>;
  def reror : KVX_INSTRUCTION
    <(outs QuadReg:$a1), (ins VectorRegE:$a2, VectorRegO:$a3, SingleReg:$a4),
     !strconcat (OpcStr, " $a1 = $a2, $a3, $a4"),
     [/* no straightforward pattern */],
     BCU_TINY_AUXW_CRRP_ID>;
  def rorer : KVX_INSTRUCTION
    <(outs QuadReg:$a1), (ins VectorRegO:$a2, VectorRegE:$a3, SingleReg:$a4),
     !strconcat (OpcStr, " $a1 = $a2, $a3, $a4"),
     [/* no straightforward pattern */],
     BCU_TINY_AUXW_CRRP_ID>;
}

// multiclass MC_34 is used by:
//   defm ALIGNV
multiclass MC_34<string OpcStr> {
  def reroi : KVX_INSTRUCTION
    <(outs VectorReg:$a1), (ins VectorRegE:$a2, VectorRegO:$a3, Unsigned6:$a4),
     !strconcat (OpcStr, " $a1 = $a2, $a3, $a4"),
     [/* no straightforward pattern */],
     BCU_CRRP_CRWL_CRWH_RR>;
  def rorei : KVX_INSTRUCTION
    <(outs VectorReg:$a1), (ins VectorRegO:$a2, VectorRegE:$a3, Unsigned6:$a4),
     !strconcat (OpcStr, " $a1 = $a2, $a3, $a4"),
     [/* no straightforward pattern */],
     BCU_CRRP_CRWL_CRWH_RR>;
  def reror : KVX_INSTRUCTION
    <(outs VectorReg:$a1), (ins VectorRegE:$a2, VectorRegO:$a3, SingleReg:$a4),
     !strconcat (OpcStr, " $a1 = $a2, $a3, $a4"),
     [/* no straightforward pattern */],
     BCU_CRRP_CRWL_CRWH_ID>;
  def rorer : KVX_INSTRUCTION
    <(outs VectorReg:$a1), (ins VectorRegO:$a2, VectorRegE:$a3, SingleReg:$a4),
     !strconcat (OpcStr, " $a1 = $a2, $a3, $a4"),
     [/* no straightforward pattern */],
     BCU_CRRP_CRWL_CRWH_ID>;
}

// multiclass MC_35 is used by:
//   defm XCOPYV
let isMoveReg = 1 in
multiclass MC_35<string OpcStr> {
  def re : KVX_INSTRUCTION
    <(outs VectorReg:$a1), (ins VectorRegE:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */],
     BCU_CRRP_CRWL_CRWH_RR>;
  def ro : KVX_INSTRUCTION
    <(outs VectorReg:$a1), (ins VectorRegO:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */],
     BCU_CRRP_CRWL_CRWH_RR>;
}

// multiclass MC_36 is used by:
//   defm MOVEFO
multiclass MC_36<string OpcStr> {
  def re : KVX_INSTRUCTION
    <(outs QuadReg:$a1), (ins VectorRegE:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */],
     BCU_TINY_AUXW_CRRP_RR>;
  def ro : KVX_INSTRUCTION
    <(outs QuadReg:$a1), (ins VectorRegO:$a2),
     !strconcat (OpcStr, " $a1 = $a2"),
     [/* no straightforward pattern */],
     BCU_TINY_AUXW_CRRP_RR>;
}

// def FMM222W
class FP_PairedReg_PairedReg_PairedReg_Transp_Round_Silent <string OpcStr, InstrItinClass It>
: KVX_INSTRUCTION_CV2
    <(outs PairedReg:$M), (ins PairedReg:$O, PairedReg:$P, TransposeMod:$t, RoundingMod:$r, SilentMod:$s),
     !strconcat (OpcStr, "$t$r$s $M = $O, $P"), [], It>
{}

// def FMMA222W
// def FMMS222W
class FP_PairedReg_PairedReg_PairedReg_Transp_Round_Silent_Accumulate <string OpcStr, InstrItinClass It>
: KVX_INSTRUCTION_CV2
    <(outs PairedReg:$M_Out), (ins PairedReg:$O, PairedReg:$P, PairedReg:$M_In, TransposeMod:$t, RoundingMod:$r, SilentMod:$s),
     !strconcat (OpcStr, "$t$r$s $M_Out = $O, $P"), [], It>
{
  let Constraints = "$M_Out = $M_In";
}


def AWAIT : KVX_INSTRUCTION
  <(outs), (ins),
   "await",
   [/* no straightforward pattern */],
   ALL_ID>;

def SLEEP : KVX_INSTRUCTION
  <(outs), (ins),
   "sleep",
   [/* no straightforward pattern */],
   ALL_ID>;

def STOP : KVX_INSTRUCTION
  <(outs), (ins),
   "stop",
   [/* no straightforward pattern */],
   ALL_ID>;

def BARRIER : KVX_INSTRUCTION
  <(outs), (ins),
   "barrier",
   [/* no straightforward pattern */],
   ALL_ID>;

def TLBREAD : KVX_INSTRUCTION
  <(outs), (ins),
   "tlbread",
   [/* no straightforward pattern */],
   ALL_ID>;

def TLBPROBE : KVX_INSTRUCTION
  <(outs), (ins),
   "tlbprobe",
   [/* no straightforward pattern */],
   ALL_ID>;

def TLBWRITE : KVX_INSTRUCTION
  <(outs), (ins),
   "tlbwrite",
   [/* no straightforward pattern */],
   ALL_ID>;

def TLBDINVAL : KVX_INSTRUCTION
  <(outs), (ins),
   "tlbdinval",
   [/* no straightforward pattern */],
   ALL_ID>;

def TLBIINVAL : KVX_INSTRUCTION
  <(outs), (ins),
   "tlbiinval",
   [/* no straightforward pattern */],
   ALL_ID>;

let isTrap = 1, isTerminator = 1 in
def ERROP : KVX_INSTRUCTION
  <(outs), (ins),
   "errop",
   [(int_kvx_errop)],
   ALL_ID>;

let Uses = [RA], isBarrier = 1, isReturn = 1, isTerminator = 1 in
def RET : KVX_INSTRUCTION
  <(outs), (ins),
   "ret",
   [/* no straightforward pattern */],
   BCU>;

def RFE : KVX_INSTRUCTION
  <(outs), (ins),
   "rfe",
   [/* no straightforward pattern */],
   ALL_ID>;

let isBarrier = 1, isBranch = 1, isIndirectBranch = 1, isTerminator = 1 in
def IGOTO : KVX_INSTRUCTION
  <(outs), (ins SingleReg:$a1),
   "igoto $a1",
   [(brind i64:$a1)],
   BCU>;

let Defs = [RA, PM0, PM1, PM2, PM3, PM4, PM5, PM6, PM7, PCR, PMC, CS], isCall = 1, isIndirectBranch = 1 in
def ICALL : KVX_INSTRUCTION
  <(outs), (ins SingleReg:$a1),
   "icall $a1",
   [/* no straightforward pattern */],
   BCU>;

defm SCALL : MC_00<"scall">;

let isTerminator=1, hasSideEffects=1, isNotDuplicable=1, Defs = [LC,LE,LS] in
def LOOPDO : KVX_INSTRUCTION
  <(outs), (ins SingleReg:$a1, Pcrel17:$a2),
   "loopdo $a1, $a2",
   [/* no straightforward pattern */],
   ALL_ID>;

defm GET : I <"get", BCU_TINY_TINY_MAU_XNOP_RR, [GetReg], [], [],[],[SingleReg]>;

let Constraints = "$a1 = $a1o" in
def IGET : KVX_INSTRUCTION
  <(outs SingleReg:$a1o), (ins SingleReg:$a1),
   "iget $a1",
   [/* no straightforward pattern */],
   BCU_TINY_TINY_MAU_XNOP_ID>;

defm SET : MC_03<"set">;

defm RSWAP : MC_04<"rswap">;

let Constraints = "$a1 = $a1o" in
def WAITIT : KVX_INSTRUCTION
  <(outs SingleReg:$a1o), (ins SingleReg:$a1),
   "waitit $a1",
   [/* no straightforward pattern */],
   BCU_TINY_TINY_MAU_XNOP_ID>;

def SYNCGROUP : KVX_INSTRUCTION
  <(outs), (ins SingleReg:$a1),
   "syncgroup $a1",
   [/* no straightforward pattern */],
   BCU>;

let isBarrier = 1, isBranch = 1, isTerminator = 1 in
def GOTO : KVX_INSTRUCTION
  <(outs), (ins Pcrel27:$a1),
   "goto $a1",
   [(br bb:$a1)],
   BCU>;

let Defs = [RA, PM0, PM1, PM2, PM3, PM4, PM5, PM6, PM7, PCR, PMC, CS], isCall = 1 in
def CALL : KVX_INSTRUCTION
  <(outs), (ins Pcrel27:$a1),
   "call $a1",
   [/* no straightforward pattern */],
   BCU>;

let isBranch = 1, isTerminator = 1 in
def CB : KVX_INSTRUCTION
  <(outs), (ins SingleReg:$a2, Pcrel17:$a3, ScalarcondMod:$a1),
   "cb$a1 $a2 ? $a3",
   [/* no straightforward pattern */],
   BCU>;

defm LBZ : MC_LOADS<"lbz", SingleReg>;

defm LBS : MC_LOADS<"lbs", SingleReg>;

defm LHZ : MC_LOADS<"lhz", SingleReg>;

defm LHS : MC_LOADS<"lhs", SingleReg>;

defm LWZ : MC_LOADS<"lwz", SingleReg>;

defm LWS : MC_LOADS<"lws", SingleReg>;

defm LD : MC_LOADS<"ld", SingleReg>;

defm LQ : MC_LOADS<"lq", PairedReg>;

defm LO : MC_LOADS<"lo", QuadReg>;

defm LV : MC_LV<"xlo.u">, Requires<[IsV1]>;

defm XLO : MC_XLO, Requires<[IsV2]>;

defm SB : MC_STORES<"sb", SingleReg>;

defm SH : MC_STORES<"sh", SingleReg>;

defm SW : MC_STORES<"sw", SingleReg>;

defm SD : MC_STORES<"sd", SingleReg>;

defm SQ : MC_STORES<"sq", PairedReg>;

defm SO : MC_STORES<"so", QuadReg>;

defm SV : MC_SV<"xso">, Requires<[IsV1]>;

defm XSO : MC_XSO, Requires<[IsV2]>;

defm ACSWAPW : MC_0D<"acswapw">;

defm ACSWAPD : MC_0D<"acswapd">;

defm ACSWAPQ : ACSWAPQ_MC, Requires<[IsV2]>;

defm ALCLRW : MC_0E<"alclrw", i32, 2>;

defm ALCLRD : MC_0E<"alclrd", i64, 3>;

defm ALADDW : MC_0F<"aladdw">;

defm ALADDD : MC_0F<"aladdd">;

let mayLoad = 1 in
defm DTOUCHL : MC_10<"dtouchl">;

let hasSideEffects = 1 in
defm DINVALL : MC_10<"dinvall">;

let mayStore = 1 in
defm DZEROL : MC_10<"dzerol">, Requires<[IsV1]>;

let hasSideEffects = 1, mayLoad = 0, mayStore = 0 in
defm I1INVALS : MC_10<"i1invals">;

let hasSideEffects = 1 in
def D1INVAL : KVX_INSTRUCTION
  <(outs), (ins),
   "d1inval",
   [(int_kvx_d1inval)],
   LSU_LOAD>;

def I1INVAL : KVX_INSTRUCTION
  <(outs), (ins),
   "i1inval",
   [/* no straightforward pattern */],
   LSU_LOAD>;

let hasSideEffects = 1 in
def FENCE : KVX_INSTRUCTION
  <(outs), (ins),
   "fence",
   [/* no straightforward pattern */],
   LSU_LOAD>;

def NOP : KVX_INSTRUCTION
  <(outs), (ins),
   "nop",
   [/* no straightforward pattern */],
   ALU_NOP>;

defm STSUD : MC_17_SWITCH<"stsud">;

let isAdd = 1 in
defm ADDD : MC_11<"addd">;

defm SBFD : MC_11<"sbfd">;

let isCommutable = 1 in
defm ABDD : MC_12_SWITCH<"abdd">;

defm MIND : MC_11<"mind">;

defm MINUD : MC_11<"minud">;

defm MAXD : MC_11<"maxd">;

defm MAXUD : MC_11<"maxud">;

defm ANDD : MC_BINOP_64<"andd", and>;

defm NANDD : MC_11<"nandd">;

defm ORD : MC_BINOP_64<"ord", or>;

def norpfs : PatFrags<(ops node:$l, node:$r),
                       [(and (not node:$l), (not node:$r)),
                        (not (or node:$l, node:$r)),
                        (vnot (or node:$l, node:$r))]>;

defm NORD : MC_BINOP_64<"nord", norpfs>;

defm XORD : MC_BINOP_64<"xord", xor>;

def nxorpfs : PatFrags<(ops node:$l, node:$r),
                       [(not (xor node:$l, node:$r)),
                        (vnot (xor node:$l, node:$r))]>;

defm NXORD : MC_BINOP_64<"nxord", nxorpfs>;

def andnpfs : PatFrags<(ops node:$l, node:$r),
                       [(and (not node:$l), node:$r),
                        (and (vnot node:$l), node:$r)]>;

defm ANDND : MC_BINOP_64<"andnd", andnpfs>;

defm ORND : MC_11<"ornd">;

defm SBMM8 : MC_12_SWITCH<"sbmm8">;

defm SBMMT8 : MC_12_SWITCH<"sbmmt8">;

let isAdd = 1 in
defm ADDSD : ADD_SBF_SD_FAMILY<"addsd">;

let isAdd = 1 in {
defm ADDUSBO : MC_17_TINY<"addusbo">, Requires<[IsV2]>;
defm ADDUSD : MC_17_TINY<"addusd">, Requires<[IsV2]>;
defm ADDUSHQ : MC_17_TINY<"addushq">, Requires<[IsV2]>;
defm ADDUSW : MC_17_TINY<"addusw">, Requires<[IsV2]>;
defm ADDUSWP : MC_17_TINY<"adduswp">, Requires<[IsV2]>;
}

defm SBFSD : ADD_SBF_SD_FAMILY<"sbfsd">;

defm ADDX2D : MC_17_SWITCH<"addx2d">;

defm ADDX4D : MC_17_SWITCH<"addx4d">;

defm ADDX8D : MC_17_SWITCH<"addx8d">;

defm ADDX16D : MC_17_SWITCH<"addx16d">;

defm ADDX32D : MC_17_TINY<"addx32d">, Requires<[IsV2]>;

defm ADDX64D : MC_17_TINY<"addx64d">, Requires<[IsV2]>;

defm SBFX2D : MC_17_SWITCH<"sbfx2d">;

defm SBFX4D : MC_17_SWITCH<"sbfx4d">;

defm SBFX8D : MC_17_SWITCH<"sbfx8d">;

defm SBFX16D : MC_17_SWITCH<"sbfx16d">;

defm SBFX32D : MC_17_TINY<"sbfx32d">, Requires<[IsV2]>;

defm SBFX64D : MC_17_TINY<"sbfx64d">, Requires<[IsV2]>;

let isAdd = 1 in
defm ADDWD : MC_13_SWITCH<"addwd">;

defm SBFWD : MC_13_SWITCH<"sbfwd">;

let isAdd = 1 in
defm ADDUWD : MC_13_SWITCH<"adduwd">;

defm SBFUWD : MC_13_SWITCH<"sbfuwd">;

defm LANDD : MC_13<"landd">;

defm LNANDD : MC_13<"lnandd">;

defm LORD : MC_13<"lord">;

defm LNORD : MC_13<"lnord">;

defm STSUW : MC_13_SWITCH<"stsuw">; // ri variant cv2 only

let isAdd = 1 in
defm ADDW : MC_14<"addw">;

defm SBFW : MC_14<"sbfw">;

let isCommutable = 1 in
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
defm ADDSW : MC_13_SWITCH<"addsw">;

defm SBFSW : MC_13_SWITCH<"sbfsw">;

defm ADDX2W : MC_13_SWITCH<"addx2w">;

defm ADDX4W : MC_13_SWITCH<"addx4w">;

defm ADDX8W : MC_13_SWITCH<"addx8w">;

defm ADDX16W : MC_13_SWITCH<"addx16w">;

defm ADDX32W : MC_13_TINY<"addx32w">, Requires<[IsV2]>;

defm ADDX64W : MC_13_TINY<"addx64w">, Requires<[IsV2]>;

defm SBFX2W : MC_13_SWITCH<"sbfx2w">;

defm SBFX4W : MC_13_SWITCH<"sbfx4w">;

defm SBFX8W : MC_13_SWITCH<"sbfx8w">;

defm SBFX16W : MC_13_SWITCH<"sbfx16w">;

defm SBFX32W : MC_13_TINY<"sbfx32w">, Requires<[IsV2]>;

defm SBFX64W : MC_13_TINY<"sbfx64w">, Requires<[IsV2]>;

defm AVGW : MC_13_SWITCH<"avgw">;

defm AVGUW : MC_13_SWITCH<"avguw">;

defm AVGRW : MC_13_SWITCH<"avgrw">;

defm AVGRUW : MC_13_SWITCH<"avgruw">;

defm LANDW : MC_13<"landw">;

defm LNANDW : MC_13<"lnandw">;

defm LORW : MC_13<"lorw">;

defm LNORW : MC_13<"lnorw">;

let isAdd = 1 in
defm ADDWP : MC_17_TINY<"addwp">;

defm SBFWP : MC_17_TINY<"sbfwp">;

let isCommutable = 1 in
defm ABDWP : MC_17_SWITCH<"abdwp">;

defm MINWP : MC_17_TINY<"minwp">;

defm MINUWP : MC_17_TINY<"minuwp">;

defm MAXWP : MC_17_TINY<"maxwp">;

defm MAXUWP : MC_17_TINY<"maxuwp">;

defm ADDCWC : MC_17<"addwc.c">;

defm SBFCWC : MC_17<"sbfwc.c">;

let isAdd = 1 in
defm ADDSWP : MC_17_SWITCH<"addswp">;

defm SBFSWP : MC_17_SWITCH<"sbfswp">;

defm ADDX2WP : MC_17_SWITCH<"addx2wp">;

defm ADDX4WP : MC_17_SWITCH<"addx4wp">;

defm ADDX8WP : MC_17_SWITCH<"addx8wp">;

defm ADDX16WP : MC_17_SWITCH<"addx16wp">;

defm SBFX2WP : MC_17_SWITCH<"sbfx2wp">;

defm SBFX4WP : MC_17_SWITCH<"sbfx4wp">;

defm SBFX8WP : MC_17_SWITCH<"sbfx8wp">;

defm SBFX16WP : MC_17_SWITCH<"sbfx16wp">;

defm AVGWP : MC_17_SWITCH<"avgwp">;

defm AVGUWP : MC_17_SWITCH<"avguwp">;

defm AVGRWP : MC_17_SWITCH<"avgrwp">;

defm AVGRUWP : MC_17_SWITCH<"avgruwp">;

defm LANDWP : MC_17<"landwp">, Requires<[IsV1]>;

defm LNANDWP : MC_17<"lnandwp">, Requires<[IsV1]>;

defm LORWP : MC_17<"lorwp">, Requires<[IsV1]>;

defm LNORWP : MC_17<"lnorwp">, Requires<[IsV1]>;

let isAdd = 1 in
defm ADDHQ : MC_17_TINY<"addhq">;

let isAdd = 1 in
defm ADDBO : MC_17_TINY<"addbo">, Requires<[IsV2]>;

defm SBFBO : MC_17_TINY<"sbfbo">, Requires<[IsV2]>;

defm SBFHQ : MC_17_TINY<"sbfhq">;

let isCommutable = 1 in {
defm ABDBO : MC_17_TINY<"abdbo">, Requires<[IsV2]>;

defm ABDHQ : MC_17_SWITCH<"abdhq">;
}
defm MINBO : MC_17_TINY<"minbo">, Requires<[IsV2]>;

defm MINHQ : MC_17_TINY<"minhq">;

defm MINUBO : MC_17_TINY<"minubo">, Requires<[IsV2]>;

defm MINUHQ : MC_17_TINY<"minuhq">;

defm MAXBO : MC_17_TINY<"maxbo">, Requires<[IsV2]>;

defm MAXHQ : MC_17_TINY<"maxhq">;

defm MAXUBO : MC_17_TINY<"maxubo">, Requires<[IsV2]>;

defm MAXUHQ : MC_17_TINY<"maxuhq">;

let isAdd = 1 in
defm ADDCHCP : MC_17<"addhcp.c">, Requires<[IsV1]>;

defm SBFCHCP : MC_17<"sbfhcp.c">, Requires<[IsV1]>;

let isAdd = 1 in {
defm ADDSHQ : MC_17_SWITCH<"addshq">;
defm ADDSBO : MC_17_TINY<"addsbo">, Requires<[IsV2]>;
}

defm SBFSBO : MC_17_TINY<"sbfsbo">, Requires<[IsV2]>;

defm SBFSHQ : MC_17_SWITCH<"sbfshq">;

defm ADDX2BO : MC_17_TINY<"addx2bo">, Requires<[IsV2]>;

defm ADDX2HQ : MC_17_SWITCH<"addx2hq">;

defm ADDX4BO : MC_17_TINY<"addx4bo">, Requires<[IsV2]>;

defm ADDX4HQ : MC_17_SWITCH<"addx4hq">;

defm ADDX8BO : MC_17_TINY<"addx8bo">, Requires<[IsV2]>;

defm ADDX8HQ : MC_17_SWITCH<"addx8hq">;

defm ADDX16BO : MC_17_TINY<"addx16bo">, Requires<[IsV2]>;

defm ADDX16HQ : MC_17_SWITCH<"addx16hq">;

defm SBFX2BO : MC_17_TINY<"sbfx2bo">, Requires<[IsV2]>;

defm SBFX2HQ : MC_17_SWITCH<"sbfx2hq">;

defm SBFX4BO : MC_17_TINY<"sbfx4bo">, Requires<[IsV2]>;

defm SBFX4HQ : MC_17_SWITCH<"sbfx4hq">;

defm SBFX8BO : MC_17_TINY<"sbfx8bo">, Requires<[IsV2]>;

defm SBFX8HQ : MC_17_SWITCH<"sbfx8hq">;

defm SBFX16BO : MC_17_TINY<"sbfx16bo">, Requires<[IsV2]>;

defm SBFX16HQ : MC_17_SWITCH<"sbfx16hq">;

defm AVGBO : MC_17_TINY<"avgbo">, Requires<[IsV2]>;

defm AVGHQ : MC_17_SWITCH<"avghq">;

defm AVGUBO : MC_17_TINY<"avgubo">, Requires<[IsV2]>;

defm AVGUHQ : MC_17_SWITCH<"avguhq">;

defm AVGRBO : MC_17_TINY<"avgrbo">, Requires<[IsV2]>;

defm AVGRHQ : MC_17_SWITCH<"avgrhq">;

defm AVGRUBO : MC_17<"avgrubo">, Requires<[IsV2]>;

defm AVGRUHQ : MC_17_SWITCH<"avgruhq">;

defm LANDHQ : MC_17<"landhq">, Requires<[IsV1]>;

defm LNANDHQ : MC_17<"lnandhq">, Requires<[IsV1]>;

defm LORHQ : MC_17<"lorhq">, Requires<[IsV1]>;

defm LNORHQ : MC_17<"lnorhq">, Requires<[IsV1]>;

defm ADDX2WD : MC_13_SWITCH<"addx2wd">;

defm ADDX4WD : MC_13_SWITCH<"addx4wd">;

defm ADDX8WD : MC_13_SWITCH<"addx8wd">;

defm ADDX16WD : MC_13_SWITCH<"addx16wd">;

defm ADDX32WD : MC_13_TINY<"addx32wd">, Requires<[IsV2]>;

defm ADDX64WD : MC_13_TINY<"addx64wd">, Requires<[IsV2]>;

defm SBFX2WD : MC_13_SWITCH<"sbfx2wd">;

defm SBFX4WD : MC_13_SWITCH<"sbfx4wd">;

defm SBFX8WD : MC_13_SWITCH<"sbfx8wd">;

defm SBFX16WD : MC_13_SWITCH<"sbfx16wd">;

defm SBFX32WD : MC_13<"sbfx32wd">, Requires<[IsV2]>;

defm SBFX64WD : MC_13<"sbfx64wd">, Requires<[IsV2]>;

defm ADDX2UWD : MC_13_SWITCH<"addx2uwd">;

defm ADDX4UWD : MC_13_SWITCH<"addx4uwd">;

defm ADDX8UWD : MC_13_SWITCH<"addx8uwd">;

defm ADDX16UWD : MC_13_SWITCH<"addx16uwd">;

defm ADDX32UWD : MC_13_TINY<"addx32uwd">, Requires<[IsV2]>;

defm ADDX64UWD : MC_13_TINY<"addx64uwd">, Requires<[IsV2]>;

defm SBFX2UWD : MC_13_SWITCH<"sbfx2uwd">;

defm SBFX4UWD : MC_13_SWITCH<"sbfx4uwd">;

defm SBFX8UWD : MC_13_SWITCH<"sbfx8uwd">;

defm SBFX16UWD : MC_13_SWITCH<"sbfx16uwd">;

defm SBFX32UWD : MC_13_TINY<"sbfx32uwd">, Requires<[IsV2]>;

defm SBFX64UWD : MC_13_TINY<"sbfx64uwd">, Requires<[IsV2]>;

defm SBFUSBO : MC_17_TINY<"sbfusbo">, Requires<[IsV2]>;

defm SBFUSD : MC_17_TINY<"sbfusd">, Requires<[IsV2]>;

defm SBFUSHQ : MC_17_TINY<"sbfushq">, Requires<[IsV2]>;

defm SBFUSW : MC_17_TINY<"sbfusw">, Requires<[IsV2]>;

defm SBFUSWP : MC_17_TINY<"sbfuswp">, Requires<[IsV2]>;

let Defs = [CS], Uses = [CS] in
def ADDCD : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "addcd $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   ALU_FULL>;

let Defs = [CS] in
def SBFCD : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "sbfcd $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   ALU_FULL>;

let Defs = [CS], Uses = [CS] in
def ADDCDI : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "addcd.i $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   ALU_FULL>;

let Defs = [CS] in
def SBFCDI : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "sbfcd.i $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   ALU_FULL>;

def FNEGD : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fnegd $a1 = $a2",
   [(set f64:$a1, (fneg f64:$a2))],
   ALU_SWITCH_LITE_TINY>;

def FABSD : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fabsd $a1 = $a2",
   [(set f64:$a1, (fabs f64:$a2))],
   ALU_SWITCH_LITE_TINY>;

let Uses = [CS] in
def FSRECD : KVX_INSTRUCTION
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SilentMod:$a1),
   "fsrecd$a1 $a2 = $a3",
   [(set f64:$a2, (int_kvx_fsrec f64:$a3, SilentMod:$a1))],
   ALU_LITE>;

def FSRSRD : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fsrsrd $a1 = $a2",
   [(set f64:$a1, (int_kvx_fsrsr f64:$a2))],
   ALU_LITE>;

let Uses = [CS] in {
def FWIDENLWD : KVX_INSTRUCTION
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SilentMod:$a1),
   "fwidenlwd$a1 $a2 = $a3",
   [/* no straightforward pattern */],
   ALU_LITE>;

def FWIDENMWD : KVX_INSTRUCTION
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SilentMod:$a1),
   "fwidenmwd$a1 $a2 = $a3",
   [/* no straightforward pattern */],
   ALU_LITE>;

def FNARROWDW : KVX_INSTRUCTION
  <(outs SingleReg:$a3), (ins SingleReg:$a4, RoundingMod:$a1, SilentMod:$a2),
   "fnarrowdw$a1$a2 $a3 = $a4",
   [/* no straightforward pattern */],
   ALU_FULL>;
} // let Uses = [CS] in

def FNEGW : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fnegw $a1 = $a2",
   [(set f32:$a1, (fneg f32:$a2))],
   ALU_SWITCH_LITE_TINY>;

def FABSW : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fabsw $a1 = $a2",
   [(set f32:$a1, (fabs f32:$a2))],
   ALU_SWITCH_LITE_TINY>;

let Uses = [CS] in {
def FRECW : KVX_INSTRUCTION
  <(outs SingleReg:$a3), (ins SingleReg:$a4, RoundingMod:$a1, SilentMod:$a2),
   "frecw$a1$a2 $a3 = $a4",
   [/* no straightforward pattern */],
   ALU_FULL_SFU>;

def FRSRW : KVX_INSTRUCTION
  <(outs SingleReg:$a3), (ins SingleReg:$a4, RoundingMod:$a1, SilentMod:$a2),
   "frsrw$a1$a2 $a3 = $a4",
   [/* no straightforward pattern */],
   ALU_FULL_SFU>;

def FSRECW : KVX_INSTRUCTION
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SilentMod:$a1),
   "fsrecw$a1 $a2 = $a3",
   [(set f32:$a2, (int_kvx_fsrec f32:$a3, SilentMod:$a1))],
   ALU_LITE>;
}

def FSRSRW : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fsrsrw $a1 = $a2",
   [(set f32:$a1, (int_kvx_fsrsr f32:$a2))],
   ALU_LITE>;

let Uses = [CS] in {
def FWIDENLHW : KVX_INSTRUCTION
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SilentMod:$a1),
   "fwidenlhw$a1 $a2 = $a3",
   [/* no straightforward pattern */],
   ALU_LITE>;

def FWIDENMHW : KVX_INSTRUCTION
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SilentMod:$a1),
   "fwidenmhw$a1 $a2 = $a3",
   [/* no straightforward pattern */],
   ALU_LITE>;

def FNARROWWH : KVX_INSTRUCTION
  <(outs SingleReg:$a3), (ins SingleReg:$a4, RoundingMod:$a1, SilentMod:$a2),
   "fnarrowwh$a1$a2 $a3 = $a4",
   [/* no straightforward pattern */],
   ALU_LITE>;
} // let Uses = [CS] in

def FNEGWP : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fnegwp $a1 = $a2",
   [(set v2f32:$a1, (fneg v2f32:$a2))],
   ALU_SWITCH_LITE_TINY>;

def FABSWP : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fabswp $a1 = $a2",
   [(set v2f32:$a1, (fabs v2f32:$a2))],
   ALU_SWITCH_LITE_TINY>;

let Uses = [CS] in
def FSRECWP : KVX_INSTRUCTION
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SilentMod:$a1),
   "fsrecwp$a1 $a2 = $a3",
   [(set v2f32:$a2, (int_kvx_fsrec v2f32:$a3, SilentMod:$a1))],
   ALU_LITE>;

def FSRSRWP : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fsrsrwp $a1 = $a2",
   [(set v2f32:$a1, (int_kvx_fsrsr v2f32:$a2))],
   ALU_LITE>;

let Uses = [CS] in
def FWIDENLHWP : KVX_INSTRUCTION
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SilentMod:$a1),
   "fwidenlhwp$a1 $a2 = $a3",
   [/* no straightforward pattern */],
   ALU_LITE>;

let Uses = [CS] in
def FWIDENMHWP : KVX_INSTRUCTION
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SilentMod:$a1),
   "fwidenmhwp$a1 $a2 = $a3",
   [/* no straightforward pattern */],
   ALU_LITE>;

let Uses = [CS] in
def FNARROWDWP : KVX_INSTRUCTION
  <(outs SingleReg:$a3), (ins PairedReg:$a4, RoundingMod:$a1, SilentMod:$a2),
   "fnarrowdwp$a1$a2 $a3 = $a4",
   [/* no straightforward pattern */],
   ALU_FULL>;

def FNEGHQ : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fneghq $a1 = $a2",
   [(set v4f16:$a1, (fneg v4f16:$a2))],
   ALU_SWITCH_LITE_TINY>;

def FABSHQ : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "fabshq $a1 = $a2",
   [(set f16:$a1, (fabs f16:$a2))],
   ALU_SWITCH_LITE_TINY>;

let Uses = [CS] in
def FNARROWWHQ : KVX_INSTRUCTION
  <(outs SingleReg:$a3), (ins PairedReg:$a4, RoundingMod:$a1, SilentMod:$a2),
   "fnarrowwhq$a1$a2 $a3 = $a4",
   [/* no straightforward pattern */],
   ALU_LITE>;

let Constraints = "$a1 = $a1o" in
def INSF : KVX_INSTRUCTION
  <(outs SingleReg:$a1o), (ins SingleReg:$a1, SingleReg:$a2, Unsigned6:$a3, Unsigned6:$a4),
   "insf $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */],
   ALU_SWITCH_LITE_TINY>;

def EXTFZ : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2, Unsigned6:$a3, Unsigned6:$a4),
   "extfz $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */],
   ALU_SWITCH_LITE_TINY>;

def EXTFS : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2, Unsigned6:$a3, Unsigned6:$a4),
   "extfs $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */],
   ALU_SWITCH_LITE_TINY>;

def CLRF : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2, Unsigned6:$a3, Unsigned6:$a4),
   "clrf $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */],
   ALU_SWITCH_LITE_TINY>;

defm SATD : MC_18<"satd">, Requires<[IsV1]>;

defm SRSD : MC_18<"srsd">;

defm SLLD : MC_18_TINY<"slld">;

defm SRAD : MC_18_TINY<"srad">;

defm SRLD : MC_18_TINY<"srld">;

defm SLSD : MC_18<"slsd">;

defm SRSW : MC_18<"srsw">;

defm SLLW : MC_18_TINY<"sllw">;

defm SRAW : MC_18_TINY<"sraw">;

defm SRLW : MC_18_TINY<"srlw">;

defm SLSW : MC_18<"slsw">;

defm ROLW : MC_18<"rolw">;

defm RORW : MC_18<"rorw">;

defm SRSWPS : MC_18<"srswps">;

defm SLLWPS : MC_18_SWITCH<"sllwps">;

defm SRAWPS : MC_18_SWITCH<"srawps">;

defm SRLWPS : MC_18_SWITCH<"srlwps">;

defm SLSWPS : MC_18<"slswps">;

defm ROLWPS : MC_18<"rolwps">;

defm RORWPS : MC_18<"rorwps">;

defm SRSBOS : MC_18<"srsbos">, Requires<[IsV2]>;

defm SRSHQS : MC_18<"srshqs">;

defm SLLBOS : MC_18_TINY<"sllbos">, Requires<[IsV2]>;

defm SLLHQS : MC_18_SWITCH<"sllhqs">;

defm SRABOS : MC_18_TINY<"srabos">, Requires<[IsV2]>;

defm SRAHQS : MC_18_SWITCH<"srahqs">;

defm SRLBOS : MC_18_TINY<"srlbos">, Requires<[IsV2]>;

defm SRLHQS : MC_18_SWITCH<"srlhqs">;

defm SLSHQS : MC_18<"slshqs">;

defm COMPD : MC_1A<"compd">;

defm COMPW : MC_1B<"compw">;

defm COMPND : MC_1B<"compnd">, Requires<[IsV2]>;

defm COMPNW : MC_1B<"compnw">, Requires<[IsV2]>;

def COMPWD : KVX_INSTRUCTION
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, ComparisonMod:$a1),
   "compwd$a1 $a2 = $a3, $a4",
   [/* no straightforward pattern */],
   ALU_SWITCH_LITE_TINY>;

def COMPUWD : KVX_INSTRUCTION
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, ComparisonMod:$a1),
   "compuwd$a1 $a2 = $a3, $a4",
   [/* no straightforward pattern */],
   ALU_SWITCH_LITE_TINY>;

def COMPNWP : KVX_INSTRUCTION
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, ComparisonMod:$a1),
   "compnwp$a1 $a2 = $a3, $a4",
   [/* no straightforward pattern */],
   ALU_TINY>;

def COMPNBO : KVX_INSTRUCTION
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, ComparisonMod:$a1),
   "compnbo$a1 $a2 = $a3, $a4",
   [/* no straightforward pattern */],
   ALU_TINY>, Requires<[IsV2]>;

def COMPNHQ : KVX_INSTRUCTION
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, ComparisonMod:$a1),
   "compnhq$a1 $a2 = $a3, $a4",
   [/* no straightforward pattern */],
   ALU_TINY>;

defm CMOVED : MC_1C<"cmoved">;

let Constraints = "$a3 = $a3o" in
def CMOVEWP : KVX_INSTRUCTION
  <(outs SingleReg:$a3o), (ins SingleReg:$a2, SingleReg:$a3, SingleReg:$a4, SimplecondMod:$a1),
   "cmovewp$a1 $a2 ? $a3 = $a4",
   [/* no straightforward pattern */],
   ALU_SWITCH_LITE_TINY>;

let isAsCheapAsAMove = 1, isReMaterializable = 1, isMoveImm = 1, isPredicable = 1 in
defm MAKE : MC_1D<"make">;

defm PCREL : MC_1E<"pcrel">;

def CLZW : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "clzw $a1 = $a2",
   [(set i32:$a1, (ctlz i32:$a2))],
   ALU_LITE>;

def CLSW : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "clsw $a1 = $a2",
   [/* no straightforward pattern */],
   ALU_LITE>;

def CBSW : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "cbsw $a1 = $a2",
   [(set i32:$a1, (ctpop i32:$a2))],
   ALU_LITE>;

def CTZW : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "ctzw $a1 = $a2",
   [(set i32:$a1, (cttz i32:$a2))],
   ALU_LITE>;

def CLZD : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "clzd $a1 = $a2",
   [(set i64:$a1, (ctlz i64:$a2))],
   ALU_LITE>;

def CLSD : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "clsd $a1 = $a2",
   [/* no straightforward pattern */],
   ALU_LITE>;

def CBSD : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "cbsd $a1 = $a2",
   [(set i64:$a1, (ctpop i64:$a2))],
   ALU_LITE>;

def CTZD : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "ctzd $a1 = $a2",
   [(set i64:$a1, (cttz i64:$a2))],
   ALU_LITE>;

def CLZWP : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "clzwp $a1 = $a2",
   [(set v2i32:$a1, (ctlz v2i32:$a2))],
   ALU_LITE>;

def CLSWP : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "clswp $a1 = $a2",
   [/* no straightforward pattern */],
   ALU_LITE>;

def CBSWP : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "cbswp $a1 = $a2",
   [(set v2i32:$a1, (ctpop v2i32:$a2))],
   ALU_LITE>;

def CTZWP : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "ctzwp $a1 = $a2",
   [(set v2i32:$a1, (cttz v2i32:$a2))],
   ALU_LITE>;

def SXLHWP : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "sxlhwp $a1 = $a2",
   [/* no straightforward pattern */],
   ALU_SWITCH_LITE_TINY>;

def SXMHWP : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "sxmhwp $a1 = $a2",
   [/* no straightforward pattern */],
   ALU_SWITCH_LITE_TINY>;

def SXLBHQ : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "sxlbhq $a1 = $a2",
   [/* no straightforward pattern */],
   ALU_SWITCH_LITE_TINY>;

def SXMBHQ : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "sxmbhq $a1 = $a2",
   [/* no straightforward pattern */],
   ALU_SWITCH_LITE_TINY>;

let Constraints = "$a3 = $a3o" in
def CMOVEHQ : KVX_INSTRUCTION
  <(outs SingleReg:$a3o), (ins SingleReg:$a2, SingleReg:$a3, SingleReg:$a4, SimplecondMod:$a1),
   "cmovehq$a1 $a2 ? $a3 = $a4",
   [/* no straightforward pattern */],
   ALU_SWITCH_LITE_TINY>;

let Constraints = "$f = $r" in
def CMOVEBO : KVX_INSTRUCTION
  <(outs SingleReg:$r), (ins SingleReg:$c, SingleReg:$f, SingleReg:$t, SimplecondMod:$Mod),
   "cmovebo$Mod $c ? $f = $t",
   [(set v8i8:$r, (int_kvx_select_vec v8i8:$t, v8i8:$f, v8i8:$c, SimplecondMod:$Mod))],
   ALU_TINY>, Requires<[IsV2]>;

defm FCOMPNW : MC_1F_TINY<"fcompnw">, Requires<[IsV2]>;

defm FCOMPW : MC_1F<"fcompw">;

def FCOMPD : KVX_INSTRUCTION
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, FloatcompMod:$a1),
   "fcompd$a1 $a2 = $a3, $a4",
   [/* no straightforward pattern */],
   ALU_SWITCH_LITE_TINY>;

def FCOMPND : KVX_INSTRUCTION
  <(outs SingleReg:$r), (ins SingleReg:$lhs, SingleReg:$rhs, FloatcompMod:$m),
   "fcompnd$m $r = $lhs, $rhs",
   [/* no straightforward pattern */],
   ALU_TINY>, Requires<[IsV2]>;

def FCOMPNWP : KVX_INSTRUCTION
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, FloatcompMod:$a1),
   "fcompnwp$a1 $a2 = $a3, $a4",
   [/* no straightforward pattern */],
   ALU_SWITCH_LITE_TINY>;

def FCOMPNHQ : KVX_INSTRUCTION
  <(outs SingleReg:$a2), (ins SingleReg:$a3, SingleReg:$a4, FloatcompMod:$a1),
   "fcompnhq$a1 $a2 = $a3, $a4",
   [/* no straightforward pattern */],
   ALU_SWITCH_LITE_TINY>;

let Uses = [CS] in {
def FSDIVD : KVX_INSTRUCTION
  <(outs SingleReg:$a2), (ins PairedReg:$a3, SilentMod:$a1),
   "fsdivd$a1 $a2 = $a3",
   [/* no straightforward pattern */],
   ALU_LITE>;

def FCDIVD : KVX_INSTRUCTION
  <(outs SingleReg:$a2), (ins PairedReg:$a3, SilentMod:$a1),
   "fcdivd$a1 $a2 = $a3",
   [/* no straightforward pattern */],
   ALU_LITE>;

def FSDIVW : KVX_INSTRUCTION
  <(outs SingleReg:$a2), (ins PairedReg:$a3, SilentMod:$a1),
   "fsdivw$a1 $a2 = $a3",
   [/* no straightforward pattern */],
   ALU_LITE>;

def FCDIVW : KVX_INSTRUCTION
  <(outs SingleReg:$a2), (ins PairedReg:$a3, SilentMod:$a1),
   "fcdivw$a1 $a2 = $a3",
   [/* no straightforward pattern */],
   ALU_LITE>;

def FSDIVWP : KVX_INSTRUCTION
  <(outs SingleReg:$a2), (ins PairedReg:$a3, SilentMod:$a1),
   "fsdivwp$a1 $a2 = $a3",
   [/* no straightforward pattern */],
   ALU_LITE>;

def FCDIVWP : KVX_INSTRUCTION
  <(outs SingleReg:$a2), (ins PairedReg:$a3, SilentMod:$a1),
   "fcdivwp$a1 $a2 = $a3",
   [/* no straightforward pattern */],
   ALU_LITE>;
} // let Uses = [CS] in

let Constraints = "$out = $acc" in
class FFM_FAMILY_ACC <string OpcStr, RegisterClass RC_OUT, RegisterClass RC_IN, InstrItinClass itin>
  : KVX_INSTRUCTION <
    (outs RC_OUT:$out),
    (ins RC_OUT:$acc, RC_IN:$lhs, RC_IN:$rhs, RoundingMod:$r, SilentMod:$s),
    !strconcat (OpcStr, "$r$s $out = $lhs, $rhs"),
    [],
    itin>;

class FFM_FAMILY<string OpcStr, RegisterClass RC_OUT, RegisterClass RC_IN, InstrItinClass itin>
    : KVX_INSTRUCTION <
     (outs RC_OUT:$o),
     (ins RC_IN:$lhs, RC_IN:$rhs, RoundingMod:$r, SilentMod:$s),
     !strconcat (OpcStr, "$r$s $o = $lhs, $rhs"),
     [/* no straightforward pattern */],
     itin>;

let Predicates = [IsV2] in {
def FFDMAW : ROUNDING_SILENT_BINOP_FFDM<"ffdmaw", SingleReg, SingleReg, MAU_FP>;
def FFDMAWP: ROUNDING_SILENT_BINOP_FFDM<"ffdmawp", SingleReg, PairedReg, MAU_FP>;

def FFDMSW : ROUNDING_SILENT_BINOP_FFDM<"ffdmsw", SingleReg, SingleReg, MAU_FP>;
def FFDMSWP: ROUNDING_SILENT_BINOP_FFDM<"ffdmswp", SingleReg, PairedReg, MAU_FP>;

def FFMAWQ : FFM_FAMILY_ACC<"ffmawq", PairedReg, PairedReg, MAU_AUXR_FP>;
def FFMSWQ : FFM_FAMILY_ACC<"ffmswq", PairedReg, PairedReg, MAU_AUXR_FP>;

def FFDMDAW : FFM_FAMILY_ACC<"ffdmdaw", SingleReg, SingleReg, MAU_AUXR_FP>;
def FFDMDAWP : FFM_FAMILY_ACC<"ffdmdawp", SingleReg, PairedReg, MAU_AUXR_FP>;

def FFDMDSW : FFM_FAMILY_ACC<"ffdmdsw", SingleReg, SingleReg, MAU_AUXR_FP>;
def FFDMDSWP : FFM_FAMILY_ACC<"ffdmdswp", SingleReg, PairedReg, MAU_AUXR_FP>;

def FFDMASW : FFM_FAMILY_ACC<"ffdmasw", SingleReg, SingleReg, MAU_AUXR_FP>;
def FFDMASWP : FFM_FAMILY_ACC<"ffdmaswp", SingleReg, PairedReg, MAU_AUXR_FP>;

def FFDMSAW : ROUNDING_SILENT_TERNARY_AUXR_FP<"ffdmsaw", SingleReg, SingleReg, MAU_AUXR_FP>;
def FFDMSAWP : ROUNDING_SILENT_TERNARY_AUXR_FP<"ffdmsawp", SingleReg, PairedReg, MAU_AUXR_FP>;

def FMULWCP : CONJ_ROUNDING_SILENT_BINOP<"fmulwcp", PairedReg, PairedReg, MAU_FP>;

defm FFMAWC : I<"ffmawc", MAU_AUXR_FP, [SingleReg, SingleReg], [ConjugateMod, RoundingMod, SilentMod], [], [], [SingleReg], 1,
            [(set v2f32:$r, (int_kvx_ffmawc v2f32:$op0, v2f32:$op1, v2f32:$z, ConjugateMod:$mod0, RoundingMod:$mod1, SilentMod:$mod2))],
            0, 2>, Requires<[IsV2]>;

defm FFMSWC : I<"ffmswc", MAU_AUXR_FP, [SingleReg, SingleReg], [ConjugateMod, RoundingMod, SilentMod], [], [], [SingleReg], 1,
            [(set v2f32:$r, (int_kvx_ffmswc v2f32:$op0, v2f32:$op1, v2f32:$z, ConjugateMod:$mod0, RoundingMod:$mod1, SilentMod:$mod2))],
            0, 2>, Requires<[IsV2]>;


defm FFMAWCP : I<"ffmawcp", MAU_AUXR_FP, [PairedReg, PairedReg], [ConjugateMod, RoundingMod, SilentMod], [], [], [PairedReg], 1,
            [(set v4f32:$r, (int_kvx_ffmawcp v4f32:$op0, v4f32:$op1, v4f32:$z, ConjugateMod:$mod0, RoundingMod:$mod1, SilentMod:$mod2))],
            0, 2>, Requires<[IsV2]>;

defm FFMSWCP : I<"ffmswcp", MAU_AUXR_FP, [PairedReg, PairedReg], [ConjugateMod, RoundingMod, SilentMod], [], [], [PairedReg], 1,
            [(set v4f32:$r, (int_kvx_ffmswcp v4f32:$op0, v4f32:$op1, v4f32:$z, ConjugateMod:$mod0, RoundingMod:$mod1, SilentMod:$mod2))],
            0, 2>, Requires<[IsV2]>;


def XFSCALEWO : ROUNDING_SILENT_BINOP<"xfscalewo", VectorReg, VectorReg, SingleReg, BCU_CRRP_CRWL_CRWH_RR,
                [(set v256i1:$o, (int_kvx_xfscalewo v256i1:$lhs, i32:$rhs, RoundingMod:$r, SilentMod:$s))]>;

let Uses = [PCR] in {
def XCLAMPWO : TERNARY<"xclampwo", VectorReg, VectorReg, VectorReg, TCA_INT,
                [(set v256i1:$o, (int_kvx_xclampwo v256i1:$a, v256i1:$lhs, v256i1:$rhs))]>;

let isMoveReg = 1 in {
defm XCOPYV : I<"xcopyv", TCA_INT, [MatrixReg], [ShuffleVMod], [], [], [MatrixReg], 0,
                [(set v1024i1:$r, (int_kvx_xcopyv v1024i1:$op0, ShuffleVMod:$mod0))]>;
defm XCOPYX : I<"xcopyx", TCA_INT, [WideReg], [ShuffleXMod], [], [], [WideReg], 0,
                [(set v512i1:$r, (int_kvx_xcopyx v512i1:$op0, ShuffleXMod:$mod0))]>;
}

def XFFMA44HW : ROUNDING_SILENT_TERNARY<"xffma44hw", WideReg, VectorReg, VectorReg, TCA_FP,
                [(set v512i1:$o, (int_kvx_xffma44hw v256i1:$lhs, v256i1:$rhs, v512i1:$a, RoundingMod:$r, SilentMod:$s))]>;

def XFMMA484HW : ROUNDING_SILENT_TERNARY<"xfmma484hw", WideReg, WideReg, WideReg, TCA_FP,
                [(set v512i1:$o, (int_kvx_xfmma484hw v512i1:$a, v512i1:$lhs, v512i1:$rhs, RoundingMod:$r, SilentMod:$s))]>;

def XFNARROW44WH : ROUNDING_SILENT_UNARY<"xfnarrow44wh", VectorReg, WideReg, TCA_INT,
                [(set v256i1:$o, (int_kvx_xfnarrow44wh v512i1:$i, RoundingMod:$r, SilentMod:$s ))]>;

def XMADDIFWO : ROUNDING_SILENT_TERNARY<"xmaddifwo", VectorReg, VectorReg, VectorReg, TCA_INT,
                [(set v256i1:$o, (int_kvx_xmaddifwo v256i1:$a, v256i1:$lhs, v256i1:$rhs, RoundingMod:$r, SilentMod:$s))]>;

def XMSBFIFWO : ROUNDING_SILENT_TERNARY<"xmsbfifwo", VectorReg, VectorReg, VectorReg, TCA_INT,
                [(set v256i1:$o, (int_kvx_xmsbfifwo v256i1:$a, v256i1:$lhs, v256i1:$rhs, RoundingMod:$r, SilentMod:$s))]>;

def XMADD44BW0 : TERNARY<"xmadd44bw0", WideReg, VectorReg, VectorReg, TCA_INT,
                [(set v512i1:$o, (int_kvx_xmadd44bw0 v256i1:$lhs, v256i1:$rhs, v512i1:$a, ExtendMul_S))]>;

def XMADD44BW1 : TERNARY<"xmadd44bw1", WideReg, VectorReg, VectorReg, TCA_INT,
                [(set v512i1:$o, (int_kvx_xmadd44bw1 v256i1:$lhs, v256i1:$rhs, v512i1:$a, ExtendMul_S))]>;

def XMADDSU44BW0 : TERNARY<"xmaddsu44bw0", WideReg, VectorReg, VectorReg, TCA_INT,
                [(set v512i1:$o, (int_kvx_xmadd44bw0 v256i1:$lhs, v256i1:$rhs, v512i1:$a, ExtendMul_SU))]>;

def XMADDSU44BW1 : TERNARY<"xmaddsu44bw1", WideReg, VectorReg, VectorReg, TCA_INT,
                [(set v512i1:$o, (int_kvx_xmadd44bw1 v256i1:$lhs, v256i1:$rhs, v512i1:$a, ExtendMul_SU))]>;

def XMADDU44BW0 : TERNARY<"xmaddu44bw0", WideReg, VectorReg, VectorReg, TCA_INT,
                [(set v512i1:$o, (int_kvx_xmadd44bw0 v256i1:$lhs, v256i1:$rhs, v512i1:$a, ExtendMul_U))]>;

def XMADDU44BW1 : TERNARY<"xmaddu44bw1", WideReg, VectorReg, VectorReg, TCA_INT,
                [(set v512i1:$o, (int_kvx_xmadd44bw1 v256i1:$lhs, v256i1:$rhs, v512i1:$a, ExtendMul_U))]>;

def XMMA4164BW : TERNARY<"xmma4164bw", WideReg, WideReg, WideReg, TCA_INT,
                [(set v512i1:$o, (int_kvx_xmma4164bw v512i1:$a, v512i1:$lhs, v512i1:$rhs, UnSignMod_S))]>;

def XMMASU4164BW : TERNARY<"xmmasu4164bw", WideReg, WideReg, WideReg, TCA_INT,
                [(set v512i1:$o, (int_kvx_xmma4164bw v512i1:$a, v512i1:$lhs, v512i1:$rhs, UnSignMod_SU))]>;

def XMMAU4164BW : TERNARY<"xmmau4164bw", WideReg, WideReg, WideReg, TCA_INT,
                [(set v512i1:$o, (int_kvx_xmma4164bw v512i1:$a, v512i1:$lhs, v512i1:$rhs, UnSignMod_U))]>;

def XMMAUS4164BW : TERNARY<"xmmaus4164bw", WideReg, WideReg, WideReg, TCA_INT,
                [(set v512i1:$o, (int_kvx_xmma4164bw v512i1:$a, v512i1:$lhs, v512i1:$rhs, UnSignMod_US))]>;

def XMMA484BW : TERNARY<"xmma484bw", WideReg, VectorReg, VectorReg, TCA_INT,
                [(set v512i1:$o, (int_kvx_xmma484bw v256i1:$lhs, v256i1:$rhs, v512i1:$a, UnSignMod_S))]>;

def XMMASU484BW : TERNARY<"xmmasu484bw", WideReg, VectorReg, VectorReg, TCA_INT,
                [(set v512i1:$o, (int_kvx_xmma484bw v256i1:$lhs, v256i1:$rhs, v512i1:$a, UnSignMod_SU))]>;

def XMMAU484BW : TERNARY<"xmmau484bw", WideReg, VectorReg, VectorReg, TCA_INT,
                [(set v512i1:$o, (int_kvx_xmma484bw v256i1:$lhs, v256i1:$rhs, v512i1:$a, UnSignMod_U))]>;

def XMMAUS484BW : TERNARY<"xmmaus484bw", WideReg, VectorReg, VectorReg, TCA_INT,
                [(set v512i1:$o, (int_kvx_xmma484bw v256i1:$lhs, v256i1:$rhs, v512i1:$a, UnSignMod_US))]>;

def XSX48BW : UNARY<"xsx48bw", MatrixReg, VectorReg, TCA_INT,
                [(set v1024i1:$o, (int_kvx_xsx48bw v256i1:$i))]>;

def XZX48BW : UNARY<"xzx48bw", MatrixReg, VectorReg, TCA_INT,
                [(set v1024i1:$o, (int_kvx_xzx48bw v256i1:$i))]>;

def XTRUNC48WB : UNARY<"xtrunc48wb", VectorReg, MatrixReg, TCA_INT,
                [(set v256i1:$o, (int_kvx_xtrunc48wb v1024i1:$i))]>;
} // Uses = [PCR]

def DFLUSHSW : CACHE_OP<"dflushsw", SingleReg, LSU_STORE,
                [(int_kvx_dflushsw i64:$way, i64:$set, CacheLevelMod:$c)]>;

def DINVALSW : CACHE_OP<"dinvalsw", SingleReg, LSU_STORE,
                [(int_kvx_dinvalsw i64:$way, i64:$set, CacheLevelMod:$c)]>;

def DPURGESW : CACHE_OP<"dpurgesw", SingleReg, LSU_STORE,
                [(int_kvx_dpurgesw i64:$way, i64:$set, CacheLevelMod:$c)]>;

let AsmString = "xrecvo$mod0 $r" in
defm XRECVO : I <"xrecvo", ALU_TINY_CRWL_CRWH, [], [ChannelMod], [], [], [VectorReg], 0,
                  [(set v256i1:$r, (int_kvx_xrecvo ChannelMod:$mod0))]>;
let AsmString = "xsendo$mod0 $op0", hasSideEffects = 1, mayLoad = ?, mayStore = ? in
defm XSENDO : I <"xsendo", ALU_TINY_CRRP, [VectorReg], [ChannelMod], [], [], [], 0,
                  [(int_kvx_xsendo v256i1:$op0, ChannelMod:$mod0)]>;
let AsmString = "xsendrecvo$mod0$mod1 $op0, $r", hasSideEffects = 1, mayLoad = ?, mayStore = ? in
defm XSENDRECVO : I <"xsendrecvo", ALU_TINY_CRRP_CRWL_CRWH, [VectorReg], [ChannelMod, ChannelMod], [], [], [VectorReg], 0,
                  [(set v256i1:$r, (int_kvx_xsendrecvo v256i1:$op0, ChannelMod:$mod0, ChannelMod:$mod1))]>;

let isMoveReg = 1 in
defm XCOPYO : I<"xcopyo", BCU_CRRP_CRWL_CRWH_RR, [VectorReg], [], [], [], [VectorReg]>;
} // isV2

def FMIND : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "fmind $a1 = $a2, $a3",
   [],
   ALU_SWITCH_LITE_TINY>;

def FMAXD : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "fmaxd $a1 = $a2, $a3",
   [],
   ALU_SWITCH_LITE_TINY>;

def FMINW : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "fminw $a1 = $a2, $a3",
   [],
   ALU_SWITCH_LITE_TINY>;

def FMAXW : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "fmaxw $a1 = $a2, $a3",
   [],
   ALU_SWITCH_LITE_TINY>;

def FMINWP : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "fminwp $a1 = $a2, $a3",
   [],
   ALU_SWITCH_LITE_TINY>;

def FMAXWP : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "fmaxwp $a1 = $a2, $a3",
   [],
   ALU_SWITCH_LITE_TINY>;

def FMINHQ : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "fminhq $a1 = $a2, $a3",
   [],
   ALU_SWITCH_LITE_TINY>;

def FMAXHQ : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "fmaxhq $a1 = $a2, $a3",
   [],
   ALU_SWITCH_LITE_TINY>;

let Uses = [CS] in {
def FLOATD : KVX_INSTRUCTION
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "floatd$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */],
   MAU_FP>;

def FLOATWP : KVX_INSTRUCTION
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "floatwp$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */],
   MAU_FP>;

def FLOATW : KVX_INSTRUCTION
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "floatw$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */],
   MAU_FP>;

def FLOATUD : KVX_INSTRUCTION
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "floatud$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */],
   MAU_FP>;

def FLOATUWP : KVX_INSTRUCTION
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "floatuwp$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */],
   MAU_FP>;

def FLOATUW : KVX_INSTRUCTION
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "floatuw$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */],
   MAU_FP>;

def FIXEDD : KVX_INSTRUCTION
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fixedd$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */],
   MAU_FP>;

def FIXEDWP : KVX_INSTRUCTION
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fixedwp$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */],
   MAU_FP>;

def FIXEDW : KVX_INSTRUCTION
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fixedw$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */],
   MAU_FP>;

def FIXEDUD : KVX_INSTRUCTION
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fixedud$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */],
   MAU_FP>;

def FIXEDUWP : KVX_INSTRUCTION
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fixeduwp$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */],
   MAU_FP>;

def FIXEDUW : KVX_INSTRUCTION
  <(outs SingleReg:$a3), (ins SingleReg:$a4, Unsigned6:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fixeduw$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */],
   MAU_FP>;
}

defm MADDD : MC_20<"maddd">;

let Constraints = "$a1 = $a1o" in
def MSBFD : KVX_INSTRUCTION
  <(outs SingleReg:$a1o), (ins SingleReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "msbfd $a1 = $a2, $a3",
   [(set i64:$a1o, (sub i64:$a1, (mul i64:$a2, i64:$a3)))],
   MAU_AUXR_INT_AV1>;

defm MADDWP : MC_20<"maddwp">;

let Constraints = "$a1 = $a1o" in
def MSBFWP : KVX_INSTRUCTION
  <(outs SingleReg:$a1o), (ins SingleReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "msbfwp $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR_INT_AV1>;

defm MADDHQ : MC_20<"maddhq">;

let Constraints = "$a1 = $a1o" in
def MSBFHQ : KVX_INSTRUCTION
  <(outs SingleReg:$a1o), (ins SingleReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "msbfhq $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR_INT_AV1>;

let Constraints = "$a1 = $a1o" in
def MADDHWQ : KVX_INSTRUCTION
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "maddhwq $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR_INT_AV1>;

let Constraints = "$a1 = $a1o" in
def MSBFHWQ : KVX_INSTRUCTION
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "msbfhwq $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR_INT_AV1>;

let Constraints = "$a1 = $a1o" in
def MADDUHWQ : KVX_INSTRUCTION
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "madduhwq $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR_INT_AV1>;

let Constraints = "$a1 = $a1o" in
def MSBFUHWQ : KVX_INSTRUCTION
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "msbfuhwq $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR_INT_AV1>;

let Constraints = "$a1 = $a1o" in
def MADDSUHWQ : KVX_INSTRUCTION
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "maddsuhwq $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR_INT_AV1>;

let Constraints = "$a1 = $a1o" in
def MSBFSUHWQ : KVX_INSTRUCTION
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "msbfsuhwq $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR_INT_AV1>;

defm MADDDT : MC_21<"madddt">;

defm MADDUDT : MC_21<"maddudt">;

defm MADDSUDT : MC_21<"maddsudt">;

defm MADDUZDT : MC_21<"madduzdt">;

let Constraints = "$a1 = $a1o" in
def MSBFDT : KVX_INSTRUCTION
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "msbfdt $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR_INT_AV1>;

let Constraints = "$a1 = $a1o" in
def MSBFUDT : KVX_INSTRUCTION
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "msbfudt $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR_INT_AV1>;

let Constraints = "$a1 = $a1o" in
def MSBFSUDT : KVX_INSTRUCTION
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "msbfsudt $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR_INT_AV1>;

let Constraints = "$a1 = $a1o" in
def MSBFUZDT : KVX_INSTRUCTION
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "msbfuzdt $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR_INT_AV1>;

defm MULD : MC_22<"muld">;

defm MULDT : MC_23<"muldt">;

defm MULUDT : MC_23<"muludt">;

defm MULSUDT : MC_23<"mulsudt">;

defm CMULDT : MC_23<"cmuldt">;

let Constraints = "$a1 = $a1o" in
def CMULXDT : KVX_INSTRUCTION
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "cmulxdt $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR_INT_AV1>;

let Constraints = "$a1 = $a1o" in
def CMULGLXDT : KVX_INSTRUCTION
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "cmulglxdt $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR_INT_AV1>;

let Constraints = "$a1 = $a1o" in
def CMULGMXDT : KVX_INSTRUCTION
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "cmulgmxdt $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR_INT_AV1>;

let Constraints = "$a1 = $a1o" in
def CMULGHXDT : KVX_INSTRUCTION
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "cmulghxdt $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR_INT_AV1>;

defm CRCBELMW : MC_24<"crcbelmw">;

defm CRCBELLW : MC_24<"crcbellw">;

defm CRCLELMW : MC_24<"crclelmw">;

defm CRCLELLW : MC_24<"crclellw">;

defm DOT2WD : MC_22<"dot2wd">;

defm DOT2UWD : MC_22<"dot2uwd">;

defm DOT2SUWD : MC_22<"dot2suwd">;

defm DOT2W : MC_22<"dot2w">;

def DOT2WDP : KVX_INSTRUCTION
  <(outs PairedReg:$a1), (ins PairedReg:$a2, PairedReg:$a3),
   "dot2wdp $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_SWITCH_AUXR_EMPTY_INT>;

def DOT2UWDP : KVX_INSTRUCTION
  <(outs PairedReg:$a1), (ins PairedReg:$a2, PairedReg:$a3),
   "dot2uwdp $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_SWITCH_AUXR_EMPTY_INT>;

def DOT2SUWDP : KVX_INSTRUCTION
  <(outs PairedReg:$a1), (ins PairedReg:$a2, PairedReg:$a3),
   "dot2suwdp $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_SWITCH_AUXR_EMPTY_INT>;

def MULWQ : KVX_INSTRUCTION
  <(outs PairedReg:$a1), (ins PairedReg:$a2, PairedReg:$a3),
   "mulwq $a1 = $a2, $a3",
   [(set v4i32:$a1, (mul v4i32:$a2, v4i32:$a3))],
   MAU_SWITCH_AUXR_EMPTY_INT>;

def DOT2WZP : KVX_INSTRUCTION
  <(outs PairedReg:$a1), (ins PairedReg:$a2, PairedReg:$a3),
   "dot2wzp $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_SWITCH_AUXR_EMPTY_INT>;

defm MULWP : MC_22<"mulwp">;

defm MULHQ : MC_22<"mulhq">;

defm MULWC : MC_22<"mulwc">, Requires<[IsV1]>;

def MULCWC : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "mulwc.c $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_INT>, Requires<[IsV1]>;

def MULWDC : KVX_INSTRUCTION
  <(outs PairedReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "mulwdc $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_INT>, Requires<[IsV1]>;

def MULCWDC : KVX_INSTRUCTION
  <(outs PairedReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "mulwdc.c $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_INT>, Requires<[IsV1]>;

def MULHWQ : KVX_INSTRUCTION
  <(outs PairedReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "mulhwq $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_INT>;

def MULUHWQ : KVX_INSTRUCTION
  <(outs PairedReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "muluhwq $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_INT>;

def MULSUHWQ : KVX_INSTRUCTION
  <(outs PairedReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "mulsuhwq $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_INT>;

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
def MADDWDP : KVX_INSTRUCTION
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "maddwdp $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR_INT_AV1>;

let Constraints = "$a1 = $a1o" in
def MADDUWDP : KVX_INSTRUCTION
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "madduwdp $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR_INT_AV1>;

let Constraints = "$a1 = $a1o" in
def MADDSUWDP : KVX_INSTRUCTION
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "maddsuwdp $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR_INT_AV1>;

let Constraints = "$a1 = $a1o" in
def MMA212W : KVX_INSTRUCTION
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "mma212w $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR_INT_AV1>;

let Constraints = "$a1 = $a1o" in
def MSBFWDP : KVX_INSTRUCTION
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "msbfwdp $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR_INT_AV1>;

let Constraints = "$a1 = $a1o" in
def MSBFUWDP : KVX_INSTRUCTION
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "msbfuwdp $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR_INT_AV1>;

let Constraints = "$a1 = $a1o" in
def MSBFSUWDP : KVX_INSTRUCTION
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "msbfsuwdp $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR_INT_AV1>;

let Constraints = "$a1 = $a1o" in
def MMS212W : KVX_INSTRUCTION
  <(outs PairedReg:$a1o), (ins PairedReg:$a1, SingleReg:$a2, SingleReg:$a3),
   "mms212w $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_AUXR_INT_AV1>;

def MULWDP : KVX_INSTRUCTION
  <(outs PairedReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "mulwdp $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_INT>;

def MULUWDP : KVX_INSTRUCTION
  <(outs PairedReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "muluwdp $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_INT>;

def MULSUWDP : KVX_INSTRUCTION
  <(outs PairedReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "mulsuwdp $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_INT>;

def MM212W : KVX_INSTRUCTION
  <(outs PairedReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "mm212w $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_INT>;

let Uses = [CS] in {
defm FFMAD : MC_26<"ffmad">;

defm FFMAWP : MC_27<"ffmawp">;

defm FFMAHQ : MC_28<"ffmahq">;

defm FFMSD : MC_26<"ffmsd">;

defm FFMSWP : MC_27<"ffmswp">;

defm FFMSHQ : MC_28<"ffmshq">;

defm FMULD : MC_29<"fmuld">;

defm FMULHQ : MC_2B<"fmulhq">;

defm FMULWDP : MC_2C<"fmulwdp">;

defm FMULHWQ : MC_2D<"fmulhwq">;

def FMULWQ : KVX_INSTRUCTION
  <(outs PairedReg:$a3), (ins PairedReg:$a4, PairedReg:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fmulwq$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */],
   MAU_SWITCH_AUXR_EMPTY_FP>;

defm FMULWC : MC_2AM<"fmulwc">;

defm FMULWDC : MC_2C<"fmulwdc">, Requires<[IsV1]>;

defm FMULCWDC : MC_2C<"fmulwdc.c">, Requires<[IsV1]>;

let isAdd = 1 in {
defm FADDD : MC_29<"faddd">;

defm FADDHO : I <"faddho", MAU_FP, [PairedReg, PairedReg], [RoundingMod, SilentMod], [], [], [PairedReg]>;

defm FADDHQ : MC_2B<"faddhq">;

defm FADDDP : I <"fadddp", MAU_SWITCH_AUXR_EMPTY_FP, [PairedReg, PairedReg], [RoundingMod, SilentMod], [], [], [PairedReg], 0,
                 [(set v2f64:$r, (int_kvx_fadd v2f64:$op0, v2f64:$op1, RoundingMod:$mod0, SilentMod:$mod1))]>;

defm FADDWQ : I <"faddwq", MAU_SWITCH_AUXR_EMPTY_FP, [PairedReg, PairedReg], [RoundingMod, SilentMod], [], [], [PairedReg], 0,
                 [(set v4f32:$r, (int_kvx_fadd v4f32:$op0, v4f32:$op1, RoundingMod:$mod0, SilentMod:$mod1))]>;
}

defm FADDDC : I <"fadddc.c", MAU_SWITCH_AUXR_EMPTY_FP, [PairedReg, PairedReg], [RoundingMod, SilentMod], [], [], [PairedReg], 0,
                 [(set v2f64:$r, (int_kvx_faddc v2f64:$op0, v2f64:$op1, conjugate_c, RoundingMod:$mod0, SilentMod:$mod1))]>;

defm FADDWCP : I <"faddwcp.c", MAU_SWITCH_AUXR_EMPTY_FP, [PairedReg, PairedReg], [RoundingMod, SilentMod], [], [], [PairedReg], 0,
                [(set v4f32:$r, (int_kvx_faddc v4f32:$op0, v4f32:$op1, conjugate_c, RoundingMod:$mod0, SilentMod:$mod1))]>;

defm FSBFD : MC_29<"fsbfd">;

defm FSBFHQ : MC_2B<"fsbfhq">;

defm FSBFHO : I <"fsbfho", MAU_FP, [PairedReg, PairedReg], [RoundingMod, SilentMod], [], [], [PairedReg]>;

defm FSBFDP : I <"fsbfdp", MAU_SWITCH_AUXR_EMPTY_FP, [PairedReg, PairedReg], [RoundingMod, SilentMod], [], [], [PairedReg], 0,
                [(set v2f64:$r, (int_kvx_fsbf v2f64:$op0, v2f64:$op1, RoundingMod:$mod0, SilentMod:$mod1))]>;

defm FSBFDC : I <"fsbfdc.c", MAU_SWITCH_AUXR_EMPTY_FP, [PairedReg, PairedReg], [RoundingMod, SilentMod], [], [], [PairedReg], 0,
                [(set v2f64:$r, (int_kvx_fsbfc v2f64:$op0, v2f64:$op1, conjugate_c, RoundingMod:$mod0, SilentMod:$mod1))]>;

defm FSBFWQ : I <"fsbfwq", MAU_SWITCH_AUXR_EMPTY_FP, [PairedReg, PairedReg], [RoundingMod, SilentMod], [], [], [PairedReg], 0,
                 [(set v4f32:$r, (int_kvx_fsbf v4f32:$op0, v4f32:$op1, RoundingMod:$mod0, SilentMod:$mod1))]>;

defm FSBFWCP : I <"fsbfwcp.c", MAU_SWITCH_AUXR_EMPTY_FP, [PairedReg, PairedReg], [RoundingMod, SilentMod], [], [], [PairedReg], 0,
                 [(set v4f32:$r, (int_kvx_fsbfc v4f32:$op0, v4f32:$op1, conjugate_c, RoundingMod:$mod0, SilentMod:$mod1))]>;

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

defm FDOT2WD : MC_29<"fdot2wd">;

def FDOT2WZP : KVX_INSTRUCTION
  <(outs PairedReg:$a3), (ins PairedReg:$a4, PairedReg:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fdot2wzp$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */],
   MAU_SWITCH_AUXR_EMPTY_FP>;

def FDOT2WDP : KVX_INSTRUCTION
  <(outs PairedReg:$a3), (ins PairedReg:$a4, PairedReg:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fdot2wdp$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */],
   MAU_SWITCH_AUXR_EMPTY_FP>;

let Constraints = "$a3 = $a3o" in
def FMMA212W : KVX_INSTRUCTION
  <(outs PairedReg:$a3o), (ins PairedReg:$a3, SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fmma212w$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */],
   MAU_AUXR_FP>;

let Constraints = "$a3 = $a3o" in
def FMMS212W : KVX_INSTRUCTION
  <(outs PairedReg:$a3o), (ins PairedReg:$a3, SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fmms212w$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */],
   MAU_AUXR_FP>;

def FMM212W : KVX_INSTRUCTION
  <(outs PairedReg:$a3), (ins SingleReg:$a4, SingleReg:$a5, RoundingMod:$a1, SilentMod:$a2),
   "fmm212w$a1$a2 $a3 = $a4, $a5",
   [/* no straightforward pattern */],
   MAU_INT>;
} // let Uses = [CS] in

let isMoveReg = 1 in
def COPYQ : KVX_INSTRUCTION
  <(outs PairedReg:$a1), (ins SingleReg:$a2, SingleReg:$a3),
   "copyq $a1 = $a2, $a3",
   [/* no straightforward pattern */],
   MAU_INT>;

let isMoveReg = 1 in
def COPYO : KVX_INSTRUCTION
  <(outs QuadReg:$a1), (ins QuadReg:$a2),
   "copyo $a1 = $a2",
   [/* no straightforward pattern */],
   LSU_AUXR_AUXW_LOAD>;

let Uses = [PCR] in {
defm MOVETQ : MC_XMOVETQ<"xmovetq", ALU_LITE_CRWL, ALU_LITE_CRWH>, Requires<[IsV1]>;

defm XMOVETQ : MC_XMOVETQ<"xmovetq", ALU_TINY_CRWL, ALU_TINY_CRWH>, Requires<[IsV2]>;

defm ALIGNO : MC_33<"aligno">, Requires<[IsV1]>;

defm ALIGNV : MC_34<"alignv">, Requires<[IsV1]>;

def XMT44D : KVX_INSTRUCTION
  <(outs MatrixReg:$a1), (ins MatrixReg:$a2),
   "xmt44d $a1 = $a2",
   [(set v1024i1:$a1, (int_kvx_xmt44d v1024i1:$a2))],
   TCA_INT>;
let Predicates = [IsV1] in {
def MMA484BW : KVX_INSTRUCTION
  <(outs WideReg:$a1), (ins WideReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "xmma484bw $a1 = $a2, $a3, $a4",
   [(set v512i1:$a1, (int_kvx_xmma484bw v256i1:$a3, v256i1:$a4, v512i1:$a2, UnSignMod_S))],
   TCA_INT>;

def XMMA484UBW : KVX_INSTRUCTION
  <(outs WideReg:$a1), (ins WideReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "xmma484ubw $a1 = $a2, $a3, $a4",
   [(set v512i1:$a1, (int_kvx_xmma484bw v256i1:$a3, v256i1:$a4, v512i1:$a2, UnSignMod_U))],
   TCA_INT>;

def XMMA484SUBW : KVX_INSTRUCTION
  <(outs WideReg:$a1), (ins WideReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "xmma484subw $a1 = $a2, $a3, $a4",
   [(set v512i1:$a1, (int_kvx_xmma484bw v256i1:$a3, v256i1:$a4, v512i1:$a2, UnSignMod_SU))],
   TCA_INT>;

def XMMA484USBW : KVX_INSTRUCTION
  <(outs WideReg:$a1), (ins WideReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "xmma484usbw $a1 = $a2, $a3, $a4",
   [(set v512i1:$a1, (int_kvx_xmma484bw v256i1:$a3, v256i1:$a4, v512i1:$a2, UnSignMod_US))],
   TCA_INT>;
} // [IsV1]

def MMA444HBD0 : KVX_INSTRUCTION
  <(outs MatrixReg:$a1), (ins MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "mma444hbd0 $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */],
   TCA_INT>, Requires<[IsV1]>;

def MMA444UHBD0 : KVX_INSTRUCTION
  <(outs MatrixReg:$a1), (ins MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "mma444uhbd0 $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */],
   TCA_INT>, Requires<[IsV1]>;

def MMA444SUHBD0 : KVX_INSTRUCTION
  <(outs MatrixReg:$a1), (ins MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "mma444suhbd0 $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */],
   TCA_INT>, Requires<[IsV1]>;

def MMA444USHBD0 : KVX_INSTRUCTION
  <(outs MatrixReg:$a1), (ins MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "mma444ushbd0 $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */],
   TCA_INT>, Requires<[IsV1]>;

def MMA444HBD1 : KVX_INSTRUCTION
  <(outs MatrixReg:$a1), (ins MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "mma444hbd1 $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */],
   TCA_INT>, Requires<[IsV1]>;

def MMA444UHBD1 : KVX_INSTRUCTION
  <(outs MatrixReg:$a1), (ins MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "mma444uhbd1 $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */],
   TCA_INT>, Requires<[IsV1]>;

def MMA444SUHBD1 : KVX_INSTRUCTION
  <(outs MatrixReg:$a1), (ins MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "mma444suhbd1 $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */],
   TCA_INT>, Requires<[IsV1]>;

def MMA444USHBD1 : KVX_INSTRUCTION
  <(outs MatrixReg:$a1), (ins MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "mma444ushbd1 $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */],
   TCA_INT>, Requires<[IsV1]>;

def MMA444HD : KVX_INSTRUCTION
  <(outs MatrixReg:$a1), (ins MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "mma444hd $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */],
   TCA_INT>;

def MMA444UHD : KVX_INSTRUCTION
  <(outs MatrixReg:$a1), (ins MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "mma444uhd $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */],
   TCA_INT>;

def MMA444SUHD : KVX_INSTRUCTION
  <(outs MatrixReg:$a1), (ins MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "mma444suhd $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */],
   TCA_INT>;

def MMA444USHD : KVX_INSTRUCTION
  <(outs MatrixReg:$a1), (ins MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "mma444ushd $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */],
   TCA_INT>, Requires<[IsV1]>;

let Uses = [PCR, CS] in {
def FMMA242HW0 : KVX_INSTRUCTION
  <(outs BlockReg0M4:$a1), (ins WideReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "fmma242hw0 $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */],
   TCA_FP>, Requires<[IsV1]>;

def FMMA242HW1 : KVX_INSTRUCTION
  <(outs BlockReg1M4:$a1), (ins WideReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "fmma242hw1 $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */],
   TCA_FP>, Requires<[IsV1]>;

def FMMA242HW2 : KVX_INSTRUCTION
  <(outs BlockReg2M4:$a1), (ins WideReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "fmma242hw2 $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */],
   TCA_FP>, Requires<[IsV1]>;

def FMMA242HW3 : KVX_INSTRUCTION
  <(outs BlockReg3M4:$a1), (ins WideReg:$a2, VectorReg:$a3, VectorReg:$a4),
   "fmma242hw3 $a1 = $a2, $a3, $a4",
   [/* no straightforward pattern */],
   TCA_FP>, Requires<[IsV1]>;
} // let Uses = [PCR, CS] in

def CONVDHV0 : KVX_INSTRUCTION
  <(outs BlockRegE:$a3), (ins MatrixReg:$a4, RoundintMod:$a1, SaturateMod:$a2),
   "convdhv0$a1$a2 $a3 = $a4",
   [/* no straightforward pattern */],
   TCA_INT>, Requires<[IsV1]>;

def CONVDHV1 : KVX_INSTRUCTION
  <(outs BlockRegO:$a3), (ins MatrixReg:$a4, RoundintMod:$a1, SaturateMod:$a2),
   "convdhv1$a1$a2 $a3 = $a4",
   [/* no straightforward pattern */],
   TCA_INT>, Requires<[IsV1]>;

def CONVWBV0 : KVX_INSTRUCTION
  <(outs CoproReg0M4:$a3), (ins MatrixReg:$a4, RoundintMod:$a1, SaturateMod:$a2),
   "convwbv0$a1$a2 $a3 = $a4",
   [/* no straightforward pattern */],
   TCA_INT>, Requires<[IsV1]>;

def CONVWBV1 : KVX_INSTRUCTION
  <(outs CoproReg1M4:$a3), (ins MatrixReg:$a4, RoundintMod:$a1, SaturateMod:$a2),
   "convwbv1$a1$a2 $a3 = $a4",
   [/* no straightforward pattern */],
   TCA_INT>, Requires<[IsV1]>;

def CONVWBV2 : KVX_INSTRUCTION
  <(outs CoproReg2M4:$a3), (ins MatrixReg:$a4, RoundintMod:$a1, SaturateMod:$a2),
   "convwbv2$a1$a2 $a3 = $a4",
   [/* no straightforward pattern */],
   TCA_INT>;

def CONVWBV3 : KVX_INSTRUCTION
  <(outs CoproReg3M4:$a3), (ins MatrixReg:$a4, RoundintMod:$a1, SaturateMod:$a2),
   "convwbv3$a1$a2 $a3 = $a4",
   [/* no straightforward pattern */],
   TCA_INT>, Requires<[IsV1]>;

def FSCALEWV : KVX_INSTRUCTION
  <(outs VectorReg:$a4), (ins VectorReg:$a5, RoundingMod:$a1, SilentMod:$a2, RectifyMod:$a3),
   "fscalewv$a1$a2$a3 $a4 = $a5",
   [/* no straightforward pattern */],
   TCA_INT>, Requires<[IsV1]>;

let Uses = [CS, PCR] in
def FNARROWWHV : KVX_INSTRUCTION
  <(outs VectorReg:$a3), (ins WideReg:$a4, RoundingMod:$a1, SilentMod:$a2),
   "fnarrow44wh$a1$a2 $a3 = $a4",
   [(set v256i1:$a3, (int_kvx_xfnarrow44wh WideReg:$a4, RoundingMod:$a1, SilentMod:$a2))],
   TCA_INT>, Requires<[IsV1]>;
} // Uses = [PCR]

let isPredicable = 1 in
def COPYD : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "copyd $a1 = $a2",
   [/* no straightforward pattern */],
   ALU_TINY>;

let AddedComplexity = 2 in
def NOTD : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "notd $a1 = $a2",
   [(set i64:$a1, (not i64:$a2))],
   ALU_TINY>;

def NEGD : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "negd $a1 = $a2",
   [(set i64:$a1, (ineg i64:$a2))],
   ALU_TINY>;

def ABSD : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "absd $a1 = $a2",
   [(set i64:$a1, (abs i64:$a2))],
   ALU_SWITCH_LITE_TINY>;

def ZXBD : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "zxbd $a1 = $a2",
   [(set i64:$a1, (zext i8:$a2))],
   ALU_TINY>;

def SXBD : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "sxbd $a1 = $a2",
   [(set i64:$a1, (sext i8:$a2))],
   ALU_SWITCH_LITE_TINY>;

def ZXHD : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "zxhd $a1 = $a2",
   [(set i64:$a1, (zext i16:$a2))],
   ALU_SWITCH_LITE_TINY>;

def SXHD : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "sxhd $a1 = $a2",
   [(set i64:$a1, (sext i16:$a2))],
   ALU_SWITCH_LITE_TINY>;

def ZXWD : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "zxwd $a1 = $a2",
   [(set i64:$a1, (zext i32:$a2))],
   ALU_TINY>;

def SXWD : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "sxwd $a1 = $a2",
   [(set i64:$a1, (sext i32:$a2))],
   ALU_SWITCH_LITE_TINY>;

def SATDH : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "satdh $a1 = $a2",
   [/* no straightforward pattern */],
   ALU_LITE>;

def SATDW : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "satdw $a1 = $a2",
   [/* no straightforward pattern */],
   ALU_LITE>;

def COPYW : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "copyw $a1 = $a2",
   [/* no straightforward pattern */],
   ALU_TINY>;

def NOTW : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "notw $a1 = $a2",
   [(set i32:$a1, (not i32:$a2))],
   ALU_TINY>;

def NEGW : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "negw $a1 = $a2",
   [(set i32:$a1, (ineg i32:$a2))],
   ALU_TINY>;

def ABSW : KVX_INSTRUCTION
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "absw $a1 = $a2",
   [(set i32:$a1, (abs i32:$a2))],
   ALU_SWITCH_LITE_TINY>;

def NEGWP : KVX_INSTRUCTION_X
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "negwp $a1 = $a2",
   [(set v2i32:$a1, (vineg v2i32:$a2))],
   ALU_TINY_X_>;

def ABSWP : KVX_INSTRUCTION_X
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "abswp $a1 = $a2",
   [(set v2i32:$a1, (abs v2i32:$a2))],
   ALU_SWITCH_LITE_TINY_X_>;

def NEGHQ : KVX_INSTRUCTION_X
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "neghq $a1 = $a2",
   [(set v4i16:$a1, (vineg v4i16:$a2))],
   ALU_TINY_X_>;

def NEGBO : KVX_INSTRUCTION_X
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "negbo $a1 = $a2",
   [(set v8i8:$a1, (vineg v8i8:$a2))],
   ALU_TINY_X_>, Requires<[IsV2]>;

def ABSHQ : KVX_INSTRUCTION_X
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "abshq $a1 = $a2",
   [(set v4i16:$a1, (abs v4i16:$a2))],
   ALU_SWITCH_LITE_TINY_X_>;

def ABSBO : KVX_INSTRUCTION_X
  <(outs SingleReg:$a1), (ins SingleReg:$a2),
   "absbo $a1 = $a2",
   [(set v8i8:$a1, (abs v8i8:$a2))],
   ALU_TINY_X_>, Requires<[IsV2]>;

defm COPYV : MC_35<"xcopyo">, Requires<[IsV1]>;

let isMoveReg = 1 in {
defm MOVEFO : MC_36<"xmovefo">, Requires<[IsV1]>;
defm XMOVEFO : I <"xmovefo", BCU_TINY_AUXW_CRRP_RR, [VectorReg], [],[],[], [QuadReg]>, Requires<[IsV2]>;
}

let Predicates = [IsV2] in {
// TODO: Marking as commutable should allow patterns to
// match rhs or lhs immediates, but that does not seem
// to work as it does with isAdd attribute.
let isCommutable = 1 in {
defm ABDSBO : MC_17_TINY<"abdsbo">;
defm ABDSHQ : MC_17_TINY<"abdshq">;
defm ABDSW  : MC_17_TINY<"abdsw">;
defm ABDSWP : MC_17_TINY<"abdswp">;
defm ABDSD : MC_17_TINY<"abdsd">;
}
defm ABSSBO : I </*asm=*/"abssbo", /*itin=*/ALU_TINY_X_, /*Ops=*/[SingleReg], /*Mods=*/[],
                 /*MemOps=*/[], /*CC=*/[], /*Out=*/[SingleReg], /*inplace =*/ 0, /*pattern =*/
                 [(set v8i8:$r, (abs (ssubsat immAllZerosV, v8i8:$op0)))], /*IsAtomicSwap = */ 0,
                 /*added complexity */ 2>;

defm ABSSHQ : I </*asm=*/"absshq", /*itin=*/ALU_TINY_X_, /*Ops=*/[SingleReg], /*Mods=*/[],
                 /*MemOps=*/[], /*CC=*/[], /*Out=*/[SingleReg], /*inplace =*/ 0, /*pattern =*/
                 [(set v4i16:$r, (abs (ssubsat immAllZerosV, v4i16:$op0)))], /*IsAtomicSwap = */ 0,
                 /*added complexity */ 2>;

defm ABSSW  : I </*asm=*/"abssw", /*itin=*/ALU_TINY_X_, /*Ops=*/[SingleReg], /*Mods=*/[],
                 /*MemOps=*/[], /*CC=*/[], /*Out=*/[SingleReg], /*inplace =*/ 0, /*pattern =*/
                 [(set i32:$r, (abs (ssubsat 0, i32:$op0)))], /*IsAtomicSwap = */ 0,
                 /*added complexity */ 2>;

defm ABSSWP : I </*asm=*/"absswp", /*itin=*/ALU_TINY_X_, /*Ops=*/[SingleReg], /*Mods=*/[],
                 /*MemOps=*/[], /*CC=*/[], /*Out=*/[SingleReg], /*inplace =*/ 0, /*pattern =*/
                 [(set v2i32:$r, (abs (ssubsat immAllZerosV, v2i32:$op0)))], /*IsAtomicSwap = */ 0,
                 /*added complexity */ 2>;

defm ABSSD : I </*asm=*/"abssd", /*itin=*/ALU_TINY_X_, /*Ops=*/[SingleReg], /*Mods=*/[],
                 /*MemOps=*/[], /*CC=*/[], /*Out=*/[SingleReg], /*inplace =*/ 0, /*pattern =*/
                 [(set i64:$r, (abs (ssubsat 0, i64:$op0)))], /*IsAtomicSwap = */ 0,
                 /*added complexity */ 2>;

}

let Uses = [CS] in {
def FMM222W : FP_PairedReg_PairedReg_PairedReg_Transp_Round_Silent
  <"fmm222w", MAU_FP>, Requires<[IsV2]>;

def FMMA222W : FP_PairedReg_PairedReg_PairedReg_Transp_Round_Silent_Accumulate
  <"fmma222w", MAU_AUXR_FP>, Requires<[IsV2]>;

def FMMS222W : FP_PairedReg_PairedReg_PairedReg_Transp_Round_Silent_Accumulate
  <"fmms222w", MAU_AUXR_FP>, Requires<[IsV2]>;
} // let Uses = [CS] in

defm SLSBOS : MC_18<"slsbos">, Requires<[IsV2]>;
defm SLUSBOS : MC_18<"slusbos">, Requires<[IsV2]>;
defm SLUSD : MC_18<"slusd">, Requires<[IsV2]>;
defm SLUSHQS : MC_18<"slushqs">, Requires<[IsV2]>;
defm SLUSW : MC_18<"slusw">, Requires<[IsV2]>;
defm SLUSWPS : MC_18<"sluswps">, Requires<[IsV2]>;

def NEGSBO : KVX_INSTRUCTION_X
  <(outs SingleReg:$o), (ins SingleReg:$i),
   "negsbo $o = $i", [(set v8i8:$o, (vineg_ssat v8i8:$i))], ALU_TINY_X_>, Requires<[IsV2]>;

def NEGSD : KVX_INSTRUCTION_X
  <(outs SingleReg:$o), (ins SingleReg:$i),
  "negsd $o = $i", [(set i64:$o, (ssubsat 0, i64:$i))], ALU_TINY_X_>, Requires<[IsV2]>;

def NEGSHQ : KVX_INSTRUCTION_X
  <(outs SingleReg:$o), (ins SingleReg:$i),
   "negshq $o = $i", [(set v4i16:$o, (vineg_ssat v4i16:$i))], ALU_TINY_X_>, Requires<[IsV2]>;

def NEGSW : KVX_INSTRUCTION_X
  <(outs SingleReg:$o), (ins SingleReg:$i),
  "negsw $o = $i", [(set i32:$o, (ssubsat 0, i32:$i))], ALU_TINY_X_>, Requires<[IsV2]>;

def NEGSWP : KVX_INSTRUCTION_X
  <(outs SingleReg:$o), (ins SingleReg:$i),
   "negswp $o = $i", [(set v2i32:$o, (vineg_ssat v2i32:$i))], ALU_TINY_X_>, Requires<[IsV2]>;

let Predicates = [IsV2] in {
defm ALW : CV2_ATOMIC_LOAD<"alw", int_kvx_alw, i32>;
defm ALD : CV2_ATOMIC_LOAD<"ald", int_kvx_ald, i64>;
defm ASW : CV2_ATOMIC_STORE<"asw", int_kvx_asw, i32>;
defm ASD : CV2_ATOMIC_STORE<"asd", int_kvx_asd, i64>;

let isCommutable = true in {
defm XFMAXHX: I</*asm=*/"xfmaxhx", /*itin=*/TCA_FP, /*Ops=*/[VectorReg, VectorReg], /*Mods=*/[], /*MemOps=*/[], /*CC=*/[], /*Out=*/[VectorReg], /*InPlace=*/0,
  /*pattern=*/ [(set v256i1:$r, (int_kvx_xfmaxhx VectorReg:$op0, VectorReg:$op1))]>;
defm XFMINHX: I</*asm=*/"xfminhx", /*itin=*/TCA_FP, /*Ops=*/[VectorReg, VectorReg], /*Mods=*/[], /*MemOps=*/[], /*CC=*/[], /*Out=*/[VectorReg], /*InPlace=*/0,
  /*pattern=*/ [(set v256i1:$r, (int_kvx_xfminhx VectorReg:$op0, VectorReg:$op1))]>;
}

defm XSPLATOV: I</*asm=*/"xsplatov", /*itin=*/TCA_INT, /*Ops=*/[VectorReg], /*Mods=*/[ShuffleVMod], /*MemOps=*/[], /*CC=*/[], /*Out=*/[MatrixReg], /*InPlace=*/0,
  /*pattern=*/ [(set v1024i1:$r, (int_kvx_xsplatov v256i1:$op0, ShuffleVMod:$mod0))]>;

defm XSPLATOX: I</*asm=*/"xsplatox", /*itin=*/TCA_INT, /*Ops=*/[VectorReg], /*Mods=*/[ShuffleXMod], /*MemOps=*/[], /*CC=*/[], /*Out=*/[WideReg], /*InPlace=*/0,
  /*pattern=*/ [(set v512i1:$r, (int_kvx_xsplatox v256i1:$op0, ShuffleXMod:$mod0))]>;

defm XSPLATDO: XSPLATDO_MC;

let hasSideEffects = 1, mayLoad = ?, mayStore = ? in {
defm DPURGEL: DCACHE_MC <"dpurgel", int_kvx_dpurgel>;
defm DFLUSHL: DCACHE_MC <"dflushl", int_kvx_dflushl>;
}

defm ZXLBHQ : I</*asm=*/"zxlbhq", /*itin=*/ALU_TINY, /*Ops=*/[SingleReg], /*Mods=*/[], /*MemOps=*/[], /*CC=*/[], /*Out=*/[SingleReg], /*InPlace=*/0,
  /*pattern=*/ [(set v4i16:$r, (zext v4i8:$op0))]>;

defm ZXMBHQ : I</*asm=*/"zxmbhq", /*itin=*/ALU_TINY, /*Ops=*/[SingleReg], /*Mods=*/[], /*MemOps=*/[], /*CC=*/[], /*Out=*/[SingleReg], /*InPlace=*/0,
  /*pattern=*/ [(set v4i16:$r, (zext (v4i8( extract_subvector v8i8:$op0, (i64 4)))))]>;

defm ZXLHWP : I</*asm=*/"zxlhwp", /*itin=*/ALU_TINY, /*Ops=*/[SingleReg], /*Mods=*/[], /*MemOps=*/[], /*CC=*/[], /*Out=*/[SingleReg], /*InPlace=*/0,
  /*pattern=*/ [(set v2i32:$r, (zext v2i16:$op0))]>;

defm ZXMHWP : I</*asm=*/"zxmhwp", /*itin=*/ALU_TINY, /*Ops=*/[SingleReg], /*Mods=*/[], /*MemOps=*/[], /*CC=*/[], /*Out=*/[SingleReg], /*InPlace=*/0,
  /*pattern=*/ [(set v2i32:$r, (zext (v2i16( extract_subvector v4i16:$op0, (i64 2)))))]>;

defm STSUHQ: MC_17_TINY <"stsuhq", [(set v4i16:$r, (int_kvx_stsu v4i16:$op0, v4i16:$op1))]>;

defm STSUWP: MC_17_TINY <"stsuwp", [(set v2i32:$r, (int_kvx_stsu v2i32:$op0, v2i32:$op1))]>;

defm XALIGNO : I</*asm=*/"xaligno", /*itin=*/BCU_CRRP_CRWL_CRWH_RR, /*Ops=*/[BufferReg, SingleReg], /*Mods=*/[], /*MemOps=*/[], /*CC=*/[], /*Out=*/[VectorReg],
                 /*InPlace=*/0, /*pattern=*/ [(set v256i1:$r, (int_kvx_xalign512o BufferReg:$op0, SingleReg:$op1))]>;

def : Pat <(v256i1(int_kvx_xalign1024o BufferReg:$op0, i64:$op1)),
           (XALIGNO BufferReg:$op0, SingleReg:$op1)>;

defm XACCESSO : I</*asm=*/"xaccesso", /*itin=*/BCU_TINY_AUXW_CRRP_RR, /*Ops=*/[BufferReg, SingleReg], /*Mods=*/[], /*MemOps=*/[], /*CC=*/[], /*Out=*/[QuadReg],
                 /*InPlace=*/0, /*pattern=*/ [(set v4i64:$r, (int_kvx_xaccess512o BufferReg:$op0, SingleReg:$op1))]>;

def : Pat <(v4i64(int_kvx_xaccess1024o BufferReg:$op0, i64:$op1)),
           (XACCESSO BufferReg:$op0, SingleReg:$op1)>;
} // let Predicates = [IsV2]

defvar FxList = [PS, PCR, CS, CSIT, IPE, MEN, PMC, TCR, ILE, ILL, ILR, MMC, TEL, TEH, IXC, DC, MES, WS,
       DC0, DC1, DC2, DC3, PMC2, SPS_PL0, SPS_PL1, SPS_PL2, SPS_PL3, ES_PL0, ES_PL1, ES_PL2,
       ES_PL3, SYOW, HTOW, ITOW, DOW, MOW, PSOW, TPCC_PL0, TPCC_PL1, TPCC_PL2, TPCC_PL3, SPS,
       ES, TPCC];

defvar AloneList = [PS,     MMC, SPS_PL0, SPS_PL1, SPS_PL2, SPS_PL3,    SYOW,    HTOW,
      ITOW,     DOW,     MOW,    PSOW,     SPS];

defvar FxNotCV1List = [TPCM0, TPCM1, DBA2, DBA3, DWA2, DWA3, TPCM2, TPCMC, PM4, PM5, PM6, PM7,
          SRHPC, FRCC, SID_PL0, SID_PL1, SID_PL2, SID_PL3, SR1_PL0, SR1_PL1, SR1_PL2,
          SR1_PL3, SID, SR1, IXC, DC0, DC1, DC2, DC3, PMC2, TPCC_PL0, TPCC_PL1,
          TPCC_PL2, TPCC_PL3, TPCC];

defvar FxSideEffectsList = [PCR, CS, PM0, PM1, PM2, PM3, PM4, PM5, PM6, PM7];

foreach Reg = FxList in {
defvar Preds = !cond(!not(!empty(!filter(i, FxNotCV1List, !eq(i, Reg)))): [IsV2],
                     !eq(DC, Reg): [IsV1],
                     true: []<Predicate>);

defvar Sched = !cond(!not(!empty(!filter(i, AloneList, !eq(i, Reg)))): ALL_ID,
                     true: BCU);

defvar SideEffects = !cond(!not(!empty(!filter(i, FxSideEffectsList, !eq(i, Reg)))):1,
                           true: ?);

defvar FpExcept = !eq(CS, Reg);

defvar RegNum = !cast<int>(Reg.HWEncoding);

let mayRaiseFPException = FpExcept, mayLoad = SideEffects, mayStore = SideEffects, isAsCheapAsAMove = 1, Uses = [Reg], Defs = [Reg], Predicates = Preds, hasSideEffects = SideEffects in {
def WFXL_ # Reg : KVX_INSTRUCTION <
          (outs),
          (ins SingleReg:$op),
          "wfxl $" # Reg.AsmName # ", $op",
          [(int_kvx_wfx (i32 RegNum), i64:$op, (i32 0))],
           Sched>;

def WFXM_ # Reg : KVX_INSTRUCTION <
          (outs),
          (ins SingleReg:$op),
          "wfxm $" # Reg.AsmName # ", $op",
          [(int_kvx_wfx (i32 RegNum), i64:$op, (i32 1))],
           Sched>;
}
}
