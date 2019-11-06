//===----------------------------------------------------------------------===//
//  ALU Instructions - Patterns
//===----------------------------------------------------------------------===//

// ---- NOT Mapped --- //
// ABDD
// ABDHQ
// ABDW
// ABDWP
// ADDCD
// ADDCHCP
// ADDCID
// ADDCWC
// ADDSHQ
// ADDSW
// ADDSWP
// ADDUWD
// ADDWD
// ADDWP
// ADDX16D
// ADDX16HQ
// ADDX16UWD
// ADDX16W
// ADDX16WD
// ADDX16WP
// ADDX2D
// ADDX2HQ
// ADDX2UWD
// ADDX2W
// ADDX2WD
// ADDX2WP
// ADDX4D
// ADDX4HQ
// ADDX4UWD
// ADDX4W
// ADDX4WD
// ADDX4WP
// ADDX8D
// ADDX8HQ
// ADDX8UWD
// ADDX8W
// ADDX8WD
// ADDX8WP
// ANDND
// ANDNW
// AVGHQ
// AVGRUHQ
// AVGRUW
// AVGRW
// AVGRWP
// AVGUHQ
// AVGUW
// AVGUWP
// AVGW
// AVGWP
// CBSD
// CBSW
// CBSWP
// CLRF
// CLSD
// CLSW
// CLSWP
// CLZD
// CLZW
// CLZWP
// CMOVED
// CMOVEHQ
// COMVEWP
// COMPNHQ
// COMPNWP
// COMPUWD
// COMPWD
// CTZD
// CTZW
// CTZWP
// EXTFS
// EXTFZ
// INSF
// LANDD
// LANDHQ
// LANDW
// LANDWP
// LNANDD
// LNANDHQ
// LNANDW
// LNANDWP
// LNORD
// LNORHQ
// LNORW
// LORD
// LORHQ
// LORW
// LORWP
// MAXD
// MAXHQ
// MAXUD
// MAXUHQ
// MAXUW
// MAXUWP
// MAXW
// MAXWP
// MIND
// MINHQ
// MINUD
// MINUW
// MINUWP
// MINW
// MINWP
// MOVETQ
// NANDD
// NANDW
// NOP
// NORD
// NORW
// NXORD
// NXORW
// ORND
// ORNW
// PCREL
// ROLWPS
// RORWPS
// SATD
// SATUD
// SBFCD
// SBFCHCP
// SBFCID
// SBFCWC
// SBFSD
// SBFSHQ
// SBFSW
// SBFSWP
// SBFUWD
// SBFWD
// SBFX16D
// SBFX16HQ
// SBFX16UWD
// SBFX16W
// SBFX16WD
// SBFX16WP
// SBFX2D
// SBFX2HQ
// SBFX2UWD
// SBFX2W
// SBFX2WD
// SBFX2WP
// SBFX4D
// SBFX4HQ
// SBFX4UWD
// SBFX4W
// SBFX4WD
// SBFX4WP
// SBFX8D
// SBFX8HQ
// SBFX8UWD
// SBFX8W
// SBFX8WD
// SBFX8WP
// SBMM8
// SBMMT8
// SLSD
// SLSHQS
// SLSW
// SLSWPS
// SRAD
// SRADHQS
// SRAW
// SRSD
// SRSHQS
// SRSW
// SRSWPS
// STSUD
// STSUW
// SXLBHQ
// SXLHWP
// SXMBHQ
// SXMHWP
//---------------//

// defm ROLW
// defm RORW
multiclass MC_16_Pat<SDNode Node, Operand OpR1, Operand OpR2,
                    K1C_INSTRUCTION RRInstr, K1C_INSTRUCTION RIInstr> {
  def : Pat<(Node OpR1:$rs1, OpR2:$rs2), (RRInstr SingleReg:$rs1, SingleReg:$rs2)>;
  def : Pat<(Node OpR1:$rs, Unsigned6:$is), (RIInstr SingleReg:$rs, Unsigned6:$is)>;
}

// ADDD
def : Pat<(add i64:$rs1, i64:$rs2), (ADDDd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(add i64:$rs1, Signed10_64:$rs2), (ADDDd1 SingleReg:$rs1, Signed10_64:$rs2)>;
def : Pat<(add i64:$rs1, Signed37_64:$rs2), (ADDDd2 SingleReg:$rs1, Signed37_64:$rs2)>;
def : Pat<(add i64:$rs1, Wrapped64:$rs2), (ADDDd3 SingleReg:$rs1, Wrapped64:$rs2)>;

// ADDHQ

// ADDW
def : Pat<(add i32:$rs1, i32:$rs2), (ADDWd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(add i32:$rs1, Signed10_32:$rs2), (ADDWd1 SingleReg:$rs1, Signed10_32:$rs2)>;
def : Pat<(add i32:$rs1, Signed37_32:$rs2), (ADDWd2 SingleReg:$rs1, Signed37_32:$rs2)>;

//ADDWP
def : Pat<(add v2i32:$rs1, v2i32:$rs2), (ADDWPd0 SingleReg:$rs1, SingleReg:$rs2)>;

// ANDD
def : Pat<(and i64:$rs1, i64:$rs2), (ANDDd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(and i64:$rs1, Signed10_64:$rs2), (ANDDd1 SingleReg:$rs1, Signed10_64:$rs2)>;
def : Pat<(and i64:$rs1, Signed37_64:$rs2), (ANDDd2 SingleReg:$rs1, Signed37_64:$rs2)>;
def : Pat<(and i64:$rs1, Wrapped64:$rs2), (ANDDd3 SingleReg:$rs1, Wrapped64:$rs2)>;

// ANDW
def : Pat<(and i32:$rs1, i32:$rs2), (ANDWd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(and i32:$rs1, Signed10_32:$rs2), (ANDWd1 SingleReg:$rs1, Signed10_32:$rs2)>;
def : Pat<(and i32:$rs1, Signed37_32:$rs2), (ANDWd2 SingleReg:$rs1, Signed37_32:$rs2)>;

multiclass COMP_Pat<SDNode Node, int Mod> {
  //COMPD
  def : Pat<(i32 (Node i64:$lhs, i64:$rhs)),
        (COMPDd3 SingleReg:$lhs, SingleReg:$rhs, (i8 Mod))>;
  def : Pat<(i32 (Node i64:$lhs, Signed10_64:$rhs)),
        (COMPDd0 SingleReg:$lhs, Signed10_64:$rhs, (i8 Mod))>;
  def : Pat<(i32 (Node i64:$lhs, Signed37_64:$rhs)),
        (COMPDd1 SingleReg:$lhs, Signed37_64:$rhs, (i8 Mod))>;
  def : Pat<(i32 (Node i64:$lhs, Wrapped64:$rhs)),
        (COMPDd2 SingleReg:$lhs, Wrapped64:$rhs, (i8 Mod))>;

  //COMPW
  def : Pat<(i32 (Node i32:$lhs, i32:$rhs)),
        (COMPWd0 SingleReg:$lhs, SingleReg:$rhs, (i8 Mod))>;
  def : Pat<(i32 (Node i32:$lhs, Wrapped32:$rhs)),
        (COMPWd1 SingleReg:$lhs, Wrapped32:$rhs, (i8 Mod))>;
}

defm : COMP_Pat<seteq,   1/*.eq*/>;
defm : COMP_Pat<setne,   0/*.ne*/>;
defm : COMP_Pat<setugt,  9/*.gtu*/>;
defm : COMP_Pat<setuge,  7/*.geu*/>;
defm : COMP_Pat<setult,  6/*.ltu*/>;
defm : COMP_Pat<setule,  8/*.leu*/>;
defm : COMP_Pat<setgt,   5/*.gt*/>;
defm : COMP_Pat<setge,   3/*.ge*/>;
defm : COMP_Pat<setlt,   2/*.lt*/>;
defm : COMP_Pat<setle,   4/*.le*/>;

// ORD
def : Pat<(or i64:$rs1, i64:$rs2), (ORDd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(or i64:$rs1, Signed10_64:$rs2), (ORDd1 SingleReg:$rs1, Signed10_64:$rs2)>;
def : Pat<(or i64:$rs1, Signed37_64:$rs2), (ORDd2 SingleReg:$rs1, Signed37_64:$rs2)>;
def : Pat<(or i64:$rs1, Wrapped64:$rs2), (ORDd3 SingleReg:$rs1, Wrapped64:$rs2)>;

// ORW
def : Pat<(or i32:$rs1, i32:$rs2), (ORWd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(or i32:$rs1, Signed10_32:$rs2), (ORWd1 SingleReg:$rs1, Signed10_32:$rs2)>;
def : Pat<(or i32:$rs1, Signed37_32:$rs2), (ORWd2 SingleReg:$rs1, Signed37_32:$rs2)>;

// SBFD
def : Pat<(sub i64:$rs1, i64:$rs2), (SBFDd0 SingleReg:$rs2, SingleReg:$rs1)>;
def : Pat<(sub Signed10_64:$rs1, i64:$rs2), (SBFDd1 SingleReg:$rs2, Signed10_64:$rs1)>;
def : Pat<(sub Signed37_64:$rs1, i64:$rs2), (SBFDd2 SingleReg:$rs2, Signed37_64:$rs1)>;
def : Pat<(sub Wrapped64:$rs1, i64:$rs2), (SBFDd3 SingleReg:$rs2, Wrapped64:$rs1)>;

def : Pat<(ineg i32:$v), (NEGW SingleReg:$v)>;
def : Pat<(ineg i64:$v), (NEGD SingleReg:$v)>;

// SBFHQ

// SBFW
def : Pat<(sub i32:$rs1, i32:$rs2), (SBFWd0 SingleReg:$rs2, SingleReg:$rs1)>;
def : Pat<(sub Signed10_32:$rs1, i32:$rs2), (SBFWd1 SingleReg:$rs2, Signed10_32:$rs1)>;
def : Pat<(sub Signed37_32:$rs1, i32:$rs2), (SBFWd2 SingleReg:$rs2, Signed37_32:$rs1)>;

// SBFWP
def : Pat<(sub v2i32:$rs1, v2i32:$rs2), (SBFWPd0 SingleReg:$rs2, SingleReg:$rs1)>;

// SLLD
def : Pat<(shl i64:$rs1, i64:$rs2), (SLLDd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(shl i64:$rs1, Unsigned6:$rs2), (SLLDd1 SingleReg:$rs1, Unsigned6:$rs2)>;

// SLLHQS

// SLLW
def : Pat<(shl i32:$rs1, i64:$rs2), (SLLWd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(shl i32:$rs1, Unsigned6:$rs2), (SLLWd1 SingleReg:$rs1, Unsigned6:$rs2)>;

// SLLWPS
def : Pat<(shl v2i32:$rs1, v2i32:$rs2), (SLLWPSd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(shl v2i32:$rs1, Unsigned6:$rs2), (SLLWPSd1 SingleReg:$rs1, Unsigned6:$rs2)>;

// SRAD
def : Pat<(sra i64:$rs1, i64:$rs2), (SRADd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(sra i64:$rs1, Unsigned6:$rs2), (SRADd1 SingleReg:$rs1, Unsigned6:$rs2)>;

// SRAHQS

// SRAW
def : Pat<(sra i32:$rs1, i64:$rs2), (SRAWd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(sra i32:$rs1, Unsigned6:$rs2), (SRAWd1 SingleReg:$rs1, Unsigned6:$rs2)>;

// SRAWPS
def : Pat<(sra v2i32:$rs1, Unsigned6:$rs2), (SRAWPSd1 SingleReg:$rs1, Unsigned6:$rs2)>;
def : Pat<(sra v2i32:$rs1, v2i32:$rs2), (SRAWPSd0 SingleReg:$rs1, SingleReg:$rs2)>;

// SRLD
def : Pat<(srl i64:$rs1, i64:$rs2), (SRLDd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(srl i64:$rs1, Unsigned6:$rs2), (SRLDd1 SingleReg:$rs1, Unsigned6:$rs2)>;

// SRLHQS

// SRLW
def : Pat<(srl i32:$rs1, i64:$rs2), (SRLWd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(srl i32:$rs1, Unsigned6:$rs2), (SRLWd1 SingleReg:$rs1, Unsigned6:$rs2)>;

//SRLWPS
def : Pat<(srl v2i32:$rs1, v2i32:$rs2), (SRLWPSd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(srl v2i32:$rs1, Unsigned6:$rs2), (SRLWPSd1 SingleReg:$rs1, Unsigned6:$rs2)>;

// ROLW
defm : MC_16_Pat<rotl, i32, i64, ROLWd0, ROLWd1>;

// RORW
defm : MC_16_Pat<rotr, i32, i64, RORWd0, RORWd1>;

// XORD
def : Pat<(xor i64:$rs1, i64:$rs2), (XORDd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(xor i64:$rs1, Signed10_64:$rs2), (XORDd1 SingleReg:$rs1, Signed10_64:$rs2)>;
def : Pat<(xor i64:$rs1, Signed37_64:$rs2), (XORDd2 SingleReg:$rs1, Signed37_64:$rs2)>;
def : Pat<(xor i64:$rs1, Wrapped64:$rs2), (XORDd3 SingleReg:$rs1, Wrapped64:$rs2)>;

// XORW
def : Pat<(xor i32:$rs1, i32:$rs2), (XORWd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(xor i32:$rs1, Signed10_32:$rs2), (XORWd1 SingleReg:$rs1, Signed10_32:$rs2)>;
def : Pat<(xor i32:$rs1, Signed37_32:$rs2), (XORWd2 SingleReg:$rs1, Signed37_32:$rs2)>;

//===----------------------------------------------------------------------===//
//  MAU Instructions - Patterns
//===----------------------------------------------------------------------===//

// ---- NOT Mapped --- //
// CMULDT
// CMULGHXDT
// CMULGLXDT
// CMULGMXDT
// CMULXDT
// COPYQ
// CRCBELLW
// CRCBELMW
// CRCLELLW
// CRCLELMW
// DOT2SUWD
// DOT2SUWDP
// DOT2UWD
// DOT2UWDP
// DOT2W
// DOT2WD
// DOT2WDP
// DOT2WZP
// MADDD
// MADDDT
// MADDHQ
// MADDHWQ
// MADDSUDT
// MADDSUHWQ
// MADDSUWD
// MADDSUWDP
// MADDUDT
// MADDUHWQ
// MADDUWD
// MADDUWD
// MADDUWDP
// MM2AWQ
// MM2SWQ
// MSBFD
// MSBFDT
// MSBFHQ
// MSBFHWQ
// MSBFSUDT
// MSBFSUHWQ
// MSBFSUWD
// MSBFUSWDP
// MSBFUDT
// MSBFUHWQ
// MSBFUWD
// MSBFUWDP
// MSBFUZDT
// MSBFW
// MSBFWD
// MSBFWDP
// MSBFWP
// MULCWC
// MULCWDC
// MULDT
// MULHWQ
// MULSUDT
// MULSUHWQ
// MULSUWD
// MULSUWDP
// MULUDT
// MULUHWQ
// MULUWD
// MULUWDP
// MULWC
// MULWD
// MULWDC
// MULWDP
// MULWQ
//---------------//

// MULD
def : Pat<(mul i64:$rs1, i64:$rs2), (MULDd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(mul i64:$rs1, Signed10_64:$rs2), (MULDd1 SingleReg:$rs1, Signed10_64:$rs2)>;
def : Pat<(mul i64:$rs1, Signed37_64:$rs2), (MULDd2 SingleReg:$rs1, Signed37_64:$rs2)>;
def : Pat<(mul i64:$rs1, Wrapped64:$rs2), (MULDd3 SingleReg:$rs1, Wrapped64:$rs2)>;

// MULHQ

// MULW
def : Pat<(mul i32:$rs1, i32:$rs2), (MULWd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(mul i32:$rs1, Wrapped32:$rs2), (MULWd1 SingleReg:$rs1, Wrapped32:$rs2)>;

// MULWP
def : Pat<(mul v2i32:$rs1, v2i32:$rs2), (MULWPd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(srl v2i32:$rs1, Unsigned6:$rs2), (MULWPd1 SingleReg:$rs1, Unsigned6:$rs2)>;
