def GET_Instr : K1C_PseudoInstr<(outs SingleReg:$dst), (ins Signed37_32:$param),[]>;
def WFXL_Instr : K1C_PseudoInstr<(outs), (ins Signed37_32:$sysreg, SingleReg:$val),[]>;
def SBMM8ri_Instr : K1C_PseudoInstr<(outs SingleReg: $dst), (ins SingleReg:$r, Wrapped64:$r2), []>;
def SBMM8rr_Instr : K1C_PseudoInstr<(outs SingleReg: $dst), (ins SingleReg:$r, SingleReg:$r2), []>;

def: Pat<(int_k1c_get Signed37_32:$r), (GET_Instr Signed37_32:$r)>;
def: Pat<(int_k1c_wfxl Signed37_32:$r, i64:$val), (WFXL_Instr Signed37_32:$r, SingleReg:$val)>;
def: Pat<(int_k1c_sbmm8 SingleReg:$r, imm:$r2), (SBMM8ri_Instr SingleReg:$r, Wrapped64:$r2)>;
def: Pat<(int_k1c_sbmm8 SingleReg:$r, SingleReg:$r2), (SBMM8rr_Instr SingleReg:$r, SingleReg:$r2)>;

def FABSWQ_Instr : K1C_PseudoInstr<(outs PairedReg: $dst), (ins PairedReg:$r), []>;
def FABSDP_Instr : K1C_PseudoInstr<(outs PairedReg: $dst), (ins PairedReg:$r), []>;

def FNEGWQ_Instr : K1C_PseudoInstr<(outs PairedReg: $dst), (ins PairedReg:$r), []>;
def FNEGDP_Instr : K1C_PseudoInstr<(outs PairedReg: $dst), (ins PairedReg:$r), []>;

def FMAXWQ_Instr : K1C_PseudoInstr<(outs PairedReg: $dst), (ins PairedReg:$v1, PairedReg:$v2), []>;
def FMAXDP_Instr : K1C_PseudoInstr<(outs PairedReg: $dst), (ins PairedReg:$v1, PairedReg:$v2), []>;

def FMINWQ_Instr : K1C_PseudoInstr<(outs PairedReg: $dst), (ins PairedReg:$v1, PairedReg:$v2), []>;
def FMINDP_Instr : K1C_PseudoInstr<(outs PairedReg: $dst), (ins PairedReg:$v1, PairedReg:$v2), []>;

def: Pat<(int_k1c_fabswp v2f32:$r), (FABSWP SingleReg:$r)>;
def: Pat<(int_k1c_fabswq v4f32:$r), (FABSWQ_Instr PairedReg:$r)>;
def: Pat<(int_k1c_fabsdp v2f64:$r), (FABSDP_Instr PairedReg:$r)>;

def: Pat<(int_k1c_fnegwp v2f32:$r), (FNEGWP SingleReg:$r)>;
def: Pat<(int_k1c_fnegwq v4f32:$r), (FNEGWQ_Instr PairedReg:$r)>;
def: Pat<(int_k1c_fnegdp v2f64:$r), (FNEGDP_Instr PairedReg:$r)>;

def: Pat<(int_k1c_fmaxwp v2f32:$v1, v2f32:$v2), (FMAXWP SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_k1c_fmaxwq v4f32:$v1, v4f32:$v2), (FMAXWQ_Instr PairedReg:$v1, PairedReg:$v2)>;
def: Pat<(int_k1c_fmaxdp v2f64:$v1, v2f64:$v2), (FMAXDP_Instr PairedReg:$v1, PairedReg:$v2)>;

def: Pat<(int_k1c_fminwp v2f32:$v1, v2f32:$v2), (FMINWP SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_k1c_fminwq v4f32:$v1, v4f32:$v2), (FMINWQ_Instr PairedReg:$v1, PairedReg:$v2)>;
def: Pat<(int_k1c_fmindp v2f64:$v1, v2f64:$v2), (FMINDP_Instr PairedReg:$v1, PairedReg:$v2)>;
