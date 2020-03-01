//===-- K1CFloatingPoint.td --------------------------------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

def DefaultShift : PatLeaf<(i64 0)>;

// Store
def : Pat<(store (f16 SingleReg:$val), AddrRI:$addr), (SHri AddrRI:$addr, SingleReg:$val)>;
def : Pat<(store (f32 SingleReg:$val), AddrRI:$addr), (SWri AddrRI:$addr, SingleReg:$val)>;
def : Pat<(store (f64 SingleReg:$val), AddrRI:$addr), (SDri AddrRI:$addr, SingleReg:$val)>;
def : Pat<(store (v2f32 SingleReg:$val), AddrRI:$addr), (SDri AddrRI:$addr, SingleReg:$val)>;
def : Pat<(store (v4f16 SingleReg:$val), AddrRI:$addr), (SDri AddrRI:$addr, SingleReg:$val)>;
def : Pat<(store (v4f32 PairedReg:$val), AddrRI: $addr), (SQri AddrRI:$addr, PairedReg:$val)>;
def : Pat<(store (v2f64 PairedReg:$val), AddrRI: $addr), (SQri AddrRI:$addr, PairedReg:$val)>;

def truncstoref16 : PatFrag<(ops node:$val, node:$ptr),
                            (truncstore node:$val, node:$ptr)> {
  let IsStore = 1;
  let MemoryVT = f16;
}

def : Pat<(truncstoref32 f64:$val, AddrRI:$addr), (SWri AddrRI:$addr, (FNARROWDW SingleReg:$val, rounding_, silent_))>;

def : Pat<(truncstoref16 f64:$val, AddrRI:$addr), (SHri AddrRI:$addr, (FNARROWWH (FNARROWDW SingleReg:$val, rounding_, silent_), rounding_, silent_))>;
def : Pat<(truncstoref16 f32:$val, AddrRI:$addr), (SHri AddrRI:$addr, (FNARROWWH SingleReg:$val, rounding_, silent_))>;

// Load
def loadf16 : PatFrag<(ops node:$ptr), (f16 (load node:$ptr))>;
def loadf32 : PatFrag<(ops node:$ptr), (f32 (load node:$ptr))>;
def loadf64 : PatFrag<(ops node:$ptr), (f64 (load node:$ptr))>;
def loadv4f16 : PatFrag<(ops node:$ptr), (v4f16 (load node:$ptr))>;
def loadv2f32 : PatFrag<(ops node:$ptr), (v2f32 (load node:$ptr))>;
def loadv4f32 : PatFrag<(ops node:$ptr), (v4f32 (load node:$ptr))>;
def loadv2f64 : PatFrag<(ops node:$ptr), (v2f64 (load node:$ptr))>;

def : Pat<(loadf16 AddrRI:$addr), (LHZri AddrRI:$addr, variant_)>;
def : Pat<(loadf32 AddrRI:$addr), (LWZri AddrRI:$addr, variant_)>;
def : Pat<(loadf64 AddrRI:$addr), (LDri AddrRI:$addr, variant_)>;
def : Pat<(loadv2f32 AddrRI:$addr), (LDri AddrRI:$addr, variant_)>;
def : Pat<(loadv4f16 AddrRI:$addr), (LDri AddrRI:$addr, variant_)>;
def : Pat<(loadv4f32 AddrRI:$addr), (LQri AddrRI:$addr, variant_)>;
def : Pat<(loadv2f64 AddrRI:$addr), (LQri AddrRI:$addr, variant_)>;

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

// 128 bits
def : BITCAST<v2i64, v4f32, PairedReg>;
def : BITCAST<v4f32, v2i64, PairedReg>;
def : BITCAST<v2f64, v2i64, PairedReg>;
def : BITCAST<v2i64, v2f64, PairedReg>;
def : BITCAST<v4f32, v4i32, PairedReg>;
def : BITCAST<v4i32, v4f32, PairedReg>;

// FPU Insns

// FABS, see K1CInstrInfo.td
// FADDC -> TODO
// FADD
def : Pat<(fadd f16:$rs1, Binary16:$rs2), (FADDHQd0 SingleReg:$rs1, Binary16:$rs2)>;
def : Pat<(fadd f32:$rs1, Binary32:$rs2), (FADDWd0 SingleReg:$rs1, Binary32:$rs2)>;
def : Pat<(fadd f64:$rs1, Binary64:$rs2), (FADDDd0 SingleReg:$rs1, Binary64:$rs2)>;
def : Pat<(fadd f16:$rs1, f16:$rs2), (FADDHQd1 SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fadd f32:$rs1, f32:$rs2), (FADDWd1 SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fadd f64:$rs1, f64:$rs2), (FADDDd1 SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fadd v2f16:$rs1, v2f16:$rs2), (FADDHQd1 SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fadd v4f16:$rs1, v4f16:$rs2), (FADDHQd1 SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fadd v2f32:$rs1, v2f32:$rs2), (FADDWPd1 SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fadd v4f32:$rs1, v4f32:$rs2), (FADDWQ PairedReg:$rs1, PairedReg:$rs2, rounding_, silent_)>;
def : Pat<(fadd v2f64:$rs1, v2f64:$rs2), (FADDDP PairedReg:$rs1, PairedReg:$rs2, rounding_, silent_)>;
// FCDIV -> TODO
// FCOMP (TODO: factorize these patterns in ISelLowering pass)
def : Pat<(i32 (setoeq f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_oeq)>;
def : Pat<(i32 (setogt f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$ry, SingleReg:$rz, floatcomp_olt)>;
def : Pat<(i32 (setoge f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_oge)>;
def : Pat<(i32 (setolt f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_olt)>;
def : Pat<(i32 (setole f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$ry, SingleReg:$rz, floatcomp_oge)>;
def : Pat<(i32 (setone f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_one)>;
def : Pat<(i32 (seto f16:$rz, f16:$ry)), (ORDd0 (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_oge), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_olt))>;
def : Pat<(i32 (setuo f16:$rz, f16:$ry)), (ANDDd0 (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_uge), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_ult))>;
def : Pat<(i32 (setueq f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_ueq)>;
def : Pat<(i32 (setugt f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$ry, SingleReg:$rz, floatcomp_ult)>;
def : Pat<(i32 (setuge f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_uge)>;
def : Pat<(i32 (setult f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_ult)>;
def : Pat<(i32 (setule f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$ry, SingleReg:$rz, floatcomp_uge)>;
def : Pat<(i32 (setune f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_une)>;
def : Pat<(i32 (setoeq f32:$rz, Binary32:$imm)), (FCOMPWd1 SingleReg:$rz, Binary32:$imm, floatcomp_oeq)>;
def : Pat<(i32 (setogt Binary32:$imm, f32:$ry)), (FCOMPWd1 SingleReg:$ry, Binary32:$imm, floatcomp_olt)>;
def : Pat<(i32 (setoge f32:$rz, Binary32:$imm)), (FCOMPWd1 SingleReg:$rz, Binary32:$imm, floatcomp_oge)>;
def : Pat<(i32 (setolt f32:$rz, Binary32:$imm)), (FCOMPWd1 SingleReg:$rz, Binary32:$imm, floatcomp_olt)>;
def : Pat<(i32 (setole Binary32:$imm, f32:$ry)), (FCOMPWd1 SingleReg:$ry, Binary32:$imm, floatcomp_oge)>;
def : Pat<(i32 (setone f32:$rz, Binary32:$imm)), (FCOMPWd1 SingleReg:$rz, Binary32:$imm, floatcomp_one)>;
def : Pat<(i32 (seto f32:$rz, Binary32:$imm)), (ORDd0 (FCOMPWd0 SingleReg:$rz, Binary32:$imm, floatcomp_oge), (FCOMPWd0 SingleReg:$rz, Binary32:$imm, floatcomp_olt))>;
def : Pat<(i32 (setuo f32:$rz, Binary32:$imm)), (ANDDd0 (FCOMPWd0 SingleReg:$rz, Binary32:$imm, floatcomp_uge), (FCOMPWd0 SingleReg:$rz, Binary32:$imm, floatcomp_ult))>;
def : Pat<(i32 (setueq f32:$rz, Binary32:$imm)), (FCOMPWd1 SingleReg:$rz, Binary32:$imm, floatcomp_ueq)>;
def : Pat<(i32 (setugt Binary32:$imm, f32:$ry)), (FCOMPWd1 SingleReg:$ry, Binary32:$imm, floatcomp_ult)>;
def : Pat<(i32 (setuge f32:$rz, Binary32:$imm)), (FCOMPWd1 SingleReg:$rz, Binary32:$imm, floatcomp_uge)>;
def : Pat<(i32 (setult f32:$rz, Binary32:$imm)), (FCOMPWd1 SingleReg:$rz, Binary32:$imm, floatcomp_ult)>;
def : Pat<(i32 (setule Binary32:$imm, f32:$ry)), (FCOMPWd1 SingleReg:$ry, Binary32:$imm, floatcomp_uge)>;
def : Pat<(i32 (setune f32:$rz, Binary32:$imm)), (FCOMPWd1 SingleReg:$rz, Binary32:$imm, floatcomp_une)>;
def : Pat<(i32 (setoeq f32:$rz, f32:$ry)), (FCOMPWd0 SingleReg:$rz, SingleReg:$ry, floatcomp_oeq)>;
def : Pat<(i32 (setogt f32:$rz, f32:$ry)), (FCOMPWd0 SingleReg:$ry, SingleReg:$rz, floatcomp_olt)>;
def : Pat<(i32 (setoge f32:$rz, f32:$ry)), (FCOMPWd0 SingleReg:$rz, SingleReg:$ry, floatcomp_oge)>;
def : Pat<(i32 (setolt f32:$rz, f32:$ry)), (FCOMPWd0 SingleReg:$rz, SingleReg:$ry, floatcomp_olt)>;
def : Pat<(i32 (setole f32:$rz, f32:$ry)), (FCOMPWd0 SingleReg:$ry, SingleReg:$rz, floatcomp_oge)>;
def : Pat<(i32 (setone f32:$rz, f32:$ry)), (FCOMPWd0 SingleReg:$rz, SingleReg:$ry, floatcomp_one)>;
def : Pat<(i32 (seto f32:$rz, f32:$ry)), (ORDd0 (FCOMPWd0 SingleReg:$rz, SingleReg:$ry, floatcomp_oge), (FCOMPWd0 SingleReg:$rz, SingleReg:$ry, floatcomp_olt))>;
def : Pat<(i32 (setuo f32:$rz, f32:$ry)), (ANDDd0 (FCOMPWd0 SingleReg:$rz, SingleReg:$ry, floatcomp_uge), (FCOMPWd0 SingleReg:$rz, SingleReg:$ry, floatcomp_ult))>;
def : Pat<(i32 (setueq f32:$rz, f32:$ry)), (FCOMPWd0 SingleReg:$rz, SingleReg:$ry, floatcomp_ueq)>;
def : Pat<(i32 (setugt f32:$rz, f32:$ry)), (FCOMPWd0 SingleReg:$ry, SingleReg:$rz, floatcomp_ult)>;
def : Pat<(i32 (setuge f32:$rz, f32:$ry)), (FCOMPWd0 SingleReg:$rz, SingleReg:$ry, floatcomp_uge)>;
def : Pat<(i32 (setult f32:$rz, f32:$ry)), (FCOMPWd0 SingleReg:$rz, SingleReg:$ry, floatcomp_ult)>;
def : Pat<(i32 (setule f32:$rz, f32:$ry)), (FCOMPWd0 SingleReg:$ry, SingleReg:$rz, floatcomp_uge)>;
def : Pat<(i32 (setune f32:$rz, f32:$ry)), (FCOMPWd0 SingleReg:$rz, SingleReg:$ry, floatcomp_une)>;
def : Pat<(i32 (setoeq f64:$rz, f64:$ry)), (FCOMPD SingleReg:$rz, SingleReg:$ry, floatcomp_oeq)>;
def : Pat<(i32 (setogt f64:$rz, f64:$ry)), (FCOMPD SingleReg:$ry, SingleReg:$rz, floatcomp_olt)>;
def : Pat<(i32 (setoge f64:$rz, f64:$ry)), (FCOMPD SingleReg:$rz, SingleReg:$ry, floatcomp_oge)>;
def : Pat<(i32 (setolt f64:$rz, f64:$ry)), (FCOMPD SingleReg:$rz, SingleReg:$ry, floatcomp_olt)>;
def : Pat<(i32 (setole f64:$rz, f64:$ry)), (FCOMPD SingleReg:$ry, SingleReg:$rz, floatcomp_oge)>;
def : Pat<(i32 (setone f64:$rz, f64:$ry)), (FCOMPD SingleReg:$rz, SingleReg:$ry, floatcomp_one)>;
def : Pat<(i32 (seto f64:$rz, f64:$ry)), (ORDd0 (FCOMPD SingleReg:$rz, SingleReg:$ry, floatcomp_oge), (FCOMPD SingleReg:$rz, SingleReg:$ry, floatcomp_olt))>;
def : Pat<(i32 (setuo f64:$rz, f64:$ry)), (ANDDd0 (FCOMPD SingleReg:$rz, SingleReg:$ry, floatcomp_uge), (FCOMPD SingleReg:$rz, SingleReg:$ry, floatcomp_ult))>;
def : Pat<(i32 (setueq f64:$rz, f64:$ry)), (FCOMPD SingleReg:$rz, SingleReg:$ry, floatcomp_ueq)>;
def : Pat<(i32 (setugt f64:$rz, f64:$ry)), (FCOMPD SingleReg:$ry, SingleReg:$rz, floatcomp_ult)>;
def : Pat<(i32 (setuge f64:$rz, f64:$ry)), (FCOMPD SingleReg:$rz, SingleReg:$ry, floatcomp_uge)>;
def : Pat<(i32 (setult f64:$rz, f64:$ry)), (FCOMPD SingleReg:$rz, SingleReg:$ry, floatcomp_ult)>;
def : Pat<(i32 (setule f64:$rz, f64:$ry)), (FCOMPD SingleReg:$ry, SingleReg:$rz, floatcomp_uge)>;
def : Pat<(i32 (setune f64:$rz, f64:$ry)), (FCOMPD SingleReg:$rz, SingleReg:$ry, floatcomp_une)>;

multiclass COMP_FPat<SDNode Node, Floatcomp Cmp, bit SWAP> {

  def : Pat<(v4i16 (Node v4f16:$rz, v4f16:$ry)),
    !if(SWAP, (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, Cmp), (FCOMPNHQ SingleReg:$ry, SingleReg:$rz, Cmp))>;

  def : Pat<(v2i32 (Node v2f32:$rz, v2f32:$ry)),
    !if(SWAP, (FCOMPNWP SingleReg:$rz, SingleReg:$ry, Cmp), (FCOMPNWP SingleReg:$ry, SingleReg:$rz, Cmp))>;
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

def : Pat<(v4i16 (seto v4f16:$rz, v4f16:$ry)), (ORDd0 (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_oge), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_olt))>;
def : Pat<(v4i16 (setuo v4f16:$rz, v4f16:$ry)), (ANDDd0 (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_uge), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, floatcomp_ult))>;

def : Pat<(v2i32 (seto v2f32:$rz, v2f32:$ry)), (ORDd0 (FCOMPNWP SingleReg:$rz, SingleReg:$ry, floatcomp_oge), (FCOMPNWP SingleReg:$rz, SingleReg:$ry, floatcomp_olt))>;
def : Pat<(v2i32 (setuo v2f32:$rz, v2f32:$ry)), (ANDDd0 (FCOMPNWP SingleReg:$rz, SingleReg:$ry, floatcomp_uge), (FCOMPNWP SingleReg:$rz, SingleReg:$ry, floatcomp_ult))>;

defm : Select32PAT<(f32 f32:$truev), (f32 f32:$falsev),(f32 Binary32:$truev), (f32 Binary32:$falsev)>;
defm : Select32PAT<(f64 f64:$truev), (f64 f64:$falsev),(f64 Binary64:$truev), (f64 Binary64:$falsev)>;

defm : Select64PAT<(f32 f32:$truev), (f32 f32:$falsev),(f32 Binary32:$truev), (f32 Binary32:$falsev)>;
defm : Select64PAT<(f64 f64:$truev), (f64 f64:$falsev),(f64 Binary64:$truev), (f64 Binary64:$falsev)>;

// FDOT2 -> TODO
// FFMA  -> TODO
// FFMS  -> TODO
// FINV  -> TODO
// FISR  -> TODO
// FIXED
def : Pat<(i32 (fp_to_uint f16:$val)), (FIXEDUW (FWIDENLHW SingleReg:$val, silent_), DefaultShift, rounding_, silent_)>;
def : Pat<(i64 (fp_to_uint f16:$val)), (FIXEDUD (FWIDENLWD (FWIDENLHW SingleReg:$val, silent_), silent_), DefaultShift, rounding_, silent_)>;
def : Pat<(i32 (fp_to_uint f32:$val)), (FIXEDUW SingleReg:$val, DefaultShift, rounding_, silent_)>;
def : Pat<(i64 (fp_to_uint f32:$val)), (FIXEDUD (FWIDENLWD SingleReg:$val, silent_), DefaultShift, rounding_, silent_)>;
def : Pat<(i32 (fp_to_uint f64:$val)), (FIXEDUD SingleReg:$val, DefaultShift, rounding_, silent_)>;
def : Pat<(i64 (fp_to_uint f64:$val)), (FIXEDUD SingleReg:$val, DefaultShift, rounding_, silent_)>;
def : Pat<(i32 (fp_to_sint f16:$val)), (FIXEDW (FWIDENLHW SingleReg:$val, silent_), DefaultShift, rounding_, silent_)>;
def : Pat<(i64 (fp_to_sint f16:$val)), (FIXEDD (FWIDENLWD (FWIDENLHW SingleReg:$val, silent_), silent_), DefaultShift, rounding_, silent_)>;
def : Pat<(i32 (fp_to_sint f32:$val)), (FIXEDW SingleReg:$val, DefaultShift, rounding_, silent_)>;
def : Pat<(i64 (fp_to_sint f32:$val)), (FIXEDD (FWIDENLWD SingleReg:$val, silent_), DefaultShift, rounding_, silent_)>;
def : Pat<(i32 (fp_to_sint f64:$val)), (FIXEDD SingleReg:$val, DefaultShift, rounding_, silent_)>;
def : Pat<(i64 (fp_to_sint f64:$val)), (FIXEDD SingleReg:$val, DefaultShift, rounding_, silent_)>;
// FLOAT
def : Pat<(f16 (uint_to_fp i32:$val)), (FNARROWWH (FLOATUW SingleReg:$val, DefaultShift, rounding_, silent_), rounding_, silent_)>;
def : Pat<(f16 (uint_to_fp i64:$val)), (FNARROWWH (FNARROWDW (FLOATUD SingleReg:$val, DefaultShift, rounding_, silent_), rounding_, silent_), rounding_, silent_)>;
def : Pat<(f32 (uint_to_fp i32:$val)), (FLOATUW SingleReg:$val, DefaultShift, rounding_, silent_)>;
def : Pat<(f32 (uint_to_fp i64:$val)), (FLOATUW (SATUDd0 SingleReg:$val, (i32 32)), DefaultShift, rounding_, silent_)>;
def : Pat<(f64 (uint_to_fp i32:$val)), (FLOATUD (ZXWD SingleReg:$val), DefaultShift, rounding_, silent_)>;
def : Pat<(f64 (uint_to_fp i64:$val)), (FLOATUD SingleReg:$val, DefaultShift, rounding_, silent_)>;
def : Pat<(f16 (sint_to_fp i32:$val)), (FNARROWWH (FLOATW SingleReg:$val, DefaultShift, rounding_, silent_), rounding_, silent_)>;
def : Pat<(f16 (sint_to_fp i64:$val)), (FNARROWWH (FNARROWDW (FLOATD SingleReg:$val, DefaultShift, rounding_, silent_), rounding_, silent_), rounding_, silent_)>;
def : Pat<(f32 (sint_to_fp i32:$val)), (FLOATW SingleReg:$val, DefaultShift, rounding_, silent_)>;
def : Pat<(f32 (sint_to_fp i64:$val)), (FLOATW (SATDd0 SingleReg:$val, (i32 32)), DefaultShift, rounding_, silent_)>;
def : Pat<(f64 (sint_to_fp i32:$val)), (FLOATD (SXWD SingleReg:$val), DefaultShift, rounding_, silent_)>;
def : Pat<(f64 (sint_to_fp i64:$val)), (FLOATD SingleReg:$val, DefaultShift, rounding_, silent_)>;
// FMAX  -> TODO
// FMIN  -> TODO
// FMM2A -> TODO
// FMM2S -> TODO
// FMM2  -> TODO
// FMULC -> TODO
// FMUL
def : Pat<(fmul f16:$rs1, Binary16:$rs2), (FMULHQd0 SingleReg:$rs1, Binary16:$rs2)>;
def : Pat<(fmul f32:$rs1, Binary32:$rs2), (FMULWd0 SingleReg:$rs1, Binary32:$rs2)>;
def : Pat<(fmul f64:$rs1, Binary64:$rs2), (FMULDd0 SingleReg:$rs1, Binary64:$rs2)>;
def : Pat<(fmul f16:$rs1, f16:$rs2), (FMULHQd1 SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fmul f32:$rs1, f32:$rs2), (FMULWd1 SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fmul f64:$rs1, f64:$rs2), (FMULDd1 SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fmul v2f16:$rs1, v2f16:$rs2), (FMULHQd1 SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fmul v4f16:$rs1, v4f16:$rs2), (FMULHQd1 SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fmul v2f32:$rs1, v2f32:$rs2), (FMULWPd1 SingleReg:$rs1, SingleReg:$rs2, rounding_, silent_)>;
def : Pat<(fmul v4f32:$rs1, v4f32:$rs2), (FMULWQ PairedReg:$rs1, PairedReg:$rs2, rounding_, silent_)>;
// FMUL*C -> TODO
// FNARROW
def : Pat<(f16 (fpround f32:$val)), (FNARROWWH SingleReg:$val, rounding_, silent_)>;
def : Pat<(f16 (fpround f64:$val)), (FNARROWWH (FNARROWDW SingleReg:$val, rounding_, silent_), rounding_, silent_)>;
def : Pat<(f32 (fpround f64:$val)), (FNARROWDW SingleReg:$val, rounding_, silent_)>;
// FNEG, see K1CInstrInfo.td for f32, f64, v2f32, v4f16
def : Pat<(fneg f16:$rs), (FNEGHQ SingleReg:$rs)>;
def : Pat<(fneg v2f16:$rs), (FNEGHQ SingleReg:$rs)>;
def : Pat<(vfneg v2f16:$rs), (FNEGHQ SingleReg:$rs)>;
def : Pat<(vfneg v4f16:$rs), (FNEGHQ SingleReg:$rs)>;
def : Pat<(vfneg v2f32:$rs), (FNEGWP SingleReg:$rs)>;
// FSBFC -> TODO
// FSBF
def : Pat<(fsub Binary16:$rs1, f16:$rs2), (FSBFHQd0 SingleReg:$rs2, Binary16:$rs1)>;
def : Pat<(fsub Binary32:$rs1, f32:$rs2), (FSBFWd0 SingleReg:$rs2, Binary32:$rs1)>;
def : Pat<(fsub Binary64:$rs1, f64:$rs2), (FSBFDd0 SingleReg:$rs2, Binary64:$rs1)>;
def : Pat<(fsub f16:$rs1, f16:$rs2), (FSBFHQd1 SingleReg:$rs2, SingleReg:$rs1, rounding_, silent_)>;
def : Pat<(fsub f32:$rs1, f32:$rs2), (FSBFWd1 SingleReg:$rs2, SingleReg:$rs1, rounding_, silent_)>;
def : Pat<(fsub f64:$rs1, f64:$rs2), (FSBFDd1 SingleReg:$rs2, SingleReg:$rs1, rounding_, silent_)>;
def : Pat<(fsub v2f16:$rs1, v2f16:$rs2), (FSBFHQd1 SingleReg:$rs2, SingleReg:$rs1, rounding_, silent_)>;
def : Pat<(fsub v4f16:$rs1, v4f16:$rs2), (FSBFHQd1 SingleReg:$rs2, SingleReg:$rs1, rounding_, silent_)>;
def : Pat<(fsub v2f32:$rs1, v2f32:$rs2), (FSBFWPd1 SingleReg:$rs2, SingleReg:$rs1, rounding_, silent_)>;
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
def : Pat<(extractelt (v2f32 SingleReg:$v), 1), (SRADd1 SingleReg :$v, (i64 32))>;

// v4f32
def : Pat<(extractelt (v4f32 PairedReg:$v), 0), (f32 (EXTRACT_SUBREG $v, 1))>;
def : Pat<(extractelt (v4f32 PairedReg:$v), 1), (SRADd1 (f32 (EXTRACT_SUBREG $v, 1)), (i64 32))>;
def : Pat<(extractelt (v4f32 PairedReg:$v), 2), (f32 (EXTRACT_SUBREG $v, 2))>;
def : Pat<(extractelt (v4f32 PairedReg:$v), 3), (SRADd1 (f32 (EXTRACT_SUBREG $v, 2)), (i64 32))>;

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
def : Pat<(extractelt v2f16:$v, 1), (SRLDd1 SingleReg:$v, (i64 16))>;

// v4f16
def : Pat<(extractelt (v4f16 SingleReg:$v), 0), (EXTFZ SingleReg:$v, 15, 0)>;
def : Pat<(extractelt (v4f16 SingleReg:$v), 1), (EXTFZ SingleReg:$v, 31, 16)>;
def : Pat<(extractelt (v4f16 SingleReg:$v), 2), (EXTFZ SingleReg:$v, 47, 32)>;
def : Pat<(extractelt (v4f16 SingleReg:$v), 3), (SRLDd1 SingleReg:$v, (i64 48))>;

def : Pat<(fcopysign f64:$v1, f64:$v2), (INSF SingleReg:$v1, (f64 (SRADd0 SingleReg:$v2, 63)), 63, 63)>;
def : Pat<(fcopysign f64:$v1, f32:$v2), (INSF SingleReg:$v1, (f64 (SRAWd0 SingleReg:$v2, 31)), 63, 63)>;
def : Pat<(fcopysign f64:$v1, f16:$v2), (INSF SingleReg:$v1, (f64 (SRAWd0 SingleReg:$v2, 15)), 63, 63)>;
def : Pat<(fcopysign f32:$v1, f64:$v2), (INSF SingleReg:$v1, (f64 (SRADd0 SingleReg:$v2, 63)), 31, 31)>;
def : Pat<(fcopysign f32:$v1, f32:$v2), (INSF SingleReg:$v1, (f64 (SRAWd0 SingleReg:$v2, 31)), 31, 31)>;
def : Pat<(fcopysign f32:$v1, f16:$v2), (INSF SingleReg:$v1, (f64 (SRAWd0 SingleReg:$v2, 15)), 31, 31)>;
def : Pat<(fcopysign f16:$v1, f64:$v2), (INSF SingleReg:$v1, (f64 (SRADd0 SingleReg:$v2, 63)), 15, 15)>;
def : Pat<(fcopysign f16:$v1, f32:$v2), (INSF SingleReg:$v1, (f64 (SRAWd0 SingleReg:$v2, 31)), 15, 15)>;
def : Pat<(fcopysign f16:$v1, f16:$v2), (INSF SingleReg:$v1, (f64 (SRAWd0 SingleReg:$v2, 15)), 15, 15)>;
