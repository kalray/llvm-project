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
// ADDHQ
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
// COMPW
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
// ROLW
// ROLWPS
// RORW
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

// ADDD
def : Pat<(add i64:$rs1, i64:$rs2), (ADDDd0 SingleReg:$rs1, SingleReg:$rs2)>;
// Correct match immediate not supported yed
//def : Pat<(add i64:$rs1, Wrapped64:$rs2), (ADDDd3 SingleReg:$rs1, Wrapped64:$rs2)>;

// ADDW
def : Pat<(add i32:$rs1, i32:$rs2), (ADDWd0 SingleReg:$rs1, SingleReg:$rs2)>;
// Correct match immediate not supported yed
//def : Pat<(add i32:$rs1, Signed32:$rs2), (ADDWd1 SingleReg:$rs1, Signed32:$rs2)>;

// ANDD
def : Pat<(and i64:$rs1, i64:$rs2), (ANDDd0 SingleReg:$rs1, SingleReg:$rs2)>;
// Correct match immediate not supported yed
//def : Pat<(and i64:$rs1, imm:$rs2), (ANDDd3 SingleReg:$rs1, imm:$rs2)>;

// ANDW
def : Pat<(and i32:$rs1, i32:$rs2), (ANDWd0 SingleReg:$rs1, SingleReg:$rs2)>;
// Correct match immediate not supported yed
//def : Pat<(and i32:$rs1, Signed32:$rs2), (ANDWd1 SingleReg:$rs1, Signed32:$rs2)>;

// COMPD
def : Pat<(i64 (seteq i64:$lhs, i64:$rhs)),
        (COMPDd3 SingleReg:$lhs, SingleReg:$rhs, (i8 1/*COMPD.eq*/))>;
def : Pat<(i64 (setne i64:$lhs, i64:$rhs)),
        (COMPDd3 SingleReg:$lhs, SingleReg:$rhs, (i8 0/*COMPD.ne*/))>;
def : Pat<(i64 (setugt i64:$lhs, i64:$rhs)),
        (COMPDd3 SingleReg:$lhs, SingleReg:$rhs, (i8 9/*COMPD.gtu*/))>;
def : Pat<(i64 (setuge i64:$lhs, i64:$rhs)),
        (COMPDd3 SingleReg:$lhs, SingleReg:$rhs, (i8 7/*COMPD.geu*/))>;
def : Pat<(i64 (setult i64:$lhs, i64:$rhs)),
        (COMPDd3 SingleReg:$lhs, SingleReg:$rhs, (i8 6/*COMPD.ltu*/))>;
def : Pat<(i64 (setule i64:$lhs, i64:$rhs)),
        (COMPDd3 SingleReg:$lhs, SingleReg:$rhs, (i8 8/*COMPD.leu*/))>;
def : Pat<(i64 (setgt i64:$lhs, i64:$rhs)),
        (COMPDd3 SingleReg:$lhs, SingleReg:$rhs, (i8 5/*COMPD.gt*/))>;
def : Pat<(i64 (setge i64:$lhs, i64:$rhs)),
        (COMPDd3 SingleReg:$lhs, SingleReg:$rhs, (i8 3/*COMPD.ge*/))>;
def : Pat<(i64 (setlt i64:$lhs, i64:$rhs)),
        (COMPDd3 SingleReg:$lhs, SingleReg:$rhs, (i8 2/*COMPD.lt*/))>;
def : Pat<(i64 (setle i64:$lhs, i64:$rhs)),
        (COMPDd3 SingleReg:$lhs, SingleReg:$rhs, (i8 4/*COMPD.le*/))>;

def : Pat<(i32 (trunc (i64 (seteq i64:$lhs, i64:$rhs)))),
        (COMPDd3 SingleReg:$lhs, SingleReg:$rhs, (i8 1/*COMPD.eq*/))>;
def : Pat<(i32 (trunc (i64 (setne i64:$lhs, i64:$rhs)))),
        (COMPDd3 SingleReg:$lhs, SingleReg:$rhs, (i8 0/*COMPD.ne*/))>;
def : Pat<(i32 (trunc (i64 (setugt i64:$lhs, i64:$rhs)))),
        (COMPDd3 SingleReg:$lhs, SingleReg:$rhs, (i8 9/*COMPD.gtu*/))>;
def : Pat<(i32 (trunc (i64 (setuge i64:$lhs, i64:$rhs)))),
        (COMPDd3 SingleReg:$lhs, SingleReg:$rhs, (i8 7/*COMPD.geu*/))>;
def : Pat<(i32 (trunc (i64 (setult i64:$lhs, i64:$rhs)))),
        (COMPDd3 SingleReg:$lhs, SingleReg:$rhs, (i8 6/*COMPD.ltu*/))>;
def : Pat<(i32 (trunc (i64 (setule i64:$lhs, i64:$rhs)))),
        (COMPDd3 SingleReg:$lhs, SingleReg:$rhs, (i8 8/*COMPD.leu*/))>;
def : Pat<(i32 (trunc (i64 (setgt i64:$lhs, i64:$rhs)))),
        (COMPDd3 SingleReg:$lhs, SingleReg:$rhs, (i8 5/*COMPD.gt*/))>;
def : Pat<(i32 (trunc (i64 (setge i64:$lhs, i64:$rhs)))),
        (COMPDd3 SingleReg:$lhs, SingleReg:$rhs, (i8 3/*COMPD.ge*/))>;
def : Pat<(i32 (trunc (i64 (setlt i64:$lhs, i64:$rhs)))),
        (COMPDd3 SingleReg:$lhs, SingleReg:$rhs, (i8 2/*COMPD.lt*/))>;
def : Pat<(i32 (trunc (i64 (setle i64:$lhs, i64:$rhs)))),
        (COMPDd3 SingleReg:$lhs, SingleReg:$rhs, (i8 4/*COMPD.le*/))>;

// COMPW
def : Pat<(i64 (seteq i32:$lhs, i32:$rhs)),
        (COMPWd0 SingleReg:$lhs, SingleReg:$rhs, (i8 1/*COMPW.eq*/))>;
def : Pat<(i64 (setne i32:$lhs, i32:$rhs)),
        (COMPWd0 SingleReg:$lhs, SingleReg:$rhs, (i8 0/*COMPW.ne*/))>;
def : Pat<(i64 (setugt i32:$lhs, i32:$rhs)),
        (COMPWd0 SingleReg:$lhs, SingleReg:$rhs, (i8 9/*COMPW.gtu*/))>;
def : Pat<(i64 (setuge i32:$lhs, i32:$rhs)),
        (COMPWd0 SingleReg:$lhs, SingleReg:$rhs, (i8 7/*COMPW.geu*/))>;
def : Pat<(i64 (setult i32:$lhs, i32:$rhs)),
        (COMPWd0 SingleReg:$lhs, SingleReg:$rhs, (i8 6/*COMPW.ltu*/))>;
def : Pat<(i64 (setule i32:$lhs, i32:$rhs)),
        (COMPWd0 SingleReg:$lhs, SingleReg:$rhs, (i8 8/*COMPW.leu*/))>;
def : Pat<(i64 (setgt i32:$lhs, i32:$rhs)),
        (COMPWd0 SingleReg:$lhs, SingleReg:$rhs, (i8 5/*COMPW.gt*/))>;
def : Pat<(i64 (setge i32:$lhs, i32:$rhs)),
        (COMPWd0 SingleReg:$lhs, SingleReg:$rhs, (i8 3/*COMPW.ge*/))>;
def : Pat<(i64 (setlt i32:$lhs, i32:$rhs)),
        (COMPWd0 SingleReg:$lhs, SingleReg:$rhs, (i8 2/*COMPW.lt*/))>;
def : Pat<(i64 (setle i32:$lhs, i32:$rhs)),
        (COMPWd0 SingleReg:$lhs, SingleReg:$rhs, (i8 4/*COMPW.le*/))>;

def : Pat<(i32 (trunc (i64 (seteq i32:$lhs, i32:$rhs)))),
        (COMPWd0 SingleReg:$lhs, SingleReg:$rhs, (i8 1/*COMPW.eq*/))>;
def : Pat<(i32 (trunc (i64 (setne i32:$lhs, i32:$rhs)))),
        (COMPWd0 SingleReg:$lhs, SingleReg:$rhs, (i8 0/*COMPW.ne*/))>;
def : Pat<(i32 (trunc (i64 (setugt i32:$lhs, i32:$rhs)))),
        (COMPWd0 SingleReg:$lhs, SingleReg:$rhs, (i8 9/*COMPW.gtu*/))>;
def : Pat<(i32 (trunc (i64 (setuge i32:$lhs, i32:$rhs)))),
        (COMPWd0 SingleReg:$lhs, SingleReg:$rhs, (i8 7/*COMPW.geu*/))>;
def : Pat<(i32 (trunc (i64 (setult i32:$lhs, i32:$rhs)))),
        (COMPWd0 SingleReg:$lhs, SingleReg:$rhs, (i8 6/*COMPW.ltu*/))>;
def : Pat<(i32 (trunc (i64 (setule i32:$lhs, i32:$rhs)))),
        (COMPWd0 SingleReg:$lhs, SingleReg:$rhs, (i8 8/*COMPW.leu*/))>;
def : Pat<(i32 (trunc (i64 (setgt i32:$lhs, i32:$rhs)))),
        (COMPWd0 SingleReg:$lhs, SingleReg:$rhs, (i8 5/*COMPW.gt*/))>;
def : Pat<(i32 (trunc (i64 (setge i32:$lhs, i32:$rhs)))),
        (COMPWd0 SingleReg:$lhs, SingleReg:$rhs, (i8 3/*COMPW.ge*/))>;
def : Pat<(i32 (trunc (i64 (setlt i32:$lhs, i32:$rhs)))),
        (COMPWd0 SingleReg:$lhs, SingleReg:$rhs, (i8 2/*COMPW.lt*/))>;
def : Pat<(i32 (trunc (i64 (setle i32:$lhs, i32:$rhs)))),
        (COMPWd0 SingleReg:$lhs, SingleReg:$rhs, (i8 4/*COMPW.le*/))>;

// ORD
def : Pat<(or i64:$rs1, i64:$rs2), (ORDd0 SingleReg:$rs1, SingleReg:$rs2)>;
// Correct match immediate not supported yed
//def : Pat<(or i64:$rs1, Signed10_64:$rs2), (ORDd1 SingleReg:$rs1, Signed10_64:$rs2)>;
//def : Pat<(or i64:$rs1, Signed37:$rs2), (ORDd2 SingleReg:$rs1, Signed37:$rs2)>;
//def : Pat<(or i64:$rs1, Wrapped64:$rs2), (ORDd3 SingleReg:$rs1, Wrapped64:$rs2)>;

// ORW
def : Pat<(or i32:$rs1, i32:$rs2), (ORWd0 SingleReg:$rs1, SingleReg:$rs2)>;
// Correct match immediate not supported yed
//def : Pat<(or i32:$rs1, Signed32:$rs2), (ORWd1 SingleReg:$rs1, Signed32:$rs2)>;

// SBFD
def : Pat<(sub i64:$rs1, i64:$rs2), (SBFDd0 SingleReg:$rs2, SingleReg:$rs1)>;
// Correct match immediate not supported yed
//def : Pat<(sub i64:$rs1, Wrapped64:$rs2), (SBFDd3 SingleReg:$rs1, Wrapped64:$rs2)>;

// SBFW
def : Pat<(sub i32:$rs1, i32:$rs2), (SBFWd0 SingleReg:$rs2, SingleReg:$rs1)>;
// Correct match immediate not supported yed
//def : Pat<(sub i32:$rs1, Signed32:$rs2), (SBFWd1 SingleReg:$rs1, Signed32:$rs2)>;

// SLLD
def : Pat<(shl i64:$rs1, i64:$rs2), (SLLDd0 SingleReg:$rs1, SingleReg:$rs2)>;

// SLLW
def : Pat<(shl i32:$rs1, i64:$rs2), (SLLWd0 SingleReg:$rs1, SingleReg:$rs2)>;

// SRAD
def : Pat<(sra i64:$rs1, i64:$rs2), (SRADd0 SingleReg:$rs1, SingleReg:$rs2)>;

// SRAW
def : Pat<(sra i32:$rs1, i64:$rs2), (SRAWd0 SingleReg:$rs1, SingleReg:$rs2)>;

// SRLD
def : Pat<(srl i64:$rs1, i64:$rs2), (SRLDd0 SingleReg:$rs1, SingleReg:$rs2)>;

// SRLW
def : Pat<(srl i32:$rs1, i64:$rs2), (SRLWd0 SingleReg:$rs1, SingleReg:$rs2)>;

// XORD
def : Pat<(xor i64:$rs1, i64:$rs2), (XORDd0 SingleReg:$rs1, SingleReg:$rs2)>;

// XORW
def : Pat<(xor i32:$rs1, i32:$rs2), (XORWd0 SingleReg:$rs1, SingleReg:$rs2)>;

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
// MULHQ
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
// MULWP
// MULWQ
//---------------//

// MULD
def : Pat<(mul i64:$rs1, i64:$rs2), (MULDd0 SingleReg:$rs1, SingleReg:$rs2)>;

// MULW
def : Pat<(mul i32:$rs1, i32:$rs2), (MULWd0 SingleReg:$rs1, SingleReg:$rs2)>;
