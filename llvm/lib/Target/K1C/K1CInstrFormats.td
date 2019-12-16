//===-- K1CInstrFormats.td - K1C Instruction Formats -------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

// This file was automatically generated, DO NOT EDIT.
// Last generated: 2019-03-18 11:14:10.983224.

// 17 insns: ['AWAIT', 'SLEEP', 'STOP', 'BARRIER', 'TLBREAD', 'TLBPROBE', 'TLBWRITE', 'TLBDINVAL', 'TLBIINVAL', 'ERROP', 'BREAK', 'RET', 'RFE', 'DINVAL', 'IINVAL', 'FENCE', 'NOP']

let Size = 4 in
class SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 6 insns: ['IGOTO', 'ICALL', 'SCALL', 'IGET', 'WAITIT', 'SYNCGROUP']

let Size = 4 in
class REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 1 insns: ['SCALL']

let Size = 4 in
class SYSNUMBER_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, ALL>;

// 1 insns: ['LOOPDO']

let Size = 4 in
class REGISTERZ_PCREL17_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, ALL>;

// 3 insns: ['FXLW', 'FXMW', 'SET']

let Size = 4 in
class SYSTEMT2_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, BCU>;

// SYSTEMT3_REGISTERZ_SIMPLE has been added by hand for SETd0 insn
// SYSTEMT2_REGISTERZ_SIMPLE may be obsolete
let Size = 4 in
class SYSTEMT3_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, BCU>;

// 3 insns: ['FXLW', 'FXMW', 'SET']

let Size = 4 in
class SYSTEMPS_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, ALL>;

// 1 insns: ['GET']

let Size = 4 in
class REGISTERZ_SYSTEMS2_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, BCU_TINY_TINY_MAU_XNOP>;

// 1 insns: ['SET']

let Size = 4 in
class SYSTEMRA_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, BCU>;

// 2 insns: ['GOTO', 'CALL']

let Size = 4 in
class PCREL27_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, BCU>;

// 1 insns: ['CB']

let Size = 4 in
class BRANCHCOND_REGISTERZ_PCREL17_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, BCU>;

// 7 insns: ['LBZ', 'LBS', 'LHZ', 'LHS', 'LWZ', 'LWS', 'LD']

let Size = 4 in
class VARIANT_REGISTERW_SIGNED10_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW>;

// 7 insns: ['LBZ', 'LBS', 'LHZ', 'LHS', 'LWZ', 'LWS', 'LD']

let Size = 8 in
class VARIANT_REGISTERW_UPPER27_LOWER10_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_X>;

// 7 insns: ['LBZ', 'LBS', 'LHZ', 'LHS', 'LWZ', 'LWS', 'LD']

let Size = 12 in
class VARIANT_REGISTERW_EXTEND27_UPPER27_LOWER10_REGISTERZ_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_Y>;

// 7 insns: ['LBZ', 'LBS', 'LHZ', 'LHS', 'LWZ', 'LWS', 'LD']

let Size = 4 in
class VARIANT_LSUCOND_REGISTERY_REGISTERW_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW>;

// 7 insns: ['LBZ', 'LBS', 'LHZ', 'LHS', 'LWZ', 'LWS', 'LD']

let Size = 8 in
class VARIANT_LSUCOND_REGISTERY_REGISTERW_OFFSET27_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_X>;

// 7 insns: ['LBZ', 'LBS', 'LHZ', 'LHS', 'LWZ', 'LWS', 'LD']

let Size = 12 in
class VARIANT_LSUCOND_REGISTERY_REGISTERW_EXTEND27_OFFSET27_REGISTERZ_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_Y>;

// 7 insns: ['LBZ', 'LBS', 'LHZ', 'LHS', 'LWZ', 'LWS', 'LD']

let Size = 4 in
class VARIANT_SCALING_REGISTERW_REGISTERY_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW>;

// 1 insns: ['LQ']

let Size = 4 in
class VARIANT_REGISTERM_SIGNED10_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW>;

// 1 insns: ['LQ']

let Size = 8 in
class VARIANT_REGISTERM_UPPER27_LOWER10_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_X>;

// 1 insns: ['LQ']

let Size = 12 in
class VARIANT_REGISTERM_EXTEND27_UPPER27_LOWER10_REGISTERZ_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_Y>;

// 1 insns: ['LQ']

let Size = 4 in
class VARIANT_LSUCOND_REGISTERY_REGISTERM_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW>;

// 1 insns: ['LQ']

let Size = 8 in
class VARIANT_LSUCOND_REGISTERY_REGISTERM_OFFSET27_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_X>;

// 1 insns: ['LQ']

let Size = 12 in
class VARIANT_LSUCOND_REGISTERY_REGISTERM_EXTEND27_OFFSET27_REGISTERZ_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_Y>;

// 1 insns: ['LQ']

let Size = 4 in
class VARIANT_SCALING_REGISTERM_REGISTERY_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW>;

// 1 insns: ['LO']

let Size = 4 in
class VARIANT_REGISTERN_SIGNED10_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW>;

// 1 insns: ['LO']

let Size = 8 in
class VARIANT_REGISTERN_UPPER27_LOWER10_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_X>;

// 1 insns: ['LO']

let Size = 12 in
class VARIANT_REGISTERN_EXTEND27_UPPER27_LOWER10_REGISTERZ_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_Y>;

// 1 insns: ['LO']

let Size = 4 in
class VARIANT_LSUCOND_REGISTERY_REGISTERN_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW>;

// 1 insns: ['LO']

let Size = 8 in
class VARIANT_LSUCOND_REGISTERY_REGISTERN_OFFSET27_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_X>;

// 1 insns: ['LO']

let Size = 12 in
class VARIANT_LSUCOND_REGISTERY_REGISTERN_EXTEND27_OFFSET27_REGISTERZ_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_Y>;

// 1 insns: ['LO']

let Size = 4 in
class VARIANT_SCALING_REGISTERN_REGISTERY_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW>;

// 1 insns: ['LV']

let Size = 4 in
class SPECULATE_REGISTERA_SIGNED10_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU>;

// 1 insns: ['LV']

let Size = 8 in
class SPECULATE_REGISTERA_UPPER27_LOWER10_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_X>;

// 1 insns: ['LV']

let Size = 12 in
class SPECULATE_REGISTERA_EXTEND27_UPPER27_LOWER10_REGISTERZ_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_Y>;

// 1 insns: ['LV']

let Size = 4 in
class SPECULATE_LSUCOND_REGISTERY_REGISTERA_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU>;

// 1 insns: ['LV']

let Size = 8 in
class SPECULATE_LSUCOND_REGISTERY_REGISTERA_OFFSET27_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_X>;

// 1 insns: ['LV']

let Size = 12 in
class SPECULATE_LSUCOND_REGISTERY_REGISTERA_EXTEND27_OFFSET27_REGISTERZ_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_Y>;

// 1 insns: ['LV']

let Size = 4 in
class SPECULATE_SCALING_REGISTERA_REGISTERY_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU>;

// 1 insns: ['LV']

let Size = 4 in
class COLUMNSEL_SPECULATE_REGISTERAQ_SIGNED10_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU>;

// 1 insns: ['LV']

let Size = 8 in
class COLUMNSEL_SPECULATE_REGISTERAQ_UPPER27_LOWER10_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_X>;

// 1 insns: ['LV']

let Size = 12 in
class COLUMNSEL_SPECULATE_REGISTERAQ_EXTEND27_UPPER27_LOWER10_REGISTERZ_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_Y>;

// 1 insns: ['LV']

let Size = 4 in
class COLUMNSEL_SPECULATE_LSUCOND_REGISTERY_REGISTERAQ_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU>;

// 1 insns: ['LV']

let Size = 8 in
class COLUMNSEL_SPECULATE_LSUCOND_REGISTERY_REGISTERAQ_OFFSET27_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_X>;

// 1 insns: ['LV']

let Size = 12 in
class COLUMNSEL_SPECULATE_LSUCOND_REGISTERY_REGISTERAQ_EXTEND27_OFFSET27_REGISTERZ_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_Y>;

// 1 insns: ['LV']

let Size = 4 in
class COLUMNSEL_SPECULATE_SCALING_REGISTERAQ_REGISTERY_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU>;

// 6 insns: ['SB', 'SH', 'SW', 'SD', 'AFADDW', 'AFADDD']

let Size = 4 in
class SIGNED10_REGISTERZ_REGISTERT_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 6 insns: ['SB', 'SH', 'SW', 'SD', 'AFADDW', 'AFADDD']

let Size = 8 in
class UPPER27_LOWER10_REGISTERZ_REGISTERT_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 6 insns: ['SB', 'SH', 'SW', 'SD', 'AFADDW', 'AFADDD']

let Size = 12 in
class EXTEND27_UPPER27_LOWER10_REGISTERZ_REGISTERT_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 6 insns: ['SB', 'SH', 'SW', 'SD', 'AFADDW', 'AFADDD']

let Size = 4 in
class SCALING_REGISTERY_REGISTERZ_REGISTERT_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 6 insns: ['SB', 'SH', 'SW', 'SD', 'AFADDW', 'AFADDD']

let Size = 4 in
class LSUCOND_REGISTERY_REGISTERZ_REGISTERT_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 6 insns: ['SB', 'SH', 'SW', 'SD', 'AFADDW', 'AFADDD']

let Size = 8 in
class LSUCOND_REGISTERY_OFFSET27_REGISTERZ_REGISTERT_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 6 insns: ['SB', 'SH', 'SW', 'SD', 'AFADDW', 'AFADDD']

let Size = 12 in
class LSUCOND_REGISTERY_EXTEND27_OFFSET27_REGISTERZ_REGISTERT_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 3 insns: ['SQ', 'ACSWAPW', 'ACSWAPD']

let Size = 4 in
class SIGNED10_REGISTERZ_REGISTERU_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 3 insns: ['SQ', 'ACSWAPW', 'ACSWAPD']

let Size = 8 in
class UPPER27_LOWER10_REGISTERZ_REGISTERU_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 1 insns: ['SQ']

let Size = 12 in
class EXTEND27_UPPER27_LOWER10_REGISTERZ_REGISTERU_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXR_Y>;

// 3 insns: ['SQ', 'ACSWAPW', 'ACSWAPD']

let Size = 4 in
class SCALING_REGISTERY_REGISTERZ_REGISTERU_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 3 insns: ['SQ', 'ACSWAPW', 'ACSWAPD']

let Size = 4 in
class LSUCOND_REGISTERY_REGISTERZ_REGISTERU_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 3 insns: ['SQ', 'ACSWAPW', 'ACSWAPD']

let Size = 8 in
class LSUCOND_REGISTERY_OFFSET27_REGISTERZ_REGISTERU_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 3 insns: ['SQ', 'ACSWAPW', 'ACSWAPD']

let Size = 12 in
class LSUCOND_REGISTERY_EXTEND27_OFFSET27_REGISTERZ_REGISTERU_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 1 insns: ['SO']

let Size = 4 in
class SIGNED10_REGISTERZ_REGISTERV_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXR>;

// 1 insns: ['SO']

let Size = 8 in
class UPPER27_LOWER10_REGISTERZ_REGISTERV_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXR_X>;

// 1 insns: ['SO']

let Size = 12 in
class EXTEND27_UPPER27_LOWER10_REGISTERZ_REGISTERV_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXR_Y>;

// 1 insns: ['SO']

let Size = 4 in
class SCALING_REGISTERY_REGISTERZ_REGISTERV_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXR>;

// 1 insns: ['SO']

let Size = 4 in
class LSUCOND_REGISTERY_REGISTERZ_REGISTERV_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXR>;

// 1 insns: ['SO']

let Size = 8 in
class LSUCOND_REGISTERY_OFFSET27_REGISTERZ_REGISTERV_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
 : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXR_X>;

// 1 insns: ['SO']

let Size = 12 in
class LSUCOND_REGISTERY_EXTEND27_OFFSET27_REGISTERZ_REGISTERV_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXR_Y>;

// 1 insns: ['SV']

let Size = 4 in
class SIGNED10_REGISTERZ_REGISTERE_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_CRRP>;

// 1 insns: ['SV']

let Size = 8 in
class UPPER27_LOWER10_REGISTERZ_REGISTERE_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_CRRP_X>;

// 1 insns: ['SV']

let Size = 12 in
class EXTEND27_UPPER27_LOWER10_REGISTERZ_REGISTERE_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_CRRP_Y>;

// 1 insns: ['SV']

let Size = 4 in
class SCALING_REGISTERY_REGISTERZ_REGISTERE_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_CRRP>;

// 1 insns: ['SV']

let Size = 4 in
class LSUCOND_REGISTERY_REGISTERZ_REGISTERE_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_CRRP>;

// 1 insns: ['SV']

let Size = 8 in
class LSUCOND_REGISTERY_OFFSET27_REGISTERZ_REGISTERE_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_CRRP_X>;

// 1 insns: ['SV']

let Size = 12 in
class LSUCOND_REGISTERY_EXTEND27_OFFSET27_REGISTERZ_REGISTERE_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_CRRP_Y>;

// 2 insns: ['ALCLRW', 'ALCLRD']

let Size = 4 in
class REGISTERW_SIGNED10_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW>;

// 2 insns: ['ALCLRW', 'ALCLRD']

let Size = 8 in
class REGISTERW_UPPER27_LOWER10_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_X>;

// 2 insns: ['ALCLRW', 'ALCLRD']

let Size = 12 in
class REGISTERW_EXTEND27_UPPER27_LOWER10_REGISTERZ_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_Y>;

// 2 insns: ['ALCLRW', 'ALCLRD']

let Size = 4 in
class SCALING_REGISTERW_REGISTERY_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW>;

// 2 insns: ['ALCLRW', 'ALCLRD']

let Size = 4 in
class LSUCOND_REGISTERY_REGISTERW_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW>;

// 2 insns: ['ALCLRW', 'ALCLRD']

let Size = 8 in
class LSUCOND_REGISTERY_REGISTERW_OFFSET27_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_X>;

// 2 insns: ['ALCLRW', 'ALCLRD']

let Size = 12 in
class LSUCOND_REGISTERY_REGISTERW_EXTEND27_OFFSET27_REGISTERZ_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_Y>;

// 4 insns: ['DTOUCHL', 'DINVALL', 'DZEROL', 'IINVALS']

let Size = 4 in
class SIGNED10_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU>;

// 4 insns: ['DTOUCHL', 'DINVALL', 'DZEROL', 'IINVALS']

let Size = 8 in
class UPPER27_LOWER10_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_X>;

// 4 insns: ['DTOUCHL', 'DINVALL', 'DZEROL', 'IINVALS']

let Size = 12 in
class EXTEND27_UPPER27_LOWER10_REGISTERZ_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_Y>;

// 4 insns: ['DTOUCHL', 'DINVALL', 'DZEROL', 'IINVALS']

let Size = 4 in
class REGISTERY_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU>;

// 4 insns: ['DTOUCHL', 'DINVALL', 'DZEROL', 'IINVALS']

let Size = 4 in
class LSUCOND_REGISTERY_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU>;

// 4 insns: ['DTOUCHL', 'DINVALL', 'DZEROL', 'IINVALS']

let Size = 8 in
class LSUCOND_REGISTERY_OFFSET27_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_X>;

// 4 insns: ['DTOUCHL', 'DINVALL', 'DZEROL', 'IINVALS']

let Size = 12 in
class LSUCOND_REGISTERY_EXTEND27_OFFSET27_REGISTERZ_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_Y>;

// 209 insns: ['STSUD', 'ADDD', 'SBFD', 'ABDD', 'MIND', 'MINUD', 'MAXD', 'MAXUD', 'ANDD', 'NANDD', 'ORD', 'NORD', 'XORD', 'NXORD', 'ANDND', 'ORND', 'SBMM8', 'SBMMT8', 'ADDSD', 'SBFSD', 'ADDX2D', 'ADDX4D', 'ADDX8D', 'ADDX16D', 'SBFX2D', 'SBFX4D', 'SBFX8D', 'SBFX16D', 'ADDWD', 'SBFWD', 'ADDUWD', 'SBFUWD', 'LANDD', 'LNANDD', 'LORD', 'LNORD', 'STSUW', 'ADDW', 'SBFW', 'ABDW', 'MINW', 'MINUW', 'MAXW', 'MAXUW', 'ANDW', 'NANDW', 'ORW', 'NORW', 'XORW', 'NXORW', 'ANDNW', 'ORNW', 'ADDSW', 'SBFSW', 'ADDX2W', 'ADDX4W', 'ADDX8W', 'ADDX16W', 'SBFX2W', 'SBFX4W', 'SBFX8W', 'SBFX16W', 'AVGW', 'AVGUW', 'AVGRW', 'AVGRUW', 'LANDW', 'LNANDW', 'LORW', 'LNORW', 'ADDWP', 'SBFWP', 'ABDWP', 'MINWP', 'MINUWP', 'MAXWP', 'MAXUWP', 'ADDCWC', 'SBFCWC', 'ADDSWP', 'SBFSWP', 'ADDX2WP', 'ADDX4WP', 'ADDX8WP', 'ADDX16WP', 'SBFX2WP', 'SBFX4WP', 'SBFX8WP', 'SBFX16WP', 'AVGWP', 'AVGUWP', 'AVGRWP', 'AVGRUWP', 'LANDWP', 'LNANDWP', 'LORWP', 'LNORWP', 'ADDHQ', 'SBFHQ', 'ABDHQ', 'MINHQ', 'MINUHQ', 'MAXHQ', 'MAXUHQ', 'ADDCHCP', 'SBFCHCP', 'ADDSHQ', 'SBFSHQ', 'ADDX2HQ', 'ADDX4HQ', 'ADDX8HQ', 'ADDX16HQ', 'SBFX2HQ', 'SBFX4HQ', 'SBFX8HQ', 'SBFX16HQ', 'AVGHQ', 'AVGUHQ', 'AVGRHQ', 'AVGRUHQ', 'LANDHQ', 'LNANDHQ', 'LORHQ', 'LNORHQ', 'ADDX2WD', 'ADDX4WD', 'ADDX8WD', 'ADDX16WD', 'SBFX2WD', 'SBFX4WD', 'SBFX8WD', 'SBFX16WD', 'ADDX2UWD', 'ADDX4UWD', 'ADDX8UWD', 'ADDX16UWD', 'SBFX2UWD', 'SBFX4UWD', 'SBFX8UWD', 'SBFX16UWD', 'ADDCD', 'SBFCD', 'ADDCID', 'SBFCID', 'SATD', 'SATUD', 'SRSD', 'SLLD', 'SRAD', 'SRLD', 'SLSD', 'SRSW', 'SLLW', 'SRAW', 'SRLW', 'SLSW', 'ROLW', 'RORW', 'SRSWPS', 'SLLWPS', 'SRAWPS', 'SRLWPS', 'SLSWPS', 'ROLWPS', 'RORWPS', 'SRSHQS', 'SLLHQS', 'SRAHQS', 'SRLHQS', 'SLSHQS', 'FMIND', 'FMAXD', 'FMINW', 'FMAXW', 'FMINWP', 'FMAXWP', 'FMINHQ', 'FMAXHQ', 'MADDD', 'MSBFD', 'MADDWP', 'MSBFWP', 'MADDHQ', 'MSBFHQ', 'MULD', 'CRCBELMW', 'CRCBELLW', 'CRCLELMW', 'CRCLELLW', 'DOT2WD', 'DOT2UWD', 'DOT2SUWD', 'DOT2W', 'MULWP', 'MULHQ', 'MULWC', 'MULCWC', 'MADDWD', 'MADDUWD', 'MADDSUWD', 'MADDW', 'MSBFWD', 'MSBFUWD', 'MSBFSUWD', 'MSBFW', 'MULWD', 'MULUWD', 'MULSUWD', 'MULW']

let Size = 4 in
class REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 77 insns: ['ADDD', 'SBFD', 'ABDD', 'MIND', 'MINUD', 'MAXD', 'MAXUD', 'ANDD', 'NANDD', 'ORD', 'NORD', 'XORD', 'NXORD', 'ANDND', 'ORND', 'SBMM8', 'SBMMT8', 'ADDSD', 'SBFSD', 'ADDW', 'SBFW', 'ABDW', 'MINW', 'MINUW', 'MAXW', 'MAXUW', 'ANDW', 'NANDW', 'ORW', 'NORW', 'XORW', 'NXORW', 'ANDNW', 'ORNW', 'MADDD', 'MADDWP', 'MADDHQ', 'MULD', 'DOT2WD', 'DOT2UWD', 'DOT2SUWD', 'DOT2W', 'MULWP', 'MULHQ', 'MULWC', 'FFMAD', 'FFMAWP', 'FFMAHQ', 'FFMSD', 'FFMSWP', 'FFMSHQ', 'FMULD', 'FMULWP', 'FMULHQ', 'FMULWC', 'FMULCWC', 'FADDD', 'FADDWP', 'FADDHQ', 'FADDCWC', 'FSBFD', 'FSBFWP', 'FSBFHQ', 'FSBFCWC', 'FFMAHW', 'FFMAW', 'FFMAWD', 'FFMSHW', 'FFMSW', 'FFMSWD', 'FADDW', 'FSBFW', 'FMULHW', 'FMULW', 'FMULWD', 'FDOT2W', 'FDOT2WD']

let Size = 4 in
class REGISTERW_REGISTERZ_SIGNED10_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 77 insns: ['ADDD', 'SBFD', 'ABDD', 'MIND', 'MINUD', 'MAXD', 'MAXUD', 'ANDD', 'NANDD', 'ORD', 'NORD', 'XORD', 'NXORD', 'ANDND', 'ORND', 'SBMM8', 'SBMMT8', 'ADDSD', 'SBFSD', 'ADDW', 'SBFW', 'ABDW', 'MINW', 'MINUW', 'MAXW', 'MAXUW', 'ANDW', 'NANDW', 'ORW', 'NORW', 'XORW', 'NXORW', 'ANDNW', 'ORNW', 'MADDD', 'MADDWP', 'MADDHQ', 'MULD', 'DOT2WD', 'DOT2UWD', 'DOT2SUWD', 'DOT2W', 'MULWP', 'MULHQ', 'MULWC', 'FFMAD', 'FFMAWP', 'FFMAHQ', 'FFMSD', 'FFMSWP', 'FFMSHQ', 'FMULD', 'FMULWP', 'FMULHQ', 'FMULWC', 'FMULCWC', 'FADDD', 'FADDWP', 'FADDHQ', 'FADDCWC', 'FSBFD', 'FSBFWP', 'FSBFHQ', 'FSBFCWC', 'FFMAHW', 'FFMAW', 'FFMAWD', 'FFMSHW', 'FFMSW', 'FFMSWD', 'FADDW', 'FSBFW', 'FMULHW', 'FMULW', 'FMULWD', 'FDOT2W', 'FDOT2WD']

let Size = 8 in
class REGISTERW_REGISTERZ_UPPER27_LOWER10_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 62 insns: ['ADDD', 'SBFD', 'ABDD', 'MIND', 'MINUD', 'MAXD', 'MAXUD', 'ANDD', 'NANDD', 'ORD', 'NORD', 'XORD', 'NXORD', 'ANDND', 'ORND', 'SBMM8', 'SBMMT8', 'ADDSD', 'SBFSD', 'MADDD', 'MADDWP', 'MADDHQ', 'MULD', 'DOT2WD', 'DOT2UWD', 'DOT2SUWD', 'DOT2W', 'MULWP', 'MULHQ', 'MULWC', 'FFMAD', 'FFMAWP', 'FFMAHQ', 'FFMSD', 'FFMSWP', 'FFMSHQ', 'FMULD', 'FMULWP', 'FMULHQ', 'FMULWC', 'FMULCWC', 'FADDD', 'FADDWP', 'FADDHQ', 'FADDCWC', 'FSBFD', 'FSBFWP', 'FSBFHQ', 'FSBFCWC', 'FFMAHW', 'FFMAW', 'FFMAWD', 'FFMSHW', 'FFMSW', 'FFMSWD', 'FADDW', 'FSBFW', 'FMULHW', 'FMULW', 'FMULWD', 'FDOT2W', 'FDOT2WD']

let Size = 12 in
class REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 66 insns: ['ADDX2D', 'ADDX4D', 'ADDX8D', 'ADDX16D', 'SBFX2D', 'SBFX4D', 'SBFX8D', 'SBFX16D', 'ADDWD', 'SBFWD', 'ADDUWD', 'SBFUWD', 'LANDD', 'LNANDD', 'LORD', 'LNORD', 'ADDSW', 'SBFSW', 'ADDX2W', 'ADDX4W', 'ADDX8W', 'ADDX16W', 'SBFX2W', 'SBFX4W', 'SBFX8W', 'SBFX16W', 'AVGW', 'AVGUW', 'AVGRW', 'AVGRUW', 'LANDW', 'LNANDW', 'LORW', 'LNORW', 'ADDX2WD', 'ADDX4WD', 'ADDX8WD', 'ADDX16WD', 'SBFX2WD', 'SBFX4WD', 'SBFX8WD', 'SBFX16WD', 'ADDX2UWD', 'ADDX4UWD', 'ADDX8UWD', 'ADDX16UWD', 'SBFX2UWD', 'SBFX4UWD', 'SBFX8UWD', 'SBFX16UWD', 'CRCBELMW', 'CRCBELLW', 'CRCLELMW', 'CRCLELLW', 'MADDWD', 'MADDUWD', 'MADDSUWD', 'MADDW', 'MSBFWD', 'MSBFUWD', 'MSBFSUWD', 'MSBFW', 'MULWD', 'MULUWD', 'MULSUWD', 'MULW']

let Size = 8 in
class REGISTERW_REGISTERZ_UPPER27_LOWER5_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 54 insns: ['ADDWP', 'SBFWP', 'ABDWP', 'MINWP', 'MINUWP', 'MAXWP', 'MAXUWP', 'ADDCWC', 'SBFCWC', 'ADDSWP', 'SBFSWP', 'ADDX2WP', 'ADDX4WP', 'ADDX8WP', 'ADDX16WP', 'SBFX2WP', 'SBFX4WP', 'SBFX8WP', 'SBFX16WP', 'AVGWP', 'AVGUWP', 'AVGRWP', 'AVGRUWP', 'LANDWP', 'LNANDWP', 'LORWP', 'LNORWP', 'ADDHQ', 'SBFHQ', 'ABDHQ', 'MINHQ', 'MINUHQ', 'MAXHQ', 'MAXUHQ', 'ADDCHCP', 'SBFCHCP', 'ADDSHQ', 'SBFSHQ', 'ADDX2HQ', 'ADDX4HQ', 'ADDX8HQ', 'ADDX16HQ', 'SBFX2HQ', 'SBFX4HQ', 'SBFX8HQ', 'SBFX16HQ', 'AVGHQ', 'AVGUHQ', 'AVGRHQ', 'AVGRUHQ', 'LANDHQ', 'LNANDHQ', 'LORHQ', 'LNORHQ']

let Size = 8 in
class SPLAT32_REGISTERW_REGISTERZ_UPPER27_LOWER5_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 45 insns: ['FNEGD', 'FABSD', 'FSISRD', 'FNEGW', 'FABSW', 'FSISRW', 'FNEGWP', 'FABSWP', 'FSISRWP', 'FNEGHQ', 'FABSHQ', 'CLZW', 'CLSW', 'CBSW', 'CTZW', 'CLZD', 'CLSD', 'CBSD', 'CTZD', 'CLZWP', 'CLSWP', 'CBSWP', 'CTZWP', 'SXLHWP', 'SXMHWP', 'SXLBHQ', 'SXMBHQ', 'COPYD', 'NOTD', 'NEGD', 'ABSD', 'ZXBD', 'SXBD', 'ZXHD', 'SXHD', 'ZXWD', 'SXWD', 'SATDH', 'SATUDH', 'SATDW', 'SATUDW', 'COPYW', 'NOTW', 'NEGW', 'ABSW']

let Size = 4 in
class REGISTERW_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 9 insns: ['FSINVD', 'FWIDENLWD', 'FWIDENMWD', 'FSINVW', 'FWIDENLHW', 'FWIDENMHW', 'FSINVWP', 'FWIDENLHWP', 'FWIDENMHWP']

let Size = 4 in
class SILENT2_REGISTERW_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE>;

// 4 insns: ['FNARROWDW', 'FINVW', 'FISRW', 'FNARROWWH']

let Size = 4 in
class ROUNDING2_SILENT2_REGISTERW_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 2 insns: ['FNARROWDWP', 'FNARROWWHQ']

let Size = 4 in
class ROUNDING2_SILENT2_REGISTERW_REGISTERP_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 4 insns: ['INSF', 'EXTFZ', 'EXTFS', 'CLRF']

let Size = 4 in
class REGISTERW_REGISTERZ_STOPBIT2_STOPBIT4_STARTBIT_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE>;

// 26 insns: ['SATD', 'SATUD', 'SRSD', 'SLLD', 'SRAD', 'SRLD', 'SLSD', 'SRSW', 'SLLW', 'SRAW', 'SRLW', 'SLSW', 'ROLW', 'RORW', 'SRSWPS', 'SLLWPS', 'SRAWPS', 'SRLWPS', 'SLSWPS', 'ROLWPS', 'RORWPS', 'SRSHQS', 'SLLHQS', 'SRAHQS', 'SRLHQS', 'SLSHQS']

let Size = 4 in
class REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 1 insns: ['COMPD']

let Size = 4 in
class COMPARISON_REGISTERW_REGISTERZ_SIGNED10_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, ALU_TINY>;

// 1 insns: ['COMPD']

let Size = 8 in
class COMPARISON_REGISTERW_REGISTERZ_UPPER27_LOWER10_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, ALU_TINY_X>;

// 1 insns: ['COMPD']

let Size = 12 in
class COMPARISON_REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, ALU_TINY_Y>;

// 6 insns: ['COMPD', 'COMPW', 'COMPWD', 'COMPUWD', 'COMPNWP', 'COMPNHQ']

let Size = 4 in
class COMPARISON_REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 1 insns: ['COMPW']

let Size = 8 in
class COMPARISON_REGISTERW_REGISTERZ_UPPER27_LOWER5_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, ALU_TINY_X>;

// 1 insns: ['CMOVED']

let Size = 4 in
class SCALARCOND_REGISTERZ_REGISTERW_SIGNED10_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE>;

// 1 insns: ['CMOVED']

let Size = 8 in
class SCALARCOND_REGISTERZ_REGISTERW_UPPER27_LOWER10_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE_X>;

// 1 insns: ['CMOVED']

let Size = 12 in
class SCALARCOND_REGISTERZ_REGISTERW_EXTEND27_UPPER27_LOWER10_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE_Y>;

// 1 insns: ['CMOVED']

let Size = 4 in
class SCALARCOND_REGISTERZ_REGISTERW_REGISTERY_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE>;

// 2 insns: ['CMOVEWP', 'CMOVEHQ']

let Size = 4 in
class SIMDCOND_REGISTERZ_REGISTERW_REGISTERY_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE>;

// 2 insns: ['MAKE', 'PCREL']

let Size = 4 in
class REGISTERW_SIGNED16_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 2 insns: ['MAKE', 'PCREL']

let Size = 8 in
class REGISTERW_EXTEND6_UPPER27_LOWER10_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 2 insns: ['MAKE', 'PCREL']

let Size = 12 in
class REGISTERW_EXTEND27_UPPER27_LOWER10_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 4 insns: ['FCOMPW', 'FCOMPD', 'FCOMPNWP', 'FCOMPNHQ']

let Size = 4 in
class FLOATCOMP_REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE>;

// 2 insns: ['FCOMPW', 'FCOMPD']

let Size = 8 in
class FLOATCOMP_REGISTERW_REGISTERZ_UPPER27_LOWER5_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE_X>;

// 6 insns: ['FSDIVD', 'FCDIVD', 'FSDIVW', 'FCDIVW', 'FSDIVWP', 'FCDIVWP']

let Size = 4 in
class SILENT2_REGISTERW_REGISTERP_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE>;

// 12 insns: ['FLOATD', 'FLOATWP', 'FLOATW', 'FLOATUD', 'FLOATUWP', 'FLOATUW', 'FIXEDD', 'FIXEDWP', 'FIXEDW', 'FIXEDUD', 'FIXEDUWP', 'FIXEDUW']

let Size = 4 in
class ROUNDING_SILENT_REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, MAU>;

// 40 insns: ['MADDHWQ', 'MSBFHWQ', 'MADDUHWQ', 'MSBFUHWQ', 'MADDSUHWQ', 'MSBFSUHWQ', 'MADDDT', 'MADDUDT', 'MADDSUDT', 'MADDUZDT', 'MSBFDT', 'MSBFUDT', 'MSBFSUDT', 'MSBFUZDT', 'MULDT', 'MULUDT', 'MULSUDT', 'CMULDT', 'CMULXDT', 'CMULGLXDT', 'CMULGMXDT', 'CMULGHXDT', 'MULWDC', 'MULCWDC', 'MULHWQ', 'MULUHWQ', 'MULSUHWQ', 'MADDWDP', 'MADDUWDP', 'MADDSUWDP', 'MM2AWQ', 'MSBFWDP', 'MSBFUWDP', 'MSBFSUWDP', 'MM2SWQ', 'MULWDP', 'MULUWDP', 'MULSUWDP', 'MM2WQ', 'COPYQ']

let Size = 4 in
class REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 16 insns: ['MADDDT', 'MADDUDT', 'MADDSUDT', 'MADDUZDT', 'MULDT', 'MULUDT', 'MULSUDT', 'CMULDT', 'FMULWDP', 'FMULHWQ', 'FMULWDC', 'FMULCWDC', 'FFMAWDP', 'FFMAHWQ', 'FFMSWDP', 'FFMSHWQ']

let Size = 4 in
class REGISTERM_REGISTERZ_SIGNED10_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 16 insns: ['MADDDT', 'MADDUDT', 'MADDSUDT', 'MADDUZDT', 'MULDT', 'MULUDT', 'MULSUDT', 'CMULDT', 'FMULWDP', 'FMULHWQ', 'FMULWDC', 'FMULCWDC', 'FFMAWDP', 'FFMAHWQ', 'FFMSWDP', 'FFMSHWQ']

let Size = 8 in
class REGISTERM_REGISTERZ_UPPER27_LOWER10_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 16 insns: ['MADDDT', 'MADDUDT', 'MADDSUDT', 'MADDUZDT', 'MULDT', 'MULUDT', 'MULSUDT', 'CMULDT', 'FMULWDP', 'FMULHWQ', 'FMULWDC', 'FMULCWDC', 'FFMAWDP', 'FFMAHWQ', 'FFMSWDP', 'FFMSHWQ']

let Size = 12 in
class REGISTERM_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 5 insns: ['DOT2WDP', 'DOT2UWDP', 'DOT2SUWDP', 'MULWQ', 'DOT2WZP']

let Size = 4 in
class REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, MAU_AUXR>;

// 32 insns: ['FFMAD', 'FFMAWP', 'FFMAHQ', 'FFMSD', 'FFMSWP', 'FFMSHQ', 'FMULD', 'FMULWP', 'FMULHQ', 'FMULWC', 'FMULCWC', 'FADDD', 'FADDWP', 'FADDHQ', 'FADDCWC', 'FSBFD', 'FSBFWP', 'FSBFHQ', 'FSBFCWC', 'FFMAHW', 'FFMAW', 'FFMAWD', 'FFMSHW', 'FFMSW', 'FFMSWD', 'FADDW', 'FSBFW', 'FMULHW', 'FMULW', 'FMULWD', 'FDOT2W', 'FDOT2WD']

let Size = 4 in
class ROUNDING_SILENT_REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 11 insns: ['FMULWDP', 'FMULHWQ', 'FMULWDC', 'FMULCWDC', 'FFMAWDP', 'FFMAHWQ', 'FFMSWDP', 'FFMSHWQ', 'FMM2AWQ', 'FMM2SWQ', 'FMM2WQ']

let Size = 4 in
class ROUNDING_SILENT_REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 11 insns: ['FMULWQ', 'FADDDP', 'FADDWQ', 'FADDCDC', 'FADDCWCP', 'FSBFDP', 'FSBFWQ', 'FSBFCDC', 'FSBFCWCP', 'FDOT2WZP', 'FDOT2WDP']

let Size = 4 in
class ROUNDING_SILENT_REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, MAU_AUXR>;

// 1 insns: ['COPYO']

let Size = 4 in
class REGISTERN_REGISTERQ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXR_AUXW>;

// 1 insns: ['MOVETQ']

let Size = 4 in
class REGISTERAL_REGISTERZ_REGISTERY_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE_CRWL>;

// 1 insns: ['MOVETQ']

let Size = 4 in
class REGISTERAH_REGISTERZ_REGISTERY_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE_CRWH>;

// 1 insns: ['ALIGNO']

let Size = 4 in
class REGISTERN_REGISTERBE_REGISTERCO_BYTESHIFT_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, BCU_TINY_AUXW_CRRP>;

// 1 insns: ['ALIGNO']

let Size = 4 in
class REGISTERN_REGISTERBO_REGISTERCE_BYTESHIFT_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, BCU_TINY_AUXW_CRRP>;

// 1 insns: ['ALIGNO']

let Size = 4 in
class REGISTERN_REGISTERBE_REGISTERCO_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, BCU_TINY_AUXW_CRRP>;

// 1 insns: ['ALIGNO']

let Size = 4 in
class REGISTERN_REGISTERBO_REGISTERCE_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, BCU_TINY_AUXW_CRRP>;

// 1 insns: ['ALIGNV']

let Size = 4 in
class REGISTERA_REGISTERBE_REGISTERCO_BYTESHIFT_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, BCU_CRRW>;

// 1 insns: ['ALIGNV']

let Size = 4 in
class REGISTERA_REGISTERBO_REGISTERCE_BYTESHIFT_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, BCU_CRRW>;

// 1 insns: ['ALIGNV']

let Size = 4 in
class REGISTERA_REGISTERBE_REGISTERCO_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, BCU_CRRW>;

// 1 insns: ['ALIGNV']

let Size = 4 in
class REGISTERA_REGISTERBO_REGISTERCE_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, BCU_CRRW>;

// 1 insns: ['MT4X4D']

let Size = 4 in
class REGISTERAQ_REGISTERBQ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 4 insns: ['MM4ABW', 'MM4AUBW', 'MM4ASUBW', 'MM4AUSBW']

let Size = 4 in
class REGISTERAP_REGISTERBP_REGISTERC_REGISTERD_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 12 insns: ['MM4AHBD0', 'MM4AUHBD0', 'MM4ASUHBD0', 'MM4AUSHBD0', 'MM4AHBD1', 'MM4AUHBD1', 'MM4ASUHBD1', 'MM4AUSHBD1', 'MM4AHD', 'MM4AUHD', 'MM4ASUHD', 'MM4AUSHD']

let Size = 4 in
class REGISTERAQ_REGISTERBQ_REGISTERC_REGISTERD_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 1 insns: ['FMM4AHW0']

let Size = 4 in
class REGISTERA0_REGISTERBP_REGISTERC_REGISTERD_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 1 insns: ['FMM4AHW1']

let Size = 4 in
class REGISTERA1_REGISTERBP_REGISTERC_REGISTERD_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 1 insns: ['FMM4AHW2']

let Size = 4 in
class REGISTERA2_REGISTERBP_REGISTERC_REGISTERD_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 1 insns: ['FMM4AHW3']

let Size = 4 in
class REGISTERA3_REGISTERBP_REGISTERC_REGISTERD_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 1 insns: ['CONVDHV0']

let Size = 4 in
class ROUNDINT_SATURATE_REGISTERAL_REGISTERBQ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 1 insns: ['CONVDHV1']

let Size = 4 in
class ROUNDINT_SATURATE_REGISTERAH_REGISTERBQ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 1 insns: ['CONVWBV0']

let Size = 4 in
class ROUNDINT_SATURATE_REGISTERAX_REGISTERBQ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 1 insns: ['CONVWBV1']

let Size = 4 in
class ROUNDINT_SATURATE_REGISTERAY_REGISTERBQ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 1 insns: ['CONVWBV2']

let Size = 4 in
class ROUNDINT_SATURATE_REGISTERAZ_REGISTERBQ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 1 insns: ['CONVWBV3']

let Size = 4 in
class ROUNDINT_SATURATE_REGISTERAT_REGISTERBQ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 1 insns: ['FSCALEWV']

let Size = 4 in
class XROUNDING_SILENT2_RECTIFY_REGISTERA_REGISTERB_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 1 insns: ['FNARROWWHV']

let Size = 4 in
class XROUNDING_SILENT2_REGISTERA_REGISTERBP_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 4 insns: ['NEGWP', 'ABSWP', 'NEGHQ', 'ABSHQ']

let Size = 8 in
class REGISTERW_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 1 insns: ['COPYV']

let Size = 4 in
class REGISTERA_REGISTERBE_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, BCU_CRRW>;

// 1 insns: ['COPYV']

let Size = 4 in
class REGISTERA_REGISTERBO_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, BCU_CRRW>;

// 1 insns: ['MOVEFO']

let Size = 4 in
class REGISTERN_REGISTERBE_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, BCU_TINY_AUXW_CRRP>;

// 1 insns: ['MOVEFO']

let Size = 4 in
class REGISTERN_REGISTERBO_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : K1C_INSTRUCTION <outs, ins, asmstr, pattern, BCU_TINY_AUXW_CRRP>;
