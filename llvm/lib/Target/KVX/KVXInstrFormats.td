//===-- KVXInstrFormats.td - KVX Instruction Formats -------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

// This file was automatically generated,
//   *DO NOT EDIT*,
//   please contact code owner.
// Last generated: 2020-09-16 15:58:51.230190.


def IsV1 : Predicate<"Subtarget->isV1()">;
def IsV2 : Predicate<"Subtarget->isV2()">;

class KVX_INSTRUCTION
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : Instruction {
    dag OutOperandList = outs;
    dag InOperandList = ins;
    let AsmString = asmstr;
    let Pattern = pattern;
    let Itinerary = itin;
    let Namespace = "KVX";
  }

class KVX_PSEUDO
  <dag outs, dag ins, list<dag> pattern, string asmstr = "pseudo">
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, NoItinerary> {
    let isPseudo = 1;
    let isCodeGenOnly = 1;
    let hasNoSchedulingInfo = 1;
  }

class KVX_PSEUDO_W_SCHEDINFO
  <dag outs, dag ins, list<dag> pattern, InstrItinClass itin, string asmstr = "pseudo">
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin> {
    let isPseudo = 1;
    let isCodeGenOnly = 1;
    let Itinerary = itin;
  }

// 16 insn(s):
// AWAIT, SLEEP, STOP, BARRIER, TLBREAD, TLBPROBE, TLBWRITE, TLBDINVAL,
// TLBIINVAL, ERROP, RET, RFE, DINVAL, IINVAL, FENCE, NOP
let Size = 4 in
class SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 6 insn(s):
// IGOTO, ICALL, SCALL, IGET, WAITIT, SYNCGROUP
let Size = 4 in
class REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 1 insn(s):
// SCALL
let Size = 4 in
class SYSNUMBER_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALL>;

// 1 insn(s):
// LOOPDO
let Size = 4 in
class REGISTERZ_PCREL17_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALL>;

// 2 insn(s):
// WFXL, WFXM
let Size = 4 in
class SYSTEMT2_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU>;

// 3 insn(s):
// WFXL, WFXM, SET
let Size = 4 in
class SYSTEMALONE_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALL>;

// 3 insn(s):
// WFXL, WFXM, SET
let Size = 4 in
class SYSTEMT4_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU>;

// 1 insn(s):
// GET
let Size = 4 in
class REGISTERZ_SYSTEMS2_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU_TINY_TINY_MAU_XNOP>;

// 2 insn(s):
// GET, RSWAP
let Size = 4 in
class REGISTERZ_SYSTEMS3_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU_TINY_TINY_MAU_XNOP>;

// 1 insn(s):
// SET
let Size = 4 in
class SYSTEMT3_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU>;

// 1 insn(s):
// SET
let Size = 4 in
class SYSTEMRA_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU>;

// 1 insn(s):
// RSWAP
let Size = 4 in
class REGISTERZ_SYSTEMS4_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU_TINY_TINY_MAU_XNOP>;

// 1 insn(s):
// RSWAP
let Size = 4 in
class REGISTERZ_SYSTEMALONE_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALL>;

// 2 insn(s):
// GOTO, CALL
let Size = 4 in
class PCREL27_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU>;

// 1 insn(s):
// CB
let Size = 4 in
class BRANCHCOND_REGISTERZ_PCREL17_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU>;

// 7 insn(s):
// LBZ, LBS, LHZ, LHS, LWZ, LWS, LD
let Size = 4 in
class VARIANT_REGISTERW_SIGNED10_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_LOAD>;

// 7 insn(s):
// LBZ, LBS, LHZ, LHS, LWZ, LWS, LD
let Size = 8 in
class VARIANT_REGISTERW_UPPER27_LOWER10_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_X_LOAD>;

// 7 insn(s):
// LBZ, LBS, LHZ, LHS, LWZ, LWS, LD
let Size = 12 in
class VARIANT_REGISTERW_EXTEND27_UPPER27_LOWER10_REGISTERZ_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_Y_LOAD>;

// 7 insn(s):
// LBZ, LBS, LHZ, LHS, LWZ, LWS, LD
let Size = 4 in
class VARIANT_LSUCOND_REGISTERY_REGISTERW_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_LOAD>;

// 7 insn(s):
// LBZ, LBS, LHZ, LHS, LWZ, LWS, LD
let Size = 8 in
class VARIANT_LSUCOND_REGISTERY_REGISTERW_OFFSET27_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_X_LOAD>;

// 7 insn(s):
// LBZ, LBS, LHZ, LHS, LWZ, LWS, LD
let Size = 12 in
class VARIANT_LSUCOND_REGISTERY_REGISTERW_EXTEND27_OFFSET27_REGISTERZ_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_Y_LOAD>;

// 7 insn(s):
// LBZ, LBS, LHZ, LHS, LWZ, LWS, LD
let Size = 4 in
class VARIANT_DOSCALE_REGISTERW_REGISTERY_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_LOAD>;

// 1 insn(s):
// LQ
let Size = 4 in
class VARIANT_REGISTERM_SIGNED10_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_LOAD>;

// 1 insn(s):
// LQ
let Size = 8 in
class VARIANT_REGISTERM_UPPER27_LOWER10_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_X_LOAD>;

// 1 insn(s):
// LQ
let Size = 12 in
class VARIANT_REGISTERM_EXTEND27_UPPER27_LOWER10_REGISTERZ_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_Y_LOAD>;

// 1 insn(s):
// LQ
let Size = 4 in
class VARIANT_LSUCOND_REGISTERY_REGISTERM_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_LOAD>;

// 1 insn(s):
// LQ
let Size = 8 in
class VARIANT_LSUCOND_REGISTERY_REGISTERM_OFFSET27_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_X_LOAD>;

// 1 insn(s):
// LQ
let Size = 12 in
class VARIANT_LSUCOND_REGISTERY_REGISTERM_EXTEND27_OFFSET27_REGISTERZ_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_Y_LOAD>;

// 1 insn(s):
// LQ
let Size = 4 in
class VARIANT_DOSCALE_REGISTERM_REGISTERY_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_LOAD>;

// 1 insn(s):
// LO
let Size = 4 in
class VARIANT_REGISTERN_SIGNED10_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_LOAD>;

// 1 insn(s):
// LO
let Size = 8 in
class VARIANT_REGISTERN_UPPER27_LOWER10_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_X_LOAD>;

// 1 insn(s):
// LO
let Size = 12 in
class VARIANT_REGISTERN_EXTEND27_UPPER27_LOWER10_REGISTERZ_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_Y_LOAD>;

// 1 insn(s):
// LO
let Size = 4 in
class VARIANT_LSUCOND_REGISTERY_REGISTERN_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_LOAD>;

// 1 insn(s):
// LO
let Size = 8 in
class VARIANT_LSUCOND_REGISTERY_REGISTERN_OFFSET27_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_X_LOAD>;

// 1 insn(s):
// LO
let Size = 12 in
class VARIANT_LSUCOND_REGISTERY_REGISTERN_EXTEND27_OFFSET27_REGISTERZ_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_Y_LOAD>;

// 1 insn(s):
// LO
let Size = 4 in
class VARIANT_DOSCALE_REGISTERN_REGISTERY_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_LOAD>;

// 1 insn(s):
// LV
let Size = 4 in
class SPECULATE_REGISTERA_SIGNED10_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_LOAD>;

// 1 insn(s):
// LV
let Size = 8 in
class SPECULATE_REGISTERA_UPPER27_LOWER10_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_X_LOAD>;

// 1 insn(s):
// LV
let Size = 12 in
class SPECULATE_REGISTERA_EXTEND27_UPPER27_LOWER10_REGISTERZ_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_Y_LOAD>;

// 1 insn(s):
// LV
let Size = 4 in
class SPECULATE_LSUCOND_REGISTERY_REGISTERA_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_LOAD>;

// 1 insn(s):
// LV
let Size = 8 in
class SPECULATE_LSUCOND_REGISTERY_REGISTERA_OFFSET27_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_X_LOAD>;

// 1 insn(s):
// LV
let Size = 12 in
class SPECULATE_LSUCOND_REGISTERY_REGISTERA_EXTEND27_OFFSET27_REGISTERZ_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_Y_LOAD>;

// 1 insn(s):
// LV
let Size = 4 in
class SPECULATE_DOSCALE_REGISTERA_REGISTERY_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_LOAD>;

// 1 insn(s):
// LV
let Size = 4 in
class COLUMN_SPECULATE_REGISTERAQ_SIGNED10_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_LOAD>;

// 1 insn(s):
// LV
let Size = 8 in
class COLUMN_SPECULATE_REGISTERAQ_UPPER27_LOWER10_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_X_LOAD>;

// 1 insn(s):
// LV
let Size = 12 in
class COLUMN_SPECULATE_REGISTERAQ_EXTEND27_UPPER27_LOWER10_REGISTERZ_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_Y_LOAD>;

// 1 insn(s):
// LV
let Size = 4 in
class COLUMN_SPECULATE_LSUCOND_REGISTERY_REGISTERAQ_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_LOAD>;

// 1 insn(s):
// LV
let Size = 8 in
class COLUMN_SPECULATE_LSUCOND_REGISTERY_REGISTERAQ_OFFSET27_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_X_LOAD>;

// 1 insn(s):
// LV
let Size = 12 in
class COLUMN_SPECULATE_LSUCOND_REGISTERY_REGISTERAQ_EXTEND27_OFFSET27_REGISTERZ_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_Y_LOAD>;

// 1 insn(s):
// LV
let Size = 4 in
class COLUMN_SPECULATE_DOSCALE_REGISTERAQ_REGISTERY_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_LOAD>;

// 6 insn(s):
// SB, SH, SW, SD, ALADDW, ALADDD
let Size = 4 in
class SIGNED10_REGISTERZ_REGISTERT_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 6 insn(s):
// SB, SH, SW, SD, ALADDW, ALADDD
let Size = 8 in
class UPPER27_LOWER10_REGISTERZ_REGISTERT_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 6 insn(s):
// SB, SH, SW, SD, ALADDW, ALADDD
let Size = 12 in
class EXTEND27_UPPER27_LOWER10_REGISTERZ_REGISTERT_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 6 insn(s):
// SB, SH, SW, SD, ALADDW, ALADDD
let Size = 4 in
class DOSCALE_REGISTERY_REGISTERZ_REGISTERT_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 6 insn(s):
// SB, SH, SW, SD, ALADDW, ALADDD
let Size = 4 in
class LSUCOND_REGISTERY_REGISTERZ_REGISTERT_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 6 insn(s):
// SB, SH, SW, SD, ALADDW, ALADDD
let Size = 8 in
class LSUCOND_REGISTERY_OFFSET27_REGISTERZ_REGISTERT_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 6 insn(s):
// SB, SH, SW, SD, ALADDW, ALADDD
let Size = 12 in
class LSUCOND_REGISTERY_EXTEND27_OFFSET27_REGISTERZ_REGISTERT_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 3 insn(s):
// SQ, ACSWAPW, ACSWAPD
let Size = 4 in
class SIGNED10_REGISTERZ_REGISTERU_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 3 insn(s):
// SQ, ACSWAPW, ACSWAPD
let Size = 8 in
class UPPER27_LOWER10_REGISTERZ_REGISTERU_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 3 insn(s):
// SQ, ACSWAPW, ACSWAPD
let Size = 12 in
class EXTEND27_UPPER27_LOWER10_REGISTERZ_REGISTERU_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 3 insn(s):
// SQ, ACSWAPW, ACSWAPD
let Size = 4 in
class DOSCALE_REGISTERY_REGISTERZ_REGISTERU_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 3 insn(s):
// SQ, ACSWAPW, ACSWAPD
let Size = 4 in
class LSUCOND_REGISTERY_REGISTERZ_REGISTERU_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 3 insn(s):
// SQ, ACSWAPW, ACSWAPD
let Size = 8 in
class LSUCOND_REGISTERY_OFFSET27_REGISTERZ_REGISTERU_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 3 insn(s):
// SQ, ACSWAPW, ACSWAPD
let Size = 12 in
class LSUCOND_REGISTERY_EXTEND27_OFFSET27_REGISTERZ_REGISTERU_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 1 insn(s):
// SO
let Size = 4 in
class SIGNED10_REGISTERZ_REGISTERV_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXR_STORE>;

// 1 insn(s):
// SO
let Size = 8 in
class UPPER27_LOWER10_REGISTERZ_REGISTERV_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXR_X_STORE>;

// 1 insn(s):
// SO
let Size = 12 in
class EXTEND27_UPPER27_LOWER10_REGISTERZ_REGISTERV_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXR_Y_STORE>;

// 1 insn(s):
// SO
let Size = 4 in
class DOSCALE_REGISTERY_REGISTERZ_REGISTERV_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXR_STORE>;

// 1 insn(s):
// SO
let Size = 4 in
class LSUCOND_REGISTERY_REGISTERZ_REGISTERV_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXR_STORE>;

// 1 insn(s):
// SO
let Size = 8 in
class LSUCOND_REGISTERY_OFFSET27_REGISTERZ_REGISTERV_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXR_X_STORE>;

// 1 insn(s):
// SO
let Size = 12 in
class LSUCOND_REGISTERY_EXTEND27_OFFSET27_REGISTERZ_REGISTERV_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXR_Y_STORE>;

// 1 insn(s):
// SV
let Size = 4 in
class SIGNED10_REGISTERZ_REGISTERE_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_CRRP_STORE>;

// 1 insn(s):
// SV
let Size = 8 in
class UPPER27_LOWER10_REGISTERZ_REGISTERE_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_CRRP_X_STORE>;

// 1 insn(s):
// SV
let Size = 12 in
class EXTEND27_UPPER27_LOWER10_REGISTERZ_REGISTERE_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_CRRP_Y_STORE>;

// 1 insn(s):
// SV
let Size = 4 in
class DOSCALE_REGISTERY_REGISTERZ_REGISTERE_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_CRRP_STORE>;

// 1 insn(s):
// SV
let Size = 4 in
class LSUCOND_REGISTERY_REGISTERZ_REGISTERE_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_CRRP_STORE>;

// 1 insn(s):
// SV
let Size = 8 in
class LSUCOND_REGISTERY_OFFSET27_REGISTERZ_REGISTERE_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_CRRP_X_STORE>;

// 1 insn(s):
// SV
let Size = 12 in
class LSUCOND_REGISTERY_EXTEND27_OFFSET27_REGISTERZ_REGISTERE_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_CRRP_Y_STORE>;

// 2 insn(s):
// ALCLRW, ALCLRD
let Size = 4 in
class REGISTERW_SIGNED10_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_ALCLR>;

// 2 insn(s):
// ALCLRW, ALCLRD
let Size = 8 in
class REGISTERW_UPPER27_LOWER10_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_X_ALCLR>;

// 2 insn(s):
// ALCLRW, ALCLRD
let Size = 12 in
class REGISTERW_EXTEND27_UPPER27_LOWER10_REGISTERZ_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_Y_ALCLR>;

// 2 insn(s):
// ALCLRW, ALCLRD
let Size = 4 in
class DOSCALE_REGISTERW_REGISTERY_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_ALCLR>;

// 2 insn(s):
// ALCLRW, ALCLRD
let Size = 4 in
class LSUCOND_REGISTERY_REGISTERW_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_ALCLR>;

// 2 insn(s):
// ALCLRW, ALCLRD
let Size = 8 in
class LSUCOND_REGISTERY_REGISTERW_OFFSET27_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_X_ALCLR>;

// 2 insn(s):
// ALCLRW, ALCLRD
let Size = 12 in
class LSUCOND_REGISTERY_REGISTERW_EXTEND27_OFFSET27_REGISTERZ_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_Y_ALCLR>;

// 4 insn(s):
// DTOUCHL, DINVALL, DZEROL, IINVALS
let Size = 4 in
class SIGNED10_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_LOAD>;

// 4 insn(s):
// DTOUCHL, DINVALL, DZEROL, IINVALS
let Size = 8 in
class UPPER27_LOWER10_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_X_LOAD>;

// 4 insn(s):
// DTOUCHL, DINVALL, DZEROL, IINVALS
let Size = 12 in
class EXTEND27_UPPER27_LOWER10_REGISTERZ_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_Y_LOAD>;

// 4 insn(s):
// DTOUCHL, DINVALL, DZEROL, IINVALS
let Size = 4 in
class REGISTERY_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_LOAD>;

// 4 insn(s):
// DTOUCHL, DINVALL, DZEROL, IINVALS
let Size = 4 in
class LSUCOND_REGISTERY_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_LOAD>;

// 4 insn(s):
// DTOUCHL, DINVALL, DZEROL, IINVALS
let Size = 8 in
class LSUCOND_REGISTERY_OFFSET27_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_X_LOAD>;

// 4 insn(s):
// DTOUCHL, DINVALL, DZEROL, IINVALS
let Size = 12 in
class LSUCOND_REGISTERY_EXTEND27_OFFSET27_REGISTERZ_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_Y_LOAD>;

// STSUD, ADDD, SBFD, ABDD, MIND, MINUD, MAXD, MAXUD, ANDD, NANDD, ORD, NORD,
// XORD, NXORD, ANDND, ORND, SBMM8, SBMMT8, ADDSD, ADDUSD, ADDUSW, ADDUSWP, SBFSD, ADDX2D, ADDX4D,
// ADDX8D, ADDX16D, ADDX32D, ADDX64D, SBFX2D, SBFX4D, SBFX8D, SBFX16D, SBFX32D, SBFX64D, ADDWD, SBFWD, ADDUWD,
// SBFUWD, LANDD, LNANDD, LORD, LNORD, STSUW, ADDW, SBFW, ABDW, MINW, MINUW,
// MAXW, MAXUW, ANDW, NANDW, ORW, NORW, XORW, NXORW, ANDNW, ORNW, ADDSW,
// SBFSW, ADDX2W, ADDX4W, ADDX8W, ADDX16W, ADDX32W, ADDX64W, SBFX2W, SBFX4W, SBFX8W, SBFX16W, SBFX32W,  SBFX64W,
// AVGW, AVGUW, AVGRW, AVGRUW, LANDW, LNANDW, LORW, LNORW, ADDWP, SBFWP,
// ABDWP, MINWP, MINUWP, MAXWP, MAXUWP, ADDCWC, SBFCWC, ADDSWP, SBFSWP,
// ADDX2WP, ADDX4WP, ADDX8WP, ADDX16WP, SBFX2WP, SBFX4WP, SBFX8WP, SBFX16WP,
// AVGWP, AVGUWP, AVGRWP, AVGRUWP, LANDWP, LNANDWP, LORWP, LNORWP, ADDBO, ADDHQ,
// SBFBO, SBFHQ, ABDBO, ABDHQ, MINBO, MINHQ, MINUBO, MINUHQ, MAXBO, MAXHQ, MAXUBO,
// MAXUHQ, ADDCHCP, SBFCHCP, ADDSBO, ADDUSBO, ADDUSHQ, ADDSHQ,
// SBFSHQ, ADDX2BO, ADDX2HQ, ADDX4BO, ADDX4HQ, ADDX8BO, ADDX8HQ, ADDX16BO, ADDX16HQ,
// SBFX2BO, SBFX2HQ, SBFX4BO, SBFX4HQ, SBFX8BO, SBFX8HQ, SBFX16BO, SBFX16HQ,
// SBFX16HQ, AVGHQ, AVGUHQ, AVGRHQ, AVGRUHQ, LANDHQ, LNANDHQ, LORHQ, LNORHQ,
// ADDX2WD, ADDX4WD, ADDX8WD, ADDX16WD, ADDX32WD, ADDX64WD, SBFX2WD, SBFX4WD, SBFX8WD, SBFX16WD, SBFX32WD, SBFX64WD,
// ADDX2UWD, ADDX4UWD, ADDX8UWD, ADDX16UWD, ADDX32UWD, ADDX64UWD, SBFX2UWD, SBFX4UWD, SBFX8UWD,
// SBFX16UWD, SBFX32UWD, SBFX64UWD, ADDCD, SBFCD, ADDCDI, SBFCDI, SATD, SRSD, SLLD, SRAD, SRLD,
// SLSD, SRSW, SLLW, SRAW, SRLW, SLSW, ROLW, RORW, SRSWPS, SLLWPS, SRAWPS,
// SRLWPS, SLSWPS, ROLWPS, RORWPS, SRSHQS, SLLBOS, SLLHQS, SRABOS, SRAHQS, SRLBOS, SRLHQS, SLSHQS,
// FMIND, FMAXD, FMINW, FMAXW, FMINWP, FMAXWP, FMINHQ, FMAXHQ, MADDD, MSBFD,
// MADDWP, MSBFWP, MADDHQ, MSBFHQ, MULD, CRCBELMW, CRCBELLW, CRCLELMW,
// CRCLELLW, DOT2WD, DOT2UWD, DOT2SUWD, DOT2W, MULWP, MULHQ, MULWC, MULCWC,
// MADDWD, MADDUWD, MADDSUWD, MADDW, MSBFWD, MSBFUWD, MSBFSUWD, MSBFW, MULWD,
// MULUWD, MULSUWD, MULW, ABDSW, SBFUSBO, SBFUSD, SBFUSHQ, SBFUSW, SBFUSWP, SBFSBO,
// AVGBO, AVGUBO, AVGRBO, AVGRUBO, SLSBOS, SLUSBOS, SLUSD, SLUSW, SLUSWPS, SLUSHQS,
// ABDSWP, ABDSBO, ABDSD, ABDSHQ
let Size = 4 in
class REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 45 insn(s):
// ADDD, SBFD, ABDD, MIND, MINUD, MAXD, MAXUD, ANDD, NANDD, ORD, NORD, XORD,
// NXORD, ANDND, ORND, SBMM8, SBMMT8, ADDSD, SBFSD, ADDW, SBFW, ABDW, MINW,
// MINUW, MAXW, MAXUW, ANDW, NANDW, ORW, NORW, XORW, NXORW, ANDNW, ORNW,
// MADDD, MADDWP, MADDHQ, MULD, DOT2WD, DOT2UWD, DOT2SUWD, DOT2W, MULWP,
// MULHQ, MULWC
let Size = 4 in
class REGISTERW_REGISTERZ_SIGNED10_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 45 insn(s):
// ADDD, SBFD, ABDD, MIND, MINUD, MAXD, MAXUD, ANDD, NANDD, ORD, NORD, XORD,
// NXORD, ANDND, ORND, SBMM8, SBMMT8, ADDSD, SBFSD, ADDW, SBFW, ABDW, MINW,
// MINUW, MAXW, MAXUW, ANDW, NANDW, ORW, NORW, XORW, NXORW, ANDNW, ORNW,
// MADDD, MADDWP, MADDHQ, MULD, DOT2WD, DOT2UWD, DOT2SUWD, DOT2W, MULWP,
// MULHQ, MULWC
let Size = 8 in
class REGISTERW_REGISTERZ_UPPER27_LOWER10_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 30 insn(s):
// ADDD, SBFD, ABDD, MIND, MINUD, MAXD, MAXUD, ANDD, NANDD, ORD, NORD, XORD,
// NXORD, ANDND, ORND, SBMM8, SBMMT8, ADDSD, SBFSD, MADDD, MADDWP, MADDHQ,
// MULD, DOT2WD, DOT2UWD, DOT2SUWD, DOT2W, MULWP, MULHQ, MULWC
let Size = 12 in
class REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// ADDX2D, ADDX4D, ADDX8D, ADDX16D, ADDX32D, ADDX64D, SBFX2D, SBFX4D, SBFX8D, SBFX16D, SBFX32D, SBFX64D, ADDWD,
// SBFWD, ADDUWD, SBFUWD, LANDD, LNANDD, LORD, LNORD, ADDSW, SBFSW, ADDX2W,
// ADDX4W, ADDX8W, ADDX16W, ADDX32W, ADDX64W, SBFX2W, SBFX4W, SBFX8W, SBFX16W, SBFX32W, SBFX64W, AVGW, AVGUW,
// AVGRW, AVGRUW, LANDW, LNANDW, LORW, LNORW, ADDX2WD, ADDX4WD, ADDX8WD,
// ADDX16WD, ADDX32WD, ADDX64WD, SBFX2WD, SBFX4WD, SBFX8WD, SBFX16WD, SBFX32WD, SBFX64WD, ADDX2UWD, ADDX4UWD,
// ADDX8UWD, ADDX16UWD, ADDX32UWD, ADDX64UWD, SBFX2UWD, SBFX4UWD, SBFX8UWD, SBFX16UWD, SBFX32UWD, SBFX64UWD, CRCBELMW,
// CRCBELLW, CRCLELMW, CRCLELLW, MADDWD, MADDUWD, MADDSUWD, MADDW, MSBFWD,
// MSBFUWD, MSBFSUWD, MSBFW, MULWD, MULUWD, MULSUWD, MULW, ABDSBO, ABDSW, ABDSWP, ABDSHQ
let Size = 8 in
class REGISTERW_REGISTERZ_UPPER27_LOWER5_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// ADDWP, SBFWP, ABDWP, MINWP, MINUWP, MAXWP, MAXUWP, ADDCWC, SBFCWC, ADDSWP,
// SBFSWP, ADDX2WP, ADDX4WP, ADDX8WP, ADDX16WP, SBFX2WP, SBFX4WP, SBFX8WP,
// SBFX16WP, AVGWP, AVGUWP, AVGRWP, AVGRUWP, LANDWP, LNANDWP, LORWP, LNORWP,
// ADDBO, ADDHQ, SBFBO, SBFHQ, ABDBO, ABDHQ, MINBO, MINHQ, MINUBO, MINUHQ, MAXBO, MAXHQ, MAXUBO, MAXUHQ, ADDCHCP, SBFCHCP,
// ADDSBO, ADDUSBO, ADDUSHQ, ADDSHQ, SBFSHQ, ADDX2BO, ADDX2HQ, ADDX4BO, ADDX4HQ, ADDX8BO, ADDX8HQ, ADDX16BO, ADDX16HQ,
// SBFX2BO, SBFX2HQ, SBFX4BO, SBFX4HQ, SBFX8BO, SBFX8HQ, SBFX16BO, SBFX16HQ,
// AVGHQ, AVGUHQ, AVGRHQ, AVGRUHQ, LANDHQ, LNANDHQ, LORHQ,
// LNORHQ, ADDUSD, ADDUSW, ADDUSWP, SBFUSBO, SBFUSD, SBFUSHQ, SBFUSW, SBFUSWP, SBFSBO,
// ABDSBO, AVGBO, AVGUBO, AVGRBO, AVGRUBO, ABDSD, ABDSHQ
let Size = 8 in
class SPLAT32_REGISTERW_REGISTERZ_UPPER27_LOWER5_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 43 insn(s):
// FNEGD, FABSD, FSRSRD, FNEGW, FABSW, FSRSRW, FNEGWP, FABSWP, FSRSRWP,
// FNEGHQ, FABSHQ, CLZW, CLSW, CBSW, CTZW, CLZD, CLSD, CBSD, CTZD, CLZWP,
// CLSWP, CBSWP, CTZWP, SXLHWP, SXMHWP, SXLBHQ, SXMBHQ, COPYD, NOTD, NEGD,
// ABSD, ZXBD, SXBD, ZXHD, SXHD, ZXWD, SXWD, SATDH, SATDW, COPYW, NOTW, NEGW,
// ABSW
let Size = 4 in
class REGISTERW_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 9 insn(s):
// FSRECD, FWIDENLWD, FWIDENMWD, FSRECW, FWIDENLHW, FWIDENMHW, FSRECWP,
// FWIDENLHWP, FWIDENMHWP
let Size = 4 in
class SILENT2_REGISTERW_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE>;

// 4 insn(s):
// FNARROWDW, FRECW, FRSRW, FNARROWWH
let Size = 4 in
class ROUNDING2_SILENT2_REGISTERW_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 2 insn(s):
// FNARROWDWP, FNARROWWHQ
let Size = 4 in
class ROUNDING2_SILENT2_REGISTERW_REGISTERP_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 4 insn(s):
// INSF, EXTFZ, EXTFS, CLRF
let Size = 4 in
class REGISTERW_REGISTERZ_STOPBIT2_STOPBIT4_STARTBIT_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE>;

// 25 insn(s):
// SATD, SRSD, SLLD, SRAD, SRLD, SLSD, SRSW, SLLW, SRAW, SRLW, SLSW, ROLW,
// RORW, SRSWPS, SLLWPS, SRAWPS, SRLWPS, SLSWPS, ROLWPS, RORWPS, SRSBOS, SRSHQS,
// SLLBOS, SLLHQS, SRABOS, SRAHQS, SRLBOS, SRLHQS, SLSHQS,
// SLSBOS, SLUSBOS, SLUSD, SLUSW, SLUSWPS, SLUSHQS
let Size = 4 in
class REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 1 insn(s):
// COMPD
let Size = 4 in
class COMPARISON_REGISTERW_REGISTERZ_SIGNED10_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_TINY>;

// 1 insn(s):
// COMPD
let Size = 8 in
class COMPARISON_REGISTERW_REGISTERZ_UPPER27_LOWER10_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_TINY_X>;

// 1 insn(s):
// COMPD
let Size = 12 in
class COMPARISON_REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_TINY_Y>;

// COMPD, COMPW, COMPWD, COMPUWD, COMPNWP, COMPNBO, COMPNHQ, COMPNW
let Size = 4 in
class COMPARISON_REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// COMPW, COMPNW, COMPND
let Size = 8 in
class COMPARISON_REGISTERW_REGISTERZ_UPPER27_LOWER5_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_TINY_X>;

// 1 insn(s):
// CMOVED
let Size = 4 in
class SCALARCOND_REGISTERZ_REGISTERW_SIGNED10_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE>;

// 1 insn(s):
// CMOVED
let Size = 8 in
class SCALARCOND_REGISTERZ_REGISTERW_UPPER27_LOWER10_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE_X>;

// 1 insn(s):
// CMOVED
let Size = 12 in
class SCALARCOND_REGISTERZ_REGISTERW_EXTEND27_UPPER27_LOWER10_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE_Y>;

// 1 insn(s):
// CMOVED
let Size = 4 in
class SCALARCOND_REGISTERZ_REGISTERW_REGISTERY_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE>;

// CMOVEWP, CMOVEHQ, CMOVEBO
let Size = 4 in
class SIMDCOND_REGISTERZ_REGISTERW_REGISTERY_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE>;

// 2 insn(s):
// MAKE, PCREL
let Size = 4 in
class REGISTERW_SIGNED16_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 2 insn(s):
// MAKE, PCREL
let Size = 8 in
class REGISTERW_EXTEND6_UPPER27_LOWER10_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 2 insn(s):
// MAKE, PCREL
let Size = 12 in
class REGISTERW_EXTEND27_UPPER27_LOWER10_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// FCOMPW, FCOMPNW
let Size = 4 in
class FLOATCOMP_REGISTERW_REGISTERZ_REGISTERY_SIMPLE_BINARY32
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE>;

// FCOMPW, FCOMPNW
let Size = 8 in
class FLOATCOMP_REGISTERW_REGISTERZ_UPPER27_LOWER5_DOUBLE_BINARY32
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE_X>;

// 1 insn(s):
// FCOMPD
let Size = 4 in
class FLOATCOMP_REGISTERW_REGISTERZ_REGISTERY_SIMPLE_BINARY64
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE>;

// 1 insn(s):
// FCOMPNWP
let Size = 4 in
class FLOATCOMP_REGISTERW_REGISTERZ_REGISTERY_SIMPLE_BINARY32X2
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE>;

// 1 insn(s):
// FCOMPNHQ
let Size = 4 in
class FLOATCOMP_REGISTERW_REGISTERZ_REGISTERY_SIMPLE_BINARY16X4
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE>;

// 6 insn(s):
// FSDIVD, FCDIVD, FSDIVW, FCDIVW, FSDIVWP, FCDIVWP
let Size = 4 in
class SILENT2_REGISTERW_REGISTERP_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE>;

// 4 insn(s):
// FLOATD, FLOATUD, FIXEDD, FIXEDUD
let Size = 4 in
class ROUNDING_SILENT_REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE_BINARY64
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, MAU_FP>;

// 4 insn(s):
// FLOATWP, FLOATUWP, FIXEDWP, FIXEDUWP
let Size = 4 in
class ROUNDING_SILENT_REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE_BINARY32X2
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, MAU_FP>;

// 4 insn(s):
// FLOATW, FLOATUW, FIXEDW, FIXEDUW
let Size = 4 in
class ROUNDING_SILENT_REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE_BINARY32
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, MAU_FP>;

// 40 insn(s):
// MADDHWQ, MSBFHWQ, MADDUHWQ, MSBFUHWQ, MADDSUHWQ, MSBFSUHWQ, MADDDT,
// MADDUDT, MADDSUDT, MADDUZDT, MSBFDT, MSBFUDT, MSBFSUDT, MSBFUZDT, MULDT,
// MULUDT, MULSUDT, CMULDT, CMULXDT, CMULGLXDT, CMULGMXDT, CMULGHXDT, MULWDC,
// MULCWDC, MULHWQ, MULUHWQ, MULSUHWQ, MADDWDP, MADDUWDP, MADDSUWDP, MMA212W,
// MSBFWDP, MSBFUWDP, MSBFSUWDP, MMS212W, MULWDP, MULUWDP, MULSUWDP, MM212W,
// COPYQ
let Size = 4 in
class REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 8 insn(s):
// MADDDT, MADDUDT, MADDSUDT, MADDUZDT, MULDT, MULUDT, MULSUDT, CMULDT
let Size = 4 in
class REGISTERM_REGISTERZ_SIGNED10_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 8 insn(s):
// MADDDT, MADDUDT, MADDSUDT, MADDUZDT, MULDT, MULUDT, MULSUDT, CMULDT
let Size = 8 in
class REGISTERM_REGISTERZ_UPPER27_LOWER10_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 8 insn(s):
// MADDDT, MADDUDT, MADDSUDT, MADDUZDT, MULDT, MULUDT, MULSUDT, CMULDT
let Size = 12 in
class REGISTERM_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 5 insn(s):
// DOT2WDP, DOT2UWDP, DOT2SUWDP, MULWQ, DOT2WZP
let Size = 4 in
class REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, MAU_AUXR>;

// 9 insn(s):
// FFMAD, FFMSD, FMULD, FADDD, FSBFD, FFMAWD, FFMSWD, FMULWD, FDOT2WD
let Size = 12, Predicates = [IsV1] in
class REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE_BINARY64
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 9 insn(s):
// FFMAD, FFMSD, FMULD, FADDD, FSBFD, FFMAWD, FFMSWD, FMULWD, FDOT2WD
let Size = 4 in
class ROUNDING_SILENT_REGISTERW_REGISTERZ_REGISTERY_SIMPLE_BINARY64
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 6 insn(s):
// FFMAWP, FFMSWP, FMULWP, FMULWC, FADDWP, FSBFWP
let Size = 12, Predicates = [IsV1] in
class REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE_BINARY32X2
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 7 insn(s):
// FFDMDAW, FFMAWP, FFMSWP, FMULWP, FMULWC, FADDWP, FSBFWP
let Size = 4 in
class ROUNDING_SILENT_REGISTERW_REGISTERZ_REGISTERY_SIMPLE_BINARY32X2
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 1 insn:
// FFDMDAWP
let Size = 4 in
class ROUNDING_SILENT_REGISTERW_REGISTERP_REGISTERQ_SIMPLE_BINARY32X2
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 5 insn(s):
// FFMAHQ, FFMSHQ, FMULHQ, FADDHQ, FSBFHQ
let Size = 12, Predicates = [IsV1] in
class REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE_BINARY16X4
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 5 insn(s):
// FFMAHQ, FFMSHQ, FMULHQ, FADDHQ, FSBFHQ
let Size = 4 in
class ROUNDING_SILENT_REGISTERW_REGISTERZ_REGISTERY_SIMPLE_BINARY16X4
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 5 insn(s):
// FMULWDP, FMULWDC, FMULCWDC, FFMAWDP, FFMSWDP
let Size = 12, Predicates = [IsV1] in
class REGISTERM_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE_BINARY32X2
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 5 insn(s):
// FMULWDP, FMULWDC, FMULCWDC, FFMAWDP, FFMSWDP
let Size = 4 in
class ROUNDING_SILENT_REGISTERM_REGISTERZ_REGISTERY_SIMPLE_BINARY32X2
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 3 insn(s):
// FMULHWQ, FFMAHWQ, FFMSHWQ
let Size = 12, Predicates = [IsV1] in
class REGISTERM_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE_BINARY16X4
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 3 insn(s):
// FMULHWQ, FFMAHWQ, FFMSHWQ
let Size = 4 in
class ROUNDING_SILENT_REGISTERM_REGISTERZ_REGISTERY_SIMPLE_BINARY16X4
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 7 insn(s):
// FMULWQ, FADDDP, FADDWQ, FSBFDP, FSBFWQ, FDOT2WZP, FDOT2WDP
let Size = 4 in
class ROUNDING_SILENT_REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, MAU_AUXR_FP>;

// 9 insn(s):
// FFMAHW, FFMAW, FFMSHW, FFMSW, FADDW, FSBFW, FMULHW, FMULW, FDOT2W
let Size = 8, Predicates = [IsV1] in
class REGISTERW_REGISTERZ_UPPER27_LOWER10_DOUBLE_BINARY32
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 9 insn(s):
// FFMAHW, FFMAW, FFMSHW, FFMSW, FADDW, FSBFW, FMULHW, FMULW, FDOT2W
let Size = 4 in
class ROUNDING_SILENT_REGISTERW_REGISTERZ_REGISTERY_SIMPLE_BINARY32
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 3 insn(s):
// FMMA212W, FMMS212W, FMM212W
let Size = 4 in
class ROUNDING_SILENT_REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// FMM222W, FMMA222W, FMMS222W
let Size = 4 in
class ROUNDING_SILENT_TRANSPOSE_REGISTERM_REGISTERO_REGISTERP
  <dag outs, dag ins, string asmstr, InstrItinClass itin, list<dag> pattern = []>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>, Requires<[IsV2]>;

// 1 insn(s):
// COPYO
let Size = 4 in
class REGISTERN_REGISTERQ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXR_AUXW_LOAD>;

// 1 insn(s):
// MOVETQ
let Size = 4 in
class REGISTERAL_REGISTERZ_REGISTERY_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE_CRWL>;

// 1 insn(s):
// MOVETQ
let Size = 4 in
class REGISTERAH_REGISTERZ_REGISTERY_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE_CRWH>;

// 1 insn(s):
// ALIGNO
let Size = 4 in
class REGISTERN_REGISTERBE_REGISTERCO_BYTESHIFT_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU_TINY_AUXW_CRRP>;

// 1 insn(s):
// ALIGNO
let Size = 4 in
class REGISTERN_REGISTERBO_REGISTERCE_BYTESHIFT_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU_TINY_AUXW_CRRP>;

// 1 insn(s):
// ALIGNO
let Size = 4 in
class REGISTERN_REGISTERBE_REGISTERCO_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU_TINY_AUXW_CRRP>;

// 1 insn(s):
// ALIGNO
let Size = 4 in
class REGISTERN_REGISTERBO_REGISTERCE_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU_TINY_AUXW_CRRP>;

// 1 insn(s):
// ALIGNV
let Size = 4 in
class REGISTERA_REGISTERBE_REGISTERCO_BYTESHIFT_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU_CRRP_CRWL_CRWH>;

// 1 insn(s):
// ALIGNV
let Size = 4 in
class REGISTERA_REGISTERBO_REGISTERCE_BYTESHIFT_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU_CRRP_CRWL_CRWH>;

// 1 insn(s):
// ALIGNV
let Size = 4 in
class REGISTERA_REGISTERBE_REGISTERCO_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU_CRRP_CRWL_CRWH>;

// 1 insn(s):
// ALIGNV
let Size = 4 in
class REGISTERA_REGISTERBO_REGISTERCE_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU_CRRP_CRWL_CRWH>;

// 1 insn(s):
// MT44D
let Size = 4 in
class REGISTERAQ_REGISTERBQ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 4 insn(s):
// MMA484BW, MMA484UBW, MMA484SUBW, MMA484USBW
let Size = 4 in
class REGISTERAP_REGISTERBP_REGISTERC_REGISTERD_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 12 insn(s):
// MMA444HBD0, MMA444UHBD0, MMA444SUHBD0, MMA444USHBD0, MMA444HBD1,
// MMA444UHBD1, MMA444SUHBD1, MMA444USHBD1, MMA444HD, MMA444UHD, MMA444SUHD,
// MMA444USHD
let Size = 4 in
class REGISTERAQ_REGISTERBQ_REGISTERC_REGISTERD_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 1 insn(s):
// FMMA242HW0
let Size = 4 in
class REGISTERA0_REGISTERBP_REGISTERC_REGISTERD_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, TCA_FP16>;

// 1 insn(s):
// FMMA242HW1
let Size = 4 in
class REGISTERA1_REGISTERBP_REGISTERC_REGISTERD_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, TCA_FP16>;

// 1 insn(s):
// FMMA242HW2
let Size = 4 in
class REGISTERA2_REGISTERBP_REGISTERC_REGISTERD_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, TCA_FP16>;

// 1 insn(s):
// FMMA242HW3
let Size = 4 in
class REGISTERA3_REGISTERBP_REGISTERC_REGISTERD_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, TCA_FP16>;

// 1 insn(s):
// CONVDHV0
let Size = 4 in
class ROUNDINT_SATURATE_REGISTERAL_REGISTERBQ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 1 insn(s):
// CONVDHV1
let Size = 4 in
class ROUNDINT_SATURATE_REGISTERAH_REGISTERBQ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 1 insn(s):
// CONVWBV0
let Size = 4 in
class ROUNDINT_SATURATE_REGISTERAX_REGISTERBQ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 1 insn(s):
// CONVWBV1
let Size = 4 in
class ROUNDINT_SATURATE_REGISTERAY_REGISTERBQ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 1 insn(s):
// CONVWBV2
let Size = 4 in
class ROUNDINT_SATURATE_REGISTERAZ_REGISTERBQ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 1 insn(s):
// CONVWBV3
let Size = 4 in
class ROUNDINT_SATURATE_REGISTERAT_REGISTERBQ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 1 insn(s):
// FSCALEWV
let Size = 4 in
class XROUNDING_SILENT2_RECTIFY_REGISTERA_REGISTERB_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 1 insn(s):
// FNARROWWHV
let Size = 4 in
class XROUNDING_SILENT2_REGISTERA_REGISTERBP_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 4 insn(s):
// NEGWP, ABSWP, NEGHQ, ABSBO, ABSHQ
let Size = 8 in
class REGISTERW_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 1 insn(s):
// COPYV
let Size = 4 in
class REGISTERA_REGISTERBE_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU_CRRP_CRWL_CRWH>;

// 1 insn(s):
// COPYV
let Size = 4 in
class REGISTERA_REGISTERBO_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU_CRRP_CRWL_CRWH>;

// 1 insn(s):
// MOVEFO
let Size = 4 in
class REGISTERN_REGISTERBE_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU_TINY_AUXW_CRRP>;

// 1 insn(s):
// MOVEFO
let Size = 4 in
class REGISTERN_REGISTERBO_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU_TINY_AUXW_CRRP>;

