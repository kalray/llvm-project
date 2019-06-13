//===-- K1RegisterInfo.td - K1 Register defs ---------------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
//  Declarations that describe the K1 register file
//===----------------------------------------------------------------------===//

// This file was automatically generated, DO NOT EDIT.
// Last generated: 2019-03-18 11:14:10.982437.


let Namespace = "K1C" in {

// K1 Register base class:
//   - K1Register
//   - K1RegisterWithSubRegs
// Registers are identified with 6-bit ID numbers.
// Registers with sub-registers are always covered by them.

class K1Register<bits<6> num, string n,
                 list<string> alt = []> : Register<n, alt> {
  let HWEncoding{5-0} = num;
}

class K1RegisterWithSubRegs<bits<6> num, string n,
                            list<Register> subregs> : RegisterWithSubRegs<n, subregs> {
  let HWEncoding{5-0} = num;
  let CoveredBySubRegs = 1;
}

} // let Namespace = "K1C"

// SRF - System Register File
class SRF<bits<6> num, string n, list<string> alt = []> : K1Register<num, n, alt>;

// GRF - General Register File
class GRF<bits<6> num, string n, list<string> alt = []> : K1Register<num, n, alt>;

// PRF - Paired Register File
class PRF<bits<6> num, string n, list<Register> subregs> : K1RegisterWithSubRegs<num, n, subregs> {
  let SubRegIndices = [SubRegIndex<64,   0>, SubRegIndex<64,  64>];
}

// QRF - Quadruple Register File
class QRF<bits<6> num, string n, list<Register> subregs> : K1RegisterWithSubRegs<num, n, subregs> {
  let SubRegIndices = [SubRegIndex<64,   0>, SubRegIndex<64,  64>,
                       SubRegIndex<64, 128>, SubRegIndex<64, 192>];
}

// CRF - Coprocessor Register File
class CRF<bits<6> num, string n> : K1Register<num, n>;

// BRF - Block Register File
class BRF<bits<6> num, string n, list<Register> subregs> : K1RegisterWithSubRegs<num, n, subregs> {
  let SubRegIndices = [SubRegIndex<64,   0>, SubRegIndex<64,  64>];
}

// ARF - Accelerator Register File
class ARF<bits<6> num, string n, list<Register> subregs> : K1RegisterWithSubRegs<num, n, subregs> {
  let SubRegIndices = [SubRegIndex<64,   0>, SubRegIndex<64,  64>,
                       SubRegIndex<64, 128>, SubRegIndex<64, 192>];
}

// WRF - Wide Register File
class WRF<bits<6> num, string n, list<Register> subregs> : K1RegisterWithSubRegs<num, n, subregs> {
  let SubRegIndices = [SubRegIndex<64,   0>, SubRegIndex<64,  64>,
                       SubRegIndex<64, 128>, SubRegIndex<64, 192>,
                       SubRegIndex<64, 256>, SubRegIndex<64, 320>,
                       SubRegIndex<64, 384>, SubRegIndex<64, 448>];
}

// XRF - Extended Register File
class XRF<bits<6> num, string n, list<Register> subregs> : K1RegisterWithSubRegs<num, n, subregs> {
  let SubRegIndices = [SubRegIndex<64,   0>, SubRegIndex<64,  64>,
                       SubRegIndex<64, 128>, SubRegIndex<64, 192>,
                       SubRegIndex<64, 256>, SubRegIndex<64, 320>,
                       SubRegIndex<64, 384>, SubRegIndex<64, 448>,
                       SubRegIndex<64, 512>, SubRegIndex<64, 576>,
                       SubRegIndex<64, 640>, SubRegIndex<64, 704>,
                       SubRegIndex<64, 768>, SubRegIndex<64, 832>,
                       SubRegIndex<64, 896>, SubRegIndex<64, 960>];
}

// System Register File
def PC    : SRF< 0,    "$pc",  ["$s0"]>, DwarfRegNum<[ 64]>;
def PS    : SRF< 1,    "$ps",  ["$s1"]>, DwarfRegNum<[ 65]>;
def SPC   : SRF< 2,   "$spc",  ["$s2"]>, DwarfRegNum<[ 66]>;
def SPS   : SRF< 3,   "$sps",  ["$s3"]>, DwarfRegNum<[ 73]>; // !! changed with RA
def SSPC  : SRF< 4,  "$sspc",  ["$s4"]>, DwarfRegNum<[ 68]>;
def SSPS  : SRF< 5,  "$ssps",  ["$s5"]>, DwarfRegNum<[ 69]>;
def SR3   : SRF< 6,   "$sr3",  ["$s6"]>, DwarfRegNum<[ 70]>;
def SR4   : SRF< 7,   "$sr4",  ["$s7"]>, DwarfRegNum<[ 71]>;
def CS    : SRF< 8,    "$cs",  ["$s8"]>, DwarfRegNum<[ 72]>;
def RA    : SRF< 9,    "$ra",  ["$s9"]>, DwarfRegNum<[ 67]>; //!! 67
def PI    : SRF<10,   "$pcr", ["$s10"]>, DwarfRegNum<[ 74]>;
def LS    : SRF<11,    "$ls", ["$s11"]>, DwarfRegNum<[ 75]>;
def LE    : SRF<12,    "$le", ["$s12"]>, DwarfRegNum<[ 76]>;
def LC    : SRF<13,    "$lc", ["$s13"]>, DwarfRegNum<[ 77]>;
def EA    : SRF<14,    "$ea", ["$s14"]>, DwarfRegNum<[ 78]>;
def EV    : SRF<15,    "$ev", ["$s15"]>, DwarfRegNum<[ 79]>;
def RES0  : SRF<16,  "$res0", ["$s16"]>, DwarfRegNum<[ 80]>;
def RES1  : SRF<17,  "$res1", ["$s17"]>, DwarfRegNum<[ 81]>;
def RES2  : SRF<18,  "$res2", ["$s18"]>, DwarfRegNum<[ 82]>;
def RES3  : SRF<19,  "$res3", ["$s19"]>, DwarfRegNum<[ 83]>;
def EV4   : SRF<20,   "$ev4", ["$s20"]>, DwarfRegNum<[ 84]>;
def MEN   : SRF<21,   "$men", ["$s21"]>, DwarfRegNum<[ 85]>;
def PMSA  : SRF<22,  "$pmsa", ["$s22"]>, DwarfRegNum<[ 86]>;
def AESPC : SRF<23, "$aespc", ["$s23"]>, DwarfRegNum<[ 87]>;
def PM0   : SRF<24,   "$pm0", ["$s24"]>, DwarfRegNum<[ 88]>;
def PM1   : SRF<25,   "$pm1", ["$s25"]>, DwarfRegNum<[ 89]>;
def PM2   : SRF<26,   "$pm2", ["$s26"]>, DwarfRegNum<[ 90]>;
def PM3   : SRF<27,   "$pm3", ["$s27"]>, DwarfRegNum<[ 91]>;
def PMC   : SRF<28,   "$pmc", ["$s28"]>, DwarfRegNum<[ 92]>;
def SR0   : SRF<29,   "$sr0", ["$s29"]>, DwarfRegNum<[ 93]>;
def SR1   : SRF<30,   "$sr1", ["$s30"]>, DwarfRegNum<[ 94]>;
def SR2   : SRF<31,   "$sr2", ["$s31"]>, DwarfRegNum<[ 95]>;
def T0V   : SRF<32,   "$t0v", ["$s32"]>, DwarfRegNum<[ 96]>;
def T1V   : SRF<33,   "$t1v", ["$s33"]>, DwarfRegNum<[ 97]>;
def T0R   : SRF<34,   "$t0r", ["$s34"]>, DwarfRegNum<[ 98]>;
def T1R   : SRF<35,   "$t1r", ["$s35"]>, DwarfRegNum<[ 99]>;
def TC    : SRF<36,   "$tcr", ["$s36"]>, DwarfRegNum<[100]>;
def WDC   : SRF<37,   "$wdc", ["$s37"]>, DwarfRegNum<[101]>;
def WDR   : SRF<38,   "$wdr", ["$s38"]>, DwarfRegNum<[102]>;
def ILE   : SRF<39,   "$ile", ["$s39"]>, DwarfRegNum<[103]>;
def ILL   : SRF<40,   "$ill", ["$s40"]>, DwarfRegNum<[104]>;
def ILH   : SRF<41,   "$ilh", ["$s41"]>, DwarfRegNum<[105]>;
def MMC   : SRF<42,   "$mmc", ["$s42"]>, DwarfRegNum<[106]>;
def TEL   : SRF<43,   "$tel", ["$s43"]>, DwarfRegNum<[107]>;
def TEH   : SRF<44,   "$teh", ["$s44"]>, DwarfRegNum<[108]>;
def DV    : SRF<45,    "$dv", ["$s45"]>, DwarfRegNum<[109]>;
def OCE0  : SRF<46,  "$oce0", ["$s46"]>, DwarfRegNum<[110]>;
def OCE1  : SRF<47,  "$oce1", ["$s47"]>, DwarfRegNum<[111]>;
def OCEC  : SRF<48,  "$ocec", ["$s48"]>, DwarfRegNum<[112]>;
def OCEA  : SRF<49,  "$ocea", ["$s49"]>, DwarfRegNum<[113]>;
def ES    : SRF<50,    "$es", ["$s50"]>, DwarfRegNum<[114]>;
def ILR   : SRF<51,   "$ilr", ["$s51"]>, DwarfRegNum<[115]>;
def WS    : SRF<53,    "$ws", ["$s53"]>, DwarfRegNum<[117]>;
def MES   : SRF<54,   "$mes", ["$s54"]>, DwarfRegNum<[118]>;


// General Register File
def R0  : GRF< 0,  "$r0">, DwarfRegNum<[ 0]>;
def R1  : GRF< 1,  "$r1">, DwarfRegNum<[ 1]>;
def R2  : GRF< 2,  "$r2">, DwarfRegNum<[ 2]>;
def R3  : GRF< 3,  "$r3">, DwarfRegNum<[ 3]>;
def R4  : GRF< 4,  "$r4">, DwarfRegNum<[ 4]>;
def R5  : GRF< 5,  "$r5">, DwarfRegNum<[ 5]>;
def R6  : GRF< 6,  "$r6">, DwarfRegNum<[ 6]>;
def R7  : GRF< 7,  "$r7">, DwarfRegNum<[ 7]>;
def R8  : GRF< 8,  "$r8">, DwarfRegNum<[ 8]>;
def R9  : GRF< 9,  "$r9">, DwarfRegNum<[ 9]>;
def R10 : GRF<10, "$r10">, DwarfRegNum<[10]>;
def R11 : GRF<11, "$r11">, DwarfRegNum<[11]>;
def R12 : GRF<12, "$r12", ["$sp"]>, DwarfRegNum<[12]>;
def R13 : GRF<13, "$r13", ["$tp"]>, DwarfRegNum<[13]>;
def R14 : GRF<14, "$r14", ["$fp"]>, DwarfRegNum<[14]>;
def R15 : GRF<15, "$r15">, DwarfRegNum<[15]>;
def R16 : GRF<16, "$r16">, DwarfRegNum<[16]>;
def R17 : GRF<17, "$r17">, DwarfRegNum<[17]>;
def R18 : GRF<18, "$r18">, DwarfRegNum<[18]>;
def R19 : GRF<19, "$r19">, DwarfRegNum<[19]>;
def R20 : GRF<20, "$r20">, DwarfRegNum<[20]>;
def R21 : GRF<21, "$r21">, DwarfRegNum<[21]>;
def R22 : GRF<22, "$r22">, DwarfRegNum<[22]>;
def R23 : GRF<23, "$r23">, DwarfRegNum<[23]>;
def R24 : GRF<24, "$r24">, DwarfRegNum<[24]>;
def R25 : GRF<25, "$r25">, DwarfRegNum<[25]>;
def R26 : GRF<26, "$r26">, DwarfRegNum<[26]>;
def R27 : GRF<27, "$r27">, DwarfRegNum<[27]>;
def R28 : GRF<28, "$r28">, DwarfRegNum<[28]>;
def R29 : GRF<29, "$r29">, DwarfRegNum<[29]>;
def R30 : GRF<30, "$r30">, DwarfRegNum<[30]>;
def R31 : GRF<31, "$r31">, DwarfRegNum<[31]>;
def R32 : GRF<32, "$r32">, DwarfRegNum<[32]>;
def R33 : GRF<33, "$r33">, DwarfRegNum<[33]>;
def R34 : GRF<34, "$r34">, DwarfRegNum<[34]>;
def R35 : GRF<35, "$r35">, DwarfRegNum<[35]>;
def R36 : GRF<36, "$r36">, DwarfRegNum<[36]>;
def R37 : GRF<37, "$r37">, DwarfRegNum<[37]>;
def R38 : GRF<38, "$r38">, DwarfRegNum<[38]>;
def R39 : GRF<39, "$r39">, DwarfRegNum<[39]>;
def R40 : GRF<40, "$r40">, DwarfRegNum<[40]>;
def R41 : GRF<41, "$r41">, DwarfRegNum<[41]>;
def R42 : GRF<42, "$r42">, DwarfRegNum<[42]>;
def R43 : GRF<43, "$r43">, DwarfRegNum<[43]>;
def R44 : GRF<44, "$r44">, DwarfRegNum<[44]>;
def R45 : GRF<45, "$r45">, DwarfRegNum<[45]>;
def R46 : GRF<46, "$r46">, DwarfRegNum<[46]>;
def R47 : GRF<47, "$r47">, DwarfRegNum<[47]>;
def R48 : GRF<48, "$r48">, DwarfRegNum<[48]>;
def R49 : GRF<49, "$r49">, DwarfRegNum<[49]>;
def R50 : GRF<50, "$r50">, DwarfRegNum<[50]>;
def R51 : GRF<51, "$r51">, DwarfRegNum<[51]>;
def R52 : GRF<52, "$r52">, DwarfRegNum<[52]>;
def R53 : GRF<53, "$r53">, DwarfRegNum<[53]>;
def R54 : GRF<54, "$r54">, DwarfRegNum<[54]>;
def R55 : GRF<55, "$r55">, DwarfRegNum<[55]>;
def R56 : GRF<56, "$r56">, DwarfRegNum<[56]>;
def R57 : GRF<57, "$r57">, DwarfRegNum<[57]>;
def R58 : GRF<58, "$r58">, DwarfRegNum<[58]>;
def R59 : GRF<59, "$r59">, DwarfRegNum<[59]>;
def R60 : GRF<60, "$r60">, DwarfRegNum<[60]>;
def R61 : GRF<61, "$r61">, DwarfRegNum<[61]>;
def R62 : GRF<62, "$r62">, DwarfRegNum<[62]>;
def R63 : GRF<63, "$r63">, DwarfRegNum<[63]>;


// Paired Register File
def P0  : PRF< 0,   "$r0r1", [ R0,  R1]>, DwarfRegNum<[128]>;
def P2  : PRF< 2,   "$r2r3", [ R2,  R3]>, DwarfRegNum<[129]>;
def P4  : PRF< 4,   "$r4r5", [ R4,  R5]>, DwarfRegNum<[130]>;
def P6  : PRF< 6,   "$r6r7", [ R6,  R7]>, DwarfRegNum<[131]>;
def P8  : PRF< 8,   "$r8r9", [ R8,  R9]>, DwarfRegNum<[132]>;
def P10 : PRF<10, "$r10r11", [R10, R11]>, DwarfRegNum<[133]>;
def P12 : PRF<12, "$r12r13", [R12, R13]>, DwarfRegNum<[134]>;
def P14 : PRF<14, "$r14r15", [R14, R15]>, DwarfRegNum<[135]>;
def P16 : PRF<16, "$r16r17", [R16, R17]>, DwarfRegNum<[136]>;
def P18 : PRF<18, "$r18r19", [R18, R19]>, DwarfRegNum<[137]>;
def P20 : PRF<20, "$r20r21", [R20, R21]>, DwarfRegNum<[138]>;
def P22 : PRF<22, "$r22r23", [R22, R23]>, DwarfRegNum<[139]>;
def P24 : PRF<24, "$r24r25", [R24, R25]>, DwarfRegNum<[140]>;
def P26 : PRF<26, "$r26r27", [R26, R27]>, DwarfRegNum<[141]>;
def P28 : PRF<28, "$r28r29", [R28, R29]>, DwarfRegNum<[142]>;
def P30 : PRF<30, "$r30r31", [R30, R31]>, DwarfRegNum<[143]>;
def P32 : PRF<32, "$r32r33", [R32, R33]>, DwarfRegNum<[144]>;
def P34 : PRF<34, "$r34r35", [R34, R35]>, DwarfRegNum<[145]>;
def P36 : PRF<36, "$r36r37", [R36, R37]>, DwarfRegNum<[146]>;
def P38 : PRF<38, "$r38r39", [R38, R39]>, DwarfRegNum<[147]>;
def P40 : PRF<40, "$r40r41", [R40, R41]>, DwarfRegNum<[148]>;
def P42 : PRF<42, "$r42r43", [R42, R43]>, DwarfRegNum<[149]>;
def P44 : PRF<44, "$r44r45", [R44, R45]>, DwarfRegNum<[150]>;
def P46 : PRF<46, "$r46r47", [R46, R47]>, DwarfRegNum<[151]>;
def P48 : PRF<48, "$r48r49", [R48, R49]>, DwarfRegNum<[152]>;
def P50 : PRF<50, "$r50r51", [R50, R51]>, DwarfRegNum<[153]>;
def P52 : PRF<52, "$r52r53", [R52, R53]>, DwarfRegNum<[154]>;
def P54 : PRF<54, "$r54r55", [R54, R55]>, DwarfRegNum<[155]>;
def P56 : PRF<56, "$r56r57", [R56, R57]>, DwarfRegNum<[156]>;
def P58 : PRF<58, "$r58r59", [R58, R59]>, DwarfRegNum<[157]>;
def P60 : PRF<60, "$r60r61", [R60, R61]>, DwarfRegNum<[158]>;
def P62 : PRF<62, "$r62r63", [R62, R63]>, DwarfRegNum<[159]>;


// Quadruple Register File
def Q0  : QRF< 0,     "$r0r1r2r3", [ R0,  R1,  R2,  R3]>, DwarfRegNum<[160]>;
def Q4  : QRF< 4,     "$r4r5r6r7", [ R4,  R5,  R6,  R7]>, DwarfRegNum<[161]>;
def Q8  : QRF< 8,   "$r8r9r10r11", [ R8,  R9, R10, R11]>, DwarfRegNum<[162]>;
def Q12 : QRF<12, "$r12r13r14r15", [R12, R13, R14, R15]>, DwarfRegNum<[163]>;
def Q16 : QRF<16, "$r16r17r18r19", [R16, R17, R18, R19]>, DwarfRegNum<[164]>;
def Q20 : QRF<20, "$r20r21r22r23", [R20, R21, R22, R23]>, DwarfRegNum<[165]>;
def Q24 : QRF<24, "$r24r25r26r27", [R24, R25, R26, R27]>, DwarfRegNum<[166]>;
def Q28 : QRF<28, "$r28r29r30r31", [R28, R29, R30, R31]>, DwarfRegNum<[167]>;
def Q32 : QRF<32, "$r32r33r34r35", [R32, R33, R34, R35]>, DwarfRegNum<[168]>;
def Q36 : QRF<36, "$r36r37r38r39", [R36, R37, R38, R39]>, DwarfRegNum<[169]>;
def Q40 : QRF<40, "$r40r41r42r43", [R40, R41, R42, R43]>, DwarfRegNum<[170]>;
def Q44 : QRF<44, "$r44r45r46r47", [R44, R45, R46, R47]>, DwarfRegNum<[171]>;
def Q48 : QRF<48, "$r48r49r50r51", [R48, R49, R50, R51]>, DwarfRegNum<[172]>;
def Q52 : QRF<52, "$r52r53r54r55", [R52, R53, R54, R55]>, DwarfRegNum<[173]>;
def Q56 : QRF<56, "$r56r57r58r59", [R56, R57, R58, R59]>, DwarfRegNum<[174]>;
def Q60 : QRF<60, "$r60r61r62r63", [R60, R61, R62, R63]>, DwarfRegNum<[175]>;


// Coprocessor Register File
def C0   : CRF<  0,  "$a0.x">, DwarfRegNum<[176]>;
def C1   : CRF<  0,  "$a0.y">, DwarfRegNum<[177]>;
def C2   : CRF<  0,  "$a0.z">, DwarfRegNum<[178]>;
def C3   : CRF<  0,  "$a0.t">, DwarfRegNum<[179]>;
def C4   : CRF<  1,  "$a1.x">, DwarfRegNum<[180]>;
def C5   : CRF<  1,  "$a1.y">, DwarfRegNum<[181]>;
def C6   : CRF<  1,  "$a1.z">, DwarfRegNum<[182]>;
def C7   : CRF<  1,  "$a1.t">, DwarfRegNum<[183]>;
def C8   : CRF<  2,  "$a2.x">, DwarfRegNum<[184]>;
def C9   : CRF<  2,  "$a2.y">, DwarfRegNum<[185]>;
def C10  : CRF<  2,  "$a2.z">, DwarfRegNum<[186]>;
def C11  : CRF<  2,  "$a2.t">, DwarfRegNum<[187]>;
def C12  : CRF<  3,  "$a3.x">, DwarfRegNum<[188]>;
def C13  : CRF<  3,  "$a3.y">, DwarfRegNum<[189]>;
def C14  : CRF<  3,  "$a3.z">, DwarfRegNum<[190]>;
def C15  : CRF<  3,  "$a3.t">, DwarfRegNum<[191]>;
def C16  : CRF<  4,  "$a4.x">, DwarfRegNum<[192]>;
def C17  : CRF<  4,  "$a4.y">, DwarfRegNum<[193]>;
def C18  : CRF<  4,  "$a4.z">, DwarfRegNum<[194]>;
def C19  : CRF<  4,  "$a4.t">, DwarfRegNum<[195]>;
def C20  : CRF<  5,  "$a5.x">, DwarfRegNum<[196]>;
def C21  : CRF<  5,  "$a5.y">, DwarfRegNum<[197]>;
def C22  : CRF<  5,  "$a5.z">, DwarfRegNum<[198]>;
def C23  : CRF<  5,  "$a5.t">, DwarfRegNum<[199]>;
def C24  : CRF<  6,  "$a6.x">, DwarfRegNum<[200]>;
def C25  : CRF<  6,  "$a6.y">, DwarfRegNum<[201]>;
def C26  : CRF<  6,  "$a6.z">, DwarfRegNum<[202]>;
def C27  : CRF<  6,  "$a6.t">, DwarfRegNum<[203]>;
def C28  : CRF<  7,  "$a7.x">, DwarfRegNum<[204]>;
def C29  : CRF<  7,  "$a7.y">, DwarfRegNum<[205]>;
def C30  : CRF<  7,  "$a7.z">, DwarfRegNum<[206]>;
def C31  : CRF<  7,  "$a7.t">, DwarfRegNum<[207]>;
def C32  : CRF<  8,  "$a8.x">, DwarfRegNum<[208]>;
def C33  : CRF<  8,  "$a8.y">, DwarfRegNum<[209]>;
def C34  : CRF<  8,  "$a8.z">, DwarfRegNum<[210]>;
def C35  : CRF<  8,  "$a8.t">, DwarfRegNum<[211]>;
def C36  : CRF<  9,  "$a9.x">, DwarfRegNum<[212]>;
def C37  : CRF<  9,  "$a9.y">, DwarfRegNum<[213]>;
def C38  : CRF<  9,  "$a9.z">, DwarfRegNum<[214]>;
def C39  : CRF<  9,  "$a9.t">, DwarfRegNum<[215]>;
def C40  : CRF< 10, "$a10.x">, DwarfRegNum<[216]>;
def C41  : CRF< 10, "$a10.y">, DwarfRegNum<[217]>;
def C42  : CRF< 10, "$a10.z">, DwarfRegNum<[218]>;
def C43  : CRF< 10, "$a10.t">, DwarfRegNum<[219]>;
def C44  : CRF< 11, "$a11.x">, DwarfRegNum<[220]>;
def C45  : CRF< 11, "$a11.y">, DwarfRegNum<[221]>;
def C46  : CRF< 11, "$a11.z">, DwarfRegNum<[222]>;
def C47  : CRF< 11, "$a11.t">, DwarfRegNum<[223]>;
def C48  : CRF< 12, "$a12.x">, DwarfRegNum<[224]>;
def C49  : CRF< 12, "$a12.y">, DwarfRegNum<[225]>;
def C50  : CRF< 12, "$a12.z">, DwarfRegNum<[226]>;
def C51  : CRF< 12, "$a12.t">, DwarfRegNum<[227]>;
def C52  : CRF< 13, "$a13.x">, DwarfRegNum<[228]>;
def C53  : CRF< 13, "$a13.y">, DwarfRegNum<[229]>;
def C54  : CRF< 13, "$a13.z">, DwarfRegNum<[230]>;
def C55  : CRF< 13, "$a13.t">, DwarfRegNum<[231]>;
def C56  : CRF< 14, "$a14.x">, DwarfRegNum<[232]>;
def C57  : CRF< 14, "$a14.y">, DwarfRegNum<[233]>;
def C58  : CRF< 14, "$a14.z">, DwarfRegNum<[234]>;
def C59  : CRF< 14, "$a14.t">, DwarfRegNum<[235]>;
def C60  : CRF< 15, "$a15.x">, DwarfRegNum<[236]>;
def C61  : CRF< 15, "$a15.y">, DwarfRegNum<[237]>;
def C62  : CRF< 15, "$a15.z">, DwarfRegNum<[238]>;
def C63  : CRF< 15, "$a15.t">, DwarfRegNum<[239]>;
def C64  : CRF< 16, "$a16.x">, DwarfRegNum<[240]>;
def C65  : CRF< 16, "$a16.y">, DwarfRegNum<[241]>;
def C66  : CRF< 16, "$a16.z">, DwarfRegNum<[242]>;
def C67  : CRF< 16, "$a16.t">, DwarfRegNum<[243]>;
def C68  : CRF< 17, "$a17.x">, DwarfRegNum<[244]>;
def C69  : CRF< 17, "$a17.y">, DwarfRegNum<[245]>;
def C70  : CRF< 17, "$a17.z">, DwarfRegNum<[246]>;
def C71  : CRF< 17, "$a17.t">, DwarfRegNum<[247]>;
def C72  : CRF< 18, "$a18.x">, DwarfRegNum<[248]>;
def C73  : CRF< 18, "$a18.y">, DwarfRegNum<[249]>;
def C74  : CRF< 18, "$a18.z">, DwarfRegNum<[250]>;
def C75  : CRF< 18, "$a18.t">, DwarfRegNum<[251]>;
def C76  : CRF< 19, "$a19.x">, DwarfRegNum<[252]>;
def C77  : CRF< 19, "$a19.y">, DwarfRegNum<[253]>;
def C78  : CRF< 19, "$a19.z">, DwarfRegNum<[254]>;
def C79  : CRF< 19, "$a19.t">, DwarfRegNum<[255]>;
def C80  : CRF< 20, "$a20.x">, DwarfRegNum<[256]>;
def C81  : CRF< 20, "$a20.y">, DwarfRegNum<[257]>;
def C82  : CRF< 20, "$a20.z">, DwarfRegNum<[258]>;
def C83  : CRF< 20, "$a20.t">, DwarfRegNum<[259]>;
def C84  : CRF< 21, "$a21.x">, DwarfRegNum<[260]>;
def C85  : CRF< 21, "$a21.y">, DwarfRegNum<[261]>;
def C86  : CRF< 21, "$a21.z">, DwarfRegNum<[262]>;
def C87  : CRF< 21, "$a21.t">, DwarfRegNum<[263]>;
def C88  : CRF< 22, "$a22.x">, DwarfRegNum<[264]>;
def C89  : CRF< 22, "$a22.y">, DwarfRegNum<[265]>;
def C90  : CRF< 22, "$a22.z">, DwarfRegNum<[266]>;
def C91  : CRF< 22, "$a22.t">, DwarfRegNum<[267]>;
def C92  : CRF< 23, "$a23.x">, DwarfRegNum<[268]>;
def C93  : CRF< 23, "$a23.y">, DwarfRegNum<[269]>;
def C94  : CRF< 23, "$a23.z">, DwarfRegNum<[270]>;
def C95  : CRF< 23, "$a23.t">, DwarfRegNum<[271]>;
def C96  : CRF< 24, "$a24.x">, DwarfRegNum<[272]>;
def C97  : CRF< 24, "$a24.y">, DwarfRegNum<[273]>;
def C98  : CRF< 24, "$a24.z">, DwarfRegNum<[274]>;
def C99  : CRF< 24, "$a24.t">, DwarfRegNum<[275]>;
def C100 : CRF< 25, "$a25.x">, DwarfRegNum<[276]>;
def C101 : CRF< 25, "$a25.y">, DwarfRegNum<[277]>;
def C102 : CRF< 25, "$a25.z">, DwarfRegNum<[278]>;
def C103 : CRF< 25, "$a25.t">, DwarfRegNum<[279]>;
def C104 : CRF< 26, "$a26.x">, DwarfRegNum<[280]>;
def C105 : CRF< 26, "$a26.y">, DwarfRegNum<[281]>;
def C106 : CRF< 26, "$a26.z">, DwarfRegNum<[282]>;
def C107 : CRF< 26, "$a26.t">, DwarfRegNum<[283]>;
def C108 : CRF< 27, "$a27.x">, DwarfRegNum<[284]>;
def C109 : CRF< 27, "$a27.y">, DwarfRegNum<[285]>;
def C110 : CRF< 27, "$a27.z">, DwarfRegNum<[286]>;
def C111 : CRF< 27, "$a27.t">, DwarfRegNum<[287]>;
def C112 : CRF< 28, "$a28.x">, DwarfRegNum<[288]>;
def C113 : CRF< 28, "$a28.y">, DwarfRegNum<[289]>;
def C114 : CRF< 28, "$a28.z">, DwarfRegNum<[290]>;
def C115 : CRF< 28, "$a28.t">, DwarfRegNum<[291]>;
def C116 : CRF< 29, "$a29.x">, DwarfRegNum<[292]>;
def C117 : CRF< 29, "$a29.y">, DwarfRegNum<[293]>;
def C118 : CRF< 29, "$a29.z">, DwarfRegNum<[294]>;
def C119 : CRF< 29, "$a29.t">, DwarfRegNum<[295]>;
def C120 : CRF< 30, "$a30.x">, DwarfRegNum<[296]>;
def C121 : CRF< 30, "$a30.y">, DwarfRegNum<[297]>;
def C122 : CRF< 30, "$a30.z">, DwarfRegNum<[298]>;
def C123 : CRF< 30, "$a30.t">, DwarfRegNum<[299]>;
def C124 : CRF< 31, "$a31.x">, DwarfRegNum<[300]>;
def C125 : CRF< 31, "$a31.y">, DwarfRegNum<[301]>;
def C126 : CRF< 31, "$a31.z">, DwarfRegNum<[302]>;
def C127 : CRF< 31, "$a31.t">, DwarfRegNum<[303]>;
def C128 : CRF< 32, "$a32.x">, DwarfRegNum<[304]>;
def C129 : CRF< 32, "$a32.y">, DwarfRegNum<[305]>;
def C130 : CRF< 32, "$a32.z">, DwarfRegNum<[306]>;
def C131 : CRF< 32, "$a32.t">, DwarfRegNum<[307]>;
def C132 : CRF< 33, "$a33.x">, DwarfRegNum<[308]>;
def C133 : CRF< 33, "$a33.y">, DwarfRegNum<[309]>;
def C134 : CRF< 33, "$a33.z">, DwarfRegNum<[310]>;
def C135 : CRF< 33, "$a33.t">, DwarfRegNum<[311]>;
def C136 : CRF< 34, "$a34.x">, DwarfRegNum<[312]>;
def C137 : CRF< 34, "$a34.y">, DwarfRegNum<[313]>;
def C138 : CRF< 34, "$a34.z">, DwarfRegNum<[314]>;
def C139 : CRF< 34, "$a34.t">, DwarfRegNum<[315]>;
def C140 : CRF< 35, "$a35.x">, DwarfRegNum<[316]>;
def C141 : CRF< 35, "$a35.y">, DwarfRegNum<[317]>;
def C142 : CRF< 35, "$a35.z">, DwarfRegNum<[318]>;
def C143 : CRF< 35, "$a35.t">, DwarfRegNum<[319]>;
def C144 : CRF< 36, "$a36.x">, DwarfRegNum<[320]>;
def C145 : CRF< 36, "$a36.y">, DwarfRegNum<[321]>;
def C146 : CRF< 36, "$a36.z">, DwarfRegNum<[322]>;
def C147 : CRF< 36, "$a36.t">, DwarfRegNum<[323]>;
def C148 : CRF< 37, "$a37.x">, DwarfRegNum<[324]>;
def C149 : CRF< 37, "$a37.y">, DwarfRegNum<[325]>;
def C150 : CRF< 37, "$a37.z">, DwarfRegNum<[326]>;
def C151 : CRF< 37, "$a37.t">, DwarfRegNum<[327]>;
def C152 : CRF< 38, "$a38.x">, DwarfRegNum<[328]>;
def C153 : CRF< 38, "$a38.y">, DwarfRegNum<[329]>;
def C154 : CRF< 38, "$a38.z">, DwarfRegNum<[330]>;
def C155 : CRF< 38, "$a38.t">, DwarfRegNum<[331]>;
def C156 : CRF< 39, "$a39.x">, DwarfRegNum<[332]>;
def C157 : CRF< 39, "$a39.y">, DwarfRegNum<[333]>;
def C158 : CRF< 39, "$a39.z">, DwarfRegNum<[334]>;
def C159 : CRF< 39, "$a39.t">, DwarfRegNum<[335]>;
def C160 : CRF< 40, "$a40.x">, DwarfRegNum<[336]>;
def C161 : CRF< 40, "$a40.y">, DwarfRegNum<[337]>;
def C162 : CRF< 40, "$a40.z">, DwarfRegNum<[338]>;
def C163 : CRF< 40, "$a40.t">, DwarfRegNum<[339]>;
def C164 : CRF< 41, "$a41.x">, DwarfRegNum<[340]>;
def C165 : CRF< 41, "$a41.y">, DwarfRegNum<[341]>;
def C166 : CRF< 41, "$a41.z">, DwarfRegNum<[342]>;
def C167 : CRF< 41, "$a41.t">, DwarfRegNum<[343]>;
def C168 : CRF< 42, "$a42.x">, DwarfRegNum<[344]>;
def C169 : CRF< 42, "$a42.y">, DwarfRegNum<[345]>;
def C170 : CRF< 42, "$a42.z">, DwarfRegNum<[346]>;
def C171 : CRF< 42, "$a42.t">, DwarfRegNum<[347]>;
def C172 : CRF< 43, "$a43.x">, DwarfRegNum<[348]>;
def C173 : CRF< 43, "$a43.y">, DwarfRegNum<[349]>;
def C174 : CRF< 43, "$a43.z">, DwarfRegNum<[350]>;
def C175 : CRF< 43, "$a43.t">, DwarfRegNum<[351]>;
def C176 : CRF< 44, "$a44.x">, DwarfRegNum<[352]>;
def C177 : CRF< 44, "$a44.y">, DwarfRegNum<[353]>;
def C178 : CRF< 44, "$a44.z">, DwarfRegNum<[354]>;
def C179 : CRF< 44, "$a44.t">, DwarfRegNum<[355]>;
def C180 : CRF< 45, "$a45.x">, DwarfRegNum<[356]>;
def C181 : CRF< 45, "$a45.y">, DwarfRegNum<[357]>;
def C182 : CRF< 45, "$a45.z">, DwarfRegNum<[358]>;
def C183 : CRF< 45, "$a45.t">, DwarfRegNum<[359]>;
def C184 : CRF< 46, "$a46.x">, DwarfRegNum<[360]>;
def C185 : CRF< 46, "$a46.y">, DwarfRegNum<[361]>;
def C186 : CRF< 46, "$a46.z">, DwarfRegNum<[362]>;
def C187 : CRF< 46, "$a46.t">, DwarfRegNum<[363]>;
def C188 : CRF< 47, "$a47.x">, DwarfRegNum<[364]>;
def C189 : CRF< 47, "$a47.y">, DwarfRegNum<[365]>;
def C190 : CRF< 47, "$a47.z">, DwarfRegNum<[366]>;
def C191 : CRF< 47, "$a47.t">, DwarfRegNum<[367]>;
def C192 : CRF< 48, "$a48.x">, DwarfRegNum<[368]>;
def C193 : CRF< 48, "$a48.y">, DwarfRegNum<[369]>;
def C194 : CRF< 48, "$a48.z">, DwarfRegNum<[370]>;
def C195 : CRF< 48, "$a48.t">, DwarfRegNum<[371]>;
def C196 : CRF< 49, "$a49.x">, DwarfRegNum<[372]>;
def C197 : CRF< 49, "$a49.y">, DwarfRegNum<[373]>;
def C198 : CRF< 49, "$a49.z">, DwarfRegNum<[374]>;
def C199 : CRF< 49, "$a49.t">, DwarfRegNum<[375]>;
def C200 : CRF< 50, "$a50.x">, DwarfRegNum<[376]>;
def C201 : CRF< 50, "$a50.y">, DwarfRegNum<[377]>;
def C202 : CRF< 50, "$a50.z">, DwarfRegNum<[378]>;
def C203 : CRF< 50, "$a50.t">, DwarfRegNum<[379]>;
def C204 : CRF< 51, "$a51.x">, DwarfRegNum<[380]>;
def C205 : CRF< 51, "$a51.y">, DwarfRegNum<[381]>;
def C206 : CRF< 51, "$a51.z">, DwarfRegNum<[382]>;
def C207 : CRF< 51, "$a51.t">, DwarfRegNum<[383]>;
def C208 : CRF< 52, "$a52.x">, DwarfRegNum<[384]>;
def C209 : CRF< 52, "$a52.y">, DwarfRegNum<[385]>;
def C210 : CRF< 52, "$a52.z">, DwarfRegNum<[386]>;
def C211 : CRF< 52, "$a52.t">, DwarfRegNum<[387]>;
def C212 : CRF< 53, "$a53.x">, DwarfRegNum<[388]>;
def C213 : CRF< 53, "$a53.y">, DwarfRegNum<[389]>;
def C214 : CRF< 53, "$a53.z">, DwarfRegNum<[390]>;
def C215 : CRF< 53, "$a53.t">, DwarfRegNum<[391]>;
def C216 : CRF< 54, "$a54.x">, DwarfRegNum<[392]>;
def C217 : CRF< 54, "$a54.y">, DwarfRegNum<[393]>;
def C218 : CRF< 54, "$a54.z">, DwarfRegNum<[394]>;
def C219 : CRF< 54, "$a54.t">, DwarfRegNum<[395]>;
def C220 : CRF< 54, "$a55.x">, DwarfRegNum<[396]>;
def C221 : CRF< 54, "$a55.y">, DwarfRegNum<[397]>;
def C222 : CRF< 55, "$a55.z">, DwarfRegNum<[398]>;
def C223 : CRF< 55, "$a55.t">, DwarfRegNum<[399]>;
def C224 : CRF< 56, "$a56.x">, DwarfRegNum<[400]>;
def C225 : CRF< 56, "$a56.y">, DwarfRegNum<[401]>;
def C226 : CRF< 56, "$a56.z">, DwarfRegNum<[402]>;
def C227 : CRF< 56, "$a56.t">, DwarfRegNum<[403]>;
def C228 : CRF< 57, "$a57.x">, DwarfRegNum<[404]>;
def C229 : CRF< 57, "$a57.y">, DwarfRegNum<[405]>;
def C230 : CRF< 57, "$a57.z">, DwarfRegNum<[406]>;
def C231 : CRF< 57, "$a57.t">, DwarfRegNum<[407]>;
def C232 : CRF< 58, "$a58.x">, DwarfRegNum<[408]>;
def C233 : CRF< 58, "$a58.y">, DwarfRegNum<[409]>;
def C234 : CRF< 58, "$a58.z">, DwarfRegNum<[410]>;
def C235 : CRF< 58, "$a58.t">, DwarfRegNum<[411]>;
def C236 : CRF< 59, "$a59.x">, DwarfRegNum<[412]>;
def C237 : CRF< 59, "$a59.y">, DwarfRegNum<[413]>;
def C238 : CRF< 59, "$a59.z">, DwarfRegNum<[414]>;
def C239 : CRF< 59, "$a59.t">, DwarfRegNum<[415]>;
def C240 : CRF< 60, "$a60.x">, DwarfRegNum<[416]>;
def C241 : CRF< 60, "$a60.y">, DwarfRegNum<[417]>;
def C242 : CRF< 60, "$a60.z">, DwarfRegNum<[418]>;
def C243 : CRF< 60, "$a60.t">, DwarfRegNum<[419]>;
def C244 : CRF< 61, "$a61.x">, DwarfRegNum<[420]>;
def C245 : CRF< 61, "$a61.y">, DwarfRegNum<[421]>;
def C246 : CRF< 61, "$a61.z">, DwarfRegNum<[422]>;
def C247 : CRF< 61, "$a61.t">, DwarfRegNum<[423]>;
def C248 : CRF< 62, "$a62.x">, DwarfRegNum<[424]>;
def C249 : CRF< 62, "$a62.y">, DwarfRegNum<[425]>;
def C250 : CRF< 62, "$a62.z">, DwarfRegNum<[426]>;
def C251 : CRF< 62, "$a62.t">, DwarfRegNum<[427]>;
def C252 : CRF< 63, "$a63.x">, DwarfRegNum<[428]>;
def C253 : CRF< 63, "$a63.y">, DwarfRegNum<[429]>;
def C254 : CRF< 63, "$a63.z">, DwarfRegNum<[430]>;
def C255 : CRF< 63, "$a63.t">, DwarfRegNum<[431]>;


// Block Register File
def B0   : BRF<  0,  "$a0.lo", [  C0,   C1]>, DwarfRegNum<[432]>;
def B1   : BRF<  0,  "$a0.hi", [  C2,   C3]>, DwarfRegNum<[433]>;
def B2   : BRF<  1,  "$a1.lo", [  C4,   C5]>, DwarfRegNum<[434]>;
def B3   : BRF<  1,  "$a1.hi", [  C6,   C7]>, DwarfRegNum<[435]>;
def B4   : BRF<  2,  "$a2.lo", [  C8,   C9]>, DwarfRegNum<[436]>;
def B5   : BRF<  2,  "$a2.hi", [ C10,  C11]>, DwarfRegNum<[437]>;
def B6   : BRF<  3,  "$a3.lo", [ C12,  C13]>, DwarfRegNum<[438]>;
def B7   : BRF<  3,  "$a3.hi", [ C14,  C15]>, DwarfRegNum<[439]>;
def B8   : BRF<  4,  "$a4.lo", [ C16,  C17]>, DwarfRegNum<[440]>;
def B9   : BRF<  4,  "$a4.hi", [ C18,  C19]>, DwarfRegNum<[441]>;
def B10  : BRF<  5,  "$a5.lo", [ C20,  C21]>, DwarfRegNum<[442]>;
def B11  : BRF<  5,  "$a5.hi", [ C22,  C23]>, DwarfRegNum<[443]>;
def B12  : BRF<  6,  "$a6.lo", [ C24,  C25]>, DwarfRegNum<[444]>;
def B13  : BRF<  6,  "$a6.hi", [ C26,  C27]>, DwarfRegNum<[445]>;
def B14  : BRF<  7,  "$a7.lo", [ C28,  C29]>, DwarfRegNum<[446]>;
def B15  : BRF<  7,  "$a7.hi", [ C30,  C31]>, DwarfRegNum<[447]>;
def B16  : BRF<  8,  "$a8.lo", [ C32,  C33]>, DwarfRegNum<[448]>;
def B17  : BRF<  8,  "$a8.hi", [ C34,  C35]>, DwarfRegNum<[449]>;
def B18  : BRF<  9,  "$a9.lo", [ C36,  C37]>, DwarfRegNum<[450]>;
def B19  : BRF<  9,  "$a9.hi", [ C38,  C39]>, DwarfRegNum<[451]>;
def B20  : BRF< 10, "$a10.lo", [ C40,  C41]>, DwarfRegNum<[452]>;
def B21  : BRF< 10, "$a10.hi", [ C42,  C43]>, DwarfRegNum<[453]>;
def B22  : BRF< 11, "$a11.lo", [ C44,  C45]>, DwarfRegNum<[454]>;
def B23  : BRF< 11, "$a11.hi", [ C46,  C47]>, DwarfRegNum<[455]>;
def B24  : BRF< 12, "$a12.lo", [ C48,  C49]>, DwarfRegNum<[456]>;
def B25  : BRF< 12, "$a12.hi", [ C50,  C51]>, DwarfRegNum<[457]>;
def B26  : BRF< 13, "$a13.lo", [ C52,  C53]>, DwarfRegNum<[458]>;
def B27  : BRF< 13, "$a13.hi", [ C54,  C55]>, DwarfRegNum<[459]>;
def B28  : BRF< 14, "$a14.lo", [ C56,  C57]>, DwarfRegNum<[460]>;
def B29  : BRF< 14, "$a14.hi", [ C58,  C59]>, DwarfRegNum<[461]>;
def B30  : BRF< 15, "$a15.lo", [ C60,  C61]>, DwarfRegNum<[462]>;
def B31  : BRF< 15, "$a15.hi", [ C62,  C63]>, DwarfRegNum<[463]>;
def B32  : BRF< 16, "$a16.lo", [ C64,  C65]>, DwarfRegNum<[464]>;
def B33  : BRF< 16, "$a16.hi", [ C66,  C67]>, DwarfRegNum<[465]>;
def B34  : BRF< 17, "$a17.lo", [ C68,  C69]>, DwarfRegNum<[466]>;
def B35  : BRF< 17, "$a17.hi", [ C70,  C71]>, DwarfRegNum<[467]>;
def B36  : BRF< 18, "$a18.lo", [ C72,  C73]>, DwarfRegNum<[468]>;
def B37  : BRF< 18, "$a18.hi", [ C74,  C75]>, DwarfRegNum<[469]>;
def B38  : BRF< 19, "$a19.lo", [ C76,  C77]>, DwarfRegNum<[470]>;
def B39  : BRF< 19, "$a19.hi", [ C78,  C79]>, DwarfRegNum<[471]>;
def B40  : BRF< 20, "$a20.lo", [ C80,  C81]>, DwarfRegNum<[472]>;
def B41  : BRF< 20, "$a20.hi", [ C82,  C83]>, DwarfRegNum<[473]>;
def B42  : BRF< 21, "$a21.lo", [ C84,  C85]>, DwarfRegNum<[474]>;
def B43  : BRF< 21, "$a21.hi", [ C86,  C87]>, DwarfRegNum<[475]>;
def B44  : BRF< 22, "$a22.lo", [ C88,  C89]>, DwarfRegNum<[476]>;
def B45  : BRF< 22, "$a22.hi", [ C90,  C91]>, DwarfRegNum<[477]>;
def B46  : BRF< 23, "$a23.lo", [ C92,  C93]>, DwarfRegNum<[478]>;
def B47  : BRF< 23, "$a23.hi", [ C94,  C95]>, DwarfRegNum<[479]>;
def B48  : BRF< 24, "$a24.lo", [ C96,  C97]>, DwarfRegNum<[480]>;
def B49  : BRF< 24, "$a24.hi", [ C98,  C99]>, DwarfRegNum<[481]>;
def B50  : BRF< 25, "$a25.lo", [C100, C101]>, DwarfRegNum<[482]>;
def B51  : BRF< 25, "$a25.hi", [C102, C103]>, DwarfRegNum<[483]>;
def B52  : BRF< 26, "$a26.lo", [C104, C105]>, DwarfRegNum<[484]>;
def B53  : BRF< 26, "$a26.hi", [C106, C107]>, DwarfRegNum<[485]>;
def B54  : BRF< 27, "$a27.lo", [C108, C109]>, DwarfRegNum<[486]>;
def B55  : BRF< 27, "$a27.hi", [C110, C111]>, DwarfRegNum<[487]>;
def B56  : BRF< 28, "$a28.lo", [C112, C113]>, DwarfRegNum<[488]>;
def B57  : BRF< 28, "$a28.hi", [C114, C115]>, DwarfRegNum<[489]>;
def B58  : BRF< 29, "$a29.lo", [C116, C117]>, DwarfRegNum<[490]>;
def B59  : BRF< 29, "$a29.hi", [C118, C119]>, DwarfRegNum<[491]>;
def B60  : BRF< 30, "$a30.lo", [C120, C121]>, DwarfRegNum<[492]>;
def B61  : BRF< 30, "$a30.hi", [C122, C123]>, DwarfRegNum<[493]>;
def B62  : BRF< 31, "$a31.lo", [C124, C125]>, DwarfRegNum<[494]>;
def B63  : BRF< 31, "$a31.hi", [C126, C127]>, DwarfRegNum<[495]>;
def B64  : BRF< 32, "$a32.lo", [C128, C129]>, DwarfRegNum<[496]>;
def B65  : BRF< 32, "$a32.hi", [C130, C131]>, DwarfRegNum<[497]>;
def B66  : BRF< 33, "$a33.lo", [C132, C133]>, DwarfRegNum<[498]>;
def B67  : BRF< 33, "$a33.hi", [C134, C135]>, DwarfRegNum<[499]>;
def B68  : BRF< 34, "$a34.lo", [C136, C137]>, DwarfRegNum<[500]>;
def B69  : BRF< 34, "$a34.hi", [C138, C139]>, DwarfRegNum<[501]>;
def B70  : BRF< 35, "$a35.lo", [C140, C141]>, DwarfRegNum<[502]>;
def B71  : BRF< 35, "$a35.hi", [C142, C143]>, DwarfRegNum<[503]>;
def B72  : BRF< 36, "$a36.lo", [C144, C145]>, DwarfRegNum<[504]>;
def B73  : BRF< 36, "$a36.hi", [C146, C147]>, DwarfRegNum<[505]>;
def B74  : BRF< 37, "$a37.lo", [C148, C149]>, DwarfRegNum<[506]>;
def B75  : BRF< 37, "$a37.hi", [C150, C151]>, DwarfRegNum<[507]>;
def B76  : BRF< 38, "$a38.lo", [C152, C153]>, DwarfRegNum<[508]>;
def B77  : BRF< 38, "$a38.hi", [C154, C155]>, DwarfRegNum<[509]>;
def B78  : BRF< 39, "$a39.lo", [C156, C157]>, DwarfRegNum<[510]>;
def B79  : BRF< 39, "$a39.hi", [C158, C159]>, DwarfRegNum<[511]>;
def B80  : BRF< 40, "$a40.lo", [C160, C161]>, DwarfRegNum<[512]>;
def B81  : BRF< 40, "$a40.hi", [C162, C163]>, DwarfRegNum<[513]>;
def B82  : BRF< 41, "$a41.lo", [C164, C165]>, DwarfRegNum<[514]>;
def B83  : BRF< 41, "$a41.hi", [C166, C167]>, DwarfRegNum<[515]>;
def B84  : BRF< 42, "$a42.lo", [C168, C169]>, DwarfRegNum<[516]>;
def B85  : BRF< 42, "$a42.hi", [C170, C171]>, DwarfRegNum<[517]>;
def B86  : BRF< 43, "$a43.lo", [C172, C173]>, DwarfRegNum<[518]>;
def B87  : BRF< 43, "$a43.hi", [C174, C175]>, DwarfRegNum<[519]>;
def B88  : BRF< 44, "$a44.lo", [C176, C177]>, DwarfRegNum<[520]>;
def B89  : BRF< 44, "$a44.hi", [C178, C179]>, DwarfRegNum<[521]>;
def B90  : BRF< 45, "$a45.lo", [C180, C181]>, DwarfRegNum<[522]>;
def B91  : BRF< 45, "$a45.hi", [C182, C183]>, DwarfRegNum<[523]>;
def B92  : BRF< 46, "$a46.lo", [C184, C185]>, DwarfRegNum<[524]>;
def B93  : BRF< 46, "$a46.hi", [C186, C187]>, DwarfRegNum<[525]>;
def B94  : BRF< 47, "$a47.lo", [C188, C189]>, DwarfRegNum<[526]>;
def B95  : BRF< 47, "$a47.hi", [C190, C191]>, DwarfRegNum<[527]>;
def B96  : BRF< 48, "$a48.lo", [C192, C193]>, DwarfRegNum<[528]>;
def B97  : BRF< 48, "$a48.hi", [C194, C195]>, DwarfRegNum<[529]>;
def B98  : BRF< 49, "$a49.lo", [C196, C197]>, DwarfRegNum<[530]>;
def B99  : BRF< 49, "$a49.hi", [C198, C199]>, DwarfRegNum<[531]>;
def B100 : BRF< 50, "$a50.lo", [C200, C201]>, DwarfRegNum<[532]>;
def B101 : BRF< 50, "$a50.hi", [C202, C203]>, DwarfRegNum<[533]>;
def B102 : BRF< 51, "$a51.lo", [C204, C205]>, DwarfRegNum<[534]>;
def B103 : BRF< 51, "$a51.hi", [C206, C207]>, DwarfRegNum<[535]>;
def B104 : BRF< 52, "$a52.lo", [C208, C209]>, DwarfRegNum<[536]>;
def B105 : BRF< 52, "$a52.hi", [C210, C211]>, DwarfRegNum<[537]>;
def B106 : BRF< 53, "$a53.lo", [C212, C213]>, DwarfRegNum<[538]>;
def B107 : BRF< 53, "$a53.hi", [C214, C215]>, DwarfRegNum<[539]>;
def B108 : BRF< 54, "$a54.lo", [C216, C217]>, DwarfRegNum<[540]>;
def B109 : BRF< 54, "$a54.hi", [C218, C219]>, DwarfRegNum<[541]>;
def B110 : BRF< 55, "$a55.lo", [C220, C221]>, DwarfRegNum<[542]>;
def B111 : BRF< 55, "$a55.hi", [C222, C223]>, DwarfRegNum<[543]>;
def B112 : BRF< 56, "$a56.lo", [C224, C225]>, DwarfRegNum<[544]>;
def B113 : BRF< 56, "$a56.hi", [C226, C227]>, DwarfRegNum<[545]>;
def B114 : BRF< 57, "$a57.lo", [C228, C229]>, DwarfRegNum<[546]>;
def B115 : BRF< 57, "$a57.hi", [C230, C231]>, DwarfRegNum<[547]>;
def B116 : BRF< 58, "$a58.lo", [C232, C233]>, DwarfRegNum<[548]>;
def B117 : BRF< 58, "$a58.hi", [C234, C235]>, DwarfRegNum<[549]>;
def B118 : BRF< 59, "$a59.lo", [C236, C237]>, DwarfRegNum<[550]>;
def B119 : BRF< 59, "$a59.hi", [C238, C239]>, DwarfRegNum<[551]>;
def B120 : BRF< 60, "$a60.lo", [C240, C241]>, DwarfRegNum<[552]>;
def B121 : BRF< 60, "$a60.hi", [C242, C243]>, DwarfRegNum<[553]>;
def B122 : BRF< 61, "$a61.lo", [C244, C245]>, DwarfRegNum<[554]>;
def B123 : BRF< 61, "$a61.hi", [C246, C247]>, DwarfRegNum<[555]>;
def B124 : BRF< 62, "$a62.lo", [C248, C249]>, DwarfRegNum<[556]>;
def B125 : BRF< 62, "$a62.hi", [C250, C251]>, DwarfRegNum<[557]>;
def B126 : BRF< 63, "$a63.lo", [C252, C253]>, DwarfRegNum<[558]>;
def B127 : BRF< 63, "$a63.hi", [C254, C255]>, DwarfRegNum<[559]>;


// Accelerator Register File
def A0  : ARF< 0,  "$a0", [  C0,   C1,   C2,   C3]>, DwarfRegNum<[560]>;
def A1  : ARF< 1,  "$a1", [  C4,   C5,   C6,   C7]>, DwarfRegNum<[561]>;
def A2  : ARF< 2,  "$a2", [  C8,   C9,  C10,  C11]>, DwarfRegNum<[562]>;
def A3  : ARF< 3,  "$a3", [ C12,  C13,  C14,  C15]>, DwarfRegNum<[563]>;
def A4  : ARF< 4,  "$a4", [ C16,  C17,  C18,  C19]>, DwarfRegNum<[564]>;
def A5  : ARF< 5,  "$a5", [ C20,  C21,  C22,  C23]>, DwarfRegNum<[565]>;
def A6  : ARF< 6,  "$a6", [ C24,  C25,  C26,  C27]>, DwarfRegNum<[566]>;
def A7  : ARF< 7,  "$a7", [ C28,  C29,  C30,  C31]>, DwarfRegNum<[567]>;
def A8  : ARF< 8,  "$a8", [ C32,  C33,  C34,  C35]>, DwarfRegNum<[568]>;
def A9  : ARF< 9,  "$a9", [ C36,  C37,  C38,  C39]>, DwarfRegNum<[569]>;
def A10 : ARF<10, "$a10", [ C40,  C41,  C42,  C43]>, DwarfRegNum<[570]>;
def A11 : ARF<11, "$a11", [ C44,  C45,  C46,  C47]>, DwarfRegNum<[571]>;
def A12 : ARF<12, "$a12", [ C48,  C49,  C50,  C51]>, DwarfRegNum<[572]>;
def A13 : ARF<13, "$a13", [ C52,  C53,  C54,  C55]>, DwarfRegNum<[573]>;
def A14 : ARF<14, "$a14", [ C56,  C57,  C58,  C59]>, DwarfRegNum<[574]>;
def A15 : ARF<15, "$a15", [ C60,  C61,  C62,  C63]>, DwarfRegNum<[575]>;
def A16 : ARF<16, "$a16", [ C64,  C65,  C66,  C67]>, DwarfRegNum<[576]>;
def A17 : ARF<17, "$a17", [ C68,  C69,  C70,  C71]>, DwarfRegNum<[577]>;
def A18 : ARF<18, "$a18", [ C72,  C73,  C74,  C75]>, DwarfRegNum<[578]>;
def A19 : ARF<19, "$a19", [ C76,  C77,  C78,  C79]>, DwarfRegNum<[579]>;
def A20 : ARF<20, "$a20", [ C80,  C81,  C82,  C83]>, DwarfRegNum<[580]>;
def A21 : ARF<21, "$a21", [ C84,  C85,  C86,  C87]>, DwarfRegNum<[581]>;
def A22 : ARF<22, "$a22", [ C88,  C89,  C90,  C91]>, DwarfRegNum<[582]>;
def A23 : ARF<23, "$a23", [ C92,  C93,  C94,  C95]>, DwarfRegNum<[583]>;
def A24 : ARF<24, "$a24", [ C96,  C97,  C98,  C99]>, DwarfRegNum<[584]>;
def A25 : ARF<25, "$a25", [C100, C101, C102, C103]>, DwarfRegNum<[585]>;
def A26 : ARF<26, "$a26", [C104, C105, C106, C107]>, DwarfRegNum<[586]>;
def A27 : ARF<27, "$a27", [C108, C109, C110, C111]>, DwarfRegNum<[587]>;
def A28 : ARF<28, "$a28", [C112, C113, C114, C115]>, DwarfRegNum<[588]>;
def A29 : ARF<29, "$a29", [C116, C117, C118, C119]>, DwarfRegNum<[589]>;
def A30 : ARF<30, "$a30", [C120, C121, C122, C123]>, DwarfRegNum<[590]>;
def A31 : ARF<31, "$a31", [C124, C125, C126, C127]>, DwarfRegNum<[591]>;
def A32 : ARF<32, "$a32", [C128, C129, C130, C131]>, DwarfRegNum<[592]>;
def A33 : ARF<33, "$a33", [C132, C133, C134, C135]>, DwarfRegNum<[593]>;
def A34 : ARF<34, "$a34", [C136, C137, C138, C139]>, DwarfRegNum<[594]>;
def A35 : ARF<35, "$a35", [C140, C141, C142, C143]>, DwarfRegNum<[595]>;
def A36 : ARF<36, "$a36", [C144, C145, C146, C147]>, DwarfRegNum<[596]>;
def A37 : ARF<37, "$a37", [C148, C149, C150, C151]>, DwarfRegNum<[597]>;
def A38 : ARF<38, "$a38", [C152, C153, C154, C155]>, DwarfRegNum<[598]>;
def A39 : ARF<39, "$a39", [C156, C157, C158, C159]>, DwarfRegNum<[599]>;
def A40 : ARF<40, "$a40", [C160, C161, C162, C163]>, DwarfRegNum<[600]>;
def A41 : ARF<41, "$a41", [C164, C165, C166, C167]>, DwarfRegNum<[601]>;
def A42 : ARF<42, "$a42", [C168, C169, C170, C171]>, DwarfRegNum<[602]>;
def A43 : ARF<43, "$a43", [C172, C173, C174, C175]>, DwarfRegNum<[603]>;
def A44 : ARF<44, "$a44", [C176, C177, C178, C179]>, DwarfRegNum<[604]>;
def A45 : ARF<45, "$a45", [C180, C181, C182, C183]>, DwarfRegNum<[605]>;
def A46 : ARF<46, "$a46", [C184, C185, C186, C187]>, DwarfRegNum<[606]>;
def A47 : ARF<47, "$a47", [C188, C189, C190, C191]>, DwarfRegNum<[607]>;
def A48 : ARF<48, "$a48", [C192, C193, C194, C195]>, DwarfRegNum<[608]>;
def A49 : ARF<49, "$a49", [C196, C197, C198, C199]>, DwarfRegNum<[609]>;
def A50 : ARF<50, "$a50", [C200, C201, C202, C203]>, DwarfRegNum<[610]>;
def A51 : ARF<51, "$a51", [C204, C205, C206, C207]>, DwarfRegNum<[611]>;
def A52 : ARF<52, "$a52", [C208, C209, C210, C211]>, DwarfRegNum<[612]>;
def A53 : ARF<53, "$a53", [C212, C213, C214, C215]>, DwarfRegNum<[613]>;
def A54 : ARF<54, "$a54", [C216, C217, C218, C219]>, DwarfRegNum<[614]>;
def A55 : ARF<55, "$a55", [C220, C221, C222, C223]>, DwarfRegNum<[615]>;
def A56 : ARF<56, "$a56", [C224, C225, C226, C227]>, DwarfRegNum<[616]>;
def A57 : ARF<57, "$a57", [C228, C229, C230, C231]>, DwarfRegNum<[617]>;
def A58 : ARF<58, "$a58", [C232, C233, C234, C235]>, DwarfRegNum<[618]>;
def A59 : ARF<59, "$a59", [C236, C237, C238, C239]>, DwarfRegNum<[619]>;
def A60 : ARF<60, "$a60", [C240, C241, C242, C243]>, DwarfRegNum<[620]>;
def A61 : ARF<61, "$a61", [C244, C245, C246, C247]>, DwarfRegNum<[621]>;
def A62 : ARF<62, "$a62", [C248, C249, C250, C251]>, DwarfRegNum<[622]>;
def A63 : ARF<63, "$a63", [C252, C253, C254, C255]>, DwarfRegNum<[623]>;


// Wide Register File
def W0  : WRF< 0,   "$a0a1", [  C0,   C1,   C2,   C3,   C4,   C5,   C6,   C7]>, DwarfRegNum<[624]>;
def W1  : WRF< 1,   "$a2a3", [  C8,   C9,  C10,  C11,  C12,  C13,  C14,  C15]>, DwarfRegNum<[625]>;
def W2  : WRF< 2,   "$a4a5", [ C16,  C17,  C18,  C19,  C20,  C21,  C22,  C23]>, DwarfRegNum<[626]>;
def W3  : WRF< 3,   "$a6a7", [ C24,  C25,  C26,  C27,  C28,  C29,  C30,  C31]>, DwarfRegNum<[627]>;
def W4  : WRF< 4,   "$a8a9", [ C32,  C33,  C34,  C35,  C36,  C37,  C38,  C39]>, DwarfRegNum<[628]>;
def W5  : WRF< 5, "$a10a11", [ C40,  C41,  C42,  C43,  C44,  C45,  C46,  C47]>, DwarfRegNum<[629]>;
def W6  : WRF< 6, "$a12a13", [ C48,  C49,  C50,  C51,  C52,  C53,  C54,  C55]>, DwarfRegNum<[630]>;
def W7  : WRF< 7, "$a14a15", [ C56,  C57,  C58,  C59,  C60,  C61,  C62,  C63]>, DwarfRegNum<[631]>;
def W8  : WRF< 8, "$a16a17", [ C64,  C65,  C66,  C67,  C68,  C69,  C70,  C71]>, DwarfRegNum<[632]>;
def W9  : WRF< 9, "$a18a19", [ C72,  C73,  C74,  C75,  C76,  C77,  C78,  C79]>, DwarfRegNum<[633]>;
def W10 : WRF<10, "$a20a21", [ C80,  C81,  C82,  C83,  C84,  C85,  C86,  C87]>, DwarfRegNum<[634]>;
def W11 : WRF<11, "$a22a23", [ C88,  C89,  C90,  C91,  C92,  C93,  C94,  C95]>, DwarfRegNum<[635]>;
def W12 : WRF<12, "$a24a25", [ C96,  C97,  C98,  C99, C100, C101, C102, C103]>, DwarfRegNum<[636]>;
def W13 : WRF<13, "$a26a27", [C104, C105, C106, C107, C108, C109, C110, C111]>, DwarfRegNum<[637]>;
def W14 : WRF<14, "$a28a29", [C112, C113, C114, C115, C116, C117, C118, C119]>, DwarfRegNum<[638]>;
def W15 : WRF<15, "$a30a31", [C120, C121, C122, C123, C124, C125, C126, C127]>, DwarfRegNum<[639]>;
def W16 : WRF<16, "$a32a33", [C128, C129, C130, C131, C132, C133, C134, C135]>, DwarfRegNum<[640]>;
def W17 : WRF<17, "$a34a35", [C136, C137, C138, C139, C140, C141, C142, C143]>, DwarfRegNum<[641]>;
def W18 : WRF<18, "$a36a37", [C144, C145, C146, C147, C148, C149, C150, C151]>, DwarfRegNum<[642]>;
def W19 : WRF<19, "$a38a39", [C152, C153, C154, C155, C156, C157, C158, C159]>, DwarfRegNum<[643]>;
def W20 : WRF<20, "$a40a41", [C160, C161, C162, C163, C164, C165, C166, C167]>, DwarfRegNum<[644]>;
def W21 : WRF<21, "$a42a43", [C168, C169, C170, C171, C172, C173, C174, C175]>, DwarfRegNum<[645]>;
def W22 : WRF<22, "$a44a45", [C176, C177, C178, C179, C180, C181, C182, C183]>, DwarfRegNum<[646]>;
def W23 : WRF<23, "$a46a47", [C184, C185, C186, C187, C188, C189, C190, C191]>, DwarfRegNum<[647]>;
def W24 : WRF<24, "$a48a49", [C192, C193, C194, C195, C196, C197, C198, C199]>, DwarfRegNum<[648]>;
def W25 : WRF<25, "$a50a51", [C200, C201, C202, C203, C204, C205, C206, C207]>, DwarfRegNum<[649]>;
def W26 : WRF<26, "$a52a53", [C208, C209, C210, C211, C212, C213, C214, C215]>, DwarfRegNum<[650]>;
def W27 : WRF<27, "$a54a55", [C216, C217, C218, C219, C220, C221, C222, C223]>, DwarfRegNum<[651]>;
def W28 : WRF<28, "$a56a57", [C224, C225, C226, C227, C228, C229, C230, C231]>, DwarfRegNum<[652]>;
def W29 : WRF<29, "$a58a59", [C232, C233, C234, C235, C236, C237, C238, C239]>, DwarfRegNum<[653]>;
def W30 : WRF<30, "$a60a61", [C240, C241, C242, C243, C244, C245, C246, C247]>, DwarfRegNum<[654]>;
def W31 : WRF<31, "$a62a63", [C248, C249, C250, C251, C252, C253, C254, C255]>, DwarfRegNum<[655]>;


// Extended Register File
def X0  : XRF< 0,     "$a0a1a2a3", [  C0,   C1,   C2,   C3,   C4,   C5,   C6,   C7,   C8,   C9,  C10,  C11,  C12,  C13,  C14,  C15]>, DwarfRegNum<[656]>;
def X1  : XRF< 1,     "$a4a5a6a7", [ C16,  C17,  C18,  C19,  C20,  C21,  C22,  C23,  C24,  C25,  C26,  C27,  C28,  C29,  C30,  C31]>, DwarfRegNum<[657]>;
def X2  : XRF< 2,   "$a8a9a10a11", [ C32,  C33,  C34,  C35,  C36,  C37,  C38,  C39,  C40,  C41,  C42,  C43,  C44,  C45,  C46,  C47]>, DwarfRegNum<[658]>;
def X3  : XRF< 3, "$a12a13a14a15", [ C48,  C49,  C50,  C51,  C52,  C53,  C54,  C55,  C56,  C57,  C58,  C59,  C60,  C61,  C62,  C63]>, DwarfRegNum<[659]>;
def X4  : XRF< 4, "$a16a17a18a19", [ C64,  C65,  C66,  C67,  C68,  C69,  C70,  C71,  C72,  C73,  C74,  C75,  C76,  C77,  C78,  C79]>, DwarfRegNum<[660]>;
def X5  : XRF< 5, "$a20a21a22a23", [ C80,  C81,  C82,  C83,  C84,  C85,  C86,  C87,  C88,  C89,  C90,  C91,  C92,  C93,  C94,  C95]>, DwarfRegNum<[661]>;
def X6  : XRF< 6, "$a24a25a26a27", [ C96,  C97,  C98,  C99, C100, C101, C102, C103, C104, C105, C106, C107, C108, C109, C110, C111]>, DwarfRegNum<[662]>;
def X7  : XRF< 7, "$a28a29a30a31", [C112, C113, C114, C115, C116, C117, C118, C119, C120, C121, C122, C123, C124, C125, C126, C127]>, DwarfRegNum<[663]>;
def X8  : XRF< 8, "$a32a33a34a35", [C128, C129, C130, C131, C132, C133, C134, C135, C136, C137, C138, C139, C140, C141, C142, C143]>, DwarfRegNum<[664]>;
def X9  : XRF< 9, "$a36a37a38a39", [C144, C145, C146, C147, C148, C149, C150, C151, C152, C153, C154, C155, C156, C157, C158, C159]>, DwarfRegNum<[665]>;
def X10 : XRF<10, "$a40a41a42a43", [C160, C161, C162, C163, C164, C165, C166, C167, C168, C169, C170, C171, C172, C173, C174, C175]>, DwarfRegNum<[666]>;
def X11 : XRF<11, "$a44a45a46a47", [C176, C177, C178, C179, C180, C181, C182, C183, C184, C185, C186, C187, C188, C189, C190, C191]>, DwarfRegNum<[667]>;
def X12 : XRF<12, "$a48a49a50a51", [C192, C193, C194, C195, C196, C197, C198, C199, C200, C201, C202, C203, C204, C205, C206, C207]>, DwarfRegNum<[668]>;
def X13 : XRF<13, "$a52a53a54a55", [C208, C209, C210, C211, C212, C213, C214, C215, C216, C217, C218, C219, C220, C221, C222, C223]>, DwarfRegNum<[669]>;
def X14 : XRF<14, "$a56a57a58a59", [C224, C225, C226, C227, C228, C229, C230, C231, C232, C233, C234, C235, C236, C237, C238, C239]>, DwarfRegNum<[670]>;
def X15 : XRF<15, "$a60a61a62a63", [C240, C241, C242, C243, C244, C245, C246, C247, C248, C249, C250, C251, C252, C253, C254, C255]>, DwarfRegNum<[671]>;

def PSReg : RegisterClass<"K1C", [i1, i8, i16, i32, i64, f16, f32, f64, v8i8, v4i16, v2i32, v4f16, v2f32], 64, (add PS)>;

let Size = 64 in
def RAReg : RegisterClass<"K1C", [i1, i8, i16, i32, i64, f16, f32, f64, v8i8, v4i16, v2i32, v4f16, v2f32], 64, (add RA)>;

// SRF - System Register File
def SystemReg : RegisterClass<"K1C", [i1, i8, i16, i32, i64, f16, f32, f64, v8i8, v4i16, v2i32, v4f16, v2f32], 64, (add PC, PS, SPC, SPS, SSPC, SSPS, SR3, SR4, CS, RA, PI, LS, LE, LC, EA, EV, RES0, RES1, RES2, RES3, EV4, MEN, PMSA, AESPC, PM0, PM1, PM2, PM3, PMC, SR0, SR1, SR2, T0V, T1V, T0R, T1R, TC, WDC, WDR, ILE, ILL, ILH, MMC, TEL, TEH, DV, OCE0, OCE1, OCEC, OCEA, ES, ILR, WS, MES)>;

// GRF - General Register File
let Size = 64 in
def SingleReg : RegisterClass<"K1C", [i1, i8, i16, i32, i64, f16, f32, f64, v8i8, v4i16, v2i32, v4f16, v2f32], 64, (add R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, R18, R19, R20, R21, R22, R23, R24, R25, R26, R27, R28, R29, R30, R31, R32, R33, R34, R35, R36, R37, R38, R39, R40, R41, R42, R43, R44, R45, R46, R47, R48, R49, R50, R51, R52, R53, R54, R55, R56, R57, R58, R59, R60, R61, R62, R63)>;

// PRF - Paired Register File
def PairedReg : RegisterClass<"K1C", [v16i8, v8i16, v4i32, v2i64, v8f16, v4f32, v2f64], 128, (add P0, P2, P4, P6, P8, P10, P12, P14, P16, P18, P20, P22, P24, P26, P28, P30, P32, P34, P36, P38, P40, P42, P44, P46, P48, P50, P52, P54, P56, P58, P60, P62)>;

// QRF - Quadruple Register File
def QuadReg : RegisterClass<"K1C", [v32i8, v16i16, v8i32, v4i64, /*v16f16,*/ v8f32, v4f64], 256, (add Q0, Q4, Q8, Q12, Q16, Q20, Q24, Q28, Q32, Q36, Q40, Q44, Q48, Q52, Q56, Q60)>;

// CRF - Coprocessor Register File
def CoproReg : RegisterClass<"K1C", [i1, i8, i16, i32, i64, f16, f32, f64, v8i8, v4i16, v2i32, v4f16, v2f32], 64, (add C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13, C14, C15, C16, C17, C18, C19, C20, C21, C22, C23, C24, C25, C26, C27, C28, C29, C30, C31, C32, C33, C34, C35, C36, C37, C38, C39, C40, C41, C42, C43, C44, C45, C46, C47, C48, C49, C50, C51, C52, C53, C54, C55, C56, C57, C58, C59, C60, C61, C62, C63, C64, C65, C66, C67, C68, C69, C70, C71, C72, C73, C74, C75, C76, C77, C78, C79, C80, C81, C82, C83, C84, C85, C86, C87, C88, C89, C90, C91, C92, C93, C94, C95, C96, C97, C98, C99, C100, C101, C102, C103, C104, C105, C106, C107, C108, C109, C110, C111, C112, C113, C114, C115, C116, C117, C118, C119, C120, C121, C122, C123, C124, C125, C126, C127, C128, C129, C130, C131, C132, C133, C134, C135, C136, C137, C138, C139, C140, C141, C142, C143, C144, C145, C146, C147, C148, C149, C150, C151, C152, C153, C154, C155, C156, C157, C158, C159, C160, C161, C162, C163, C164, C165, C166, C167, C168, C169, C170, C171, C172, C173, C174, C175, C176, C177, C178, C179, C180, C181, C182, C183, C184, C185, C186, C187, C188, C189, C190, C191, C192, C193, C194, C195, C196, C197, C198, C199, C200, C201, C202, C203, C204, C205, C206, C207, C208, C209, C210, C211, C212, C213, C214, C215, C216, C217, C218, C219, C220, C221, C222, C223, C224, C225, C226, C227, C228, C229, C230, C231, C232, C233, C234, C235, C236, C237, C238, C239, C240, C241, C242, C243, C244, C245, C246, C247, C248, C249, C250, C251, C252, C253, C254, C255)>;

// BRF - Block Register File
def BlockReg : RegisterClass<"K1C", [v16i8, v8i16, v4i32, v2i64, v8f16, v4f32, v2f64], 128, (add B0, B1, B2, B3, B4, B5, B6, B7, B8, B9, B10, B11, B12, B13, B14, B15, B16, B17, B18, B19, B20, B21, B22, B23, B24, B25, B26, B27, B28, B29, B30, B31, B32, B33, B34, B35, B36, B37, B38, B39, B40, B41, B42, B43, B44, B45, B46, B47, B48, B49, B50, B51, B52, B53, B54, B55, B56, B57, B58, B59, B60, B61, B62, B63, B64, B65, B66, B67, B68, B69, B70, B71, B72, B73, B74, B75, B76, B77, B78, B79, B80, B81, B82, B83, B84, B85, B86, B87, B88, B89, B90, B91, B92, B93, B94, B95, B96, B97, B98, B99, B100, B101, B102, B103, B104, B105, B106, B107, B108, B109, B110, B111, B112, B113, B114, B115, B116, B117, B118, B119, B120, B121, B122, B123, B124, B125, B126, B127)>;

// ARF - Accelerator Register File
def AccelReg : RegisterClass<"K1C", [v32i8, v16i16, v8i32, v4i64, /*v16f16,*/ v8f32, v4f64], 256, (add A0, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18, A19, A20, A21, A22, A23, A24, A25, A26, A27, A28, A29, A30, A31, A32, A33, A34, A35, A36, A37, A38, A39, A40, A41, A42, A43, A44, A45, A46, A47, A48, A49, A50, A51, A52, A53, A54, A55, A56, A57, A58, A59, A60, A61, A62, A63)>;

// WRF - Wide Register File
def WideReg : RegisterClass<"K1C", [v64i8, v32i16, v16i32, v8i64, /*v32f16,*/ v16f32, v8f64], 512, (add W0, W1, W2, W3, W4, W5, W6, W7, W8, W9, W10, W11, W12, W13, W14, W15, W16, W17, W18, W19, W20, W21, W22, W23, W24, W25, W26, W27, W28, W29, W30, W31)>;

// XRF - Extended Register File
def ExtendReg : RegisterClass<"K1C", [v128i8, v64i16, v32i32, v16i64 /*v64f16,*/ /*v32f32,*/ /*v16f64*/], 1024, (add X0, X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14, X15)>;

// SRF - System Registers Excluding PC and PS
def NopcpsReg : RegisterClass<"K1C", [i1, i8, i16, i32, i64, f16, f32, f64, v8i8, v4i16, v2i32, v4f16, v2f32], 64, (add SPC, SPS, SSPC, SSPS, SR3, SR4, CS, RA, PI, LS, LE, LC, EA, EV, RES0, RES1, RES2, RES3, EV4, MEN, PMSA, AESPC, PM0, PM1, PM2, PM3, PMC, SR0, SR1, SR2, T0V, T1V, T0R, T1R, TC, WDC, WDR, ILE, ILL, ILH, MMC, TEL, TEH, DV, OCE0, OCE1, OCEC, OCEA, ES, ILR, WS, MES)>;

// ARF - Accelerator Registers Even Numbered
def AccelRegE : RegisterClass<"K1C", [v32i8, v16i16, v8i32, v4i64, /*v16f16,*/ v8f32, v4f64], 256, (add A0, A2, A4, A6, A8, A10, A12, A14, A16, A18, A20, A22, A24, A26, A28, A30, A32, A34, A36, A38, A40, A42, A44, A46, A48, A50, A52, A54, A56, A58, A60, A62)>;

// ARF - Accelerator Registers Odd Numbered
def AccelRegO : RegisterClass<"K1C", [v32i8, v16i16, v8i32, v4i64, /*v16f16,*/ v8f32, v4f64], 256, (add A1, A3, A5, A7, A9, A11, A13, A15, A17, A19, A21, A23, A25, A27, A29, A31, A33, A35, A37, A39, A41, A43, A45, A47, A49, A51, A53, A55, A57, A59, A61, A63)>;

// BRF - Block Registers Even Numbered
def BlockRegE : RegisterClass<"K1C", [v16i8, v8i16, v4i32, v2i64, v8f16, v4f32, v2f64], 128, (add B0, B2, B4, B6, B8, B10, B12, B14, B16, B18, B20, B22, B24, B26, B28, B30, B32, B34, B36, B38, B40, B42, B44, B46, B48, B50, B52, B54, B56, B58, B60, B62, B64, B66, B68, B70, B72, B74, B76, B78, B80, B82, B84, B86, B88, B90, B92, B94, B96, B98, B100, B102, B104, B106, B108, B110, B112, B114, B116, B118, B120, B122, B124, B126)>;

// BRF - Block Registers Odd Numbered
def BlockRegO : RegisterClass<"K1C", [v16i8, v8i16, v4i32, v2i64, v8f16, v4f32, v2f64], 128, (add B1, B3, B5, B7, B9, B11, B13, B15, B17, B19, B21, B23, B25, B27, B29, B31, B33, B35, B37, B39, B41, B43, B45, B47, B49, B51, B53, B55, B57, B59, B61, B63, B65, B67, B69, B71, B73, B75, B77, B79, B81, B83, B85, B87, B89, B91, B93, B95, B97, B99, B101, B103, B105, B107, B109, B111, B113, B115, B117, B119, B121, B123, B125, B127)>;

// BRF - Block Registers 0 Modulo 4
def BlockReg0M4 : RegisterClass<"K1C", [v16i8, v8i16, v4i32, v2i64, v8f16, v4f32, v2f64], 128, (add B0, B4, B8, B12, B16, B20, B24, B28, B32, B36, B40, B44, B48, B52, B56, B60, B64, B68, B72, B76, B80, B84, B88, B92, B96, B100, B104, B108, B112, B116, B120, B124)>;

// BRF - Block Registers 1 Modulo 4
def BlockReg1M4 : RegisterClass<"K1C", [v16i8, v8i16, v4i32, v2i64, v8f16, v4f32, v2f64], 128, (add B1, B5, B9, B13, B17, B21, B25, B29, B33, B37, B41, B45, B49, B53, B57, B61, B65, B69, B73, B77, B81, B85, B89, B93, B97, B101, B105, B109, B113, B117, B121, B125)>;

// BRF - Block Registers 2 Modulo 4
def BlockReg2M4 : RegisterClass<"K1C", [v16i8, v8i16, v4i32, v2i64, v8f16, v4f32, v2f64], 128, (add B2, B6, B10, B14, B18, B22, B26, B30, B34, B38, B42, B46, B50, B54, B58, B62, B66, B70, B74, B78, B82, B86, B90, B94, B98, B102, B106, B110, B114, B118, B122, B126)>;

// BRF - Block Registers 3 Modulo 4
def BlockReg3M4 : RegisterClass<"K1C", [v16i8, v8i16, v4i32, v2i64, v8f16, v4f32, v2f64], 128, (add B3, B7, B11, B15, B19, B23, B27, B31, B35, B39, B43, B47, B51, B55, B59, B63, B67, B71, B75, B79, B83, B87, B91, B95, B99, B103, B107, B111, B115, B119, B123, B127)>;

// CRF - Coprocessor Registers 0 Modulo 4
def CoproReg0M4 : RegisterClass<"K1C", [i1, i8, i16, i32, i64, f16, f32, f64, v8i8, v4i16, v2i32, v4f16, v2f32], 64, (add C0, C4, C8, C12, C16, C20, C24, C28, C32, C36, C40, C44, C48, C52, C56, C60, C64, C68, C72, C76, C80, C84, C88, C92, C96, C100, C104, C108, C112, C116, C120, C124, C128, C132, C136, C140, C144, C148, C152, C156, C160, C164, C168, C172, C176, C180, C184, C188, C192, C196, C200, C204, C208, C212, C216, C220, C224, C228, C232, C236, C240, C244, C248, C252)>;

// CRF - Coprocessor Registers 1 Modulo 4
def CoproReg1M4 : RegisterClass<"K1C", [i1, i8, i16, i32, i64, f16, f32, f64, v8i8, v4i16, v2i32, v4f16, v2f32], 64, (add C1, C5, C9, C13, C17, C21, C25, C29, C33, C37, C41, C45, C49, C53, C57, C61, C65, C69, C73, C77, C81, C85, C89, C93, C97, C101, C105, C109, C113, C117, C121, C125, C129, C133, C137, C141, C145, C149, C153, C157, C161, C165, C169, C173, C177, C181, C185, C189, C193, C197, C201, C205, C209, C213, C217, C221, C225, C229, C233, C237, C241, C245, C249, C253)>;

// CRF - Coprocessor Registers 2 Modulo 4
def CoproReg2M4 : RegisterClass<"K1C", [i1, i8, i16, i32, i64, f16, f32, f64, v8i8, v4i16, v2i32, v4f16, v2f32], 64, (add C2, C6, C10, C14, C18, C22, C26, C30, C34, C38, C42, C46, C50, C54, C58, C62, C66, C70, C74, C78, C82, C86, C90, C94, C98, C102, C106, C110, C114, C118, C122, C126, C130, C134, C138, C142, C146, C150, C154, C158, C162, C166, C170, C174, C178, C182, C186, C190, C194, C198, C202, C206, C210, C214, C218, C222, C226, C230, C234, C238, C242, C246, C250, C254)>;

// CRF - Coprocessor Registers 3 Modulo 4
def CoproReg3M4 : RegisterClass<"K1C", [i1, i8, i16, i32, i64, f16, f32, f64, v8i8, v4i16, v2i32, v4f16, v2f32], 64, (add C3, C7, C11, C15, C19, C23, C27, C31, C35, C39, C43, C47, C51, C55, C59, C63, C67, C71, C75, C79, C83, C87, C91, C95, C99, C103, C107, C111, C115, C119, C123, C127, C131, C135, C139, C143, C147, C151, C155, C159, C163, C167, C171, C175, C179, C183, C187, C191, C195, C199, C203, C207, C211, C215, C219, C223, C227, C231, C235, C239, C243, C247, C251, C255)>;
