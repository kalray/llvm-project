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

def int_kvx_get : Intrinsic<[llvm_i64_ty], [llvm_i32_ty], []>;

def int_kvx_acswapw: Intrinsic<[llvm_i32_ty], [llvm_ptr_ty, llvm_i32_ty, llvm_i32_ty], []>;
def int_kvx_acswapd: Intrinsic<[llvm_i64_ty], [llvm_ptr_ty, llvm_i64_ty, llvm_i64_ty], []>;

def int_kvx_alclrw: Intrinsic<[llvm_i32_ty], [llvm_ptr_ty], []>;
def int_kvx_alclrd: Intrinsic<[llvm_i64_ty], [llvm_ptr_ty], []>;

def int_kvx_fabswp: Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty], [IntrNoMem]>;
def int_kvx_fnegwp: Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty], [IntrNoMem]>;

def int_kvx_fmaxwp: Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty], [IntrNoMem]>;
def int_kvx_fminwp: Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty], [IntrNoMem]>;

def int_kvx_faddwp : Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_faddwq : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fadddp : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fadddq : Intrinsic<[llvm_v4f64_ty], [llvm_v4f64_ty, llvm_v4f64_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

def int_kvx_fsbfwp : Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fsbfwq : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fsbfdp : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fsbfdq : Intrinsic<[llvm_v4f64_ty], [llvm_v4f64_ty, llvm_v4f64_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

def int_kvx_fmulwp : Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmulwc : Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmulwq : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmulwcp : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmuldp : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmuldc : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmulcdc : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

def int_kvx_fmm212w : Intrinsic<[llvm_v4f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmawp : Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmawc : Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmawq : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmawcp : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmadp : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmadc : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmacdc : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmma212w : Intrinsic<[llvm_v4f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_v4f32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmswp : Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmswc : Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmswq : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmswcp : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmsdp : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmsdc : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmscdc : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmms212w : Intrinsic<[llvm_v4f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_v4f32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

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

def int_kvx_trunchbo: Intrinsic<[llvm_v8i8_ty], [llvm_v8i16_ty], [IntrNoMem]>;

def int_kvx_fixedw: Intrinsic<[llvm_i32_ty], [llvm_float_ty, llvm_i64_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fixeduw: Intrinsic<[llvm_i32_ty], [llvm_float_ty, llvm_i64_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fixedwp: Intrinsic<[llvm_v2i32_ty], [llvm_v2f32_ty, llvm_i64_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fixeduwp: Intrinsic<[llvm_v2i32_ty], [llvm_v2f32_ty, llvm_i64_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fixedd: Intrinsic<[llvm_i64_ty], [llvm_double_ty, llvm_i64_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fixedud: Intrinsic<[llvm_i64_ty], [llvm_double_ty, llvm_i64_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_floatw: Intrinsic<[llvm_float_ty], [llvm_i32_ty, llvm_i64_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_floatwp: Intrinsic<[llvm_v2f32_ty], [llvm_v2i32_ty, llvm_i64_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_floatuw: Intrinsic<[llvm_float_ty], [llvm_i32_ty, llvm_i64_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_floatuwp: Intrinsic<[llvm_v2f32_ty], [llvm_v2i32_ty, llvm_i64_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_floatd: Intrinsic<[llvm_double_ty], [llvm_i64_ty, llvm_i64_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_floatud: Intrinsic<[llvm_double_ty], [llvm_i64_ty, llvm_i64_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

def int_kvx_stsuw: Intrinsic<[llvm_i32_ty], [llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_stsud: Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;

def int_kvx_aladdd: Intrinsic<[llvm_i64_ty], [llvm_ptr_ty, llvm_i64_ty], [IntrArgMemOnly]>;
def int_kvx_aladdw: Intrinsic<[llvm_i32_ty], [llvm_ptr_ty, llvm_i32_ty], [IntrArgMemOnly]>;

def int_kvx_abdw: Intrinsic<[llvm_i32_ty], [llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_abdwp: Intrinsic<[llvm_v2i32_ty], [llvm_v2i32_ty, llvm_v2i32_ty], [IntrNoMem]>;
def int_kvx_abdhq : Intrinsic<[llvm_v4i16_ty], [llvm_v4i16_ty, llvm_v4i16_ty], [IntrNoMem]>;
def int_kvx_abdd: Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_addsw: Intrinsic<[llvm_i32_ty], [llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_addsd: Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_sbfshq: Intrinsic<[llvm_v4i16_ty], [llvm_v4i16_ty, llvm_v4i16_ty], [IntrNoMem]>;
def int_kvx_sbfswp: Intrinsic<[llvm_v2i32_ty], [llvm_v2i32_ty, llvm_v2i32_ty], [IntrNoMem]>;
def int_kvx_sbfsw: Intrinsic<[llvm_i32_ty], [llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_sbfsd: Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_addd: Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_addshq: Intrinsic<[llvm_v4i16_ty], [llvm_v4i16_ty, llvm_v4i16_ty], [IntrNoMem]>;
def int_kvx_addswp: Intrinsic<[llvm_v2i32_ty], [llvm_v2i32_ty, llvm_v2i32_ty], [IntrNoMem]>;
def int_kvx_sbfd: Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_avghq: Intrinsic<[llvm_v4i16_ty], [llvm_v4i16_ty, llvm_v4i16_ty], [IntrNoMem]>;
def int_kvx_avgw: Intrinsic<[llvm_i32_ty], [llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_avgwp: Intrinsic<[llvm_v2i32_ty], [llvm_v2i32_ty, llvm_v2i32_ty], [IntrNoMem]>;
def int_kvx_avguhq: Intrinsic<[llvm_v4i16_ty], [llvm_v4i16_ty, llvm_v4i16_ty], [IntrNoMem]>;
def int_kvx_avguw: Intrinsic<[llvm_i32_ty], [llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_avguwp: Intrinsic<[llvm_v2i32_ty], [llvm_v2i32_ty, llvm_v2i32_ty], [IntrNoMem]>;
def int_kvx_avgrhq: Intrinsic<[llvm_v4i16_ty], [llvm_v4i16_ty, llvm_v4i16_ty], [IntrNoMem]>;
def int_kvx_avgrw: Intrinsic<[llvm_i32_ty], [llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_avgruhq: Intrinsic<[llvm_v4i16_ty], [llvm_v4i16_ty, llvm_v4i16_ty], [IntrNoMem]>;
def int_kvx_avgrwp: Intrinsic<[llvm_v2i32_ty], [llvm_v2i32_ty, llvm_v2i32_ty], [IntrNoMem]>;
def int_kvx_avgruw: Intrinsic<[llvm_i32_ty], [llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_avgruwp: Intrinsic<[llvm_v2i32_ty], [llvm_v2i32_ty, llvm_v2i32_ty], [IntrNoMem]>;
def int_kvx_fabsw: Intrinsic<[llvm_float_ty], [llvm_float_ty], [IntrNoMem]>;
def int_kvx_fabsd: Intrinsic<[llvm_double_ty], [llvm_double_ty], [IntrNoMem]>;
def int_kvx_fnegw: Intrinsic<[llvm_float_ty], [llvm_float_ty], [IntrNoMem]>;
def int_kvx_fnegd: Intrinsic<[llvm_double_ty], [llvm_double_ty], [IntrNoMem]>;
def int_kvx_fminw: Intrinsic<[llvm_float_ty], [llvm_float_ty, llvm_float_ty], [IntrNoMem]>;
def int_kvx_fmind: Intrinsic<[llvm_double_ty], [llvm_double_ty, llvm_double_ty], [IntrNoMem]>;
def int_kvx_fmaxw: Intrinsic<[llvm_float_ty], [llvm_float_ty, llvm_float_ty], [IntrNoMem]>;
def int_kvx_fmaxd: Intrinsic<[llvm_double_ty], [llvm_double_ty, llvm_double_ty], [IntrNoMem]>;
def int_kvx_frecw: Intrinsic<[llvm_float_ty], [llvm_float_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_frsrw: Intrinsic<[llvm_float_ty], [llvm_float_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_faddw: Intrinsic<[llvm_float_ty], [llvm_float_ty, llvm_float_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_faddd: Intrinsic<[llvm_double_ty], [llvm_double_ty, llvm_double_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fsbfw: Intrinsic<[llvm_float_ty], [llvm_float_ty, llvm_float_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fsbfd: Intrinsic<[llvm_double_ty], [llvm_double_ty, llvm_double_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmulw: Intrinsic<[llvm_float_ty], [llvm_float_ty, llvm_float_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmuld: Intrinsic<[llvm_double_ty], [llvm_double_ty, llvm_double_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmulwd: Intrinsic<[llvm_double_ty], [llvm_float_ty, llvm_float_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmaw: Intrinsic<[llvm_float_ty], [llvm_float_ty, llvm_float_ty, llvm_float_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmad: Intrinsic<[llvm_double_ty], [llvm_double_ty, llvm_double_ty, llvm_double_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmawd: Intrinsic<[llvm_double_ty], [llvm_float_ty, llvm_float_ty, llvm_double_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmsw: Intrinsic<[llvm_float_ty], [llvm_float_ty, llvm_float_ty, llvm_float_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmsd: Intrinsic<[llvm_double_ty], [llvm_double_ty, llvm_double_ty, llvm_double_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmswd: Intrinsic<[llvm_double_ty], [llvm_float_ty, llvm_float_ty, llvm_double_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fcdivw: Intrinsic<[llvm_float_ty], [llvm_float_ty, llvm_float_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fcdivd: Intrinsic<[llvm_double_ty], [llvm_double_ty, llvm_double_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fsdivw: Intrinsic<[llvm_float_ty], [llvm_float_ty, llvm_float_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fsdivd: Intrinsic<[llvm_double_ty], [llvm_double_ty, llvm_double_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fsrecw: Intrinsic<[llvm_float_ty], [llvm_float_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fsrecd: Intrinsic<[llvm_double_ty], [llvm_double_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fsrsrw: Intrinsic<[llvm_float_ty], [llvm_float_ty], [IntrNoMem]>;
def int_kvx_fsrsrd: Intrinsic<[llvm_double_ty], [llvm_double_ty], [IntrNoMem]>;
def int_kvx_maxhq: Intrinsic<[llvm_v4i16_ty], [llvm_v4i16_ty, llvm_v4i16_ty], [IntrNoMem]>;
def int_kvx_maxw: Intrinsic<[llvm_i32_ty], [llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_maxwp: Intrinsic<[llvm_v2i32_ty], [llvm_v2i32_ty, llvm_v2i32_ty], [IntrNoMem]>;
def int_kvx_maxd: Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>; 
def int_kvx_minhq: Intrinsic<[llvm_v4i16_ty], [llvm_v4i16_ty, llvm_v4i16_ty], [IntrNoMem]>;
def int_kvx_minw: Intrinsic<[llvm_i32_ty], [llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_minwp: Intrinsic<[llvm_v2i32_ty], [llvm_v2i32_ty, llvm_v2i32_ty], [IntrNoMem]>;
def int_kvx_mind: Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_maxuhq: Intrinsic<[llvm_v4i16_ty], [llvm_v4i16_ty, llvm_v4i16_ty], [IntrNoMem]>;
def int_kvx_maxuw: Intrinsic<[llvm_i32_ty], [llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_maxuwp: Intrinsic<[llvm_v2i32_ty], [llvm_v2i32_ty, llvm_v2i32_ty], [IntrNoMem]>;
def int_kvx_maxud: Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>; 
def int_kvx_minuhq: Intrinsic<[llvm_v4i16_ty], [llvm_v4i16_ty, llvm_v4i16_ty], [IntrNoMem]>;
def int_kvx_minuw: Intrinsic<[llvm_i32_ty], [llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_minuwp: Intrinsic<[llvm_v2i32_ty], [llvm_v2i32_ty, llvm_v2i32_ty], [IntrNoMem]>;
def int_kvx_minud: Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>; 
def int_kvx_sbmm8 : Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_sbmmt8 : Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_satd : Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_slld : Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_sllhqs : Intrinsic<[llvm_v4i16_ty], [llvm_v4i16_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_sllwps : Intrinsic<[llvm_v2i32_ty], [llvm_v2i32_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_slsd : Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_slshqs : Intrinsic<[llvm_v4i16_ty], [llvm_v4i16_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_slswps : Intrinsic<[llvm_v2i32_ty], [llvm_v2i32_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_srad : Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_srahqs : Intrinsic<[llvm_v4i16_ty], [llvm_v4i16_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_srawps : Intrinsic<[llvm_v2i32_ty], [llvm_v2i32_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_srld : Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_srlhqs : Intrinsic<[llvm_v4i16_ty], [llvm_v4i16_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_srlwps : Intrinsic<[llvm_v2i32_ty], [llvm_v2i32_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_srsd : Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_srshqs : Intrinsic<[llvm_v4i16_ty], [llvm_v4i16_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_srswps : Intrinsic<[llvm_v2i32_ty], [llvm_v2i32_ty, llvm_i64_ty], [IntrNoMem]>;

def int_kvx_fwidenlhw: Intrinsic<[llvm_float_ty], [llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fwidenmhw: Intrinsic<[llvm_float_ty], [llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fnarrowwh: Intrinsic<[llvm_i32_ty], [llvm_float_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

def int_kvx_cmovehq : Intrinsic<[llvm_v4i16_ty], [llvm_v4i16_ty, llvm_v4i16_ty, llvm_v4i16_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_cmovewp : Intrinsic<[llvm_v2i32_ty], [llvm_v2i32_ty, llvm_v2i32_ty, llvm_v2i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_cmoved : Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty, llvm_i64_ty, llvm_i32_ty], [IntrNoMem]>;

def int_kvx_loopdoexit : Intrinsic<[llvm_i64_ty], [], [IntrNoDuplicate]>;

def int_kvx_fconjwc : Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty], [IntrNoMem]>;
def int_kvx_fconjwcp : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty], [IntrNoMem]>;
def int_kvx_fconjdc : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty], [IntrNoMem]>;

//===----------------------------------------------------------------------===//
// TCA - tightly-coupled accelerator
//===----------------------------------------------------------------------===//
// Move from GRP to TCA registers
def int_kvx_movetolo: Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_movetohi: Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_moveto: Intrinsic<[llvm_v256i1_ty], [llvm_i64_ty, llvm_i64_ty, llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_moveoto: Intrinsic<[llvm_v256i1_ty], [llvm_v4i64_ty], [IntrNoMem]>;

// Move from TCA registers to GPR
def int_kvx_movefo: Intrinsic<[llvm_v4i64_ty], [llvm_v256i1_ty], [IntrNoMem]>;

// Load / Store vector
def int_kvx_lv_cond: Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_ptr_ty, llvm_i64_ty, llvm_i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;
def int_kvx_lvc: Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty, llvm_ptr_ty, llvm_i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;
def int_kvx_lvc_cond: Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty, llvm_ptr_ty, llvm_i32_ty, llvm_i64_ty, llvm_i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;
def int_kvx_sv_cond: Intrinsic<[], [llvm_ptr_ty, llvm_v256i1_ty, llvm_i64_ty, llvm_i32_ty], [IntrWriteMem]>;
// atomic register copy/shift operations
def int_kvx_swapvo : Intrinsic<[llvm_v4i64_ty, llvm_v256i1_ty], [llvm_v4i64_ty, llvm_v256i1_ty], [IntrNoMem]>;
def int_kvx_alignov : Intrinsic<[llvm_v4i64_ty], [llvm_v256i1_ty, llvm_v256i1_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_alignv : Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty, llvm_i64_ty], [IntrNoMem]>;

// Matrix / Wide sub-registers manipulation
def int_kvx_insertwm : Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty, llvm_v512i1_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_insertvm : Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_insertvw : Intrinsic<[llvm_v512i1_ty],  [llvm_v512i1_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_movefmw : Intrinsic<[llvm_v512i1_ty], [llvm_v1024i1_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_movefmv : Intrinsic<[llvm_v256i1_ty], [llvm_v1024i1_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_movefwv : Intrinsic<[llvm_v256i1_ty], [llvm_v512i1_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_buildfvm : Intrinsic<[llvm_v1024i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty, llvm_v256i1_ty, llvm_v256i1_ty], [IntrNoMem]>;
def int_kvx_buildfwm : Intrinsic<[llvm_v1024i1_ty], [llvm_v512i1_ty, llvm_v512i1_ty], [IntrNoMem]>;
def int_kvx_buildfvw : Intrinsic<[llvm_v512i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty], [IntrNoMem]>;

// TCA arithmetic intrinsics
class KVX_TCA_Inplace<list<LLVMType> args>
    : Intrinsic<[llvm_v256i1_ty], !listconcat([llvm_v256i1_ty], args), [IntrNoMem]>;

class KVX_TCA_convd : KVX_TCA_Inplace<[llvm_v1024i1_ty, llvm_i32_ty, llvm_i32_ty]>;
def int_kvx_convdhv0 : KVX_TCA_convd;
def int_kvx_convdhv1 : KVX_TCA_convd;
def int_kvx_convdhv : Intrinsic<[llvm_v256i1_ty], [llvm_v1024i1_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

def int_kvx_convwbv0 : KVX_TCA_convd;
def int_kvx_convwbv1 : KVX_TCA_convd;
def int_kvx_convwbv2 : KVX_TCA_convd;
def int_kvx_convwbv3 : KVX_TCA_convd;
def int_kvx_convwbv : Intrinsic<[llvm_v256i1_ty], [llvm_v1024i1_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

class KVX_TCA_fmma : KVX_TCA_Inplace<[llvm_v512i1_ty, llvm_v256i1_ty, llvm_v256i1_ty]>;
def int_kvx_fmma242hw0 : KVX_TCA_fmma;
def int_kvx_fmma242hw1 : KVX_TCA_fmma;
def int_kvx_fmma242hw2 : KVX_TCA_fmma;
def int_kvx_fmma242hw3 : KVX_TCA_fmma;
def int_kvx_fmma444hw : Intrinsic<[llvm_v512i1_ty], [llvm_v512i1_ty, llvm_v256i1_ty, llvm_v256i1_ty], [IntrNoMem]>;

class KVX_TCA_Ternary<list<LLVMType> args>
    : Intrinsic<args, !listconcat(args, [llvm_v256i1_ty], [llvm_v256i1_ty]), [IntrNoMem]>;
def int_kvx_mma444hbd0 : KVX_TCA_Ternary<[llvm_v1024i1_ty]>;
def int_kvx_mma444hbd1 : KVX_TCA_Ternary<[llvm_v1024i1_ty]>;
def int_kvx_mma484hbd : Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty, llvm_v512i1_ty, llvm_v256i1_ty], [IntrNoMem]>;
def int_kvx_mma444hd : KVX_TCA_Ternary<[llvm_v1024i1_ty]>;
def int_kvx_mma444suhbd0 : KVX_TCA_Ternary<[llvm_v1024i1_ty]>;
def int_kvx_mma444suhbd1 : KVX_TCA_Ternary<[llvm_v1024i1_ty]>;
def int_kvx_mma484suhbd : Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty, llvm_v512i1_ty, llvm_v256i1_ty], [IntrNoMem]>;
def int_kvx_mma444suhd : KVX_TCA_Ternary<[llvm_v1024i1_ty]>;
def int_kvx_mma444uhbd0 : KVX_TCA_Ternary<[llvm_v1024i1_ty]>;
def int_kvx_mma444uhbd1 : KVX_TCA_Ternary<[llvm_v1024i1_ty]>;
def int_kvx_mma484uhbd : Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty, llvm_v512i1_ty, llvm_v256i1_ty], [IntrNoMem]>;
def int_kvx_mma444uhd : KVX_TCA_Ternary<[llvm_v1024i1_ty]>;
def int_kvx_mma444ushbd0 : KVX_TCA_Ternary<[llvm_v1024i1_ty]>;
def int_kvx_mma444ushbd1 : KVX_TCA_Ternary<[llvm_v1024i1_ty]>;
def int_kvx_mma484ushbd : Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty, llvm_v512i1_ty, llvm_v256i1_ty], [IntrNoMem]>;
def int_kvx_mma444ushd : KVX_TCA_Ternary<[llvm_v1024i1_ty]>;
def int_kvx_mma484bw : KVX_TCA_Ternary<[llvm_v512i1_ty]>;
def int_kvx_mma484subw : KVX_TCA_Ternary<[llvm_v512i1_ty]>;
def int_kvx_mma484ubw : KVX_TCA_Ternary<[llvm_v512i1_ty]>;
def int_kvx_mma484usbw : KVX_TCA_Ternary<[llvm_v512i1_ty]>;

def int_kvx_mt44d : Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty], [IntrNoMem]>;
// fscalewv is not inplace, but has same args pattern
def int_kvx_fscalewv : Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;
def int_kvx_fnarrowwhv : Intrinsic<[llvm_v256i1_ty], [llvm_v512i1_ty, llvm_i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;
}  // TargetPrefix = "kvx"
