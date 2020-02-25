//===-- K1C.td - Describe the K1C Target Machine -----------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

include "llvm/Target/Target.td"

//===----------------------------------------------------------------------===//
//  Register Descriptions
//===----------------------------------------------------------------------===//

include "K1CRegisterInfo.td"

//===----------------------------------------------------------------------===//
//  Hardware Descriptions
//===----------------------------------------------------------------------===//

include "K1CSchedule.td"

//===----------------------------------------------------------------------===//
//  Instruction Descriptions
//===----------------------------------------------------------------------===//

class BRANCHCOND<int N> : PatLeaf<(i32 N)>;
def BRANCHCOND_DNEZ : BRANCHCOND<0>;
def BRANCHCOND_DEQZ : BRANCHCOND<1>;
def BRANCHCOND_DLTZ : BRANCHCOND<2>;
def BRANCHCOND_DGEZ : BRANCHCOND<3>;
def BRANCHCOND_DLEZ : BRANCHCOND<4>;
def BRANCHCOND_DGTZ : BRANCHCOND<5>;
def BRANCHCOND_ODD  : BRANCHCOND<6>;
def BRANCHCOND_EVEN : BRANCHCOND<7>;
def BRANCHCOND_WNEZ : BRANCHCOND<8>;
def BRANCHCOND_WEQZ : BRANCHCOND<9>;
def BRANCHCOND_WLTZ : BRANCHCOND<10>;
def BRANCHCOND_WGEZ : BRANCHCOND<11>;
def BRANCHCOND_WLEZ : BRANCHCOND<12>;
def BRANCHCOND_WGTZ : BRANCHCOND<13>;

class COMPARISON<int N> : PatLeaf<(i32 N)>;
def COMPARISON_NE   : COMPARISON<0>;
def COMPARISON_EQ   : COMPARISON<1>;
def COMPARISON_LT   : COMPARISON<2>;
def COMPARISON_GE   : COMPARISON<3>;
def COMPARISON_LE   : COMPARISON<4>;
def COMPARISON_GT   : COMPARISON<5>;
def COMPARISON_LTU  : COMPARISON<6>;
def COMPARISON_GEU  : COMPARISON<7>;
def COMPARISON_LEU  : COMPARISON<8>;
def COMPARISON_GTU  : COMPARISON<9>;
def COMPARISON_ALL  : COMPARISON<10>;
def COMPARISON_NALL : COMPARISON<11>;
def COMPARISON_ANY  : COMPARISON<12>;
def COMPARISON_NONE : COMPARISON<13>;

def immZero : PatFrags<(ops), [(bitconvert (i32 0)), (bitconvert (i64 0))]>;
def immOnes : PatFrags<(ops), [(bitconvert (i32 -1)), (bitconvert (i64 -1))]>;
def vineg : PatFrag<(ops node:$v), (sub immZero, node:$v)>;
def vfneg : PatFrag<(ops node:$v), (fsub immZero, node:$v)>;
def vinot : PatFrag<(ops node:$v), (xor node:$v, immOnes)>;

class BITCAST
  <ValueType DstVT, ValueType SrcVT, RegisterClass DstRC>
  : Pat<(DstVT (bitconvert (SrcVT DstRC:$src))), (DstVT DstRC:$src)>;

def K1CInstrInfo : InstrInfo;

include "K1CInstrInfo.td"
include "K1CPatterns.td"
include "K1CArithmetic.td"
include "K1CFloatingPoint.td"
include "K1CPICPatterns.td"
include "K1CAtomic.td"
include "K1CIntrinsic.td"

//===----------------------------------------------------------------------===//
//  Calling Conventions
//===----------------------------------------------------------------------===//

include "K1CCallingConv.td"

//===----------------------------------------------------------------------===//
//  Assembly Printers
//===----------------------------------------------------------------------===//

def K1CAsmParser : AsmParser {
  let ShouldEmitMatchRegisterAltName = 1;
}

def K1CAsmWriter : AsmWriter {
}

def K1C : Target {
    let InstructionSet = K1CInstrInfo;

    let AssemblyParsers = [K1CAsmParser];
    let AssemblyWriters = [K1CAsmWriter];
}

//===----------------------------------------------------------------------===//
//  Processors Supported
//===----------------------------------------------------------------------===//

def : ProcessorModel<"k1c", K1CSchedMachineModel, []>;
