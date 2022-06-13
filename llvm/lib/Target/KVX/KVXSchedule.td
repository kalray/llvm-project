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
def MAU_FP : InstrItinClass;
def MAU_X : InstrItinClass;
def MAU_X_FP : InstrItinClass;
def MAU_Y : InstrItinClass;
def MAU_Y_FP : InstrItinClass;
def MAU_AUXR : InstrItinClass;
def MAU_AUXR_X : InstrItinClass;
def MAU_AUXR_Y : InstrItinClass;
def MAU_AUXR_FP : InstrItinClass;
def MAU_AUXR_X_FP : InstrItinClass;
def MAU_AUXR_Y_FP : InstrItinClass;

def LSU_STORE : InstrItinClass;
def LSU_X_STORE : InstrItinClass;
def LSU_Y_STORE : InstrItinClass;
def LSU_CRRP_STORE : InstrItinClass;
def LSU_CRRP_X_STORE : InstrItinClass;
def LSU_CRRP_Y_STORE : InstrItinClass;
def LSU_AUXR_STORE : InstrItinClass;
def LSU_AUXR_X_STORE : InstrItinClass;
def LSU_AUXR_Y_STORE : InstrItinClass;
def LSU_AUXW_STORE : InstrItinClass;
def LSU_AUXW_X_STORE : InstrItinClass;
def LSU_AUXW_Y_STORE : InstrItinClass;
def LSU_AUXR_AUXW_STORE : InstrItinClass;
def LSU_AUXR_AUXW_X_STORE : InstrItinClass;
def LSU_AUXR_AUXW_Y_STORE : InstrItinClass;

def LSU_LOAD : InstrItinClass;
def LSU_X_LOAD : InstrItinClass;
def LSU_Y_LOAD : InstrItinClass;
def LSU_CRRP_LOAD : InstrItinClass;
def LSU_CRRP_X_LOAD : InstrItinClass;
def LSU_CRRP_Y_LOAD : InstrItinClass;
def LSU_AUXR_LOAD : InstrItinClass;
def LSU_AUXR_X_LOAD : InstrItinClass;
def LSU_AUXR_Y_LOAD : InstrItinClass;
def LSU_AUXW_LOAD : InstrItinClass;
def LSU_AUXW_X_LOAD : InstrItinClass;
def LSU_AUXW_Y_LOAD : InstrItinClass;
def LSU_AUXR_AUXW_LOAD : InstrItinClass;
def LSU_AUXR_AUXW_X_LOAD : InstrItinClass;
def LSU_AUXR_AUXW_Y_LOAD : InstrItinClass;

def LSU_AUXW_ALCLR : InstrItinClass;
def LSU_AUXW_X_ALCLR : InstrItinClass;
def LSU_AUXW_Y_ALCLR : InstrItinClass;

def SWAPVO : InstrItinClass;

/**
 *  The KV3 pipeline has PF, ID, RR, E1..E5 stages
 *  PF can be ignored since there is no read/write in that stage
 *  Some instructions read at ID, most at RR, some at E1
 *  All instructions write their operands at E1..E5
 *
 *  In the KV3 VLIW, the resources only matter for encoding the bundles (aka
 *  there will never be a stall because of two instructions using the same MAU)
 *  Yet, the Packetizer still needs to know about resource usage in order to
 *  figure out how many instructions can be issued at the same cycle.
 *
 *  Our model, defined below, encodes the resource usage at the first stage
 *  (ID), then adds the other stages (RR, E1..E5) as stages that do not consume
 *  resources. To let the scheduler compute stalls accurately, we specify by
 *  hand the time of access of the different operands with the OperandCycles
 *  field.
 *
 *  In addition to the above, all instructions from the KV3 (not the TCA)
 *  benefit from a bypass mechanism. We also model this.
 */

/** TODO
 *  General issues with the current description:
 *  - ISSUE resources are not modeled, so the scheduler might be too greedy in
 *    the bundling; the packetizer will then split the bundle in two, which is
 *    suboptimal.
 */

def KVXItinList {
list<InstrItinData> ItinList = [
  // ALL reserves all resources to ensure nothing else gets scheduled
  InstrItinData<ALL, [
    InstrStage<1, [TINY0_FU], 0>,
    InstrStage<1, [TINY1_FU], 0>,
    InstrStage<1, [TINY2_FU], 0>,
    InstrStage<1, [TINY3_FU], 0>,
    InstrStage<1, [BCU_FU], 0>,
    InstrStage<1, [TCA_FU], 0>,
    InstrStage<1, [NOP0_FU], 0>,
    InstrStage<1, [NOP1_FU], 0>,
    InstrStage<1, [NOP2_FU], 0>,
    InstrStage<1, [NOP3_FU], 0>,
    ]
  >,
  InstrItinData<ALU_NOP, [
    InstrStage<1, [NOP0_FU, NOP1_FU, NOP2_FU, NOP3_FU]>
    ]
  >,
  InstrItinData<ALU_TINY, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>,
    ], [3, 2, 2]
  >,
  InstrItinData<ALU_TINY_X, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>,
    ], [3, 2, 2]
  >,
  InstrItinData<ALU_TINY_Y, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>
    ], [3, 2, 2]
  >,
  InstrItinData<ALU_LITE, [
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>
    ], [3, 2, 2]
  >,
  InstrItinData<ALU_LITE_X, [
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>
    ], [3, 2, 2]
  >,
  InstrItinData<ALU_LITE_Y, [
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>
    ], [3, 2, 2]
  >,
  InstrItinData<ALU_LITE_CRWL, [
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [CRWL_FU]>
    ], [3, 2, 2]
  >,
  InstrItinData<ALU_LITE_CRWH, [
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [CRWH_FU]>
    ], [3, 2, 2]
  >,
  InstrItinData<ALU_FULL, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [FULL_FU]>
  ], [3, 2, 2]
  >,
  InstrItinData<SFU, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [FULL_FU]>
  ], [13, 2, 2]
  >,
  InstrItinData<ALU_FULL_X, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [FULL_FU]>
    ], [3, 2, 2]
  >,
  InstrItinData<ALU_FULL_Y, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [FULL_FU]>
    ], [3, 2, 2]
  >,
  InstrItinData<BCU, [
    InstrStage<1, [BCU_FU]> // TODO: branch penalty not modeled
    ]
  >,
  InstrItinData<BCU_CRRP_CRWL_CRWH, [
    InstrStage<1, [BCU_FU], 0>,
    InstrStage<1, [CRRP_FU], 0>,
    InstrStage<1, [CRWL_FU], 0>,
    InstrStage<1, [CRWH_FU]>
    ], [5, 2, 2]
  >,
  InstrItinData<BCU_TINY_AUXW_CRRP, [
    InstrStage<1, [BCU_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [AUXW_FU], 0>,
    InstrStage<1, [CRRP_FU]>
    ], [5, 2, 2]
  >,
  // TODO : need to split this class into several to handle bypasses finely
  // (SFRs have no bypasses but GPRs do)
  InstrItinData<BCU_TINY_TINY_MAU_XNOP, [
    InstrStage<1, [BCU_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU], 0>,
    InstrStage<1, [NOP0_FU, NOP1_FU, NOP2_FU, NOP3_FU], 0>,
    InstrStage<1, [NOP0_FU, NOP1_FU, NOP2_FU, NOP3_FU], 0>,
    InstrStage<1, [NOP0_FU, NOP1_FU, NOP2_FU, NOP3_FU], 0>,
    InstrStage<1, [NOP0_FU, NOP1_FU, NOP2_FU, NOP3_FU]>
    ], [3, 2, 2]
  >,
  InstrItinData<TCA, [
    InstrStage<1, [TCA_FU]>
    ], [5, 2, 2]
  >,
  InstrItinData<TCA_FP16, [
    InstrStage<1, [TCA_FU]>
    ], [7, 2, 2]
  >,
  // NOTE : stores have up to 5 operands
  InstrItinData<LSU_STORE, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU]>
    ], [2, 2, 2, 2, 2]
  >,
  InstrItinData<LSU_X_STORE, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU]>
    ], [2, 2, 2, 2, 2]
  >,
  InstrItinData<LSU_Y_STORE, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU]>
    ], [2, 2, 2, 2, 2]
  >,
  // TODO : latency will be off for SV, and can't be easily fixed
  // Indeed, the QuadReg (who is read at E1) is either in 2nd or 3rd position
  // cf. MC_0B in KVXInstrInfo.td
  InstrItinData<LSU_CRRP_STORE, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [CRRP_FU]>
    ], [2, 2, 2, 2, 2]
  >,
  InstrItinData<LSU_CRRP_X_STORE, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [CRRP_FU]>
    ], [2, 2, 2, 2, 2]
  >,
  InstrItinData<LSU_CRRP_Y_STORE, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [CRRP_FU]>
    ], [2, 2, 2, 2, 2]
  >,
  InstrItinData<LSU_AUXR_STORE, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
    ], [2, 2, 2, 2, 2]
  >,
  InstrItinData<LSU_AUXR_X_STORE, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
    ], [2, 2, 2, 2, 2]
  >,
  InstrItinData<LSU_AUXR_Y_STORE, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
    ], [2, 2, 2, 2, 2]
  >,
  InstrItinData<LSU_AUXW_STORE, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [2, 2, 2, 2, 2]
  >,
  InstrItinData<LSU_AUXW_X_STORE, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [2, 2, 2, 2, 2]
  >,
  InstrItinData<LSU_AUXW_Y_STORE, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [2, 2, 2, 2, 2]
  >,
  InstrItinData<LSU_AUXR_AUXW_STORE, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [2, 2, 2, 2, 2]
  >,
  InstrItinData<LSU_AUXR_AUXW_X_STORE, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [2, 2, 2, 2, 2]
  >,
  InstrItinData<LSU_AUXR_AUXW_Y_STORE, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [2, 2, 2, 2, 2]
  >,
  // ALCLRW, ALCLRD: result available at E2
    InstrItinData<LSU_AUXW_ALCLR, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [4, 2, 2, 2, 2, 2]
  >,
  InstrItinData<LSU_AUXW_X_ALCLR, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [4, 2, 2, 2, 2, 2]
  >,
  InstrItinData<LSU_AUXW_Y_ALCLR, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [4, 2, 2, 2, 2, 2]
  >,
  InstrItinData<LSU_LOAD, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU]>
    ], [5, 2, 2, 2, 2, 2]
  >,
  InstrItinData<LSU_X_LOAD, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU]>
    ], [5, 2, 2, 2, 2, 2]
  >,
  InstrItinData<LSU_Y_LOAD, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU]>
    ], [5, 2, 2, 2, 2, 2]
  >,
  InstrItinData<LSU_CRRP_LOAD, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [CRRP_FU]>
    ], [5, 2, 2, 2, 2, 2]
  >,
  InstrItinData<LSU_CRRP_X_LOAD, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [CRRP_FU]>
    ], [5, 2, 2, 2, 2, 2]
  >,
  InstrItinData<LSU_CRRP_Y_LOAD, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [CRRP_FU]>
    ], [5, 2, 2, 2, 2, 2]
  >,
  InstrItinData<LSU_AUXR_LOAD, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
    ], [5, 2, 2, 2, 2, 2]
  >,
  InstrItinData<LSU_AUXR_X_LOAD, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
    ], [5, 2, 2, 2, 2, 2]
  >,
  InstrItinData<LSU_AUXR_Y_LOAD, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
    ], [5, 2, 2, 2, 2, 2]
  >,
  InstrItinData<LSU_AUXW_LOAD, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [5, 2, 2, 2, 2, 2]
  >,
  InstrItinData<LSU_AUXW_X_LOAD, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [5, 2, 2, 2, 2, 2]
  >,
  InstrItinData<LSU_AUXW_Y_LOAD, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [5, 2, 2, 2, 2, 2]
  >,
  InstrItinData<LSU_AUXR_AUXW_LOAD, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [5, 2, 2, 2, 2, 2]
  >,
  InstrItinData<LSU_AUXR_AUXW_X_LOAD, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [5, 2, 2, 2, 2, 2]
  >,
  InstrItinData<LSU_AUXR_AUXW_Y_LOAD, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [5, 2, 2, 2, 2, 2]
  >,
  InstrItinData<MAU, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU]>
    ], [4, 2, 2]
  >,
  InstrItinData<MAU_FP, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU]>
    ], [6, 2, 2]
  >,
  InstrItinData<MAU_X, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU]>
    ], [4, 2, 2]
  >,
  InstrItinData<MAU_X_FP, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU]>
    ], [6, 2, 2]
  >,
  InstrItinData<MAU_Y, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU]>
    ], [4, 2, 2]
  >,
  InstrItinData<MAU_Y_FP, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU]>
    ], [6, 2, 2]
  >,
  InstrItinData<MAU_AUXR, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
    ], [4, 2, 2]
  >,
  InstrItinData<MAU_AUXR_X, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
    ], [4, 2, 2]
  >,
  InstrItinData<MAU_AUXR_Y, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
    ], [4, 2, 2]
  >,
  InstrItinData<MAU_AUXR_FP, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
    ], [6, 2, 2]
  >,
  InstrItinData<MAU_AUXR_X_FP, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
    ], [6, 2, 2]
  >,
  InstrItinData<MAU_AUXR_Y_FP, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
    ], [6, 2, 2]
  >,
  // TODO : add OperandLatencies here as well
  // We need to expand SWAPVOp pseudos after packetizer. To correctly schedule/bundle them,
  // we need a dedicated scheduling itinerary for it.
  InstrItinData<SWAPVO, [
    // moveto E == ALU_LITE_CRWL
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [CRWL_FU], 0>,
    // moveto O == ALU_LITE_CRWH
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [CRWH_FU], 0>,
    // movefo == BCU_TINY_AUXW_CRRP
    InstrStage<3, [BCU_FU], 0>,
    InstrStage<3, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<3, [AUXW_FU], 0>,
    InstrStage<3, [CRRP_FU]>
  ], [3, 5, 2, 2]>
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
