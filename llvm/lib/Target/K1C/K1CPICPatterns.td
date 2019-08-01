//===-- K1CPICPatterns.td ----------------------------------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

def PICInternIndirection : SDNode<"K1CISD::PICInternIndirection", SDTIntBinOp>;
def PICExternIndirection : SDNode<"K1CISD::PICExternIndirection", SDTIntBinOp>;
def PICPCRelativeGOTAddr : SDNode<"K1CISD::PICPCRelativeGOTAddr", SDTUNDEF>;


def PICPCRELGOTADDR : REGISTERW_EXTEND27_UPPER27_LOWER10_TRIPLE
  <(outs SingleReg:$gotaddr), (ins ),
   "pcrel $gotaddr = @gotaddr()",
   [(set (i64 SingleReg:$gotaddr), (PICPCRelativeGOTAddr ))],
   __UNKNOWN_ITIN__>;

def PICINTERNINDIRECTION : REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
  <(outs SingleReg:$symaddr), (ins SingleReg:$gotaddr, Wrapped64:$gotoff),
   "addd $symaddr = $gotaddr, @gotoff($gotoff)",
   [(set (i64 SingleReg:$symaddr),
         (PICInternIndirection (i64 SingleReg:$gotaddr),
                               (i64 tglobaladdr:$gotoff)))],
   __UNKNOWN_ITIN__>;

def PICEXTERNINDIRECTION : REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
  <(outs SingleReg:$symaddr), (ins SingleReg:$gotaddr, Wrapped64:$gotoff),
   "ld $symaddr = @got($gotoff)[$gotaddr]",
   [(set (i64 SingleReg:$symaddr),
         (PICExternIndirection (i64 SingleReg:$gotaddr),
                               (i64 tglobaladdr:$gotoff)))],
   __UNKNOWN_ITIN__>;

let Defs=[RA], isCall=1 in
def CALLPLT : PCREL27_SIMPLE
  <(outs), (ins Pcrel27:$pcreladdr, SingleReg:$deadreg),
   "call $pcreladdr",
   [/* no direct match, see Call pattern below */]>;


// Do not indirect symbols for function calls (loader will)
// NOTE: SingleReg:$gotaddr operand is unused here
def : Pat<(Call (PICExternIndirection (i64 SingleReg:$gotaddr),
                                      (i64 tglobaladdr:$gotoff))),
          (CALLPLT Pcrel27:$gotoff, SingleReg:$gotaddr)>;
