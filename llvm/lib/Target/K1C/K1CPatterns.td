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

//let isBarrier = 1, isReturn = 1, isTerminator = 1 in
//def K1CRet : K1C_INSTRUCTION<(outs), (ins), "ret", [(K1CRetNode)], NoItinerary>;

def : Pat<(K1CRetNode),(RET)>;

def : Pat<(Call tglobaladdr:$func),(CALL Pcrel27:$func)>;
def : Pat<(Call texternalsym:$func),(CALL Pcrel27:$func)>;

def Bundle : K1C_INSTRUCTION<(outs), (ins), ";;", [], NoItinerary>;

/*let isBarrier = 1, isReturn = 1, isTerminator = 1 in
def PseudoRET : K1C_PseudoInstr<(outs), (ins), "ret", [(K1CRetNode)]>,
PseudoInstExpansion<(K1CRet)>;*/

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

// WARNING. This is a workaround to support full i32.
// Correctly it should be split in two cases to use MAKEd0 16bit, MAKEd1 for more than 16bit
def : Pat<(i32 Signed32:$Signed16),
    (MAKEd0 Signed16:$Signed16)>;

def : Pat<(i64 Signed43:$Signed43),
    (MAKEd1 Signed43:$Signed43)>;

def : Pat<(i64 Wrapped64:$Wrapped64),
    (MAKEd2 Wrapped64:$Wrapped64)>;

def AddrFI : ComplexPattern<iPTR, 1, "SelectAddrFI", [frameindex], []>;

/*def : Pat<(store (i16 SingleReg:$rs1), AddrFI:$rs2),
    (SHd0 Signed10:$rs2, (i64 R12), SingleReg:$rs1)>;

def : Pat<(store (i64 SingleReg:$rs1), AddrFI:$rs2),
    (SHd1 Signed37:$rs2, (i64 R12), SingleReg:$rs1)>;

def : Pat<(store (i64 SingleReg:$rs1), AddrFI:$rs2),
    (SHd2 Wrapped64:$rs2, (i64 R12), SingleReg:$rs1)>;*/

// disabled for now , matching is done by K1CSW, K1CSD instruction patterns

def : Pat<(store (i32 SingleReg:$rs1), AddrFI:$frameindex),
    (SWd0 Signed10:$frameindex, (i64 R12), SingleReg:$rs1)>;

def : Pat<(store (i64 SingleReg:$rs1), AddrFI:$frameindex),
    (SDd0 Signed10:$frameindex, (i64 R12), SingleReg:$rs1)>;

def : Pat<(store (i64 SingleReg:$rs1), AddrFI:$rs2),
    (SDd1 Signed37:$rs2, (i64 R12), SingleReg:$rs1)>;

def : Pat<(store (i64 SingleReg:$rs1), AddrFI:$rs2),
    (SDd2 Wrapped64:$rs2, (i64 R12), SingleReg:$rs1)>;

def : Pat<(store (i32 SingleReg:$rs1), iPTR:$rs2),
    (SWd0 (i32 0), SingleReg:$rs2, SingleReg:$rs1)>;

/*def : Pat<(store (i64 SingleReg:$rs1), (i64 SingleReg:$rs2)),
    (SDd3 SingleReg:$rs1, (i64 R12), SingleReg:$rs2, (i8 0))>;*/

def : Pat<(add i32:$rs1, i32:$rs2),
    (ADDWd0 SingleReg:$rs1, SingleReg:$rs2)>;

def : Pat<(add i64:$rs1, i64:$rs2),
    (ADDDd0 SingleReg:$rs1, SingleReg:$rs2)>;

def : Pat<(truncstorei8 i32:$rs1, AddrFI:$rs2),
    (SBd0 Signed10:$rs2, (i64 R12), SingleReg:$rs1)>;

def : Pat<(truncstorei16 i32:$rs1, AddrFI:$rs2),
    (SHd0 Signed10:$rs2, (i64 R12), SingleReg:$rs1)>;

/*def : Pat<(add i64:$rs1, i64:$rs2),
    (ADDDd0 SingleReg:$rs1, SingleReg:$rs2)>;*/

def loadi8 : PatFrag<(ops node:$ptr), (i8 (load node:$ptr))>;
def loadi16 : PatFrag<(ops node:$ptr), (i16 (load node:$ptr))>;
def loadi32 : PatFrag<(ops node:$ptr), (i32 (load node:$ptr))>;
def loadi64 : PatFrag<(ops node:$ptr), (i64 (load node:$ptr))>;

def : Pat<(i32 (sextloadi8 AddrFI:$rs2)), (LBZd0 Signed10:$rs2, (i64 R12), (i8 0))>;
def : Pat<(i32 (sextloadi16 AddrFI:$rs2)), (LHZd0 Signed10:$rs2, (i64 R12), (i8 0))>;
def : Pat<(i64 (sextloadi8 AddrFI:$rs2)), (LBZd0 Signed10:$rs2, (i64 R12), (i8 0))>;
def : Pat<(i64 (sextloadi16 AddrFI:$rs2)), (LHZd0 Signed10:$rs2, (i64 R12), (i8 0))>;
def : Pat<(i64 (sextloadi32 AddrFI:$rs2)), (LWZd0 Signed10:$rs2, (i64 R12), (i8 0))>;

def : Pat<(loadi8 (iPTR AddrFI:$rs2)),
    (LBZd0 Signed10:$rs2, (i64 R12), (i8 0))>;

def : Pat<(loadi16 (iPTR AddrFI:$rs2)),
    (LHZd0 Signed10:$rs2, (i64 R12), (i8 0))>;

def : Pat<(loadi32 (iPTR AddrFI:$rs2)),
    (LWZd0 Signed10:$rs2, (i64 R12), (i8 0))>;

def : Pat<(loadi32 (iPTR AddrFI:$rs2)),
    (LWZd0 Signed10:$rs2, (i64 R12), (i8 0))>;

def : Pat<(loadi64 (iPTR AddrFI:$rs2)),
    (LDd0 Signed10:$rs2, (i64 R12), (i8 0))>;

//def : Pat<(i32 (sext_inreg i32:$val, i16)), (SXHD SingleReg:$val)>;

def : Pat<(i64 (anyext i32:$val)), (SXWD SingleReg:$val)>;
def : Pat<(i64 (zext i16:$val)), (ZXHD SingleReg:$val)>;
def : Pat<(i64 (sext i16:$val)), (SXHD SingleReg:$val)>;
def : Pat<(i64 (sext_inreg i64:$val, i8)), (SXBD SingleReg:$val)>;
def : Pat<(i64 (sext_inreg i64:$val, i16)), (SXHD SingleReg:$val)>;

def : Pat<(i64 (zext i32:$val)), (ZXWD SingleReg:$val)>;
def : Pat<(i64 (sext i32:$val)), (SXWD SingleReg:$val)>;

def ADDRrr : ComplexPattern<iPTR, 2, "SelectAddrRR", [], []>;
def ADDRri : ComplexPattern<iPTR, 2, "SelectAddrRI", [frameindex], []>;

def MemRR : Operand<iPTR> {
  let PrintMethod = "printMemOperand";
  let MIOperandInfo = (ops SingleReg:$addressReg, SingleReg:$indexReg);
}

def MemRI : Operand<iPTR> {
  let PrintMethod = "printMemOperand";
  let MIOperandInfo = (ops SingleReg:$addressReg, i32imm:$offset);
}

// def K1CSW : K1C_INSTRUCTION<(outs), (ins MemRI:$addr, SingleReg:$val), "sw $addr = $val", [(store i32:$val,ADDRri:$addr)], NoItinerary>;
def K1CSD : K1C_INSTRUCTION<(outs), (ins MemRI:$addr, SingleReg:$val), "sd $addr = $val", [(store i64:$val,ADDRri:$addr)], NoItinerary>;

//def : Pat<(store ADDRri:$addr, SingleReg:$value),
//    (K1CSD MemRI:$addr, SingleReg:$value)>;
