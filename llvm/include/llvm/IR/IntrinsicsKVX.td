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
def int_kvx_waitit: Intrinsic<[], [llvm_i64_ty], []>;

def int_kvx_dinvall: Intrinsic<[], [llvm_ptr_ty], []>;
def int_kvx_dtouchl: Intrinsic<[], [llvm_ptr_ty], []>;
def int_kvx_dzerol: Intrinsic<[], [llvm_ptr_ty], []>;
def int_kvx_iinvals: Intrinsic<[], [llvm_ptr_ty], []>;

def int_kvx_get : Intrinsic<[llvm_i64_ty], [llvm_i32_ty],[IntrReadMem]>;
def int_kvx_set : Intrinsic<[], [llvm_i32_ty, llvm_i64_ty], []>;
def int_kvx_wfxl : Intrinsic<[], [llvm_i32_ty, llvm_i64_ty], []>;
def int_kvx_wfxm : Intrinsic<[], [llvm_i32_ty, llvm_i64_ty], []>;
def int_kvx_sbmm8 : Intrinsic<[llvm_i64_ty], [llvm_i32_ty, llvm_i64_ty], []>;

def int_kvx_lbzu: Intrinsic<[llvm_i32_ty], [llvm_ptr_ty], [IntrReadMem]>;
def int_kvx_lhzu: Intrinsic<[llvm_i32_ty], [llvm_ptr_ty], [IntrReadMem]>;
def int_kvx_lwzu: Intrinsic<[llvm_i32_ty], [llvm_ptr_ty], [IntrReadMem]>;
def int_kvx_ldu: Intrinsic<[llvm_i64_ty], [llvm_ptr_ty], [IntrReadMem]>;
def int_kvx_acswapw: Intrinsic<[llvm_i32_ty], [llvm_ptr_ty, llvm_i32_ty, llvm_i32_ty], []>;
def int_kvx_acswapd: Intrinsic<[llvm_i64_ty], [llvm_ptr_ty, llvm_i64_ty, llvm_i64_ty], []>;

def int_kvx_fabswp: Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty], [IntrNoMem]>;
def int_kvx_fabswq: Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty], [IntrNoMem]>;
def int_kvx_fabsdp: Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty], [IntrNoMem]>;

def int_kvx_fnegwp: Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty], [IntrNoMem]>;
def int_kvx_fnegwq: Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty], [IntrNoMem]>;
def int_kvx_fnegdp: Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty], [IntrNoMem]>;

def int_kvx_fmaxwp: Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty], [IntrNoMem]>;
def int_kvx_fmaxwq: Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty], [IntrNoMem]>;
def int_kvx_fmaxdp: Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty], [IntrNoMem]>;

def int_kvx_fminwp: Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty], [IntrNoMem]>;
def int_kvx_fminwq: Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty], [IntrNoMem]>;
def int_kvx_fmindp: Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty], [IntrNoMem]>;

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

def int_kvx_fmm2wq : Intrinsic<[llvm_v4f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmawp : Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmawq : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmadp : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmm2awq : Intrinsic<[llvm_v4f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_v4f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmswp : Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmswq : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmsdp : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmm2swq : Intrinsic<[llvm_v4f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_v4f32_ty, llvm_i32_ty], [IntrNoMem]>;

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
}  // TargetPrefix = "kvx"
