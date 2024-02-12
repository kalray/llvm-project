let TargetPrefix = "kvx" in {

def int_kvx_await : Intrinsic<[], [],[]>;
def int_kvx_barrier : Intrinsic<[], [],[]>;
def int_kvx_d1inval : Intrinsic<[], [],[]>;
def int_kvx_errop : Intrinsic<[], [],[IntrNoReturn, IntrCold]>;
def int_kvx_fence : Intrinsic<[], [llvm_i32_ty],[]>;
def int_kvx_i1inval : Intrinsic<[], [],[]>;
def int_kvx_rfe : Intrinsic<[], [],[IntrNoReturn, IntrCold]>;
def int_kvx_sleep : Intrinsic<[], [],[]>;
def int_kvx_stop : Intrinsic<[], [],[]>;
def int_kvx_tlbdinval : Intrinsic<[], [],[]>;
def int_kvx_tlbiinval : Intrinsic<[], [],[]>;
def int_kvx_tlbprobe : Intrinsic<[], [],[]>;
def int_kvx_tlbread : Intrinsic<[], [],[]>;
def int_kvx_tlbwrite : Intrinsic<[], [],[]>;

def int_kvx_syncgroup: Intrinsic<[], [llvm_i64_ty], []>;
def int_kvx_waitit: Intrinsic<[llvm_i32_ty], [llvm_i64_ty], []>;

def int_kvx_wfx : Intrinsic<[], [llvm_i32_ty, llvm_i64_ty, llvm_i32_ty], [IntrHasSideEffects]>;

def int_kvx_dinvall: Intrinsic<[], [llvm_ptr_ty], []>;
def int_kvx_dtouchl: Intrinsic<[], [llvm_ptr_ty], []>;
def int_kvx_dzerol: Intrinsic<[], [llvm_ptr_ty], []>;
def int_kvx_i1invals: Intrinsic<[], [llvm_ptr_ty], []>;

def int_kvx_ready: Intrinsic<[llvm_i64_ty], [llvm_vararg_ty], [IntrNoMem]>;
def int_kvx_store: Intrinsic<[], [/*store value*/ llvm_any_ty, LLVMPointerTo<0>, /*size*/ llvm_i32_ty, /*ready*/ llvm_any_ty], [IntrWriteMem, IntrArgMemOnly]>;
def int_kvx_store_vol: Intrinsic<[], [/*store value*/ llvm_any_ty, LLVMPointerTo<0>, /*size*/ llvm_i32_ty, /*ready*/ llvm_any_ty], [IntrHasSideEffects]>;
def int_kvx_storec: Intrinsic<[], [/*store value*/ llvm_any_ty, LLVMPointerTo<0>, /*size*/ llvm_i32_ty,
                                   /*condition*/ llvm_i64_ty, /*lsucond*/ llvm_i32_ty, /*lsomask*/ llvm_i32_ty, /*optional ready*/ llvm_vararg_ty], [IntrWriteMem, IntrArgMemOnly]>;
def int_kvx_storec_vol: Intrinsic<[], [/*store value*/ llvm_any_ty, LLVMPointerTo<0>, /*size*/ llvm_i32_ty,
                                   /*condition*/ llvm_i64_ty, /*lsucond*/ llvm_i32_ty, /*lsomask*/ llvm_i32_ty, /*optional ready*/ llvm_vararg_ty], [IntrHasSideEffects]>;
def int_kvx_loadc_u: Intrinsic<[llvm_any_ty], [LLVMMatchType<0>, LLVMPointerTo<0>, /*size*/ llvm_i32_ty,
                                   /*condition*/ llvm_i64_ty, /*variant*/ llvm_i32_ty, /*lsucond*/ llvm_i32_ty, /*lsomask*/ llvm_i32_ty], [IntrReadMem, IntrArgMemOnly]>;
def int_kvx_loadc_u_vol: Intrinsic<[llvm_any_ty], [LLVMMatchType<0>, LLVMPointerTo<0>, /*size*/ llvm_i32_ty,
                                   /*condition*/ llvm_i64_ty, /*variant*/ llvm_i32_ty, /*lsucond*/ llvm_i32_ty, /*lsomask*/ llvm_i32_ty], [IntrReadMem, IntrArgMemOnly]>;

def int_kvx_acswapw: Intrinsic<[llvm_i32_ty], [llvm_ptr_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrArgMemOnly]>;
def int_kvx_acswapd: Intrinsic<[llvm_i64_ty], [llvm_ptr_ty, llvm_i64_ty, llvm_i64_ty, llvm_i32_ty, llvm_i32_ty], [IntrArgMemOnly]>;
def int_kvx_acswapq: Intrinsic<[llvm_v2i64_ty], [llvm_ptr_ty, llvm_v2i64_ty, llvm_v2i64_ty, llvm_i32_ty, llvm_i32_ty], [IntrArgMemOnly]>;

def int_kvx_fmm212w : Intrinsic<[llvm_v4f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmma212w : Intrinsic<[llvm_v4f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_v4f32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmms212w : Intrinsic<[llvm_v4f32_ty], [llvm_v2f32_ty, llvm_v2f32_ty, llvm_v4f32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmm222w : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmma222w : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmms222w : Intrinsic<[llvm_v4f32_ty], [llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

def int_kvx_fixedw: Intrinsic<[llvm_i32_ty], [llvm_float_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fixeduw: Intrinsic<[llvm_i32_ty], [llvm_float_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fixedwp: Intrinsic<[llvm_v2i32_ty], [llvm_v2f32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fixeduwp: Intrinsic<[llvm_v2i32_ty], [llvm_v2f32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fixedd: Intrinsic<[llvm_i64_ty], [llvm_double_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fixedud: Intrinsic<[llvm_i64_ty], [llvm_double_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_floatw: Intrinsic<[llvm_float_ty], [llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_floatwp: Intrinsic<[llvm_v2f32_ty], [llvm_v2i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_floatuw: Intrinsic<[llvm_float_ty], [llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_floatuwp: Intrinsic<[llvm_v2f32_ty], [llvm_v2i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_floatd: Intrinsic<[llvm_double_ty], [llvm_i64_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_floatud: Intrinsic<[llvm_double_ty], [llvm_i64_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

def int_kvx_aladdd: Intrinsic<[llvm_i64_ty], [llvm_ptr_ty, llvm_i64_ty], [IntrArgMemOnly]>;
def int_kvx_aladdw: Intrinsic<[llvm_i32_ty], [llvm_ptr_ty, llvm_i32_ty], [IntrArgMemOnly]>;

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
def int_kvx_frecw: Intrinsic<[llvm_float_ty], [llvm_float_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_frsrw: Intrinsic<[llvm_float_ty], [llvm_float_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

// Floating-Point Fused Dual-Multiply Dual-Add

def int_kvx_madddt: Intrinsic<[llvm_v2i64_ty], [llvm_v2i64_ty, llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_maddsudt: Intrinsic<[llvm_v2i64_ty], [llvm_v2i64_ty, llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_maddudt: Intrinsic<[llvm_v2i64_ty], [llvm_v2i64_ty, llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_madduzdt: Intrinsic<[llvm_v2i64_ty], [llvm_v2i64_ty, llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_msbfdt: Intrinsic<[llvm_v2i64_ty], [llvm_v2i64_ty, llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_msbfsudt: Intrinsic<[llvm_v2i64_ty], [llvm_v2i64_ty, llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_msbfudt: Intrinsic<[llvm_v2i64_ty], [llvm_v2i64_ty, llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_msbfuzdt: Intrinsic<[llvm_v2i64_ty], [llvm_v2i64_ty, llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;

def int_kvx_sbmm8 : Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_sbmmt8 : Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_satd : Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_sbfcd: Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty, llvm_i32_ty], []>;

def int_kvx_loopdoexit : Intrinsic<[llvm_i64_ty], [], [IntrNoDuplicate]>;

//===----------------------------------------------------------------------===//
// KVX Coolidge V2 builtins
//===----------------------------------------------------------------------===//

def int_kvx_dflushsw : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty, llvm_i32_ty], [IntrArgMemOnly]>;
def int_kvx_dinvalsw : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty, llvm_i32_ty], [IntrArgMemOnly]>;
def int_kvx_dpurgesw : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty, llvm_i32_ty], [IntrArgMemOnly]>;

def int_kvx_alw: Intrinsic<[llvm_i32_ty], [llvm_ptr_ty, llvm_i32_ty], [IntrReadMem]>;
def int_kvx_ald: Intrinsic<[llvm_i64_ty], [llvm_ptr_ty, llvm_i32_ty], [IntrReadMem]>;
def int_kvx_asw: Intrinsic<[], [llvm_ptr_ty, llvm_i32_ty, llvm_i32_ty], [IntrWriteMem]>;
def int_kvx_asd: Intrinsic<[], [llvm_ptr_ty, llvm_i64_ty, llvm_i32_ty], [IntrWriteMem]>;

def int_kvx_dpurgel : Intrinsic<[], [llvm_ptr_ty], [IntrArgMemOnly]>;
def int_kvx_dflushl : Intrinsic<[], [llvm_ptr_ty], [IntrArgMemOnly]>;

def int_kvx_sxlbhq : Intrinsic<[llvm_v4i16_ty], [llvm_v8i8_ty], [IntrNoMem]>;
def int_kvx_sxmbhq : Intrinsic<[llvm_v4i16_ty], [llvm_v8i8_ty], [IntrNoMem]>;

def int_kvx_zxlbhq  : Intrinsic<[llvm_v4i16_ty], [llvm_v8i8_ty], [IntrNoMem]>;
def int_kvx_zxmbhq  : Intrinsic<[llvm_v4i16_ty], [llvm_v8i8_ty], [IntrNoMem]>;

def int_kvx_sxlhwp : Intrinsic<[llvm_v2i32_ty], [llvm_v4i16_ty], [IntrNoMem]>;
def int_kvx_sxmhwp : Intrinsic<[llvm_v2i32_ty], [llvm_v4i16_ty], [IntrNoMem]>;

def int_kvx_zxlhwp  : Intrinsic<[llvm_v2i32_ty], [llvm_v4i16_ty], [IntrNoMem]>;
def int_kvx_zxmhwp  : Intrinsic<[llvm_v2i32_ty], [llvm_v4i16_ty], [IntrNoMem]>;

// Move from GPR to TCA registers
def int_kvx_xmovetq: Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_i64_ty, llvm_i64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_xmoveto: Intrinsic<[llvm_v256i1_ty], [llvm_i64_ty, llvm_i64_ty, llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_xmoveto256: Intrinsic<[llvm_v256i1_ty], [llvm_v4i64_ty], [IntrNoMem]>;
def int_kvx_xmovetq256: Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_v2i64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_xmovetd256: Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_i64_ty, llvm_i32_ty], [IntrNoMem]>;

// Move from TCA registers to GPR
def int_kvx_xmovefo256: Intrinsic<[llvm_v4i64_ty], [llvm_v256i1_ty], [IntrNoMem]>;
def int_kvx_xmovefq256: Intrinsic<[llvm_v2i64_ty], [llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_xmovefd256: Intrinsic<[llvm_i64_ty], [llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;

// atomic register copy/shift operations
def int_kvx_xswapo256 : Intrinsic<[llvm_v4i64_ty, llvm_v256i1_ty], [llvm_v4i64_ty, llvm_v256i1_ty], [IntrNoMem]>;

//===----------------------------------------------------------------------===//
// TCA - tightly-coupled accelerator
//===----------------------------------------------------------------------===//
// Matrix / Wide sub-registers manipulation
def int_kvx_xinsertwm : Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty, llvm_v512i1_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_xinsertvm : Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_xinsertvw : Intrinsic<[llvm_v512i1_ty],  [llvm_v512i1_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_xmovefmw : Intrinsic<[llvm_v512i1_ty], [llvm_v1024i1_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_xmovefmv : Intrinsic<[llvm_v256i1_ty], [llvm_v1024i1_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_xmovefwv : Intrinsic<[llvm_v256i1_ty], [llvm_v512i1_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_xbuild1024 : Intrinsic<[llvm_v1024i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty, llvm_v256i1_ty, llvm_v256i1_ty], [IntrNoMem]>;

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
def int_kvx_xfmma444hw : Intrinsic<[llvm_v512i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty, llvm_v512i1_ty], [IntrReadMem]>;

class KVX_TCA_Ternary<list<LLVMType> args>
    : Intrinsic<args, !listconcat(args, [llvm_v256i1_ty], [llvm_v256i1_ty]), [IntrReadMem]>;
def int_kvx_xmma444hbd0 : Intrinsic<[llvm_v1024i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty, llvm_v1024i1_ty, llvm_i32_ty], [IntrReadMem]>;
def int_kvx_xmma444hbd1 : Intrinsic<[llvm_v1024i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty, llvm_v1024i1_ty, llvm_i32_ty], [IntrReadMem]>;
def int_kvx_xmma484hbd : Intrinsic<[llvm_v1024i1_ty], [llvm_v512i1_ty, llvm_v256i1_ty, llvm_v1024i1_ty, llvm_i32_ty], [IntrReadMem]>;
def int_kvx_xmma444hd : Intrinsic<[llvm_v1024i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty, llvm_v1024i1_ty, llvm_i32_ty], [IntrReadMem]>;


def int_kvx_xmt44d : Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty], [IntrReadMem]>;
// fscalewv is not inplace, but has same args pattern
def int_kvx_xfscalewv : Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;

//===----------------------------------------------------------------------===//
// KV3 V1 TCA intrinsics
//===----------------------------------------------------------------------===//

def int_kvx_lv: Intrinsic<[llvm_v256i1_ty], [llvm_ptr_ty, llvm_i32_ty], [IntrReadMem]>;
def int_kvx_lv_cond: Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_ptr_ty, llvm_i64_ty, llvm_i32_ty, llvm_i32_ty], [IntrReadMem]>;
def int_kvx_lvc: Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty, llvm_ptr_ty, llvm_i32_ty, llvm_i32_ty], [IntrReadMem]>;
def int_kvx_lvc_cond: Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty, llvm_ptr_ty, llvm_i64_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrReadMem]>;
def int_kvx_sv: Intrinsic<[], [llvm_ptr_ty, llvm_v256i1_ty], [IntrWriteMem]>;
def int_kvx_sv_cond: Intrinsic<[], [llvm_ptr_ty, llvm_v256i1_ty, llvm_i64_ty, llvm_i32_ty], [IntrWriteMem]>;

//===----------------------------------------------------------------------===//
// KV3 V2 TCA intrinsics
//===----------------------------------------------------------------------===//
def int_kvx_xandno : Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty], [IntrNoMem]>;
def int_kvx_xando : Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty], [IntrNoMem]>;
def int_kvx_xclampwo : KVX_TCA_Ternary<[llvm_v256i1_ty]>;
def int_kvx_xcopyv: Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_xcopyx: Intrinsic<[llvm_v512i1_ty], [llvm_v512i1_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_xffma44hw : Intrinsic<[llvm_v512i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty, llvm_v512i1_ty, llvm_i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;
def int_kvx_xfmaxhx : Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty], [IntrNoMem]>;
def int_kvx_xfminhx : Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty], [IntrNoMem]>;
def int_kvx_xfmma484hw : Intrinsic<[llvm_v512i1_ty], [llvm_v512i1_ty, llvm_v512i1_ty, llvm_v512i1_ty, llvm_i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;
def int_kvx_xfnarrow44wh : Intrinsic<[llvm_v256i1_ty], [llvm_v512i1_ty, llvm_i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;
def int_kvx_xfscalewo : Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;
def int_kvx_xiorno : Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty], [IntrNoMem]>;
def int_kvx_xioro : Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty], [IntrNoMem]>;
def int_kvx_xload1024: Intrinsic<[llvm_v1024i1_ty], [llvm_ptr_ty, llvm_i32_ty], [IntrReadMem]>;
def int_kvx_xload256: Intrinsic<[llvm_v256i1_ty], [llvm_ptr_ty, llvm_i32_ty], [IntrReadMem]>;
def int_kvx_xload512: Intrinsic<[llvm_v512i1_ty], [llvm_ptr_ty, llvm_i32_ty], [IntrReadMem]>;
def int_kvx_xloadc1024: Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty, llvm_ptr_ty, llvm_v4i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrReadMem]>;
def int_kvx_xloadc256: Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_ptr_ty, llvm_i64_ty, llvm_i32_ty, llvm_i32_ty], [IntrReadMem]>;
def int_kvx_xloadc512: Intrinsic<[llvm_v512i1_ty], [llvm_v512i1_ty, llvm_ptr_ty, llvm_i64_ty, llvm_i32_ty, llvm_i32_ty], [IntrReadMem]>;
def int_kvx_xload1024q0: Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty, llvm_ptr_ty, llvm_i32_ty], [IntrReadMem]>;
def int_kvx_xload1024q1: Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty, llvm_ptr_ty, llvm_i32_ty], [IntrReadMem]>;
def int_kvx_xload1024q2: Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty, llvm_ptr_ty, llvm_i32_ty], [IntrReadMem]>;
def int_kvx_xload1024q3: Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty, llvm_ptr_ty, llvm_i32_ty], [IntrReadMem]>;
def int_kvx_xloadc1024q0: Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty, llvm_ptr_ty, llvm_i64_ty, llvm_i32_ty, llvm_i32_ty], [IntrReadMem]>;
def int_kvx_xloadc1024q1: Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty, llvm_ptr_ty, llvm_i64_ty, llvm_i32_ty, llvm_i32_ty], [IntrReadMem]>;
def int_kvx_xloadc1024q2: Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty, llvm_ptr_ty, llvm_i64_ty, llvm_i32_ty, llvm_i32_ty], [IntrReadMem]>;
def int_kvx_xloadc1024q3: Intrinsic<[llvm_v1024i1_ty], [llvm_v1024i1_ty, llvm_ptr_ty, llvm_i64_ty, llvm_i32_ty, llvm_i32_ty], [IntrReadMem]>;
def int_kvx_xmadd44bw0 : Intrinsic<[llvm_v512i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty, llvm_v512i1_ty, llvm_i32_ty], [IntrReadMem]>;
def int_kvx_xmadd44bw1 : Intrinsic<[llvm_v512i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty, llvm_v512i1_ty, llvm_i32_ty], [IntrReadMem]>;
def int_kvx_xmaddifwo : Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty, llvm_v256i1_ty, llvm_i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;
def int_kvx_xmma4164bw : Intrinsic<[llvm_v512i1_ty], [llvm_v512i1_ty, llvm_v512i1_ty, llvm_v512i1_ty, llvm_i32_ty], [IntrReadMem]>;
def int_kvx_xmma484bw : Intrinsic<[llvm_v512i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty, llvm_v512i1_ty, llvm_i32_ty], [IntrReadMem]>;
def int_kvx_xmsbfifwo : Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty, llvm_v256i1_ty, llvm_i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;
def int_kvx_xnando : Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty], [IntrNoMem]>;
def int_kvx_xnioro : Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty], [IntrNoMem]>;
def int_kvx_xneoro : Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty], [IntrNoMem]>;
def int_kvx_xrecvo: Intrinsic<[llvm_v256i1_ty], [llvm_i32_ty], [IntrHasSideEffects, Throws]>;
def int_kvx_xsbmm8dq : Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty], [IntrNoMem]>;
def int_kvx_xsbmmt8dq : Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty], [IntrNoMem]>;
def int_kvx_xsendo: Intrinsic<[], [llvm_v256i1_ty, llvm_i32_ty], [IntrHasSideEffects, Throws]>;
def int_kvx_xsendrecvo: Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_i32_ty, llvm_i32_ty], [IntrHasSideEffects, Throws]>;
def int_kvx_xsplatdo : Intrinsic<[llvm_v256i1_ty], [llvm_i64_ty], [IntrNoMem]>;
def int_kvx_xsplatov : Intrinsic<[llvm_v1024i1_ty], [llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_xsplatox : Intrinsic<[llvm_v512i1_ty], [llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_xstore256: Intrinsic<[], [llvm_v256i1_ty, llvm_ptr_ty], [IntrWriteMem]>;
def int_kvx_xstorec256: Intrinsic<[], [llvm_v256i1_ty, llvm_ptr_ty, llvm_i64_ty, llvm_i32_ty], [IntrWriteMem]>;
def int_kvx_xsx48bw : Intrinsic<[llvm_v1024i1_ty], [llvm_v256i1_ty], [IntrReadMem]>;
def int_kvx_xtrunc48wb : Intrinsic<[llvm_v256i1_ty], [llvm_v1024i1_ty], [IntrReadMem]>;
def int_kvx_xeoro : Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty], [IntrNoMem]>;
def int_kvx_xzx48bw : Intrinsic<[llvm_v1024i1_ty], [llvm_v256i1_ty], [IntrReadMem]>;

//===----------------------------------------------------------------------===//
// ACB 4.8 TCA intrinsics. Should remove them in ACB 4.10
//===----------------------------------------------------------------------===//
def int_kvx_alignov : Intrinsic<[llvm_v4i64_ty], [llvm_v256i1_ty, llvm_v256i1_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_alignv : Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty, llvm_i64_ty], [IntrNoMem]>;

//===----------------------------------------------------------------------===//
// Overloaded intrinsics
//===----------------------------------------------------------------------===//

def int_kvx_vec_cmp : Intrinsic<[llvm_anyint_ty], [llvm_anyvector_ty, LLVMMatchType<1>, llvm_i32_ty], [IntrNoMem, IntrWillReturn]>;

def int_kvx_abd: Intrinsic<[llvm_anyint_ty], [LLVMMatchType<0>, LLVMMatchType<0>, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_abs : Intrinsic<[llvm_anyint_ty], [LLVMMatchType<0>, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_alclr: Intrinsic<[llvm_anyint_ty], [llvm_ptr_ty], [IntrArgMemOnly]>;
def int_kvx_any: Intrinsic<[llvm_i64_ty], [llvm_any_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_any2: Intrinsic<[llvm_i64_ty], [llvm_any_ty, LLVMMatchType<0>, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_any4: Intrinsic<[llvm_i64_ty], [llvm_any_ty, LLVMMatchType<0>, LLVMMatchType<0>, LLVMMatchType<0>, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_avg: Intrinsic<[llvm_anyint_ty], [LLVMMatchType<0>, LLVMMatchType<0>, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_bitcnt: Intrinsic<[llvm_anyint_ty], [LLVMMatchType<0>, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_cat : Intrinsic<[llvm_anyvector_ty], [LLVMHalfElementsVectorType<0>, LLVMHalfElementsVectorType<0>], [IntrNoMem]>;
def int_kvx_fadd : Intrinsic<[llvm_anyfloat_ty], [LLVMMatchType<0>, LLVMMatchType<0>, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_faddc : Intrinsic<[llvm_anyfloat_ty], [LLVMMatchType<0>, LLVMMatchType<0>, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fcconj : Intrinsic<[llvm_anyfloat_ty], [LLVMMatchType<0>], [IntrNoMem]>;
def int_kvx_fcdiv: Intrinsic<[llvm_anyfloat_ty], [LLVMMatchType<0>, LLVMMatchType<0>, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fcfma : Intrinsic<[llvm_anyfloat_ty], [LLVMMatchType<0>, LLVMMatchType<0>, LLVMMatchType<0>, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fcfms : Intrinsic<[llvm_anyfloat_ty], [LLVMMatchType<0>, LLVMMatchType<0>, LLVMMatchType<0>, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fcmul : Intrinsic<[llvm_anyfloat_ty], [LLVMMatchType<0>, LLVMMatchType<0>, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffdma: Intrinsic<[llvm_anyfloat_ty], [LLVMDoubleElementsOfVecOrScalar<0>, LLVMDoubleElementsOfVecOrScalar<0>, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffdmas: Intrinsic<[llvm_anyfloat_ty], [LLVMDoubleElementsOfVecOrScalar<0>, LLVMDoubleElementsOfVecOrScalar<0>, LLVMMatchType<0>, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffdmda: Intrinsic<[llvm_anyfloat_ty], [LLVMDoubleElementsOfVecOrScalar<0>, LLVMDoubleElementsOfVecOrScalar<0>, LLVMMatchType<0>, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffdmds: Intrinsic<[llvm_anyfloat_ty], [LLVMDoubleElementsOfVecOrScalar<0>, LLVMDoubleElementsOfVecOrScalar<0>, LLVMMatchType<0>, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffdms: Intrinsic<[llvm_anyfloat_ty], [LLVMDoubleElementsOfVecOrScalar<0>, LLVMDoubleElementsOfVecOrScalar<0>, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffdmsa: Intrinsic<[llvm_anyfloat_ty], [LLVMDoubleElementsOfVecOrScalar<0>, LLVMDoubleElementsOfVecOrScalar<0>, LLVMMatchType<0>, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffma : Intrinsic<[llvm_anyfloat_ty], [LLVMMatchType<0>, LLVMMatchType<0>, LLVMMatchType<0>, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmax : Intrinsic<[llvm_anyfloat_ty], [LLVMTruncatedType<0>, LLVMTruncatedType<0>, LLVMMatchType<0>, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffms : Intrinsic<[llvm_anyfloat_ty], [LLVMMatchType<0>, LLVMMatchType<0>, LLVMMatchType<0>, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_ffmsx : Intrinsic<[llvm_anyfloat_ty], [LLVMTruncatedType<0>, LLVMTruncatedType<0>, LLVMMatchType<0>, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmul : Intrinsic<[llvm_anyfloat_ty], [LLVMMatchType<0>, LLVMMatchType<0>, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fmulx : Intrinsic<[llvm_anyfloat_ty], [LLVMTruncatedType<0>, LLVMTruncatedType<0>, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fnarrow: Intrinsic<[llvm_anyfloat_ty], [LLVMExtendedType<0>, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fneg: Intrinsic<[llvm_anyfloat_ty], [LLVMMatchType<0>], [IntrNoMem]>;
def int_kvx_fsbf : Intrinsic<[llvm_anyfloat_ty], [LLVMMatchType<0>, LLVMMatchType<0>, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fsbfc : Intrinsic<[llvm_anyfloat_ty], [LLVMMatchType<0>, LLVMMatchType<0>, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fsdiv: Intrinsic<[llvm_anyfloat_ty], [LLVMMatchType<0>, LLVMMatchType<0>, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fsrec: Intrinsic<[llvm_anyfloat_ty], [LLVMMatchType<0>, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_fsrsr: Intrinsic<[llvm_anyfloat_ty], [LLVMMatchType<0>], [IntrNoMem]>;
def int_kvx_fwiden: Intrinsic<[llvm_anyfloat_ty], [LLVMTruncatedType<0>, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_high : Intrinsic<[llvm_anyvector_ty], [LLVMDoubleElementsOfVecOrScalar<0>], [IntrNoMem]>;
def int_kvx_low : Intrinsic<[llvm_anyvector_ty], [LLVMDoubleElementsOfVecOrScalar<0>], [IntrNoMem]>;
def int_kvx_maddx: Intrinsic<[llvm_anyint_ty], [LLVMTruncatedType<0>, LLVMTruncatedType<0>, LLVMMatchType<0>, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_max: Intrinsic<[llvm_anyfloat_ty], [LLVMMatchType<0>, LLVMMatchType<0>], [IntrNoMem]>;
def int_kvx_min: Intrinsic<[llvm_anyfloat_ty], [LLVMMatchType<0>, LLVMMatchType<0>], [IntrNoMem]>;
def int_kvx_msbfx: Intrinsic<[llvm_anyint_ty], [LLVMTruncatedType<0>, LLVMTruncatedType<0>, LLVMMatchType<0>, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_mulx: Intrinsic<[llvm_anyint_ty], [LLVMTruncatedType<0>, LLVMTruncatedType<0>, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_narrowint: Intrinsic<[llvm_anyint_ty], [LLVMExtendedType<0>, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_select_vec: Intrinsic<[llvm_anyvector_ty], [LLVMMatchType<0>, LLVMMatchType<0>, LLVMVectorOfBitcastsToInt<0>, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_select: Intrinsic<[llvm_any_ty], [LLVMMatchType<0>, LLVMMatchType<0>, llvm_i64_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_shl: Intrinsic<[llvm_anyint_ty], [LLVMMatchType<0>, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_shr: Intrinsic<[llvm_anyint_ty], [LLVMMatchType<0>, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_stsu: Intrinsic<[llvm_anyint_ty], [LLVMMatchType<0>, LLVMMatchType<0>], [IntrNoMem]>;
def int_kvx_widenint: Intrinsic<[llvm_anyint_ty], [LLVMTruncatedType<0>, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_wideninte: Intrinsic<[llvm_anyint_ty], [LLVMSubdivide2VectorType<0>, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_widenintes: Intrinsic<[llvm_i64_ty], [llvm_v2i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_wideninto: Intrinsic<[llvm_anyint_ty], [LLVMSubdivide2VectorType<0>, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_widenintos: Intrinsic<[llvm_i64_ty], [llvm_v2i32_ty, llvm_i32_ty], [IntrNoMem]>;
def int_kvx_xaccesso : Intrinsic<[llvm_v4i64_ty], [llvm_anyvector_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_xaligno : Intrinsic<[llvm_v256i1_ty], [llvm_anyvector_ty, llvm_i64_ty], [IntrNoMem]>;
def int_kvx_xpreload : Intrinsic<[llvm_anyint_ty], [LLVMMatchType<0>, llvm_ptr_ty, llvm_i64_ty, llvm_i32_ty, llvm_i32_ty], [IntrReadMem]>;
def int_kvx_xsplat : Intrinsic<[llvm_anyint_ty], [llvm_i64_ty], [IntrNoMem]>;
}  // TargetPrefix = "kvx"
