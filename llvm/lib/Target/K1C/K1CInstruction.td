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

def Sysnumber : Operand<OtherVT> {
}

def Signed10 : Operand<OtherVT> {
}

def VariantMod : Operand<OtherVT> {
}

def Signed37 : Operand<OtherVT> {
}

def Wrapped64 : Operand<OtherVT> {
}

def ScalarcondMod : Operand<OtherVT> {
}

def Signed27 : Operand<OtherVT> {
}

def Signed54 : Operand<OtherVT> {
}

def ScalingMod : Operand<OtherVT> {
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

def Signed16 : Operand<OtherVT> {
}

def Signed43 : Operand<OtherVT> {
}

def FloatcompMod : Operand<OtherVT> {
}

def RoundingMod : Operand<OtherVT> {
}

def SilentMod : Operand<OtherVT> {
}

def Pcrel17 : Operand<OtherVT> {
}

def Pcrel27 : Operand<OtherVT> {
}

def SimplecondMod : Operand<OtherVT> {
}

def RoundintMod : Operand<OtherVT> {
}

def SaturateMod : Operand<OtherVT> {
}

def RectifyMod : Operand<OtherVT> {
}
