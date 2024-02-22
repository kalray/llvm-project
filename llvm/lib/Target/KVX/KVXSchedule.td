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

multiclass ItinBaseSingle {
  def "": InstrItinClass;
  def _SRW: SchedWrite; // used for WriteRes model, complementary to itineraries
}

class MyStringList<list<string> _l>{
  list<string> l = _l;
}

multiclass ItinBase<bit hasXY, list<string> variants = [""]> {
  foreach variant = variants in {
    defvar fullName = !cond(!eq(variant, ""): NAME, 1: NAME#_#variant);
    defm fullName: ItinBaseSingle;
    if hasXY then {
      defm fullName # _X_: ItinBaseSingle;
      defm fullName # _Y_: ItinBaseSingle;
    }
  }
  def _VL: MyStringList<variants>;
}

multiclass ItinSingle<list<string> variants=[""]> {
  defm "": ItinBase</*hasXY*/ 0, variants>;
}

multiclass ItinXY<list<string> variants=[""]> {
  defm "": ItinBase</*hasXY*/ 1, variants>;
}

defm ALL : ItinSingle<["ID", "RR"]>;
defm BCU : ItinSingle;
defm BCU_TINY_TINY_MAU_XNOP : ItinSingle<["ID", "RR"]>;
defm BCU_CRRP_CRWL_CRWH : ItinSingle<["ID", "RR"]>;
defm BCU_TINY_AUXW_CRRP : ItinSingle<["ID", "RR"]>;

defm TCA : ItinXY<["INT", "FP"]>;

defm ALU_NOP : ItinSingle;
defm ALU_TINY : ItinXY;
defm ALU_TINY_X2 : ItinSingle;
defm ALU_LITE : ItinXY;
defm ALU_LITE_CRWL : ItinSingle;
defm ALU_LITE_CRWH : ItinSingle;
defm ALU_TINY_CRWL : ItinSingle;
defm ALU_TINY_CRWH : ItinSingle;
defm ALU_TINY_CRRP : ItinSingle;
defm ALU_TINY_CRRP_CRWL_CRWH : ItinSingle;
defm ALU_TINY_CRWL_CRWH: ItinXY;
defm ALU_FULL : ItinXY;
defm ALU_FULL_SFU : ItinSingle;

defm MAU : ItinXY<["INT", "FP"]>;
defm MAU_AUXR : ItinXY<["INT", "FP", "INT_AV1"]>; // AV1 = Accumulator Value at 1st operand

defm LSU : ItinXY<["LOAD", "STORE", "XLOAD"]>;
defm LSU_CRRP : ItinXY<["STORE", "STORE_SV2", "STORE_SV3"]>; // SV2 = Store Value at 2nd operand
defm LSU_AUXR : ItinXY<["STORE_SV2", "STORE_SV3"]>;
defm LSU_AUXW : ItinXY<["LOAD", "ALCLR"]>;
defm LSU_AUXR_AUXW : ItinXY<["LOAD", "LOAD_SV2", "LOAD_SV3"]>;

defm XSWAP256 : ItinSingle;

// Switch-itineraries for instructions whose reservation table changes
// between CV1 and CV2
// Format: NAME_SWITCH_CV1VALUE_CV2VALUE

defm ALU_SWITCH_LITE_TINY : ItinXY;
defm MAU_SWITCH_AUXR_EMPTY : ItinXY<["INT", "FP"]>;

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

class InstrItinDataList <list<InstrItinData> _l> {
  list<InstrItinData> l = _l;
}

multiclass DataXYBase <bit hasXY, list<InstrStage> rt, list<int> lat_ops,
                       list<InstrStage> rt_cv2, list<int> lat_ops_cv2> {
  defvar has_cv2_rt = !not(!empty(rt_cv2));
  defvar has_cv2_lat = !not(!empty(lat_ops_cv2));
  defvar cv2_rt = !cond(has_cv2_rt: rt_cv2, 1: rt);
  defvar cv2_lat = !cond(has_cv2_lat: lat_ops_cv2, 1: lat_ops);

  defvar cv1_single = [
    InstrItinData<!cast<InstrItinClass>(NAME), rt, lat_ops, [], 1>,
  ];
  defvar cv1_xy = [
    InstrItinData<!cast<InstrItinClass>(NAME # _X_), rt, lat_ops, [], 2>,
    InstrItinData<!cast<InstrItinClass>(NAME # _Y_), rt, lat_ops, [], 3>,
  ];
  defvar cv1 = !cond(hasXY: cv1_single # cv1_xy, 1: cv1_single);

  defvar cv2_single = [
    InstrItinData<!cast<InstrItinClass>(NAME), cv2_rt, cv2_lat, [], 1>,
  ];
  defvar cv2_xy = [
    InstrItinData<!cast<InstrItinClass>(NAME # _X_), cv2_rt, cv2_lat, [], 2>,
    InstrItinData<!cast<InstrItinClass>(NAME # _Y_), cv2_rt, cv2_lat, [], 3>,
  ];
  defvar cv2 = !cond(hasXY: cv2_single # cv2_xy, 1: cv2_single);

  if !or(has_cv2_rt, has_cv2_lat) then {
    def _IDL_CV1 : InstrItinDataList<cv1>;
    def _IDL_CV2 : InstrItinDataList<cv2>;
  } else {
    def _IDL : InstrItinDataList<cv1>;
  }
}

multiclass DataXY <list<InstrStage> rt, list<int> lat_ops,
                   list<InstrStage> rt_cv2=[], list<int> lat_ops_cv2=[]> {
  defm "": DataXYBase</*hasXY*/ 1, rt, lat_ops, rt_cv2, lat_ops_cv2>;
}

class LatOpsVariant <string _variant, list<int> _lat_ops, list<int> _lat_ops_cv2=[]> {
  list<int> lat_ops = _lat_ops;
  list<int> lat_ops_cv2 = _lat_ops_cv2;
  string variant = _variant;
}

multiclass DataXYVariantsBase <bit hasXY, list<InstrStage> rt, list<LatOpsVariant> lat_ops_variants, int issue_count, list<InstrStage> rt_cv2> {
  defvar has_cv2_lat = !foldl(0, lat_ops_variants, b, lov, !or(b, !not(!empty(lov.lat_ops_cv2))));
  if !and(!ne(issue_count, 1), hasXY) then {
    def : KVX_Error<"XY instruction with base issue count != 1 not supported">;
  }

  foreach lov = lat_ops_variants in {
    defm _#lov.variant: DataXYBase<hasXY, rt, lov.lat_ops, rt_cv2, lov.lat_ops_cv2>;
  }

  if !or(!not(!empty(rt_cv2)), has_cv2_lat) then {
    def _IDL_CV1: InstrItinDataList<
      !foldl([]<InstrItinData>, lat_ops_variants, acc, lov,
        acc # !cast<InstrItinDataList>(NAME # _ # lov.variant # _IDL_CV1).l)>;
    def _IDL_CV2: InstrItinDataList<
      !foldl([]<InstrItinData>, lat_ops_variants, acc, lov,
        acc # !cast<InstrItinDataList>(NAME # _ # lov.variant # _IDL_CV2).l)>;
  } else {
    def _IDL: InstrItinDataList<
      !foldl([]<InstrItinData>, lat_ops_variants, acc, lov,
        acc # !cast<InstrItinDataList>(NAME # _ # lov.variant # _IDL).l)>;
  }
}

multiclass DataXYVariants<list<InstrStage> rt, list<LatOpsVariant> lat_ops_variants, list<InstrStage> rt_cv2=[]> {
  defm "": DataXYVariantsBase</*hasXY*/ 1, rt, lat_ops_variants, /*issue*/ 1, rt_cv2>;
}

multiclass DataSingleVariants<list<InstrStage> rt, list<LatOpsVariant> lat_ops_variants, int issue_count=1, list<InstrStage> rt_cv2=[]> {
  defm "": DataXYVariantsBase</*hasXY*/ 0, rt, lat_ops_variants, issue_count, rt_cv2>;
}

multiclass DataSingle <list<InstrStage> rt, list<int> lat_ops, int issue_count=1> {
  def _IDL : InstrItinDataList<[InstrItinData<!cast<InstrItinClass>(NAME), rt, lat_ops, [], issue_count>]>;
}

defvar ONE_TINY = InstrStage<1, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>;
defvar ONE_LITE = InstrStage<1, [LITE0_FU, LITE1_FU], 0>;
defvar ONE_FULL = InstrStage<1, [FULL_FU], 0>;
defvar ONE_MAU = InstrStage<1, [MAU_FU], 0>;
defvar ONE_AUXR = InstrStage<1, [AUXR_FU], 0>;
defvar ONE_NOP = InstrStage<1, [NOP0_FU, NOP1_FU, NOP2_FU, NOP3_FU], 0>;
defvar ONE_BCU = InstrStage<1, [BCU_FU], 0>;
defvar ONE_TCA = InstrStage<1, [TCA_FU], 0>;
defvar ONE_CRWL = InstrStage<1, [CRWL_FU], 0>;
defvar ONE_CRWH = InstrStage<1, [CRWH_FU], 0>;
defvar ONE_CRRP = InstrStage<1, [CRRP_FU], 0>;
defvar ONE_AUXW = InstrStage<1, [AUXW_FU], 0>;
defvar ONE_LSU = InstrStage<1, [LSU_FU], 0>;

defvar XTINY = [
  InstrStage<1, [TINY0_FU], 0>,
  InstrStage<1, [TINY1_FU], 0>,
  InstrStage<1, [TINY2_FU], 0>,
  InstrStage<1, [TINY3_FU], 0>,
];

defvar XNOP = [
  InstrStage<1, [NOP0_FU], 0>,
  InstrStage<1, [NOP1_FU], 0>,
  InstrStage<1, [NOP2_FU], 0>,
  InstrStage<1, [NOP3_FU], 0>,
];

defvar ALU_TINY_ITIN_RT = [ONE_TINY];
defvar ALU_TINY_X2_ITIN_RT = [ONE_TINY, ONE_TINY];
defvar ALU_LITE_ITIN_RT = [ONE_TINY, ONE_LITE];
defvar ALU_FULL_ITIN_RT = [ONE_TINY, ONE_LITE, ONE_FULL];
defvar ALU_TINY_CRRP_ITIN_RT = [ONE_TINY, ONE_CRRP];
defvar ALU_TINY_CRWL_ITIN_RT = [ONE_TINY, ONE_CRWL];
defvar ALU_TINY_CRWH_ITIN_RT = [ONE_TINY, ONE_CRWH];
defvar ALU_TINY_CRWL_CRWH_ITIN_RT = [ONE_TINY, ONE_CRWL, ONE_CRWH];
defvar ALU_TINY_CRRP_CRWL_CRWH_ITIN_RT = [ONE_TINY, ONE_CRRP, ONE_CRWL, ONE_CRWH];
defvar ALU_LITE_CRWL_ITIN_RT = [ONE_TINY, ONE_LITE, ONE_CRWL];
defvar ALU_LITE_CRWH_ITIN_RT = [ONE_TINY, ONE_LITE, ONE_CRWH];

defvar NOP_ITIN_RT = [ONE_NOP];

defvar BCU_ITIN_RT = [ONE_BCU];
defvar BCU_CRRP_CRWL_CRWH_ITIN_RT = [ONE_BCU, ONE_CRRP, ONE_CRWL, ONE_CRWH];
defvar BCU_TINY_AUXW_CRRP_ITIN_RT = [ONE_BCU, ONE_TINY, ONE_AUXW, ONE_CRRP];
defvar BCU_TINY_TINY_MAU_XNOP_ITIN_RT = [ONE_BCU, ONE_TINY, ONE_TINY, ONE_MAU] # XNOP;

defvar TCA_ITIN_RT = [ONE_TCA];

defvar LSU_ITIN_RT = [ONE_TINY, ONE_LSU];
defvar LSU_CRRP_ITIN_RT = [ONE_TINY, ONE_LSU, ONE_CRRP];
defvar LSU_AUXR_ITIN_RT = [ONE_TINY, ONE_LSU, ONE_AUXR];
defvar LSU_AUXW_ITIN_RT = [ONE_TINY, ONE_LSU, ONE_AUXW];
defvar LSU_AUXR_AUXW_ITIN_RT = [ONE_TINY, ONE_LSU, ONE_AUXR, ONE_AUXW];

defvar MAU_ITIN_RT = [ONE_TINY, ONE_MAU];
defvar MAU_AUXR_ITIN_RT = [ONE_TINY, ONE_MAU, ONE_AUXR];

defvar ALL_ITIN_RT = XTINY # [ONE_BCU, ONE_TCA] # XNOP;

defvar READ_ID = [1];
defvar READ_RR = [2];
defvar READ_E1 = [3];
defvar READ_RRx2 = READ_RR # READ_RR;
defvar READ_RRx3 = READ_RRx2 # READ_RR;
defvar READ_RRx4 = READ_RRx2 # READ_RRx2;
defvar READ_RRx5 = READ_RRx4 # READ_RR;
defvar READ_RR_E1_RRx3 = READ_RR # READ_E1 # READ_RRx3;
defvar READ_RRx2_E1_RRx2 = READ_RRx2 # READ_E1 # READ_RRx2;

defvar WE1 = [2];
defvar WE2 = [3];
defvar WE3 = [4];
defvar WE4 = [5];
defvar WE5 = [6];
defvar WE6 = [7];
defvar WSFU = [12];

// NB = No Bypass. We assume there are always bypasses; when they aren't, we
// must wait one more cycle. This is the case on the TCA.
// TODO: handle TCA bypasses once they are clearly defined
defvar WE3NB = WE4;
defvar WE4NB = WE5;
defvar WE5NB = WE6;

defvar WE1_RR = WE1 # READ_RR;
defvar WE1_ID = WE1 # READ_ID;
defvar WE1_RRx3 = WE1 # READ_RRx3;
defvar WE1_RRx4 = WE1 # READ_RRx4;

defvar WE2_RR = WE2 # READ_RR;
defvar WE2_RRx2 = WE2 # READ_RRx2;
defvar WE2_RRx3 = WE2 # READ_RRx2 # READ_RR;
defvar WE2_E1_RRx2 = WE2 # READ_E1 # READ_RRx2;
defvar WE2_RRx5 = WE2 # READ_RRx5;

defvar WE3_RRx2 = WE3 # READ_RRx2;
defvar WE3_RRx2_ID = WE3 # READ_RRx2 # READ_ID;
defvar WE3_RRx5 = WE3 # READ_RRx5;
defvar WE3_RR_E1_RRx3 = WE3 # READ_RR_E1_RRx3;
defvar WE3_RRx2_E1_RRx2 = WE3 # READ_RRx2_E1_RRx2;

defvar WE3NB_RRx2 = WE3NB # READ_RRx2;
defvar WE3NB_RRx2_ID = WE3NB_RRx2 # READ_ID;
defvar WE3NB_RRx3 = WE3NB # READ_RRx3;
defvar WE3NB_RRx5 = WE3NB # READ_RRx5;

defvar WE4_RRx3 = WE4 # READ_RRx3;

defvar WE4NB_RRx3 = WE4NB # READ_RRx3;

defvar WE5_RRx2 = WE5 # READ_RRx2;

defvar WE5NB_RRx3 = WE5NB # READ_RRx3;

defvar WSFU_RRx3 = WSFU # READ_RRx3;

defvar NOOP = []<int>;

/**
 * Note: most of the itineraries below have for example WE1_RRx3 instead of WE1_RRx2
 * This is because some instructions have accumulators: these have 4 operands instead of 3
 * The extra operand must be accounted for in the operand list, otherwise LLVM assumes
 * the latency is always 1.
 * Having this extra information does no harm to the instructions that have only 3 operands.
 */

// ALU_LITE -> ALU_TINY
defm ALU_SWITCH_LITE_TINY: DataXY<ALU_LITE_ITIN_RT, WE1_RRx3, /*CV2*/ALU_TINY_ITIN_RT>;

// MAU + AUXR -> MAU
defm MAU_SWITCH_AUXR_EMPTY: DataXYVariants<MAU_AUXR_ITIN_RT, [
  LatOpsVariant<"INT", WE2_RRx3>,
  LatOpsVariant<"FP", WE4_RRx3>],
  /*CV2*/MAU_ITIN_RT>;

// Common

// ALL reserves all resources to ensure nothing else gets scheduled
defm ALL: DataSingleVariants<ALL_ITIN_RT, [
  LatOpsVariant<"ID", READ_ID>,
  LatOpsVariant<"RR", WE1_RR>], 8 /*ISSUE*/>;

defm ALU_NOP: DataSingle<NOP_ITIN_RT, NOOP>;
defm ALU_TINY: DataXY<ALU_TINY_ITIN_RT, WE1_RRx3>;
defm ALU_TINY_X2: DataSingle<ALU_TINY_X2_ITIN_RT, WE1_RRx4, 2 /*ISSUE*/>;
defm ALU_TINY_CRWH: DataSingle<ALU_TINY_CRWH_ITIN_RT, WE3NB_RRx3>;
defm ALU_TINY_CRWL: DataSingle<ALU_TINY_CRWL_ITIN_RT, WE3NB_RRx3>;
defm ALU_TINY_CRRP: DataSingle<ALU_TINY_CRRP_ITIN_RT, READ_RR>;
defm ALU_TINY_CRRP_CRWL_CRWH: DataSingle<ALU_TINY_CRRP_CRWL_CRWH_ITIN_RT, WE3NB_RRx3>;
defm ALU_TINY_CRWL_CRWH: DataXY<ALU_TINY_CRWL_CRWH_ITIN_RT, WE3NB>;
defm ALU_LITE: DataXY<ALU_LITE_ITIN_RT, WE1_RRx3>;
defm ALU_LITE_CRWL: DataSingle<ALU_LITE_CRWL_ITIN_RT, WE3NB_RRx3>;
defm ALU_LITE_CRWH: DataSingle<ALU_LITE_CRWH_ITIN_RT, WE3NB_RRx3>;
defm ALU_FULL: DataXY<ALU_FULL_ITIN_RT, WE1_RRx4>; // x4 because of system regs uses on ADDCD/ADDCDI/SBFCD/SBFCDI
defm ALU_FULL_SFU: DataSingle<ALU_FULL_ITIN_RT, WSFU_RRx3>;

defm BCU: DataSingle<BCU_ITIN_RT, READ_ID>;

defm BCU_CRRP_CRWL_CRWH: DataSingleVariants<BCU_CRRP_CRWL_CRWH_ITIN_RT, [
  LatOpsVariant<"RR", WE3NB_RRx2>,
  LatOpsVariant<"ID", WE3NB_RRx2_ID>
]>;

defm BCU_TINY_AUXW_CRRP: DataSingleVariants<BCU_TINY_AUXW_CRRP_ITIN_RT, [
  LatOpsVariant<"RR", WE3_RRx2>,
  LatOpsVariant<"ID", WE3_RRx2_ID>
]>;

defm BCU_TINY_TINY_MAU_XNOP: DataSingleVariants<BCU_TINY_TINY_MAU_XNOP_ITIN_RT, [
  LatOpsVariant<"RR", WE1_RR>,
  LatOpsVariant<"ID", WE1_ID>
]>;

defm TCA: DataXYVariants<TCA_ITIN_RT, [
  LatOpsVariant<"INT", WE3NB_RRx3, /*CV2*/ WE3NB_RRx3>,
  LatOpsVariant<"FP", WE5NB_RRx3, /*CV2*/ WE4NB_RRx3>
]>;

// NOTE : stores have up to 5 operands
defm LSU: DataXYVariants<LSU_ITIN_RT, [
  LatOpsVariant<"STORE", READ_RRx5>,
  LatOpsVariant<"LOAD", WE3_RRx5>,
  LatOpsVariant<"XLOAD", WE3NB_RRx5>
]>;

defm LSU_CRRP: DataXYVariants<LSU_CRRP_ITIN_RT, [
  LatOpsVariant<"STORE", READ_RRx5>,
  LatOpsVariant<"STORE_SV2", READ_RR_E1_RRx3>,
  LatOpsVariant<"STORE_SV3", READ_RRx2_E1_RRx2>,
]>;

// TODO : latency will be off for SV, and can't be easily fixed
// Indeed, the QuadReg (who is read at E1) is either in 2nd or 3rd position
// cf. MC_0B in KVXInstrInfo.td
defm LSU_AUXR: DataXYVariants<LSU_AUXR_ITIN_RT, [
  LatOpsVariant<"STORE_SV2", READ_RR_E1_RRx3>,
  LatOpsVariant<"STORE_SV3", READ_RRx2_E1_RRx2>,
]>;

defm LSU_AUXW: DataXYVariants<LSU_AUXW_ITIN_RT, [
  LatOpsVariant<"LOAD", WE3_RRx5>,
  LatOpsVariant<"ALCLR", WE2_RRx5>
]>;

defm LSU_AUXR_AUXW: DataXYVariants<LSU_AUXR_AUXW_ITIN_RT, [
  LatOpsVariant<"LOAD_SV2", WE3_RR_E1_RRx3>,
  LatOpsVariant<"LOAD_SV3", WE3_RRx2_E1_RRx2>,
  LatOpsVariant<"LOAD", WE3_RRx5>
]>;

defm MAU: DataXYVariants<MAU_ITIN_RT, [
  LatOpsVariant<"INT", WE2_RRx3>,
  LatOpsVariant<"FP", WE4_RRx3>
]>;

defm MAU_AUXR: DataXYVariants<MAU_AUXR_ITIN_RT, [
  LatOpsVariant<"INT", WE2_RRx3>,
  LatOpsVariant<"INT_AV1", WE2_E1_RRx2>,
  LatOpsVariant<"FP", WE4_RRx3>
]>;

def KVXItinList {
list<InstrItinData> CV1Switch =
  ALU_SWITCH_LITE_TINY_IDL_CV1.l #
  MAU_SWITCH_AUXR_EMPTY_IDL_CV1.l #
  TCA_IDL_CV1.l;

list<InstrItinData> CV2Switch =
  ALU_SWITCH_LITE_TINY_IDL_CV2.l #
  MAU_SWITCH_AUXR_EMPTY_IDL_CV2.l #
  TCA_IDL_CV2.l;

list<InstrItinData> Common =
  ALL_IDL.l
  # ALU_NOP_IDL.l
  # ALU_TINY_X2_IDL.l
  # ALU_TINY_IDL.l # ALU_TINY_CRRP_IDL.l # ALU_TINY_CRWH_IDL.l # ALU_TINY_CRWL_IDL.l
  # ALU_TINY_CRWL_CRWH_IDL.l # ALU_TINY_CRRP_CRWL_CRWH_IDL.l
  # ALU_LITE_IDL.l # ALU_LITE_CRWL_IDL.l # ALU_LITE_CRWH_IDL.l
  # ALU_FULL_IDL.l # ALU_FULL_SFU_IDL.l
  # BCU_IDL.l # BCU_CRRP_CRWL_CRWH_IDL.l # BCU_TINY_AUXW_CRRP_IDL.l # BCU_TINY_TINY_MAU_XNOP_IDL.l
  # LSU_IDL.l # LSU_CRRP_IDL.l # LSU_AUXR_IDL.l # LSU_AUXW_IDL.l # LSU_AUXR_AUXW_IDL.l
  # MAU_IDL.l # MAU_AUXR_IDL.l
  # [
  // TODO : add OperandLatencies here as well
  // We need to expand XSWAP256p pseudos after packetizer. To correctly schedule/bundle them,
  // we need a dedicated scheduling itinerary for it.
  InstrItinData<XSWAP256, [
    // moveto E == ALU_LITE_CRWL
    ONE_LITE,
    ONE_TINY,
    ONE_CRWL,
    // moveto O == ALU_LITE_CRWH
    ONE_LITE,
    ONE_TINY,
    ONE_CRWH,
    // xmovefo == BCU_TINY_AUXW_CRRP
    InstrStage<3, [BCU_FU], 0>,
    InstrStage<3, [TINY0_FU, TINY1_FU, TINY2_FU, TINY3_FU], 0>,
    InstrStage<3, [AUXW_FU], 0>,
    InstrStage<3, [CRRP_FU], 0>
  ], [2, 4, 2, 2], [], 3>
];
}

multiclass KVXItineraries<list<InstrItinData> ItinList> {
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

defm KVXCV1: KVXItineraries<KVXItinList.Common # KVXItinList.CV1Switch>;
defm KVXCV2: KVXItineraries<KVXItinList.Common # KVXItinList.CV2Switch>;

multiclass KVXSchedMachineModel<ProcessorItineraries Itin> {
  def SchedMachineModel: SchedMachineModel {
    let Itineraries = Itin;
    let MicroOpBufferSize = 0; // VLIW In-order
    let IssueWidth = 8; // 8 ISSUE resources
    let LoadLatency = 5; // Cycles to access L1$, (23 cycles if miss)
    let PostRAScheduler = 1;
    let IsVLIWProcessor = 1;
    let CompleteModel = 1;
    let MispredictPenalty = 0;
  }
}

defm KVXCV1: KVXSchedMachineModel<KVXCV1Itineraries>;
defm KVXCV2: KVXSchedMachineModel<KVXCV2Itineraries>;

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
}

multiclass KVXItinWriteRes <SchedMachineModel model, InstrItinClass itinClass,
                            list<ProcResource> resources, int issueWidth,
                            SchedWrite srw> {
  let NumMicroOps = issueWidth in
    def _WR: KVXWriteRes<model, srw, resources>;
  let SchedModel = model in
    def _IRW: ItinRW<[srw], [itinClass]>;
}

multiclass KVXProcResourceDef <int count=1> {
  def _CV1: KVXProcResource<KVXCV1SchedMachineModel, count>;
  def _CV2: KVXProcResource<KVXCV2SchedMachineModel, count>;
}

def CopyI: SchedWrite;

defm TINY_PR: KVXProcResourceDef<4>;
defm LITE_PR: KVXProcResourceDef<2>;
defm FULL_PR: KVXProcResourceDef;
defm LSU_PR: KVXProcResourceDef;
defm MAU_PR: KVXProcResourceDef;
defm BCU_PR: KVXProcResourceDef;
defm TCA_PR: KVXProcResourceDef;
defm AUXR_PR: KVXProcResourceDef;
defm AUXW_PR: KVXProcResourceDef;
defm CRRP_PR: KVXProcResourceDef;
defm CRWL_PR: KVXProcResourceDef;
defm CRWH_PR: KVXProcResourceDef;
defm NOP_PR: KVXProcResourceDef<4>;

multiclass KVXItinWriteResDefBase<bit isCV1, list<KVXProcResource> rt, int issueCount, list<KVXProcResource> rt2> {
  defvar itinClass = !cast<InstrItinClass>(NAME);
  defvar schedWrite = !cast<SchedWrite>(NAME # _SRW);
  defvar nameWithCV = NAME # _ # !cond(isCV1: "CV1", 1: "CV2");
  defvar schedModel = !cond(isCV1: KVXCV1SchedMachineModel, 1: KVXCV2SchedMachineModel);
  defvar rt_cv2 = !cond(!size(rt2): rt2, 1: rt);
  defvar rt_cv = !cond(isCV1: rt, 1: rt_cv2);
  defm nameWithCV: KVXItinWriteRes<schedModel, itinClass, rt_cv, issueCount, schedWrite>;
}

defvar NO_VARIANT = [""];

multiclass KVXItinWriteResDef<bit isCV1, list<KVXProcResource> rt, bit hasXY=0, int issueCount=1, list<string> variants = NO_VARIANT, list<KVXProcResource> rt2>{
  if !and(!ne(issueCount, 1), hasXY) then {
    def : KVX_Error<"XY instruction with base issue count != 1 not supported">;
  }

  foreach variant = variants in {
    defvar fullName = !cond(!eq(variant, ""): NAME, true: NAME#_#variant);
    defm fullName: KVXItinWriteResDefBase<isCV1, rt, issueCount, rt2>;
    if hasXY then {
      defm fullName # _X_: KVXItinWriteResDefBase<isCV1, rt, 2, rt2>;
      defm fullName # _Y_: KVXItinWriteResDefBase<isCV1, rt, 3, rt2>;
    }
  }
}

multiclass KVXItinWriteResXY<bit isCV1, list<KVXProcResource> rt, list<string> variants=[""], list<KVXProcResource> rt2=[]> {
  defm "": KVXItinWriteResDef<isCV1, rt, /*hasXY*/ 1, /*issueCount*/ 1, variants, rt2>;
}

multiclass KVXItinWriteResSingle<bit isCV1, list<KVXProcResource> rt, int issueCount=1, list<string> variants=[""], list<KVXProcResource> rt2=[]> {
  defm "": KVXItinWriteResDef<isCV1, rt, /*hasXY*/ 0, issueCount, variants, rt2>;
}

foreach m = [KVXCV1SchedMachineModel, KVXCV2SchedMachineModel] in {
  defvar IS_CV1 = !eq(m, KVXCV1SchedMachineModel);
  defvar IS_CV2 = !eq(m, KVXCV2SchedMachineModel);
  defvar NOP_PRM = !cond(IS_CV1 : NOP_PR_CV1, IS_CV2 : NOP_PR_CV2);
  defvar TINY_PRM = !cond(IS_CV1 : TINY_PR_CV1, IS_CV2 : TINY_PR_CV2);
  defvar LITE_PRM = !cond(IS_CV1 : LITE_PR_CV1, IS_CV2 : LITE_PR_CV2);
  defvar FULL_PRM = !cond(IS_CV1 : FULL_PR_CV1, IS_CV2 : FULL_PR_CV2);
  defvar CRWL_PRM = !cond(IS_CV1 : CRWL_PR_CV1, IS_CV2 : CRWL_PR_CV2);
  defvar CRWH_PRM = !cond(IS_CV1 : CRWH_PR_CV1, IS_CV2 : CRWH_PR_CV2);
  defvar CRRP_PRM = !cond(IS_CV1 : CRRP_PR_CV1, IS_CV2 : CRRP_PR_CV2);
  defvar AUXR_PRM = !cond(IS_CV1 : AUXR_PR_CV1, IS_CV2 : AUXR_PR_CV2);
  defvar AUXW_PRM = !cond(IS_CV1 : AUXW_PR_CV1, IS_CV2 : AUXW_PR_CV2);
  defvar BCU_PRM = !cond(IS_CV1 : BCU_PR_CV1, IS_CV2 : BCU_PR_CV2);
  defvar MAU_PRM = !cond(IS_CV1 : MAU_PR_CV1, IS_CV2 : MAU_PR_CV2);
  defvar TCA_PRM = !cond(IS_CV1 : TCA_PR_CV1, IS_CV2 : TCA_PR_CV2);
  defvar LSU_PRM = !cond(IS_CV1 : LSU_PR_CV1, IS_CV2 : LSU_PR_CV2);

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
  defvar ALU_TINY_X2_RT = TINY_RU # TINY_RU;
  defvar ALU_LITE_RT = LITE_RU;

  defvar ALU_LITE_CRWL_RT = LITE_RU # CRWL_RU;
  defvar ALU_LITE_CRWH_RT = LITE_RU # CRWH_RU;

  defvar ALU_TINY_CRWL_RT = TINY_RU # CRWL_RU;
  defvar ALU_TINY_CRWH_RT = TINY_RU # CRWH_RU;
  defvar ALU_TINY_CRRP_RT = TINY_RU # CRRP_RU;
  defvar ALU_TINY_CRWL_CRWH_RT = TINY_RU # CRWL_RU # CRWH_RU;
  defvar ALU_TINY_CRRP_CRWL_CRWH_RT = TINY_RU # CRRP_RU # CRWL_RU # CRWH_RU;

  defvar ALU_FULL_RT = FULL_RU;

  defvar BCU_RT = BCU_RU;
  defvar BCU_CRRP_CRWL_CRWH_RT = BCU_RU # CRRP_RU # CRWL_RU # CRWH_RU;
  defvar BCU_TINY_AUXW_CRRP_RT = BCU_RU # TINY_RU # AUXW_RU # CRRP_RU;
  defvar BCU_TINY_TINY_MAU_XNOP_RT = BCU_RU # TINY_RU # MAU_RU # XNOP_RU;

  defvar TCA_RT = TCA_RU;

  defvar LSU_RT = LSU_RU;

  defvar LSU_CRRP_RT = LSU_RU # CRRP_RU;

  defvar LSU_AUXR_RT = LSU_RU # AUXR_RU;

// Dedicated reservation table forXSWAP256: moveto + moveto + xmovefo
  defvar LSU_AUXW_RT = LSU_RU # AUXW_RU;

  defvar LSU_AUXR_AUXW_RT = LSU_RU # AUXW_RU # AUXR_RU;

  defvar MAU_RT = MAU_RU;

  defvar MAU_AUXR_RT = MAU_RU # AUXR_RU;

  // Dedicated reservation table for XSWAP256: moveto + moveto + xmovefo
  defvar XSWAP256_RT = ALU_LITE_CRWL_RT # ALU_LITE_CRWH_RT # BCU_TINY_AUXW_CRRP_RT;

  // Handling XSWAP256 separately
  let SchedModel = m in {
    let NumMicroOps = 1 in // arbitrary cut in 1+2
      def XSWAP256_WR1#m: WriteRes<XSWAP256_SRW1, XSWAP256_RT>; // 1st operand
    let NumMicroOps = 2 in
      // Note: all resources are consumed by 1st operand
      def XSWAP256_WR2#m: WriteRes<XSWAP256_SRW2, []>; // 2nd operand
    def XSWAP256_IRW#m: ItinRW<[XSWAP256_SRW1, XSWAP256_SRW2], [XSWAP256]>;
  }

// === Mappings for the CV1/CV2 invariant itinerary classes ===

  defm ALL: KVXItinWriteResSingle<IS_CV1, [], /*issues*/ 8, ALL_VL.l>;

  defm ALU_NOP: KVXItinWriteResSingle<IS_CV1, ALU_NOP_RT>;
  defm ALU_TINY: KVXItinWriteResXY<IS_CV1, ALU_TINY_RT>;
  defm ALU_TINY_X2: KVXItinWriteResSingle<IS_CV1, ALU_TINY_X2_RT, /*issues*/ 2>;
  defm ALU_TINY_CRRP: KVXItinWriteResSingle<IS_CV1, ALU_TINY_CRRP_RT>;
  defm ALU_TINY_CRWL: KVXItinWriteResSingle<IS_CV1, ALU_TINY_CRWL_RT>;
  defm ALU_TINY_CRWH: KVXItinWriteResSingle<IS_CV1, ALU_TINY_CRWH_RT>;
  defm ALU_TINY_CRWL_CRWH: KVXItinWriteResXY<IS_CV1, ALU_TINY_CRWL_CRWH_RT>;
  defm ALU_TINY_CRRP_CRWL_CRWH: KVXItinWriteResSingle<IS_CV1, ALU_TINY_CRRP_CRWL_CRWH_RT>;
  defm ALU_LITE: KVXItinWriteResXY<IS_CV1, ALU_LITE_RT>;
  defm ALU_LITE_CRWL: KVXItinWriteResSingle<IS_CV1, ALU_LITE_CRWL_RT>;
  defm ALU_LITE_CRWH: KVXItinWriteResSingle<IS_CV1, ALU_LITE_CRWH_RT>;
  defm ALU_FULL: KVXItinWriteResXY<IS_CV1, ALU_FULL_RT>;
  defm ALU_FULL_SFU: KVXItinWriteResSingle<IS_CV1, ALU_FULL_RT>;

  defm BCU: KVXItinWriteResSingle<IS_CV1, BCU_RT>;
  defm BCU_CRRP_CRWL_CRWH: KVXItinWriteResSingle<IS_CV1, BCU_CRRP_CRWL_CRWH_RT, 1, BCU_CRRP_CRWL_CRWH_VL.l>;
  defm BCU_TINY_AUXW_CRRP: KVXItinWriteResSingle<IS_CV1, BCU_TINY_AUXW_CRRP_RT, 1, BCU_TINY_AUXW_CRRP_VL.l>;
  defm BCU_TINY_TINY_MAU_XNOP: KVXItinWriteResSingle<IS_CV1, BCU_TINY_TINY_MAU_XNOP_RT, 1, BCU_TINY_TINY_MAU_XNOP_VL.l>;

  defm TCA: KVXItinWriteResSingle<IS_CV1, TCA_RT, 1, TCA_VL.l>;

  defm LSU: KVXItinWriteResXY<IS_CV1, LSU_RT, LSU_VL.l>;
  defm LSU_CRRP: KVXItinWriteResXY<IS_CV1, LSU_CRRP_RT, LSU_CRRP_VL.l>;
  defm LSU_AUXR: KVXItinWriteResXY<IS_CV1, LSU_AUXR_RT, LSU_AUXR_VL.l>;
  defm LSU_AUXW: KVXItinWriteResXY<IS_CV1, LSU_AUXW_RT, LSU_AUXW_VL.l>;
  defm LSU_AUXR_AUXW: KVXItinWriteResXY<IS_CV1, LSU_AUXR_AUXW_RT, LSU_AUXR_AUXW_VL.l>;

  defm MAU: KVXItinWriteResXY<IS_CV1, MAU_RT, MAU_VL.l>;
  defm MAU_AUXR: KVXItinWriteResXY<IS_CV1, MAU_AUXR_RT, MAU_AUXR_VL.l>;

  let SchedModel = m in {
    // CopyI is expanded to ADDD -> ALU_TINY reservation table
    let NumMicroOps = 1 in
      def : KVXWriteRes<m, CopyI, ALU_TINY_RT>;
    def : InstRW<[CopyI], (instrs COPY)>;
  }

  // === Mappings for the CV1/CV2 switch itinerary classes ===

  defm ALU_SWITCH_LITE_TINY: KVXItinWriteResXY<IS_CV1, ALU_LITE_RT, NO_VARIANT, ALU_TINY_RT>;
  defm MAU_SWITCH_AUXR_EMPTY: KVXItinWriteResXY<IS_CV1, MAU_AUXR_RT, MAU_SWITCH_AUXR_EMPTY_VL.l, MAU_RT>;
}
