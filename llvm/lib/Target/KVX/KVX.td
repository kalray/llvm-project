//===-- KVX.td - Describe the KVX Target Machine -----------*- tablegen -*-===//
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

include "KVXRegisterInfo.td"

//===----------------------------------------------------------------------===//
//  Hardware Descriptions
//===----------------------------------------------------------------------===//

include "KVXSchedule.td"

//===----------------------------------------------------------------------===//
//  Instruction Descriptions
//===----------------------------------------------------------------------===//

include "KVXModifierInfo.td"

def immZero : PatFrags<(ops), [(bitconvert (i32 0)), (bitconvert (i64 0))]>;
def immOnes : PatFrags<(ops), [(bitconvert (i32 -1)), (bitconvert (i64 -1))]>;
def vineg : PatFrag<(ops node:$v), (sub immZero, node:$v)>;
def vfneg : PatFrag<(ops node:$v), (fsub immZero, node:$v)>;
def vinot : PatFrag<(ops node:$v), (xor node:$v, immOnes)>;

class BITCAST
  <ValueType DstVT, ValueType SrcVT, RegisterClass DstRC>
  : Pat<(DstVT (bitconvert (SrcVT DstRC:$src))), (DstVT DstRC:$src)>;

def KVXInstrInfo : InstrInfo;

include "KVXInstrInfo.td"
include "KVXInstrInfoMan.td"
include "KVXPatterns.td"
include "KVXPatternsIntegerArithmetic.td"
include "KVXPatternsFloatingPoint.td"
include "KVXPatternsPIC.td"
include "KVXPatternsAtomic.td"
include "KVXPatternsIntrinsics.td"

//===----------------------------------------------------------------------===//
//  Calling Conventions
//===----------------------------------------------------------------------===//

include "KVXCallingConv.td"

//===----------------------------------------------------------------------===//
//  Assembly Printers
//===----------------------------------------------------------------------===//

def KVXAsmParser : AsmParser {
  let ShouldEmitMatchRegisterAltName = 1;
}

def KVXAsmWriter : AsmWriter {
}

def KVX : Target {
    let InstructionSet = KVXInstrInfo;

    let AssemblyParsers = [KVXAsmParser];
    let AssemblyWriters = [KVXAsmWriter];
}

//===----------------------------------------------------------------------===//
//  Processors Supported
//===----------------------------------------------------------------------===//

def : ProcessorModel<"kv3", KVXSchedMachineModel, []>;
