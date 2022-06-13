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

// This file contains two distinct scheduling models: the legacy itineraries
// and the more recent SchedModel model.
//
// Latency-wise: itineraries are used by all schedulers. When both are present,
// which is the case here, itineraries are used.
//
// Resource-wise: MachineScheduler uses a conjunction of both (rejects the
// scheduling if one model says there is not enough resource). All other
// schedulers (ScheduleDAG, PostRATDList, Packetizer) rely on itineraries.

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

defvar ALL_ITIN_CLASSES = [
  ALL, BCU, BCU_TINY_TINY_MAU_XNOP, BCU_CRRP_CRWL_CRWH, BCU_TINY_AUXW_CRRP,
  TCA, TCA_FP16,
  ALU_NOP, ALU_TINY, ALU_TINY_X, ALU_TINY_Y,
  ALU_LITE, ALU_LITE_X, ALU_LITE_Y, ALU_LITE_CRWL, ALU_LITE_CRWH,
  ALU_FULL, SFU, ALU_FULL_X, ALU_FULL_Y,
  MAU, MAU_FP, MAU_X, MAU_X_FP, MAU_Y, MAU_Y_FP,
  MAU_AUXR, MAU_AUXR_X, MAU_AUXR_Y, MAU_AUXR_FP, MAU_AUXR_X_FP, MAU_AUXR_Y_FP,
  LSU_STORE, LSU_X_STORE, LSU_Y_STORE,
  LSU_CRRP_STORE, LSU_CRRP_X_STORE, LSU_CRRP_Y_STORE,
  LSU_AUXR_STORE, LSU_AUXR_X_STORE, LSU_AUXR_Y_STORE,
  LSU_AUXW_STORE, LSU_AUXW_X_STORE, LSU_AUXW_Y_STORE,
  LSU_AUXR_AUXW_STORE, LSU_AUXR_AUXW_X_STORE, LSU_AUXR_AUXW_Y_STORE,
  LSU_LOAD, LSU_X_LOAD, LSU_Y_LOAD,
  LSU_CRRP_LOAD, LSU_CRRP_X_LOAD, LSU_CRRP_Y_LOAD,
  LSU_AUXR_LOAD, LSU_AUXR_X_LOAD, LSU_AUXR_Y_LOAD,
  LSU_AUXW_LOAD, LSU_AUXW_X_LOAD, LSU_AUXW_Y_LOAD,
  LSU_AUXR_AUXW_LOAD, LSU_AUXR_AUXW_X_LOAD, LSU_AUXR_AUXW_Y_LOAD,
  LSU_AUXW_ALCLR, LSU_AUXW_X_ALCLR, LSU_AUXW_Y_ALCLR,
];

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
    ], [], [], 8
  >,
  InstrItinData<ALU_NOP, [
    InstrStage<1, [NOP0_FU, NOP1_FU, NOP2_FU, NOP3_FU]>
    ], [], [], 1
  >,
  InstrItinData<ALU_TINY, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>,
    ], [2, 2, 2], [], 1
  >,
  InstrItinData<ALU_TINY_X, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>,
    ], [2, 2, 2], [], 2
  >,
  InstrItinData<ALU_TINY_Y, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>
    ], [2, 2, 2], [], 3
  >,
  InstrItinData<ALU_LITE, [
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>
    ], [2, 2, 2], [], 1
  >,
  InstrItinData<ALU_LITE_X, [
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>
    ], [2, 2, 2], [], 2
  >,
  InstrItinData<ALU_LITE_Y, [
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>
    ], [2, 2, 2], [], 3
  >,
  InstrItinData<ALU_LITE_CRWL, [
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [CRWL_FU]>
    ], [2, 2, 2], [], 1
  >,
  InstrItinData<ALU_LITE_CRWH, [
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [CRWH_FU]>
    ], [2, 2, 2], [], 1
  >,
  InstrItinData<ALU_FULL, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [FULL_FU]>
  ], [2, 2, 2], [], 1
  >,
  InstrItinData<SFU, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [FULL_FU]>
  ], [12, 2, 2], [], 1
  >,
  InstrItinData<ALU_FULL_X, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [FULL_FU]>
    ], [2, 2, 2], [], 2
  >,
  InstrItinData<ALU_FULL_Y, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [FULL_FU]>
    ], [2, 2, 2], [], 3
  >,
  InstrItinData<BCU, [
    InstrStage<1, [BCU_FU]> // TODO: branch penalty not modeled
    ], [], [], 1
  >,
  InstrItinData<BCU_CRRP_CRWL_CRWH, [
    InstrStage<1, [BCU_FU], 0>,
    InstrStage<1, [CRRP_FU], 0>,
    InstrStage<1, [CRWL_FU], 0>,
    InstrStage<1, [CRWH_FU]>
    ], [4, 2, 2], [], 1
  >,
  InstrItinData<BCU_TINY_AUXW_CRRP, [
    InstrStage<1, [BCU_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [AUXW_FU], 0>,
    InstrStage<1, [CRRP_FU]>
    ], [4, 2, 2], [], 1
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
    ], [2, 2, 2], [], 1
  >,
  InstrItinData<TCA, [
    InstrStage<1, [TCA_FU]>
    ], [4, 2, 2], [], 1
  >,
  InstrItinData<TCA_FP16, [
    InstrStage<1, [TCA_FU]>
    ], [6, 2, 2], [], 1
  >,
  // NOTE : stores have up to 5 operands
  InstrItinData<LSU_STORE, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU]>
    ], [2, 2, 2, 2, 2], [], 1
  >,
  InstrItinData<LSU_X_STORE, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU]>
    ], [2, 2, 2, 2, 2], [], 2
  >,
  InstrItinData<LSU_Y_STORE, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU]>
    ], [2, 2, 2, 2, 2], [], 3
  >,
  // TODO : latency will be off for SV, and can't be easily fixed
  // Indeed, the QuadReg (who is read at E1) is either in 2nd or 3rd position
  // cf. MC_0B in KVXInstrInfo.td
  InstrItinData<LSU_CRRP_STORE, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [CRRP_FU]>
    ], [2, 2, 2, 2, 2], [], 1
  >,
  InstrItinData<LSU_CRRP_X_STORE, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [CRRP_FU]>
    ], [2, 2, 2, 2, 2], [], 2
  >,
  InstrItinData<LSU_CRRP_Y_STORE, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [CRRP_FU]>
    ], [2, 2, 2, 2, 2], [], 3
  >,
  InstrItinData<LSU_AUXR_STORE, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
    ], [2, 2, 2, 2, 2], [], 1
  >,
  InstrItinData<LSU_AUXR_X_STORE, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
    ], [2, 2, 2, 2, 2], [], 2
  >,
  InstrItinData<LSU_AUXR_Y_STORE, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
    ], [2, 2, 2, 2, 2], [], 3
  >,
  InstrItinData<LSU_AUXW_STORE, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [2, 2, 2, 2, 2], [], 1
  >,
  InstrItinData<LSU_AUXW_X_STORE, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [2, 2, 2, 2, 2], [], 2
  >,
  InstrItinData<LSU_AUXW_Y_STORE, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [2, 2, 2, 2, 2], [], 3
  >,
  InstrItinData<LSU_AUXR_AUXW_STORE, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [2, 2, 2, 2, 2], [], 1
  >,
  InstrItinData<LSU_AUXR_AUXW_X_STORE, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [2, 2, 2, 2, 2], [], 2
  >,
  InstrItinData<LSU_AUXR_AUXW_Y_STORE, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [2, 2, 2, 2, 2], [], 3
  >,
  // ALCLRW, ALCLRD: result available at E2
    InstrItinData<LSU_AUXW_ALCLR, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [3, 2, 2, 2, 2, 2], [], 1
  >,
  InstrItinData<LSU_AUXW_X_ALCLR, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [3, 2, 2, 2, 2, 2], [], 2
  >,
  InstrItinData<LSU_AUXW_Y_ALCLR, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [3, 2, 2, 2, 2, 2], [], 3
  >,
  InstrItinData<LSU_LOAD, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU]>
    ], [4, 2, 2, 2, 2, 2], [], 1
  >,
  InstrItinData<LSU_X_LOAD, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU]>
    ], [4, 2, 2, 2, 2, 2], [], 2
  >,
  InstrItinData<LSU_Y_LOAD, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU]>
    ], [4, 2, 2, 2, 2, 2], [], 3
  >,
  InstrItinData<LSU_CRRP_LOAD, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [CRRP_FU]>
    ], [4, 2, 2, 2, 2, 2], [], 1
  >,
  InstrItinData<LSU_CRRP_X_LOAD, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [CRRP_FU]>
    ], [4, 2, 2, 2, 2, 2], [], 2
  >,
  InstrItinData<LSU_CRRP_Y_LOAD, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [CRRP_FU]>
    ], [4, 2, 2, 2, 2, 2], [], 3
  >,
  InstrItinData<LSU_AUXR_LOAD, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
    ], [4, 2, 2, 2, 2, 2], [], 1
  >,
  InstrItinData<LSU_AUXR_X_LOAD, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
    ], [4, 2, 2, 2, 2, 2], [], 2
  >,
  InstrItinData<LSU_AUXR_Y_LOAD, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
    ], [4, 2, 2, 2, 2, 2], [], 3
  >,
  InstrItinData<LSU_AUXW_LOAD, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [4, 2, 2, 2, 2, 2], [], 1
  >,
  InstrItinData<LSU_AUXW_X_LOAD, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [4, 2, 2, 2, 2, 2], [], 2
  >,
  InstrItinData<LSU_AUXW_Y_LOAD, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [4, 2, 2, 2, 2, 2], [], 3
  >,
  InstrItinData<LSU_AUXR_AUXW_LOAD, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [4, 2, 2, 2, 2, 2], [], 1
  >,
  InstrItinData<LSU_AUXR_AUXW_X_LOAD, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [4, 2, 2, 2, 2, 2], [], 2
  >,
  InstrItinData<LSU_AUXR_AUXW_Y_LOAD, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [4, 2, 2, 2, 2, 2], [], 3
  >,
  InstrItinData<MAU, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU]>
    ], [3, 2, 2], [], 1
  >,
  InstrItinData<MAU_FP, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU]>
    ], [5, 2, 2], [], 1
  >,
  InstrItinData<MAU_X, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU]>
    ], [3, 2, 2], [], 2
  >,
  InstrItinData<MAU_X_FP, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU]>
    ], [5, 2, 2], [], 2
  >,
  InstrItinData<MAU_Y, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU]>
    ], [3, 2, 2], [], 3
  >,
  InstrItinData<MAU_Y_FP, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU]>
    ], [5, 2, 2], [], 3
  >,
  InstrItinData<MAU_AUXR, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
    ], [3, 2, 2], [], 1
  >,
  InstrItinData<MAU_AUXR_X, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
    ], [3, 2, 2], [], 2
  >,
  InstrItinData<MAU_AUXR_Y, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
    ], [3, 2, 2], [], 3
  >,
  InstrItinData<MAU_AUXR_FP, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
    ], [5, 2, 2], [], 1
  >,
  InstrItinData<MAU_AUXR_X_FP, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
    ], [5, 2, 2], [], 2
  >,
  InstrItinData<MAU_AUXR_Y_FP, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
    ], [5, 2, 2], [], 3
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
  ], [2, 4, 2, 2], [], 3>
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
  let IssueWidth = 8; // 8 ISSUE resources
  let LoadLatency = 5; // Cycles to access L1$, (23 cycles if miss)
  let PostRAScheduler = 1;
  let CompleteModel = 1;
  let MispredictPenalty = 0;
}

let BufferSize = 0 in // we want in-order
let SchedModel = KVXSchedMachineModel in // binding to our machine model
class KVXProcResource<int num> : ProcResource<num>;

def TINY_PR: KVXProcResource<4>;
def LITE_PR: KVXProcResource<2>;
def FULL_PR: KVXProcResource<1>;
def LSU_PR: KVXProcResource<1>;
def MAU_PR: KVXProcResource<1>;
def BCU_PR: KVXProcResource<1>;
def TCA_PR: KVXProcResource<1>;
def AUXR_PR: KVXProcResource<1>;
def AUXW_PR: KVXProcResource<1>;
def CRRP_PR: KVXProcResource<1>;
def CRWL_PR: KVXProcResource<1>;
def CRWH_PR: KVXProcResource<1>;
def NOP_PR: KVXProcResource<4>;

/* Reservation table definitions */
// TODO - the definition of XNOP_RU is inaccurate, as LLVM interprets it as
//        NOP_PR being used for 4 cycles
defvar XNOP_RU = [NOP_PR, NOP_PR, NOP_PR, NOP_PR];

defvar NOP_RU = [NOP_PR];
defvar TINY_RU = [TINY_PR];
defvar LITE_RU = [LITE_PR, TINY_PR];
defvar FULL_RU = [FULL_PR, LITE_PR, TINY_PR];
defvar CRWL_RU = [CRWL_PR];
defvar CRWH_RU = [CRWH_PR];
defvar CRRP_RU = [CRRP_PR];
defvar AUXR_RU = [AUXR_PR];
defvar AUXW_RU = [AUXW_PR];
defvar BCU_RU = [BCU_PR];
defvar MAU_RU = [MAU_PR, TINY_PR];
defvar TCA_RU = [TCA_PR];
defvar LSU_RU = [LSU_PR, TINY_PR];

// The actual tables, as defined in the VLIWCore documentation
defvar ALU_NOP_RT = NOP_RU;

defvar ALU_TINY_RT = TINY_RU;
defvar ALU_LITE_RT = LITE_RU;

defvar ALU_LITE_CRWL_RT = LITE_RU # CRWL_RU;
defvar ALU_LITE_CRWH_RT = LITE_RU # CRWH_RU;

defvar ALU_FULL_RT = FULL_RU;

defvar BCU_RT = BCU_RU;
defvar BCU_CRRP_CRWL_CRWH_RT = BCU_RU # CRRP_RU # CRWL_RU # CRWH_RU;
defvar BCU_TINY_AUXW_CRRP_RT = BCU_RU # TINY_RU # AUXW_RU # CRRP_RU;
defvar BCU_TINY_TINY_MAU_XNOP_RT = BCU_RU # TINY_RU # MAU_RU # XNOP_RU;

defvar TCA_RT = TCA_RU;

defvar LSU_RT = LSU_RU;

defvar LSU_CRRP_RT = LSU_RU # CRRP_RU;

defvar LSU_AUXR_RT = LSU_RU # AUXR_RU;

defvar LSU_AUXW_RT = LSU_RU # AUXW_RU;

defvar LSU_AUXR_AUXW_RT = LSU_RU # AUXW_RU # AUXR_RU;

defvar MAU_RT = MAU_RU;

defvar MAU_AUXR_RT = MAU_RU # AUXR_RU;

// Dedicated reservation table for SWAPVO: moveto + moveto + movefo
defvar SWAPVO_RT = ALU_LITE_CRWL_RT # ALU_LITE_CRWH_RT # BCU_TINY_AUXW_CRRP_RT;

foreach itinClass = ALL_ITIN_CLASSES in {
  def itinClass # _SRW: SchedWrite;
}

def SWAPVO_SRW1: SchedWrite;
def SWAPVO_SRW2: SchedWrite;

// Custom class to make the writeLatency explicit, and specify that we have
// a fully pipelined model.
let SchedModel = KVXSchedMachineModel in
class KVXWriteRes<SchedWrite write, int writeLatency, list<ProcResource> resources>
  : WriteRes<write, resources> {
  let Latency = writeLatency;
  let ResourceCycles = []<int>; // our processor is fully pipelined
}

multiclass KVXItinWriteRes <InstrItinClass itinClass, int writeLatency,
                            list<ProcResource> resources, int issueWidth,
                            SchedWrite srw> {
  let NumMicroOps = issueWidth in
    def _WR: KVXWriteRes<srw, writeLatency, resources>;
  let SchedModel = KVXSchedMachineModel in
    def _IRW: ItinRW<[srw], [itinClass]>;
}

// Handling SWAPVO separately
let SchedModel = KVXSchedMachineModel in {
  let ResourceCycles = []<int> in {
    let Latency = 1 in
    let NumMicroOps = 1 in // arbitrary cut in 1+2
      def SWAPVO_WR1: WriteRes<SWAPVO_SRW1, SWAPVO_RT>; // 1st operand
    let Latency = 3 in
    let NumMicroOps = 2 in
      // Note: all resources are consumed by 1st operand
      def SWAPVO_WR2: WriteRes<SWAPVO_SRW2, []>; // 2nd operand
  }
  def SWAPVO_IRW: ItinRW<[SWAPVO_SRW1, SWAPVO_SRW2], [SWAPVO]>;
}

/* Binding itinerary classes to reservation table + write latency */
/* TODO: for now, this is regardless of the operand. It is possible to further
 * customize it with a per-operand model.
 * TODO: once we get rid of itineraries, we could directly
 * bind an instruction to its write latency and its resource table.
 * This will also allow us to have a more precise model, as this one is not
 * accurate everywhere (e.g. SET instruction)
 */
defvar alu_lat = 1;
defvar sfu_lat = 11; // TODO - is it really 11?
defvar bcu_tca_lat = 3; // BCU instructions writing to TCA reg
defvar bcu_lat = 1;
defvar tca_int_lat = 3;
defvar tca_fp_lat = 5;
defvar store_lat = 1;
defvar load_lat = 3; // assuming L1 cache hit
defvar alclr_lat = 2;
defvar mau_int_lat = 2;
defvar mau_fp_lat = 4;

defm: KVXItinWriteRes<ALL, alu_lat, [], 8, ALL_SRW>; // we rely on NumMicroOps=8
defm: KVXItinWriteRes<ALU_NOP, alu_lat, ALU_NOP_RT, 1, ALU_NOP_SRW>;

defm: KVXItinWriteRes<ALU_TINY, alu_lat, ALU_TINY_RT, 1, ALU_TINY_SRW>;
defm: KVXItinWriteRes<ALU_TINY_X, alu_lat, ALU_TINY_RT, 2, ALU_TINY_X_SRW>;
defm: KVXItinWriteRes<ALU_TINY_Y, alu_lat, ALU_TINY_RT, 3, ALU_TINY_Y_SRW>;

defm: KVXItinWriteRes<ALU_LITE, alu_lat, ALU_LITE_RT, 1, ALU_LITE_SRW>;
defm: KVXItinWriteRes<ALU_LITE_X, alu_lat, ALU_LITE_RT, 2, ALU_LITE_X_SRW>;
defm: KVXItinWriteRes<ALU_LITE_Y, alu_lat, ALU_LITE_RT, 3, ALU_LITE_Y_SRW>;

defm: KVXItinWriteRes<ALU_LITE_CRWL, alu_lat, ALU_LITE_CRWL_RT, 1, ALU_LITE_CRWL_SRW>;
defm: KVXItinWriteRes<ALU_LITE_CRWH, alu_lat, ALU_LITE_CRWH_RT, 1, ALU_LITE_CRWH_SRW>;

defm: KVXItinWriteRes<ALU_FULL, alu_lat, ALU_FULL_RT, 1, ALU_FULL_SRW>;
defm: KVXItinWriteRes<ALU_FULL_X, alu_lat, ALU_FULL_RT, 2, ALU_FULL_X_SRW>;
defm: KVXItinWriteRes<ALU_FULL_Y, alu_lat, ALU_FULL_RT, 3, ALU_FULL_Y_SRW>;
defm: KVXItinWriteRes<SFU, sfu_lat, ALU_FULL_RT, 1, SFU_SRW>;

defm: KVXItinWriteRes<BCU, bcu_lat, BCU_RT, 1, BCU_SRW>;
defm: KVXItinWriteRes<BCU_CRRP_CRWL_CRWH, bcu_tca_lat, BCU_CRRP_CRWL_CRWH_RT,
                      1, BCU_CRRP_CRWL_CRWH_SRW>;
defm: KVXItinWriteRes<BCU_TINY_AUXW_CRRP, bcu_tca_lat, BCU_TINY_AUXW_CRRP_RT,
                      1, BCU_TINY_AUXW_CRRP_SRW>;
/* TODO: SFRs do not have bypasses, GPRs do. The operand should have a negative
 * ReadAdvance */
defm: KVXItinWriteRes<BCU_TINY_TINY_MAU_XNOP, bcu_lat, BCU_TINY_TINY_MAU_XNOP_RT,
                      1, BCU_TINY_TINY_MAU_XNOP_SRW>;

defm: KVXItinWriteRes<TCA, tca_int_lat, TCA_RT, 1, TCA_SRW>;
defm: KVXItinWriteRes<TCA_FP16, tca_fp_lat, TCA_RT, 1, TCA_FP16_SRW>;

defm: KVXItinWriteRes<LSU_STORE, store_lat, LSU_RT, 1, LSU_STORE_SRW>;
defm: KVXItinWriteRes<LSU_X_STORE, store_lat, LSU_RT, 2, LSU_X_STORE_SRW>;
defm: KVXItinWriteRes<LSU_Y_STORE, store_lat, LSU_RT, 3, LSU_Y_STORE_SRW>;

defm: KVXItinWriteRes<LSU_CRRP_STORE, store_lat, LSU_CRRP_RT, 1, LSU_CRRP_STORE_SRW>;
defm: KVXItinWriteRes<LSU_CRRP_X_STORE, store_lat, LSU_CRRP_RT, 2, LSU_CRRP_X_STORE_SRW>;
defm: KVXItinWriteRes<LSU_CRRP_Y_STORE, store_lat, LSU_CRRP_RT, 3, LSU_CRRP_Y_STORE_SRW>;

defm: KVXItinWriteRes<LSU_AUXR_STORE, store_lat, LSU_AUXR_RT, 1, LSU_AUXR_STORE_SRW>;
defm: KVXItinWriteRes<LSU_AUXR_X_STORE, store_lat, LSU_AUXR_RT, 2, LSU_AUXR_X_STORE_SRW>;
defm: KVXItinWriteRes<LSU_AUXR_Y_STORE, store_lat, LSU_AUXR_RT, 3, LSU_AUXR_Y_STORE_SRW>;

defm: KVXItinWriteRes<LSU_AUXW_STORE, store_lat, LSU_AUXW_RT, 1, LSU_AUXW_STORE_SRW>;
defm: KVXItinWriteRes<LSU_AUXW_X_STORE, store_lat, LSU_AUXW_RT, 2, LSU_AUXW_X_STORE_SRW>;
defm: KVXItinWriteRes<LSU_AUXW_Y_STORE, store_lat, LSU_AUXW_RT, 3, LSU_AUXW_Y_STORE_SRW>;

defm: KVXItinWriteRes<LSU_AUXR_AUXW_STORE, store_lat, LSU_AUXR_AUXW_RT, 1,
                      LSU_AUXR_AUXW_STORE_SRW>;
defm: KVXItinWriteRes<LSU_AUXR_AUXW_X_STORE, store_lat, LSU_AUXR_AUXW_RT, 2,
                      LSU_AUXR_AUXW_X_STORE_SRW>;
defm: KVXItinWriteRes<LSU_AUXR_AUXW_Y_STORE, store_lat, LSU_AUXR_AUXW_RT, 3,
                      LSU_AUXR_AUXW_Y_STORE_SRW>;

defm: KVXItinWriteRes<LSU_AUXW_ALCLR, alclr_lat, LSU_AUXW_RT, 1, LSU_AUXW_ALCLR_SRW>;
defm: KVXItinWriteRes<LSU_AUXW_X_ALCLR, alclr_lat, LSU_AUXW_RT, 2, LSU_AUXW_X_ALCLR_SRW>;
defm: KVXItinWriteRes<LSU_AUXW_Y_ALCLR, alclr_lat, LSU_AUXW_RT, 3, LSU_AUXW_Y_ALCLR_SRW>;

defm: KVXItinWriteRes<LSU_LOAD, load_lat, LSU_RT, 1, LSU_LOAD_SRW>;
defm: KVXItinWriteRes<LSU_X_LOAD, load_lat, LSU_RT, 2, LSU_X_LOAD_SRW>;
defm: KVXItinWriteRes<LSU_Y_LOAD, load_lat, LSU_RT, 3, LSU_Y_LOAD_SRW>;

defm: KVXItinWriteRes<LSU_CRRP_LOAD, load_lat, LSU_CRRP_RT, 1, LSU_CRRP_LOAD_SRW>;
defm: KVXItinWriteRes<LSU_CRRP_X_LOAD, load_lat, LSU_CRRP_RT, 2, LSU_CRRP_X_LOAD_SRW>;
defm: KVXItinWriteRes<LSU_CRRP_Y_LOAD, load_lat, LSU_CRRP_RT, 3, LSU_CRRP_Y_LOAD_SRW>;

defm: KVXItinWriteRes<LSU_AUXR_LOAD, load_lat, LSU_AUXR_RT, 1, LSU_AUXR_LOAD_SRW>;
defm: KVXItinWriteRes<LSU_AUXR_X_LOAD, load_lat, LSU_AUXR_RT, 2, LSU_AUXR_X_LOAD_SRW>;
defm: KVXItinWriteRes<LSU_AUXR_Y_LOAD, load_lat, LSU_AUXR_RT, 3, LSU_AUXR_Y_LOAD_SRW>;

defm: KVXItinWriteRes<LSU_AUXW_LOAD, load_lat, LSU_AUXW_RT, 1, LSU_AUXW_LOAD_SRW>;
defm: KVXItinWriteRes<LSU_AUXW_X_LOAD, load_lat, LSU_AUXW_RT, 2, LSU_AUXW_X_LOAD_SRW>;
defm: KVXItinWriteRes<LSU_AUXW_Y_LOAD, load_lat, LSU_AUXW_RT, 3, LSU_AUXW_Y_LOAD_SRW>;

defm: KVXItinWriteRes<LSU_AUXR_AUXW_LOAD, load_lat, LSU_AUXR_AUXW_RT, 1,
                      LSU_AUXR_AUXW_LOAD_SRW>;
defm: KVXItinWriteRes<LSU_AUXR_AUXW_X_LOAD, load_lat, LSU_AUXR_AUXW_RT, 2,
                      LSU_AUXR_AUXW_X_LOAD_SRW>;
defm: KVXItinWriteRes<LSU_AUXR_AUXW_Y_LOAD, load_lat, LSU_AUXR_AUXW_RT, 3,
                      LSU_AUXR_AUXW_Y_LOAD_SRW>;

defm: KVXItinWriteRes<MAU, mau_int_lat, MAU_RT, 1, MAU_SRW>;
defm: KVXItinWriteRes<MAU_X, mau_int_lat, MAU_RT, 2, MAU_X_SRW>;
defm: KVXItinWriteRes<MAU_Y, mau_int_lat, MAU_RT, 3, MAU_Y_SRW>;

defm: KVXItinWriteRes<MAU_AUXR, mau_int_lat, MAU_AUXR_RT, 1, MAU_AUXR_SRW>;
defm: KVXItinWriteRes<MAU_AUXR_X, mau_int_lat, MAU_AUXR_RT, 2, MAU_AUXR_X_SRW>;
defm: KVXItinWriteRes<MAU_AUXR_Y, mau_int_lat, MAU_AUXR_RT, 3, MAU_AUXR_Y_SRW>;

defm: KVXItinWriteRes<MAU_FP, mau_fp_lat, MAU_RT, 1, MAU_FP_SRW>;
defm: KVXItinWriteRes<MAU_X_FP, mau_fp_lat, MAU_RT, 2, MAU_X_FP_SRW>;
defm: KVXItinWriteRes<MAU_Y_FP, mau_fp_lat, MAU_RT, 3, MAU_Y_FP_SRW>;

defm: KVXItinWriteRes<MAU_AUXR_FP, mau_fp_lat, MAU_AUXR_RT, 1, MAU_AUXR_FP_SRW>;
defm: KVXItinWriteRes<MAU_AUXR_X_FP, mau_fp_lat, MAU_AUXR_RT, 2, MAU_AUXR_X_FP_SRW>;
defm: KVXItinWriteRes<MAU_AUXR_Y_FP, mau_fp_lat, MAU_AUXR_RT, 3, MAU_AUXR_Y_FP_SRW>;

def CopyI : SchedWrite;
let SchedModel = KVXSchedMachineModel in {
  // CopyI is expanded to ADDD -> ALU_TINY reservation table
  let NumMicroOps = 1 in
    def : KVXWriteRes<CopyI, 1, ALU_TINY_RT>;
  def : InstRW<[CopyI], (instrs COPY)>;
}
