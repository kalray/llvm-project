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
// LANDHQ
// LANDWP
// LNANDHQ
// LNANDWP
// LNORHQ
// LORHQ
// LORWP
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
// SBFHQ
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
// SLLHQS
// SLLWPS
// SLSD
// SLSHQS
// SLSW
// SLSWPS
// SRAD
// SRAHQS
// SRADHQS
// SRAW
// SRAWPS
// SRLHQS
// SRLWPS
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

// 128 bits
def : BITCAST<v4i32, v2i64, PairedReg>;
def : BITCAST<v2i64, v4i32, PairedReg>;

// 64 bits
def : BITCAST<v4i16, i64, SingleReg>;
def : BITCAST<i64, v4i16, SingleReg>;
def : BITCAST<v2i32, v4i16, SingleReg>;
def : BITCAST<v4i16, v2i32, SingleReg>;
def : BITCAST<i64, v2i32, SingleReg>;
def : BITCAST<v2i32, i64, SingleReg>;

// 32 bits
def : BITCAST<v2i16, i32, SingleReg>;
def : BITCAST<i32, v2i16, SingleReg>;

// defm ROLW
// defm RORW
multiclass MC_16_Pat<SDNode Node, Operand OpR1, Operand OpR2,
                    K1C_INSTRUCTION RRInstr, K1C_INSTRUCTION RIInstr> {
  def : Pat<(Node OpR1:$rs1, OpR2:$rs2), (RRInstr SingleReg:$rs1, SingleReg:$rs2)>;
  def : Pat<(Node OpR1:$rs, Unsigned6:$is), (RIInstr SingleReg:$rs, Unsigned6:$is)>;
}

// ADDD
def : Pat<(add i64:$rs1, i64:$rs2), (ADDDd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(add i64:$rs1, Signed10:$rs2), (ADDDd1 SingleReg:$rs1, Signed10:$rs2)>;
def : Pat<(add i64:$rs1, Signed37:$rs2), (ADDDd2 SingleReg:$rs1, Signed37:$rs2)>;
def : Pat<(add i64:$rs1, Wrapped64:$rs2), (ADDDd3 SingleReg:$rs1, Wrapped64:$rs2)>;

// ADDHQ
def : Pat<(add v2i16:$rs1, v2i16:$rs2), (ADDHQd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(add v4i16:$rs1, v4i16:$rs2), (ADDHQd0 SingleReg:$rs1, SingleReg:$rs2)>;

// ADDW
def : Pat<(add i32:$rs1, i32:$rs2), (ADDWd2 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(add i32:$rs1, Signed10W:$rs2), (ADDWd0 SingleReg:$rs1, Signed10W:$rs2)>;
def : Pat<(add i32:$rs1, Signed37W:$rs2), (ADDWd1 SingleReg:$rs1, Signed37W:$rs2)>;

// ADDWP
def : Pat<(add v2i32:$rs1, v2i32:$rs2), (ADDWPd0 SingleReg:$rs1, SingleReg:$rs2)>;

// ANDD
def : Pat<(and i64:$rs1, i64:$rs2), (ANDDd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(and i64:$rs1, Signed10:$rs2), (ANDDd1 SingleReg:$rs1, Signed10:$rs2)>;
def : Pat<(and i64:$rs1, Signed37:$rs2), (ANDDd2 SingleReg:$rs1, Signed37:$rs2)>;
def : Pat<(and i64:$rs1, Wrapped64:$rs2), (ANDDd3 SingleReg:$rs1, Wrapped64:$rs2)>;
def : Pat<(and v2i32:$rs1, v2i32:$rs2), (ANDDd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(and v4i16:$rs1, v4i16:$rs2), (ANDDd0 SingleReg:$rs1, SingleReg:$rs2)>;

// LANDW
def : Pat<(and (i32 (setne i32:$v1, (i32 0))), (i32 (setne i32:$v2, (i32 0)))),
      (LANDWd0 SingleReg:$v1, SingleReg:$v2)>;

// LNANDW
def : Pat<(or (i32 (seteq i32:$v1, (i32 0))), (i32 (seteq i32:$v2, (i32 0)))),
      (LNANDWd0 SingleReg:$v1, SingleReg:$v2)>;

// LANDD
def : Pat<(and (i32 (setne i64:$v1, (i64 0))), (i32 (setne i64:$v2, (i64 0)))),
      (LANDDd0 SingleReg:$v1, SingleReg:$v2)>;

// LNANDD
def : Pat<(or (i32 (seteq i64:$v1, (i64 0))), (i32 (seteq i64:$v2, (i64 0)))),
      (LNANDDd0 SingleReg:$v1, SingleReg:$v2)>;

// LORW
def : Pat<(i32 (setne (or i32:$v1, i32:$v2), (i32 0))),
      (LORWd0 SingleReg:$v1, SingleReg:$v2)>;

// LNORW
def : Pat<(i32 (seteq (or i32:$v1, i32:$v2), (i32 0))), (LNORWd0 SingleReg:$v1, SingleReg:$v2)>;

// LORD
def : Pat<(i32 (setne (or i64:$v1, i64:$v2), (i64 0))),
      (LORDd0 SingleReg:$v1, SingleReg:$v2)>;

// LNORD
def : Pat<(i32 (seteq (or i64:$v1, i64:$v2), (i64 0))), (LNORDd0 SingleReg:$v1, SingleReg:$v2)>;

// ANDW
def : Pat<(and i32:$rs1, i32:$rs2), (ANDWd2 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(and i32:$rs1, Signed10W:$rs2), (ANDWd0 SingleReg:$rs1, Signed10W:$rs2)>;
def : Pat<(and i32:$rs1, Signed37W:$rs2), (ANDWd1 SingleReg:$rs1, Signed37W:$rs2)>;
def : Pat<(and v2i16:$rs1, v2i16:$rs2), (ANDWd2 SingleReg:$rs1, SingleReg:$rs2)>;

multiclass COMP_Pat<SDNode Node, int Mod> {
  //COMPD
  def : Pat<(i32 (Node i64:$lhs, i64:$rhs)),
        (COMPDd3 SingleReg:$lhs, SingleReg:$rhs, (i8 Mod))>;
  def : Pat<(i32 (Node i64:$lhs, Signed10:$rhs)),
        (COMPDd0 SingleReg:$lhs, Signed10:$rhs, (i8 Mod))>;
  def : Pat<(i32 (Node i64:$lhs, Signed37:$rhs)),
        (COMPDd1 SingleReg:$lhs, Signed37:$rhs, (i8 Mod))>;
  def : Pat<(i32 (Node i64:$lhs, Wrapped64:$rhs)),
        (COMPDd2 SingleReg:$lhs, Wrapped64:$rhs, (i8 Mod))>;

  //COMPW
  def : Pat<(i32 (Node i32:$lhs, i32:$rhs)),
        (COMPWd0 SingleReg:$lhs, SingleReg:$rhs, (i8 Mod))>;
  def : Pat<(i32 (Node i32:$lhs, Wrapped32:$rhs)),
        (COMPWd1 SingleReg:$lhs, Wrapped32:$rhs, (i8 Mod))>;

  //COMPNHQ
  def : Pat<(v4i16 (Node v4i16:$lhs, v4i16:$rhs)),
        (COMPNHQ SingleReg:$lhs, SingleReg:$rhs, (i8 Mod))>;

  //COMPNWP
  def : Pat<(v2i32 (Node v2i32:$lhs, v2i32:$rhs)),
        (COMPNWP SingleReg:$lhs, SingleReg:$rhs, (i8 Mod))>;
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
def : Pat<(or i64:$rs1, Signed10:$rs2), (ORDd1 SingleReg:$rs1, Signed10:$rs2)>;
def : Pat<(or i64:$rs1, Signed37:$rs2), (ORDd2 SingleReg:$rs1, Signed37:$rs2)>;
def : Pat<(or i64:$rs1, Wrapped64:$rs2), (ORDd3 SingleReg:$rs1, Wrapped64:$rs2)>;
def : Pat<(or v2i32:$rs1, v2i32:$rs2), (ORDd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(or v4i16:$rs1, v4i16:$rs2), (ORDd0 SingleReg:$rs1, SingleReg:$rs2)>;

// ORW
def : Pat<(or i32:$rs1, i32:$rs2), (ORWd2 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(or i32:$rs1, Signed10W:$rs2), (ORWd0 SingleReg:$rs1, Signed10W:$rs2)>;
def : Pat<(or i32:$rs1, Signed37W:$rs2), (ORWd1 SingleReg:$rs1, Signed37W:$rs2)>;
def : Pat<(or v2i16:$rs1, v2i16:$rs2), (ORWd2 SingleReg:$rs1, SingleReg:$rs2)>;

// SBFD
def : Pat<(sub i64:$rs1, i64:$rs2), (SBFDd0 SingleReg:$rs2, SingleReg:$rs1)>;
def : Pat<(sub Signed10:$rs1, i64:$rs2), (SBFDd1 SingleReg:$rs2, Signed10:$rs1)>;
def : Pat<(sub Signed37:$rs1, i64:$rs2), (SBFDd2 SingleReg:$rs2, Signed37:$rs1)>;
def : Pat<(sub Wrapped64:$rs1, i64:$rs2), (SBFDd3 SingleReg:$rs2, Wrapped64:$rs1)>;

// SBFHQ
def : Pat<(sub v4i16:$rs1, v4i16:$rs2), (SBFHQd0 SingleReg:$rs2, SingleReg:$rs1)>;
def : Pat<(sub v2i16:$rs1, v2i16:$rs2), (SBFHQd0 SingleReg:$rs2, SingleReg:$rs1)>;

// SBFW
def : Pat<(sub i32:$rs1, i32:$rs2), (SBFWd2 SingleReg:$rs2, SingleReg:$rs1)>;
def : Pat<(sub Signed10W:$rs1, i32:$rs2), (SBFWd0 SingleReg:$rs2, Signed10W:$rs1)>;
def : Pat<(sub Signed37W:$rs1, i32:$rs2), (SBFWd1 SingleReg:$rs2, Signed37W:$rs1)>;

// SBFWP
def : Pat<(sub v2i32:$rs1, v2i32:$rs2), (SBFWPd0 SingleReg:$rs2, SingleReg:$rs1)>;

// SLLD
def : Pat<(shl i64:$rs1, i64:$rs2), (SLLDd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(shl i64:$rs1, Unsigned6:$rs2), (SLLDd1 SingleReg:$rs1, Unsigned6:$rs2)>;

// SLLW
def : Pat<(shl i32:$rs1, i64:$rs2), (SLLWd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(shl i32:$rs1, Unsigned6:$rs2), (SLLWd1 SingleReg:$rs1, Unsigned6:$rs2)>;

// SRAD
def : Pat<(sra i64:$rs1, i64:$rs2), (SRADd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(sra i64:$rs1, Unsigned6:$rs2), (SRADd1 SingleReg:$rs1, Unsigned6:$rs2)>;

// SRAW
def : Pat<(sra i32:$rs1, i64:$rs2), (SRAWd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(sra i32:$rs1, Unsigned6:$rs2), (SRAWd1 SingleReg:$rs1, Unsigned6:$rs2)>;

// SRLD
def : Pat<(srl i64:$rs1, i64:$rs2), (SRLDd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(srl i64:$rs1, Unsigned6:$rs2), (SRLDd1 SingleReg:$rs1, Unsigned6:$rs2)>;

// SRLW
def : Pat<(srl i32:$rs1, i64:$rs2), (SRLWd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(srl i32:$rs1, Unsigned6:$rs2), (SRLWd1 SingleReg:$rs1, Unsigned6:$rs2)>;

// ROLW
defm : MC_16_Pat<rotl, i32, i64, ROLWd0, ROLWd1>;

// RORW
defm : MC_16_Pat<rotr, i32, i64, RORWd0, RORWd1>;

// XORD
def : Pat<(xor i64:$rs1, i64:$rs2), (XORDd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(xor i64:$rs1, Signed10:$rs2), (XORDd1 SingleReg:$rs1, Signed10:$rs2)>;
def : Pat<(xor i64:$rs1, Signed37:$rs2), (XORDd2 SingleReg:$rs1, Signed37:$rs2)>;
def : Pat<(xor i64:$rs1, Wrapped64:$rs2), (XORDd3 SingleReg:$rs1, Wrapped64:$rs2)>;
def : Pat<(xor v2i32:$rs1, v2i32:$rs2), (XORDd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(xor v4i16:$rs1, v4i16:$rs2), (XORDd0 SingleReg:$rs1, SingleReg:$rs2)>;

// XORW
def : Pat<(xor i32:$rs1, i32:$rs2), (XORWd2 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(xor i32:$rs1, Signed10W:$rs2), (XORWd0 SingleReg:$rs1, Signed10W:$rs2)>;
def : Pat<(xor i32:$rs1, Signed37W:$rs2), (XORWd1 SingleReg:$rs1, Signed37W:$rs2)>;
def : Pat<(xor v2i16:$rs1, v2i16:$rs2), (XORWd2 SingleReg:$rs1, SingleReg:$rs2)>;

// MINW
def : Pat<(smin i32:$v1, i32:$v2), (MINWd0 SingleReg:$v1, SingleReg:$v2)>;
def : Pat<(smin i32:$v1, Signed10W:$v2), (MINWd1 SingleReg:$v1, Signed10W:$v2)>;
def : Pat<(smin i32:$v1, Signed37W:$v2), (MINWd2 SingleReg:$v1, Signed37W:$v2)>;

// MINUW
def : Pat<(umin i32:$v1, i32:$v2), (MINUWd0 SingleReg:$v1, SingleReg:$v2)>;
def : Pat<(umin i32:$v1, Signed10W:$v2), (MINUWd1 SingleReg:$v1, Signed10W:$v2)>;
def : Pat<(umin i32:$v1, Signed37W:$v2), (MINUWd2 SingleReg:$v1, Signed37W:$v2)>;

// MAXW
def : Pat<(smax i32:$v1, i32:$v2), (MAXWd0 SingleReg:$v1, SingleReg:$v2)>;
def : Pat<(smax i32:$v1, Signed10W:$v2), (MAXWd1 SingleReg:$v1, Signed10W:$v2)>;
def : Pat<(smax i32:$v1, Signed37W:$v2), (MAXWd2 SingleReg:$v1, Signed37W:$v2)>;

// MAXUW
def : Pat<(umax i32:$v1, i32:$v2), (MAXUWd0 SingleReg:$v1, SingleReg:$v2)>;
def : Pat<(umax i32:$v1, Signed10W:$v2), (MAXUWd1 SingleReg:$v1, Signed10W:$v2)>;
def : Pat<(umax i32:$v1, Signed37W:$v2), (MAXUWd2 SingleReg:$v1, Signed37W:$v2)>;

// MIND
def : Pat<(smin i64:$v1, i64:$v2), (MINDd0 SingleReg:$v1, SingleReg:$v2)>;
def : Pat<(smin i64:$v1, Signed10:$v2), (MINDd1 SingleReg:$v1, Signed10:$v2)>;
def : Pat<(smin i64:$v1, Signed37:$v2), (MINDd2 SingleReg:$v1, Signed37:$v2)>;
def : Pat<(smin i64:$v1, Wrapped64:$v2), (MINDd3 SingleReg:$v1, Wrapped64:$v2)>;

// MINUD
def : Pat<(umin i64:$v1, i64:$v2), (MINUDd0 SingleReg:$v1, SingleReg:$v2)>;
def : Pat<(umin i64:$v1, Signed10:$v2), (MINUDd1 SingleReg:$v1, Signed10:$v2)>;
def : Pat<(umin i64:$v1, Signed37:$v2), (MINUDd2 SingleReg:$v1, Signed37:$v2)>;
def : Pat<(umin i64:$v1, Wrapped64:$v2), (MINUDd3 SingleReg:$v1, Wrapped64:$v2)>;

// MAXD
def : Pat<(smax i64:$v1, i64:$v2), (MAXDd0 SingleReg:$v1, SingleReg:$v2)>;
def : Pat<(smax i64:$v1, Signed10:$v2), (MAXDd1 SingleReg:$v1, Signed10:$v2)>;
def : Pat<(smax i64:$v1, Signed37:$v2), (MAXDd2 SingleReg:$v1, Signed37:$v2)>;
def : Pat<(smax i64:$v1, Wrapped64:$v2), (MAXDd3 SingleReg:$v1, Wrapped64:$v2)>;

// MAXUD
def : Pat<(umax i64:$v1, i64:$v2), (MAXUDd0 SingleReg:$v1, SingleReg:$v2)>;
def : Pat<(umax i64:$v1, Signed10:$v2), (MAXUDd1 SingleReg:$v1, Signed10:$v2)>;
def : Pat<(umax i64:$v1, Signed37:$v2), (MAXUDd2 SingleReg:$v1, Signed37:$v2)>;
def : Pat<(umax i64:$v1, Wrapped64:$v2), (MAXUDd3 SingleReg:$v1, Wrapped64:$v2)>;

// MAXWP
// MAXUWP
// MINWP
// MINUWP
// MAXHQ
// MINHQ
// MAXUHQ
// MINUHQ
// Implemented in K1CISelLowering

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
//---------------//

// MULD
def : Pat<(mul i64:$rs1, i64:$rs2), (MULDd3 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(mul i64:$rs1, Signed10:$rs2), (MULDd0 SingleReg:$rs1, Signed10:$rs2)>;
def : Pat<(mul i64:$rs1, Signed37:$rs2), (MULDd1 SingleReg:$rs1, Signed37:$rs2)>;
def : Pat<(mul i64:$rs1, Wrapped64:$rs2), (MULDd2 SingleReg:$rs1, Wrapped64:$rs2)>;

// MULW
def : Pat<(mul i32:$rs1, i32:$rs2), (MULWd0 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(mul i32:$rs1, Wrapped32:$rs2), (MULWd1 SingleReg:$rs1, Wrapped32:$rs2)>;

// MULHQ
def : Pat<(mul v2i16:$rs1, v2i16:$rs2), (MULHQd3 SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(mul v4i16:$rs1, v4i16:$rs2), (MULHQd3 SingleReg:$rs1, SingleReg:$rs2)>;

// MULWP
def : Pat<(mul v2i32:$rs1, v2i32:$rs2), (MULWPd3 SingleReg:$rs1, SingleReg:$rs2)>;

def : Pat<(add v8i8:$v1, v8i8:$v2),
      (XORDd0
            (ADDDd0
                  (ANDDd3 SingleReg:$v1, 0x7f7f7f7f7f7f7f7f),
                  (ANDDd3 SingleReg:$v2, 0x7f7f7f7f7f7f7f7f)
            ),
            (ANDDd3
                  (XORDd0
                        SingleReg:$v1, SingleReg:$v2
                  ),
                  0x8080808080808080
            )
      )>;

def : Pat<(sub v8i8:$v1, v8i8:$v2),
      (XORDd0
            (ANDDd3
                  (NXORDd0 SingleReg:$v1, SingleReg:$v2),
                  0x8080808080808080
            ),
            (SBFDd0
                  (ANDDd3 SingleReg:$v2, 0x7f7f7f7f7f7f7f7f),
                  (ORDd3 SingleReg:$v1, 0x8080808080808080)
            )
      )>;

def : Pat<(and v8i8:$v1, v8i8:$v2), (ANDDd0 SingleReg:$v1, SingleReg:$v2)>;
def : Pat<(or v8i8:$v1, v8i8:$v2), (ORDd0 SingleReg:$v1, SingleReg:$v2)>;
def : Pat<(xor v8i8:$v1, v8i8:$v2), (XORDd0 SingleReg:$v1, SingleReg:$v2)>;
