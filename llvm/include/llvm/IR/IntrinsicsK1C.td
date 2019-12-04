let TargetPrefix = "k1c" in {

def int_k1c_dinval : Intrinsic<[], [],[]>;
def int_k1c_fence : Intrinsic<[], [],[]>;
def int_k1c_get : Intrinsic<[llvm_i64_ty], [llvm_i32_ty],[IntrReadMem]>;
def int_k1c_wfxl : Intrinsic<[], [llvm_i32_ty, llvm_i64_ty], []>;
def int_k1c_sbmm8 : Intrinsic<[llvm_i64_ty], [llvm_i32_ty, llvm_i64_ty], []>;

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

}  // TargetPrefix = "k1c"
