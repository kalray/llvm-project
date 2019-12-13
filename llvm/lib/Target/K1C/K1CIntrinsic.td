def: Pat<(int_k1c_dinval), (DINVAL)>;
def: Pat<(int_k1c_fence), (FENCE)>;

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

def: Pat<(int_k1c_faddwp v2f32:$v1, v2f32:$v2, i32:$mod), (FADDWPd3 SingleReg:$v1, SingleReg:$v2, RoundingMod:$mod, 0)>;
def: Pat<(int_k1c_faddcwc v2f32:$v1, v2f32:$v2, i32:$mod), (FADDCWCd3 SingleReg:$v1, SingleReg:$v2, RoundingMod:$mod, 0)>;
def: Pat<(int_k1c_faddwq v4f32:$v1, v4f32:$v2, i32:$mod), (FADDWQ PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod, 0)>;
def: Pat<(int_k1c_faddcwcp v4f32:$v1, v4f32:$v2, i32:$mod), (FADDCWCP PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod, 0)>;
def: Pat<(int_k1c_fadddp v2f64:$v1, v2f64:$v2, i32:$mod), (FADDDP PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod, 0)>;
def: Pat<(int_k1c_faddcdc v2f64:$v1, v2f64:$v2, i32:$mod), (FADDCDC PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod, 0)>;

def: Pat<(int_k1c_fsbfwp v2f32:$v1, v2f32:$v2, i32:$mod), (FSBFWPd3 SingleReg:$v1, SingleReg:$v2, RoundingMod:$mod, 0)>;
def: Pat<(int_k1c_fsbfcwc v2f32:$v1, v2f32:$v2, i32:$mod), (FSBFCWCd3 SingleReg:$v1, SingleReg:$v2, RoundingMod:$mod, 0)>;
def: Pat<(int_k1c_fsbfwq v4f32:$v1, v4f32:$v2, i32:$mod), (FSBFWQ PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod, 0)>;
def: Pat<(int_k1c_fsbfcwcp v4f32:$v1, v4f32:$v2, i32:$mod), (FSBFCWCP PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod, 0)>;
def: Pat<(int_k1c_fsbfdp v2f64:$v1, v2f64:$v2, i32:$mod), (FSBFDP PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod, 0)>;
def: Pat<(int_k1c_fsbfcdc v2f64:$v1, v2f64:$v2, i32:$mod), (FSBFCDC PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod, 0)>;

def FMULWCP_Instr : K1C_PseudoInstr<(outs PairedReg: $dst), (ins PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod), []>;
def FMULCWCP_Instr : K1C_PseudoInstr<(outs PairedReg: $dst), (ins PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod), []>;
def FMULDP_Instr : K1C_PseudoInstr<(outs PairedReg: $dst), (ins PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod), []>;
let Constraints = "@earlyclobber $dst" in
def FMULDC_Instr : K1C_PseudoInstr<(outs PairedReg: $dst), (ins PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod), []>;
let Constraints = "@earlyclobber $dst,@earlyclobber $scratch" in
def FMULCDC_Instr : K1C_PseudoInstr<(outs PairedReg: $dst, SingleReg: $scratch), (ins PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod), []>;

def: Pat<(int_k1c_fmulwp v2f32:$v1, v2f32:$v2, i32:$mod), (FMULWPd3 SingleReg:$v1, SingleReg:$v2, RoundingMod:$mod, 0)>;
def: Pat<(int_k1c_fmulwc v2f32:$v1, v2f32:$v2, i32:$mod), (FMULWCd3 SingleReg:$v1, SingleReg:$v2, RoundingMod:$mod, 0)>;
def: Pat<(int_k1c_fmulcwc v2f32:$v1, v2f32:$v2, i32:$mod), (FMULCWCd3 SingleReg:$v1, SingleReg:$v2, RoundingMod:$mod, 0)>;
def: Pat<(int_k1c_fmulwq v4f32:$v1, v4f32:$v2, i32:$mod), (FMULWQ PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod, 0)>;
def: Pat<(int_k1c_fmulwcp v4f32:$v1, v4f32:$v2, i32:$mod), (FMULWCP_Instr PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod)>;
def: Pat<(int_k1c_fmulcwcp v4f32:$v1, v4f32:$v2, i32:$mod), (FMULCWCP_Instr PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod)>;
def: Pat<(int_k1c_fmuldp v2f64:$v1, v2f64:$v2, i32:$mod), (FMULDP_Instr PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod)>;
def: Pat<(int_k1c_fmuldc v2f64:$v1, v2f64:$v2, i32:$mod), (FMULDC_Instr PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod)>;
def: Pat<(int_k1c_fmulcdc v2f64:$v1, v2f64:$v2, i32:$mod), (FMULCDC_Instr PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod)>;

let Constraints = "$dst = $v3" in
def FFMAWP_Instr : K1C_PseudoInstr<(outs SingleReg: $dst), (ins SingleReg:$v1, SingleReg:$v2, SingleReg:$v3, RoundingMod:$mod), []>;
let Constraints = "$dst = $v3" in
def FFMAWQ_Instr : K1C_PseudoInstr<(outs PairedReg: $dst), (ins PairedReg:$v1, PairedReg:$v2, PairedReg:$v3, RoundingMod:$mod), []>;
let Constraints = "$dst = $v3" in
def FFMADP_Instr : K1C_PseudoInstr<(outs PairedReg: $dst), (ins PairedReg:$v1, PairedReg:$v2, PairedReg:$v3, RoundingMod:$mod), []>;
let Constraints = "$dst = $v3" in
def FMM2AWQ_Instr : K1C_PseudoInstr<(outs PairedReg: $dst), (ins SingleReg:$v1, SingleReg:$v2, PairedReg:$v3, RoundingMod:$mod), []>;
let Constraints = "$dst = $v3" in
def FFMSWP_Instr : K1C_PseudoInstr<(outs SingleReg: $dst), (ins SingleReg:$v1, SingleReg:$v2, SingleReg:$v3, RoundingMod:$mod), []>;
let Constraints = "$dst = $v3" in
def FFMSWQ_Instr : K1C_PseudoInstr<(outs PairedReg: $dst), (ins PairedReg:$v1, PairedReg:$v2, PairedReg:$v3, RoundingMod:$mod), []>;
let Constraints = "$dst = $v3" in
def FFMSDP_Instr : K1C_PseudoInstr<(outs PairedReg: $dst), (ins PairedReg:$v1, PairedReg:$v2, PairedReg:$v3, RoundingMod:$mod), []>;
let Constraints = "$dst = $v3" in
def FMM2SWQ_Instr : K1C_PseudoInstr<(outs PairedReg: $dst), (ins SingleReg:$v1, SingleReg:$v2, PairedReg:$v3, RoundingMod:$mod), []>;

def: Pat<(int_k1c_fmm2wq v2f32:$v1, v2f32:$v2, i32:$mod), (FMM2WQ SingleReg:$v1, SingleReg:$v2, RoundingMod:$mod, 0)>;
def: Pat<(int_k1c_ffmawp v2f32:$v1, v2f32:$v2, v2f32:$v3, i32:$mod), (FFMAWP_Instr SingleReg:$v1, SingleReg:$v2, SingleReg:$v3, RoundingMod:$mod)>;
def: Pat<(int_k1c_ffmawq v4f32:$v1, v4f32:$v2, v4f32:$v3, i32:$mod), (FFMAWQ_Instr PairedReg:$v1, PairedReg:$v2, PairedReg:$v3, RoundingMod:$mod)>;
def: Pat<(int_k1c_ffmadp v2f64:$v1, v2f64:$v2, v2f64:$v3, i32:$mod), (FFMADP_Instr PairedReg:$v1, PairedReg:$v2, PairedReg:$v3, RoundingMod:$mod)>;
def: Pat<(int_k1c_fmm2awq v2f32:$v1, v2f32:$v2, v4f32:$v3, i32:$mod), (FMM2AWQ_Instr SingleReg:$v1, SingleReg:$v2, PairedReg:$v3, RoundingMod:$mod)>;
def: Pat<(int_k1c_ffmswp v2f32:$v1, v2f32:$v2, v2f32:$v3, i32:$mod), (FFMSWP_Instr SingleReg:$v1, SingleReg:$v2, SingleReg:$v3, RoundingMod:$mod)>;
def: Pat<(int_k1c_ffmswq v4f32:$v1, v4f32:$v2, v4f32:$v3, i32:$mod), (FFMSWQ_Instr PairedReg:$v1, PairedReg:$v2, PairedReg:$v3, RoundingMod:$mod)>;
def: Pat<(int_k1c_ffmsdp v2f64:$v1, v2f64:$v2, v2f64:$v3, i32:$mod), (FFMSDP_Instr PairedReg:$v1, PairedReg:$v2, PairedReg:$v3, RoundingMod:$mod)>;
def: Pat<(int_k1c_fmm2swq v2f32:$v1, v2f32:$v2, v4f32:$v3, i32:$mod), (FMM2SWQ_Instr SingleReg:$v1, SingleReg:$v2, PairedReg:$v3, RoundingMod:$mod)>;
