//===-- K1C.td - Describe the K1C Target Machine -----------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

include "llvm/Target/Target.td"

include "K1CRegisterInfo.td"
include "K1CInstrInfo.td"
include "K1CPatterns.td"
include "K1CArithmetic.td"
include "K1CFloatingPoint.td"
include "K1CCallingConv.td"
include "K1CPICPatterns.td"

def K1CInstrInfo : InstrInfo {
}

def K1CAsmWriter : AsmWriter {
    int PassSubtarget = 1;
}

def K1C : Target {
    let InstructionSet = K1CInstrInfo;
}

def : Processor<"generic", NoItineraries, []>;
