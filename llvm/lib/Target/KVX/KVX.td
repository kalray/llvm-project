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

def FeatureV1 : SubtargetFeature<"v1", "IsV1", "true",
                                 "Enable V1 only instructions">;

def FeatureV2 : SubtargetFeature<"v2", "IsV2", "true",
                                 "Enable V2 only instructions">;


// This is a hack to get an error message as assert does not work
class KVX_Error<string s> {
  dag fail = !dag(ins, []<DAGOperand>, [s]<string>);
}

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

//===----------------------------------------------------------------------===//
// Reusable pattern fragments
//===----------------------------------------------------------------------===//

// Detects both shl and multiply by a constant
class shiftMulPats <int shiftC, ValueType vt> :
PatFrags<(ops node:$v), [(shl $v, (i32 shiftC)), (mul $v, (vt !shl(1, shiftC)))]>;

def vineg : PatFrag<(ops node:$v), (sub immAllZerosV, node:$v)>;
def vineg_ssat : PatFrag<(ops node:$v), (ssubsat immAllZerosV, node:$v)>;
def vfneg : PatFrags<(ops node:$v), [(fsub immAllZerosV, node:$v), (fneg node:$v)]>;

multiclass BITCAST <ValueType DstVT, ValueType SrcVT, RegisterClass RC> {
  def : Pat<(DstVT (bitconvert (SrcVT RC:$src))), (DstVT RC:$src)>;
  def : Pat<(SrcVT (bitconvert (DstVT RC:$src))), (SrcVT RC:$src)>;
}

def allexts : PatFrags<(ops node:$op),
                       [(sext node:$op),
                        (zext node:$op),
                        (anyext node:$op)]>;

def trunc_imm_32 : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(N->getZExtValue() & 0xffffffff, SDLoc(N), MVT::i32);
}]>;

def imm32_to_imm64 : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(N->getSExtValue(), SDLoc(N), MVT::i64);
}]>;

def immu32_to_imm64 : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(N->getZExtValue(), SDLoc(N), MVT::i64);
}]>;

def fpimm_to_i64 : SDNodeXForm<fpimm, [{
  return CurDAG->getTargetConstant(N->getValueAPF().bitcastToAPInt().getSExtValue(), SDLoc(N), MVT::i64);
}]>;

def get_fpimm_16 : SDNodeXForm<fpimm, [{
  return CurDAG->getTargetConstantFP(N->getValueAPF(), SDLoc(N), MVT::f16);
}]>;

def PairedRegLo: OutPatFrag<(ops node:$R), (EXTRACT_SUBREG $R, sub_d0)>;
def PairedRegHi: OutPatFrag<(ops node:$R), (EXTRACT_SUBREG $R, sub_d1)>;
def BuildPairedReg: OutPatFrag<(ops node:$hi, node:$lo), (REG_SEQUENCE PairedReg, node:$hi, sub_d1, node:$lo, sub_d0)>;

class PairedRegRepl<Instruction I>: OutPatFrag<(ops node:$lhs, node:$rhs),
            (REG_SEQUENCE PairedReg,
              (I (i64 (EXTRACT_SUBREG node:$lhs, sub_d1)),
                 (i64 (EXTRACT_SUBREG node:$rhs, sub_d1))), sub_d1,
              (I (i64 (EXTRACT_SUBREG node:$lhs, sub_d0)),
                 (i64 (EXTRACT_SUBREG node:$rhs, sub_d0))), sub_d0)>;

def KVXInstrInfo : InstrInfo;
include "KVXConstants.td"
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

def : ProcessorModel<"kv3-1", KVXCV1SchedMachineModel, [FeatureV1]>;
def : ProcessorModel<"kv3-2", KVXCV2SchedMachineModel, [FeatureV2]>;
def : ProcessorModel<"kv4-1", KVXCV2SchedMachineModel, [FeatureV2]>;
