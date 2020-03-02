//===-- KVXRegisterInfo.td - KVX Register defs -------------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
//  Declarations that describe the KVX register file
//===----------------------------------------------------------------------===//

// This file was automatically generated,
//   *DO NOT EDIT*,
//   please contact code owner.
// Last generated: 2020-01-28 17:49:54.224406.


let Namespace = "KVX" in {

// KVX Register base class:
//   - KVXRegister
//   - KVXRegisterWithSubRegs
// Registers are identified with 9-bit ID numbers.
// Registers with sub-registers are always covered by them.

class KVXRegister<bits<9> num, string n, list<string> alt = []>
      : Register<n, alt> {
  let HWEncoding{8-0} = num;
}

class KVXRegisterWithSubRegs<bits<9> num, string n,
                             list<Register> subregs, list<string> alt = []>
      : RegisterWithSubRegs<n, subregs> {
  let HWEncoding{8-0} = num;
  let CoveredBySubRegs = 1;
  list<string> AltNames = alt;
}


// SFR - System Function Registers
class SFR<bits<9> num, string n, list<string> alt = []>
      : KVXRegister<num, n, alt>;

// GPR - General-Purpose Registers
class GPR<bits<9> num, string n, list<string> alt = []>
      : KVXRegister<num, n, alt>;

// PGR - Paired General Registers
class PGR<bits<9> num, string n, list<Register> subregs>
      : KVXRegisterWithSubRegs<num, n, subregs> {
  let SubRegIndices = [SubRegIndex<64,   0>, SubRegIndex<64,  64>];
}

// QGR - Quadruple General Registers
class QGR<bits<9> num, string n, list<Register> subregs>
      : KVXRegisterWithSubRegs<num, n, subregs> {
  let SubRegIndices = [SubRegIndex<64,   0>, SubRegIndex<64,  64>,
                       SubRegIndex<64, 128>, SubRegIndex<64, 192>];
}

// XCR - Extension Coprocessor Registers
class XCR<bits<9> num, string n, list<string> alt = []>
      : KVXRegister<num, n, alt>;

// XBR - Extension Block Registers
class XBR<bits<9> num, string n, list<Register> subregs, list<string> alt = []>
      : KVXRegisterWithSubRegs<num, n, subregs, alt> {
  let SubRegIndices = [SubRegIndex<64,   0>, SubRegIndex<64,  64>];
}

// XVR - Extension Vector Registers
class XVR<bits<9> num, string n, list<Register> subregs>
      : KVXRegisterWithSubRegs<num, n, subregs> {
  let SubRegIndices = [SubRegIndex<64,   0>, SubRegIndex<64,  64>,
                       SubRegIndex<64, 128>, SubRegIndex<64, 192>];
}

// XWR - Extension Wide Registers
class XWR<bits<9> num, string n, list<Register> subregs>
      : KVXRegisterWithSubRegs<num, n, subregs> {
  let SubRegIndices = [SubRegIndex<64,   0>, SubRegIndex<64,  64>,
                       SubRegIndex<64, 128>, SubRegIndex<64, 192>,
                       SubRegIndex<64, 256>, SubRegIndex<64, 320>,
                       SubRegIndex<64, 384>, SubRegIndex<64, 448>];
}

// XMR - Extension Matrix Registers
class XMR<bits<9> num, string n, list<Register> subregs>
      : KVXRegisterWithSubRegs<num, n, subregs> {
  let SubRegIndices = [SubRegIndex<64,   0>, SubRegIndex<64,  64>,
                       SubRegIndex<64, 128>, SubRegIndex<64, 192>,
                       SubRegIndex<64, 256>, SubRegIndex<64, 320>,
                       SubRegIndex<64, 384>, SubRegIndex<64, 448>,
                       SubRegIndex<64, 512>, SubRegIndex<64, 576>,
                       SubRegIndex<64, 640>, SubRegIndex<64, 704>,
                       SubRegIndex<64, 768>, SubRegIndex<64, 832>,
                       SubRegIndex<64, 896>, SubRegIndex<64, 960>];
}

// System Function Registers
def PC      : SFR<  0,      "$pc",   ["$s0"]>, DwarfRegNum<[ 64]>;
def PS      : SFR<  1,      "$ps",   ["$s1"]>, DwarfRegNum<[ 65]>;
def PCR     : SFR<  2,     "$pcr",   ["$s2"]>, DwarfRegNum<[ 66]>;
def RA      : SFR<  3,      "$ra",   ["$s3"]>, DwarfRegNum<[ 67]>;
def CS      : SFR<  4,      "$cs",   ["$s4"]>, DwarfRegNum<[ 68]>;
def CSIT    : SFR<  5,    "$csit",   ["$s5"]>, DwarfRegNum<[ 69]>;
def AESPC   : SFR<  6,   "$aespc",   ["$s6"]>, DwarfRegNum<[ 70]>;
def LS      : SFR<  7,      "$ls",   ["$s7"]>, DwarfRegNum<[ 71]>;
def LE      : SFR<  8,      "$le",   ["$s8"]>, DwarfRegNum<[ 72]>;
def LC      : SFR<  9,      "$lc",   ["$s9"]>, DwarfRegNum<[ 73]>;
def IPE     : SFR< 10,     "$ipe",  ["$s10"]>, DwarfRegNum<[ 74]>;
def MEN     : SFR< 11,     "$men",  ["$s11"]>, DwarfRegNum<[ 75]>;
def PMC     : SFR< 12,     "$pmc",  ["$s12"]>, DwarfRegNum<[ 76]>;
def PM0     : SFR< 13,     "$pm0",  ["$s13"]>, DwarfRegNum<[ 77]>;
def PM1     : SFR< 14,     "$pm1",  ["$s14"]>, DwarfRegNum<[ 78]>;
def PM2     : SFR< 15,     "$pm2",  ["$s15"]>, DwarfRegNum<[ 79]>;
def PM3     : SFR< 16,     "$pm3",  ["$s16"]>, DwarfRegNum<[ 80]>;
def PMSA    : SFR< 17,    "$pmsa",  ["$s17"]>, DwarfRegNum<[ 81]>;
def TCR     : SFR< 18,     "$tcr",  ["$s18"]>, DwarfRegNum<[ 82]>;
def T0V     : SFR< 19,     "$t0v",  ["$s19"]>, DwarfRegNum<[ 83]>;
def T1V     : SFR< 20,     "$t1v",  ["$s20"]>, DwarfRegNum<[ 84]>;
def T0R     : SFR< 21,     "$t0r",  ["$s21"]>, DwarfRegNum<[ 85]>;
def T1R     : SFR< 22,     "$t1r",  ["$s22"]>, DwarfRegNum<[ 86]>;
def WDV     : SFR< 23,     "$wdv",  ["$s23"]>, DwarfRegNum<[ 87]>;
def WDR     : SFR< 24,     "$wdr",  ["$s24"]>, DwarfRegNum<[ 88]>;
def ILE     : SFR< 25,     "$ile",  ["$s25"]>, DwarfRegNum<[ 89]>;
def ILL     : SFR< 26,     "$ill",  ["$s26"]>, DwarfRegNum<[ 90]>;
def ILR     : SFR< 27,     "$ilr",  ["$s27"]>, DwarfRegNum<[ 91]>;
def MMC     : SFR< 28,     "$mmc",  ["$s28"]>, DwarfRegNum<[ 92]>;
def TEL     : SFR< 29,     "$tel",  ["$s29"]>, DwarfRegNum<[ 93]>;
def TEH     : SFR< 30,     "$teh",  ["$s30"]>, DwarfRegNum<[ 94]>;
def RES31   : SFR< 31,   "$res31",  ["$s31"]>, DwarfRegNum<[ 95]>;
def SYO     : SFR< 32,     "$syo",  ["$s32"]>, DwarfRegNum<[ 96]>;
def HTO     : SFR< 33,     "$hto",  ["$s33"]>, DwarfRegNum<[ 97]>;
def ITO     : SFR< 34,     "$ito",  ["$s34"]>, DwarfRegNum<[ 98]>;
def DO      : SFR< 35,      "$do",  ["$s35"]>, DwarfRegNum<[ 99]>;
def MO      : SFR< 36,      "$mo",  ["$s36"]>, DwarfRegNum<[100]>;
def PSO     : SFR< 37,     "$pso",  ["$s37"]>, DwarfRegNum<[101]>;
def RES38   : SFR< 38,   "$res38",  ["$s38"]>, DwarfRegNum<[102]>;
def RES39   : SFR< 39,   "$res39",  ["$s39"]>, DwarfRegNum<[103]>;
def DC      : SFR< 40,      "$dc",  ["$s40"]>, DwarfRegNum<[104]>;
def DBA0    : SFR< 41,    "$dba0",  ["$s41"]>, DwarfRegNum<[105]>;
def DBA1    : SFR< 42,    "$dba1",  ["$s42"]>, DwarfRegNum<[106]>;
def DWA0    : SFR< 43,    "$dwa0",  ["$s43"]>, DwarfRegNum<[107]>;
def DWA1    : SFR< 44,    "$dwa1",  ["$s44"]>, DwarfRegNum<[108]>;
def MES     : SFR< 45,     "$mes",  ["$s45"]>, DwarfRegNum<[109]>;
def WS      : SFR< 46,      "$ws",  ["$s46"]>, DwarfRegNum<[110]>;
def RES47   : SFR< 47,   "$res47",  ["$s47"]>, DwarfRegNum<[111]>;
def RES48   : SFR< 48,   "$res48",  ["$s48"]>, DwarfRegNum<[112]>;
def RES49   : SFR< 49,   "$res49",  ["$s49"]>, DwarfRegNum<[113]>;
def RES50   : SFR< 50,   "$res50",  ["$s50"]>, DwarfRegNum<[114]>;
def RES51   : SFR< 51,   "$res51",  ["$s51"]>, DwarfRegNum<[115]>;
def RES52   : SFR< 52,   "$res52",  ["$s52"]>, DwarfRegNum<[116]>;
def RES53   : SFR< 53,   "$res53",  ["$s53"]>, DwarfRegNum<[117]>;
def RES54   : SFR< 54,   "$res54",  ["$s54"]>, DwarfRegNum<[118]>;
def RES55   : SFR< 55,   "$res55",  ["$s55"]>, DwarfRegNum<[119]>;
def RES56   : SFR< 56,   "$res56",  ["$s56"]>, DwarfRegNum<[120]>;
def RES57   : SFR< 57,   "$res57",  ["$s57"]>, DwarfRegNum<[121]>;
def RES58   : SFR< 58,   "$res58",  ["$s58"]>, DwarfRegNum<[122]>;
def RES59   : SFR< 59,   "$res59",  ["$s59"]>, DwarfRegNum<[123]>;
def RES60   : SFR< 60,   "$res60",  ["$s60"]>, DwarfRegNum<[124]>;
def RES61   : SFR< 61,   "$res61",  ["$s61"]>, DwarfRegNum<[125]>;
def RES62   : SFR< 62,   "$res62",  ["$s62"]>, DwarfRegNum<[126]>;
def RES63   : SFR< 63,   "$res63",  ["$s63"]>, DwarfRegNum<[127]>;
def SPC_PL0 : SFR< 64, "$spc_pl0",  ["$s64"]>, DwarfRegNum<[128]>;
def SPC_PL1 : SFR< 65, "$spc_pl1",  ["$s65"]>, DwarfRegNum<[129]>;
def SPC_PL2 : SFR< 66, "$spc_pl2",  ["$s66"]>, DwarfRegNum<[130]>;
def SPC_PL3 : SFR< 67, "$spc_pl3",  ["$s67"]>, DwarfRegNum<[131]>;
def SPS_PL0 : SFR< 68, "$sps_pl0",  ["$s68"]>, DwarfRegNum<[132]>;
def SPS_PL1 : SFR< 69, "$sps_pl1",  ["$s69"]>, DwarfRegNum<[133]>;
def SPS_PL2 : SFR< 70, "$sps_pl2",  ["$s70"]>, DwarfRegNum<[134]>;
def SPS_PL3 : SFR< 71, "$sps_pl3",  ["$s71"]>, DwarfRegNum<[135]>;
def EA_PL0  : SFR< 72,  "$ea_pl0",  ["$s72"]>, DwarfRegNum<[136]>;
def EA_PL1  : SFR< 73,  "$ea_pl1",  ["$s73"]>, DwarfRegNum<[137]>;
def EA_PL2  : SFR< 74,  "$ea_pl2",  ["$s74"]>, DwarfRegNum<[138]>;
def EA_PL3  : SFR< 75,  "$ea_pl3",  ["$s75"]>, DwarfRegNum<[139]>;
def EV_PL0  : SFR< 76,  "$ev_pl0",  ["$s76"]>, DwarfRegNum<[140]>;
def EV_PL1  : SFR< 77,  "$ev_pl1",  ["$s77"]>, DwarfRegNum<[141]>;
def EV_PL2  : SFR< 78,  "$ev_pl2",  ["$s78"]>, DwarfRegNum<[142]>;
def EV_PL3  : SFR< 79,  "$ev_pl3",  ["$s79"]>, DwarfRegNum<[143]>;
def SR_PL0  : SFR< 80,  "$sr_pl0",  ["$s80"]>, DwarfRegNum<[144]>;
def SR_PL1  : SFR< 81,  "$sr_pl1",  ["$s81"]>, DwarfRegNum<[145]>;
def SR_PL2  : SFR< 82,  "$sr_pl2",  ["$s82"]>, DwarfRegNum<[146]>;
def SR_PL3  : SFR< 83,  "$sr_pl3",  ["$s83"]>, DwarfRegNum<[147]>;
def ES_PL0  : SFR< 84,  "$es_pl0",  ["$s84"]>, DwarfRegNum<[148]>;
def ES_PL1  : SFR< 85,  "$es_pl1",  ["$s85"]>, DwarfRegNum<[149]>;
def ES_PL2  : SFR< 86,  "$es_pl2",  ["$s86"]>, DwarfRegNum<[150]>;
def ES_PL3  : SFR< 87,  "$es_pl3",  ["$s87"]>, DwarfRegNum<[151]>;
def RES88   : SFR< 88,   "$res88",  ["$s88"]>, DwarfRegNum<[152]>;
def RES89   : SFR< 89,   "$res89",  ["$s89"]>, DwarfRegNum<[153]>;
def RES90   : SFR< 90,   "$res90",  ["$s90"]>, DwarfRegNum<[154]>;
def RES91   : SFR< 91,   "$res91",  ["$s91"]>, DwarfRegNum<[155]>;
def RES92   : SFR< 92,   "$res92",  ["$s92"]>, DwarfRegNum<[156]>;
def RES93   : SFR< 93,   "$res93",  ["$s93"]>, DwarfRegNum<[157]>;
def RES94   : SFR< 94,   "$res94",  ["$s94"]>, DwarfRegNum<[158]>;
def RES95   : SFR< 95,   "$res95",  ["$s95"]>, DwarfRegNum<[159]>;
def SYOW    : SFR< 96,    "$syow",  ["$s96"]>, DwarfRegNum<[160]>;
def HTOW    : SFR< 97,    "$htow",  ["$s97"]>, DwarfRegNum<[161]>;
def ITOW    : SFR< 98,    "$itow",  ["$s98"]>, DwarfRegNum<[162]>;
def DOW     : SFR< 99,     "$dow",  ["$s99"]>, DwarfRegNum<[163]>;
def MOW     : SFR<100,     "$mow", ["$s100"]>, DwarfRegNum<[164]>;
def PSOW    : SFR<101,    "$psow", ["$s101"]>, DwarfRegNum<[165]>;
def RES102  : SFR<102,  "$res102", ["$s102"]>, DwarfRegNum<[166]>;
def RES103  : SFR<103,  "$res103", ["$s103"]>, DwarfRegNum<[167]>;
def RES104  : SFR<104,  "$res104", ["$s104"]>, DwarfRegNum<[168]>;
def RES105  : SFR<105,  "$res105", ["$s105"]>, DwarfRegNum<[169]>;
def RES106  : SFR<106,  "$res106", ["$s106"]>, DwarfRegNum<[170]>;
def RES107  : SFR<107,  "$res107", ["$s107"]>, DwarfRegNum<[171]>;
def RES108  : SFR<108,  "$res108", ["$s108"]>, DwarfRegNum<[172]>;
def RES109  : SFR<109,  "$res109", ["$s109"]>, DwarfRegNum<[173]>;
def RES110  : SFR<110,  "$res110", ["$s110"]>, DwarfRegNum<[174]>;
def RES111  : SFR<111,  "$res111", ["$s111"]>, DwarfRegNum<[175]>;
def RES112  : SFR<112,  "$res112", ["$s112"]>, DwarfRegNum<[176]>;
def RES113  : SFR<113,  "$res113", ["$s113"]>, DwarfRegNum<[177]>;
def RES114  : SFR<114,  "$res114", ["$s114"]>, DwarfRegNum<[178]>;
def RES115  : SFR<115,  "$res115", ["$s115"]>, DwarfRegNum<[179]>;
def RES116  : SFR<116,  "$res116", ["$s116"]>, DwarfRegNum<[180]>;
def RES117  : SFR<117,  "$res117", ["$s117"]>, DwarfRegNum<[181]>;
def RES118  : SFR<118,  "$res118", ["$s118"]>, DwarfRegNum<[182]>;
def RES119  : SFR<119,  "$res119", ["$s119"]>, DwarfRegNum<[183]>;
def RES120  : SFR<120,  "$res120", ["$s120"]>, DwarfRegNum<[184]>;
def RES121  : SFR<121,  "$res121", ["$s121"]>, DwarfRegNum<[185]>;
def RES122  : SFR<122,  "$res122", ["$s122"]>, DwarfRegNum<[186]>;
def RES123  : SFR<123,  "$res123", ["$s123"]>, DwarfRegNum<[187]>;
def RES124  : SFR<124,  "$res124", ["$s124"]>, DwarfRegNum<[188]>;
def RES125  : SFR<125,  "$res125", ["$s125"]>, DwarfRegNum<[189]>;
def RES126  : SFR<126,  "$res126", ["$s126"]>, DwarfRegNum<[190]>;
def RES127  : SFR<127,  "$res127", ["$s127"]>, DwarfRegNum<[191]>;
def SPC     : SFR<128,     "$spc", ["$s128"]>, DwarfRegNum<[192]>;
def RES129  : SFR<129,  "$res129", ["$s129"]>, DwarfRegNum<[193]>;
def RES130  : SFR<130,  "$res130", ["$s130"]>, DwarfRegNum<[194]>;
def RES131  : SFR<131,  "$res131", ["$s131"]>, DwarfRegNum<[195]>;
def SPS     : SFR<132,     "$sps", ["$s132"]>, DwarfRegNum<[196]>;
def RES133  : SFR<133,  "$res133", ["$s133"]>, DwarfRegNum<[197]>;
def RES134  : SFR<134,  "$res134", ["$s134"]>, DwarfRegNum<[198]>;
def RES135  : SFR<135,  "$res135", ["$s135"]>, DwarfRegNum<[199]>;
def EA      : SFR<136,      "$ea", ["$s136"]>, DwarfRegNum<[200]>;
def RES137  : SFR<137,  "$res137", ["$s137"]>, DwarfRegNum<[201]>;
def RES138  : SFR<138,  "$res138", ["$s138"]>, DwarfRegNum<[202]>;
def RES139  : SFR<139,  "$res139", ["$s139"]>, DwarfRegNum<[203]>;
def EV      : SFR<140,      "$ev", ["$s140"]>, DwarfRegNum<[204]>;
def RES141  : SFR<141,  "$res141", ["$s141"]>, DwarfRegNum<[205]>;
def RES142  : SFR<142,  "$res142", ["$s142"]>, DwarfRegNum<[206]>;
def RES143  : SFR<143,  "$res143", ["$s143"]>, DwarfRegNum<[207]>;
def SR      : SFR<144,      "$sr", ["$s144"]>, DwarfRegNum<[208]>;
def RES145  : SFR<145,  "$res145", ["$s145"]>, DwarfRegNum<[209]>;
def RES146  : SFR<146,  "$res146", ["$s146"]>, DwarfRegNum<[210]>;
def RES147  : SFR<147,  "$res147", ["$s147"]>, DwarfRegNum<[211]>;
def ES      : SFR<148,      "$es", ["$s148"]>, DwarfRegNum<[212]>;
def RES149  : SFR<149,  "$res149", ["$s149"]>, DwarfRegNum<[213]>;
def RES150  : SFR<150,  "$res150", ["$s150"]>, DwarfRegNum<[214]>;
def RES151  : SFR<151,  "$res151", ["$s151"]>, DwarfRegNum<[215]>;
def RES152  : SFR<152,  "$res152", ["$s152"]>, DwarfRegNum<[216]>;
def RES153  : SFR<153,  "$res153", ["$s153"]>, DwarfRegNum<[217]>;
def RES154  : SFR<154,  "$res154", ["$s154"]>, DwarfRegNum<[218]>;
def RES155  : SFR<155,  "$res155", ["$s155"]>, DwarfRegNum<[219]>;
def RES156  : SFR<156,  "$res156", ["$s156"]>, DwarfRegNum<[220]>;
def RES157  : SFR<157,  "$res157", ["$s157"]>, DwarfRegNum<[221]>;
def RES158  : SFR<158,  "$res158", ["$s158"]>, DwarfRegNum<[222]>;
def RES159  : SFR<159,  "$res159", ["$s159"]>, DwarfRegNum<[223]>;
def RES160  : SFR<160,  "$res160", ["$s160"]>, DwarfRegNum<[224]>;
def RES161  : SFR<161,  "$res161", ["$s161"]>, DwarfRegNum<[225]>;
def RES162  : SFR<162,  "$res162", ["$s162"]>, DwarfRegNum<[226]>;
def RES163  : SFR<163,  "$res163", ["$s163"]>, DwarfRegNum<[227]>;
def RES164  : SFR<164,  "$res164", ["$s164"]>, DwarfRegNum<[228]>;
def RES165  : SFR<165,  "$res165", ["$s165"]>, DwarfRegNum<[229]>;
def RES166  : SFR<166,  "$res166", ["$s166"]>, DwarfRegNum<[230]>;
def RES167  : SFR<167,  "$res167", ["$s167"]>, DwarfRegNum<[231]>;
def RES168  : SFR<168,  "$res168", ["$s168"]>, DwarfRegNum<[232]>;
def RES169  : SFR<169,  "$res169", ["$s169"]>, DwarfRegNum<[233]>;
def RES170  : SFR<170,  "$res170", ["$s170"]>, DwarfRegNum<[234]>;
def RES171  : SFR<171,  "$res171", ["$s171"]>, DwarfRegNum<[235]>;
def RES172  : SFR<172,  "$res172", ["$s172"]>, DwarfRegNum<[236]>;
def RES173  : SFR<173,  "$res173", ["$s173"]>, DwarfRegNum<[237]>;
def RES174  : SFR<174,  "$res174", ["$s174"]>, DwarfRegNum<[238]>;
def RES175  : SFR<175,  "$res175", ["$s175"]>, DwarfRegNum<[239]>;
def RES176  : SFR<176,  "$res176", ["$s176"]>, DwarfRegNum<[240]>;
def RES177  : SFR<177,  "$res177", ["$s177"]>, DwarfRegNum<[241]>;
def RES178  : SFR<178,  "$res178", ["$s178"]>, DwarfRegNum<[242]>;
def RES179  : SFR<179,  "$res179", ["$s179"]>, DwarfRegNum<[243]>;
def RES180  : SFR<180,  "$res180", ["$s180"]>, DwarfRegNum<[244]>;
def RES181  : SFR<181,  "$res181", ["$s181"]>, DwarfRegNum<[245]>;
def RES182  : SFR<182,  "$res182", ["$s182"]>, DwarfRegNum<[246]>;
def RES183  : SFR<183,  "$res183", ["$s183"]>, DwarfRegNum<[247]>;
def RES184  : SFR<184,  "$res184", ["$s184"]>, DwarfRegNum<[248]>;
def RES185  : SFR<185,  "$res185", ["$s185"]>, DwarfRegNum<[249]>;
def RES186  : SFR<186,  "$res186", ["$s186"]>, DwarfRegNum<[250]>;
def RES187  : SFR<187,  "$res187", ["$s187"]>, DwarfRegNum<[251]>;
def RES188  : SFR<188,  "$res188", ["$s188"]>, DwarfRegNum<[252]>;
def RES189  : SFR<189,  "$res189", ["$s189"]>, DwarfRegNum<[253]>;
def RES190  : SFR<190,  "$res190", ["$s190"]>, DwarfRegNum<[254]>;
def RES191  : SFR<191,  "$res191", ["$s191"]>, DwarfRegNum<[255]>;
def RES192  : SFR<192,  "$res192", ["$s192"]>;
def RES193  : SFR<193,  "$res193", ["$s193"]>;
def RES194  : SFR<194,  "$res194", ["$s194"]>;
def RES195  : SFR<195,  "$res195", ["$s195"]>;
def RES196  : SFR<196,  "$res196", ["$s196"]>;
def RES197  : SFR<197,  "$res197", ["$s197"]>;
def RES198  : SFR<198,  "$res198", ["$s198"]>;
def RES199  : SFR<199,  "$res199", ["$s199"]>;
def RES200  : SFR<200,  "$res200", ["$s200"]>;
def RES201  : SFR<201,  "$res201", ["$s201"]>;
def RES202  : SFR<202,  "$res202", ["$s202"]>;
def RES203  : SFR<203,  "$res203", ["$s203"]>;
def RES204  : SFR<204,  "$res204", ["$s204"]>;
def RES205  : SFR<205,  "$res205", ["$s205"]>;
def RES206  : SFR<206,  "$res206", ["$s206"]>;
def RES207  : SFR<207,  "$res207", ["$s207"]>;
def RES208  : SFR<208,  "$res208", ["$s208"]>;
def RES209  : SFR<209,  "$res209", ["$s209"]>;
def RES210  : SFR<210,  "$res210", ["$s210"]>;
def RES211  : SFR<211,  "$res211", ["$s211"]>;
def RES212  : SFR<212,  "$res212", ["$s212"]>;
def RES213  : SFR<213,  "$res213", ["$s213"]>;
def RES214  : SFR<214,  "$res214", ["$s214"]>;
def RES215  : SFR<215,  "$res215", ["$s215"]>;
def RES216  : SFR<216,  "$res216", ["$s216"]>;
def RES217  : SFR<217,  "$res217", ["$s217"]>;
def RES218  : SFR<218,  "$res218", ["$s218"]>;
def RES219  : SFR<219,  "$res219", ["$s219"]>;
def RES220  : SFR<220,  "$res220", ["$s220"]>;
def RES221  : SFR<221,  "$res221", ["$s221"]>;
def RES222  : SFR<222,  "$res222", ["$s222"]>;
def RES223  : SFR<223,  "$res223", ["$s223"]>;
def RES224  : SFR<224,  "$res224", ["$s224"]>;
def RES225  : SFR<225,  "$res225", ["$s225"]>;
def RES226  : SFR<226,  "$res226", ["$s226"]>;
def RES227  : SFR<227,  "$res227", ["$s227"]>;
def RES228  : SFR<228,  "$res228", ["$s228"]>;
def RES229  : SFR<229,  "$res229", ["$s229"]>;
def RES230  : SFR<230,  "$res230", ["$s230"]>;
def RES231  : SFR<231,  "$res231", ["$s231"]>;
def RES232  : SFR<232,  "$res232", ["$s232"]>;
def RES233  : SFR<233,  "$res233", ["$s233"]>;
def RES234  : SFR<234,  "$res234", ["$s234"]>;
def RES235  : SFR<235,  "$res235", ["$s235"]>;
def RES236  : SFR<236,  "$res236", ["$s236"]>;
def RES237  : SFR<237,  "$res237", ["$s237"]>;
def RES238  : SFR<238,  "$res238", ["$s238"]>;
def RES239  : SFR<239,  "$res239", ["$s239"]>;
def RES240  : SFR<240,  "$res240", ["$s240"]>;
def RES241  : SFR<241,  "$res241", ["$s241"]>;
def RES242  : SFR<242,  "$res242", ["$s242"]>;
def RES243  : SFR<243,  "$res243", ["$s243"]>;
def RES244  : SFR<244,  "$res244", ["$s244"]>;
def RES245  : SFR<245,  "$res245", ["$s245"]>;
def RES246  : SFR<246,  "$res246", ["$s246"]>;
def RES247  : SFR<247,  "$res247", ["$s247"]>;
def RES248  : SFR<248,  "$res248", ["$s248"]>;
def RES249  : SFR<249,  "$res249", ["$s249"]>;
def RES250  : SFR<250,  "$res250", ["$s250"]>;
def RES251  : SFR<251,  "$res251", ["$s251"]>;
def RES252  : SFR<252,  "$res252", ["$s252"]>;
def RES253  : SFR<253,  "$res253", ["$s253"]>;
def RES254  : SFR<254,  "$res254", ["$s254"]>;
def RES255  : SFR<255,  "$res255", ["$s255"]>;
def VSFR0   : SFR<256,   "$vsfr0", ["$s256"]>;
def VSFR1   : SFR<257,   "$vsfr1", ["$s257"]>;
def VSFR2   : SFR<258,   "$vsfr2", ["$s258"]>;
def VSFR3   : SFR<259,   "$vsfr3", ["$s259"]>;
def VSFR4   : SFR<260,   "$vsfr4", ["$s260"]>;
def VSFR5   : SFR<261,   "$vsfr5", ["$s261"]>;
def VSFR6   : SFR<262,   "$vsfr6", ["$s262"]>;
def VSFR7   : SFR<263,   "$vsfr7", ["$s263"]>;
def VSFR8   : SFR<264,   "$vsfr8", ["$s264"]>;
def VSFR9   : SFR<265,   "$vsfr9", ["$s265"]>;
def VSFR10  : SFR<266,  "$vsfr10", ["$s266"]>;
def VSFR11  : SFR<267,  "$vsfr11", ["$s267"]>;
def VSFR12  : SFR<268,  "$vsfr12", ["$s268"]>;
def VSFR13  : SFR<269,  "$vsfr13", ["$s269"]>;
def VSFR14  : SFR<270,  "$vsfr14", ["$s270"]>;
def VSFR15  : SFR<271,  "$vsfr15", ["$s271"]>;
def VSFR16  : SFR<272,  "$vsfr16", ["$s272"]>;
def VSFR17  : SFR<273,  "$vsfr17", ["$s273"]>;
def VSFR18  : SFR<274,  "$vsfr18", ["$s274"]>;
def VSFR19  : SFR<275,  "$vsfr19", ["$s275"]>;
def VSFR20  : SFR<276,  "$vsfr20", ["$s276"]>;
def VSFR21  : SFR<277,  "$vsfr21", ["$s277"]>;
def VSFR22  : SFR<278,  "$vsfr22", ["$s278"]>;
def VSFR23  : SFR<279,  "$vsfr23", ["$s279"]>;
def VSFR24  : SFR<280,  "$vsfr24", ["$s280"]>;
def VSFR25  : SFR<281,  "$vsfr25", ["$s281"]>;
def VSFR26  : SFR<282,  "$vsfr26", ["$s282"]>;
def VSFR27  : SFR<283,  "$vsfr27", ["$s283"]>;
def VSFR28  : SFR<284,  "$vsfr28", ["$s284"]>;
def VSFR29  : SFR<285,  "$vsfr29", ["$s285"]>;
def VSFR30  : SFR<286,  "$vsfr30", ["$s286"]>;
def VSFR31  : SFR<287,  "$vsfr31", ["$s287"]>;
def VSFR32  : SFR<288,  "$vsfr32", ["$s288"]>;
def VSFR33  : SFR<289,  "$vsfr33", ["$s289"]>;
def VSFR34  : SFR<290,  "$vsfr34", ["$s290"]>;
def VSFR35  : SFR<291,  "$vsfr35", ["$s291"]>;
def VSFR36  : SFR<292,  "$vsfr36", ["$s292"]>;
def VSFR37  : SFR<293,  "$vsfr37", ["$s293"]>;
def VSFR38  : SFR<294,  "$vsfr38", ["$s294"]>;
def VSFR39  : SFR<295,  "$vsfr39", ["$s295"]>;
def VSFR40  : SFR<296,  "$vsfr40", ["$s296"]>;
def VSFR41  : SFR<297,  "$vsfr41", ["$s297"]>;
def VSFR42  : SFR<298,  "$vsfr42", ["$s298"]>;
def VSFR43  : SFR<299,  "$vsfr43", ["$s299"]>;
def VSFR44  : SFR<300,  "$vsfr44", ["$s300"]>;
def VSFR45  : SFR<301,  "$vsfr45", ["$s301"]>;
def VSFR46  : SFR<302,  "$vsfr46", ["$s302"]>;
def VSFR47  : SFR<303,  "$vsfr47", ["$s303"]>;
def VSFR48  : SFR<304,  "$vsfr48", ["$s304"]>;
def VSFR49  : SFR<305,  "$vsfr49", ["$s305"]>;
def VSFR50  : SFR<306,  "$vsfr50", ["$s306"]>;
def VSFR51  : SFR<307,  "$vsfr51", ["$s307"]>;
def VSFR52  : SFR<308,  "$vsfr52", ["$s308"]>;
def VSFR53  : SFR<309,  "$vsfr53", ["$s309"]>;
def VSFR54  : SFR<310,  "$vsfr54", ["$s310"]>;
def VSFR55  : SFR<311,  "$vsfr55", ["$s311"]>;
def VSFR56  : SFR<312,  "$vsfr56", ["$s312"]>;
def VSFR57  : SFR<313,  "$vsfr57", ["$s313"]>;
def VSFR58  : SFR<314,  "$vsfr58", ["$s314"]>;
def VSFR59  : SFR<315,  "$vsfr59", ["$s315"]>;
def VSFR60  : SFR<316,  "$vsfr60", ["$s316"]>;
def VSFR61  : SFR<317,  "$vsfr61", ["$s317"]>;
def VSFR62  : SFR<318,  "$vsfr62", ["$s318"]>;
def VSFR63  : SFR<319,  "$vsfr63", ["$s319"]>;
def VSFR64  : SFR<320,  "$vsfr64", ["$s320"]>;
def VSFR65  : SFR<321,  "$vsfr65", ["$s321"]>;
def VSFR66  : SFR<322,  "$vsfr66", ["$s322"]>;
def VSFR67  : SFR<323,  "$vsfr67", ["$s323"]>;
def VSFR68  : SFR<324,  "$vsfr68", ["$s324"]>;
def VSFR69  : SFR<325,  "$vsfr69", ["$s325"]>;
def VSFR70  : SFR<326,  "$vsfr70", ["$s326"]>;
def VSFR71  : SFR<327,  "$vsfr71", ["$s327"]>;
def VSFR72  : SFR<328,  "$vsfr72", ["$s328"]>;
def VSFR73  : SFR<329,  "$vsfr73", ["$s329"]>;
def VSFR74  : SFR<330,  "$vsfr74", ["$s330"]>;
def VSFR75  : SFR<331,  "$vsfr75", ["$s331"]>;
def VSFR76  : SFR<332,  "$vsfr76", ["$s332"]>;
def VSFR77  : SFR<333,  "$vsfr77", ["$s333"]>;
def VSFR78  : SFR<334,  "$vsfr78", ["$s334"]>;
def VSFR79  : SFR<335,  "$vsfr79", ["$s335"]>;
def VSFR80  : SFR<336,  "$vsfr80", ["$s336"]>;
def VSFR81  : SFR<337,  "$vsfr81", ["$s337"]>;
def VSFR82  : SFR<338,  "$vsfr82", ["$s338"]>;
def VSFR83  : SFR<339,  "$vsfr83", ["$s339"]>;
def VSFR84  : SFR<340,  "$vsfr84", ["$s340"]>;
def VSFR85  : SFR<341,  "$vsfr85", ["$s341"]>;
def VSFR86  : SFR<342,  "$vsfr86", ["$s342"]>;
def VSFR87  : SFR<343,  "$vsfr87", ["$s343"]>;
def VSFR88  : SFR<344,  "$vsfr88", ["$s344"]>;
def VSFR89  : SFR<345,  "$vsfr89", ["$s345"]>;
def VSFR90  : SFR<346,  "$vsfr90", ["$s346"]>;
def VSFR91  : SFR<347,  "$vsfr91", ["$s347"]>;
def VSFR92  : SFR<348,  "$vsfr92", ["$s348"]>;
def VSFR93  : SFR<349,  "$vsfr93", ["$s349"]>;
def VSFR94  : SFR<350,  "$vsfr94", ["$s350"]>;
def VSFR95  : SFR<351,  "$vsfr95", ["$s351"]>;
def VSFR96  : SFR<352,  "$vsfr96", ["$s352"]>;
def VSFR97  : SFR<353,  "$vsfr97", ["$s353"]>;
def VSFR98  : SFR<354,  "$vsfr98", ["$s354"]>;
def VSFR99  : SFR<355,  "$vsfr99", ["$s355"]>;
def VSFR100 : SFR<356, "$vsfr100", ["$s356"]>;
def VSFR101 : SFR<357, "$vsfr101", ["$s357"]>;
def VSFR102 : SFR<358, "$vsfr102", ["$s358"]>;
def VSFR103 : SFR<359, "$vsfr103", ["$s359"]>;
def VSFR104 : SFR<360, "$vsfr104", ["$s360"]>;
def VSFR105 : SFR<361, "$vsfr105", ["$s361"]>;
def VSFR106 : SFR<362, "$vsfr106", ["$s362"]>;
def VSFR107 : SFR<363, "$vsfr107", ["$s363"]>;
def VSFR108 : SFR<364, "$vsfr108", ["$s364"]>;
def VSFR109 : SFR<365, "$vsfr109", ["$s365"]>;
def VSFR110 : SFR<366, "$vsfr110", ["$s366"]>;
def VSFR111 : SFR<367, "$vsfr111", ["$s367"]>;
def VSFR112 : SFR<368, "$vsfr112", ["$s368"]>;
def VSFR113 : SFR<369, "$vsfr113", ["$s369"]>;
def VSFR114 : SFR<370, "$vsfr114", ["$s370"]>;
def VSFR115 : SFR<371, "$vsfr115", ["$s371"]>;
def VSFR116 : SFR<372, "$vsfr116", ["$s372"]>;
def VSFR117 : SFR<373, "$vsfr117", ["$s373"]>;
def VSFR118 : SFR<374, "$vsfr118", ["$s374"]>;
def VSFR119 : SFR<375, "$vsfr119", ["$s375"]>;
def VSFR120 : SFR<376, "$vsfr120", ["$s376"]>;
def VSFR121 : SFR<377, "$vsfr121", ["$s377"]>;
def VSFR122 : SFR<378, "$vsfr122", ["$s378"]>;
def VSFR123 : SFR<379, "$vsfr123", ["$s379"]>;
def VSFR124 : SFR<380, "$vsfr124", ["$s380"]>;
def VSFR125 : SFR<381, "$vsfr125", ["$s381"]>;
def VSFR126 : SFR<382, "$vsfr126", ["$s382"]>;
def VSFR127 : SFR<383, "$vsfr127", ["$s383"]>;
def VSFR128 : SFR<384, "$vsfr128", ["$s384"]>;
def VSFR129 : SFR<385, "$vsfr129", ["$s385"]>;
def VSFR130 : SFR<386, "$vsfr130", ["$s386"]>;
def VSFR131 : SFR<387, "$vsfr131", ["$s387"]>;
def VSFR132 : SFR<388, "$vsfr132", ["$s388"]>;
def VSFR133 : SFR<389, "$vsfr133", ["$s389"]>;
def VSFR134 : SFR<390, "$vsfr134", ["$s390"]>;
def VSFR135 : SFR<391, "$vsfr135", ["$s391"]>;
def VSFR136 : SFR<392, "$vsfr136", ["$s392"]>;
def VSFR137 : SFR<393, "$vsfr137", ["$s393"]>;
def VSFR138 : SFR<394, "$vsfr138", ["$s394"]>;
def VSFR139 : SFR<395, "$vsfr139", ["$s395"]>;
def VSFR140 : SFR<396, "$vsfr140", ["$s396"]>;
def VSFR141 : SFR<397, "$vsfr141", ["$s397"]>;
def VSFR142 : SFR<398, "$vsfr142", ["$s398"]>;
def VSFR143 : SFR<399, "$vsfr143", ["$s399"]>;
def VSFR144 : SFR<400, "$vsfr144", ["$s400"]>;
def VSFR145 : SFR<401, "$vsfr145", ["$s401"]>;
def VSFR146 : SFR<402, "$vsfr146", ["$s402"]>;
def VSFR147 : SFR<403, "$vsfr147", ["$s403"]>;
def VSFR148 : SFR<404, "$vsfr148", ["$s404"]>;
def VSFR149 : SFR<405, "$vsfr149", ["$s405"]>;
def VSFR150 : SFR<406, "$vsfr150", ["$s406"]>;
def VSFR151 : SFR<407, "$vsfr151", ["$s407"]>;
def VSFR152 : SFR<408, "$vsfr152", ["$s408"]>;
def VSFR153 : SFR<409, "$vsfr153", ["$s409"]>;
def VSFR154 : SFR<410, "$vsfr154", ["$s410"]>;
def VSFR155 : SFR<411, "$vsfr155", ["$s411"]>;
def VSFR156 : SFR<412, "$vsfr156", ["$s412"]>;
def VSFR157 : SFR<413, "$vsfr157", ["$s413"]>;
def VSFR158 : SFR<414, "$vsfr158", ["$s414"]>;
def VSFR159 : SFR<415, "$vsfr159", ["$s415"]>;
def VSFR160 : SFR<416, "$vsfr160", ["$s416"]>;
def VSFR161 : SFR<417, "$vsfr161", ["$s417"]>;
def VSFR162 : SFR<418, "$vsfr162", ["$s418"]>;
def VSFR163 : SFR<419, "$vsfr163", ["$s419"]>;
def VSFR164 : SFR<420, "$vsfr164", ["$s420"]>;
def VSFR165 : SFR<421, "$vsfr165", ["$s421"]>;
def VSFR166 : SFR<422, "$vsfr166", ["$s422"]>;
def VSFR167 : SFR<423, "$vsfr167", ["$s423"]>;
def VSFR168 : SFR<424, "$vsfr168", ["$s424"]>;
def VSFR169 : SFR<425, "$vsfr169", ["$s425"]>;
def VSFR170 : SFR<426, "$vsfr170", ["$s426"]>;
def VSFR171 : SFR<427, "$vsfr171", ["$s427"]>;
def VSFR172 : SFR<428, "$vsfr172", ["$s428"]>;
def VSFR173 : SFR<429, "$vsfr173", ["$s429"]>;
def VSFR174 : SFR<430, "$vsfr174", ["$s430"]>;
def VSFR175 : SFR<431, "$vsfr175", ["$s431"]>;
def VSFR176 : SFR<432, "$vsfr176", ["$s432"]>;
def VSFR177 : SFR<433, "$vsfr177", ["$s433"]>;
def VSFR178 : SFR<434, "$vsfr178", ["$s434"]>;
def VSFR179 : SFR<435, "$vsfr179", ["$s435"]>;
def VSFR180 : SFR<436, "$vsfr180", ["$s436"]>;
def VSFR181 : SFR<437, "$vsfr181", ["$s437"]>;
def VSFR182 : SFR<438, "$vsfr182", ["$s438"]>;
def VSFR183 : SFR<439, "$vsfr183", ["$s439"]>;
def VSFR184 : SFR<440, "$vsfr184", ["$s440"]>;
def VSFR185 : SFR<441, "$vsfr185", ["$s441"]>;
def VSFR186 : SFR<442, "$vsfr186", ["$s442"]>;
def VSFR187 : SFR<443, "$vsfr187", ["$s443"]>;
def VSFR188 : SFR<444, "$vsfr188", ["$s444"]>;
def VSFR189 : SFR<445, "$vsfr189", ["$s445"]>;
def VSFR190 : SFR<446, "$vsfr190", ["$s446"]>;
def VSFR191 : SFR<447, "$vsfr191", ["$s447"]>;
def VSFR192 : SFR<448, "$vsfr192", ["$s448"]>;
def VSFR193 : SFR<449, "$vsfr193", ["$s449"]>;
def VSFR194 : SFR<450, "$vsfr194", ["$s450"]>;
def VSFR195 : SFR<451, "$vsfr195", ["$s451"]>;
def VSFR196 : SFR<452, "$vsfr196", ["$s452"]>;
def VSFR197 : SFR<453, "$vsfr197", ["$s453"]>;
def VSFR198 : SFR<454, "$vsfr198", ["$s454"]>;
def VSFR199 : SFR<455, "$vsfr199", ["$s455"]>;
def VSFR200 : SFR<456, "$vsfr200", ["$s456"]>;
def VSFR201 : SFR<457, "$vsfr201", ["$s457"]>;
def VSFR202 : SFR<458, "$vsfr202", ["$s458"]>;
def VSFR203 : SFR<459, "$vsfr203", ["$s459"]>;
def VSFR204 : SFR<460, "$vsfr204", ["$s460"]>;
def VSFR205 : SFR<461, "$vsfr205", ["$s461"]>;
def VSFR206 : SFR<462, "$vsfr206", ["$s462"]>;
def VSFR207 : SFR<463, "$vsfr207", ["$s463"]>;
def VSFR208 : SFR<464, "$vsfr208", ["$s464"]>;
def VSFR209 : SFR<465, "$vsfr209", ["$s465"]>;
def VSFR210 : SFR<466, "$vsfr210", ["$s466"]>;
def VSFR211 : SFR<467, "$vsfr211", ["$s467"]>;
def VSFR212 : SFR<468, "$vsfr212", ["$s468"]>;
def VSFR213 : SFR<469, "$vsfr213", ["$s469"]>;
def VSFR214 : SFR<470, "$vsfr214", ["$s470"]>;
def VSFR215 : SFR<471, "$vsfr215", ["$s471"]>;
def VSFR216 : SFR<472, "$vsfr216", ["$s472"]>;
def VSFR217 : SFR<473, "$vsfr217", ["$s473"]>;
def VSFR218 : SFR<474, "$vsfr218", ["$s474"]>;
def VSFR219 : SFR<475, "$vsfr219", ["$s475"]>;
def VSFR220 : SFR<476, "$vsfr220", ["$s476"]>;
def VSFR221 : SFR<477, "$vsfr221", ["$s477"]>;
def VSFR222 : SFR<478, "$vsfr222", ["$s478"]>;
def VSFR223 : SFR<479, "$vsfr223", ["$s479"]>;
def VSFR224 : SFR<480, "$vsfr224", ["$s480"]>;
def VSFR225 : SFR<481, "$vsfr225", ["$s481"]>;
def VSFR226 : SFR<482, "$vsfr226", ["$s482"]>;
def VSFR227 : SFR<483, "$vsfr227", ["$s483"]>;
def VSFR228 : SFR<484, "$vsfr228", ["$s484"]>;
def VSFR229 : SFR<485, "$vsfr229", ["$s485"]>;
def VSFR230 : SFR<486, "$vsfr230", ["$s486"]>;
def VSFR231 : SFR<487, "$vsfr231", ["$s487"]>;
def VSFR232 : SFR<488, "$vsfr232", ["$s488"]>;
def VSFR233 : SFR<489, "$vsfr233", ["$s489"]>;
def VSFR234 : SFR<490, "$vsfr234", ["$s490"]>;
def VSFR235 : SFR<491, "$vsfr235", ["$s491"]>;
def VSFR236 : SFR<492, "$vsfr236", ["$s492"]>;
def VSFR237 : SFR<493, "$vsfr237", ["$s493"]>;
def VSFR238 : SFR<494, "$vsfr238", ["$s494"]>;
def VSFR239 : SFR<495, "$vsfr239", ["$s495"]>;
def VSFR240 : SFR<496, "$vsfr240", ["$s496"]>;
def VSFR241 : SFR<497, "$vsfr241", ["$s497"]>;
def VSFR242 : SFR<498, "$vsfr242", ["$s498"]>;
def VSFR243 : SFR<499, "$vsfr243", ["$s499"]>;
def VSFR244 : SFR<500, "$vsfr244", ["$s500"]>;
def VSFR245 : SFR<501, "$vsfr245", ["$s501"]>;
def VSFR246 : SFR<502, "$vsfr246", ["$s502"]>;
def VSFR247 : SFR<503, "$vsfr247", ["$s503"]>;
def VSFR248 : SFR<504, "$vsfr248", ["$s504"]>;
def VSFR249 : SFR<505, "$vsfr249", ["$s505"]>;
def VSFR250 : SFR<506, "$vsfr250", ["$s506"]>;
def VSFR251 : SFR<507, "$vsfr251", ["$s507"]>;
def VSFR252 : SFR<508, "$vsfr252", ["$s508"]>;
def VSFR253 : SFR<509, "$vsfr253", ["$s509"]>;
def VSFR254 : SFR<510, "$vsfr254", ["$s510"]>;
def VSFR255 : SFR<511, "$vsfr255", ["$s511"]>;


// General-Purpose Registers
def R0  : GPR< 0,  "$r0">, DwarfRegNum<[ 0]>;
def R1  : GPR< 1,  "$r1">, DwarfRegNum<[ 1]>;
def R2  : GPR< 2,  "$r2">, DwarfRegNum<[ 2]>;
def R3  : GPR< 3,  "$r3">, DwarfRegNum<[ 3]>;
def R4  : GPR< 4,  "$r4">, DwarfRegNum<[ 4]>;
def R5  : GPR< 5,  "$r5">, DwarfRegNum<[ 5]>;
def R6  : GPR< 6,  "$r6">, DwarfRegNum<[ 6]>;
def R7  : GPR< 7,  "$r7">, DwarfRegNum<[ 7]>;
def R8  : GPR< 8,  "$r8">, DwarfRegNum<[ 8]>;
def R9  : GPR< 9,  "$r9">, DwarfRegNum<[ 9]>;
def R10 : GPR<10, "$r10">, DwarfRegNum<[10]>;
def R11 : GPR<11, "$r11">, DwarfRegNum<[11]>;
def R12 : GPR<12, "$r12", ["$sp"]>, DwarfRegNum<[12]>;
def R13 : GPR<13, "$r13", ["$tp"]>, DwarfRegNum<[13]>;
def R14 : GPR<14, "$r14", ["$fp"]>, DwarfRegNum<[14]>;
def R15 : GPR<15, "$r15">, DwarfRegNum<[15]>;
def R16 : GPR<16, "$r16">, DwarfRegNum<[16]>;
def R17 : GPR<17, "$r17">, DwarfRegNum<[17]>;
def R18 : GPR<18, "$r18">, DwarfRegNum<[18]>;
def R19 : GPR<19, "$r19">, DwarfRegNum<[19]>;
def R20 : GPR<20, "$r20">, DwarfRegNum<[20]>;
def R21 : GPR<21, "$r21">, DwarfRegNum<[21]>;
def R22 : GPR<22, "$r22">, DwarfRegNum<[22]>;
def R23 : GPR<23, "$r23">, DwarfRegNum<[23]>;
def R24 : GPR<24, "$r24">, DwarfRegNum<[24]>;
def R25 : GPR<25, "$r25">, DwarfRegNum<[25]>;
def R26 : GPR<26, "$r26">, DwarfRegNum<[26]>;
def R27 : GPR<27, "$r27">, DwarfRegNum<[27]>;
def R28 : GPR<28, "$r28">, DwarfRegNum<[28]>;
def R29 : GPR<29, "$r29">, DwarfRegNum<[29]>;
def R30 : GPR<30, "$r30">, DwarfRegNum<[30]>;
def R31 : GPR<31, "$r31">, DwarfRegNum<[31]>;
def R32 : GPR<32, "$r32">, DwarfRegNum<[32]>;
def R33 : GPR<33, "$r33">, DwarfRegNum<[33]>;
def R34 : GPR<34, "$r34">, DwarfRegNum<[34]>;
def R35 : GPR<35, "$r35">, DwarfRegNum<[35]>;
def R36 : GPR<36, "$r36">, DwarfRegNum<[36]>;
def R37 : GPR<37, "$r37">, DwarfRegNum<[37]>;
def R38 : GPR<38, "$r38">, DwarfRegNum<[38]>;
def R39 : GPR<39, "$r39">, DwarfRegNum<[39]>;
def R40 : GPR<40, "$r40">, DwarfRegNum<[40]>;
def R41 : GPR<41, "$r41">, DwarfRegNum<[41]>;
def R42 : GPR<42, "$r42">, DwarfRegNum<[42]>;
def R43 : GPR<43, "$r43">, DwarfRegNum<[43]>;
def R44 : GPR<44, "$r44">, DwarfRegNum<[44]>;
def R45 : GPR<45, "$r45">, DwarfRegNum<[45]>;
def R46 : GPR<46, "$r46">, DwarfRegNum<[46]>;
def R47 : GPR<47, "$r47">, DwarfRegNum<[47]>;
def R48 : GPR<48, "$r48">, DwarfRegNum<[48]>;
def R49 : GPR<49, "$r49">, DwarfRegNum<[49]>;
def R50 : GPR<50, "$r50">, DwarfRegNum<[50]>;
def R51 : GPR<51, "$r51">, DwarfRegNum<[51]>;
def R52 : GPR<52, "$r52">, DwarfRegNum<[52]>;
def R53 : GPR<53, "$r53">, DwarfRegNum<[53]>;
def R54 : GPR<54, "$r54">, DwarfRegNum<[54]>;
def R55 : GPR<55, "$r55">, DwarfRegNum<[55]>;
def R56 : GPR<56, "$r56">, DwarfRegNum<[56]>;
def R57 : GPR<57, "$r57">, DwarfRegNum<[57]>;
def R58 : GPR<58, "$r58">, DwarfRegNum<[58]>;
def R59 : GPR<59, "$r59">, DwarfRegNum<[59]>;
def R60 : GPR<60, "$r60">, DwarfRegNum<[60]>;
def R61 : GPR<61, "$r61">, DwarfRegNum<[61]>;
def R62 : GPR<62, "$r62">, DwarfRegNum<[62]>;
def R63 : GPR<63, "$r63">, DwarfRegNum<[63]>;


// Paired General Registers
def P0  : PGR< 0,   "$r0r1", [ R0,  R1]>;
def P2  : PGR< 2,   "$r2r3", [ R2,  R3]>;
def P4  : PGR< 4,   "$r4r5", [ R4,  R5]>;
def P6  : PGR< 6,   "$r6r7", [ R6,  R7]>;
def P8  : PGR< 8,   "$r8r9", [ R8,  R9]>;
def P10 : PGR<10, "$r10r11", [R10, R11]>;
def P12 : PGR<12, "$r12r13", [R12, R13]>;
def P14 : PGR<14, "$r14r15", [R14, R15]>;
def P16 : PGR<16, "$r16r17", [R16, R17]>;
def P18 : PGR<18, "$r18r19", [R18, R19]>;
def P20 : PGR<20, "$r20r21", [R20, R21]>;
def P22 : PGR<22, "$r22r23", [R22, R23]>;
def P24 : PGR<24, "$r24r25", [R24, R25]>;
def P26 : PGR<26, "$r26r27", [R26, R27]>;
def P28 : PGR<28, "$r28r29", [R28, R29]>;
def P30 : PGR<30, "$r30r31", [R30, R31]>;
def P32 : PGR<32, "$r32r33", [R32, R33]>;
def P34 : PGR<34, "$r34r35", [R34, R35]>;
def P36 : PGR<36, "$r36r37", [R36, R37]>;
def P38 : PGR<38, "$r38r39", [R38, R39]>;
def P40 : PGR<40, "$r40r41", [R40, R41]>;
def P42 : PGR<42, "$r42r43", [R42, R43]>;
def P44 : PGR<44, "$r44r45", [R44, R45]>;
def P46 : PGR<46, "$r46r47", [R46, R47]>;
def P48 : PGR<48, "$r48r49", [R48, R49]>;
def P50 : PGR<50, "$r50r51", [R50, R51]>;
def P52 : PGR<52, "$r52r53", [R52, R53]>;
def P54 : PGR<54, "$r54r55", [R54, R55]>;
def P56 : PGR<56, "$r56r57", [R56, R57]>;
def P58 : PGR<58, "$r58r59", [R58, R59]>;
def P60 : PGR<60, "$r60r61", [R60, R61]>;
def P62 : PGR<62, "$r62r63", [R62, R63]>;


// Quadruple General Registers
def Q0  : QGR< 0,     "$r0r1r2r3", [ R0,  R1,  R2,  R3]>;
def Q4  : QGR< 4,     "$r4r5r6r7", [ R4,  R5,  R6,  R7]>;
def Q8  : QGR< 8,   "$r8r9r10r11", [ R8,  R9, R10, R11]>;
def Q12 : QGR<12, "$r12r13r14r15", [R12, R13, R14, R15]>;
def Q16 : QGR<16, "$r16r17r18r19", [R16, R17, R18, R19]>;
def Q20 : QGR<20, "$r20r21r22r23", [R20, R21, R22, R23]>;
def Q24 : QGR<24, "$r24r25r26r27", [R24, R25, R26, R27]>;
def Q28 : QGR<28, "$r28r29r30r31", [R28, R29, R30, R31]>;
def Q32 : QGR<32, "$r32r33r34r35", [R32, R33, R34, R35]>;
def Q36 : QGR<36, "$r36r37r38r39", [R36, R37, R38, R39]>;
def Q40 : QGR<40, "$r40r41r42r43", [R40, R41, R42, R43]>;
def Q44 : QGR<44, "$r44r45r46r47", [R44, R45, R46, R47]>;
def Q48 : QGR<48, "$r48r49r50r51", [R48, R49, R50, R51]>;
def Q52 : QGR<52, "$r52r53r54r55", [R52, R53, R54, R55]>;
def Q56 : QGR<56, "$r56r57r58r59", [R56, R57, R58, R59]>;
def Q60 : QGR<60, "$r60r61r62r63", [R60, R61, R62, R63]>;


// Extension Coprocessor Registers
def C0   : XCR<  0,  "$a0_x",  ["$a0.x"]>, DwarfRegNum<[256]>;
def C1   : XCR<  1,  "$a0_y",  ["$a0.y"]>, DwarfRegNum<[257]>;
def C2   : XCR<  2,  "$a0_z",  ["$a0.z"]>, DwarfRegNum<[258]>;
def C3   : XCR<  3,  "$a0_t",  ["$a0.t"]>, DwarfRegNum<[259]>;
def C4   : XCR<  4,  "$a1_x",  ["$a1.x"]>, DwarfRegNum<[260]>;
def C5   : XCR<  5,  "$a1_y",  ["$a1.y"]>, DwarfRegNum<[261]>;
def C6   : XCR<  6,  "$a1_z",  ["$a1.z"]>, DwarfRegNum<[262]>;
def C7   : XCR<  7,  "$a1_t",  ["$a1.t"]>, DwarfRegNum<[263]>;
def C8   : XCR<  8,  "$a2_x",  ["$a2.x"]>, DwarfRegNum<[264]>;
def C9   : XCR<  9,  "$a2_y",  ["$a2.y"]>, DwarfRegNum<[265]>;
def C10  : XCR< 10,  "$a2_z",  ["$a2.z"]>, DwarfRegNum<[266]>;
def C11  : XCR< 11,  "$a2_t",  ["$a2.t"]>, DwarfRegNum<[267]>;
def C12  : XCR< 12,  "$a3_x",  ["$a3.x"]>, DwarfRegNum<[268]>;
def C13  : XCR< 13,  "$a3_y",  ["$a3.y"]>, DwarfRegNum<[269]>;
def C14  : XCR< 14,  "$a3_z",  ["$a3.z"]>, DwarfRegNum<[270]>;
def C15  : XCR< 15,  "$a3_t",  ["$a3.t"]>, DwarfRegNum<[271]>;
def C16  : XCR< 16,  "$a4_x",  ["$a4.x"]>, DwarfRegNum<[272]>;
def C17  : XCR< 17,  "$a4_y",  ["$a4.y"]>, DwarfRegNum<[273]>;
def C18  : XCR< 18,  "$a4_z",  ["$a4.z"]>, DwarfRegNum<[274]>;
def C19  : XCR< 19,  "$a4_t",  ["$a4.t"]>, DwarfRegNum<[275]>;
def C20  : XCR< 20,  "$a5_x",  ["$a5.x"]>, DwarfRegNum<[276]>;
def C21  : XCR< 21,  "$a5_y",  ["$a5.y"]>, DwarfRegNum<[277]>;
def C22  : XCR< 22,  "$a5_z",  ["$a5.z"]>, DwarfRegNum<[278]>;
def C23  : XCR< 23,  "$a5_t",  ["$a5.t"]>, DwarfRegNum<[279]>;
def C24  : XCR< 24,  "$a6_x",  ["$a6.x"]>, DwarfRegNum<[280]>;
def C25  : XCR< 25,  "$a6_y",  ["$a6.y"]>, DwarfRegNum<[281]>;
def C26  : XCR< 26,  "$a6_z",  ["$a6.z"]>, DwarfRegNum<[282]>;
def C27  : XCR< 27,  "$a6_t",  ["$a6.t"]>, DwarfRegNum<[283]>;
def C28  : XCR< 28,  "$a7_x",  ["$a7.x"]>, DwarfRegNum<[284]>;
def C29  : XCR< 29,  "$a7_y",  ["$a7.y"]>, DwarfRegNum<[285]>;
def C30  : XCR< 30,  "$a7_z",  ["$a7.z"]>, DwarfRegNum<[286]>;
def C31  : XCR< 31,  "$a7_t",  ["$a7.t"]>, DwarfRegNum<[287]>;
def C32  : XCR< 32,  "$a8_x",  ["$a8.x"]>, DwarfRegNum<[288]>;
def C33  : XCR< 33,  "$a8_y",  ["$a8.y"]>, DwarfRegNum<[289]>;
def C34  : XCR< 34,  "$a8_z",  ["$a8.z"]>, DwarfRegNum<[290]>;
def C35  : XCR< 35,  "$a8_t",  ["$a8.t"]>, DwarfRegNum<[291]>;
def C36  : XCR< 36,  "$a9_x",  ["$a9.x"]>, DwarfRegNum<[292]>;
def C37  : XCR< 37,  "$a9_y",  ["$a9.y"]>, DwarfRegNum<[293]>;
def C38  : XCR< 38,  "$a9_z",  ["$a9.z"]>, DwarfRegNum<[294]>;
def C39  : XCR< 39,  "$a9_t",  ["$a9.t"]>, DwarfRegNum<[295]>;
def C40  : XCR< 40, "$a10_x", ["$a10.x"]>, DwarfRegNum<[296]>;
def C41  : XCR< 41, "$a10_y", ["$a10.y"]>, DwarfRegNum<[297]>;
def C42  : XCR< 42, "$a10_z", ["$a10.z"]>, DwarfRegNum<[298]>;
def C43  : XCR< 43, "$a10_t", ["$a10.t"]>, DwarfRegNum<[299]>;
def C44  : XCR< 44, "$a11_x", ["$a11.x"]>, DwarfRegNum<[300]>;
def C45  : XCR< 45, "$a11_y", ["$a11.y"]>, DwarfRegNum<[301]>;
def C46  : XCR< 46, "$a11_z", ["$a11.z"]>, DwarfRegNum<[302]>;
def C47  : XCR< 47, "$a11_t", ["$a11.t"]>, DwarfRegNum<[303]>;
def C48  : XCR< 48, "$a12_x", ["$a12.x"]>, DwarfRegNum<[304]>;
def C49  : XCR< 49, "$a12_y", ["$a12.y"]>, DwarfRegNum<[305]>;
def C50  : XCR< 50, "$a12_z", ["$a12.z"]>, DwarfRegNum<[306]>;
def C51  : XCR< 51, "$a12_t", ["$a12.t"]>, DwarfRegNum<[307]>;
def C52  : XCR< 52, "$a13_x", ["$a13.x"]>, DwarfRegNum<[308]>;
def C53  : XCR< 53, "$a13_y", ["$a13.y"]>, DwarfRegNum<[309]>;
def C54  : XCR< 54, "$a13_z", ["$a13.z"]>, DwarfRegNum<[310]>;
def C55  : XCR< 55, "$a13_t", ["$a13.t"]>, DwarfRegNum<[311]>;
def C56  : XCR< 56, "$a14_x", ["$a14.x"]>, DwarfRegNum<[312]>;
def C57  : XCR< 57, "$a14_y", ["$a14.y"]>, DwarfRegNum<[313]>;
def C58  : XCR< 58, "$a14_z", ["$a14.z"]>, DwarfRegNum<[314]>;
def C59  : XCR< 59, "$a14_t", ["$a14.t"]>, DwarfRegNum<[315]>;
def C60  : XCR< 60, "$a15_x", ["$a15.x"]>, DwarfRegNum<[316]>;
def C61  : XCR< 61, "$a15_y", ["$a15.y"]>, DwarfRegNum<[317]>;
def C62  : XCR< 62, "$a15_z", ["$a15.z"]>, DwarfRegNum<[318]>;
def C63  : XCR< 63, "$a15_t", ["$a15.t"]>, DwarfRegNum<[319]>;
def C64  : XCR< 64, "$a16_x", ["$a16.x"]>, DwarfRegNum<[320]>;
def C65  : XCR< 65, "$a16_y", ["$a16.y"]>, DwarfRegNum<[321]>;
def C66  : XCR< 66, "$a16_z", ["$a16.z"]>, DwarfRegNum<[322]>;
def C67  : XCR< 67, "$a16_t", ["$a16.t"]>, DwarfRegNum<[323]>;
def C68  : XCR< 68, "$a17_x", ["$a17.x"]>, DwarfRegNum<[324]>;
def C69  : XCR< 69, "$a17_y", ["$a17.y"]>, DwarfRegNum<[325]>;
def C70  : XCR< 70, "$a17_z", ["$a17.z"]>, DwarfRegNum<[326]>;
def C71  : XCR< 71, "$a17_t", ["$a17.t"]>, DwarfRegNum<[327]>;
def C72  : XCR< 72, "$a18_x", ["$a18.x"]>, DwarfRegNum<[328]>;
def C73  : XCR< 73, "$a18_y", ["$a18.y"]>, DwarfRegNum<[329]>;
def C74  : XCR< 74, "$a18_z", ["$a18.z"]>, DwarfRegNum<[330]>;
def C75  : XCR< 75, "$a18_t", ["$a18.t"]>, DwarfRegNum<[331]>;
def C76  : XCR< 76, "$a19_x", ["$a19.x"]>, DwarfRegNum<[332]>;
def C77  : XCR< 77, "$a19_y", ["$a19.y"]>, DwarfRegNum<[333]>;
def C78  : XCR< 78, "$a19_z", ["$a19.z"]>, DwarfRegNum<[334]>;
def C79  : XCR< 79, "$a19_t", ["$a19.t"]>, DwarfRegNum<[335]>;
def C80  : XCR< 80, "$a20_x", ["$a20.x"]>, DwarfRegNum<[336]>;
def C81  : XCR< 81, "$a20_y", ["$a20.y"]>, DwarfRegNum<[337]>;
def C82  : XCR< 82, "$a20_z", ["$a20.z"]>, DwarfRegNum<[338]>;
def C83  : XCR< 83, "$a20_t", ["$a20.t"]>, DwarfRegNum<[339]>;
def C84  : XCR< 84, "$a21_x", ["$a21.x"]>, DwarfRegNum<[340]>;
def C85  : XCR< 85, "$a21_y", ["$a21.y"]>, DwarfRegNum<[341]>;
def C86  : XCR< 86, "$a21_z", ["$a21.z"]>, DwarfRegNum<[342]>;
def C87  : XCR< 87, "$a21_t", ["$a21.t"]>, DwarfRegNum<[343]>;
def C88  : XCR< 88, "$a22_x", ["$a22.x"]>, DwarfRegNum<[344]>;
def C89  : XCR< 89, "$a22_y", ["$a22.y"]>, DwarfRegNum<[345]>;
def C90  : XCR< 90, "$a22_z", ["$a22.z"]>, DwarfRegNum<[346]>;
def C91  : XCR< 91, "$a22_t", ["$a22.t"]>, DwarfRegNum<[347]>;
def C92  : XCR< 92, "$a23_x", ["$a23.x"]>, DwarfRegNum<[348]>;
def C93  : XCR< 93, "$a23_y", ["$a23.y"]>, DwarfRegNum<[349]>;
def C94  : XCR< 94, "$a23_z", ["$a23.z"]>, DwarfRegNum<[350]>;
def C95  : XCR< 95, "$a23_t", ["$a23.t"]>, DwarfRegNum<[351]>;
def C96  : XCR< 96, "$a24_x", ["$a24.x"]>, DwarfRegNum<[352]>;
def C97  : XCR< 97, "$a24_y", ["$a24.y"]>, DwarfRegNum<[353]>;
def C98  : XCR< 98, "$a24_z", ["$a24.z"]>, DwarfRegNum<[354]>;
def C99  : XCR< 99, "$a24_t", ["$a24.t"]>, DwarfRegNum<[355]>;
def C100 : XCR<100, "$a25_x", ["$a25.x"]>, DwarfRegNum<[356]>;
def C101 : XCR<101, "$a25_y", ["$a25.y"]>, DwarfRegNum<[357]>;
def C102 : XCR<102, "$a25_z", ["$a25.z"]>, DwarfRegNum<[358]>;
def C103 : XCR<103, "$a25_t", ["$a25.t"]>, DwarfRegNum<[359]>;
def C104 : XCR<104, "$a26_x", ["$a26.x"]>, DwarfRegNum<[360]>;
def C105 : XCR<105, "$a26_y", ["$a26.y"]>, DwarfRegNum<[361]>;
def C106 : XCR<106, "$a26_z", ["$a26.z"]>, DwarfRegNum<[362]>;
def C107 : XCR<107, "$a26_t", ["$a26.t"]>, DwarfRegNum<[363]>;
def C108 : XCR<108, "$a27_x", ["$a27.x"]>, DwarfRegNum<[364]>;
def C109 : XCR<109, "$a27_y", ["$a27.y"]>, DwarfRegNum<[365]>;
def C110 : XCR<110, "$a27_z", ["$a27.z"]>, DwarfRegNum<[366]>;
def C111 : XCR<111, "$a27_t", ["$a27.t"]>, DwarfRegNum<[367]>;
def C112 : XCR<112, "$a28_x", ["$a28.x"]>, DwarfRegNum<[368]>;
def C113 : XCR<113, "$a28_y", ["$a28.y"]>, DwarfRegNum<[369]>;
def C114 : XCR<114, "$a28_z", ["$a28.z"]>, DwarfRegNum<[370]>;
def C115 : XCR<115, "$a28_t", ["$a28.t"]>, DwarfRegNum<[371]>;
def C116 : XCR<116, "$a29_x", ["$a29.x"]>, DwarfRegNum<[372]>;
def C117 : XCR<117, "$a29_y", ["$a29.y"]>, DwarfRegNum<[373]>;
def C118 : XCR<118, "$a29_z", ["$a29.z"]>, DwarfRegNum<[374]>;
def C119 : XCR<119, "$a29_t", ["$a29.t"]>, DwarfRegNum<[375]>;
def C120 : XCR<120, "$a30_x", ["$a30.x"]>, DwarfRegNum<[376]>;
def C121 : XCR<121, "$a30_y", ["$a30.y"]>, DwarfRegNum<[377]>;
def C122 : XCR<122, "$a30_z", ["$a30.z"]>, DwarfRegNum<[378]>;
def C123 : XCR<123, "$a30_t", ["$a30.t"]>, DwarfRegNum<[379]>;
def C124 : XCR<124, "$a31_x", ["$a31.x"]>, DwarfRegNum<[380]>;
def C125 : XCR<125, "$a31_y", ["$a31.y"]>, DwarfRegNum<[381]>;
def C126 : XCR<126, "$a31_z", ["$a31.z"]>, DwarfRegNum<[382]>;
def C127 : XCR<127, "$a31_t", ["$a31.t"]>, DwarfRegNum<[383]>;
def C128 : XCR<128, "$a32_x", ["$a32.x"]>, DwarfRegNum<[384]>;
def C129 : XCR<129, "$a32_y", ["$a32.y"]>, DwarfRegNum<[385]>;
def C130 : XCR<130, "$a32_z", ["$a32.z"]>, DwarfRegNum<[386]>;
def C131 : XCR<131, "$a32_t", ["$a32.t"]>, DwarfRegNum<[387]>;
def C132 : XCR<132, "$a33_x", ["$a33.x"]>, DwarfRegNum<[388]>;
def C133 : XCR<133, "$a33_y", ["$a33.y"]>, DwarfRegNum<[389]>;
def C134 : XCR<134, "$a33_z", ["$a33.z"]>, DwarfRegNum<[390]>;
def C135 : XCR<135, "$a33_t", ["$a33.t"]>, DwarfRegNum<[391]>;
def C136 : XCR<136, "$a34_x", ["$a34.x"]>, DwarfRegNum<[392]>;
def C137 : XCR<137, "$a34_y", ["$a34.y"]>, DwarfRegNum<[393]>;
def C138 : XCR<138, "$a34_z", ["$a34.z"]>, DwarfRegNum<[394]>;
def C139 : XCR<139, "$a34_t", ["$a34.t"]>, DwarfRegNum<[395]>;
def C140 : XCR<140, "$a35_x", ["$a35.x"]>, DwarfRegNum<[396]>;
def C141 : XCR<141, "$a35_y", ["$a35.y"]>, DwarfRegNum<[397]>;
def C142 : XCR<142, "$a35_z", ["$a35.z"]>, DwarfRegNum<[398]>;
def C143 : XCR<143, "$a35_t", ["$a35.t"]>, DwarfRegNum<[399]>;
def C144 : XCR<144, "$a36_x", ["$a36.x"]>, DwarfRegNum<[400]>;
def C145 : XCR<145, "$a36_y", ["$a36.y"]>, DwarfRegNum<[401]>;
def C146 : XCR<146, "$a36_z", ["$a36.z"]>, DwarfRegNum<[402]>;
def C147 : XCR<147, "$a36_t", ["$a36.t"]>, DwarfRegNum<[403]>;
def C148 : XCR<148, "$a37_x", ["$a37.x"]>, DwarfRegNum<[404]>;
def C149 : XCR<149, "$a37_y", ["$a37.y"]>, DwarfRegNum<[405]>;
def C150 : XCR<150, "$a37_z", ["$a37.z"]>, DwarfRegNum<[406]>;
def C151 : XCR<151, "$a37_t", ["$a37.t"]>, DwarfRegNum<[407]>;
def C152 : XCR<152, "$a38_x", ["$a38.x"]>, DwarfRegNum<[408]>;
def C153 : XCR<153, "$a38_y", ["$a38.y"]>, DwarfRegNum<[409]>;
def C154 : XCR<154, "$a38_z", ["$a38.z"]>, DwarfRegNum<[410]>;
def C155 : XCR<155, "$a38_t", ["$a38.t"]>, DwarfRegNum<[411]>;
def C156 : XCR<156, "$a39_x", ["$a39.x"]>, DwarfRegNum<[412]>;
def C157 : XCR<157, "$a39_y", ["$a39.y"]>, DwarfRegNum<[413]>;
def C158 : XCR<158, "$a39_z", ["$a39.z"]>, DwarfRegNum<[414]>;
def C159 : XCR<159, "$a39_t", ["$a39.t"]>, DwarfRegNum<[415]>;
def C160 : XCR<160, "$a40_x", ["$a40.x"]>, DwarfRegNum<[416]>;
def C161 : XCR<161, "$a40_y", ["$a40.y"]>, DwarfRegNum<[417]>;
def C162 : XCR<162, "$a40_z", ["$a40.z"]>, DwarfRegNum<[418]>;
def C163 : XCR<163, "$a40_t", ["$a40.t"]>, DwarfRegNum<[419]>;
def C164 : XCR<164, "$a41_x", ["$a41.x"]>, DwarfRegNum<[420]>;
def C165 : XCR<165, "$a41_y", ["$a41.y"]>, DwarfRegNum<[421]>;
def C166 : XCR<166, "$a41_z", ["$a41.z"]>, DwarfRegNum<[422]>;
def C167 : XCR<167, "$a41_t", ["$a41.t"]>, DwarfRegNum<[423]>;
def C168 : XCR<168, "$a42_x", ["$a42.x"]>, DwarfRegNum<[424]>;
def C169 : XCR<169, "$a42_y", ["$a42.y"]>, DwarfRegNum<[425]>;
def C170 : XCR<170, "$a42_z", ["$a42.z"]>, DwarfRegNum<[426]>;
def C171 : XCR<171, "$a42_t", ["$a42.t"]>, DwarfRegNum<[427]>;
def C172 : XCR<172, "$a43_x", ["$a43.x"]>, DwarfRegNum<[428]>;
def C173 : XCR<173, "$a43_y", ["$a43.y"]>, DwarfRegNum<[429]>;
def C174 : XCR<174, "$a43_z", ["$a43.z"]>, DwarfRegNum<[430]>;
def C175 : XCR<175, "$a43_t", ["$a43.t"]>, DwarfRegNum<[431]>;
def C176 : XCR<176, "$a44_x", ["$a44.x"]>, DwarfRegNum<[432]>;
def C177 : XCR<177, "$a44_y", ["$a44.y"]>, DwarfRegNum<[433]>;
def C178 : XCR<178, "$a44_z", ["$a44.z"]>, DwarfRegNum<[434]>;
def C179 : XCR<179, "$a44_t", ["$a44.t"]>, DwarfRegNum<[435]>;
def C180 : XCR<180, "$a45_x", ["$a45.x"]>, DwarfRegNum<[436]>;
def C181 : XCR<181, "$a45_y", ["$a45.y"]>, DwarfRegNum<[437]>;
def C182 : XCR<182, "$a45_z", ["$a45.z"]>, DwarfRegNum<[438]>;
def C183 : XCR<183, "$a45_t", ["$a45.t"]>, DwarfRegNum<[439]>;
def C184 : XCR<184, "$a46_x", ["$a46.x"]>, DwarfRegNum<[440]>;
def C185 : XCR<185, "$a46_y", ["$a46.y"]>, DwarfRegNum<[441]>;
def C186 : XCR<186, "$a46_z", ["$a46.z"]>, DwarfRegNum<[442]>;
def C187 : XCR<187, "$a46_t", ["$a46.t"]>, DwarfRegNum<[443]>;
def C188 : XCR<188, "$a47_x", ["$a47.x"]>, DwarfRegNum<[444]>;
def C189 : XCR<189, "$a47_y", ["$a47.y"]>, DwarfRegNum<[445]>;
def C190 : XCR<190, "$a47_z", ["$a47.z"]>, DwarfRegNum<[446]>;
def C191 : XCR<191, "$a47_t", ["$a47.t"]>, DwarfRegNum<[447]>;
def C192 : XCR<192, "$a48_x", ["$a48.x"]>, DwarfRegNum<[448]>;
def C193 : XCR<193, "$a48_y", ["$a48.y"]>, DwarfRegNum<[449]>;
def C194 : XCR<194, "$a48_z", ["$a48.z"]>, DwarfRegNum<[450]>;
def C195 : XCR<195, "$a48_t", ["$a48.t"]>, DwarfRegNum<[451]>;
def C196 : XCR<196, "$a49_x", ["$a49.x"]>, DwarfRegNum<[452]>;
def C197 : XCR<197, "$a49_y", ["$a49.y"]>, DwarfRegNum<[453]>;
def C198 : XCR<198, "$a49_z", ["$a49.z"]>, DwarfRegNum<[454]>;
def C199 : XCR<199, "$a49_t", ["$a49.t"]>, DwarfRegNum<[455]>;
def C200 : XCR<200, "$a50_x", ["$a50.x"]>, DwarfRegNum<[456]>;
def C201 : XCR<201, "$a50_y", ["$a50.y"]>, DwarfRegNum<[457]>;
def C202 : XCR<202, "$a50_z", ["$a50.z"]>, DwarfRegNum<[458]>;
def C203 : XCR<203, "$a50_t", ["$a50.t"]>, DwarfRegNum<[459]>;
def C204 : XCR<204, "$a51_x", ["$a51.x"]>, DwarfRegNum<[460]>;
def C205 : XCR<205, "$a51_y", ["$a51.y"]>, DwarfRegNum<[461]>;
def C206 : XCR<206, "$a51_z", ["$a51.z"]>, DwarfRegNum<[462]>;
def C207 : XCR<207, "$a51_t", ["$a51.t"]>, DwarfRegNum<[463]>;
def C208 : XCR<208, "$a52_x", ["$a52.x"]>, DwarfRegNum<[464]>;
def C209 : XCR<209, "$a52_y", ["$a52.y"]>, DwarfRegNum<[465]>;
def C210 : XCR<210, "$a52_z", ["$a52.z"]>, DwarfRegNum<[466]>;
def C211 : XCR<211, "$a52_t", ["$a52.t"]>, DwarfRegNum<[467]>;
def C212 : XCR<212, "$a53_x", ["$a53.x"]>, DwarfRegNum<[468]>;
def C213 : XCR<213, "$a53_y", ["$a53.y"]>, DwarfRegNum<[469]>;
def C214 : XCR<214, "$a53_z", ["$a53.z"]>, DwarfRegNum<[470]>;
def C215 : XCR<215, "$a53_t", ["$a53.t"]>, DwarfRegNum<[471]>;
def C216 : XCR<216, "$a54_x", ["$a54.x"]>, DwarfRegNum<[472]>;
def C217 : XCR<217, "$a54_y", ["$a54.y"]>, DwarfRegNum<[473]>;
def C218 : XCR<218, "$a54_z", ["$a54.z"]>, DwarfRegNum<[474]>;
def C219 : XCR<219, "$a54_t", ["$a54.t"]>, DwarfRegNum<[475]>;
def C220 : XCR<220, "$a55_x", ["$a55.x"]>, DwarfRegNum<[476]>;
def C221 : XCR<221, "$a55_y", ["$a55.y"]>, DwarfRegNum<[477]>;
def C222 : XCR<222, "$a55_z", ["$a55.z"]>, DwarfRegNum<[478]>;
def C223 : XCR<223, "$a55_t", ["$a55.t"]>, DwarfRegNum<[479]>;
def C224 : XCR<224, "$a56_x", ["$a56.x"]>, DwarfRegNum<[480]>;
def C225 : XCR<225, "$a56_y", ["$a56.y"]>, DwarfRegNum<[481]>;
def C226 : XCR<226, "$a56_z", ["$a56.z"]>, DwarfRegNum<[482]>;
def C227 : XCR<227, "$a56_t", ["$a56.t"]>, DwarfRegNum<[483]>;
def C228 : XCR<228, "$a57_x", ["$a57.x"]>, DwarfRegNum<[484]>;
def C229 : XCR<229, "$a57_y", ["$a57.y"]>, DwarfRegNum<[485]>;
def C230 : XCR<230, "$a57_z", ["$a57.z"]>, DwarfRegNum<[486]>;
def C231 : XCR<231, "$a57_t", ["$a57.t"]>, DwarfRegNum<[487]>;
def C232 : XCR<232, "$a58_x", ["$a58.x"]>, DwarfRegNum<[488]>;
def C233 : XCR<233, "$a58_y", ["$a58.y"]>, DwarfRegNum<[489]>;
def C234 : XCR<234, "$a58_z", ["$a58.z"]>, DwarfRegNum<[490]>;
def C235 : XCR<235, "$a58_t", ["$a58.t"]>, DwarfRegNum<[491]>;
def C236 : XCR<236, "$a59_x", ["$a59.x"]>, DwarfRegNum<[492]>;
def C237 : XCR<237, "$a59_y", ["$a59.y"]>, DwarfRegNum<[493]>;
def C238 : XCR<238, "$a59_z", ["$a59.z"]>, DwarfRegNum<[494]>;
def C239 : XCR<239, "$a59_t", ["$a59.t"]>, DwarfRegNum<[495]>;
def C240 : XCR<240, "$a60_x", ["$a60.x"]>, DwarfRegNum<[496]>;
def C241 : XCR<241, "$a60_y", ["$a60.y"]>, DwarfRegNum<[497]>;
def C242 : XCR<242, "$a60_z", ["$a60.z"]>, DwarfRegNum<[498]>;
def C243 : XCR<243, "$a60_t", ["$a60.t"]>, DwarfRegNum<[499]>;
def C244 : XCR<244, "$a61_x", ["$a61.x"]>, DwarfRegNum<[500]>;
def C245 : XCR<245, "$a61_y", ["$a61.y"]>, DwarfRegNum<[501]>;
def C246 : XCR<246, "$a61_z", ["$a61.z"]>, DwarfRegNum<[502]>;
def C247 : XCR<247, "$a61_t", ["$a61.t"]>, DwarfRegNum<[503]>;
def C248 : XCR<248, "$a62_x", ["$a62.x"]>, DwarfRegNum<[504]>;
def C249 : XCR<249, "$a62_y", ["$a62.y"]>, DwarfRegNum<[505]>;
def C250 : XCR<250, "$a62_z", ["$a62.z"]>, DwarfRegNum<[506]>;
def C251 : XCR<251, "$a62_t", ["$a62.t"]>, DwarfRegNum<[507]>;
def C252 : XCR<252, "$a63_x", ["$a63.x"]>, DwarfRegNum<[508]>;
def C253 : XCR<253, "$a63_y", ["$a63.y"]>, DwarfRegNum<[509]>;
def C254 : XCR<254, "$a63_z", ["$a63.z"]>, DwarfRegNum<[510]>;
def C255 : XCR<255, "$a63_t", ["$a63.t"]>, DwarfRegNum<[511]>;


// Extension Block Registers
def B0   : XBR<  0,  "$a0_lo", [  C0,   C1],  ["$a0.lo"]>;
def B1   : XBR<  1,  "$a0_hi", [  C2,   C3],  ["$a0.hi"]>;
def B2   : XBR<  2,  "$a1_lo", [  C4,   C5],  ["$a1.lo"]>;
def B3   : XBR<  3,  "$a1_hi", [  C6,   C7],  ["$a1.hi"]>;
def B4   : XBR<  4,  "$a2_lo", [  C8,   C9],  ["$a2.lo"]>;
def B5   : XBR<  5,  "$a2_hi", [ C10,  C11],  ["$a2.hi"]>;
def B6   : XBR<  6,  "$a3_lo", [ C12,  C13],  ["$a3.lo"]>;
def B7   : XBR<  7,  "$a3_hi", [ C14,  C15],  ["$a3.hi"]>;
def B8   : XBR<  8,  "$a4_lo", [ C16,  C17],  ["$a4.lo"]>;
def B9   : XBR<  9,  "$a4_hi", [ C18,  C19],  ["$a4.hi"]>;
def B10  : XBR< 10,  "$a5_lo", [ C20,  C21],  ["$a5.lo"]>;
def B11  : XBR< 11,  "$a5_hi", [ C22,  C23],  ["$a5.hi"]>;
def B12  : XBR< 12,  "$a6_lo", [ C24,  C25],  ["$a6.lo"]>;
def B13  : XBR< 13,  "$a6_hi", [ C26,  C27],  ["$a6.hi"]>;
def B14  : XBR< 14,  "$a7_lo", [ C28,  C29],  ["$a7.lo"]>;
def B15  : XBR< 15,  "$a7_hi", [ C30,  C31],  ["$a7.hi"]>;
def B16  : XBR< 16,  "$a8_lo", [ C32,  C33],  ["$a8.lo"]>;
def B17  : XBR< 17,  "$a8_hi", [ C34,  C35],  ["$a8.hi"]>;
def B18  : XBR< 18,  "$a9_lo", [ C36,  C37],  ["$a9.lo"]>;
def B19  : XBR< 19,  "$a9_hi", [ C38,  C39],  ["$a9.hi"]>;
def B20  : XBR< 20, "$a10_lo", [ C40,  C41], ["$a10.lo"]>;
def B21  : XBR< 21, "$a10_hi", [ C42,  C43], ["$a10.hi"]>;
def B22  : XBR< 22, "$a11_lo", [ C44,  C45], ["$a11.lo"]>;
def B23  : XBR< 23, "$a11_hi", [ C46,  C47], ["$a11.hi"]>;
def B24  : XBR< 24, "$a12_lo", [ C48,  C49], ["$a12.lo"]>;
def B25  : XBR< 25, "$a12_hi", [ C50,  C51], ["$a12.hi"]>;
def B26  : XBR< 26, "$a13_lo", [ C52,  C53], ["$a13.lo"]>;
def B27  : XBR< 27, "$a13_hi", [ C54,  C55], ["$a13.hi"]>;
def B28  : XBR< 28, "$a14_lo", [ C56,  C57], ["$a14.lo"]>;
def B29  : XBR< 29, "$a14_hi", [ C58,  C59], ["$a14.hi"]>;
def B30  : XBR< 30, "$a15_lo", [ C60,  C61], ["$a15.lo"]>;
def B31  : XBR< 31, "$a15_hi", [ C62,  C63], ["$a15.hi"]>;
def B32  : XBR< 32, "$a16_lo", [ C64,  C65], ["$a16.lo"]>;
def B33  : XBR< 33, "$a16_hi", [ C66,  C67], ["$a16.hi"]>;
def B34  : XBR< 34, "$a17_lo", [ C68,  C69], ["$a17.lo"]>;
def B35  : XBR< 35, "$a17_hi", [ C70,  C71], ["$a17.hi"]>;
def B36  : XBR< 36, "$a18_lo", [ C72,  C73], ["$a18.lo"]>;
def B37  : XBR< 37, "$a18_hi", [ C74,  C75], ["$a18.hi"]>;
def B38  : XBR< 38, "$a19_lo", [ C76,  C77], ["$a19.lo"]>;
def B39  : XBR< 39, "$a19_hi", [ C78,  C79], ["$a19.hi"]>;
def B40  : XBR< 40, "$a20_lo", [ C80,  C81], ["$a20.lo"]>;
def B41  : XBR< 41, "$a20_hi", [ C82,  C83], ["$a20.hi"]>;
def B42  : XBR< 42, "$a21_lo", [ C84,  C85], ["$a21.lo"]>;
def B43  : XBR< 43, "$a21_hi", [ C86,  C87], ["$a21.hi"]>;
def B44  : XBR< 44, "$a22_lo", [ C88,  C89], ["$a22.lo"]>;
def B45  : XBR< 45, "$a22_hi", [ C90,  C91], ["$a22.hi"]>;
def B46  : XBR< 46, "$a23_lo", [ C92,  C93], ["$a23.lo"]>;
def B47  : XBR< 47, "$a23_hi", [ C94,  C95], ["$a23.hi"]>;
def B48  : XBR< 48, "$a24_lo", [ C96,  C97], ["$a24.lo"]>;
def B49  : XBR< 49, "$a24_hi", [ C98,  C99], ["$a24.hi"]>;
def B50  : XBR< 50, "$a25_lo", [C100, C101], ["$a25.lo"]>;
def B51  : XBR< 51, "$a25_hi", [C102, C103], ["$a25.hi"]>;
def B52  : XBR< 52, "$a26_lo", [C104, C105], ["$a26.lo"]>;
def B53  : XBR< 53, "$a26_hi", [C106, C107], ["$a26.hi"]>;
def B54  : XBR< 54, "$a27_lo", [C108, C109], ["$a27.lo"]>;
def B55  : XBR< 55, "$a27_hi", [C110, C111], ["$a27.hi"]>;
def B56  : XBR< 56, "$a28_lo", [C112, C113], ["$a28.lo"]>;
def B57  : XBR< 57, "$a28_hi", [C114, C115], ["$a28.hi"]>;
def B58  : XBR< 58, "$a29_lo", [C116, C117], ["$a29.lo"]>;
def B59  : XBR< 59, "$a29_hi", [C118, C119], ["$a29.hi"]>;
def B60  : XBR< 60, "$a30_lo", [C120, C121], ["$a30.lo"]>;
def B61  : XBR< 61, "$a30_hi", [C122, C123], ["$a30.hi"]>;
def B62  : XBR< 62, "$a31_lo", [C124, C125], ["$a31.lo"]>;
def B63  : XBR< 63, "$a31_hi", [C126, C127], ["$a31.hi"]>;
def B64  : XBR< 64, "$a32_lo", [C128, C129], ["$a32.lo"]>;
def B65  : XBR< 65, "$a32_hi", [C130, C131], ["$a32.hi"]>;
def B66  : XBR< 66, "$a33_lo", [C132, C133], ["$a33.lo"]>;
def B67  : XBR< 67, "$a33_hi", [C134, C135], ["$a33.hi"]>;
def B68  : XBR< 68, "$a34_lo", [C136, C137], ["$a34.lo"]>;
def B69  : XBR< 69, "$a34_hi", [C138, C139], ["$a34.hi"]>;
def B70  : XBR< 70, "$a35_lo", [C140, C141], ["$a35.lo"]>;
def B71  : XBR< 71, "$a35_hi", [C142, C143], ["$a35.hi"]>;
def B72  : XBR< 72, "$a36_lo", [C144, C145], ["$a36.lo"]>;
def B73  : XBR< 73, "$a36_hi", [C146, C147], ["$a36.hi"]>;
def B74  : XBR< 74, "$a37_lo", [C148, C149], ["$a37.lo"]>;
def B75  : XBR< 75, "$a37_hi", [C150, C151], ["$a37.hi"]>;
def B76  : XBR< 76, "$a38_lo", [C152, C153], ["$a38.lo"]>;
def B77  : XBR< 77, "$a38_hi", [C154, C155], ["$a38.hi"]>;
def B78  : XBR< 78, "$a39_lo", [C156, C157], ["$a39.lo"]>;
def B79  : XBR< 79, "$a39_hi", [C158, C159], ["$a39.hi"]>;
def B80  : XBR< 80, "$a40_lo", [C160, C161], ["$a40.lo"]>;
def B81  : XBR< 81, "$a40_hi", [C162, C163], ["$a40.hi"]>;
def B82  : XBR< 82, "$a41_lo", [C164, C165], ["$a41.lo"]>;
def B83  : XBR< 83, "$a41_hi", [C166, C167], ["$a41.hi"]>;
def B84  : XBR< 84, "$a42_lo", [C168, C169], ["$a42.lo"]>;
def B85  : XBR< 85, "$a42_hi", [C170, C171], ["$a42.hi"]>;
def B86  : XBR< 86, "$a43_lo", [C172, C173], ["$a43.lo"]>;
def B87  : XBR< 87, "$a43_hi", [C174, C175], ["$a43.hi"]>;
def B88  : XBR< 88, "$a44_lo", [C176, C177], ["$a44.lo"]>;
def B89  : XBR< 89, "$a44_hi", [C178, C179], ["$a44.hi"]>;
def B90  : XBR< 90, "$a45_lo", [C180, C181], ["$a45.lo"]>;
def B91  : XBR< 91, "$a45_hi", [C182, C183], ["$a45.hi"]>;
def B92  : XBR< 92, "$a46_lo", [C184, C185], ["$a46.lo"]>;
def B93  : XBR< 93, "$a46_hi", [C186, C187], ["$a46.hi"]>;
def B94  : XBR< 94, "$a47_lo", [C188, C189], ["$a47.lo"]>;
def B95  : XBR< 95, "$a47_hi", [C190, C191], ["$a47.hi"]>;
def B96  : XBR< 96, "$a48_lo", [C192, C193], ["$a48.lo"]>;
def B97  : XBR< 97, "$a48_hi", [C194, C195], ["$a48.hi"]>;
def B98  : XBR< 98, "$a49_lo", [C196, C197], ["$a49.lo"]>;
def B99  : XBR< 99, "$a49_hi", [C198, C199], ["$a49.hi"]>;
def B100 : XBR<100, "$a50_lo", [C200, C201], ["$a50.lo"]>;
def B101 : XBR<101, "$a50_hi", [C202, C203], ["$a50.hi"]>;
def B102 : XBR<102, "$a51_lo", [C204, C205], ["$a51.lo"]>;
def B103 : XBR<103, "$a51_hi", [C206, C207], ["$a51.hi"]>;
def B104 : XBR<104, "$a52_lo", [C208, C209], ["$a52.lo"]>;
def B105 : XBR<105, "$a52_hi", [C210, C211], ["$a52.hi"]>;
def B106 : XBR<106, "$a53_lo", [C212, C213], ["$a53.lo"]>;
def B107 : XBR<107, "$a53_hi", [C214, C215], ["$a53.hi"]>;
def B108 : XBR<108, "$a54_lo", [C216, C217], ["$a54.lo"]>;
def B109 : XBR<109, "$a54_hi", [C218, C219], ["$a54.hi"]>;
def B110 : XBR<110, "$a55_lo", [C220, C221], ["$a55.lo"]>;
def B111 : XBR<111, "$a55_hi", [C222, C223], ["$a55.hi"]>;
def B112 : XBR<112, "$a56_lo", [C224, C225], ["$a56.lo"]>;
def B113 : XBR<113, "$a56_hi", [C226, C227], ["$a56.hi"]>;
def B114 : XBR<114, "$a57_lo", [C228, C229], ["$a57.lo"]>;
def B115 : XBR<115, "$a57_hi", [C230, C231], ["$a57.hi"]>;
def B116 : XBR<116, "$a58_lo", [C232, C233], ["$a58.lo"]>;
def B117 : XBR<117, "$a58_hi", [C234, C235], ["$a58.hi"]>;
def B118 : XBR<118, "$a59_lo", [C236, C237], ["$a59.lo"]>;
def B119 : XBR<119, "$a59_hi", [C238, C239], ["$a59.hi"]>;
def B120 : XBR<120, "$a60_lo", [C240, C241], ["$a60.lo"]>;
def B121 : XBR<121, "$a60_hi", [C242, C243], ["$a60.hi"]>;
def B122 : XBR<122, "$a61_lo", [C244, C245], ["$a61.lo"]>;
def B123 : XBR<123, "$a61_hi", [C246, C247], ["$a61.hi"]>;
def B124 : XBR<124, "$a62_lo", [C248, C249], ["$a62.lo"]>;
def B125 : XBR<125, "$a62_hi", [C250, C251], ["$a62.hi"]>;
def B126 : XBR<126, "$a63_lo", [C252, C253], ["$a63.lo"]>;
def B127 : XBR<127, "$a63_hi", [C254, C255], ["$a63.hi"]>;


// Extension Vector Registers
def A0  : XVR< 0,  "$a0", [  C0,   C1,   C2,   C3]>;
def A1  : XVR< 1,  "$a1", [  C4,   C5,   C6,   C7]>;
def A2  : XVR< 2,  "$a2", [  C8,   C9,  C10,  C11]>;
def A3  : XVR< 3,  "$a3", [ C12,  C13,  C14,  C15]>;
def A4  : XVR< 4,  "$a4", [ C16,  C17,  C18,  C19]>;
def A5  : XVR< 5,  "$a5", [ C20,  C21,  C22,  C23]>;
def A6  : XVR< 6,  "$a6", [ C24,  C25,  C26,  C27]>;
def A7  : XVR< 7,  "$a7", [ C28,  C29,  C30,  C31]>;
def A8  : XVR< 8,  "$a8", [ C32,  C33,  C34,  C35]>;
def A9  : XVR< 9,  "$a9", [ C36,  C37,  C38,  C39]>;
def A10 : XVR<10, "$a10", [ C40,  C41,  C42,  C43]>;
def A11 : XVR<11, "$a11", [ C44,  C45,  C46,  C47]>;
def A12 : XVR<12, "$a12", [ C48,  C49,  C50,  C51]>;
def A13 : XVR<13, "$a13", [ C52,  C53,  C54,  C55]>;
def A14 : XVR<14, "$a14", [ C56,  C57,  C58,  C59]>;
def A15 : XVR<15, "$a15", [ C60,  C61,  C62,  C63]>;
def A16 : XVR<16, "$a16", [ C64,  C65,  C66,  C67]>;
def A17 : XVR<17, "$a17", [ C68,  C69,  C70,  C71]>;
def A18 : XVR<18, "$a18", [ C72,  C73,  C74,  C75]>;
def A19 : XVR<19, "$a19", [ C76,  C77,  C78,  C79]>;
def A20 : XVR<20, "$a20", [ C80,  C81,  C82,  C83]>;
def A21 : XVR<21, "$a21", [ C84,  C85,  C86,  C87]>;
def A22 : XVR<22, "$a22", [ C88,  C89,  C90,  C91]>;
def A23 : XVR<23, "$a23", [ C92,  C93,  C94,  C95]>;
def A24 : XVR<24, "$a24", [ C96,  C97,  C98,  C99]>;
def A25 : XVR<25, "$a25", [C100, C101, C102, C103]>;
def A26 : XVR<26, "$a26", [C104, C105, C106, C107]>;
def A27 : XVR<27, "$a27", [C108, C109, C110, C111]>;
def A28 : XVR<28, "$a28", [C112, C113, C114, C115]>;
def A29 : XVR<29, "$a29", [C116, C117, C118, C119]>;
def A30 : XVR<30, "$a30", [C120, C121, C122, C123]>;
def A31 : XVR<31, "$a31", [C124, C125, C126, C127]>;
def A32 : XVR<32, "$a32", [C128, C129, C130, C131]>;
def A33 : XVR<33, "$a33", [C132, C133, C134, C135]>;
def A34 : XVR<34, "$a34", [C136, C137, C138, C139]>;
def A35 : XVR<35, "$a35", [C140, C141, C142, C143]>;
def A36 : XVR<36, "$a36", [C144, C145, C146, C147]>;
def A37 : XVR<37, "$a37", [C148, C149, C150, C151]>;
def A38 : XVR<38, "$a38", [C152, C153, C154, C155]>;
def A39 : XVR<39, "$a39", [C156, C157, C158, C159]>;
def A40 : XVR<40, "$a40", [C160, C161, C162, C163]>;
def A41 : XVR<41, "$a41", [C164, C165, C166, C167]>;
def A42 : XVR<42, "$a42", [C168, C169, C170, C171]>;
def A43 : XVR<43, "$a43", [C172, C173, C174, C175]>;
def A44 : XVR<44, "$a44", [C176, C177, C178, C179]>;
def A45 : XVR<45, "$a45", [C180, C181, C182, C183]>;
def A46 : XVR<46, "$a46", [C184, C185, C186, C187]>;
def A47 : XVR<47, "$a47", [C188, C189, C190, C191]>;
def A48 : XVR<48, "$a48", [C192, C193, C194, C195]>;
def A49 : XVR<49, "$a49", [C196, C197, C198, C199]>;
def A50 : XVR<50, "$a50", [C200, C201, C202, C203]>;
def A51 : XVR<51, "$a51", [C204, C205, C206, C207]>;
def A52 : XVR<52, "$a52", [C208, C209, C210, C211]>;
def A53 : XVR<53, "$a53", [C212, C213, C214, C215]>;
def A54 : XVR<54, "$a54", [C216, C217, C218, C219]>;
def A55 : XVR<55, "$a55", [C220, C221, C222, C223]>;
def A56 : XVR<56, "$a56", [C224, C225, C226, C227]>;
def A57 : XVR<57, "$a57", [C228, C229, C230, C231]>;
def A58 : XVR<58, "$a58", [C232, C233, C234, C235]>;
def A59 : XVR<59, "$a59", [C236, C237, C238, C239]>;
def A60 : XVR<60, "$a60", [C240, C241, C242, C243]>;
def A61 : XVR<61, "$a61", [C244, C245, C246, C247]>;
def A62 : XVR<62, "$a62", [C248, C249, C250, C251]>;
def A63 : XVR<63, "$a63", [C252, C253, C254, C255]>;


// Extension Wide Registers
def W0  : XWR< 0,   "$a0a1", [  C0,   C1,   C2,   C3,   C4,   C5,   C6,   C7]>;
def W1  : XWR< 1,   "$a2a3", [  C8,   C9,  C10,  C11,  C12,  C13,  C14,  C15]>;
def W2  : XWR< 2,   "$a4a5", [ C16,  C17,  C18,  C19,  C20,  C21,  C22,  C23]>;
def W3  : XWR< 3,   "$a6a7", [ C24,  C25,  C26,  C27,  C28,  C29,  C30,  C31]>;
def W4  : XWR< 4,   "$a8a9", [ C32,  C33,  C34,  C35,  C36,  C37,  C38,  C39]>;
def W5  : XWR< 5, "$a10a11", [ C40,  C41,  C42,  C43,  C44,  C45,  C46,  C47]>;
def W6  : XWR< 6, "$a12a13", [ C48,  C49,  C50,  C51,  C52,  C53,  C54,  C55]>;
def W7  : XWR< 7, "$a14a15", [ C56,  C57,  C58,  C59,  C60,  C61,  C62,  C63]>;
def W8  : XWR< 8, "$a16a17", [ C64,  C65,  C66,  C67,  C68,  C69,  C70,  C71]>;
def W9  : XWR< 9, "$a18a19", [ C72,  C73,  C74,  C75,  C76,  C77,  C78,  C79]>;
def W10 : XWR<10, "$a20a21", [ C80,  C81,  C82,  C83,  C84,  C85,  C86,  C87]>;
def W11 : XWR<11, "$a22a23", [ C88,  C89,  C90,  C91,  C92,  C93,  C94,  C95]>;
def W12 : XWR<12, "$a24a25", [ C96,  C97,  C98,  C99, C100, C101, C102, C103]>;
def W13 : XWR<13, "$a26a27", [C104, C105, C106, C107, C108, C109, C110, C111]>;
def W14 : XWR<14, "$a28a29", [C112, C113, C114, C115, C116, C117, C118, C119]>;
def W15 : XWR<15, "$a30a31", [C120, C121, C122, C123, C124, C125, C126, C127]>;
def W16 : XWR<16, "$a32a33", [C128, C129, C130, C131, C132, C133, C134, C135]>;
def W17 : XWR<17, "$a34a35", [C136, C137, C138, C139, C140, C141, C142, C143]>;
def W18 : XWR<18, "$a36a37", [C144, C145, C146, C147, C148, C149, C150, C151]>;
def W19 : XWR<19, "$a38a39", [C152, C153, C154, C155, C156, C157, C158, C159]>;
def W20 : XWR<20, "$a40a41", [C160, C161, C162, C163, C164, C165, C166, C167]>;
def W21 : XWR<21, "$a42a43", [C168, C169, C170, C171, C172, C173, C174, C175]>;
def W22 : XWR<22, "$a44a45", [C176, C177, C178, C179, C180, C181, C182, C183]>;
def W23 : XWR<23, "$a46a47", [C184, C185, C186, C187, C188, C189, C190, C191]>;
def W24 : XWR<24, "$a48a49", [C192, C193, C194, C195, C196, C197, C198, C199]>;
def W25 : XWR<25, "$a50a51", [C200, C201, C202, C203, C204, C205, C206, C207]>;
def W26 : XWR<26, "$a52a53", [C208, C209, C210, C211, C212, C213, C214, C215]>;
def W27 : XWR<27, "$a54a55", [C216, C217, C218, C219, C220, C221, C222, C223]>;
def W28 : XWR<28, "$a56a57", [C224, C225, C226, C227, C228, C229, C230, C231]>;
def W29 : XWR<29, "$a58a59", [C232, C233, C234, C235, C236, C237, C238, C239]>;
def W30 : XWR<30, "$a60a61", [C240, C241, C242, C243, C244, C245, C246, C247]>;
def W31 : XWR<31, "$a62a63", [C248, C249, C250, C251, C252, C253, C254, C255]>;


// Extension Matrix Registers
def X0  : XMR< 0,     "$a0a1a2a3", [  C0,   C1,   C2,   C3,   C4,   C5,   C6,   C7,   C8,   C9,  C10,  C11,  C12,  C13,  C14,  C15]>;
def X1  : XMR< 1,     "$a4a5a6a7", [ C16,  C17,  C18,  C19,  C20,  C21,  C22,  C23,  C24,  C25,  C26,  C27,  C28,  C29,  C30,  C31]>;
def X2  : XMR< 2,   "$a8a9a10a11", [ C32,  C33,  C34,  C35,  C36,  C37,  C38,  C39,  C40,  C41,  C42,  C43,  C44,  C45,  C46,  C47]>;
def X3  : XMR< 3, "$a12a13a14a15", [ C48,  C49,  C50,  C51,  C52,  C53,  C54,  C55,  C56,  C57,  C58,  C59,  C60,  C61,  C62,  C63]>;
def X4  : XMR< 4, "$a16a17a18a19", [ C64,  C65,  C66,  C67,  C68,  C69,  C70,  C71,  C72,  C73,  C74,  C75,  C76,  C77,  C78,  C79]>;
def X5  : XMR< 5, "$a20a21a22a23", [ C80,  C81,  C82,  C83,  C84,  C85,  C86,  C87,  C88,  C89,  C90,  C91,  C92,  C93,  C94,  C95]>;
def X6  : XMR< 6, "$a24a25a26a27", [ C96,  C97,  C98,  C99, C100, C101, C102, C103, C104, C105, C106, C107, C108, C109, C110, C111]>;
def X7  : XMR< 7, "$a28a29a30a31", [C112, C113, C114, C115, C116, C117, C118, C119, C120, C121, C122, C123, C124, C125, C126, C127]>;
def X8  : XMR< 8, "$a32a33a34a35", [C128, C129, C130, C131, C132, C133, C134, C135, C136, C137, C138, C139, C140, C141, C142, C143]>;
def X9  : XMR< 9, "$a36a37a38a39", [C144, C145, C146, C147, C148, C149, C150, C151, C152, C153, C154, C155, C156, C157, C158, C159]>;
def X10 : XMR<10, "$a40a41a42a43", [C160, C161, C162, C163, C164, C165, C166, C167, C168, C169, C170, C171, C172, C173, C174, C175]>;
def X11 : XMR<11, "$a44a45a46a47", [C176, C177, C178, C179, C180, C181, C182, C183, C184, C185, C186, C187, C188, C189, C190, C191]>;
def X12 : XMR<12, "$a48a49a50a51", [C192, C193, C194, C195, C196, C197, C198, C199, C200, C201, C202, C203, C204, C205, C206, C207]>;
def X13 : XMR<13, "$a52a53a54a55", [C208, C209, C210, C211, C212, C213, C214, C215, C216, C217, C218, C219, C220, C221, C222, C223]>;
def X14 : XMR<14, "$a56a57a58a59", [C224, C225, C226, C227, C228, C229, C230, C231, C232, C233, C234, C235, C236, C237, C238, C239]>;
def X15 : XMR<15, "$a60a61a62a63", [C240, C241, C242, C243, C244, C245, C246, C247, C248, C249, C250, C251, C252, C253, C254, C255]>;


} // let Namespace = "KVX"


// SFR - System Function Registers
let Size = 64 in
def SystemReg : RegisterClass<"KVX",
  [i32, i64],
  64, (add
        PC,      PS,     PCR,      RA,      CS,    CSIT,   AESPC,      LS,
        LE,      LC,     IPE,     MEN,     PMC,     PM0,     PM1,     PM2,
       PM3,    PMSA,     TCR,     T0V,     T1V,     T0R,     T1R,     WDV,
       WDR,     ILE,     ILL,     ILR,     MMC,     TEL,     TEH,   RES31,
       SYO,     HTO,     ITO,      DO,      MO,     PSO,   RES38,   RES39,
        DC,    DBA0,    DBA1,    DWA0,    DWA1,     MES,      WS,   RES47,
     RES48,   RES49,   RES50,   RES51,   RES52,   RES53,   RES54,   RES55,
     RES56,   RES57,   RES58,   RES59,   RES60,   RES61,   RES62,   RES63,
   SPC_PL0, SPC_PL1, SPC_PL2, SPC_PL3, SPS_PL0, SPS_PL1, SPS_PL2, SPS_PL3,
    EA_PL0,  EA_PL1,  EA_PL2,  EA_PL3,  EV_PL0,  EV_PL1,  EV_PL2,  EV_PL3,
    SR_PL0,  SR_PL1,  SR_PL2,  SR_PL3,  ES_PL0,  ES_PL1,  ES_PL2,  ES_PL3,
     RES88,   RES89,   RES90,   RES91,   RES92,   RES93,   RES94,   RES95,
      SYOW,    HTOW,    ITOW,     DOW,     MOW,    PSOW,  RES102,  RES103,
    RES104,  RES105,  RES106,  RES107,  RES108,  RES109,  RES110,  RES111,
    RES112,  RES113,  RES114,  RES115,  RES116,  RES117,  RES118,  RES119,
    RES120,  RES121,  RES122,  RES123,  RES124,  RES125,  RES126,  RES127,
       SPC,  RES129,  RES130,  RES131,     SPS,  RES133,  RES134,  RES135,
        EA,  RES137,  RES138,  RES139,      EV,  RES141,  RES142,  RES143,
        SR,  RES145,  RES146,  RES147,      ES,  RES149,  RES150,  RES151,
    RES152,  RES153,  RES154,  RES155,  RES156,  RES157,  RES158,  RES159,
    RES160,  RES161,  RES162,  RES163,  RES164,  RES165,  RES166,  RES167,
    RES168,  RES169,  RES170,  RES171,  RES172,  RES173,  RES174,  RES175,
    RES176,  RES177,  RES178,  RES179,  RES180,  RES181,  RES182,  RES183,
    RES184,  RES185,  RES186,  RES187,  RES188,  RES189,  RES190,  RES191,
    RES192,  RES193,  RES194,  RES195,  RES196,  RES197,  RES198,  RES199,
    RES200,  RES201,  RES202,  RES203,  RES204,  RES205,  RES206,  RES207,
    RES208,  RES209,  RES210,  RES211,  RES212,  RES213,  RES214,  RES215,
    RES216,  RES217,  RES218,  RES219,  RES220,  RES221,  RES222,  RES223,
    RES224,  RES225,  RES226,  RES227,  RES228,  RES229,  RES230,  RES231,
    RES232,  RES233,  RES234,  RES235,  RES236,  RES237,  RES238,  RES239,
    RES240,  RES241,  RES242,  RES243,  RES244,  RES245,  RES246,  RES247,
    RES248,  RES249,  RES250,  RES251,  RES252,  RES253,  RES254,  RES255,
     VSFR0,   VSFR1,   VSFR2,   VSFR3,   VSFR4,   VSFR5,   VSFR6,   VSFR7,
     VSFR8,   VSFR9,  VSFR10,  VSFR11,  VSFR12,  VSFR13,  VSFR14,  VSFR15,
    VSFR16,  VSFR17,  VSFR18,  VSFR19,  VSFR20,  VSFR21,  VSFR22,  VSFR23,
    VSFR24,  VSFR25,  VSFR26,  VSFR27,  VSFR28,  VSFR29,  VSFR30,  VSFR31,
    VSFR32,  VSFR33,  VSFR34,  VSFR35,  VSFR36,  VSFR37,  VSFR38,  VSFR39,
    VSFR40,  VSFR41,  VSFR42,  VSFR43,  VSFR44,  VSFR45,  VSFR46,  VSFR47,
    VSFR48,  VSFR49,  VSFR50,  VSFR51,  VSFR52,  VSFR53,  VSFR54,  VSFR55,
    VSFR56,  VSFR57,  VSFR58,  VSFR59,  VSFR60,  VSFR61,  VSFR62,  VSFR63,
    VSFR64,  VSFR65,  VSFR66,  VSFR67,  VSFR68,  VSFR69,  VSFR70,  VSFR71,
    VSFR72,  VSFR73,  VSFR74,  VSFR75,  VSFR76,  VSFR77,  VSFR78,  VSFR79,
    VSFR80,  VSFR81,  VSFR82,  VSFR83,  VSFR84,  VSFR85,  VSFR86,  VSFR87,
    VSFR88,  VSFR89,  VSFR90,  VSFR91,  VSFR92,  VSFR93,  VSFR94,  VSFR95,
    VSFR96,  VSFR97,  VSFR98,  VSFR99, VSFR100, VSFR101, VSFR102, VSFR103,
   VSFR104, VSFR105, VSFR106, VSFR107, VSFR108, VSFR109, VSFR110, VSFR111,
   VSFR112, VSFR113, VSFR114, VSFR115, VSFR116, VSFR117, VSFR118, VSFR119,
   VSFR120, VSFR121, VSFR122, VSFR123, VSFR124, VSFR125, VSFR126, VSFR127,
   VSFR128, VSFR129, VSFR130, VSFR131, VSFR132, VSFR133, VSFR134, VSFR135,
   VSFR136, VSFR137, VSFR138, VSFR139, VSFR140, VSFR141, VSFR142, VSFR143,
   VSFR144, VSFR145, VSFR146, VSFR147, VSFR148, VSFR149, VSFR150, VSFR151,
   VSFR152, VSFR153, VSFR154, VSFR155, VSFR156, VSFR157, VSFR158, VSFR159,
   VSFR160, VSFR161, VSFR162, VSFR163, VSFR164, VSFR165, VSFR166, VSFR167,
   VSFR168, VSFR169, VSFR170, VSFR171, VSFR172, VSFR173, VSFR174, VSFR175,
   VSFR176, VSFR177, VSFR178, VSFR179, VSFR180, VSFR181, VSFR182, VSFR183,
   VSFR184, VSFR185, VSFR186, VSFR187, VSFR188, VSFR189, VSFR190, VSFR191,
   VSFR192, VSFR193, VSFR194, VSFR195, VSFR196, VSFR197, VSFR198, VSFR199,
   VSFR200, VSFR201, VSFR202, VSFR203, VSFR204, VSFR205, VSFR206, VSFR207,
   VSFR208, VSFR209, VSFR210, VSFR211, VSFR212, VSFR213, VSFR214, VSFR215,
   VSFR216, VSFR217, VSFR218, VSFR219, VSFR220, VSFR221, VSFR222, VSFR223,
   VSFR224, VSFR225, VSFR226, VSFR227, VSFR228, VSFR229, VSFR230, VSFR231,
   VSFR232, VSFR233, VSFR234, VSFR235, VSFR236, VSFR237, VSFR238, VSFR239,
   VSFR240, VSFR241, VSFR242, VSFR243, VSFR244, VSFR245, VSFR246, VSFR247,
   VSFR248, VSFR249, VSFR250, VSFR251, VSFR252, VSFR253, VSFR254, VSFR255)>;

// GPR - General-Purpose Registers
let Size = 64 in
def SingleReg : RegisterClass<"KVX",
  [i64, i1, i8, i16, i32, f16, f32, f64, v8i8, v4i16, v2i16, v2i32, v4f16, v2f16, v2f32],
  64, (add
    R0,  R1,  R2,  R3,  R4,  R5,  R6,  R7,  R8,  R9, R10, R11, R12, R13, R14,
   R15, R16, R17, R18, R19, R20, R21, R22, R23, R24, R25, R26, R27, R28, R29,
   R30, R31, R32, R33, R34, R35, R36, R37, R38, R39, R40, R41, R42, R43, R44,
   R45, R46, R47, R48, R49, R50, R51, R52, R53, R54, R55, R56, R57, R58, R59,
   R60, R61, R62, R63)>;

// PGR - Paired General Registers
let Size = 128 in
def PairedReg : RegisterClass<"KVX",
  [v4i32, v2i64, v4f32, v2f64],
  128, (add
    P0,  P2,  P4,  P6,  P8, P10, P12, P14, P16, P18, P20, P22, P24, P26, P28,
   P30, P32, P34, P36, P38, P40, P42, P44, P46, P48, P50, P52, P54, P56, P58,
   P60, P62)>;

// QGR - Quadruple General Registers
let Size = 256 in
def QuadReg : RegisterClass<"KVX",
  [v4i64, v4f64],
  256, (add
    Q0,  Q4,  Q8, Q12, Q16, Q20, Q24, Q28, Q32, Q36, Q40, Q44, Q48, Q52, Q56,
   Q60)>;

// XCR - Extension Coprocessor Registers
let Size = 64 in
def CoproReg : RegisterClass<"KVX",
  [i64],
  64, (add
     C0,   C1,   C2,   C3,   C4,   C5,   C6,   C7,   C8,   C9,  C10,  C11,
    C12,  C13,  C14,  C15,  C16,  C17,  C18,  C19,  C20,  C21,  C22,  C23,
    C24,  C25,  C26,  C27,  C28,  C29,  C30,  C31,  C32,  C33,  C34,  C35,
    C36,  C37,  C38,  C39,  C40,  C41,  C42,  C43,  C44,  C45,  C46,  C47,
    C48,  C49,  C50,  C51,  C52,  C53,  C54,  C55,  C56,  C57,  C58,  C59,
    C60,  C61,  C62,  C63,  C64,  C65,  C66,  C67,  C68,  C69,  C70,  C71,
    C72,  C73,  C74,  C75,  C76,  C77,  C78,  C79,  C80,  C81,  C82,  C83,
    C84,  C85,  C86,  C87,  C88,  C89,  C90,  C91,  C92,  C93,  C94,  C95,
    C96,  C97,  C98,  C99, C100, C101, C102, C103, C104, C105, C106, C107,
   C108, C109, C110, C111, C112, C113, C114, C115, C116, C117, C118, C119,
   C120, C121, C122, C123, C124, C125, C126, C127, C128, C129, C130, C131,
   C132, C133, C134, C135, C136, C137, C138, C139, C140, C141, C142, C143,
   C144, C145, C146, C147, C148, C149, C150, C151, C152, C153, C154, C155,
   C156, C157, C158, C159, C160, C161, C162, C163, C164, C165, C166, C167,
   C168, C169, C170, C171, C172, C173, C174, C175, C176, C177, C178, C179,
   C180, C181, C182, C183, C184, C185, C186, C187, C188, C189, C190, C191,
   C192, C193, C194, C195, C196, C197, C198, C199, C200, C201, C202, C203,
   C204, C205, C206, C207, C208, C209, C210, C211, C212, C213, C214, C215,
   C216, C217, C218, C219, C220, C221, C222, C223, C224, C225, C226, C227,
   C228, C229, C230, C231, C232, C233, C234, C235, C236, C237, C238, C239,
   C240, C241, C242, C243, C244, C245, C246, C247, C248, C249, C250, C251,
   C252, C253, C254, C255)>;

// XBR - Extension Block Registers
let Size = 128 in
def BlockReg : RegisterClass<"KVX",
  [v2i64],
  128, (add
     B0,   B1,   B2,   B3,   B4,   B5,   B6,   B7,   B8,   B9,  B10,  B11,
    B12,  B13,  B14,  B15,  B16,  B17,  B18,  B19,  B20,  B21,  B22,  B23,
    B24,  B25,  B26,  B27,  B28,  B29,  B30,  B31,  B32,  B33,  B34,  B35,
    B36,  B37,  B38,  B39,  B40,  B41,  B42,  B43,  B44,  B45,  B46,  B47,
    B48,  B49,  B50,  B51,  B52,  B53,  B54,  B55,  B56,  B57,  B58,  B59,
    B60,  B61,  B62,  B63,  B64,  B65,  B66,  B67,  B68,  B69,  B70,  B71,
    B72,  B73,  B74,  B75,  B76,  B77,  B78,  B79,  B80,  B81,  B82,  B83,
    B84,  B85,  B86,  B87,  B88,  B89,  B90,  B91,  B92,  B93,  B94,  B95,
    B96,  B97,  B98,  B99, B100, B101, B102, B103, B104, B105, B106, B107,
   B108, B109, B110, B111, B112, B113, B114, B115, B116, B117, B118, B119,
   B120, B121, B122, B123, B124, B125, B126, B127)>;

// XVR - Extension Vector Registers
let Size = 256 in
def VectorReg : RegisterClass<"KVX",
  [v4i64],
  256, (add
    A0,  A1,  A2,  A3,  A4,  A5,  A6,  A7,  A8,  A9, A10, A11, A12, A13, A14,
   A15, A16, A17, A18, A19, A20, A21, A22, A23, A24, A25, A26, A27, A28, A29,
   A30, A31, A32, A33, A34, A35, A36, A37, A38, A39, A40, A41, A42, A43, A44,
   A45, A46, A47, A48, A49, A50, A51, A52, A53, A54, A55, A56, A57, A58, A59,
   A60, A61, A62, A63)>;

// XWR - Extension Wide Registers
let Size = 512 in
def WideReg : RegisterClass<"KVX",
  [v8i64],
  512, (add
    W0,  W1,  W2,  W3,  W4,  W5,  W6,  W7,  W8,  W9, W10, W11, W12, W13, W14,
   W15, W16, W17, W18, W19, W20, W21, W22, W23, W24, W25, W26, W27, W28, W29,
   W30, W31)>;

// XMR - Extension Matrix Registers
let Size = 1024 in
def MatrixReg : RegisterClass<"KVX",
  [v16i64],
  1024, (add
    X0,  X1,  X2,  X3,  X4,  X5,  X6,  X7,  X8,  X9, X10, X11, X12, X13, X14,
   X15)>;

// SFR - RegClas Implying Alone in Bundle
let Size = 64 in
def AloneReg : RegisterClass<"KVX",
  [i32, i64],
  64, (add
        PS,     MMC, SPS_PL0, SPS_PL1, SPS_PL2, SPS_PL3,    SYOW,    HTOW,
      ITOW,     DOW,     MOW,    PSOW,     SPS)>;

// SFR - Singleton RegClas with RA
let Size = 64 in
def OnlyraReg : RegisterClass<"KVX",
  [i32, i64],
  64, (add
   RA)>;

// SFR - Only GET System Registers
let Size = 64 in
def OnlygetReg : RegisterClass<"KVX",
  [i32, i64],
  64, (add
        PC,      PS,     PCR,      RA,      CS,    CSIT,   AESPC,      LS,
        LE,      LC,     IPE,     MEN,     PMC,     PM0,     PM1,     PM2,
       PM3,    PMSA,     TCR,     T0V,     T1V,     T0R,     T1R,     WDV,
       WDR,     ILE,     ILL,     ILR,     MMC,     TEL,     TEH,     SYO,
       HTO,     ITO,      DO,      MO,     PSO,      DC,    DBA0,    DBA1,
      DWA0,    DWA1,     MES,      WS, SPC_PL0, SPC_PL1, SPC_PL2, SPC_PL3,
   SPS_PL0, SPS_PL1, SPS_PL2, SPS_PL3,  EA_PL0,  EA_PL1,  EA_PL2,  EA_PL3,
    EV_PL0,  EV_PL1,  EV_PL2,  EV_PL3,  SR_PL0,  SR_PL1,  SR_PL2,  SR_PL3,
    ES_PL0,  ES_PL1,  ES_PL2,  ES_PL3,     SPC,     SPS,      EA,      EV,
        SR,      ES,   VSFR0,   VSFR1,   VSFR2,   VSFR3,   VSFR4,   VSFR5,
     VSFR6,   VSFR7,   VSFR8,   VSFR9,  VSFR10,  VSFR11,  VSFR12,  VSFR13,
    VSFR14,  VSFR15,  VSFR16,  VSFR17,  VSFR18,  VSFR19,  VSFR20,  VSFR21,
    VSFR22,  VSFR23,  VSFR24,  VSFR25,  VSFR26,  VSFR27,  VSFR28,  VSFR29,
    VSFR30,  VSFR31,  VSFR32,  VSFR33,  VSFR34,  VSFR35,  VSFR36,  VSFR37,
    VSFR38,  VSFR39,  VSFR40,  VSFR41,  VSFR42,  VSFR43,  VSFR44,  VSFR45,
    VSFR46,  VSFR47,  VSFR48,  VSFR49,  VSFR50,  VSFR51,  VSFR52,  VSFR53,
    VSFR54,  VSFR55,  VSFR56,  VSFR57,  VSFR58,  VSFR59,  VSFR60,  VSFR61,
    VSFR62,  VSFR63,  VSFR64,  VSFR65,  VSFR66,  VSFR67,  VSFR68,  VSFR69,
    VSFR70,  VSFR71,  VSFR72,  VSFR73,  VSFR74,  VSFR75,  VSFR76,  VSFR77,
    VSFR78,  VSFR79,  VSFR80,  VSFR81,  VSFR82,  VSFR83,  VSFR84,  VSFR85,
    VSFR86,  VSFR87,  VSFR88,  VSFR89,  VSFR90,  VSFR91,  VSFR92,  VSFR93,
    VSFR94,  VSFR95,  VSFR96,  VSFR97,  VSFR98,  VSFR99, VSFR100, VSFR101,
   VSFR102, VSFR103, VSFR104, VSFR105, VSFR106, VSFR107, VSFR108, VSFR109,
   VSFR110, VSFR111, VSFR112, VSFR113, VSFR114, VSFR115, VSFR116, VSFR117,
   VSFR118, VSFR119, VSFR120, VSFR121, VSFR122, VSFR123, VSFR124, VSFR125,
   VSFR126, VSFR127, VSFR128, VSFR129, VSFR130, VSFR131, VSFR132, VSFR133,
   VSFR134, VSFR135, VSFR136, VSFR137, VSFR138, VSFR139, VSFR140, VSFR141,
   VSFR142, VSFR143, VSFR144, VSFR145, VSFR146, VSFR147, VSFR148, VSFR149,
   VSFR150, VSFR151, VSFR152, VSFR153, VSFR154, VSFR155, VSFR156, VSFR157,
   VSFR158, VSFR159, VSFR160, VSFR161, VSFR162, VSFR163, VSFR164, VSFR165,
   VSFR166, VSFR167, VSFR168, VSFR169, VSFR170, VSFR171, VSFR172, VSFR173,
   VSFR174, VSFR175, VSFR176, VSFR177, VSFR178, VSFR179, VSFR180, VSFR181,
   VSFR182, VSFR183, VSFR184, VSFR185, VSFR186, VSFR187, VSFR188, VSFR189,
   VSFR190, VSFR191, VSFR192, VSFR193, VSFR194, VSFR195, VSFR196, VSFR197,
   VSFR198, VSFR199, VSFR200, VSFR201, VSFR202, VSFR203, VSFR204, VSFR205,
   VSFR206, VSFR207, VSFR208, VSFR209, VSFR210, VSFR211, VSFR212, VSFR213,
   VSFR214, VSFR215, VSFR216, VSFR217, VSFR218, VSFR219, VSFR220, VSFR221,
   VSFR222, VSFR223, VSFR224, VSFR225, VSFR226, VSFR227, VSFR228, VSFR229,
   VSFR230, VSFR231, VSFR232, VSFR233, VSFR234, VSFR235, VSFR236, VSFR237,
   VSFR238, VSFR239, VSFR240, VSFR241, VSFR242, VSFR243, VSFR244, VSFR245,
   VSFR246, VSFR247, VSFR248, VSFR249, VSFR250, VSFR251, VSFR252, VSFR253,
   VSFR254, VSFR255)>;

// SFR - Only SET System Registers without PS
let Size = 64 in
def OnlysetReg : RegisterClass<"KVX",
  [i32, i64],
  64, (add
        PS,     PCR,      RA,      CS,    CSIT,   AESPC,      LS,      LE,
        LC,     IPE,     MEN,     PMC,     PM0,     PM1,     PM2,     PM3,
      PMSA,     TCR,     T0V,     T1V,     T0R,     T1R,     WDV,     WDR,
       ILE,     ILL,     ILR,     MMC,     TEL,     TEH,      DC,    DBA0,
      DBA1,    DWA0,    DWA1,     MES,      WS, SPC_PL0, SPC_PL1, SPC_PL2,
   SPC_PL3, SPS_PL0, SPS_PL1, SPS_PL2, SPS_PL3,  EA_PL0,  EA_PL1,  EA_PL2,
    EA_PL3,  EV_PL0,  EV_PL1,  EV_PL2,  EV_PL3,  SR_PL0,  SR_PL1,  SR_PL2,
    SR_PL3,  ES_PL0,  ES_PL1,  ES_PL2,  ES_PL3,     SPC,     SPS,      EA,
        EV,      SR,      ES,   VSFR0,   VSFR1,   VSFR2,   VSFR3,   VSFR4,
     VSFR5,   VSFR6,   VSFR7,   VSFR8,   VSFR9,  VSFR10,  VSFR11,  VSFR12,
    VSFR13,  VSFR14,  VSFR15,  VSFR16,  VSFR17,  VSFR18,  VSFR19,  VSFR20,
    VSFR21,  VSFR22,  VSFR23,  VSFR24,  VSFR25,  VSFR26,  VSFR27,  VSFR28,
    VSFR29,  VSFR30,  VSFR31,  VSFR32,  VSFR33,  VSFR34,  VSFR35,  VSFR36,
    VSFR37,  VSFR38,  VSFR39,  VSFR40,  VSFR41,  VSFR42,  VSFR43,  VSFR44,
    VSFR45,  VSFR46,  VSFR47,  VSFR48,  VSFR49,  VSFR50,  VSFR51,  VSFR52,
    VSFR53,  VSFR54,  VSFR55,  VSFR56,  VSFR57,  VSFR58,  VSFR59,  VSFR60,
    VSFR61,  VSFR62,  VSFR63,  VSFR64,  VSFR65,  VSFR66,  VSFR67,  VSFR68,
    VSFR69,  VSFR70,  VSFR71,  VSFR72,  VSFR73,  VSFR74,  VSFR75,  VSFR76,
    VSFR77,  VSFR78,  VSFR79,  VSFR80,  VSFR81,  VSFR82,  VSFR83,  VSFR84,
    VSFR85,  VSFR86,  VSFR87,  VSFR88,  VSFR89,  VSFR90,  VSFR91,  VSFR92,
    VSFR93,  VSFR94,  VSFR95,  VSFR96,  VSFR97,  VSFR98,  VSFR99, VSFR100,
   VSFR101, VSFR102, VSFR103, VSFR104, VSFR105, VSFR106, VSFR107, VSFR108,
   VSFR109, VSFR110, VSFR111, VSFR112, VSFR113, VSFR114, VSFR115, VSFR116,
   VSFR117, VSFR118, VSFR119, VSFR120, VSFR121, VSFR122, VSFR123, VSFR124,
   VSFR125, VSFR126, VSFR127, VSFR128, VSFR129, VSFR130, VSFR131, VSFR132,
   VSFR133, VSFR134, VSFR135, VSFR136, VSFR137, VSFR138, VSFR139, VSFR140,
   VSFR141, VSFR142, VSFR143, VSFR144, VSFR145, VSFR146, VSFR147, VSFR148,
   VSFR149, VSFR150, VSFR151, VSFR152, VSFR153, VSFR154, VSFR155, VSFR156,
   VSFR157, VSFR158, VSFR159, VSFR160, VSFR161, VSFR162, VSFR163, VSFR164,
   VSFR165, VSFR166, VSFR167, VSFR168, VSFR169, VSFR170, VSFR171, VSFR172,
   VSFR173, VSFR174, VSFR175, VSFR176, VSFR177, VSFR178, VSFR179, VSFR180,
   VSFR181, VSFR182, VSFR183, VSFR184, VSFR185, VSFR186, VSFR187, VSFR188,
   VSFR189, VSFR190, VSFR191, VSFR192, VSFR193, VSFR194, VSFR195, VSFR196,
   VSFR197, VSFR198, VSFR199, VSFR200, VSFR201, VSFR202, VSFR203, VSFR204,
   VSFR205, VSFR206, VSFR207, VSFR208, VSFR209, VSFR210, VSFR211, VSFR212,
   VSFR213, VSFR214, VSFR215, VSFR216, VSFR217, VSFR218, VSFR219, VSFR220,
   VSFR221, VSFR222, VSFR223, VSFR224, VSFR225, VSFR226, VSFR227, VSFR228,
   VSFR229, VSFR230, VSFR231, VSFR232, VSFR233, VSFR234, VSFR235, VSFR236,
   VSFR237, VSFR238, VSFR239, VSFR240, VSFR241, VSFR242, VSFR243, VSFR244,
   VSFR245, VSFR246, VSFR247, VSFR248, VSFR249, VSFR250, VSFR251, VSFR252,
   VSFR253, VSFR254, VSFR255)>;

// SFR - Only FX System Registers without PS
let Size = 64 in
def OnlyfxReg : RegisterClass<"KVX",
  [i32, i64],
  64, (add
       PCR,      CS,    CSIT,     IPE,     MEN,     PMC,     TCR,     ILE,
       ILL,     ILR,     MMC,     TEL,     TEH,      DC,     MES,      WS,
   SPS_PL0, SPS_PL1, SPS_PL2, SPS_PL3,  ES_PL0,  ES_PL1,  ES_PL2,  ES_PL3,
       SPS,      ES)>;

// SFR - Only SWAP System Registers without PS
let Size = 64 in
def OnlyswapReg : RegisterClass<"KVX",
  [i32, i64],
  64, (add
        PC,     PCR,      RA,      CS,    CSIT,   AESPC,      LS,      LE,
        LC,     IPE,     MEN,     PMC,     PM0,     PM1,     PM2,     PM3,
      PMSA,     TCR,     T0V,     T1V,     T0R,     T1R,     WDV,     WDR,
       ILE,     ILL,     ILR,     MMC,     TEL,     TEH,   RES31,     SYO,
       HTO,     ITO,      DO,      MO,     PSO,   RES38,   RES39,      DC,
      DBA0,    DBA1,    DWA0,    DWA1,     MES,      WS,   RES47,   RES48,
     RES49,   RES50,   RES51,   RES52,   RES53,   RES54,   RES55,   RES56,
     RES57,   RES58,   RES59,   RES60,   RES61,   RES62,   RES63, SPC_PL0,
   SPC_PL1, SPC_PL2, SPC_PL3, SPS_PL0, SPS_PL1, SPS_PL2, SPS_PL3,  EA_PL0,
    EA_PL1,  EA_PL2,  EA_PL3,  EV_PL0,  EV_PL1,  EV_PL2,  EV_PL3,  SR_PL0,
    SR_PL1,  SR_PL2,  SR_PL3,  ES_PL0,  ES_PL1,  ES_PL2,  ES_PL3,   RES88,
     RES89,   RES90,   RES91,   RES92,   RES93,   RES94,   RES95,    SYOW,
      HTOW,    ITOW,     DOW,     MOW,    PSOW,  RES102,  RES103,  RES104,
    RES105,  RES106,  RES107,  RES108,  RES109,  RES110,  RES111,  RES112,
    RES113,  RES114,  RES115,  RES116,  RES117,  RES118,  RES119,  RES120,
    RES121,  RES122,  RES123,  RES124,  RES125,  RES126,  RES127,     SPC,
    RES129,  RES130,  RES131,     SPS,  RES133,  RES134,  RES135,      EA,
    RES137,  RES138,  RES139,      EV,  RES141,  RES142,  RES143,      SR,
    RES145,  RES146,  RES147,      ES,  RES149,  RES150,  RES151,  RES152,
    RES153,  RES154,  RES155,  RES156,  RES157,  RES158,  RES159,  RES160,
    RES161,  RES162,  RES163,  RES164,  RES165,  RES166,  RES167,  RES168,
    RES169,  RES170,  RES171,  RES172,  RES173,  RES174,  RES175,  RES176,
    RES177,  RES178,  RES179,  RES180,  RES181,  RES182,  RES183,  RES184,
    RES185,  RES186,  RES187,  RES188,  RES189,  RES190,  RES191,  RES192,
    RES193,  RES194,  RES195,  RES196,  RES197,  RES198,  RES199,  RES200,
    RES201,  RES202,  RES203,  RES204,  RES205,  RES206,  RES207,  RES208,
    RES209,  RES210,  RES211,  RES212,  RES213,  RES214,  RES215,  RES216,
    RES217,  RES218,  RES219,  RES220,  RES221,  RES222,  RES223,  RES224,
    RES225,  RES226,  RES227,  RES228,  RES229,  RES230,  RES231,  RES232,
    RES233,  RES234,  RES235,  RES236,  RES237,  RES238,  RES239,  RES240,
    RES241,  RES242,  RES243,  RES244,  RES245,  RES246,  RES247,  RES248,
    RES249,  RES250,  RES251,  RES252,  RES253,  RES254,  RES255,   VSFR0,
     VSFR1,   VSFR2,   VSFR3,   VSFR4,   VSFR5,   VSFR6,   VSFR7,   VSFR8,
     VSFR9,  VSFR10,  VSFR11,  VSFR12,  VSFR13,  VSFR14,  VSFR15,  VSFR16,
    VSFR17,  VSFR18,  VSFR19,  VSFR20,  VSFR21,  VSFR22,  VSFR23,  VSFR24,
    VSFR25,  VSFR26,  VSFR27,  VSFR28,  VSFR29,  VSFR30,  VSFR31,  VSFR32,
    VSFR33,  VSFR34,  VSFR35,  VSFR36,  VSFR37,  VSFR38,  VSFR39,  VSFR40,
    VSFR41,  VSFR42,  VSFR43,  VSFR44,  VSFR45,  VSFR46,  VSFR47,  VSFR48,
    VSFR49,  VSFR50,  VSFR51,  VSFR52,  VSFR53,  VSFR54,  VSFR55,  VSFR56,
    VSFR57,  VSFR58,  VSFR59,  VSFR60,  VSFR61,  VSFR62,  VSFR63,  VSFR64,
    VSFR65,  VSFR66,  VSFR67,  VSFR68,  VSFR69,  VSFR70,  VSFR71,  VSFR72,
    VSFR73,  VSFR74,  VSFR75,  VSFR76,  VSFR77,  VSFR78,  VSFR79,  VSFR80,
    VSFR81,  VSFR82,  VSFR83,  VSFR84,  VSFR85,  VSFR86,  VSFR87,  VSFR88,
    VSFR89,  VSFR90,  VSFR91,  VSFR92,  VSFR93,  VSFR94,  VSFR95,  VSFR96,
    VSFR97,  VSFR98,  VSFR99, VSFR100, VSFR101, VSFR102, VSFR103, VSFR104,
   VSFR105, VSFR106, VSFR107, VSFR108, VSFR109, VSFR110, VSFR111, VSFR112,
   VSFR113, VSFR114, VSFR115, VSFR116, VSFR117, VSFR118, VSFR119, VSFR120,
   VSFR121, VSFR122, VSFR123, VSFR124, VSFR125, VSFR126, VSFR127, VSFR128,
   VSFR129, VSFR130, VSFR131, VSFR132, VSFR133, VSFR134, VSFR135, VSFR136,
   VSFR137, VSFR138, VSFR139, VSFR140, VSFR141, VSFR142, VSFR143, VSFR144,
   VSFR145, VSFR146, VSFR147, VSFR148, VSFR149, VSFR150, VSFR151, VSFR152,
   VSFR153, VSFR154, VSFR155, VSFR156, VSFR157, VSFR158, VSFR159, VSFR160,
   VSFR161, VSFR162, VSFR163, VSFR164, VSFR165, VSFR166, VSFR167, VSFR168,
   VSFR169, VSFR170, VSFR171, VSFR172, VSFR173, VSFR174, VSFR175, VSFR176,
   VSFR177, VSFR178, VSFR179, VSFR180, VSFR181, VSFR182, VSFR183, VSFR184,
   VSFR185, VSFR186, VSFR187, VSFR188, VSFR189, VSFR190, VSFR191, VSFR192,
   VSFR193, VSFR194, VSFR195, VSFR196, VSFR197, VSFR198, VSFR199, VSFR200,
   VSFR201, VSFR202, VSFR203, VSFR204, VSFR205, VSFR206, VSFR207, VSFR208,
   VSFR209, VSFR210, VSFR211, VSFR212, VSFR213, VSFR214, VSFR215, VSFR216,
   VSFR217, VSFR218, VSFR219, VSFR220, VSFR221, VSFR222, VSFR223, VSFR224,
   VSFR225, VSFR226, VSFR227, VSFR228, VSFR229, VSFR230, VSFR231, VSFR232,
   VSFR233, VSFR234, VSFR235, VSFR236, VSFR237, VSFR238, VSFR239, VSFR240,
   VSFR241, VSFR242, VSFR243, VSFR244, VSFR245, VSFR246, VSFR247, VSFR248,
   VSFR249, VSFR250, VSFR251, VSFR252, VSFR253, VSFR254, VSFR255)>;

// XVR - Accelerator Registers Even Numbered
let Size = 256 in
def VectorRegE : RegisterClass<"KVX",
  [v4i64],
  256, (add
    A0,  A2,  A4,  A6,  A8, A10, A12, A14, A16, A18, A20, A22, A24, A26, A28,
   A30, A32, A34, A36, A38, A40, A42, A44, A46, A48, A50, A52, A54, A56, A58,
   A60, A62)>;

// XVR - Accelerator Registers Odd Numbered
let Size = 256 in
def VectorRegO : RegisterClass<"KVX",
  [v4i64],
  256, (add
    A1,  A3,  A5,  A7,  A9, A11, A13, A15, A17, A19, A21, A23, A25, A27, A29,
   A31, A33, A35, A37, A39, A41, A43, A45, A47, A49, A51, A53, A55, A57, A59,
   A61, A63)>;

// XBR - Block Registers Even Numbered
let Size = 128 in
def BlockRegE : RegisterClass<"KVX",
  [v2i64],
  128, (add
     B0,   B2,   B4,   B6,   B8,  B10,  B12,  B14,  B16,  B18,  B20,  B22,
    B24,  B26,  B28,  B30,  B32,  B34,  B36,  B38,  B40,  B42,  B44,  B46,
    B48,  B50,  B52,  B54,  B56,  B58,  B60,  B62,  B64,  B66,  B68,  B70,
    B72,  B74,  B76,  B78,  B80,  B82,  B84,  B86,  B88,  B90,  B92,  B94,
    B96,  B98, B100, B102, B104, B106, B108, B110, B112, B114, B116, B118,
   B120, B122, B124, B126)>;

// XBR - Block Registers Odd Numbered
let Size = 128 in
def BlockRegO : RegisterClass<"KVX",
  [v2i64],
  128, (add
     B1,   B3,   B5,   B7,   B9,  B11,  B13,  B15,  B17,  B19,  B21,  B23,
    B25,  B27,  B29,  B31,  B33,  B35,  B37,  B39,  B41,  B43,  B45,  B47,
    B49,  B51,  B53,  B55,  B57,  B59,  B61,  B63,  B65,  B67,  B69,  B71,
    B73,  B75,  B77,  B79,  B81,  B83,  B85,  B87,  B89,  B91,  B93,  B95,
    B97,  B99, B101, B103, B105, B107, B109, B111, B113, B115, B117, B119,
   B121, B123, B125, B127)>;

// XBR - Block Registers 0 Modulo 4
let Size = 128 in
def BlockReg0M4 : RegisterClass<"KVX",
  [v2i64],
  128, (add
     B0,   B4,   B8,  B12,  B16,  B20,  B24,  B28,  B32,  B36,  B40,  B44,
    B48,  B52,  B56,  B60,  B64,  B68,  B72,  B76,  B80,  B84,  B88,  B92,
    B96, B100, B104, B108, B112, B116, B120, B124)>;

// XBR - Block Registers 1 Modulo 4
let Size = 128 in
def BlockReg1M4 : RegisterClass<"KVX",
  [v2i64],
  128, (add
     B1,   B5,   B9,  B13,  B17,  B21,  B25,  B29,  B33,  B37,  B41,  B45,
    B49,  B53,  B57,  B61,  B65,  B69,  B73,  B77,  B81,  B85,  B89,  B93,
    B97, B101, B105, B109, B113, B117, B121, B125)>;

// XBR - Block Registers 2 Modulo 4
let Size = 128 in
def BlockReg2M4 : RegisterClass<"KVX",
  [v2i64],
  128, (add
     B2,   B6,  B10,  B14,  B18,  B22,  B26,  B30,  B34,  B38,  B42,  B46,
    B50,  B54,  B58,  B62,  B66,  B70,  B74,  B78,  B82,  B86,  B90,  B94,
    B98, B102, B106, B110, B114, B118, B122, B126)>;

// XBR - Block Registers 3 Modulo 4
let Size = 128 in
def BlockReg3M4 : RegisterClass<"KVX",
  [v2i64],
  128, (add
     B3,   B7,  B11,  B15,  B19,  B23,  B27,  B31,  B35,  B39,  B43,  B47,
    B51,  B55,  B59,  B63,  B67,  B71,  B75,  B79,  B83,  B87,  B91,  B95,
    B99, B103, B107, B111, B115, B119, B123, B127)>;

// XCR - Coprocessor Registers 0 Modulo 4
let Size = 64 in
def CoproReg0M4 : RegisterClass<"KVX",
  [i64],
  64, (add
     C0,   C4,   C8,  C12,  C16,  C20,  C24,  C28,  C32,  C36,  C40,  C44,
    C48,  C52,  C56,  C60,  C64,  C68,  C72,  C76,  C80,  C84,  C88,  C92,
    C96, C100, C104, C108, C112, C116, C120, C124, C128, C132, C136, C140,
   C144, C148, C152, C156, C160, C164, C168, C172, C176, C180, C184, C188,
   C192, C196, C200, C204, C208, C212, C216, C220, C224, C228, C232, C236,
   C240, C244, C248, C252)>;

// XCR - Coprocessor Registers 1 Modulo 4
let Size = 64 in
def CoproReg1M4 : RegisterClass<"KVX",
  [i64],
  64, (add
     C1,   C5,   C9,  C13,  C17,  C21,  C25,  C29,  C33,  C37,  C41,  C45,
    C49,  C53,  C57,  C61,  C65,  C69,  C73,  C77,  C81,  C85,  C89,  C93,
    C97, C101, C105, C109, C113, C117, C121, C125, C129, C133, C137, C141,
   C145, C149, C153, C157, C161, C165, C169, C173, C177, C181, C185, C189,
   C193, C197, C201, C205, C209, C213, C217, C221, C225, C229, C233, C237,
   C241, C245, C249, C253)>;

// XCR - Coprocessor Registers 2 Modulo 4
let Size = 64 in
def CoproReg2M4 : RegisterClass<"KVX",
  [i64],
  64, (add
     C2,   C6,  C10,  C14,  C18,  C22,  C26,  C30,  C34,  C38,  C42,  C46,
    C50,  C54,  C58,  C62,  C66,  C70,  C74,  C78,  C82,  C86,  C90,  C94,
    C98, C102, C106, C110, C114, C118, C122, C126, C130, C134, C138, C142,
   C146, C150, C154, C158, C162, C166, C170, C174, C178, C182, C186, C190,
   C194, C198, C202, C206, C210, C214, C218, C222, C226, C230, C234, C238,
   C242, C246, C250, C254)>;

// XCR - Coprocessor Registers 3 Modulo 4
let Size = 64 in
def CoproReg3M4 : RegisterClass<"KVX",
  [i64],
  64, (add
     C3,   C7,  C11,  C15,  C19,  C23,  C27,  C31,  C35,  C39,  C43,  C47,
    C51,  C55,  C59,  C63,  C67,  C71,  C75,  C79,  C83,  C87,  C91,  C95,
    C99, C103, C107, C111, C115, C119, C123, C127, C131, C135, C139, C143,
   C147, C151, C155, C159, C163, C167, C171, C175, C179, C183, C187, C191,
   C195, C199, C203, C207, C211, C215, C219, C223, C227, C231, C235, C239,
   C243, C247, C251, C255)>;
