//===-- K1CInstruction.td - K1C Instruction Description ----*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

class K1C_INSTRUCTION<dag outs, dag ins, string asmstr, list<dag> pattern,
    InstrItinClass itin>
    : Instruction {

  dag OutOperandList = outs;
  dag InOperandList = ins;
  let AsmString = asmstr;
  let Pattern = pattern;
  let Namespace = "K1C";
}

class K1C_PseudoInstr<dag outs, dag ins, string asmstr, list<dag> pattern>
   : K1C_INSTRUCTION<outs, ins, asmstr, pattern, NoItinerary>
{
  let isPseudo = 1;
}

def __UNKNOWN_ITIN__ : InstrItinClass {
}

def Signed10 : Operand<i32>, ImmLeaf<i32,  [{
  return Imm>=-(1<<9) && Imm<(1<<9);
}]>;

def Signed16 : Operand<i32>, ImmLeaf<i32, [{
  return Imm>=-(1<<15) && Imm<(1<<15);
}]>;

def Signed32 : Operand<i32>, ImmLeaf<i32, [{return isInt<32>(Imm);}]>;

def Signed37 : Operand<i64>, ImmLeaf<i64, [{
  return Imm>=-(1<<36) && Imm<(1<<36);
}]>;

def Signed43 : Operand<i64>, ImmLeaf<i64, [{
  return Imm>=-(1<<42) && Imm<(1<<42);
}]>;

def Wrapped64 : Operand<i64>, ImmLeaf<i64, [{return isInt<64>(Imm);}]>;

def Pcrel27 : Operand<i64> {
}


def Sysnumber : Operand<OtherVT> {
}

def VariantMod : Operand<i8> {
  let PrintMethod = "printVariantMod";
}

def ScalingMod : Operand<i8> {
  let PrintMethod = "printScalingMod";
}

def ScalarcondMod : Operand<i8> {
  let PrintMethod = "printScalarcondMod";
}

def Signed27 : Operand<OtherVT> {
}

def Signed54 : Operand<OtherVT> {
}


def SpeculateMod : Operand<OtherVT> {
}

def ColumnselMod : Operand<OtherVT> {
}

def Wrapped32 : Operand<OtherVT> {
}

def Splat32Mod : Operand<OtherVT> {
}

def Unsigned6 : Operand<OtherVT> {
}

def ComparisonMod : Operand<OtherVT> {
}


def FloatcompMod : Operand<OtherVT> {
}

def RoundingMod : Operand<OtherVT> {
}

def SilentMod : Operand<OtherVT> {
}

def Pcrel17 : Operand<OtherVT> {
}


def SimplecondMod : Operand<OtherVT> {
}

def RoundintMod : Operand<OtherVT> {
}

def SaturateMod : Operand<OtherVT> {
}

def RectifyMod : Operand<OtherVT> {
}

def SDT_K1CCall : SDTypeProfile<0, -1, [SDTCisVT<0, i64>]>;
def Call : SDNode<"K1CISD::CALL", SDT_K1CCall, [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue, SDNPVariadic]>;
