//===-- KVXOperandInfo.td - KVX Operand defs -------****----*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

// This file was automatically generated,
//   *DO NOT EDIT*,
//   please contact code owner.
// Last generated: 2020-09-16 15:58:51.230374.


def Pcrel27 : Operand<iPTR> {}
def Pcrel17 : Operand<iPTR> {}
def Sysnumber : Operand<i32>, ImmLeaf<i32, [{return isInt<12>(Imm);}]>;
def Unsigned6 : Operand<i64>, ImmLeaf<i64, [{return isUInt<6>(Imm);}]>;
def Signed6 : Operand<i64>, ImmLeaf<i64, [{return isInt<6>(Imm);}]>;
def Signed10 : Operand<i64>, ImmLeaf<i64, [{return isInt<10>(Imm);}]>;
def Signed12 : Operand<i64>, ImmLeaf<i64, [{return isInt<12>(Imm);}]>;
def Signed16 : Operand<i64>, ImmLeaf<i64, [{return isInt<16>(Imm);}]>;
def Signed27 : Operand<i64>, ImmLeaf<i64, [{return isInt<27>(Imm);}]>;

def Wrapped32 : Operand<i32>, ImmLeaf<i32, [{return isInt<32>(Imm);}]> {
  let PrintMethod = "printHexaBitsImm32";
}

def Signed37 : Operand<i64>, ImmLeaf<i64, [{return isInt<37>(Imm);}]>;
def Signed43 : Operand<i64>, ImmLeaf<i64, [{return isInt<43>(Imm);}]>;
def Signed54 : Operand<i64>, ImmLeaf<i64, [{return isInt<54>(Imm);}]>;
def Wrapped64 : Operand<i64>, ImmLeaf<i64, [{return isInt<64>(Imm);}]>;

def Signed10W : Operand<i32>, ImmLeaf<i32, [{return isInt<10>(Imm);}]> {
  let PrintMethod = "printHexaBitsImm32";
}

def Signed16W : Operand<i32>, ImmLeaf<i32, [{return isInt<16>(Imm);}]> {
  let PrintMethod = "printHexaBitsImm32";
}

def Signed37W : Operand<i32>, ImmLeaf<i32, [{return isInt<37>(Imm);}]> {
  let PrintMethod = "printHexaBitsImm32";
}

def Wrapped64W : Operand<i64>, ImmLeaf<i64, [{return isInt<32>(Imm);}]> {
  let PrintMethod = "printHexaBitsImm32";
}

// Matches a 64-bits immediate value with 32-bits MSB 0. Used with simd
// insns when splat modifier available but not set.
def UWord64 : Operand<i64>, ImmLeaf<i64, [{return isUInt<32>(Imm);}]>;

// Matches a 64-bits immediate value with the 32-bits MSB == 32-bits LSB. Used with simd
// insns when splat modifier is set.
def UWsplat : Operand<i64>, ImmLeaf<i64, [{return (Imm >> 32) == (Imm & 0xffffffff);}]>;

def ScalarcondMod : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 13);}]> {
  let PrintMethod = "printScalarcondMod";
}

def SimplecondMod : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 7);}]> {
  let PrintMethod = "printSimplecondMod";
}

def ComparisonMod : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 13);}]> {
  let PrintMethod = "printComparisonMod";
}

def FloatcompMod : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 7);}]> {
  let PrintMethod = "printFloatcompMod";
}

def RoundingMod : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 7);}]> {
  let PrintMethod = "printRoundingMod";
}

def SilentMod : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 1);}]> {
  let PrintMethod = "printSilentMod";
}

def RoundintMod : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 4);}]> {
  let PrintMethod = "printRoundintMod";
}

def SaturateMod : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 1);}]> {
  let PrintMethod = "printSaturateMod";
}

def RectifyMod : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 1);}]> {
   let PrintMethod = "printRectifyMod";
}

def VariantMod : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 3);}]> {
  let PrintMethod = "printVariantMod";
}

def SpeculateMod : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 1);}]> {
  let PrintMethod = "printSpeculateMod";
}

def ColumnMod : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 3);}]> {
  let PrintMethod = "printColumnMod";
}

def DoscaleMod : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 1);}]> {
  let PrintMethod = "printDoscaleMod";
}

def Splat32Mod : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 1);}]> {
  let PrintMethod = "printSplat32Mod";
}

def Binary16 : Operand<f16>, FPImmLeaf<f16, [{
      return isInt<16>(Imm.bitcastToAPInt().getZExtValue());
    }]> {
  let PrintMethod = "printBinary16ImmOperand";
}

def Binary16x4 : Operand<v4f16>, FPImmLeaf<v4f16, [{
      return isInt<64>(Imm.bitcastToAPInt().getZExtValue());
    }]> {
  // FIXME: PrintMethod is not implemented yet
  // let PrintMethod = "printBinary16x4ImmOperand";
}

def Binary32 : Operand<f32>, FPImmLeaf<f32, [{
      return isInt<32>(Imm.bitcastToAPInt().getZExtValue());
    }]> {
  let PrintMethod = "printBinary32ImmOperand";
}

def Binary32x2 : Operand<v2f32>, FPImmLeaf<v2f32, [{
      return isInt<64>(Imm.bitcastToAPInt().getZExtValue());
    }]> {
  // FIXME: PrintMethod is not implemented yet
  // let PrintMethod = "printBinary32x2ImmOperand";
}

def Binary64 : Operand<f64>, FPImmLeaf<f64, [{
      return isInt<64>(Imm.bitcastToAPInt().getZExtValue());
    }]> {
  let PrintMethod = "printBinary64ImmOperand";
}
