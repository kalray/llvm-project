//===-- K1CSchedule.td - Scheduling Description for K1C Target ------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file describes the K1C scheduling informations in TableGen format.
//
//===----------------------------------------------------------------------===//

def K1C_FWD : Bypass;

//foreach Index = 0-7 in def ISSUE#Index#_UNIT : FuncUnit; // 8 - See K1CVLIWPacketizerList.cpp
foreach Index = 0-3 in def TINY#Index#_UNIT : FuncUnit; // 4
foreach Index = 0-1 in def LITE#Index#_UNIT : FuncUnit; // 2
def FULL_UNIT : FuncUnit; // 1
def LSU_UNIT : FuncUnit; // 1
def MAU_UNIT : FuncUnit; // 1
def BCU_UNIT : FuncUnit; // 1
def TCA_UNIT : FuncUnit; // 1
def AUXR_UNIT : FuncUnit; // 1
def AUXW_UNIT : FuncUnit; // 1
def CRRP_UNIT : FuncUnit; // 1
def CRWL_UNIT : FuncUnit; // 1
def CRWH_UNIT : FuncUnit; // 1
foreach Index = 0-3 in def NOP#Index#_UNIT : FuncUnit; // 4

def ALL : InstrItinClass;
def ALU_FULL : InstrItinClass;
def ALU_FULL_X : InstrItinClass;
def ALU_FULL_Y : InstrItinClass;
def ALU_LITE : InstrItinClass;
def ALU_LITE_X : InstrItinClass;
def ALU_LITE_Y : InstrItinClass;
def ALU_LITE_CRWH : InstrItinClass;
def ALU_LITE_CRWL : InstrItinClass;
def ALU_NOP : InstrItinClass;
def ALU_TINY : InstrItinClass;
def ALU_TINY_X : InstrItinClass;
def ALU_TINY_Y : InstrItinClass;
def BCU : InstrItinClass;
def BCU_CRRP_CRWL_CRWH : InstrItinClass;
def BCU_TINY_AUXW_CRRP : InstrItinClass;
def BCU_TINY_TINY_MAU_XNOP : InstrItinClass;
def LSU : InstrItinClass;
def LSU_X : InstrItinClass;
def LSU_Y : InstrItinClass;
def LSU_AUXR : InstrItinClass;
def LSU_AUXR_X : InstrItinClass;
def LSU_AUXR_Y : InstrItinClass;
def LSU_AUXR_AUXW : InstrItinClass;
def LSU_AUXR_AUXW_X : InstrItinClass;
def LSU_AUXR_AUXW_Y : InstrItinClass;
def LSU_AUXW : InstrItinClass;
def LSU_AUXW_X : InstrItinClass;
def LSU_AUXW_Y : InstrItinClass;
def LSU_CRRP : InstrItinClass;
def LSU_CRRP_X : InstrItinClass;
def LSU_CRRP_Y : InstrItinClass;
def MAU : InstrItinClass;
def MAU_X : InstrItinClass;
def MAU_Y : InstrItinClass;
def MAU_AUXR : InstrItinClass;
def MAU_AUXR_X : InstrItinClass;
def MAU_AUXR_Y : InstrItinClass;
def TCA : InstrItinClass;

def CMB_BCU_CRRP_CRW_UNIT : FuncUnit;
def CMB_BCU_AUXW_CRRP_UNIT : FuncUnit;
def CMB_MAU_BCU_XNOP_UNIT : FuncUnit;
def CMB_LSU_AUXR_UNIT : FuncUnit;
def CMB_LSU_AUX_UNIT : FuncUnit;
def CMB_LSU_AUXW_UNIT : FuncUnit;
def CMB_LSU_CRRP_UNIT : FuncUnit;
def CMB_MAU_AUXR_UNIT : FuncUnit;

def K1CCombo :
  ComboFuncUnits<[
    ComboFuncData<CMB_BCU_CRRP_CRW_UNIT, [BCU_UNIT, CRRP_UNIT,
                                          CRWL_UNIT, CRWH_UNIT]>,
    ComboFuncData<CMB_BCU_AUXW_CRRP_UNIT, [BCU_UNIT, AUXW_UNIT, CRRP_UNIT]>,
    ComboFuncData<CMB_MAU_BCU_XNOP_UNIT, [MAU_UNIT, BCU_UNIT, NOP0_UNIT,
                                          NOP1_UNIT, NOP2_UNIT, NOP3_UNIT]>,
    ComboFuncData<CMB_LSU_AUXR_UNIT, [LSU_UNIT, AUXR_UNIT]>,
    ComboFuncData<CMB_LSU_AUX_UNIT, [LSU_UNIT, AUXR_UNIT, AUXW_UNIT]>,
    ComboFuncData<CMB_LSU_AUXW_UNIT, [LSU_UNIT, AUXW_UNIT]>,
    ComboFuncData<CMB_LSU_CRRP_UNIT, [LSU_UNIT, CRRP_UNIT]>,
    ComboFuncData<CMB_MAU_AUXR_UNIT, [MAU_UNIT, AUXR_UNIT]>
    ]>;

def K1CItinList {
  list<InstrItinData> ItinList = [
    InstrItinData<ALL, []>,

    InstrItinData<ALU_FULL, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>,
      InstrStage<1, [LITE0_UNIT, LITE1_UNIT]>,
      InstrStage<1, [FULL_UNIT]>
    ]>,

    InstrItinData<ALU_FULL_X, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>,
      InstrStage<1, [LITE0_UNIT, LITE1_UNIT]>,
      InstrStage<1, [FULL_UNIT]>
    ]>,

    InstrItinData<ALU_FULL_Y, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>,
      InstrStage<1, [LITE0_UNIT, LITE1_UNIT]>,
      InstrStage<1, [FULL_UNIT]>
    ]>,

    InstrItinData<ALU_LITE, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>,
      InstrStage<1, [LITE0_UNIT, LITE1_UNIT]>
    ]>,

    InstrItinData<ALU_LITE_X, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>,
      InstrStage<1, [LITE0_UNIT, LITE1_UNIT]>
    ]>,

    InstrItinData<ALU_LITE_Y, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>,
      InstrStage<1, [LITE0_UNIT, LITE1_UNIT]>
    ]>,

    InstrItinData<ALU_LITE_CRWH, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>,
      InstrStage<1, [LITE0_UNIT, LITE1_UNIT]>,
      InstrStage<1, [CRWH_UNIT]>
    ]>,

    InstrItinData<ALU_LITE_CRWL, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>,
      InstrStage<1, [LITE0_UNIT, LITE1_UNIT]>,
      InstrStage<1, [CRWL_UNIT]>
    ]>,

    InstrItinData<ALU_NOP, [
      InstrStage<1, [NOP0_UNIT, NOP1_UNIT, NOP2_UNIT, NOP3_UNIT]>
    ]>,

    InstrItinData<ALU_TINY, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>
    ]>,

    InstrItinData<ALU_TINY_X, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>
    ]>,

    InstrItinData<ALU_TINY_Y, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>
    ]>,

    InstrItinData<BCU, [
      InstrStage<1, [BCU_UNIT]>
    ]>,

    InstrItinData<BCU_CRRP_CRWL_CRWH, [
      InstrStage<1, [CMB_BCU_CRRP_CRW_UNIT]>
    ]>,

    InstrItinData<BCU_TINY_AUXW_CRRP, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>,
      InstrStage<1, [CMB_BCU_AUXW_CRRP_UNIT]>
    ]>,

    InstrItinData<BCU_TINY_TINY_MAU_XNOP, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>,
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>,
      InstrStage<1, [CMB_MAU_BCU_XNOP_UNIT]>
    ]>,

    InstrItinData<LSU, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>,
      InstrStage<1, [LSU_UNIT]>
    ]>,

    InstrItinData<LSU_X, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>,
      InstrStage<1, [LSU_UNIT]>
    ]>,

    InstrItinData<LSU_Y, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>,
      InstrStage<1, [LSU_UNIT]>
    ]>,

    InstrItinData<LSU_AUXR, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>,
      InstrStage<1, [CMB_LSU_AUXR_UNIT]>
    ]>,

    InstrItinData<LSU_AUXR_X, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>,
      InstrStage<1, [CMB_LSU_AUXR_UNIT]>
    ]>,

    InstrItinData<LSU_AUXR_Y, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>,
      InstrStage<1, [CMB_LSU_AUXR_UNIT]>
    ]>,

    InstrItinData<LSU_AUXR_AUXW, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>,
      InstrStage<1, [CMB_LSU_AUX_UNIT]>
    ]>,

    InstrItinData<LSU_AUXR_AUXW_X, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>,
      InstrStage<1, [CMB_LSU_AUX_UNIT]>
    ]>,

    InstrItinData<LSU_AUXR_AUXW_Y, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>,
      InstrStage<1, [CMB_LSU_AUX_UNIT]>
    ]>,

    InstrItinData<LSU_AUXW, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>,
      InstrStage<1, [CMB_LSU_AUXW_UNIT]>
    ]>,

    InstrItinData<LSU_AUXW_X, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>,
      InstrStage<1, [CMB_LSU_AUXW_UNIT]>
    ]>,

    InstrItinData<LSU_AUXW_Y, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>,
      InstrStage<1, [CMB_LSU_AUXW_UNIT]>
    ]>,

    InstrItinData<LSU_CRRP, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>,
      InstrStage<1, [CMB_LSU_CRRP_UNIT]>
    ]>,

    InstrItinData<LSU_CRRP_X, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>,
      InstrStage<1, [CMB_LSU_CRRP_UNIT]>
    ]>,

    InstrItinData<LSU_CRRP_Y, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>,
      InstrStage<1, [CMB_LSU_CRRP_UNIT]>
    ]>,

    InstrItinData<MAU, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>,
      InstrStage<1, [MAU_UNIT]>
    ]>,

    InstrItinData<MAU_X, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>,
      InstrStage<1, [MAU_UNIT]>
    ]>,

    InstrItinData<MAU_Y, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>,
      InstrStage<1, [MAU_UNIT]>
    ]>,

    InstrItinData<MAU_AUXR, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>,
      InstrStage<1, [CMB_MAU_AUXR_UNIT]>
    ]>,

    InstrItinData<MAU_AUXR_X, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>,
      InstrStage<1, [CMB_MAU_AUXR_UNIT]>
    ]>,

    InstrItinData<MAU_AUXR_Y, [
      InstrStage<1, [TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT]>,
      InstrStage<1, [CMB_MAU_AUXR_UNIT]>
    ]>,

    InstrItinData<TCA, [
      InstrStage<1, [TCA_UNIT]>
    ]>
  ];
}

def K1CItineraries:
  ProcessorItineraries<[TINY0_UNIT, TINY1_UNIT, TINY2_UNIT, TINY3_UNIT,
                        LITE0_UNIT, LITE1_UNIT, FULL_UNIT, LSU_UNIT, MAU_UNIT,
                        BCU_UNIT, TCA_UNIT, AUXR_UNIT, AUXW_UNIT, CRRP_UNIT,
                        CRWH_UNIT, CRWL_UNIT, NOP0_UNIT, NOP1_UNIT, NOP2_UNIT,
                        NOP3_UNIT, CMB_BCU_CRRP_CRW_UNIT, CMB_BCU_AUXW_CRRP_UNIT,
                        CMB_MAU_BCU_XNOP_UNIT, CMB_LSU_AUXR_UNIT,
                        CMB_LSU_AUX_UNIT, CMB_LSU_AUXW_UNIT, CMB_LSU_CRRP_UNIT,
                        CMB_MAU_AUXR_UNIT],
                        [K1C_FWD], K1CItinList.ItinList>;

def K1CSchedMachineModel : SchedMachineModel {
  let Itineraries = K1CItineraries;
  let CompleteModel = 0;
}
