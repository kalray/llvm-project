//===-- K1CFloatingPoint.td --------------------------------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

class SILENT<int N> : PatLeaf<(i8 N)>;
def SILENT_OFF : SILENT<0>;
def SILENT_ON  : SILENT<1>;

class ROUNDING<int N> : PatLeaf<(i8 N)>;
def ROUND_NE : ROUNDING<0>;
def ROUND_U  : ROUNDING<1>;
def ROUND_D  : ROUNDING<2>;
def ROUND_Z  : ROUNDING<3>;
def ROUND_NA : ROUNDING<4>;
def ROUND_NZ : ROUNDING<5>;
def ROUND_O  : ROUNDING<6>;
def ROUND_CS : ROUNDING<7>;

class FCOMP<int N> : PatLeaf<(i8 N)>;
def FCOMP_ONE : FCOMP<0>;
def FCOMP_UEQ : FCOMP<1>;
def FCOMP_OEQ : FCOMP<2>;
def FCOMP_UNE : FCOMP<3>;
def FCOMP_OLT : FCOMP<4>;
def FCOMP_UGE : FCOMP<5>;
def FCOMP_OGE : FCOMP<6>;
def FCOMP_ULT : FCOMP<7>;

def DEFAULT_FPCONV_SHIFT : PatLeaf<(i64 0)>;

class VARIANT<int N> : PatLeaf<(i8 N)>;
def VARIANT_CACHED               : VARIANT<0>;
def VARIANT_SPECULATIVE          : VARIANT<1>;
def VARIANT_UNCACHED             : VARIANT<2>;
def VARIANT_UNCACHED_SPECULATIVE : VARIANT<3>;

// Store
def : Pat<(store (f16 SingleReg:$val), AddrRI:$addr), (SHri AddrRI:$addr, SingleReg:$val)>;
def : Pat<(store (f32 SingleReg:$val), AddrRI:$addr), (SWri AddrRI:$addr, SingleReg:$val)>;
def : Pat<(store (f64 SingleReg:$val), AddrRI:$addr), (SDri AddrRI:$addr, SingleReg:$val)>;
def : Pat<(store (v2f32 SingleReg:$val), AddrRI:$addr), (SDri AddrRI:$addr, SingleReg:$val)>;
def : Pat<(store (v4f16 SingleReg:$val), AddrRI:$addr), (SDri AddrRI:$addr, SingleReg:$val)>;
def : Pat<(store (v4f32 PairedReg:$val), AddrRI: $addr), (SQri AddrRI:$addr, PairedReg:$val)>;

def truncstoref16 : PatFrag<(ops node:$val, node:$ptr),
                            (truncstore node:$val, node:$ptr)> {
  let IsStore = 1;
  let MemoryVT = f16;
}

def : Pat<(truncstoref32 f64:$val, AddrRI:$addr), (SWri AddrRI:$addr, (FNARROWDW SingleReg:$val, ROUND_CS, SILENT_OFF))>;

def : Pat<(truncstoref16 f32:$val, AddrRI:$addr), (SHri AddrRI:$addr, (FNARROWWH SingleReg:$val, ROUND_CS, SILENT_OFF))>;

// Load
def loadf16 : PatFrag<(ops node:$ptr), (f16 (load node:$ptr))>;
def loadf32 : PatFrag<(ops node:$ptr), (f32 (load node:$ptr))>;
def loadf64 : PatFrag<(ops node:$ptr), (f64 (load node:$ptr))>;
def loadv4f16 : PatFrag<(ops node:$ptr), (v4f16 (load node:$ptr))>;
def loadv2f32 : PatFrag<(ops node:$ptr), (v2f32 (load node:$ptr))>;
def loadv4f32 : PatFrag<(ops node:$ptr), (v4f32 (load node:$ptr))>;

def : Pat<(loadf16 AddrRI:$addr), (LHZri AddrRI:$addr, VARIANT_CACHED)>;
def : Pat<(loadf32 AddrRI:$addr), (LWZri AddrRI:$addr, VARIANT_CACHED)>;
def : Pat<(loadf64 AddrRI:$addr), (LDri AddrRI:$addr, VARIANT_CACHED)>;
def : Pat<(loadv2f32 AddrRI:$addr), (LDri AddrRI:$addr, VARIANT_CACHED)>;
def : Pat<(loadv4f16 AddrRI:$addr), (LDri AddrRI:$addr, VARIANT_CACHED)>;
def : Pat<(loadv4f32 AddrRI:$addr), (LQri AddrRI:$addr, VARIANT_CACHED)>;

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

// FPU Insns

// FABS, see K1CInstrInfo.td
// FADDC -> TODO
// FADD, see K1CInstrInfo.td for immediate patterns
def : Pat<(fadd f16:$rs1, f16:$rs2), (FADDHQrr SingleReg:$rs1, SingleReg:$rs2, ROUND_CS, SILENT_OFF)>;
def : Pat<(fadd f32:$rs1, f32:$rs2), (FADDWrr SingleReg:$rs1, SingleReg:$rs2, ROUND_CS, SILENT_OFF)>;
def : Pat<(fadd f64:$rs1, f64:$rs2), (FADDDrr SingleReg:$rs1, SingleReg:$rs2, ROUND_CS, SILENT_OFF)>;
def : Pat<(fadd v4f16:$rs1, v4f16:$rs2), (FADDHQrr SingleReg:$rs1, SingleReg:$rs2, ROUND_CS, SILENT_OFF)>;
def : Pat<(fadd v2f32:$rs1, v2f32:$rs2), (FADDWPd3 SingleReg:$rs1, SingleReg:$rs2, ROUND_CS, SILENT_OFF)>;
def : Pat<(fadd v4f32:$rs1, v4f32:$rs2), (FADDWQ PairedReg:$rs1, PairedReg:$rs2, ROUND_CS, SILENT_OFF)>;
// FCDIV -> TODO
// FCOMP (TODO: factorize these patterns in ISelLowering pass)
def : Pat<(i32 (setoeq f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, FCOMP_OEQ)>;
def : Pat<(i32 (setogt f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$ry, SingleReg:$rz, FCOMP_OLT)>;
def : Pat<(i32 (setoge f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, FCOMP_OGE)>;
def : Pat<(i32 (setolt f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, FCOMP_OLT)>;
def : Pat<(i32 (setole f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$ry, SingleReg:$rz, FCOMP_OGE)>;
def : Pat<(i32 (setone f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, FCOMP_ONE)>;
def : Pat<(i32 (seto f16:$rz, f16:$ry)), (ORDd0 (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, FCOMP_OEQ), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, FCOMP_ONE))>;
def : Pat<(i32 (setuo f16:$rz, f16:$ry)), (ORDd0 (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, FCOMP_UEQ), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, FCOMP_UNE))>;
def : Pat<(i32 (setueq f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, FCOMP_UEQ)>;
def : Pat<(i32 (setugt f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$ry, SingleReg:$rz, FCOMP_ULT)>;
def : Pat<(i32 (setuge f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, FCOMP_UGE)>;
def : Pat<(i32 (setult f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, FCOMP_ULT)>;
def : Pat<(i32 (setule f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$ry, SingleReg:$rz, FCOMP_UGE)>;
def : Pat<(i32 (setune f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, FCOMP_UNE)>;
def : Pat<(i32 (setoeq f32:$rz, Binary32Imm:$imm)), (FCOMPWri SingleReg:$rz, Binary32Imm:$imm, FCOMP_OEQ)>;
def : Pat<(i32 (setogt Binary32Imm:$imm, f32:$ry)), (FCOMPWri SingleReg:$ry, Binary32Imm:$imm, FCOMP_OLT)>;
def : Pat<(i32 (setoge f32:$rz, Binary32Imm:$imm)), (FCOMPWri SingleReg:$rz, Binary32Imm:$imm, FCOMP_OGE)>;
def : Pat<(i32 (setolt f32:$rz, Binary32Imm:$imm)), (FCOMPWri SingleReg:$rz, Binary32Imm:$imm, FCOMP_OLT)>;
def : Pat<(i32 (setole Binary32Imm:$imm, f32:$ry)), (FCOMPWri SingleReg:$ry, Binary32Imm:$imm, FCOMP_OGE)>;
def : Pat<(i32 (setone f32:$rz, Binary32Imm:$imm)), (FCOMPWri SingleReg:$rz, Binary32Imm:$imm, FCOMP_ONE)>;
def : Pat<(i32 (seto f32:$rz, Binary32Imm:$imm)), (ORDd0 (FCOMPWrr SingleReg:$rz, Binary32Imm:$imm, FCOMP_OEQ), (FCOMPWrr SingleReg:$rz, Binary32Imm:$imm, FCOMP_ONE))>;
def : Pat<(i32 (setuo f32:$rz, Binary32Imm:$imm)), (ORDd0 (FCOMPWrr SingleReg:$rz, Binary32Imm:$imm, FCOMP_UEQ), (FCOMPWrr SingleReg:$rz, Binary32Imm:$imm, FCOMP_UNE))>;
def : Pat<(i32 (setueq f32:$rz, Binary32Imm:$imm)), (FCOMPWri SingleReg:$rz, Binary32Imm:$imm, FCOMP_UEQ)>;
def : Pat<(i32 (setugt Binary32Imm:$imm, f32:$ry)), (FCOMPWri SingleReg:$ry, Binary32Imm:$imm, FCOMP_ULT)>;
def : Pat<(i32 (setuge f32:$rz, Binary32Imm:$imm)), (FCOMPWri SingleReg:$rz, Binary32Imm:$imm, FCOMP_UGE)>;
def : Pat<(i32 (setult f32:$rz, Binary32Imm:$imm)), (FCOMPWri SingleReg:$rz, Binary32Imm:$imm, FCOMP_ULT)>;
def : Pat<(i32 (setule Binary32Imm:$imm, f32:$ry)), (FCOMPWri SingleReg:$ry, Binary32Imm:$imm, FCOMP_UGE)>;
def : Pat<(i32 (setune f32:$rz, Binary32Imm:$imm)), (FCOMPWri SingleReg:$rz, Binary32Imm:$imm, FCOMP_UNE)>;
def : Pat<(i32 (setoeq f32:$rz, f32:$ry)), (FCOMPWrr SingleReg:$rz, SingleReg:$ry, FCOMP_OEQ)>;
def : Pat<(i32 (setogt f32:$rz, f32:$ry)), (FCOMPWrr SingleReg:$ry, SingleReg:$rz, FCOMP_OLT)>;
def : Pat<(i32 (setoge f32:$rz, f32:$ry)), (FCOMPWrr SingleReg:$rz, SingleReg:$ry, FCOMP_OGE)>;
def : Pat<(i32 (setolt f32:$rz, f32:$ry)), (FCOMPWrr SingleReg:$rz, SingleReg:$ry, FCOMP_OLT)>;
def : Pat<(i32 (setole f32:$rz, f32:$ry)), (FCOMPWrr SingleReg:$ry, SingleReg:$rz, FCOMP_OGE)>;
def : Pat<(i32 (setone f32:$rz, f32:$ry)), (FCOMPWrr SingleReg:$rz, SingleReg:$ry, FCOMP_ONE)>;
def : Pat<(i32 (seto f32:$rz, f32:$ry)), (ORDd0 (FCOMPWrr SingleReg:$rz, SingleReg:$ry, FCOMP_OEQ), (FCOMPWrr SingleReg:$rz, SingleReg:$ry, FCOMP_ONE))>;
def : Pat<(i32 (setuo f32:$rz, f32:$ry)), (ORDd0 (FCOMPWrr SingleReg:$rz, SingleReg:$ry, FCOMP_UEQ), (FCOMPWrr SingleReg:$rz, SingleReg:$ry, FCOMP_UNE))>;
def : Pat<(i32 (setueq f32:$rz, f32:$ry)), (FCOMPWrr SingleReg:$rz, SingleReg:$ry, FCOMP_UEQ)>;
def : Pat<(i32 (setugt f32:$rz, f32:$ry)), (FCOMPWrr SingleReg:$ry, SingleReg:$rz, FCOMP_ULT)>;
def : Pat<(i32 (setuge f32:$rz, f32:$ry)), (FCOMPWrr SingleReg:$rz, SingleReg:$ry, FCOMP_UGE)>;
def : Pat<(i32 (setult f32:$rz, f32:$ry)), (FCOMPWrr SingleReg:$rz, SingleReg:$ry, FCOMP_ULT)>;
def : Pat<(i32 (setule f32:$rz, f32:$ry)), (FCOMPWrr SingleReg:$ry, SingleReg:$rz, FCOMP_UGE)>;
def : Pat<(i32 (setune f32:$rz, f32:$ry)), (FCOMPWrr SingleReg:$rz, SingleReg:$ry, FCOMP_UNE)>;
def : Pat<(i32 (setoeq f64:$rz, f64:$ry)), (FCOMPDrr SingleReg:$rz, SingleReg:$ry, FCOMP_OEQ)>;
def : Pat<(i32 (setogt f64:$rz, f64:$ry)), (FCOMPDrr SingleReg:$ry, SingleReg:$rz, FCOMP_OLT)>;
def : Pat<(i32 (setoge f64:$rz, f64:$ry)), (FCOMPDrr SingleReg:$rz, SingleReg:$ry, FCOMP_OGE)>;
def : Pat<(i32 (setolt f64:$rz, f64:$ry)), (FCOMPDrr SingleReg:$rz, SingleReg:$ry, FCOMP_OLT)>;
def : Pat<(i32 (setole f64:$rz, f64:$ry)), (FCOMPDrr SingleReg:$ry, SingleReg:$rz, FCOMP_OGE)>;
def : Pat<(i32 (setone f64:$rz, f64:$ry)), (FCOMPDrr SingleReg:$rz, SingleReg:$ry, FCOMP_ONE)>;
def : Pat<(i32 (seto f64:$rz, f64:$ry)), (ORDd0 (FCOMPDrr SingleReg:$rz, SingleReg:$ry, FCOMP_OEQ), (FCOMPDrr SingleReg:$rz, SingleReg:$ry, FCOMP_ONE))>;
def : Pat<(i32 (setuo f64:$rz, f64:$ry)), (ORDd0 (FCOMPDrr SingleReg:$rz, SingleReg:$ry, FCOMP_UEQ), (FCOMPDrr SingleReg:$rz, SingleReg:$ry, FCOMP_UNE))>;
def : Pat<(i32 (setueq f64:$rz, f64:$ry)), (FCOMPDrr SingleReg:$rz, SingleReg:$ry, FCOMP_UEQ)>;
def : Pat<(i32 (setugt f64:$rz, f64:$ry)), (FCOMPDrr SingleReg:$ry, SingleReg:$rz, FCOMP_ULT)>;
def : Pat<(i32 (setuge f64:$rz, f64:$ry)), (FCOMPDrr SingleReg:$rz, SingleReg:$ry, FCOMP_UGE)>;
def : Pat<(i32 (setult f64:$rz, f64:$ry)), (FCOMPDrr SingleReg:$rz, SingleReg:$ry, FCOMP_ULT)>;
def : Pat<(i32 (setule f64:$rz, f64:$ry)), (FCOMPDrr SingleReg:$ry, SingleReg:$rz, FCOMP_UGE)>;
def : Pat<(i32 (setune f64:$rz, f64:$ry)), (FCOMPDrr SingleReg:$rz, SingleReg:$ry, FCOMP_UNE)>;
// SELECT_CC expanded to SELECT
def : Pat<(SelectCC i64:$cmp, i64:$zero, f32:$truev, f32:$falsev), (Select_Instr SingleReg:$cmp, $zero, Binary32Imm:$truev, Binary32Imm:$falsev)>;
def : Pat<(SelectCC i64:$cmp, i64:$zero, f64:$truev, f64:$falsev), (Select_Instr SingleReg:$cmp, $zero, Binary64Imm:$truev, Binary64Imm:$falsev)>;
// FDOT2 -> TODO
// FFMA  -> TODO
// FFMS  -> TODO
// FINV  -> TODO
// FISR  -> TODO
// FIXED
def : Pat<(i32 (fp_to_uint f16:$val)), (FIXEDUW (FWIDENLHW SingleReg:$val, SILENT_OFF), DEFAULT_FPCONV_SHIFT, ROUND_CS, SILENT_OFF)>;
def : Pat<(i64 (fp_to_uint f16:$val)), (FIXEDUD (FWIDENLWD (FWIDENLHW SingleReg:$val, SILENT_OFF), SILENT_OFF), DEFAULT_FPCONV_SHIFT, ROUND_CS, SILENT_OFF)>;
def : Pat<(i32 (fp_to_uint f32:$val)), (FIXEDUW SingleReg:$val, DEFAULT_FPCONV_SHIFT, ROUND_CS, SILENT_OFF)>;
def : Pat<(i64 (fp_to_uint f32:$val)), (FIXEDUD (FWIDENLWD SingleReg:$val, SILENT_OFF), DEFAULT_FPCONV_SHIFT, ROUND_CS, SILENT_OFF)>;
def : Pat<(i32 (fp_to_uint f64:$val)), (FIXEDUD SingleReg:$val, DEFAULT_FPCONV_SHIFT, ROUND_CS, SILENT_OFF)>;
def : Pat<(i64 (fp_to_uint f64:$val)), (FIXEDUD SingleReg:$val, DEFAULT_FPCONV_SHIFT, ROUND_CS, SILENT_OFF)>;
def : Pat<(i32 (fp_to_sint f16:$val)), (FIXEDW (FWIDENLHW SingleReg:$val, SILENT_OFF), DEFAULT_FPCONV_SHIFT, ROUND_CS, SILENT_OFF)>;
def : Pat<(i64 (fp_to_sint f16:$val)), (FIXEDD (FWIDENLWD (FWIDENLHW SingleReg:$val, SILENT_OFF), SILENT_OFF), DEFAULT_FPCONV_SHIFT, ROUND_CS, SILENT_OFF)>;
def : Pat<(i32 (fp_to_sint f32:$val)), (FIXEDW SingleReg:$val, DEFAULT_FPCONV_SHIFT, ROUND_CS, SILENT_OFF)>;
def : Pat<(i64 (fp_to_sint f32:$val)), (FIXEDD (FWIDENLWD SingleReg:$val, SILENT_OFF), DEFAULT_FPCONV_SHIFT, ROUND_CS, SILENT_OFF)>;
def : Pat<(i32 (fp_to_sint f64:$val)), (FIXEDD SingleReg:$val, DEFAULT_FPCONV_SHIFT, ROUND_CS, SILENT_OFF)>;
def : Pat<(i64 (fp_to_sint f64:$val)), (FIXEDD SingleReg:$val, DEFAULT_FPCONV_SHIFT, ROUND_CS, SILENT_OFF)>;
// FLOAT
def : Pat<(f16 (uint_to_fp i32:$val)), (FNARROWWH (FLOATUW SingleReg:$val, DEFAULT_FPCONV_SHIFT, ROUND_CS, SILENT_OFF), ROUND_CS, SILENT_OFF)>;
def : Pat<(f16 (uint_to_fp i64:$val)), (FNARROWWH (FNARROWDW (FLOATUD SingleReg:$val, DEFAULT_FPCONV_SHIFT, ROUND_CS, SILENT_OFF), ROUND_CS, SILENT_OFF), ROUND_CS, SILENT_OFF)>;
def : Pat<(f32 (uint_to_fp i32:$val)), (FLOATUW SingleReg:$val, DEFAULT_FPCONV_SHIFT, ROUND_CS, SILENT_OFF)>;
def : Pat<(f32 (uint_to_fp i64:$val)), (FLOATUW (SATUDd0 SingleReg:$val, (i32 32)), DEFAULT_FPCONV_SHIFT, ROUND_CS, SILENT_OFF)>;
def : Pat<(f64 (uint_to_fp i32:$val)), (FLOATUD (ZXWD SingleReg:$val), DEFAULT_FPCONV_SHIFT, ROUND_CS, SILENT_OFF)>;
def : Pat<(f64 (uint_to_fp i64:$val)), (FLOATUD SingleReg:$val, DEFAULT_FPCONV_SHIFT, ROUND_CS, SILENT_OFF)>;
def : Pat<(f16 (sint_to_fp i32:$val)), (FNARROWWH (FLOATW SingleReg:$val, DEFAULT_FPCONV_SHIFT, ROUND_CS, SILENT_OFF), ROUND_CS, SILENT_OFF)>;
def : Pat<(f16 (sint_to_fp i64:$val)), (FNARROWWH (FNARROWDW (FLOATD SingleReg:$val, DEFAULT_FPCONV_SHIFT, ROUND_CS, SILENT_OFF), ROUND_CS, SILENT_OFF), ROUND_CS, SILENT_OFF)>;
def : Pat<(f32 (sint_to_fp i32:$val)), (FLOATW SingleReg:$val, DEFAULT_FPCONV_SHIFT, ROUND_CS, SILENT_OFF)>;
def : Pat<(f32 (sint_to_fp i64:$val)), (FLOATW (SATDd0 SingleReg:$val, (i32 32)), DEFAULT_FPCONV_SHIFT, ROUND_CS, SILENT_OFF)>;
def : Pat<(f64 (sint_to_fp i32:$val)), (FLOATD (SXWD SingleReg:$val), DEFAULT_FPCONV_SHIFT, ROUND_CS, SILENT_OFF)>;
def : Pat<(f64 (sint_to_fp i64:$val)), (FLOATD SingleReg:$val, DEFAULT_FPCONV_SHIFT, ROUND_CS, SILENT_OFF)>;
// FMAX  -> TODO
// FMIN  -> TODO
// FMM2A -> TODO
// FMM2S -> TODO
// FMM2  -> TODO
// FMULC -> TODO
// FMUL, see K1CInstrInfo.td for immediate patterns
def : Pat<(fmul f16:$rs1, f16:$rs2), (FMULHQrr SingleReg:$rs1, SingleReg:$rs2, ROUND_CS, SILENT_OFF)>;
def : Pat<(fmul f32:$rs1, f32:$rs2), (FMULWrr SingleReg:$rs1, SingleReg:$rs2, ROUND_CS, SILENT_OFF)>;
def : Pat<(fmul f64:$rs1, f64:$rs2), (FMULDrr SingleReg:$rs1, SingleReg:$rs2, ROUND_CS, SILENT_OFF)>;
def : Pat<(fmul v2f32:$rs1, v2f32:$rs2), (FMULWPd3 SingleReg:$rs1, SingleReg:$rs2, ROUND_CS, SILENT_OFF)>;
def : Pat<(fmul v4f32:$rs1, v4f32:$rs2), (FMULWQ PairedReg:$rs1, PairedReg:$rs2, ROUND_CS, SILENT_OFF)>;
// FMUL*C -> TODO
// FNARROW
def : Pat<(f16 (fpround f32:$val)), (FNARROWWH SingleReg:$val, ROUND_CS, SILENT_OFF)>;
def : Pat<(f16 (fpround f64:$val)), (FNARROWWH (FNARROWDW SingleReg:$val, ROUND_CS, SILENT_OFF), ROUND_CS, SILENT_OFF)>;
def : Pat<(f32 (fpround f64:$val)), (FNARROWDW SingleReg:$val, ROUND_CS, SILENT_OFF)>;
// FNEG, see K1CInstrInfo.td
// FSBFC -> TODO
// FSBF, see K1CInstrInfo.td for immediate patterns
def : Pat<(fsub f16:$rs1, f16:$rs2), (FSBFHQrr SingleReg:$rs1, SingleReg:$rs2, ROUND_CS, SILENT_OFF)>;
def : Pat<(fsub f32:$rs1, f32:$rs2), (FSBFWrr SingleReg:$rs1, SingleReg:$rs2, ROUND_CS, SILENT_OFF)>;
def : Pat<(fsub f64:$rs1, f64:$rs2), (FSBFDrr SingleReg:$rs1, SingleReg:$rs2, ROUND_CS, SILENT_OFF)>;
def : Pat<(fsub v4f16:$rs1, v4f16:$rs2), (FSBFHQrr SingleReg:$rs2, SingleReg:$rs1, ROUND_CS, SILENT_OFF)>;
def : Pat<(fsub v2f32:$rs1, v2f32:$rs2), (FSBFWPd3 SingleReg:$rs2, SingleReg:$rs1, ROUND_CS, SILENT_OFF)>;
def : Pat<(fsub v4f32:$rs1, v4f32:$rs2), (FSBFWQ PairedReg:$rs2, PairedReg:$rs1, ROUND_CS, SILENT_OFF)>;
// FSDIV -> TODO
// FSINV -> TODO
// FSISR -> TODO
// FWIDEN
def : Pat<(f64 (fpextend f32:$val)), (FWIDENLWD SingleReg:$val, SILENT_OFF)>;
def : Pat<(f64 (fpextend f16:$val)), (FWIDENLWD (FWIDENLHW SingleReg:$val, SILENT_OFF), SILENT_OFF)>;
def : Pat<(f32 (fpextend f16:$val)), (FWIDENLHW SingleReg:$val, SILENT_OFF)>;

def : Pat<(v4f16 (build_vector f16:$v1, f16:$v2, f16:$v3, f16:$v4)),
      (ORDd0
              (ORDd0 (SLLDd1 SingleReg:$v4, (i64 48)), (SLLDd1 SingleReg:$v3, (i64 32))),
              (ORDd0 (SLLDd1 SingleReg:$v2, (i64 16)), SingleReg:$v1)
      )>;

def : Pat<(extractelt (v2f32 SingleReg:$v), 0), (COPY SingleReg:$v)>;
def : Pat<(extractelt (v2f32 SingleReg:$v), 1), (SRADd1 SingleReg :$v, (i64 32))>;
