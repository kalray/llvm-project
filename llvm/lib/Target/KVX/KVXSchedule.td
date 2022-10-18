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

//===-- Itineraries --===//

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

// Itineraries shared between CV1 and CV2
def ALL : InstrItinClass;
def BCU : InstrItinClass;
def BCU_TINY_TINY_MAU_XNOP : InstrItinClass;
def BCU_CRRP_CRWL_CRWH : InstrItinClass;
def BCU_TINY_AUXW_CRRP : InstrItinClass;
def TCA_INT : InstrItinClass;
def TCA_FP : InstrItinClass;
def ALU_NOP : InstrItinClass;
def ALU_TINY : InstrItinClass;
def ALU_TINY_X_ : InstrItinClass;
def ALU_TINY_Y_ : InstrItinClass;
def ALU_LITE : InstrItinClass;
def ALU_LITE_X_ : InstrItinClass;
def ALU_LITE_Y_ : InstrItinClass;
def ALU_LITE_CRWL : InstrItinClass;
def ALU_LITE_CRWH : InstrItinClass;
def ALU_TINY_CRWL : InstrItinClass;
def ALU_TINY_CRWH : InstrItinClass;
def ALU_FULL : InstrItinClass;
def ALU_FULL_SFU : InstrItinClass;
def ALU_FULL_X_ : InstrItinClass;
def ALU_FULL_Y_ : InstrItinClass;
def MAU_INT : InstrItinClass;
def MAU_FP : InstrItinClass;
def MAU_INT_X_ : InstrItinClass;
def MAU_FP_X_ : InstrItinClass;
def MAU_INT_Y_ : InstrItinClass;
def MAU_FP_Y_ : InstrItinClass;
def MAU_AUXR_INT : InstrItinClass;
def MAU_AUXR_INT_X_ : InstrItinClass;
def MAU_AUXR_INT_Y_ : InstrItinClass;
def MAU_AUXR_FP : InstrItinClass;
def MAU_AUXR_FP_X_ : InstrItinClass;
def MAU_AUXR_FP_Y_ : InstrItinClass;

def LSU_STORE : InstrItinClass;
def LSU_STORE_X_ : InstrItinClass;
def LSU_STORE_Y_ : InstrItinClass;
def LSU_CRRP_STORE : InstrItinClass;
def LSU_CRRP_STORE_X_ : InstrItinClass;
def LSU_CRRP_STORE_Y_ : InstrItinClass;
def LSU_AUXR_STORE : InstrItinClass;
def LSU_AUXR_STORE_X_ : InstrItinClass;
def LSU_AUXR_STORE_Y_ : InstrItinClass;
def LSU_AUXW_STORE : InstrItinClass;
def LSU_AUXW_STORE_X_ : InstrItinClass;
def LSU_AUXW_STORE_Y_ : InstrItinClass;
def LSU_AUXR_AUXW_STORE : InstrItinClass;
def LSU_AUXR_AUXW_STORE_X_ : InstrItinClass;
def LSU_AUXR_AUXW_STORE_Y_ : InstrItinClass;

def LSU_LOAD : InstrItinClass;
def LSU_LOAD_X_ : InstrItinClass;
def LSU_LOAD_Y_ : InstrItinClass;
def LSU_CRRP_LOAD : InstrItinClass;
def LSU_CRRP_LOAD_X_ : InstrItinClass;
def LSU_CRRP_LOAD_Y_ : InstrItinClass;
def LSU_AUXR_LOAD : InstrItinClass;
def LSU_AUXR_LOAD_X_ : InstrItinClass;
def LSU_AUXR_LOAD_Y_ : InstrItinClass;
def LSU_AUXW_LOAD : InstrItinClass;
def LSU_AUXW_LOAD_X_ : InstrItinClass;
def LSU_AUXW_LOAD_Y_ : InstrItinClass;
def LSU_AUXR_AUXW_LOAD : InstrItinClass;
def LSU_AUXR_AUXW_LOAD_X_ : InstrItinClass;
def LSU_AUXR_AUXW_LOAD_Y_ : InstrItinClass;

def LSU_AUXW_ALCLR : InstrItinClass;
def LSU_AUXW_ALCLR_X_ : InstrItinClass;
def LSU_AUXW_ALCLR_Y_ : InstrItinClass;

def XSWAP256 : InstrItinClass;

def ALU_TINY_CRRP : InstrItinClass;
def ALU_TINY_CRRP_CRWL_CRWH : InstrItinClass;
def ALU_TINY_CRWL_CRWH : InstrItinClass;
def ALU_TINY_CRWL_CRWH_X_ : InstrItinClass;
def ALU_TINY_CRWL_CRWH_Y_ : InstrItinClass;
// Switch-itineraries for instructions whose reservation table changes
// between CV1 and CV2
// Format: NAME_SWITCH_CV1VALUE_CV2VALUE

def ALU_SWITCH_LITE_TINY : InstrItinClass;
def ALU_SWITCH_LITE_TINY_X_ : InstrItinClass;
def ALU_SWITCH_LITE_TINY_Y_ : InstrItinClass;
def MAU_SWITCH_AUXR_EMPTY_INT : InstrItinClass;
def MAU_SWITCH_AUXR_EMPTY_INT_X_ : InstrItinClass;
def MAU_SWITCH_AUXR_EMPTY_INT_Y_ : InstrItinClass;
def MAU_SWITCH_AUXR_EMPTY_FP : InstrItinClass;
def MAU_SWITCH_AUXR_EMPTY_FP_X_ : InstrItinClass;
def MAU_SWITCH_AUXR_EMPTY_FP_Y_ : InstrItinClass;

defvar ALL_ITIN_CLASSES = [
  ALL, BCU, BCU_TINY_TINY_MAU_XNOP, BCU_CRRP_CRWL_CRWH, BCU_TINY_AUXW_CRRP,
  TCA_INT, TCA_FP,
  ALU_NOP, ALU_TINY, ALU_TINY_X_, ALU_TINY_Y_,
  ALU_SWITCH_LITE_TINY, ALU_SWITCH_LITE_TINY_X_, ALU_SWITCH_LITE_TINY_Y_,
  ALU_LITE, ALU_LITE_X_, ALU_LITE_Y_, ALU_LITE_CRWL, ALU_LITE_CRWH, ALU_TINY_CRWL, ALU_TINY_CRWH,
  ALU_FULL, ALU_FULL_SFU, ALU_FULL_X_, ALU_FULL_Y_,
  MAU_INT, MAU_FP, MAU_INT_X_, MAU_FP_X_, MAU_INT_Y_, MAU_FP_Y_,
  MAU_AUXR_INT, MAU_AUXR_INT_X_, MAU_AUXR_INT_Y_, MAU_AUXR_FP, MAU_AUXR_FP_X_, MAU_AUXR_FP_Y_,
  LSU_STORE, LSU_STORE_X_, LSU_STORE_Y_,
  LSU_CRRP_STORE, LSU_CRRP_STORE_X_, LSU_CRRP_STORE_Y_,
  LSU_AUXR_STORE, LSU_AUXR_STORE_X_, LSU_AUXR_STORE_Y_,
  LSU_AUXW_STORE, LSU_AUXW_STORE_X_, LSU_AUXW_STORE_Y_,
  LSU_AUXR_AUXW_STORE, LSU_AUXR_AUXW_STORE_X_, LSU_AUXR_AUXW_STORE_Y_,
  LSU_LOAD, LSU_LOAD_X_, LSU_LOAD_Y_,
  LSU_CRRP_LOAD, LSU_CRRP_LOAD_X_, LSU_CRRP_LOAD_Y_,
  LSU_AUXR_LOAD, LSU_AUXR_LOAD_X_, LSU_AUXR_LOAD_Y_,
  LSU_AUXW_LOAD, LSU_AUXW_LOAD_X_, LSU_AUXW_LOAD_Y_,
  LSU_AUXR_AUXW_LOAD, LSU_AUXR_AUXW_LOAD_X_, LSU_AUXR_AUXW_LOAD_Y_,
  LSU_AUXW_ALCLR, LSU_AUXW_ALCLR_X_, LSU_AUXW_ALCLR_Y_,
  ALU_TINY_CRRP, ALU_TINY_CRRP_CRWL_CRWH, ALU_TINY_CRWL_CRWH, ALU_TINY_CRWL_CRWH_X_, ALU_TINY_CRWL_CRWH_Y_,
  MAU_SWITCH_AUXR_EMPTY_INT, MAU_SWITCH_AUXR_EMPTY_INT_X_, MAU_SWITCH_AUXR_EMPTY_INT_Y_,
  MAU_SWITCH_AUXR_EMPTY_FP, MAU_SWITCH_AUXR_EMPTY_FP_X_, MAU_SWITCH_AUXR_EMPTY_FP_Y_
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

/* Commented definition example:
 *  InstrItinData<ALU_LITE_X_, [ // itinerary name
 *    InstrStage<1, [LITE0_FU, LITE1_FU], 0>, // one LITE
 *    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]> // one TINY
 *    ]
 *    , [2, 2, 2] // [(writeop_stage - 1), (readop1_stage), (readopt2_stage), ...]
 *    , [] // bypasses. None in our case (for now): we model them with readops
 *    , 2 // number of micro-ops, i.e. the number of consumed ISSUE resources
 *  >,
 *
 * In our implementation, the stages are 1 for ID, 2 for RR, 3 for E1, etc..
 * Be careful that the stage for write operands must be decremented:
 *   2 for E1, 3 for E2, etc..
 *
 * Indeed, the latency between two instructions is given by the following
 * formula in LLVM code: writeop_cycle - readop_cycle + 1
 * See getOperandLatency() in MCInstrItineraries.h for details
 *
 * Thus, if a [4, 2] instruction (writes at E3, reads at RR)
 * writes a register used by a [2, 1] instruction (writes at E1, reads at ID)
 * Then the latency is going to be 4 - 1 + 1 = 4 cycles
 *
 * Additional note: all operand latencies should be given. If an instruction has
 * 1 write operand and 4 read operands, then the list should contain 5 elements.
 * In the absence of a write operand, the read operands are assumed to be at the
 * start of the list; hence, the operand list for a CB is [1] (reads at ID)
**/

def KVXItinList {
list<InstrItinData> CV1Switch = [
  // ALU_LITE -> ALU_TINY
  InstrItinData<ALU_SWITCH_LITE_TINY, [
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>
    ], [2, 2, 2], [], 1
  >,
  InstrItinData<ALU_SWITCH_LITE_TINY_X_, [
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>
    ], [2, 2, 2], [], 2
  >,
  InstrItinData<ALU_SWITCH_LITE_TINY_Y_, [
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>
    ], [2, 2, 2], [], 3
  >,

  // MAU + AUXR -> MAU, int
  InstrItinData<MAU_SWITCH_AUXR_EMPTY_INT, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU], 0>,
    InstrStage<1, [AUXR_FU], 0>
    ], [3, 2, 2], [], 1
  >,
  InstrItinData<MAU_SWITCH_AUXR_EMPTY_INT_X_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU], 0>,
    InstrStage<1, [AUXR_FU], 0>
    ], [3, 2, 2], [], 2
  >,
  InstrItinData<MAU_SWITCH_AUXR_EMPTY_INT_Y_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU], 0>,
    InstrStage<1, [AUXR_FU], 0>
    ], [3, 2, 2], [], 3
  >,

  // MAU + AUXR -> MAU, float
  InstrItinData<MAU_SWITCH_AUXR_EMPTY_FP, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU], 0>,
    InstrStage<1, [AUXR_FU], 0>
    ], [5, 2, 2], [], 1
  >,
  InstrItinData<MAU_SWITCH_AUXR_EMPTY_FP_X_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU], 0>,
    InstrStage<1, [AUXR_FU], 0>
    ], [5, 2, 2], [], 2
  >,
  InstrItinData<MAU_SWITCH_AUXR_EMPTY_FP_Y_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU], 0>,
    InstrStage<1, [AUXR_FU], 0>
    ], [5, 2, 2], [], 3
  >,
];

list<InstrItinData> CV2Switch = [
  // ALU_LITE -> ALU_TINY
  InstrItinData<ALU_SWITCH_LITE_TINY, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>
    ], [2, 2, 2], [], 1
  >,
  InstrItinData<ALU_SWITCH_LITE_TINY_X_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>
    ], [2, 2, 2], [], 2
  >,
  InstrItinData<ALU_SWITCH_LITE_TINY_Y_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>
    ], [2, 2, 2], [], 3
  >,

  // MAU + AUXR -> MAU, int
    InstrItinData<MAU_SWITCH_AUXR_EMPTY_INT, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU], 0>,
    ], [3, 2, 2], [], 1
  >,
  InstrItinData<MAU_SWITCH_AUXR_EMPTY_INT_X_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU], 0>,
    ], [3, 2, 2], [], 2
  >,
  InstrItinData<MAU_SWITCH_AUXR_EMPTY_INT_Y_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU], 0>,
    ], [3, 2, 2], [], 3
  >,

  // MAU + AUXR -> MAU, FP
  InstrItinData<MAU_SWITCH_AUXR_EMPTY_FP, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU], 0>,
    ], [5, 2, 2], [], 1
  >,
  InstrItinData<MAU_SWITCH_AUXR_EMPTY_FP_X_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU], 0>,
    ], [5, 2, 2], [], 2
  >,
  InstrItinData<MAU_SWITCH_AUXR_EMPTY_FP_Y_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU], 0>,
    ], [5, 2, 2], [], 3
  >,
];

list<InstrItinData> Common = [
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
  InstrItinData<ALU_TINY_X_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>,
    ], [2, 2, 2], [], 2
  >,
  InstrItinData<ALU_TINY_Y_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>
    ], [2, 2, 2], [], 3
  >,
  InstrItinData<ALU_LITE, [
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>
    ], [2, 2, 2], [], 1
  >,
  InstrItinData<ALU_LITE_X_, [
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU]>
    ], [2, 2, 2], [], 2
  >,
  InstrItinData<ALU_LITE_Y_, [
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
  InstrItinData<ALU_TINY_CRWL, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [CRWL_FU]>
    ], [2, 2, 2], [], 1
  >,
  InstrItinData<ALU_TINY_CRWH, [
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
  InstrItinData<ALU_FULL_SFU, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [FULL_FU]>
  ], [12, 2, 2], [], 1
  >,
  InstrItinData<ALU_FULL_X_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [FULL_FU]>
    ], [2, 2, 2], [], 2
  >,
  InstrItinData<ALU_FULL_Y_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [FULL_FU]>
    ], [2, 2, 2], [], 3
  >,
  InstrItinData<BCU, [
    InstrStage<1, [BCU_FU]> // TODO: branch penalty not modeled
    ], [1], [], 1
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
  InstrItinData<TCA_INT, [
    InstrStage<1, [TCA_FU]>
    ], [4, 2, 2], [], 1
  >,
  InstrItinData<TCA_FP, [
    InstrStage<1, [TCA_FU]>
    ], [6, 2, 2], [], 1
  >,
  // NOTE : stores have up to 5 operands
  InstrItinData<LSU_STORE, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU]>
    ], [2, 2, 2, 2, 2], [], 1
  >,
  InstrItinData<LSU_STORE_X_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU]>
    ], [2, 2, 2, 2, 2], [], 2
  >,
  InstrItinData<LSU_STORE_Y_, [
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
  InstrItinData<LSU_CRRP_STORE_X_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [CRRP_FU]>
    ], [2, 2, 2, 2, 2], [], 2
  >,
  InstrItinData<LSU_CRRP_STORE_Y_, [
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
  InstrItinData<LSU_AUXR_STORE_X_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
    ], [2, 2, 2, 2, 2], [], 2
  >,
  InstrItinData<LSU_AUXR_STORE_Y_, [
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
  InstrItinData<LSU_AUXW_STORE_X_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [2, 2, 2, 2, 2], [], 2
  >,
  InstrItinData<LSU_AUXW_STORE_Y_, [
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
  InstrItinData<LSU_AUXR_AUXW_STORE_X_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [2, 2, 2, 2, 2], [], 2
  >,
  InstrItinData<LSU_AUXR_AUXW_STORE_Y_, [
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
  InstrItinData<LSU_AUXW_ALCLR_X_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [3, 2, 2, 2, 2, 2], [], 2
  >,
  InstrItinData<LSU_AUXW_ALCLR_Y_, [
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
  InstrItinData<LSU_LOAD_X_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU]>
    ], [4, 2, 2, 2, 2, 2], [], 2
  >,
  InstrItinData<LSU_LOAD_Y_, [
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
  InstrItinData<LSU_CRRP_LOAD_X_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [CRRP_FU]>
    ], [4, 2, 2, 2, 2, 2], [], 2
  >,
  InstrItinData<LSU_CRRP_LOAD_Y_, [
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
  InstrItinData<LSU_AUXR_LOAD_X_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
    ], [4, 2, 2, 2, 2, 2], [], 2
  >,
  InstrItinData<LSU_AUXR_LOAD_Y_, [
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
  InstrItinData<LSU_AUXW_LOAD_X_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [4, 2, 2, 2, 2, 2], [], 2
  >,
  InstrItinData<LSU_AUXW_LOAD_Y_, [
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
  InstrItinData<LSU_AUXR_AUXW_LOAD_X_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [4, 2, 2, 2, 2, 2], [], 2
  >,
  InstrItinData<LSU_AUXR_AUXW_LOAD_Y_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [LSU_FU], 0>,
    InstrStage<1, [AUXR_FU], 0>,
    InstrStage<1, [AUXW_FU]>
    ], [4, 2, 2, 2, 2, 2], [], 3
  >,
  InstrItinData<MAU_INT, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU]>
    ], [3, 2, 2], [], 1
  >,
  InstrItinData<MAU_FP, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU]>
    ], [5, 2, 2], [], 1
  >,
  InstrItinData<MAU_INT_X_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU]>
    ], [3, 2, 2], [], 2
  >,
  InstrItinData<MAU_FP_X_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU]>
    ], [5, 2, 2], [], 2
  >,
  InstrItinData<MAU_INT_Y_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU]>
    ], [3, 2, 2], [], 3
  >,
  InstrItinData<MAU_FP_Y_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU]>
    ], [5, 2, 2], [], 3
  >,
  InstrItinData<MAU_AUXR_INT, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
    ], [3, 2, 2], [], 1
  >,
  InstrItinData<MAU_AUXR_INT_X_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
    ], [3, 2, 2], [], 2
  >,
  InstrItinData<MAU_AUXR_INT_Y_, [
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
  InstrItinData<MAU_AUXR_FP_X_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
    ], [5, 2, 2], [], 2
  >,
  InstrItinData<MAU_AUXR_FP_Y_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [MAU_FU], 0>,
    InstrStage<1, [AUXR_FU]>
    ], [5, 2, 2], [], 3
  >,
  InstrItinData<ALU_TINY_CRRP, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [CRRP_FU]>
    ], [2], [], 1
  >,
  InstrItinData<ALU_TINY_CRRP_CRWL_CRWH, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [CRRP_FU], 0>,
    InstrStage<1, [CRWL_FU], 0>,
    InstrStage<1, [CRWH_FU]>
    ], [3, 2], [], 1
  >,
  InstrItinData<ALU_TINY_CRWL_CRWH, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [CRWL_FU], 0>,
    InstrStage<1, [CRWH_FU]>
    ], [3], [], 1
  >,
  InstrItinData<ALU_TINY_CRWL_CRWH_X_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [CRWL_FU], 0>,
    InstrStage<1, [CRWH_FU]>
    ], [3], [], 2
  >,
  InstrItinData<ALU_TINY_CRWL_CRWH_Y_, [
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [CRWL_FU], 0>,
    InstrStage<1, [CRWH_FU]>
    ], [3], [], 3
  >,

// TODO : add OperandLatencies here as well
  // We need to expand XSWAP256p pseudos after packetizer. To correctly schedule/bundle them,
  // we need a dedicated scheduling itinerary for it.
  InstrItinData<XSWAP256, [
    // movetq E == ALU_LITE_CRWL
    InstrStage<1, [LITE0_FU, LITE1_FU], 0>,
    InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<1, [CRWL_FU], 0>,
    // movetq O == ALU_LITE_CRWH
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

multiclass KVX_ITINERARIES<list<InstrItinData> ItinList> {
  def Itineraries:
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
    ], [], ItinList>;
}

defm KVXCV1: KVX_ITINERARIES<KVXItinList.Common # KVXItinList.CV1Switch>;
defm KVXCV2: KVX_ITINERARIES<KVXItinList.Common # KVXItinList.CV2Switch>;

multiclass KVX_SCHED_MACHINE_MODEL<ProcessorItineraries Itin> {
  def SchedMachineModel: SchedMachineModel {
    let Itineraries = Itin;
    let MicroOpBufferSize = 0; // VLIW In-order
    let IssueWidth = 8; // 8 ISSUE resources
    let LoadLatency = 5; // Cycles to access L1$, (23 cycles if miss)
    let PostRAScheduler = 1;
    let CompleteModel = 1;
    let MispredictPenalty = 0;
  }
}

defm KVXCV1: KVX_SCHED_MACHINE_MODEL<KVXCV1Itineraries>;
defm KVXCV2: KVX_SCHED_MACHINE_MODEL<KVXCV2Itineraries>;

//===-- ProcResources --===//

// Using ProcResources unlock some MachineScheduler heuristics counting
// critical resources such as RES-DEMAND.
//
// The scheduler still uses the latencies given by the itineraries, so there is
// no need to specify them below.
//
// Note that the below model is not sufficient for our architecture:
// instructions using multiple resources of the same kind are incorrectly
// modeled by LLVM. If we were to rely only on WriteRes entries, we would see
// invalid bundles {GET, TINY, TINY, TINY}.

foreach itinClass = ALL_ITIN_CLASSES in {
  def itinClass # _SRW: SchedWrite;
}

def XSWAP256_SRW1: SchedWrite;
def XSWAP256_SRW2: SchedWrite;

let BufferSize = 0 in // we want in-order
class KVXProcResource<SchedMachineModel m, int num> : ProcResource<num> {
  let SchedModel = m; // binding to our machine model
}

// Custom class to specify that we have a fully pipelined model.
class KVXWriteRes<SchedMachineModel model, SchedWrite write, list<ProcResource> resources>
  : WriteRes<write, resources> {
  let SchedModel = model;
  let ResourceCycles = []<int>; // our processor is fully pipelined
}

multiclass KVXItinWriteRes <SchedMachineModel model, InstrItinClass itinClass,
                            list<ProcResource> resources, int issueWidth,
                            SchedWrite srw> {
  let NumMicroOps = issueWidth in
    def _WR: KVXWriteRes<model, srw, resources>;
  let SchedModel = model in
    def _IRW: ItinRW<[srw], [itinClass]>;
}

foreach m = [KVXCV1SchedMachineModel, KVXCV2SchedMachineModel] in {
  def TINY_PR_#m: KVXProcResource<m, 4>;
  def LITE_PR_#m: KVXProcResource<m, 2>;
  def FULL_PR_#m: KVXProcResource<m, 1>;
  def LSU_PR_#m: KVXProcResource<m, 1>;
  def MAU_PR_#m: KVXProcResource<m, 1>;
  def BCU_PR_#m: KVXProcResource<m, 1>;
  def TCA_PR_#m: KVXProcResource<m, 1>;
  def AUXR_PR_#m: KVXProcResource<m, 1>;
  def AUXW_PR_#m: KVXProcResource<m, 1>;
  def CRRP_PR_#m: KVXProcResource<m, 1>;
  def CRWL_PR_#m: KVXProcResource<m, 1>;
  def CRWH_PR_#m: KVXProcResource<m, 1>;
  def NOP_PR_#m: KVXProcResource<m, 4>;

  def CopyI_#m : SchedWrite;
}

foreach m = [KVXCV1SchedMachineModel, KVXCV2SchedMachineModel] in {
  defvar IS_CV1 = !eq(m, KVXCV1SchedMachineModel);
  defvar IS_CV2 = !eq(m, KVXCV2SchedMachineModel);
  defvar NOP_PRM = !cond(IS_CV1 : NOP_PR_KVXCV1SchedMachineModel, IS_CV2 : NOP_PR_KVXCV2SchedMachineModel);
  defvar TINY_PRM = !cond(IS_CV1 : TINY_PR_KVXCV1SchedMachineModel, IS_CV2 : TINY_PR_KVXCV2SchedMachineModel);
  defvar LITE_PRM = !cond(IS_CV1 : LITE_PR_KVXCV1SchedMachineModel, IS_CV2 : LITE_PR_KVXCV2SchedMachineModel);
  defvar FULL_PRM = !cond(IS_CV1 : FULL_PR_KVXCV1SchedMachineModel, IS_CV2 : FULL_PR_KVXCV2SchedMachineModel);
  defvar CRWL_PRM = !cond(IS_CV1 : CRWL_PR_KVXCV1SchedMachineModel, IS_CV2 : CRWL_PR_KVXCV2SchedMachineModel);
  defvar CRWH_PRM = !cond(IS_CV1 : CRWH_PR_KVXCV1SchedMachineModel, IS_CV2 : CRWH_PR_KVXCV2SchedMachineModel);
  defvar CRRP_PRM = !cond(IS_CV1 : CRRP_PR_KVXCV1SchedMachineModel, IS_CV2 : CRRP_PR_KVXCV2SchedMachineModel);
  defvar AUXR_PRM = !cond(IS_CV1 : AUXR_PR_KVXCV1SchedMachineModel, IS_CV2 : AUXR_PR_KVXCV2SchedMachineModel);
  defvar AUXW_PRM = !cond(IS_CV1 : AUXW_PR_KVXCV1SchedMachineModel, IS_CV2 : AUXW_PR_KVXCV2SchedMachineModel);
  defvar BCU_PRM = !cond(IS_CV1 : BCU_PR_KVXCV1SchedMachineModel, IS_CV2 : BCU_PR_KVXCV2SchedMachineModel);
  defvar MAU_PRM = !cond(IS_CV1 : MAU_PR_KVXCV1SchedMachineModel, IS_CV2 : MAU_PR_KVXCV2SchedMachineModel);
  defvar TCA_PRM = !cond(IS_CV1 : TCA_PR_KVXCV1SchedMachineModel, IS_CV2 : TCA_PR_KVXCV2SchedMachineModel);
  defvar LSU_PRM = !cond(IS_CV1 : LSU_PR_KVXCV1SchedMachineModel, IS_CV2 : LSU_PR_KVXCV2SchedMachineModel);

  /* Reservation table definitions */
  // TODO - the definition of XNOP_RU is inaccurate, as LLVM interprets it as
  //        NOP_PR being used for 4 cycles
  defvar XNOP_RU = [NOP_PRM, NOP_PRM, NOP_PRM, NOP_PRM];

  defvar NOP_RU = [NOP_PRM];
  defvar TINY_RU = [TINY_PRM];
  defvar LITE_RU = [LITE_PRM, TINY_PRM];
  defvar FULL_RU = [FULL_PRM, LITE_PRM, TINY_PRM];
  defvar CRWL_RU = [CRWL_PRM];
  defvar CRWH_RU = [CRWH_PRM];
  defvar CRRP_RU = [CRRP_PRM];
  defvar AUXR_RU = [AUXR_PRM];
  defvar AUXW_RU = [AUXW_PRM];
  defvar BCU_RU = [BCU_PRM];
  defvar MAU_RU = [MAU_PRM, TINY_PRM];
  defvar TCA_RU = [TCA_PRM];
  defvar LSU_RU = [LSU_PRM, TINY_PRM];

  // The actual tables, as defined in the VLIWCore documentation
  defvar ALU_NOP_RT = NOP_RU;

  defvar ALU_TINY_RT = TINY_RU;
  defvar ALU_LITE_RT = LITE_RU;

  defvar ALU_LITE_CRWL_RT = LITE_RU # CRWL_RU;
  defvar ALU_LITE_CRWH_RT = LITE_RU # CRWH_RU;

  defvar ALU_TINY_CRWL_RT = TINY_RU # CRWL_RU;
  defvar ALU_TINY_CRWH_RT = TINY_RU # CRWH_RU;

  defvar ALU_FULL_RT = FULL_RU;

  defvar BCU_RT = BCU_RU;
  defvar BCU_CRRP_CRWL_CRWH_RT = BCU_RU # CRRP_RU # CRWL_RU # CRWH_RU;
  defvar BCU_TINY_AUXW_CRRP_RT = BCU_RU # TINY_RU # AUXW_RU # CRRP_RU;
  defvar BCU_TINY_TINY_MAU_XNOP_RT = BCU_RU # TINY_RU # MAU_RU # XNOP_RU;

  defvar TCA_RT = TCA_RU;

  defvar LSU_RT = LSU_RU;

  defvar LSU_CRRP_RT = LSU_RU # CRRP_RU;

  defvar LSU_AUXR_RT = LSU_RU # AUXR_RU;

  defvar ALU_TINY_CRRP_CRWL_CRWH_RT = TINY_RU # CRRP_RU # CRWL_RU # CRWH_RU;
  defvar ALU_TINY_CRRP_RT = TINY_RU # CRRP_RU;
  defvar ALU_TINY_CRWL_CRWH_RT = TINY_RU # CRWL_RU # CRWH_RU;
// Dedicated reservation table forXSWAP256: moveto + moveto + movefo
  defvar LSU_AUXW_RT = LSU_RU # AUXW_RU;

  defvar LSU_AUXR_AUXW_RT = LSU_RU # AUXW_RU # AUXR_RU;

  defvar MAU_RT = MAU_RU;

  defvar MAU_AUXR_RT = MAU_RU # AUXR_RU;

  // TODO: In cv2 the two LITE instructions are TINY.
  // Dedicated reservation table for XSWAP256: moveto + moveto + movefo
  defvar XSWAP256_RT = ALU_LITE_CRWL_RT # ALU_LITE_CRWH_RT # BCU_TINY_AUXW_CRRP_RT;

  // Handling XSWAP256 separately
  let SchedModel = m in {
    let ResourceCycles = []<int> in {
      let NumMicroOps = 1 in // arbitrary cut in 1+2
        def XSWAP256_WR1#m: WriteRes<XSWAP256_SRW1, XSWAP256_RT>; // 1st operand
      let NumMicroOps = 2 in
        // Note: all resources are consumed by 1st operand
        def XSWAP256_WR2#m: WriteRes<XSWAP256_SRW2, []>; // 2nd operand
    }
    def XSWAP256_IRW#m: ItinRW<[XSWAP256_SRW1, XSWAP256_SRW2], [XSWAP256]>;
  }

// === Mappings for the CV1/CV2 invariant itinerary classes ===

  defm ALL#m: KVXItinWriteRes<m, ALL, [], 8, ALL_SRW>;
  defm ALU_NOP#m: KVXItinWriteRes<m, ALU_NOP, ALU_NOP_RT, 1, ALU_NOP_SRW>;

  defm ALU_TINY#m: KVXItinWriteRes<m, ALU_TINY, ALU_TINY_RT, 1, ALU_TINY_SRW>;
  defm ALU_TINY_X_#m: KVXItinWriteRes<m, ALU_TINY_X_, ALU_TINY_RT, 2, ALU_TINY_X__SRW>;
  defm ALU_TINY_Y_#m: KVXItinWriteRes<m, ALU_TINY_Y_, ALU_TINY_RT, 3, ALU_TINY_Y__SRW>;

  defm ALU_LITE#m: KVXItinWriteRes<m, ALU_LITE, ALU_LITE_RT, 1, ALU_LITE_SRW>;
  defm ALU_LITE_X_#m: KVXItinWriteRes<m, ALU_LITE_X_, ALU_LITE_RT, 2, ALU_LITE_X__SRW>;
  defm ALU_LITE_Y_#m: KVXItinWriteRes<m, ALU_LITE_Y_, ALU_LITE_RT, 3, ALU_LITE_Y__SRW>;

  defm ALU_LITE_CRWL#m: KVXItinWriteRes<m, ALU_LITE_CRWL, ALU_LITE_CRWL_RT, 1, ALU_LITE_CRWL_SRW>;
  defm ALU_LITE_CRWH#m: KVXItinWriteRes<m, ALU_LITE_CRWH, ALU_LITE_CRWH_RT, 1, ALU_LITE_CRWH_SRW>;

  defm ALU_TINY_CRWL#m: KVXItinWriteRes<m, ALU_TINY_CRWL, ALU_TINY_CRWL_RT, 1, ALU_TINY_CRWL_SRW>;
  defm ALU_TINY_CRWH#m: KVXItinWriteRes<m, ALU_TINY_CRWH, ALU_TINY_CRWH_RT, 1, ALU_TINY_CRWH_SRW>;

  defm ALU_FULL#m: KVXItinWriteRes<m, ALU_FULL, ALU_FULL_RT, 1, ALU_FULL_SRW>;
  defm ALU_FULL_X_#m: KVXItinWriteRes<m, ALU_FULL_X_, ALU_FULL_RT, 2, ALU_FULL_X__SRW>;
  defm ALU_FULL_Y_#m: KVXItinWriteRes<m, ALU_FULL_Y_, ALU_FULL_RT, 3, ALU_FULL_Y__SRW>;
  defm ALU_FULL_SFU#m: KVXItinWriteRes<m, ALU_FULL_SFU, ALU_FULL_RT, 1, ALU_FULL_SFU_SRW>;

  defm BCU#m: KVXItinWriteRes<m, BCU, BCU_RT, 1, BCU_SRW>;
  defm BCU_CRRP_CRWL_CRWH#m:
    KVXItinWriteRes<m, BCU_CRRP_CRWL_CRWH, BCU_CRRP_CRWL_CRWH_RT,
                    1, BCU_CRRP_CRWL_CRWH_SRW>;
  defm BCU_TINY_AUXW_CRRP#m:
    KVXItinWriteRes<m, BCU_TINY_AUXW_CRRP, BCU_TINY_AUXW_CRRP_RT,
                    1, BCU_TINY_AUXW_CRRP_SRW>;
  /* TODO: SFRs do not have bypasses, GPRs do. The operand should have a negative
  * ReadAdvance */
  defm BCU_TINY_TINY_MAU_XNOP#m:
    KVXItinWriteRes<m, BCU_TINY_TINY_MAU_XNOP, BCU_TINY_TINY_MAU_XNOP_RT,
                    1, BCU_TINY_TINY_MAU_XNOP_SRW>;

  defm TCA_INT#m: KVXItinWriteRes<m, TCA_INT, TCA_RT, 1, TCA_INT_SRW>;
  defm TCA_FP#m: KVXItinWriteRes<m, TCA_FP, TCA_RT, 1, TCA_FP_SRW>;

  defm LSU_STORE#m: KVXItinWriteRes<m, LSU_STORE, LSU_RT, 1, LSU_STORE_SRW>;
  defm LSU_STORE_X_#m: KVXItinWriteRes<m, LSU_STORE_X_, LSU_RT, 2, LSU_STORE_X__SRW>;
  defm LSU_STORE_Y_#m: KVXItinWriteRes<m, LSU_STORE_Y_, LSU_RT, 3, LSU_STORE_Y__SRW>;

  defm LSU_CRRP_STORE#m: KVXItinWriteRes<m, LSU_CRRP_STORE, LSU_CRRP_RT, 1, LSU_CRRP_STORE_SRW>;
  defm LSU_CRRP_STORE_X_#m: KVXItinWriteRes<m, LSU_CRRP_STORE_X_, LSU_CRRP_RT, 2, LSU_CRRP_STORE_X__SRW>;
  defm LSU_CRRP_STORE_Y_#m: KVXItinWriteRes<m, LSU_CRRP_STORE_Y_, LSU_CRRP_RT, 3, LSU_CRRP_STORE_Y__SRW>;

  defm LSU_AUXR_STORE#m: KVXItinWriteRes<m, LSU_AUXR_STORE, LSU_AUXR_RT, 1, LSU_AUXR_STORE_SRW>;
  defm LSU_AUXR_STORE_X_#m: KVXItinWriteRes<m, LSU_AUXR_STORE_X_, LSU_AUXR_RT, 2, LSU_AUXR_STORE_X__SRW>;
  defm LSU_AUXR_STORE_Y_#m: KVXItinWriteRes<m, LSU_AUXR_STORE_Y_, LSU_AUXR_RT, 3, LSU_AUXR_STORE_Y__SRW>;

  defm LSU_AUXW_STORE#m: KVXItinWriteRes<m, LSU_AUXW_STORE, LSU_AUXW_RT, 1, LSU_AUXW_STORE_SRW>;
  defm LSU_AUXW_STORE_X_#m: KVXItinWriteRes<m, LSU_AUXW_STORE_X_, LSU_AUXW_RT, 2, LSU_AUXW_STORE_X__SRW>;
  defm LSU_AUXW_STORE_Y_#m: KVXItinWriteRes<m, LSU_AUXW_STORE_Y_, LSU_AUXW_RT, 3, LSU_AUXW_STORE_Y__SRW>;

  defm LSU_AUXR_AUXW_STORE#m:
    KVXItinWriteRes<m, LSU_AUXR_AUXW_STORE, LSU_AUXR_AUXW_RT, 1,
                    LSU_AUXR_AUXW_STORE_SRW>;
  defm LSU_AUXR_AUXW_STORE_X_#m:
    KVXItinWriteRes<m, LSU_AUXR_AUXW_STORE_X_, LSU_AUXR_AUXW_RT, 2,
                    LSU_AUXR_AUXW_STORE_X__SRW>;
  defm LSU_AUXR_AUXW_STORE_Y_#m:
    KVXItinWriteRes<m, LSU_AUXR_AUXW_STORE_Y_, LSU_AUXR_AUXW_RT, 3,
                    LSU_AUXR_AUXW_STORE_Y__SRW>;

  defm LSU_AUXW_ALCLR#m: KVXItinWriteRes<m, LSU_AUXW_ALCLR, LSU_AUXW_RT, 1, LSU_AUXW_ALCLR_SRW>;
  defm LSU_AUXW_ALCLR_X_#m: KVXItinWriteRes<m, LSU_AUXW_ALCLR_X_, LSU_AUXW_RT, 2, LSU_AUXW_ALCLR_X__SRW>;
  defm LSU_AUXW_ALCLR_Y_#m: KVXItinWriteRes<m, LSU_AUXW_ALCLR_Y_, LSU_AUXW_RT, 3, LSU_AUXW_ALCLR_Y__SRW>;

  defm LSU_LOAD#m: KVXItinWriteRes<m, LSU_LOAD, LSU_RT, 1, LSU_LOAD_SRW>;
  defm LSU_LOAD_X_#m: KVXItinWriteRes<m, LSU_LOAD_X_, LSU_RT, 2, LSU_LOAD_X__SRW>;
  defm LSU_LOAD_Y_#m: KVXItinWriteRes<m, LSU_LOAD_Y_, LSU_RT, 3, LSU_LOAD_Y__SRW>;

  defm LSU_CRRP_LOAD#m: KVXItinWriteRes<m, LSU_CRRP_LOAD, LSU_CRRP_RT, 1, LSU_CRRP_LOAD_SRW>;
  defm LSU_CRRP_LOAD_X_#m: KVXItinWriteRes<m, LSU_CRRP_LOAD_X_, LSU_CRRP_RT, 2, LSU_CRRP_LOAD_X__SRW>;
  defm LSU_CRRP_LOAD_Y_#m: KVXItinWriteRes<m, LSU_CRRP_LOAD_Y_, LSU_CRRP_RT, 3, LSU_CRRP_LOAD_Y__SRW>;

  defm LSU_AUXR_LOAD#m: KVXItinWriteRes<m, LSU_AUXR_LOAD, LSU_AUXR_RT, 1, LSU_AUXR_LOAD_SRW>;
  defm LSU_AUXR_LOAD_X_#m: KVXItinWriteRes<m, LSU_AUXR_LOAD_X_, LSU_AUXR_RT, 2, LSU_AUXR_LOAD_X__SRW>;
  defm LSU_AUXR_LOAD_Y_#m: KVXItinWriteRes<m, LSU_AUXR_LOAD_Y_, LSU_AUXR_RT, 3, LSU_AUXR_LOAD_Y__SRW>;

  defm LSU_AUXW_LOAD#m: KVXItinWriteRes<m, LSU_AUXW_LOAD, LSU_AUXW_RT, 1, LSU_AUXW_LOAD_SRW>;
  defm LSU_AUXW_LOAD_X_#m: KVXItinWriteRes<m, LSU_AUXW_LOAD_X_, LSU_AUXW_RT, 2, LSU_AUXW_LOAD_X__SRW>;
  defm LSU_AUXW_LOAD_Y_#m: KVXItinWriteRes<m, LSU_AUXW_LOAD_Y_, LSU_AUXW_RT, 3, LSU_AUXW_LOAD_Y__SRW>;

  defm LSU_AUXR_AUXW_LOAD#m:
    KVXItinWriteRes<m, LSU_AUXR_AUXW_LOAD, LSU_AUXR_AUXW_RT, 1,
                    LSU_AUXR_AUXW_LOAD_SRW>;
  defm LSU_AUXR_AUXW_LOAD_X_#m:
    KVXItinWriteRes<m, LSU_AUXR_AUXW_LOAD_X_, LSU_AUXR_AUXW_RT, 2,
                    LSU_AUXR_AUXW_LOAD_X__SRW>;
  defm LSU_AUXR_AUXW_LOAD_Y_#m:
    KVXItinWriteRes<m, LSU_AUXR_AUXW_LOAD_Y_, LSU_AUXR_AUXW_RT, 3,
                    LSU_AUXR_AUXW_LOAD_Y__SRW>;

  defm MAU_INT#m: KVXItinWriteRes<m, MAU_INT, MAU_RT, 1, MAU_INT_SRW>;
  defm MAU_INT_X_#m: KVXItinWriteRes<m, MAU_INT_X_, MAU_RT, 2, MAU_INT_X__SRW>;
  defm MAU_INT_Y_#m: KVXItinWriteRes<m, MAU_INT_Y_, MAU_RT, 3, MAU_INT_Y__SRW>;

  defm MAU_AUXR_INT#m: KVXItinWriteRes<m, MAU_AUXR_INT, MAU_AUXR_RT, 1, MAU_AUXR_INT_SRW>;
  defm MAU_AUXR_INT_X_#m: KVXItinWriteRes<m, MAU_AUXR_INT_X_, MAU_AUXR_RT, 2, MAU_AUXR_INT_X__SRW>;
  defm MAU_AUXR_INT_Y_#m: KVXItinWriteRes<m, MAU_AUXR_INT_Y_, MAU_AUXR_RT, 3, MAU_AUXR_INT_Y__SRW>;

  defm MAU_FP#m: KVXItinWriteRes<m, MAU_FP, MAU_RT, 1, MAU_FP_SRW>;
  defm MAU_FP_X_#m: KVXItinWriteRes<m, MAU_FP_X_, MAU_RT, 2, MAU_FP_X__SRW>;
  defm MAU_FP_Y_#m: KVXItinWriteRes<m, MAU_FP_Y_, MAU_RT, 3, MAU_FP_Y__SRW>;

  defm MAU_AUXR_FP#m: KVXItinWriteRes<m, MAU_AUXR_FP, MAU_AUXR_RT, 1, MAU_AUXR_FP_SRW>;
  defm MAU_AUXR_FP_X_#m: KVXItinWriteRes<m, MAU_AUXR_FP_X_, MAU_AUXR_RT, 2, MAU_AUXR_FP_X__SRW>;
  defm MAU_AUXR_FP_Y_#m: KVXItinWriteRes<m, MAU_AUXR_FP_Y_, MAU_AUXR_RT, 3, MAU_AUXR_FP_Y__SRW>;

  defvar CopyIM = !cond(
    IS_CV1 : CopyI_KVXCV1SchedMachineModel,
    IS_CV2 : CopyI_KVXCV2SchedMachineModel
  );
  let SchedModel = m in {
    // CopyI is expanded to ADDD -> ALU_TINY reservation table
    let NumMicroOps = 1 in
      def : KVXWriteRes<m, CopyIM, ALU_TINY_RT>;
    def : InstRW<[CopyIM], (instrs COPY)>;
  }

  // === Mappings for the CV1/CV2 switch itinerary classes ===

  if IS_CV1 then {
    // ALU_LITE -> ALU_TINY
    defm: KVXItinWriteRes<m, ALU_SWITCH_LITE_TINY, ALU_LITE_RT, 1,
                          ALU_SWITCH_LITE_TINY_SRW>;
    defm: KVXItinWriteRes<m, ALU_SWITCH_LITE_TINY_X_, ALU_LITE_RT, 2,
                          ALU_SWITCH_LITE_TINY_X__SRW>;
    defm: KVXItinWriteRes<m, ALU_SWITCH_LITE_TINY_Y_, ALU_LITE_RT, 3,
                          ALU_SWITCH_LITE_TINY_Y__SRW>;

    // MAU + AUXR -> MAU, int
    defm: KVXItinWriteRes<m, MAU_SWITCH_AUXR_EMPTY_INT, MAU_AUXR_RT, 1,
                          MAU_SWITCH_AUXR_EMPTY_INT_SRW>;
    defm: KVXItinWriteRes<m, MAU_SWITCH_AUXR_EMPTY_INT_X_, MAU_AUXR_RT, 2,
                          MAU_SWITCH_AUXR_EMPTY_INT_X__SRW>;
    defm: KVXItinWriteRes<m, MAU_SWITCH_AUXR_EMPTY_INT_Y_, MAU_AUXR_RT, 3,
                          MAU_SWITCH_AUXR_EMPTY_INT_Y__SRW>;

    // MAU + AUXR -> MAU, float
    defm: KVXItinWriteRes<m, MAU_SWITCH_AUXR_EMPTY_FP, MAU_AUXR_RT, 1,
                          MAU_SWITCH_AUXR_EMPTY_FP_SRW>;
    defm: KVXItinWriteRes<m, MAU_SWITCH_AUXR_EMPTY_FP_X_, MAU_AUXR_RT, 2,
                          MAU_SWITCH_AUXR_EMPTY_FP_X__SRW>;
    defm: KVXItinWriteRes<m, MAU_SWITCH_AUXR_EMPTY_FP_Y_, MAU_AUXR_RT, 3,
                          MAU_SWITCH_AUXR_EMPTY_FP_Y__SRW>;
  } else {
    // ALU_LITE -> ALU_TINY
    defm: KVXItinWriteRes<m, ALU_SWITCH_LITE_TINY, ALU_TINY_RT, 1,
                          ALU_SWITCH_LITE_TINY_SRW>;
    defm: KVXItinWriteRes<m, ALU_SWITCH_LITE_TINY_X_, ALU_TINY_RT, 2,
                          ALU_SWITCH_LITE_TINY_X__SRW>;
    defm: KVXItinWriteRes<m, ALU_SWITCH_LITE_TINY_Y_, ALU_TINY_RT, 3,
                          ALU_SWITCH_LITE_TINY_Y__SRW>;

    // MAU + AUXR -> MAU, int
    defm: KVXItinWriteRes<m, MAU_SWITCH_AUXR_EMPTY_INT, MAU_RT, 1,
                          MAU_SWITCH_AUXR_EMPTY_INT_SRW>;
    defm: KVXItinWriteRes<m, MAU_SWITCH_AUXR_EMPTY_INT_X_, MAU_RT, 2,
                          MAU_SWITCH_AUXR_EMPTY_INT_X__SRW>;
    defm: KVXItinWriteRes<m, MAU_SWITCH_AUXR_EMPTY_INT_Y_, MAU_RT, 3,
                          MAU_SWITCH_AUXR_EMPTY_INT_Y__SRW>;

    // MAU + AUXR -> MAU, float
    defm: KVXItinWriteRes<m, MAU_SWITCH_AUXR_EMPTY_FP, MAU_RT, 1,
                          MAU_SWITCH_AUXR_EMPTY_FP_SRW>;
    defm: KVXItinWriteRes<m, MAU_SWITCH_AUXR_EMPTY_FP_X_, MAU_RT, 2,
                          MAU_SWITCH_AUXR_EMPTY_FP_X__SRW>;
    defm: KVXItinWriteRes<m, MAU_SWITCH_AUXR_EMPTY_FP_Y_, MAU_RT, 3,
                          MAU_SWITCH_AUXR_EMPTY_FP_Y__SRW>;
    defm: KVXItinWriteRes<m, ALU_TINY_CRRP_CRWL_CRWH, ALU_TINY_CRRP_CRWL_CRWH_RT, 1 /* issue width */, ALU_TINY_CRRP_CRWL_CRWH_SRW>;
    defm: KVXItinWriteRes<m, ALU_TINY_CRRP, ALU_TINY_CRRP_RT, 1 /* issue width */, ALU_TINY_CRRP_SRW>;
    defm: KVXItinWriteRes<m, ALU_TINY_CRWL_CRWH, ALU_TINY_CRWL_CRWH_RT, 1 /* issue width */, ALU_TINY_CRWL_CRWH_SRW>;
    defm: KVXItinWriteRes<m, ALU_TINY_CRWL_CRWH_X_, ALU_TINY_CRWL_CRWH_RT, 2 /* issue width */, ALU_TINY_CRWL_CRWH_X__SRW>;
    defm: KVXItinWriteRes<m, ALU_TINY_CRWL_CRWH_Y_, ALU_TINY_CRWL_CRWH_RT, 3 /* issue width */, ALU_TINY_CRWL_CRWH_Y__SRW>;
  }
}
