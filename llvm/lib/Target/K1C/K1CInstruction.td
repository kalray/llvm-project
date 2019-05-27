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
  let AsmString = asmstr # "\t";
  let Pattern = pattern;
  let Namespace = "K1C";
}

class K1C_PseudoInstr<dag outs, dag ins, list<dag> pattern, string asmstr="">
   : K1C_INSTRUCTION<outs, ins, asmstr, pattern, NoItinerary>
{
  let isPseudo = 1;
}


def __UNKNOWN_ITIN__ : InstrItinClass {
}

def Signed10_32 : Operand<i32>, ImmLeaf<i32, [{return isInt<10>(Imm);}]>;
def Signed10_64 : Operand<i64>, ImmLeaf<i64, [{return isInt<10>(Imm);}]>;

def Signed16_32 : Operand<i32>, ImmLeaf<i32, [{return isInt<16>(Imm);}]>;
def Signed16_64 : Operand<i64>, ImmLeaf<i64, [{return isInt<16>(Imm);}]>;

def Signed37_32 : Operand<i32>, ImmLeaf<i32, [{return isInt<37>(Imm);}]>;
def Signed37_64 : Operand<i64>, ImmLeaf<i64, [{return isInt<37>(Imm);}]>;

def Signed43 : Operand<i64>, ImmLeaf<i64, [{return isInt<43>(Imm);}]>;

def Wrapped32 : Operand<i32>, ImmLeaf<i32, [{return isInt<32>(Imm);}]>;

def Wrapped64 : Operand<i64>, ImmLeaf<i64, [{return isInt<64>(Imm);}]>;

def Unsigned6 : Operand<i64>, ImmLeaf<i64, [{return isUInt<6>(Imm);}]>;

def Pcrel17 : Operand<iPTR> {
}

def Pcrel27 : Operand<iPTR> {
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

def Splat32Mod : Operand<OtherVT> {
}

def ComparisonMod : Operand<i8> {
  let PrintMethod = "printComparisonMod";
}

def FloatcompMod : Operand<OtherVT> {
}

def RoundingMod : Operand<i8> {
  let PrintMethod = "printRoundingMod";
}

def SilentMod : Operand<i8> {
  let PrintMethod = "printSilentMod";
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
