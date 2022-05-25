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
defm : StorePat<store, f16, SingleReg, 1, SHp, SHri10,  SHri37,  SHri64, SHrr>;
defm : StorePatNode<truncstoref16, f32, SingleReg, 1, SHp, SHri10,  SHri37,  SHri64, SHrr,
                    (FNARROWWH SingleReg:$val, rounding_, silent_)>;
defm : StorePatNode<truncstoref16, f64, SingleReg, 1, SHp, SHri10,  SHri37,  SHri64, SHrr,
                    (FNARROWWH (FNARROWDW SingleReg:$val, rounding_, silent_),
                      rounding_, silent_)>;

defm : StorePat<store, f32, SingleReg, 2, SWp, SWri10,  SWri37,  SWri64, SWrr>;
defm : StorePatNode<truncstoref32, f64, SingleReg, 2, SWp, SWri10,  SWri37,  SWri64, SWrr,
                    (FNARROWDW SingleReg:$val, rounding_, silent_)>;
defm : StorePat<store, v2f16, SingleReg, 2, SWp, SWri10,  SWri37,  SWri64, SWrr>;

defm : StorePat<store, f64, SingleReg, 3, SDp, SDri10,  SDri37,  SDri64, SDrr>;
defm : StorePat<store, v2f32, SingleReg, 3, SDp, SDri10,  SDri37,  SDri64, SDrr>;
defm : StorePat<store, v4f16, SingleReg, 3, SDp, SDri10,  SDri37,  SDri64, SDrr>;

defm : StorePat<store, v4f32, PairedReg, 4, SQp, SQri10,  SQri37,  SQri64, SQrr>;
defm : StorePat<store, v2f64, PairedReg, 4, SQp, SQri10,  SQri37,  SQri64, SQrr>;

defm : StorePat<store, v4f64, QuadReg, 5, SOp, SOri10,  SOri37,  SOri64, SOrr>;

def fmulcont : PatFrag<(ops node:$op0, node:$op1), (fmul node:$op0, node:$op1), [{
    return N->getFlags().hasAllowContract();
  }]>;

def faddcont : PatFrag<(ops node:$op0, node:$op1), (fadd node:$op0, node:$op1), [{
    return N->getFlags().hasAllowContract();
  }]>;

def fsubcont : PatFrag<(ops node:$op0, node:$op1), (fsub node:$op0, node:$op1), [{
    return N->getFlags().hasAllowContract();
  }]>;

defm : LoadPat<load, f16, 1, LHZp, LHZri10, LHZri37, LHZri64, LHZrr>;
defm : LoadPat<load, f32, 2, LWZp, LWZri10, LWZri37, LWZri64, LWZrr>;
defm : LoadPat<load, v2f16, 2, LWZp, LWZri10, LWZri37, LWZri64, LWZrr>;
defm : LoadPat<load, f64, 3, LDp, LDri10, LDri37, LDri64, LDrr>;
defm : LoadPat<load, v2f32, 3, LDp, LDri10, LDri37, LDri64, LDrr>;
defm : LoadPat<load, v4f16, 3, LDp, LDri10, LDri37, LDri64, LDrr>;
defm : LoadPat<load, v4f32, 4, LQp, LQri10, LQri37, LQri64, LQrr>;
defm : LoadPat<load, v2f64, 4, LQp, LQri10, LQri37, LQri64, LQrr>;
defm : LoadPat<load, v4f64, 5, LOp, LOri10, LOri37, LOri64, LOrr>;

// FABS
def : Pat<(v2f16(fabs v2f16:$v)), (FABSHQ SingleReg:$v)>;
def : Pat<(v4f16(fabs v4f16:$v)), (FABSHQ SingleReg:$v)>;

// FADD
def : Pat<(f16(fadd f16:$r, Binary16:$IMM)), (f16 (FADDHQri (f16(ZXHD SingleReg:$r)), (get_fpimm_16 fpimm:$IMM)))>, Requires<[IsV1]>;
def : Pat<(f16(fadd f16:$r, Binary16:$IMM)), (f16 (FADDHQrr (f16(ZXHD SingleReg:$r)), (MAKEi16 (get_fpimm_16 fpimm:$IMM)), rounding_, silent_))>;
def : Pat<(fadd f32:$rs1, Binary32:$rs2), (FADDWri SingleReg:$rs1, Binary32:$rs2)>, Requires<[IsV1]>;
def : Pat<(fadd f64:$rs1, Binary64:$rs2), (FADDDri SingleReg:$rs1, Binary64:$rs2)>, Requires<[IsV1]>;
def : Pat<(fadd f16:$rs1, f16:$rs2), (FADDHQrr (ZXHD SingleReg:$rs1), (ZXHD SingleReg:$rs2), rounding_, silent_)>;
def : Pat<(fadd f32:$rs1, f32:$rs2), (FADDWrr SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fadd f64:$rs1, f64:$rs2), (FADDDrr SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(v2f16(fadd v2f16:$r, (v2f16 (is_imm_vec:$IMM)))), (v2f16 (FADDHQri (ZXWD SingleReg:$r), (build_imm_vec $IMM)))>, Requires<[IsV1]>;
def : Pat<(v2f16(fadd v2f16:$r, (v2f16 (is_imm_vec:$IMM)))), (v2f16 (FADDHQrr (ZXWD SingleReg:$r), (MAKEi43 (build_imm_vec $IMM)), rounding_, silent_))>;
def : Pat<(fadd v2f16:$rs1, v2f16:$rs2), (FADDHQrr (ZXWD SingleReg:$rs1), (ZXWD SingleReg:$rs2), rounding_, silent_)>;
def : Pat<(v4f16(fadd v4f16:$r, (v4f16 (is_imm_vec:$IMM)))), (v4f16 (FADDHQri SingleReg:$r, (build_imm_vec $IMM)))>, Requires<[IsV1]>;
def : Pat<(fadd v4f16:$rs1, v4f16:$rs2), (FADDHQrr SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(v2f32(fadd v2f32:$r, (v2f32 (is_imm_vec:$IMM)))), (v2f32 (FADDWPri SingleReg:$r, (build_imm_vec $IMM), conjugate_))>, Requires<[IsV1]>;
def : Pat<(fadd v2f32:$rs1, v2f32:$rs2), (FADDWPrr SingleReg:$rs1, SingleReg:$rs2, conjugate_, rounding_, silent_)>;
def : Pat<(fadd v4f32:$rs1, v4f32:$rs2), (FADDWQ PairedReg:$rs1, PairedReg:$rs2, conjugate_, rounding_, silent_)>;
def : Pat<(fadd v2f64:$rs1, v2f64:$rs2), (FADDDP PairedReg:$rs1, PairedReg:$rs2, conjugate_, rounding_, silent_)>;
def : Pat<(v4f64 (fadd v4f64:$rs1, v4f64:$rs2)),
          (v4f64(REG_SEQUENCE QuadReg,
            (v2f64(FADDDP
              (v2f64 (EXTRACT_SUBREG QuadReg:$rs1, sub_p0)),
              (v2f64 (EXTRACT_SUBREG QuadReg:$rs2, sub_p0)),
              conjugate_,
              rounding_,
              silent_)),
            sub_p0,
            (v2f64(FADDDP
              (v2f64 (EXTRACT_SUBREG QuadReg:$rs1, sub_p1)),
              (v2f64 (EXTRACT_SUBREG QuadReg:$rs2, sub_p1)),
              conjugate_,
              rounding_,
              silent_)),
            sub_p1))>;

// FCOMP
multiclass FCOMP<SDNode SetCC, Floatcomp Cmp, bit SwapOperands> {
  defm : ZAext_And1_Pat<(i32 (SetCC f16:$rz, f16:$ry)),
    !if(SwapOperands,
     (ANDWri10 (FCOMPNHQ SingleReg:$ry, SingleReg:$rz, Cmp), 1),
     (ANDWri10 (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, Cmp), 1)
    )>;

  // FCOMPWri
  def : Pat<
    !if(SwapOperands,
        (i32 (SetCC Binary32:$imm, f32:$r)),
        (i32 (SetCC f32:$r, Binary32:$imm))
       ),
     (FCOMPWri SingleReg:$r, Binary32:$imm, Cmp)
    >;

  // FCOMPNWrr
  def : Pat<(i32 (SetCC f32:$rz, f32:$ry)),
    !if(SwapOperands,
     (FCOMPWrr SingleReg:$ry, SingleReg:$rz, Cmp),
     (FCOMPWrr SingleReg:$rz, SingleReg:$ry, Cmp)
    )>;

  def : Pat<(i32 (SetCC f64:$rz, f64:$ry)),
    !if(SwapOperands,
     (FCOMPD SingleReg:$ry, SingleReg:$rz, Cmp),
     (FCOMPD SingleReg:$rz, SingleReg:$ry, Cmp)
    )>;

  // FCOMPNWri
  def : Pat<
    !if(SwapOperands,
       (select (i32 (SetCC Binary32:$imm, f32:$r)), (i32 -1), (i32 0)),
       (select (i32 (SetCC f32:$r, Binary32:$imm)), (i32 -1), (i32 0))
       ),
     (FCOMPNWri SingleReg:$r, Binary32:$imm, Cmp)
    >, Requires<[IsV2]>;

  // FCOMPNWrr
  def : Pat<(select (i32 (SetCC f32:$rz, f32:$ry)), (i32 -1), (i32 0)),
    !if(SwapOperands,
     (FCOMPNWrr SingleReg:$ry, SingleReg:$rz, Cmp),
     (FCOMPNWrr SingleReg:$rz, SingleReg:$ry, Cmp)
    )>, Requires<[IsV2]>;

  // FCOMPW + NEGW
  def : Pat<
    !if(SwapOperands,
       (select (i32 (SetCC Binary32:$imm, f32:$r)), (i32 -1), (i32 0)),
       (select (i32 (SetCC f32:$r, Binary32:$imm)), (i32 -1), (i32 0))
       ),
     (NEGW(FCOMPWri SingleReg:$r, Binary32:$imm, Cmp))
    >;

  def : Pat<(select (i32 (SetCC f32:$rz, f32:$ry)), (i32 -1), (i32 0)),
    !if(SwapOperands,
     (NEGW (FCOMPWrr SingleReg:$ry, SingleReg:$rz, Cmp)),
     (NEGW (FCOMPWrr SingleReg:$rz, SingleReg:$ry, Cmp))
    )>;

  // FCOMPD + NEGW
  def : Pat<(select (i32 (SetCC f64:$rz, f64:$ry)), (i32 -1), (i32 0)),
    !if(SwapOperands,
     (NEGW (FCOMPD SingleReg:$ry, SingleReg:$rz, Cmp)),
     (NEGW (FCOMPD SingleReg:$rz, SingleReg:$ry, Cmp))
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
def : Pat<(i32 (seto f16:$r, f16:$r)), (ANDWri10 (FCOMPNHQ SingleReg:$r, SingleReg:$r, floatcomp_oeq), 1)>;
def : Pat<(i32 (seto f16:$rz, f16:$ry)), (ANDWri10 (ORWrr (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_oge), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_olt)), 1)>;
def : Pat<(i32 (seto f32:$r, f32:$r)), (FCOMPWrr SingleReg:$r, SingleReg:$r, floatcomp_oeq)>;
def : Pat<(i32 (seto f32:$rz, f32:$ry)), (ORWrr (FCOMPWrr SingleReg:$rz, SingleReg:$ry, floatcomp_oge), (FCOMPWrr SingleReg:$rz, SingleReg:$ry, floatcomp_olt))>;
def : Pat<(i32 (seto f64:$r, f64:$r)), (FCOMPD SingleReg:$r, SingleReg:$r, floatcomp_oeq)>;
def : Pat<(i32 (seto f64:$rz, f64:$ry)), (ORWrr (FCOMPD   SingleReg:$rz, SingleReg:$ry, floatcomp_oge), (FCOMPD   SingleReg:$rz, SingleReg:$ry, floatcomp_olt))>;

// Unordered comparisons
defm : FCOMP<setueq, floatcomp_ueq, 0>;
defm : FCOMP<setugt, floatcomp_ult, 1>;
defm : FCOMP<setuge, floatcomp_uge, 0>;
defm : FCOMP<setult, floatcomp_ult, 0>;
defm : FCOMP<setule, floatcomp_uge, 1>;
defm : FCOMP<setune, floatcomp_une, 0>;
def : Pat<(i32 (setuo f16:$r, f16:$r)), (ANDWri10 (FCOMPNHQ SingleReg:$r, SingleReg:$r, floatcomp_une), 1)>;
def : Pat<(i32 (setuo f16:$rz, f16:$ry)), (ANDWri10 (ANDWrr (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_uge), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_ult)), 1)>;
def : Pat<(i32 (setuo f32:$r, f32:$r)), (FCOMPWrr SingleReg:$r, SingleReg:$r, floatcomp_une)>;
def : Pat<(i32 (setuo f32:$rz, f32:$ry)), (ANDWrr (FCOMPWrr SingleReg:$rz, SingleReg:$ry, floatcomp_uge), (FCOMPWrr SingleReg:$rz, SingleReg:$ry, floatcomp_ult))>;
def : Pat<(i32 (setuo f64:$r, f64:$r)), (FCOMPD   SingleReg:$r, SingleReg:$r, floatcomp_une)>;
def : Pat<(i32 (setuo f64:$rz, f64:$ry)), (ANDWrr (FCOMPD   SingleReg:$rz, SingleReg:$ry, floatcomp_uge), (FCOMPD   SingleReg:$rz, SingleReg:$ry, floatcomp_ult))>;

// TODO: have some tests for these patterns.
def : Pat<(i32 (seto f32:$rz, Binary32:$imm)), (ORDrr (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_oge), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_olt))>;
def : Pat<(i32 (setuo f32:$rz, Binary32:$imm)), (ANDDrr (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_uge), (FCOMPWri SingleReg:$rz, Binary32:$imm, floatcomp_ult))>;


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

// FDOT2W
def : Pat<(f32 (faddcont (f32 (vector_extract (v2f32 (fmulcont v2f32:$lhs, (is_imm_vec:$rhs))), (i64 0))),
                    (f32 (vector_extract (v2f32 (fmulcont v2f32:$lhs, (is_imm_vec:$rhs))), (i64 1))))),
          (f32 (FDOT2Wri SingleReg:$lhs, (build_imm_vec $rhs)))>, Requires<[IsV1]>;

def : Pat<(f32 (fsub (f32 (vector_extract (v2f32 (fmulcont v2f32:$lhs, (is_imm_vec:$rhs))), (i64 1))),
                    (f32 (vector_extract (v2f32 (fmulcont v2f32:$lhs, (is_imm_vec:$rhs))), (i64 0))))),
          (f32 (FDOT2Wri SingleReg:$lhs, (build_imm_vec_neg0 $rhs)))>, Requires<[IsV1]>;

def : Pat<(f32 (fsub (f32 (vector_extract (v2f32 (fmulcont v2f32:$lhs, (is_imm_vec:$rhs))), (i64 0))),
                    (f32 (vector_extract (v2f32 (fmulcont v2f32:$lhs, (is_imm_vec:$rhs))), (i64 1))))),
          (f32 (FDOT2Wri SingleReg:$lhs, (build_imm_vec_neg1 $rhs)))>, Requires<[IsV1]>;

def : Pat<(f32 (fma:$dot2fma
                  (f32 (bitconvert (i32 (trunc i64:$t2)))),
                  (fpimm),
                  (f32 (fmulcont
                      (f32 (bitconvert (i32 (trunc (srl i64:$t2, (i64 32)))))),
                      (fpimm))))),
          (f32 (FDOT2Wri SingleReg:$t2, (build_fdot_imm $dot2fma)))>, Requires<[IsV1]>;

def : Pat<(f32 (fma:$dot2fma
                  (f32 (bitconvert (i32 (trunc (srl i64:$t2, (i64 32)))))),
                  (fpimm),
                  (f32 (fmulcont
                      (f32 (bitconvert (i32 (trunc i64:$t2)))),
                      (fpimm))))),
          (f32 (FDOT2Wri SingleReg:$t2, (build_fdot_imm_swp $dot2fma)))>, Requires<[IsV1]>;

multiclass FDOT2WRR_FFDMAW<KVX_INSTRUCTION I> {
def : Pat<(f32 (faddcont (f32 (vector_extract (v2f32 (fmulcont v2f32:$lhs, (is_imm_vec:$rhs))), (i64 0))),
                    (f32 (vector_extract (v2f32 (fmulcont v2f32:$lhs, (is_imm_vec:$rhs))), (i64 1))))),
          (f32 (I SingleReg:$lhs, (MAKEi64 (build_imm_vec $rhs)), rounding_, silent_))>;

def : Pat<(f32 (fsub (f32 (vector_extract (v2f32 (fmulcont v2f32:$lhs, (is_imm_vec:$rhs))), (i64 1))),
                    (f32 (vector_extract (v2f32 (fmulcont v2f32:$lhs, (is_imm_vec:$rhs))), (i64 0))))),
          (f32 (I SingleReg:$lhs, (MAKEi64 (build_imm_vec_neg0 $rhs)), rounding_, silent_))>;

def : Pat<(f32 (fsub (f32 (vector_extract (v2f32 (fmulcont v2f32:$lhs, (is_imm_vec:$rhs))), (i64 0))),
                    (f32 (vector_extract (v2f32 (fmulcont v2f32:$lhs, (is_imm_vec:$rhs))), (i64 1))))),
          (f32 (I SingleReg:$lhs, (MAKEi64 (build_imm_vec_neg1 $rhs)), rounding_, silent_))>;

def : Pat<(f32 (faddcont (f32 (vector_extract (v2f32 (fmulcont v2f32:$lhs, v2f32:$rhs)), (i64 0))),
                     (f32 (vector_extract (v2f32 (fmulcont v2f32:$lhs, v2f32:$rhs)), (i64 1))))),
          (f32 (I SingleReg:$lhs, SingleReg:$rhs, rounding_, silent_))>;

def : Pat<(f32 (faddcont (f32 (fmulcont
                              (f32 (bitconvert (i32 (trunc (i64 (srl i64:$lhs, (i64 32))))))),
                              (f32 (bitconvert (i32 (trunc (i64 (srl i64:$rhs, (i64 32))))))))),
                     (f32 (fmulcont
                              (f32 (bitconvert (i32 (trunc i64:$lhs)))),
                              (f32 (bitconvert (i32 (trunc i64:$rhs)))))))),
          (f32 (I SingleReg:$lhs, SingleReg:$rhs, rounding_, silent_))>;

def : Pat<(f32 (fma
                  (f32 (bitconvert (i32 (trunc i64:$t2)))),
                  (f32 (bitconvert (i32 (trunc i64:$t4)))),
                  (f32 (fmulcont
                      (f32 (bitconvert (i32 (trunc (srl i64:$t2, (i64 32)))))),
                      (f32 (bitconvert (i32 (trunc (srl i64:$t4, (i64 32)))))))))),
          (f32 (I SingleReg:$t2, SingleReg:$t4, rounding_, silent_))>;

def : Pat<(f32 (fma:$dot2fma
                  (f32 (bitconvert (i32 (trunc i64:$t2)))),
                  (fpimm),
                  (f32 (fmulcont
                      (f32 (bitconvert (i32 (trunc (srl i64:$t2, (i64 32)))))),
                      (fpimm))))),
          (f32 (I SingleReg:$t2, (MAKEi64 (build_fdot_imm $dot2fma)), rounding_, silent_))>;

def : Pat<(f32 (fma:$dot2fma
                  (f32 (bitconvert (i32 (trunc (srl i64:$t2, (i64 32)))))),
                  (fpimm),
                  (f32 (fmulcont
                      (f32 (bitconvert (i32 (trunc i64:$t2)))),
                      (fpimm))))),
          (f32 (I SingleReg:$t2, (MAKEi64 (build_fdot_imm_swp $dot2fma)), rounding_, silent_))>;

def : Pat<(f32 (faddcont (f32 (fmulcont
                              (f32 (vector_extract v2f32:$lhs, (i64 1))),
                              (f32 (bitconvert (i32 (trunc (i64 (srl i64:$rhs, (i64 32))))))))),
                     (f32 (fmulcont
                              (f32 (vector_extract v2f32:$lhs, (i64 0))),
                              (f32 ( bitconvert (i32 (trunc i64:$rhs)))))))),
          (f32 (I SingleReg:$lhs, SingleReg:$rhs, rounding_, silent_))>;
}

defm : FDOT2WRR_FFDMAW<FDOT2Wrr>, Requires<[IsV1]>;
defm : FDOT2WRR_FFDMAW<FFDMAW>, Requires<[IsV2]>;

let Predicates = [IsV2] in {
// FFDMAWP
def : Pat<(v2f32 (faddcont
          (extract_subvector (fmulcont v4f32:$lhs, v4f32:$rhs), (i64 0)),
          (extract_subvector (fmulcont v4f32:$lhs, v4f32:$rhs), (i64 2)))),
         (FFDMAWP PairedReg:$lhs, PairedReg:$rhs, rounding_, silent_)>;

// FFDMDAW
def : Pat<(f32 (faddcont
          (faddcont
            (extractelt (fmulcont v2f32:$lhs, v2f32:$rhs), (i64 0)),
            f32:$acc),
          (extractelt (fmulcont v2f32:$lhs, v2f32:$rhs), (i64 1)))),
         (FFDMDAW SingleReg:$acc, SingleReg:$lhs, SingleReg:$rhs, rounding_, silent_)>;

def : Pat<(f32 (faddcont
          (faddcont
            (extractelt (fmulcont v2f32:$lhs, v2f32:$rhs), (i64 0)),
            (extractelt (fmulcont v2f32:$lhs, v2f32:$rhs), (i64 1))),
          f32:$acc)),
         (FFDMDAW SingleReg:$acc, SingleReg:$lhs, SingleReg:$rhs, rounding_, silent_)>;

// FFDMDAWP
def : Pat<(v2f32 (faddcont
          (faddcont
            (extract_subvector (fmulcont v4f32:$lhs, v4f32:$rhs), (i64 0)),
            v2f32:$acc),
          (extract_subvector (fmulcont v4f32:$lhs, v4f32:$rhs), (i64 2)))),
         (FFDMDAWP SingleReg:$acc, PairedReg:$lhs, PairedReg:$rhs, rounding_, silent_)>;

def : Pat<(v2f32 (faddcont
          (faddcont
            (extract_subvector (fmulcont v4f32:$lhs, v4f32:$rhs), (i64 0)),
            (extract_subvector (fmulcont v4f32:$lhs, v4f32:$rhs), (i64 2))),
            v2f32:$acc)),
         (FFDMDAWP SingleReg:$acc, PairedReg:$lhs, PairedReg:$rhs, rounding_, silent_)>;

// FFDMDSWP
def : Pat<(v2f32 (fsubcont
          (fsubcont
            v2f32:$acc,
            (extract_subvector (fmulcont v4f32:$lhs, v4f32:$rhs), (i64 0))),
          (extract_subvector (fmulcont v4f32:$lhs, v4f32:$rhs), (i64 2)))),
         (FFDMDSWP SingleReg:$acc, PairedReg:$lhs, PairedReg:$rhs, rounding_, silent_)>;

def : Pat<(v2f32 (fsubcont
          (fsubcont
            v2f32:$acc,
            (extract_subvector (fmulcont v4f32:$lhs, v4f32:$rhs), (i64 2))),
          (extract_subvector (fmulcont v4f32:$lhs, v4f32:$rhs), (i64 0)))),
         (FFDMDSWP SingleReg:$acc, PairedReg:$lhs, PairedReg:$rhs, rounding_, silent_)>;

def : Pat<(v2f32 (fsubcont
            v2f32:$acc,
            (faddcont
              (extract_subvector (fmulcont v4f32:$lhs, v4f32:$rhs), (i64 0)),
              (extract_subvector (fmulcont v4f32:$lhs, v4f32:$rhs), (i64 2))))),
         (FFDMDSWP SingleReg:$acc, PairedReg:$lhs, PairedReg:$rhs, rounding_, silent_)>;

// FFDMDSW
def : Pat<(f32 (fsubcont
          (fsubcont
            f32:$acc,
            (extractelt (fmulcont v2f32:$lhs, v2f32:$rhs), (i64 0))),
          (extractelt (fmulcont v2f32:$lhs, v2f32:$rhs), (i64 1)))),
         (FFDMDSW SingleReg:$acc, SingleReg:$lhs, SingleReg:$rhs, rounding_, silent_)>;

def : Pat<(f32 (fsubcont
          (fsubcont
            f32:$acc,
            (extractelt (fmulcont v2f32:$lhs, v2f32:$rhs), (i64 1))),
          (extractelt (fmulcont v2f32:$lhs, v2f32:$rhs), (i64 0)))),
         (FFDMDSW SingleReg:$acc, SingleReg:$lhs, SingleReg:$rhs, rounding_, silent_)>;

def : Pat<(f32 (fsubcont
          (fsubcont
            f32:$acc,
            (extractelt (fmulcont v2f32:$lhs, v2f32:$rhs), (i64 1))),
          (extractelt (fmulcont v2f32:$lhs, v2f32:$rhs), (i64 0)))),
         (FFDMDSW SingleReg:$acc, SingleReg:$lhs, SingleReg:$rhs, rounding_, silent_)>;

def : Pat<(f32 (fsubcont
          f32:$acc,
          (faddcont
            (extractelt (fmulcont v2f32:$lhs, v2f32:$rhs), (i64 0)),
            (extractelt (fmulcont v2f32:$lhs, v2f32:$rhs), (i64 1))))),
         (FFDMDSW SingleReg:$acc, SingleReg:$lhs, SingleReg:$rhs, rounding_, silent_)>;

// FFDMASW
def : Pat<(f32 (faddcont
          f32:$acc,
          (fsubcont
            (extractelt (fmulcont v2f32:$lhs, v2f32:$rhs), (i64 0)),
            (extractelt (fmulcont v2f32:$lhs, v2f32:$rhs), (i64 1))))),
         (FFDMASW SingleReg:$acc, SingleReg:$lhs, SingleReg:$rhs, rounding_, silent_)>;

def : Pat<(f32 (faddcont
          (extractelt (fmulcont v2f32:$lhs, v2f32:$rhs), (i64 0)),
          (fsubcont
            f32:$acc,
          (extractelt (fmulcont v2f32:$lhs, v2f32:$rhs), (i64 1))))),
         (FFDMASW SingleReg:$acc, SingleReg:$lhs, SingleReg:$rhs, rounding_, silent_)>;

def : Pat<(f32 (fsubcont
          (faddcont
            f32:$acc,
            (extractelt (fmulcont v2f32:$lhs, v2f32:$rhs), (i64 0))),
          (extractelt (fmulcont v2f32:$lhs, v2f32:$rhs), (i64 1)))),
         (FFDMASW SingleReg:$acc, SingleReg:$lhs, SingleReg:$rhs, rounding_, silent_)>;

// FFDMSAW
def : Pat<(f32 (faddcont
          f32:$acc,
          (fsubcont
            (extractelt (fmulcont v2f32:$lhs, v2f32:$rhs), (i64 1)),
            (extractelt (fmulcont v2f32:$lhs, v2f32:$rhs), (i64 0))))),
         (FFDMSAW SingleReg:$acc, SingleReg:$lhs, SingleReg:$rhs, rounding_, silent_)>;

def : Pat<(f32 (faddcont
          (extractelt (fmulcont v2f32:$lhs, v2f32:$rhs), (i64 1)),
          (fsubcont
            f32:$acc,
          (extractelt (fmulcont v2f32:$lhs, v2f32:$rhs), (i64 0))))),
         (FFDMSAW SingleReg:$acc, SingleReg:$lhs, SingleReg:$rhs, rounding_, silent_)>;

def : Pat<(f32 (fsubcont
          (faddcont
            f32:$acc,
            (extractelt (fmulcont v2f32:$lhs, v2f32:$rhs), (i64 1))),
          (extractelt (fmulcont v2f32:$lhs, v2f32:$rhs), (i64 0)))),
         (FFDMSAW SingleReg:$acc, SingleReg:$lhs, SingleReg:$rhs, rounding_, silent_)>;

// FFDMASWP
def : Pat<(v2f32 (faddcont
          v2f32:$acc,
          (fsubcont
            (extract_subvector (fmulcont v4f32:$lhs, v4f32:$rhs), (i64 0)),
            (extract_subvector (fmulcont v4f32:$lhs, v4f32:$rhs), (i64 2))))),
         (FFDMASWP SingleReg:$acc, PairedReg:$lhs, PairedReg:$rhs, rounding_, silent_)>;

def : Pat<(v2f32 (faddcont
          (extract_subvector (fmulcont v4f32:$lhs, v4f32:$rhs), (i64 0)),
          (fsubcont
            v2f32:$acc,
          (extract_subvector (fmulcont v4f32:$lhs, v4f32:$rhs), (i64 2))))),
         (FFDMASWP SingleReg:$acc, PairedReg:$lhs, PairedReg:$rhs, rounding_, silent_)>;

def : Pat<(v2f32 (fsubcont
          (faddcont
            v2f32:$acc,
            (extract_subvector (fmulcont v4f32:$lhs, v4f32:$rhs), (i64 0))),
          (extract_subvector (fmulcont v4f32:$lhs, v4f32:$rhs), (i64 2)))),
         (FFDMASWP SingleReg:$acc, PairedReg:$lhs, PairedReg:$rhs, rounding_, silent_)>;

// FFDMSAWP
def : Pat<(v2f32 (faddcont
          v2f32:$acc,
          (fsubcont
            (extract_subvector (fmulcont v4f32:$lhs, v4f32:$rhs), (i64 2)),
            (extract_subvector (fmulcont v4f32:$lhs, v4f32:$rhs), (i64 0))))),
         (FFDMSAWP SingleReg:$acc, PairedReg:$lhs, PairedReg:$rhs, rounding_, silent_)>;

def : Pat<(v2f32 (faddcont
          (extract_subvector (fmulcont v4f32:$lhs, v4f32:$rhs), (i64 2)),
          (fsubcont
            v2f32:$acc,
          (extract_subvector (fmulcont v4f32:$lhs, v4f32:$rhs), (i64 0))))),
         (FFDMSAWP SingleReg:$acc, PairedReg:$lhs, PairedReg:$rhs, rounding_, silent_)>;

def : Pat<(v2f32 (fsubcont
          (faddcont
            v2f32:$acc,
            (extract_subvector (fmulcont v4f32:$lhs, v4f32:$rhs), (i64 2))),
          (extract_subvector (fmulcont v4f32:$lhs, v4f32:$rhs), (i64 0)))),
         (FFDMSAWP SingleReg:$acc, PairedReg:$lhs, PairedReg:$rhs, rounding_, silent_)>;

// FFDMSW
def : Pat<(f32 (fsubcont
          (extractelt (fmulcont v2f32:$lhs, v2f32:$rhs), (i64 0)),
          (extractelt (fmulcont v2f32:$lhs, v2f32:$rhs), (i64 1)))),
         (FFDMSW SingleReg:$lhs, SingleReg:$rhs, rounding_, silent_)>;

// FFDMSWP
def : Pat<(v2f32 (fsubcont
          (extract_subvector (fmulcont v4f32:$lhs, v4f32:$rhs), (i64 0)),
          (extract_subvector (fmulcont v4f32:$lhs, v4f32:$rhs), (i64 2)))),
         (FFDMSWP PairedReg:$lhs, PairedReg:$rhs, rounding_, silent_)>;
}

// FFMA
def : Pat<(f16 (fma f16:$rx, Binary16:$IMM, f16:$rz)), (f16(FFMAHQri (ZXHD(f16 SingleReg:$rz)), (ZXHD(f16 SingleReg:$rx)), (get_fpimm_16 fpimm:$IMM)))>, Requires<[IsV1]>;
def : Pat<(f16 (fma f16:$rx, Binary16:$IMM, f16:$rz)), (f16(FFMAHQrr (ZXHD(f16 SingleReg:$rz)), (ZXHD(f16 SingleReg:$rx)), (MAKEi16 (get_fpimm_16 fpimm:$IMM)), rounding_, silent_))>;
def : Pat<(f16 (fma f16:$rx, f16:$ry, f16:$rz)), (FFMAHQrr (ZXHD SingleReg:$rz), (ZXHD SingleReg:$rx), (ZXHD SingleReg:$ry), rounding_, silent_)>;

def : Pat<(f32 (fma f32:$rx, Binary32:$ry, f32:$rz)), (FFMAWri SingleReg:$rz, SingleReg:$rx, Binary32:$ry)>, Requires<[IsV1]>;
def : Pat<(f32 (fma f32:$rx, f32:$ry, f32:$rz)), (FFMAWrr SingleReg:$rz, SingleReg:$rx, SingleReg:$ry, rounding_, silent_)>;

def : Pat<(f64 (fma f64:$rx, Binary64:$ry, f64:$rz)), (FFMADri SingleReg:$rz, SingleReg:$rx, Binary64:$ry)>, Requires <[IsV1]>;
def : Pat<(f64 (fma f64:$rx, f64:$ry, f64:$rz)), (FFMADrr SingleReg:$rz, SingleReg:$rx, SingleReg:$ry, rounding_, silent_)>;

// TODO: Add ri variants
def : Pat<(v2f64 (fma v2f64:$rx, v2f64:$ry, v2f64:$rz)),
          (v2f64 (REG_SEQUENCE PairedReg,
                  (f64 (FFMADrr
                       (f64 (EXTRACT_SUBREG PairedReg:$rz, sub_s0)),
                       (f64 (EXTRACT_SUBREG PairedReg:$rx, sub_s0)),
                       (f64 (EXTRACT_SUBREG PairedReg:$ry, sub_s0)),
                       rounding_, silent_)),
                  sub_s0,
                  (f64 (FFMADrr
                       (f64 (EXTRACT_SUBREG PairedReg:$rz, sub_s1)),
                       (f64 (EXTRACT_SUBREG PairedReg:$rx, sub_s1)),
                       (f64 (EXTRACT_SUBREG PairedReg:$ry, sub_s1)),
                       rounding_, silent_)),
                  sub_s1))>;

def : Pat<(v2f32 (fma v2f32:$rx, v2f32:$ry, v2f32:$rz)), (FFMAWPrr SingleReg:$rz, SingleReg:$rx, SingleReg:$ry, rounding_, silent_)>;
def : Pat<(v2f32 (fma v2f32:$rx, (v2f32 (is_imm_vec:$IMM)), v2f32:$rz)), (FFMAWPri SingleReg:$rz, SingleReg:$rx, (build_imm_vec $IMM))>, Requires<[IsV1]>;

def : Pat<(v2f16 (fma v2f16:$rx, (v2f16 (is_imm_vec:$IMM)), v2f16:$rz)), (FFMAHQri  (ZXWD SingleReg:$rz), (ZXWD SingleReg:$rx), (build_imm_vec $IMM))>, Requires<[IsV1]>;
def : Pat<(v2f16 (fma v2f16:$rx, (v2f16 (is_imm_vec:$IMM)), v2f16:$rz)), (FFMAHQrr  (ZXWD SingleReg:$rz), (ZXWD SingleReg:$rx), (MAKEi64 (build_imm_vec $IMM)), rounding_, silent_)>;
def : Pat<(v2f16 (fma v2f16:$rx, v2f16:$ry, v2f16:$rz)), (FFMAHQrr (ZXWD SingleReg:$rz), (ZXWD SingleReg:$rx), (ZXWD SingleReg:$ry), rounding_, silent_)>;

def : Pat<(v4f16 (fma v4f16:$rx, (v4f16 (is_imm_vec:$IMM)), v4f16:$rz)), (FFMAHQri SingleReg:$rz, SingleReg:$rx, (build_imm_vec $IMM))>, Requires<[IsV1]>;
def : Pat<(v4f16 (fma v4f16:$rx, v4f16:$ry, v4f16:$rz)), (FFMAHQrr SingleReg:$rz, SingleReg:$rx, SingleReg:$ry, rounding_, silent_)>;

def : Pat<(v4f32 (fma v4f32:$lhs, v4f32:$rhs, v4f32:$acc)),
          (FFMAWQ PairedReg:$acc, PairedReg:$lhs, PairedReg:$rhs, rounding_, silent_)>, Requires<[IsV2]>;

// TODO: Add ri variants
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

// FFMAHW
// TODO: ri variants
def : Pat<(f32 (fma (f32 (fpextend f16:$r1)), (f32 (fpextend f16:$r2)), f32:$r0)),
          (FFMAHWrr SingleReg:$r0, SingleReg:$r1, SingleReg:$r2, rounding_, silent_)>;

// FFMAHWQ
// TODO: ri variants
def : Pat<(v4f32 (fma (v4f32 (fpextend v4f16:$r1)), (v4f32 (fpextend v4f16:$r2)), v4f32:$r0)),
          (FFMAHWQrr PairedReg:$r0, SingleReg:$r1, SingleReg:$r2, rounding_, silent_)>;

// FFMAWDP
// TODO: ri variants
def : Pat<(v2f64 (fma (v2f64 (fpextend v2f32:$r1)), (v2f64 (fpextend v2f32:$r2)), v2f64:$r0)),
          (FFMAWDPrr PairedReg:$r0, SingleReg:$r1, SingleReg:$r2, rounding_, silent_)>;

// FFMS
def : Pat <(f16 (fsubcont f16:$r0, (fmulcont f16:$r2, f16:$r1))), (FFMSHQrr (ZXHD SingleReg:$r0), (ZXHD SingleReg:$r1), (ZXHD SingleReg:$r2), rounding_, silent_)>;
def : Pat <(f32 (fsubcont f32:$r0, (fmulcont f32:$r2, f32:$r1))), (FFMSWrr SingleReg:$r0, SingleReg:$r1, SingleReg:$r2, rounding_, silent_)>;
def : Pat <(f64 (fsubcont f64:$r0, (fmulcont f64:$r2, f64:$r1))), (FFMSDrr SingleReg:$r0, SingleReg:$r1, SingleReg:$r2, rounding_, silent_)>;

def : Pat <(v2f32 (fsubcont v2f32:$r0, (fmulcont v2f32:$r2, v2f32:$r1))), (FFMSWPrr SingleReg:$r0, SingleReg:$r1, SingleReg:$r2, rounding_, silent_)>;
def : Pat <(v2f16 (fsubcont v2f16:$r0, (fmulcont v2f16:$r2, v2f16:$r1))), (FFMSHQrr (ZXWD SingleReg:$r0), (ZXWD SingleReg:$r1), (ZXWD SingleReg:$r2), rounding_, silent_)>;
def : Pat <(v4f16 (fsubcont v4f16:$r0, (fmulcont v4f16:$r2, v4f16:$r1))), (FFMSHQrr SingleReg:$r0, SingleReg:$r1, SingleReg:$r2, rounding_, silent_)>;

multiclass FFMSPAT<ValueType vt, KVX_INSTRUCTION FMS, KVX_INSTRUCTION MUL, RegisterClass RC> {
def : Pat<(vt (fma (vfneg vt:$rx), vt:$ry, vt:$rz)),
          (FMS RC:$rz, RC:$rx, RC:$ry, rounding_, silent_)>;

def : Pat<(vt (fma vt:$rx, vt:$ry, (fneg (fmul vt:$rz, vt:$ra)))),
          (FMS (MUL vt:$rx, vt:$ry, rounding_, silent_), RC:$rz, RC:$ra, rounding_, silent_)>;
}
defm : FFMSPAT<f16, FFMSHQrr, FMULHQrr, SingleReg>;
defm : FFMSPAT<f32, FFMSWrr, FMULWrr, SingleReg>;
defm : FFMSPAT<f64, FFMSDrr, FMULDrr, SingleReg>;
defm : FFMSPAT<v2f32, FFMSWPrr, FMULWPrr, SingleReg>;
defm : FFMSPAT<v2f16, FFMSHQrr, FMULHQrr, SingleReg>;
defm : FFMSPAT<v4f16, FFMSHQrr, FMULHQrr, SingleReg>;
defm : FFMSPAT<v4f32, FFMSWQ, FMULWQ, PairedReg>, Requires<[IsV2]>;

// FFMSWDP
// TODO: Add ri variants
def : Pat<(v4f32 (fma (vfneg v4f32:$rx), v4f32:$ry, v4f32:$rz)),
          (REG_SEQUENCE PairedReg,
            (FFMSWPrr
              (v2f32 (EXTRACT_SUBREG PairedReg:$rz, sub_s0)),
              (v2f32 (EXTRACT_SUBREG PairedReg:$rx, sub_s0)),
              (v2f32 (EXTRACT_SUBREG PairedReg:$ry, sub_s0)),
              rounding_,
              silent_),
            sub_s0,
            (FFMSWPrr
              (v2f32 (EXTRACT_SUBREG PairedReg:$rz, sub_s1)),
              (v2f32 (EXTRACT_SUBREG PairedReg:$rx, sub_s1)),
              (v2f32 (EXTRACT_SUBREG PairedReg:$ry, sub_s1)),
              rounding_,
              silent_),
            sub_s1)>;


multiclass FFMS_EXPAND_PAT<ValueType vt, ValueType small_vt, KVX_INSTRUCTION FMS, KVXRegister OutRegType> {
  def : Pat<(vt (fma (fneg  (vt (fpextend small_vt:$r1))), (vt (fpextend small_vt:$r2)), vt:$r0)),
            (FMS OutRegType:$r0, SingleReg:$r1, SingleReg:$r2, rounding_, silent_)>;

  def : Pat<(vt (fma (vt (fpextend (fneg small_vt:$r1))), (vt (fpextend small_vt:$r2)), vt:$r0)),
            (FMS OutRegType:$r0, SingleReg:$r1, SingleReg:$r2, rounding_, silent_)>;

  def : Pat <(vt (fsubcont vt:$r0, (fmulcont (vt (fpextend small_vt:$r1)), (vt (fpextend small_vt:$r2))))),
             (FMS OutRegType:$r0, SingleReg:$r1, SingleReg:$r2, rounding_, silent_)>;
}
// FFMSHW
// TODO: ri variants
defm : FFMS_EXPAND_PAT<f32, f16, FFMSHWrr, SingleReg>;

// FFMSHWQ
// TODO: ri variants
defm : FFMS_EXPAND_PAT<v4f32, v4f16, FFMSHWQrr, PairedReg>;

// FFMSWDP
defm : FFMS_EXPAND_PAT<v2f64, v2f32, FFMSWDPrr, PairedReg>;

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
def : Pat<(f16(fmul f16:$r, Binary16:$IMM)), (f16 (FMULHQri (f16(ZXHD SingleReg:$r)), (get_fpimm_16 fpimm:$IMM)))>, Requires<[IsV1]>;
def : Pat<(f16(fmul f16:$r, Binary16:$IMM)), (f16 (FMULHQrr (f16(ZXHD SingleReg:$r)), (MAKEi16 (get_fpimm_16 fpimm:$IMM)), rounding_, silent_))>;
def : Pat<(fmul f32:$rs1, Binary32:$rs2), (FMULWri SingleReg:$rs1, Binary32:$rs2)>, Requires<[IsV1]>;
def : Pat<(fmul f64:$rs1, Binary64:$rs2), (FMULDri SingleReg:$rs1, Binary64:$rs2)>, Requires<[IsV1]>;
def : Pat<(fmul f16:$rs1, f16:$rs2), (FMULHQrr (ZXHD SingleReg:$rs1), (ZXHD SingleReg:$rs2), rounding_, silent_)>;
def : Pat<(fmul f32:$rs1, f32:$rs2), (FMULWrr SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fmul f64:$rs1, f64:$rs2), (FMULDrr SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(v2f64 (fmul v2f64:$rx, v2f64:$ry)),
          (v2f64 (REG_SEQUENCE PairedReg,
                  (f64 (FMULDrr
                       (f64 (EXTRACT_SUBREG PairedReg:$rx, sub_s0)),
                       (f64 (EXTRACT_SUBREG PairedReg:$ry, sub_s0)),
                       rounding_, silent_)),
                  sub_s0,
                  (f64 (FMULDrr
                       (f64 (EXTRACT_SUBREG PairedReg:$rx, sub_s1)),
                       (f64 (EXTRACT_SUBREG PairedReg:$ry, sub_s1)),
                       rounding_, silent_)),
                  sub_s1))>;
def : Pat<(v2f16(fmul v2f16:$r, (v2f16 (is_imm_vec:$IMM)))), (v2f16 (FMULHQri (ZXWD SingleReg:$r), (build_imm_vec $IMM)))>, Requires<[IsV1]>;
def : Pat<(v2f16(fmul v2f16:$r, (v2f16 (is_imm_vec:$IMM)))), (v2f16 (FMULHQrr (ZXWD SingleReg:$r), (MAKEi43 (build_imm_vec $IMM)), rounding_, silent_))>;
def : Pat<(fmul v2f16:$rs1, v2f16:$rs2), (FMULHQrr (ZXWD SingleReg:$rs1), (ZXWD SingleReg:$rs2), rounding_, silent_)>;
def : Pat<(v4f16(fmul v4f16:$r, (v4f16 (is_imm_vec:$IMM)))), (v4f16 (FMULHQri SingleReg:$r, (build_imm_vec $IMM)))>, Requires<[IsV1]>;
def : Pat<(fmul v4f16:$rs1, v4f16:$rs2), (FMULHQrr SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(v2f32(fmul v2f32:$r, (v2f32 (is_imm_vec:$IMM)))), (v2f32 (FMULWPri SingleReg:$r, (build_imm_vec $IMM)))>, Requires<[IsV1]>;
def : Pat<(fmul v2f32:$rs1, v2f32:$rs2), (FMULWPrr SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fmul v4f32:$rs1, v4f32:$rs2), (FMULWQ PairedReg:$rs1, PairedReg:$rs2, rounding_, silent_)>;

// FMULHW TODO: Add ri variant
def : Pat<(fmul (f32 (fpextend f16:$rs1)), (f32 (fpextend f16:$rs2))),
          (FMULHWrr SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;

// FMULHWQ TODO: Add ri variants
def : Pat<(fmul (v4f32 (fpextend v4f16:$rs1)), (v4f32 (fpextend v4f16:$rs2))),
          (FMULHWQrr SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;

// FMULWC
def : Pat<(v2f32 (build_vector
          (fma
            (extractelt v2f32:$t2, 0),
            fpimm:$t5,
            (fneg (fmulcont (extractelt v2f32:$t2, 1), fpimm:$t9))),
          (fma:$FMA
            (extractelt v2f32:$t2, 1),
            fpimm:$t5,
            (fmulcont (extractelt v2f32:$t2, 0), fpimm:$t9)))),
          (FMULWCri SingleReg:$t2, (build_fdot_imm $FMA), conjugate_)>, Requires<[IsV1]>;

def : Pat<(v2f32 (build_vector
          (fma
            (extractelt v2f32:$t2, 0),
            fpimm:$t5,
            (fneg (fmulcont (extractelt v2f32:$t2, 1), fpimm:$t9))),
          (fma:$FMA
            (extractelt v2f32:$t2, 1),
            fpimm:$t5,
            (fmulcont (extractelt v2f32:$t2, 0), fpimm:$t9)))),
          (FMULWCrr SingleReg:$t2, (MAKEi64 (build_fdot_imm $FMA)), conjugate_, rounding_, silent_)>;

def : Pat<(v2f32 (build_vector
          (fma:$FMA
            (extractelt v2f32:$t2, 1),
            fpimm:$t5,
            (fmulcont (extractelt v2f32:$t2, 0), fpimm:$t9)),
          (fma
            (extractelt v2f32:$t2, 0),
            fpimm:$t5,
            (fneg (fmulcont (extractelt v2f32:$t2, 1), fpimm:$t9))))),
          (FMULWCri SingleReg:$t2, (build_fdot_imm_swp $FMA), conjugate_c)>, Requires<[IsV1]>;

def : Pat<(v2f32 (build_vector
          (fma:$FMA
            (extractelt v2f32:$t2, 1),
            fpimm:$t5,
            (fmulcont (extractelt v2f32:$t2, 0), fpimm:$t9)),
          (fma
            (extractelt v2f32:$t2, 0),
            fpimm:$t5,
            (fneg (fmulcont (extractelt v2f32:$t2, 1), fpimm:$t9))))),
          (FMULWCrr SingleReg:$t2, (MAKEi64 (build_fdot_imm_swp $FMA)), conjugate_, rounding_, silent_)>;

def : Pat<(v2f32 (build_vector
          (fma:$FMA
            (extractelt v2f32:$t2, 1),
            fpimm:$t5,
            (fmulcont (extractelt v2f32:$t2, 0), fpimm:$t9)),
          (fma
            (extractelt v2f32:$t2, 1),
            fpimm:$t9,
            (fneg (fmulcont (extractelt v2f32:$t2, 0), fpimm:$t5))))),
          (FMULWCri SingleReg:$t2, (build_fdot_imm_swp_neg0 $FMA), conjugate_)>, Requires<[IsV1]>;

def : Pat<(v2f32 (build_vector
          (fma:$FMA
            (extractelt v2f32:$t2, 1),
            fpimm:$t5,
            (fmulcont (extractelt v2f32:$t2, 0), fpimm:$t9)),
          (fma
            (extractelt v2f32:$t2, 1),
            fpimm:$t9,
            (fneg (fmulcont (extractelt v2f32:$t2, 0), fpimm:$t5))))),
          (FMULWCrr SingleReg:$t2, (MAKEi64 (build_fdot_imm_swp_neg0 $FMA)), conjugate_, rounding_, silent_)>;

def : Pat<(v2f32 (build_vector
          (fma:$FMA
            (extractelt v2f32:$t2, 0),
            fpimm:$t5,
            (fmulcont (extractelt v2f32:$t2, 1), fpimm:$t9)),
          (fma
            (extractelt v2f32:$t2, 1),
            fpimm:$t5,
            (fneg (fmulcont (extractelt v2f32:$t2, 0), fpimm:$t9))))),
          (FMULWCri SingleReg:$t2, (build_fdot_imm_neg1 $FMA), conjugate_)>, Requires<[IsV1]>;

def : Pat<(v2f32 (build_vector
          (fma:$FMA
            (extractelt v2f32:$t2, 0),
            fpimm:$t5,
            (fmulcont (extractelt v2f32:$t2, 1), fpimm:$t9)),
          (fma
            (extractelt v2f32:$t2, 1),
            fpimm:$t5,
            (fneg (fmulcont (extractelt v2f32:$t2, 0), fpimm:$t9))))),
          (FMULWCrr SingleReg:$t2, (MAKEi64 (build_fdot_imm_neg1 $FMA)), conjugate_, rounding_, silent_)>;

def : Pat<(v2f32 (build_vector
          (fma
            (extractelt v2f32:$t4, 0),
            (extractelt v2f32:$t2, 0),
            (fneg (fmulcont (extractelt v2f32:$t4, 1), (extractelt v2f32:$t2, 1)))),
          (fma
            (extractelt v2f32:$t4, 0),
            (extractelt v2f32:$t2, 1),
            (fmulcont (extractelt v2f32:$t4, 1), (extractelt v2f32:$t2, 0))))),
          (FMULWCrr SingleReg:$t4, SingleReg:$t2, conjugate_, rounding_, silent_)>;

def : Pat<(v2f32 (build_vector
          (fma
            (extractelt v2f32:$t4, 0),
            (extractelt v2f32:$t2, 0),
          (fmulcont (extractelt v2f32:$t4, 1), (extractelt v2f32:$t2, 1))),
          (fma
            (extractelt v2f32:$t4, 0),
            (extractelt v2f32:$t2, 1),
            (fneg (fmulcont (extractelt v2f32:$t4, 1), (extractelt v2f32:$t2, 0)))))),
          (FMULWCrr SingleReg:$t2, SingleReg:$t4, conjugate_c, rounding_, silent_)>;

def : Pat<(v2f32 (build_vector
          (fma
            (fneg (extractelt v2f32:$t4, 1)),
            (extractelt v2f32:$t2, 1),
            (fma (extractelt v2f32:$t4, 0), (extractelt v2f32:$t2, 0), (extractelt v2f32:$t6, 0))),
          (fma
            (extractelt v2f32:$t4, 1),
            (extractelt v2f32:$t2, 0),
            (fma (extractelt v2f32:$t4, 0), (extractelt v2f32:$t2, 1), (extractelt v2f32:$t6, 1))))),
          (FADDWPrr (FMULWCrr SingleReg:$t4, SingleReg:$t2, conjugate_, rounding_, silent_), SingleReg:$t6, conjugate_, rounding_, silent_)>;

def : Pat<(v2f32 (build_vector
          (fma
            (fneg (extractelt v2f32:$t4, 1)),
            (extractelt v2f32:$t2, 1),
            (fma (extractelt v2f32:$t4, 0), (extractelt v2f32:$t2, 0), (extractelt v2f32:$t6, 0))),
          (fma
            (extractelt v2f32:$t4, 0),
            (extractelt v2f32:$t2, 1),
            (fma (extractelt v2f32:$t4, 1), (extractelt v2f32:$t2, 0), (extractelt v2f32:$t6, 1))))),
          (FADDWPrr (FMULWCrr SingleReg:$t4, SingleReg:$t2, conjugate_, rounding_, silent_), SingleReg:$t6, conjugate_, rounding_, silent_)>;

def : Pat<(v2f32
            (fadd
              (build_vector
                (f32 (fma
                  (extractelt v2f32:$t2, 0),
                  (extractelt v2f32:$t4, 0),
                  (fmul
                    (extractelt v2f32:$t4, 1),
                    (fneg (extractelt v2f32:$t2, 1))
                  )
              )),
              (f32 (fma
                  (extractelt v2f32:$t2, 0),
                  (extractelt v2f32:$t4, 1),
                  (fmul
                    (extractelt v2f32:$t2, 1),
                    (extractelt v2f32:$t4, 0)
                  )
              ))),
              v2f32:$t6)),
          (FADDWPrr (FMULWCrr SingleReg:$t4, SingleReg:$t2, conjugate_, rounding_, silent_), SingleReg:$t6, conjugate_, rounding_, silent_)>;
// FMULWDC
// Match the imaginary part from a v2f32 x v2f32 -> v2f64 pattern
def : Pat<(f64
            (fma
              (extractelt (v2f64 (fpextend v2f32:$t4)), 1),
              (extractelt (v2f64 (fpextend v2f32:$t2)), 0),
              (fmul
                (extractelt (v2f64 (fpextend v2f32:$t4)), 0),
                (extractelt (v2f64 (fpextend v2f32:$t2)), 1)
              ))),
          (f64(EXTRACT_SUBREG (FMULWDCrr SingleReg:$t2, SingleReg:$t4, rounding_, silent_), sub_s1))>;
// Match the real part from a v2f32 x v2f32 -> v2f64 pattern
def : Pat<(f64
            (fma
              (extractelt (v2f64 (fpextend v2f32:$t4)), 0),
              (extractelt (v2f64 (fpextend v2f32:$t2)), 0),
              (fneg (fmul
                (extractelt (v2f64 (fpextend v2f32:$t4)), 1),
                (extractelt (v2f64 (fpextend v2f32:$t2)), 1)
              )))),
          (f64(EXTRACT_SUBREG (FMULWDCrr SingleReg:$t2, SingleReg:$t4, rounding_, silent_), sub_s0))>;

// Match the imaginary part using C complex code
def : Pat<(f64
            (fma
              (f64 (fpextend (f32 (bitconvert (i32 (trunc (i64 (srl i64:$t4, (i64 32))))))))),
              (f64 (fpextend (f32 (bitconvert (i32 (trunc i64:$t2)))))),
              (f64 (fmul
                (f64 (fpextend (f32 (bitconvert (i32 (trunc (i64 (srl i64:$t2, (i64 32))))))))),
                (f64 (fpextend (f32 (bitconvert (i32 (trunc i64:$t4))))))
          )))),
          (f64(EXTRACT_SUBREG (FMULWDCrr SingleReg:$t2, SingleReg:$t4, rounding_, silent_), sub_s1))>;

// Match the real part a C complex code
def : Pat<(f64
            (fma
              (f64 (fpextend (f32 (bitconvert (i32 (trunc i64:$t4)))))),
              (f64 (fpextend (f32 (bitconvert (i32 (trunc i64:$t2)))))),
              (f64 (fneg (fmul
                (f64 (fpextend (f32 (bitconvert (i32 (trunc (i64 (srl i64:$t4, (i64 32))))))))),
                (f64 (fpextend (f32 (bitconvert (i32 (trunc (i64 (srl i64:$t2, (i64 32)))))))))
          ))))),
          (f64(EXTRACT_SUBREG (FMULWDCrr SingleReg:$t2, SingleReg:$t4, rounding_, silent_), sub_s0))>;
// FMULWDP TODO: Add ri variants
def : Pat<(fmul (v2f64 (fpextend v2f32:$rs1)), (v2f64 (fpextend v2f32:$rs2))),
          (FMULWDPrr SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;

// FNARROW
def : Pat<(f16 (fpround f32:$val)), (FNARROWWH SingleReg:$val, rounding_, silent_)>;
def : Pat<(f16 (fpround f64:$val)), (FNARROWWH (FNARROWDW SingleReg:$val, rounding_, silent_), rounding_, silent_)>;
def : Pat<(f32 (fpround f64:$val)), (FNARROWDW SingleReg:$val, rounding_, silent_)>;
def : Pat<(v2f16 (fpround v2f32:$val)), (FNARROWWHQ (INSERT_SUBREG
                                                      (INSERT_SUBREG (v4f32 (IMPLICIT_DEF)), SingleReg:$val, sub_s0),
                                                      (MAKEi16 0), sub_s1), rounding_, silent_)>;
def : Pat<(v2f16 (fpround v2f64:$val)), (v2f16 (FNARROWWHQ (v4f32 (REG_SEQUENCE PairedReg,
                                          (v2f32 (FNARROWDWP PairedReg:$val, rounding_, silent_)), sub_s0,
                                          (v2f32 (MAKEi16 0)), sub_s1) ),
                                          rounding_, silent_))>;

def : Pat<(v2f32 (fpround v2f64:$val)), (FNARROWDWP PairedReg:$val, rounding_, silent_)>;

def : Pat<(v4f16 (fpround v4f32:$val)), (FNARROWWHQ PairedReg:$val, rounding_, silent_)>;

def : Pat<(v4f16 (fpround v4f64:$val)), (FNARROWWHQ (REG_SEQUENCE PairedReg,
                                          (FNARROWDWP (v2f64 (EXTRACT_SUBREG QuadReg:$val, sub_p0)), rounding_, silent_), sub_s0,
                                          (FNARROWDWP (v2f64 (EXTRACT_SUBREG QuadReg:$val, sub_p1)), rounding_, silent_), sub_s1),
                                          rounding_, silent_)>;

// FMAX
def : Pat<(f16 (fmaxnum f16:$v0, f16:$v1)), (FMAXHQ $v0, $v1)>;
def : Pat<(v2f16 (fmaxnum v2f16:$v0, v2f16:$v1)), (FMAXHQ $v0, $v1)>;

// FMIN
def : Pat<(f16 (fminnum f16:$v0, f16:$v1)), (FMINHQ $v0, $v1)>;
def : Pat<(v2f16 (fminnum v2f16:$v0, v2f16:$v1)), (FMINHQ $v0, $v1)>;

// FNEG
def : Pat<(vfneg f16:$rs), (FNEGHQ SingleReg:$rs)>;
def : Pat<(vfneg v2f16:$rs), (FNEGHQ SingleReg:$rs)>;
def : Pat<(vfneg v2f16:$rs), (FNEGHQ SingleReg:$rs)>;
def : Pat<(vfneg v4f16:$rs), (FNEGHQ SingleReg:$rs)>;
def : Pat<(vfneg v2f32:$rs), (FNEGWP SingleReg:$rs)>;
def : Pat<(vfneg v4f32:$rs),
          (v4f32 (REG_SEQUENCE PairedReg,
            (v2f32(FNEGWP (v2f32 (EXTRACT_SUBREG PairedReg:$rs, sub_s0)))), sub_s0,
            (v2f32(FNEGWP (v2f32 (EXTRACT_SUBREG PairedReg:$rs, sub_s1)))), sub_s1))>;

def : Pat<(vfneg v2f64:$rs),
          (v2f64 (REG_SEQUENCE PairedReg,
            (f64 (FNEGD (f64 (EXTRACT_SUBREG PairedReg:$rs, sub_s0)))), sub_s0,
            (f64 (FNEGD (f64 (EXTRACT_SUBREG PairedReg:$rs, sub_s1)))), sub_s1))>;

def : Pat<(vfneg v4f64:$rs),
          (v4f64 (REG_SEQUENCE QuadReg,
            (f64 (FNEGD (f64 (EXTRACT_SUBREG QuadReg:$rs, sub_s0)))), sub_s0,
            (f64 (FNEGD (f64 (EXTRACT_SUBREG QuadReg:$rs, sub_s1)))), sub_s1,
            (f64 (XORDri64 (f64 (EXTRACT_SUBREG QuadReg:$rs, sub_s2)), 0x8000000000000000)), sub_s2,
            (f64 (XORDri64 (f64 (EXTRACT_SUBREG QuadReg:$rs, sub_s3)), 0x8000000000000000)), sub_s3))>;

// FSBF
def : Pat<(f16(fsub Binary16:$IMM, f16:$r)), (f16 (FSBFHQri (f16(ZXHD SingleReg:$r)), (get_fpimm_16 fpimm:$IMM)))>, Requires<[IsV1]>;
def : Pat<(f16(fsub Binary16:$IMM, f16:$r)), (f16 (FSBFHQrr (f16(ZXHD SingleReg:$r)), (MAKEi16 (get_fpimm_16 fpimm:$IMM)), rounding_, silent_))>, Requires<[IsV1]>;
def : Pat<(fsub Binary32:$rs1, f32:$rs2), (FSBFWri SingleReg:$rs2, Binary32:$rs1)>, Requires<[IsV1]>;
def : Pat<(fsub Binary64:$rs1, f64:$rs2), (FSBFDri SingleReg:$rs2, Binary64:$rs1)>, Requires<[IsV1]>;
def : Pat<(fsub f16:$rs1, f16:$rs2), (FSBFHQrr (ZXHD SingleReg:$rs2), (ZXHD SingleReg:$rs1), rounding_, silent_)>;
def : Pat<(fsub f32:$rs1, f32:$rs2), (FSBFWrr SingleReg:$rs2, SingleReg:$rs1, rounding_, silent_)>;
def : Pat<(fsub f64:$rs1, f64:$rs2), (FSBFDrr SingleReg:$rs2, SingleReg:$rs1, rounding_, silent_)>;
def : Pat<(v2f16(fsub (v2f16 (is_imm_vec:$IMM)), v2f16:$r)), (FSBFHQri (ZXWD SingleReg:$r), (build_imm_vec fpimm:$IMM))>, Requires<[IsV1]>;
def : Pat<(v2f16(fsub (v2f16 (is_imm_vec:$IMM)), v2f16:$r)), (FSBFHQrr (ZXWD SingleReg:$r), (MAKEi43 (build_imm_vec fpimm:$IMM)), rounding_, silent_)>;
def : Pat<(fsub v2f16:$rs1, v2f16:$rs2), (FSBFHQrr (ZXWD SingleReg:$rs2), (ZXWD SingleReg:$rs1), rounding_, silent_)>;
def : Pat<(v4f16(fsub (v4f16 (is_imm_vec:$IMM)), v4f16:$r)), (FSBFHQri SingleReg:$r, (build_imm_vec fpimm:$IMM))>, Requires<[IsV1]>;
def : Pat<(fsub v4f16:$rs1, v4f16:$rs2), (FSBFHQrr SingleReg:$rs2, SingleReg:$rs1, rounding_, silent_)>;
def : Pat<(v2f32(fsub (v2f32 (is_imm_vec:$IMM)), v2f32:$r)), (FSBFWPri SingleReg:$r, (build_imm_vec fpimm:$IMM), conjugate_)>, Requires<[IsV1]>;
def : Pat<(fsub v2f32:$rs1, v2f32:$rs2), (FSBFWPrr SingleReg:$rs2, SingleReg:$rs1, conjugate_, rounding_, silent_)>;
def : Pat<(fsub v4f32:$rs1, v4f32:$rs2), (FSBFWQ PairedReg:$rs2, PairedReg:$rs1, conjugate_, rounding_, silent_)>;
def : Pat<(fsub v2f64:$rs1, v2f64:$rs2), (FSBFDP PairedReg:$rs2, PairedReg:$rs1, conjugate_, rounding_, silent_)>;
def : Pat<(v4f64 (fsub v4f64:$rs1, v4f64:$rs2)),
          (v4f64(REG_SEQUENCE QuadReg,
            (v2f64(FSBFDP
              (v2f64 (EXTRACT_SUBREG QuadReg:$rs2, sub_p0)),
              (v2f64 (EXTRACT_SUBREG QuadReg:$rs1, sub_p0)),
              conjugate_,
              rounding_,
              silent_)),
            sub_p0,
            (v2f64(FSBFDP
              (v2f64 (EXTRACT_SUBREG QuadReg:$rs2, sub_p1)),
              (v2f64 (EXTRACT_SUBREG QuadReg:$rs1, sub_p1)),
              conjugate_,
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

foreach vt = [v2f16, v4f16] in
  def : Pat<(f32 (fpextend (f16 (vector_extract vt:$v, 1)))), (FWIDENMHW SingleReg:$v, silent_)>;

def : Pat<(v2f64 (fpextend v2f16:$val)),
          (v2f64 (REG_SEQUENCE PairedReg,
                  (FWIDENLWD (FWIDENLHWP SingleReg:$val, silent_), silent_), sub_s0,
                  (FWIDENMWD (FWIDENLHWP SingleReg:$val, silent_), silent_), sub_s1))>;

def : Pat<(v2f64 (fpextend v2f32:$val)),
          (v2f64 (REG_SEQUENCE PairedReg,
                  (FWIDENLWD SingleReg:$val, silent_), sub_s0,
                  (FWIDENMWD SingleReg:$val, silent_), sub_s1))>;

def : Pat<(v4f64 (fpextend v4f16:$val)), (REG_SEQUENCE QuadReg,
                                           (FWIDENLWD (FWIDENLHWP SingleReg:$val, silent_), silent_), sub_s0,
                                           (FWIDENMWD (FWIDENLHWP SingleReg:$val, silent_), silent_), sub_s1,
                                           (FWIDENLWD (FWIDENMHWP SingleReg:$val, silent_), silent_), sub_s2,
                                           (FWIDENMWD (FWIDENMHWP SingleReg:$val, silent_), silent_), sub_s3)>;

def : Pat<(v4f64 (fpextend v4f32:$val)), (REG_SEQUENCE QuadReg,
                                           (FWIDENLWD (v2f32 (EXTRACT_SUBREG PairedReg:$val, sub_s0)), silent_), sub_s0,
                                           (FWIDENMWD (v2f32 (EXTRACT_SUBREG PairedReg:$val, sub_s0)), silent_), sub_s1,
                                           (FWIDENLWD (v2f32 (EXTRACT_SUBREG PairedReg:$val, sub_s1)), silent_), sub_s2,
                                           (FWIDENMWD (v2f32 (EXTRACT_SUBREG PairedReg:$val, sub_s1)), silent_), sub_s3)>;

// build_vector and vector_extract
// v2f16
def : Pat<(v2f16 (is_imm_vec:$IMM)), (MAKEi43 (build_imm_vec $IMM))>;
def : Pat<(v2f16 (build_vector (f16(vector_extract v2f16:$v, 0)), (f16(vector_extract v2f16:$v, 0)))),
          (INSF SingleReg:$v, SingleReg:$v, 31, 16)>;
def : Pat<(v2f16 (build_vector (f16(vector_extract v2f16:$v0, 0)), (f16(vector_extract v2f16:$v1, 0)))),
          (INSF SingleReg:$v0, SingleReg:$v1, 31, 16)>;
def : Pat<(v2f16 (build_vector (f16(vector_extract v2f16:$v, 1)), (f16(vector_extract v2f16:$v, 0)))),
          (SBMM8ri64 SingleReg:$v, 0x02010804)>;
def : Pat<(v2f16 (build_vector (f16(vector_extract v2f16:$v, 1)), (f16(vector_extract v2f16:$v, 1)))),
          (SBMM8ri64 SingleReg:$v, 0x08040804)>;
def : Pat<(v2f16 (build_vector f16:$v0, f16:$v1)), (INSF SingleReg:$v0, SingleReg:$v1, 31, 16)>;
def : Pat<(f16 (vector_extract v2f16:$v, i64:$p)), (SRLWrr SingleReg:$v, (SLLWri SingleReg:$p, 4))>;

// v2f32
def : Pat<(v2i32 (is_imm_vec_kvx_splat32_:$IMM)), (MAKEi43 (build_imm_vec $IMM))>;
def : Pat<(v2f32 (is_imm_vec:$IMM)), (MAKEi64 (build_imm_vec $IMM))>;
def : Pat<(v2f32 (build_vector f32:$v0, f32:$v1)), (INSF SingleReg:$v0, SingleReg:$v1, 63, 32)>;
def : Pat<(v2f32 (build_vector (f32(vector_extract v2f32:$v, 1)), (f32(vector_extract v2f32:$v, 0)))),
          (SBMM8ri64 SingleReg:$v, 0x0804020180402010)>;
def : Pat<(v2f32 (build_vector (f32(vector_extract v2f32:$v, 1)), (f32(vector_extract v2f32:$v, 1)))),
          (SBMM8ri64 SingleReg:$v, 0x8040201080402010)>;
def : Pat<(v2f32 (build_vector (f32(vector_extract v2f32:$v0, 1)), (f32(vector_extract v2f32:$v1, 0)))),
          (SBMM8ri64 (INSF SingleReg:$v0, SingleReg:$v1, 31, 0), 0x0804020180402010)>;
def : Pat<(f32 (vector_extract v2f32:$v, i64:$p)), (SRLDrr SingleReg:$v, (SLLWri SingleReg:$p, 5))>;

// v4f16
def : Pat<(v4f16 (is_imm_vec:$IMM)), (MAKEi64 (build_imm_vec $IMM))>;
def : Pat<(v4f16 (build_vector f16:$v0, f16:$v1, f16:$v2, f16:$v3)),
          (INSF (INSF SingleReg:$v0, SingleReg:$v1, 31, 16), (INSF SingleReg:$v2, SingleReg:$v3, 31, 16), 63, 32)>;
def : Pat<(f16 (vector_extract v4f16:$v, i64:$p)), (SRLDrr SingleReg:$v, (SLLWri SingleReg:$p, 4))>;

def : Pat<(v4f16 (concat_vectors v2f16:$v0, v2f16:$v1)),
          (v4f16 (INSF SingleReg:$v0, SingleReg:$v1, 63, 32))>;

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
def : Pat<(extractelt (v4f32 PairedReg:$v), 1), (SRLDri (f32 (EXTRACT_SUBREG $v, sub_s0)), (i64 32))>;
def : Pat<(extractelt (v4f32 PairedReg:$v), 2), (f32 (EXTRACT_SUBREG $v, sub_s1))>;
def : Pat<(extractelt (v4f32 PairedReg:$v), 3), (SRLDri (f32 (EXTRACT_SUBREG $v, sub_s1)), (i64 32))>;

def : Pat<(f32(extractelt v4f32:$v, i64:$s)),
          (f32
            (SRLDrr
              (v2f32
                (CMOVEDrr
                  (i32 (SRLWri (i64 SingleReg:$s), 1)),
                  (v2f32 (EXTRACT_SUBREG (v4f32 PairedReg:$v), sub_s0)),
                  (v2f32 (EXTRACT_SUBREG (v4f32 PairedReg:$v), sub_s1)),
                  scalarcond_odd
                )
              ),
              (i32 (SLLWri ( i32 (ANDWri10 (i64 SingleReg:$s), 1)), 5))
            )
          )>;


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

def : Pat<(fcopysign v2f16:$v1, v2f16:$v2),
          (ORWrr (ANDWri37 SingleReg:$v1, 0x7FFF7FFF), (ANDWri37 SingleReg:$v2, 0x80008000))>;

def : Pat<(fcopysign v2f16:$v1, v2f32:$v2),
          (ORWrr (ANDWri37 SingleReg:$v1, 0x7FFF7FFF), (ANDWri37 (SBMM8ri37 SingleReg:$v2, 0x80000800), 0x80008000))>;

def : Pat<(fcopysign v2f16:$v1, v2f64:$v2),
          (INSF
            (INSF SingleReg:$v1,
              (SRLDri (i64 (EXTRACT_SUBREG PairedReg:$v2, sub_s0)), 63),
              15, 15
            ),
            (SRLDri (i64 (EXTRACT_SUBREG PairedReg:$v2, sub_s1)), 63),
            31, 31
          )>;

def : Pat<(fcopysign v4f16:$v1, v4f16:$v2),
          (ORDrr (FABSHQ SingleReg:$v1), (ANDDri64 SingleReg:$v2, 0x8000800080008000))>;

def : Pat<(fcopysign v2f32:$v1, v2f16:$v2),
          (ORDrr (FABSWP SingleReg:$v1), (SBMM8ri64 (ANDWri37 SingleReg:$v2, 0x80008000), 0x800000002000000))>;

def : Pat<(fcopysign v2f32:$v1, v2f32:$v2),
          (ORDrr (FABSWP SingleReg:$v1), (ANDDri64 SingleReg:$v2, 0x8000000080000000))>;

def : Pat<(fcopysign v2f32:$v1, v2f64:$v2),
          (INSF
            (INSF SingleReg:$v1,
              (SRLDri (i64 (EXTRACT_SUBREG PairedReg:$v2, sub_s0)), 63),
              31, 31
            ),
            (SRLDri (i64 (EXTRACT_SUBREG PairedReg:$v2, sub_s1)), 63),
            63, 63
          )>;

def : Pat<(fcopysign v4f16:$v1, v4f32:$v2),
          (ORDrr
            (FABSHQ SingleReg:$v1),
            (ANDDri64
              (FNARROWWHQ PairedReg:$v2, rounding_rna, silent_s),
            0x8000800080008000))>;

def : Pat<(fcopysign v4f16:$v1, v4f64:$v2),
          (INSF
            (INSF
              (INSF
                (INSF
                  v4f16:$v1,
                  (SRLDri (i64 (EXTRACT_SUBREG QuadReg:$v2, sub_s0)), 63), 15, 15
                ),
                (SRLDri (i64 (EXTRACT_SUBREG QuadReg:$v2, sub_s1)), 63), 31, 31
              ),
              (SRLDri (i64 (EXTRACT_SUBREG QuadReg:$v2, sub_s2)), 63), 47, 47
            ),
            (SRLDri (i64 (EXTRACT_SUBREG QuadReg:$v2, sub_s0)), 63), 63, 63)>;

def : Pat<(fcopysign v4f32:$v1, v4f16:$v2),
          (REG_SEQUENCE PairedReg,
            (ORDrr
              (FABSWP (v2f32 (EXTRACT_SUBREG PairedReg:$v1, sub_s0))),
              (SBMM8ri64 (ANDDri64 SingleReg:$v2, 0x8000800080008000), 0x800000002000000)
            ),
            sub_s0,
            (ORDrr
              (FABSWP (v2f32 (EXTRACT_SUBREG PairedReg:$v1, sub_s1))),
              (SBMM8ri64 (ANDDri64 SingleReg:$v2, 0x8000800080008000), 0x8000000020000000)
            ),
            sub_s1)>;

def : Pat<(fcopysign v4f32:$v1, v4f32:$v2),
          (REG_SEQUENCE PairedReg,
            (ORDrr
              (FABSWP (v2f32 (EXTRACT_SUBREG PairedReg:$v1, sub_s0))),
              (ANDDri64
                (v2f32 (EXTRACT_SUBREG PairedReg:$v2, sub_s0)),
                0x8000000080000000
              )),
              sub_s0,
            (ORDrr
              (FABSWP (v2f32 (EXTRACT_SUBREG PairedReg:$v1, sub_s1))),
              (ANDDri64
                (v2f32 (EXTRACT_SUBREG PairedReg:$v2, sub_s1)),
                0x8000000080000000
              )),
              sub_s1)>;

def : Pat<(fcopysign v4f32:$v1, v4f64:$v2),
          (REG_SEQUENCE PairedReg,
          (INSF
            (INSF (v2f32 (EXTRACT_SUBREG PairedReg:$v1, sub_s0)),
              (SRLDri (i64 (EXTRACT_SUBREG QuadReg:$v2, sub_s0)), 63),
              31, 31
            ),
            (SRLDri (i64 (EXTRACT_SUBREG QuadReg:$v2, sub_s1)), 63),
            63, 63
          ),
          sub_s0,
          (INSF
            (INSF (v2f32 (EXTRACT_SUBREG PairedReg:$v1, sub_s1)),
              (SRLDri (i64 (EXTRACT_SUBREG QuadReg:$v2, sub_s2)), 63),
              31, 31
            ),
            (SRLDri (i64 (EXTRACT_SUBREG QuadReg:$v2, sub_s3)), 63),
            63, 63
          ),
          sub_s1)>;

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
