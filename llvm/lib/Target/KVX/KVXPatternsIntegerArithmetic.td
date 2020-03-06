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
// ADDX16HQ
// ADDX16WP
// ADDX2HQ
// ADDX2WP
// ADDX4HQ
// ADDX4WP
// ADDX8HQ
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
// SBFX16HQ
// SBFX16WP
// SBFX2HQ
// SBFX2WP
// SBFX4HQ
// SBFX4WD
// SBFX4WP
// SBFX8HQ
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

// FIXME: already defined in KVXInstrInfo
// defm ROLW
// defm RORW
multiclass MC_16_Pat<SDNode Node, Operand OpR1, Operand OpR2,
                    KVX_INSTRUCTION RRInstr, KVX_INSTRUCTION RIInstr> {
  def : Pat<(Node OpR1:$rs1, OpR2:$rs2), (RRInstr SingleReg:$rs1, SingleReg:$rs2)>;
  def : Pat<(Node OpR1:$rs, Unsigned6:$is), (RIInstr SingleReg:$rs, Unsigned6:$is)>;
}

// ADDD
def : Pat<(add i64:$rs1, i64:$rs2), (ADDDrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(add i64:$rs1, Signed10:$rs2), (ADDDri10 SingleReg:$rs1, Signed10:$rs2)>;
def : Pat<(add i64:$rs1, Signed37:$rs2), (ADDDri37 SingleReg:$rs1, Signed37:$rs2)>;
def : Pat<(add i64:$rs1, Wrapped64:$rs2), (ADDDri64 SingleReg:$rs1, Wrapped64:$rs2)>;

// ADDHQ
def : Pat<(add v2i16:$rs1, v2i16:$rs2), (ADDHQrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(add v4i16:$rs1, v4i16:$rs2), (ADDHQrr SingleReg:$rs1, SingleReg:$rs2)>;

// MADDW
def MADDWp : KVX_PSEUDO<(outs SingleReg:$out), (ins SingleReg:$a, SingleReg:$b, SingleReg:$c), []>;

def : Pat<(add i32:$a, (mul i32:$b, i32:$c)), (MADDWp SingleReg:$a, SingleReg:$b, SingleReg:$c)>;
def : Pat<(add (mul i32:$a, i32:$b), i32:$c), (MADDWp SingleReg:$c, SingleReg:$a, SingleReg:$b)>;

def : Pat<(add i32:$a, (mul i32:$b, Wrapped32:$c)), (MADDWp SingleReg:$a, SingleReg:$b, Wrapped32:$c)>;
def : Pat<(add (mul i32:$a, Wrapped32:$b), i32:$c), (MADDWp SingleReg:$c, SingleReg:$a, Wrapped32:$b)>;

// ADDX*, SBFX*

multiclass ADDXDPAT<SDNode sc, KVX_INSTRUCTION RRInstr, KVX_INSTRUCTION RIInstr> {
def : Pat<(add i64:$r1, (shl i64:$r2, sc)), (RRInstr SingleReg:$r2, SingleReg:$r1)>;
def : Pat<(add (shl i64:$r2, sc), i64:$r1), (RRInstr SingleReg:$r2, SingleReg:$r1)>;

def : Pat<(add (shl i64:$r2, sc), Wrapped64W:$r1), (RIInstr SingleReg:$r2, Wrapped64W:$r1)>;
}

multiclass SBFXDPAT<SDNode sc, KVX_INSTRUCTION RRInstr, KVX_INSTRUCTION RIInstr> {
def : Pat<(sub i64:$r1, (shl i64:$r2, sc)), (RRInstr SingleReg:$r2, SingleReg:$r1)>;
def : Pat<(sub Wrapped64W:$r1, (shl i64:$r2, sc)), (RIInstr SingleReg:$r2, Wrapped64W:$r1)>;
}

defm : ADDXDPAT<(i64 4), ADDX16Dmrr, ADDX16Dmri>;
defm : ADDXDPAT<(i64 3), ADDX8Dmrr, ADDX8Dmri>;
defm : ADDXDPAT<(i64 2), ADDX4Dmrr, ADDX4Dmri>;
defm : ADDXDPAT<(i64 1), ADDX2Dmrr, ADDX2Dmri>;
defm : SBFXDPAT<(i64 4), SBFX16Dmrr, SBFX16Dmri>;
defm : SBFXDPAT<(i64 3), SBFX8Dmrr, SBFX8Dmri>;
defm : SBFXDPAT<(i64 2), SBFX4Dmrr, SBFX4Dmri>;
defm : SBFXDPAT<(i64 1), SBFX2Dmrr, SBFX2Dmri>;

multiclass ADDXUWDPAT<SDNode sc, KVX_INSTRUCTION RRInstr, KVX_INSTRUCTION RIInstr> {
def : Pat<(add i64:$r1, (i64 (zext (shl i32:$r2, sc))) ), (RRInstr SingleReg:$r2, SingleReg:$r1)>;
def : Pat<(add (i64 (zext (shl i32:$r2, sc))), i64:$r1), (RRInstr SingleReg:$r2, SingleReg:$r1)>;

def : Pat<(add (i64 (zext (shl i32:$r2, sc))), Wrapped64W:$r1), (RIInstr SingleReg:$r2, Wrapped64W:$r1)>;
}

multiclass SBFXUWDPAT<SDNode sc, KVX_INSTRUCTION RRInstr, KVX_INSTRUCTION RIInstr> {
def : Pat<(sub i64:$r1, (i64 (zext (shl i32:$r2, sc))) ), (RRInstr SingleReg:$r2, SingleReg:$r1)>;
def : Pat<(sub Wrapped64W:$r1, (i64 (zext (shl i32:$r2, sc))) ), (RRInstr SingleReg:$r2, Wrapped64W:$r1)>;
}

defm : ADDXUWDPAT<(i64 4), ADDX16UWDmrr, ADDX16UWDmri>;
defm : ADDXUWDPAT<(i64 3), ADDX8UWDmrr, ADDX8UWDmri>;
defm : ADDXUWDPAT<(i64 2), ADDX4UWDmrr, ADDX4UWDmri>;
defm : ADDXUWDPAT<(i64 1), ADDX2UWDmrr, ADDX2UWDmri>;
defm : SBFXUWDPAT<(i64 4), SBFX16UWDmrr, SBFX16UWDmri>;
defm : SBFXUWDPAT<(i64 3), SBFX8UWDmrr, SBFX8UWDmri>;
defm : SBFXUWDPAT<(i64 2), SBFX4UWDmrr, SBFX4UWDmri>;
defm : SBFXUWDPAT<(i64 1), SBFX2UWDmrr, SBFX2UWDmri>;

multiclass ADDXWPAT<SDNode sc, KVX_INSTRUCTION RRInstr, KVX_INSTRUCTION RIInstr> {
def : Pat<(add i32:$r1, (shl i32:$r2, sc)), (RRInstr SingleReg:$r2, SingleReg:$r1)>;
def : Pat<(add (shl i32:$r2, sc), i32:$r1), (RRInstr SingleReg:$r2, SingleReg:$r1)>;

def : Pat<(add (shl i32:$r2, sc), Wrapped32:$r1), (RIInstr SingleReg:$r2, Wrapped32:$r1)>;
}

multiclass SBFXWPAT<SDNode sc, KVX_INSTRUCTION RRInstr, KVX_INSTRUCTION RIInstr> {
def : Pat<(sub i32:$r1, (shl i32:$r2, sc)), (RRInstr SingleReg:$r2, SingleReg:$r1)>;
def : Pat<(sub Wrapped32:$r1, (shl i32:$r2, sc)), (RIInstr SingleReg:$r2, Wrapped32:$r1)>;
}

defm : ADDXWPAT<(i64 4), ADDX16Wrr, ADDX16Wri>;
defm : ADDXWPAT<(i64 3), ADDX8Wrr, ADDX8Wri>;
defm : ADDXWPAT<(i64 2), ADDX4Wrr, ADDX4Wri>;
defm : ADDXWPAT<(i64 1), ADDX2Wrr, ADDX2Wri>;
defm : SBFXWPAT<(i64 4), SBFX16Wrr, SBFX16Wri>;
defm : SBFXWPAT<(i64 3), SBFX8Wrr, SBFX8Wri>;
defm : SBFXWPAT<(i64 2), SBFX4Wrr, SBFX4Wri>;
defm : SBFXWPAT<(i64 1), SBFX2Wrr, SBFX2Wri>;

multiclass ADDXWDPAT<SDNode sc, KVX_INSTRUCTION RRInstr, KVX_INSTRUCTION RIInstr> {
def : Pat<(add i64:$r1, (i64 (sext (shl i32:$r2, sc))) ), (RRInstr SingleReg:$r2, SingleReg:$r1)>;
def : Pat<(add (i64 (sext (shl i32:$r2, sc))), i64:$r1), (RRInstr SingleReg:$r2, SingleReg:$r1)>;

def : Pat<(add (i64 (sext (shl i32:$r2, sc))), Wrapped64W:$r1), (RIInstr SingleReg:$r2, Wrapped64W:$r1)>;
}

multiclass SBFXWDPAT<SDNode sc, KVX_INSTRUCTION RRInstr, KVX_INSTRUCTION RIInstr> {
def : Pat<(sub i64:$r1, (i64 (sext (shl i32:$r2, sc))) ), (RRInstr SingleReg:$r2, SingleReg:$r1)>;
def : Pat<(sub Wrapped64W:$r1, (i64 (sext (shl i32:$r2, sc)))), (RIInstr SingleReg:$r2, Wrapped64W:$r1)>;
}

defm : ADDXWDPAT<(i64 4), ADDX16WDmrr, ADDX16WDmri>;
defm : ADDXWDPAT<(i64 3), ADDX8WDmrr, ADDX8WDmri>;
defm : ADDXWDPAT<(i64 2), ADDX4WDmrr, ADDX4WDmri>;
defm : ADDXWDPAT<(i64 1), ADDX2WDmrr, ADDX2WDmri>;
defm : SBFXWDPAT<(i64 4), SBFX16WDmrr, SBFX16WDmri>;
defm : SBFXWDPAT<(i64 3), SBFX8WDmrr, SBFX8WDmri>;
defm : SBFXWDPAT<(i64 2), SBFX4WDmrr, SBFX4WDmri>;
defm : SBFXWDPAT<(i64 1), SBFX2WDmrr, SBFX2WDmri>;

// ADDW
def : Pat<(add i32:$rs1, i32:$rs2), (ADDWrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(add i32:$rs1, Signed10W:$rs2), (ADDWri10 SingleReg:$rs1, Signed10W:$rs2)>;
def : Pat<(add i32:$rs1, Signed37W:$rs2), (ADDWri37 SingleReg:$rs1, Signed37W:$rs2)>;

// ADDWP
def : Pat<(add v2i32:$rs1, v2i32:$rs2), (ADDWPrr SingleReg:$rs1, SingleReg:$rs2)>;

// ANDD
def : Pat<(and i64:$rs1, i64:$rs2), (ANDDrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(and i64:$rs1, Signed10:$rs2), (ANDDri10 SingleReg:$rs1, Signed10:$rs2)>;
def : Pat<(and i64:$rs1, Signed37:$rs2), (ANDDri37 SingleReg:$rs1, Signed37:$rs2)>;
def : Pat<(and i64:$rs1, Wrapped64:$rs2), (ANDDri64 SingleReg:$rs1, Wrapped64:$rs2)>;
def : Pat<(and v2i32:$rs1, v2i32:$rs2), (ANDDrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(and v4i16:$rs1, v4i16:$rs2), (ANDDrr SingleReg:$rs1, SingleReg:$rs2)>;

// LANDW
def : Pat<(and (i32 (setne i32:$v1, (i32 0))), (i32 (setne i32:$v2, (i32 0)))),
      (LANDWrr SingleReg:$v1, SingleReg:$v2)>;

// LNANDW
def : Pat<(or (i32 (seteq i32:$v1, (i32 0))), (i32 (seteq i32:$v2, (i32 0)))),
      (LNANDWrr SingleReg:$v1, SingleReg:$v2)>;

// LANDD
def : Pat<(and (i32 (setne i64:$v1, (i64 0))), (i32 (setne i64:$v2, (i64 0)))),
      (LANDDrr SingleReg:$v1, SingleReg:$v2)>;

// LNANDD
def : Pat<(or (i32 (seteq i64:$v1, (i64 0))), (i32 (seteq i64:$v2, (i64 0)))),
      (LNANDDrr SingleReg:$v1, SingleReg:$v2)>;

// LORW
def : Pat<(i32 (setne (or i32:$v1, i32:$v2), (i32 0))),
      (LORWrr SingleReg:$v1, SingleReg:$v2)>;

// LNORW
def : Pat<(i32 (seteq (or i32:$v1, i32:$v2), (i32 0))), (LNORWrr SingleReg:$v1, SingleReg:$v2)>;

// LORD
def : Pat<(i32 (setne (or i64:$v1, i64:$v2), (i64 0))),
      (LORDrr SingleReg:$v1, SingleReg:$v2)>;

// LNORD
def : Pat<(i32 (seteq (or i64:$v1, i64:$v2), (i64 0))), (LNORDrr SingleReg:$v1, SingleReg:$v2)>;

// ANDW
def : Pat<(and i32:$rs1, i32:$rs2), (ANDWrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(and i32:$rs1, Signed10W:$rs2), (ANDWri10 SingleReg:$rs1, Signed10W:$rs2)>;
def : Pat<(and i32:$rs1, Signed37W:$rs2), (ANDWri37 SingleReg:$rs1, Signed37W:$rs2)>;
def : Pat<(and v2i16:$rs1, v2i16:$rs2), (ANDWrr SingleReg:$rs1, SingleReg:$rs2)>;

multiclass COMP_Pat<SDNode Node, Comparison Mod> {
  //COMPD
  def : Pat<(i32 (Node i64:$lhs, i64:$rhs)),
        (COMPDrr SingleReg:$lhs, SingleReg:$rhs, Mod)>;
  def : Pat<(i32 (Node i64:$lhs, Signed10:$rhs)),
        (COMPDri10 SingleReg:$lhs, Signed10:$rhs, Mod)>;
  def : Pat<(i32 (Node i64:$lhs, Signed37:$rhs)),
        (COMPDri37 SingleReg:$lhs, Signed37:$rhs, Mod)>;
  def : Pat<(i32 (Node i64:$lhs, Wrapped64:$rhs)),
        (COMPDri64 SingleReg:$lhs, Wrapped64:$rhs, Mod)>;

  //COMPW
  def : Pat<(i32 (Node i32:$lhs, i32:$rhs)),
        (COMPWrr SingleReg:$lhs, SingleReg:$rhs, Mod)>;
  def : Pat<(i32 (Node i32:$lhs, Wrapped32:$rhs)),
        (COMPWri SingleReg:$lhs, Wrapped32:$rhs, Mod)>;

  //COMPNHQ
  def : Pat<(v4i16 (Node v4i16:$lhs, v4i16:$rhs)),
        (COMPNHQ SingleReg:$lhs, SingleReg:$rhs, Mod)>;

  //COMPNWP
  def : Pat<(v2i32 (Node v2i32:$lhs, v2i32:$rhs)),
        (COMPNWP SingleReg:$lhs, SingleReg:$rhs, Mod)>;
}

defm : COMP_Pat<seteq,   comparison_eq>;
defm : COMP_Pat<setne,   comparison_ne>;
defm : COMP_Pat<setugt,  comparison_gtu>;
defm : COMP_Pat<setuge,  comparison_geu>;
defm : COMP_Pat<setult,  comparison_ltu>;
defm : COMP_Pat<setule,  comparison_leu>;
defm : COMP_Pat<setgt,   comparison_gt>;
defm : COMP_Pat<setge,   comparison_ge>;
defm : COMP_Pat<setlt,   comparison_lt>;
defm : COMP_Pat<setle,   comparison_le>;

// ORD
def : Pat<(or i64:$rs1, i64:$rs2), (ORDrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(or i64:$rs1, Signed10:$rs2), (ORDri10 SingleReg:$rs1, Signed10:$rs2)>;
def : Pat<(or i64:$rs1, Signed37:$rs2), (ORDri37 SingleReg:$rs1, Signed37:$rs2)>;
def : Pat<(or i64:$rs1, Wrapped64:$rs2), (ORDri64 SingleReg:$rs1, Wrapped64:$rs2)>;
def : Pat<(or v2i32:$rs1, v2i32:$rs2), (ORDrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(or v4i16:$rs1, v4i16:$rs2), (ORDrr SingleReg:$rs1, SingleReg:$rs2)>;

// ORW
def : Pat<(or i32:$rs1, i32:$rs2), (ORWrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(or i32:$rs1, Signed10W:$rs2), (ORWri10 SingleReg:$rs1, Signed10W:$rs2)>;
def : Pat<(or i32:$rs1, Signed37W:$rs2), (ORWri37 SingleReg:$rs1, Signed37W:$rs2)>;
def : Pat<(or v2i16:$rs1, v2i16:$rs2), (ORWrr SingleReg:$rs1, SingleReg:$rs2)>;

// SBFD
def : Pat<(sub i64:$rs1, i64:$rs2), (SBFDrr SingleReg:$rs2, SingleReg:$rs1)>;
def : Pat<(sub Signed10:$rs1, i64:$rs2), (SBFDri10 SingleReg:$rs2, Signed10:$rs1)>;
def : Pat<(sub Signed37:$rs1, i64:$rs2), (SBFDri37 SingleReg:$rs2, Signed37:$rs1)>;
def : Pat<(sub Wrapped64:$rs1, i64:$rs2), (SBFDri64 SingleReg:$rs2, Wrapped64:$rs1)>;

// SBFHQ
def : Pat<(sub v4i16:$rs1, v4i16:$rs2), (SBFHQrr SingleReg:$rs2, SingleReg:$rs1)>;
def : Pat<(sub v2i16:$rs1, v2i16:$rs2), (SBFHQrr SingleReg:$rs2, SingleReg:$rs1)>;

// SBFW
def : Pat<(sub i32:$rs1, i32:$rs2), (SBFWrr SingleReg:$rs2, SingleReg:$rs1)>;
def : Pat<(sub Signed10W:$rs1, i32:$rs2), (SBFWri10 SingleReg:$rs2, Signed10W:$rs1)>;
def : Pat<(sub Signed37W:$rs1, i32:$rs2), (SBFWri37 SingleReg:$rs2, Signed37W:$rs1)>;

// SBFWP
def : Pat<(sub v2i32:$rs1, v2i32:$rs2), (SBFWPrr SingleReg:$rs2, SingleReg:$rs1)>;

// SLLD
def : Pat<(shl i64:$rs1, i64:$rs2), (SLLDrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(shl i64:$rs1, Unsigned6:$rs2), (SLLDri SingleReg:$rs1, Unsigned6:$rs2)>;

// SLLW
def : Pat<(shl i32:$rs1, i64:$rs2), (SLLWrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(shl i32:$rs1, Unsigned6:$rs2), (SLLWri SingleReg:$rs1, Unsigned6:$rs2)>;

// SRAD
def : Pat<(sra i64:$rs1, i64:$rs2), (SRADrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(sra i64:$rs1, Unsigned6:$rs2), (SRADri SingleReg:$rs1, Unsigned6:$rs2)>;

// SRAW
def : Pat<(sra i32:$rs1, i64:$rs2), (SRAWrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(sra i32:$rs1, Unsigned6:$rs2), (SRAWri SingleReg:$rs1, Unsigned6:$rs2)>;

// SRLD
def : Pat<(srl i64:$rs1, i64:$rs2), (SRLDrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(srl i64:$rs1, Unsigned6:$rs2), (SRLDri SingleReg:$rs1, Unsigned6:$rs2)>;

// SRLW
def : Pat<(srl i32:$rs1, i64:$rs2), (SRLWrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(srl i32:$rs1, Unsigned6:$rs2), (SRLWri SingleReg:$rs1, Unsigned6:$rs2)>;

// ROLW
defm : MC_16_Pat<rotl, i32, i64, ROLWrr, ROLWri>;

// RORW
defm : MC_16_Pat<rotr, i32, i64, RORWrr, RORWri>;

// XORD
def : Pat<(xor i64:$rs1, i64:$rs2), (XORDrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(xor i64:$rs1, Signed10:$rs2), (XORDri10 SingleReg:$rs1, Signed10:$rs2)>;
def : Pat<(xor i64:$rs1, Signed37:$rs2), (XORDri37 SingleReg:$rs1, Signed37:$rs2)>;
def : Pat<(xor i64:$rs1, Wrapped64:$rs2), (XORDri64 SingleReg:$rs1, Wrapped64:$rs2)>;
def : Pat<(xor v2i32:$rs1, v2i32:$rs2), (XORDrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(xor v4i16:$rs1, v4i16:$rs2), (XORDrr SingleReg:$rs1, SingleReg:$rs2)>;

// XORW
def : Pat<(xor i32:$rs1, i32:$rs2), (XORWrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(xor i32:$rs1, Signed10W:$rs2), (XORWri10 SingleReg:$rs1, Signed10W:$rs2)>;
def : Pat<(xor i32:$rs1, Signed37W:$rs2), (XORWri37 SingleReg:$rs1, Signed37W:$rs2)>;
def : Pat<(xor v2i16:$rs1, v2i16:$rs2), (XORWrr SingleReg:$rs1, SingleReg:$rs2)>;

// MINW
def : Pat<(smin i32:$v1, i32:$v2), (MINWrr SingleReg:$v1, SingleReg:$v2)>;
def : Pat<(smin i32:$v1, Signed10W:$v2), (MINWri10 SingleReg:$v1, Signed10W:$v2)>;
def : Pat<(smin i32:$v1, Signed37W:$v2), (MINWri37 SingleReg:$v1, Signed37W:$v2)>;

// MINUW
def : Pat<(umin i32:$v1, i32:$v2), (MINUWrr SingleReg:$v1, SingleReg:$v2)>;
def : Pat<(umin i32:$v1, Signed10W:$v2), (MINUWri10 SingleReg:$v1, Signed10W:$v2)>;
def : Pat<(umin i32:$v1, Signed37W:$v2), (MINUWri37 SingleReg:$v1, Signed37W:$v2)>;

// MAXW
def : Pat<(smax i32:$v1, i32:$v2), (MAXWrr SingleReg:$v1, SingleReg:$v2)>;
def : Pat<(smax i32:$v1, Signed10W:$v2), (MAXWri10 SingleReg:$v1, Signed10W:$v2)>;
def : Pat<(smax i32:$v1, Signed37W:$v2), (MAXWri37 SingleReg:$v1, Signed37W:$v2)>;

// MAXUW
def : Pat<(umax i32:$v1, i32:$v2), (MAXUWrr SingleReg:$v1, SingleReg:$v2)>;
def : Pat<(umax i32:$v1, Signed10W:$v2), (MAXUWri10 SingleReg:$v1, Signed10W:$v2)>;
def : Pat<(umax i32:$v1, Signed37W:$v2), (MAXUWri37 SingleReg:$v1, Signed37W:$v2)>;

// MIND
def : Pat<(smin i64:$v1, i64:$v2), (MINDrr SingleReg:$v1, SingleReg:$v2)>;
def : Pat<(smin i64:$v1, Signed10:$v2), (MINDri10 SingleReg:$v1, Signed10:$v2)>;
def : Pat<(smin i64:$v1, Signed37:$v2), (MINDri37 SingleReg:$v1, Signed37:$v2)>;
def : Pat<(smin i64:$v1, Wrapped64:$v2), (MINDri64 SingleReg:$v1, Wrapped64:$v2)>;

// MINUD
def : Pat<(umin i64:$v1, i64:$v2), (MINUDrr SingleReg:$v1, SingleReg:$v2)>;
def : Pat<(umin i64:$v1, Signed10:$v2), (MINUDri10 SingleReg:$v1, Signed10:$v2)>;
def : Pat<(umin i64:$v1, Signed37:$v2), (MINUDri37 SingleReg:$v1, Signed37:$v2)>;
def : Pat<(umin i64:$v1, Wrapped64:$v2), (MINUDri64 SingleReg:$v1, Wrapped64:$v2)>;

// MAXD
def : Pat<(smax i64:$v1, i64:$v2), (MAXDrr SingleReg:$v1, SingleReg:$v2)>;
def : Pat<(smax i64:$v1, Signed10:$v2), (MAXDri10 SingleReg:$v1, Signed10:$v2)>;
def : Pat<(smax i64:$v1, Signed37:$v2), (MAXDri37 SingleReg:$v1, Signed37:$v2)>;
def : Pat<(smax i64:$v1, Wrapped64:$v2), (MAXDri64 SingleReg:$v1, Wrapped64:$v2)>;

// MAXUD
def : Pat<(umax i64:$v1, i64:$v2), (MAXUDrr SingleReg:$v1, SingleReg:$v2)>;
def : Pat<(umax i64:$v1, Signed10:$v2), (MAXUDri10 SingleReg:$v1, Signed10:$v2)>;
def : Pat<(umax i64:$v1, Signed37:$v2), (MAXUDri37 SingleReg:$v1, Signed37:$v2)>;
def : Pat<(umax i64:$v1, Wrapped64:$v2), (MAXUDri64 SingleReg:$v1, Wrapped64:$v2)>;

// MAXWP
// MAXUWP
// MINWP
// MINUWP
// MAXHQ
// MINHQ
// MAXUHQ
// MINUHQ
// Implemented in KVXISelLowering

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
def : Pat<(mul i64:$rs1, i64:$rs2), (MULDrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(mul i64:$rs1, Signed10:$rs2), (MULDri10 SingleReg:$rs1, Signed10:$rs2)>;
def : Pat<(mul i64:$rs1, Signed37:$rs2), (MULDri37 SingleReg:$rs1, Signed37:$rs2)>;
def : Pat<(mul i64:$rs1, Wrapped64:$rs2), (MULDri64 SingleReg:$rs1, Wrapped64:$rs2)>;

// MULW
def : Pat<(mul i32:$rs1, i32:$rs2), (MULWrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(mul i32:$rs1, Wrapped32:$rs2), (MULWri SingleReg:$rs1, Wrapped32:$rs2)>;

// MULHQ
def : Pat<(mul v2i16:$rs1, v2i16:$rs2), (MULHQrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(mul v4i16:$rs1, v4i16:$rs2), (MULHQrr SingleReg:$rs1, SingleReg:$rs2)>;

// MULWP
def : Pat<(mul v2i32:$rs1, v2i32:$rs2), (MULWPrr SingleReg:$rs1, SingleReg:$rs2)>;

def : Pat<(add v8i8:$v1, v8i8:$v2),
      (XORDrr
            (ADDDrr
                  (ANDDri64 SingleReg:$v1, 0x7f7f7f7f7f7f7f7f),
                  (ANDDri64 SingleReg:$v2, 0x7f7f7f7f7f7f7f7f)
            ),
            (ANDDri64
                  (XORDrr
                        SingleReg:$v1, SingleReg:$v2
                  ),
                  0x8080808080808080
            )
      )>;

def : Pat<(sub v8i8:$v1, v8i8:$v2),
      (XORDrr
            (ANDDri64
                  (NXORDrr SingleReg:$v1, SingleReg:$v2),
                  0x8080808080808080
            ),
            (SBFDrr
                  (ANDDri64 SingleReg:$v2, 0x7f7f7f7f7f7f7f7f),
                  (ORDri64 SingleReg:$v1, 0x8080808080808080)
            )
      )>;

def : Pat<(and v8i8:$v1, v8i8:$v2), (ANDDrr SingleReg:$v1, SingleReg:$v2)>;
def : Pat<(or v8i8:$v1, v8i8:$v2), (ORDrr SingleReg:$v1, SingleReg:$v2)>;
def : Pat<(xor v8i8:$v1, v8i8:$v2), (XORDrr SingleReg:$v1, SingleReg:$v2)>;
