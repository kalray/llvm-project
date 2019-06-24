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
// FADDC
// FADD, see K1CInstrInfo.td for immediate patterns
def : Pat<(fadd f16:$rs1, f16:$rs2), (FADDHQrr SingleReg:$rs1, SingleReg:$rs2, ROUND_CS, SILENT_OFF)>;
def : Pat<(fadd f32:$rs1, f32:$rs2), (FADDWrr SingleReg:$rs1, SingleReg:$rs2, ROUND_CS, SILENT_OFF)>;
def : Pat<(fadd f64:$rs1, f64:$rs2), (FADDDrr SingleReg:$rs1, SingleReg:$rs2, ROUND_CS, SILENT_OFF)>;
// FCDIV
// FCOMP
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
// FMULC
// FMUL
// FNARROW
def : Pat<(f16 (fpround f32:$val)), (FNARROWWH SingleReg:$val, ROUND_CS, SILENT_OFF)>;
def : Pat<(f16 (fpround f64:$val)), (FNARROWWH (FNARROWDW SingleReg:$val, ROUND_CS, SILENT_OFF), ROUND_CS, SILENT_OFF)>;
def : Pat<(f32 (fpround f64:$val)), (FNARROWDW SingleReg:$val, ROUND_CS, SILENT_OFF)>;
// FNEG
// FSBFC
// FSBF
// FSDIV
// FSINV
// FSISR
// FWIDEN
def : Pat<(f64 (fpextend f32:$val)), (FWIDENLWD SingleReg:$val, SILENT_OFF)>;
def : Pat<(f64 (fpextend f16:$val)), (FWIDENLWD (FWIDENLHW SingleReg:$val, SILENT_OFF), SILENT_OFF)>;
def : Pat<(f32 (fpextend f16:$val)), (FWIDENLHW SingleReg:$val, SILENT_OFF)>;
