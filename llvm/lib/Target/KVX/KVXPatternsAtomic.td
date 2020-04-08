def FENCE_Instr : KVX_PSEUDO<(outs), (ins Wrapped64:$a, Wrapped64:$b), []>;

let isIndirectBranch = 1 in
{
def ASWAP8_Instr : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$scratch, SingleReg:$sbase, SingleReg:$sval, SingleReg:$scount), (ins AddrRI:$ptr, SingleReg:$val), []>;
def ASWAP32_Instr : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$scratch), (ins AddrRI:$ptr, SingleReg:$val), []>;
def ASWAP64_Instr : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$scratch), (ins AddrRI:$ptr, SingleReg:$val), []>;
}

def : Pat<(atomic_fence i64:$a, i64:$b), (FENCE_Instr Wrapped64:$a, Wrapped64:$b)>;

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

def : Pat<(atomic_swap_8 AddrRI:$addr, i32:$val), (ASWAP8_Instr AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_swap_32 AddrRI:$addr, i32:$val), (ASWAP32_Instr AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_swap_64 AddrRI:$addr, i64:$val), (ASWAP64_Instr AddrRI:$addr, SingleReg:$val)>;

let isIndirectBranch = 1 in
{
def ALOADADD32_Instr : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$scratch), (ins AddrRI:$ptr, SingleReg:$val), []>;
def ALOADADD64_Instr : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$scratch), (ins AddrRI:$ptr, SingleReg:$val), []>;
def ALOADSUB32_Instr : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$scratch), (ins AddrRI:$ptr, SingleReg:$val), []>;
def ALOADSUB64_Instr : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$scratch), (ins AddrRI:$ptr, SingleReg:$val), []>;
def ALOADAND32_Instr : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$scratch), (ins AddrRI:$ptr, SingleReg:$val), []>;
def ALOADAND64_Instr : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$scratch), (ins AddrRI:$ptr, SingleReg:$val), []>;
def ALOADXOR32_Instr : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$scratch), (ins AddrRI:$ptr, SingleReg:$val), []>;
def ALOADXOR64_Instr : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$scratch), (ins AddrRI:$ptr, SingleReg:$val), []>;
def ALOADOR32_Instr : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$scratch), (ins AddrRI:$ptr, SingleReg:$val), []>;
def ALOADOR64_Instr : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$scratch), (ins AddrRI:$ptr, SingleReg:$val), []>;
def ALOADNAND32_Instr : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$scratch), (ins AddrRI:$ptr, SingleReg:$val), []>;
def ALOADNAND64_Instr : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$scratch), (ins AddrRI:$ptr, SingleReg:$val), []>;
}


def : Pat<(atomic_load_add_32 AddrRI:$addr, i32:$val), (ALOADADD32_Instr AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_add_64 AddrRI:$addr, i64:$val), (ALOADADD64_Instr AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_sub_32 AddrRI:$addr, i32:$val), (ALOADSUB32_Instr AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_sub_64 AddrRI:$addr, i64:$val), (ALOADSUB64_Instr AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_and_32 AddrRI:$addr, i32:$val), (ALOADAND32_Instr AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_and_64 AddrRI:$addr, i64:$val), (ALOADAND64_Instr AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_xor_32 AddrRI:$addr, i32:$val), (ALOADXOR32_Instr AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_xor_64 AddrRI:$addr, i64:$val), (ALOADXOR64_Instr AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_or_32 AddrRI:$addr, i32:$val), (ALOADOR32_Instr AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_or_64 AddrRI:$addr, i64:$val), (ALOADOR64_Instr AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_nand_32 AddrRI:$addr, i32:$val), (ALOADNAND32_Instr AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_load_nand_64 AddrRI:$addr, i64:$val), (ALOADNAND64_Instr AddrRI:$addr, SingleReg:$val)>;


def ACMPSWAP32_Instr : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$scratch), (ins AddrRI:$a, SingleReg:$b, SingleReg:$c), []>;
def ACMPSWAP64_Instr : KVX_PSEUDO<(outs SingleReg:$res, PairedReg:$scratch), (ins AddrRI:$a, SingleReg:$b, SingleReg:$c), []>;
def : Pat<(atomic_cmp_swap_32 AddrRI:$a, i32:$b, i32:$c), (ACMPSWAP32_Instr AddrRI:$a, SingleReg:$b, SingleReg:$c)>;
def : Pat<(atomic_cmp_swap_64 AddrRI:$a, i64:$b, i64:$c), (ACMPSWAP64_Instr AddrRI:$a, SingleReg:$b, SingleReg:$c)>;
