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

// Store
def : Pat<(store (f16 SingleReg:$val), AddrRI:$addr), (SHri AddrRI:$addr, SingleReg:$val)>;
def : Pat<(store (f32 SingleReg:$val), AddrRI:$addr), (SWri AddrRI:$addr, SingleReg:$val)>;
def : Pat<(store (f64 SingleReg:$val), AddrRI:$addr), (SDri AddrRI:$addr, SingleReg:$val)>;

// Load
def loadf16 : PatFrag<(ops node:$ptr), (f16 (load node:$ptr))>;
def loadf32 : PatFrag<(ops node:$ptr), (f32 (load node:$ptr))>;
def loadf64 : PatFrag<(ops node:$ptr), (f64 (load node:$ptr))>;

def : Pat<(loadf16 AddrRI:$addr), (LHZri AddrRI:$addr)>;
def : Pat<(loadf32 AddrRI:$addr), (LWZri AddrRI:$addr)>;
def : Pat<(loadf64 AddrRI:$addr), (LDri AddrRI:$addr)>;


// FPU Insns

// FABS, see K1CInstrInfo.td
// FADDC -> TODO
// FADD, see K1CInstrInfo.td for immediate patterns
def : Pat<(fadd f16:$rs1, f16:$rs2), (FADDHQrr SingleReg:$rs1, SingleReg:$rs2, ROUND_CS, SILENT_OFF)>;
def : Pat<(fadd f32:$rs1, f32:$rs2), (FADDWrr SingleReg:$rs1, SingleReg:$rs2, ROUND_CS, SILENT_OFF)>;
def : Pat<(fadd f64:$rs1, f64:$rs2), (FADDDrr SingleReg:$rs1, SingleReg:$rs2, ROUND_CS, SILENT_OFF)>;
// FCDIV -> TODO
// FCOMP (TODO: factorize these patterns in ISelLowering pass)
def : Pat<(i64 (setoeq f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, FCOMP_OEQ)>;
def : Pat<(i64 (setogt f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$ry, SingleReg:$rz, FCOMP_OLT)>;
def : Pat<(i64 (setoge f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, FCOMP_OGE)>;
def : Pat<(i64 (setolt f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, FCOMP_OLT)>;
def : Pat<(i64 (setole f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$ry, SingleReg:$rz, FCOMP_OGE)>;
def : Pat<(i64 (setone f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, FCOMP_ONE)>;
def : Pat<(i64 (seto f16:$rz, f16:$ry)), (ORDd0 (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, FCOMP_OEQ), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, FCOMP_ONE))>;
def : Pat<(i64 (setuo f16:$rz, f16:$ry)), (ORDd0 (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, FCOMP_UEQ), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, FCOMP_UNE))>;
def : Pat<(i64 (setueq f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, FCOMP_UEQ)>;
def : Pat<(i64 (setugt f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$ry, SingleReg:$rz, FCOMP_ULT)>;
def : Pat<(i64 (setuge f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, FCOMP_UGE)>;
def : Pat<(i64 (setult f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, FCOMP_ULT)>;
def : Pat<(i64 (setule f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$ry, SingleReg:$rz, FCOMP_UGE)>;
def : Pat<(i64 (setune f16:$rz, f16:$ry)), (FCOMPNHQ SingleReg:$rz, SingleReg:$ry, FCOMP_UNE)>;
def : Pat<(i64 (setoeq f32:$rz, Binary32Imm:$imm)), (FCOMPWri SingleReg:$rz, Binary32Imm:$imm, FCOMP_OEQ)>;
def : Pat<(i64 (setogt Binary32Imm:$imm, f32:$ry)), (FCOMPWri SingleReg:$ry, Binary32Imm:$imm, FCOMP_OLT)>;
def : Pat<(i64 (setoge f32:$rz, Binary32Imm:$imm)), (FCOMPWri SingleReg:$rz, Binary32Imm:$imm, FCOMP_OGE)>;
def : Pat<(i64 (setolt f32:$rz, Binary32Imm:$imm)), (FCOMPWri SingleReg:$rz, Binary32Imm:$imm, FCOMP_OLT)>;
def : Pat<(i64 (setole Binary32Imm:$imm, f32:$ry)), (FCOMPWri SingleReg:$ry, Binary32Imm:$imm, FCOMP_OGE)>;
def : Pat<(i64 (setone f32:$rz, Binary32Imm:$imm)), (FCOMPWri SingleReg:$rz, Binary32Imm:$imm, FCOMP_ONE)>;
def : Pat<(i64 (seto f32:$rz, Binary32Imm:$imm)), (ORDd0 (FCOMPWrr SingleReg:$rz, Binary32Imm:$imm, FCOMP_OEQ), (FCOMPWrr SingleReg:$rz, Binary32Imm:$imm, FCOMP_ONE))>;
def : Pat<(i64 (setuo f32:$rz, Binary32Imm:$imm)), (ORDd0 (FCOMPWrr SingleReg:$rz, Binary32Imm:$imm, FCOMP_UEQ), (FCOMPWrr SingleReg:$rz, Binary32Imm:$imm, FCOMP_UNE))>;
def : Pat<(i64 (setueq f32:$rz, Binary32Imm:$imm)), (FCOMPWri SingleReg:$rz, Binary32Imm:$imm, FCOMP_UEQ)>;
def : Pat<(i64 (setugt Binary32Imm:$imm, f32:$ry)), (FCOMPWri SingleReg:$ry, Binary32Imm:$imm, FCOMP_ULT)>;
def : Pat<(i64 (setuge f32:$rz, Binary32Imm:$imm)), (FCOMPWri SingleReg:$rz, Binary32Imm:$imm, FCOMP_UGE)>;
def : Pat<(i64 (setult f32:$rz, Binary32Imm:$imm)), (FCOMPWri SingleReg:$rz, Binary32Imm:$imm, FCOMP_ULT)>;
def : Pat<(i64 (setule Binary32Imm:$imm, f32:$ry)), (FCOMPWri SingleReg:$ry, Binary32Imm:$imm, FCOMP_UGE)>;
def : Pat<(i64 (setune f32:$rz, Binary32Imm:$imm)), (FCOMPWri SingleReg:$rz, Binary32Imm:$imm, FCOMP_UNE)>;
def : Pat<(i64 (setoeq f32:$rz, f32:$ry)), (FCOMPWrr SingleReg:$rz, SingleReg:$ry, FCOMP_OEQ)>;
def : Pat<(i64 (setogt f32:$rz, f32:$ry)), (FCOMPWrr SingleReg:$ry, SingleReg:$rz, FCOMP_OLT)>;
def : Pat<(i64 (setoge f32:$rz, f32:$ry)), (FCOMPWrr SingleReg:$rz, SingleReg:$ry, FCOMP_OGE)>;
def : Pat<(i64 (setolt f32:$rz, f32:$ry)), (FCOMPWrr SingleReg:$rz, SingleReg:$ry, FCOMP_OLT)>;
def : Pat<(i64 (setole f32:$rz, f32:$ry)), (FCOMPWrr SingleReg:$ry, SingleReg:$rz, FCOMP_OGE)>;
def : Pat<(i64 (setone f32:$rz, f32:$ry)), (FCOMPWrr SingleReg:$rz, SingleReg:$ry, FCOMP_ONE)>;
def : Pat<(i64 (seto f32:$rz, f32:$ry)), (ORDd0 (FCOMPWrr SingleReg:$rz, SingleReg:$ry, FCOMP_OEQ), (FCOMPWrr SingleReg:$rz, SingleReg:$ry, FCOMP_ONE))>;
def : Pat<(i64 (setuo f32:$rz, f32:$ry)), (ORDd0 (FCOMPWrr SingleReg:$rz, SingleReg:$ry, FCOMP_UEQ), (FCOMPWrr SingleReg:$rz, SingleReg:$ry, FCOMP_UNE))>;
def : Pat<(i64 (setueq f32:$rz, f32:$ry)), (FCOMPWrr SingleReg:$rz, SingleReg:$ry, FCOMP_UEQ)>;
def : Pat<(i64 (setugt f32:$rz, f32:$ry)), (FCOMPWrr SingleReg:$ry, SingleReg:$rz, FCOMP_ULT)>;
def : Pat<(i64 (setuge f32:$rz, f32:$ry)), (FCOMPWrr SingleReg:$rz, SingleReg:$ry, FCOMP_UGE)>;
def : Pat<(i64 (setult f32:$rz, f32:$ry)), (FCOMPWrr SingleReg:$rz, SingleReg:$ry, FCOMP_ULT)>;
def : Pat<(i64 (setule f32:$rz, f32:$ry)), (FCOMPWrr SingleReg:$ry, SingleReg:$rz, FCOMP_UGE)>;
def : Pat<(i64 (setune f32:$rz, f32:$ry)), (FCOMPWrr SingleReg:$rz, SingleReg:$ry, FCOMP_UNE)>;
def : Pat<(i64 (setoeq f64:$rz, f64:$ry)), (FCOMPDrr SingleReg:$rz, SingleReg:$ry, FCOMP_OEQ)>;
def : Pat<(i64 (setogt f64:$rz, f64:$ry)), (FCOMPDrr SingleReg:$ry, SingleReg:$rz, FCOMP_OLT)>;
def : Pat<(i64 (setoge f64:$rz, f64:$ry)), (FCOMPDrr SingleReg:$rz, SingleReg:$ry, FCOMP_OGE)>;
def : Pat<(i64 (setolt f64:$rz, f64:$ry)), (FCOMPDrr SingleReg:$rz, SingleReg:$ry, FCOMP_OLT)>;
def : Pat<(i64 (setole f64:$rz, f64:$ry)), (FCOMPDrr SingleReg:$ry, SingleReg:$rz, FCOMP_OGE)>;
def : Pat<(i64 (setone f64:$rz, f64:$ry)), (FCOMPDrr SingleReg:$rz, SingleReg:$ry, FCOMP_ONE)>;
def : Pat<(i64 (seto f64:$rz, f64:$ry)), (ORDd0 (FCOMPDrr SingleReg:$rz, SingleReg:$ry, FCOMP_OEQ), (FCOMPDrr SingleReg:$rz, SingleReg:$ry, FCOMP_ONE))>;
def : Pat<(i64 (setuo f64:$rz, f64:$ry)), (ORDd0 (FCOMPDrr SingleReg:$rz, SingleReg:$ry, FCOMP_UEQ), (FCOMPDrr SingleReg:$rz, SingleReg:$ry, FCOMP_UNE))>;
def : Pat<(i64 (setueq f64:$rz, f64:$ry)), (FCOMPDrr SingleReg:$rz, SingleReg:$ry, FCOMP_UEQ)>;
def : Pat<(i64 (setugt f64:$rz, f64:$ry)), (FCOMPDrr SingleReg:$ry, SingleReg:$rz, FCOMP_ULT)>;
def : Pat<(i64 (setuge f64:$rz, f64:$ry)), (FCOMPDrr SingleReg:$rz, SingleReg:$ry, FCOMP_UGE)>;
def : Pat<(i64 (setult f64:$rz, f64:$ry)), (FCOMPDrr SingleReg:$rz, SingleReg:$ry, FCOMP_ULT)>;
def : Pat<(i64 (setule f64:$rz, f64:$ry)), (FCOMPDrr SingleReg:$ry, SingleReg:$rz, FCOMP_UGE)>;
def : Pat<(i64 (setune f64:$rz, f64:$ry)), (FCOMPDrr SingleReg:$rz, SingleReg:$ry, FCOMP_UNE)>;
// FDOT2
// FFMA
// FFMS
// FINV
// FISR
// FIXED
// FLOAT
// FMAX
// FMIN
// FMM2A
// FMM2S
// FMM2
// FMULC -> TODO
// FMUL
// FMUL*C -> TODO
// FNARROW
def : Pat<(f16 (fpround f32:$val)), (FNARROWWH SingleReg:$val, ROUND_CS, SILENT_OFF)>;
def : Pat<(f16 (fpround f64:$val)), (FNARROWWH (FNARROWDW SingleReg:$val, ROUND_CS, SILENT_OFF), ROUND_CS, SILENT_OFF)>;
def : Pat<(f32 (fpround f64:$val)), (FNARROWDW SingleReg:$val, ROUND_CS, SILENT_OFF)>;
// FNEG
// FSBFC -> TODO
// FSBF
// FSDIV -> TODO
// FSINV
// FSISR
// FWIDEN
def : Pat<(f64 (fpextend f32:$val)), (FWIDENLWD SingleReg:$val, SILENT_OFF)>;
def : Pat<(f64 (fpextend f16:$val)), (FWIDENLWD (FWIDENLHW SingleReg:$val, SILENT_OFF), SILENT_OFF)>;
def : Pat<(f32 (fpextend f16:$val)), (FWIDENLHW SingleReg:$val, SILENT_OFF)>;
