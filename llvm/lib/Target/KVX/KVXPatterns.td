//===-- KVXPatterns.td - KVX Patterns ----------------------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
// TODO: Add patterns for
// ACSWAPD ACSWAPW ADDCHCP ALCLRD ALCLRW CLRF CMULDT CMULGHXDT
// CMULGLXDT CMULGMXDT CMULXDT
// CRCBELLW CRCBELMW CRCLELLW CRCLELMW DOT2SUWDP DOT2UWDP
// DOT2WDP FCDIVWP FDOT2WD FDOT2WDP FDOT2WZP
// FMULCWDC
// FMULWDC FSDIVWP FSRECWP FSRSRWP FWIDENMHWP FWIDENMWD
// IGET
// MADDDT MADDSUDT MADDUDT
// MADDUZDT MSBFDT
// MSBFSUDT MSBFUDT
// MSBFUZDT MULCWDC
// MULWDC NOP RFE RSWAP RSWAP
// SBFCHCP SBFCWC SBFWD SBFUWD SCALL


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

def KVXFence: SDNode<"KVXISD::FENCE", SDTNone, [SDNPHasChain, SDNPSideEffect]>;

def SDT_KVX_X_YY : SDTypeProfile<1, 2, [SDTCisInt<0>, SDTCisSameAs<2, 1>, SDTCisInt<2>]>;

def KVX_sext_mul  :  SDNode<"KVXISD::SEXT_MUL", SDT_KVX_X_YY, []>;
def KVX_szext_mul  :  SDNode<"KVXISD::SZEXT_MUL", SDT_KVX_X_YY, []>;
def KVX_zext_mul :  SDNode<"KVXISD::ZEXT_MUL", SDT_KVX_X_YY, []>;

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


def : Pat<(KVXFence), (FENCE)>;

//===----------------------------------------------------------------------===//
// ComplexPatterns definitions.
//===----------------------------------------------------------------------===//

def AddrFI : ComplexPattern<iPTR, 1, "SelectAddrFI", [frameindex], []>;

def AddrRR : Operand<iPTR>, ComplexPattern<iPTR, 2, "SelectAddrRR", [], []> {
  let PrintMethod = "printMemOperand";
  let MIOperandInfo = (ops SingleReg:$offset, SingleReg:$baseReg );
}

//===----------------------------------------------------------------------===//
// Pseudo instructions patterns.
//===----------------------------------------------------------------------===//

def DINVALLp : KVX_PSEUDO<(outs), (ins AddrRR:$addr), []>;
def DTOUCHLp : KVX_PSEUDO<(outs), (ins AddrRR:$addr), []>;
def DZEROLp : KVX_PSEUDO<(outs), (ins AddrRR:$addr), []>;
def IINVALSp : KVX_PSEUDO<(outs), (ins AddrRR:$addr), []>;
let Constraints = "$output = $newsp" in
def SPCHECKp : KVX_PSEUDO<(outs SingleReg:$output), (ins SingleReg:$newsp, SingleReg:$check), []>;

//===----------------------------------------------------------------------===//
// Peephole patterns.
//===----------------------------------------------------------------------===//

// Remove zero/any extend from i32 to i64 (instructions embed it)
multiclass ZEFPat<dag pattern, dag result> {
  def : Pat<(i32 pattern), result>;
  def : Pat<(i64 (zanyext pattern)), result>;
}

//  match zanyext as well (and pattern, 1) and a combination of both
multiclass ZAext_And1_Pat<dag pattern, dag result> {
  def : Pat<(i32 pattern), result>;
  def : Pat<(i32 (and (i32 pattern), 1)), result>;
  def : Pat<(i64 (zanyext pattern)), result>;
  def : Pat<(i64 (zanyext (i32 (and (i32 pattern), 1)))), result>;
  def : Pat<(i64 (and (zanyext (i32 pattern)), 1)), result>;
}

// FIXME: clean code below

def SDT_KVXCall : SDTypeProfile<0, -1, [SDTCisVT<0, i64>]>;
def Call : SDNode<"KVXISD::CALL", SDT_KVXCall, [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue, SDNPVariadic]>;

// 16 bit casts
defm : BITCAST<f16, v2i8, SingleReg>;

// // 32 bit casts
defm : BITCAST<f32, i32, SingleReg>;
defm : BITCAST<f32, v2f16, SingleReg>;
defm : BITCAST<f32, v2i16, SingleReg>;
defm : BITCAST<f32, v4i8, SingleReg>;

defm : BITCAST<i32, v2f16, SingleReg>;
defm : BITCAST<i32, v2i16, SingleReg>;
defm : BITCAST<i32, v4i8, SingleReg>;

defm : BITCAST<v2f16, v2i16, SingleReg>;
defm : BITCAST<v2f16, v4i8, SingleReg>;

defm : BITCAST<v2i16, v4i8, SingleReg>;

// 64 bit casts
defm : BITCAST<f64, i64, SingleReg>;
defm : BITCAST<f64, v2f32, SingleReg>;
defm : BITCAST<f64, v2i32, SingleReg>;
defm : BITCAST<f64, v4f16, SingleReg>;
defm : BITCAST<f64, v4i16, SingleReg>;
defm : BITCAST<f64, v8i8, SingleReg>;

defm : BITCAST<i64, v2f32, SingleReg>;
defm : BITCAST<i64, v2i32, SingleReg>;
defm : BITCAST<i64, v4f16, SingleReg>;
defm : BITCAST<i64, v4i16, SingleReg>;
defm : BITCAST<i64, v8i8, SingleReg>;

defm : BITCAST<v2f32, v2i32, SingleReg>;
defm : BITCAST<v2f32, v4f16, SingleReg>;
defm : BITCAST<v2f32, v4i16, SingleReg>;
defm : BITCAST<v2f32, v8i8, SingleReg>;

defm : BITCAST<v2i32, v4f16, SingleReg>;
defm : BITCAST<v2i32, v4i16, SingleReg>;
defm : BITCAST<v2i32, v8i8, SingleReg>;

defm : BITCAST<v4f16, v4i16, SingleReg>;
defm : BITCAST<v4f16, v8i8, SingleReg>;

defm : BITCAST<v4i16, v8i8, SingleReg>;

// 128 bit casts
defm : BITCAST<v2f64, v2i64, PairedReg>;
defm : BITCAST<v2f64, v4f32, PairedReg>;
defm : BITCAST<v2f64, v4i32, PairedReg>;

defm : BITCAST<v2i64, v4f32, PairedReg>;
defm : BITCAST<v2i64, v4i32, PairedReg>;

defm : BITCAST<v4f32, v4i32, PairedReg>;

// 256 bit casts
defm : BITCAST<v4f64, v4i64, QuadReg>;


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

def SDTKVXWrapper : SDTypeProfile<1, 1, [SDTCisSameAs<0, 1>, SDTCisPtrTy<0>]>;
def SDTKVXTail : SDTypeProfile<0, -1, [SDTCisVT<0, i64>]>;

def KVXWrapper : SDNode<"KVXISD::AddrWrapper", SDTKVXWrapper>;

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
                               [(callseq_start timm:$amt, timm:$amt2)], "ADJCALLSTACKDOWN">;
def ADJCALLSTACKUP : KVX_PSEUDO<(outs), (ins i32imm:$amt1, i32imm:$amt2),
                            [(callseq_end timm:$amt1, timm:$amt2)], "ADJCALLSTACKUP">;
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
def LBSp : KVX_PSEUDO_W_SCHEDINFO<
        (outs SingleReg:$out),
        (ins Wrapped64:$offset, SingleReg:$base, VariantMod:$var), [], LSU_AUXW>;
def LBZp : KVX_PSEUDO_W_SCHEDINFO<
        (outs SingleReg:$out),
        (ins Wrapped64:$offset, SingleReg:$base, VariantMod:$var), [], LSU_AUXW>;
def LHSp : KVX_PSEUDO_W_SCHEDINFO<
        (outs SingleReg:$out),
        (ins Wrapped64:$offset, SingleReg:$base, VariantMod:$var), [], LSU_AUXW>;
def LHZp : KVX_PSEUDO_W_SCHEDINFO<
        (outs SingleReg:$out),
        (ins Wrapped64:$offset, SingleReg:$base, VariantMod:$var), [], LSU_AUXW>;
def LWSp : KVX_PSEUDO_W_SCHEDINFO<
        (outs SingleReg:$out),
        (ins Wrapped64:$offset, SingleReg:$base, VariantMod:$var), [], LSU_AUXW>;
def LWZp : KVX_PSEUDO_W_SCHEDINFO<
        (outs SingleReg:$out),
        (ins Wrapped64:$offset, SingleReg:$base, VariantMod:$var), [], LSU_AUXW>;
def LDp : KVX_PSEUDO_W_SCHEDINFO<
        (outs SingleReg:$out),
        (ins Wrapped64:$offset, SingleReg:$base, VariantMod:$var), [], LSU_AUXW>;
def LQp : KVX_PSEUDO_W_SCHEDINFO<
        (outs PairedReg:$out),
        (ins Wrapped64:$offset, SingleReg:$base, VariantMod:$var), [], LSU_AUXW>;
def LOp : KVX_PSEUDO_W_SCHEDINFO<
        (outs QuadReg:$out),
        (ins Wrapped64:$offset, SingleReg:$base, VariantMod:$var), [], LSU_AUXW>;
def LVp : KVX_PSEUDO_W_SCHEDINFO<
        (outs VectorReg:$out),
        (ins Wrapped64:$offset, SingleReg:$base, SpeculateMod:$var), [], LSU>;

def LWIDEp : KVX_PSEUDO<
        (outs WideReg:$out),
        (ins Wrapped64:$offset, SingleReg:$base, SpeculateMod:$var), []>;

def LMATRIXp : KVX_PSEUDO<
        (outs MatrixReg:$out),
        (ins Wrapped64:$offset, SingleReg:$base, SpeculateMod:$var), []>;
}

def lvspec : PatFrag<(ops node:$ptr), (v256i1 (load node:$ptr)), [{
    const MemSDNode *LD = cast<MemSDNode>(N);
    return LD->getAddressSpace() == 258;
   }]>;

def lvvspec : PatFrag<(ops node:$ptr), (v512i1 (load node:$ptr)), [{
    const MemSDNode *LD = cast<MemSDNode>(N);
    return LD->getAddressSpace() == 258;
   }]>;

def lxspec : PatFrag<(ops node:$ptr), (v1024i1 (load node:$ptr)), [{
    const MemSDNode *LD = cast<MemSDNode>(N);
    return LD->getAddressSpace() == 258;
   }]>;

foreach type = [ i1, i8, i16, i32, i64, v2i8, v4i8, v8i8, v2i32, v4i16, v2i16, v2i64, v4i32, v4i64] in {

def load#type : PatFrag<(ops node:$ptr), (type (load node:$ptr)), [{
    const MemSDNode *LD = cast<MemSDNode>(N);
    return LD->getAddressSpace() < 256;
  }]>;

def loadbypass#type : PatFrag<(ops node:$ptr), (type (load node:$ptr)), [{
    const MemSDNode *LD = cast<MemSDNode>(N);
    return LD->getAddressSpace() == 256;
  }]>;

def extloadbypass#type : PatFrag<(ops node:$ptr), (extload node:$ptr), [{
    const MemSDNode *LD = cast<MemSDNode>(N);
    return LD->getAddressSpace() == 256;
  }]>
{
  let IsLoad = 1;
  let MemoryVT = type;
}

def zextloadbypass#type : PatFrag<(ops node:$ptr), (zextload node:$ptr), [{
    const MemSDNode *LD = cast<MemSDNode>(N);
    return LD->getAddressSpace() == 256;
  }]>
{
  let IsLoad = 1;
  let MemoryVT = type;
}

def sextloadbypass#type : PatFrag<(ops node:$ptr), (sextload node:$ptr), [{
    const MemSDNode *LD = cast<MemSDNode>(N);
    return LD->getAddressSpace() == 256;
  }]>
{
  let IsLoad = 1;
  let MemoryVT = type;
}

def loadpreload#type : PatFrag<(ops node:$ptr), (type (load node:$ptr)), [{
    const MemSDNode *LD = cast<MemSDNode>(N);
    return LD->getAddressSpace() == 257;
  }]>;

def extloadpreload#type : PatFrag<(ops node:$ptr), (extload node:$ptr), [{
    const MemSDNode *LD = cast<MemSDNode>(N);
    return LD->getAddressSpace() == 257;
  }]>
{
  let IsLoad = 1;
  let MemoryVT = type;
}

def zextloadpreload#type : PatFrag<(ops node:$ptr), (zextload node:$ptr), [{
    const MemSDNode *LD = cast<MemSDNode>(N);
    return LD->getAddressSpace() == 257;
  }]>
{
  let IsLoad = 1;
  let MemoryVT = type;
}

def sextloadpreload#type : PatFrag<(ops node:$ptr), (sextload node:$ptr), [{
    const MemSDNode *LD = cast<MemSDNode>(N);
    return LD->getAddressSpace() == 257;
  }] >
{
  let IsLoad = 1;
  let MemoryVT = type;
}

def loadspec#type : PatFrag<(ops node:$ptr), (type (load node:$ptr)), [{
    const MemSDNode *LD = cast<MemSDNode>(N);
    return LD->getAddressSpace() == 258;
  }]>;

def extloadspec#type : PatFrag<(ops node:$ptr), (extload node:$ptr), [{
    const MemSDNode *LD = cast<MemSDNode>(N);
    return LD->getAddressSpace() == 258;
  }]>
{
  let IsLoad = 1;
  let MemoryVT = type;
}

def zextloadspec#type : PatFrag<(ops node:$ptr), (zextload node:$ptr), [{
    const MemSDNode *LD = cast<MemSDNode>(N);
    return LD->getAddressSpace() == 258;
  }]>
{
  let IsLoad = 1;
  let MemoryVT = type;
}

def sextloadspec#type : PatFrag<(ops node:$ptr), (sextload node:$ptr), [{
    const MemSDNode *LD = cast<MemSDNode>(N);
    return LD->getAddressSpace() == 258;
  }]>
{
  let IsLoad = 1;
  let MemoryVT = type;
}

}

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

// bypass loads
defm : SimpleLoadPat<sextloadbypassi1, i32, LBSp, LBSri10, LBSrr, variant_u>;
defm : SimpleLoadPat<zextloadbypassi1, i32, LBZp, LBZri10, LBZrr, variant_u>;
defm : SimpleLoadPat<extloadbypassi1, i32, LBZp, LBZri10, LBZrr, variant_u>;
defm : SimpleLoadPat<sextloadbypassi1, i64, LBSp, LBSri10, LBSrr, variant_u>;
defm : SimpleLoadPat<zextloadbypassi1, i64, LBZp, LBZri10, LBZrr, variant_u>;
defm : SimpleLoadPat<extloadbypassi1, i64, LBZp, LBZri10, LBZrr, variant_u>;
defm : SimpleLoadPat<loadbypassi1, i1, LBSp, LBSri10, LBSrr, variant_u>;

defm : SimpleLoadPat<sextloadbypassi8, i32, LBSp, LBSri10, LBSrr, variant_u>;
defm : SimpleLoadPat<zextloadbypassi8, i32, LBZp, LBZri10, LBZrr, variant_u>;
defm : SimpleLoadPat<extloadbypassi8, i32, LBZp, LBZri10, LBZrr, variant_u>;
defm : SimpleLoadPat<sextloadbypassi8, i64, LBSp, LBSri10, LBSrr, variant_u>;
defm : SimpleLoadPat<zextloadbypassi8, i64, LBZp, LBZri10, LBZrr, variant_u>;
defm : SimpleLoadPat<extloadbypassi8, i64, LBZp, LBZri10, LBZrr, variant_u>;
defm : SimpleLoadPat<loadbypassi8, i8, LBSp, LBSri10, LBSrr, variant_u>;

defm : LoadPat<sextloadbypassi16, i32, 1, LHSp, LHSri10, LHSrr, variant_u>;
defm : LoadPat<zextloadbypassi16, i32, 1, LHZp, LHZri10, LHZrr, variant_u>;
defm : LoadPat<extloadbypassi16, i32, 1, LHZp, LHZri10, LHZrr, variant_u>;
defm : LoadPat<sextloadbypassi16, i64, 1, LHSp, LHSri10, LHSrr, variant_u>;
defm : LoadPat<zextloadbypassi16, i64, 1, LHZp, LHZri10, LHZrr, variant_u>;
defm : LoadPat<extloadbypassi16, i64, 1, LHZp, LHZri10, LHZrr, variant_u>;
defm : LoadPat<loadbypassi16, i16, 1, LHSp, LHSri10, LHSrr, variant_u>;
defm : LoadPat<loadbypassv2i8, v2i8, 1, LHZp, LHZri10, LHZrr, variant_u>;

defm : LoadPat<sextloadbypassi32, i64, 2, LWSp, LWSri10, LWSrr, variant_u>;
defm : LoadPat<zextloadbypassi32, i64, 2, LWZp, LWZri10, LWZrr, variant_u>;
defm : LoadPat<extloadbypassi32, i64, 2, LWZp, LWZri10, LWZrr, variant_u>;
defm : LoadPat<loadbypassi32, i32, 2, LWZp, LWZri10, LWZrr, variant_u>;
defm : LoadPat<loadbypassv2i16, v2i16, 2, LWZp, LWZri10, LWZrr, variant_u>;
defm : LoadPat<loadbypassv4i8, v4i8, 2, LWZp, LWZri10, LWZrr, variant_u>;

defm : LoadPat<loadbypassi64, i64, 3, LDp, LDri10, LDrr, variant_u>;
defm : LoadPat<loadbypassv8i8, v8i8, 3, LDp, LDri10, LDrr, variant_u>;
defm : LoadPat<loadbypassv2i32, v2i32, 3, LDp, LDri10, LDrr, variant_u>;
defm : LoadPat<loadbypassv4i16, v4i16, 3, LDp, LDri10, LDrr, variant_u>;

defm : LoadPat<loadbypassv2i64, v2i64, 4, LQp, LQri10, LQrr, variant_u>;
defm : LoadPat<loadbypassv4i32, v4i32, 4, LQp, LQri10, LQrr, variant_u>;

defm : LoadPat<loadbypassv4i64, v4i64, 5, LOp, LOri10, LOrr, variant_u>;

// preload loads
defm : SimpleLoadPat<sextloadpreloadi1, i32, LBSp, LBSri10, LBSrr, variant_us>;
defm : SimpleLoadPat<zextloadpreloadi1, i32, LBZp, LBZri10, LBZrr, variant_us>;
defm : SimpleLoadPat<extloadpreloadi1, i32, LBZp, LBZri10, LBZrr, variant_us>;
defm : SimpleLoadPat<sextloadpreloadi1, i64, LBSp, LBSri10, LBSrr, variant_us>;
defm : SimpleLoadPat<zextloadpreloadi1, i64, LBZp, LBZri10, LBZrr, variant_us>;
defm : SimpleLoadPat<extloadpreloadi1, i64, LBZp, LBZri10, LBZrr, variant_us>;
defm : SimpleLoadPat<loadpreloadi1, i1, LBSp, LBSri10, LBSrr, variant_us>;

defm : SimpleLoadPat<sextloadpreloadi8, i32, LBSp, LBSri10, LBSrr, variant_us>;
defm : SimpleLoadPat<zextloadpreloadi8, i32, LBZp, LBZri10, LBZrr, variant_us>;
defm : SimpleLoadPat<extloadpreloadi8, i32, LBZp, LBZri10, LBZrr, variant_us>;
defm : SimpleLoadPat<sextloadpreloadi8, i64, LBSp, LBSri10, LBSrr, variant_us>;
defm : SimpleLoadPat<zextloadpreloadi8, i64, LBZp, LBZri10, LBZrr, variant_us>;
defm : SimpleLoadPat<extloadpreloadi8, i64, LBZp, LBZri10, LBZrr, variant_us>;
defm : SimpleLoadPat<loadpreloadi8, i8, LBSp, LBSri10, LBSrr, variant_us>;

defm : LoadPat<sextloadpreloadi16, i32, 1, LHSp, LHSri10, LHSrr, variant_us>;
defm : LoadPat<zextloadpreloadi16, i32, 1, LHZp, LHZri10, LHZrr, variant_us>;
defm : LoadPat<extloadpreloadi16, i32, 1, LHZp, LHZri10, LHZrr, variant_us>;
defm : LoadPat<sextloadpreloadi16, i64, 1, LHSp, LHSri10, LHSrr, variant_us>;
defm : LoadPat<zextloadpreloadi16, i64, 1, LHZp, LHZri10, LHZrr, variant_us>;
defm : LoadPat<extloadpreloadi16, i64, 1, LHZp, LHZri10, LHZrr, variant_us>;
defm : LoadPat<loadpreloadi16, i16, 1, LHSp, LHSri10, LHSrr, variant_us>;
defm : LoadPat<loadpreloadv2i8, v2i8, 1, LHZp, LHZri10, LHZrr, variant_us>;

defm : LoadPat<sextloadpreloadi32, i64, 2, LWSp, LWSri10, LWSrr, variant_us>;
defm : LoadPat<zextloadpreloadi32, i64, 2, LWZp, LWZri10, LWZrr, variant_us>;
defm : LoadPat<extloadpreloadi32, i64, 2, LWZp, LWZri10, LWZrr, variant_us>;
defm : LoadPat<loadpreloadi32, i32, 2, LWZp, LWZri10, LWZrr, variant_us>;
defm : LoadPat<loadpreloadv2i16, v2i16, 2, LWZp, LWZri10, LWZrr, variant_us>;
defm : LoadPat<loadpreloadv4i8, v4i8, 2, LWZp, LWZri10, LWZrr, variant_us>;

defm : LoadPat<loadpreloadi64, i64, 3, LDp, LDri10, LDrr, variant_us>;
defm : LoadPat<loadpreloadv8i8, v8i8, 3, LDp, LDri10, LDrr, variant_us>;
defm : LoadPat<loadpreloadv2i32, v2i32, 3, LDp, LDri10, LDrr, variant_us>;
defm : LoadPat<loadpreloadv4i16, v4i16, 3, LDp, LDri10, LDrr, variant_us>;

defm : LoadPat<loadpreloadv2i64, v2i64, 4, LQp, LQri10, LQrr, variant_us>;
defm : LoadPat<loadpreloadv4i32, v4i32, 4, LQp, LQri10, LQrr, variant_us>;

defm : LoadPat<loadpreloadv4i64, v4i64, 5, LOp, LOri10, LOrr, variant_us>;

// speculative loads
defm : SimpleLoadPat<sextloadspeci1, i32, LBSp, LBSri10, LBSrr, variant_s>;
defm : SimpleLoadPat<zextloadspeci1, i32, LBZp, LBZri10, LBZrr, variant_s>;
defm : SimpleLoadPat<extloadspeci1, i32, LBZp, LBZri10, LBZrr, variant_s>;
defm : SimpleLoadPat<sextloadspeci1, i64, LBSp, LBSri10, LBSrr, variant_s>;
defm : SimpleLoadPat<zextloadspeci1, i64, LBZp, LBZri10, LBZrr, variant_s>;
defm : SimpleLoadPat<extloadspeci1, i64, LBZp, LBZri10, LBZrr, variant_s>;
defm : SimpleLoadPat<loadspeci1, i1, LBSp, LBSri10, LBSrr, variant_s>;

defm : SimpleLoadPat<sextloadspeci8, i32, LBSp, LBSri10, LBSrr, variant_s>;
defm : SimpleLoadPat<zextloadspeci8, i32, LBZp, LBZri10, LBZrr, variant_s>;
defm : SimpleLoadPat<extloadspeci8, i32, LBZp, LBZri10, LBZrr, variant_s>;
defm : SimpleLoadPat<sextloadspeci8, i64, LBSp, LBSri10, LBSrr, variant_s>;
defm : SimpleLoadPat<zextloadspeci8, i64, LBZp, LBZri10, LBZrr, variant_s>;
defm : SimpleLoadPat<extloadspeci8, i64, LBZp, LBZri10, LBZrr, variant_s>;
defm : SimpleLoadPat<loadspeci8, i8, LBSp, LBSri10, LBSrr, variant_s>;

defm : LoadPat<sextloadspeci16, i32, 1, LHSp, LHSri10, LHSrr, variant_s>;
defm : LoadPat<zextloadspeci16, i32, 1, LHZp, LHZri10, LHZrr, variant_s>;
defm : LoadPat<extloadspeci16, i32, 1, LHZp, LHZri10, LHZrr, variant_s>;
defm : LoadPat<sextloadspeci16, i64, 1, LHSp, LHSri10, LHSrr, variant_s>;
defm : LoadPat<zextloadspeci16, i64, 1, LHZp, LHZri10, LHZrr, variant_s>;
defm : LoadPat<extloadspeci16, i64, 1, LHZp, LHZri10, LHZrr, variant_s>;
defm : LoadPat<loadspeci16, i16, 1, LHSp, LHSri10, LHSrr, variant_s>;
defm : LoadPat<loadspecv2i8, v2i8, 1, LHZp, LHZri10, LHZrr, variant_s>;

defm : LoadPat<sextloadspeci32, i64, 2, LWSp, LWSri10, LWSrr, variant_s>;
defm : LoadPat<zextloadspeci32, i64, 2, LWZp, LWZri10, LWZrr, variant_s>;
defm : LoadPat<extloadspeci32, i64, 2, LWZp, LWZri10, LWZrr, variant_s>;
defm : LoadPat<loadspeci32, i32, 2, LWZp, LWZri10, LWZrr, variant_s>;
defm : LoadPat<loadspecv2i16, v2i16, 2, LWZp, LWZri10, LWZrr, variant_s>;
defm : LoadPat<loadspecv4i8, v4i8, 2, LWZp, LWZri10, LWZrr, variant_s>;

defm : LoadPat<loadspeci64, i64, 3, LDp, LDri10, LDrr, variant_s>;
defm : LoadPat<loadspecv8i8, v8i8, 3, LDp, LDri10, LDrr, variant_s>;
defm : LoadPat<loadspecv2i32, v2i32, 3, LDp, LDri10, LDrr, variant_s>;
defm : LoadPat<loadspecv4i16, v4i16, 3, LDp, LDri10, LDrr, variant_s>;

defm : LoadPat<loadspecv2i64, v2i64, 4, LQp, LQri10, LQrr, variant_s>;
defm : LoadPat<loadspecv4i32, v4i32, 4, LQp, LQri10, LQrr, variant_s>;

defm : LoadPat<loadspecv4i64, v4i64, 5, LOp, LOri10, LOrr, variant_s>;
defm : LoadPat<lvspec, v256i1, 5, LVp, LVri10, LVrr, speculate_s>;
def : Pat<(v512i1 (lvvspec SingleReg:$base)),
          (v512i1 (REG_SEQUENCE WideReg,
                    (LVp (i64 32), SingleReg:$base, speculate_),  sub_v1,
                    (LVp (i64 0), SingleReg:$base, speculate_),  sub_v0))>;
def : Pat<(v1024i1 (lxspec SingleReg:$base)),
          (v1024i1 (REG_SEQUENCE MatrixReg,
                    (LVp (i64 96), SingleReg:$base, speculate_),  sub_v3,
                    (LVp (i64 64), SingleReg:$base, speculate_),  sub_v2,
                    (LVp (i64 32), SingleReg:$base, speculate_),  sub_v1,
                    (LVp (i64 0), SingleReg:$base, speculate_),   sub_v0))>;
// normal loads
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
defm : LoadPat<loadv2i8, v2i8, 1, LHZp, LHZri10, LHZrr, variant_>;

defm : LoadPat<sextloadi32, i64, 2, LWSp, LWSri10, LWSrr, variant_>;
defm : LoadPat<zextloadi32, i64, 2, LWZp, LWZri10, LWZrr, variant_>;
defm : LoadPat<extloadi32, i64, 2, LWZp, LWZri10, LWZrr, variant_>;
defm : LoadPat<loadi32, i32, 2, LWZp, LWZri10, LWZrr, variant_>;
defm : LoadPat<loadv2i16, v2i16, 2, LWZp, LWZri10, LWZrr, variant_>;
defm : LoadPat<loadv4i8, v4i8, 2, LWZp, LWZri10, LWZrr, variant_>;

defm : LoadPat<loadi64, i64, 3, LDp, LDri10, LDrr, variant_>;
defm : LoadPat<loadv8i8, v8i8, 3, LDp, LDri10, LDrr, variant_>;
defm : LoadPat<loadv2i32, v2i32, 3, LDp, LDri10, LDrr, variant_>;
defm : LoadPat<loadv4i16, v4i16, 3, LDp, LDri10, LDrr, variant_>;

defm : LoadPat<loadv2i64, v2i64, 4, LQp, LQri10, LQrr, variant_>;
defm : LoadPat<loadv4i32, v4i32, 4, LQp, LQri10, LQrr, variant_>;

defm : LoadPat<loadv4i64, v4i64, 5, LOp, LOri10, LOrr, variant_>;
defm : LoadPat<load, v256i1, 5, LVp, LVri10, LVrr, speculate_>;

def : Pat<(v512i1 (load SingleReg:$base)),
          (v512i1 (REG_SEQUENCE WideReg,
                    (LVp (i64 32), SingleReg:$base, speculate_),  sub_v1,
                    (LVp (i64 0), SingleReg:$base, speculate_),  sub_v0))>;
def : Pat<(v1024i1 (load SingleReg:$base)),
          (v1024i1 (REG_SEQUENCE MatrixReg,
                    (LVp (i64 96), SingleReg:$base, speculate_), sub_v3,
                    (LVp (i64 64), SingleReg:$base, speculate_), sub_v2,
                    (LVp (i64 32), SingleReg:$base, speculate_), sub_v1,
                    (LVp (i64 0), SingleReg:$base, speculate_),  sub_v0))>;


//===----------------------------------------------------------------------===//
// Store Patterns
//===----------------------------------------------------------------------===//

// Pseudo instructions that select the right store instruction variant based on
// the offset value.
let mayStore = 1 in
{
def SBp : KVX_PSEUDO_W_SCHEDINFO<
        (outs), (ins Wrapped64:$offset, SingleReg:$base, SingleReg:$val), [], LSU_AUXW>;
def SHp : KVX_PSEUDO_W_SCHEDINFO<
        (outs), (ins Wrapped64:$offset, SingleReg:$base, SingleReg:$val), [], LSU_AUXW>;
def SWp : KVX_PSEUDO_W_SCHEDINFO<
        (outs), (ins Wrapped64:$offset, SingleReg:$base, SingleReg:$val), [], LSU_AUXW>;
def SDp : KVX_PSEUDO_W_SCHEDINFO<
        (outs), (ins Wrapped64:$offset, SingleReg:$base, SingleReg:$val), [], LSU_AUXW>;
def SQp : KVX_PSEUDO_W_SCHEDINFO<
        (outs), (ins Wrapped64:$offset, SingleReg:$base, PairedReg:$val), [], LSU_AUXW>;
def SOp : KVX_PSEUDO_W_SCHEDINFO<
        (outs), (ins Wrapped64:$offset, SingleReg:$base, QuadReg:$val), [], LSU_AUXW>;
def SVp : KVX_PSEUDO_W_SCHEDINFO<
        (outs), (ins Wrapped64:$offset, SingleReg:$base, VectorReg:$val), [], LSU>;
def SWIDEp : KVX_PSEUDO<
        (outs), (ins Wrapped64:$offset, SingleReg:$base, WideReg:$val), []>;
def SMATRIXp : KVX_PSEUDO<
        (outs), (ins Wrapped64:$offset, SingleReg:$base, MatrixReg:$val), []>;
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
defm : StorePat<store, v2i8, SingleReg, 1 , SHp, SHri10, SHrr>;

defm : StorePat<store, i32, SingleReg, 2, SWp, SWri10, SWrr>;
defm : StorePat<truncstorei32, i64, SingleReg, 2, SWp, SWri10, SWrr>;
defm : StorePat<store, v2i16, SingleReg, 2, SWp, SWri10, SWrr>;
defm : StorePat<store, v4i8, SingleReg, 2, SWp, SWri10, SWrr>;

defm : StorePat<store, i64, SingleReg, 3, SDp, SDri10, SDrr>;
defm : StorePat<store, v8i8, SingleReg, 3, SDp, SDri10, SDrr>;
defm : StorePat<store, v2i32, SingleReg, 3, SDp, SDri10, SDrr>;
defm : StorePat<store, v4i16, SingleReg, 3 , SDp, SDri10, SDrr>;

defm : StorePat<store, v2i64, PairedReg, 4, SQp, SQri10, SQrr>;
defm : StorePat<store, v4i32, PairedReg, 4, SQp, SQri10, SQrr>;

defm : StorePat<store, v4i64, QuadReg, 5, SOp, SOri10, SOrr>;
defm : StorePat<store, v256i1,VectorReg,5, SVp, SVri10, SVrr>;
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


// This ADDDri64 is modified at eliminateFrameIndex. Correct immediate variant
// is selected there.
// TODO: Use a pseudo instruction? See SUBD below.
def : Pat<(i64 AddrFI:$fi), (ADDDri64 SingleReg:$fi, (i64 0))>;

def : Pat<(brind (i32 SingleReg:$r)), (IGOTO SingleReg:$r)>;

// TODO: clean the patterns for SELECTCONDW and SELECTCONDD. The
// Wrapped/Wrapped cases are catching Register Operands, why?
let Constraints = "@earlyclobber $scratch, $dst = $falsev" in
def SELECTp : KVX_PSEUDO<(outs SingleReg:$dst, SingleReg:$scratch),
                         (ins SingleReg:$cmp, SingleReg:$truev, SingleReg:$falsev, ScalarcondMod:$cond),[]>;
// TODO: i32 (select (i32 setcc:$v), -1, 0) should be a simple NEGW $v
multiclass SELECTCONDW<SDNode ntrue, SDNode nfalse, SDNode itrue, SDNode ifalse>
{
        def : Pat<(select (i32 (seteq i32:$val, (i32 0))), ntrue, nfalse),
                (SELECTp SingleReg:$val, itrue, ifalse, scalarcond_weqz)>;

        def : Pat<(select (i32 (setne i32:$val, (i32 0))), ntrue, nfalse),
                (SELECTp SingleReg:$val, itrue, ifalse, scalarcond_wnez)>;

        def : Pat<(select (i32 (setlt i32:$val, (i32 0))), ntrue, nfalse),
                (SELECTp SingleReg:$val, itrue, ifalse, scalarcond_wltz)>;

        def : Pat<(select (i32 (setgt i32:$val, (i32 -1))), ntrue, nfalse),
                (SELECTp SingleReg:$val, itrue, ifalse, scalarcond_wgez)>;

        def : Pat<(select (i32 (setlt i32:$val, (i32 1))), ntrue, nfalse),
                (SELECTp SingleReg:$val, itrue, ifalse, scalarcond_wlez)>;

        def : Pat<(select (i32 (setgt i32:$val, (i32 0))), ntrue, nfalse),
                (SELECTp SingleReg:$val, itrue, ifalse, scalarcond_wgtz)>;

        def : Pat<(select (i32 (seteq (and i32:$val, (i32 1)), (i32 0))), ntrue, nfalse),
                (SELECTp SingleReg:$val, itrue, ifalse, scalarcond_even)>;

        def : Pat<(select i32:$cmp, ntrue, nfalse),
                (SELECTp SingleReg:$cmp, itrue, ifalse, scalarcond_wnez)>;
}

// TCA select
// We use a hacky method to perform a select for tca vector operations.
// (select cc, v1, v2) becomes ALIGNV (v2, v1, cc * 64)
// FIXME: For now we are enforcing it to be performed in a fixed rero
// or rore. Perhaps this should be a pseudo and the correct instruction
// chosen after reg-alloc?
def : Pat <(select i32:$cc, v256i1:$truev, v256i1:$falsev),
           (ALIGNVreror VectorReg:$falsev, VectorReg:$truev, (SLLWri SingleReg:$cc, 6))>;

def : Pat <(select i32:$cc, v512i1:$truev, v512i1:$falsev),
           (REG_SEQUENCE WideReg,
           (ALIGNVreror (v256i1 (EXTRACT_SUBREG WideReg:$falsev, sub_v0)), (v256i1 (EXTRACT_SUBREG WideReg:$truev, sub_v0)), (SLLWri SingleReg:$cc, 6)), sub_v0,
           (ALIGNVrorer (v256i1 (EXTRACT_SUBREG WideReg:$falsev, sub_v1)), (v256i1 (EXTRACT_SUBREG WideReg:$truev, sub_v1)), (SLLWri SingleReg:$cc, 6)), sub_v1
           )>;
def : Pat <(select i32:$cc, v1024i1:$truev, v1024i1:$falsev),
           (REG_SEQUENCE MatrixReg,
           (ALIGNVreror (v256i1 (EXTRACT_SUBREG MatrixReg:$falsev, sub_v0)), (v256i1 (EXTRACT_SUBREG MatrixReg:$truev, sub_v0)), (SLLWri SingleReg:$cc, 6)), sub_v0,
           (ALIGNVrorer (v256i1 (EXTRACT_SUBREG MatrixReg:$falsev, sub_v1)), (v256i1 (EXTRACT_SUBREG MatrixReg:$truev, sub_v1)), (SLLWri SingleReg:$cc, 6)), sub_v1,
           (ALIGNVreror (v256i1 (EXTRACT_SUBREG MatrixReg:$falsev, sub_v2)), (v256i1 (EXTRACT_SUBREG MatrixReg:$truev, sub_v2)), (SLLWri SingleReg:$cc, 6)), sub_v2,
           (ALIGNVrorer (v256i1 (EXTRACT_SUBREG MatrixReg:$falsev, sub_v3)), (v256i1 (EXTRACT_SUBREG MatrixReg:$truev, sub_v3)), (SLLWri SingleReg:$cc, 6)), sub_v3
           )>;

defm : SELECTCONDW<(i32 i32:$truev), (i32 i32:$falsev), (i32 Wrapped32:$truev), (i32 Wrapped32:$falsev)>;
defm : SELECTCONDW<(i64 i64:$truev), (i64 i64:$falsev), (i64 Wrapped64:$truev), (i64 Wrapped64:$falsev)>;
defm : SELECTCONDW<(KVXWrapper tglobaladdr:$truev), (KVXWrapper tglobaladdr:$falsev), (i64 SingleReg:$truev), (i64 SingleReg:$falsev)>;

// TODO: i64 (select (i32 setcc:$v), -1, 0) should be a simple NEGD $v

multiclass SELECTCONDD<SDNode ntrue, SDNode nfalse, SDNode itrue, SDNode ifalse>
{
        def : Pat<(select (i32 (seteq i64:$val, (i64 0))), ntrue, nfalse),
                (SELECTp SingleReg:$val, itrue, ifalse, scalarcond_deqz)>;

        def : Pat<(select (i32 (setne i64:$val, (i64 0))), ntrue, nfalse),
                (SELECTp SingleReg:$val, itrue, ifalse, scalarcond_dnez)>;

        def : Pat<(select (i32 (setlt i64:$val, (i64 0))), ntrue, nfalse),
                (SELECTp SingleReg:$val, itrue, ifalse, scalarcond_dltz)>;

        def : Pat<(select (i32 (setgt i64:$val, (i64 -1))), ntrue, nfalse),
                (SELECTp SingleReg:$val, itrue, ifalse, scalarcond_dgez)>;

        def : Pat<(select (i32 (setlt i64:$val, (i64 1))), ntrue, nfalse),
                (SELECTp SingleReg:$val, itrue, ifalse, scalarcond_dlez)>;

        def : Pat<(select (i32 (setgt i64:$val, (i64 0))), ntrue, nfalse),
                (SELECTp SingleReg:$val, itrue, ifalse, scalarcond_dgtz)>;

        def : Pat<(select (i32 (seteq (and i64:$val, (i64 1)), (i64 0))), ntrue, nfalse),
                (SELECTp SingleReg:$val, itrue, ifalse, scalarcond_even)>;

        def : Pat<(select i64:$cmp, ntrue, nfalse),
                (SELECTp SingleReg:$cmp, itrue, ifalse, scalarcond_dnez)>;
}

defm : SELECTCONDD<(i32 i32:$truev), (i32 i32:$falsev), (i32 Wrapped32:$truev), (i32 Wrapped32:$falsev)>;
defm : SELECTCONDD<(i64 i64:$truev), (i64 i64:$falsev), (i64 Wrapped64:$truev), (i64 Wrapped64:$falsev)>;
defm : SELECTCONDD<(KVXWrapper tglobaladdr:$truev), (KVXWrapper tglobaladdr:$falsev), (i64 SingleReg:$truev), (i64 SingleReg:$falsev)>;

def : Pat<(i1 (trunc i64:$param)),  (COPY SingleReg:$param)>;
def : Pat<(i8 (trunc i64:$param)),  (COPY SingleReg:$param)>;
def : Pat<(i16 (trunc i64:$param)), (COPY SingleReg:$param)>;
def : Pat<(i32 (trunc i64:$param)), (COPY SingleReg:$param)>;

def : Pat<(i1 (trunc i32:$param)),  (COPY SingleReg:$param)>;
def : Pat<(i8 (trunc i32:$param)),  (COPY SingleReg:$param)>;
def : Pat<(i16 (trunc i32:$param)), (COPY SingleReg:$param)>;

def : Pat<(i1 (trunc i16:$param)),  (COPY SingleReg:$param)>;
def : Pat<(i8 (trunc i16:$param)),  (COPY SingleReg:$param)>;

def : Pat<(i1 (trunc i8:$param)),   (COPY SingleReg:$param)>;

//===----------------------------------------------------------------------===//
// Vector patterns.
//===----------------------------------------------------------------------===//
// TODO: Legalize splat_vector and replace all custom splats using build_vector
def v2_splat : PatFrag<(ops node:$i), (build_vector node:$i, node:$i)>;
def v2_splat_1 : PatFrags<(ops), [(v2_splat (i32 1)), (v2_splat (i64 1))]>;
def v2_splat_15 : PatFrags<(ops), [(v2_splat (i32 15)), (v2_splat (i64 15))]>;
def v2_splat_31 : PatFrags<(ops), [(v2_splat (i32 31)), (v2_splat (i64 31))]>;

def v3_splat : PatFrag<(ops node:$i), (build_vector node:$i, node:$i, node:$i, (i32 undef))>;
def v3_splat_1 : PatFrags<(ops), [(v3_splat (i32 1)), (v3_splat (i64 1))]>;

def v4_splat : PatFrag<(ops node:$i), (build_vector node:$i, node:$i, node:$i, node:$i)>;
def v4_splat_1 : PatFrags<(ops), [(v4_splat (i32 1)), (v4_splat (i64 1))]>;
def v4_splat_15 : PatFrags<(ops), [(v4_splat (i32 15)), (v4_splat (i64 15))]>;

def v8_splat : PatFrag<(ops node:$i), (build_vector node:$i, node:$i, node:$i, node:$i, node:$i, node:$i, node:$i, node:$i)>;

def ZEXT_VEC2_SETCC_Pat : PatFrags<(ops node:$lhs, node:$rhs),
        [(or node:$lhs, node:$rhs), (and (or node:$lhs, node:$rhs), v2_splat_1)]>;

def ZEXT_VEC4_SETCC_Pat : PatFrags<(ops node:$lhs, node:$rhs),
        [(or node:$lhs, node:$rhs), (and (or node:$lhs, node:$rhs), v4_splat_1)]>;

def get_not_imm : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(~N->getSExtValue(), SDLoc(N), N->getValueType(0));
}]>;


def mod_16_imm_64 : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(N->getZExtValue() % 16, SDLoc(N), MVT::i64);
}]>;

def mod_32_imm_64 : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(N->getZExtValue() % 32, SDLoc(N), MVT::i64);
}]>;

def imm32s_sub_1 : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(N->getSExtValue() -1, SDLoc(N), MVT::i32);
}]>;

def imm32u_sub_1 : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(N->getZExtValue() -1, SDLoc(N), MVT::i32);
}]>;

def build_imm_vec : SDNodeXForm<build_vector, [{
  return KVX_LOW::buildImmVector(*N, *CurDAG, false);
}]>;

def build_imm_vec_neg : SDNodeXForm<build_vector, [{
  return KVX_LOW::buildImmVector(*N, *CurDAG, false, -1);
}]>;

def build_fpimm_vec : SDNodeXForm<build_vector, [{
  return KVX_LOW::buildImmVector(*N, *CurDAG, true);
}]>;

def build_fpimm_vec_neg0 : SDNodeXForm<build_vector, [{
  return KVX_LOW::buildImmVector(*N, *CurDAG, true, 1);
}]>;

def build_fpimm_vec_neg1 : SDNodeXForm<build_vector, [{
  return KVX_LOW::buildImmVector(*N, *CurDAG, true, 2);
}]>;

def is_imm_vec : PatLeaf<(build_vector), [{
  return cast<BuildVectorSDNode>(N)->isConstant();
}], build_imm_vec>;

def is_imm_vec_ri37 : PatLeaf<(build_vector), [{
   return KVX_LOW::isKVXSplat32ImmVec(N, CurDAG, false);
}], build_imm_vec>;

def is_imm_vec_leq1bit : PatLeaf<(build_vector), [{
  return KVX_LOW::isImmVecOfLeqNbits(N, CurDAG, 1);
}], build_imm_vec>;

def is_imm_vec_leq2bits : PatLeaf<(build_vector), [{
   return KVX_LOW::isImmVecOfLeqNbits(N, CurDAG, 2);
}], build_imm_vec>;

def is_imm_vec_leq3bits : PatLeaf<(build_vector), [{
   return KVX_LOW::isImmVecOfLeqNbits(N, CurDAG, 3);
}], build_imm_vec>;

def is_imm_vec_leq4bits : PatLeaf<(build_vector), [{
   return KVX_LOW::isImmVecOfLeqNbits(N, CurDAG, 4);
}], build_imm_vec>;


def is_imm_vec_kvx_splat32_ : PatLeaf<(build_vector), [{
   return KVX_LOW::isKVXSplat32ImmVec(N, CurDAG, false);
}], build_imm_vec>;

def is_imm_vec_kvx_splat32_at : PatLeaf<(build_vector), [{
   return KVX_LOW::isKVXSplat32ImmVec(N, CurDAG, true);
}], build_imm_vec>;

def imm_vec_1bit_splat_ :  PatLeaf<(build_vector), [{
  return KVX_LOW::isImmVecOfLeqNbits(N, CurDAG, 1) &&
         KVX_LOW::isKVXSplat32ImmVec(N, CurDAG, false);
}], build_imm_vec>;

def imm_vec_1bit_splat_at :  PatLeaf<(build_vector), [{
  return KVX_LOW::isImmVecOfLeqNbits(N, CurDAG, 1) &&
         KVX_LOW::isKVXSplat32ImmVec(N, CurDAG, true);
}], build_imm_vec>;

def imm_vec_2bit_splat_ :  PatLeaf<(build_vector), [{
  return KVX_LOW::isImmVecOfLeqNbits(N, CurDAG, 2) &&
         KVX_LOW::isKVXSplat32ImmVec(N, CurDAG, false);
}], build_imm_vec>;

def imm_vec_2bit_splat_at :  PatLeaf<(build_vector), [{
  return KVX_LOW::isImmVecOfLeqNbits(N, CurDAG, 2) &&
         KVX_LOW::isKVXSplat32ImmVec(N, CurDAG, true);
}], build_imm_vec>;

def imm_vec_3bit_splat_ :  PatLeaf<(build_vector), [{
  return KVX_LOW::isImmVecOfLeqNbits(N, CurDAG, 3) &&
         KVX_LOW::isKVXSplat32ImmVec(N, CurDAG, false);
}], build_imm_vec>;

def imm_vec_3bit_splat_at :  PatLeaf<(build_vector), [{
  return KVX_LOW::isImmVecOfLeqNbits(N, CurDAG, 3) &&
         KVX_LOW::isKVXSplat32ImmVec(N, CurDAG, true);
}], build_imm_vec>;

def imm_vec_4bit_splat_ :  PatLeaf<(build_vector), [{
  return KVX_LOW::isImmVecOfLeqNbits(N, CurDAG, 4) &&
         KVX_LOW::isKVXSplat32ImmVec(N, CurDAG, false);
}], build_imm_vec>;

def imm_vec_4bit_splat_at :  PatLeaf<(build_vector), [{
  return KVX_LOW::isImmVecOfLeqNbits(N, CurDAG, 4) &&
         KVX_LOW::isKVXSplat32ImmVec(N, CurDAG, true);
}], build_imm_vec>;

multiclass KVX_VSELECT_SingleReg<ValueType vt, ValueType ct, KVX_INSTRUCTION instRR> {
def : Pat<(vt (vselect ct:$c, vt:$true, vt:$false)),
          (vt (instRR SingleReg:$c, SingleReg:$true, SingleReg:$false, simplecond_even))>;
}

defm : KVX_VSELECT_SingleReg <v2f16, v2i16, CMOVEHQ>;
defm : KVX_VSELECT_SingleReg <v2i16, v2i16, CMOVEHQ>;
defm : KVX_VSELECT_SingleReg <v4f16, v4i16, CMOVEHQ>;
defm : KVX_VSELECT_SingleReg <v4i16, v4i16, CMOVEHQ>;
defm : KVX_VSELECT_SingleReg <v2f32, v2i32, CMOVEWP>;
defm : KVX_VSELECT_SingleReg <v2i32, v2i32, CMOVEWP>;

// For v4f32 and v4i32 vselect
multiclass KVX_VSELECT_PairedReg<ValueType vt, ValueType halfvt> {
def : Pat<(vt (vselect v4i32:$c, vt:$true, vt:$false)),
          (vt (REG_SEQUENCE PairedReg,
              (halfvt (CMOVEWP (v2i32 (EXTRACT_SUBREG PairedReg:$c, sub_s0)),
                               (halfvt (EXTRACT_SUBREG PairedReg:$true, sub_s0)),
                               (halfvt (EXTRACT_SUBREG PairedReg:$false, sub_s0)),
                               simplecond_even)),
              sub_s0,
              (halfvt (CMOVEWP (v2i32 (EXTRACT_SUBREG PairedReg:$c, sub_s1)),
                               (halfvt (EXTRACT_SUBREG PairedReg:$true, sub_s1)),
                               (halfvt (EXTRACT_SUBREG PairedReg:$false, sub_s1)),
                               simplecond_even)),
              sub_s1))>;
}
defm : KVX_VSELECT_PairedReg <v4f32, v2f32>;
defm : KVX_VSELECT_PairedReg <v4i32, v2i32>;

// v2i8
def : Pat<(v2i8 (is_imm_vec:$IMM)), (MAKEi16 (build_imm_vec $IMM))>;
def : Pat<(v2i8 (build_vector i32:$v0, i32:$v1)), (INSF SingleReg:$v0, SingleReg:$v1, 15, 8)>;

def : Pat<(v2i8 (trunc v2i16:$v)), (SBMM8ri37 $v, 0x401)>;
def : Pat<(v2i8 (trunc v2i32:$v)), (SBMM8ri37 $v, 0x1001)>;
def : Pat<(v2i8 (trunc v2i64:$v)), (INSF (i64 (EXTRACT_SUBREG PairedReg:$v, sub_s0)),
                                         (i64 (EXTRACT_SUBREG PairedReg:$v, sub_s1)),
                                         15, 8)>;

def : Pat<(v2i8 (trunc (v2i16 (build_vector i32:$s0, i32:$s1)))), (INSF SingleReg:$s0, SingleReg:$s1, 15, 8)>;
def : Pat<(v2i8 (trunc (v2i32 (build_vector i32:$s0, i32:$s1)))), (INSF SingleReg:$s0, SingleReg:$s1, 15, 8)>;
def : Pat<(v2i8 (trunc (v2i64 (build_vector i64:$s0, i64:$s1)))), (INSF SingleReg:$s0, SingleReg:$s1, 15, 8)>;

// v2i16
def : Pat<(v2i16 (build_vector Signed16:$v0, (i32 0))), (MAKEi16 Signed16:$v0)>;
def : Pat<(v2i16 (is_imm_vec:$IMM)), (MAKEi43 (build_imm_vec $IMM))>;
def : Pat<(v2i16 (build_vector (i32(vector_extract v2i16:$v, 0)), (i32(vector_extract v2i16:$v, 0)))),
          (INSF SingleReg:$v, SingleReg:$v, 31, 16)>;
def : Pat<(v2i16 (build_vector (i32(vector_extract v2i16:$v0, 0)), (i32(vector_extract v2i16:$v1, 0)))),
          (INSF SingleReg:$v0, SingleReg:$v1, 31, 16)>;
def : Pat<(v2i16 (build_vector (i32(vector_extract v2i16:$v, 1)), (i32(vector_extract v2i16:$v, 0)))),
          (SBMM8ri64 SingleReg:$v, 0x02010804)>;
def : Pat<(v2i16 (build_vector (i32(vector_extract v2i16:$v, 1)), (i32(vector_extract v2i16:$v, 1)))),
          (SBMM8ri64 SingleReg:$v, 0x08040804)>;
def : Pat<(v2i16 (build_vector i32:$v0, i32:$v1)), (INSF SingleReg:$v0, SingleReg:$v1, 31, 16)>;

def : Pat<(v2i16 (trunc v2i32:$v)), (SBMM8ri37 $v, 0x20100201)>;
def : Pat<(v2i16 (trunc v2i64:$v)), (INSF (i64 (EXTRACT_SUBREG PairedReg:$v, sub_s0)),
                                         (i64 (EXTRACT_SUBREG PairedReg:$v, sub_s1)),
                                         31, 16)>;

def : Pat<(v2i16 (trunc (v2i32 (build_vector i64:$s0, i32:$s1)))), (INSF SingleReg:$s0, SingleReg:$s1, 31, 16)>;
def : Pat<(v2i16 (trunc (v2i64 (build_vector i64:$s0, i64:$s1)))), (INSF SingleReg:$s0, SingleReg:$s1, 31, 16)>;

// v2i32
def : Pat<(v2i32 (is_imm_vec_kvx_splat32_:$IMM)), (MAKEi43 (build_imm_vec $IMM))>;
def : Pat<(v2i32 (is_imm_vec:$IMM)), (MAKEi64 (build_imm_vec $IMM))>;
def : Pat<(v2i32 (build_vector i32:$v0, i32:$v1)), (INSF SingleReg:$v0, SingleReg:$v1, 63, 32)>;
def : Pat<(v2i32 (build_vector (i32(vector_extract v2i32:$v, 1)), (i32(vector_extract v2i32:$v, 0)))),
          (SBMM8ri64 SingleReg:$v, 0x0804020180402010)>;
def : Pat<(v2i32 (build_vector (i32(vector_extract v2i32:$v, 1)), (i32(vector_extract v2i32:$v, 1)))),
          (SBMM8ri64 SingleReg:$v, 0x8040201080402010)>;
def : Pat<(v2i32 (build_vector (i32(vector_extract v2i32:$v0, 1)), (i32(vector_extract v2i32:$v1, 0)))),
          (SBMM8ri64 (INSF SingleReg:$v0, SingleReg:$v1, 31, 0), 0x0804020180402010)>;

def : Pat<(v2i32 (trunc (v2i64 (build_vector i64:$s0, i64:$s1)))), (INSF SingleReg:$s0, SingleReg:$s1, 63, 32)>;
def : Pat<(v2i32 (trunc v2i64:$v)), (INSF (i64 (EXTRACT_SUBREG PairedReg:$v, sub_s0)),
                                         (i64 (EXTRACT_SUBREG PairedReg:$v, sub_s1)),
                                         63, 32)>;

// v3i16
def : Pat<(v4i16 (is_imm_vec_kvx_splat32_:$IMM)), (MAKEi43 (build_imm_vec $IMM))>;
def : Pat<(v4i16 (build_vector:$IMM (i32 imm), (i32 imm), (i32 imm), (i32 undef))), (MAKEi64 (build_imm_vec $IMM))>;
def : Pat<(v4i16 (build_vector i32:$v0, i32:$v1, i32:$v2, (i32 undef))),
          (INSF (INSF SingleReg:$v0, SingleReg:$v1, 31, 16), SingleReg:$v2, 47, 32)>;

// v4i8
def : Pat<(v4i8 (is_imm_vec:$IMM)), (MAKEi43 (build_imm_vec $IMM))>;
def : Pat<(v4i8 (build_vector i32:$v0, i32:$v1, i32:$v2, i32:$v3)),
          (INSF (INSF SingleReg:$v0, SingleReg:$v1, 15, 8), (INSF SingleReg:$v2, SingleReg:$v3, 15, 8), 31, 16)>;
def : Pat<(v4i8 (concat_vectors v2i8:$v0, v2i8:$v1)),
          (v4i8 (INSF SingleReg:$v0, SingleReg:$v1, 31, 16))>;
def : Pat<(v4i8 (trunc (v4i16 (build_vector i32:$s0, i32:$s1, i32:$s2, i32:$s3)))), (INSF
                                                                                         (INSF SingleReg:$s0, SingleReg:$s1, 15, 8),
                                                                                         (INSF SingleReg:$s2, SingleReg:$s3, 15, 8),
                                                                                         31, 16)>;

def : Pat<(v4i8 (trunc (v4i32 (build_vector i32:$s0, i32:$s1, i32:$s2, i32:$s3)))), (INSF
                                                                                         (INSF SingleReg:$s0, SingleReg:$s1, 15, 8),
                                                                                         (INSF SingleReg:$s2, SingleReg:$s3, 15, 8),
                                                                                         31, 16)>;
def : Pat<(v4i8 (trunc (v4i64 (build_vector i64:$s0, i64:$s1, i64:$s2, i64:$s3)))), (INSF
                                                                                         (INSF SingleReg:$s0, SingleReg:$s1, 15, 8),
                                                                                         (INSF SingleReg:$s2, SingleReg:$s3, 15, 8),
                                                                                         31, 16)>;
def : Pat<(v4i8 (trunc v4i16:$v)), (SBMM8ri37 $v, 0x40100401)>;
def : Pat<(v4i8 (trunc v4i32:$v)), (INSF (SBMM8ri37 (i64(EXTRACT_SUBREG PairedReg:$v, sub_s0)), 0x1001),
                                         (SBMM8ri37 (i64(EXTRACT_SUBREG PairedReg:$v, sub_s1)), 0x1001),
                                         31, 16)>;
def : Pat<(v4i8 (trunc v4i64:$v)), (INSF (INSF (i64 (EXTRACT_SUBREG QuadReg:$v, sub_s0)),
                                               (i64 (EXTRACT_SUBREG QuadReg:$v, sub_s1)),
                                               15, 8),
                                          (INSF (i64 (EXTRACT_SUBREG QuadReg:$v, sub_s2)),
                                                (i64 (EXTRACT_SUBREG QuadReg:$v, sub_s3)),
                                               15, 8),
                                         31, 16)>;

// v4i16
def : Pat<(v4i16 (is_imm_vec_kvx_splat32_:$IMM)), (MAKEi43 (build_imm_vec $IMM))>;
def : Pat<(v4i16 (is_imm_vec:$IMM)), (MAKEi64 (build_imm_vec $IMM))>;
def : Pat<(v4i16 (v4_splat (i32 (vector_extract v4i16:$v, 0)))),
          (SBMM8ri64 SingleReg:$v, 0x0201020102010201)>;
def : Pat<(v4i16 (v4_splat i32:$v)),
          (SBMM8ri64 SingleReg:$v, 0x0201020102010201)>;
def : Pat<(v4i16 (v4_splat (i32 (vector_extract v4i16:$v, 1)))),
          (SBMM8ri64 SingleReg:$v, 0x0804080408040804)>;
def : Pat<(v4i16 (v4_splat (i32 (srl i32:$v, (i64 16))))),
          (SBMM8ri64 SingleReg:$v, 0x0804080408040804)>;
def : Pat<(v4i16 (v4_splat (i32 (trunc (i64 (srl i64:$v, (i64 16))))))),
          (SBMM8ri64 SingleReg:$v, 0x0804080408040804)>;
def : Pat<(v4i16 (v4_splat (i32 (vector_extract v4i16:$v, 2)))),
          (SBMM8ri64 SingleReg:$v, 0x2010201020102010)>;
def : Pat<(v4i16 (v4_splat (i32 (trunc (i64 (srl i64:$v, (i64 32))))))),
          (SBMM8ri64 SingleReg:$v, 0x2010201020102010)>;
def : Pat<(v4i16 (v4_splat (i32 (vector_extract v4i16:$v, 3)))),
          (SBMM8ri64 SingleReg:$v, 0x8040804080408040)>;
def : Pat<(v4i16 (v4_splat (i32 (trunc (i64 (srl i64:$v, (i64 48))))))),
          (SBMM8ri64 SingleReg:$v, 0x8040804080408040)>;
def : Pat<(v4i16 (build_vector i32:$v0, i32:$v1, i32:$v2, i32:$v3)),
          (INSF (INSF SingleReg:$v0, SingleReg:$v1, 31, 16), (INSF SingleReg:$v2, SingleReg:$v3, 31, 16), 63, 32)>;
def : Pat<(v4i16 (concat_vectors v2i16:$v0, v2i16:$v1)),
          (v4i16 (INSF SingleReg:$v0, SingleReg:$v1, 63, 32))>;

def : Pat<(v4i16 (trunc v4i32:$v)), (INSF (SBMM8ri37 (i64(EXTRACT_SUBREG PairedReg:$v, sub_s0)), 0x20100201),
                                         (SBMM8ri37 (i64(EXTRACT_SUBREG PairedReg:$v, sub_s1)), 0x20100201),
                                         63, 32)>;
def : Pat<(v4i16 (trunc v4i64:$v)), (INSF (INSF (i64 (EXTRACT_SUBREG QuadReg:$v, sub_s0)),
                                               (i64 (EXTRACT_SUBREG QuadReg:$v, sub_s1)),
                                               31, 16),
                                          (INSF (i64 (EXTRACT_SUBREG QuadReg:$v, sub_s2)),
                                                (i64 (EXTRACT_SUBREG QuadReg:$v, sub_s3)),
                                               31, 16),
                                         63, 32)>;

def : Pat<(v4i16 (trunc (v4i32 (build_vector i32:$s0, i32:$s1, i32:$s2, i32:$s3)))), (INSF
                                                                                         (INSF SingleReg:$s0, SingleReg:$s1, 31, 16),
                                                                                         (INSF SingleReg:$s2, SingleReg:$s3, 31, 16),
                                                                                         63, 32)>;
def : Pat<(v4i16 (trunc (v4i64 (build_vector i64:$s0, i64:$s1, i64:$s2, i64:$s3)))), (INSF
                                                                                         (INSF SingleReg:$s0, SingleReg:$s1, 31, 16),
                                                                                         (INSF SingleReg:$s2, SingleReg:$s3, 31, 16),
                                                                                         63, 32)>;

// v8i8
def : Pat<(v8i8 (is_imm_vec:$IMM)), (MAKEi64 (build_imm_vec $IMM))>;
def : Pat<(v8i8 (build_vector i32:$v0, i32:$v1, i32:$v2, i32:$v3, i32:$v4, i32:$v5, i32:$v6, i32:$v7)),
          (INSF
          (INSF (INSF SingleReg:$v0, SingleReg:$v1, 15, 8), (INSF SingleReg:$v2, SingleReg:$v3, 15, 8), 31, 16),
          (INSF (INSF SingleReg:$v4, SingleReg:$v5, 15, 8), (INSF SingleReg:$v6, SingleReg:$v7, 15, 8), 31, 16),
          63, 32)>;

def : Pat<(v8i8 (v8_splat i32:$s)), (SBMM8ri64 SingleReg:$s, 0x0101010101010101)>;
def : Pat<(v8i8 (concat_vectors v4i8:$v0, v4i8:$v1)),
  (INSF  SingleReg:$v0, SingleReg:$v1, 63, 32)>;

// v2i32
def : Pat<(extractelt (v2i32 SingleReg:$v), 0), (COPY SingleReg:$v)>;
def : Pat<(extractelt (v2i32 SingleReg:$v), 1), (SRADri SingleReg :$v, (i64 32))>;
def : Pat<(i32 (vector_extract v2i32:$v, i64:$p)), (SRLDrr SingleReg:$v, (SLLWri SingleReg:$p, 6))>;

// v2i16
def : Pat<(i32 (vector_extract v2i16:$v, 0)), (ZXHD SingleReg:$v)>;
def : Pat<(i32 (vector_extract v2i16:$v, 1)), (SRLWri SingleReg:$v, (i64 16))>;
def : Pat<(i32 (vector_extract v2i16:$v, i64:$p)), (ZXHD (SRLWrr SingleReg:$v, (SLLWri SingleReg:$p, 4)))>;

def : Pat<(i32 (sext_inreg (vector_extract v2i16:$v, 0), i16)), (SXHD SingleReg:$v)>;
def : Pat<(i32 (sext_inreg (vector_extract v2i16:$v, 1), i16)), (SRAWri SingleReg:$v, (i64 16))>;
def : Pat<(i32 (sext_inreg (vector_extract v2i16:$v, i64:$p), i16)), (SXHD (SRLWrr SingleReg:$v, (SLLWri SingleReg:$p, 4)))>;

def : Pat<(i64 (sext_inreg (i64 (anyext (i32 (vector_extract v2i16:$v, 0)))), i16)), (SXHD SingleReg:$v)>;
def : Pat<(i64 (sext_inreg (i64 (anyext (i32 (vector_extract v2i16:$v, 1)))), i16)), (EXTFS SingleReg:$v, 31, 16)>;
def : Pat<(i64 (sext_inreg (vector_extract v2i16:$v, i64:$p), i16)), (SXHD (SRLWrr SingleReg:$v, (SLLWri SingleReg:$p, 4)))>;

// v4i16
def : Pat<(i32 (vector_extract (v4i16 SingleReg:$v), 0)), (ZXHD SingleReg:$v)>;
def : Pat<(i32 (vector_extract (v4i16 SingleReg:$v), 1)), (SRLWri SingleReg:$v, 16)>;
def : Pat<(i32 (vector_extract (v4i16 SingleReg:$v), 2)), (EXTFZ SingleReg:$v, 47, 32)>;
def : Pat<(i32 (vector_extract (v4i16 SingleReg:$v), 3)), (SRLDri SingleReg:$v, (i64 48))>;
def : Pat<(i32 (vector_extract v4i16:$v, i64:$p)), (ZXHD (SRLDrr SingleReg:$v, (SLLWri SingleReg:$p, 4)))>;

def : Pat<(i32 (sext_inreg (vector_extract (v4i16 SingleReg:$v), 0), i16)), (SXHD SingleReg:$v)>;
def : Pat<(i32 (sext_inreg (vector_extract (v4i16 SingleReg:$v), 1), i16)), (EXTFS SingleReg:$v, 31, 16)>;
def : Pat<(i32 (sext_inreg (vector_extract (v4i16 SingleReg:$v), 2), i16)), (EXTFS SingleReg:$v, 47, 32)>;
def : Pat<(i32 (sext_inreg (vector_extract (v4i16 SingleReg:$v), 3), i16)), (SRADri SingleReg:$v, (i64 48))>;
def : Pat<(i32 (sext_inreg (vector_extract v4i16:$v, i64:$p), i16)), (ZXHD (SRLDrr SingleReg:$v, (SLLWri SingleReg:$p, 4)))>;

// v2i64
def : Pat<(v2i64 (build_vector i64:$v1, i64:$v2)),
  (INSERT_SUBREG
    (INSERT_SUBREG (v2i64 (IMPLICIT_DEF)), SingleReg:$v1, sub_s0),
    SingleReg:$v2, sub_s1
  )>;

def : Pat<(v4i32 (concat_vectors v2i32:$v0, v2i32:$v1)),
  (INSERT_SUBREG
    (INSERT_SUBREG (v4i32 (IMPLICIT_DEF)), SingleReg:$v0, sub_s0),
    SingleReg:$v1, sub_s1
  )>;

def : Pat<(extractelt (v2i64 PairedReg:$v), 0), (i64 (EXTRACT_SUBREG $v, sub_s0))>;
def : Pat<(extractelt (v2i64 PairedReg:$v), 1), (i64 (EXTRACT_SUBREG $v, sub_s1))>;
def : Pat<(i64 (vector_extract v2i64:$v, i64:$p)),
          (CMOVEDrr SingleReg:$p,
            (i64 (EXTRACT_SUBREG PairedReg:$v, sub_s0)),
            (i64 (EXTRACT_SUBREG PairedReg:$v, sub_s1)),
            scalarcond_odd
            )>;

// v4i64
def : Pat<(extractelt (v4i64 QuadReg:$v), 0), (i64 (EXTRACT_SUBREG $v, sub_s0))>;
def : Pat<(extractelt (v4i64 QuadReg:$v), 1), (i64 (EXTRACT_SUBREG $v, sub_s1))>;
def : Pat<(extractelt (v4i64 QuadReg:$v), 2), (i64 (EXTRACT_SUBREG $v, sub_s2))>;
def : Pat<(extractelt (v4i64 QuadReg:$v), 3), (i64 (EXTRACT_SUBREG $v, sub_s3))>;

def : Pat<(v4i64 (build_vector i64:$v1, i64:$v2, i64:$v3, i64:$v4)),
  (INSERT_SUBREG (INSERT_SUBREG (INSERT_SUBREG
    (INSERT_SUBREG (v4i64 (IMPLICIT_DEF)), $v1, sub_s0), $v2, sub_s1), $v3, sub_s2), $v4, sub_s3)>;

def : Pat<(v4i64 (concat_vectors v2i64:$v0, v2i64:$v1)),
  (INSERT_SUBREG (INSERT_SUBREG (v4i64 (IMPLICIT_DEF)), $v0, sub_p0), $v1, sub_p1)>;

// v2i32
def : Pat<(v2i32 (extract_subvector (v4i32 PairedReg:$v), (i64 0))),
          (v2i32 (EXTRACT_SUBREG $v, sub_s0))>;

def : Pat<(v2i32 (extract_subvector (v4i32 PairedReg:$v), (i64 2))),
          (v2i32 (EXTRACT_SUBREG $v, sub_s1))>;

def : Pat<(v2i64 (extract_subvector (v4i64 QuadReg:$v), (i64 0))),
          (v2i64 (EXTRACT_SUBREG $v, sub_p0))>;

def : Pat<(v2i64 (extract_subvector (v4i64 QuadReg:$v), (i64 2))),
          (v2i64 (EXTRACT_SUBREG $v, sub_p1))>;

// v4i32
def : Pat<(extractelt (v4i32 PairedReg:$v), 0), (i32 (EXTRACT_SUBREG $v, sub_s0))>;
def : Pat<(extractelt (v4i32 PairedReg:$v), 1), (SRLDri (i32 (EXTRACT_SUBREG $v, sub_s0)), (i64 32))>;
def : Pat<(extractelt (v4i32 PairedReg:$v), 2), (i32 (EXTRACT_SUBREG $v, sub_s1))>;
def : Pat<(extractelt (v4i32 PairedReg:$v), 3), (SRLDri (i32 (EXTRACT_SUBREG $v, sub_s1)), (i64 32))>;

def : Pat<(v4i32 (trunc v4i64:$v)), (REG_SEQUENCE PairedReg,
                                      (INSF (i64 (EXTRACT_SUBREG QuadReg:$v, sub_s0)),
                                            (i64 (EXTRACT_SUBREG QuadReg:$v, sub_s1)),
                                            63, 32),
                                      sub_s0,
                                      (INSF (i64 (EXTRACT_SUBREG QuadReg:$v, sub_s2)),
                                            (i64 (EXTRACT_SUBREG QuadReg:$v, sub_s3)),
                                            63, 32),
                                      sub_s1)>;

// v2i8
def : Pat<(i32 (vector_extract (v2i8 SingleReg:$v), 0)), (ZXBD SingleReg:$v)>;
def : Pat<(i32 (vector_extract (v2i8 SingleReg:$v), 1)), (EXTFZ SingleReg:$v, 15, 8)>;
def : Pat<(i32 (vector_extract (v2i8 SingleReg:$v), i64:$idx)), (ZXBD (SRLWri SingleReg:$v, (SLLWri SingleReg:$idx, 3)))>;

// v4i8
def : Pat<(i32 (vector_extract (v4i8 SingleReg:$v), 0)), (ZXBD SingleReg:$v)>;
def : Pat<(i32 (vector_extract (v4i8 SingleReg:$v), 1)), (EXTFZ SingleReg:$v, 15, 8)>;
def : Pat<(i32 (vector_extract (v4i8 SingleReg:$v), 2)), (EXTFZ SingleReg:$v, 23, 16)>;
def : Pat<(i32 (vector_extract (v4i8 SingleReg:$v), 3)), (SRLWri SingleReg:$v, 24)>;
def : Pat<(i32 (vector_extract (v4i8 SingleReg:$v), i64:$idx)), (ZXBD (SRLWri SingleReg:$v, (SLLWri SingleReg:$idx, 3)))>;

def : Pat<(v2i8 (extract_subvector (v4i8 SingleReg:$v), (i64 0))),(v2i8 (ZXHD SingleReg:$v))>;
def : Pat<(v2i8 (extract_subvector (v4i8 SingleReg:$v), (i64 2))),(v2i8 (SRLWri SingleReg:$v, 16))>;

// v8i8
def : Pat<(i32 (vector_extract (v8i8 SingleReg:$v), 0)), (ZXBD SingleReg:$v)>;
def : Pat<(i32 (vector_extract (v8i8 SingleReg:$v), 1)), (EXTFZ SingleReg:$v, 15, 8)>;
def : Pat<(i32 (vector_extract (v8i8 SingleReg:$v), 2)), (EXTFZ SingleReg:$v, 23, 16)>;
def : Pat<(i32 (vector_extract (v8i8 SingleReg:$v), 3)), (SRLWri SingleReg:$v, 24)>;
def : Pat<(i32 (vector_extract (v8i8 SingleReg:$v), 4)), (EXTFZ SingleReg:$v, 39, 32)>;
def : Pat<(i32 (vector_extract (v8i8 SingleReg:$v), 5)), (EXTFZ SingleReg:$v, 47, 40)>;
def : Pat<(i32 (vector_extract (v8i8 SingleReg:$v), 6)), (EXTFZ SingleReg:$v, 55, 48)>;
def : Pat<(i32 (vector_extract (v8i8 SingleReg:$v), 7)), (SRLDri SingleReg:$v, (i64 56))>;
def : Pat<(i32 (vector_extract (v8i8 SingleReg:$v), i64:$idx)), (ZXBD (SRLDri SingleReg:$v, (SLLWri SingleReg:$idx, 3)))>;

def : Pat<(v2i8 (extract_subvector (v8i8 SingleReg:$v), (i64 0))),(v2i8 (ZXHD SingleReg:$v))>;
def : Pat<(v2i8 (extract_subvector (v8i8 SingleReg:$v), (i64 2))),(v2i8 (SRLWri SingleReg:$v, 16))>;
def : Pat<(v2i8 (extract_subvector (v8i8 SingleReg:$v), (i64 4))),(v2i8 (EXTFZ SingleReg:$v, 47,32))>;
def : Pat<(v2i8 (extract_subvector (v8i8 SingleReg:$v), (i64 6))),(v2i8 (SRLDri SingleReg:$v, 48))>;

def : Pat<(v4i8 (extract_subvector (v8i8 SingleReg:$v), (i64 0))),(v4i8 (ZXWD SingleReg:$v))>;
def : Pat<(v4i8 (extract_subvector (v8i8 SingleReg:$v), (i64 4))),(v4i8 (SRLDri SingleReg:$v, 32))>;

def : Pat<(v8i8 (v8_splat (i32 SingleReg:$s))), (SBMM8ri64 SingleReg:$s, 0x0101010101010101)>;

// insert_vector_element
// v2i16
def : Pat<(v2i16 (insertelt v2i16:$to, i16:$e, i64:$idx)),
          (CMOVEDrr SingleReg:$idx,
            (INSF SingleReg:$to, SingleReg:$e, 31, 16),
            (INSF SingleReg:$to, SingleReg:$e, 15, 0),
            scalarcond_even)>;

// v2i32
def : Pat<(v2i32 (insertelt v2i32:$to, i32:$e, i64:$idx)),
          (CMOVEDrr SingleReg:$idx,
            (INSF SingleReg:$to, SingleReg:$e, 63, 32),
            (INSF SingleReg:$to, SingleReg:$e, 31, 0),
            scalarcond_even)>;

// v4i16
def : Pat<(v4i16 (insertelt v4i16:$to, i16:$e, i64:$idx)),
              (CMOVEHQ
                (COMPNHQ
                  (MAKEi64 0x3000200010000),
                  (INSF
                    (INSF SingleReg:$idx, SingleReg:$idx, 31, 16),
                    (INSF SingleReg:$idx, SingleReg:$idx, 31, 16),
                    63, 32),
                  comparison_eq),
                  SingleReg:$to,
                  (INSF
                    (INSF SingleReg:$e, SingleReg:$e, 31, 16),
                    (INSF SingleReg:$e, SingleReg:$e, 31, 16),
                    63, 32),
                simplecond_nez)>;

// v4i32
def : Pat<(v4i32 (insertelt v4i32:$to, i32:$e, 0)),
            (REG_SEQUENCE PairedReg,
              (INSF (v2i32(EXTRACT_SUBREG PairedReg:$to, sub_s0)), SingleReg:$e, 31, 0),
              sub_s0,
              (v2i32 (EXTRACT_SUBREG PairedReg:$to, sub_s1)),
              sub_s1)>;

def : Pat<(v4i32 (insertelt v4i32:$to, i32:$e, (i64 1))),
            (REG_SEQUENCE PairedReg,
              (INSF (v2i32(EXTRACT_SUBREG PairedReg:$to, sub_s0)), SingleReg:$e, 63, 32),
              sub_s0,
              (v2i32 (EXTRACT_SUBREG PairedReg:$to, sub_s1)),
              sub_s1)>;

def : Pat<(v4i32 (insertelt v4i32:$to, i32:$e, (i64 2))),
            (REG_SEQUENCE PairedReg,
              (v2i32 (EXTRACT_SUBREG PairedReg:$to, sub_s0)),
              sub_s0,
              (INSF (v2i32 (EXTRACT_SUBREG PairedReg:$to, sub_s1)), SingleReg:$e, 31, 0),
              sub_s1)>;

def : Pat<(v4i32 (insertelt v4i32:$to, i32:$e, (i64 3))),
            (REG_SEQUENCE PairedReg,
              (v2i32 (EXTRACT_SUBREG PairedReg:$to, sub_s0)),
              sub_s0,
              (INSF (v2i32 (EXTRACT_SUBREG PairedReg:$to, sub_s1)), SingleReg:$e, 63, 32),
              sub_s1)>;

def : Pat<(v4i32 (insertelt v4i32:$to, i32:$e, i64:$idx)),
            (REG_SEQUENCE PairedReg,
              (CMOVEWP
                (COMPNWP (MAKEi64 0x100000000), (INSF SingleReg:$idx, SingleReg:$idx, 63, 31), comparison_eq),
                (v2i32 (EXTRACT_SUBREG PairedReg:$to, sub_s0)),
                (INSF SingleReg:$e, SingleReg:$e, 63, 31),
                simplecond_eqz
               ),
               sub_s0,
              (CMOVEWP
                (COMPNWP (MAKEi64 0x300000002), (INSF SingleReg:$idx, SingleReg:$idx, 63, 31), comparison_eq),
                (v2i32 (EXTRACT_SUBREG PairedReg:$to, sub_s1)),
                (INSF SingleReg:$e, SingleReg:$e, 63, 31),
                simplecond_eqz
               ),
               sub_s1)>;

// v2i64
def : Pat<(v2i64 (insertelt v2i64:$to, i64:$e, i64:$idx)),
          (REG_SEQUENCE PairedReg,
            (CMOVEDrr SingleReg:$idx, (i64 (EXTRACT_SUBREG PairedReg:$to, sub_s0)), SingleReg:$e, scalarcond_even),
            sub_s0,
            (CMOVEDrr SingleReg:$idx, (i64 (EXTRACT_SUBREG PairedReg:$to, sub_s1)), SingleReg:$e, scalarcond_odd),
            sub_s1 )>;

// v2i64
def : Pat<(v4i64 (insertelt v4i64:$to, i64:$e, i64:$idx)),
          (REG_SEQUENCE QuadReg,
            (CMOVEDrr (COMPDri10 SingleReg:$idx, 0, comparison_eq), (i64 (EXTRACT_SUBREG QuadReg:$to, sub_s0)), SingleReg:$e, scalarcond_odd),
            sub_s0,
            (CMOVEDrr (COMPDri10 SingleReg:$idx, 1, comparison_eq), (i64 (EXTRACT_SUBREG QuadReg:$to, sub_s1)), SingleReg:$e, scalarcond_odd),
            sub_s1,
            (CMOVEDrr (COMPDri10 SingleReg:$idx, 2, comparison_eq), (i64 (EXTRACT_SUBREG QuadReg:$to, sub_s2)), SingleReg:$e, scalarcond_odd),
            sub_s2,
            (CMOVEDrr (COMPDri10 SingleReg:$idx, 3, comparison_eq), (i64 (EXTRACT_SUBREG QuadReg:$to, sub_s3)), SingleReg:$e, scalarcond_odd),
            sub_s3)>;


//===----------------------------------------------------------------------===//
//  Synthetic Instructions - Patterns
//===----------------------------------------------------------------------===//

// NEGD, see KVXInstrInfo.td
// NEGHQ, see KVXInstrInfo.td for v4i16
def : Pat<(vineg v2i16:$v), (NEGHQ SingleReg:$v)>;

// NEGW, see KVXInstrInfo.td
// NEGWP, see KVXInstrInfo.td
def : Pat<(sub (v2i32 (v2_splat (i32 0))), v2i32:$r), (NEGWP SingleReg:$r)>;

// NOTW, see KVXInstrInfo.td for i32
def : Pat<(vnot v2i16:$v), (NOTW SingleReg:$v)>;
def : Pat<(vnot v4i8:$v), (NOTW SingleReg:$v)>;
def : Pat<(vnot v2i8:$v), (NOTW SingleReg:$v)>;

// NOTD, see KVXInstrInfo.td for i64
def : Pat<(vnot v2i32:$v), (NOTD SingleReg:$v)>;
def : Pat<(vnot v4i16:$v), (NOTD SingleReg:$v)>;
def : Pat<(vnot v8i8:$v), (NOTD SingleReg:$v)>;

def: Pat<(KVXJT tjumptable:$a), (MAKEi64 Wrapped64:$a)>;
def: Pat<(KVXJT_PCREL i64:$a), (PCRELmi64 SingleReg:$a)>;

// BITREVERSE
def: Pat<(i8 (bitreverse i8:$v)),     (SBMM8rr (MAKEi64 0x102040810204080), SingleReg:$v)>;
def: Pat<(v2i8 (bitreverse v2i8:$v)), (SBMM8rr (MAKEi64 0x102040810204080), SingleReg:$v)>;
def: Pat<(v4i8 (bitreverse v4i8:$v)), (SBMM8rr (MAKEi64 0x102040810204080), SingleReg:$v)>;
def: Pat<(v8i8 (bitreverse v8i8:$v)), (SBMM8rr (MAKEi64 0x102040810204080), SingleReg:$v)>;

def: Pat<(v2i16 (bitreverse v2i16:$v)), (SBMM8rr (MAKEi64 0x102040810204080), (SBMM8ri37 SingleReg:$v, 0x04080102))>;
def: Pat<(v4i16 (bitreverse v4i16:$v)), (SBMM8rr (MAKEi64 0x0102040810204080), (SBMM8ri64 SingleReg:$v, 0x4080102004080102))>;

def: Pat<(i32 (bitreverse i32:$v)), (SBMM8rr (MAKEi64 0x0102040810204080), (SBMM8ri37 SingleReg:$v, 0x01020408))>;
def: Pat<(v2i32 (bitreverse v2i32:$v)), (SBMM8rr (MAKEi64 0x0102040810204080), (SBMM8ri64 SingleReg:$v, 0x1020408001020408))>;

def: Pat<(i64 (bitreverse i64:$v)), (SBMM8rr (MAKEi64 0x0102040810204080), (SBMM8ri64 SingleReg:$v, 0x0102040810204080))>;

// BSWAP
def: Pat<(srl (i32 (bswap i32:$v)), (i64 16)), (SBMM8ri37 SingleReg:$v, 0x0102)>;
def: Pat<(i32 (bswap i32:$v)), (SBMM8ri37 SingleReg:$v, 0x01020408)>;
def: Pat<(i64 (bswap i64:$v)), (SBMM8ri64 SingleReg:$v, 0x0102040810204080)>;
def: Pat<(v2i16 (bswap v2i16:$v)), (SBMM8ri64 SingleReg:$v, 0x04080102)>;
def: Pat<(v4i16 (bswap v4i16:$v)), (SBMM8ri64 SingleReg:$v, 0x4080102004080102)>;
def: Pat<(v2i32 (bswap v2i32:$v)), (SBMM8ri64 SingleReg:$v, 0x1020408001020408)>;

def: Pat<(v2i64 (bswap v2i64:$v)), (v2i64 (REG_SEQUENCE PairedReg,
                                      (SBMM8ri64 (i64(EXTRACT_SUBREG PairedReg:$v, sub_s0)), 0x0102040810204080), sub_s0,
                                      (SBMM8ri64 (i64(EXTRACT_SUBREG PairedReg:$v, sub_s1)), 0x0102040810204080), sub_s1))>;

def: Pat<(v4i32 (bswap v4i32:$v)), (v4i32 (REG_SEQUENCE PairedReg,
                                      (SBMM8ri64 (v2i32(EXTRACT_SUBREG PairedReg:$v, sub_s0)), 0x1020408001020408), sub_s0,
                                      (SBMM8ri64 (v2i32(EXTRACT_SUBREG PairedReg:$v, sub_s1)), 0x1020408001020408), sub_s1))>;

def: Pat<(v4i64 (bswap v4i64:$v)), (v4i64 (REG_SEQUENCE QuadReg,
                                      (SBMM8ri64 (i64(EXTRACT_SUBREG QuadReg:$v, sub_s0)), 0x0102040810204080), sub_s0,
                                      (SBMM8ri64 (i64(EXTRACT_SUBREG QuadReg:$v, sub_s1)), 0x0102040810204080), sub_s1,
                                      (SBMM8ri64 (i64(EXTRACT_SUBREG QuadReg:$v, sub_s2)), 0x0102040810204080), sub_s2,
                                      (SBMM8ri64 (i64(EXTRACT_SUBREG QuadReg:$v, sub_s3)), 0x0102040810204080), sub_s3))>;

multiclass CMOVE_ENTIRE_VEC_IMM <ValueType vt, KVX_INSTRUCTION RI, SDNodeXForm build> {
def : Pat<(vt (select i32:$cc, vt:$t, is_imm_vec:$f)),
            (vt (RI SingleReg:$cc, SingleReg:$t, (build $f), scalarcond_even))>;
def : Pat<(vt (select i32:$cc, is_imm_vec:$t, vt:$f)),
            (vt (RI SingleReg:$cc, SingleReg:$f, (build $t), scalarcond_odd))>;
def : Pat<(vt (select i32:$cc, vt:$t, is_imm_vec_ri37:$f)),
            (vt (CMOVEDri37 SingleReg:$cc, SingleReg:$t, (build $f), scalarcond_even))>;
def : Pat<(vt (select i32:$cc, is_imm_vec_ri37:$t, vt:$f)),
            (vt (CMOVEDri37 SingleReg:$cc, SingleReg:$f, (build $t), scalarcond_odd))>;
}

// TODO: Test if using the pseudo select instructions to vectors up to 64 bits is possible
// as they are optimized.
foreach vt = [ v2i8, v2i16, v4i8 ] in
defm : CMOVE_ENTIRE_VEC_IMM<vt, CMOVEDri37, build_imm_vec>;
defm : CMOVE_ENTIRE_VEC_IMM<v2f16, CMOVEDri37, build_fpimm_vec>;

foreach vt = [ v2i32, v4i16, v8i8 ] in
defm : CMOVE_ENTIRE_VEC_IMM<vt, CMOVEDri64, build_imm_vec>;
foreach vt = [ v2f32, v4f16 ] in
defm : CMOVE_ENTIRE_VEC_IMM<vt, CMOVEDri64, build_fpimm_vec>;

foreach vt = [ v2i8, v2f16, v2i16, v2f32, v2i32, v4i8, v4f16, v4i16, v8i8 ] in {
      def : Pat<(vt (select i32:$cc, vt:$t, vt:$f)),
                (CMOVEDrr SingleReg:$cc, SingleReg:$t, SingleReg:$f, scalarcond_even)>;
      def : Pat<(vt (select i64:$cc, vt:$t, vt:$f)),
                (CMOVEDrr SingleReg:$cc, SingleReg:$t, SingleReg:$f, scalarcond_even)>;
}

foreach vt = [ v2f64, v2i64, v4f32, v4i32 ] in {
def : Pat<(vt (select i32:$cc, vt:$t, vt:$f)),
            (REG_SEQUENCE PairedReg,
            (CMOVEDrr
                  SingleReg:$cc,
                  (i64(EXTRACT_SUBREG PairedReg:$t, sub_s0)),
                  (i64(EXTRACT_SUBREG PairedReg:$f, sub_s0)),
                  scalarcond_even),
            sub_s0,
            (CMOVEDrr
                  SingleReg:$cc,
                  (i64(EXTRACT_SUBREG PairedReg:$t, sub_s1)),
                  (i64(EXTRACT_SUBREG PairedReg:$f, sub_s1)),
                  scalarcond_even),
            sub_s1)>;
}

foreach vt = [ v4f64, v4i64 ] in {
def : Pat<(vt (select i32:$cc, vt:$t, vt:$f)),
            (REG_SEQUENCE QuadReg,
            (CMOVEDrr
                  SingleReg:$cc,
                  (i64(EXTRACT_SUBREG QuadReg:$t, sub_s0)),
                  (i64(EXTRACT_SUBREG QuadReg:$f, sub_s0)),
                  scalarcond_even),
            sub_s0,
            (CMOVEDrr
                  SingleReg:$cc,
                  (i64(EXTRACT_SUBREG QuadReg:$t, sub_s1)),
                  (i64(EXTRACT_SUBREG QuadReg:$f, sub_s1)),
                  scalarcond_even),
            sub_s1,
            (CMOVEDrr
                  SingleReg:$cc,
                  (i64(EXTRACT_SUBREG QuadReg:$t, sub_s2)),
                  (i64(EXTRACT_SUBREG QuadReg:$f, sub_s2)),
                  scalarcond_even),
            sub_s2,
            (CMOVEDrr
                  SingleReg:$cc,
                  (i64(EXTRACT_SUBREG QuadReg:$t, sub_s3)),
                  (i64(EXTRACT_SUBREG QuadReg:$f, sub_s3)),
                  scalarcond_even),
            sub_s3)>;
}

// For the moment we only use build_vector in tca for zeroinit
def COPYZAp : KVX_PSEUDO<(outs VectorReg:$dst), (ins), []>;
def COPYZWp : KVX_PSEUDO<(outs WideReg:$dst), (ins), []>;
def COPYZXp : KVX_PSEUDO<(outs MatrixReg:$dst), (ins), []>;

def: Pat<(v256i1 (build_vector)), (COPYZAp)>; // A48, A49
def: Pat<(v512i1 (build_vector)), (COPYZWp)>; // W25
def: Pat<(v1024i1 (build_vector)), (COPYZXp)>; // X12

// SUBD: Only used for FrameLowering and replaced by the correct ADDD
// instruction at eliminateFrameIndex(). Do not use it in any pattern!
// TODO: Avoid this definition by using a pseudo instruction.
defm SUBD : MC_11<"subd">;
