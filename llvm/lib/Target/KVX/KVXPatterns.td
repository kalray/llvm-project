//===-- KVXPatterns.td - KVX Patterns ----------------------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//


//===----------------------------------------------------------------------===//
// Custom selection DAG type profile definitions.
//===----------------------------------------------------------------------===//

def SDTKVXBRCond : SDTypeProfile<0, 3,
      [SDTCisInt<0>, SDTCisVT<1, iPTR>, SDTCisVT<2, i32>]>;
def SDTKVXComp : SDTypeProfile<1, 3,
      [SDTCisInt<0>, SDTCisSameAs<0, 1>, SDTCisSameAs<0, 2>, SDTCisVT<3, i32>]>;
def SDTKVXJTPcrel
  : SDTypeProfile<1, 1, [SDTCisVT<0, i64>, SDTCisVT<1, i64>]>;


//===----------------------------------------------------------------------===//
// Custom selection DAG node definitions.
//===----------------------------------------------------------------------===//

def KVXBRCond : SDNode<"KVXISD::BRCOND", SDTKVXBRCond, [SDNPHasChain]>;
def KVXComp : SDNode<"KVXISD::COMP", SDTKVXComp, []>;

def KVXJT: SDNode<"KVXISD::JT", SDTIntUnaryOp>;
def KVXJT_PCREL: SDNode<"KVXISD::JT_PCREL", SDTKVXJTPcrel>;

//===----------------------------------------------------------------------===//
// Selection DAG patterns using custom DAG nodes.
//===----------------------------------------------------------------------===//

def : Pat<(KVXBRCond i32:$lhs, bb:$dst, i32:$mod),
            (CB SingleReg:$lhs, Pcrel17:$dst, ScalarcondMod:$mod)>;
def : Pat<(KVXBRCond i64:$lhs, bb:$dst, i32:$mod),
            (CB SingleReg:$lhs, Pcrel17:$dst, ScalarcondMod:$mod)>;


def : Pat<(KVXComp i32:$lhs, i32:$rhs, i32:$mod),
            (COMPWrr SingleReg:$lhs, SingleReg:$rhs, ScalarcondMod:$mod)>;
def : Pat<(KVXComp i32:$lhs, Wrapped32:$rhs, i32:$mod),
            (COMPWri SingleReg:$lhs, Wrapped32:$rhs, ScalarcondMod:$mod)>;
def : Pat<(KVXComp i64:$lhs, Signed10:$rhs, i32:$mod),
            (COMPDri10 SingleReg:$lhs, Signed10:$rhs, ComparisonMod:$mod)>;
def : Pat<(KVXComp i64:$lhs, Signed37:$rhs, i32:$mod),
            (COMPDri37 SingleReg:$lhs, Signed37:$rhs, ComparisonMod:$mod)>;
def : Pat<(KVXComp i64:$lhs, Wrapped64:$rhs, i32:$mod),
            (COMPDri64 SingleReg:$lhs, Wrapped64:$rhs, ComparisonMod:$mod)>;
def : Pat<(KVXComp i64:$lhs, i64:$rhs, i32:$mod),
            (COMPDrr SingleReg:$lhs, SingleReg:$rhs, ComparisonMod:$mod)>;

//===----------------------------------------------------------------------===//
// ComplexPatterns definitions.
//===----------------------------------------------------------------------===//

def AddrFI : ComplexPattern<iPTR, 1, "SelectAddrFI", [frameindex], []>;

// FIXME: rename AddrRI to Addr
def AddrRI : Operand<iPTR>, ComplexPattern<iPTR, 2, "SelectAddrRI", [], []> {
  let PrintMethod = "printMemOperand";
  let MIOperandInfo = (ops SingleReg:$offset, SingleReg:$baseReg );
}

//===----------------------------------------------------------------------===//
// Pseudo instructions patterns.
//===----------------------------------------------------------------------===//

def DINVALLp : KVX_PSEUDO<(outs), (ins AddrRI:$addr), []>;
def DTOUCHLp : KVX_PSEUDO<(outs), (ins AddrRI:$addr), []>;
def DZEROLp : KVX_PSEUDO<(outs), (ins AddrRI:$addr), []>;
def IINVALSp : KVX_PSEUDO<(outs), (ins AddrRI:$addr), []>;

//===----------------------------------------------------------------------===//
// Peephole patterns.
//===----------------------------------------------------------------------===//

// Remove zero/any extend from i32 to i64 (instructions embed it)
multiclass ZEFPat<dag pattern, dag result> {
  def : Pat<(i32 pattern), result>;
  def : Pat<(i64 (zext pattern)), result>;
}

// FIXME: clean code below

def SDT_KVXCall : SDTypeProfile<0, -1, [SDTCisVT<0, i64>]>;
def Call : SDNode<"KVXISD::CALL", SDT_KVXCall, [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue, SDNPVariadic]>;

def : BITCAST<i64, v8i8, SingleReg>;
def : BITCAST<v8i8, i64, SingleReg>;

let isCall = 1, isBarrier = 1, isBranch = 1, isTerminator = 1, isReturn = 1, Uses = [R12] in
def TAIL : PCREL27_SIMPLE
  <(outs), (ins Pcrel27:$a1),
   "goto $a1",
   [ ]>;

let isCall = 1, isBarrier = 1, isBranch = 1, isIndirectBranch = 1, isTerminator = 1, isReturn = 1, Uses = [R12] in
def ITAIL : REGISTERZ_SIMPLE
  <(outs), (ins SingleReg:$a1),
   "igoto $a1",
   [ ],
   BCU>;

let isBarrier=1, isBranch=1, isPseudo=1, isIndirectBranch=1, isTerminator=1 in
def ENDLOOP : REGISTERZ_SIMPLE <(outs), (ins), "ENDLOOP", [ ], ALL>;

def SDTKVXWrapper : SDTypeProfile<1, 1, [SDTCisSameAs<0, 1>, SDTCisPtrTy<0>]>;
def SDTKVXTail : SDTypeProfile<0, -1, [SDTCisVT<0, i64>]>;

def KVXWrapper : SDNode<"KVXISD::AddrWrapper", SDTKVXWrapper>;

def SDT_KVXSelectCC : SDTypeProfile<1, 3, [SDTCisVT<0, i32>]>;

def SelectCC : SDNode<"KVXISD::SELECT_CC", SDT_KVXSelectCC, []>;

def Tail : SDNode <"KVXISD::TAIL", SDTKVXTail, [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue, SDNPVariadic]>;

def GetSystemReg : SDNode <"KVXISD::GetSystemReg", SDTypeProfile<1, 1, [SDTCisSameAs<0, 1>]>>;
def GETSYSTEMREG : REGISTERZ_SYSTEMS2_SIMPLE
  <(outs SingleReg:$dst), (ins SystemReg:$sr),
   "get $dst = $sr",
   [(set (i64 SingleReg:$dst), (GetSystemReg SystemReg:$sr))]>;

//
// Function return
//

def KVXRetNode : SDNode<"KVXISD::RET", SDTNone,
                       [SDNPHasChain, SDNPOptInGlue, SDNPMayLoad, SDNPVariadic]>;

def : Pat<(KVXRetNode),(RET)>;

def : Pat<(Call (KVXWrapper tglobaladdr:$func)),(CALL Pcrel27:$func)>;
def : Pat<(Call texternalsym:$func),(CALL Pcrel27:$func)>;
def : Pat<(Call SingleReg:$func),(ICALL SingleReg:$func)>;

def : Pat<(Tail (KVXWrapper tglobaladdr:$func)),(TAIL Pcrel27:$func)>;
def : Pat<(Tail texternalsym:$func), (TAIL Pcrel27:$func)>;
def : Pat<(Tail SingleReg:$func),(ITAIL SingleReg:$func)>;

/*let isBarrier = 1, isReturn = 1, isTerminator = 1 in
def PseudoRET : KVX_PSEUDO<(outs), (ins), "ret", [(KVXRetNode)]>,
PseudoInstExpansion<(KVXRet)>;*/

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
def ADJCALLSTACKDOWN : KVX_PSEUDO<(outs), (ins i32imm:$amt, i32imm:$amt2),
                               [(callseq_start timm:$amt, timm:$amt2)], "ADJCALLSTACKDOWN $amt">;
def ADJCALLSTACKUP : KVX_PSEUDO<(outs), (ins i32imm:$amt1, i32imm:$amt2),
                            [(callseq_end timm:$amt1, timm:$amt2)], "ADJCALLSTACKUP $amt1">;
} // Defs = [R12], Uses = [R12]

def MAKETLS : REGISTERW_EXTEND27_UPPER27_LOWER10_TRIPLE
  <(outs SingleReg:$SingleReg), (ins Wrapped64:$imm),
  "make $SingleReg = @tlsle( $imm )",
  [],
  ALU_TINY_Y>;

// MAKE patterns disabled - selection is done in code
/*
def : Pat<(Signed16:$imm), (MAKEi16 Signed16:$imm)>;
def : Pat<(Signed43:$imm), (MAKEi43 Signed43:$imm)>;
def : Pat<(Wrapped64:$imm), (MAKEi64 Wrapped64:$imm)>;
*/
def : Pat<(KVXWrapper tglobaladdr:$dst), (MAKEi64 tglobaladdr:$dst)>;
def : Pat<(KVXWrapper tglobaltlsaddr:$dst), (MAKETLS tglobaltlsaddr:$dst)>;
def : Pat<(KVXWrapper tblockaddress:$dst), (MAKEi64 tblockaddress:$dst)>;

//===----------------------------------------------------------------------===//
// Load Patterns
//===----------------------------------------------------------------------===//

// Pseudo instructions that select the right load instruction variant based on
// the offset value.
let mayLoad = 1 in
{
def LBSp : KVX_PSEUDO
        <(outs SingleReg:$out),
        (ins Wrapped64:$offset, SingleReg:$base, VariantMod:$var), []>;
def LBZp : KVX_PSEUDO
        <(outs SingleReg:$out),
        (ins Wrapped64:$offset, SingleReg:$base, VariantMod:$var), []>;
def LHSp : KVX_PSEUDO<
        (outs SingleReg:$out),
        (ins Wrapped64:$offset, SingleReg:$base, VariantMod:$var), []>;
def LHZp : KVX_PSEUDO<
        (outs SingleReg:$out),
        (ins Wrapped64:$offset, SingleReg:$base, VariantMod:$var), []>;
def LWSp : KVX_PSEUDO<
        (outs SingleReg:$out),
        (ins Wrapped64:$offset, SingleReg:$base, VariantMod:$var), []>;
def LWZp : KVX_PSEUDO<
        (outs SingleReg:$out),
        (ins Wrapped64:$offset, SingleReg:$base, VariantMod:$var), []>;
def LDp : KVX_PSEUDO<
        (outs SingleReg:$out),
        (ins Wrapped64:$offset, SingleReg:$base, VariantMod:$var), []>;
def LQp : KVX_PSEUDO<
        (outs PairedReg:$out),
        (ins Wrapped64:$offset, SingleReg:$base, VariantMod:$var), []>;
def LOp : KVX_PSEUDO<
        (outs QuadReg:$out),
        (ins Wrapped64:$offset, SingleReg:$base, VariantMod:$var), []>;
}

def loadi1 : PatFrag<(ops node:$ptr), (i1 (load node:$ptr))>;
def loadi8 : PatFrag<(ops node:$ptr), (i8 (load node:$ptr))>;
def loadi16 : PatFrag<(ops node:$ptr), (i16 (load node:$ptr))>;
def loadi32 : PatFrag<(ops node:$ptr), (i32 (load node:$ptr))>;
def loadi64 : PatFrag<(ops node:$ptr), (i64 (load node:$ptr))>;
def loadv8i8 : PatFrag<(ops node:$ptr), (v8i8 (load node:$ptr))>;
def loadv2i32 : PatFrag<(ops node:$ptr), (v2i32 (load node:$ptr))>;
def loadv4i16 : PatFrag<(ops node:$ptr), (v4i16 (load node:$ptr))>;
def loadv2i16 : PatFrag<(ops node:$ptr), (v2i16 (load node:$ptr))>;
def loadv2f16 : PatFrag<(ops node:$ptr), (v2f16 (load node:$ptr))>;
def loadv2i64 : PatFrag<(ops node:$ptr), (v2i64 (load node:$ptr))>;
def loadv4i32 : PatFrag<(ops node:$ptr), (v4i32 (load node:$ptr))>;

def IsOrAdd: PatFrag<(ops node:$A, node:$B), (or node:$A, node:$B), [{
  return isOrEquivalentToAdd(N);
}]>;

multiclass LoadPatRI<PatFrag LoadOp, ValueType vt, KVX_PSEUDO pinst,
                     int mod> {
  def : Pat<(vt (LoadOp AddrFI:$base)), (pinst (i64 0), SingleReg:$base, mod)>;
  def : Pat<(vt (LoadOp (add AddrFI:$base, Wrapped64:$offset))),
            (pinst Wrapped64:$offset, SingleReg:$base, mod)>;
  def : Pat<(vt (LoadOp (IsOrAdd AddrFI:$base, Wrapped64:$offset))),
            (pinst Wrapped64:$offset, SingleReg:$base, mod)>;
  def : Pat<(vt (LoadOp (add SingleReg:$base, Wrapped64:$offset))),
            (pinst Wrapped64:$offset, SingleReg:$base, mod)>;
}

multiclass LoadPatRR<PatFrag LoadOp, ValueType vt, KVX_INSTRUCTION rr,
                     int mod> {
  def : Pat<(vt (LoadOp (add SingleReg:$base, SingleReg:$offset))),
            (rr SingleReg:$offset, SingleReg:$base, mod, scaling_)>;
  def : Pat<(vt (LoadOp (or SingleReg:$base, SingleReg:$offset))),
            (rr SingleReg:$offset, SingleReg:$base, mod, scaling_)>;
}

multiclass LoadPatXS<PatFrag LoadOp, ValueType vt, int sc, KVX_INSTRUCTION rr,
                     int mod> {
  def : Pat<(vt (LoadOp
                  (add SingleReg:$base, (shl SingleReg:$offset, (i64 sc))))),
            (rr SingleReg:$offset, SingleReg:$base, mod, scaling_xs)>;
  def : Pat<(vt (LoadOp
                  (add (shl SingleReg:$offset, (i64 sc)), SingleReg:$base))),
            (rr SingleReg:$offset, SingleReg:$base, mod, scaling_xs)>;
  def : Pat<(vt (LoadOp
                  (or SingleReg:$base, (shl SingleReg:$offset, (i64 sc))))),
            (rr SingleReg:$offset, SingleReg:$base, mod, scaling_xs)>;
  def : Pat<(vt (LoadOp
                  (or (shl SingleReg:$offset, (i64 sc)), SingleReg:$base))),
            (rr SingleReg:$offset, SingleReg:$base, mod, scaling_xs)>;
}

multiclass SimpleLoadPat<PatFrag LoadOp, ValueType vt, KVX_PSEUDO pinst,
                         KVX_INSTRUCTION ri10, KVX_INSTRUCTION rr, int mod> {
  def : Pat<(vt (LoadOp SingleReg:$base)),
            (ri10 (i64 0), SingleReg:$base, mod)>;
  defm : LoadPatRI<LoadOp, vt, pinst, mod>;
  defm : LoadPatRR<LoadOp, vt, rr, mod>;
}

multiclass LoadPat<PatFrag LoadOp, ValueType vt, int sc, KVX_PSEUDO pinst,
                   KVX_INSTRUCTION ri10, KVX_INSTRUCTION rr, int mod> {
  def : Pat<(vt (LoadOp SingleReg:$base)),
            (ri10 (i64 0), SingleReg:$base, mod)>;
  defm : LoadPatRI<LoadOp, vt, pinst, mod>;
  defm : LoadPatRR<LoadOp, vt, rr, mod>;
  defm : LoadPatXS<LoadOp, vt, sc, rr, mod>;
}

defm : SimpleLoadPat<sextloadi1, i32, LBSp, LBSri10, LBSrr, variant_>;
defm : SimpleLoadPat<zextloadi1, i32, LBZp, LBZri10, LBZrr, variant_>;
defm : SimpleLoadPat<extloadi1, i32, LBZp, LBZri10, LBZrr, variant_>;
defm : SimpleLoadPat<sextloadi1, i64, LBSp, LBSri10, LBSrr, variant_>;
defm : SimpleLoadPat<zextloadi1, i64, LBZp, LBZri10, LBZrr, variant_>;
defm : SimpleLoadPat<extloadi1, i64, LBZp, LBZri10, LBZrr, variant_>;
defm : SimpleLoadPat<loadi1, i1, LBSp, LBSri10, LBSrr, variant_>;

defm : SimpleLoadPat<sextloadi8, i32, LBSp, LBSri10, LBSrr, variant_>;
defm : SimpleLoadPat<zextloadi8, i32, LBZp, LBZri10, LBZrr, variant_>;
defm : SimpleLoadPat<extloadi8, i32, LBZp, LBZri10, LBZrr, variant_>;
defm : SimpleLoadPat<sextloadi8, i64, LBSp, LBSri10, LBSrr, variant_>;
defm : SimpleLoadPat<zextloadi8, i64, LBZp, LBZri10, LBZrr, variant_>;
defm : SimpleLoadPat<extloadi8, i64, LBZp, LBZri10, LBZrr, variant_>;
defm : SimpleLoadPat<loadi8, i8, LBSp, LBSri10, LBSrr, variant_>;

defm : LoadPat<sextloadi16, i32, 1, LHSp, LHSri10, LHSrr, variant_>;
defm : LoadPat<zextloadi16, i32, 1, LHZp, LHZri10, LHZrr, variant_>;
defm : LoadPat<extloadi16, i32, 1, LHZp, LHZri10, LHZrr, variant_>;
defm : LoadPat<sextloadi16, i64, 1, LHSp, LHSri10, LHSrr, variant_>;
defm : LoadPat<zextloadi16, i64, 1, LHZp, LHZri10, LHZrr, variant_>;
defm : LoadPat<extloadi16, i64, 1, LHZp, LHZri10, LHZrr, variant_>;
defm : LoadPat<loadi16, i16, 1, LHSp, LHSri10, LHSrr, variant_>;

defm : LoadPat<sextloadi32, i64, 2, LWSp, LWSri10, LWSrr, variant_>;
defm : LoadPat<zextloadi32, i64, 2, LWZp, LWZri10, LWZrr, variant_>;
defm : LoadPat<extloadi32, i64, 2, LWZp, LWZri10, LWZrr, variant_>;
defm : LoadPat<loadi32, i32, 2, LWZp, LWZri10, LWZrr, variant_>;
defm : LoadPat<loadv2i16, v2i16, 2, LWZp, LWZri10, LWZrr, variant_>;

defm : LoadPat<loadi64, i64, 3, LDp, LDri10, LDrr, variant_>;
defm : LoadPat<loadv8i8, v8i8, 3, LDp, LDri10, LDrr, variant_>;
defm : LoadPat<loadv2i32, v2i32, 3, LDp, LDri10, LDrr, variant_>;
defm : LoadPat<loadv4i16, v4i16, 3, LDp, LDri10, LDrr, variant_>;

defm : LoadPat<loadv2i64, v2i64, 4, LQp, LQri10, LQrr, variant_>;
defm : LoadPat<loadv4i32, v4i32, 4, LQp, LQri10, LQrr, variant_>;

//===----------------------------------------------------------------------===//
// Store Patterns
//===----------------------------------------------------------------------===//

// Pseudo instructions that select the right store instruction variant based on
// the offset value.
let mayStore = 1 in
{
def SBp : KVX_PSEUDO<
        (outs), (ins Wrapped64:$offset, SingleReg:$base, SingleReg:$val), []>;
def SHp : KVX_PSEUDO<
        (outs), (ins Wrapped64:$offset, SingleReg:$base, SingleReg:$val), []>;
def SWp : KVX_PSEUDO<
        (outs), (ins Wrapped64:$offset, SingleReg:$base, SingleReg:$val), []>;
def SDp : KVX_PSEUDO<
        (outs), (ins Wrapped64:$offset, SingleReg:$base, SingleReg:$val), []>;
def SQp : KVX_PSEUDO<
        (outs), (ins Wrapped64:$offset, SingleReg:$base, PairedReg:$val), []>;
def SOp : KVX_PSEUDO<
        (outs), (ins Wrapped64:$offset, SingleReg:$base, QuadReg:$val), []>;
}

multiclass StorePatRI<PatFrag StoreOp, ValueType vt, RegisterClass rc,
                      KVX_PSEUDO pinst, SDNode nval > {
  def : Pat<(StoreOp vt:$val, AddrFI:$base),
            (pinst (i64 0), SingleReg:$base, nval)>;
  def : Pat<(StoreOp vt:$val, (add AddrFI:$base, Wrapped64:$offset)),
            (pinst Wrapped64:$offset, SingleReg:$base, nval)>;
  def : Pat<(StoreOp vt:$val, (IsOrAdd AddrFI:$base, Wrapped64:$offset)),
            (pinst Wrapped64:$offset, SingleReg:$base, nval)>;
  def : Pat<(StoreOp vt:$val, (add SingleReg:$base, Wrapped64:$offset)),
            (pinst Wrapped64:$offset, SingleReg:$base, nval)>;
}

multiclass StorePatRR<PatFrag StoreOp, ValueType vt, RegisterClass rc,
                      KVX_INSTRUCTION rr, SDNode nval > {
  def : Pat<(StoreOp vt:$val, (add SingleReg:$base, SingleReg:$offset)),
            (rr SingleReg:$offset, SingleReg:$base, nval, scaling_)>;
  def : Pat<(StoreOp vt:$val, (or SingleReg:$base, SingleReg:$offset)),
            (rr SingleReg:$offset, SingleReg:$base, nval, scaling_)>;
}

multiclass StorePatXS<PatFrag StoreOp, ValueType vt, RegisterClass rc, int sc,
                      KVX_INSTRUCTION rr, SDNode nval > {
  def : Pat<(StoreOp vt:$val,
              (add SingleReg:$base, (shl SingleReg:$offset, (i64 sc)))),
            (rr SingleReg:$offset, SingleReg:$base, nval, scaling_xs)>;
  def : Pat<(StoreOp vt:$val,
              (add (shl SingleReg:$offset, (i64 sc)), SingleReg:$base)),
            (rr SingleReg:$offset, SingleReg:$base, nval, scaling_xs)>;
  def : Pat<(StoreOp vt:$val,
              (or SingleReg:$base, (shl SingleReg:$offset, (i64 sc)))),
            (rr SingleReg:$offset, SingleReg:$base, nval, scaling_xs)>;
  def : Pat<(StoreOp vt:$val,
              (or (shl SingleReg:$offset, (i64 sc)), SingleReg:$base)),
            (rr SingleReg:$offset, SingleReg:$base, nval, scaling_xs)>;
}

multiclass SimpleStorePat<PatFrag StoreOp, ValueType vt, RegisterClass rc,
                          KVX_PSEUDO pinst, KVX_INSTRUCTION ri10,
                          KVX_INSTRUCTION rr> {
  def : Pat<(StoreOp vt:$val, SingleReg:$base),
            (ri10 (i64 0), SingleReg:$base, (vt rc:$val))>;
  defm : StorePatRI<StoreOp, vt, rc, pinst, (vt rc:$val)>;
  defm : StorePatRR<StoreOp, vt, rc, rr, (vt rc:$val)>;
}

multiclass StorePat<PatFrag StoreOp, ValueType vt, RegisterClass rc, int sc,
                    KVX_PSEUDO pinst, KVX_INSTRUCTION ri10,
                    KVX_INSTRUCTION rr> {
  def : Pat<(StoreOp vt:$val, SingleReg:$base),
            (ri10 (i64 0), SingleReg:$base, (vt rc:$val))>;
  defm : StorePatRI<StoreOp, vt, rc, pinst, (vt rc:$val)>;
  defm : StorePatRR<StoreOp, vt, rc, rr, (vt rc:$val)>;
  defm : StorePatXS<StoreOp, vt, rc, sc, rr, (vt rc:$val)>;
}

multiclass StorePatNode<PatFrag StoreOp, ValueType vt, RegisterClass rc, int sc,
                        KVX_PSEUDO pinst, KVX_INSTRUCTION ri10,
                        KVX_INSTRUCTION rr, SDNode nval> {
  def : Pat<(StoreOp vt:$val, SingleReg:$base),
            (ri10 (i64 0), SingleReg:$base, nval)>;
  defm : StorePatRI<StoreOp, vt, rc, pinst, nval>;
  defm : StorePatRR<StoreOp, vt, rc, rr, nval>;
  defm : StorePatXS<StoreOp, vt, rc, sc, rr, nval>;
}

defm : SimpleStorePat<store, i8, SingleReg, SBp, SBri10, SBrr>;
defm : SimpleStorePat<truncstorei8, i32, SingleReg, SBp, SBri10, SBrr>;
defm : SimpleStorePat<truncstorei8, i64, SingleReg, SBp, SBri10, SBrr>;

defm : StorePat<store, i16, SingleReg, 1, SHp, SHri10, SHrr>;
defm : StorePat<truncstorei16, i32, SingleReg, 1, SHp, SHri10, SHrr>;
defm : StorePat<truncstorei16, i64, SingleReg, 1, SHp, SHri10, SHrr>;

defm : StorePat<store, i32, SingleReg, 2, SWp, SWri10, SWrr>;
defm : StorePat<truncstorei32, i64, SingleReg, 2, SWp, SWri10, SWrr>;
defm : StorePat<store, v2i16, SingleReg, 2, SWp, SWri10, SWrr>;

defm : StorePat<store, i64, SingleReg, 3, SDp, SDri10, SDrr>;
defm : StorePat<store, v8i8, SingleReg, 3, SDp, SDri10, SDrr>;
defm : StorePat<store, v2i32, SingleReg, 3, SDp, SDri10, SDrr>;
defm : StorePat<store, v4i16, SingleReg, 3 , SDp, SDri10, SDrr>;

defm : StorePat<store, v2i64, PairedReg, 4, SQp, SQri10, SQrr>;
defm : StorePat<store, v4i32, PairedReg, 4, SQp, SQri10, SQrr>;


// sign extend optimizations
def : Pat<(and SingleReg:$val,(i64 0xffffffff)), (ZXWD SingleReg:$val)>;
def : Pat<(and SingleReg:$val,(i32 0xffff)), (ZXHD SingleReg:$val)>;
def : Pat<(and SingleReg:$val,(i32 0xff)), (ZXBD SingleReg:$val)>;

// eliminate zero extend for shift ops second operand
multiclass SHIFT_PAT32<SDNode n, SDNode instr>
{
  defm : ZEFPat<(n i32:$r1, (and SingleReg:$val,(i64 0xff))), (instr SingleReg:$r1, SingleReg:$val)>;
  defm : ZEFPat<(n i32:$r1, (and SingleReg:$val,(i64 0xffff))), (instr SingleReg:$r1, SingleReg:$val)>;
  defm : ZEFPat<(n i32:$r1, (and SingleReg:$val,(i64 0xffffffff))), (instr SingleReg:$r1, SingleReg:$val)>;

  defm : ZEFPat<(n i32:$r1, (i64 (zext (i32 (sext_inreg i32:$val,i8))))), (instr SingleReg:$r1, SingleReg:$val)>;
  defm : ZEFPat<(n i32:$r1, (i64 (zext (i32 (sext_inreg i32:$val,i16))))), (instr SingleReg:$r1, SingleReg:$val)>;
  defm : ZEFPat<(n i32:$r1, (i64 (zext i32:$val))), (instr SingleReg:$r1, SingleReg:$val)>;
}
multiclass SHIFT_PAT64<SDNode n, SDNode instr>
{ 
        def : Pat<(n i64:$r1,
                (and (i64 (sext_inreg SingleReg:$val,i8)),(i64 0xffffffff))),(instr SingleReg:$r1, SingleReg:$val)>;
        def : Pat<(n i64:$r1,
                (and (i64 (sext_inreg SingleReg:$val,i16)),(i64 0xffffffff))),(instr SingleReg:$r1, SingleReg:$val)>;

        def : Pat<(n i64:$r1,
                (and SingleReg:$val, (i64 255))),(instr SingleReg:$r1, SingleReg:$val)>;
        def : Pat<(n i64:$r1,
                (and SingleReg:$val, (i64 0xffff))),(instr SingleReg:$r1, SingleReg:$val)>;
        def : Pat<(n i64:$r1,
                (i64 (zext i32:$val))),(instr SingleReg:$r1, SingleReg:$val)>;
}

defm : SHIFT_PAT32<shl, SLLWrr>;
defm : SHIFT_PAT32<sra, SRAWrr>;
defm : SHIFT_PAT32<srl, SRLWrr>;
defm : SHIFT_PAT64<shl, SLLDrr>;
defm : SHIFT_PAT64<sra, SRADrr>;
defm : SHIFT_PAT64<srl, SRLDrr>;

// Zero/sign extend patterns to i32
def : Pat<(i32 (anyext i8:$val)), (COPY SingleReg:$val)>;
def : Pat<(i32 (anyext i16:$val)), (COPY SingleReg:$val)>;
def : Pat<(i32 (zext i8:$val)), (ZXBD SingleReg:$val)>;
def : Pat<(i32 (sext i8:$val)), (SXBD SingleReg:$val)>;
def : Pat<(i32 (zext i16:$val)), (ZXHD SingleReg:$val)>;
def : Pat<(i32 (sext i16:$val)), (SXHD SingleReg:$val)>;

// Zero/sign extend patterns to i64
def : Pat<(i64 (anyext i8:$val)), (COPY SingleReg:$val)>;
def : Pat<(i64 (anyext i16:$val)), (COPY SingleReg:$val)>;
def : Pat<(i64 (anyext i32:$val)), (COPY SingleReg:$val)>;

def : Pat<(i32 (sext_inreg SingleReg:$val, i1)), (EXTFS SingleReg:$val, 0, 0)>;
def : Pat<(i32 (sext_inreg SingleReg:$val, i8)), (SXBD SingleReg:$val)>;
def : Pat<(i32 (sext_inreg SingleReg:$val, i16)), (SXHD SingleReg:$val)>;

def : Pat<(i64 (sext_inreg SingleReg:$val, i1)), (EXTFS SingleReg:$val, 0, 0)>;
def : Pat<(i64 (sext_inreg SingleReg:$val, i8)), (SXBD SingleReg:$val)>;
def : Pat<(i64 (sext_inreg SingleReg:$val, i16)), (SXHD SingleReg:$val)>;
def : Pat<(i64 (sext_inreg SingleReg:$val, i32)), (SXWD SingleReg:$val)>;

def : Pat<(v8i8 (sext_inreg SingleReg:$val, v8i1)), (COPY SingleReg:$val)>;

// Conditional branch
def : Pat<(brcond i32:$cond, bb:$dst), (CB SingleReg:$cond, Pcrel17:$dst, scalarcond_wnez)>;
def : Pat<(brcond i64:$cond, bb:$dst), (CB SingleReg:$cond, Pcrel17:$dst, scalarcond_dnez)>;


def : Pat<(i64 AddrFI:$fi), (ADDDri64 SingleReg:$fi,(i64 0) )>;

def : Pat<(brind (i32 SingleReg:$r)), (IGOTO SingleReg:$r)>;


let Constraints = "@earlyclobber $scratch, $dst = $falsev" in
def Select32p : KVX_PSEUDO<(outs SingleReg:$dst, SingleReg:$scratch),
        (ins SingleReg:$cmp, SingleReg:$truev, SingleReg:$falsev, ScalarcondMod:$cond),[]>;

let Constraints = "@earlyclobber $scratch, $dst = $falsev" in
def Select64p : KVX_PSEUDO<(outs SingleReg:$dst, SingleReg:$scratch),
        (ins SingleReg:$cmp, SingleReg:$truev, SingleReg:$falsev, ScalarcondMod:$cond),[]>;

multiclass Select32PAT<SDNode ntrue, SDNode nfalse, SDNode itrue, SDNode ifalse>
{
        def : Pat<(SelectCC (i32 (seteq i32:$val, (i32 0))), ntrue, nfalse),
                (Select32p SingleReg:$val, itrue, ifalse, scalarcond_weqz)>;

        def : Pat<(SelectCC (i32 (setne i32:$val, (i32 0))), ntrue, nfalse),
                (Select32p SingleReg:$val, itrue, ifalse, scalarcond_wnez)>;

        def : Pat<(SelectCC (i32 (setlt i32:$val, (i32 0))), ntrue, nfalse),
                (Select32p SingleReg:$val, itrue, ifalse, scalarcond_wltz)>;

        def : Pat<(SelectCC (i32 (setgt i32:$val, (i32 -1))), ntrue, nfalse),
                (Select32p SingleReg:$val, itrue, ifalse, scalarcond_wgez)>;

        def : Pat<(SelectCC (i32 (setlt i32:$val, (i32 1))), ntrue, nfalse),
                (Select32p SingleReg:$val, itrue, ifalse, scalarcond_wlez)>;

        def : Pat<(SelectCC (i32 (setgt i32:$val, (i32 0))), ntrue, nfalse),
                (Select32p SingleReg:$val, itrue, ifalse, scalarcond_wgtz)>;

        def : Pat<(SelectCC (i32 (seteq (and i32:$val, (i32 1)), (i32 0))), ntrue, nfalse),
                (Select32p SingleReg:$val, itrue, ifalse, scalarcond_even)>;

        def : Pat<(SelectCC i32:$cmp, ntrue, nfalse),
                (Select32p SingleReg:$cmp, itrue, ifalse, scalarcond_wnez)>;
}

defm : Select32PAT<(i32 i32:$truev), (i32 i32:$falsev), (i32 Wrapped32:$truev), (i32 Wrapped32:$falsev)>;
defm : Select32PAT<(i64 i64:$truev), (i64 i64:$falsev), (i64 Wrapped64:$truev), (i64 Wrapped64:$falsev)>;
defm : Select32PAT<(KVXWrapper tglobaladdr:$truev), (KVXWrapper tglobaladdr:$falsev), (i64 SingleReg:$truev), (i64 SingleReg:$falsev)>;

multiclass Select64PAT<SDNode ntrue, SDNode nfalse, SDNode itrue, SDNode ifalse>
{
        def : Pat<(SelectCC (i32 (seteq i64:$val, (i64 0))), ntrue, nfalse),
                (Select64p SingleReg:$val, itrue, ifalse, scalarcond_deqz)>;

        def : Pat<(SelectCC (i32 (setne i64:$val, (i64 0))), ntrue, nfalse),
                (Select64p SingleReg:$val, itrue, ifalse, scalarcond_dnez)>;

        def : Pat<(SelectCC (i32 (setlt i64:$val, (i64 0))), ntrue, nfalse),
                (Select64p SingleReg:$val, itrue, ifalse, scalarcond_dltz)>;

        def : Pat<(SelectCC (i32 (setgt i64:$val, (i64 -1))), ntrue, nfalse),
                (Select64p SingleReg:$val, itrue, ifalse, scalarcond_dgez)>;

        def : Pat<(SelectCC (i32 (setlt i64:$val, (i64 1))), ntrue, nfalse),
                (Select64p SingleReg:$val, itrue, ifalse, scalarcond_dlez)>;

        def : Pat<(SelectCC (i32 (setgt i64:$val, (i64 0))), ntrue, nfalse),
                (Select64p SingleReg:$val, itrue, ifalse, scalarcond_dgtz)>;

        def : Pat<(SelectCC (i32 (seteq (and i64:$val, (i64 1)), (i64 0))), ntrue, nfalse),
                (Select64p SingleReg:$val, itrue, ifalse, scalarcond_even)>;

        def : Pat<(SelectCC i64:$cmp, ntrue, nfalse),
                (Select64p SingleReg:$cmp, itrue, ifalse, scalarcond_dnez)>;
}

defm : Select64PAT<(i32 i32:$truev), (i32 i32:$falsev), (i32 Wrapped32:$truev), (i32 Wrapped32:$falsev)>;
defm : Select64PAT<(i64 i64:$truev), (i64 i64:$falsev), (i64 Wrapped64:$truev), (i64 Wrapped64:$falsev)>;
defm : Select64PAT<(KVXWrapper tglobaladdr:$truev), (KVXWrapper tglobaladdr:$falsev), (i64 SingleReg:$truev), (i64 SingleReg:$falsev)>;

def : Pat<(i1 (trunc i64:$param)), (ANDDri10 SingleReg:$param, (i64 1))>;
def : Pat<(i8 (trunc i64:$param)), (ZXBD SingleReg:$param)>;
def : Pat<(i16 (trunc i64:$param)), (ZXHD SingleReg:$param)>;
def : Pat<(i32 (trunc i64:$param)), (ZXWD SingleReg:$param)>;

def : Pat<(i1 (trunc i32:$param)), (ANDWri10 SingleReg:$param, (i32 1))>;
def : Pat<(i8 (trunc i32:$param)), (ZXBD SingleReg:$param)>;
def : Pat<(i16 (trunc i32:$param)), (ZXHD SingleReg:$param)>;

def : Pat<(i1 (trunc i16:$param)), (ANDWri10 SingleReg:$param, (i32 1))>;
def : Pat<(i8 (trunc i16:$param)), (ZXBD SingleReg:$param)>;

def : Pat<(i1 (trunc i8:$param)), (ANDWri10 SingleReg:$param, (i32 1))>;

// v2i32
def : Pat<(extractelt (v2i32 SingleReg:$v), 0), (COPY SingleReg:$v)>;
def : Pat<(extractelt (v2i32 SingleReg:$v), 1), (SRADri SingleReg :$v, (i64 32))>;

// v2i16
def : Pat<(i32 (vector_extract v2i16:$v, 0)), (ZXHD SingleReg:$v)>;
def : Pat<(i32 (vector_extract v2i16:$v, 1)), (SRLWri SingleReg:$v, (i64 16))>;

def : Pat<(i32 (sext_inreg (vector_extract v2i16:$v, 0), i16)), (SXHD SingleReg:$v)>;
def : Pat<(i32 (sext_inreg (vector_extract v2i16:$v, 1), i16)), (SRAWri SingleReg:$v, (i64 16))>;

def : Pat<(i64 (sext_inreg (i64 (anyext (i32 (vector_extract v2i16:$v, 0)))), i16)), (SXHD SingleReg:$v)>;
def : Pat<(i64 (sext_inreg (i64 (anyext (i32 (vector_extract v2i16:$v, 1)))), i16)), (EXTFS SingleReg:$v, 31, 16)>;

// v4i16
def : Pat<(i32 (vector_extract (v4i16 SingleReg:$v), 0)), (EXTFZ SingleReg:$v, 15, 0)>;
def : Pat<(i32 (vector_extract (v4i16 SingleReg:$v), 1)), (EXTFZ SingleReg:$v, 31, 16)>;
def : Pat<(i32 (vector_extract (v4i16 SingleReg:$v), 2)), (EXTFZ SingleReg:$v, 47, 32)>;
def : Pat<(i32 (vector_extract (v4i16 SingleReg:$v), 3)), (SRLDri SingleReg:$v, (i64 48))>;

def : Pat<(i32 (sext_inreg (vector_extract (v4i16 SingleReg:$v), 0), i16)), (EXTFS SingleReg:$v, 15, 0)>;
def : Pat<(i32 (sext_inreg (vector_extract (v4i16 SingleReg:$v), 1), i16)), (EXTFS SingleReg:$v, 31, 16)>;
def : Pat<(i32 (sext_inreg (vector_extract (v4i16 SingleReg:$v), 2), i16)), (EXTFS SingleReg:$v, 47, 32)>;
def : Pat<(i32 (sext_inreg (vector_extract (v4i16 SingleReg:$v), 3), i16)), (SRADri SingleReg:$v, (i64 48))>;

// v2i64
def : Pat<(v2i64 (build_vector i64:$v1, i64:$v2)),
  (INSERT_SUBREG
    (INSERT_SUBREG (v2i64 (IMPLICIT_DEF)), SingleReg:$v1, 1),
    SingleReg:$v2, 2
  )>;

def : Pat<(extractelt (v2i64 PairedReg:$v), 0), (i64 (EXTRACT_SUBREG $v, 1))>;
def : Pat<(extractelt (v2i64 PairedReg:$v), 1), (i64 (EXTRACT_SUBREG $v, 2))>;

// v4i32
def : Pat<(extractelt (v4i32 PairedReg:$v), 0), (i32 (EXTRACT_SUBREG $v, 1))>;
def : Pat<(extractelt (v4i32 PairedReg:$v), 1), (SRADri (i32 (EXTRACT_SUBREG $v, 1)), (i64 32))>;
def : Pat<(extractelt (v4i32 PairedReg:$v), 2), (i32 (EXTRACT_SUBREG $v, 2))>;
def : Pat<(extractelt (v4i32 PairedReg:$v), 3), (SRADri (i32 (EXTRACT_SUBREG $v, 2)), (i64 32))>;

// v8i8
def : Pat<(i32 (vector_extract (v8i8 SingleReg:$v), 0)), (EXTFZ SingleReg:$v, 7, 0)>;
def : Pat<(i32 (vector_extract (v8i8 SingleReg:$v), 1)), (EXTFZ SingleReg:$v, 15, 8)>;
def : Pat<(i32 (vector_extract (v8i8 SingleReg:$v), 2)), (EXTFZ SingleReg:$v, 23, 16)>;
def : Pat<(i32 (vector_extract (v8i8 SingleReg:$v), 3)), (EXTFZ SingleReg:$v, 31, 24)>;
def : Pat<(i32 (vector_extract (v8i8 SingleReg:$v), 4)), (EXTFZ SingleReg:$v, 39, 32)>;
def : Pat<(i32 (vector_extract (v8i8 SingleReg:$v), 5)), (EXTFZ SingleReg:$v, 47, 40)>;
def : Pat<(i32 (vector_extract (v8i8 SingleReg:$v), 6)), (EXTFZ SingleReg:$v, 55, 48)>;
def : Pat<(i32 (vector_extract (v8i8 SingleReg:$v), 7)), (SRLDri SingleReg:$v, (i64 56))>;

//===----------------------------------------------------------------------===//
//  Synthetic Instructions - Patterns
//===----------------------------------------------------------------------===//

// NEGD, see KVXInstrInfo.td
// NEGHQ, see KVXInstrInfo.td for v4i16
def : Pat<(vineg v2i16:$v), (NEGHQ SingleReg:$v)>;

// NEGW, see KVXInstrInfo.td
// NEGWP, see KVXInstrInfo.td

// NOTW, see KVXInstrInfo.td for i32
def : Pat<(vinot v2i16:$v), (NOTW SingleReg:$v)>;

// NOTD, see KVXInstrInfo.td for i64
def : Pat<(vinot v4i16:$v), (NOTD SingleReg:$v)>;
def : Pat<(vinot v2i32:$v), (NOTD SingleReg:$v)>;

def: Pat<(KVXJT tjumptable:$a), (MAKEi64 Wrapped64:$a)>;
def: Pat<(KVXJT_PCREL i64:$a), (PCRELmi64 SingleReg:$a)>;
