//===-- KVXSchedule.td - Scheduling Description for KVX Target ------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file describes the KVX scheduling informations in TableGen format.
//
//===----------------------------------------------------------------------===//

// This file was automatically generated,
//   *DO NOT EDIT*,
//   please contact code owner.
// Last generated: 2020-01-31 09:16:32.863017.


// ISSUEI_FU FuncUnits have been disabled due to DFA limitations.
// May be enabled with LLVM 10 since DFA algorithms have been updated to get rid
// of those limitations.
// This is safe since KVXPacketizer ensures that Sched::ALL instructions are
// alone in a bundle.
//
// foreach I = 0-7 in def ISSUE#I#_FU : FuncUnit;
foreach I = 0-3 in def TINY#I#_FU : FuncUnit;
foreach I = 0-1 in def LITE#I#_FU : FuncUnit;
def FULL_FU : FuncUnit;
def LSU_FU : FuncUnit;
def MAU_FU : FuncUnit;
def BCU_FU : FuncUnit;
def TCA_FU : FuncUnit;
def AUXR_FU : FuncUnit;
def AUXW_FU : FuncUnit;
def CRRP_FU : FuncUnit;
def CRWL_FU : FuncUnit;
def CRWH_FU : FuncUnit;
// NOPI_FU FuncUnits have been disabled due to DFA limitations (see ISSUEI_FP)
// This is safe since only NOP, IGET, and WAITIT instructions are using this unit.
// They can't be packetized together today since NOP instruction can't be emitted
// yet.
//
foreach I = 0-3 in def NOP#I#_FU : FuncUnit;


def ALL : InstrItinClass;
def BCU : InstrItinClass;
def BCU_TINY_TINY_MAU_XNOP : InstrItinClass;
def BCU_CRRP_CRWL_CRWH : InstrItinClass;
def BCU_TINY_AUXW_CRRP : InstrItinClass;
def TCA : InstrItinClass;
def ALU_NOP : InstrItinClass;
def ALU_TINY : InstrItinClass;
def ALU_TINY_X : InstrItinClass;
def ALU_TINY_Y : InstrItinClass;
def ALU_LITE : InstrItinClass;
def ALU_LITE_X : InstrItinClass;
def ALU_LITE_Y : InstrItinClass;
def ALU_LITE_CRWL : InstrItinClass;
def ALU_LITE_CRWH : InstrItinClass;
def ALU_FULL : InstrItinClass;
def ALU_FULL_X : InstrItinClass;
def ALU_FULL_Y : InstrItinClass;
def MAU : InstrItinClass;
def MAU_X : InstrItinClass;
def MAU_Y : InstrItinClass;
def MAU_AUXR : InstrItinClass;
def MAU_AUXR_X : InstrItinClass;
def MAU_AUXR_Y : InstrItinClass;
def LSU : InstrItinClass;
def LSU_X : InstrItinClass;
def LSU_Y : InstrItinClass;
def LSU_CRRP : InstrItinClass;
def LSU_CRRP_X : InstrItinClass;
def LSU_CRRP_Y : InstrItinClass;
def LSU_AUXR : InstrItinClass;
def LSU_AUXR_X : InstrItinClass;
def LSU_AUXR_Y : InstrItinClass;
def LSU_AUXW : InstrItinClass;
def LSU_AUXW_X : InstrItinClass;
def LSU_AUXW_Y : InstrItinClass;
def LSU_AUXR_AUXW : InstrItinClass;
def LSU_AUXR_AUXW_X : InstrItinClass;
def LSU_AUXR_AUXW_Y : InstrItinClass;


def KVXItinList {
list<InstrItinData> ItinList = [
  InstrItinData<ALL, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU]>
  ]>,
  InstrItinData<ALU_NOP, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [NOP0_FU, NOP1_FU, NOP2_FU, NOP3_FU]>
  ]>,
  InstrItinData<ALU_TINY, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>
  ]>,
  InstrItinData<ALU_TINY_X, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>
  ]>,
  InstrItinData<ALU_TINY_Y, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>
  ]>,
  InstrItinData<ALU_LITE, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>
  ]>,
  InstrItinData<ALU_LITE_X, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>
  ]>,
  InstrItinData<ALU_LITE_Y, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>
  ]>,
  InstrItinData<ALU_LITE_CRWL, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [CRWL_FU]>
  ]>,
  InstrItinData<ALU_LITE_CRWH, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [CRWH_FU]>
  ]>,
  InstrItinData<ALU_FULL, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [FULL_FU]>
  ]>,
  InstrItinData<ALU_FULL_X, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [FULL_FU]>
  ]>,
  InstrItinData<ALU_FULL_Y, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [FULL_FU]>
  ]>,
  InstrItinData<BCU, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [BCU_FU]>
  ]>,
  InstrItinData<BCU_CRRP_CRWL_CRWH, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [BCU_FU], 0>,
    InstrStage<1, [CRRP_FU], 0>,
    InstrStage<1, [CRWL_FU], 0>,
    InstrStage<1, [CRWH_FU]>
  ]>,
  InstrItinData<BCU_TINY_AUXW_CRRP, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [BCU_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [AUXW_FU], 0>,
    InstrStage<1, [CRRP_FU]>
  ]>,
  InstrItinData<BCU_TINY_TINY_MAU_XNOP, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [BCU_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU]>
    // InstrStage<1, [MAU_FU], 0>,
    // InstrStage<1, [NOP0_FU, NOP1_FU, NOP2_FU, NOP3_FU], 0>,
    // InstrStage<1, [NOP0_FU, NOP1_FU, NOP2_FU, NOP3_FU], 0>,
    // InstrStage<1, [NOP0_FU, NOP1_FU, NOP2_FU, NOP3_FU], 0>,
    // InstrStage<1, [NOP0_FU, NOP1_FU, NOP2_FU, NOP3_FU]>
  ]>,
  InstrItinData<TCA, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [TCA_FU]>
  ]>,
  InstrItinData<LSU, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU]>
  ]>,
  InstrItinData<LSU_X, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU]>
  ]>,
  InstrItinData<LSU_Y, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU]>
  ]>,
  InstrItinData<LSU_CRRP, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [CRRP_FU]>
  ]>,
  InstrItinData<LSU_CRRP_X, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [CRRP_FU]>
  ]>,
  InstrItinData<LSU_CRRP_Y, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [CRRP_FU]>
  ]>,
  InstrItinData<LSU_AUXR, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
  ]>,
  InstrItinData<LSU_AUXR_X, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
  ]>,
  InstrItinData<LSU_AUXR_Y, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
  ]>,
  InstrItinData<LSU_AUXW, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXW_FU]>
  ]>,
  InstrItinData<LSU_AUXW_X, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXW_FU]>
  ]>,
  InstrItinData<LSU_AUXW_Y, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXW_FU]>
  ]>,
  InstrItinData<LSU_AUXR_AUXW, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU], 0>,
    InstrStage<1, [AUXW_FU]>
  ]>,
  InstrItinData<LSU_AUXR_AUXW_X, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU], 0>,
    InstrStage<1, [AUXW_FU]>
  ]>,
  InstrItinData<LSU_AUXR_AUXW_Y, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU], 0>,
    InstrStage<1, [AUXW_FU]>
  ]>,
  InstrItinData<MAU, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU]>
  ]>,
  InstrItinData<MAU_X, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU]>
  ]>,
  InstrItinData<MAU_Y, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU]>
  ]>,
  InstrItinData<MAU_AUXR, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
  ]>,
  InstrItinData<MAU_AUXR_X, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
  ]>,
  InstrItinData<MAU_AUXR_Y, [
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    // InstrStage<1, [ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
  ]>
];
}


def KVXItineraries:
  ProcessorItineraries<[
    // ISSUE0_FU, ISSUE1_FU, ISSUE2_FU, ISSUE3_FU, ISSUE4_FU, ISSUE5_FU, ISSUE6_FU, ISSUE7_FU,
    TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU,
    LITE0_FU, LITE1_FU,
    FULL_FU,
    LSU_FU,
    MAU_FU,
    BCU_FU,
    TCA_FU,
    AUXR_FU,
    AUXW_FU,
    CRRP_FU,
    CRWL_FU,
    CRWH_FU
    // CRWH_FU,
    // NOP0_FU, NOP1_FU, NOP2_FU, NOP3_FU
  ], [], KVXItinList.ItinList>;


def KVXSchedMachineModel : SchedMachineModel {
  let Itineraries = KVXItineraries;
  let IssueWidth = 8;
}


def CopyI : SchedWrite;
let SchedModel = KVXSchedMachineModel in
def : InstRW<[CopyI], (instrs COPY)>;
