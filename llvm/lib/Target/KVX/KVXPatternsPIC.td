//===-- KVXPICPatterns.td ----------------------------------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

def PICInternIndirection : SDNode<"KVXISD::PICInternIndirection", SDTIntBinOp>;
def PICExternIndirection : SDNode<"KVXISD::PICExternIndirection",
  SDTypeProfile<1, 1, [SDTCisSameAs<0, 1>, SDTCisInt<0>]>>;
def PICPCRelativeGOTAddr : SDNode<"KVXISD::PICPCRelativeGOTAddr", SDTUNDEF>;
def PICKVXWrapper : SDNode<"KVXISD::PICAddrWrapper", SDTKVXWrapper>;


def PICPCRELGOTADDR : REGISTERW_EXTEND27_UPPER27_LOWER10_TRIPLE
  <(outs SingleReg:$gotaddr), (ins ),
   "pcrel $gotaddr = @gotaddr()",
   [(set (i64 SingleReg:$gotaddr), (PICPCRelativeGOTAddr ))],
   ALU_FULL_Y>;

def PICINTERNINDIRECTION : REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
  <(outs SingleReg:$symaddr), (ins SingleReg:$gotaddr, Wrapped64:$gotoff),
   "addd $symaddr = $gotaddr, @gotoff( $gotoff )",
   [(set (i64 SingleReg:$symaddr),
         (PICInternIndirection (i64 SingleReg:$gotaddr),
                               (i64 tglobaladdr:$gotoff)))],
   ALU_TINY_Y>;

def PCRELGOTADDR : REGISTERW_EXTEND27_UPPER27_LOWER10_TRIPLE
    <(outs SingleReg:$addr), (ins), "pcrel $addr = @gotaddr()", [], ALU_FULL_Y>;

def PICEXTERNINDIRECTION : REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
    <(outs SingleReg:$addr), (ins SingleReg:$gotaddr, Wrapped64:$gotoff),
    "ld $addr = @got( $gotoff )[$gotaddr]", [], LSU_AUXW_Y_LOAD>;

def : Pat<(i64 (PICExternIndirection (i64 tglobaladdr:$gotoff))),
  (PICEXTERNINDIRECTION (PCRELGOTADDR), Pcrel27:$gotoff)>;

let Defs=[RA], isCall=1 in
def CALLPLT : PCREL27_SIMPLE
  <(outs), (ins Pcrel27:$pcreladdr),
   "call $pcreladdr",
   [/* no direct match, see Call pattern below */]>;


// Do not indirect symbols for function calls (loader will)
// NOTE: SingleReg:$gotaddr operand is unused here
def : Pat<(Call (PICExternIndirection (i64 tglobaladdr:$gotoff))),
          (CALLPLT Pcrel27:$gotoff)>;

def PICPCREL : REGISTERW_EXTEND27_UPPER27_LOWER10_TRIPLE
  <(outs SingleReg:$SingleReg), (ins Wrapped64:$Wrapped64),
  "pcrel $SingleReg = @pcrel( $Wrapped64 )",
  [(set (i64 SingleReg:$SingleReg), (PICKVXWrapper tblockaddress:$Wrapped64))],
  ALU_FULL_Y>;

// SJLJ excpetion handling required
def : Pat<(PICInternIndirection i64:$gotaddr, mcsym:$imm),
          (PICINTERNINDIRECTION SingleReg:$gotaddr, Wrapped64:$imm)>;
