let TargetPrefix = "kvx" in {

def int_kvx_await : Intrinsic<[], [],[]>;
def int_kvx_barrier : Intrinsic<[], [],[]>;
def int_kvx_dinval : Intrinsic<[], [],[]>;
def int_kvx_errop : Intrinsic<[], [],[]>;
def int_kvx_fence : Intrinsic<[], [],[]>;
def int_kvx_iinval : Intrinsic<[], [],[]>;
def int_kvx_sleep : Intrinsic<[], [],[]>;
def int_kvx_stop : Intrinsic<[], [],[]>;
def int_kvx_tlbdinval : Intrinsic<[], [],[]>;
def int_kvx_tlbiinval : Intrinsic<[], [],[]>;
def int_kvx_tlbprobe : Intrinsic<[], [],[]>;
def int_kvx_tlbread : Intrinsic<[], [],[]>;
def int_kvx_tlbwrite : Intrinsic<[], [],[]>;

def int_kvx_syncgroup: Intrinsic<[], [llvm_i64_ty], []>;
def int_kvx_waitit: Intrinsic<[llvm_i32_ty], [llvm_i64_ty], []>;

def int_kvx_dinvall: Intrinsic<[], [llvm_ptr_ty], []>;
def int_kvx_dtouchl: Intrinsic<[], [llvm_ptr_ty], []>;
def int_kvx_dzerol: Intrinsic<[], [llvm_ptr_ty], []>;
def int_kvx_iinvals: Intrinsic<[], [llvm_ptr_ty], []>;

def int_kvx_get : Intrinsic<[llvm_i64_ty], [llvm_i32_ty],[IntrReadMem]>;
def int_kvx_set : Intrinsic<[], [llvm_i32_ty, llvm_i64_ty], []>;
def int_kvx_wfxl : Intrinsic<[], [llvm_i32_ty, llvm_i64_ty], []>;
def int_kvx_wfxm : Intrinsic<[], [llvm_i32_ty, llvm_i64_ty], []>;

def int_kvx_acswapw: Intrinsic<[llvm_i32_ty], [llvm_ptr_ty, llvm_i32_ty, llvm_i32_ty], []>;
def int_kvx_acswapd: Intrinsic<[llvm_i64_ty], [llvm_ptr_ty, llvm_i64_ty, llvm_i64_ty], []>;

def int_kvx_fabswp: Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty], [IntrNoMem]>;
def int_kvx_fnegwp: Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty], [IntrNoMem]>;

def int_kvx_fmaxwp: Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty], [IntrNoMem]>;
def int_kvx_fminwp: Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty], [IntrNoMem]>;

def int_kvx_faddwp : Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_faddcwc : Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_faddwq : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_faddcwcp : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fadddp : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_faddcdc : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty], [IntrNoMem]>;

def int_kvx_fsbfwp : Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fsbfcwc : Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fsbfwq : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fsbfcwcp : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fsbfdp : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fsbfcdc : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty], [IntrNoMem]>;

def int_kvx_fmulwp : Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmulwc : Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmulcwc : Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmulwq : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmulwcp : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmulcwcp : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmuldp : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmuldc : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmulcdc : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty], [IntrNoMem]>;

def int_kvx_fmm212w : Intrinsic<[llvm_v4f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmawp : Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmawq : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmadp : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmma212w : Intrinsic<[llvm_v4f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_v4f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmswp : Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmswq : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmsdp : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmms212w : Intrinsic<[llvm_v4f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_v4f32_ty, llvm_i32_ty], [IntrNoMem]>;

def int_kvx_ctzd: Intrinsic<[llvm_i64_ty], [llvm_i64_ty], [IntrNoMem]>;
def int_kvx_ctzw: Intrinsic<[llvm_i32_ty], [llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ctzwp: Intrinsic<[llvm_v2i32_ty], [llvm_v2i32_ty], [IntrNoMem]>;
def int_kvx_clzd: Intrinsic<[llvm_i64_ty], [llvm_i64_ty], [IntrNoMem]>;
def int_kvx_clzw: Intrinsic<[llvm_i32_ty], [llvm_i32_ty], [IntrNoMem]>;
def int_kvx_clzwp: Intrinsic<[llvm_v2i32_ty], [llvm_v2i32_ty], [IntrNoMem]>;
def int_kvx_clsd: Intrinsic<[llvm_i64_ty], [llvm_i64_ty], [IntrNoMem]>;
def int_kvx_clsw: Intrinsic<[llvm_i32_ty], [llvm_i32_ty], [IntrNoMem]>;
def int_kvx_clswp: Intrinsic<[llvm_v2i32_ty], [llvm_v2i32_ty], [IntrNoMem]>;
def int_kvx_cbsd: Intrinsic<[llvm_i64_ty], [llvm_i64_ty], [IntrNoMem]>;
def int_kvx_cbsw: Intrinsic<[llvm_i32_ty], [llvm_i32_ty], [IntrNoMem]>;
def int_kvx_cbswp: Intrinsic<[llvm_v2i32_ty], [llvm_v2i32_ty], [IntrNoMem]>;

def int_kvx_fixedw: Intrinsic<[llvm_i32_ty], [llvm_float_ty, llvm_i64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fixeduw: Intrinsic<[llvm_i32_ty], [llvm_float_ty, llvm_i64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fixedwp: Intrinsic<[llvm_v2i32_ty], [llvm_v2f32_ty, llvm_i64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fixeduwp: Intrinsic<[llvm_v2i32_ty], [llvm_v2f32_ty, llvm_i64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fixedd: Intrinsic<[llvm_i64_ty], [llvm_double_ty, llvm_i64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fixedud: Intrinsic<[llvm_i64_ty], [llvm_double_ty, llvm_i64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_floatw: Intrinsic<[llvm_float_ty], [llvm_i32_ty, llvm_i64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_floatwp: Intrinsic<[llvm_v2f32_ty], [llvm_v2i32_ty, llvm_i64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_floatuw: Intrinsic<[llvm_float_ty], [llvm_i32_ty, llvm_i64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_floatuwp: Intrinsic<[llvm_v2f32_ty], [llvm_v2i32_ty, llvm_i64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_floatd: Intrinsic<[llvm_double_ty], [llvm_i64_ty, llvm_i64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_floatud: Intrinsic<[llvm_double_ty], [llvm_i64_ty, llvm_i64_ty, llvm_i32_ty], [IntrNoMem]>;

def int_kvx_stsuw: Intrinsic<[llvm_i32_ty], [llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_stsud: Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;

def int_kvx_aladdd: Intrinsic<[llvm_i64_ty], [llvm_ptr_ty, llvm_i64_ty], [IntrReadMem]>;
def int_kvx_aladdw: Intrinsic<[llvm_i32_ty], [llvm_ptr_ty, llvm_i32_ty], [IntrReadMem]>;

def int_kvx_abdw: Intrinsic<[llvm_i32_ty], [llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_abdd: Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_addsw: Intrinsic<[llvm_i32_ty], [llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_addsd: Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_sbfsw: Intrinsic<[llvm_i32_ty], [llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_sbfsd: Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_addd: Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_sbfd: Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_avgw: Intrinsic<[llvm_i32_ty], [llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_avguw: Intrinsic<[llvm_i32_ty], [llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_avgrw: Intrinsic<[llvm_i32_ty], [llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_avgruw: Intrinsic<[llvm_i32_ty], [llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fabsw: Intrinsic<[llvm_float_ty], [llvm_float_ty], [IntrNoMem]>;
def int_kvx_fabsd: Intrinsic<[llvm_double_ty], [llvm_double_ty], [IntrNoMem]>;
def int_kvx_fnegw: Intrinsic<[llvm_float_ty], [llvm_float_ty], [IntrNoMem]>;
def int_kvx_fnegd: Intrinsic<[llvm_double_ty], [llvm_double_ty], [IntrNoMem]>;
def int_kvx_fminw: Intrinsic<[llvm_float_ty], [llvm_float_ty, llvm_float_ty], [IntrNoMem]>;
def int_kvx_fmind: Intrinsic<[llvm_double_ty], [llvm_double_ty, llvm_double_ty], [IntrNoMem]>;
def int_kvx_fmaxw: Intrinsic<[llvm_float_ty], [llvm_float_ty, llvm_float_ty], [IntrNoMem]>;
def int_kvx_fmaxd: Intrinsic<[llvm_double_ty], [llvm_double_ty, llvm_double_ty], [IntrNoMem]>;
def int_kvx_frecw: Intrinsic<[llvm_float_ty], [llvm_float_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_frsrw: Intrinsic<[llvm_float_ty], [llvm_float_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_faddw: Intrinsic<[llvm_float_ty], [llvm_float_ty, llvm_float_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_faddd: Intrinsic<[llvm_double_ty], [llvm_double_ty, llvm_double_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fsbfw: Intrinsic<[llvm_float_ty], [llvm_float_ty, llvm_float_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fsbfd: Intrinsic<[llvm_double_ty], [llvm_double_ty, llvm_double_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmulw: Intrinsic<[llvm_float_ty], [llvm_float_ty, llvm_float_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmuld: Intrinsic<[llvm_double_ty], [llvm_double_ty, llvm_double_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmulwd: Intrinsic<[llvm_double_ty], [llvm_float_ty, llvm_float_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmaw: Intrinsic<[llvm_float_ty], [llvm_float_ty, llvm_float_ty, llvm_float_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmad: Intrinsic<[llvm_double_ty], [llvm_double_ty, llvm_double_ty, llvm_double_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmawd: Intrinsic<[llvm_double_ty], [llvm_float_ty, llvm_float_ty, llvm_double_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmsw: Intrinsic<[llvm_float_ty], [llvm_float_ty, llvm_float_ty, llvm_float_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmsd: Intrinsic<[llvm_double_ty], [llvm_double_ty, llvm_double_ty, llvm_double_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmswd: Intrinsic<[llvm_double_ty], [llvm_float_ty, llvm_float_ty, llvm_double_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fcdivw: Intrinsic<[llvm_float_ty], [llvm_float_ty, llvm_float_ty], [IntrNoMem]>;
def int_kvx_fcdivd: Intrinsic<[llvm_double_ty], [llvm_double_ty, llvm_double_ty], [IntrNoMem]>;
def int_kvx_fsdivw: Intrinsic<[llvm_float_ty], [llvm_float_ty, llvm_float_ty], [IntrNoMem]>;
def int_kvx_fsdivd: Intrinsic<[llvm_double_ty], [llvm_double_ty, llvm_double_ty], [IntrNoMem]>;
def int_kvx_fsrecw: Intrinsic<[llvm_float_ty], [llvm_float_ty], [IntrNoMem]>;
def int_kvx_fsrecd: Intrinsic<[llvm_double_ty], [llvm_double_ty], [IntrNoMem]>;
def int_kvx_fsrsrw: Intrinsic<[llvm_float_ty], [llvm_float_ty], [IntrNoMem]>;
def int_kvx_fsrsrd: Intrinsic<[llvm_double_ty], [llvm_double_ty], [IntrNoMem]>;
def int_kvx_sbmm8 : Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_sbmmt8 : Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_satd : Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fwidenlhw: Intrinsic<[llvm_float_ty], [llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fwidenmhw: Intrinsic<[llvm_float_ty], [llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fnarrowwh: Intrinsic<[llvm_i32_ty], [llvm_float_ty], [IntrNoMem]>;

def int_kvx_cmovehq : Intrinsic<[llvm_v4i16_ty], [llvm_v4i16_ty, llvm_v4i16_ty, llvm_v4i16_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_cmovewp : Intrinsic<[llvm_v2i32_ty], [llvm_v2i32_ty, llvm_v2i32_ty, llvm_v2i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_cmoved : Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty, llvm_i64_ty, llvm_i32_ty], [IntrNoMem]>;

}  // TargetPrefix = "kvx"
