def: Pat<(int_kvx_await), (AWAIT)>;
def: Pat<(int_kvx_barrier), (BARRIER)>;
def: Pat<(int_kvx_dinval), (DINVAL)>;
def: Pat<(int_kvx_errop), (ERROP)>;
def: Pat<(int_kvx_fence), (FENCE)>;
def: Pat<(int_kvx_iinval), (IINVAL)>;
def: Pat<(int_kvx_sleep), (SLEEP)>;
def: Pat<(int_kvx_stop), (STOP)>;
def: Pat<(int_kvx_tlbdinval), (TLBDINVAL)>;
def: Pat<(int_kvx_tlbiinval), (TLBIINVAL)>;
def: Pat<(int_kvx_tlbprobe), (TLBPROBE)>;
def: Pat<(int_kvx_tlbread), (TLBREAD)>;
def: Pat<(int_kvx_tlbwrite), (TLBWRITE)>;

def GET_Instr : KVX_PSEUDO<(outs SingleReg:$dst), (ins Sysnumber:$param),[]>;
def SET_Instr : KVX_PSEUDO<(outs), (ins Sysnumber:$sysreg, SingleReg:$val),[]>;
def WFXL_Instr : KVX_PSEUDO<(outs), (ins Sysnumber:$sysreg, SingleReg:$val),[]>;
def WFXM_Instr : KVX_PSEUDO<(outs), (ins Sysnumber:$sysreg, SingleReg:$val),[]>;

def: Pat<(int_kvx_get Sysnumber:$r), (GET_Instr Sysnumber:$r)>;
def: Pat<(int_kvx_wfxl Sysnumber:$r, i64:$val), (WFXL_Instr Sysnumber:$r, SingleReg:$val)>;
def: Pat<(int_kvx_wfxm Sysnumber:$r, i64:$val), (WFXM_Instr Sysnumber:$r, SingleReg:$val)>;
def: Pat<(int_kvx_set Sysnumber:$r, i64:$val), (SET_Instr Sysnumber:$r, SingleReg:$val)>;

def: Pat<(int_kvx_syncgroup SingleReg:$r), (SYNCGROUP SingleReg:$r)>;
def: Pat<(int_kvx_waitit SingleReg:$r), (WAITIT SingleReg:$r)>;

def: Pat<(int_kvx_dinvall AddrRI:$addr), (DINVALLp AddrRI:$addr)>;
def: Pat<(int_kvx_dtouchl AddrRI:$addr), (DTOUCHLp AddrRI:$addr)>;
def: Pat<(int_kvx_dzerol AddrRI:$addr), (DZEROLp AddrRI:$addr)>;
def: Pat<(int_kvx_iinvals AddrRI:$addr), (IINVALSp AddrRI:$addr)>;

def: Pat<(int_kvx_sbmm8 SingleReg:$r, Signed10:$r2), (SBMM8ri10 SingleReg:$r, Signed10:$r2)>;
def: Pat<(int_kvx_sbmm8 SingleReg:$r, Signed37:$r2), (SBMM8ri37 SingleReg:$r, Signed37:$r2)>;
def: Pat<(int_kvx_sbmm8 SingleReg:$r, Wrapped64:$r2), (SBMM8ri64 SingleReg:$r, Wrapped64:$r2)>;
def: Pat<(int_kvx_sbmm8 SingleReg:$r, SingleReg:$r2), (SBMM8rr SingleReg:$r, SingleReg:$r2)>;

def kvx_lbzu : PatFrag<(ops node:$ptr), (int_kvx_lbzu node:$ptr)>;
def kvx_lhzu : PatFrag<(ops node:$ptr), (int_kvx_lhzu node:$ptr)>;
def kvx_lwzu : PatFrag<(ops node:$ptr), (int_kvx_lwzu node:$ptr)>;
def kvx_ldu : PatFrag<(ops node:$ptr), (int_kvx_ldu node:$ptr)>;

defm : SimpleLoadPat<kvx_lbzu, i32, LBZp, LBZri10, LBZrr, variant_u>;
defm : LoadPat<kvx_lhzu, i32, 1, LHZp, LHZri10, LHZrr, variant_u>;
defm : LoadPat<kvx_lwzu, i32, 2, LWZp, LWZri10, LWZrr, variant_u>;
defm : LoadPat<kvx_ldu, i64, 3, LDp, LDri10, LDrr, variant_u>;

def: Pat<(int_kvx_acswapw i64:$addr, i32:$expect, i32:$update), (i32 (EXTRACT_SUBREG
  (v2i64 (ACSWAPWri10 (i64 0), SingleReg:$addr, (INSERT_SUBREG (INSERT_SUBREG (v2i64 (IMPLICIT_DEF)),
    SingleReg:$expect, 1), SingleReg:$update, 2))), 2))>;

def: Pat<(int_kvx_acswapd i64:$addr, i64:$expect, i64:$update), (i64 (EXTRACT_SUBREG
  (v2i64 (ACSWAPDri10 (i64 0), SingleReg:$addr, (INSERT_SUBREG (INSERT_SUBREG (v2i64 (IMPLICIT_DEF)),
    SingleReg:$expect, 1), SingleReg:$update, 2))), 2))>;

def FABSWQ_Instr : KVX_PSEUDO<(outs PairedReg: $dst), (ins PairedReg:$r), []>;
def FABSDP_Instr : KVX_PSEUDO<(outs PairedReg: $dst), (ins PairedReg:$r), []>;

def FNEGWQ_Instr : KVX_PSEUDO<(outs PairedReg: $dst), (ins PairedReg:$r), []>;
def FNEGDP_Instr : KVX_PSEUDO<(outs PairedReg: $dst), (ins PairedReg:$r), []>;

def FMAXWQ_Instr : KVX_PSEUDO<(outs PairedReg: $dst), (ins PairedReg:$v1, PairedReg:$v2), []>;
def FMAXDP_Instr : KVX_PSEUDO<(outs PairedReg: $dst), (ins PairedReg:$v1, PairedReg:$v2), []>;

def FMINWQ_Instr : KVX_PSEUDO<(outs PairedReg: $dst), (ins PairedReg:$v1, PairedReg:$v2), []>;
def FMINDP_Instr : KVX_PSEUDO<(outs PairedReg: $dst), (ins PairedReg:$v1, PairedReg:$v2), []>;

def: Pat<(int_kvx_fabswp v2f32:$r), (FABSWP SingleReg:$r)>;
def: Pat<(int_kvx_fabswq v4f32:$r), (FABSWQ_Instr PairedReg:$r)>;
def: Pat<(int_kvx_fabsdp v2f64:$r), (FABSDP_Instr PairedReg:$r)>;

def: Pat<(int_kvx_fnegwp v2f32:$r), (FNEGWP SingleReg:$r)>;
def: Pat<(int_kvx_fnegwq v4f32:$r), (FNEGWQ_Instr PairedReg:$r)>;
def: Pat<(int_kvx_fnegdp v2f64:$r), (FNEGDP_Instr PairedReg:$r)>;

def: Pat<(int_kvx_fmaxwp v2f32:$v1, v2f32:$v2), (FMAXWP SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_fmaxwq v4f32:$v1, v4f32:$v2), (FMAXWQ_Instr PairedReg:$v1, PairedReg:$v2)>;
def: Pat<(int_kvx_fmaxdp v2f64:$v1, v2f64:$v2), (FMAXDP_Instr PairedReg:$v1, PairedReg:$v2)>;

def: Pat<(int_kvx_fminwp v2f32:$v1, v2f32:$v2), (FMINWP SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_fminwq v4f32:$v1, v4f32:$v2), (FMINWQ_Instr PairedReg:$v1, PairedReg:$v2)>;
def: Pat<(int_kvx_fmindp v2f64:$v1, v2f64:$v2), (FMINDP_Instr PairedReg:$v1, PairedReg:$v2)>;

def: Pat<(int_kvx_faddwp v2f32:$v1, v2f32:$v2, i32:$mod), (FADDWPrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$mod, 0)>;
def: Pat<(int_kvx_faddcwc v2f32:$v1, v2f32:$v2, i32:$mod), (FADDCWCrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$mod, 0)>;
def: Pat<(int_kvx_faddwq v4f32:$v1, v4f32:$v2, i32:$mod), (FADDWQ PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod, 0)>;
def: Pat<(int_kvx_faddcwcp v4f32:$v1, v4f32:$v2, i32:$mod), (FADDCWCP PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod, 0)>;
def: Pat<(int_kvx_fadddp v2f64:$v1, v2f64:$v2, i32:$mod), (FADDDP PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod, 0)>;
def: Pat<(int_kvx_faddcdc v2f64:$v1, v2f64:$v2, i32:$mod), (FADDCDC PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod, 0)>;

def: Pat<(int_kvx_fsbfwp v2f32:$v1, v2f32:$v2, i32:$mod), (FSBFWPrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$mod, 0)>;
def: Pat<(int_kvx_fsbfcwc v2f32:$v1, v2f32:$v2, i32:$mod), (FSBFCWCrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$mod, 0)>;
def: Pat<(int_kvx_fsbfwq v4f32:$v1, v4f32:$v2, i32:$mod), (FSBFWQ PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod, 0)>;
def: Pat<(int_kvx_fsbfcwcp v4f32:$v1, v4f32:$v2, i32:$mod), (FSBFCWCP PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod, 0)>;
def: Pat<(int_kvx_fsbfdp v2f64:$v1, v2f64:$v2, i32:$mod), (FSBFDP PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod, 0)>;
def: Pat<(int_kvx_fsbfcdc v2f64:$v1, v2f64:$v2, i32:$mod), (FSBFCDC PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod, 0)>;

def FMULWCP_Instr : KVX_PSEUDO<(outs PairedReg: $dst), (ins PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod), []>;
def FMULCWCP_Instr : KVX_PSEUDO<(outs PairedReg: $dst), (ins PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod), []>;
def FMULDP_Instr : KVX_PSEUDO<(outs PairedReg: $dst), (ins PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod), []>;
let Constraints = "@earlyclobber $dst" in
def FMULDC_Instr : KVX_PSEUDO<(outs PairedReg: $dst), (ins PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod), []>;
let Constraints = "@earlyclobber $dst,@earlyclobber $scratch" in
def FMULCDC_Instr : KVX_PSEUDO<(outs PairedReg: $dst, SingleReg: $scratch), (ins PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod), []>;

def: Pat<(int_kvx_fmulwp v2f32:$v1, v2f32:$v2, i32:$mod), (FMULWPrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$mod, 0)>;
def: Pat<(int_kvx_fmulwc v2f32:$v1, v2f32:$v2, i32:$mod), (FMULWCrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$mod, 0)>;
def: Pat<(int_kvx_fmulcwc v2f32:$v1, v2f32:$v2, i32:$mod), (FMULCWCrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$mod, 0)>;
def: Pat<(int_kvx_fmulwq v4f32:$v1, v4f32:$v2, i32:$mod), (FMULWQ PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod, 0)>;
def: Pat<(int_kvx_fmulwcp v4f32:$v1, v4f32:$v2, i32:$mod), (FMULWCP_Instr PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod)>;
def: Pat<(int_kvx_fmulcwcp v4f32:$v1, v4f32:$v2, i32:$mod), (FMULCWCP_Instr PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod)>;
def: Pat<(int_kvx_fmuldp v2f64:$v1, v2f64:$v2, i32:$mod), (FMULDP_Instr PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod)>;
def: Pat<(int_kvx_fmuldc v2f64:$v1, v2f64:$v2, i32:$mod), (FMULDC_Instr PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod)>;
def: Pat<(int_kvx_fmulcdc v2f64:$v1, v2f64:$v2, i32:$mod), (FMULCDC_Instr PairedReg:$v1, PairedReg:$v2, RoundingMod:$mod)>;

let Constraints = "$dst = $v3" in
def FFMAWP_Instr : KVX_PSEUDO<(outs SingleReg: $dst), (ins SingleReg:$v1, SingleReg:$v2, SingleReg:$v3, RoundingMod:$mod), []>;
let Constraints = "$dst = $v3" in
def FFMAWQ_Instr : KVX_PSEUDO<(outs PairedReg: $dst), (ins PairedReg:$v1, PairedReg:$v2, PairedReg:$v3, RoundingMod:$mod), []>;
let Constraints = "$dst = $v3" in
def FFMADP_Instr : KVX_PSEUDO<(outs PairedReg: $dst), (ins PairedReg:$v1, PairedReg:$v2, PairedReg:$v3, RoundingMod:$mod), []>;
let Constraints = "$dst = $v3" in
def FMM2AWQ_Instr : KVX_PSEUDO<(outs PairedReg: $dst), (ins SingleReg:$v1, SingleReg:$v2, PairedReg:$v3, RoundingMod:$mod), []>;
let Constraints = "$dst = $v3" in
def FFMSWP_Instr : KVX_PSEUDO<(outs SingleReg: $dst), (ins SingleReg:$v1, SingleReg:$v2, SingleReg:$v3, RoundingMod:$mod), []>;
let Constraints = "$dst = $v3" in
def FFMSWQ_Instr : KVX_PSEUDO<(outs PairedReg: $dst), (ins PairedReg:$v1, PairedReg:$v2, PairedReg:$v3, RoundingMod:$mod), []>;
let Constraints = "$dst = $v3" in
def FFMSDP_Instr : KVX_PSEUDO<(outs PairedReg: $dst), (ins PairedReg:$v1, PairedReg:$v2, PairedReg:$v3, RoundingMod:$mod), []>;
let Constraints = "$dst = $v3" in
def FMM2SWQ_Instr : KVX_PSEUDO<(outs PairedReg: $dst), (ins SingleReg:$v1, SingleReg:$v2, PairedReg:$v3, RoundingMod:$mod), []>;

def: Pat<(int_kvx_fmm2wq v2f32:$v1, v2f32:$v2, i32:$mod), (FMM2WQ SingleReg:$v1, SingleReg:$v2, RoundingMod:$mod, 0)>;
def: Pat<(int_kvx_ffmawp v2f32:$v1, v2f32:$v2, v2f32:$v3, i32:$mod), (FFMAWP_Instr SingleReg:$v1, SingleReg:$v2, SingleReg:$v3, RoundingMod:$mod)>;
def: Pat<(int_kvx_ffmawq v4f32:$v1, v4f32:$v2, v4f32:$v3, i32:$mod), (FFMAWQ_Instr PairedReg:$v1, PairedReg:$v2, PairedReg:$v3, RoundingMod:$mod)>;
def: Pat<(int_kvx_ffmadp v2f64:$v1, v2f64:$v2, v2f64:$v3, i32:$mod), (FFMADP_Instr PairedReg:$v1, PairedReg:$v2, PairedReg:$v3, RoundingMod:$mod)>;
def: Pat<(int_kvx_fmm2awq v2f32:$v1, v2f32:$v2, v4f32:$v3, i32:$mod), (FMM2AWQ_Instr SingleReg:$v1, SingleReg:$v2, PairedReg:$v3, RoundingMod:$mod)>;
def: Pat<(int_kvx_ffmswp v2f32:$v1, v2f32:$v2, v2f32:$v3, i32:$mod), (FFMSWP_Instr SingleReg:$v1, SingleReg:$v2, SingleReg:$v3, RoundingMod:$mod)>;
def: Pat<(int_kvx_ffmswq v4f32:$v1, v4f32:$v2, v4f32:$v3, i32:$mod), (FFMSWQ_Instr PairedReg:$v1, PairedReg:$v2, PairedReg:$v3, RoundingMod:$mod)>;
def: Pat<(int_kvx_ffmsdp v2f64:$v1, v2f64:$v2, v2f64:$v3, i32:$mod), (FFMSDP_Instr PairedReg:$v1, PairedReg:$v2, PairedReg:$v3, RoundingMod:$mod)>;
def: Pat<(int_kvx_fmm2swq v2f32:$v1, v2f32:$v2, v4f32:$v3, i32:$mod), (FMM2SWQ_Instr SingleReg:$v1, SingleReg:$v2, PairedReg:$v3, RoundingMod:$mod)>;

def: Pat<(int_kvx_ctzd i64:$r), (CTZD SingleReg:$r)>;
def: Pat<(int_kvx_ctzw i32:$r), (CTZW SingleReg:$r)>;
def: Pat<(int_kvx_ctzwp v2i32:$r), (CTZWP SingleReg:$r)>;
def: Pat<(int_kvx_clzd i64:$r), (CLZD SingleReg:$r)>;
def: Pat<(int_kvx_clzw i32:$r), (CLZW SingleReg:$r)>;
def: Pat<(int_kvx_clzwp v2i32:$r), (CLZWP SingleReg:$r)>;
def: Pat<(int_kvx_clsd i64:$r), (CLSD SingleReg:$r)>;
def: Pat<(int_kvx_clsw i32:$r), (CLSW SingleReg:$r)>;
def: Pat<(int_kvx_clswp v2i32:$r), (CLSWP SingleReg:$r)>;
def: Pat<(int_kvx_cbsd i64:$r), (CBSD SingleReg:$r)>;
def: Pat<(int_kvx_cbsw i32:$r), (CBSW SingleReg:$r)>;
def: Pat<(int_kvx_cbswp v2i32:$r), (CBSWP SingleReg:$r)>;
