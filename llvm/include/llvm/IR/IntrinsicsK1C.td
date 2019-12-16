let TargetPrefix = "k1c" in {

def int_k1c_dinval : Intrinsic<[], [],[]>;
def int_k1c_fence : Intrinsic<[], [],[]>;
def int_k1c_stop : GCCBuiltin<"__builtin_k1_stop">, Intrinsic<[], [],[]>;
def int_k1c_get : Intrinsic<[llvm_i64_ty], [llvm_i32_ty],[IntrReadMem]>;
def int_k1c_set : Intrinsic<[], [llvm_i32_ty, llvm_i64_ty], []>;
def int_k1c_wfxl : Intrinsic<[], [llvm_i32_ty, llvm_i64_ty], []>;
def int_k1c_wfxm : Intrinsic<[], [llvm_i32_ty, llvm_i64_ty], []>;
def int_k1c_sbmm8 : Intrinsic<[llvm_i64_ty], [llvm_i32_ty, llvm_i64_ty], []>;

def int_k1c_lwzu: Intrinsic<[llvm_i32_ty], [llvm_ptr_ty], [IntrReadMem]>;
def int_k1c_acswapw: Intrinsic<[llvm_i32_ty], [llvm_ptr_ty, llvm_i32_ty, llvm_i32_ty], []>;

def int_k1c_fabswp: GCCBuiltin<"__builtin_k1_fabswp">, Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty], [IntrNoMem]>;
def int_k1c_fabswq: GCCBuiltin<"__builtin_k1_fabswq">, Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty], [IntrNoMem]>;
def int_k1c_fabsdp: GCCBuiltin<"__builtin_k1_fabsdp">, Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty], [IntrNoMem]>;

def int_k1c_fnegwp: GCCBuiltin<"__builtin_k1_fnegwp">, Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty], [IntrNoMem]>;
def int_k1c_fnegwq: GCCBuiltin<"__builtin_k1_fnegwq">, Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty], [IntrNoMem]>;
def int_k1c_fnegdp: GCCBuiltin<"__builtin_k1_fnegdp">, Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty], [IntrNoMem]>;

def int_k1c_fmaxwp: GCCBuiltin<"__builtin_k1_fmaxwp">, Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty], [IntrNoMem]>;
def int_k1c_fmaxwq: GCCBuiltin<"__builtin_k1_fmaxwq">, Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty], [IntrNoMem]>;
def int_k1c_fmaxdp: GCCBuiltin<"__builtin_k1_fmaxdp">, Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty], [IntrNoMem]>;

def int_k1c_fminwp: GCCBuiltin<"__builtin_k1_fminwp">, Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty], [IntrNoMem]>;
def int_k1c_fminwq: GCCBuiltin<"__builtin_k1_fminwq">, Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty], [IntrNoMem]>;
def int_k1c_fmindp: GCCBuiltin<"__builtin_k1_fmindp">, Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty], [IntrNoMem]>;

def int_k1c_faddwp : Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_k1c_faddcwc : Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_k1c_faddwq : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_k1c_faddcwcp : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_k1c_fadddp : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_k1c_faddcdc : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty], [IntrNoMem]>;

def int_k1c_fsbfwp : Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_k1c_fsbfcwc : Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_k1c_fsbfwq : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_k1c_fsbfcwcp : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_k1c_fsbfdp : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_k1c_fsbfcdc : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty], [IntrNoMem]>;

def int_k1c_fmulwp : Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_k1c_fmulwc : Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_k1c_fmulcwc : Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_k1c_fmulwq : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_k1c_fmulwcp : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_k1c_fmulcwcp : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_k1c_fmuldp : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_k1c_fmuldc : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_k1c_fmulcdc : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty], [IntrNoMem]>;

def int_k1c_fmm2wq : Intrinsic<[llvm_v4f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_k1c_ffmawp : Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_k1c_ffmawq : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_k1c_ffmadp : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_k1c_fmm2awq : Intrinsic<[llvm_v4f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_v4f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_k1c_ffmswp : Intrinsic<[llvm_v2f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_k1c_ffmswq : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_k1c_ffmsdp : Intrinsic<[llvm_v2f64_ty], [llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_k1c_fmm2swq : Intrinsic<[llvm_v4f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_v4f32_ty, llvm_i32_ty], [IntrNoMem]>;

}  // TargetPrefix = "k1c"
