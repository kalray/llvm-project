//===-- K1CPatterns.td - K1C Patterns ----------------------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

def SDTK1CWrapper : SDTypeProfile<1, 1, [SDTCisSameAs<0, 1>, SDTCisPtrTy<0>]>;

def K1CWrapper : SDNode<"K1CISD::Wrapper", SDTK1CWrapper>;

//
// Function return
//

def K1CRetNode : SDNode<"K1CISD::RET", SDTNone,
                       [SDNPHasChain, SDNPOptInGlue, SDNPMayLoad, SDNPVariadic]>;


//let isBarrier = 1, isReturn = 1, isTerminator = 1 in
//def K1CRet : K1C_INSTRUCTION<(outs), (ins), "ret", [(K1CRetNode)], NoItinerary>;

def : Pat<(K1CRetNode),(RET)>;

def : Pat<(Call (K1CWrapper tglobaladdr:$func)),(CALL Pcrel27:$func)>;
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

// MAKE patterns disabled - selection is done in code
/*def : Pat<(Signed16:$imm), (MAKEd0 Signed16:$imm)>;
def : Pat<(Signed43:$imm), (MAKEd1 Signed43:$imm)>;
def : Pat<(Wrapped64:$imm), (MAKEd2 Wrapped64:$imm)>;*/

def : Pat<(K1CWrapper tglobaladdr:$dst), (MAKEd2 tglobaladdr:$dst)>;


// ADD patterns
def : Pat<(add i32:$rs1, i32:$rs2), (ADDWd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(add i64:$rs1, i64:$rs2), (ADDDd0 SingleReg:$rs1, SingleReg:$rs2)>;

def : Pat<(add i32:$rs1, Signed32:$rs2), (ADDWd1 SingleReg:$rs1, Signed32:$rs2)>;

// AND patterns
def : Pat<(and i32:$rs1, Signed32:$rs2), (ANDWd1 SingleReg:$rs1, Signed32:$rs2)>;
def : Pat<(and i64:$rs1, Wrapped64:$rs2), (ANDDd3 SingleReg:$rs1, Wrapped64:$rs2)>;

def MemRR : Operand<iPTR>, ComplexPattern<iPTR, 2, "SelectAddrRR", [], []> {
  let PrintMethod = "printMemOperand";
  let MIOperandInfo = (ops SingleReg:$indexReg, SingleReg:$baseReg);
}

// extracts offsset and register (or frameindex)
def AddrRI : Operand<iPTR>, ComplexPattern<iPTR, 2, "SelectAddrRI", [frameindex], []> {
  let PrintMethod = "printMemOperand";
  let MIOperandInfo = (ops i64imm:$offset, SingleReg:$baseReg );
}

// store instructions with register-immediate addressing mode
def SBri : K1C_INSTRUCTION<(outs), (ins AddrRI:$addr, SingleReg:$val), "sb $addr = $val", [], NoItinerary>;
def SHri : K1C_INSTRUCTION<(outs), (ins AddrRI:$addr, SingleReg:$val), "sh $addr = $val", [], NoItinerary>;
def SWri : K1C_INSTRUCTION<(outs), (ins AddrRI:$addr, SingleReg:$val), "sw $addr = $val", [], NoItinerary>;
def SDri : K1C_INSTRUCTION<(outs), (ins AddrRI:$addr, SingleReg:$val), "sd $addr = $val", [], NoItinerary>;

// load instructions with register-immediate addressing mode
def LBSri : K1C_INSTRUCTION<(outs SingleReg:$out), (ins AddrRI:$addr), "lbs $out = $addr", [], NoItinerary>;
def LBZri : K1C_INSTRUCTION<(outs SingleReg:$out), (ins AddrRI:$addr), "lbz $out = $addr", [], NoItinerary>;
def LHSri : K1C_INSTRUCTION<(outs SingleReg:$out), (ins AddrRI:$addr), "lhs $out = $addr", [], NoItinerary>;
def LHZri : K1C_INSTRUCTION<(outs SingleReg:$out), (ins AddrRI:$addr), "lhz $out = $addr", [], NoItinerary>;
def LWSri : K1C_INSTRUCTION<(outs SingleReg:$out), (ins AddrRI:$addr), "lws $out = $addr", [], NoItinerary>;
def LWZri : K1C_INSTRUCTION<(outs SingleReg:$out), (ins AddrRI:$addr), "lwz $out = $addr", [], NoItinerary>;
def LDri : K1C_INSTRUCTION<(outs SingleReg:$out), (ins AddrRI:$addr), "ld $out = $addr", [], NoItinerary>;

// Store patterns
def : Pat<(store (i8 SingleReg:$val), AddrRI:$addr), (SBri AddrRI:$addr,SingleReg:$val)>;
def : Pat<(store (i16 SingleReg:$val), AddrRI:$addr), (SHri AddrRI:$addr,SingleReg:$val)>;
def : Pat<(store (i32 SingleReg:$val), AddrRI:$addr), (SWri AddrRI:$addr,SingleReg:$val)>;
def : Pat<(store (i64 SingleReg:$val), AddrRI:$addr), (SDri AddrRI:$addr,SingleReg:$val)>;

def : Pat<(truncstorei8 i64:$val, AddrRI:$addr), (SBri AddrRI:$addr, SingleReg:$val)>;
def : Pat<(truncstorei8 i32:$val, AddrRI:$addr), (SBri AddrRI:$addr, SingleReg:$val)>;
def : Pat<(truncstorei16 i64:$val, AddrRI:$addr), (SHri AddrRI:$addr, SingleReg:$val)>;
def : Pat<(truncstorei16 i32:$val, AddrRI:$addr), (SHri AddrRI:$addr, SingleReg:$val)>;

def : Pat<(truncstorei8 (i32 SingleReg:$val), (i64 SingleReg:$base)), (SBd0 (i64 0), SingleReg:$base, SingleReg:$val)>;
def : Pat<(truncstorei16 (i32 SingleReg:$val), (i64 SingleReg:$base)), (SHd0 (i64 0), SingleReg:$base, SingleReg:$val)>;
def : Pat<(truncstorei8 (i64 SingleReg:$val), (i64 SingleReg:$base)), (SBd0 (i64 0), SingleReg:$base, SingleReg:$val)>;
def : Pat<(truncstorei16 (i64 SingleReg:$val), (i64 SingleReg:$base)), (SHd0 (i64 0), SingleReg:$base, SingleReg:$val)>;
def : Pat<(truncstorei32 (i64 SingleReg:$val), (i64 SingleReg:$base)), (SWd0 (i64 0), SingleReg:$base, SingleReg:$val)>;


// Load patterns
def loadi8 : PatFrag<(ops node:$ptr), (i8 (load node:$ptr))>;
def loadi16 : PatFrag<(ops node:$ptr), (i16 (load node:$ptr))>;
def loadi32 : PatFrag<(ops node:$ptr), (i32 (load node:$ptr))>;
def loadi64 : PatFrag<(ops node:$ptr), (i64 (load node:$ptr))>;

// load i8 in i32
def : Pat<(i32 (sextloadi8 AddrRI:$addr)), (LBSri AddrRI:$addr)>;
def : Pat<(i32 (zextloadi8 AddrRI:$addr)), (LBZri AddrRI:$addr)>;
def : Pat<(i32 (extloadi8 AddrRI:$addr)), (LBZri AddrRI:$addr)>;
def : Pat<(i32 (extloadi8 (iPTR SingleReg:$rs2))), (LBZd0 (i64 0), SingleReg:$rs2, (i8 0))>;

// load i16 in i32
def : Pat<(i32 (sextloadi16 AddrRI:$addr)), (LHSri AddrRI:$addr)>;
def : Pat<(i32 (zextloadi16 AddrRI:$addr)), (LHZri AddrRI:$addr)>;
def : Pat<(i32 (extloadi16 AddrRI:$addr)), (LHZri AddrRI:$addr)>;
def : Pat<(i32 (extloadi16 (iPTR SingleReg:$rs2))), (LHZd0 (i64 0), SingleReg:$rs2, (i8 0))>;

// load i8 in i64
def : Pat<(i64 (sextloadi8 AddrRI:$addr)), (LBSri AddrRI:$addr)>;
def : Pat<(i64 (zextloadi8 AddrRI:$addr)), (LBZri AddrRI:$addr)>;
def : Pat<(i64 (extloadi8 AddrRI:$addr)), (LBZri AddrRI:$addr)>;
def : Pat<(i64 (extloadi8 (iPTR SingleReg:$rs2))), (LBZd0 (i64 0), SingleReg:$rs2, (i8 0))>;

// load i16 in i64
def : Pat<(i64 (sextloadi16 AddrRI:$addr)), (LHSri AddrRI:$addr)>;
def : Pat<(i64 (zextloadi16 AddrRI:$addr)), (LHZri AddrRI:$addr)>;
def : Pat<(i64 (extloadi16 AddrRI:$addr)), (LHZri AddrRI:$addr)>;
def : Pat<(i64 (extloadi16 (iPTR SingleReg:$rs2))), (LHZd0 (i64 0), SingleReg:$rs2, (i8 0))>;

// load i32 in i64
def : Pat<(i64 (sextloadi32 AddrRI:$addr)), (LWSri AddrRI:$addr)>;
def : Pat<(i64 (zextloadi32 AddrRI:$addr)), (LWZri AddrRI:$addr)>;
def : Pat<(i64 (extloadi32 AddrRI:$addr)), (LWZri AddrRI:$addr)>;
def : Pat<(i64 (extloadi32 (iPTR SingleReg:$rs2))), (LWZd0 (i64 0), SingleReg:$rs2, (i8 0))>;
def : Pat<(loadi32 (iPTR SingleReg:$rs2)), (LWZd0 (i64 0), SingleReg:$rs2, (i8 0))>;

def : Pat<(loadi8 AddrRI:$addr), (LBZri AddrRI:$addr)>;
def : Pat<(loadi16 AddrRI:$addr), (LHZri AddrRI:$addr)>;
def : Pat<(loadi32 AddrRI:$addr), (LWZri AddrRI:$addr)>;
def : Pat<(loadi64 AddrRI:$addr), (LDri AddrRI:$addr)>;
def : Pat<(loadi64 (iPTR SingleReg:$rs2)), (LDd0 (i64 0), SingleReg:$rs2, (i8 0))>;

// Zero/sign extend patterns
def : Pat<(i64 (anyext i8:$val)), (ZXBD SingleReg:$val)>;
def : Pat<(i64 (anyext i16:$val)), (ZXHD SingleReg:$val)>;
def : Pat<(i64 (anyext i32:$val)), (ZXWD SingleReg:$val)>;
def : Pat<(i64 (zext i8:$val)), (ZXBD SingleReg:$val)>;
def : Pat<(i64 (sext i8:$val)), (SXBD SingleReg:$val)>;
def : Pat<(i64 (zext i16:$val)), (ZXHD SingleReg:$val)>;
def : Pat<(i64 (sext i16:$val)), (SXHD SingleReg:$val)>;
def : Pat<(i64 (zext i32:$val)), (ZXWD SingleReg:$val)>;
def : Pat<(i64 (sext i32:$val)), (SXWD SingleReg:$val)>;

def : Pat<(i32 (sext_inreg i32:$val, i8)), (SXBD SingleReg:$val)>;
def : Pat<(i32 (sext_inreg i32:$val, i16)), (SXHD SingleReg:$val)>;

def : Pat<(i64 (sext_inreg i64:$val, i8)), (SXBD SingleReg:$val)>;
def : Pat<(i64 (sext_inreg i64:$val, i16)), (SXHD SingleReg:$val)>;
def : Pat<(i64 (sext_inreg i64:$val, i32)), (SXWD SingleReg:$val)>;

// Unconditional branch
def : Pat<(br bb:$addr), (GOTO Pcrel27:$addr)>;



// Conditional branches(setcc)
def : Pat<(brcond (i64 (setle (i32 SingleReg:$lhs), i32:$rhs)), bb:$dst),
        (CB (COMPWd1 SingleReg:$lhs, Wrapped32:$rhs, (i8 4/*COMPW.le*/)), Pcrel17:$dst, (i8 8/*CB.wnez*/))>;

def : Pat<(brcond (i64 (setgt (i32 SingleReg:$lhs), i32:$rhs)), bb:$dst),
        (CB (COMPWd1 SingleReg:$lhs, Wrapped32:$rhs, (i8 5/*COMPW.gt*/)), Pcrel17:$dst, (i8 8/*CB.wnez*/))>;

def : Pat<(brcond (i64 (setge (i32 SingleReg:$lhs), i32:$rhs)), bb:$dst),
        (CB (COMPWd1 SingleReg:$lhs, Wrapped32:$rhs, (i8 3/*COMPW.ge*/)), Pcrel17:$dst, (i8 8/*CB.wnez*/))>;

def : Pat<(brcond (i64 (setne (i32 SingleReg:$lhs), i32:$rhs)), bb:$dst),
        (CB (COMPWd1 SingleReg:$lhs, Wrapped32:$rhs, (i8 0/*COMPW.ne*/)), Pcrel17:$dst, (i8 8/*CB.wnez*/))>;

def : Pat<(brcond (i64 (seteq (i32 SingleReg:$lhs), i32:$rhs)), bb:$dst),
        (CB (COMPWd1 SingleReg:$lhs, Wrapped32:$rhs, (i8 1/*COMPW.eq*/)), Pcrel17:$dst, (i8 8/*CB.wnez*/))>;

def : Pat<(brcond (i64 (setlt (i32 SingleReg:$lhs), i32:$rhs)), bb:$dst),
        (CB (COMPWd1 SingleReg:$lhs, Wrapped32:$rhs, (i8 2/*COMPW.lt*/)), Pcrel17:$dst, (i8 8/*CB.wnez*/))>;

def : Pat<(brcond (i64 (setugt (i32 SingleReg:$lhs), i32:$rhs)), bb:$dst),
        (CB (COMPWd1 SingleReg:$lhs, Wrapped32:$rhs, (i8 9/*COMPW.gtu*/)), Pcrel17:$dst, (i8 8/*CB.wnez*/))>;

def : Pat<(brcond (i64 (setuge (i32 SingleReg:$lhs), i32:$rhs)), bb:$dst),
        (CB (COMPWd1 SingleReg:$lhs, Wrapped32:$rhs, (i8 7/*COMPW.geu*/)), Pcrel17:$dst, (i8 8/*CB.wnez*/))>;

def : Pat<(brcond (i64 (setult (i32 SingleReg:$lhs), i32:$rhs)), bb:$dst),
        (CB (COMPWd1 SingleReg:$lhs, Wrapped32:$rhs, (i8 6/*COMPW.ltu*/)), Pcrel17:$dst, (i8 8/*CB.wnez*/))>;

def : Pat<(brcond (i64 (setule (i32 SingleReg:$lhs), i32:$rhs)), bb:$dst),
        (CB (COMPWd1 SingleReg:$lhs, Wrapped32:$rhs, (i8 8/*COMPW.leu*/)), Pcrel17:$dst, (i8 8/*CB.wnez*/))>;





def : Pat<(brcond (i64 (setle (i64 SingleReg:$lhs), i64:$rhs)), bb:$dst),
        (CB (COMPDd2 SingleReg:$lhs, Wrapped64:$rhs, (i8 4/*COMPW.le*/)), Pcrel17:$dst, (i8 8/*CB.wnez*/))>;

def : Pat<(brcond (i64 (setgt (i64 SingleReg:$lhs), i64:$rhs)), bb:$dst),
        (CB (COMPDd2 SingleReg:$lhs, Wrapped64:$rhs, (i8 5/*COMPW.gt*/)), Pcrel17:$dst, (i8 8/*CB.wnez*/))>;

def : Pat<(brcond (i64 (setge (i64 SingleReg:$lhs), i64:$rhs)), bb:$dst),
        (CB (COMPDd2 SingleReg:$lhs, Wrapped64:$rhs, (i8 3/*COMPW.ge*/)), Pcrel17:$dst, (i8 8/*CB.wnez*/))>;

def : Pat<(brcond (i64 (setne (i64 SingleReg:$lhs), i64:$rhs)), bb:$dst),
        (CB (COMPDd2 SingleReg:$lhs, Wrapped64:$rhs, (i8 0/*COMPW.ne*/)), Pcrel17:$dst, (i8 8/*CB.wnez*/))>;

def : Pat<(brcond (i64 (seteq (i64 SingleReg:$lhs), i64:$rhs)), bb:$dst),
        (CB (COMPDd2 SingleReg:$lhs, Wrapped64:$rhs, (i8 1/*COMPW.eq*/)), Pcrel17:$dst, (i8 8/*CB.wnez*/))>;

def : Pat<(brcond (i64 (setlt (i64 SingleReg:$lhs), i64:$rhs)), bb:$dst),
        (CB (COMPDd2 SingleReg:$lhs, Wrapped64:$rhs, (i8 2/*COMPW.lt*/)), Pcrel17:$dst, (i8 8/*CB.wnez*/))>;

def : Pat<(brcond (i64 (setugt (i64 SingleReg:$lhs), i64:$rhs)), bb:$dst),
        (CB (COMPDd2 SingleReg:$lhs, Wrapped64:$rhs, (i8 9/*COMPW.gtu*/)), Pcrel17:$dst, (i8 8/*CB.wnez*/))>;

def : Pat<(brcond (i64 (setuge (i64 SingleReg:$lhs), i64:$rhs)), bb:$dst),
        (CB (COMPDd2 SingleReg:$lhs, Wrapped64:$rhs, (i8 7/*COMPW.geu*/)), Pcrel17:$dst, (i8 8/*CB.wnez*/))>;

def : Pat<(brcond (i64 (setult (i64 SingleReg:$lhs), i64:$rhs)), bb:$dst),
        (CB (COMPDd2 SingleReg:$lhs, Wrapped64:$rhs, (i8 6/*COMPW.ltu*/)), Pcrel17:$dst, (i8 8/*CB.wnez*/))>;

def : Pat<(brcond (i64 (setule (i64 SingleReg:$lhs), i64:$rhs)), bb:$dst),
        (CB (COMPDd2 SingleReg:$lhs, Wrapped64:$rhs, (i8 8/*COMPW.leu*/)), Pcrel17:$dst, (i8 8/*CB.wnez*/))>;
