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
// Last generated: 2020-06-20 21:47:17.941683.

// TODO: This file has been modified manually! Please fix the generator.
//
// - NOPI_FU units usage has been restored.
// - Fix KVXSchedMachineModel properties.
// - Set average/estimated cycle costs of all InstrItinClass.

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
foreach I = 0-3 in def NOP#I#_FU : FuncUnit;


def ALL : InstrItinClass;
def BCU : InstrItinClass;
def BCU_TINY_TINY_MAU_XNOP : InstrItinClass;
def BCU_CRRP_CRWL_CRWH : InstrItinClass;
def BCU_TINY_AUXW_CRRP : InstrItinClass;
def TCA : InstrItinClass;
def TCA_FP16 : InstrItinClass;
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
def SFU : InstrItinClass;
def ALU_FULL_X : InstrItinClass;
def ALU_FULL_Y : InstrItinClass;
def MAU : InstrItinClass;
def MAU_FP16 : InstrItinClass;
def MAU_X : InstrItinClass;
def MAU_X_FP16 : InstrItinClass;
def MAU_Y : InstrItinClass;
def MAU_Y_FP16 : InstrItinClass;
def MAU_AUXR : InstrItinClass;
def MAU_AUXR_X : InstrItinClass;
def MAU_AUXR_Y : InstrItinClass;
def MAU_AUXR_FP16 : InstrItinClass;
def MAU_AUXR_X_FP16 : InstrItinClass;
def MAU_AUXR_Y_FP16 : InstrItinClass;
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
def SWAPVO : InstrItinClass;


def KVXItinList {
list<InstrItinData> ItinList = [
  InstrItinData<ALL, [
    // This itineray is empty, it consumes all resources. This is checked by KVXPacketizer.
  ]>,
  InstrItinData<ALU_NOP, [
    InstrStage<1, [NOP0_FU, NOP1_FU, NOP2_FU, NOP3_FU]>
  ]>,
  InstrItinData<ALU_TINY, [
    InstrStage<3, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>
  ]>,
  InstrItinData<ALU_TINY_X, [
    InstrStage<3, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>
  ]>,
  InstrItinData<ALU_TINY_Y, [
    InstrStage<3, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>
  ]>,
  InstrItinData<ALU_LITE, [
    InstrStage<3, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<3, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>
  ]>,
  InstrItinData<ALU_LITE_X, [
    InstrStage<3, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<3, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>
  ]>,
  InstrItinData<ALU_LITE_Y, [
    InstrStage<3, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<3, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>
  ]>,
  InstrItinData<ALU_LITE_CRWL, [
    InstrStage<3, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<3, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<3, [CRWL_FU]>
  ]>,
  InstrItinData<ALU_LITE_CRWH, [
    InstrStage<3, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<3, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<3, [CRWH_FU]>
  ]>,
  InstrItinData<ALU_FULL, [
    InstrStage<4, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<4, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<4, [FULL_FU]>
  ]>,
  InstrItinData<SFU, [
    InstrStage<16, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<16, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<16, [FULL_FU]>
  ]>,
  InstrItinData<ALU_FULL_X, [
    InstrStage<3, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<3, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<3, [FULL_FU]>
  ]>,
  InstrItinData<ALU_FULL_Y, [
    InstrStage<3, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<3, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<3, [FULL_FU]>
  ]>,
  InstrItinData<BCU, [
    InstrStage<2, [BCU_FU]>
  ]>,
  InstrItinData<BCU_CRRP_CRWL_CRWH, [
    InstrStage<5, [BCU_FU], 0>,
    InstrStage<5, [CRRP_FU], 0>,
    InstrStage<5, [CRWL_FU], 0>,
    InstrStage<5, [CRWH_FU]>
  ]>,
  InstrItinData<BCU_TINY_AUXW_CRRP, [
    InstrStage<5, [BCU_FU], 0>,
    InstrStage<5, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<5, [AUXW_FU], 0>,
    InstrStage<5, [CRRP_FU]>
  ]>,
  InstrItinData<BCU_TINY_TINY_MAU_XNOP, [
    InstrStage<3, [BCU_FU], 0>,
    InstrStage<3, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<3, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<3, [MAU_FU], 0>,
    InstrStage<3, [NOP0_FU, NOP1_FU, NOP2_FU, NOP3_FU], 0>,
    InstrStage<3, [NOP0_FU, NOP1_FU, NOP2_FU, NOP3_FU], 0>,
    InstrStage<3, [NOP0_FU, NOP1_FU, NOP2_FU, NOP3_FU], 0>,
    InstrStage<3, [NOP0_FU, NOP1_FU, NOP2_FU, NOP3_FU]>
  ]>,
  InstrItinData<TCA, [
    InstrStage<5, [TCA_FU]>
  ]>,
  InstrItinData<TCA_FP16, [
    InstrStage<7, [TCA_FU]>
  ]>,
  InstrItinData<LSU, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU]>
  ]>,
  InstrItinData<LSU_X, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU]>
  ]>,
  InstrItinData<LSU_Y, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU]>
  ]>,
  InstrItinData<LSU_CRRP, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [CRRP_FU]>
  ]>,
  InstrItinData<LSU_CRRP_X, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [CRRP_FU]>
  ]>,
  InstrItinData<LSU_CRRP_Y, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [CRRP_FU]>
  ]>,
  InstrItinData<LSU_AUXR, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
  ]>,
  InstrItinData<LSU_AUXR_X, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
  ]>,
  InstrItinData<LSU_AUXR_Y, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
  ]>,
  InstrItinData<LSU_AUXW, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXW_FU]>
  ]>,
  InstrItinData<LSU_AUXW_X, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXW_FU]>
  ]>,
  InstrItinData<LSU_AUXW_Y, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXW_FU]>
  ]>,
  InstrItinData<LSU_AUXR_AUXW, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU], 0>,
    InstrStage<1, [AUXW_FU]>
  ]>,
  InstrItinData<LSU_AUXR_AUXW_X, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU], 0>,
    InstrStage<1, [AUXW_FU]>
  ]>,
  InstrItinData<LSU_AUXR_AUXW_Y, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU], 0>,
    InstrStage<1, [AUXW_FU]>
  ]>,
  InstrItinData<MAU, [
    InstrStage<4, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<4, [MAU_FU]>
  ]>,
  InstrItinData<MAU_FP16, [
    InstrStage<3, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<3, [MAU_FU]>
  ]>,
  InstrItinData<MAU_X, [
    InstrStage<4, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<4, [MAU_FU]>
  ]>,
  InstrItinData<MAU_X_FP16, [
    InstrStage<3, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<3, [MAU_FU]>
  ]>,
  InstrItinData<MAU_Y, [
    InstrStage<4, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<4, [MAU_FU]>
  ]>,
  InstrItinData<MAU_Y_FP16, [
    InstrStage<3, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<3, [MAU_FU]>
  ]>,
  InstrItinData<MAU_AUXR, [
    InstrStage<4, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<4, [MAU_FU], 0>,
    InstrStage<4, [AUXR_FU]>
  ]>,
  InstrItinData<MAU_AUXR_X, [
    InstrStage<4, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<4, [MAU_FU], 0>,
    InstrStage<4, [AUXR_FU]>
  ]>,
  InstrItinData<MAU_AUXR_Y, [
    InstrStage<4, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<4, [MAU_FU], 0>,
    InstrStage<4, [AUXR_FU]>
  ]>,
  InstrItinData<MAU_AUXR_FP16, [
    InstrStage<3, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<3, [MAU_FU], 0>,
    InstrStage<3, [AUXR_FU]>
  ]>,
  InstrItinData<MAU_AUXR_X_FP16, [
    InstrStage<3, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<3, [MAU_FU], 0>,
    InstrStage<3, [AUXR_FU]>
  ]>,
  InstrItinData<MAU_AUXR_Y_FP16, [
    InstrStage<3, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<3, [MAU_FU], 0>,
    InstrStage<3, [AUXR_FU]>
  ]>,
  // We need to expand SWAPVOp pseudos after packetizer. To correctly schedule/bundle them,
  // we need a dedicated scheduling itinerary for it.
  InstrItinData<SWAPVO, [
    // moveto E == ALU_LITE_CRWL
    InstrStage<3, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<3, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<3, [CRWL_FU], 0>,
    // moveto O == ALU_LITE_CRWH
    InstrStage<3, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<3, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<3, [CRWH_FU], 0>,
    // movefo == BCU_TINY_AUXW_CRRP
    InstrStage<5, [BCU_FU], 0>,
    InstrStage<5, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<5, [AUXW_FU], 0>,
    InstrStage<5, [CRRP_FU]>
  ]>
];
}


def KVXItineraries:
  ProcessorItineraries<[
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
    CRWH_FU,
    NOP0_FU, NOP1_FU, NOP2_FU, NOP3_FU
  ], [], KVXItinList.ItinList>;


def KVXSchedMachineModel : SchedMachineModel {
  let Itineraries = KVXItineraries;
  let MicroOpBufferSize = 0; // VLIW In-order
  let IssueWidth = 6; // 5-issue VLIW core + 1-issue TCA
  let LoadLatency = 5; // Cycles to access L1$, (23 cycles if miss)
  let PostRAScheduler = 1;
  let CompleteModel = 1;
  let MispredictPenalty = 0;
}


def CopyI : SchedWrite;
let SchedModel = KVXSchedMachineModel in
def : InstRW<[CopyI], (instrs COPY)>;
