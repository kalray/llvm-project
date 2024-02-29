//===-- KVXPatternsAtomic.td - KVX Atomic Patterns ---------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

def atomicloadi8 : PatFrag<(ops node:$ptr), (i8 (atomic_load_8 node:$ptr))>;
def atomicloadi8toi32 : PatFrag<(ops node:$ptr),
                                (i32 (atomic_load_8 node:$ptr))>;
def atomicloadi8Sexttoi32 : PatFrag<(ops node:$ptr),
                                (i32 (sext_inreg (i32 (atomic_load_8 node:$ptr)), i8))>;
def atomicloadi8Sexttoi64 : PatFrag<(ops node:$ptr),
                                (i64 (sext_inreg (i64 (anyext (i32 (atomic_load_8 node:$ptr)))), i8))>;
def atomicloadi16 : PatFrag<(ops node:$ptr), (i16 (atomic_load_16 node:$ptr))>;
def atomicloadi16toi32 : PatFrag<(ops node:$ptr),
                                 (i32 (atomic_load_16 node:$ptr))>;
def atomicloadi16Sexttoi32 : PatFrag<(ops node:$ptr),
                                (i32 (sext_inreg (i32 (atomic_load_16 node:$ptr)), i16))>;
def atomicloadi16Sexttoi64 : PatFrag<(ops node:$ptr),
                                (i64 (sext_inreg (i64 (anyext (i32(atomic_load_16 node:$ptr)))), i16))>;
def atomicloadi32 : PatFrag<(ops node:$ptr), (i32 (atomic_load_32 node:$ptr))>;
def atomicloadi64 : PatFrag<(ops node:$ptr), (i64 (atomic_load_64 node:$ptr))>;

defm : SimpleLoadPat<atomicloadi8, i8, LBZp, LBZri10, LBZri37, LBZri64, LBZrr>;
defm : SimpleLoadPat<atomicloadi8toi32, i32, LBZp, LBZri10, LBZri37, LBZri64, LBZrr>;
defm : SimpleLoadPat<atomicloadi8Sexttoi32, i32, LBSp, LBSri10, LBSri37, LBSri64, LBSrr>;
defm : SimpleLoadPat<atomicloadi8Sexttoi64, i64, LBSp, LBSri10, LBSri37, LBSri64, LBSrr>;
defm : LoadPat<atomicloadi16, i16, 1, LHZp, LHZri10, LHZri37, LHZri64, LHZrr>;
defm : LoadPat<atomicloadi16toi32, i32, 1, LHZp, LHZri10, LHZri37, LHZri64, LHZrr>;
defm : LoadPat<atomicloadi16Sexttoi32, i32, 1, LHSp, LHSri10, LHSri37, LHSri64, LHSrr>;
defm : LoadPat<atomicloadi16Sexttoi64, i64, 1, LHSp, LHSri10, LHSri37, LHSri64, LHSrr>;
defm : LoadPat<atomicloadi32, i32, 2, LWZp, LWZri10, LWZri37, LWZri64, LWZrr>;
defm : LoadPat<atomicloadi64, i64, 3, LDp, LDri10, LDri37, LDri64, LDrr>;

defm : StorePat<atomic_store_8,  i32, SingleReg, 0, SBp, SBri10,  SBri37,  SBri64, SBrr>;
defm : StorePat<atomic_store_16, i32, SingleReg, 1, SHp, SHri10,  SHri37,  SHri64, SHrr>;
defm : StorePat<atomic_store_32, i32, SingleReg, 2, SWp, SWri10,  SWri37,  SWri64, SWrr>;
defm : StorePat<atomic_store_64, i64, SingleReg, 3, SDp, SDri10,  SDri37,  SDri64, SDrr>;


// ATOMIC RMW
let Constraints = "@earlyclobber $pr", mayLoad = 1, mayStore = 1 in {
  def ALOADADDp  : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$pr), (ins AddrRR:$addr, SingleReg:$op), []>;
  def ALOADSUBp  : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$pr), (ins AddrRR:$addr, SingleReg:$op), []>;
  def ALOADANDp  : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$pr), (ins AddrRR:$addr, SingleReg:$op), []>;
  def ALOADNANDp : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$pr), (ins AddrRR:$addr, SingleReg:$op), []>;
  def ALOADORp   : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$pr), (ins AddrRR:$addr, SingleReg:$op), []>;
  def ALOADXORp  : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$pr), (ins AddrRR:$addr, SingleReg:$op), []>;
  def ALOADMINp  : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$pr), (ins AddrRR:$addr, SingleReg:$op), []>;
  def ALOADMAXp  : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$pr), (ins AddrRR:$addr, SingleReg:$op), []>;
  def ALOADUMINp : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$pr), (ins AddrRR:$addr, SingleReg:$op), []>;
  def ALOADUMAXp : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$pr), (ins AddrRR:$addr, SingleReg:$op), []>;
}

// ATOMIC_CMP_SWAP
let Constraints = "@earlyclobber $res,@earlyclobber $pr", mayLoad = 1, mayStore = 1 in
def ACMPSWAPp  : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$pr),
                            (ins AddrRR:$addr, SingleReg:$op1, SingleReg:$op2), []>;
let Constraints = "@earlyclobber $res,@earlyclobber $pr,@earlyclobber $sr1,@earlyclobber $sr2,@earlyclobber $sr3", mayLoad = 1, mayStore = 1 in
def ATASp : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$pr, SingleReg:$sr1, SingleReg:$sr2, SingleReg:$sr3),
                       (ins AddrRR:$addr, SingleReg:$op), []>;

// ATOMIC_SWAP
let Constraints = "@earlyclobber $pr", mayLoad = 1, mayStore = 1 in
def ASWAPp     : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$pr), (ins AddrRR:$addr, SingleReg:$op), []>;

def : Pat<(atomic_load_add_32 AddrRR:$addr, i32:$val), (ALOADADDp AddrRR:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_add_64 AddrRR:$addr, i64:$val), (ALOADADDp AddrRR:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_sub_32 AddrRR:$addr, i32:$val), (ALOADSUBp AddrRR:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_sub_64 AddrRR:$addr, i64:$val), (ALOADSUBp AddrRR:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_and_32 AddrRR:$addr, i32:$val), (ALOADANDp AddrRR:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_and_64 AddrRR:$addr, i64:$val), (ALOADANDp AddrRR:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_nand_32 AddrRR:$addr, i32:$val), (ALOADNANDp AddrRR:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_nand_64 AddrRR:$addr, i64:$val), (ALOADNANDp AddrRR:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_or_32 AddrRR:$addr, i32:$val), (ALOADORp AddrRR:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_or_64 AddrRR:$addr, i64:$val), (ALOADORp AddrRR:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_xor_32 AddrRR:$addr, i32:$val), (ALOADXORp AddrRR:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_xor_64 AddrRR:$addr, i64:$val), (ALOADXORp AddrRR:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_min_32 AddrRR:$addr, i32:$val), (ALOADMINp AddrRR:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_min_64 AddrRR:$addr, i64:$val), (ALOADMINp AddrRR:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_max_32 AddrRR:$addr, i32:$val), (ALOADMAXp AddrRR:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_max_64 AddrRR:$addr, i64:$val), (ALOADMAXp AddrRR:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_umin_32 AddrRR:$addr, i32:$val), (ALOADUMINp AddrRR:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_umin_64 AddrRR:$addr, i64:$val), (ALOADUMINp AddrRR:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_umax_32 AddrRR:$addr, i32:$val), (ALOADUMAXp AddrRR:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_umax_64 AddrRR:$addr, i64:$val), (ALOADUMAXp AddrRR:$addr, SingleReg:$val)>;

def : Pat<(atomic_cmp_swap_32 AddrRR:$addr, i32:$cmp, i32:$swap), (ACMPSWAPp AddrRR:$addr, SingleReg:$cmp, SingleReg:$swap)>;
def : Pat<(atomic_cmp_swap_64 AddrRR:$addr, i64:$cmp, i64:$swap), (ACMPSWAPp AddrRR:$addr, SingleReg:$cmp, SingleReg:$swap)>;

def : Pat<(atomic_swap_8 AddrRR:$addr, i32:$swap), (ATASp AddrRR:$addr, SingleReg:$swap)>;
def : Pat<(atomic_swap_32 AddrRR:$addr, i32:$swap), (ASWAPp AddrRR:$addr, SingleReg:$swap)>;
def : Pat<(atomic_swap_64 AddrRR:$addr, i64:$swap), (ASWAPp AddrRR:$addr, SingleReg:$swap)>;
