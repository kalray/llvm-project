//===-- KVXOperandInfo.td - KVX Operand defs -------****----*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

// This file was automatically generated,
// Last generated: 2020-09-16 15:58:51.230374.


def Pcrel27 : Operand<iPTR> {}
def Pcrel27Imm : Operand<OtherVT> {}
def Pcrel17 : Operand<iPTR> {}
def Pcrel17Imm : Operand<OtherVT> {}
def Sysnumber : Operand<i64>, ImmLeaf<i64, [{return isInt<12>(Imm);}]>;
def Unsigned6 : Operand<i64>, ImmLeaf<i64, [{return isUInt<6>(Imm);}]>;
def Unsigned3W : Operand<i32>, ImmLeaf<i32, [{return isUInt<3>(Imm);}]>;
def Unsigned4W : Operand<i32>, ImmLeaf<i32, [{return isUInt<4>(Imm);}]>;
def Unsigned5W : Operand<i32>, ImmLeaf<i32, [{return isUInt<5>(Imm);}]>;
def Unsigned6W : Operand<i32>, ImmLeaf<i32, [{return isUInt<6>(Imm);}]>;
def Signed6 : Operand<i64>, ImmLeaf<i64, [{return isInt<6>(Imm);}]>;
def Signed10 : Operand<i64>, ImmLeaf<i64, [{return isInt<10>(Imm);}]>;
def Unsigned10 : Operand<i64>, ImmLeaf<i64, [{return isUInt<10>(Imm);}]>;
// TODO: Signed12 to Signed27 should print in hex, limited to 32 bits
// but our current printHexaBitsImm32 does not handle fp values.
def Signed12 : Operand<i64>, ImmLeaf<i64, [{return isInt<12>(Imm);}]>;
def Signed16 : Operand<i64>, ImmLeaf<i64, [{return isInt<16>(Imm);}]>;
def Signed27 : Operand<i64>, ImmLeaf<i64, [{return isInt<27>(Imm);}]>;

def Signed37 : Operand<i64>, ImmLeaf<i64, [{return isInt<37>(Imm);}]>;
def Signed43 : Operand<i64>, ImmLeaf<i64, [{return isInt<43>(Imm);}]>;
def Signed54 : Operand<i64>, ImmLeaf<i64, [{return isInt<54>(Imm);}]>;
def Wrapped64 : Operand<i64>, ImmLeaf<i64, [{return isInt<64>(Imm);}]>;

def SignedSplat32Imm : Operand<i64>, ImmLeaf<i64, [{return isInt<64>(Imm) && ( (unsigned long)(Imm << 32) == (Imm & 0xffffffff00000000) );}]>;
def UnsignedSplat32Imm : Operand<i64>, ImmLeaf<i64, [{return ( (unsigned long)(Imm << 32) == (Imm & 0xffffffff00000000) );}]>;

let PrintMethod = "printHexaBitsImm32" in {
def Signed10W : Operand<i32>, ImmLeaf<i32, [{return isInt<10>(Imm);}]>;
def Signed16W : Operand<i32>, ImmLeaf<i32, [{return isInt<16>(Imm);}]>;
def Wrapped32 : Operand<i32>, ImmLeaf<i32, [{return isInt<32>(Imm);}]>;
def Wrapped64W : Operand<i64>, ImmLeaf<i64, [{return isInt<32>(Imm);}]>;
def Unsigned64W : Operand<i64>, ImmLeaf<i64, [{return isUInt<32>(Imm);}]>;
}

let PrintMethod = "printHexaBitsImm32Splat" in {
def Wrapped32Splat : Operand<i32>, ImmLeaf<i32, [{return isInt<32>(Imm);}]>;
}

// Ensures that Imm - 1 is still a Wrapped32. Used for AVGR.
def Wrapped32PlusOne : Operand<i32>, ImmLeaf<i32, [{return isInt<32>(Imm-1);}]>;

// Ensures that Imm - 1 is still a Unsigned32. Used for AVGR.
def Unsigned32PlusOne : Operand<i32>, ImmLeaf<i32, [{return isUInt<32>(Imm-1);}]>;

def ScalarcondMod : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 13);}]> {
  let PrintMethod = "printScalarcondMod";
}

def LsomaskMod : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 7);}]> {
  let PrintMethod = "printLsomaskMod";
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

// Hack: We use the silent modifier to allow using address spaces to set speculate
def SpeculateMod : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 3);}]> {
  let PrintMethod = "printSpeculateMod";
}

def DoscaleMod : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 1);}]> {
  let PrintMethod = "printDoscaleMod";
}

def Splat32Mod : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 1);}]> {
  let PrintMethod = "printSplat32Mod";
}

def ConjugateMod : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 1);}]> {
  let PrintMethod = "printConjugateMod";
}

def Binary16 : Operand<f16>, FPImmLeaf<f16, [{
      return isUInt<16>(Imm.bitcastToAPInt().getZExtValue());
    }]> {
  let PrintMethod = "printFPImmOperand";
}

def Binary16x4 : Operand<v4f16>, FPImmLeaf<v4f16, [{
      return isInt<64>(Imm.bitcastToAPInt().getSExtValue());
    }]> {
  let PrintMethod = "printFPImmOperand";
}

def Binary32 : Operand<f32>, FPImmLeaf<f32, [{
      return isUInt<32>(Imm.bitcastToAPInt().getZExtValue());
    }]> {
  let PrintMethod = "printFPImmOperand";
}

def Binary32x2 : Operand<v2f32>, FPImmLeaf<v2f32, [{
      return isInt<64>(Imm.bitcastToAPInt().getZExtValue());
    }]> {
  let PrintMethod = "printFPImmOperand";
}

def Binary64 : Operand<f64>, FPImmLeaf<f64, [{
      return isUInt<64>(Imm.bitcastToAPInt().getZExtValue());
    }]> {
  let PrintMethod = "printFPImmOperand";
}

def TransposeMod : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 3);}]> {
  let PrintMethod = "printTransposeMod";
}

def BoolcasMod : Operand<i32>, ImmLeaf<i32, [{return (Imm == 0) || (Imm == 1);}]> {
  let PrintMethod = "printBoolcasMod";
}

def CoherencyMod : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 1);}]> {
  let PrintMethod = "printCoherencyMod";
}

def CacheLevelMod : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 1);}]> {
  let PrintMethod = "printCacheLevelMod";
}

def QindexMod : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 3);}]> {
  let PrintMethod = "printQindexMod";
}

def LsumaskMod : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 7);}]> {
  let PrintMethod = "printLsumaskMod";
}

def LsumaskScalarMod : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 3);}]> {
  let PrintMethod = "printLsumaskMod";
}

def LsumaskMaskMod : Operand<i32>, ImmLeaf<i32, [{return (4 <= Imm) && (Imm <= 7);}]> {
  let PrintMethod = "printLsumaskMod";
}

def ChannelMod : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 1);}]> {
  let PrintMethod = "printChannelMod";
}

def ShuffleVMod : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 1);}]> {
  let PrintMethod = "printShuffleVMod";
}

def ShuffleXMod : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 6);}]> {
  let PrintMethod = "printShuffleXMod";
}

def LsupackMod : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 5);}]> {
  let PrintMethod = "printLsupackMod";
}

def AccessesMod : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 3);}]> {
  let PrintMethod = "printAccessesMod";
}

def chain : Operand<OtherVT>;

def build_imm_vec : SDNodeXForm<build_vector, [{
  return KVX_LOW::buildImmVector(*N, *CurDAG);
}]>;

def is_imm_vec : PatLeaf<(build_vector), [{
  return cast<BuildVectorSDNode>(N)->isConstant();
}], build_imm_vec>;

def is_imm_vec_kvx_splat32_at : PatLeaf<(build_vector), [{
   return KVX_LOW::isKVXSplat32ImmVec(N, CurDAG, true);
}], build_imm_vec>;
