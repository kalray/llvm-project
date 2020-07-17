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
def atomicloadi16 : PatFrag<(ops node:$ptr), (i16 (atomic_load_16 node:$ptr))>;
def atomicloadi16toi32 : PatFrag<(ops node:$ptr),
                                 (i32 (atomic_load_16 node:$ptr))>;
def atomicloadi32 : PatFrag<(ops node:$ptr), (i32 (atomic_load_32 node:$ptr))>;
def atomicloadi64 : PatFrag<(ops node:$ptr), (i64 (atomic_load_64 node:$ptr))>;

defm : SimpleLoadPat<atomicloadi8, i8, LBZp, LBZri10, LBZrr, variant_u>;
defm : SimpleLoadPat<atomicloadi8toi32, i32, LBZp, LBZri10, LBZrr, variant_u>;
defm : LoadPat<atomicloadi16, i16, 1, LHZp, LHZri10, LHZrr, variant_u>;
defm : LoadPat<atomicloadi16toi32, i32, 1, LHZp, LHZri10, LHZrr, variant_u>;
defm : LoadPat<atomicloadi32, i32, 2, LWZp, LWZri10, LWZrr, variant_u>;
defm : LoadPat<atomicloadi64, i64, 3, LDp, LDri10, LDrr, variant_u>;

def atomicstore8 : PatFrag<(ops node:$val, node:$ptr),
                           (atomic_store_8 node:$ptr, node:$val)>;
def atomicstore16 : PatFrag<(ops node:$val, node:$ptr),
                            (atomic_store_16 node:$ptr, node:$val)>;
def atomicstore32 : PatFrag<(ops node:$val, node:$ptr),
                            (atomic_store_32 node:$ptr, node:$val)>;
def atomicstore64 : PatFrag<(ops node:$val, node:$ptr),
                            (atomic_store_64 node:$ptr, node:$val)>;

defm : SimpleStorePat<atomicstore8, i32, SingleReg, SBp, SBri10, SBrr>;
defm : StorePat<atomicstore16, i32, SingleReg, 1, SHp, SHri10, SHrr>;
defm : StorePat<atomicstore32, i32, SingleReg, 2, SWp, SWri10, SWrr>;
defm : StorePat<atomicstore64, i64, SingleReg, 3, SDp, SDri10, SDrr>;


// ATOMIC RMW
let Constraints = "@earlyclobber $pr" in {
  def ALOADADDp  : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$pr), (ins AddrRI:$addr, SingleReg:$op), []>;
  def ALOADSUBp  : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$pr), (ins AddrRI:$addr, SingleReg:$op), []>;
  def ALOADANDp  : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$pr), (ins AddrRI:$addr, SingleReg:$op), []>;
  def ALOADNANDp : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$pr), (ins AddrRI:$addr, SingleReg:$op), []>;
  def ALOADORp   : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$pr), (ins AddrRI:$addr, SingleReg:$op), []>;
  def ALOADXORp  : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$pr), (ins AddrRI:$addr, SingleReg:$op), []>;
  def ALOADMINp  : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$pr), (ins AddrRI:$addr, SingleReg:$op), []>;
  def ALOADMAXp  : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$pr), (ins AddrRI:$addr, SingleReg:$op), []>;
  def ALOADUMINp : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$pr), (ins AddrRI:$addr, SingleReg:$op), []>;
  def ALOADUMAXp : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$pr), (ins AddrRI:$addr, SingleReg:$op), []>;
}

// ATOMIC_CMP_SWAP
let Constraints = "@earlyclobber $res,@earlyclobber $pr" in
def ACMPSWAPp  : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$pr),
                            (ins AddrRI:$addr, SingleReg:$op1, SingleReg:$op2), []>;
let Constraints = "@earlyclobber $res,@earlyclobber $pr,@earlyclobber $sr1,@earlyclobber $sr2,@earlyclobber $sr3" in
def ATASp : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$pr, SingleReg:$sr1, SingleReg:$sr2, SingleReg:$sr3),
                       (ins AddrRI:$addr, SingleReg:$op), []>;

// ATOMIC_SWAP
let Constraints = "@earlyclobber $pr" in
def ASWAPp     : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$pr), (ins AddrRI:$addr, SingleReg:$op), []>;

def : Pat<(atomic_load_add_32 AddrRI:$addr, i32:$val), (ALOADADDp AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_add_64 AddrRI:$addr, i64:$val), (ALOADADDp AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_sub_32 AddrRI:$addr, i32:$val), (ALOADSUBp AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_sub_64 AddrRI:$addr, i64:$val), (ALOADSUBp AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_and_32 AddrRI:$addr, i32:$val), (ALOADANDp AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_and_64 AddrRI:$addr, i64:$val), (ALOADANDp AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_nand_32 AddrRI:$addr, i32:$val), (ALOADNANDp AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_nand_64 AddrRI:$addr, i64:$val), (ALOADNANDp AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_or_32 AddrRI:$addr, i32:$val), (ALOADORp AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_or_64 AddrRI:$addr, i64:$val), (ALOADORp AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_xor_32 AddrRI:$addr, i32:$val), (ALOADXORp AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_xor_64 AddrRI:$addr, i64:$val), (ALOADXORp AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_min_32 AddrRI:$addr, i32:$val), (ALOADMINp AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_min_64 AddrRI:$addr, i64:$val), (ALOADMINp AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_max_32 AddrRI:$addr, i32:$val), (ALOADMAXp AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_max_64 AddrRI:$addr, i64:$val), (ALOADMAXp AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_umin_32 AddrRI:$addr, i32:$val), (ALOADUMINp AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_umin_64 AddrRI:$addr, i64:$val), (ALOADUMINp AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_umax_32 AddrRI:$addr, i32:$val), (ALOADUMAXp AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_umax_64 AddrRI:$addr, i64:$val), (ALOADUMAXp AddrRI:$addr, SingleReg:$val)>;

def : Pat<(atomic_cmp_swap_32 AddrRI:$addr, i32:$cmp, i32:$swap), (ACMPSWAPp AddrRI:$addr, SingleReg:$cmp, SingleReg:$swap)>;
def : Pat<(atomic_cmp_swap_64 AddrRI:$addr, i64:$cmp, i64:$swap), (ACMPSWAPp AddrRI:$addr, SingleReg:$cmp, SingleReg:$swap)>;

def : Pat<(atomic_swap_8 AddrRI:$addr, i32:$swap), (ATASp AddrRI:$addr, SingleReg:$swap)>;
def : Pat<(atomic_swap_32 AddrRI:$addr, i32:$swap), (ASWAPp AddrRI:$addr, SingleReg:$swap)>;
def : Pat<(atomic_swap_64 AddrRI:$addr, i64:$swap), (ASWAPp AddrRI:$addr, SingleReg:$swap)>;
