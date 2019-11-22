//===-- K1CRegisterInfo.td - K1C Register defs -------------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
//  Declarations that describe the K1C register file
//===----------------------------------------------------------------------===//

// This file was automatically generated,
//   *DO NOT EDIT*,
//   please contact code owner.
// Last generated: 2019-08-28 14:17:37.866250.


let Namespace = "K1C" in {

// K1C Register base class:
//   - K1CRegister
//   - K1CRegisterWithSubRegs
// Registers are identified with 9-bit ID numbers.
// Registers with sub-registers are always covered by them.

class K1CRegister<bits<9> num, string n, list<string> alt = []>
      : Register<n, alt> {
  let HWEncoding{8-0} = num;
}

class K1CRegisterWithSubRegs<bits<9> num, string n,
                             list<Register> subregs, list<string> alt = []>
      : RegisterWithSubRegs<n, subregs> {
  let HWEncoding{8-0} = num;
  let CoveredBySubRegs = 1;
  list<string> AltNames = alt;
}


// SRF - System Register File
class SRF<bits<9> num, string n, list<string> alt = []>
      : K1CRegister<num, n, alt>;

// GRF - General Register File
class GRF<bits<9> num, string n, list<string> alt = []>
      : K1CRegister<num, n, alt>;

// PRF - Paired Register File
class PRF<bits<9> num, string n, list<Register> subregs>
      : K1CRegisterWithSubRegs<num, n, subregs> {
  let SubRegIndices = [SubRegIndex<64,   0>, SubRegIndex<64,  64>];
}

// QRF - Quadruple Register File
class QRF<bits<9> num, string n, list<Register> subregs>
      : K1CRegisterWithSubRegs<num, n, subregs> {
  let SubRegIndices = [SubRegIndex<64,   0>, SubRegIndex<64,  64>,
                       SubRegIndex<64, 128>, SubRegIndex<64, 192>];
}

// CRF - Coprocessor Register File
class CRF<bits<9> num, string n, list<string> alt = []>
      : K1CRegister<num, n, alt>;

// BRF - Block Register File
class BRF<bits<9> num, string n, list<Register> subregs, list<string> alt = []>
      : K1CRegisterWithSubRegs<num, n, subregs, alt> {
  let SubRegIndices = [SubRegIndex<64,   0>, SubRegIndex<64,  64>];
}

// ARF - Accelerator Register File
class ARF<bits<9> num, string n, list<Register> subregs>
      : K1CRegisterWithSubRegs<num, n, subregs> {
  let SubRegIndices = [SubRegIndex<64,   0>, SubRegIndex<64,  64>,
                       SubRegIndex<64, 128>, SubRegIndex<64, 192>];
}

// WRF - Wide Register File
class WRF<bits<9> num, string n, list<Register> subregs>
      : K1CRegisterWithSubRegs<num, n, subregs> {
  let SubRegIndices = [SubRegIndex<64,   0>, SubRegIndex<64,  64>,
                       SubRegIndex<64, 128>, SubRegIndex<64, 192>,
                       SubRegIndex<64, 256>, SubRegIndex<64, 320>,
                       SubRegIndex<64, 384>, SubRegIndex<64, 448>];
}

// XRF - Extended Register File
class XRF<bits<9> num, string n, list<Register> subregs>
      : K1CRegisterWithSubRegs<num, n, subregs> {
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
def PC      : SRF<  0,      "$pc",   ["$s0"]>, DwarfRegNum<[ 64]>;
def PS      : SRF<  1,      "$ps",   ["$s1"]>, DwarfRegNum<[ 65]>;
def PCR     : SRF<  2,     "$pcr",   ["$s2"]>, DwarfRegNum<[ 66]>;
def RA      : SRF<  3,      "$ra",   ["$s3"]>, DwarfRegNum<[ 67]>;
def CS      : SRF<  4,      "$cs",   ["$s4"]>, DwarfRegNum<[ 68]>;
def CSIT    : SRF<  5,    "$csit",   ["$s5"]>, DwarfRegNum<[ 69]>;
def AESPC   : SRF<  6,   "$aespc",   ["$s6"]>, DwarfRegNum<[ 70]>;
def LS      : SRF<  7,      "$ls",   ["$s7"]>, DwarfRegNum<[ 71]>;
def LE      : SRF<  8,      "$le",   ["$s8"]>, DwarfRegNum<[ 72]>;
def LC      : SRF<  9,      "$lc",   ["$s9"]>, DwarfRegNum<[ 73]>;
def IPE     : SRF< 10,     "$ipe",  ["$s10"]>, DwarfRegNum<[ 74]>;
def MEN     : SRF< 11,     "$men",  ["$s11"]>, DwarfRegNum<[ 75]>;
def PMC     : SRF< 12,     "$pmc",  ["$s12"]>, DwarfRegNum<[ 76]>;
def PM0     : SRF< 13,     "$pm0",  ["$s13"]>, DwarfRegNum<[ 77]>;
def PM1     : SRF< 14,     "$pm1",  ["$s14"]>, DwarfRegNum<[ 78]>;
def PM2     : SRF< 15,     "$pm2",  ["$s15"]>, DwarfRegNum<[ 79]>;
def PM3     : SRF< 16,     "$pm3",  ["$s16"]>, DwarfRegNum<[ 80]>;
def PMSA    : SRF< 17,    "$pmsa",  ["$s17"]>, DwarfRegNum<[ 81]>;
def TCR     : SRF< 18,     "$tcr",  ["$s18"]>, DwarfRegNum<[ 82]>;
def T0V     : SRF< 19,     "$t0v",  ["$s19"]>, DwarfRegNum<[ 83]>;
def T1V     : SRF< 20,     "$t1v",  ["$s20"]>, DwarfRegNum<[ 84]>;
def T0R     : SRF< 21,     "$t0r",  ["$s21"]>, DwarfRegNum<[ 85]>;
def T1R     : SRF< 22,     "$t1r",  ["$s22"]>, DwarfRegNum<[ 86]>;
def WDV     : SRF< 23,     "$wdv",  ["$s23"]>, DwarfRegNum<[ 87]>;
def WDR     : SRF< 24,     "$wdr",  ["$s24"]>, DwarfRegNum<[ 88]>;
def ILE     : SRF< 25,     "$ile",  ["$s25"]>, DwarfRegNum<[ 89]>;
def ILL     : SRF< 26,     "$ill",  ["$s26"]>, DwarfRegNum<[ 90]>;
def ILR     : SRF< 27,     "$ilr",  ["$s27"]>, DwarfRegNum<[ 91]>;
def MMC     : SRF< 28,     "$mmc",  ["$s28"]>, DwarfRegNum<[ 92]>;
def TEL     : SRF< 29,     "$tel",  ["$s29"]>, DwarfRegNum<[ 93]>;
def TEH     : SRF< 30,     "$teh",  ["$s30"]>, DwarfRegNum<[ 94]>;
def RES31   : SRF< 31,   "$res31",  ["$s31"]>, DwarfRegNum<[ 95]>;
def SYO     : SRF< 32,     "$syo",  ["$s32"]>, DwarfRegNum<[ 96]>;
def HTO     : SRF< 33,     "$hto",  ["$s33"]>, DwarfRegNum<[ 97]>;
def ITO     : SRF< 34,     "$ito",  ["$s34"]>, DwarfRegNum<[ 98]>;
def DO      : SRF< 35,      "$do",  ["$s35"]>, DwarfRegNum<[ 99]>;
def MO      : SRF< 36,      "$mo",  ["$s36"]>, DwarfRegNum<[100]>;
def PSO     : SRF< 37,     "$pso",  ["$s37"]>, DwarfRegNum<[101]>;
def RES38   : SRF< 38,   "$res38",  ["$s38"]>, DwarfRegNum<[102]>;
def RES39   : SRF< 39,   "$res39",  ["$s39"]>, DwarfRegNum<[103]>;
def DC      : SRF< 40,      "$dc",  ["$s40"]>, DwarfRegNum<[104]>;
def DBA0    : SRF< 41,    "$dba0",  ["$s41"]>, DwarfRegNum<[105]>;
def DBA1    : SRF< 42,    "$dba1",  ["$s42"]>, DwarfRegNum<[106]>;
def DWA0    : SRF< 43,    "$dwa0",  ["$s43"]>, DwarfRegNum<[107]>;
def DWA1    : SRF< 44,    "$dwa1",  ["$s44"]>, DwarfRegNum<[108]>;
def MES     : SRF< 45,     "$mes",  ["$s45"]>, DwarfRegNum<[109]>;
def WS      : SRF< 46,      "$ws",  ["$s46"]>, DwarfRegNum<[110]>;
def RES47   : SRF< 47,   "$res47",  ["$s47"]>, DwarfRegNum<[111]>;
def RES48   : SRF< 48,   "$res48",  ["$s48"]>, DwarfRegNum<[112]>;
def RES49   : SRF< 49,   "$res49",  ["$s49"]>, DwarfRegNum<[113]>;
def RES50   : SRF< 50,   "$res50",  ["$s50"]>, DwarfRegNum<[114]>;
def RES51   : SRF< 51,   "$res51",  ["$s51"]>, DwarfRegNum<[115]>;
def RES52   : SRF< 52,   "$res52",  ["$s52"]>, DwarfRegNum<[116]>;
def RES53   : SRF< 53,   "$res53",  ["$s53"]>, DwarfRegNum<[117]>;
def RES54   : SRF< 54,   "$res54",  ["$s54"]>, DwarfRegNum<[118]>;
def RES55   : SRF< 55,   "$res55",  ["$s55"]>, DwarfRegNum<[119]>;
def RES56   : SRF< 56,   "$res56",  ["$s56"]>, DwarfRegNum<[120]>;
def RES57   : SRF< 57,   "$res57",  ["$s57"]>, DwarfRegNum<[121]>;
def RES58   : SRF< 58,   "$res58",  ["$s58"]>, DwarfRegNum<[122]>;
def RES59   : SRF< 59,   "$res59",  ["$s59"]>, DwarfRegNum<[123]>;
def RES60   : SRF< 60,   "$res60",  ["$s60"]>, DwarfRegNum<[124]>;
def RES61   : SRF< 61,   "$res61",  ["$s61"]>, DwarfRegNum<[125]>;
def RES62   : SRF< 62,   "$res62",  ["$s62"]>, DwarfRegNum<[126]>;
def RES63   : SRF< 63,   "$res63",  ["$s63"]>, DwarfRegNum<[127]>;
def SPC_PL0 : SRF< 64, "$spc_pl0",  ["$s64"]>, DwarfRegNum<[128]>;
def SPC_PL1 : SRF< 65, "$spc_pl1",  ["$s65"]>, DwarfRegNum<[129]>;
def SPC_PL2 : SRF< 66, "$spc_pl2",  ["$s66"]>, DwarfRegNum<[130]>;
def SPC_PL3 : SRF< 67, "$spc_pl3",  ["$s67"]>, DwarfRegNum<[131]>;
def SPS_PL0 : SRF< 68, "$sps_pl0",  ["$s68"]>, DwarfRegNum<[132]>;
def SPS_PL1 : SRF< 69, "$sps_pl1",  ["$s69"]>, DwarfRegNum<[133]>;
def SPS_PL2 : SRF< 70, "$sps_pl2",  ["$s70"]>, DwarfRegNum<[134]>;
def SPS_PL3 : SRF< 71, "$sps_pl3",  ["$s71"]>, DwarfRegNum<[135]>;
def EA_PL0  : SRF< 72,  "$ea_pl0",  ["$s72"]>, DwarfRegNum<[136]>;
def EA_PL1  : SRF< 73,  "$ea_pl1",  ["$s73"]>, DwarfRegNum<[137]>;
def EA_PL2  : SRF< 74,  "$ea_pl2",  ["$s74"]>, DwarfRegNum<[138]>;
def EA_PL3  : SRF< 75,  "$ea_pl3",  ["$s75"]>, DwarfRegNum<[139]>;
def EV_PL0  : SRF< 76,  "$ev_pl0",  ["$s76"]>, DwarfRegNum<[140]>;
def EV_PL1  : SRF< 77,  "$ev_pl1",  ["$s77"]>, DwarfRegNum<[141]>;
def EV_PL2  : SRF< 78,  "$ev_pl2",  ["$s78"]>, DwarfRegNum<[142]>;
def EV_PL3  : SRF< 79,  "$ev_pl3",  ["$s79"]>, DwarfRegNum<[143]>;
def SR_PL0  : SRF< 80,  "$sr_pl0",  ["$s80"]>, DwarfRegNum<[144]>;
def SR_PL1  : SRF< 81,  "$sr_pl1",  ["$s81"]>, DwarfRegNum<[145]>;
def SR_PL2  : SRF< 82,  "$sr_pl2",  ["$s82"]>, DwarfRegNum<[146]>;
def SR_PL3  : SRF< 83,  "$sr_pl3",  ["$s83"]>, DwarfRegNum<[147]>;
def ES_PL0  : SRF< 84,  "$es_pl0",  ["$s84"]>, DwarfRegNum<[148]>;
def ES_PL1  : SRF< 85,  "$es_pl1",  ["$s85"]>, DwarfRegNum<[149]>;
def ES_PL2  : SRF< 86,  "$es_pl2",  ["$s86"]>, DwarfRegNum<[150]>;
def ES_PL3  : SRF< 87,  "$es_pl3",  ["$s87"]>, DwarfRegNum<[151]>;
def RES88   : SRF< 88,   "$res88",  ["$s88"]>, DwarfRegNum<[152]>;
def RES89   : SRF< 89,   "$res89",  ["$s89"]>, DwarfRegNum<[153]>;
def RES90   : SRF< 90,   "$res90",  ["$s90"]>, DwarfRegNum<[154]>;
def RES91   : SRF< 91,   "$res91",  ["$s91"]>, DwarfRegNum<[155]>;
def RES92   : SRF< 92,   "$res92",  ["$s92"]>, DwarfRegNum<[156]>;
def RES93   : SRF< 93,   "$res93",  ["$s93"]>, DwarfRegNum<[157]>;
def RES94   : SRF< 94,   "$res94",  ["$s94"]>, DwarfRegNum<[158]>;
def RES95   : SRF< 95,   "$res95",  ["$s95"]>, DwarfRegNum<[159]>;
def SYOW    : SRF< 96,    "$syow",  ["$s96"]>, DwarfRegNum<[160]>;
def HTOW    : SRF< 97,    "$htow",  ["$s97"]>, DwarfRegNum<[161]>;
def ITOW    : SRF< 98,    "$itow",  ["$s98"]>, DwarfRegNum<[162]>;
def DOW     : SRF< 99,     "$dow",  ["$s99"]>, DwarfRegNum<[163]>;
def MOW     : SRF<100,     "$mow", ["$s100"]>, DwarfRegNum<[164]>;
def PSOW    : SRF<101,    "$psow", ["$s101"]>, DwarfRegNum<[165]>;
def RES102  : SRF<102,  "$res102", ["$s102"]>, DwarfRegNum<[166]>;
def RES103  : SRF<103,  "$res103", ["$s103"]>, DwarfRegNum<[167]>;
def RES104  : SRF<104,  "$res104", ["$s104"]>, DwarfRegNum<[168]>;
def RES105  : SRF<105,  "$res105", ["$s105"]>, DwarfRegNum<[169]>;
def RES106  : SRF<106,  "$res106", ["$s106"]>, DwarfRegNum<[170]>;
def RES107  : SRF<107,  "$res107", ["$s107"]>, DwarfRegNum<[171]>;
def RES108  : SRF<108,  "$res108", ["$s108"]>, DwarfRegNum<[172]>;
def RES109  : SRF<109,  "$res109", ["$s109"]>, DwarfRegNum<[173]>;
def RES110  : SRF<110,  "$res110", ["$s110"]>, DwarfRegNum<[174]>;
def RES111  : SRF<111,  "$res111", ["$s111"]>, DwarfRegNum<[175]>;
def RES112  : SRF<112,  "$res112", ["$s112"]>, DwarfRegNum<[176]>;
def RES113  : SRF<113,  "$res113", ["$s113"]>, DwarfRegNum<[177]>;
def RES114  : SRF<114,  "$res114", ["$s114"]>, DwarfRegNum<[178]>;
def RES115  : SRF<115,  "$res115", ["$s115"]>, DwarfRegNum<[179]>;
def RES116  : SRF<116,  "$res116", ["$s116"]>, DwarfRegNum<[180]>;
def RES117  : SRF<117,  "$res117", ["$s117"]>, DwarfRegNum<[181]>;
def RES118  : SRF<118,  "$res118", ["$s118"]>, DwarfRegNum<[182]>;
def RES119  : SRF<119,  "$res119", ["$s119"]>, DwarfRegNum<[183]>;
def RES120  : SRF<120,  "$res120", ["$s120"]>, DwarfRegNum<[184]>;
def RES121  : SRF<121,  "$res121", ["$s121"]>, DwarfRegNum<[185]>;
def RES122  : SRF<122,  "$res122", ["$s122"]>, DwarfRegNum<[186]>;
def RES123  : SRF<123,  "$res123", ["$s123"]>, DwarfRegNum<[187]>;
def RES124  : SRF<124,  "$res124", ["$s124"]>, DwarfRegNum<[188]>;
def RES125  : SRF<125,  "$res125", ["$s125"]>, DwarfRegNum<[189]>;
def RES126  : SRF<126,  "$res126", ["$s126"]>, DwarfRegNum<[190]>;
def RES127  : SRF<127,  "$res127", ["$s127"]>, DwarfRegNum<[191]>;
def SPC     : SRF<128,     "$spc", ["$s128"]>, DwarfRegNum<[192]>;
def RES129  : SRF<129,  "$res129", ["$s129"]>, DwarfRegNum<[193]>;
def RES130  : SRF<130,  "$res130", ["$s130"]>, DwarfRegNum<[194]>;
def RES131  : SRF<131,  "$res131", ["$s131"]>, DwarfRegNum<[195]>;
def SPS     : SRF<132,     "$sps", ["$s132"]>, DwarfRegNum<[196]>;
def RES133  : SRF<133,  "$res133", ["$s133"]>, DwarfRegNum<[197]>;
def RES134  : SRF<134,  "$res134", ["$s134"]>, DwarfRegNum<[198]>;
def RES135  : SRF<135,  "$res135", ["$s135"]>, DwarfRegNum<[199]>;
def EA      : SRF<136,      "$ea", ["$s136"]>, DwarfRegNum<[200]>;
def RES137  : SRF<137,  "$res137", ["$s137"]>, DwarfRegNum<[201]>;
def RES138  : SRF<138,  "$res138", ["$s138"]>, DwarfRegNum<[202]>;
def RES139  : SRF<139,  "$res139", ["$s139"]>, DwarfRegNum<[203]>;
def EV      : SRF<140,      "$ev", ["$s140"]>, DwarfRegNum<[204]>;
def RES141  : SRF<141,  "$res141", ["$s141"]>, DwarfRegNum<[205]>;
def RES142  : SRF<142,  "$res142", ["$s142"]>, DwarfRegNum<[206]>;
def RES143  : SRF<143,  "$res143", ["$s143"]>, DwarfRegNum<[207]>;
def SR      : SRF<144,      "$sr", ["$s144"]>, DwarfRegNum<[208]>;
def RES145  : SRF<145,  "$res145", ["$s145"]>, DwarfRegNum<[209]>;
def RES146  : SRF<146,  "$res146", ["$s146"]>, DwarfRegNum<[210]>;
def RES147  : SRF<147,  "$res147", ["$s147"]>, DwarfRegNum<[211]>;
def ES      : SRF<148,      "$es", ["$s148"]>, DwarfRegNum<[212]>;
def RES149  : SRF<149,  "$res149", ["$s149"]>, DwarfRegNum<[213]>;
def RES150  : SRF<150,  "$res150", ["$s150"]>, DwarfRegNum<[214]>;
def RES151  : SRF<151,  "$res151", ["$s151"]>, DwarfRegNum<[215]>;
def RES152  : SRF<152,  "$res152", ["$s152"]>, DwarfRegNum<[216]>;
def RES153  : SRF<153,  "$res153", ["$s153"]>, DwarfRegNum<[217]>;
def RES154  : SRF<154,  "$res154", ["$s154"]>, DwarfRegNum<[218]>;
def RES155  : SRF<155,  "$res155", ["$s155"]>, DwarfRegNum<[219]>;
def RES156  : SRF<156,  "$res156", ["$s156"]>, DwarfRegNum<[220]>;
def RES157  : SRF<157,  "$res157", ["$s157"]>, DwarfRegNum<[221]>;
def RES158  : SRF<158,  "$res158", ["$s158"]>, DwarfRegNum<[222]>;
def RES159  : SRF<159,  "$res159", ["$s159"]>, DwarfRegNum<[223]>;
def RES160  : SRF<160,  "$res160", ["$s160"]>, DwarfRegNum<[224]>;
def RES161  : SRF<161,  "$res161", ["$s161"]>, DwarfRegNum<[225]>;
def RES162  : SRF<162,  "$res162", ["$s162"]>, DwarfRegNum<[226]>;
def RES163  : SRF<163,  "$res163", ["$s163"]>, DwarfRegNum<[227]>;
def RES164  : SRF<164,  "$res164", ["$s164"]>, DwarfRegNum<[228]>;
def RES165  : SRF<165,  "$res165", ["$s165"]>, DwarfRegNum<[229]>;
def RES166  : SRF<166,  "$res166", ["$s166"]>, DwarfRegNum<[230]>;
def RES167  : SRF<167,  "$res167", ["$s167"]>, DwarfRegNum<[231]>;
def RES168  : SRF<168,  "$res168", ["$s168"]>, DwarfRegNum<[232]>;
def RES169  : SRF<169,  "$res169", ["$s169"]>, DwarfRegNum<[233]>;
def RES170  : SRF<170,  "$res170", ["$s170"]>, DwarfRegNum<[234]>;
def RES171  : SRF<171,  "$res171", ["$s171"]>, DwarfRegNum<[235]>;
def RES172  : SRF<172,  "$res172", ["$s172"]>, DwarfRegNum<[236]>;
def RES173  : SRF<173,  "$res173", ["$s173"]>, DwarfRegNum<[237]>;
def RES174  : SRF<174,  "$res174", ["$s174"]>, DwarfRegNum<[238]>;
def RES175  : SRF<175,  "$res175", ["$s175"]>, DwarfRegNum<[239]>;
def RES176  : SRF<176,  "$res176", ["$s176"]>, DwarfRegNum<[240]>;
def RES177  : SRF<177,  "$res177", ["$s177"]>, DwarfRegNum<[241]>;
def RES178  : SRF<178,  "$res178", ["$s178"]>, DwarfRegNum<[242]>;
def RES179  : SRF<179,  "$res179", ["$s179"]>, DwarfRegNum<[243]>;
def RES180  : SRF<180,  "$res180", ["$s180"]>, DwarfRegNum<[244]>;
def RES181  : SRF<181,  "$res181", ["$s181"]>, DwarfRegNum<[245]>;
def RES182  : SRF<182,  "$res182", ["$s182"]>, DwarfRegNum<[246]>;
def RES183  : SRF<183,  "$res183", ["$s183"]>, DwarfRegNum<[247]>;
def RES184  : SRF<184,  "$res184", ["$s184"]>, DwarfRegNum<[248]>;
def RES185  : SRF<185,  "$res185", ["$s185"]>, DwarfRegNum<[249]>;
def RES186  : SRF<186,  "$res186", ["$s186"]>, DwarfRegNum<[250]>;
def RES187  : SRF<187,  "$res187", ["$s187"]>, DwarfRegNum<[251]>;
def RES188  : SRF<188,  "$res188", ["$s188"]>, DwarfRegNum<[252]>;
def RES189  : SRF<189,  "$res189", ["$s189"]>, DwarfRegNum<[253]>;
def RES190  : SRF<190,  "$res190", ["$s190"]>, DwarfRegNum<[254]>;
def RES191  : SRF<191,  "$res191", ["$s191"]>, DwarfRegNum<[255]>;
def RES192  : SRF<192,  "$res192", ["$s192"]>;
def RES193  : SRF<193,  "$res193", ["$s193"]>;
def RES194  : SRF<194,  "$res194", ["$s194"]>;
def RES195  : SRF<195,  "$res195", ["$s195"]>;
def RES196  : SRF<196,  "$res196", ["$s196"]>;
def RES197  : SRF<197,  "$res197", ["$s197"]>;
def RES198  : SRF<198,  "$res198", ["$s198"]>;
def RES199  : SRF<199,  "$res199", ["$s199"]>;
def RES200  : SRF<200,  "$res200", ["$s200"]>;
def RES201  : SRF<201,  "$res201", ["$s201"]>;
def RES202  : SRF<202,  "$res202", ["$s202"]>;
def RES203  : SRF<203,  "$res203", ["$s203"]>;
def RES204  : SRF<204,  "$res204", ["$s204"]>;
def RES205  : SRF<205,  "$res205", ["$s205"]>;
def RES206  : SRF<206,  "$res206", ["$s206"]>;
def RES207  : SRF<207,  "$res207", ["$s207"]>;
def RES208  : SRF<208,  "$res208", ["$s208"]>;
def RES209  : SRF<209,  "$res209", ["$s209"]>;
def RES210  : SRF<210,  "$res210", ["$s210"]>;
def RES211  : SRF<211,  "$res211", ["$s211"]>;
def RES212  : SRF<212,  "$res212", ["$s212"]>;
def RES213  : SRF<213,  "$res213", ["$s213"]>;
def RES214  : SRF<214,  "$res214", ["$s214"]>;
def RES215  : SRF<215,  "$res215", ["$s215"]>;
def RES216  : SRF<216,  "$res216", ["$s216"]>;
def RES217  : SRF<217,  "$res217", ["$s217"]>;
def RES218  : SRF<218,  "$res218", ["$s218"]>;
def RES219  : SRF<219,  "$res219", ["$s219"]>;
def RES220  : SRF<220,  "$res220", ["$s220"]>;
def RES221  : SRF<221,  "$res221", ["$s221"]>;
def RES222  : SRF<222,  "$res222", ["$s222"]>;
def RES223  : SRF<223,  "$res223", ["$s223"]>;
def RES224  : SRF<224,  "$res224", ["$s224"]>;
def RES225  : SRF<225,  "$res225", ["$s225"]>;
def RES226  : SRF<226,  "$res226", ["$s226"]>;
def RES227  : SRF<227,  "$res227", ["$s227"]>;
def RES228  : SRF<228,  "$res228", ["$s228"]>;
def RES229  : SRF<229,  "$res229", ["$s229"]>;
def RES230  : SRF<230,  "$res230", ["$s230"]>;
def RES231  : SRF<231,  "$res231", ["$s231"]>;
def RES232  : SRF<232,  "$res232", ["$s232"]>;
def RES233  : SRF<233,  "$res233", ["$s233"]>;
def RES234  : SRF<234,  "$res234", ["$s234"]>;
def RES235  : SRF<235,  "$res235", ["$s235"]>;
def RES236  : SRF<236,  "$res236", ["$s236"]>;
def RES237  : SRF<237,  "$res237", ["$s237"]>;
def RES238  : SRF<238,  "$res238", ["$s238"]>;
def RES239  : SRF<239,  "$res239", ["$s239"]>;
def RES240  : SRF<240,  "$res240", ["$s240"]>;
def RES241  : SRF<241,  "$res241", ["$s241"]>;
def RES242  : SRF<242,  "$res242", ["$s242"]>;
def RES243  : SRF<243,  "$res243", ["$s243"]>;
def RES244  : SRF<244,  "$res244", ["$s244"]>;
def RES245  : SRF<245,  "$res245", ["$s245"]>;
def RES246  : SRF<246,  "$res246", ["$s246"]>;
def RES247  : SRF<247,  "$res247", ["$s247"]>;
def RES248  : SRF<248,  "$res248", ["$s248"]>;
def RES249  : SRF<249,  "$res249", ["$s249"]>;
def RES250  : SRF<250,  "$res250", ["$s250"]>;
def RES251  : SRF<251,  "$res251", ["$s251"]>;
def RES252  : SRF<252,  "$res252", ["$s252"]>;
def RES253  : SRF<253,  "$res253", ["$s253"]>;
def RES254  : SRF<254,  "$res254", ["$s254"]>;
def RES255  : SRF<255,  "$res255", ["$s255"]>;
def VSFR0   : SRF<256,   "$vsfr0", ["$s256"]>;
def VSFR1   : SRF<257,   "$vsfr1", ["$s257"]>;
def VSFR2   : SRF<258,   "$vsfr2", ["$s258"]>;
def VSFR3   : SRF<259,   "$vsfr3", ["$s259"]>;
def VSFR4   : SRF<260,   "$vsfr4", ["$s260"]>;
def VSFR5   : SRF<261,   "$vsfr5", ["$s261"]>;
def VSFR6   : SRF<262,   "$vsfr6", ["$s262"]>;
def VSFR7   : SRF<263,   "$vsfr7", ["$s263"]>;
def VSFR8   : SRF<264,   "$vsfr8", ["$s264"]>;
def VSFR9   : SRF<265,   "$vsfr9", ["$s265"]>;
def VSFR10  : SRF<266,  "$vsfr10", ["$s266"]>;
def VSFR11  : SRF<267,  "$vsfr11", ["$s267"]>;
def VSFR12  : SRF<268,  "$vsfr12", ["$s268"]>;
def VSFR13  : SRF<269,  "$vsfr13", ["$s269"]>;
def VSFR14  : SRF<270,  "$vsfr14", ["$s270"]>;
def VSFR15  : SRF<271,  "$vsfr15", ["$s271"]>;
def VSFR16  : SRF<272,  "$vsfr16", ["$s272"]>;
def VSFR17  : SRF<273,  "$vsfr17", ["$s273"]>;
def VSFR18  : SRF<274,  "$vsfr18", ["$s274"]>;
def VSFR19  : SRF<275,  "$vsfr19", ["$s275"]>;
def VSFR20  : SRF<276,  "$vsfr20", ["$s276"]>;
def VSFR21  : SRF<277,  "$vsfr21", ["$s277"]>;
def VSFR22  : SRF<278,  "$vsfr22", ["$s278"]>;
def VSFR23  : SRF<279,  "$vsfr23", ["$s279"]>;
def VSFR24  : SRF<280,  "$vsfr24", ["$s280"]>;
def VSFR25  : SRF<281,  "$vsfr25", ["$s281"]>;
def VSFR26  : SRF<282,  "$vsfr26", ["$s282"]>;
def VSFR27  : SRF<283,  "$vsfr27", ["$s283"]>;
def VSFR28  : SRF<284,  "$vsfr28", ["$s284"]>;
def VSFR29  : SRF<285,  "$vsfr29", ["$s285"]>;
def VSFR30  : SRF<286,  "$vsfr30", ["$s286"]>;
def VSFR31  : SRF<287,  "$vsfr31", ["$s287"]>;
def VSFR32  : SRF<288,  "$vsfr32", ["$s288"]>;
def VSFR33  : SRF<289,  "$vsfr33", ["$s289"]>;
def VSFR34  : SRF<290,  "$vsfr34", ["$s290"]>;
def VSFR35  : SRF<291,  "$vsfr35", ["$s291"]>;
def VSFR36  : SRF<292,  "$vsfr36", ["$s292"]>;
def VSFR37  : SRF<293,  "$vsfr37", ["$s293"]>;
def VSFR38  : SRF<294,  "$vsfr38", ["$s294"]>;
def VSFR39  : SRF<295,  "$vsfr39", ["$s295"]>;
def VSFR40  : SRF<296,  "$vsfr40", ["$s296"]>;
def VSFR41  : SRF<297,  "$vsfr41", ["$s297"]>;
def VSFR42  : SRF<298,  "$vsfr42", ["$s298"]>;
def VSFR43  : SRF<299,  "$vsfr43", ["$s299"]>;
def VSFR44  : SRF<300,  "$vsfr44", ["$s300"]>;
def VSFR45  : SRF<301,  "$vsfr45", ["$s301"]>;
def VSFR46  : SRF<302,  "$vsfr46", ["$s302"]>;
def VSFR47  : SRF<303,  "$vsfr47", ["$s303"]>;
def VSFR48  : SRF<304,  "$vsfr48", ["$s304"]>;
def VSFR49  : SRF<305,  "$vsfr49", ["$s305"]>;
def VSFR50  : SRF<306,  "$vsfr50", ["$s306"]>;
def VSFR51  : SRF<307,  "$vsfr51", ["$s307"]>;
def VSFR52  : SRF<308,  "$vsfr52", ["$s308"]>;
def VSFR53  : SRF<309,  "$vsfr53", ["$s309"]>;
def VSFR54  : SRF<310,  "$vsfr54", ["$s310"]>;
def VSFR55  : SRF<311,  "$vsfr55", ["$s311"]>;
def VSFR56  : SRF<312,  "$vsfr56", ["$s312"]>;
def VSFR57  : SRF<313,  "$vsfr57", ["$s313"]>;
def VSFR58  : SRF<314,  "$vsfr58", ["$s314"]>;
def VSFR59  : SRF<315,  "$vsfr59", ["$s315"]>;
def VSFR60  : SRF<316,  "$vsfr60", ["$s316"]>;
def VSFR61  : SRF<317,  "$vsfr61", ["$s317"]>;
def VSFR62  : SRF<318,  "$vsfr62", ["$s318"]>;
def VSFR63  : SRF<319,  "$vsfr63", ["$s319"]>;
def VSFR64  : SRF<320,  "$vsfr64", ["$s320"]>;
def VSFR65  : SRF<321,  "$vsfr65", ["$s321"]>;
def VSFR66  : SRF<322,  "$vsfr66", ["$s322"]>;
def VSFR67  : SRF<323,  "$vsfr67", ["$s323"]>;
def VSFR68  : SRF<324,  "$vsfr68", ["$s324"]>;
def VSFR69  : SRF<325,  "$vsfr69", ["$s325"]>;
def VSFR70  : SRF<326,  "$vsfr70", ["$s326"]>;
def VSFR71  : SRF<327,  "$vsfr71", ["$s327"]>;
def VSFR72  : SRF<328,  "$vsfr72", ["$s328"]>;
def VSFR73  : SRF<329,  "$vsfr73", ["$s329"]>;
def VSFR74  : SRF<330,  "$vsfr74", ["$s330"]>;
def VSFR75  : SRF<331,  "$vsfr75", ["$s331"]>;
def VSFR76  : SRF<332,  "$vsfr76", ["$s332"]>;
def VSFR77  : SRF<333,  "$vsfr77", ["$s333"]>;
def VSFR78  : SRF<334,  "$vsfr78", ["$s334"]>;
def VSFR79  : SRF<335,  "$vsfr79", ["$s335"]>;
def VSFR80  : SRF<336,  "$vsfr80", ["$s336"]>;
def VSFR81  : SRF<337,  "$vsfr81", ["$s337"]>;
def VSFR82  : SRF<338,  "$vsfr82", ["$s338"]>;
def VSFR83  : SRF<339,  "$vsfr83", ["$s339"]>;
def VSFR84  : SRF<340,  "$vsfr84", ["$s340"]>;
def VSFR85  : SRF<341,  "$vsfr85", ["$s341"]>;
def VSFR86  : SRF<342,  "$vsfr86", ["$s342"]>;
def VSFR87  : SRF<343,  "$vsfr87", ["$s343"]>;
def VSFR88  : SRF<344,  "$vsfr88", ["$s344"]>;
def VSFR89  : SRF<345,  "$vsfr89", ["$s345"]>;
def VSFR90  : SRF<346,  "$vsfr90", ["$s346"]>;
def VSFR91  : SRF<347,  "$vsfr91", ["$s347"]>;
def VSFR92  : SRF<348,  "$vsfr92", ["$s348"]>;
def VSFR93  : SRF<349,  "$vsfr93", ["$s349"]>;
def VSFR94  : SRF<350,  "$vsfr94", ["$s350"]>;
def VSFR95  : SRF<351,  "$vsfr95", ["$s351"]>;
def VSFR96  : SRF<352,  "$vsfr96", ["$s352"]>;
def VSFR97  : SRF<353,  "$vsfr97", ["$s353"]>;
def VSFR98  : SRF<354,  "$vsfr98", ["$s354"]>;
def VSFR99  : SRF<355,  "$vsfr99", ["$s355"]>;
def VSFR100 : SRF<356, "$vsfr100", ["$s356"]>;
def VSFR101 : SRF<357, "$vsfr101", ["$s357"]>;
def VSFR102 : SRF<358, "$vsfr102", ["$s358"]>;
def VSFR103 : SRF<359, "$vsfr103", ["$s359"]>;
def VSFR104 : SRF<360, "$vsfr104", ["$s360"]>;
def VSFR105 : SRF<361, "$vsfr105", ["$s361"]>;
def VSFR106 : SRF<362, "$vsfr106", ["$s362"]>;
def VSFR107 : SRF<363, "$vsfr107", ["$s363"]>;
def VSFR108 : SRF<364, "$vsfr108", ["$s364"]>;
def VSFR109 : SRF<365, "$vsfr109", ["$s365"]>;
def VSFR110 : SRF<366, "$vsfr110", ["$s366"]>;
def VSFR111 : SRF<367, "$vsfr111", ["$s367"]>;
def VSFR112 : SRF<368, "$vsfr112", ["$s368"]>;
def VSFR113 : SRF<369, "$vsfr113", ["$s369"]>;
def VSFR114 : SRF<370, "$vsfr114", ["$s370"]>;
def VSFR115 : SRF<371, "$vsfr115", ["$s371"]>;
def VSFR116 : SRF<372, "$vsfr116", ["$s372"]>;
def VSFR117 : SRF<373, "$vsfr117", ["$s373"]>;
def VSFR118 : SRF<374, "$vsfr118", ["$s374"]>;
def VSFR119 : SRF<375, "$vsfr119", ["$s375"]>;
def VSFR120 : SRF<376, "$vsfr120", ["$s376"]>;
def VSFR121 : SRF<377, "$vsfr121", ["$s377"]>;
def VSFR122 : SRF<378, "$vsfr122", ["$s378"]>;
def VSFR123 : SRF<379, "$vsfr123", ["$s379"]>;
def VSFR124 : SRF<380, "$vsfr124", ["$s380"]>;
def VSFR125 : SRF<381, "$vsfr125", ["$s381"]>;
def VSFR126 : SRF<382, "$vsfr126", ["$s382"]>;
def VSFR127 : SRF<383, "$vsfr127", ["$s383"]>;
def VSFR128 : SRF<384, "$vsfr128", ["$s384"]>;
def VSFR129 : SRF<385, "$vsfr129", ["$s385"]>;
def VSFR130 : SRF<386, "$vsfr130", ["$s386"]>;
def VSFR131 : SRF<387, "$vsfr131", ["$s387"]>;
def VSFR132 : SRF<388, "$vsfr132", ["$s388"]>;
def VSFR133 : SRF<389, "$vsfr133", ["$s389"]>;
def VSFR134 : SRF<390, "$vsfr134", ["$s390"]>;
def VSFR135 : SRF<391, "$vsfr135", ["$s391"]>;
def VSFR136 : SRF<392, "$vsfr136", ["$s392"]>;
def VSFR137 : SRF<393, "$vsfr137", ["$s393"]>;
def VSFR138 : SRF<394, "$vsfr138", ["$s394"]>;
def VSFR139 : SRF<395, "$vsfr139", ["$s395"]>;
def VSFR140 : SRF<396, "$vsfr140", ["$s396"]>;
def VSFR141 : SRF<397, "$vsfr141", ["$s397"]>;
def VSFR142 : SRF<398, "$vsfr142", ["$s398"]>;
def VSFR143 : SRF<399, "$vsfr143", ["$s399"]>;
def VSFR144 : SRF<400, "$vsfr144", ["$s400"]>;
def VSFR145 : SRF<401, "$vsfr145", ["$s401"]>;
def VSFR146 : SRF<402, "$vsfr146", ["$s402"]>;
def VSFR147 : SRF<403, "$vsfr147", ["$s403"]>;
def VSFR148 : SRF<404, "$vsfr148", ["$s404"]>;
def VSFR149 : SRF<405, "$vsfr149", ["$s405"]>;
def VSFR150 : SRF<406, "$vsfr150", ["$s406"]>;
def VSFR151 : SRF<407, "$vsfr151", ["$s407"]>;
def VSFR152 : SRF<408, "$vsfr152", ["$s408"]>;
def VSFR153 : SRF<409, "$vsfr153", ["$s409"]>;
def VSFR154 : SRF<410, "$vsfr154", ["$s410"]>;
def VSFR155 : SRF<411, "$vsfr155", ["$s411"]>;
def VSFR156 : SRF<412, "$vsfr156", ["$s412"]>;
def VSFR157 : SRF<413, "$vsfr157", ["$s413"]>;
def VSFR158 : SRF<414, "$vsfr158", ["$s414"]>;
def VSFR159 : SRF<415, "$vsfr159", ["$s415"]>;
def VSFR160 : SRF<416, "$vsfr160", ["$s416"]>;
def VSFR161 : SRF<417, "$vsfr161", ["$s417"]>;
def VSFR162 : SRF<418, "$vsfr162", ["$s418"]>;
def VSFR163 : SRF<419, "$vsfr163", ["$s419"]>;
def VSFR164 : SRF<420, "$vsfr164", ["$s420"]>;
def VSFR165 : SRF<421, "$vsfr165", ["$s421"]>;
def VSFR166 : SRF<422, "$vsfr166", ["$s422"]>;
def VSFR167 : SRF<423, "$vsfr167", ["$s423"]>;
def VSFR168 : SRF<424, "$vsfr168", ["$s424"]>;
def VSFR169 : SRF<425, "$vsfr169", ["$s425"]>;
def VSFR170 : SRF<426, "$vsfr170", ["$s426"]>;
def VSFR171 : SRF<427, "$vsfr171", ["$s427"]>;
def VSFR172 : SRF<428, "$vsfr172", ["$s428"]>;
def VSFR173 : SRF<429, "$vsfr173", ["$s429"]>;
def VSFR174 : SRF<430, "$vsfr174", ["$s430"]>;
def VSFR175 : SRF<431, "$vsfr175", ["$s431"]>;
def VSFR176 : SRF<432, "$vsfr176", ["$s432"]>;
def VSFR177 : SRF<433, "$vsfr177", ["$s433"]>;
def VSFR178 : SRF<434, "$vsfr178", ["$s434"]>;
def VSFR179 : SRF<435, "$vsfr179", ["$s435"]>;
def VSFR180 : SRF<436, "$vsfr180", ["$s436"]>;
def VSFR181 : SRF<437, "$vsfr181", ["$s437"]>;
def VSFR182 : SRF<438, "$vsfr182", ["$s438"]>;
def VSFR183 : SRF<439, "$vsfr183", ["$s439"]>;
def VSFR184 : SRF<440, "$vsfr184", ["$s440"]>;
def VSFR185 : SRF<441, "$vsfr185", ["$s441"]>;
def VSFR186 : SRF<442, "$vsfr186", ["$s442"]>;
def VSFR187 : SRF<443, "$vsfr187", ["$s443"]>;
def VSFR188 : SRF<444, "$vsfr188", ["$s444"]>;
def VSFR189 : SRF<445, "$vsfr189", ["$s445"]>;
def VSFR190 : SRF<446, "$vsfr190", ["$s446"]>;
def VSFR191 : SRF<447, "$vsfr191", ["$s447"]>;
def VSFR192 : SRF<448, "$vsfr192", ["$s448"]>;
def VSFR193 : SRF<449, "$vsfr193", ["$s449"]>;
def VSFR194 : SRF<450, "$vsfr194", ["$s450"]>;
def VSFR195 : SRF<451, "$vsfr195", ["$s451"]>;
def VSFR196 : SRF<452, "$vsfr196", ["$s452"]>;
def VSFR197 : SRF<453, "$vsfr197", ["$s453"]>;
def VSFR198 : SRF<454, "$vsfr198", ["$s454"]>;
def VSFR199 : SRF<455, "$vsfr199", ["$s455"]>;
def VSFR200 : SRF<456, "$vsfr200", ["$s456"]>;
def VSFR201 : SRF<457, "$vsfr201", ["$s457"]>;
def VSFR202 : SRF<458, "$vsfr202", ["$s458"]>;
def VSFR203 : SRF<459, "$vsfr203", ["$s459"]>;
def VSFR204 : SRF<460, "$vsfr204", ["$s460"]>;
def VSFR205 : SRF<461, "$vsfr205", ["$s461"]>;
def VSFR206 : SRF<462, "$vsfr206", ["$s462"]>;
def VSFR207 : SRF<463, "$vsfr207", ["$s463"]>;
def VSFR208 : SRF<464, "$vsfr208", ["$s464"]>;
def VSFR209 : SRF<465, "$vsfr209", ["$s465"]>;
def VSFR210 : SRF<466, "$vsfr210", ["$s466"]>;
def VSFR211 : SRF<467, "$vsfr211", ["$s467"]>;
def VSFR212 : SRF<468, "$vsfr212", ["$s468"]>;
def VSFR213 : SRF<469, "$vsfr213", ["$s469"]>;
def VSFR214 : SRF<470, "$vsfr214", ["$s470"]>;
def VSFR215 : SRF<471, "$vsfr215", ["$s471"]>;
def VSFR216 : SRF<472, "$vsfr216", ["$s472"]>;
def VSFR217 : SRF<473, "$vsfr217", ["$s473"]>;
def VSFR218 : SRF<474, "$vsfr218", ["$s474"]>;
def VSFR219 : SRF<475, "$vsfr219", ["$s475"]>;
def VSFR220 : SRF<476, "$vsfr220", ["$s476"]>;
def VSFR221 : SRF<477, "$vsfr221", ["$s477"]>;
def VSFR222 : SRF<478, "$vsfr222", ["$s478"]>;
def VSFR223 : SRF<479, "$vsfr223", ["$s479"]>;
def VSFR224 : SRF<480, "$vsfr224", ["$s480"]>;
def VSFR225 : SRF<481, "$vsfr225", ["$s481"]>;
def VSFR226 : SRF<482, "$vsfr226", ["$s482"]>;
def VSFR227 : SRF<483, "$vsfr227", ["$s483"]>;
def VSFR228 : SRF<484, "$vsfr228", ["$s484"]>;
def VSFR229 : SRF<485, "$vsfr229", ["$s485"]>;
def VSFR230 : SRF<486, "$vsfr230", ["$s486"]>;
def VSFR231 : SRF<487, "$vsfr231", ["$s487"]>;
def VSFR232 : SRF<488, "$vsfr232", ["$s488"]>;
def VSFR233 : SRF<489, "$vsfr233", ["$s489"]>;
def VSFR234 : SRF<490, "$vsfr234", ["$s490"]>;
def VSFR235 : SRF<491, "$vsfr235", ["$s491"]>;
def VSFR236 : SRF<492, "$vsfr236", ["$s492"]>;
def VSFR237 : SRF<493, "$vsfr237", ["$s493"]>;
def VSFR238 : SRF<494, "$vsfr238", ["$s494"]>;
def VSFR239 : SRF<495, "$vsfr239", ["$s495"]>;
def VSFR240 : SRF<496, "$vsfr240", ["$s496"]>;
def VSFR241 : SRF<497, "$vsfr241", ["$s497"]>;
def VSFR242 : SRF<498, "$vsfr242", ["$s498"]>;
def VSFR243 : SRF<499, "$vsfr243", ["$s499"]>;
def VSFR244 : SRF<500, "$vsfr244", ["$s500"]>;
def VSFR245 : SRF<501, "$vsfr245", ["$s501"]>;
def VSFR246 : SRF<502, "$vsfr246", ["$s502"]>;
def VSFR247 : SRF<503, "$vsfr247", ["$s503"]>;
def VSFR248 : SRF<504, "$vsfr248", ["$s504"]>;
def VSFR249 : SRF<505, "$vsfr249", ["$s505"]>;
def VSFR250 : SRF<506, "$vsfr250", ["$s506"]>;
def VSFR251 : SRF<507, "$vsfr251", ["$s507"]>;
def VSFR252 : SRF<508, "$vsfr252", ["$s508"]>;
def VSFR253 : SRF<509, "$vsfr253", ["$s509"]>;
def VSFR254 : SRF<510, "$vsfr254", ["$s510"]>;
def VSFR255 : SRF<511, "$vsfr255", ["$s511"]>;


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
def P0  : PRF< 0,   "$r0r1", [ R0,  R1]>;
def P2  : PRF< 2,   "$r2r3", [ R2,  R3]>;
def P4  : PRF< 4,   "$r4r5", [ R4,  R5]>;
def P6  : PRF< 6,   "$r6r7", [ R6,  R7]>;
def P8  : PRF< 8,   "$r8r9", [ R8,  R9]>;
def P10 : PRF<10, "$r10r11", [R10, R11]>;
def P12 : PRF<12, "$r12r13", [R12, R13]>;
def P14 : PRF<14, "$r14r15", [R14, R15]>;
def P16 : PRF<16, "$r16r17", [R16, R17]>;
def P18 : PRF<18, "$r18r19", [R18, R19]>;
def P20 : PRF<20, "$r20r21", [R20, R21]>;
def P22 : PRF<22, "$r22r23", [R22, R23]>;
def P24 : PRF<24, "$r24r25", [R24, R25]>;
def P26 : PRF<26, "$r26r27", [R26, R27]>;
def P28 : PRF<28, "$r28r29", [R28, R29]>;
def P30 : PRF<30, "$r30r31", [R30, R31]>;
def P32 : PRF<32, "$r32r33", [R32, R33]>;
def P34 : PRF<34, "$r34r35", [R34, R35]>;
def P36 : PRF<36, "$r36r37", [R36, R37]>;
def P38 : PRF<38, "$r38r39", [R38, R39]>;
def P40 : PRF<40, "$r40r41", [R40, R41]>;
def P42 : PRF<42, "$r42r43", [R42, R43]>;
def P44 : PRF<44, "$r44r45", [R44, R45]>;
def P46 : PRF<46, "$r46r47", [R46, R47]>;
def P48 : PRF<48, "$r48r49", [R48, R49]>;
def P50 : PRF<50, "$r50r51", [R50, R51]>;
def P52 : PRF<52, "$r52r53", [R52, R53]>;
def P54 : PRF<54, "$r54r55", [R54, R55]>;
def P56 : PRF<56, "$r56r57", [R56, R57]>;
def P58 : PRF<58, "$r58r59", [R58, R59]>;
def P60 : PRF<60, "$r60r61", [R60, R61]>;
def P62 : PRF<62, "$r62r63", [R62, R63]>;


// Quadruple Register File
def Q0  : QRF< 0,     "$r0r1r2r3", [ R0,  R1,  R2,  R3]>;
def Q4  : QRF< 4,     "$r4r5r6r7", [ R4,  R5,  R6,  R7]>;
def Q8  : QRF< 8,   "$r8r9r10r11", [ R8,  R9, R10, R11]>;
def Q12 : QRF<12, "$r12r13r14r15", [R12, R13, R14, R15]>;
def Q16 : QRF<16, "$r16r17r18r19", [R16, R17, R18, R19]>;
def Q20 : QRF<20, "$r20r21r22r23", [R20, R21, R22, R23]>;
def Q24 : QRF<24, "$r24r25r26r27", [R24, R25, R26, R27]>;
def Q28 : QRF<28, "$r28r29r30r31", [R28, R29, R30, R31]>;
def Q32 : QRF<32, "$r32r33r34r35", [R32, R33, R34, R35]>;
def Q36 : QRF<36, "$r36r37r38r39", [R36, R37, R38, R39]>;
def Q40 : QRF<40, "$r40r41r42r43", [R40, R41, R42, R43]>;
def Q44 : QRF<44, "$r44r45r46r47", [R44, R45, R46, R47]>;
def Q48 : QRF<48, "$r48r49r50r51", [R48, R49, R50, R51]>;
def Q52 : QRF<52, "$r52r53r54r55", [R52, R53, R54, R55]>;
def Q56 : QRF<56, "$r56r57r58r59", [R56, R57, R58, R59]>;
def Q60 : QRF<60, "$r60r61r62r63", [R60, R61, R62, R63]>;


// Coprocessor Register File
def C0   : CRF<  0,  "$a0_x",  ["$a0.x"]>, DwarfRegNum<[256]>;
def C1   : CRF<  1,  "$a0_y",  ["$a0.y"]>, DwarfRegNum<[257]>;
def C2   : CRF<  2,  "$a0_z",  ["$a0.z"]>, DwarfRegNum<[258]>;
def C3   : CRF<  3,  "$a0_t",  ["$a0.t"]>, DwarfRegNum<[259]>;
def C4   : CRF<  4,  "$a1_x",  ["$a1.x"]>, DwarfRegNum<[260]>;
def C5   : CRF<  5,  "$a1_y",  ["$a1.y"]>, DwarfRegNum<[261]>;
def C6   : CRF<  6,  "$a1_z",  ["$a1.z"]>, DwarfRegNum<[262]>;
def C7   : CRF<  7,  "$a1_t",  ["$a1.t"]>, DwarfRegNum<[263]>;
def C8   : CRF<  8,  "$a2_x",  ["$a2.x"]>, DwarfRegNum<[264]>;
def C9   : CRF<  9,  "$a2_y",  ["$a2.y"]>, DwarfRegNum<[265]>;
def C10  : CRF< 10,  "$a2_z",  ["$a2.z"]>, DwarfRegNum<[266]>;
def C11  : CRF< 11,  "$a2_t",  ["$a2.t"]>, DwarfRegNum<[267]>;
def C12  : CRF< 12,  "$a3_x",  ["$a3.x"]>, DwarfRegNum<[268]>;
def C13  : CRF< 13,  "$a3_y",  ["$a3.y"]>, DwarfRegNum<[269]>;
def C14  : CRF< 14,  "$a3_z",  ["$a3.z"]>, DwarfRegNum<[270]>;
def C15  : CRF< 15,  "$a3_t",  ["$a3.t"]>, DwarfRegNum<[271]>;
def C16  : CRF< 16,  "$a4_x",  ["$a4.x"]>, DwarfRegNum<[272]>;
def C17  : CRF< 17,  "$a4_y",  ["$a4.y"]>, DwarfRegNum<[273]>;
def C18  : CRF< 18,  "$a4_z",  ["$a4.z"]>, DwarfRegNum<[274]>;
def C19  : CRF< 19,  "$a4_t",  ["$a4.t"]>, DwarfRegNum<[275]>;
def C20  : CRF< 20,  "$a5_x",  ["$a5.x"]>, DwarfRegNum<[276]>;
def C21  : CRF< 21,  "$a5_y",  ["$a5.y"]>, DwarfRegNum<[277]>;
def C22  : CRF< 22,  "$a5_z",  ["$a5.z"]>, DwarfRegNum<[278]>;
def C23  : CRF< 23,  "$a5_t",  ["$a5.t"]>, DwarfRegNum<[279]>;
def C24  : CRF< 24,  "$a6_x",  ["$a6.x"]>, DwarfRegNum<[280]>;
def C25  : CRF< 25,  "$a6_y",  ["$a6.y"]>, DwarfRegNum<[281]>;
def C26  : CRF< 26,  "$a6_z",  ["$a6.z"]>, DwarfRegNum<[282]>;
def C27  : CRF< 27,  "$a6_t",  ["$a6.t"]>, DwarfRegNum<[283]>;
def C28  : CRF< 28,  "$a7_x",  ["$a7.x"]>, DwarfRegNum<[284]>;
def C29  : CRF< 29,  "$a7_y",  ["$a7.y"]>, DwarfRegNum<[285]>;
def C30  : CRF< 30,  "$a7_z",  ["$a7.z"]>, DwarfRegNum<[286]>;
def C31  : CRF< 31,  "$a7_t",  ["$a7.t"]>, DwarfRegNum<[287]>;
def C32  : CRF< 32,  "$a8_x",  ["$a8.x"]>, DwarfRegNum<[288]>;
def C33  : CRF< 33,  "$a8_y",  ["$a8.y"]>, DwarfRegNum<[289]>;
def C34  : CRF< 34,  "$a8_z",  ["$a8.z"]>, DwarfRegNum<[290]>;
def C35  : CRF< 35,  "$a8_t",  ["$a8.t"]>, DwarfRegNum<[291]>;
def C36  : CRF< 36,  "$a9_x",  ["$a9.x"]>, DwarfRegNum<[292]>;
def C37  : CRF< 37,  "$a9_y",  ["$a9.y"]>, DwarfRegNum<[293]>;
def C38  : CRF< 38,  "$a9_z",  ["$a9.z"]>, DwarfRegNum<[294]>;
def C39  : CRF< 39,  "$a9_t",  ["$a9.t"]>, DwarfRegNum<[295]>;
def C40  : CRF< 40, "$a10_x", ["$a10.x"]>, DwarfRegNum<[296]>;
def C41  : CRF< 41, "$a10_y", ["$a10.y"]>, DwarfRegNum<[297]>;
def C42  : CRF< 42, "$a10_z", ["$a10.z"]>, DwarfRegNum<[298]>;
def C43  : CRF< 43, "$a10_t", ["$a10.t"]>, DwarfRegNum<[299]>;
def C44  : CRF< 44, "$a11_x", ["$a11.x"]>, DwarfRegNum<[300]>;
def C45  : CRF< 45, "$a11_y", ["$a11.y"]>, DwarfRegNum<[301]>;
def C46  : CRF< 46, "$a11_z", ["$a11.z"]>, DwarfRegNum<[302]>;
def C47  : CRF< 47, "$a11_t", ["$a11.t"]>, DwarfRegNum<[303]>;
def C48  : CRF< 48, "$a12_x", ["$a12.x"]>, DwarfRegNum<[304]>;
def C49  : CRF< 49, "$a12_y", ["$a12.y"]>, DwarfRegNum<[305]>;
def C50  : CRF< 50, "$a12_z", ["$a12.z"]>, DwarfRegNum<[306]>;
def C51  : CRF< 51, "$a12_t", ["$a12.t"]>, DwarfRegNum<[307]>;
def C52  : CRF< 52, "$a13_x", ["$a13.x"]>, DwarfRegNum<[308]>;
def C53  : CRF< 53, "$a13_y", ["$a13.y"]>, DwarfRegNum<[309]>;
def C54  : CRF< 54, "$a13_z", ["$a13.z"]>, DwarfRegNum<[310]>;
def C55  : CRF< 55, "$a13_t", ["$a13.t"]>, DwarfRegNum<[311]>;
def C56  : CRF< 56, "$a14_x", ["$a14.x"]>, DwarfRegNum<[312]>;
def C57  : CRF< 57, "$a14_y", ["$a14.y"]>, DwarfRegNum<[313]>;
def C58  : CRF< 58, "$a14_z", ["$a14.z"]>, DwarfRegNum<[314]>;
def C59  : CRF< 59, "$a14_t", ["$a14.t"]>, DwarfRegNum<[315]>;
def C60  : CRF< 60, "$a15_x", ["$a15.x"]>, DwarfRegNum<[316]>;
def C61  : CRF< 61, "$a15_y", ["$a15.y"]>, DwarfRegNum<[317]>;
def C62  : CRF< 62, "$a15_z", ["$a15.z"]>, DwarfRegNum<[318]>;
def C63  : CRF< 63, "$a15_t", ["$a15.t"]>, DwarfRegNum<[319]>;
def C64  : CRF< 64, "$a16_x", ["$a16.x"]>, DwarfRegNum<[320]>;
def C65  : CRF< 65, "$a16_y", ["$a16.y"]>, DwarfRegNum<[321]>;
def C66  : CRF< 66, "$a16_z", ["$a16.z"]>, DwarfRegNum<[322]>;
def C67  : CRF< 67, "$a16_t", ["$a16.t"]>, DwarfRegNum<[323]>;
def C68  : CRF< 68, "$a17_x", ["$a17.x"]>, DwarfRegNum<[324]>;
def C69  : CRF< 69, "$a17_y", ["$a17.y"]>, DwarfRegNum<[325]>;
def C70  : CRF< 70, "$a17_z", ["$a17.z"]>, DwarfRegNum<[326]>;
def C71  : CRF< 71, "$a17_t", ["$a17.t"]>, DwarfRegNum<[327]>;
def C72  : CRF< 72, "$a18_x", ["$a18.x"]>, DwarfRegNum<[328]>;
def C73  : CRF< 73, "$a18_y", ["$a18.y"]>, DwarfRegNum<[329]>;
def C74  : CRF< 74, "$a18_z", ["$a18.z"]>, DwarfRegNum<[330]>;
def C75  : CRF< 75, "$a18_t", ["$a18.t"]>, DwarfRegNum<[331]>;
def C76  : CRF< 76, "$a19_x", ["$a19.x"]>, DwarfRegNum<[332]>;
def C77  : CRF< 77, "$a19_y", ["$a19.y"]>, DwarfRegNum<[333]>;
def C78  : CRF< 78, "$a19_z", ["$a19.z"]>, DwarfRegNum<[334]>;
def C79  : CRF< 79, "$a19_t", ["$a19.t"]>, DwarfRegNum<[335]>;
def C80  : CRF< 80, "$a20_x", ["$a20.x"]>, DwarfRegNum<[336]>;
def C81  : CRF< 81, "$a20_y", ["$a20.y"]>, DwarfRegNum<[337]>;
def C82  : CRF< 82, "$a20_z", ["$a20.z"]>, DwarfRegNum<[338]>;
def C83  : CRF< 83, "$a20_t", ["$a20.t"]>, DwarfRegNum<[339]>;
def C84  : CRF< 84, "$a21_x", ["$a21.x"]>, DwarfRegNum<[340]>;
def C85  : CRF< 85, "$a21_y", ["$a21.y"]>, DwarfRegNum<[341]>;
def C86  : CRF< 86, "$a21_z", ["$a21.z"]>, DwarfRegNum<[342]>;
def C87  : CRF< 87, "$a21_t", ["$a21.t"]>, DwarfRegNum<[343]>;
def C88  : CRF< 88, "$a22_x", ["$a22.x"]>, DwarfRegNum<[344]>;
def C89  : CRF< 89, "$a22_y", ["$a22.y"]>, DwarfRegNum<[345]>;
def C90  : CRF< 90, "$a22_z", ["$a22.z"]>, DwarfRegNum<[346]>;
def C91  : CRF< 91, "$a22_t", ["$a22.t"]>, DwarfRegNum<[347]>;
def C92  : CRF< 92, "$a23_x", ["$a23.x"]>, DwarfRegNum<[348]>;
def C93  : CRF< 93, "$a23_y", ["$a23.y"]>, DwarfRegNum<[349]>;
def C94  : CRF< 94, "$a23_z", ["$a23.z"]>, DwarfRegNum<[350]>;
def C95  : CRF< 95, "$a23_t", ["$a23.t"]>, DwarfRegNum<[351]>;
def C96  : CRF< 96, "$a24_x", ["$a24.x"]>, DwarfRegNum<[352]>;
def C97  : CRF< 97, "$a24_y", ["$a24.y"]>, DwarfRegNum<[353]>;
def C98  : CRF< 98, "$a24_z", ["$a24.z"]>, DwarfRegNum<[354]>;
def C99  : CRF< 99, "$a24_t", ["$a24.t"]>, DwarfRegNum<[355]>;
def C100 : CRF<100, "$a25_x", ["$a25.x"]>, DwarfRegNum<[356]>;
def C101 : CRF<101, "$a25_y", ["$a25.y"]>, DwarfRegNum<[357]>;
def C102 : CRF<102, "$a25_z", ["$a25.z"]>, DwarfRegNum<[358]>;
def C103 : CRF<103, "$a25_t", ["$a25.t"]>, DwarfRegNum<[359]>;
def C104 : CRF<104, "$a26_x", ["$a26.x"]>, DwarfRegNum<[360]>;
def C105 : CRF<105, "$a26_y", ["$a26.y"]>, DwarfRegNum<[361]>;
def C106 : CRF<106, "$a26_z", ["$a26.z"]>, DwarfRegNum<[362]>;
def C107 : CRF<107, "$a26_t", ["$a26.t"]>, DwarfRegNum<[363]>;
def C108 : CRF<108, "$a27_x", ["$a27.x"]>, DwarfRegNum<[364]>;
def C109 : CRF<109, "$a27_y", ["$a27.y"]>, DwarfRegNum<[365]>;
def C110 : CRF<110, "$a27_z", ["$a27.z"]>, DwarfRegNum<[366]>;
def C111 : CRF<111, "$a27_t", ["$a27.t"]>, DwarfRegNum<[367]>;
def C112 : CRF<112, "$a28_x", ["$a28.x"]>, DwarfRegNum<[368]>;
def C113 : CRF<113, "$a28_y", ["$a28.y"]>, DwarfRegNum<[369]>;
def C114 : CRF<114, "$a28_z", ["$a28.z"]>, DwarfRegNum<[370]>;
def C115 : CRF<115, "$a28_t", ["$a28.t"]>, DwarfRegNum<[371]>;
def C116 : CRF<116, "$a29_x", ["$a29.x"]>, DwarfRegNum<[372]>;
def C117 : CRF<117, "$a29_y", ["$a29.y"]>, DwarfRegNum<[373]>;
def C118 : CRF<118, "$a29_z", ["$a29.z"]>, DwarfRegNum<[374]>;
def C119 : CRF<119, "$a29_t", ["$a29.t"]>, DwarfRegNum<[375]>;
def C120 : CRF<120, "$a30_x", ["$a30.x"]>, DwarfRegNum<[376]>;
def C121 : CRF<121, "$a30_y", ["$a30.y"]>, DwarfRegNum<[377]>;
def C122 : CRF<122, "$a30_z", ["$a30.z"]>, DwarfRegNum<[378]>;
def C123 : CRF<123, "$a30_t", ["$a30.t"]>, DwarfRegNum<[379]>;
def C124 : CRF<124, "$a31_x", ["$a31.x"]>, DwarfRegNum<[380]>;
def C125 : CRF<125, "$a31_y", ["$a31.y"]>, DwarfRegNum<[381]>;
def C126 : CRF<126, "$a31_z", ["$a31.z"]>, DwarfRegNum<[382]>;
def C127 : CRF<127, "$a31_t", ["$a31.t"]>, DwarfRegNum<[383]>;
def C128 : CRF<128, "$a32_x", ["$a32.x"]>, DwarfRegNum<[384]>;
def C129 : CRF<129, "$a32_y", ["$a32.y"]>, DwarfRegNum<[385]>;
def C130 : CRF<130, "$a32_z", ["$a32.z"]>, DwarfRegNum<[386]>;
def C131 : CRF<131, "$a32_t", ["$a32.t"]>, DwarfRegNum<[387]>;
def C132 : CRF<132, "$a33_x", ["$a33.x"]>, DwarfRegNum<[388]>;
def C133 : CRF<133, "$a33_y", ["$a33.y"]>, DwarfRegNum<[389]>;
def C134 : CRF<134, "$a33_z", ["$a33.z"]>, DwarfRegNum<[390]>;
def C135 : CRF<135, "$a33_t", ["$a33.t"]>, DwarfRegNum<[391]>;
def C136 : CRF<136, "$a34_x", ["$a34.x"]>, DwarfRegNum<[392]>;
def C137 : CRF<137, "$a34_y", ["$a34.y"]>, DwarfRegNum<[393]>;
def C138 : CRF<138, "$a34_z", ["$a34.z"]>, DwarfRegNum<[394]>;
def C139 : CRF<139, "$a34_t", ["$a34.t"]>, DwarfRegNum<[395]>;
def C140 : CRF<140, "$a35_x", ["$a35.x"]>, DwarfRegNum<[396]>;
def C141 : CRF<141, "$a35_y", ["$a35.y"]>, DwarfRegNum<[397]>;
def C142 : CRF<142, "$a35_z", ["$a35.z"]>, DwarfRegNum<[398]>;
def C143 : CRF<143, "$a35_t", ["$a35.t"]>, DwarfRegNum<[399]>;
def C144 : CRF<144, "$a36_x", ["$a36.x"]>, DwarfRegNum<[400]>;
def C145 : CRF<145, "$a36_y", ["$a36.y"]>, DwarfRegNum<[401]>;
def C146 : CRF<146, "$a36_z", ["$a36.z"]>, DwarfRegNum<[402]>;
def C147 : CRF<147, "$a36_t", ["$a36.t"]>, DwarfRegNum<[403]>;
def C148 : CRF<148, "$a37_x", ["$a37.x"]>, DwarfRegNum<[404]>;
def C149 : CRF<149, "$a37_y", ["$a37.y"]>, DwarfRegNum<[405]>;
def C150 : CRF<150, "$a37_z", ["$a37.z"]>, DwarfRegNum<[406]>;
def C151 : CRF<151, "$a37_t", ["$a37.t"]>, DwarfRegNum<[407]>;
def C152 : CRF<152, "$a38_x", ["$a38.x"]>, DwarfRegNum<[408]>;
def C153 : CRF<153, "$a38_y", ["$a38.y"]>, DwarfRegNum<[409]>;
def C154 : CRF<154, "$a38_z", ["$a38.z"]>, DwarfRegNum<[410]>;
def C155 : CRF<155, "$a38_t", ["$a38.t"]>, DwarfRegNum<[411]>;
def C156 : CRF<156, "$a39_x", ["$a39.x"]>, DwarfRegNum<[412]>;
def C157 : CRF<157, "$a39_y", ["$a39.y"]>, DwarfRegNum<[413]>;
def C158 : CRF<158, "$a39_z", ["$a39.z"]>, DwarfRegNum<[414]>;
def C159 : CRF<159, "$a39_t", ["$a39.t"]>, DwarfRegNum<[415]>;
def C160 : CRF<160, "$a40_x", ["$a40.x"]>, DwarfRegNum<[416]>;
def C161 : CRF<161, "$a40_y", ["$a40.y"]>, DwarfRegNum<[417]>;
def C162 : CRF<162, "$a40_z", ["$a40.z"]>, DwarfRegNum<[418]>;
def C163 : CRF<163, "$a40_t", ["$a40.t"]>, DwarfRegNum<[419]>;
def C164 : CRF<164, "$a41_x", ["$a41.x"]>, DwarfRegNum<[420]>;
def C165 : CRF<165, "$a41_y", ["$a41.y"]>, DwarfRegNum<[421]>;
def C166 : CRF<166, "$a41_z", ["$a41.z"]>, DwarfRegNum<[422]>;
def C167 : CRF<167, "$a41_t", ["$a41.t"]>, DwarfRegNum<[423]>;
def C168 : CRF<168, "$a42_x", ["$a42.x"]>, DwarfRegNum<[424]>;
def C169 : CRF<169, "$a42_y", ["$a42.y"]>, DwarfRegNum<[425]>;
def C170 : CRF<170, "$a42_z", ["$a42.z"]>, DwarfRegNum<[426]>;
def C171 : CRF<171, "$a42_t", ["$a42.t"]>, DwarfRegNum<[427]>;
def C172 : CRF<172, "$a43_x", ["$a43.x"]>, DwarfRegNum<[428]>;
def C173 : CRF<173, "$a43_y", ["$a43.y"]>, DwarfRegNum<[429]>;
def C174 : CRF<174, "$a43_z", ["$a43.z"]>, DwarfRegNum<[430]>;
def C175 : CRF<175, "$a43_t", ["$a43.t"]>, DwarfRegNum<[431]>;
def C176 : CRF<176, "$a44_x", ["$a44.x"]>, DwarfRegNum<[432]>;
def C177 : CRF<177, "$a44_y", ["$a44.y"]>, DwarfRegNum<[433]>;
def C178 : CRF<178, "$a44_z", ["$a44.z"]>, DwarfRegNum<[434]>;
def C179 : CRF<179, "$a44_t", ["$a44.t"]>, DwarfRegNum<[435]>;
def C180 : CRF<180, "$a45_x", ["$a45.x"]>, DwarfRegNum<[436]>;
def C181 : CRF<181, "$a45_y", ["$a45.y"]>, DwarfRegNum<[437]>;
def C182 : CRF<182, "$a45_z", ["$a45.z"]>, DwarfRegNum<[438]>;
def C183 : CRF<183, "$a45_t", ["$a45.t"]>, DwarfRegNum<[439]>;
def C184 : CRF<184, "$a46_x", ["$a46.x"]>, DwarfRegNum<[440]>;
def C185 : CRF<185, "$a46_y", ["$a46.y"]>, DwarfRegNum<[441]>;
def C186 : CRF<186, "$a46_z", ["$a46.z"]>, DwarfRegNum<[442]>;
def C187 : CRF<187, "$a46_t", ["$a46.t"]>, DwarfRegNum<[443]>;
def C188 : CRF<188, "$a47_x", ["$a47.x"]>, DwarfRegNum<[444]>;
def C189 : CRF<189, "$a47_y", ["$a47.y"]>, DwarfRegNum<[445]>;
def C190 : CRF<190, "$a47_z", ["$a47.z"]>, DwarfRegNum<[446]>;
def C191 : CRF<191, "$a47_t", ["$a47.t"]>, DwarfRegNum<[447]>;
def C192 : CRF<192, "$a48_x", ["$a48.x"]>, DwarfRegNum<[448]>;
def C193 : CRF<193, "$a48_y", ["$a48.y"]>, DwarfRegNum<[449]>;
def C194 : CRF<194, "$a48_z", ["$a48.z"]>, DwarfRegNum<[450]>;
def C195 : CRF<195, "$a48_t", ["$a48.t"]>, DwarfRegNum<[451]>;
def C196 : CRF<196, "$a49_x", ["$a49.x"]>, DwarfRegNum<[452]>;
def C197 : CRF<197, "$a49_y", ["$a49.y"]>, DwarfRegNum<[453]>;
def C198 : CRF<198, "$a49_z", ["$a49.z"]>, DwarfRegNum<[454]>;
def C199 : CRF<199, "$a49_t", ["$a49.t"]>, DwarfRegNum<[455]>;
def C200 : CRF<200, "$a50_x", ["$a50.x"]>, DwarfRegNum<[456]>;
def C201 : CRF<201, "$a50_y", ["$a50.y"]>, DwarfRegNum<[457]>;
def C202 : CRF<202, "$a50_z", ["$a50.z"]>, DwarfRegNum<[458]>;
def C203 : CRF<203, "$a50_t", ["$a50.t"]>, DwarfRegNum<[459]>;
def C204 : CRF<204, "$a51_x", ["$a51.x"]>, DwarfRegNum<[460]>;
def C205 : CRF<205, "$a51_y", ["$a51.y"]>, DwarfRegNum<[461]>;
def C206 : CRF<206, "$a51_z", ["$a51.z"]>, DwarfRegNum<[462]>;
def C207 : CRF<207, "$a51_t", ["$a51.t"]>, DwarfRegNum<[463]>;
def C208 : CRF<208, "$a52_x", ["$a52.x"]>, DwarfRegNum<[464]>;
def C209 : CRF<209, "$a52_y", ["$a52.y"]>, DwarfRegNum<[465]>;
def C210 : CRF<210, "$a52_z", ["$a52.z"]>, DwarfRegNum<[466]>;
def C211 : CRF<211, "$a52_t", ["$a52.t"]>, DwarfRegNum<[467]>;
def C212 : CRF<212, "$a53_x", ["$a53.x"]>, DwarfRegNum<[468]>;
def C213 : CRF<213, "$a53_y", ["$a53.y"]>, DwarfRegNum<[469]>;
def C214 : CRF<214, "$a53_z", ["$a53.z"]>, DwarfRegNum<[470]>;
def C215 : CRF<215, "$a53_t", ["$a53.t"]>, DwarfRegNum<[471]>;
def C216 : CRF<216, "$a54_x", ["$a54.x"]>, DwarfRegNum<[472]>;
def C217 : CRF<217, "$a54_y", ["$a54.y"]>, DwarfRegNum<[473]>;
def C218 : CRF<218, "$a54_z", ["$a54.z"]>, DwarfRegNum<[474]>;
def C219 : CRF<219, "$a54_t", ["$a54.t"]>, DwarfRegNum<[475]>;
def C220 : CRF<220, "$a55_x", ["$a55.x"]>, DwarfRegNum<[476]>;
def C221 : CRF<221, "$a55_y", ["$a55.y"]>, DwarfRegNum<[477]>;
def C222 : CRF<222, "$a55_z", ["$a55.z"]>, DwarfRegNum<[478]>;
def C223 : CRF<223, "$a55_t", ["$a55.t"]>, DwarfRegNum<[479]>;
def C224 : CRF<224, "$a56_x", ["$a56.x"]>, DwarfRegNum<[480]>;
def C225 : CRF<225, "$a56_y", ["$a56.y"]>, DwarfRegNum<[481]>;
def C226 : CRF<226, "$a56_z", ["$a56.z"]>, DwarfRegNum<[482]>;
def C227 : CRF<227, "$a56_t", ["$a56.t"]>, DwarfRegNum<[483]>;
def C228 : CRF<228, "$a57_x", ["$a57.x"]>, DwarfRegNum<[484]>;
def C229 : CRF<229, "$a57_y", ["$a57.y"]>, DwarfRegNum<[485]>;
def C230 : CRF<230, "$a57_z", ["$a57.z"]>, DwarfRegNum<[486]>;
def C231 : CRF<231, "$a57_t", ["$a57.t"]>, DwarfRegNum<[487]>;
def C232 : CRF<232, "$a58_x", ["$a58.x"]>, DwarfRegNum<[488]>;
def C233 : CRF<233, "$a58_y", ["$a58.y"]>, DwarfRegNum<[489]>;
def C234 : CRF<234, "$a58_z", ["$a58.z"]>, DwarfRegNum<[490]>;
def C235 : CRF<235, "$a58_t", ["$a58.t"]>, DwarfRegNum<[491]>;
def C236 : CRF<236, "$a59_x", ["$a59.x"]>, DwarfRegNum<[492]>;
def C237 : CRF<237, "$a59_y", ["$a59.y"]>, DwarfRegNum<[493]>;
def C238 : CRF<238, "$a59_z", ["$a59.z"]>, DwarfRegNum<[494]>;
def C239 : CRF<239, "$a59_t", ["$a59.t"]>, DwarfRegNum<[495]>;
def C240 : CRF<240, "$a60_x", ["$a60.x"]>, DwarfRegNum<[496]>;
def C241 : CRF<241, "$a60_y", ["$a60.y"]>, DwarfRegNum<[497]>;
def C242 : CRF<242, "$a60_z", ["$a60.z"]>, DwarfRegNum<[498]>;
def C243 : CRF<243, "$a60_t", ["$a60.t"]>, DwarfRegNum<[499]>;
def C244 : CRF<244, "$a61_x", ["$a61.x"]>, DwarfRegNum<[500]>;
def C245 : CRF<245, "$a61_y", ["$a61.y"]>, DwarfRegNum<[501]>;
def C246 : CRF<246, "$a61_z", ["$a61.z"]>, DwarfRegNum<[502]>;
def C247 : CRF<247, "$a61_t", ["$a61.t"]>, DwarfRegNum<[503]>;
def C248 : CRF<248, "$a62_x", ["$a62.x"]>, DwarfRegNum<[504]>;
def C249 : CRF<249, "$a62_y", ["$a62.y"]>, DwarfRegNum<[505]>;
def C250 : CRF<250, "$a62_z", ["$a62.z"]>, DwarfRegNum<[506]>;
def C251 : CRF<251, "$a62_t", ["$a62.t"]>, DwarfRegNum<[507]>;
def C252 : CRF<252, "$a63_x", ["$a63.x"]>, DwarfRegNum<[508]>;
def C253 : CRF<253, "$a63_y", ["$a63.y"]>, DwarfRegNum<[509]>;
def C254 : CRF<254, "$a63_z", ["$a63.z"]>, DwarfRegNum<[510]>;
def C255 : CRF<255, "$a63_t", ["$a63.t"]>, DwarfRegNum<[511]>;


// Block Register File
def B0   : BRF<  0,  "$a0_lo", [  C0,   C1],  ["$a0.lo"]>;
def B1   : BRF<  1,  "$a0_hi", [  C2,   C3],  ["$a0.hi"]>;
def B2   : BRF<  2,  "$a1_lo", [  C4,   C5],  ["$a1.lo"]>;
def B3   : BRF<  3,  "$a1_hi", [  C6,   C7],  ["$a1.hi"]>;
def B4   : BRF<  4,  "$a2_lo", [  C8,   C9],  ["$a2.lo"]>;
def B5   : BRF<  5,  "$a2_hi", [ C10,  C11],  ["$a2.hi"]>;
def B6   : BRF<  6,  "$a3_lo", [ C12,  C13],  ["$a3.lo"]>;
def B7   : BRF<  7,  "$a3_hi", [ C14,  C15],  ["$a3.hi"]>;
def B8   : BRF<  8,  "$a4_lo", [ C16,  C17],  ["$a4.lo"]>;
def B9   : BRF<  9,  "$a4_hi", [ C18,  C19],  ["$a4.hi"]>;
def B10  : BRF< 10,  "$a5_lo", [ C20,  C21],  ["$a5.lo"]>;
def B11  : BRF< 11,  "$a5_hi", [ C22,  C23],  ["$a5.hi"]>;
def B12  : BRF< 12,  "$a6_lo", [ C24,  C25],  ["$a6.lo"]>;
def B13  : BRF< 13,  "$a6_hi", [ C26,  C27],  ["$a6.hi"]>;
def B14  : BRF< 14,  "$a7_lo", [ C28,  C29],  ["$a7.lo"]>;
def B15  : BRF< 15,  "$a7_hi", [ C30,  C31],  ["$a7.hi"]>;
def B16  : BRF< 16,  "$a8_lo", [ C32,  C33],  ["$a8.lo"]>;
def B17  : BRF< 17,  "$a8_hi", [ C34,  C35],  ["$a8.hi"]>;
def B18  : BRF< 18,  "$a9_lo", [ C36,  C37],  ["$a9.lo"]>;
def B19  : BRF< 19,  "$a9_hi", [ C38,  C39],  ["$a9.hi"]>;
def B20  : BRF< 20, "$a10_lo", [ C40,  C41], ["$a10.lo"]>;
def B21  : BRF< 21, "$a10_hi", [ C42,  C43], ["$a10.hi"]>;
def B22  : BRF< 22, "$a11_lo", [ C44,  C45], ["$a11.lo"]>;
def B23  : BRF< 23, "$a11_hi", [ C46,  C47], ["$a11.hi"]>;
def B24  : BRF< 24, "$a12_lo", [ C48,  C49], ["$a12.lo"]>;
def B25  : BRF< 25, "$a12_hi", [ C50,  C51], ["$a12.hi"]>;
def B26  : BRF< 26, "$a13_lo", [ C52,  C53], ["$a13.lo"]>;
def B27  : BRF< 27, "$a13_hi", [ C54,  C55], ["$a13.hi"]>;
def B28  : BRF< 28, "$a14_lo", [ C56,  C57], ["$a14.lo"]>;
def B29  : BRF< 29, "$a14_hi", [ C58,  C59], ["$a14.hi"]>;
def B30  : BRF< 30, "$a15_lo", [ C60,  C61], ["$a15.lo"]>;
def B31  : BRF< 31, "$a15_hi", [ C62,  C63], ["$a15.hi"]>;
def B32  : BRF< 32, "$a16_lo", [ C64,  C65], ["$a16.lo"]>;
def B33  : BRF< 33, "$a16_hi", [ C66,  C67], ["$a16.hi"]>;
def B34  : BRF< 34, "$a17_lo", [ C68,  C69], ["$a17.lo"]>;
def B35  : BRF< 35, "$a17_hi", [ C70,  C71], ["$a17.hi"]>;
def B36  : BRF< 36, "$a18_lo", [ C72,  C73], ["$a18.lo"]>;
def B37  : BRF< 37, "$a18_hi", [ C74,  C75], ["$a18.hi"]>;
def B38  : BRF< 38, "$a19_lo", [ C76,  C77], ["$a19.lo"]>;
def B39  : BRF< 39, "$a19_hi", [ C78,  C79], ["$a19.hi"]>;
def B40  : BRF< 40, "$a20_lo", [ C80,  C81], ["$a20.lo"]>;
def B41  : BRF< 41, "$a20_hi", [ C82,  C83], ["$a20.hi"]>;
def B42  : BRF< 42, "$a21_lo", [ C84,  C85], ["$a21.lo"]>;
def B43  : BRF< 43, "$a21_hi", [ C86,  C87], ["$a21.hi"]>;
def B44  : BRF< 44, "$a22_lo", [ C88,  C89], ["$a22.lo"]>;
def B45  : BRF< 45, "$a22_hi", [ C90,  C91], ["$a22.hi"]>;
def B46  : BRF< 46, "$a23_lo", [ C92,  C93], ["$a23.lo"]>;
def B47  : BRF< 47, "$a23_hi", [ C94,  C95], ["$a23.hi"]>;
def B48  : BRF< 48, "$a24_lo", [ C96,  C97], ["$a24.lo"]>;
def B49  : BRF< 49, "$a24_hi", [ C98,  C99], ["$a24.hi"]>;
def B50  : BRF< 50, "$a25_lo", [C100, C101], ["$a25.lo"]>;
def B51  : BRF< 51, "$a25_hi", [C102, C103], ["$a25.hi"]>;
def B52  : BRF< 52, "$a26_lo", [C104, C105], ["$a26.lo"]>;
def B53  : BRF< 53, "$a26_hi", [C106, C107], ["$a26.hi"]>;
def B54  : BRF< 54, "$a27_lo", [C108, C109], ["$a27.lo"]>;
def B55  : BRF< 55, "$a27_hi", [C110, C111], ["$a27.hi"]>;
def B56  : BRF< 56, "$a28_lo", [C112, C113], ["$a28.lo"]>;
def B57  : BRF< 57, "$a28_hi", [C114, C115], ["$a28.hi"]>;
def B58  : BRF< 58, "$a29_lo", [C116, C117], ["$a29.lo"]>;
def B59  : BRF< 59, "$a29_hi", [C118, C119], ["$a29.hi"]>;
def B60  : BRF< 60, "$a30_lo", [C120, C121], ["$a30.lo"]>;
def B61  : BRF< 61, "$a30_hi", [C122, C123], ["$a30.hi"]>;
def B62  : BRF< 62, "$a31_lo", [C124, C125], ["$a31.lo"]>;
def B63  : BRF< 63, "$a31_hi", [C126, C127], ["$a31.hi"]>;
def B64  : BRF< 64, "$a32_lo", [C128, C129], ["$a32.lo"]>;
def B65  : BRF< 65, "$a32_hi", [C130, C131], ["$a32.hi"]>;
def B66  : BRF< 66, "$a33_lo", [C132, C133], ["$a33.lo"]>;
def B67  : BRF< 67, "$a33_hi", [C134, C135], ["$a33.hi"]>;
def B68  : BRF< 68, "$a34_lo", [C136, C137], ["$a34.lo"]>;
def B69  : BRF< 69, "$a34_hi", [C138, C139], ["$a34.hi"]>;
def B70  : BRF< 70, "$a35_lo", [C140, C141], ["$a35.lo"]>;
def B71  : BRF< 71, "$a35_hi", [C142, C143], ["$a35.hi"]>;
def B72  : BRF< 72, "$a36_lo", [C144, C145], ["$a36.lo"]>;
def B73  : BRF< 73, "$a36_hi", [C146, C147], ["$a36.hi"]>;
def B74  : BRF< 74, "$a37_lo", [C148, C149], ["$a37.lo"]>;
def B75  : BRF< 75, "$a37_hi", [C150, C151], ["$a37.hi"]>;
def B76  : BRF< 76, "$a38_lo", [C152, C153], ["$a38.lo"]>;
def B77  : BRF< 77, "$a38_hi", [C154, C155], ["$a38.hi"]>;
def B78  : BRF< 78, "$a39_lo", [C156, C157], ["$a39.lo"]>;
def B79  : BRF< 79, "$a39_hi", [C158, C159], ["$a39.hi"]>;
def B80  : BRF< 80, "$a40_lo", [C160, C161], ["$a40.lo"]>;
def B81  : BRF< 81, "$a40_hi", [C162, C163], ["$a40.hi"]>;
def B82  : BRF< 82, "$a41_lo", [C164, C165], ["$a41.lo"]>;
def B83  : BRF< 83, "$a41_hi", [C166, C167], ["$a41.hi"]>;
def B84  : BRF< 84, "$a42_lo", [C168, C169], ["$a42.lo"]>;
def B85  : BRF< 85, "$a42_hi", [C170, C171], ["$a42.hi"]>;
def B86  : BRF< 86, "$a43_lo", [C172, C173], ["$a43.lo"]>;
def B87  : BRF< 87, "$a43_hi", [C174, C175], ["$a43.hi"]>;
def B88  : BRF< 88, "$a44_lo", [C176, C177], ["$a44.lo"]>;
def B89  : BRF< 89, "$a44_hi", [C178, C179], ["$a44.hi"]>;
def B90  : BRF< 90, "$a45_lo", [C180, C181], ["$a45.lo"]>;
def B91  : BRF< 91, "$a45_hi", [C182, C183], ["$a45.hi"]>;
def B92  : BRF< 92, "$a46_lo", [C184, C185], ["$a46.lo"]>;
def B93  : BRF< 93, "$a46_hi", [C186, C187], ["$a46.hi"]>;
def B94  : BRF< 94, "$a47_lo", [C188, C189], ["$a47.lo"]>;
def B95  : BRF< 95, "$a47_hi", [C190, C191], ["$a47.hi"]>;
def B96  : BRF< 96, "$a48_lo", [C192, C193], ["$a48.lo"]>;
def B97  : BRF< 97, "$a48_hi", [C194, C195], ["$a48.hi"]>;
def B98  : BRF< 98, "$a49_lo", [C196, C197], ["$a49.lo"]>;
def B99  : BRF< 99, "$a49_hi", [C198, C199], ["$a49.hi"]>;
def B100 : BRF<100, "$a50_lo", [C200, C201], ["$a50.lo"]>;
def B101 : BRF<101, "$a50_hi", [C202, C203], ["$a50.hi"]>;
def B102 : BRF<102, "$a51_lo", [C204, C205], ["$a51.lo"]>;
def B103 : BRF<103, "$a51_hi", [C206, C207], ["$a51.hi"]>;
def B104 : BRF<104, "$a52_lo", [C208, C209], ["$a52.lo"]>;
def B105 : BRF<105, "$a52_hi", [C210, C211], ["$a52.hi"]>;
def B106 : BRF<106, "$a53_lo", [C212, C213], ["$a53.lo"]>;
def B107 : BRF<107, "$a53_hi", [C214, C215], ["$a53.hi"]>;
def B108 : BRF<108, "$a54_lo", [C216, C217], ["$a54.lo"]>;
def B109 : BRF<109, "$a54_hi", [C218, C219], ["$a54.hi"]>;
def B110 : BRF<110, "$a55_lo", [C220, C221], ["$a55.lo"]>;
def B111 : BRF<111, "$a55_hi", [C222, C223], ["$a55.hi"]>;
def B112 : BRF<112, "$a56_lo", [C224, C225], ["$a56.lo"]>;
def B113 : BRF<113, "$a56_hi", [C226, C227], ["$a56.hi"]>;
def B114 : BRF<114, "$a57_lo", [C228, C229], ["$a57.lo"]>;
def B115 : BRF<115, "$a57_hi", [C230, C231], ["$a57.hi"]>;
def B116 : BRF<116, "$a58_lo", [C232, C233], ["$a58.lo"]>;
def B117 : BRF<117, "$a58_hi", [C234, C235], ["$a58.hi"]>;
def B118 : BRF<118, "$a59_lo", [C236, C237], ["$a59.lo"]>;
def B119 : BRF<119, "$a59_hi", [C238, C239], ["$a59.hi"]>;
def B120 : BRF<120, "$a60_lo", [C240, C241], ["$a60.lo"]>;
def B121 : BRF<121, "$a60_hi", [C242, C243], ["$a60.hi"]>;
def B122 : BRF<122, "$a61_lo", [C244, C245], ["$a61.lo"]>;
def B123 : BRF<123, "$a61_hi", [C246, C247], ["$a61.hi"]>;
def B124 : BRF<124, "$a62_lo", [C248, C249], ["$a62.lo"]>;
def B125 : BRF<125, "$a62_hi", [C250, C251], ["$a62.hi"]>;
def B126 : BRF<126, "$a63_lo", [C252, C253], ["$a63.lo"]>;
def B127 : BRF<127, "$a63_hi", [C254, C255], ["$a63.hi"]>;


// Accelerator Register File
def A0  : ARF< 0,  "$a0", [  C0,   C1,   C2,   C3]>;
def A1  : ARF< 1,  "$a1", [  C4,   C5,   C6,   C7]>;
def A2  : ARF< 2,  "$a2", [  C8,   C9,  C10,  C11]>;
def A3  : ARF< 3,  "$a3", [ C12,  C13,  C14,  C15]>;
def A4  : ARF< 4,  "$a4", [ C16,  C17,  C18,  C19]>;
def A5  : ARF< 5,  "$a5", [ C20,  C21,  C22,  C23]>;
def A6  : ARF< 6,  "$a6", [ C24,  C25,  C26,  C27]>;
def A7  : ARF< 7,  "$a7", [ C28,  C29,  C30,  C31]>;
def A8  : ARF< 8,  "$a8", [ C32,  C33,  C34,  C35]>;
def A9  : ARF< 9,  "$a9", [ C36,  C37,  C38,  C39]>;
def A10 : ARF<10, "$a10", [ C40,  C41,  C42,  C43]>;
def A11 : ARF<11, "$a11", [ C44,  C45,  C46,  C47]>;
def A12 : ARF<12, "$a12", [ C48,  C49,  C50,  C51]>;
def A13 : ARF<13, "$a13", [ C52,  C53,  C54,  C55]>;
def A14 : ARF<14, "$a14", [ C56,  C57,  C58,  C59]>;
def A15 : ARF<15, "$a15", [ C60,  C61,  C62,  C63]>;
def A16 : ARF<16, "$a16", [ C64,  C65,  C66,  C67]>;
def A17 : ARF<17, "$a17", [ C68,  C69,  C70,  C71]>;
def A18 : ARF<18, "$a18", [ C72,  C73,  C74,  C75]>;
def A19 : ARF<19, "$a19", [ C76,  C77,  C78,  C79]>;
def A20 : ARF<20, "$a20", [ C80,  C81,  C82,  C83]>;
def A21 : ARF<21, "$a21", [ C84,  C85,  C86,  C87]>;
def A22 : ARF<22, "$a22", [ C88,  C89,  C90,  C91]>;
def A23 : ARF<23, "$a23", [ C92,  C93,  C94,  C95]>;
def A24 : ARF<24, "$a24", [ C96,  C97,  C98,  C99]>;
def A25 : ARF<25, "$a25", [C100, C101, C102, C103]>;
def A26 : ARF<26, "$a26", [C104, C105, C106, C107]>;
def A27 : ARF<27, "$a27", [C108, C109, C110, C111]>;
def A28 : ARF<28, "$a28", [C112, C113, C114, C115]>;
def A29 : ARF<29, "$a29", [C116, C117, C118, C119]>;
def A30 : ARF<30, "$a30", [C120, C121, C122, C123]>;
def A31 : ARF<31, "$a31", [C124, C125, C126, C127]>;
def A32 : ARF<32, "$a32", [C128, C129, C130, C131]>;
def A33 : ARF<33, "$a33", [C132, C133, C134, C135]>;
def A34 : ARF<34, "$a34", [C136, C137, C138, C139]>;
def A35 : ARF<35, "$a35", [C140, C141, C142, C143]>;
def A36 : ARF<36, "$a36", [C144, C145, C146, C147]>;
def A37 : ARF<37, "$a37", [C148, C149, C150, C151]>;
def A38 : ARF<38, "$a38", [C152, C153, C154, C155]>;
def A39 : ARF<39, "$a39", [C156, C157, C158, C159]>;
def A40 : ARF<40, "$a40", [C160, C161, C162, C163]>;
def A41 : ARF<41, "$a41", [C164, C165, C166, C167]>;
def A42 : ARF<42, "$a42", [C168, C169, C170, C171]>;
def A43 : ARF<43, "$a43", [C172, C173, C174, C175]>;
def A44 : ARF<44, "$a44", [C176, C177, C178, C179]>;
def A45 : ARF<45, "$a45", [C180, C181, C182, C183]>;
def A46 : ARF<46, "$a46", [C184, C185, C186, C187]>;
def A47 : ARF<47, "$a47", [C188, C189, C190, C191]>;
def A48 : ARF<48, "$a48", [C192, C193, C194, C195]>;
def A49 : ARF<49, "$a49", [C196, C197, C198, C199]>;
def A50 : ARF<50, "$a50", [C200, C201, C202, C203]>;
def A51 : ARF<51, "$a51", [C204, C205, C206, C207]>;
def A52 : ARF<52, "$a52", [C208, C209, C210, C211]>;
def A53 : ARF<53, "$a53", [C212, C213, C214, C215]>;
def A54 : ARF<54, "$a54", [C216, C217, C218, C219]>;
def A55 : ARF<55, "$a55", [C220, C221, C222, C223]>;
def A56 : ARF<56, "$a56", [C224, C225, C226, C227]>;
def A57 : ARF<57, "$a57", [C228, C229, C230, C231]>;
def A58 : ARF<58, "$a58", [C232, C233, C234, C235]>;
def A59 : ARF<59, "$a59", [C236, C237, C238, C239]>;
def A60 : ARF<60, "$a60", [C240, C241, C242, C243]>;
def A61 : ARF<61, "$a61", [C244, C245, C246, C247]>;
def A62 : ARF<62, "$a62", [C248, C249, C250, C251]>;
def A63 : ARF<63, "$a63", [C252, C253, C254, C255]>;


// Wide Register File
def W0  : WRF< 0,   "$a0a1", [  C0,   C1,   C2,   C3,   C4,   C5,   C6,   C7]>;
def W1  : WRF< 1,   "$a2a3", [  C8,   C9,  C10,  C11,  C12,  C13,  C14,  C15]>;
def W2  : WRF< 2,   "$a4a5", [ C16,  C17,  C18,  C19,  C20,  C21,  C22,  C23]>;
def W3  : WRF< 3,   "$a6a7", [ C24,  C25,  C26,  C27,  C28,  C29,  C30,  C31]>;
def W4  : WRF< 4,   "$a8a9", [ C32,  C33,  C34,  C35,  C36,  C37,  C38,  C39]>;
def W5  : WRF< 5, "$a10a11", [ C40,  C41,  C42,  C43,  C44,  C45,  C46,  C47]>;
def W6  : WRF< 6, "$a12a13", [ C48,  C49,  C50,  C51,  C52,  C53,  C54,  C55]>;
def W7  : WRF< 7, "$a14a15", [ C56,  C57,  C58,  C59,  C60,  C61,  C62,  C63]>;
def W8  : WRF< 8, "$a16a17", [ C64,  C65,  C66,  C67,  C68,  C69,  C70,  C71]>;
def W9  : WRF< 9, "$a18a19", [ C72,  C73,  C74,  C75,  C76,  C77,  C78,  C79]>;
def W10 : WRF<10, "$a20a21", [ C80,  C81,  C82,  C83,  C84,  C85,  C86,  C87]>;
def W11 : WRF<11, "$a22a23", [ C88,  C89,  C90,  C91,  C92,  C93,  C94,  C95]>;
def W12 : WRF<12, "$a24a25", [ C96,  C97,  C98,  C99, C100, C101, C102, C103]>;
def W13 : WRF<13, "$a26a27", [C104, C105, C106, C107, C108, C109, C110, C111]>;
def W14 : WRF<14, "$a28a29", [C112, C113, C114, C115, C116, C117, C118, C119]>;
def W15 : WRF<15, "$a30a31", [C120, C121, C122, C123, C124, C125, C126, C127]>;
def W16 : WRF<16, "$a32a33", [C128, C129, C130, C131, C132, C133, C134, C135]>;
def W17 : WRF<17, "$a34a35", [C136, C137, C138, C139, C140, C141, C142, C143]>;
def W18 : WRF<18, "$a36a37", [C144, C145, C146, C147, C148, C149, C150, C151]>;
def W19 : WRF<19, "$a38a39", [C152, C153, C154, C155, C156, C157, C158, C159]>;
def W20 : WRF<20, "$a40a41", [C160, C161, C162, C163, C164, C165, C166, C167]>;
def W21 : WRF<21, "$a42a43", [C168, C169, C170, C171, C172, C173, C174, C175]>;
def W22 : WRF<22, "$a44a45", [C176, C177, C178, C179, C180, C181, C182, C183]>;
def W23 : WRF<23, "$a46a47", [C184, C185, C186, C187, C188, C189, C190, C191]>;
def W24 : WRF<24, "$a48a49", [C192, C193, C194, C195, C196, C197, C198, C199]>;
def W25 : WRF<25, "$a50a51", [C200, C201, C202, C203, C204, C205, C206, C207]>;
def W26 : WRF<26, "$a52a53", [C208, C209, C210, C211, C212, C213, C214, C215]>;
def W27 : WRF<27, "$a54a55", [C216, C217, C218, C219, C220, C221, C222, C223]>;
def W28 : WRF<28, "$a56a57", [C224, C225, C226, C227, C228, C229, C230, C231]>;
def W29 : WRF<29, "$a58a59", [C232, C233, C234, C235, C236, C237, C238, C239]>;
def W30 : WRF<30, "$a60a61", [C240, C241, C242, C243, C244, C245, C246, C247]>;
def W31 : WRF<31, "$a62a63", [C248, C249, C250, C251, C252, C253, C254, C255]>;


// Extended Register File
def X0  : XRF< 0,     "$a0a1a2a3", [  C0,   C1,   C2,   C3,   C4,   C5,   C6,   C7,   C8,   C9,  C10,  C11,  C12,  C13,  C14,  C15]>;
def X1  : XRF< 1,     "$a4a5a6a7", [ C16,  C17,  C18,  C19,  C20,  C21,  C22,  C23,  C24,  C25,  C26,  C27,  C28,  C29,  C30,  C31]>;
def X2  : XRF< 2,   "$a8a9a10a11", [ C32,  C33,  C34,  C35,  C36,  C37,  C38,  C39,  C40,  C41,  C42,  C43,  C44,  C45,  C46,  C47]>;
def X3  : XRF< 3, "$a12a13a14a15", [ C48,  C49,  C50,  C51,  C52,  C53,  C54,  C55,  C56,  C57,  C58,  C59,  C60,  C61,  C62,  C63]>;
def X4  : XRF< 4, "$a16a17a18a19", [ C64,  C65,  C66,  C67,  C68,  C69,  C70,  C71,  C72,  C73,  C74,  C75,  C76,  C77,  C78,  C79]>;
def X5  : XRF< 5, "$a20a21a22a23", [ C80,  C81,  C82,  C83,  C84,  C85,  C86,  C87,  C88,  C89,  C90,  C91,  C92,  C93,  C94,  C95]>;
def X6  : XRF< 6, "$a24a25a26a27", [ C96,  C97,  C98,  C99, C100, C101, C102, C103, C104, C105, C106, C107, C108, C109, C110, C111]>;
def X7  : XRF< 7, "$a28a29a30a31", [C112, C113, C114, C115, C116, C117, C118, C119, C120, C121, C122, C123, C124, C125, C126, C127]>;
def X8  : XRF< 8, "$a32a33a34a35", [C128, C129, C130, C131, C132, C133, C134, C135, C136, C137, C138, C139, C140, C141, C142, C143]>;
def X9  : XRF< 9, "$a36a37a38a39", [C144, C145, C146, C147, C148, C149, C150, C151, C152, C153, C154, C155, C156, C157, C158, C159]>;
def X10 : XRF<10, "$a40a41a42a43", [C160, C161, C162, C163, C164, C165, C166, C167, C168, C169, C170, C171, C172, C173, C174, C175]>;
def X11 : XRF<11, "$a44a45a46a47", [C176, C177, C178, C179, C180, C181, C182, C183, C184, C185, C186, C187, C188, C189, C190, C191]>;
def X12 : XRF<12, "$a48a49a50a51", [C192, C193, C194, C195, C196, C197, C198, C199, C200, C201, C202, C203, C204, C205, C206, C207]>;
def X13 : XRF<13, "$a52a53a54a55", [C208, C209, C210, C211, C212, C213, C214, C215, C216, C217, C218, C219, C220, C221, C222, C223]>;
def X14 : XRF<14, "$a56a57a58a59", [C224, C225, C226, C227, C228, C229, C230, C231, C232, C233, C234, C235, C236, C237, C238, C239]>;
def X15 : XRF<15, "$a60a61a62a63", [C240, C241, C242, C243, C244, C245, C246, C247, C248, C249, C250, C251, C252, C253, C254, C255]>;


} // let Namespace = "K1C"


// SRF - System Register File
def SystemReg : RegisterClass<"K1C",
  [i1, i8, i16, i32, i64, f16, f32, f64, v8i8, v4i16, v2i32, v4f16, v2f32],
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

// GRF - General Register File
let Size = 64 in
def SingleReg : RegisterClass<"K1C",
  [i64, i1, i8, i16, i32, f16, f32, f64, v8i8, v4i16, v2i32, v4f16, v2f32],
  64, (add
    R0,  R1,  R2,  R3,  R4,  R5,  R6,  R7,  R8,  R9, R10, R11, R12, R13, R14,
   R15, R16, R17, R18, R19, R20, R21, R22, R23, R24, R25, R26, R27, R28, R29,
   R30, R31, R32, R33, R34, R35, R36, R37, R38, R39, R40, R41, R42, R43, R44,
   R45, R46, R47, R48, R49, R50, R51, R52, R53, R54, R55, R56, R57, R58, R59,
   R60, R61, R62, R63)>;

// PRF - Paired Register File
let Size = 128 in
def PairedReg : RegisterClass<"K1C",
  [v16i8, v8i16, v4i32, v2i64, v8f16, v4f32, v2f64],
  128, (add
    P0,  P2,  P4,  P6,  P8, P10, P12, P14, P16, P18, P20, P22, P24, P26, P28,
   P30, P32, P34, P36, P38, P40, P42, P44, P46, P48, P50, P52, P54, P56, P58,
   P60, P62)>;

// QRF - Quadruple Register File
def QuadReg : RegisterClass<"K1C",
  [v32i8, v16i16, v8i32, v4i64, v8f32, v4f64],
  256, (add
    Q0,  Q4,  Q8, Q12, Q16, Q20, Q24, Q28, Q32, Q36, Q40, Q44, Q48, Q52, Q56,
   Q60)>;

// CRF - Coprocessor Register File
def CoproReg : RegisterClass<"K1C",
  [i1, i8, i16, i32, i64, f16, f32, f64, v8i8, v4i16, v2i32, v4f16, v2f32],
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

// BRF - Block Register File
def BlockReg : RegisterClass<"K1C",
  [v16i8, v8i16, v4i32, v2i64, v8f16, v4f32, v2f64],
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

// ARF - Accelerator Register File
def AccelReg : RegisterClass<"K1C",
  [v32i8, v16i16, v8i32, v4i64, v8f32, v4f64],
  256, (add
    A0,  A1,  A2,  A3,  A4,  A5,  A6,  A7,  A8,  A9, A10, A11, A12, A13, A14,
   A15, A16, A17, A18, A19, A20, A21, A22, A23, A24, A25, A26, A27, A28, A29,
   A30, A31, A32, A33, A34, A35, A36, A37, A38, A39, A40, A41, A42, A43, A44,
   A45, A46, A47, A48, A49, A50, A51, A52, A53, A54, A55, A56, A57, A58, A59,
   A60, A61, A62, A63)>;

// WRF - Wide Register File
def WideReg : RegisterClass<"K1C",
  [v64i8, v32i16, v16i32, v8i64, v16f32, v8f64],
  512, (add
    W0,  W1,  W2,  W3,  W4,  W5,  W6,  W7,  W8,  W9, W10, W11, W12, W13, W14,
   W15, W16, W17, W18, W19, W20, W21, W22, W23, W24, W25, W26, W27, W28, W29,
   W30, W31)>;

// XRF - Extended Register File
def ExtendReg : RegisterClass<"K1C",
  // XRF also support v64f16, v32f32, and v16f64 types but not LLVM
  [v128i8, v64i16, v32i32, v16i64],
  1024, (add
    X0,  X1,  X2,  X3,  X4,  X5,  X6,  X7,  X8,  X9, X10, X11, X12, X13, X14,
   X15)>;

// SRF - Singleton RegClas with PS
def AloneReg : RegisterClass<"K1C",
  [i1, i8, i16, i32, i64, f16, f32, f64, v8i8, v4i16, v2i32, v4f16, v2f32],
  64, (add
        PS,     MMC, SPS_PL0, SPS_PL1, SPS_PL2, SPS_PL3,    SYOW,    HTOW,
      ITOW,     DOW,     MOW,    PSOW,     SPS)>;

// ARF - Accelerator Registers Even Numbered
def AccelRegE : RegisterClass<"K1C",
  [v32i8, v16i16, v8i32, v4i64, v8f32, v4f64],
  256, (add
    A0,  A2,  A4,  A6,  A8, A10, A12, A14, A16, A18, A20, A22, A24, A26, A28,
   A30, A32, A34, A36, A38, A40, A42, A44, A46, A48, A50, A52, A54, A56, A58,
   A60, A62)>;

// ARF - Accelerator Registers Odd Numbered
def AccelRegO : RegisterClass<"K1C",
  [v32i8, v16i16, v8i32, v4i64, v8f32, v4f64],
  256, (add
    A1,  A3,  A5,  A7,  A9, A11, A13, A15, A17, A19, A21, A23, A25, A27, A29,
   A31, A33, A35, A37, A39, A41, A43, A45, A47, A49, A51, A53, A55, A57, A59,
   A61, A63)>;

// BRF - Block Registers Even Numbered
def BlockRegE : RegisterClass<"K1C",
  [v16i8, v8i16, v4i32, v2i64, v8f16, v4f32, v2f64],
  128, (add
     B0,   B2,   B4,   B6,   B8,  B10,  B12,  B14,  B16,  B18,  B20,  B22,
    B24,  B26,  B28,  B30,  B32,  B34,  B36,  B38,  B40,  B42,  B44,  B46,
    B48,  B50,  B52,  B54,  B56,  B58,  B60,  B62,  B64,  B66,  B68,  B70,
    B72,  B74,  B76,  B78,  B80,  B82,  B84,  B86,  B88,  B90,  B92,  B94,
    B96,  B98, B100, B102, B104, B106, B108, B110, B112, B114, B116, B118,
   B120, B122, B124, B126)>;

// BRF - Block Registers Odd Numbered
def BlockRegO : RegisterClass<"K1C",
  [v16i8, v8i16, v4i32, v2i64, v8f16, v4f32, v2f64],
  128, (add
     B1,   B3,   B5,   B7,   B9,  B11,  B13,  B15,  B17,  B19,  B21,  B23,
    B25,  B27,  B29,  B31,  B33,  B35,  B37,  B39,  B41,  B43,  B45,  B47,
    B49,  B51,  B53,  B55,  B57,  B59,  B61,  B63,  B65,  B67,  B69,  B71,
    B73,  B75,  B77,  B79,  B81,  B83,  B85,  B87,  B89,  B91,  B93,  B95,
    B97,  B99, B101, B103, B105, B107, B109, B111, B113, B115, B117, B119,
   B121, B123, B125, B127)>;

// BRF - Block Registers 0 Modulo 4
def BlockReg0M4 : RegisterClass<"K1C",
  [v16i8, v8i16, v4i32, v2i64, v8f16, v4f32, v2f64],
  128, (add
     B0,   B4,   B8,  B12,  B16,  B20,  B24,  B28,  B32,  B36,  B40,  B44,
    B48,  B52,  B56,  B60,  B64,  B68,  B72,  B76,  B80,  B84,  B88,  B92,
    B96, B100, B104, B108, B112, B116, B120, B124)>;

// BRF - Block Registers 1 Modulo 4
def BlockReg1M4 : RegisterClass<"K1C",
  [v16i8, v8i16, v4i32, v2i64, v8f16, v4f32, v2f64],
  128, (add
     B1,   B5,   B9,  B13,  B17,  B21,  B25,  B29,  B33,  B37,  B41,  B45,
    B49,  B53,  B57,  B61,  B65,  B69,  B73,  B77,  B81,  B85,  B89,  B93,
    B97, B101, B105, B109, B113, B117, B121, B125)>;

// BRF - Block Registers 2 Modulo 4
def BlockReg2M4 : RegisterClass<"K1C",
  [v16i8, v8i16, v4i32, v2i64, v8f16, v4f32, v2f64],
  128, (add
     B2,   B6,  B10,  B14,  B18,  B22,  B26,  B30,  B34,  B38,  B42,  B46,
    B50,  B54,  B58,  B62,  B66,  B70,  B74,  B78,  B82,  B86,  B90,  B94,
    B98, B102, B106, B110, B114, B118, B122, B126)>;

// BRF - Block Registers 3 Modulo 4
def BlockReg3M4 : RegisterClass<"K1C",
  [v16i8, v8i16, v4i32, v2i64, v8f16, v4f32, v2f64],
  128, (add
     B3,   B7,  B11,  B15,  B19,  B23,  B27,  B31,  B35,  B39,  B43,  B47,
    B51,  B55,  B59,  B63,  B67,  B71,  B75,  B79,  B83,  B87,  B91,  B95,
    B99, B103, B107, B111, B115, B119, B123, B127)>;

// CRF - Coprocessor Registers 0 Modulo 4
def CoproReg0M4 : RegisterClass<"K1C",
  [i1, i8, i16, i32, i64, f16, f32, f64, v8i8, v4i16, v2i32, v4f16, v2f32],
  64, (add
     C0,   C4,   C8,  C12,  C16,  C20,  C24,  C28,  C32,  C36,  C40,  C44,
    C48,  C52,  C56,  C60,  C64,  C68,  C72,  C76,  C80,  C84,  C88,  C92,
    C96, C100, C104, C108, C112, C116, C120, C124, C128, C132, C136, C140,
   C144, C148, C152, C156, C160, C164, C168, C172, C176, C180, C184, C188,
   C192, C196, C200, C204, C208, C212, C216, C220, C224, C228, C232, C236,
   C240, C244, C248, C252)>;

// CRF - Coprocessor Registers 1 Modulo 4
def CoproReg1M4 : RegisterClass<"K1C",
  [i1, i8, i16, i32, i64, f16, f32, f64, v8i8, v4i16, v2i32, v4f16, v2f32],
  64, (add
     C1,   C5,   C9,  C13,  C17,  C21,  C25,  C29,  C33,  C37,  C41,  C45,
    C49,  C53,  C57,  C61,  C65,  C69,  C73,  C77,  C81,  C85,  C89,  C93,
    C97, C101, C105, C109, C113, C117, C121, C125, C129, C133, C137, C141,
   C145, C149, C153, C157, C161, C165, C169, C173, C177, C181, C185, C189,
   C193, C197, C201, C205, C209, C213, C217, C221, C225, C229, C233, C237,
   C241, C245, C249, C253)>;

// CRF - Coprocessor Registers 2 Modulo 4
def CoproReg2M4 : RegisterClass<"K1C",
  [i1, i8, i16, i32, i64, f16, f32, f64, v8i8, v4i16, v2i32, v4f16, v2f32],
  64, (add
     C2,   C6,  C10,  C14,  C18,  C22,  C26,  C30,  C34,  C38,  C42,  C46,
    C50,  C54,  C58,  C62,  C66,  C70,  C74,  C78,  C82,  C86,  C90,  C94,
    C98, C102, C106, C110, C114, C118, C122, C126, C130, C134, C138, C142,
   C146, C150, C154, C158, C162, C166, C170, C174, C178, C182, C186, C190,
   C194, C198, C202, C206, C210, C214, C218, C222, C226, C230, C234, C238,
   C242, C246, C250, C254)>;

// CRF - Coprocessor Registers 3 Modulo 4
def CoproReg3M4 : RegisterClass<"K1C",
  [i1, i8, i16, i32, i64, f16, f32, f64, v8i8, v4i16, v2i32, v4f16, v2f32],
  64, (add
     C3,   C7,  C11,  C15,  C19,  C23,  C27,  C31,  C35,  C39,  C43,  C47,
    C51,  C55,  C59,  C63,  C67,  C71,  C75,  C79,  C83,  C87,  C91,  C95,
    C99, C103, C107, C111, C115, C119, C123, C127, C131, C135, C139, C143,
   C147, C151, C155, C159, C163, C167, C171, C175, C179, C183, C187, C191,
   C195, C199, C203, C207, C211, C215, C219, C223, C227, C231, C235, C239,
   C243, C247, C251, C255)>;

// Only FX System Registers without PS
def OnlyfxReg : RegisterClass<"K1C",
  [i1, i8, i16, i32, i64, f16, f32, f64, v8i8, v4i16, v2i32, v4f16, v2f32],
  64, (add
   PCR, CS, CSIT, IPE, MEN, PMC, TCR, ILE, ILL, ILR, MMC, TEL, TEH, DC,
   MES, WS, SPS_PL0, SPS_PL1, SPS_PL2, SPS_PL3, ES_PL0, ES_PL1, ES_PL2,
   ES_PL3, SPS, ES)>;

// Only RA Register
let Size = 64 in
def OnlyraReg : RegisterClass<"K1C",
  [i1, i8, i16, i32, i64, f16, f32, f64, v8i8, v4i16, v2i32, v4f16, v2f32],
  64, (add RA)>;
