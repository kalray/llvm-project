//===-- KVXFloatingPoint.td --------------------------------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

def DefaultShift : PatLeaf<(i64 0)>;

def truncstoref16 : PatFrag<(ops node:$val, node:$ptr),
                            (truncstore node:$val, node:$ptr)> {
  let IsStore = 1;
  let MemoryVT = f16;
}

// Store
defm : StorePat<store, f16, SingleReg, 1, SHp, SHri10, SHrr>;
defm : StorePatNode<truncstoref16, f32, SingleReg, 1, SHp, SHri10, SHrr,
                    (FNARROWWH SingleReg:$val, rounding_, silent_)>;
defm : StorePatNode<truncstoref16, f64, SingleReg, 1, SHp, SHri10, SHrr,
                    (FNARROWWH (FNARROWDW SingleReg:$val, rounding_, silent_),
                      rounding_, silent_)>;

defm : StorePat<store, f32, SingleReg, 2, SWp, SWri10, SWrr>;
defm : StorePatNode<truncstoref32, f64, SingleReg, 2, SWp, SWri10, SWrr,
                    (FNARROWDW SingleReg:$val, rounding_, silent_)>;
defm : StorePat<store, v2f16, SingleReg, 2, SWp, SWri10, SWrr>;

defm : StorePat<store, f64, SingleReg, 3, SDp, SDri10, SDrr>;
defm : StorePat<store, v2f32, SingleReg, 3, SDp, SDri10, SDrr>;
defm : StorePat<store, v4f16, SingleReg, 3, SDp, SDri10, SDrr>;

defm : StorePat<store, v4f32, PairedReg, 4, SQp, SQri10, SQrr>;
defm : StorePat<store, v2f64, PairedReg, 4, SQp, SQri10, SQrr>;

// Load
def loadf16 : PatFrag<(ops node:$ptr), (f16 (load node:$ptr))>;
def loadf32 : PatFrag<(ops node:$ptr), (f32 (load node:$ptr))>;
def loadf64 : PatFrag<(ops node:$ptr), (f64 (load node:$ptr))>;
def loadv4f16 : PatFrag<(ops node:$ptr), (v4f16 (load node:$ptr))>;
def loadv2f32 : PatFrag<(ops node:$ptr), (v2f32 (load node:$ptr))>;
def loadv4f32 : PatFrag<(ops node:$ptr), (v4f32 (load node:$ptr))>;
def loadv2f64 : PatFrag<(ops node:$ptr), (v2f64 (load node:$ptr))>;

defm : LoadPat<loadf16, f16, 1, LHZp, LHZri10, LHZrr, variant_>;
defm : LoadPat<loadf32, f32, 2, LWZp, LWZri10, LWZrr, variant_>;
defm : LoadPat<loadv2f16, v2f16, 2, LWZp, LWZri10, LWZrr, variant_>;
defm : LoadPat<loadf64, f64, 3, LDp, LDri10, LDrr, variant_>;
defm : LoadPat<loadv2f32, v2f32, 3, LDp, LDri10, LDrr, variant_>;
defm : LoadPat<loadv4f16, v4f16, 3, LDp, LDri10, LDrr, variant_>;
defm : LoadPat<loadv4f32, v4f32, 4, LQp, LQri10, LQrr, variant_>;
defm : LoadPat<loadv2f64, v2f64, 4, LQp, LQri10, LQrr, variant_>;

// 16 bits
def : BITCAST<f16, i16, SingleReg>;
def : BITCAST<i16, f16, SingleReg>;

// 32 bits
def : BITCAST<f32, i32, SingleReg>;
def : BITCAST<i32, f32, SingleReg>;
def : BITCAST<v2i16, f32, SingleReg>;
def : BITCAST<f32, v2i16, SingleReg>;
def : BITCAST<v2f16, i32, SingleReg>;
def : BITCAST<i32, v2f16, SingleReg>;
def : BITCAST<v2f16, v2i16, SingleReg>;
def : BITCAST<v2i16, v2f16, SingleReg>;

// 64 bits
def : BITCAST<f64, i64, SingleReg>;
def : BITCAST<i64, f64, SingleReg>;
def : BITCAST<v4i16, f64, SingleReg>;
def : BITCAST<f64, v4i16, SingleReg>;
def : BITCAST<v2i32, f64, SingleReg>;
def : BITCAST<f64, v2i32, SingleReg>;
def : BITCAST<v2f32, f64, SingleReg>;
def : BITCAST<f64, v2f32, SingleReg>;
def : BITCAST<v2f32, i64, SingleReg>;
def : BITCAST<i64, v2f32, SingleReg>;
def : BITCAST<v2i32, v2f32, SingleReg>;
def : BITCAST<v2f32, v2i32, SingleReg>;
def : BITCAST<i64, v4f16, SingleReg>;
def : BITCAST<v4f16, i64, SingleReg>;
def : BITCAST<v2i32, v4f16, SingleReg>;
def : BITCAST<v4f16, v2i32, SingleReg>;
def : BITCAST<v4i16, v4f16, SingleReg>;
def : BITCAST<v4f16, v4i16, SingleReg>;

// 128 bits
def : BITCAST<v2i64, v4f32, PairedReg>;
def : BITCAST<v4f32, v2i64, PairedReg>;
def : BITCAST<v2f64, v2i64, PairedReg>;
def : BITCAST<v2i64, v2f64, PairedReg>;
def : BITCAST<v4f32, v4i32, PairedReg>;
def : BITCAST<v4i32, v4f32, PairedReg>;

// FPU Insns

// FABS, see KVXInstrInfo.td
// FADDC -> TODO
// FADD
def FADDH : REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE_BINARY16X4
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Binary16:$a3),
     "faddhq $a1 = $a2, $a3",
     [(set f16:$a1, (fadd f16:$a2, Binary16:$a3))],
     MAU_Y>;
def : Pat<(fadd f32:$rs1, Binary32:$rs2), (FADDWri SingleReg:$rs1, Binary32:$rs2)>;
def : Pat<(fadd f64:$rs1, Binary64:$rs2), (FADDDri SingleReg:$rs1, Binary64:$rs2)>;
def : Pat<(fadd f16:$rs1, f16:$rs2), (FADDHQrr SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fadd f32:$rs1, f32:$rs2), (FADDWrr SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fadd f64:$rs1, f64:$rs2), (FADDDrr SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fadd v2f16:$rs1, v2f16:$rs2), (FADDHQrr SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fadd v4f16:$rs1, v4f16:$rs2), (FADDHQrr SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fadd v2f32:$rs1, v2f32:$rs2), (FADDWPrr SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fadd v4f32:$rs1, v4f32:$rs2), (FADDWQ PairedReg:$rs1, PairedReg:$rs2, rounding_, silent_)>;
def : Pat<(fadd v2f64:$rs1, v2f64:$rs2), (FADDDP PairedReg:$rs1, PairedReg:$rs2, rounding_, silent_)>;
// FCDIV -> TODO
// FCOMP ->
multiclass FCOMP<SDNode SetCC, Floatcomp Cmp, bit SwapOperands> {
  def : Pat<(i32 (SetCC f16:$rz, f16:$ry)),
    !if(SwapOperands,
     (FCOMPNHQ SingleReg:$ry, SingleReg:$rz, Cmp),
     (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, Cmp)
    )>;
  def : Pat<(i64 (SetCC f16:$rz, f16:$ry)),
    !if(SwapOperands,
     (FCOMPNHQ SingleReg:$ry, SingleReg:$rz, Cmp),
     (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, Cmp)
    )>;

  def : Pat<(i32 (SetCC f32:$rz, f32:$ry)),
    !if(SwapOperands,
     (FCOMPWrr SingleReg:$ry, SingleReg:$rz, Cmp),
     (FCOMPWrr SingleReg:$rz, SingleReg:$ry, Cmp)
    )>;
  def : Pat<(i64 (SetCC f32:$rz, f32:$ry)),
    !if(SwapOperands,
     (FCOMPWrr SingleReg:$ry, SingleReg:$rz, Cmp),
     (FCOMPWrr SingleReg:$rz, SingleReg:$ry, Cmp)
    )>;

  def : Pat<(i32 (SetCC f64:$rz, f64:$ry)),
    !if(SwapOperands,
     (FCOMPD SingleReg:$ry, SingleReg:$rz, Cmp),
     (FCOMPD SingleReg:$rz, SingleReg:$ry, Cmp)
    )>;
  def : Pat<(i64 (SetCC f64:$rz, f64:$ry)),
    !if(SwapOperands,
     (FCOMPD SingleReg:$ry, SingleReg:$rz, Cmp),
     (FCOMPD SingleReg:$rz, SingleReg:$ry, Cmp)
    )>;
}

// Using -ffast-math generates the following setcc patterns
defm : FCOMP<seteq, floatcomp_oeq, 0>;
defm : FCOMP<setgt, floatcomp_olt, 1>;
defm : FCOMP<setge, floatcomp_oge, 0>;
defm : FCOMP<setlt, floatcomp_olt, 0>;
defm : FCOMP<setle, floatcomp_oge, 1>;
defm : FCOMP<setne, floatcomp_one, 0>;
// Ordered comparisons
defm : FCOMP<setoeq, floatcomp_oeq, 0>;
defm : FCOMP<setogt, floatcomp_olt, 1>;
defm : FCOMP<setoge, floatcomp_oge, 0>;
defm : FCOMP<setolt, floatcomp_olt, 0>;
defm : FCOMP<setole, floatcomp_oge, 1>;
defm : FCOMP<setone, floatcomp_one, 0>;
def : Pat<(i32 (seto f16:$rz, f16:$ry)), (ORWrr (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_oge), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_olt))>;
def : Pat<(i32 (seto f32:$rz, f32:$ry)), (ORWrr (FCOMPWrr SingleReg:$rz, SingleReg:$ry, floatcomp_oge), (FCOMPWrr SingleReg:$rz, SingleReg:$ry, floatcomp_olt))>;
def : Pat<(i32 (seto f64:$rz, f64:$ry)), (ORWrr (FCOMPD   SingleReg:$rz, SingleReg:$ry, floatcomp_oge), (FCOMPD   SingleReg:$rz, SingleReg:$ry, floatcomp_olt))>;
def : Pat<(i64 (seto f32:$rz, f32:$ry)), (ORDrr (FCOMPWrr SingleReg:$rz, SingleReg:$ry, floatcomp_oge), (FCOMPWrr SingleReg:$rz, SingleReg:$ry, floatcomp_olt))>;
def : Pat<(i64 (seto f64:$rz, f64:$ry)), (ORDrr (FCOMPD   SingleReg:$rz, SingleReg:$ry, floatcomp_oge), (FCOMPD   SingleReg:$rz, SingleReg:$ry, floatcomp_olt))>;
// Unordered comparisons
defm : FCOMP<setueq, floatcomp_ueq, 0>;
defm : FCOMP<setugt, floatcomp_ult, 1>;
defm : FCOMP<setuge, floatcomp_uge, 0>;
defm : FCOMP<setult, floatcomp_ult, 0>;
defm : FCOMP<setule, floatcomp_uge, 1>;
defm : FCOMP<setune, floatcomp_une, 0>;
def : Pat<(i32 (setuo f16:$rz, f16:$ry)), (ANDWrr (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_uge), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_ult))>;
def : Pat<(i32 (setuo f32:$rz, f32:$ry)), (ANDWrr (FCOMPWrr SingleReg:$rz, SingleReg:$ry, floatcomp_uge), (FCOMPWrr SingleReg:$rz, SingleReg:$ry, floatcomp_ult))>;
def : Pat<(i32 (setuo f64:$rz, f64:$ry)), (ANDWrr (FCOMPD   SingleReg:$rz, SingleReg:$ry, floatcomp_uge), (FCOMPD   SingleReg:$rz, SingleReg:$ry, floatcomp_ult))>;
def : Pat<(i64 (setuo f32:$rz, f32:$ry)), (ANDDrr (FCOMPWrr SingleReg:$rz, SingleReg:$ry, floatcomp_uge), (FCOMPWrr SingleReg:$rz, SingleReg:$ry, floatcomp_ult))>;
def : Pat<(i64 (setuo f64:$rz, f64:$ry)), (ANDDrr (FCOMPD   SingleReg:$rz, SingleReg:$ry, floatcomp_uge), (FCOMPD   SingleReg:$rz, SingleReg:$ry, floatcomp_ult))>;

// FIXME: insns with immediates won't be supported in kv3-2. For binary
// compatibility reasons, there is a risk for such insns to be removed from the
// kv3-1 ISA. Remove or factorize the patterns below accordingly.
def : Pat<(i32 (setoeq f32:$rz, Binary32:$imm)), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_oeq)>;
def : Pat<(i32 (setogt Binary32:$imm, f32:$ry)), (FCOMPWri SingleReg:$ry, Binary32:$imm, floatcomp_olt)>;
def : Pat<(i32 (setoge f32:$rz, Binary32:$imm)), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_oge)>;
def : Pat<(i32 (setolt f32:$rz, Binary32:$imm)), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_olt)>;
def : Pat<(i32 (setole Binary32:$imm, f32:$ry)), (FCOMPWri SingleReg:$ry, Binary32:$imm, floatcomp_oge)>;
def : Pat<(i32 (setone f32:$rz, Binary32:$imm)), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_one)>;
def : Pat<(i32 (seto f32:$rz, Binary32:$imm)), (ORDrr (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_oge), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_olt))>;
def : Pat<(i32 (setuo f32:$rz, Binary32:$imm)), (ANDDrr (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_uge), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_ult))>;
def : Pat<(i32 (setueq f32:$rz, Binary32:$imm)), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_ueq)>;
def : Pat<(i32 (setugt Binary32:$imm, f32:$ry)), (FCOMPWri SingleReg:$ry, Binary32:$imm, floatcomp_ult)>;
def : Pat<(i32 (setuge f32:$rz, Binary32:$imm)), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_uge)>;
def : Pat<(i32 (setult f32:$rz, Binary32:$imm)), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_ult)>;
def : Pat<(i32 (setule Binary32:$imm, f32:$ry)), (FCOMPWri SingleReg:$ry, Binary32:$imm, floatcomp_uge)>;
def : Pat<(i32 (setune f32:$rz, Binary32:$imm)), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_une)>;
def : Pat<(i64 (setoeq f32:$rz, Binary32:$imm)), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_oeq)>;
def : Pat<(i64 (setogt Binary32:$imm, f32:$ry)), (FCOMPWri SingleReg:$ry, Binary32:$imm, floatcomp_olt)>;
def : Pat<(i64 (setoge f32:$rz, Binary32:$imm)), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_oge)>;
def : Pat<(i64 (setolt f32:$rz, Binary32:$imm)), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_olt)>;
def : Pat<(i64 (setole Binary32:$imm, f32:$ry)), (FCOMPWri SingleReg:$ry, Binary32:$imm, floatcomp_oge)>;
def : Pat<(i64 (setone f32:$rz, Binary32:$imm)), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_one)>;
def : Pat<(i64 (seto f32:$rz, Binary32:$imm)), (ORDrr (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_oge), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_olt))>;
def : Pat<(i64 (setuo f32:$rz, Binary32:$imm)), (ANDDrr (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_uge), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_ult))>;
def : Pat<(i64 (setueq f32:$rz, Binary32:$imm)), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_ueq)>;
def : Pat<(i64 (setugt Binary32:$imm, f32:$ry)), (FCOMPWri SingleReg:$ry, Binary32:$imm, floatcomp_ult)>;
def : Pat<(i64 (setuge f32:$rz, Binary32:$imm)), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_uge)>;
def : Pat<(i64 (setult f32:$rz, Binary32:$imm)), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_ult)>;
def : Pat<(i64 (setule Binary32:$imm, f32:$ry)), (FCOMPWri SingleReg:$ry, Binary32:$imm, floatcomp_uge)>;
def : Pat<(i64 (setune f32:$rz, Binary32:$imm)), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_une)>;


multiclass COMP_FPat<SDNode Node, Floatcomp Cmp, bit SWAP> {

  def : Pat<(v4i16 (Node v4f16:$rz, v4f16:$ry)),
    !if(SWAP, (FCOMPNHQ SingleReg:$ry, SingleReg:$rz, Cmp), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, Cmp))>;

  def : Pat<(v2i32 (Node v2f32:$rz, v2f32:$ry)),
    !if(SWAP, (FCOMPNWP SingleReg:$ry, SingleReg:$rz, Cmp), (FCOMPNWP SingleReg:$rz, SingleReg:$ry, Cmp))>;
}

defm : COMP_FPat<setoeq, floatcomp_oeq, 0>;
defm : COMP_FPat<setogt, floatcomp_olt, 1>;
defm : COMP_FPat<setoge, floatcomp_oge, 0>;
defm : COMP_FPat<setolt, floatcomp_olt, 0>;
defm : COMP_FPat<setole, floatcomp_oge, 1>;
defm : COMP_FPat<setone, floatcomp_one, 0>;
defm : COMP_FPat<setueq, floatcomp_ueq, 0>;
defm : COMP_FPat<setugt, floatcomp_ult, 1>;
defm : COMP_FPat<setuge, floatcomp_uge, 0>;
defm : COMP_FPat<setult, floatcomp_ult, 0>;
defm : COMP_FPat<setule, floatcomp_uge, 1>;
defm : COMP_FPat<setune, floatcomp_une, 0>;

def : Pat<(v4i16 (seto v4f16:$rz, v4f16:$ry)), (ORDrr (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_oge), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_olt))>;
def : Pat<(v4i16 (setuo v4f16:$rz, v4f16:$ry)), (ANDDrr (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_uge), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_ult))>;

def : Pat<(v2i32 (seto v2f32:$rz, v2f32:$ry)), (ORDrr (FCOMPNWP SingleReg:$rz, SingleReg:$ry, floatcomp_oge), (FCOMPNWP SingleReg:$rz, SingleReg:$ry, floatcomp_olt))>;
def : Pat<(v2i32 (setuo v2f32:$rz, v2f32:$ry)), (ANDDrr (FCOMPNWP SingleReg:$rz, SingleReg:$ry, floatcomp_uge), (FCOMPNWP SingleReg:$rz, SingleReg:$ry, floatcomp_ult))>;

defm : Select32PAT<(f16 f16:$truev), (f16 f16:$falsev),(f16 Binary16:$truev), (f16 Binary16:$falsev)>;
defm : Select32PAT<(f32 f32:$truev), (f32 f32:$falsev),(f32 Binary32:$truev), (f32 Binary32:$falsev)>;
defm : Select32PAT<(f64 f64:$truev), (f64 f64:$falsev),(f64 Binary64:$truev), (f64 Binary64:$falsev)>;

defm : Select64PAT<(f16 f16:$truev), (f16 f16:$falsev),(f16 Binary16:$truev), (f16 Binary16:$falsev)>;
defm : Select64PAT<(f32 f32:$truev), (f32 f32:$falsev),(f32 Binary32:$truev), (f32 Binary32:$falsev)>;
defm : Select64PAT<(f64 f64:$truev), (f64 f64:$falsev),(f64 Binary64:$truev), (f64 Binary64:$falsev)>;

// FDOT2 -> TODO
// FFMA  -> TODO
// FFMS  -> TODO
// FINV  -> TODO
// FISR  -> TODO
// FIXED
def : Pat<(i32 (fp_to_uint f16:$val)), (FIXEDUW (FWIDENLHW SingleReg:$val, silent_), DefaultShift, rounding_rz, silent_)>;
def : Pat<(i64 (fp_to_uint f16:$val)), (FIXEDUD (FWIDENLWD (FWIDENLHW SingleReg:$val, silent_), silent_), DefaultShift, rounding_rz, silent_)>;
def : Pat<(i32 (fp_to_uint f32:$val)), (FIXEDUW SingleReg:$val, DefaultShift, rounding_rz, silent_)>;
def : Pat<(i64 (fp_to_uint f32:$val)), (FIXEDUD (FWIDENLWD SingleReg:$val, silent_), DefaultShift, rounding_rz, silent_)>;
def : Pat<(i32 (fp_to_uint f64:$val)), (FIXEDUD SingleReg:$val, DefaultShift, rounding_rz, silent_)>;
def : Pat<(i64 (fp_to_uint f64:$val)), (FIXEDUD SingleReg:$val, DefaultShift, rounding_rz, silent_)>;
def : Pat<(i32 (fp_to_sint f16:$val)), (FIXEDW (FWIDENLHW SingleReg:$val, silent_), DefaultShift, rounding_rz, silent_)>;
def : Pat<(i64 (fp_to_sint f16:$val)), (FIXEDD (FWIDENLWD (FWIDENLHW SingleReg:$val, silent_), silent_), DefaultShift, rounding_rz, silent_)>;
def : Pat<(i32 (fp_to_sint f32:$val)), (FIXEDW SingleReg:$val, DefaultShift, rounding_rz, silent_)>;
def : Pat<(i64 (fp_to_sint f32:$val)), (FIXEDD (FWIDENLWD SingleReg:$val, silent_), DefaultShift, rounding_rz, silent_)>;
def : Pat<(i32 (fp_to_sint f64:$val)), (FIXEDD SingleReg:$val, DefaultShift, rounding_rz, silent_)>;
def : Pat<(i64 (fp_to_sint f64:$val)), (FIXEDD SingleReg:$val, DefaultShift, rounding_rz, silent_)>;
// FLOAT
// FIXME f16 patterns have issues with double rounding / implement RTcalls ?
def : Pat<(f16 (uint_to_fp i32:$val)), (FNARROWWH (FLOATUW SingleReg:$val, DefaultShift, rounding_rn, silent_), rounding_rn, silent_)>;
def : Pat<(f16 (uint_to_fp i64:$val)), (FNARROWWH (FNARROWDW (FLOATUD SingleReg:$val, DefaultShift, rounding_rn, silent_), rounding_rn, silent_), rounding_rn, silent_)>;
def : Pat<(f32 (uint_to_fp i32:$val)), (FLOATUW SingleReg:$val, DefaultShift, rounding_rn, silent_)>;
def : Pat<(f64 (uint_to_fp i32:$val)), (FLOATUD (ZXWD SingleReg:$val), DefaultShift, rounding_rn, silent_)>;
def : Pat<(f64 (uint_to_fp i64:$val)), (FLOATUD SingleReg:$val, DefaultShift, rounding_rn, silent_)>;
def : Pat<(f16 (sint_to_fp i32:$val)), (FNARROWWH (FLOATW SingleReg:$val, DefaultShift, rounding_rn, silent_), rounding_rn, silent_)>;
def : Pat<(f16 (sint_to_fp i64:$val)), (FNARROWWH (FNARROWDW (FLOATD SingleReg:$val, DefaultShift, rounding_rn, silent_), rounding_rn, silent_), rounding_rn, silent_)>;
def : Pat<(f32 (sint_to_fp i32:$val)), (FLOATW SingleReg:$val, DefaultShift, rounding_rn, silent_)>;
def : Pat<(f64 (sint_to_fp i32:$val)), (FLOATD (SXWD SingleReg:$val), DefaultShift, rounding_rn, silent_)>;
def : Pat<(f64 (sint_to_fp i64:$val)), (FLOATD SingleReg:$val, DefaultShift, rounding_rn, silent_)>;
// FMAX  -> TODO
// FMIN  -> TODO
// FMM2A -> TODO
// FMM2S -> TODO
// FMM2  -> TODO
// FMULC -> TODO
// FMUL
def FMULH : REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE_BINARY16X4
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Binary16:$a3),
     "fmulhq $a1 = $a2, $a3",
     [(set f16:$a1, (fmul f16:$a2, Binary16:$a3))],
     MAU_Y>;
def : Pat<(fmul f32:$rs1, Binary32:$rs2), (FMULWri SingleReg:$rs1, Binary32:$rs2)>;
def : Pat<(fmul f64:$rs1, Binary64:$rs2), (FMULDri SingleReg:$rs1, Binary64:$rs2)>;
def : Pat<(fmul f16:$rs1, f16:$rs2), (FMULHQrr SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fmul f32:$rs1, f32:$rs2), (FMULWrr SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fmul f64:$rs1, f64:$rs2), (FMULDrr SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fmul v2f16:$rs1, v2f16:$rs2), (FMULHQrr SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fmul v4f16:$rs1, v4f16:$rs2), (FMULHQrr SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fmul v2f32:$rs1, v2f32:$rs2), (FMULWPrr SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fmul v4f32:$rs1, v4f32:$rs2), (FMULWQ PairedReg:$rs1, PairedReg:$rs2, rounding_, silent_)>;
// FMUL*C -> TODO
// FNARROW
def : Pat<(f16 (fpround f32:$val)), (FNARROWWH SingleReg:$val, rounding_, silent_)>;
def : Pat<(f16 (fpround f64:$val)), (FNARROWWH (FNARROWDW SingleReg:$val, rounding_, silent_), rounding_, silent_)>;
def : Pat<(f32 (fpround f64:$val)), (FNARROWDW SingleReg:$val, rounding_, silent_)>;
// FNEG, see KVXInstrInfo.td for f32, f64, v2f32, v4f16
def : Pat<(fneg f16:$rs), (FNEGHQ SingleReg:$rs)>;
def : Pat<(fneg v2f16:$rs), (FNEGHQ SingleReg:$rs)>;
def : Pat<(vfneg v2f16:$rs), (FNEGHQ SingleReg:$rs)>;
def : Pat<(vfneg v4f16:$rs), (FNEGHQ SingleReg:$rs)>;
def : Pat<(vfneg v2f32:$rs), (FNEGWP SingleReg:$rs)>;
// FSBFC -> TODO
// FSBF
def FSBFH : REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE_BINARY16X4
    <(outs SingleReg:$a1), (ins SingleReg:$a2, Binary16:$a3),
     "fsbfhq $a1 = $a2, $a3",
     [(set f16:$a1, (fsub f16:$a3, Binary16:$a2))],
     MAU_Y>;
def : Pat<(fsub Binary32:$rs1, f32:$rs2), (FSBFWri SingleReg:$rs2, Binary32:$rs1)>;
def : Pat<(fsub Binary64:$rs1, f64:$rs2), (FSBFDri SingleReg:$rs2, Binary64:$rs1)>;
def : Pat<(fsub f16:$rs1, f16:$rs2), (FSBFHQrr SingleReg:$rs2, SingleReg:$rs1, rounding_, silent_)>;
def : Pat<(fsub f32:$rs1, f32:$rs2), (FSBFWrr SingleReg:$rs2, SingleReg:$rs1, rounding_, silent_)>;
def : Pat<(fsub f64:$rs1, f64:$rs2), (FSBFDrr SingleReg:$rs2, SingleReg:$rs1, rounding_, silent_)>;
def : Pat<(fsub v2f16:$rs1, v2f16:$rs2), (FSBFHQrr SingleReg:$rs2, SingleReg:$rs1, rounding_, silent_)>;
def : Pat<(fsub v4f16:$rs1, v4f16:$rs2), (FSBFHQrr SingleReg:$rs2, SingleReg:$rs1, rounding_, silent_)>;
def : Pat<(fsub v2f32:$rs1, v2f32:$rs2), (FSBFWPrr SingleReg:$rs2, SingleReg:$rs1, rounding_, silent_)>;
def : Pat<(fsub v4f32:$rs1, v4f32:$rs2), (FSBFWQ PairedReg:$rs2, PairedReg:$rs1, rounding_, silent_)>;
def : Pat<(fsub v2f64:$rs1, v2f64:$rs2), (FSBFDP PairedReg:$rs2, PairedReg:$rs1, rounding_, silent_)>;
// FSDIV -> TODO
// FSINV -> TODO
// FSISR -> TODO
// FWIDEN
def : Pat<(f64 (fpextend f32:$val)), (FWIDENLWD SingleReg:$val, silent_)>;
def : Pat<(f64 (fpextend f16:$val)), (FWIDENLWD (FWIDENLHW SingleReg:$val, silent_), silent_)>;
def : Pat<(f32 (fpextend f16:$val)), (FWIDENLHW SingleReg:$val, silent_)>;

// v2f32
def : Pat<(extractelt (v2f32 SingleReg:$v), 0), (COPY SingleReg:$v)>;
def : Pat<(extractelt (v2f32 SingleReg:$v), 1), (SRADri SingleReg :$v, (i64 32))>;

// v4f32
def : Pat<(extractelt (v4f32 PairedReg:$v), 0), (f32 (EXTRACT_SUBREG $v, 1))>;
def : Pat<(extractelt (v4f32 PairedReg:$v), 1), (SRADri (f32 (EXTRACT_SUBREG $v, 1)), (i64 32))>;
def : Pat<(extractelt (v4f32 PairedReg:$v), 2), (f32 (EXTRACT_SUBREG $v, 2))>;
def : Pat<(extractelt (v4f32 PairedReg:$v), 3), (SRADri (f32 (EXTRACT_SUBREG $v, 2)), (i64 32))>;

// v2f64
def : Pat<(v2f64 (build_vector f64:$v1, f64:$v2)),
  (INSERT_SUBREG
    (INSERT_SUBREG (v2f64 (IMPLICIT_DEF)), SingleReg:$v1, 1),
    SingleReg:$v2, 2
  )>;

def : Pat<(extractelt (v2f64 PairedReg:$v), 0), (f64 (EXTRACT_SUBREG $v, 1))>;
def : Pat<(extractelt (v2f64 PairedReg:$v), 1), (f64 (EXTRACT_SUBREG $v, 2))>;

// v2f16
def : Pat<(extractelt v2f16:$v, 0), (ZXHD SingleReg:$v)>;
def : Pat<(extractelt v2f16:$v, 1), (SRLDri SingleReg:$v, (i64 16))>;

// v4f16
def : Pat<(extractelt (v4f16 SingleReg:$v), 0), (EXTFZ SingleReg:$v, 15, 0)>;
def : Pat<(extractelt (v4f16 SingleReg:$v), 1), (EXTFZ SingleReg:$v, 31, 16)>;
def : Pat<(extractelt (v4f16 SingleReg:$v), 2), (EXTFZ SingleReg:$v, 47, 32)>;
def : Pat<(extractelt (v4f16 SingleReg:$v), 3), (SRLDri SingleReg:$v, (i64 48))>;

def : Pat<(fcopysign f64:$v1, f64:$v2), (INSF SingleReg:$v1, (f64 (SRADri SingleReg:$v2, 63)), 63, 63)>;
def : Pat<(fcopysign f64:$v1, f32:$v2), (INSF SingleReg:$v1, (f64 (SRAWri SingleReg:$v2, 31)), 63, 63)>;
def : Pat<(fcopysign f64:$v1, f16:$v2), (INSF SingleReg:$v1, (f64 (SRAWri SingleReg:$v2, 15)), 63, 63)>;
def : Pat<(fcopysign f32:$v1, f64:$v2), (INSF SingleReg:$v1, (f64 (SRADri SingleReg:$v2, 63)), 31, 31)>;
def : Pat<(fcopysign f32:$v1, f32:$v2), (INSF SingleReg:$v1, (f64 (SRAWri SingleReg:$v2, 31)), 31, 31)>;
def : Pat<(fcopysign f32:$v1, f16:$v2), (INSF SingleReg:$v1, (f64 (SRAWri SingleReg:$v2, 15)), 31, 31)>;
def : Pat<(fcopysign f16:$v1, f64:$v2), (INSF SingleReg:$v1, (f64 (SRADri SingleReg:$v2, 63)), 15, 15)>;
def : Pat<(fcopysign f16:$v1, f32:$v2), (INSF SingleReg:$v1, (f64 (SRAWri SingleReg:$v2, 31)), 15, 15)>;
def : Pat<(fcopysign f16:$v1, f16:$v2), (INSF SingleReg:$v1, (f64 (SRAWri SingleReg:$v2, 15)), 15, 15)>;
