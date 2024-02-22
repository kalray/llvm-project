//===-- KVXRegisterInfo.td - KVX Register defs -------------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
//  Declarations that describe the KVX register files
//===----------------------------------------------------------------------===//

// Last update: 2022-10-04 00:58:11.349922


let Namespace = "KVX" in {
include "KVXSubRegisterInfo.td"

let FallbackRegAltNameIndex = NoRegAltName in
def BuffName : RegAltNameIndex;
def LoHiXYZT : RegAltNameIndex;

// SFR - System Function Registers
class SFR<bits<9> num, string n, list<string> alt = []> : Register<n, alt> {
  let HWEncoding{8-0} = num;
}

// GPR - General-Purpose Registers
class GPR<bits<6> num, string n, list<string> alt = []> : Register<n, alt> {
        let HWEncoding{5-0} = num;
}

// PGR - Paired General Registers
class PGR<bits<5> num, string n, list<Register> subregs, list<string> alt = []> : RegisterWithSubRegs<n, subregs> {
  list<string> AltNames = alt;
  let CoveredBySubRegs = 1;
  let HWEncoding{4-0} = num;
  let SubRegIndices = [sub_d0, sub_d1];
}

// QGR - Quadruple General Registers
class QGR<bits<4> num, string n, list<Register> subregs, list<string> alt = []> : RegisterWithSubRegs<n, subregs> {
  list<string> AltNames = alt;
  let CoveredBySubRegs = 1;
  let HWEncoding{3-0} = num;
  let SubRegIndices = [sub_q0, sub_q1];
}

// XCR - Extension Coprocessor Registers
class XCR<bits<8> num, string n, list<string> alt = []> : Register<n, alt> {
  let HWEncoding{7-0} = num;
}

// XBR - Extension Block Registers
class XBR<bits<7> num, string n, list<Register> subregs, list<string> alt = []> : RegisterWithSubRegs<n, subregs> {
  list<string> AltNames = alt;
  let CoveredBySubRegs = 1;
  let HWEncoding{6-0} = num;
  let SubRegIndices = [sub_d0, sub_d1];
}

// XVR - Extension Vector Registers
class XVR<bits<6> num, string n, list<Register> subregs, list<string> alt = []> : RegisterWithSubRegs<n, subregs> {
  list<string> AltNames = alt;
  let CoveredBySubRegs = 1;
  let HWEncoding{5-0} = num;
  let SubRegIndices = [sub_q0, sub_q1];
}

// XWR - Extension Wide Registers
let RegAltNameIndices = [LoHiXYZT, BuffName] in
class XWR<bits<5> num, string n, list<Register> subregs, list<string> alt = []> : RegisterWithSubRegs<n, subregs> {
  list<string> AltNames = alt;
  let CoveredBySubRegs = 1;
  let HWEncoding{4-0} = num;
  let SubRegIndices = [sub_v0, sub_v1];
}

// XMR - Extension Matrix Registers
let RegAltNameIndices = [BuffName] in
class XMR<bits<4> num, string n, list<Register> subregs, list<string> alt = []> : RegisterWithSubRegs<n, subregs> {
  list<string> AltNames = alt;
  let CoveredBySubRegs = 1;
  let HWEncoding{3-0} = num;
  let SubRegIndices = [sub_w0, sub_w1];
}

class X8R<bits<3> num, string n, list<Register> subregs, list<string> alt = []> : RegisterWithSubRegs<n, subregs> {
  list<string> AltNames = alt;
  let CoveredBySubRegs = 1;
  let HWEncoding{2-0} = num;
  let SubRegIndices = [sub_m0, sub_m1];
}

class X16R<bits<2> num, string n, list<Register> subregs, list<string> alt = []> : RegisterWithSubRegs<n, subregs> {
  list<string> AltNames = alt;
  let CoveredBySubRegs = 1;
  let HWEncoding{1-0} = num;
  let SubRegIndices = [sub_2K0, sub_2K1];
}

// System Function Registers
def PC       : SFR<  0,      "$pc",                  ["$s0"]>, DwarfRegNum<[ 64]>;
def PS       : SFR<  1,      "$ps",                  ["$s1"]>, DwarfRegNum<[ 65]>;
def PCR      : SFR<  2,     "$pcr",                  ["$s2"]>, DwarfRegNum<[ 66]>;
def RA       : SFR<  3,      "$ra",                  ["$s3"]>, DwarfRegNum<[ 67]>;
def CS       : SFR<  4,      "$cs",                  ["$s4"]>, DwarfRegNum<[ 68]>;
def CSIT     : SFR<  5,    "$csit",                  ["$s5"]>, DwarfRegNum<[ 69]>;
def AESPC    : SFR<  6,   "$aespc",                  ["$s6"]>, DwarfRegNum<[ 70]>;
def LS       : SFR<  7,      "$ls",                  ["$s7"]>, DwarfRegNum<[ 71]>;
def LE       : SFR<  8,      "$le",                  ["$s8"]>, DwarfRegNum<[ 72]>;
def LC       : SFR<  9,      "$lc",                  ["$s9"]>, DwarfRegNum<[ 73]>;
def IPE      : SFR< 10,     "$ipe",                 ["$s10"]>, DwarfRegNum<[ 74]>;
def MEN      : SFR< 11,     "$men",                 ["$s11"]>, DwarfRegNum<[ 75]>;
def PMC      : SFR< 12,     "$pmc",                 ["$s12"]>, DwarfRegNum<[ 76]>;
def PM0      : SFR< 13,     "$pm0",                 ["$s13"]>, DwarfRegNum<[ 77]>;
def PM1      : SFR< 14,     "$pm1",                 ["$s14"]>, DwarfRegNum<[ 78]>;
def PM2      : SFR< 15,     "$pm2",                 ["$s15"]>, DwarfRegNum<[ 79]>;
def PM3      : SFR< 16,     "$pm3",                 ["$s16"]>, DwarfRegNum<[ 80]>;
def PMSA     : SFR< 17,    "$pmsa",                 ["$s17"]>, DwarfRegNum<[ 81]>;
def TCR      : SFR< 18,     "$tcr",                 ["$s18"]>, DwarfRegNum<[ 82]>;
def T0V      : SFR< 19,     "$t0v",                 ["$s19"]>, DwarfRegNum<[ 83]>;
def T1V      : SFR< 20,     "$t1v",                 ["$s20"]>, DwarfRegNum<[ 84]>;
def T0R      : SFR< 21,     "$t0r",                 ["$s21"]>, DwarfRegNum<[ 85]>;
def T1R      : SFR< 22,     "$t1r",                 ["$s22"]>, DwarfRegNum<[ 86]>;
def WDV      : SFR< 23,     "$wdv",                 ["$s23"]>, DwarfRegNum<[ 87]>;
def WDR      : SFR< 24,     "$wdr",                 ["$s24"]>, DwarfRegNum<[ 88]>;
def ILE      : SFR< 25,     "$ile",                 ["$s25"]>, DwarfRegNum<[ 89]>;
def ILL      : SFR< 26,     "$ill",                 ["$s26"]>, DwarfRegNum<[ 90]>;
def ILR      : SFR< 27,     "$ilr",                 ["$s27"]>, DwarfRegNum<[ 91]>;
def MMC      : SFR< 28,     "$mmc",                 ["$s28"]>, DwarfRegNum<[ 92]>;
def TEL      : SFR< 29,     "$tel",                 ["$s29"]>, DwarfRegNum<[ 93]>;
def TEH      : SFR< 30,     "$teh",                 ["$s30"]>, DwarfRegNum<[ 94]>;
def IXC      : SFR< 31,     "$ixc",                 ["$s31"]>, DwarfRegNum<[ 95]>;
def SYO      : SFR< 32,     "$syo",                 ["$s32"]>, DwarfRegNum<[ 96]>;
def HTO      : SFR< 33,     "$hto",                 ["$s33"]>, DwarfRegNum<[ 97]>;
def ITO      : SFR< 34,     "$ito",                 ["$s34"]>, DwarfRegNum<[ 98]>;
def DO       : SFR< 35,      "$do",                 ["$s35"]>, DwarfRegNum<[ 99]>;
def MO       : SFR< 36,      "$mo",                 ["$s36"]>, DwarfRegNum<[100]>;
def PSO      : SFR< 37,     "$pso",                 ["$s37"]>, DwarfRegNum<[101]>;
def TPCM0    : SFR< 38,     "$s38",     ["$res38", "$tpcm0"]>, DwarfRegNum<[102]>;
def TPCM1    : SFR< 39,     "$s39",     ["$res39", "$tpcm1"]>, DwarfRegNum<[103]>;
def DC       : SFR< 40,     "$s40",        ["$res40", "$dc"]>, DwarfRegNum<[104]>;
def DBA0     : SFR< 41,    "$dba0",                 ["$s41"]>, DwarfRegNum<[105]>;
def DBA1     : SFR< 42,    "$dba1",                 ["$s42"]>, DwarfRegNum<[106]>;
def DWA0     : SFR< 43,    "$dwa0",                 ["$s43"]>, DwarfRegNum<[107]>;
def DWA1     : SFR< 44,    "$dwa1",                 ["$s44"]>, DwarfRegNum<[108]>;
def MES      : SFR< 45,     "$mes",                 ["$s45"]>, DwarfRegNum<[109]>;
def WS       : SFR< 46,      "$ws",                 ["$s46"]>, DwarfRegNum<[110]>;
def DC0      : SFR< 47,     "$s47",       ["$res47", "$dc0"]>, DwarfRegNum<[111]>;
def DC1      : SFR< 48,     "$s48",       ["$res48", "$dc1"]>, DwarfRegNum<[112]>;
def DC2      : SFR< 49,     "$s49",       ["$res49", "$dc2"]>, DwarfRegNum<[113]>;
def DC3      : SFR< 50,     "$s50",       ["$res50", "$dc3"]>, DwarfRegNum<[114]>;
def DBA2     : SFR< 51,     "$s51",      ["$res51", "$dba2"]>, DwarfRegNum<[115]>;
def DBA3     : SFR< 52,     "$s52",      ["$res52", "$dba3"]>, DwarfRegNum<[116]>;
def DWA2     : SFR< 53,     "$s53",      ["$res53", "$dwa2"]>, DwarfRegNum<[117]>;
def DWA3     : SFR< 54,     "$s54",      ["$res54", "$dwa3"]>, DwarfRegNum<[118]>;
def TPCM2    : SFR< 55,     "$s55",     ["$res55", "$tpcm2"]>, DwarfRegNum<[119]>;
def TPCMC    : SFR< 56,     "$s56",     ["$res56", "$tpcmc"]>, DwarfRegNum<[120]>;
def PM4      : SFR< 57,     "$s57",       ["$res57", "$pm4"]>, DwarfRegNum<[121]>;
def PM5      : SFR< 58,     "$s58",       ["$res58", "$pm5"]>, DwarfRegNum<[122]>;
def PM6      : SFR< 59,     "$s59",       ["$res59", "$pm6"]>, DwarfRegNum<[123]>;
def PM7      : SFR< 60,     "$s60",       ["$res60", "$pm7"]>, DwarfRegNum<[124]>;
def PMC2     : SFR< 61,     "$s61",      ["$res61", "$pmc2"]>, DwarfRegNum<[125]>;
def SRHPC    : SFR< 62,     "$s62",     ["$res62", "$srhpc"]>, DwarfRegNum<[126]>;
def FRCC     : SFR< 63,     "$s63",      ["$res63", "$frcc"]>, DwarfRegNum<[127]>;
def SPC_PL0  : SFR< 64, "$spc_pl0",                 ["$s64"]>, DwarfRegNum<[128]>;
def SPC_PL1  : SFR< 65, "$spc_pl1",                 ["$s65"]>, DwarfRegNum<[129]>;
def SPC_PL2  : SFR< 66, "$spc_pl2",                 ["$s66"]>, DwarfRegNum<[130]>;
def SPC_PL3  : SFR< 67, "$spc_pl3",                 ["$s67"]>, DwarfRegNum<[131]>;
def SPS_PL0  : SFR< 68, "$sps_pl0",                 ["$s68"]>, DwarfRegNum<[132]>;
def SPS_PL1  : SFR< 69, "$sps_pl1",                 ["$s69"]>, DwarfRegNum<[133]>;
def SPS_PL2  : SFR< 70, "$sps_pl2",                 ["$s70"]>, DwarfRegNum<[134]>;
def SPS_PL3  : SFR< 71, "$sps_pl3",                 ["$s71"]>, DwarfRegNum<[135]>;
def EA_PL0   : SFR< 72,  "$ea_pl0",                 ["$s72"]>, DwarfRegNum<[136]>;
def EA_PL1   : SFR< 73,  "$ea_pl1",                 ["$s73"]>, DwarfRegNum<[137]>;
def EA_PL2   : SFR< 74,  "$ea_pl2",                 ["$s74"]>, DwarfRegNum<[138]>;
def EA_PL3   : SFR< 75,  "$ea_pl3",                 ["$s75"]>, DwarfRegNum<[139]>;
def EV_PL0   : SFR< 76,  "$ev_pl0",                 ["$s76"]>, DwarfRegNum<[140]>;
def EV_PL1   : SFR< 77,  "$ev_pl1",                 ["$s77"]>, DwarfRegNum<[141]>;
def EV_PL2   : SFR< 78,  "$ev_pl2",                 ["$s78"]>, DwarfRegNum<[142]>;
def EV_PL3   : SFR< 79,  "$ev_pl3",                 ["$s79"]>, DwarfRegNum<[143]>;
def SR_PL0   : SFR< 80,  "$sr_pl0",                 ["$s80"]>, DwarfRegNum<[144]>;
def SR_PL1   : SFR< 81,  "$sr_pl1",                 ["$s81"]>, DwarfRegNum<[145]>;
def SR_PL2   : SFR< 82,  "$sr_pl2",                 ["$s82"]>, DwarfRegNum<[146]>;
def SR_PL3   : SFR< 83,  "$sr_pl3",                 ["$s83"]>, DwarfRegNum<[147]>;
def ES_PL0   : SFR< 84,  "$es_pl0",                 ["$s84"]>, DwarfRegNum<[148]>;
def ES_PL1   : SFR< 85,  "$es_pl1",                 ["$s85"]>, DwarfRegNum<[149]>;
def ES_PL2   : SFR< 86,  "$es_pl2",                 ["$s86"]>, DwarfRegNum<[150]>;
def ES_PL3   : SFR< 87,  "$es_pl3",                 ["$s87"]>, DwarfRegNum<[151]>;
def SID_PL0  : SFR< 88,     "$s88",   ["$res88", "$sid_pl0"]>, DwarfRegNum<[152]>;
def SID_PL1  : SFR< 89,     "$s89",   ["$res89", "$sid_pl1"]>, DwarfRegNum<[153]>;
def SID_PL2  : SFR< 90,     "$s90",   ["$res90", "$sid_pl2"]>, DwarfRegNum<[154]>;
def SID_PL3  : SFR< 91,     "$s91",   ["$res91", "$sid_pl3"]>, DwarfRegNum<[155]>;
def SR1_PL0  : SFR< 92,     "$s92",   ["$res92", "$sr1_pl0"]>, DwarfRegNum<[156]>;
def SR1_PL1  : SFR< 93,     "$s93",   ["$res93", "$sr1_pl1"]>, DwarfRegNum<[157]>;
def SR1_PL2  : SFR< 94,     "$s94",   ["$res94", "$sr1_pl2"]>, DwarfRegNum<[158]>;
def SR1_PL3  : SFR< 95,     "$s95",   ["$res95", "$sr1_pl3"]>, DwarfRegNum<[159]>;
def SYOW     : SFR< 96,    "$syow",                 ["$s96"]>, DwarfRegNum<[160]>;
def HTOW     : SFR< 97,    "$htow",                 ["$s97"]>, DwarfRegNum<[161]>;
def ITOW     : SFR< 98,    "$itow",                 ["$s98"]>, DwarfRegNum<[162]>;
def DOW      : SFR< 99,     "$dow",                 ["$s99"]>, DwarfRegNum<[163]>;
def MOW      : SFR<100,     "$mow",                ["$s100"]>, DwarfRegNum<[164]>;
def PSOW     : SFR<101,    "$psow",                ["$s101"]>, DwarfRegNum<[165]>;
def RES102   : SFR<102,  "$res102",                ["$s102"]>, DwarfRegNum<[166]>;
def RES103   : SFR<103,  "$res103",                ["$s103"]>, DwarfRegNum<[167]>;
def TPCC_PL0 : SFR<104,    "$s104", ["$res104", "$tpcc_pl0"]>, DwarfRegNum<[168]>;
def TPCC_PL1 : SFR<105,    "$s105", ["$res105", "$tpcc_pl1"]>, DwarfRegNum<[169]>;
def TPCC_PL2 : SFR<106,    "$s106", ["$res106", "$tpcc_pl2"]>, DwarfRegNum<[170]>;
def TPCC_PL3 : SFR<107,    "$s107", ["$res107", "$tpcc_pl3"]>, DwarfRegNum<[171]>;
def RES108   : SFR<108,  "$res108",                ["$s108"]>, DwarfRegNum<[172]>;
def RES109   : SFR<109,  "$res109",                ["$s109"]>, DwarfRegNum<[173]>;
def RES110   : SFR<110,  "$res110",                ["$s110"]>, DwarfRegNum<[174]>;
def RES111   : SFR<111,  "$res111",                ["$s111"]>, DwarfRegNum<[175]>;
def RES112   : SFR<112,  "$res112",                ["$s112"]>, DwarfRegNum<[176]>;
def RES113   : SFR<113,  "$res113",                ["$s113"]>, DwarfRegNum<[177]>;
def RES114   : SFR<114,  "$res114",                ["$s114"]>, DwarfRegNum<[178]>;
def RES115   : SFR<115,  "$res115",                ["$s115"]>, DwarfRegNum<[179]>;
def RES116   : SFR<116,  "$res116",                ["$s116"]>, DwarfRegNum<[180]>;
def RES117   : SFR<117,  "$res117",                ["$s117"]>, DwarfRegNum<[181]>;
def RES118   : SFR<118,  "$res118",                ["$s118"]>, DwarfRegNum<[182]>;
def RES119   : SFR<119,  "$res119",                ["$s119"]>, DwarfRegNum<[183]>;
def RES120   : SFR<120,  "$res120",                ["$s120"]>, DwarfRegNum<[184]>;
def RES121   : SFR<121,  "$res121",                ["$s121"]>, DwarfRegNum<[185]>;
def RES122   : SFR<122,  "$res122",                ["$s122"]>, DwarfRegNum<[186]>;
def RES123   : SFR<123,  "$res123",                ["$s123"]>, DwarfRegNum<[187]>;
def RES124   : SFR<124,  "$res124",                ["$s124"]>, DwarfRegNum<[188]>;
def RES125   : SFR<125,  "$res125",                ["$s125"]>, DwarfRegNum<[189]>;
def RES126   : SFR<126,  "$res126",                ["$s126"]>, DwarfRegNum<[190]>;
def RES127   : SFR<127,  "$res127",                ["$s127"]>, DwarfRegNum<[191]>;
def SPC      : SFR<128,     "$spc",                ["$s128"]>, DwarfRegNum<[192]>;
def RES129   : SFR<129,  "$res129",                ["$s129"]>, DwarfRegNum<[193]>;
def RES130   : SFR<130,  "$res130",                ["$s130"]>, DwarfRegNum<[194]>;
def RES131   : SFR<131,  "$res131",                ["$s131"]>, DwarfRegNum<[195]>;
def SPS      : SFR<132,     "$sps",                ["$s132"]>, DwarfRegNum<[196]>;
def RES133   : SFR<133,  "$res133",                ["$s133"]>, DwarfRegNum<[197]>;
def RES134   : SFR<134,  "$res134",                ["$s134"]>, DwarfRegNum<[198]>;
def RES135   : SFR<135,  "$res135",                ["$s135"]>, DwarfRegNum<[199]>;
def EA       : SFR<136,      "$ea",                ["$s136"]>, DwarfRegNum<[200]>;
def RES137   : SFR<137,  "$res137",                ["$s137"]>, DwarfRegNum<[201]>;
def RES138   : SFR<138,  "$res138",                ["$s138"]>, DwarfRegNum<[202]>;
def RES139   : SFR<139,  "$res139",                ["$s139"]>, DwarfRegNum<[203]>;
def EV       : SFR<140,      "$ev",                ["$s140"]>, DwarfRegNum<[204]>;
def RES141   : SFR<141,  "$res141",                ["$s141"]>, DwarfRegNum<[205]>;
def RES142   : SFR<142,  "$res142",                ["$s142"]>, DwarfRegNum<[206]>;
def RES143   : SFR<143,  "$res143",                ["$s143"]>, DwarfRegNum<[207]>;
def SR       : SFR<144,      "$sr",                ["$s144"]>, DwarfRegNum<[208]>;
def RES145   : SFR<145,  "$res145",                ["$s145"]>, DwarfRegNum<[209]>;
def RES146   : SFR<146,  "$res146",                ["$s146"]>, DwarfRegNum<[210]>;
def RES147   : SFR<147,  "$res147",                ["$s147"]>, DwarfRegNum<[211]>;
def ES       : SFR<148,      "$es",                ["$s148"]>, DwarfRegNum<[212]>;
def RES149   : SFR<149,  "$res149",                ["$s149"]>, DwarfRegNum<[213]>;
def RES150   : SFR<150,  "$res150",                ["$s150"]>, DwarfRegNum<[214]>;
def RES151   : SFR<151,  "$res151",                ["$s151"]>, DwarfRegNum<[215]>;
def SID      : SFR<152,    "$s152",      ["$res152", "$sid"]>, DwarfRegNum<[216]>;
def RES153   : SFR<153,  "$res153",                ["$s153"]>, DwarfRegNum<[217]>;
def RES154   : SFR<154,  "$res154",                ["$s154"]>, DwarfRegNum<[218]>;
def RES155   : SFR<155,  "$res155",                ["$s155"]>, DwarfRegNum<[219]>;
def SR1      : SFR<156,    "$s156",      ["$res156", "$sr1"]>, DwarfRegNum<[220]>;
def RES157   : SFR<157,  "$res157",                ["$s157"]>, DwarfRegNum<[221]>;
def RES158   : SFR<158,  "$res158",                ["$s158"]>, DwarfRegNum<[222]>;
def RES159   : SFR<159,  "$res159",                ["$s159"]>, DwarfRegNum<[223]>;
def RES160   : SFR<160,  "$res160",                ["$s160"]>, DwarfRegNum<[224]>;
def RES161   : SFR<161,  "$res161",                ["$s161"]>, DwarfRegNum<[225]>;
def RES162   : SFR<162,  "$res162",                ["$s162"]>, DwarfRegNum<[226]>;
def RES163   : SFR<163,  "$res163",                ["$s163"]>, DwarfRegNum<[227]>;
def RES164   : SFR<164,  "$res164",                ["$s164"]>, DwarfRegNum<[228]>;
def RES165   : SFR<165,  "$res165",                ["$s165"]>, DwarfRegNum<[229]>;
def RES166   : SFR<166,  "$res166",                ["$s166"]>, DwarfRegNum<[230]>;
def RES167   : SFR<167,  "$res167",                ["$s167"]>, DwarfRegNum<[231]>;
def TPCC     : SFR<168,    "$s168",     ["$res168", "$tpcc"]>, DwarfRegNum<[232]>;
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
def R0  : GPR< 0,  "$r0",       ["$r0r1.lo", "$r0r1r2r3.x"]>, DwarfRegNum<[ 0]>;
def R1  : GPR< 1,  "$r1",       ["$r0r1.hi", "$r0r1r2r3.y"]>, DwarfRegNum<[ 1]>;
def R2  : GPR< 2,  "$r2",       ["$r2r3.lo", "$r0r1r2r3.z"]>, DwarfRegNum<[ 2]>;
def R3  : GPR< 3,  "$r3",       ["$r2r3.hi", "$r0r1r2r3.t"]>, DwarfRegNum<[ 3]>;
def R4  : GPR< 4,  "$r4",       ["$r4r5.lo", "$r4r5r6r7.x"]>, DwarfRegNum<[ 4]>;
def R5  : GPR< 5,  "$r5",       ["$r4r5.hi", "$r4r5r6r7.y"]>, DwarfRegNum<[ 5]>;
def R6  : GPR< 6,  "$r6",       ["$r6r7.lo", "$r4r5r6r7.z"]>, DwarfRegNum<[ 6]>;
def R7  : GPR< 7,  "$r7",       ["$r6r7.hi", "$r4r5r6r7.t"]>, DwarfRegNum<[ 7]>;
def R8  : GPR< 8,  "$r8",     ["$r8r9.lo", "$r8r9r10r11.x"]>, DwarfRegNum<[ 8]>;
def R9  : GPR< 9,  "$r9",     ["$r8r9.hi", "$r8r9r10r11.y"]>, DwarfRegNum<[ 9]>;
def R10 : GPR<10, "$r10",   ["$r10r11.lo", "$r8r9r10r11.z"]>, DwarfRegNum<[10]>;
def R11 : GPR<11, "$r11",   ["$r10r11.hi", "$r8r9r10r11.t"]>, DwarfRegNum<[11]>;
def R12 : GPR<12, "$r12",                           ["$sp"]>, DwarfRegNum<[12]>;
def R13 : GPR<13, "$r13",                           ["$tp"]>, DwarfRegNum<[13]>;
def R14 : GPR<14, "$r14",                           ["$fp"]>, DwarfRegNum<[14]>;
def R15 : GPR<15, "$r15",                           ["$rp"]>, DwarfRegNum<[15]>;
def R16 : GPR<16, "$r16", ["$r16r17r18r19.x", "$r16r17.lo"]>, DwarfRegNum<[16]>;
def R17 : GPR<17, "$r17", ["$r16r17r18r19.y", "$r16r17.hi"]>, DwarfRegNum<[17]>;
def R18 : GPR<18, "$r18", ["$r18r19.lo", "$r16r17r18r19.z"]>, DwarfRegNum<[18]>;
def R19 : GPR<19, "$r19", ["$r18r19.hi", "$r16r17r18r19.t"]>, DwarfRegNum<[19]>;
def R20 : GPR<20, "$r20", ["$r20r21.lo", "$r20r21r22r23.x"]>, DwarfRegNum<[20]>;
def R21 : GPR<21, "$r21", ["$r20r21r22r23.y", "$r20r21.hi"]>, DwarfRegNum<[21]>;
def R22 : GPR<22, "$r22", ["$r20r21r22r23.z", "$r22r23.lo"]>, DwarfRegNum<[22]>;
def R23 : GPR<23, "$r23", ["$r20r21r22r23.t", "$r22r23.hi"]>, DwarfRegNum<[23]>;
def R24 : GPR<24, "$r24", ["$r24r25.lo", "$r24r25r26r27.x"]>, DwarfRegNum<[24]>;
def R25 : GPR<25, "$r25", ["$r24r25r26r27.y", "$r24r25.hi"]>, DwarfRegNum<[25]>;
def R26 : GPR<26, "$r26", ["$r24r25r26r27.z", "$r26r27.lo"]>, DwarfRegNum<[26]>;
def R27 : GPR<27, "$r27", ["$r24r25r26r27.t", "$r26r27.hi"]>, DwarfRegNum<[27]>;
def R28 : GPR<28, "$r28", ["$r28r29.lo", "$r28r29r30r31.x"]>, DwarfRegNum<[28]>;
def R29 : GPR<29, "$r29", ["$r28r29.hi", "$r28r29r30r31.y"]>, DwarfRegNum<[29]>;
def R30 : GPR<30, "$r30", ["$r30r31.lo", "$r28r29r30r31.z"]>, DwarfRegNum<[30]>;
def R31 : GPR<31, "$r31", ["$r30r31.hi", "$r28r29r30r31.t"]>, DwarfRegNum<[31]>;
def R32 : GPR<32, "$r32", ["$r32r33.lo", "$r32r33r34r35.x"]>, DwarfRegNum<[32]>;
def R33 : GPR<33, "$r33", ["$r32r33.hi", "$r32r33r34r35.y"]>, DwarfRegNum<[33]>;
def R34 : GPR<34, "$r34", ["$r34r35.lo", "$r32r33r34r35.z"]>, DwarfRegNum<[34]>;
def R35 : GPR<35, "$r35", ["$r34r35.hi", "$r32r33r34r35.t"]>, DwarfRegNum<[35]>;
def R36 : GPR<36, "$r36", ["$r36r37r38r39.x", "$r36r37.lo"]>, DwarfRegNum<[36]>;
def R37 : GPR<37, "$r37", ["$r36r37r38r39.y", "$r36r37.hi"]>, DwarfRegNum<[37]>;
def R38 : GPR<38, "$r38", ["$r38r39.lo", "$r36r37r38r39.z"]>, DwarfRegNum<[38]>;
def R39 : GPR<39, "$r39", ["$r38r39.hi", "$r36r37r38r39.t"]>, DwarfRegNum<[39]>;
def R40 : GPR<40, "$r40", ["$r40r41.lo", "$r40r41r42r43.x"]>, DwarfRegNum<[40]>;
def R41 : GPR<41, "$r41", ["$r40r41r42r43.y", "$r40r41.hi"]>, DwarfRegNum<[41]>;
def R42 : GPR<42, "$r42", ["$r42r43.lo", "$r40r41r42r43.z"]>, DwarfRegNum<[42]>;
def R43 : GPR<43, "$r43", ["$r40r41r42r43.t", "$r42r43.hi"]>, DwarfRegNum<[43]>;
def R44 : GPR<44, "$r44", ["$r44r45.lo", "$r44r45r46r47.x"]>, DwarfRegNum<[44]>;
def R45 : GPR<45, "$r45", ["$r44r45r46r47.y", "$r44r45.hi"]>, DwarfRegNum<[45]>;
def R46 : GPR<46, "$r46", ["$r46r47.lo", "$r44r45r46r47.z"]>, DwarfRegNum<[46]>;
def R47 : GPR<47, "$r47", ["$r46r47.hi", "$r44r45r46r47.t"]>, DwarfRegNum<[47]>;
def R48 : GPR<48, "$r48", ["$r48r49.lo", "$r48r49r50r51.x"]>, DwarfRegNum<[48]>;
def R49 : GPR<49, "$r49", ["$r48r49r50r51.y", "$r48r49.hi"]>, DwarfRegNum<[49]>;
def R50 : GPR<50, "$r50", ["$r50r51.lo", "$r48r49r50r51.z"]>, DwarfRegNum<[50]>;
def R51 : GPR<51, "$r51", ["$r50r51.hi", "$r48r49r50r51.t"]>, DwarfRegNum<[51]>;
def R52 : GPR<52, "$r52", ["$r52r53r54r55.x", "$r52r53.lo"]>, DwarfRegNum<[52]>;
def R53 : GPR<53, "$r53", ["$r52r53r54r55.y", "$r52r53.hi"]>, DwarfRegNum<[53]>;
def R54 : GPR<54, "$r54", ["$r54r55.lo", "$r52r53r54r55.z"]>, DwarfRegNum<[54]>;
def R55 : GPR<55, "$r55", ["$r54r55.hi", "$r52r53r54r55.t"]>, DwarfRegNum<[55]>;
def R56 : GPR<56, "$r56", ["$r56r57r58r59.x", "$r56r57.lo"]>, DwarfRegNum<[56]>;
def R57 : GPR<57, "$r57", ["$r56r57r58r59.y", "$r56r57.hi"]>, DwarfRegNum<[57]>;
def R58 : GPR<58, "$r58", ["$r58r59.lo", "$r56r57r58r59.z"]>, DwarfRegNum<[58]>;
def R59 : GPR<59, "$r59", ["$r58r59.hi", "$r56r57r58r59.t"]>, DwarfRegNum<[59]>;
def R60 : GPR<60, "$r60", ["$r60r61.lo", "$r60r61r62r63.x"]>, DwarfRegNum<[60]>;
def R61 : GPR<61, "$r61", ["$r60r61r62r63.y", "$r60r61.hi"]>, DwarfRegNum<[61]>;
def R62 : GPR<62, "$r62", ["$r60r61r62r63.z", "$r62r63.lo"]>, DwarfRegNum<[62]>;
def R63 : GPR<63, "$r63", ["$r60r61r62r63.t", "$r62r63.hi"]>, DwarfRegNum<[63]>;


// Paired General Registers
def P0  : PGR< 0,   "$r0r1", [ R0,  R1],     ["$r0r1r2r3.lo"]>;
def P2  : PGR< 1,   "$r2r3", [ R2,  R3],     ["$r0r1r2r3.hi"]>;
def P4  : PGR< 2,   "$r4r5", [ R4,  R5],     ["$r4r5r6r7.lo"]>;
def P6  : PGR< 3,   "$r6r7", [ R6,  R7],     ["$r4r5r6r7.hi"]>;
def P8  : PGR< 4,   "$r8r9", [ R8,  R9],   ["$r8r9r10r11.lo"]>;
def P10 : PGR< 5, "$r10r11", [R10, R11],   ["$r8r9r10r11.hi"]>;
def P12 : PGR< 6, "$r12r13", [R12, R13], ["$r12r13r14r15.lo"]>;
def P14 : PGR< 7, "$r14r15", [R14, R15], ["$r12r13r14r15.hi"]>;
def P16 : PGR< 8, "$r16r17", [R16, R17], ["$r16r17r18r19.lo"]>;
def P18 : PGR< 9, "$r18r19", [R18, R19], ["$r16r17r18r19.hi"]>;
def P20 : PGR<10, "$r20r21", [R20, R21], ["$r20r21r22r23.lo"]>;
def P22 : PGR<11, "$r22r23", [R22, R23], ["$r20r21r22r23.hi"]>;
def P24 : PGR<12, "$r24r25", [R24, R25], ["$r24r25r26r27.lo"]>;
def P26 : PGR<13, "$r26r27", [R26, R27], ["$r24r25r26r27.hi"]>;
def P28 : PGR<14, "$r28r29", [R28, R29], ["$r28r29r30r31.lo"]>;
def P30 : PGR<15, "$r30r31", [R30, R31], ["$r28r29r30r31.hi"]>;
def P32 : PGR<16, "$r32r33", [R32, R33], ["$r32r33r34r35.lo"]>;
def P34 : PGR<17, "$r34r35", [R34, R35], ["$r32r33r34r35.hi"]>;
def P36 : PGR<18, "$r36r37", [R36, R37], ["$r36r37r38r39.lo"]>;
def P38 : PGR<19, "$r38r39", [R38, R39], ["$r36r37r38r39.hi"]>;
def P40 : PGR<20, "$r40r41", [R40, R41], ["$r40r41r42r43.lo"]>;
def P42 : PGR<21, "$r42r43", [R42, R43], ["$r40r41r42r43.hi"]>;
def P44 : PGR<22, "$r44r45", [R44, R45], ["$r44r45r46r47.lo"]>;
def P46 : PGR<23, "$r46r47", [R46, R47], ["$r44r45r46r47.hi"]>;
def P48 : PGR<24, "$r48r49", [R48, R49], ["$r48r49r50r51.lo"]>;
def P50 : PGR<25, "$r50r51", [R50, R51], ["$r48r49r50r51.hi"]>;
def P52 : PGR<26, "$r52r53", [R52, R53], ["$r52r53r54r55.lo"]>;
def P54 : PGR<27, "$r54r55", [R54, R55], ["$r52r53r54r55.hi"]>;
def P56 : PGR<28, "$r56r57", [R56, R57], ["$r56r57r58r59.lo"]>;
def P58 : PGR<29, "$r58r59", [R58, R59], ["$r56r57r58r59.hi"]>;
def P60 : PGR<30, "$r60r61", [R60, R61], ["$r60r61r62r63.lo"]>;
def P62 : PGR<31, "$r62r63", [R62, R63], ["$r60r61r62r63.hi"]>;


// Quadruple General Registers
def Q0  : QGR< 0,     "$r0r1r2r3", [ P0,  P2]>;
def Q4  : QGR< 1,     "$r4r5r6r7", [ P4,  P6]>;
def Q8  : QGR< 2,   "$r8r9r10r11", [ P8, P10]>;
def Q12 : QGR< 3, "$r12r13r14r15", [P12, P14]>;
def Q16 : QGR< 4, "$r16r17r18r19", [P16, P18]>;
def Q20 : QGR< 5, "$r20r21r22r23", [P20, P22]>;
def Q24 : QGR< 6, "$r24r25r26r27", [P24, P26]>;
def Q28 : QGR< 7, "$r28r29r30r31", [P28, P30]>;
def Q32 : QGR< 8, "$r32r33r34r35", [P32, P34]>;
def Q36 : QGR< 9, "$r36r37r38r39", [P36, P38]>;
def Q40 : QGR<10, "$r40r41r42r43", [P40, P42]>;
def Q44 : QGR<11, "$r44r45r46r47", [P44, P46]>;
def Q48 : QGR<12, "$r48r49r50r51", [P48, P50]>;
def Q52 : QGR<13, "$r52r53r54r55", [P52, P54]>;
def Q56 : QGR<14, "$r56r57r58r59", [P56, P58]>;
def Q60 : QGR<15, "$r60r61r62r63", [P60, P62]>;


// Extension Coprocessor Registers
def C0   : XCR<  0,  "$a0.x",  ["$a0_x"]>, DwarfRegNum<[256]>;
def C1   : XCR<  1,  "$a0.y",  ["$a0_y"]>, DwarfRegNum<[257]>;
def C2   : XCR<  2,  "$a0.z",  ["$a0_z"]>, DwarfRegNum<[258]>;
def C3   : XCR<  3,  "$a0.t",  ["$a0_t"]>, DwarfRegNum<[259]>;
def C4   : XCR<  4,  "$a1.x",  ["$a1_x"]>, DwarfRegNum<[260]>;
def C5   : XCR<  5,  "$a1.y",  ["$a1_y"]>, DwarfRegNum<[261]>;
def C6   : XCR<  6,  "$a1.z",  ["$a1_z"]>, DwarfRegNum<[262]>;
def C7   : XCR<  7,  "$a1.t",  ["$a1_t"]>, DwarfRegNum<[263]>;
def C8   : XCR<  8,  "$a2.x",  ["$a2_x"]>, DwarfRegNum<[264]>;
def C9   : XCR<  9,  "$a2.y",  ["$a2_y"]>, DwarfRegNum<[265]>;
def C10  : XCR< 10,  "$a2.z",  ["$a2_z"]>, DwarfRegNum<[266]>;
def C11  : XCR< 11,  "$a2.t",  ["$a2_t"]>, DwarfRegNum<[267]>;
def C12  : XCR< 12,  "$a3.x",  ["$a3_x"]>, DwarfRegNum<[268]>;
def C13  : XCR< 13,  "$a3.y",  ["$a3_y"]>, DwarfRegNum<[269]>;
def C14  : XCR< 14,  "$a3.z",  ["$a3_z"]>, DwarfRegNum<[270]>;
def C15  : XCR< 15,  "$a3.t",  ["$a3_t"]>, DwarfRegNum<[271]>;
def C16  : XCR< 16,  "$a4.x",  ["$a4_x"]>, DwarfRegNum<[272]>;
def C17  : XCR< 17,  "$a4.y",  ["$a4_y"]>, DwarfRegNum<[273]>;
def C18  : XCR< 18,  "$a4.z",  ["$a4_z"]>, DwarfRegNum<[274]>;
def C19  : XCR< 19,  "$a4.t",  ["$a4_t"]>, DwarfRegNum<[275]>;
def C20  : XCR< 20,  "$a5.x",  ["$a5_x"]>, DwarfRegNum<[276]>;
def C21  : XCR< 21,  "$a5.y",  ["$a5_y"]>, DwarfRegNum<[277]>;
def C22  : XCR< 22,  "$a5.z",  ["$a5_z"]>, DwarfRegNum<[278]>;
def C23  : XCR< 23,  "$a5.t",  ["$a5_t"]>, DwarfRegNum<[279]>;
def C24  : XCR< 24,  "$a6.x",  ["$a6_x"]>, DwarfRegNum<[280]>;
def C25  : XCR< 25,  "$a6.y",  ["$a6_y"]>, DwarfRegNum<[281]>;
def C26  : XCR< 26,  "$a6.z",  ["$a6_z"]>, DwarfRegNum<[282]>;
def C27  : XCR< 27,  "$a6.t",  ["$a6_t"]>, DwarfRegNum<[283]>;
def C28  : XCR< 28,  "$a7.x",  ["$a7_x"]>, DwarfRegNum<[284]>;
def C29  : XCR< 29,  "$a7.y",  ["$a7_y"]>, DwarfRegNum<[285]>;
def C30  : XCR< 30,  "$a7.z",  ["$a7_z"]>, DwarfRegNum<[286]>;
def C31  : XCR< 31,  "$a7.t",  ["$a7_t"]>, DwarfRegNum<[287]>;
def C32  : XCR< 32,  "$a8.x",  ["$a8_x"]>, DwarfRegNum<[288]>;
def C33  : XCR< 33,  "$a8.y",  ["$a8_y"]>, DwarfRegNum<[289]>;
def C34  : XCR< 34,  "$a8.z",  ["$a8_z"]>, DwarfRegNum<[290]>;
def C35  : XCR< 35,  "$a8.t",  ["$a8_t"]>, DwarfRegNum<[291]>;
def C36  : XCR< 36,  "$a9.x",  ["$a9_x"]>, DwarfRegNum<[292]>;
def C37  : XCR< 37,  "$a9.y",  ["$a9_y"]>, DwarfRegNum<[293]>;
def C38  : XCR< 38,  "$a9.z",  ["$a9_z"]>, DwarfRegNum<[294]>;
def C39  : XCR< 39,  "$a9.t",  ["$a9_t"]>, DwarfRegNum<[295]>;
def C40  : XCR< 40, "$a10.x", ["$a10_x"]>, DwarfRegNum<[296]>;
def C41  : XCR< 41, "$a10.y", ["$a10_y"]>, DwarfRegNum<[297]>;
def C42  : XCR< 42, "$a10.z", ["$a10_z"]>, DwarfRegNum<[298]>;
def C43  : XCR< 43, "$a10.t", ["$a10_t"]>, DwarfRegNum<[299]>;
def C44  : XCR< 44, "$a11.x", ["$a11_x"]>, DwarfRegNum<[300]>;
def C45  : XCR< 45, "$a11.y", ["$a11_y"]>, DwarfRegNum<[301]>;
def C46  : XCR< 46, "$a11.z", ["$a11_z"]>, DwarfRegNum<[302]>;
def C47  : XCR< 47, "$a11.t", ["$a11_t"]>, DwarfRegNum<[303]>;
def C48  : XCR< 48, "$a12.x", ["$a12_x"]>, DwarfRegNum<[304]>;
def C49  : XCR< 49, "$a12.y", ["$a12_y"]>, DwarfRegNum<[305]>;
def C50  : XCR< 50, "$a12.z", ["$a12_z"]>, DwarfRegNum<[306]>;
def C51  : XCR< 51, "$a12.t", ["$a12_t"]>, DwarfRegNum<[307]>;
def C52  : XCR< 52, "$a13.x", ["$a13_x"]>, DwarfRegNum<[308]>;
def C53  : XCR< 53, "$a13.y", ["$a13_y"]>, DwarfRegNum<[309]>;
def C54  : XCR< 54, "$a13.z", ["$a13_z"]>, DwarfRegNum<[310]>;
def C55  : XCR< 55, "$a13.t", ["$a13_t"]>, DwarfRegNum<[311]>;
def C56  : XCR< 56, "$a14.x", ["$a14_x"]>, DwarfRegNum<[312]>;
def C57  : XCR< 57, "$a14.y", ["$a14_y"]>, DwarfRegNum<[313]>;
def C58  : XCR< 58, "$a14.z", ["$a14_z"]>, DwarfRegNum<[314]>;
def C59  : XCR< 59, "$a14.t", ["$a14_t"]>, DwarfRegNum<[315]>;
def C60  : XCR< 60, "$a15.x", ["$a15_x"]>, DwarfRegNum<[316]>;
def C61  : XCR< 61, "$a15.y", ["$a15_y"]>, DwarfRegNum<[317]>;
def C62  : XCR< 62, "$a15.z", ["$a15_z"]>, DwarfRegNum<[318]>;
def C63  : XCR< 63, "$a15.t", ["$a15_t"]>, DwarfRegNum<[319]>;
def C64  : XCR< 64, "$a16.x", ["$a16_x"]>, DwarfRegNum<[320]>;
def C65  : XCR< 65, "$a16.y", ["$a16_y"]>, DwarfRegNum<[321]>;
def C66  : XCR< 66, "$a16.z", ["$a16_z"]>, DwarfRegNum<[322]>;
def C67  : XCR< 67, "$a16.t", ["$a16_t"]>, DwarfRegNum<[323]>;
def C68  : XCR< 68, "$a17.x", ["$a17_x"]>, DwarfRegNum<[324]>;
def C69  : XCR< 69, "$a17.y", ["$a17_y"]>, DwarfRegNum<[325]>;
def C70  : XCR< 70, "$a17.z", ["$a17_z"]>, DwarfRegNum<[326]>;
def C71  : XCR< 71, "$a17.t", ["$a17_t"]>, DwarfRegNum<[327]>;
def C72  : XCR< 72, "$a18.x", ["$a18_x"]>, DwarfRegNum<[328]>;
def C73  : XCR< 73, "$a18.y", ["$a18_y"]>, DwarfRegNum<[329]>;
def C74  : XCR< 74, "$a18.z", ["$a18_z"]>, DwarfRegNum<[330]>;
def C75  : XCR< 75, "$a18.t", ["$a18_t"]>, DwarfRegNum<[331]>;
def C76  : XCR< 76, "$a19.x", ["$a19_x"]>, DwarfRegNum<[332]>;
def C77  : XCR< 77, "$a19.y", ["$a19_y"]>, DwarfRegNum<[333]>;
def C78  : XCR< 78, "$a19.z", ["$a19_z"]>, DwarfRegNum<[334]>;
def C79  : XCR< 79, "$a19.t", ["$a19_t"]>, DwarfRegNum<[335]>;
def C80  : XCR< 80, "$a20.x", ["$a20_x"]>, DwarfRegNum<[336]>;
def C81  : XCR< 81, "$a20.y", ["$a20_y"]>, DwarfRegNum<[337]>;
def C82  : XCR< 82, "$a20.z", ["$a20_z"]>, DwarfRegNum<[338]>;
def C83  : XCR< 83, "$a20.t", ["$a20_t"]>, DwarfRegNum<[339]>;
def C84  : XCR< 84, "$a21.x", ["$a21_x"]>, DwarfRegNum<[340]>;
def C85  : XCR< 85, "$a21.y", ["$a21_y"]>, DwarfRegNum<[341]>;
def C86  : XCR< 86, "$a21.z", ["$a21_z"]>, DwarfRegNum<[342]>;
def C87  : XCR< 87, "$a21.t", ["$a21_t"]>, DwarfRegNum<[343]>;
def C88  : XCR< 88, "$a22.x", ["$a22_x"]>, DwarfRegNum<[344]>;
def C89  : XCR< 89, "$a22.y", ["$a22_y"]>, DwarfRegNum<[345]>;
def C90  : XCR< 90, "$a22.z", ["$a22_z"]>, DwarfRegNum<[346]>;
def C91  : XCR< 91, "$a22.t", ["$a22_t"]>, DwarfRegNum<[347]>;
def C92  : XCR< 92, "$a23.x", ["$a23_x"]>, DwarfRegNum<[348]>;
def C93  : XCR< 93, "$a23.y", ["$a23_y"]>, DwarfRegNum<[349]>;
def C94  : XCR< 94, "$a23.z", ["$a23_z"]>, DwarfRegNum<[350]>;
def C95  : XCR< 95, "$a23.t", ["$a23_t"]>, DwarfRegNum<[351]>;
def C96  : XCR< 96, "$a24.x", ["$a24_x"]>, DwarfRegNum<[352]>;
def C97  : XCR< 97, "$a24.y", ["$a24_y"]>, DwarfRegNum<[353]>;
def C98  : XCR< 98, "$a24.z", ["$a24_z"]>, DwarfRegNum<[354]>;
def C99  : XCR< 99, "$a24.t", ["$a24_t"]>, DwarfRegNum<[355]>;
def C100 : XCR<100, "$a25.x", ["$a25_x"]>, DwarfRegNum<[356]>;
def C101 : XCR<101, "$a25.y", ["$a25_y"]>, DwarfRegNum<[357]>;
def C102 : XCR<102, "$a25.z", ["$a25_z"]>, DwarfRegNum<[358]>;
def C103 : XCR<103, "$a25.t", ["$a25_t"]>, DwarfRegNum<[359]>;
def C104 : XCR<104, "$a26.x", ["$a26_x"]>, DwarfRegNum<[360]>;
def C105 : XCR<105, "$a26.y", ["$a26_y"]>, DwarfRegNum<[361]>;
def C106 : XCR<106, "$a26.z", ["$a26_z"]>, DwarfRegNum<[362]>;
def C107 : XCR<107, "$a26.t", ["$a26_t"]>, DwarfRegNum<[363]>;
def C108 : XCR<108, "$a27.x", ["$a27_x"]>, DwarfRegNum<[364]>;
def C109 : XCR<109, "$a27.y", ["$a27_y"]>, DwarfRegNum<[365]>;
def C110 : XCR<110, "$a27.z", ["$a27_z"]>, DwarfRegNum<[366]>;
def C111 : XCR<111, "$a27.t", ["$a27_t"]>, DwarfRegNum<[367]>;
def C112 : XCR<112, "$a28.x", ["$a28_x"]>, DwarfRegNum<[368]>;
def C113 : XCR<113, "$a28.y", ["$a28_y"]>, DwarfRegNum<[369]>;
def C114 : XCR<114, "$a28.z", ["$a28_z"]>, DwarfRegNum<[370]>;
def C115 : XCR<115, "$a28.t", ["$a28_t"]>, DwarfRegNum<[371]>;
def C116 : XCR<116, "$a29.x", ["$a29_x"]>, DwarfRegNum<[372]>;
def C117 : XCR<117, "$a29.y", ["$a29_y"]>, DwarfRegNum<[373]>;
def C118 : XCR<118, "$a29.z", ["$a29_z"]>, DwarfRegNum<[374]>;
def C119 : XCR<119, "$a29.t", ["$a29_t"]>, DwarfRegNum<[375]>;
def C120 : XCR<120, "$a30.x", ["$a30_x"]>, DwarfRegNum<[376]>;
def C121 : XCR<121, "$a30.y", ["$a30_y"]>, DwarfRegNum<[377]>;
def C122 : XCR<122, "$a30.z", ["$a30_z"]>, DwarfRegNum<[378]>;
def C123 : XCR<123, "$a30.t", ["$a30_t"]>, DwarfRegNum<[379]>;
def C124 : XCR<124, "$a31.x", ["$a31_x"]>, DwarfRegNum<[380]>;
def C125 : XCR<125, "$a31.y", ["$a31_y"]>, DwarfRegNum<[381]>;
def C126 : XCR<126, "$a31.z", ["$a31_z"]>, DwarfRegNum<[382]>;
def C127 : XCR<127, "$a31.t", ["$a31_t"]>, DwarfRegNum<[383]>;
def C128 : XCR<128, "$a32.x", ["$a32_x"]>, DwarfRegNum<[384]>;
def C129 : XCR<129, "$a32.y", ["$a32_y"]>, DwarfRegNum<[385]>;
def C130 : XCR<130, "$a32.z", ["$a32_z"]>, DwarfRegNum<[386]>;
def C131 : XCR<131, "$a32.t", ["$a32_t"]>, DwarfRegNum<[387]>;
def C132 : XCR<132, "$a33.x", ["$a33_x"]>, DwarfRegNum<[388]>;
def C133 : XCR<133, "$a33.y", ["$a33_y"]>, DwarfRegNum<[389]>;
def C134 : XCR<134, "$a33.z", ["$a33_z"]>, DwarfRegNum<[390]>;
def C135 : XCR<135, "$a33.t", ["$a33_t"]>, DwarfRegNum<[391]>;
def C136 : XCR<136, "$a34.x", ["$a34_x"]>, DwarfRegNum<[392]>;
def C137 : XCR<137, "$a34.y", ["$a34_y"]>, DwarfRegNum<[393]>;
def C138 : XCR<138, "$a34.z", ["$a34_z"]>, DwarfRegNum<[394]>;
def C139 : XCR<139, "$a34.t", ["$a34_t"]>, DwarfRegNum<[395]>;
def C140 : XCR<140, "$a35.x", ["$a35_x"]>, DwarfRegNum<[396]>;
def C141 : XCR<141, "$a35.y", ["$a35_y"]>, DwarfRegNum<[397]>;
def C142 : XCR<142, "$a35.z", ["$a35_z"]>, DwarfRegNum<[398]>;
def C143 : XCR<143, "$a35.t", ["$a35_t"]>, DwarfRegNum<[399]>;
def C144 : XCR<144, "$a36.x", ["$a36_x"]>, DwarfRegNum<[400]>;
def C145 : XCR<145, "$a36.y", ["$a36_y"]>, DwarfRegNum<[401]>;
def C146 : XCR<146, "$a36.z", ["$a36_z"]>, DwarfRegNum<[402]>;
def C147 : XCR<147, "$a36.t", ["$a36_t"]>, DwarfRegNum<[403]>;
def C148 : XCR<148, "$a37.x", ["$a37_x"]>, DwarfRegNum<[404]>;
def C149 : XCR<149, "$a37.y", ["$a37_y"]>, DwarfRegNum<[405]>;
def C150 : XCR<150, "$a37.z", ["$a37_z"]>, DwarfRegNum<[406]>;
def C151 : XCR<151, "$a37.t", ["$a37_t"]>, DwarfRegNum<[407]>;
def C152 : XCR<152, "$a38.x", ["$a38_x"]>, DwarfRegNum<[408]>;
def C153 : XCR<153, "$a38.y", ["$a38_y"]>, DwarfRegNum<[409]>;
def C154 : XCR<154, "$a38.z", ["$a38_z"]>, DwarfRegNum<[410]>;
def C155 : XCR<155, "$a38.t", ["$a38_t"]>, DwarfRegNum<[411]>;
def C156 : XCR<156, "$a39.x", ["$a39_x"]>, DwarfRegNum<[412]>;
def C157 : XCR<157, "$a39.y", ["$a39_y"]>, DwarfRegNum<[413]>;
def C158 : XCR<158, "$a39.z", ["$a39_z"]>, DwarfRegNum<[414]>;
def C159 : XCR<159, "$a39.t", ["$a39_t"]>, DwarfRegNum<[415]>;
def C160 : XCR<160, "$a40.x", ["$a40_x"]>, DwarfRegNum<[416]>;
def C161 : XCR<161, "$a40.y", ["$a40_y"]>, DwarfRegNum<[417]>;
def C162 : XCR<162, "$a40.z", ["$a40_z"]>, DwarfRegNum<[418]>;
def C163 : XCR<163, "$a40.t", ["$a40_t"]>, DwarfRegNum<[419]>;
def C164 : XCR<164, "$a41.x", ["$a41_x"]>, DwarfRegNum<[420]>;
def C165 : XCR<165, "$a41.y", ["$a41_y"]>, DwarfRegNum<[421]>;
def C166 : XCR<166, "$a41.z", ["$a41_z"]>, DwarfRegNum<[422]>;
def C167 : XCR<167, "$a41.t", ["$a41_t"]>, DwarfRegNum<[423]>;
def C168 : XCR<168, "$a42.x", ["$a42_x"]>, DwarfRegNum<[424]>;
def C169 : XCR<169, "$a42.y", ["$a42_y"]>, DwarfRegNum<[425]>;
def C170 : XCR<170, "$a42.z", ["$a42_z"]>, DwarfRegNum<[426]>;
def C171 : XCR<171, "$a42.t", ["$a42_t"]>, DwarfRegNum<[427]>;
def C172 : XCR<172, "$a43.x", ["$a43_x"]>, DwarfRegNum<[428]>;
def C173 : XCR<173, "$a43.y", ["$a43_y"]>, DwarfRegNum<[429]>;
def C174 : XCR<174, "$a43.z", ["$a43_z"]>, DwarfRegNum<[430]>;
def C175 : XCR<175, "$a43.t", ["$a43_t"]>, DwarfRegNum<[431]>;
def C176 : XCR<176, "$a44.x", ["$a44_x"]>, DwarfRegNum<[432]>;
def C177 : XCR<177, "$a44.y", ["$a44_y"]>, DwarfRegNum<[433]>;
def C178 : XCR<178, "$a44.z", ["$a44_z"]>, DwarfRegNum<[434]>;
def C179 : XCR<179, "$a44.t", ["$a44_t"]>, DwarfRegNum<[435]>;
def C180 : XCR<180, "$a45.x", ["$a45_x"]>, DwarfRegNum<[436]>;
def C181 : XCR<181, "$a45.y", ["$a45_y"]>, DwarfRegNum<[437]>;
def C182 : XCR<182, "$a45.z", ["$a45_z"]>, DwarfRegNum<[438]>;
def C183 : XCR<183, "$a45.t", ["$a45_t"]>, DwarfRegNum<[439]>;
def C184 : XCR<184, "$a46.x", ["$a46_x"]>, DwarfRegNum<[440]>;
def C185 : XCR<185, "$a46.y", ["$a46_y"]>, DwarfRegNum<[441]>;
def C186 : XCR<186, "$a46.z", ["$a46_z"]>, DwarfRegNum<[442]>;
def C187 : XCR<187, "$a46.t", ["$a46_t"]>, DwarfRegNum<[443]>;
def C188 : XCR<188, "$a47.x", ["$a47_x"]>, DwarfRegNum<[444]>;
def C189 : XCR<189, "$a47.y", ["$a47_y"]>, DwarfRegNum<[445]>;
def C190 : XCR<190, "$a47.z", ["$a47_z"]>, DwarfRegNum<[446]>;
def C191 : XCR<191, "$a47.t", ["$a47_t"]>, DwarfRegNum<[447]>;
def C192 : XCR<192, "$a48.x", ["$a48_x"]>, DwarfRegNum<[448]>;
def C193 : XCR<193, "$a48.y", ["$a48_y"]>, DwarfRegNum<[449]>;
def C194 : XCR<194, "$a48.z", ["$a48_z"]>, DwarfRegNum<[450]>;
def C195 : XCR<195, "$a48.t", ["$a48_t"]>, DwarfRegNum<[451]>;
def C196 : XCR<196, "$a49.x", ["$a49_x"]>, DwarfRegNum<[452]>;
def C197 : XCR<197, "$a49.y", ["$a49_y"]>, DwarfRegNum<[453]>;
def C198 : XCR<198, "$a49.z", ["$a49_z"]>, DwarfRegNum<[454]>;
def C199 : XCR<199, "$a49.t", ["$a49_t"]>, DwarfRegNum<[455]>;
def C200 : XCR<200, "$a50.x", ["$a50_x"]>, DwarfRegNum<[456]>;
def C201 : XCR<201, "$a50.y", ["$a50_y"]>, DwarfRegNum<[457]>;
def C202 : XCR<202, "$a50.z", ["$a50_z"]>, DwarfRegNum<[458]>;
def C203 : XCR<203, "$a50.t", ["$a50_t"]>, DwarfRegNum<[459]>;
def C204 : XCR<204, "$a51.x", ["$a51_x"]>, DwarfRegNum<[460]>;
def C205 : XCR<205, "$a51.y", ["$a51_y"]>, DwarfRegNum<[461]>;
def C206 : XCR<206, "$a51.z", ["$a51_z"]>, DwarfRegNum<[462]>;
def C207 : XCR<207, "$a51.t", ["$a51_t"]>, DwarfRegNum<[463]>;
def C208 : XCR<208, "$a52.x", ["$a52_x"]>, DwarfRegNum<[464]>;
def C209 : XCR<209, "$a52.y", ["$a52_y"]>, DwarfRegNum<[465]>;
def C210 : XCR<210, "$a52.z", ["$a52_z"]>, DwarfRegNum<[466]>;
def C211 : XCR<211, "$a52.t", ["$a52_t"]>, DwarfRegNum<[467]>;
def C212 : XCR<212, "$a53.x", ["$a53_x"]>, DwarfRegNum<[468]>;
def C213 : XCR<213, "$a53.y", ["$a53_y"]>, DwarfRegNum<[469]>;
def C214 : XCR<214, "$a53.z", ["$a53_z"]>, DwarfRegNum<[470]>;
def C215 : XCR<215, "$a53.t", ["$a53_t"]>, DwarfRegNum<[471]>;
def C216 : XCR<216, "$a54.x", ["$a54_x"]>, DwarfRegNum<[472]>;
def C217 : XCR<217, "$a54.y", ["$a54_y"]>, DwarfRegNum<[473]>;
def C218 : XCR<218, "$a54.z", ["$a54_z"]>, DwarfRegNum<[474]>;
def C219 : XCR<219, "$a54.t", ["$a54_t"]>, DwarfRegNum<[475]>;
def C220 : XCR<220, "$a55.x", ["$a55_x"]>, DwarfRegNum<[476]>;
def C221 : XCR<221, "$a55.y", ["$a55_y"]>, DwarfRegNum<[477]>;
def C222 : XCR<222, "$a55.z", ["$a55_z"]>, DwarfRegNum<[478]>;
def C223 : XCR<223, "$a55.t", ["$a55_t"]>, DwarfRegNum<[479]>;
def C224 : XCR<224, "$a56.x", ["$a56_x"]>, DwarfRegNum<[480]>;
def C225 : XCR<225, "$a56.y", ["$a56_y"]>, DwarfRegNum<[481]>;
def C226 : XCR<226, "$a56.z", ["$a56_z"]>, DwarfRegNum<[482]>;
def C227 : XCR<227, "$a56.t", ["$a56_t"]>, DwarfRegNum<[483]>;
def C228 : XCR<228, "$a57.x", ["$a57_x"]>, DwarfRegNum<[484]>;
def C229 : XCR<229, "$a57.y", ["$a57_y"]>, DwarfRegNum<[485]>;
def C230 : XCR<230, "$a57.z", ["$a57_z"]>, DwarfRegNum<[486]>;
def C231 : XCR<231, "$a57.t", ["$a57_t"]>, DwarfRegNum<[487]>;
def C232 : XCR<232, "$a58.x", ["$a58_x"]>, DwarfRegNum<[488]>;
def C233 : XCR<233, "$a58.y", ["$a58_y"]>, DwarfRegNum<[489]>;
def C234 : XCR<234, "$a58.z", ["$a58_z"]>, DwarfRegNum<[490]>;
def C235 : XCR<235, "$a58.t", ["$a58_t"]>, DwarfRegNum<[491]>;
def C236 : XCR<236, "$a59.x", ["$a59_x"]>, DwarfRegNum<[492]>;
def C237 : XCR<237, "$a59.y", ["$a59_y"]>, DwarfRegNum<[493]>;
def C238 : XCR<238, "$a59.z", ["$a59_z"]>, DwarfRegNum<[494]>;
def C239 : XCR<239, "$a59.t", ["$a59_t"]>, DwarfRegNum<[495]>;
def C240 : XCR<240, "$a60.x", ["$a60_x"]>, DwarfRegNum<[496]>;
def C241 : XCR<241, "$a60.y", ["$a60_y"]>, DwarfRegNum<[497]>;
def C242 : XCR<242, "$a60.z", ["$a60_z"]>, DwarfRegNum<[498]>;
def C243 : XCR<243, "$a60.t", ["$a60_t"]>, DwarfRegNum<[499]>;
def C244 : XCR<244, "$a61.x", ["$a61_x"]>, DwarfRegNum<[500]>;
def C245 : XCR<245, "$a61.y", ["$a61_y"]>, DwarfRegNum<[501]>;
def C246 : XCR<246, "$a61.z", ["$a61_z"]>, DwarfRegNum<[502]>;
def C247 : XCR<247, "$a61.t", ["$a61_t"]>, DwarfRegNum<[503]>;
def C248 : XCR<248, "$a62.x", ["$a62_x"]>, DwarfRegNum<[504]>;
def C249 : XCR<249, "$a62.y", ["$a62_y"]>, DwarfRegNum<[505]>;
def C250 : XCR<250, "$a62.z", ["$a62_z"]>, DwarfRegNum<[506]>;
def C251 : XCR<251, "$a62.t", ["$a62_t"]>, DwarfRegNum<[507]>;
def C252 : XCR<252, "$a63.x", ["$a63_x"]>, DwarfRegNum<[508]>;
def C253 : XCR<253, "$a63.y", ["$a63_y"]>, DwarfRegNum<[509]>;
def C254 : XCR<254, "$a63.z", ["$a63_z"]>, DwarfRegNum<[510]>;
def C255 : XCR<255, "$a63.t", ["$a63_t"]>, DwarfRegNum<[511]>;

// Extension Block Registers
def B0   : XBR<  0,  "$a0.lo", [  C0,   C1],  ["$a0_lo"]>;
def B1   : XBR<  1,  "$a0.hi", [  C2,   C3],  ["$a0_hi"]>;
def B2   : XBR<  2,  "$a1.lo", [  C4,   C5],  ["$a1_lo"]>;
def B3   : XBR<  3,  "$a1.hi", [  C6,   C7],  ["$a1_hi"]>;
def B4   : XBR<  4,  "$a2.lo", [  C8,   C9],  ["$a2_lo"]>;
def B5   : XBR<  5,  "$a2.hi", [ C10,  C11],  ["$a2_hi"]>;
def B6   : XBR<  6,  "$a3.lo", [ C12,  C13],  ["$a3_lo"]>;
def B7   : XBR<  7,  "$a3.hi", [ C14,  C15],  ["$a3_hi"]>;
def B8   : XBR<  8,  "$a4.lo", [ C16,  C17],  ["$a4_lo"]>;
def B9   : XBR<  9,  "$a4.hi", [ C18,  C19],  ["$a4_hi"]>;
def B10  : XBR< 10,  "$a5.lo", [ C20,  C21],  ["$a5_lo"]>;
def B11  : XBR< 11,  "$a5.hi", [ C22,  C23],  ["$a5_hi"]>;
def B12  : XBR< 12,  "$a6.lo", [ C24,  C25],  ["$a6_lo"]>;
def B13  : XBR< 13,  "$a6.hi", [ C26,  C27],  ["$a6_hi"]>;
def B14  : XBR< 14,  "$a7.lo", [ C28,  C29],  ["$a7_lo"]>;
def B15  : XBR< 15,  "$a7.hi", [ C30,  C31],  ["$a7_hi"]>;
def B16  : XBR< 16,  "$a8.lo", [ C32,  C33],  ["$a8_lo"]>;
def B17  : XBR< 17,  "$a8.hi", [ C34,  C35],  ["$a8_hi"]>;
def B18  : XBR< 18,  "$a9.lo", [ C36,  C37],  ["$a9_lo"]>;
def B19  : XBR< 19,  "$a9.hi", [ C38,  C39],  ["$a9_hi"]>;
def B20  : XBR< 20, "$a10.lo", [ C40,  C41], ["$a10_lo"]>;
def B21  : XBR< 21, "$a10.hi", [ C42,  C43], ["$a10_hi"]>;
def B22  : XBR< 22, "$a11.lo", [ C44,  C45], ["$a11_lo"]>;
def B23  : XBR< 23, "$a11.hi", [ C46,  C47], ["$a11_hi"]>;
def B24  : XBR< 24, "$a12.lo", [ C48,  C49], ["$a12_lo"]>;
def B25  : XBR< 25, "$a12.hi", [ C50,  C51], ["$a12_hi"]>;
def B26  : XBR< 26, "$a13.lo", [ C52,  C53], ["$a13_lo"]>;
def B27  : XBR< 27, "$a13.hi", [ C54,  C55], ["$a13_hi"]>;
def B28  : XBR< 28, "$a14.lo", [ C56,  C57], ["$a14_lo"]>;
def B29  : XBR< 29, "$a14.hi", [ C58,  C59], ["$a14_hi"]>;
def B30  : XBR< 30, "$a15.lo", [ C60,  C61], ["$a15_lo"]>;
def B31  : XBR< 31, "$a15.hi", [ C62,  C63], ["$a15_hi"]>;
def B32  : XBR< 32, "$a16.lo", [ C64,  C65], ["$a16_lo"]>;
def B33  : XBR< 33, "$a16.hi", [ C66,  C67], ["$a16_hi"]>;
def B34  : XBR< 34, "$a17.lo", [ C68,  C69], ["$a17_lo"]>;
def B35  : XBR< 35, "$a17.hi", [ C70,  C71], ["$a17_hi"]>;
def B36  : XBR< 36, "$a18.lo", [ C72,  C73], ["$a18_lo"]>;
def B37  : XBR< 37, "$a18.hi", [ C74,  C75], ["$a18_hi"]>;
def B38  : XBR< 38, "$a19.lo", [ C76,  C77], ["$a19_lo"]>;
def B39  : XBR< 39, "$a19.hi", [ C78,  C79], ["$a19_hi"]>;
def B40  : XBR< 40, "$a20.lo", [ C80,  C81], ["$a20_lo"]>;
def B41  : XBR< 41, "$a20.hi", [ C82,  C83], ["$a20_hi"]>;
def B42  : XBR< 42, "$a21.lo", [ C84,  C85], ["$a21_lo"]>;
def B43  : XBR< 43, "$a21.hi", [ C86,  C87], ["$a21_hi"]>;
def B44  : XBR< 44, "$a22.lo", [ C88,  C89], ["$a22_lo"]>;
def B45  : XBR< 45, "$a22.hi", [ C90,  C91], ["$a22_hi"]>;
def B46  : XBR< 46, "$a23.lo", [ C92,  C93], ["$a23_lo"]>;
def B47  : XBR< 47, "$a23.hi", [ C94,  C95], ["$a23_hi"]>;
def B48  : XBR< 48, "$a24.lo", [ C96,  C97], ["$a24_lo"]>;
def B49  : XBR< 49, "$a24.hi", [ C98,  C99], ["$a24_hi"]>;
def B50  : XBR< 50, "$a25.lo", [C100, C101], ["$a25_lo"]>;
def B51  : XBR< 51, "$a25.hi", [C102, C103], ["$a25_hi"]>;
def B52  : XBR< 52, "$a26.lo", [C104, C105], ["$a26_lo"]>;
def B53  : XBR< 53, "$a26.hi", [C106, C107], ["$a26_hi"]>;
def B54  : XBR< 54, "$a27.lo", [C108, C109], ["$a27_lo"]>;
def B55  : XBR< 55, "$a27.hi", [C110, C111], ["$a27_hi"]>;
def B56  : XBR< 56, "$a28.lo", [C112, C113], ["$a28_lo"]>;
def B57  : XBR< 57, "$a28.hi", [C114, C115], ["$a28_hi"]>;
def B58  : XBR< 58, "$a29.lo", [C116, C117], ["$a29_lo"]>;
def B59  : XBR< 59, "$a29.hi", [C118, C119], ["$a29_hi"]>;
def B60  : XBR< 60, "$a30.lo", [C120, C121], ["$a30_lo"]>;
def B61  : XBR< 61, "$a30.hi", [C122, C123], ["$a30_hi"]>;
def B62  : XBR< 62, "$a31.lo", [C124, C125], ["$a31_lo"]>;
def B63  : XBR< 63, "$a31.hi", [C126, C127], ["$a31_hi"]>;
def B64  : XBR< 64, "$a32.lo", [C128, C129], ["$a32_lo"]>;
def B65  : XBR< 65, "$a32.hi", [C130, C131], ["$a32_hi"]>;
def B66  : XBR< 66, "$a33.lo", [C132, C133], ["$a33_lo"]>;
def B67  : XBR< 67, "$a33.hi", [C134, C135], ["$a33_hi"]>;
def B68  : XBR< 68, "$a34.lo", [C136, C137], ["$a34_lo"]>;
def B69  : XBR< 69, "$a34.hi", [C138, C139], ["$a34_hi"]>;
def B70  : XBR< 70, "$a35.lo", [C140, C141], ["$a35_lo"]>;
def B71  : XBR< 71, "$a35.hi", [C142, C143], ["$a35_hi"]>;
def B72  : XBR< 72, "$a36.lo", [C144, C145], ["$a36_lo"]>;
def B73  : XBR< 73, "$a36.hi", [C146, C147], ["$a36_hi"]>;
def B74  : XBR< 74, "$a37.lo", [C148, C149], ["$a37_lo"]>;
def B75  : XBR< 75, "$a37.hi", [C150, C151], ["$a37_hi"]>;
def B76  : XBR< 76, "$a38.lo", [C152, C153], ["$a38_lo"]>;
def B77  : XBR< 77, "$a38.hi", [C154, C155], ["$a38_hi"]>;
def B78  : XBR< 78, "$a39.lo", [C156, C157], ["$a39_lo"]>;
def B79  : XBR< 79, "$a39.hi", [C158, C159], ["$a39_hi"]>;
def B80  : XBR< 80, "$a40.lo", [C160, C161], ["$a40_lo"]>;
def B81  : XBR< 81, "$a40.hi", [C162, C163], ["$a40_hi"]>;
def B82  : XBR< 82, "$a41.lo", [C164, C165], ["$a41_lo"]>;
def B83  : XBR< 83, "$a41.hi", [C166, C167], ["$a41_hi"]>;
def B84  : XBR< 84, "$a42.lo", [C168, C169], ["$a42_lo"]>;
def B85  : XBR< 85, "$a42.hi", [C170, C171], ["$a42_hi"]>;
def B86  : XBR< 86, "$a43.lo", [C172, C173], ["$a43_lo"]>;
def B87  : XBR< 87, "$a43.hi", [C174, C175], ["$a43_hi"]>;
def B88  : XBR< 88, "$a44.lo", [C176, C177], ["$a44_lo"]>;
def B89  : XBR< 89, "$a44.hi", [C178, C179], ["$a44_hi"]>;
def B90  : XBR< 90, "$a45.lo", [C180, C181], ["$a45_lo"]>;
def B91  : XBR< 91, "$a45.hi", [C182, C183], ["$a45_hi"]>;
def B92  : XBR< 92, "$a46.lo", [C184, C185], ["$a46_lo"]>;
def B93  : XBR< 93, "$a46.hi", [C186, C187], ["$a46_hi"]>;
def B94  : XBR< 94, "$a47.lo", [C188, C189], ["$a47_lo"]>;
def B95  : XBR< 95, "$a47.hi", [C190, C191], ["$a47_hi"]>;
def B96  : XBR< 96, "$a48.lo", [C192, C193], ["$a48_lo"]>;
def B97  : XBR< 97, "$a48.hi", [C194, C195], ["$a48_hi"]>;
def B98  : XBR< 98, "$a49.lo", [C196, C197], ["$a49_lo"]>;
def B99  : XBR< 99, "$a49.hi", [C198, C199], ["$a49_hi"]>;
def B100 : XBR<100, "$a50.lo", [C200, C201], ["$a50_lo"]>;
def B101 : XBR<101, "$a50.hi", [C202, C203], ["$a50_hi"]>;
def B102 : XBR<102, "$a51.lo", [C204, C205], ["$a51_lo"]>;
def B103 : XBR<103, "$a51.hi", [C206, C207], ["$a51_hi"]>;
def B104 : XBR<104, "$a52.lo", [C208, C209], ["$a52_lo"]>;
def B105 : XBR<105, "$a52.hi", [C210, C211], ["$a52_hi"]>;
def B106 : XBR<106, "$a53.lo", [C212, C213], ["$a53_lo"]>;
def B107 : XBR<107, "$a53.hi", [C214, C215], ["$a53_hi"]>;
def B108 : XBR<108, "$a54.lo", [C216, C217], ["$a54_lo"]>;
def B109 : XBR<109, "$a54.hi", [C218, C219], ["$a54_hi"]>;
def B110 : XBR<110, "$a55.lo", [C220, C221], ["$a55_lo"]>;
def B111 : XBR<111, "$a55.hi", [C222, C223], ["$a55_hi"]>;
def B112 : XBR<112, "$a56.lo", [C224, C225], ["$a56_lo"]>;
def B113 : XBR<113, "$a56.hi", [C226, C227], ["$a56_hi"]>;
def B114 : XBR<114, "$a57.lo", [C228, C229], ["$a57_lo"]>;
def B115 : XBR<115, "$a57.hi", [C230, C231], ["$a57_hi"]>;
def B116 : XBR<116, "$a58.lo", [C232, C233], ["$a58_lo"]>;
def B117 : XBR<117, "$a58.hi", [C234, C235], ["$a58_hi"]>;
def B118 : XBR<118, "$a59.lo", [C236, C237], ["$a59_lo"]>;
def B119 : XBR<119, "$a59.hi", [C238, C239], ["$a59_hi"]>;
def B120 : XBR<120, "$a60.lo", [C240, C241], ["$a60_lo"]>;
def B121 : XBR<121, "$a60.hi", [C242, C243], ["$a60_hi"]>;
def B122 : XBR<122, "$a61.lo", [C244, C245], ["$a61_lo"]>;
def B123 : XBR<123, "$a61.hi", [C246, C247], ["$a61_hi"]>;
def B124 : XBR<124, "$a62.lo", [C248, C249], ["$a62_lo"]>;
def B125 : XBR<125, "$a62.hi", [C250, C251], ["$a62_hi"]>;
def B126 : XBR<126, "$a63.lo", [C252, C253], ["$a63_lo"]>;
def B127 : XBR<127, "$a63.hi", [C254, C255], ["$a63_hi"]>;

// Extension Vector Registers
def A0  : XVR< 0,  "$a0", [B0,  B1],          ["$a0a1a2a3.x, $a0a1.lo"]>;
def A1  : XVR< 1,  "$a1", [B2,  B3],          ["$a0a1.hi, $a0a1a2a3.y"]>;
def A2  : XVR< 2,  "$a2", [B4,  B5],          ["$a0a1a2a3.z, $a2a3.lo"]>;
def A3  : XVR< 3,  "$a3", [B6,  B7],          ["$a2a3.hi, $a0a1a2a3.t"]>;
def A4  : XVR< 4,  "$a4", [B8,  B9],          ["$a4a5a6a7.x, $a4a5.lo"]>;
def A5  : XVR< 5,  "$a5", [B10,	B11],         ["$a4a5.hi, $a4a5a6a7.y"]>;
def A6  : XVR< 6,  "$a6", [B12,	B13],         ["$a4a5a6a7.z, $a6a7.lo"]>;
def A7  : XVR< 7,  "$a7", [B14,	B15],         ["$a6a7.hi, $a4a5a6a7.t"]>;
def A8  : XVR< 8,  "$a8", [B16,	B17],       ["$a8a9.lo, $a8a9a10a11.x"]>;
def A9  : XVR< 9,  "$a9", [B18,	B19],       ["$a8a9.hi, $a8a9a10a11.y"]>;
def A10 : XVR<10, "$a10", [B20,	B21],     ["$a10a11.lo, $a8a9a10a11.z"]>;
def A11 : XVR<11, "$a11", [B22,	B23],     ["$a10a11.hi, $a8a9a10a11.t"]>;
def A12 : XVR<12, "$a12", [B24,	B25],   ["$a12a13.lo, $a12a13a14a15.x"]>;
def A13 : XVR<13, "$a13", [B26,	B27],   ["$a12a13a14a15.y, $a12a13.hi"]>;
def A14 : XVR<14, "$a14", [B28,	B29],   ["$a14a15.lo, $a12a13a14a15.z"]>;
def A15 : XVR<15, "$a15", [B30,	B31],   ["$a14a15.hi, $a12a13a14a15.t"]>;
def A16 : XVR<16, "$a16", [B32,	B33],   ["$a16a17.lo, $a16a17a18a19.x"]>;
def A17 : XVR<17, "$a17", [B34,	B35],   ["$a16a17a18a19.y, $a16a17.hi"]>;
def A18 : XVR<18, "$a18", [B36,	B37],   ["$a18a19.lo, $a16a17a18a19.z"]>;
def A19 : XVR<19, "$a19", [B38,	B39],   ["$a18a19.hi, $a16a17a18a19.t"]>;
def A20 : XVR<20, "$a20", [B40,	B41],   ["$a20a21a22a23.x, $a20a21.lo"]>;
def A21 : XVR<21, "$a21", [B42,	B43],   ["$a20a21a22a23.y, $a20a21.hi"]>;
def A22 : XVR<22, "$a22", [B44,	B45],   ["$a20a21a22a23.z, $a22a23.lo"]>;
def A23 : XVR<23, "$a23", [B46,	B47],   ["$a22a23.hi, $a20a21a22a23.t"]>;
def A24 : XVR<24, "$a24", [B48,	B49],   ["$a24a25a26a27.x, $a24a25.lo"]>;
def A25 : XVR<25, "$a25", [B50,	B51],   ["$a24a25a26a27.y, $a24a25.hi"]>;
def A26 : XVR<26, "$a26", [B52,	B53],   ["$a24a25a26a27.z, $a26a27.lo"]>;
def A27 : XVR<27, "$a27", [B54,	B55],   ["$a26a27.hi, $a24a25a26a27.t"]>;
def A28 : XVR<28, "$a28", [B56,	B57],   ["$a28a29a30a31.x, $a28a29.lo"]>;
def A29 : XVR<29, "$a29", [B58,	B59],   ["$a28a29.hi, $a28a29a30a31.y"]>;
def A30 : XVR<30, "$a30", [B60,	B61],   ["$a30a31.lo, $a28a29a30a31.z"]>;
def A31 : XVR<31, "$a31", [B62,	B63],   ["$a30a31.hi, $a28a29a30a31.t"]>;
def A32 : XVR<32, "$a32", [B64,	B65],   ["$a32a33.lo, $a32a33a34a35.x"]>;
def A33 : XVR<33, "$a33", [B66,	B67],   ["$a32a33.hi, $a32a33a34a35.y"]>;
def A34 : XVR<34, "$a34", [B68,	B69],   ["$a34a35.lo, $a32a33a34a35.z"]>;
def A35 : XVR<35, "$a35", [B70,	B71],   ["$a32a33a34a35.t, $a34a35.hi"]>;
def A36 : XVR<36, "$a36", [B72,	B73],   ["$a36a37.lo, $a36a37a38a39.x"]>;
def A37 : XVR<37, "$a37", [B74,	B75],   ["$a36a37.hi, $a36a37a38a39.y"]>;
def A38 : XVR<38, "$a38", [B76,	B77],   ["$a38a39.lo, $a36a37a38a39.z"]>;
def A39 : XVR<39, "$a39", [B78,	B79],   ["$a38a39.hi, $a36a37a38a39.t"]>;
def A40 : XVR<40, "$a40", [B80,	B81],   ["$a40a41.lo, $a40a41a42a43.x"]>;
def A41 : XVR<41, "$a41", [B82,	B83],   ["$a40a41.hi, $a40a41a42a43.y"]>;
def A42 : XVR<42, "$a42", [B84,	B85],   ["$a42a43.lo, $a40a41a42a43.z"]>;
def A43 : XVR<43, "$a43", [B86,	B87],   ["$a42a43.hi, $a40a41a42a43.t"]>;
def A44 : XVR<44, "$a44", [B88,	B89],   ["$a44a45.lo, $a44a45a46a47.x"]>;
def A45 : XVR<45, "$a45", [B90,	B91],   ["$a44a45.hi, $a44a45a46a47.y"]>;
def A46 : XVR<46, "$a46", [B92,	B93],   ["$a46a47.lo, $a44a45a46a47.z"]>;
def A47 : XVR<47, "$a47", [B94,	B95],   ["$a46a47.hi, $a44a45a46a47.t"]>;
def A48 : XVR<48, "$a48", [B96,	B97],   ["$a48a49.lo, $a48a49a50a51.x"]>;
def A49 : XVR<49, "$a49", [B98,	B99],   ["$a48a49.hi, $a48a49a50a51.y"]>;
def A50 : XVR<50, "$a50", [B100,B101],  ["$a50a51.lo, $a48a49a50a51.z"]>;
def A51 : XVR<51, "$a51", [B102, B103], ["$a50a51.hi, $a48a49a50a51.t"]>;
def A52 : XVR<52, "$a52", [B104, B105], ["$a52a53.lo, $a52a53a54a55.x"]>;
def A53 : XVR<53, "$a53", [B106, B107], ["$a52a53a54a55.y, $a52a53.hi"]>;
def A54 : XVR<54, "$a54", [B108, B109], ["$a54a55.lo, $a52a53a54a55.z"]>;
def A55 : XVR<55, "$a55", [B110, B111], ["$a54a55.hi, $a52a53a54a55.t"]>;
def A56 : XVR<56, "$a56", [B112, B113], ["$a56a57.lo, $a56a57a58a59.x"]>;
def A57 : XVR<57, "$a57", [B114, B115], ["$a56a57a58a59.y, $a56a57.hi"]>;
def A58 : XVR<58, "$a58", [B116, B117], ["$a58a59.lo, $a56a57a58a59.z"]>;
def A59 : XVR<59, "$a59", [B118, B119], ["$a58a59.hi, $a56a57a58a59.t"]>;
def A60 : XVR<60, "$a60", [B120, B121], ["$a60a61a62a63.x, $a60a61.lo"]>;
def A61 : XVR<61, "$a61", [B122, B123], ["$a60a61a62a63.y, $a60a61.hi"]>;
def A62 : XVR<62, "$a62", [B124, B125], ["$a60a61a62a63.z, $a62a63.lo"]>;
def A63 : XVR<63, "$a63", [B126, B127], ["$a62a63.hi, $a60a61a62a63.t"]>;

// Extension Wide Registers
def W0  : XWR< 0,  "$a0a1", [A0,	A1],      ["$a0a1a2a3.lo", "$a0..a1"]>;
def W1  : XWR< 1,  "$a2a3", [A2,	A3],      ["$a0a1a2a3.hi", "$a2..a3"]>;
def W2  : XWR< 2,  "$a4a5", [A4,	A5],      ["$a4a5a6a7.lo", "$a4..a5"]>;
def W3  : XWR< 3,  "$a6a7", [A6,	A7],      ["$a4a5a6a7.hi", "$a6..a7"]>;
def W4  : XWR< 4,  "$a8a9", [A8,	A9],    ["$a8a9a10a11.lo", "$a8..a9"]>;
def W5  : XWR< 5, "$a10a11", [A10,A11],   ["$a8a9a10a11.hi", "$a10..a11"]>;
def W6  : XWR< 6, "$a12a13", [A12,A13], ["$a12a13a14a15.lo", "$a12..a13"]>;
def W7  : XWR< 7, "$a14a15", [A14,A15], ["$a12a13a14a15.hi", "$a14..a15"]>;
def W8  : XWR< 8, "$a16a17", [A16,A17], ["$a16a17a18a19.lo", "$a16..a17"]>;
def W9  : XWR< 9, "$a18a19", [A18,A19], ["$a16a17a18a19.hi", "$a18..a19"]>;
def W10 : XWR<10, "$a20a21", [A20,A21], ["$a20a21a22a23.lo", "$a20..a21"]>;
def W11 : XWR<11, "$a22a23", [A22,A23], ["$a20a21a22a23.hi", "$a22..a23"]>;
def W12 : XWR<12, "$a24a25", [A24,A25], ["$a24a25a26a27.lo", "$a24..a25"]>;
def W13 : XWR<13, "$a26a27", [A26,A27], ["$a24a25a26a27.hi", "$a26..a27"]>;
def W14 : XWR<14, "$a28a29", [A28,A29], ["$a28a29a30a31.lo", "$a28..a29"]>;
def W15 : XWR<15, "$a30a31", [A30,A31], ["$a28a29a30a31.hi", "$a30..a31"]>;
def W16 : XWR<16, "$a32a33", [A32,A33], ["$a32a33a34a35.lo", "$a32..a33"]>;
def W17 : XWR<17, "$a34a35", [A34,A35], ["$a32a33a34a35.hi", "$a34..a35"]>;
def W18 : XWR<18, "$a36a37", [A36,A37], ["$a36a37a38a39.lo", "$a36..a37"]>;
def W19 : XWR<19, "$a38a39", [A38,A39], ["$a36a37a38a39.hi", "$a38..a39"]>;
def W20 : XWR<20, "$a40a41", [A40,A41], ["$a40a41a42a43.lo", "$a40..a41"]>;
def W21 : XWR<21, "$a42a43", [A42,A43], ["$a40a41a42a43.hi", "$a42..a43"]>;
def W22 : XWR<22, "$a44a45", [A44,A45], ["$a44a45a46a47.lo", "$a44..a45"]>;
def W23 : XWR<23, "$a46a47", [A46,A47], ["$a44a45a46a47.hi", "$a46..a47"]>;
def W24 : XWR<24, "$a48a49", [A48,A49], ["$a48a49a50a51.lo", "$a48..a49"]>;
def W25 : XWR<25, "$a50a51", [A50,A51], ["$a48a49a50a51.hi", "$a50..a51"]>;
def W26 : XWR<26, "$a52a53", [A52,A53], ["$a52a53a54a55.lo", "$a52..a53"]>;
def W27 : XWR<27, "$a54a55", [A54,A55], ["$a52a53a54a55.hi", "$a54..a55"]>;
def W28 : XWR<28, "$a56a57", [A56,A57], ["$a56a57a58a59.lo", "$a56..a57"]>;
def W29 : XWR<29, "$a58a59", [A58,A59], ["$a56a57a58a59.hi", "$a58..a59"]>;
def W30 : XWR<30, "$a60a61", [A60,A61], ["$a60a61a62a63.lo", "$a60..a61"]>;
def W31 : XWR<31, "$a62a63", [A62,A63], ["$a60a61a62a63.hi", "$a62..a63"]>;

// Extension Matrix Registers
def X0  : XMR< 0,     "$a0a1a2a3", [W0,	 W1], [  "$a0..a3"]>;
def X1  : XMR< 1,     "$a4a5a6a7", [W2,	 W3], [  "$a4..a7"]>;
def X2  : XMR< 2,  "$a8a9a10a11",  [W4,	 W5], [ "$a8..a11"]>;
def X3  : XMR< 3, "$a12a13a14a15", [W6,	 W7], ["$a12..a15"]>;
def X4  : XMR< 4, "$a16a17a18a19", [W8,	 W9], ["$a16..a19"]>;
def X5  : XMR< 5, "$a20a21a22a23", [W10,W11], ["$a20..a23"]>;
def X6  : XMR< 6, "$a24a25a26a27", [W12,W13], ["$a24..a27"]>;
def X7  : XMR< 7, "$a28a29a30a31", [W14,W15], ["$a28..a31"]>;
def X8  : XMR< 8, "$a32a33a34a35", [W16,W17], ["$a32..a35"]>;
def X9  : XMR< 9, "$a36a37a38a39", [W18,W19], ["$a36..a39"]>;
def X10 : XMR<10, "$a40a41a42a43", [W20,W21], ["$a40..a43"]>;
def X11 : XMR<11, "$a44a45a46a47", [W22,W23], ["$a44..a47"]>;
def X12 : XMR<12, "$a48a49a50a51", [W24,W25], ["$a48..a51"]>;
def X13 : XMR<13, "$a52a53a54a55", [W26,W27], ["$a52..a55"]>;
def X14 : XMR<14, "$a56a57a58a59", [W28,W29], ["$a56..a59"]>;
def X15 : XMR<15, "$a60a61a62a63", [W30,W31], ["$a60..a63"]>;

// Extension 2k-Register Buffer
def I0 : X8R<0,  "$a0..a7",  [  X0, X1]>;
def I1 : X8R<1,  "$a8..a15", [  X2, X3]>;
def I2 : X8R<2, "$a16..a23", [  X4, X5]>;
def I3 : X8R<3, "$a24..a31", [  X6, X7]>;
def I4 : X8R<4, "$a32..a39", [  X8, X9]>;
def I5 : X8R<5, "$a40..a47", [X10, X11]>;
def I6 : X8R<6, "$a48..a55", [X12, X13]>;
def I7 : X8R<7, "$a56..a63", [X14, X15]>;

// Extension 4k-Register Buffer
def J0 : X16R<0,  "$a0..a15", [I0, I1]>;
def J1 : X16R<1, "$a16..a31", [I2, I3]>;
def J2 : X16R<2, "$a32..a47", [I4, I5]>;
def J3 : X16R<3, "$a48..a63", [I6, I7]>;

// GPR - General-Purpose Registers
let Size = 64 in
def SingleReg : RegisterClass<"KVX",
  [i64, i1, i8, i16, i32, f16, f32, f64, v2i8, v4i8, v8i8, v4i16, v2i16, v2i32, v4f16, v2f16, v2f32],
  64, (sequence "R%u", 0, 63)>;

// PGR - Paired General Registers
let Size = 128 in
def PairedReg : RegisterClass<"KVX",
  [v4i32, v2i64, v4f32, v2f64, v8f16],
  128, (sequence "P%u", 0, 63, 2)>;

// QGR - Quadruple General Registers
let Size = 256 in
def QuadReg : RegisterClass<"KVX", [v4i64, v4f64], 256, (sequence "Q%u", 0, 63, 4)>;

// XCR - Extension Coprocessor Registers
// AllocationPriority = 7 -> 256 registers
let Size = 64, AllocationPriority = 7 in
def CoproReg : RegisterClass<"KVX",
  [v64i1],
  64, (sequence "C%u", 0, 255)>;

// XBR - Extension Block Registers
// AllocationPriority = 8 -> 128 register
let Size = 128, AllocationPriority = 8 in
def BlockReg : RegisterClass<"KVX",
  [v128i1],
  128, (sequence "B%u", 0, 127)>;

// XVR - Extension Vector Registers
// AllocationPriority = 9 -> 64 register
let Size = 256, AllocationPriority = 9 in
def VectorReg : RegisterClass<"KVX",
  [v256i1],
  256, (sequence "A%u", 0, 63)>;

// AllocationPriority = 10 -> 32 register
// XWR - Extension Wide Registers
let Size = 512, CopyCost = 2, AllocationPriority = 10, Weight = 8 in
def WideReg : RegisterClass<"KVX",
  [v512i1],
  512, (add
    W0,  W1,  W2,  W3,  W4,  W5,  W6,  W7,  W8,  W9, W10, W11, W12, W13, W14,
   W15, W16, W17, W18, W19, W20, W21, W22, W23, W24, W25, W26, W27, W28, W29,
   W30, W31)>;

// AllocationPriority = 11 -> 16 register
// XMR - Extension Matrix Registers
let Size = 1024, CopyCost = 4, AllocationPriority = 11, Weight = 16 in
def MatrixReg : RegisterClass<"KVX",
  [v1024i1],
  1024, (add
    X0,  X1,  X2,  X3,  X4,  X5,  X6,  X7,  X8,  X9, X10, X11, X12, X13, X14,
   X15)>;

// AllocationPriority = 10 -> 32 register
let Size = 256, AllocationPriority = 10, Weight = 4 in {
// XVR - Accelerator Registers Even Numbered
def VectorRegE : RegisterClass<"KVX", [v256i1], 256, (decimate VectorReg, 2)>;
// XVR - Accelerator Registers Odd Numbered
def VectorRegO : RegisterClass<"KVX", [v256i1], 256, (decimate (shl VectorReg, 1), 2)>;
}

// AllocationPriority = 9 -> 64 register
let Size = 128, AllocationPriority = 9, Weight = 2 in {
// XBR - Block Registers Even Numbered
def BlockRegE : RegisterClass<"KVX", [v128i1], 128, (decimate BlockReg, 2)>;
// XBR - Block Registers Odd Numbered
def BlockRegO : RegisterClass<"KVX", [v128i1], 128, (decimate (shl BlockReg, 1), 2)>;
}

// AllocationPriority = 10 -> 32 register
let Size = 128, AllocationPriority = 10, Weight = 2 in {
// XBR - Block Registers 0 Modulo 4
def BlockReg0M4 : RegisterClass<"KVX", [v128i1], 128, (decimate BlockReg, 4)>;

// XBR - Block Registers 1 Modulo 4
def BlockReg1M4 : RegisterClass<"KVX", [v128i1], 128, (decimate (shl BlockReg, 1), 4)>;

// XBR - Block Registers 2 Modulo 4
def BlockReg2M4 : RegisterClass<"KVX", [v128i1], 128, (decimate (shl BlockReg, 2), 4)>;

// XBR - Block Registers 3 Modulo 4
def BlockReg3M4 : RegisterClass<"KVX", [v128i1], 128, (decimate (shl BlockReg, 3), 4)>;
}

// AllocationPriority = 9 -> 64 register
let Size = 64, AllocationPriority = 9, Weight = 1 in {
// XCR - Coprocessor Registers 0 Modulo 4
def CoproReg0M4 : RegisterClass<"KVX", [v64i1], 64, (decimate CoproReg, 4)>;

// XCR - Coprocessor Registers 1 Modulo 4
def CoproReg1M4 : RegisterClass<"KVX", [v64i1], 64, (decimate (shl CoproReg, 1), 4)>;

// XCR - Coprocessor Registers 2 Modulo 4
def CoproReg2M4 : RegisterClass<"KVX", [v64i1], 64, (decimate (shl CoproReg, 2), 4)>;

// XCR - Coprocessor Registers 3 Modulo 4
def CoproReg3M4 : RegisterClass<"KVX", [v64i1], 64, (decimate (shl CoproReg, 3), 4)>;
}

// AllocationPriority = 12 -> 8 register
// X8R - Extension 8-Register Buffer
let Size = 2048, CopyCost = 8, AllocationPriority = 12, Weight = 32 in
def Buffer8Reg : RegisterClass<"KVX", [v2048i1],
  2048, (add I0, I1, I2, I3, I4, I5, I6, I7)>;

// X16R - Extension 16-Register Buffer
// AllocationPriority = 13 -> 4 register
let Size = 4096, CopyCost = 16, AllocationPriority = 13, Weight = 64 in
def Buffer16Reg : RegisterClass<"KVX", [v4096i1],
  4096, (add J0, J1, J2, J3)>;

// AllocationPriority = 0, should allocate the exact matching register
let Size = 0, Weight = 1, AllocationPriority = 0 in
def TcaBuffer : RegisterClass<
      /*string namespace*/ "KVX",
      /*list<ValueType> regTypes*/[v512i1, v1024i1,  v2048i1, v4096i1],
      /*int alignment*/ 256,
      /*dag regList*/ !con(WideReg.MemberList, MatrixReg.MemberList, Buffer8Reg.MemberList, Buffer16Reg.MemberList)
      //, RegAltNameIndex idx = NoRegAltName
      >;

let Size = 64, isAllocatable = 0, GeneratePressureSet = 0, CopyCost = 2 in {
// SFR - System Function Registers
def SystemReg : RegisterClass<"KVX", [i64], 64, (add
    PC, PS, PCR, RA, CS, CSIT, AESPC, LS, LE, LC, IPE, MEN, PMC, PM0,
    PM1, PM2, PM3, PMSA, TCR, T0V, T1V, T0R, T1R, WDV, WDR, ILE, ILL,
    ILR, MMC, TEL, TEH, IXC, SYO, HTO, ITO, DO, MO, PSO, TPCM0, TPCM1,
    DC, DBA0, DBA1, DWA0, DWA1, MES, WS, DC0, DC1, DC2, DC3, DBA2, DBA3,
    DWA2, DWA3, TPCM2, TPCMC, PM4, PM5, PM6, PM7, PMC2, SRHPC, FRCC,
    SPC_PL0, SPC_PL1, SPC_PL2, SPC_PL3, SPS_PL0, SPS_PL1, SPS_PL2,
    SPS_PL3, EA_PL0, EA_PL1, EA_PL2, EA_PL3, EV_PL0, EV_PL1, EV_PL2,
    EV_PL3, SR_PL0, SR_PL1, SR_PL2, SR_PL3, ES_PL0, ES_PL1, ES_PL2, ES_PL3,
    SID_PL0, SID_PL1, SID_PL2, SID_PL3, SR1_PL0, SR1_PL1, SR1_PL2, SR1_PL3,
    SYOW, HTOW, ITOW, DOW, MOW, PSOW, RES102, RES103, TPCC_PL0, TPCC_PL1,
    TPCC_PL2, TPCC_PL3, RES108, RES109, RES110, RES111, RES112, RES113,
    RES114, RES115, RES116, RES117, RES118, RES119, RES120, RES121, RES122,
    RES123, RES124, RES125, RES126, RES127, SPC, RES129, RES130, RES131,
    SPS, RES133, RES134, RES135, EA, RES137, RES138, RES139, EV, RES141,
    RES142, RES143, SR, RES145, RES146, RES147, ES, RES149, RES150, RES151,
    SID, RES153, RES154, RES155, SR1, RES157, RES158, RES159, RES160,
    RES161, RES162, RES163, RES164, RES165, RES166, RES167, TPCC,
    RES169,  RES170,  RES171,  RES172,  RES173,  RES174,  RES175,
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

def OnlyraReg : RegisterClass<"KVX", [i64], 64, (add RA)>;

def AloneReg : RegisterClass<"KVX", [i64], 64, (add
        PS,     MMC, SPS_PL0, SPS_PL1, SPS_PL2, SPS_PL3,    SYOW,    HTOW,
      ITOW,     DOW,     MOW,    PSOW,     SPS)>;

// Registers that can be used by get instruction
def GetReg : RegisterClass<"KVX", [i64], 64, (add
               PC,       PS,        PCR,        RA,        CS,      CSIT,     AESPC,        LS,
               LE,       LC,        IPE,       MEN,       PMC,       PM0,       PM1,       PM2,
              PM3,     PMSA,        TCR,       T0V,       T1V,       T0R,       T1R,       WDV,
              WDR,       ILE,       ILL,       ILR,       MMC,       TEL,       TEH,       SYO,
              HTO,       ITO,        DO,        MO,       PSO,      DBA0,      DBA1,      DWA0,
             DWA1,       MES,        WS,    ES_PL0,    ES_PL1,    ES_PL2,    ES_PL3,   SID_PL0,
          SID_PL1,   SID_PL2,   SID_PL3,        ES,  TPCC_PL0,  TPCC_PL1,  TPCC_PL2,  TPCC_PL3,
              SPC,       SPS,        EA,        EV,        SR,   SPC_PL0,   SPC_PL1,   SPC_PL2,
          SPC_PL3,    EA_PL0,    EA_PL1,    EA_PL2,    EA_PL3,    EV_PL0,    EV_PL1,    EV_PL2,
           EV_PL3,    SR_PL0,    SR_PL1,    SR_PL2,    SR_PL3,        DC,       IXC,     TPCM0,
            TPCM1,       DC0,       DC1,       DC2,       DC3,      DBA2,      DBA3,      DWA2,
             DWA3,     TPCM2,     TPCMC,       PM4,       PM5,       PM6,       PM7,      PMC2,
            SRHPC,      FRCC,   SPS_PL0,   SPS_PL1,   SPS_PL2,   SPS_PL3,       SID,       SR1,
             TPCC,   SR1_PL0,   SR1_PL1,   SR1_PL2,   SR1_PL3)>;

// Registers that can be used by set instruction
def SetReg : RegisterClass<"KVX", [i64], 64, (add
      PS, PCR, RA, CS, CSIT, AESPC, LS, LE, LC, IPE, MEN, PMC, PM0, PM1, PM2, PM3, PMSA, TCR,
      T0V, T1V, T0R, T1R, WDV, WDR, ILE, ILL, ILR, MMC, TEL, TEH, IXC, TPCM0, TPCM1, DC, DBA0,
      DBA1, DWA0, DWA1, MES, WS, DC0, DC1, DC2, DC3, DBA2, DBA3, DWA2, DWA3, TPCM2, TPCMC, PM4,
      PM5, PM6, PM7, PMC2, SRHPC, FRCC, SPC_PL0, SPC_PL1, SPC_PL2, SPC_PL3, SPS_PL0, SPS_PL1,
      SPS_PL2, SPS_PL3, EA_PL0, EA_PL1, EA_PL2, EA_PL3, EV_PL0, EV_PL1, EV_PL2, EV_PL3, SR_PL0,
      SR_PL1, SR_PL2, SR_PL3, ES_PL0, ES_PL1, ES_PL2, ES_PL3, SID_PL0, SID_PL1, SID_PL2, SID_PL3,
      SR1_PL0, SR1_PL1, SR1_PL2, SR1_PL3, SYOW, HTOW, ITOW, DOW, MOW, PSOW, TPCC_PL0, TPCC_PL1,
      TPCC_PL2, TPCC_PL3, SPC, SPS, EA, EV, SR, ES, SID, SR1, TPCC)>;

// Registers that can be used by wfx instructions
def FxReg : RegisterClass<"KVX", [i64], 64, (add
       PS, PCR, CS, CSIT, IPE, MEN, PMC, TCR, ILE, ILL, ILR, MMC, TEL, TEH, IXC, DC, MES, WS,
       DC0, DC1, DC2, DC3, PMC2, SPS_PL0, SPS_PL1, SPS_PL2, SPS_PL3, ES_PL0, ES_PL1, ES_PL2,
       ES_PL3, SYOW, HTOW, ITOW, DOW, MOW, PSOW, TPCC_PL0, TPCC_PL1, TPCC_PL2, TPCC_PL3, SPS,
       ES, TPCC)>;

// Registers that can't be used by get instruction in cv1
def GetNotCV1Reg : RegisterClass<"KVX", [i64], 64, (add
      IXC,    TPCM0,    TPCM1,    DC0,      DC1,    DC2,    DC3,    DBA2,    DBA3,
      DWA2,    DWA3,    TPCM2,    TPCMC,    PM4,    PM5,    PM6,    PM7,     PMC2,
      SRHPC,   FRCC,  SPS_PL0,  SPS_PL1,  SPS_PL2, SPS_PL3, SID,    SR1,
      TPCC,    SR1_PL0,    SR1_PL1,    SR1_PL2,    SR1_PL3)>;

// Registers that can't be used by set/wfx instructions in cv1
def SetFxNotCV1Reg : RegisterClass<"KVX", [i64], 64, (add
          TPCM0, TPCM1, DBA2, DBA3, DWA2, DWA3, TPCM2, TPCMC, PM4, PM5, PM6, PM7,
          SRHPC, FRCC, SID_PL0, SID_PL1, SID_PL2, SID_PL3, SR1_PL0, SR1_PL1, SR1_PL2,
          SR1_PL3, SID, SR1, IXC, DC0, DC1, DC2, DC3, PMC2, TPCC_PL0, TPCC_PL1,
          TPCC_PL2, TPCC_PL3, TPCC)>;

// Registers that can't be used by get/set/wfx instructions in cv2
def GetSetFxNotCV2Reg : RegisterClass<"KVX", [i64], 64, (add DC)>;

def SwapReg : RegisterClass<"KVX", [i64], 64, (add
         PC,      PS, PCR,       RA,       CS,     CSIT,    AESPC,       LS,
         LE,       LC,      IPE,      MEN,      PMC,      PM0,      PM1,
        PM2,      PM3,     PMSA,      TCR,      T0V,      T1V,      T0R,
        T1R,      WDV,      WDR,      ILE,      ILL,      ILR,      MMC,
        TEL,      TEH,      IXC,      SYO,      HTO,      ITO,       DO,
         MO,      PSO,    TPCM0,    TPCM1,       DC,     DBA0,     DBA1,
       DWA0,     DWA1,      MES,       WS,      DC0,      DC1,      DC2,
        DC3,     DBA2,     DBA3,     DWA2,     DWA3,    TPCM2,    TPCMC,
        PM4,      PM5,      PM6,      PM7,     PMC2,    SRHPC,     FRCC,
    SPC_PL0,  SPC_PL1,  SPC_PL2,  SPC_PL3,  SPS_PL0,  SPS_PL1,  SPS_PL2,
    SPS_PL3,   EA_PL0,   EA_PL1,   EA_PL2,   EA_PL3,   EV_PL0,   EV_PL1,
     EV_PL2,   EV_PL3,   SR_PL0,   SR_PL1,   SR_PL2,   SR_PL3,   ES_PL0,
     ES_PL1,   ES_PL2,   ES_PL3,  SID_PL0,  SID_PL1,  SID_PL2,  SID_PL3,
    SR1_PL0,  SR1_PL1,  SR1_PL2,  SR1_PL3,     SYOW,     HTOW,     ITOW,
        DOW,      MOW,     PSOW,   RES102,   RES103, TPCC_PL0, TPCC_PL1,
   TPCC_PL2, TPCC_PL3,   RES108,   RES109,   RES110,   RES111,   RES112,
     RES113,   RES114,   RES115,   RES116,   RES117,   RES118,   RES119,
     RES120,   RES121,   RES122,   RES123,   RES124,   RES125,   RES126,
     RES127,      SPC,   RES129,   RES130,   RES131,      SPS,   RES133,
     RES134,   RES135,       EA,   RES137,   RES138,   RES139,       EV,
     RES141,   RES142,   RES143,       SR,   RES145,   RES146,   RES147,
         ES,   RES149,   RES150,   RES151,      SID,   RES153,   RES154,
     RES155,      SR1,   RES157,   RES158,   RES159,   RES160,   RES161,
     RES162,   RES163,   RES164,   RES165,   RES166,   RES167,     TPCC
      )>;
} // SFR register classes
} // let Namespace = "KVX"

def BufferReg : RegisterOperand<TcaBuffer> {
  let PrintMethod = "printBuffer";
}
