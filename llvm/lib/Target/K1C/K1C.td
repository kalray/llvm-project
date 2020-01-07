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

def immZero : PatFrags<(ops), [(bitconvert (i32 0)), (bitconvert (i64 0))]>;
def vineg : PatFrag<(ops node:$v), (sub immZero, node:$v)>;
def vfneg : PatFrag<(ops node:$v), (fsub immZero, node:$v)>;

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

def : ProcessorModel<"generic", K1CSchedMachineModel, []>;
