//===-- KVXPICPatterns.td ----------------------------------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

def PICInternIndirection : SDNode<"KVXISD::PICInternIndirection", SDTIntBinOp>;
def PICExternIndirection : SDNode<"KVXISD::PICExternIndirection", SDTIntBinOp>;
def PICPCRelativeGOTAddr : SDNode<"KVXISD::PICPCRelativeGOTAddr", SDTUNDEF>;
def PICKVXWrapper : SDNode<"KVXISD::PICWRAPPER", SDTKVXWrapper>;


def PICPCRELGOTADDR : REGISTERW_EXTEND27_UPPER27_LOWER10_TRIPLE
  <(outs SingleReg:$gotaddr), (ins ),
   "pcrel $gotaddr = @gotaddr()",
   [(set (i64 SingleReg:$gotaddr), (PICPCRelativeGOTAddr ))],
   ALU_FULL>;

def PICINTERNINDIRECTION : REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
  <(outs SingleReg:$symaddr), (ins SingleReg:$gotaddr, Wrapped64:$gotoff),
   "addd $symaddr = $gotaddr, @gotoff( $gotoff )",
   [(set (i64 SingleReg:$symaddr),
         (PICInternIndirection (i64 SingleReg:$gotaddr),
                               (i64 tglobaladdr:$gotoff)))],
   ALU_TINY_Y>;

def PICEXTERNINDIRECTION : REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
  <(outs SingleReg:$symaddr), (ins SingleReg:$gotaddr, Wrapped64:$gotoff),
   "ld $symaddr = @got( $gotoff )[$gotaddr]",
   [(set (i64 SingleReg:$symaddr),
         (PICExternIndirection (i64 SingleReg:$gotaddr),
                               (i64 tglobaladdr:$gotoff)))],
   LSU_AUXW_Y>;

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

def PICPCREL : REGISTERW_EXTEND27_UPPER27_LOWER10_TRIPLE
  <(outs SingleReg:$SingleReg), (ins Wrapped64:$Wrapped64),
  "pcrel $SingleReg = @pcrel( $Wrapped64 )",
  [(set (i64 SingleReg:$SingleReg), (PICKVXWrapper tblockaddress:$Wrapped64))],
  ALU_FULL_Y>;
