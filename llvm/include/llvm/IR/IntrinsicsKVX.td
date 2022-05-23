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
def int_kvx_fmaxhq: Intrinsic<[llvm_v4f16_ty], [llvm_v4f16_ty, llvm_v4f16_ty], [IntrNoMem]>;
def int_kvx_fminwp: Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty], [IntrNoMem]>;
def int_kvx_fminhq: Intrinsic<[llvm_v4f16_ty], [llvm_v4f16_ty, llvm_v4f16_ty], [IntrNoMem]>;

def int_kvx_faddwp : Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_faddwq : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fadddp : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fadddq : Intrinsic<[llvm_v4f64_ty], [llvm_v4f64_ty, llvm_v4f64_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

def int_kvx_fsbfwp : Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fsbfwq : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fsbfdp : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fsbfdq : Intrinsic<[llvm_v4f64_ty], [llvm_v4f64_ty, llvm_v4f64_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

def int_kvx_fmulhq : Intrinsic<[llvm_v4f16_ty], [llvm_v4f16_ty, llvm_v4f16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
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
def int_kvx_ffmahq : Intrinsic<[llvm_v4f16_ty], [llvm_v4f16_ty, llvm_v4f16_ty, llvm_v4f16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
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
def int_kvx_fmm222w : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmma222w : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmms222w : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

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
def int_kvx_addcd: Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty, llvm_i32_ty], []>;
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

// Floating-Point Fused Dual-Multiply Dual-Add
def int_kvx_ffdmdaw: Intrinsic<[llvm_float_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_float_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffdmdawp: Intrinsic<[llvm_v2f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_v2f32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

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
def int_kvx_sbfcd: Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty, llvm_i32_ty], []>;
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

def int_kvx_fnarrowwh: Intrinsic<[llvm_half_ty], [llvm_float_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fnarrowwhq: Intrinsic<[llvm_v4f16_ty], [llvm_v4f32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fnarrowdw: Intrinsic<[llvm_float_ty], [llvm_double_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fnarrowdwp: Intrinsic<[llvm_v2f32_ty], [llvm_v2f64_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

def int_kvx_fwidenlwd: Intrinsic<[llvm_double_ty], [llvm_v2f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fwidenmwd: Intrinsic<[llvm_double_ty], [llvm_v2f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fwidenlhw: Intrinsic<[llvm_float_ty], [llvm_v4f16_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fwidenlhwp: Intrinsic<[llvm_v2f32_ty], [llvm_v4f16_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fwidenmhwp: Intrinsic<[llvm_v2f32_ty], [llvm_v4f16_ty, llvm_i32_ty], [IntrNoMem]>;

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
def int_kvx_xmovetolo: Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_xmovetohi: Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_xmoveto: Intrinsic<[llvm_v256i1_ty], [llvm_i64_ty, llvm_i64_ty, llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_xmoveoto: Intrinsic<[llvm_v256i1_ty], [llvm_v4i64_ty], [IntrNoMem]>;

// Move from TCA registers to GPR
def int_kvx_xmovefo: Intrinsic<[llvm_v4i64_ty], [llvm_v256i1_ty], [IntrNoMem]>;

// Load / Store vector
def int_kvx_xloadc256: Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_ptr_ty, llvm_i64_ty, llvm_i32_ty, llvm_i32_ty], [IntrReadMem]>;
def int_kvx_xload1024q: Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty, llvm_ptr_ty, llvm_i32_ty, llvm_i32_ty], [IntrReadMem]>;
def int_kvx_xloadc1024q: Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty, llvm_ptr_ty, llvm_i64_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrReadMem]>;
def int_kvx_xstorec256: Intrinsic<[], [llvm_v256i1_ty, llvm_ptr_ty, llvm_i64_ty, llvm_i32_ty], [IntrWriteMem]>;
// atomic register copy/shift operations
def int_kvx_xswapvo : Intrinsic<[llvm_v4i64_ty, llvm_v256i1_ty], [llvm_v4i64_ty, llvm_v256i1_ty], [IntrNoMem]>;
def int_kvx_xaccess512o : Intrinsic<[llvm_v4i64_ty], [llvm_v512i1_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_xalign512o : Intrinsic<[llvm_v256i1_ty], [llvm_v512i1_ty, llvm_i64_ty], [IntrNoMem]>;

// Matrix / Wide sub-registers manipulation
def int_kvx_xinsertwm : Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty, llvm_v512i1_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_xinsertvm : Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_xinsertvw : Intrinsic<[llvm_v512i1_ty],  [llvm_v512i1_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_xmovefmw : Intrinsic<[llvm_v512i1_ty], [llvm_v1024i1_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_xmovefmv : Intrinsic<[llvm_v256i1_ty], [llvm_v1024i1_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_xmovefwv : Intrinsic<[llvm_v256i1_ty], [llvm_v512i1_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_xbuildfvm : Intrinsic<[llvm_v1024i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty, llvm_v256i1_ty, llvm_v256i1_ty], [IntrNoMem]>;
def int_kvx_xbuildfwm : Intrinsic<[llvm_v1024i1_ty], [llvm_v512i1_ty, llvm_v512i1_ty], [IntrNoMem]>;
def int_kvx_xbuildfvw : Intrinsic<[llvm_v512i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty], [IntrNoMem]>;

// TCA arithmetic intrinsics
class KVX_TCA_Inplace<list<LLVMType> args>
    : Intrinsic<[llvm_v256i1_ty], !listconcat([llvm_v256i1_ty], args), [IntrReadMem]>;

class KVX_TCA_convd : KVX_TCA_Inplace<[llvm_v1024i1_ty, llvm_i32_ty, llvm_i32_ty]>;
def int_kvx_xconvdhv0 : KVX_TCA_convd;
def int_kvx_xconvdhv1 : KVX_TCA_convd;
def int_kvx_xconvdhv : Intrinsic<[llvm_v256i1_ty], [llvm_v1024i1_ty, llvm_i32_ty, llvm_i32_ty], [IntrReadMem]>;

def int_kvx_xconvwbv0 : KVX_TCA_convd;
def int_kvx_xconvwbv1 : KVX_TCA_convd;
def int_kvx_xconvwbv2 : KVX_TCA_convd;
def int_kvx_xconvwbv3 : KVX_TCA_convd;
def int_kvx_xconvwbv : Intrinsic<[llvm_v256i1_ty], [llvm_v1024i1_ty, llvm_i32_ty, llvm_i32_ty], [IntrReadMem]>;

class KVX_TCA_fmma : KVX_TCA_Inplace<[llvm_v512i1_ty, llvm_v256i1_ty, llvm_v256i1_ty]>;
def int_kvx_xfmma242hw0 : KVX_TCA_fmma;
def int_kvx_xfmma242hw1 : KVX_TCA_fmma;
def int_kvx_xfmma242hw2 : KVX_TCA_fmma;
def int_kvx_xfmma242hw3 : KVX_TCA_fmma;
def int_kvx_xfmma444hw : Intrinsic<[llvm_v512i1_ty], [llvm_v512i1_ty, llvm_v256i1_ty, llvm_v256i1_ty], [IntrReadMem]>;

class KVX_TCA_Ternary<list<LLVMType> args>
    : Intrinsic<args, !listconcat(args, [llvm_v256i1_ty], [llvm_v256i1_ty]), [IntrReadMem]>;
def int_kvx_xmma444hbd0 : KVX_TCA_Ternary<[llvm_v1024i1_ty]>;
def int_kvx_xmma444hbd1 : KVX_TCA_Ternary<[llvm_v1024i1_ty]>;
def int_kvx_xmma484hbd : Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty, llvm_v512i1_ty, llvm_v256i1_ty], [IntrReadMem]>;
def int_kvx_xmma444hd : KVX_TCA_Ternary<[llvm_v1024i1_ty]>;
def int_kvx_xmma444suhbd0 : KVX_TCA_Ternary<[llvm_v1024i1_ty]>;
def int_kvx_xmma444suhbd1 : KVX_TCA_Ternary<[llvm_v1024i1_ty]>;
def int_kvx_xmma484suhbd : Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty, llvm_v512i1_ty, llvm_v256i1_ty], [IntrReadMem]>;
def int_kvx_xmma444suhd : KVX_TCA_Ternary<[llvm_v1024i1_ty]>;
def int_kvx_xmma444uhbd0 : KVX_TCA_Ternary<[llvm_v1024i1_ty]>;
def int_kvx_xmma444uhbd1 : KVX_TCA_Ternary<[llvm_v1024i1_ty]>;
def int_kvx_xmma484uhbd : Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty, llvm_v512i1_ty, llvm_v256i1_ty], [IntrReadMem]>;
def int_kvx_xmma444uhd : KVX_TCA_Ternary<[llvm_v1024i1_ty]>;
def int_kvx_xmma444ushbd0 : KVX_TCA_Ternary<[llvm_v1024i1_ty]>;
def int_kvx_xmma444ushbd1 : KVX_TCA_Ternary<[llvm_v1024i1_ty]>;
def int_kvx_xmma484ushbd : Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty, llvm_v512i1_ty, llvm_v256i1_ty], [IntrReadMem]>;
def int_kvx_xmma444ushd : KVX_TCA_Ternary<[llvm_v1024i1_ty]>;
def int_kvx_xmma484bw : KVX_TCA_Ternary<[llvm_v512i1_ty]>;
def int_kvx_xmma484subw : KVX_TCA_Ternary<[llvm_v512i1_ty]>;
def int_kvx_xmma484ubw : KVX_TCA_Ternary<[llvm_v512i1_ty]>;
def int_kvx_xmma484usbw : KVX_TCA_Ternary<[llvm_v512i1_ty]>;

def int_kvx_xmt44d : Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty], [IntrReadMem]>;
// fscalewv is not inplace, but has same args pattern
def int_kvx_xfscalewv : Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;
def int_kvx_xfnarrowwhv : Intrinsic<[llvm_v256i1_ty], [llvm_v512i1_ty, llvm_i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;

//===----------------------------------------------------------------------===//
// ACB 4.8 TCA intrinsics. Should remove them in ACB 4.10
//===----------------------------------------------------------------------===//
def int_kvx_alignov : Intrinsic<[llvm_v4i64_ty], [llvm_v256i1_ty, llvm_v256i1_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_alignv : Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_sv_cond: Intrinsic<[], [llvm_ptr_ty, llvm_v256i1_ty, llvm_i64_ty, llvm_i32_ty], [IntrWriteMem]>;
}  // TargetPrefix = "kvx"
