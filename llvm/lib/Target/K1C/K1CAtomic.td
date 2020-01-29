def FENCE_Instr : K1C_PseudoInstr<(outs),(ins Signed37:$a, Signed37:$b), []>;

let isIndirectBranch = 1 in
{
def ASWAP8_Instr : K1C_PseudoInstr<(outs SingleReg:$res, PairedReg:$scratch, SingleReg:$sbase, SingleReg:$sval, SingleReg:$scount), (ins AddrRI:$ptr, SingleReg:$val), []>;
def ASWAP32_Instr : K1C_PseudoInstr<(outs SingleReg:$res, PairedReg:$scratch), (ins AddrRI:$ptr, SingleReg:$val), []>;
def ASWAP64_Instr : K1C_PseudoInstr<(outs SingleReg:$res, PairedReg:$scratch), (ins AddrRI:$ptr, SingleReg:$val), []>;
}

def : Pat<(atomic_fence imm:$a,imm:$b), (FENCE_Instr Signed37:$a, Signed37:$b)>;

def atomicloadi8 : PatFrag<(ops node:$ptr), (i8 (atomic_load_8 node:$ptr))>;
def atomicloadi16 : PatFrag<(ops node:$ptr), (i16 (atomic_load_16 node:$ptr))>;
def atomicloadi32 : PatFrag<(ops node:$ptr), (i32 (atomic_load_32 node:$ptr))>;
def atomicloadi64 : PatFrag<(ops node:$ptr), (i64 (atomic_load_64 node:$ptr))>;

def : Pat<(atomicloadi8 AddrRI:$addr), (LBZri AddrRI:$addr, (i8 2 /*uncached*/))>;
def : Pat<(atomicloadi16 AddrRI:$addr), (LHZri AddrRI:$addr, (i8 2 /*uncached*/))>;
def : Pat<(atomicloadi32 AddrRI:$addr), (LWZri AddrRI:$addr, (i8 2 /*uncached*/))>;
def : Pat<(atomicloadi64 AddrRI:$addr), (LDri AddrRI:$addr, (i8 2 /*uncached*/))>;

def : Pat<(atomic_store_8 AddrRI:$addr, i32:$val), (SBri AddrRI:$addr,SingleReg:$val)>;
def : Pat<(atomic_store_16 AddrRI:$addr, i32:$val), (SHri AddrRI:$addr,SingleReg:$val)>;
def : Pat<(atomic_store_32 AddrRI:$addr, i32:$val), (SWri AddrRI:$addr,SingleReg:$val)>;
def : Pat<(atomic_store_64 AddrRI:$addr, i64:$val), (SDri AddrRI:$addr,SingleReg:$val)>;

def : Pat<(atomic_swap_8 AddrRI:$addr, i32:$val), (ASWAP8_Instr AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_swap_32 AddrRI:$addr, i32:$val), (ASWAP32_Instr AddrRI:$addr, SingleReg:$val)>;
def : Pat<(atomic_swap_64 AddrRI:$addr, i64:$val), (ASWAP64_Instr AddrRI:$addr, SingleReg:$val)>;

def ALOADADD32_Instr : K1C_PseudoInstr<(outs SingleReg:$res), (ins AddrRI:$ptr, SingleReg:$val), []>;
def ALOADADD64_Instr : K1C_PseudoInstr<(outs SingleReg:$res), (ins AddrRI:$ptr, SingleReg:$val), []>;

let isIndirectBranch = 1 in
{
def ALOADSUB32_Instr : K1C_PseudoInstr<(outs SingleReg:$res, PairedReg:$scratch), (ins AddrRI:$ptr, SingleReg:$val), []>;
def ALOADSUB64_Instr : K1C_PseudoInstr<(outs SingleReg:$res, PairedReg:$scratch), (ins AddrRI:$ptr, SingleReg:$val), []>;
def ALOADAND32_Instr : K1C_PseudoInstr<(outs SingleReg:$res, PairedReg:$scratch), (ins AddrRI:$ptr, SingleReg:$val), []>;
def ALOADAND64_Instr : K1C_PseudoInstr<(outs SingleReg:$res, PairedReg:$scratch), (ins AddrRI:$ptr, SingleReg:$val), []>;
def ALOADXOR32_Instr : K1C_PseudoInstr<(outs SingleReg:$res, PairedReg:$scratch), (ins AddrRI:$ptr, SingleReg:$val), []>;
def ALOADXOR64_Instr : K1C_PseudoInstr<(outs SingleReg:$res, PairedReg:$scratch), (ins AddrRI:$ptr, SingleReg:$val), []>;
def ALOADOR32_Instr : K1C_PseudoInstr<(outs SingleReg:$res, PairedReg:$scratch), (ins AddrRI:$ptr, SingleReg:$val), []>;
def ALOADOR64_Instr : K1C_PseudoInstr<(outs SingleReg:$res, PairedReg:$scratch), (ins AddrRI:$ptr, SingleReg:$val), []>;
def ALOADNAND32_Instr : K1C_PseudoInstr<(outs SingleReg:$res, PairedReg:$scratch), (ins AddrRI:$ptr, SingleReg:$val), []>;
def ALOADNAND64_Instr : K1C_PseudoInstr<(outs SingleReg:$res, PairedReg:$scratch), (ins AddrRI:$ptr, SingleReg:$val), []>;
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


def ACMPSWAP32_Instr : K1C_PseudoInstr<(outs SingleReg:$res, PairedReg:$scratch), (ins AddrRI:$a, SingleReg:$b, SingleReg:$c), []>;
def ACMPSWAP64_Instr : K1C_PseudoInstr<(outs SingleReg:$res, PairedReg:$scratch), (ins AddrRI:$a, SingleReg:$b, SingleReg:$c), []>;
def : Pat<(atomic_cmp_swap_32 AddrRI:$a, i32:$b, i32:$c), (ACMPSWAP32_Instr AddrRI:$a, SingleReg:$b, SingleReg:$c)>;
def : Pat<(atomic_cmp_swap_64 AddrRI:$a, i64:$b, i64:$c), (ACMPSWAP64_Instr AddrRI:$a, SingleReg:$b, SingleReg:$c)>;
