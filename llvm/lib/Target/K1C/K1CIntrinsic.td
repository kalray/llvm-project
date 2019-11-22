def GET_Instr : K1C_PseudoInstr<(outs SingleReg:$dst), (ins Signed37_32:$param),[]>;
def WFXL_Instr : K1C_PseudoInstr<(outs), (ins Signed37_32:$sysreg, SingleReg:$val),[]>;
def SBMM8ri_Instr : K1C_PseudoInstr<(outs SingleReg: $dst), (ins SingleReg:$r, Wrapped64:$r2), []>;
def SBMM8rr_Instr : K1C_PseudoInstr<(outs SingleReg: $dst), (ins SingleReg:$r, SingleReg:$r2), []>;

def: Pat<(int_k1c_get Signed37_32:$r), (GET_Instr Signed37_32:$r)>;
def: Pat<(int_k1c_wfxl Signed37_32:$r, i64:$val), (WFXL_Instr Signed37_32:$r, SingleReg:$val)>;
def: Pat<(int_k1c_sbmm8 SingleReg:$r, imm:$r2), (SBMM8ri_Instr SingleReg:$r, Wrapped64:$r2)>;
def: Pat<(int_k1c_sbmm8 SingleReg:$r, SingleReg:$r2), (SBMM8rr_Instr SingleReg:$r, SingleReg:$r2)>;
