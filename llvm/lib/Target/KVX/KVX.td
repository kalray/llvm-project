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
// Subtarget features.
//===----------------------------------------------------------------------===//

def FeatureFPIMM : SubtargetFeature<"fpimm", "HasFPIMM", "true",
                                    "Enable FPU immediate-capable instructions">;

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

def vineg : PatFrag<(ops node:$v), (sub immAllZerosV, node:$v)>;
def vfneg : PatFrag<(ops node:$v), (fsub immAllZerosV, node:$v)>;

multiclass BITCAST <ValueType DstVT, ValueType SrcVT, RegisterClass RC> {
  def : Pat<(DstVT (bitconvert (SrcVT RC:$src))), (DstVT RC:$src)>;
  def : Pat<(SrcVT (bitconvert (DstVT RC:$src))), (SrcVT RC:$src)>;
}


def trunc_imm_32 : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(N->getZExtValue() & 0xffffffff, SDLoc(N), MVT::i32);
}]>;


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

def : ProcessorModel<"kv3-1", KVXSchedMachineModel, [FeatureFPIMM]>;
def : ProcessorModel<"kv3-2", KVXSchedMachineModel, []>;
