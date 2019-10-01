//===-- K1CPatterns.td - K1C Patterns ----------------------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

def SDTK1CWrapper : SDTypeProfile<1, 1, [SDTCisSameAs<0, 1>, SDTCisPtrTy<0>]>;

def K1CWrapper : SDNode<"K1CISD::WRAPPER", SDTK1CWrapper>;

def SDT_K1CSelectCC : SDTypeProfile<1, 4, [SDTCisVT<0, i32>, SDTCisVT<1, i64>, SDTCisVT<2, i64>]>;

def SelectCC : SDNode<"K1CISD::SELECT_CC", SDT_K1CSelectCC, []>;

def SDT_K1CTruncate : SDTypeProfile<1, 1, [SDTCisVT<0, i32>]>;

def Truncate : SDNode<"K1CISD::TRUNCATE", SDT_K1CTruncate, []>;

//
// Function return
//

def K1CRetNode : SDNode<"K1CISD::RET", SDTNone,
                       [SDNPHasChain, SDNPOptInGlue, SDNPMayLoad, SDNPVariadic]>;

def : Pat<(K1CRetNode),(RET)>;

def : Pat<(Call (K1CWrapper tglobaladdr:$func)),(CALL Pcrel27:$func)>;
def : Pat<(Call texternalsym:$func),(CALL Pcrel27:$func)>;
def : Pat<(Call SingleReg:$func),(ICALL SingleReg:$func)>;

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

let Defs = [R12], Uses = [R12] in {
def ADJCALLSTACKDOWN : K1C_PseudoInstr<(outs), (ins i32imm:$amt, i32imm:$amt2),
                               [(callseq_start timm:$amt, timm:$amt2)], "ADJCALLSTACKDOWN $amt">;
def ADJCALLSTACKUP : K1C_PseudoInstr<(outs), (ins i32imm:$amt1, i32imm:$amt2),
                            [(callseq_end timm:$amt1, timm:$amt2)], "ADJCALLSTACKUP $amt1">;
} // Defs = [R12], Uses = [R12]

def MAKETLS : REGISTERW_EXTEND27_UPPER27_LOWER10_TRIPLE
  <(outs SingleReg:$SingleReg), (ins Wrapped64:$Wrapped64),
  "make $SingleReg = @tlsle($Wrapped64)",
  [],
  ALU_TINY_Y>;

// MAKE patterns disabled - selection is done in code
/*
def : Pat<(Signed16:$imm), (MAKEd0 Signed16:$imm)>;
def : Pat<(Signed43:$imm), (MAKEd1 Signed43:$imm)>;
def : Pat<(Wrapped64:$imm), (MAKEd2 Wrapped64:$imm)>;
*/
def : Pat<(K1CWrapper tglobaladdr:$dst), (MAKEd2 tglobaladdr:$dst)>;
def : Pat<(K1CWrapper tglobaltlsaddr:$dst), (MAKETLS tglobaltlsaddr:$dst)>;

def MemRR : Operand<iPTR>, ComplexPattern<iPTR, 2, "SelectAddrRR", [], []> {
  let PrintMethod = "printMemOperand";
  let MIOperandInfo = (ops SingleReg:$indexReg, SingleReg:$baseReg);
}

def AddrFI : ComplexPattern<iPTR, 1, "SelectAddrFI", [frameindex], []>;

// extracts offsset and register (or frameindex)
def AddrRI : Operand<iPTR>, ComplexPattern<iPTR, 2, "SelectAddrRI", [frameindex], []> {
  let PrintMethod = "printMemOperand";
  let MIOperandInfo = (ops i64imm:$offset, SingleReg:$baseReg );
}

// FIXME: for now it's selected the wider itinerary (LSU_AUXR_Y), because
// the right one can't be determined (LSU_AUXR, LSU_AUXR_X, LSU_AUXR_Y)
// store instructions with register-immediate addressing mode
def SBri : K1C_INSTRUCTION<(outs), (ins AddrRI:$addr, SingleReg:$val), "sb $addr = $val", [], LSU_AUXR_Y>;
def SHri : K1C_INSTRUCTION<(outs), (ins AddrRI:$addr, SingleReg:$val), "sh $addr = $val", [], LSU_AUXR_Y>;
def SWri : K1C_INSTRUCTION<(outs), (ins AddrRI:$addr, SingleReg:$val), "sw $addr = $val", [], LSU_AUXR_Y>;
def SDri : K1C_INSTRUCTION<(outs), (ins AddrRI:$addr, SingleReg:$val), "sd $addr = $val", [], LSU_AUXR_Y>;

// FIXME: for now it's selected the wider itinerary (LSU_AUXW_Y), because
// the right one can't be determined (LSU_AUXW, LSU_AUXW_X, LSU_AUXW_Y)
// load instructions with register-immediate addressing mode
def LBSri : K1C_INSTRUCTION<(outs SingleReg:$out), (ins AddrRI:$addr), "lbs $out = $addr", [], LSU_AUXW_Y>;
def LBZri : K1C_INSTRUCTION<(outs SingleReg:$out), (ins AddrRI:$addr), "lbz $out = $addr", [], LSU_AUXW_Y>;
def LHSri : K1C_INSTRUCTION<(outs SingleReg:$out), (ins AddrRI:$addr), "lhs $out = $addr", [], LSU_AUXW_Y>;
def LHZri : K1C_INSTRUCTION<(outs SingleReg:$out), (ins AddrRI:$addr), "lhz $out = $addr", [], LSU_AUXW_Y>;
def LWSri : K1C_INSTRUCTION<(outs SingleReg:$out), (ins AddrRI:$addr), "lws $out = $addr", [], LSU_AUXW_Y>;
def LWZri : K1C_INSTRUCTION<(outs SingleReg:$out), (ins AddrRI:$addr), "lwz $out = $addr", [], LSU_AUXW_Y>;
def LDri : K1C_INSTRUCTION<(outs SingleReg:$out), (ins AddrRI:$addr), "ld $out = $addr", [], LSU_AUXW_Y>;

// Store patterns
def : Pat<(store (i8 SingleReg:$val), AddrRI:$addr), (SBri AddrRI:$addr,SingleReg:$val)>;
def : Pat<(store (i16 SingleReg:$val), AddrRI:$addr), (SHri AddrRI:$addr,SingleReg:$val)>;
def : Pat<(store (i32 SingleReg:$val), AddrRI:$addr), (SWri AddrRI:$addr,SingleReg:$val)>;
def : Pat<(store (i64 SingleReg:$val), AddrRI:$addr), (SDri AddrRI:$addr,SingleReg:$val)>;
def : Pat<(store (v4i16 SingleReg:$val), AddrRI:$addr), (SDri AddrRI:$addr,SingleReg:$val)>;
def : Pat<(store (v2i32 SingleReg:$val), AddrRI:$addr), (SDri AddrRI:$addr,SingleReg:$val)>;

def : Pat<(truncstorei8 i64:$val, AddrRI:$addr), (SBri AddrRI:$addr, SingleReg:$val)>;
def : Pat<(truncstorei8 i32:$val, AddrRI:$addr), (SBri AddrRI:$addr, SingleReg:$val)>;
def : Pat<(truncstorei16 i64:$val, AddrRI:$addr), (SHri AddrRI:$addr, SingleReg:$val)>;
def : Pat<(truncstorei16 i32:$val, AddrRI:$addr), (SHri AddrRI:$addr, SingleReg:$val)>;
def : Pat<(truncstorei32 i64:$val, AddrRI:$addr), (SWri AddrRI:$addr, SingleReg:$val)>;

def : Pat<(truncstorei8 (i32 SingleReg:$val), (i64 SingleReg:$base)), (SBd0 (i64 0), SingleReg:$base, SingleReg:$val)>;
def : Pat<(truncstorei16 (i32 SingleReg:$val), (i64 SingleReg:$base)), (SHd0 (i64 0), SingleReg:$base, SingleReg:$val)>;
def : Pat<(truncstorei8 (i64 SingleReg:$val), (i64 SingleReg:$base)), (SBd0 (i64 0), SingleReg:$base, SingleReg:$val)>;
def : Pat<(truncstorei16 (i64 SingleReg:$val), (i64 SingleReg:$base)), (SHd0 (i64 0), SingleReg:$base, SingleReg:$val)>;
def : Pat<(truncstorei32 (i64 SingleReg:$val), (i64 SingleReg:$base)), (SWd0 (i64 0), SingleReg:$base, SingleReg:$val)>;


// Load patterns
def loadi1 : PatFrag<(ops node:$ptr), (i1 (load node:$ptr))>;
def loadi8 : PatFrag<(ops node:$ptr), (i8 (load node:$ptr))>;
def loadi16 : PatFrag<(ops node:$ptr), (i16 (load node:$ptr))>;
def loadi32 : PatFrag<(ops node:$ptr), (i32 (load node:$ptr))>;
def loadi64 : PatFrag<(ops node:$ptr), (i64 (load node:$ptr))>;
def loadv4i16 : PatFrag<(ops node:$ptr), (v4i16 (load node:$ptr))>;
def loadv2i32 : PatFrag<(ops node:$ptr), (v2i32 (load node:$ptr))>;

// load i1 in i32
def : Pat<(i32 (sextloadi1 AddrRI:$addr)), (LBSri AddrRI:$addr)>;
def : Pat<(i32 (zextloadi1 AddrRI:$addr)), (LBZri AddrRI:$addr)>;
def : Pat<(i32 (extloadi1 AddrRI:$addr)), (LBZri AddrRI:$addr)>;
def : Pat<(i32 (extloadi1 (iPTR SingleReg:$rs2))), (LBZd0 (i64 0), SingleReg:$rs2, (i8 0))>;

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

// load i1 in i64
def : Pat<(i64 (sextloadi1 AddrRI:$addr)), (LBSri AddrRI:$addr)>;
def : Pat<(i64 (zextloadi1 AddrRI:$addr)), (LBZri AddrRI:$addr)>;
def : Pat<(i64 (extloadi1 AddrRI:$addr)), (LBZri AddrRI:$addr)>;
def : Pat<(i64 (extloadi1 (iPTR SingleReg:$rs2))), (LBZd0 (i64 0), SingleReg:$rs2, (i8 0))>;

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

def : Pat<(loadi1 AddrRI:$addr), (LBZri AddrRI:$addr)>;
def : Pat<(loadi8 AddrRI:$addr), (LBZri AddrRI:$addr)>;
def : Pat<(loadi16 AddrRI:$addr), (LHZri AddrRI:$addr)>;
def : Pat<(loadi32 AddrRI:$addr), (LWZri AddrRI:$addr)>;
def : Pat<(loadi64 AddrRI:$addr), (LDri AddrRI:$addr)>;
def : Pat<(loadv4i16 AddrRI:$addr), (LDri AddrRI:$addr)>;
def : Pat<(loadv2i32 AddrRI:$addr), (LDri AddrRI:$addr)>;
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
def : Pat<(brcond i32:$cond, bb:$dst), (CB SingleReg:$cond, Pcrel17:$dst, (i8 8/*CB.wnez*/))>;
def : Pat<(brcond i64:$cond, bb:$dst), (CB SingleReg:$cond, Pcrel17:$dst, (i8 8/*CB.wnez*/))>;

def : Pat<(i64 AddrFI:$fi), (ADDDd3 SingleReg:$fi,(i64 0) )>;

def : Pat<(brind (i32 SingleReg:$r)), (IGOTO SingleReg:$r)>;

def : Pat<(brind (i64 SingleReg:$r)), (IGOTO SingleReg:$r)>;

def Select_Instr : K1C_PseudoInstr<(outs SingleReg:$dst),
        (ins SingleReg:$cmp, SingleReg:$tmpVar, SingleReg:$truev, SingleReg:$falsev),[]>;

def : Pat<(SelectCC i64:$cmp, i64:$zero, i32:$truev, i32:$falsev),
        (Select_Instr SingleReg:$cmp, $zero, i32imm:$truev, i32imm:$falsev)>;

def : Pat<(SelectCC i64:$cmp, i64:$zero, i64:$truev, i64:$falsev),
        (Select_Instr SingleReg:$cmp, $zero, SingleReg:$truev, SingleReg:$falsev)>;

def : Pat<(SelectCC i64:$cmp, i64:$zero, (K1CWrapper tglobaladdr:$truef), (K1CWrapper tglobaladdr:$falsef)),
        (Select_Instr SingleReg:$cmp, $zero, SingleReg:$truef, SingleReg:$falsef)>;

def Truncate_Instr : K1C_PseudoInstr<(outs SingleReg:$dst), (ins SingleReg:$param),[]>;

def : Pat<(Truncate i32:$param), (Truncate_Instr SingleReg:$param)>;
def : Pat<(Truncate i64:$param), (Truncate_Instr SingleReg:$param)>;

def : Pat<(cttz i32:$src), (CTZW SingleReg:$src)>;
def : Pat<(cttz i64:$src), (CTZD SingleReg:$src)>;

def : Pat<(ctlz i32:$src), (CLZW SingleReg:$src)>;
def : Pat<(ctlz i64:$src), (CLZD SingleReg:$src)>;

def : Pat<(v4i16 (build_vector i32:$v1, i32:$v2, i32:$v3, i32:$v4)),
        (ORDd0
                (ORDd0 (SLLDd1 SingleReg:$v1, (i64 48)), (SLLDd1 SingleReg:$v2, (i64 32))),
                (ORDd0 (SLLDd1 SingleReg:$v3, (i64 16)), SingleReg:$v4)
        )>;

def : Pat<(v2i32 (build_vector i32:$v1, i32:$v2)),
        (ORDd0
                (SLLDd1 SingleReg:$v2, (i64 32)),
                SingleReg:$v1
        )>;
