//===-- K1.td - Describe the RISCV Target Machine ----------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

include "llvm/Target/Target.td"

include "K1RegisterInfo.td"
// include "K1CallingConv.td"
include "K1InstrInfo.td"

def K1InstrInfo : InstrInfo {
}

def K1AsmWriter : AsmWriter {
}

def K1 : Target {
    let InstructionSet = K1InstrInfo;
}

def : Processor<"generic", NoItineraries, []>;