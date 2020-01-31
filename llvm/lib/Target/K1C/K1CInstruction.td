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
  let Itinerary = itin;
}

class K1C_PseudoInstr<dag outs, dag ins, list<dag> pattern, string asmstr="">
   : K1C_INSTRUCTION<outs, ins, asmstr, pattern, NoItinerary>
{
  let isPseudo = 1;
  let isCodeGenOnly = 1;
  let hasNoSchedulingInfo = 1;
}

// Immediates
def Signed10W : Operand<i32>, ImmLeaf<i32, [{return isInt<10>(Imm);}]>;
def Signed10 : Operand<i64>, ImmLeaf<i64, [{return isInt<10>(Imm);}]>;
def Signed16W : Operand<i32>, ImmLeaf<i32, [{return isInt<16>(Imm);}]>;
def Signed16 : Operand<i64>, ImmLeaf<i64, [{return isInt<16>(Imm);}]>;
def Signed27 : Operand<i32>, ImmLeaf<i32, [{return isInt<27>(Imm);}]>;
def Signed37W : Operand<i32>, ImmLeaf<i32, [{return isInt<37>(Imm);}]>;
def Signed37 : Operand<i64>, ImmLeaf<i64, [{return isInt<37>(Imm);}]>;
def Signed43 : Operand<i64>, ImmLeaf<i64, [{return isInt<43>(Imm);}]>;
def Signed54 : Operand<i64>, ImmLeaf<i64, [{return isInt<54>(Imm);}]>;
def Unsigned6 : Operand<i64>, ImmLeaf<i64, [{return isUInt<6>(Imm);}]>;
def Wrapped32 : Operand<i32>, ImmLeaf<i32, [{return isInt<32>(Imm);}]>;
def Wrapped64 : Operand<i64>, ImmLeaf<i64, [{return isInt<64>(Imm);}]>;
def Sysnumber : Operand<i32>, ImmLeaf<i32, [{return isInt<12>(Imm);}]>;
def Pcrel17 : Operand<iPTR> {}
def Pcrel27 : Operand<iPTR> {}




def VariantMod : Operand<i8> {
  let PrintMethod = "printVariantMod";
}

def ScalingMod : Operand<i8> {
  let PrintMethod = "printScalingMod";
}

def ScalarcondMod : Operand<i8> {
  let PrintMethod = "printScalarcondMod";
}

def SpeculateMod : Operand<OtherVT> {
}

def ColumnMod : Operand<OtherVT> {
}

def Splat32Mod : Operand<OtherVT> {
}

def ComparisonMod : Operand<i8> {
  let PrintMethod = "printComparisonMod";
}

def FloatcompMod : Operand<i8> {
  let PrintMethod = "printFloatcompMod";
}

def RoundingMod : Operand<i32>, ImmLeaf<i32, [{return = (0 <= Imm) && (Imm <= 7);}]> {
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

def Binary16 : Operand<f16>, FPImmLeaf<f16, [{
      return isInt<16>(Imm.bitcastToAPInt().getZExtValue());
    }]> {
  let PrintMethod = "printBinary16ImmOperand";
}
def Binary32 : Operand<f32>, FPImmLeaf<f32, [{
      return isInt<32>(Imm.bitcastToAPInt().getZExtValue());
    }]> {
  let PrintMethod = "printBinary32ImmOperand";
}
def Binary64 : Operand<f64>, FPImmLeaf<f64, [{
      return isInt<64>(Imm.bitcastToAPInt().getZExtValue());
    }]> {
  let PrintMethod = "printBinary64ImmOperand";
}
