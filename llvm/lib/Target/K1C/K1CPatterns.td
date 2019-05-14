//===-- K1CPatterns.td - K1C Patterns ----------------------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//
// Function return
//

def K1CRetNode : SDNode<"K1CISD::RET", SDTNone,
                       [SDNPHasChain, SDNPOptInGlue, SDNPMayLoad, SDNPVariadic]>;

def K1CRet : K1C_INSTRUCTION<(outs), (ins), "ret", [(K1CRetNode)], NoItinerary>;

def Bundle : K1C_INSTRUCTION<(outs), (ins), ";;", [], NoItinerary>;
//
// Call frame magic
//

// These are target-independent nodes, but have target-specific formats.
def SDT_SimpleCallSeqStart : SDCallSeqStart<[ SDTCisVT<0, i32>, SDTCisVT<1, i32> ]>;
def SDT_SimpleCallSeqEnd   : SDCallSeqEnd<[ SDTCisVT<0, i32>, SDTCisVT<1, i32> ]>;

def callseq_start : SDNode<"ISD::CALLSEQ_START", SDT_SimpleCallSeqStart,
                           [SDNPHasChain, SDNPOutGlue]>;
def callseq_end   : SDNode<"ISD::CALLSEQ_END",   SDT_SimpleCallSeqEnd,
                           [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue]>;

def ADJCALLSTACKDOWN : K1C_PseudoInstr<(outs), (ins i32imm:$amt, i32imm:$amt2),
                               "ADJCALLSTACKDOWN $amt",
                               [(callseq_start timm:$amt, timm:$amt2)]>;
def ADJCALLSTACKUP : K1C_PseudoInstr<(outs), (ins i32imm:$amt1, i32imm:$amt2),
                            "ADJCALLSTACKUP $amt1",
                            [(callseq_end timm:$amt1, timm:$amt2)]>;
