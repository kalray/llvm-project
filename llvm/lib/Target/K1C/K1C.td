//===-- K1C.td - Describe the K1C Target Machine -----------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

include "llvm/Target/Target.td"

include "K1CSchedule.td"
include "K1CRegisterInfo.td"
include "K1CInstrInfo.td"
include "K1CPatterns.td"

class BITCAST
  <ValueType DstVT, ValueType SrcVT, RegisterClass DstRC>
  : Pat<(DstVT (bitconvert (SrcVT DstRC:$src))), (DstVT DstRC:$src)>;

include "K1CArithmetic.td"
include "K1CFloatingPoint.td"
include "K1CCallingConv.td"
include "K1CPICPatterns.td"
include "K1CAtomic.td"
include "K1CIntrinsic.td"

def K1CInstrInfo : InstrInfo {
}

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

def : ProcessorModel<"generic", K1CSchedMachineModel, []>;
