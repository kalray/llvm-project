//===-- KVXFloatingPoint.td --------------------------------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

def DefaultShift : PatLeaf<(i64 0)>;

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

defm : StorePat<store, v4f64, QuadReg, 5, SOp, SOri10, SOrr>;

// Load
foreach type = [ f16, f32, f64, v2f16, v4f16, v2f32, v4f32, v2f64, v4f64 ] in {
def load#type : PatFrag<(ops node:$ptr), (type (load node:$ptr)), [{
    const MemSDNode *LD = cast<MemSDNode>(N);
    return LD->getAddressSpace() < 256;
  }]>;

def loadbypass#type : PatFrag<(ops node:$ptr), (type (load node:$ptr)), [{
    const MemSDNode *LD = cast<MemSDNode>(N);
    return LD->getAddressSpace() == 256;
  }]>;

def loadpreload#type : PatFrag<(ops node:$ptr), (type (load node:$ptr)), [{
    const MemSDNode *LD = cast<MemSDNode>(N);
    return LD->getAddressSpace() == 257;
  }]>;

def loadspec#type : PatFrag<(ops node:$ptr), (type (load node:$ptr)), [{
    const MemSDNode *LD = cast<MemSDNode>(N);
    return LD->getAddressSpace() == 258;
  }]>;  
}

// Bypass loads
defm : LoadPat<loadbypassf16, f16, 1, LHZp, LHZri10, LHZrr, variant_u>;

defm : LoadPat<loadbypassf32, f32, 2, LWZp, LWZri10, LWZrr, variant_u>;
defm : LoadPat<loadbypassv2f16, v2f16, 2, LWZp, LWZri10, LWZrr, variant_u>;

defm : LoadPat<loadbypassf64, f64, 3, LDp, LDri10, LDrr, variant_u>;
defm : LoadPat<loadbypassv2f32, v2f32, 3, LDp, LDri10, LDrr, variant_u>;
defm : LoadPat<loadbypassv4f16, v4f16, 3, LDp, LDri10, LDrr, variant_u>;

defm : LoadPat<loadbypassv4f32, v4f32, 4, LQp, LQri10, LQrr, variant_u>;
defm : LoadPat<loadbypassv2f64, v2f64, 4, LQp, LQri10, LQrr, variant_u>;

defm : LoadPat<loadbypassv4f64, v4f64, 5, LOp, LOri10, LOrr, variant_u>;

// Preload loads
defm : LoadPat<loadpreloadf16, f16, 1, LHZp, LHZri10, LHZrr, variant_us>;

defm : LoadPat<loadpreloadf32, f32, 2, LWZp, LWZri10, LWZrr, variant_us>;
defm : LoadPat<loadpreloadv2f16, v2f16, 2, LWZp, LWZri10, LWZrr, variant_us>;

defm : LoadPat<loadpreloadf64, f64, 3, LDp, LDri10, LDrr, variant_us>;
defm : LoadPat<loadpreloadv2f32, v2f32, 3, LDp, LDri10, LDrr, variant_us>;
defm : LoadPat<loadpreloadv4f16, v4f16, 3, LDp, LDri10, LDrr, variant_us>;

defm : LoadPat<loadpreloadv4f32, v4f32, 4, LQp, LQri10, LQrr, variant_us>;
defm : LoadPat<loadpreloadv2f64, v2f64, 4, LQp, LQri10, LQrr, variant_us>;

defm : LoadPat<loadpreloadv4f64, v4f64, 5, LOp, LOri10, LOrr, variant_us>;

// Speculative loads
defm : LoadPat<loadspecf16, f16, 1, LHZp, LHZri10, LHZrr, variant_s>;

defm : LoadPat<loadspecf32, f32, 2, LWZp, LWZri10, LWZrr, variant_s>;
defm : LoadPat<loadspecv2f16, v2f16, 2, LWZp, LWZri10, LWZrr, variant_s>;

defm : LoadPat<loadspecf64, f64, 3, LDp, LDri10, LDrr, variant_s>;
defm : LoadPat<loadspecv2f32, v2f32, 3, LDp, LDri10, LDrr, variant_s>;
defm : LoadPat<loadspecv4f16, v4f16, 3, LDp, LDri10, LDrr, variant_s>;

defm : LoadPat<loadspecv4f32, v4f32, 4, LQp, LQri10, LQrr, variant_s>;
defm : LoadPat<loadspecv2f64, v2f64, 4, LQp, LQri10, LQrr, variant_s>;

defm : LoadPat<loadspecv4f64, v4f64, 5, LOp, LOri10, LOrr, variant_s>;

// Normal loads
defm : LoadPat<loadf16, f16, 1, LHZp, LHZri10, LHZrr, variant_>;

defm : LoadPat<loadf32, f32, 2, LWZp, LWZri10, LWZrr, variant_>;
defm : LoadPat<loadv2f16, v2f16, 2, LWZp, LWZri10, LWZrr, variant_>;

defm : LoadPat<loadf64, f64, 3, LDp, LDri10, LDrr, variant_>;
defm : LoadPat<loadv2f32, v2f32, 3, LDp, LDri10, LDrr, variant_>;
defm : LoadPat<loadv4f16, v4f16, 3, LDp, LDri10, LDrr, variant_>;

defm : LoadPat<loadv4f32, v4f32, 4, LQp, LQri10, LQrr, variant_>;
defm : LoadPat<loadv2f64, v2f64, 4, LQp, LQri10, LQrr, variant_>;

defm : LoadPat<loadv4f64, v4f64, 5, LOp, LOri10, LOrr, variant_>;

// 16 bits bitcasts
def : BITCAST<f16, i16, SingleReg>;
def : BITCAST<i16, f16, SingleReg>;
def : BITCAST<f16, v2i8, SingleReg>;
def : BITCAST<v2i8, f16, SingleReg>;

// 32 bits bitcasts
def : BITCAST<f32, i32, SingleReg>;
def : BITCAST<i32, f32, SingleReg>;
def : BITCAST<v2i16, f32, SingleReg>;
def : BITCAST<f32, v2i16, SingleReg>;
def : BITCAST<v2f16, i32, SingleReg>;
def : BITCAST<i32, v2f16, SingleReg>;
def : BITCAST<v2f16, v2i16, SingleReg>;
def : BITCAST<v2i16, v2f16, SingleReg>;
def : BITCAST<f32, v4i8, SingleReg>;
def : BITCAST<v4i8, f32, SingleReg>;

// 64 bits bitcasts
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

// 128 bits bitcasts
def : BITCAST<v2i64, v4f32, PairedReg>;
def : BITCAST<v4f32, v2i64, PairedReg>;
def : BITCAST<v2f64, v2i64, PairedReg>;
def : BITCAST<v2i64, v2f64, PairedReg>;
def : BITCAST<v4f32, v4i32, PairedReg>;
def : BITCAST<v4i32, v4f32, PairedReg>;

// 256 bits bitcasts
def : BITCAST<v4i64, v4f64, QuadReg>;
def : BITCAST<v4f64, v4i64, QuadReg>;

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

// FCOMP
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

// Ordered comparisons
defm : FCOMP<setoeq, floatcomp_oeq, 0>;
defm : FCOMP<setogt, floatcomp_olt, 1>;
defm : FCOMP<setoge, floatcomp_oge, 0>;
defm : FCOMP<setolt, floatcomp_olt, 0>;
defm : FCOMP<setole, floatcomp_oge, 1>;
defm : FCOMP<setone, floatcomp_one, 0>;
// Using -ffast-math generates the following setcc patterns
// TODO: shouldn't be unordered ones?
defm : FCOMP<seteq, floatcomp_oeq, 0>;
defm : FCOMP<setgt, floatcomp_olt, 1>;
defm : FCOMP<setge, floatcomp_oge, 0>;
defm : FCOMP<setlt, floatcomp_olt, 0>;
defm : FCOMP<setle, floatcomp_oge, 1>;
defm : FCOMP<setne, floatcomp_one, 0>;
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

// NOTE: insns with immediates won't be supported in kv3-2.
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
  def : Pat<(sra (shl (v4i16 (Node v4f16:$rz, v4f16:$ry)), (v4i16 v4_splat_15)), (v4i16 v4_splat_15)),
    !if(SWAP, (FCOMPNHQ SingleReg:$ry, SingleReg:$rz, Cmp), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, Cmp))>;

  def : Pat<(v2i32 (Node v2f32:$rz, v2f32:$ry)),
    !if(SWAP, (FCOMPNWP SingleReg:$ry, SingleReg:$rz, Cmp), (FCOMPNWP SingleReg:$rz, SingleReg:$ry, Cmp))>;
  def : Pat<(sra (shl (v2i32 (Node v2f32:$rz, v2f32:$ry)), (v2i32 v2_splat_31)), (v2i32 v2_splat_31)),
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

defm : SELECTCONDW<(f16 f16:$truev), (f16 f16:$falsev),(f16 Binary16:$truev), (f16 Binary16:$falsev)>;
defm : SELECTCONDW<(f32 f32:$truev), (f32 f32:$falsev),(f32 Binary32:$truev), (f32 Binary32:$falsev)>;
defm : SELECTCONDW<(f64 f64:$truev), (f64 f64:$falsev),(f64 Binary64:$truev), (f64 Binary64:$falsev)>;

defm : SELECTCONDD<(f16 f16:$truev), (f16 f16:$falsev),(f16 Binary16:$truev), (f16 Binary16:$falsev)>;
defm : SELECTCONDD<(f32 f32:$truev), (f32 f32:$falsev),(f32 Binary32:$truev), (f32 Binary32:$falsev)>;
defm : SELECTCONDD<(f64 f64:$truev), (f64 f64:$falsev),(f64 Binary64:$truev), (f64 Binary64:$falsev)>;

// FFMA
def : Pat<(f16 (fma f16:$rx, f16:$ry, f16:$rz)), (FFMAHQrr SingleReg:$rz, SingleReg:$rx, SingleReg:$ry, rounding_, silent_)>;
def : Pat<(f32 (fma f32:$rx, f32:$ry, f32:$rz)), (FFMAWrr SingleReg:$rz, SingleReg:$rx, SingleReg:$ry, rounding_, silent_)>;
def : Pat<(f32 (fma f32:$rx, Binary32:$ry, f32:$rz)), (FFMAWri SingleReg:$rz, SingleReg:$rx, Binary32:$ry)>;
def : Pat<(f64 (fma f64:$rx, f64:$ry, f64:$rz)), (FFMADrr SingleReg:$rz, SingleReg:$rx, SingleReg:$ry, rounding_, silent_)>;
def : Pat<(f64 (fma f64:$rx, Binary64:$ry, f64:$rz)), (FFMADri SingleReg:$rz, SingleReg:$rx, Binary64:$ry)>;

def : Pat<(v2f32 (fma v2f32:$rx, v2f32:$ry, v2f32:$rz)), (FFMAWPrr SingleReg:$rz, SingleReg:$rx, SingleReg:$ry, rounding_, silent_)>;
def : Pat<(v2f16 (fma v2f16:$rx, v2f16:$ry, v2f16:$rz)), (FFMAHQrr SingleReg:$rz, SingleReg:$rx, SingleReg:$ry, rounding_, silent_)>;
def : Pat<(v4f16 (fma v4f16:$rx, v4f16:$ry, v4f16:$rz)), (FFMAHQrr SingleReg:$rz, SingleReg:$rx, SingleReg:$ry, rounding_, silent_)>;
def : Pat<(v4f32 (fma v4f32:$rx, v4f32:$ry, v4f32:$rz)),
          (REG_SEQUENCE PairedReg,
            (FFMAWPrr
              (v2f32 (EXTRACT_SUBREG PairedReg:$rz, sub_s0)),
              (v2f32 (EXTRACT_SUBREG PairedReg:$rx, sub_s0)),
              (v2f32 (EXTRACT_SUBREG PairedReg:$ry, sub_s0)),
              rounding_,
              silent_),
            sub_s0,
            (FFMAWPrr
              (v2f32 (EXTRACT_SUBREG PairedReg:$rz, sub_s1)),
              (v2f32 (EXTRACT_SUBREG PairedReg:$rx, sub_s1)),
              (v2f32 (EXTRACT_SUBREG PairedReg:$ry, sub_s1)),
              rounding_,
              silent_),
            sub_s1)>;
// FFMS
def KVXFMS : SDNode<"KVXISD::FMS", SDTFPTernaryOp>;

def : Pat<(f32 (KVXFMS f32:$rx, f32:$ry, f32:$rz)), (FFMSWrr SingleReg:$rz, SingleReg:$rx, SingleReg:$ry, rounding_, silent_)>;
def : Pat<(f64 (KVXFMS f64:$rx, f64:$ry, f64:$rz)), (FFMSDrr SingleReg:$rz, SingleReg:$rx, SingleReg:$ry, rounding_, silent_)>;

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
// FIXME: f16 patterns have issues with double rounding / implement RTcalls ?
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

// FNARROW
def : Pat<(f16 (fpround f32:$val)), (FNARROWWH SingleReg:$val, rounding_, silent_)>;
def : Pat<(f16 (fpround f64:$val)), (FNARROWWH (FNARROWDW SingleReg:$val, rounding_, silent_), rounding_, silent_)>;
def : Pat<(f32 (fpround f64:$val)), (FNARROWDW SingleReg:$val, rounding_, silent_)>;
def : Pat<(v2f16 (fpround v2f32:$val)), (FNARROWWHQ (INSERT_SUBREG
                                                      (INSERT_SUBREG (v4f32 (IMPLICIT_DEF)), SingleReg:$val, sub_s0),
                                                      (v2f32 (IMPLICIT_DEF)), sub_s1), rounding_, silent_)>;
def : Pat<(v4f16 (fpround v4f32:$val)), (FNARROWWHQ PairedReg:$val, rounding_, silent_)>;

def : Pat<(v2f16 (fpround v2f64:$val)), (INSF (FNARROWWH (FNARROWDW (f64 (EXTRACT_SUBREG PairedReg:$val, sub_s0)), rounding_, silent_), rounding_, silent_),
                                              (FNARROWWH (FNARROWDW (f64 (EXTRACT_SUBREG PairedReg:$val, sub_s1)), rounding_, silent_), rounding_, silent_), 31, 16)>;
def : Pat<(v4f16 (fpround v4f64:$val)), (INSF
                                          (INSF (FNARROWWH (FNARROWDW (f64 (EXTRACT_SUBREG QuadReg:$val, sub_s0)), rounding_, silent_), rounding_, silent_),
                                                (FNARROWWH (FNARROWDW (f64 (EXTRACT_SUBREG QuadReg:$val, sub_s1)), rounding_, silent_), rounding_, silent_), 31, 16),
                                          (INSF (FNARROWWH (FNARROWDW (f64 (EXTRACT_SUBREG QuadReg:$val, sub_s2)), rounding_, silent_), rounding_, silent_),
                                                (FNARROWWH (FNARROWDW (f64 (EXTRACT_SUBREG QuadReg:$val, sub_s3)), rounding_, silent_), rounding_, silent_), 31, 16),
                                        63, 32)>;

// FNEG
def : Pat<(fneg f16:$rs), (FNEGHQ SingleReg:$rs)>;
def : Pat<(fneg v2f16:$rs), (FNEGHQ SingleReg:$rs)>;
def : Pat<(vfneg v2f16:$rs), (FNEGHQ SingleReg:$rs)>;
def : Pat<(vfneg v4f16:$rs), (FNEGHQ SingleReg:$rs)>;
def : Pat<(vfneg v2f32:$rs), (FNEGWP SingleReg:$rs)>;

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

// FWIDEN
def : Pat<(f64 (fpextend f32:$val)), (FWIDENLWD SingleReg:$val, silent_)>;
def : Pat<(f64 (fpextend f16:$val)), (FWIDENLWD (FWIDENLHW SingleReg:$val, silent_), silent_)>;
def : Pat<(f32 (fpextend f16:$val)), (FWIDENLHW SingleReg:$val, silent_)>;
def : Pat<(v2f32 (fpextend v2f16:$val)), (FWIDENLHWP SingleReg:$val, silent_)>;
def : Pat<(v4f32 (fpextend v4f16:$val)), (INSERT_SUBREG
                                           (INSERT_SUBREG (v4f32 (IMPLICIT_DEF)), (v2f32 (FWIDENLHWP SingleReg:$val, silent_)), sub_s0),
                                           (v2f32 (FWIDENMHWP SingleReg:$val, silent_)), sub_s1)>;

// build_vector
// v2f16
def : Pat<(v2f16 (is_imm_vec:$IMM)), (MAKEi43 (build_fpimm_vec $IMM))>;
def : Pat<(v2f16 (build_vector f16:$v0, f16:$v1)), (INSF SingleReg:$v0, SingleReg:$v1, 31, 16)>;

// v2f32
def : Pat<(v2f32 (is_imm_vec:$IMM)), (MAKEi64 (build_fpimm_vec $IMM))>;
def : Pat<(v2f32 (build_vector f32:$v0, f32:$v1)), (INSF SingleReg:$v0, SingleReg:$v1, 63, 32)>;

// v4f16
def : Pat<(v4f16 (is_imm_vec:$IMM)), (MAKEi64 (build_fpimm_vec $IMM))>;
def : Pat<(v4f16 (build_vector f16:$v0, f16:$v1, f16:$v2, f16:$v3)),
          (INSF (INSF SingleReg:$v0, SingleReg:$v1, 31, 16), (INSF SingleReg:$v2, SingleReg:$v3, 31, 16), 63, 32)>;

// v2f32
def : Pat<(extractelt (v2f32 SingleReg:$v), 0), (COPY SingleReg:$v)>;
def : Pat<(extractelt (v2f32 SingleReg:$v), 1), (SRADri SingleReg :$v, (i64 32))>;

// v4f32
def : Pat<(extractelt (v4f32 PairedReg:$v), 0), (f32 (EXTRACT_SUBREG $v, sub_s0))>;
def : Pat<(extractelt (v4f32 PairedReg:$v), 1), (SRADri (f32 (EXTRACT_SUBREG $v, sub_s0)), (i64 32))>;
def : Pat<(extractelt (v4f32 PairedReg:$v), 2), (f32 (EXTRACT_SUBREG $v, sub_s1))>;
def : Pat<(extractelt (v4f32 PairedReg:$v), 3), (SRADri (f32 (EXTRACT_SUBREG $v, sub_s1)), (i64 32))>;

def : Pat<(v2f32 (extract_subvector (v4f32 PairedReg:$v), (i64 0))),
          (v2f32 (EXTRACT_SUBREG $v, sub_s0))>;
def : Pat<(v2f32 (extract_subvector (v4f32 PairedReg:$v), (i64 2))),
          (v2f32 (EXTRACT_SUBREG $v, sub_s1))>;

// v2f64
def : Pat<(v2f64 (build_vector f64:$v1, f64:$v2)),
  (INSERT_SUBREG
    (INSERT_SUBREG (v2f64 (IMPLICIT_DEF)), SingleReg:$v1, sub_s0),
    SingleReg:$v2, sub_s1
  )>;

def : Pat<(v4f32 (concat_vectors v2f32:$v1, v2f32:$v2)),
  (INSERT_SUBREG
    (INSERT_SUBREG (v4f32 (IMPLICIT_DEF)), SingleReg:$v1, sub_s0),
    SingleReg:$v2, sub_s1
  )>;

def : Pat<(extractelt (v2f64 PairedReg:$v), 0), (f64 (EXTRACT_SUBREG $v, sub_s0))>;
def : Pat<(extractelt (v2f64 PairedReg:$v), 1), (f64 (EXTRACT_SUBREG $v, sub_s1))>;

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

// v4f64
def : Pat<(extractelt (v4f64 QuadReg:$v), 0), (f64 (EXTRACT_SUBREG $v, sub_s0))>;
def : Pat<(extractelt (v4f64 QuadReg:$v), 1), (f64 (EXTRACT_SUBREG $v, sub_s1))>;
def : Pat<(extractelt (v4f64 QuadReg:$v), 2), (f64 (EXTRACT_SUBREG $v, sub_s2))>;
def : Pat<(extractelt (v4f64 QuadReg:$v), 3), (f64 (EXTRACT_SUBREG $v, sub_s3))>;


def : Pat<(v4f64 (build_vector f64:$v1, f64:$v2, f64:$v3, f64:$v4)),
          (INSERT_SUBREG (INSERT_SUBREG (INSERT_SUBREG
    (INSERT_SUBREG (v4f64 (IMPLICIT_DEF)), $v1, sub_s0), $v2, sub_s1), $v3, sub_s2), $v4, sub_s3)>;

def : Pat<(v4f64 (concat_vectors v2f64:$v0, v2f64:$v1)),
  (INSERT_SUBREG (INSERT_SUBREG (v4f64 (IMPLICIT_DEF)), $v0, sub_p0), $v1, sub_p1)>;

def : Pat<(v2f64 (extract_subvector (v4f64 QuadReg:$v), (i64 0))),
          (EXTRACT_SUBREG $v, sub_p0)>;

def : Pat<(v2f64 (extract_subvector (v4f64 QuadReg:$v), (i64 2))),
          (EXTRACT_SUBREG $v, sub_p1)>;

// Patterns used only for -freciprocal-math
def : Pat<(fdiv f32:$a, f32:$b), (FMULWrr SingleReg:$a, (FRECW SingleReg:$b, rounding_, silent_), rounding_, silent_)>;
def : Pat<(fsqrt f32:$a), (FMULWrr SingleReg:$a, (FRSRW SingleReg:$a, rounding_, silent_), rounding_, silent_)>;
