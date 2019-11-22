let TargetPrefix = "k1c" in {

def int_k1c_dinval : Intrinsic<[], [],[]>;
def int_k1c_fence : Intrinsic<[], [],[]>;
def int_k1c_get : Intrinsic<[llvm_i64_ty], [llvm_i32_ty],[IntrReadMem]>;
def int_k1c_wfxl : Intrinsic<[], [llvm_i32_ty, llvm_i64_ty], []>;
def int_k1c_sbmm8 : Intrinsic<[llvm_i64_ty], [llvm_i32_ty, llvm_i64_ty], []>;

}  // TargetPrefix = "k1c"
