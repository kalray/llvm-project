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

def fmulcont : PatFrag<(ops node:$op0, node:$op1), (fmul node:$op0, node:$op1), [{
    return N->getFlags().hasAllowContract();
  }]>;

def faddcont : PatFrag<(ops node:$op0, node:$op1), (fadd node:$op0, node:$op1), [{
    return N->getFlags().hasAllowContract();
  }]>;

def fsubcont : PatFrag<(ops node:$op0, node:$op1), (fsub node:$op0, node:$op1), [{
    return N->getFlags().hasAllowContract();
  }]>;

def kvx_fma : PatFrags<(ops node:$op0, node:$op1, node:$op2),
              [(fma node:$op0, node:$op1, node:$op2),
               (faddcont node:$op2, (fmulcont node:$op0, node:$op1))]>;

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

// FABS
def : Pat<(v2f16(fabs v2f16:$v)), (FABSHQ SingleReg:$v)>;
def : Pat<(v4f16(fabs v4f16:$v)), (FABSHQ SingleReg:$v)>;

// FADD
// TODO: Add ri variants
// def : Pat<(fadd f16:$rs1, Binary16:$rs2), (FADDHQri (ZXHD SingleReg:$rs1), Binary16x4:$rs2)>;
def : Pat<(fadd f32:$rs1, Binary32:$rs2), (FADDWri SingleReg:$rs1, Binary32:$rs2)>, Requires<[HasFPIMM]>;
def : Pat<(fadd f64:$rs1, Binary64:$rs2), (FADDDri SingleReg:$rs1, Binary64:$rs2)>, Requires<[HasFPIMM]>;
def : Pat<(fadd f16:$rs1, f16:$rs2), (FADDHQrr (ZXHD SingleReg:$rs1), (ZXHD SingleReg:$rs2), rounding_, silent_)>;
def : Pat<(fadd f32:$rs1, f32:$rs2), (FADDWrr SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fadd f64:$rs1, f64:$rs2), (FADDDrr SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fadd v2f16:$rs1, v2f16:$rs2), (FADDHQrr (ZXWD SingleReg:$rs1), (ZXWD SingleReg:$rs2), rounding_, silent_)>;
def : Pat<(fadd v4f16:$rs1, v4f16:$rs2), (FADDHQrr SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fadd v2f32:$rs1, v2f32:$rs2), (FADDWPrr SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fadd v4f32:$rs1, v4f32:$rs2), (FADDWQ PairedReg:$rs1, PairedReg:$rs2, rounding_, silent_)>;
def : Pat<(fadd v2f64:$rs1, v2f64:$rs2), (FADDDP PairedReg:$rs1, PairedReg:$rs2, rounding_, silent_)>;
def : Pat<(v4f64 (fadd v4f64:$rs1, v4f64:$rs2)),
          (v4f64(REG_SEQUENCE QuadReg,
            (v2f64(FADDDP
              (v2f64 (EXTRACT_SUBREG QuadReg:$rs1, sub_p0)),
              (v2f64 (EXTRACT_SUBREG QuadReg:$rs2, sub_p0)),
              rounding_,
              silent_)),
            sub_p0,
            (v2f64(FADDDP
              (v2f64 (EXTRACT_SUBREG QuadReg:$rs1, sub_p1)),
              (v2f64 (EXTRACT_SUBREG QuadReg:$rs2, sub_p1)),
              rounding_,
              silent_)),
            sub_p1))>;

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
def : Pat<(i32 (seto f16:$r, f16:$r)), (FCOMPNHQ SingleReg:$r, SingleReg:$r, floatcomp_oeq)>;
def : Pat<(i32 (seto f16:$rz, f16:$ry)), (ORWrr (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_oge), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_olt))>;
def : Pat<(i32 (seto f32:$r, f32:$r)), (FCOMPWrr SingleReg:$r, SingleReg:$r, floatcomp_oeq)>;
def : Pat<(i32 (seto f32:$rz, f32:$ry)), (ORWrr (FCOMPWrr SingleReg:$rz, SingleReg:$ry, floatcomp_oge), (FCOMPWrr SingleReg:$rz, SingleReg:$ry, floatcomp_olt))>;
def : Pat<(i32 (seto f64:$r, f64:$r)), (FCOMPD SingleReg:$r, SingleReg:$r, floatcomp_oeq)>;
def : Pat<(i32 (seto f64:$rz, f64:$ry)), (ORWrr (FCOMPD   SingleReg:$rz, SingleReg:$ry, floatcomp_oge), (FCOMPD   SingleReg:$rz, SingleReg:$ry, floatcomp_olt))>;
def : Pat<(i64 (seto f32:$r, f32:$r)), (FCOMPWrr SingleReg:$r, SingleReg:$r, floatcomp_oeq)>;
def : Pat<(i64 (seto f32:$rz, f32:$ry)), (ORDrr (FCOMPWrr SingleReg:$rz, SingleReg:$ry, floatcomp_oge), (FCOMPWrr SingleReg:$rz, SingleReg:$ry, floatcomp_olt))>;
def : Pat<(i64 (seto f64:$r, f64:$r)), (FCOMPD SingleReg:$r, SingleReg:$r, floatcomp_oeq)>;
def : Pat<(i64 (seto f64:$rz, f64:$ry)), (ORDrr (FCOMPD   SingleReg:$rz, SingleReg:$ry, floatcomp_oge), (FCOMPD   SingleReg:$rz, SingleReg:$ry, floatcomp_olt))>;

// Unordered comparisons
defm : FCOMP<setueq, floatcomp_ueq, 0>;
defm : FCOMP<setugt, floatcomp_ult, 1>;
defm : FCOMP<setuge, floatcomp_uge, 0>;
defm : FCOMP<setult, floatcomp_ult, 0>;
defm : FCOMP<setule, floatcomp_uge, 1>;
defm : FCOMP<setune, floatcomp_une, 0>;
def : Pat<(i32 (setuo f16:$r, f16:$r)), (FCOMPNHQ SingleReg:$r, SingleReg:$r, floatcomp_une)>;
def : Pat<(i32 (setuo f16:$rz, f16:$ry)), (ANDWrr (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_uge), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_ult))>;
def : Pat<(i32 (setuo f32:$r, f32:$r)), (FCOMPWrr SingleReg:$r, SingleReg:$r, floatcomp_une)>;
def : Pat<(i32 (setuo f32:$rz, f32:$ry)), (ANDWrr (FCOMPWrr SingleReg:$rz, SingleReg:$ry, floatcomp_uge), (FCOMPWrr SingleReg:$rz, SingleReg:$ry, floatcomp_ult))>;
def : Pat<(i32 (setuo f64:$r, f64:$r)), (FCOMPD   SingleReg:$r, SingleReg:$r, floatcomp_une)>;
def : Pat<(i32 (setuo f64:$rz, f64:$ry)), (ANDWrr (FCOMPD   SingleReg:$rz, SingleReg:$ry, floatcomp_uge), (FCOMPD   SingleReg:$rz, SingleReg:$ry, floatcomp_ult))>;
def : Pat<(i64 (setuo f32:$r, f32:$r)), (FCOMPWrr SingleReg:$r, SingleReg:$r, floatcomp_une)>;
def : Pat<(i64 (setuo f32:$rz, f32:$ry)), (ANDDrr (FCOMPWrr SingleReg:$rz, SingleReg:$ry, floatcomp_uge), (FCOMPWrr SingleReg:$rz, SingleReg:$ry, floatcomp_ult))>;
def : Pat<(i64 (setuo f64:$r, f64:$r)), (FCOMPD   SingleReg:$r, SingleReg:$r, floatcomp_une)>;
def : Pat<(i64 (setuo f64:$rz, f64:$ry)), (ANDDrr (FCOMPD   SingleReg:$rz, SingleReg:$ry, floatcomp_uge), (FCOMPD   SingleReg:$rz, SingleReg:$ry, floatcomp_ult))>;

// TODO: have some tests for these patterns.
def : Pat<(i32 (setoeq f32:$rz, Binary32:$imm)), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_oeq)>, Requires<[HasFPIMM]>;
def : Pat<(i32 (setogt Binary32:$imm, f32:$ry)), (FCOMPWri SingleReg:$ry, Binary32:$imm, floatcomp_olt)>, Requires<[HasFPIMM]>;
def : Pat<(i32 (setoge f32:$rz, Binary32:$imm)), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_oge)>, Requires<[HasFPIMM]>;
def : Pat<(i32 (setolt f32:$rz, Binary32:$imm)), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_olt)>, Requires<[HasFPIMM]>;
def : Pat<(i32 (setole Binary32:$imm, f32:$ry)), (FCOMPWri SingleReg:$ry, Binary32:$imm, floatcomp_oge)>, Requires<[HasFPIMM]>;
def : Pat<(i32 (setone f32:$rz, Binary32:$imm)), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_one)>, Requires<[HasFPIMM]>;
def : Pat<(i32 (seto f32:$rz, Binary32:$imm)), (ORDrr (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_oge), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_olt))>, Requires<[HasFPIMM]>;
def : Pat<(i32 (setuo f32:$rz, Binary32:$imm)), (ANDDrr (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_uge), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_ult))>, Requires<[HasFPIMM]>;
def : Pat<(i32 (setueq f32:$rz, Binary32:$imm)), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_ueq)>, Requires<[HasFPIMM]>;
def : Pat<(i32 (setugt Binary32:$imm, f32:$ry)), (FCOMPWri SingleReg:$ry, Binary32:$imm, floatcomp_ult)>, Requires<[HasFPIMM]>;
def : Pat<(i32 (setuge f32:$rz, Binary32:$imm)), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_uge)>, Requires<[HasFPIMM]>;
def : Pat<(i32 (setult f32:$rz, Binary32:$imm)), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_ult)>, Requires<[HasFPIMM]>;
def : Pat<(i32 (setule Binary32:$imm, f32:$ry)), (FCOMPWri SingleReg:$ry, Binary32:$imm, floatcomp_uge)>, Requires<[HasFPIMM]>;
def : Pat<(i32 (setune f32:$rz, Binary32:$imm)), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_une)>, Requires<[HasFPIMM]>;
def : Pat<(i64 (setoeq f32:$rz, Binary32:$imm)), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_oeq)>, Requires<[HasFPIMM]>;
def : Pat<(i64 (setogt Binary32:$imm, f32:$ry)), (FCOMPWri SingleReg:$ry, Binary32:$imm, floatcomp_olt)>, Requires<[HasFPIMM]>;
def : Pat<(i64 (setoge f32:$rz, Binary32:$imm)), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_oge)>, Requires<[HasFPIMM]>;
def : Pat<(i64 (setolt f32:$rz, Binary32:$imm)), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_olt)>, Requires<[HasFPIMM]>;
def : Pat<(i64 (setole Binary32:$imm, f32:$ry)), (FCOMPWri SingleReg:$ry, Binary32:$imm, floatcomp_oge)>, Requires<[HasFPIMM]>;
def : Pat<(i64 (setone f32:$rz, Binary32:$imm)), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_one)>, Requires<[HasFPIMM]>;
def : Pat<(i64 (seto f32:$rz, Binary32:$imm)), (ORDrr (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_oge), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_olt))>, Requires<[HasFPIMM]>;
def : Pat<(i64 (setuo f32:$rz, Binary32:$imm)), (ANDDrr (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_uge), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_ult))>, Requires<[HasFPIMM]>;
def : Pat<(i64 (setueq f32:$rz, Binary32:$imm)), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_ueq)>, Requires<[HasFPIMM]>;
def : Pat<(i64 (setugt Binary32:$imm, f32:$ry)), (FCOMPWri SingleReg:$ry, Binary32:$imm, floatcomp_ult)>, Requires<[HasFPIMM]>;
def : Pat<(i64 (setuge f32:$rz, Binary32:$imm)), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_uge)>, Requires<[HasFPIMM]>;
def : Pat<(i64 (setult f32:$rz, Binary32:$imm)), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_ult)>, Requires<[HasFPIMM]>;
def : Pat<(i64 (setule Binary32:$imm, f32:$ry)), (FCOMPWri SingleReg:$ry, Binary32:$imm, floatcomp_uge)>, Requires<[HasFPIMM]>;
def : Pat<(i64 (setune f32:$rz, Binary32:$imm)), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_une)>, Requires<[HasFPIMM]>;


multiclass COMP_FPat<SDNode Node, Floatcomp Cmp, bit SWAP> {
  def : Pat<(v2i16 (Node v2f16:$rz, v2f16:$ry)),
    !if(SWAP, (FCOMPNHQ SingleReg:$ry, SingleReg:$rz, Cmp), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, Cmp))>;
  def : Pat<(sra (shl (v2i16 (Node v2f16:$rz, v2f16:$ry)), (v2i16 v2_splat_15)), (v2i16 v2_splat_15)),
    !if(SWAP, (FCOMPNHQ SingleReg:$ry, SingleReg:$rz, Cmp), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, Cmp))>;

  def : Pat<(v4i16 (Node v4f16:$rz, v4f16:$ry)),
    !if(SWAP, (FCOMPNHQ SingleReg:$ry, SingleReg:$rz, Cmp), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, Cmp))>;
  def : Pat<(sra (shl (v4i16 (Node v4f16:$rz, v4f16:$ry)), (v4i16 v4_splat_15)), (v4i16 v4_splat_15)),
    !if(SWAP, (FCOMPNHQ SingleReg:$ry, SingleReg:$rz, Cmp), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, Cmp))>;

  def : Pat<(v2i32 (Node v2f32:$rz, v2f32:$ry)),
    !if(SWAP, (FCOMPNWP SingleReg:$ry, SingleReg:$rz, Cmp), (FCOMPNWP SingleReg:$rz, SingleReg:$ry, Cmp))>;
  def : Pat<(sra (shl (v2i32 (Node v2f32:$rz, v2f32:$ry)), (v2i32 v2_splat_31)), (v2i32 v2_splat_31)),
    !if(SWAP, (FCOMPNWP SingleReg:$ry, SingleReg:$rz, Cmp), (FCOMPNWP SingleReg:$rz, SingleReg:$ry, Cmp))>;

  def : Pat<(v4i32 (Node v4f32:$rz, v4f32:$ry)),
    !if(SWAP,
        (v4i32 (REG_SEQUENCE PairedReg,
            (v2i32 ( FCOMPNWP (v2f32 (EXTRACT_SUBREG PairedReg:$ry, sub_s0)),
                            (v2f32 (EXTRACT_SUBREG PairedReg:$rz, sub_s0)),
                   Cmp)),
            sub_s0,
            (v2i32 (FCOMPNWP (v2f32 (EXTRACT_SUBREG PairedReg:$ry, sub_s1)),
                            (v2f32 (EXTRACT_SUBREG PairedReg:$rz, sub_s1)),
                   Cmp)),
            sub_s1)),
        (v4i32 (REG_SEQUENCE PairedReg,
            (v2i32 ( FCOMPNWP (v2f32 (EXTRACT_SUBREG PairedReg:$rz, sub_s0)),
                            (v2f32 (EXTRACT_SUBREG PairedReg:$ry, sub_s0)),
                   Cmp)),
            sub_s0,
            (v2i32 (FCOMPNWP (v2f32 (EXTRACT_SUBREG PairedReg:$rz, sub_s1)),
                            (v2f32 (EXTRACT_SUBREG PairedReg:$ry, sub_s1)),
                   Cmp)),
            sub_s1)))>;
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

// Using -ffast-math generates the following setcc patterns
// TODO: shouldn't be unordered ones?
defm : COMP_FPat<seteq, floatcomp_oeq, 0>;
defm : COMP_FPat<setgt, floatcomp_olt, 1>;
defm : COMP_FPat<setge, floatcomp_oge, 0>;
defm : COMP_FPat<setlt, floatcomp_olt, 0>;
defm : COMP_FPat<setle, floatcomp_oge, 1>;
defm : COMP_FPat<setne, floatcomp_one, 0>;

def : Pat<(v2i16 (seto v2f16:$r, v2f16:$r)), (FCOMPNHQ SingleReg:$r, SingleReg:$r, floatcomp_oeq)>;
def : Pat<(v2i16 (seto v2f16:$rz, v2f16:$ry)), (ORWrr (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_oge), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_olt))>;
def : Pat<(v2i16 (setuo v2f16:$r, v2f16:$r)), (FCOMPNHQ SingleReg:$r, SingleReg:$r, floatcomp_une)>;
def : Pat<(v2i16 (setuo v2f16:$rz, v2f16:$ry)), (ANDWrr (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_uge), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_ult))>;

def : Pat<(v4i16 (seto v4f16:$r, v4f16:$r)), (FCOMPNHQ SingleReg:$r, SingleReg:$r, floatcomp_oeq)>;
def : Pat<(v4i16 (seto v4f16:$rz, v4f16:$ry)), (ORDrr (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_oge), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_olt))>;
def : Pat<(v2i16 (setuo v4f16:$r, v4f16:$r)), (FCOMPNHQ SingleReg:$r, SingleReg:$r, floatcomp_une)>;
def : Pat<(v4i16 (setuo v4f16:$rz, v4f16:$ry)), (ANDDrr (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_uge), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_ult))>;

def : Pat<(v2i32 (seto v2f32:$r, v2f32:$r)), (FCOMPNWP SingleReg:$r, SingleReg:$r, floatcomp_oeq)>;
def : Pat<(v2i32 (seto v2f32:$rz, v2f32:$ry)), (ORDrr (FCOMPNWP SingleReg:$rz, SingleReg:$ry, floatcomp_oge), (FCOMPNWP SingleReg:$rz, SingleReg:$ry, floatcomp_olt))>;
def : Pat<(v2i32 (setuo v2f32:$r, v2f32:$r)), (FCOMPNWP SingleReg:$r, SingleReg:$r, floatcomp_une)>;
def : Pat<(v2i32 (setuo v2f32:$rz, v2f32:$ry)), (ANDDrr (FCOMPNWP SingleReg:$rz, SingleReg:$ry, floatcomp_uge), (FCOMPNWP SingleReg:$rz, SingleReg:$ry, floatcomp_ult))>;

def : Pat<(v4i32 (seto v4f32:$r, v4f32:$r)),
          (v4i32 (REG_SEQUENCE PairedReg,
            (v2i32 (FCOMPNWP
              (v2f32 (EXTRACT_SUBREG PairedReg:$r, sub_s0)),
              (v2f32 (EXTRACT_SUBREG PairedReg:$r, sub_s0)),
              floatcomp_oeq)),
            sub_s0,
            (v2i32 (FCOMPNWP
              (v2f32 (EXTRACT_SUBREG PairedReg:$r, sub_s1)),
              (v2f32 (EXTRACT_SUBREG PairedReg:$r, sub_s1)),
              floatcomp_oeq)),
              sub_s1))>;

def : Pat<(v4i32 (seto v4f32:$rz, v4f32:$ry)),
          (v4i32 (REG_SEQUENCE PairedReg,
            (v2i32 (ORDrr (FCOMPNWP
              (v2f32 (EXTRACT_SUBREG PairedReg:$rz, sub_s0)),
              (v2f32 (EXTRACT_SUBREG PairedReg:$ry, sub_s0)),
              floatcomp_oge),
                (FCOMPNWP
                  (v2f32 (EXTRACT_SUBREG PairedReg:$rz, sub_s0)),
                  (v2f32 (EXTRACT_SUBREG PairedReg:$ry, sub_s0)),
                  floatcomp_olt))),
              sub_s0,
            (v2i32 (ORDrr (FCOMPNWP
              (v2f32 (EXTRACT_SUBREG PairedReg:$rz, sub_s1)),
              (v2f32 (EXTRACT_SUBREG PairedReg:$ry, sub_s1)),
              floatcomp_oge),
                (FCOMPNWP
                  (v2f32 (EXTRACT_SUBREG PairedReg:$rz, sub_s1)),
                  (v2f32 (EXTRACT_SUBREG PairedReg:$ry, sub_s1)),
                  floatcomp_olt))),
              sub_s1))>;

def : Pat<(v4i32 (setuo v4f32:$r, v4f32:$r)),
          (v4i32 (REG_SEQUENCE PairedReg,
            (v2i32 (FCOMPNWP
              (v2f32 (EXTRACT_SUBREG PairedReg:$r, sub_s0)),
              (v2f32 (EXTRACT_SUBREG PairedReg:$r, sub_s0)),
              floatcomp_une)),
            sub_s0,
            (v2i32 (FCOMPNWP
              (v2f32 (EXTRACT_SUBREG PairedReg:$r, sub_s1)),
              (v2f32 (EXTRACT_SUBREG PairedReg:$r, sub_s1)),
              floatcomp_une)),
            sub_s1))>;

def : Pat<(v4i32 (setuo v4f32:$rz, v4f32:$ry)),
          (v4i32 (REG_SEQUENCE PairedReg,
            (v2i32 (ANDDrr (FCOMPNWP
              (v2f32 (EXTRACT_SUBREG PairedReg:$rz, sub_s0)),
              (v2f32 (EXTRACT_SUBREG PairedReg:$ry, sub_s0)),
              floatcomp_uge),
                (FCOMPNWP
                  (v2f32 (EXTRACT_SUBREG PairedReg:$rz, sub_s0)),
                  (v2f32 (EXTRACT_SUBREG PairedReg:$ry, sub_s0)),
                  floatcomp_ult))),
              sub_s0,
            (v2i32 (ANDDrr (FCOMPNWP
              (v2f32 (EXTRACT_SUBREG PairedReg:$rz, sub_s1)),
              (v2f32 (EXTRACT_SUBREG PairedReg:$ry, sub_s1)),
              floatcomp_uge),
                (FCOMPNWP
                  (v2f32 (EXTRACT_SUBREG PairedReg:$rz, sub_s1)),
                  (v2f32 (EXTRACT_SUBREG PairedReg:$ry, sub_s1)),
                  floatcomp_ult))),
              sub_s1))>;

defm : SELECTCONDW<(f16 f16:$truev), (f16 f16:$falsev),(f16 Binary16:$truev), (f16 Binary16:$falsev)>;
defm : SELECTCONDW<(f32 f32:$truev), (f32 f32:$falsev),(f32 Binary32:$truev), (f32 Binary32:$falsev)>;
defm : SELECTCONDW<(f64 f64:$truev), (f64 f64:$falsev),(f64 Binary64:$truev), (f64 Binary64:$falsev)>;

defm : SELECTCONDD<(f16 f16:$truev), (f16 f16:$falsev),(f16 Binary16:$truev), (f16 Binary16:$falsev)>;
defm : SELECTCONDD<(f32 f32:$truev), (f32 f32:$falsev),(f32 Binary32:$truev), (f32 Binary32:$falsev)>;
defm : SELECTCONDD<(f64 f64:$truev), (f64 f64:$falsev),(f64 Binary64:$truev), (f64 Binary64:$falsev)>;

//FDOT2W
// TODO: add ri37 variation
def : Pat<(f32 (fadd (f32 (vector_extract (v2f32 (fmul v2f32:$lhs, (is_imm_vec:$rhs))), (i64 0))),
                    (f32 (vector_extract (v2f32 (fmul v2f32:$lhs, (is_imm_vec:$rhs))), (i64 1))))),
          (f32 (FDOT2Wri SingleReg:$lhs, (build_fpimm_vec $rhs)))>;

def : Pat<(f32 (fsub (f32 (vector_extract (v2f32 (fmul v2f32:$lhs, (is_imm_vec:$rhs))), (i64 1))),
                    (f32 (vector_extract (v2f32 (fmul v2f32:$lhs, (is_imm_vec:$rhs))), (i64 0))))),
          (f32 (FDOT2Wri SingleReg:$lhs, (build_fpimm_vec_neg0 $rhs)))>;

def : Pat<(f32 (fsub (f32 (vector_extract (v2f32 (fmul v2f32:$lhs, (is_imm_vec:$rhs))), (i64 0))),
                    (f32 (vector_extract (v2f32 (fmul v2f32:$lhs, (is_imm_vec:$rhs))), (i64 1))))),
          (f32 (FDOT2Wri SingleReg:$lhs, (build_fpimm_vec_neg1 $rhs)))>;

def : Pat<(f32 (fadd (f32 (vector_extract (v2f32 (fmul v2f32:$lhs, v2f32:$rhs)), (i64 0))),
                     (f32 (vector_extract (v2f32 (fmul v2f32:$lhs, v2f32:$rhs)), (i64 1))))),
          (f32 (FDOT2Wrr SingleReg:$lhs, SingleReg:$rhs, rounding_, silent_))>;

def : Pat<(f32 (fadd (f32 (fmul
                              (f32 (bitconvert (i32 (trunc (i64 (srl i64:$lhs, (i64 32))))))),
                              (f32 (bitconvert (i32 (trunc (i64 (srl i64:$rhs, (i64 32))))))))),
                     (f32 (fmul
                              (f32 (bitconvert (i32 (trunc i64:$lhs)))),
                              (f32 ( bitconvert (i32 (trunc i64:$rhs)))))))),
          (f32 (FDOT2Wrr SingleReg:$lhs, SingleReg:$rhs, rounding_, silent_))>;

def : Pat<(f32 (fadd (f32 (fmul
                              (f32 (vector_extract v2f32:$lhs, (i64 1))),
                              (f32 (bitconvert (i32 (trunc (i64 (srl i64:$rhs, (i64 32))))))))),
                     (f32 (fmul
                              (f32 (vector_extract v2f32:$lhs, (i64 0))),
                              (f32 ( bitconvert (i32 (trunc i64:$rhs)))))))),
          (f32 (FDOT2Wrr SingleReg:$lhs, SingleReg:$rhs, rounding_, silent_))>;


// FFMA
// FIXME: Must find a way to convert a Binary16 to a Binary16x4
// def : Pat<(f16 (kvx_fma f16:$rx, Binary16:$ry, f16:$rz)), (f16(FFMAHQri (f16 SingleReg:$rz), (f16 SingleReg:$rx), ???:$ry))>, Requires<[HasFPIMM]>;
def : Pat<(f16 (kvx_fma f16:$rx, f16:$ry, f16:$rz)), (FFMAHQrr (ZXHD SingleReg:$rz), (ZXHD SingleReg:$rx), (ZXHD SingleReg:$ry), rounding_, silent_)>;

def : Pat<(f32 (kvx_fma f32:$rx, Binary32:$ry, f32:$rz)), (FFMAWri SingleReg:$rz, SingleReg:$rx, Binary32:$ry)>, Requires<[HasFPIMM]>;
def : Pat<(f32 (kvx_fma f32:$rx, f32:$ry, f32:$rz)), (FFMAWrr SingleReg:$rz, SingleReg:$rx, SingleReg:$ry, rounding_, silent_)>;

def : Pat<(f64 (kvx_fma f64:$rx, Binary64:$ry, f64:$rz)), (FFMADri SingleReg:$rz, SingleReg:$rx, Binary64:$ry)>, Requires <[HasFPIMM]>;
def : Pat<(f64 (kvx_fma f64:$rx, f64:$ry, f64:$rz)), (FFMADrr SingleReg:$rz, SingleReg:$rx, SingleReg:$ry, rounding_, silent_)>;

def : Pat<(v2f32 (kvx_fma v2f32:$rx, v2f32:$ry, v2f32:$rz)), (FFMAWPrr SingleReg:$rz, SingleReg:$rx, SingleReg:$ry, rounding_, silent_)>;
def : Pat<(v2f32 (kvx_fma v2f32:$rx, (v2f32 (is_imm_vec:$IMM)), v2f32:$rz)), (FFMAWPri SingleReg:$rz, SingleReg:$rx, (build_fpimm_vec $IMM))>, Requires<[HasFPIMM]>;

def : Pat<(v2f16 (kvx_fma v2f16:$rx, (v2f16 (is_imm_vec:$IMM)), v2f16:$rz)), (FFMAHQri  (ZXWD SingleReg:$rz), (ZXWD SingleReg:$rx), (build_fpimm_vec $IMM))>, Requires<[HasFPIMM]>;
def : Pat<(v2f16 (kvx_fma v2f16:$rx, v2f16:$ry, v2f16:$rz)), (FFMAHQrr (ZXWD SingleReg:$rz), (ZXWD SingleReg:$rx), (ZXWD SingleReg:$ry), rounding_, silent_)>;

def : Pat<(v4f16 (kvx_fma v4f16:$rx, (v4f16 (is_imm_vec:$IMM)), v4f16:$rz)), (FFMAHQri SingleReg:$rz, SingleReg:$rx, (build_fpimm_vec $IMM))>, Requires<[HasFPIMM]>;
def : Pat<(v4f16 (kvx_fma v4f16:$rx, v4f16:$ry, v4f16:$rz)), (FFMAHQrr SingleReg:$rz, SingleReg:$rx, SingleReg:$ry, rounding_, silent_)>;

// TODO: Add ri variants
def : Pat<(v4f32 (kvx_fma v4f32:$rx, v4f32:$ry, v4f32:$rz)),
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
def : Pat <(f16 (fsubcont f16:$r0, (fmulcont f16:$r2, f16:$r1))), (FFMSHQrr (ZXHD SingleReg:$r0), (ZXHD SingleReg:$r1), (ZXHD SingleReg:$r2), rounding_, silent_)>;
def : Pat <(f32 (fsubcont f32:$r0, (fmulcont f32:$r2, f32:$r1))), (FFMSWrr SingleReg:$r0, SingleReg:$r1, SingleReg:$r2, rounding_, silent_)>;
def : Pat <(f64 (fsubcont f64:$r0, (fmulcont f64:$r2, f64:$r1))), (FFMSDrr SingleReg:$r0, SingleReg:$r1, SingleReg:$r2, rounding_, silent_)>;

def : Pat <(v2f32 (fsubcont v2f32:$r0, (fmulcont v2f32:$r2, v2f32:$r1))), (FFMSWPrr SingleReg:$r0, SingleReg:$r1, SingleReg:$r2, rounding_, silent_)>;
def : Pat <(v2f16 (fsubcont v2f16:$r0, (fmulcont v2f16:$r2, v2f16:$r1))), (FFMSHQrr (ZXWD SingleReg:$r0), (ZXWD SingleReg:$r1), (ZXWD SingleReg:$r2), rounding_, silent_)>;
def : Pat <(v4f16 (fsubcont v4f16:$r0, (fmulcont v4f16:$r2, v4f16:$r1))), (FFMSHQrr SingleReg:$r0, SingleReg:$r1, SingleReg:$r2, rounding_, silent_)>;

// FIXED
multiclass FP_TO_INT<SDNode fp_to_int, KVX_INSTRUCTION i32inst, KVX_INSTRUCTION i64inst, KVX_INSTRUCTION v2i32inst> {
def : Pat<(i32 (fp_to_int f16:$val)), (i32inst (FWIDENLHW SingleReg:$val, silent_), DefaultShift, rounding_rz, silent_)>;
def : Pat<(i32 (fp_to_int f32:$val)), (i32inst SingleReg:$val, DefaultShift, rounding_rz, silent_)>;
def : Pat<(i32 (fp_to_int f64:$val)), (i64inst SingleReg:$val, DefaultShift, rounding_rz, silent_)>;

def : Pat<(i64 (fp_to_int f16:$val)), (i64inst (FWIDENLWD (FWIDENLHW SingleReg:$val, silent_), silent_), DefaultShift, rounding_rz, silent_)>;
def : Pat<(i64 (fp_to_int f32:$val)), (i64inst (FWIDENLWD SingleReg:$val, silent_), DefaultShift, rounding_rz, silent_)>;
def : Pat<(i64 (fp_to_int f64:$val)), (i64inst SingleReg:$val, DefaultShift, rounding_rz, silent_)>;

def : Pat<(v2i16 (fp_to_int v2f16:$val)), (SRLDri
                                            (INSF
                                              (v2i32inst (FWIDENLHWP SingleReg:$val, silent_), DefaultShift, rounding_rz, silent_),
                                              (v2i32inst (FWIDENLHWP SingleReg:$val, silent_), DefaultShift, rounding_rz, silent_),
                                              31, 16),
                                            16)>;

def : Pat<(v2i16 (fp_to_int v2f32:$val)), (SRLDri
                                            (INSF
                                              (v2i32inst SingleReg:$val, DefaultShift, rounding_rz, silent_),
                                              (v2i32inst SingleReg:$val, DefaultShift, rounding_rz, silent_),
                                              31, 16),
                                            16)>;

def : Pat<(v2i16 (fp_to_int v2f64:$val)), (INSF
                                              (i64inst (f64 (EXTRACT_SUBREG PairedReg:$val, sub_s0)), DefaultShift, rounding_rz, silent_),
                                              (i64inst (f64 (EXTRACT_SUBREG PairedReg:$val, sub_s1)), DefaultShift, rounding_rz, silent_),
                                              31, 16)>;

def : Pat<(v2i32 (fp_to_int v2f16:$val)), (v2i32inst (FWIDENLHWP SingleReg:$val, silent_), DefaultShift, rounding_rz, silent_)>;

def : Pat<(v2i32 (fp_to_int v2f32:$val)), (v2i32inst SingleReg:$val, DefaultShift, rounding_rz, silent_)>;

def : Pat<(v2i32 (fp_to_int v2f64:$val)), (INSF
                                              (i64inst (v2f32(EXTRACT_SUBREG PairedReg:$val, sub_s0)), DefaultShift, rounding_rz, silent_),
                                              (i64inst (v2f32(EXTRACT_SUBREG PairedReg:$val, sub_s1)), DefaultShift, rounding_rz, silent_), 63, 32)>;

def : Pat<(v2i64 (fp_to_int v2f16:$val)), (REG_SEQUENCE PairedReg,
                                           (i64inst(FWIDENLWD (FWIDENLHWP SingleReg:$val, silent_), silent_), DefaultShift, rounding_rz, silent_), sub_s0,
                                           (i64inst(FWIDENMWD (FWIDENLHWP SingleReg:$val, silent_), silent_), DefaultShift, rounding_rz, silent_), sub_s1)>;

def : Pat<(v2i64 (fp_to_int v2f32:$val)), (REG_SEQUENCE PairedReg,
                                           (i64inst(FWIDENLWD SingleReg:$val, silent_), DefaultShift, rounding_rz, silent_), sub_s0,
                                           (i64inst(FWIDENMWD SingleReg:$val, silent_), DefaultShift, rounding_rz, silent_), sub_s1)>;

def : Pat<(v2i64 (fp_to_int v2f64:$val)), (REG_SEQUENCE PairedReg,
                                           (i64inst (f64 (EXTRACT_SUBREG PairedReg:$val, sub_s0)), DefaultShift, rounding_rz, silent_), sub_s0,
                                           (i64inst (f64 (EXTRACT_SUBREG PairedReg:$val, sub_s1)), DefaultShift, rounding_rz, silent_), sub_s1)>;

def : Pat<(v4i16 (fp_to_int v4f16:$val)), (INSF
                                             (INSF
                                               (INSF
                                                (v2i32inst (v2f32(FWIDENLHWP SingleReg:$val, silent_)), DefaultShift, rounding_rz, silent_),
                                                (EXTFZ
                                                  (v2i32inst (v2f32(FWIDENLHWP SingleReg:$val, silent_)), DefaultShift, rounding_rz, silent_),
                                                  47, 32),
                                                31, 16),
                                                (v2i32inst (v2f32(FWIDENMHWP SingleReg:$val, silent_)), DefaultShift, rounding_rz, silent_),
                                                47, 32),
                                              (EXTFZ
                                                (v2i32inst (v2f32(FWIDENMHWP SingleReg:$val, silent_)), DefaultShift, rounding_rz, silent_),
                                                47, 32),
                                              63, 48)>;

def : Pat<(v4i16 (fp_to_int v4f32:$val)), (INSF
                                             (INSF
                                               (INSF
                                                (v2i32inst (v2f32(EXTRACT_SUBREG PairedReg:$val, sub_s0)), DefaultShift, rounding_rz, silent_),
                                                (EXTFZ
                                                  (v2i32inst (v2f32(EXTRACT_SUBREG PairedReg:$val, sub_s0)), DefaultShift, rounding_rz, silent_),
                                                  47, 32),
                                                31, 16),
                                                (v2i32inst (v2f32(EXTRACT_SUBREG PairedReg:$val, sub_s1)), DefaultShift, rounding_rz, silent_),
                                                47, 32),
                                              (EXTFZ
                                                (v2i32inst (v2f32(EXTRACT_SUBREG PairedReg:$val, sub_s1)), DefaultShift, rounding_rz, silent_),
                                                47, 32),
                                              63, 48)>;

def : Pat<(v4i16 (fp_to_int v4f64:$val)), (INSF (INSF (INSF
                                                        (i64inst (f64 (EXTRACT_SUBREG QuadReg:$val, sub_s0)), DefaultShift, rounding_rz, silent_),
                                                        (i64inst (f64 (EXTRACT_SUBREG QuadReg:$val, sub_s1)), DefaultShift, rounding_rz, silent_),
                                                        31, 16),
                                                      (i64inst (f64 (EXTRACT_SUBREG QuadReg:$val, sub_s2)), DefaultShift, rounding_rz, silent_),
                                                      47, 32),
                                                 (i64inst (f64 (EXTRACT_SUBREG QuadReg:$val, sub_s3)), DefaultShift, rounding_rz, silent_),
                                                 63, 48)>;

def : Pat<(v4i32 (fp_to_int v4f16:$val)), (REG_SEQUENCE PairedReg,
                                            (v2i32inst (v2f32(FWIDENLHWP SingleReg:$val, silent_)), DefaultShift, rounding_rz, silent_), sub_s0,
                                            (v2i32inst (v2f32(FWIDENMHWP SingleReg:$val, silent_)), DefaultShift, rounding_rz, silent_), sub_s1)>;

def : Pat<(v4i32 (fp_to_int v4f32:$val)), (REG_SEQUENCE PairedReg,
                                              (v2i32inst (v2f32(EXTRACT_SUBREG PairedReg:$val, sub_s0)), DefaultShift, rounding_rz, silent_), sub_s0,
                                              (v2i32inst (v2f32(EXTRACT_SUBREG PairedReg:$val, sub_s1)), DefaultShift, rounding_rz, silent_), sub_s1)>;

def : Pat<(v4i32 (fp_to_int v4f64:$val)), (REG_SEQUENCE PairedReg,
                                              (INSF (i64inst (f64 (EXTRACT_SUBREG QuadReg:$val, sub_s0)), DefaultShift, rounding_rz, silent_),
                                                    (i64inst (f64 (EXTRACT_SUBREG QuadReg:$val, sub_s1)), DefaultShift, rounding_rz, silent_),
                                                63, 32),
                                                sub_s0,
                                              (INSF (i64inst (f64 (EXTRACT_SUBREG QuadReg:$val, sub_s2)), DefaultShift, rounding_rz, silent_),
                                                    (i64inst (f64 (EXTRACT_SUBREG QuadReg:$val, sub_s3)), DefaultShift, rounding_rz, silent_),
                                                63, 32),
                                                sub_s1)>;

def : Pat<(v4i64 (fp_to_int v4f16:$val)), (REG_SEQUENCE QuadReg,
                                           (i64inst(FWIDENLWD (FWIDENLHWP SingleReg:$val, silent_), silent_), DefaultShift, rounding_rz, silent_), sub_s0,
                                           (i64inst(FWIDENMWD (FWIDENLHWP SingleReg:$val, silent_), silent_), DefaultShift, rounding_rz, silent_), sub_s1,
                                           (i64inst(FWIDENLWD (FWIDENMHWP SingleReg:$val, silent_), silent_), DefaultShift, rounding_rz, silent_), sub_s2,
                                           (i64inst(FWIDENMWD (FWIDENMHWP SingleReg:$val, silent_), silent_), DefaultShift, rounding_rz, silent_), sub_s3)>;

def : Pat<(v4i64 (fp_to_int v4f32:$val)), (REG_SEQUENCE QuadReg,
                                           (i64inst(FWIDENLWD (v2f32 (EXTRACT_SUBREG PairedReg:$val, sub_s0)), silent_), DefaultShift, rounding_rz, silent_), sub_s0,
                                           (i64inst(FWIDENMWD (v2f32 (EXTRACT_SUBREG PairedReg:$val, sub_s0)), silent_), DefaultShift, rounding_rz, silent_), sub_s1,
                                           (i64inst(FWIDENLWD (v2f32 (EXTRACT_SUBREG PairedReg:$val, sub_s1)), silent_), DefaultShift, rounding_rz, silent_), sub_s2,
                                           (i64inst(FWIDENMWD (v2f32 (EXTRACT_SUBREG PairedReg:$val, sub_s1)), silent_), DefaultShift, rounding_rz, silent_), sub_s3)>;

def : Pat<(v4i64 (fp_to_int v4f64:$val)), (REG_SEQUENCE QuadReg,
                                           (i64inst (f64 (EXTRACT_SUBREG QuadReg:$val, sub_s0)), DefaultShift, rounding_rz, silent_), sub_s0,
                                           (i64inst (f64 (EXTRACT_SUBREG QuadReg:$val, sub_s1)), DefaultShift, rounding_rz, silent_), sub_s1,
                                           (i64inst (f64 (EXTRACT_SUBREG QuadReg:$val, sub_s2)), DefaultShift, rounding_rz, silent_), sub_s2,
                                           (i64inst (f64 (EXTRACT_SUBREG QuadReg:$val, sub_s3)), DefaultShift, rounding_rz, silent_), sub_s3)>;
}

defm : FP_TO_INT<fp_to_sint, FIXEDW, FIXEDD, FIXEDWP>;
defm : FP_TO_INT<fp_to_uint, FIXEDUW, FIXEDUD, FIXEDUWP>;

// FLOAT
// FIXME: f16 patterns have issues with double rounding / implement RTcalls ?
multiclass INT_TO_FP<SDNode int_to_fp, KVX_INSTRUCTION i32inst, KVX_INSTRUCTION i64inst, KVX_INSTRUCTION v2i32inst, KVX_INSTRUCTION ext, KVX_INSTRUCTION shift> {
def : Pat<(f16 (int_to_fp i32:$val)), (FNARROWWH (i32inst SingleReg:$val, DefaultShift, rounding_rn, silent_), rounding_rn, silent_)>;
def : Pat<(f16 (int_to_fp i64:$val)), (FNARROWWH (FNARROWDW (i64inst SingleReg:$val, DefaultShift, rounding_rn, silent_), rounding_rn, silent_), rounding_rn, silent_)>;

def : Pat<(f32 (int_to_fp i32:$val)), (i32inst SingleReg:$val, DefaultShift, rounding_rn, silent_)>;
def : Pat<(f32 (int_to_fp i64:$val)), (FNARROWDW (i64inst SingleReg:$val, DefaultShift, rounding_rn, silent_), rounding_rn, silent_)>;

def : Pat<(f64 (int_to_fp i32:$val)), (i64inst (ext SingleReg:$val), DefaultShift, rounding_rn, silent_)>;
def : Pat<(f64 (int_to_fp i64:$val)), (i64inst SingleReg:$val, DefaultShift, rounding_rn, silent_)>;

def : Pat<(v2f16 (int_to_fp v2i32:$val)), (FNARROWWHQ
                                            (REG_SEQUENCE PairedReg,
                                              (MAKEi16 0), sub_s1,
                                              (v2i32inst SingleReg:$val, DefaultShift, rounding_rn, silent_), sub_s0
                                            ),
                                            rounding_rn, silent_)>;

def : Pat<(v2f32 (int_to_fp v2i32:$val)), (v2i32inst SingleReg:$val, DefaultShift, rounding_rn, silent_)>;

def : Pat<(v2f64 (int_to_fp v2i32:$val)), (REG_SEQUENCE PairedReg,
                                            (i64inst (shift SingleReg:$val, 32), DefaultShift, rounding_rn, silent_),
                                            sub_s1,
                                            (i64inst (ext SingleReg:$val), DefaultShift, rounding_rn, silent_),
                                            sub_s0)>;

def : Pat<(v4f16 (int_to_fp v4i32:$val)), (FNARROWWHQ
                                            (REG_SEQUENCE PairedReg,
                                              (v2i32inst (v2i32 (EXTRACT_SUBREG PairedReg:$val, sub_s1)), DefaultShift, rounding_rn, silent_), sub_s1,
                                              (v2i32inst (v2i32 (EXTRACT_SUBREG PairedReg:$val, sub_s0)), DefaultShift, rounding_rn, silent_), sub_s0
                                            ),
                                            rounding_rn, silent_)>;

def : Pat<(v4f32 (int_to_fp v4i32:$val)), (REG_SEQUENCE PairedReg,
                                              (v2i32inst (v2i32 (EXTRACT_SUBREG PairedReg:$val, sub_s0)), DefaultShift, rounding_rn, silent_), sub_s0,
                                              (v2i32inst (v2i32 (EXTRACT_SUBREG PairedReg:$val, sub_s1)), DefaultShift, rounding_rn, silent_), sub_s1)>;

def : Pat<(v4f64 (int_to_fp v4i32:$val)), (REG_SEQUENCE QuadReg,
                                            (i64inst (shift (v2i32 (EXTRACT_SUBREG PairedReg:$val, sub_s1)), 32), DefaultShift, rounding_rn, silent_), sub_s3,
                                            (i64inst (ext (v2i32 (EXTRACT_SUBREG PairedReg:$val, sub_s1))), DefaultShift, rounding_rn, silent_), sub_s2,
                                            (i64inst (shift (v2i32 (EXTRACT_SUBREG PairedReg:$val, sub_s0)), 32), DefaultShift, rounding_rn, silent_), sub_s1,
                                            (i64inst (ext (v2i32 (EXTRACT_SUBREG PairedReg:$val, sub_s0))), DefaultShift, rounding_rn, silent_), sub_s0)>;

}

defm : INT_TO_FP<sint_to_fp, FLOATW, FLOATD, FLOATWP, SXWD, SRADri>;
defm : INT_TO_FP<uint_to_fp, FLOATUW, FLOATUD, FLOATUWP, ZXWD, SRLDri>;

// FMUL
// TODO: Add ri variants
// def : Pat<(fmul f16:$rs1, (f16 Binary16:$rs2)), (f16(FMULHQri (f16(ZXHD (f16 SingleReg:$rs1))), Binary16x4:$a3, rounding_, silent_))>;
def : Pat<(fmul f32:$rs1, Binary32:$rs2), (FMULWri SingleReg:$rs1, Binary32:$rs2)>, Requires<[HasFPIMM]>;
def : Pat<(fmul f64:$rs1, Binary64:$rs2), (FMULDri SingleReg:$rs1, Binary64:$rs2)>, Requires<[HasFPIMM]>;
def : Pat<(fmul f16:$rs1, f16:$rs2), (FMULHQrr (ZXHD SingleReg:$rs1), (ZXHD SingleReg:$rs2), rounding_, silent_)>;
def : Pat<(fmul f32:$rs1, f32:$rs2), (FMULWrr SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fmul f64:$rs1, f64:$rs2), (FMULDrr SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fmul v2f16:$rs1, v2f16:$rs2), (FMULHQrr (ZXWD SingleReg:$rs1), (ZXWD SingleReg:$rs2), rounding_, silent_)>;
def : Pat<(fmul v4f16:$rs1, v4f16:$rs2), (FMULHQrr SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fmul v2f32:$rs1, v2f32:$rs2), (FMULWPrr SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fmul v4f32:$rs1, v4f32:$rs2), (FMULWQ PairedReg:$rs1, PairedReg:$rs2, rounding_, silent_)>;

// FNARROW
def : Pat<(f16 (fpround f32:$val)), (FNARROWWH SingleReg:$val, rounding_, silent_)>;
def : Pat<(f16 (fpround f64:$val)), (FNARROWWH (FNARROWDW SingleReg:$val, rounding_, silent_), rounding_, silent_)>;
def : Pat<(f32 (fpround f64:$val)), (FNARROWDW SingleReg:$val, rounding_, silent_)>;
def : Pat<(v2f16 (fpround v2f32:$val)), (FNARROWWHQ (INSERT_SUBREG
                                                      (INSERT_SUBREG (v4f32 (IMPLICIT_DEF)), SingleReg:$val, sub_s0),
                                                      (ANDWri10 (v2f32 (IMPLICIT_DEF)), 0), sub_s1), rounding_, silent_)>;
def : Pat<(v4f16 (fpround v4f32:$val)), (FNARROWWHQ PairedReg:$val, rounding_, silent_)>;

def : Pat<(v2f16 (fpround v2f64:$val)), (INSF (FNARROWWH (FNARROWDW (f64 (EXTRACT_SUBREG PairedReg:$val, sub_s0)), rounding_, silent_), rounding_, silent_),
                                              (FNARROWWH (FNARROWDW (f64 (EXTRACT_SUBREG PairedReg:$val, sub_s1)), rounding_, silent_), rounding_, silent_), 31, 16)>;
def : Pat<(v4f16 (fpround v4f64:$val)), (INSF
                                          (INSF (FNARROWWH (FNARROWDW (f64 (EXTRACT_SUBREG QuadReg:$val, sub_s0)), rounding_, silent_), rounding_, silent_),
                                                (FNARROWWH (FNARROWDW (f64 (EXTRACT_SUBREG QuadReg:$val, sub_s1)), rounding_, silent_), rounding_, silent_), 31, 16),
                                          (INSF (FNARROWWH (FNARROWDW (f64 (EXTRACT_SUBREG QuadReg:$val, sub_s2)), rounding_, silent_), rounding_, silent_),
                                                (FNARROWWH (FNARROWDW (f64 (EXTRACT_SUBREG QuadReg:$val, sub_s3)), rounding_, silent_), rounding_, silent_), 31, 16),
                                        63, 32)>;

// FMAX
def : Pat<(f16 (fmaxnum f16:$v0, f16:$v1)), (FMAXHQ $v0, $v1)>;
def : Pat<(v2f16 (fmaxnum v2f16:$v0, v2f16:$v1)), (FMAXHQ $v0, $v1)>;

// FMIN
def : Pat<(f16 (fminnum f16:$v0, f16:$v1)), (FMINHQ $v0, $v1)>;
def : Pat<(v2f16 (fminnum v2f16:$v0, v2f16:$v1)), (FMINHQ $v0, $v1)>;

// FNEG
def : Pat<(fneg f16:$rs), (FNEGHQ SingleReg:$rs)>;
def : Pat<(fneg v2f16:$rs), (FNEGHQ SingleReg:$rs)>;
def : Pat<(vfneg v2f16:$rs), (FNEGHQ SingleReg:$rs)>;
def : Pat<(vfneg v4f16:$rs), (FNEGHQ SingleReg:$rs)>;
def : Pat<(vfneg v2f32:$rs), (FNEGWP SingleReg:$rs)>;

// FSBF
// TODO: Add ri variants
// def : Pat<(f16(fsub (f16 Binary16:$rs2), f16:$rs2)), (f16(FSBFHQri (f16(ZXHD SingleReg:$rs2)), Binary16x4:$rs1))>;
def : Pat<(fsub Binary32:$rs1, f32:$rs2), (FSBFWri SingleReg:$rs2, Binary32:$rs1)>, Requires<[HasFPIMM]>;
def : Pat<(fsub Binary64:$rs1, f64:$rs2), (FSBFDri SingleReg:$rs2, Binary64:$rs1)>, Requires<[HasFPIMM]>;
def : Pat<(fsub f16:$rs1, f16:$rs2), (FSBFHQrr (ZXHD SingleReg:$rs2), (ZXHD SingleReg:$rs1), rounding_, silent_)>;
def : Pat<(fsub f32:$rs1, f32:$rs2), (FSBFWrr SingleReg:$rs2, SingleReg:$rs1, rounding_, silent_)>;
def : Pat<(fsub f64:$rs1, f64:$rs2), (FSBFDrr SingleReg:$rs2, SingleReg:$rs1, rounding_, silent_)>;
def : Pat<(fsub v2f16:$rs1, v2f16:$rs2), (FSBFHQrr (ZXWD SingleReg:$rs2), (ZXWD SingleReg:$rs1), rounding_, silent_)>;
def : Pat<(fsub v4f16:$rs1, v4f16:$rs2), (FSBFHQrr SingleReg:$rs2, SingleReg:$rs1, rounding_, silent_)>;
def : Pat<(fsub v2f32:$rs1, v2f32:$rs2), (FSBFWPrr SingleReg:$rs2, SingleReg:$rs1, rounding_, silent_)>;
def : Pat<(fsub v4f32:$rs1, v4f32:$rs2), (FSBFWQ PairedReg:$rs2, PairedReg:$rs1, rounding_, silent_)>;
def : Pat<(fsub v2f64:$rs1, v2f64:$rs2), (FSBFDP PairedReg:$rs2, PairedReg:$rs1, rounding_, silent_)>;
def : Pat<(v4f64 (fsub v4f64:$rs1, v4f64:$rs2)),
          (v4f64(REG_SEQUENCE QuadReg,
            (v2f64(FSBFDP
              (v2f64 (EXTRACT_SUBREG QuadReg:$rs2, sub_p0)),
              (v2f64 (EXTRACT_SUBREG QuadReg:$rs1, sub_p0)),
              rounding_,
              silent_)),
            sub_p0,
            (v2f64(FSBFDP
              (v2f64 (EXTRACT_SUBREG QuadReg:$rs2, sub_p1)),
              (v2f64 (EXTRACT_SUBREG QuadReg:$rs1, sub_p1)),
              rounding_,
              silent_)),
            sub_p1))>;

// FWIDEN
def : Pat<(f64 (fpextend f32:$val)), (FWIDENLWD SingleReg:$val, silent_)>;
def : Pat<(f64 (fpextend f16:$val)), (FWIDENLWD (FWIDENLHW SingleReg:$val, silent_), silent_)>;
def : Pat<(f32 (fpextend f16:$val)), (FWIDENLHW SingleReg:$val, silent_)>;
def : Pat<(v2f32 (fpextend v2f16:$val)), (FWIDENLHWP SingleReg:$val, silent_)>;
def : Pat<(v4f32 (fpextend v4f16:$val)), (INSERT_SUBREG
                                           (INSERT_SUBREG (v4f32 (IMPLICIT_DEF)), (v2f32 (FWIDENLHWP SingleReg:$val, silent_)), sub_s0),
                                           (v2f32 (FWIDENMHWP SingleReg:$val, silent_)), sub_s1)>;

// build_vector and vector_extract
// v2f16
def : Pat<(v2f16 (is_imm_vec:$IMM)), (MAKEi43 (build_fpimm_vec $IMM))>;
def : Pat<(v2f16 (build_vector (f16(vector_extract v2f16:$v, 0)), (f16(vector_extract v2f16:$v, 0)))),
          (INSF SingleReg:$v, SingleReg:$v, 31, 16)>;
def : Pat<(v2f16 (build_vector (f16(vector_extract v2f16:$v0, 0)), (f16(vector_extract v2f16:$v1, 0)))),
          (INSF SingleReg:$v0, SingleReg:$v1, 31, 16)>;
def : Pat<(v2f16 (build_vector (f16(vector_extract v2f16:$v, 1)), (f16(vector_extract v2f16:$v, 0)))),
          (SBMM8ri64 SingleReg:$v, 0x02010804)>;
def : Pat<(v2f16 (build_vector (f16(vector_extract v2f16:$v, 1)), (f16(vector_extract v2f16:$v, 1)))),
          (SBMM8ri64 SingleReg:$v, 0x08040804)>;
def : Pat<(v2f16 (build_vector f16:$v0, f16:$v1)), (INSF SingleReg:$v0, SingleReg:$v1, 31, 16)>;
def : Pat<(f16 (vector_extract v2f16:$v, i64:$p)), (SRLWrr SingleReg:$v, (SLLWri SingleReg:$p, 5))>;

// v2f32
def : Pat<(v2i32 (is_imm_vec_kvx_splat32_:$IMM)), (MAKEi43 (build_fpimm_vec $IMM))>;
def : Pat<(v2f32 (is_imm_vec:$IMM)), (MAKEi64 (build_fpimm_vec $IMM))>;
def : Pat<(v2f32 (build_vector f32:$v0, f32:$v1)), (INSF SingleReg:$v0, SingleReg:$v1, 63, 32)>;
def : Pat<(v2f32 (build_vector (f32(vector_extract v2f32:$v, 1)), (f32(vector_extract v2f32:$v, 0)))),
          (SBMM8ri64 SingleReg:$v, 0x0804020180402010)>;
def : Pat<(v2f32 (build_vector (f32(vector_extract v2f32:$v, 1)), (f32(vector_extract v2f32:$v, 1)))),
          (SBMM8ri64 SingleReg:$v, 0x8040201080402010)>;
def : Pat<(v2f32 (build_vector (f32(vector_extract v2f32:$v0, 1)), (f32(vector_extract v2f32:$v1, 0)))),
          (SBMM8ri64 (INSF SingleReg:$v0, SingleReg:$v1, 31, 0), 0x0804020180402010)>;
def : Pat<(f32 (vector_extract v2f32:$v, i64:$p)), (SRLDrr SingleReg:$v, (SLLWri SingleReg:$p, 6))>;

// v4f16
def : Pat<(v4f16 (is_imm_vec:$IMM)), (MAKEi64 (build_fpimm_vec $IMM))>;
def : Pat<(v4f16 (build_vector f16:$v0, f16:$v1, f16:$v2, f16:$v3)),
          (INSF (INSF SingleReg:$v0, SingleReg:$v1, 31, 16), (INSF SingleReg:$v2, SingleReg:$v3, 31, 16), 63, 32)>;
def : Pat<(f16 (vector_extract v4f16:$v, i64:$p)), (SRLDrr SingleReg:$v, (SLLWri SingleReg:$p, 5))>;

// v2f32
def : Pat<(extractelt (v2f32 SingleReg:$v), 0), (COPY SingleReg:$v)>;
def : Pat<(extractelt (v2f32 SingleReg:$v), 1), (SRADri SingleReg :$v, (i64 32))>;

// v2f32 <--> complex<float> (i64)
def ComplexToVec : Pat<(v2f32 (build_vector (f32(bitconvert(i32(trunc(i64 SingleReg:$d))))),
                            (f32(bitconvert(i32(trunc(i64(srl (i64 SingleReg:$d), (i64 32))))))))),
          (v2f32 SingleReg:$d)>;

def VecToComplex : Pat<(i64( or (shl (anyext (i32 ( extractelt (v2i32 SingleReg:$v), (i64 1)))), (i64 32)),
                               (zext (i32 ( extractelt (v2i32 SingleReg:$v), (i64 0)))))),
          (i64 SingleReg:$v)>;
def : Pat<(f32 (vector_extract v2f32:$v, i64:$p)), (SRLDrr SingleReg:$v, (SLLWri SingleReg:$p, 5))>;

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
def : Pat<(f64 (vector_extract v2f64:$v, i64:$p)),
          (CMOVEDrr SingleReg:$p, (i64 (EXTRACT_SUBREG PairedReg:$v, sub_s0)), (i64 (EXTRACT_SUBREG PairedReg:$v, sub_s1)), scalarcond_odd)>;

// v2f16
def : Pat<(extractelt v2f16:$v, 0), (COPY SingleReg:$v)>;
def : Pat<(extractelt v2f16:$v, 1), (SRLWri SingleReg:$v, (i64 16))>;

// v4f16
def : Pat<(extractelt (v4f16 SingleReg:$v), 0), (COPY SingleReg:$v)>;
def : Pat<(extractelt (v4f16 SingleReg:$v), 1), (SRLWri SingleReg:$v, 16)>;
def : Pat<(extractelt (v4f16 SingleReg:$v), 2), (SRLDri SingleReg:$v, 32)>;
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
          (v2f64 (EXTRACT_SUBREG $v, sub_p0))>;

def : Pat<(v2f64 (extract_subvector (v4f64 QuadReg:$v), (i64 2))),
          (v2f64 (EXTRACT_SUBREG $v, sub_p1))>;

// insert_vector_element
// v2f16
def : Pat<(v2f16 (insertelt v2f16:$to, f16:$e, i64:$idx)),
          (CMOVEDrr SingleReg:$idx,
            (INSF SingleReg:$to, SingleReg:$e, 31, 16),
            (INSF SingleReg:$to, SingleReg:$e, 15, 0),
            scalarcond_even)>;

// v2f32
def : Pat<(v2f32 (insertelt v2f32:$to, f32:$e, i64:$idx)),
          (CMOVEDrr SingleReg:$idx,
            (INSF SingleReg:$to, SingleReg:$e, 63, 32),
            (INSF SingleReg:$to, SingleReg:$e, 31, 0),
            scalarcond_even)>;

// v2f64
def : Pat<(v2f64 (insertelt v2f64:$to, f64:$e, i64:$idx)),
          (REG_SEQUENCE PairedReg,
            (CMOVEDrr SingleReg:$idx, (f64 (EXTRACT_SUBREG PairedReg:$to, sub_s0)), SingleReg:$e, scalarcond_even),
            sub_s0,
            (CMOVEDrr SingleReg:$idx, (f64 (EXTRACT_SUBREG PairedReg:$to, sub_s1)), SingleReg:$e, scalarcond_odd),
            sub_s1 )>;
// v4f16
def : Pat<(v4f16 (insertelt v4f16:$to, f16:$e, i64:$idx)),
              (CMOVEHQ
                (COMPNHQ
                  (MAKEi64 0x3000200010000),
                  (INSF
                    (INSF SingleReg:$idx, SingleReg:$idx, 31, 16),
                    (INSF SingleReg:$idx, SingleReg:$idx, 31, 16),
                    63, 32),
                  comparison_eq),
                  SingleReg:$to,
                  (INSF
                    (INSF SingleReg:$e, SingleReg:$e, 31, 16),
                    (INSF SingleReg:$e, SingleReg:$e, 31, 16),
                    63, 32),
                simplecond_nez)>;

// v4f32
def : Pat<(v4f32 (insertelt v4f32:$to, f32:$e, 0)),
            (REG_SEQUENCE PairedReg,
              (INSF (v2f32(EXTRACT_SUBREG PairedReg:$to, sub_s0)), SingleReg:$e, 31, 0),
              sub_s0,
              (v2f32 (EXTRACT_SUBREG PairedReg:$to, sub_s1)),
              sub_s1)>;

def : Pat<(v4f32 (insertelt v4f32:$to, f32:$e, (i64 1))),
            (REG_SEQUENCE PairedReg,
              (INSF (v2f32(EXTRACT_SUBREG PairedReg:$to, sub_s0)), SingleReg:$e, 63, 32),
              sub_s0,
              (v2f32 (EXTRACT_SUBREG PairedReg:$to, sub_s1)),
              sub_s1)>;

def : Pat<(v4f32 (insertelt v4f32:$to, f32:$e, (i64 2))),
            (REG_SEQUENCE PairedReg,
              (v2f32 (EXTRACT_SUBREG PairedReg:$to, sub_s0)),
              sub_s0,
              (INSF (v2f32 (EXTRACT_SUBREG PairedReg:$to, sub_s1)), SingleReg:$e, 31, 0),
              sub_s1)>;

def : Pat<(v4f32 (insertelt v4f32:$to, f32:$e, (i64 3))),
            (REG_SEQUENCE PairedReg,
              (v2f32 (EXTRACT_SUBREG PairedReg:$to, sub_s0)),
              sub_s0,
              (INSF (v2f32 (EXTRACT_SUBREG PairedReg:$to, sub_s1)), SingleReg:$e, 63, 32),
              sub_s1)>;

def : Pat<(v4f32 (insertelt v4f32:$to, f32:$e, i64:$idx)),
            (REG_SEQUENCE PairedReg,
              (CMOVEWP
                (COMPNWP (MAKEi64 0x100000000), (INSF SingleReg:$idx, SingleReg:$idx, 63, 31), comparison_eq),
                (v2f32 (EXTRACT_SUBREG PairedReg:$to, sub_s0)),
                (INSF SingleReg:$e, SingleReg:$e, 63, 31),
                simplecond_eqz
               ),
               sub_s0,
              (CMOVEWP
                (COMPNWP (MAKEi64 0x300000002), (INSF SingleReg:$idx, SingleReg:$idx, 63, 31), comparison_eq),
                (v2f32 (EXTRACT_SUBREG PairedReg:$to, sub_s1)),
                (INSF SingleReg:$e, SingleReg:$e, 63, 31),
                simplecond_eqz
               ),
               sub_s1)>;

// v4f64
def : Pat<(v4f64 (insertelt v4f64:$to, f64:$e, i64:$idx)),
          (REG_SEQUENCE QuadReg,
            (CMOVEDrr (COMPDri10 SingleReg:$idx, 0, comparison_eq), (f64 (EXTRACT_SUBREG QuadReg:$to, sub_s0)), SingleReg:$e, scalarcond_odd),
            sub_s0,
            (CMOVEDrr (COMPDri10 SingleReg:$idx, 1, comparison_eq), (f64 (EXTRACT_SUBREG QuadReg:$to, sub_s1)), SingleReg:$e, scalarcond_odd),
            sub_s1,
            (CMOVEDrr (COMPDri10 SingleReg:$idx, 2, comparison_eq), (f64 (EXTRACT_SUBREG QuadReg:$to, sub_s2)), SingleReg:$e, scalarcond_odd),
            sub_s2,
            (CMOVEDrr (COMPDri10 SingleReg:$idx, 3, comparison_eq), (f64 (EXTRACT_SUBREG QuadReg:$to, sub_s3)), SingleReg:$e, scalarcond_odd),
            sub_s3)>;

// Patterns used only for -freciprocal-math
def : Pat<(fdiv f32:$a, f32:$b), (FMULWrr SingleReg:$a, (FRECW SingleReg:$b, rounding_, silent_), rounding_, silent_)>;
def : Pat<(fsqrt f32:$a), (FMULWrr SingleReg:$a, (FRSRW SingleReg:$a, rounding_, silent_), rounding_, silent_)>;
