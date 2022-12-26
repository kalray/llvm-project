//===-- KVXModifierInfo.td - KVX Modifier defs -----****----*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

// This file was automatically generated,
//   *DO NOT EDIT*,
//   please contact code owner.
// Last generated: 2022-10-18 21:47:54.077870.


class Scalarcond<int N> : PatLeaf<(i32 N)>;
def scalarcond_dnez : Scalarcond<0>;
def scalarcond_deqz : Scalarcond<1>;
def scalarcond_dltz : Scalarcond<2>;
def scalarcond_dgez : Scalarcond<3>;
def scalarcond_dlez : Scalarcond<4>;
def scalarcond_dgtz : Scalarcond<5>;
def scalarcond_odd : Scalarcond<6>;
def scalarcond_even : Scalarcond<7>;
def scalarcond_wnez : Scalarcond<8>;
def scalarcond_weqz : Scalarcond<9>;
def scalarcond_wltz : Scalarcond<10>;
def scalarcond_wgez : Scalarcond<11>;
def scalarcond_wlez : Scalarcond<12>;
def scalarcond_wgtz : Scalarcond<13>;

class Simplecond<int N> : PatLeaf<(i32 N)>;
def simplecond_nez : Simplecond<0>;
def simplecond_eqz : Simplecond<1>;
def simplecond_ltz : Simplecond<2>;
def simplecond_gez : Simplecond<3>;
def simplecond_lez : Simplecond<4>;
def simplecond_gtz : Simplecond<5>;
def simplecond_odd : Simplecond<6>;
def simplecond_even : Simplecond<7>;

class Comparison<int N> : PatLeaf<(i32 N)>;
def comparison_ne : Comparison<0>;
def comparison_eq : Comparison<1>;
def comparison_lt : Comparison<2>;
def comparison_ge : Comparison<3>;
def comparison_le : Comparison<4>;
def comparison_gt : Comparison<5>;
def comparison_ltu : Comparison<6>;
def comparison_geu : Comparison<7>;
def comparison_leu : Comparison<8>;
def comparison_gtu : Comparison<9>;
def comparison_all : Comparison<10>;
def comparison_nall : Comparison<11>;
def comparison_any : Comparison<12>;
def comparison_none : Comparison<13>;

class Floatcomp<int N> : PatLeaf<(i32 N)>;
def floatcomp_one : Floatcomp<0>;
def floatcomp_ueq : Floatcomp<1>;
def floatcomp_oeq : Floatcomp<2>;
def floatcomp_une : Floatcomp<3>;
def floatcomp_olt : Floatcomp<4>;
def floatcomp_uge : Floatcomp<5>;
def floatcomp_oge : Floatcomp<6>;
def floatcomp_ult : Floatcomp<7>;

class Rounding<int N> : PatLeaf<(i32 N)>;
def rounding_rn : Rounding<0>;
def rounding_ru : Rounding<1>;
def rounding_rd : Rounding<2>;
def rounding_rz : Rounding<3>;
def rounding_rna : Rounding<4>;
def rounding_rnz : Rounding<5>;
def rounding_ro : Rounding<6>;
def rounding_ : Rounding<7>;

class Silent<int N> : PatLeaf<(i32 N)>;
def silent_ : Silent<0>;
def silent_s : Silent<1>;

class Roundint<int N> : PatLeaf<(i32 N)>;
def roundint_rn : Roundint<0>;
def roundint_ru : Roundint<1>;
def roundint_rd : Roundint<2>;
def roundint_rz : Roundint<3>;
def roundint_rhu : Roundint<4>;

class Saturate<int N> : PatLeaf<(i32 N)>;
def saturate_sat : Saturate<0>;
def saturate_satu : Saturate<1>;

class Rectify<int N> : PatLeaf<(i32 N)>;
def rectify_ : Rectify<0>;
def rectify_relu : Rectify<1>;

class Variant<int N> : PatLeaf<(i32 N)>;
def variant_ : Variant<0>;
def variant_s : Variant<1>;
def variant_u : Variant<2>;
def variant_us : Variant<3>;

class Speculate<int N> : PatLeaf<(i32 N)>;
def speculate_ : Speculate<0>;
def speculate_s : Speculate<1>;

class Scale<int N> : PatLeaf<(i32 N)>;
def scale_ : Scale<0>;
def scale_xs : Scale<1>;

class Splat32<int N> : PatLeaf<(i32 N)>;
def splat32_ : Splat32<0>;
def splat32_at : Splat32<1>;

class Conjugate<int N> : PatLeaf<(i32 N)>;
def conjugate_ : Conjugate<0>;
def conjugate_c : Conjugate<1>;

class Transpose<int N> : PatLeaf<(i32 N)>;
def transpose_nn : Transpose<0>;
def transpose_tn : Transpose<1>;
def transpose_nt : Transpose<2>;
def transpose_tt : Transpose<3>;

class Boolcas<int N> : PatLeaf<(i32 N)>;
def boolcas_v : Boolcas<0>;
def boolcas_ : Boolcas<1>;

class Coherency<int N> : PatLeaf<(i32 N)>;
def coherency_ : Coherency<0>;
def coherency_g : Coherency<1>;
def coherency_s : Coherency<2>;

class Shufflev<int N> : PatLeaf<(i32 N)>;
def shufflev_ : Shufflev<0>;
def shufflev_td : Shufflev<1>;

class Shufflex<int N> : PatLeaf<(i32 N)>;
def shufflex_ : Shufflex<0>;
def shufflex_zd : Shufflex<1>;
def shufflex_ud : Shufflex<2>;
def shufflex_tq : Shufflex<3>;

class Lsomask<int N> : PatLeaf<(i32 N)>;
def lsomask_u0 : Lsomask<0>;
def lsomask_u1 : Lsomask<1>;
def lsomask_u2 : Lsomask<2>;
def lsomask_u3 : Lsomask<3>;
def lsomask_mt : Lsomask<4>;
def lsomask_mf : Lsomask<5>;
def lsomask_mtc : Lsomask<6>;
def lsomask_mfc : Lsomask<7>;

class Lsumask<int N> : PatLeaf<(i32 N)>;
def lsumask_dnez : Lsumask<0>;
def lsumask_deqz : Lsumask<1>;
def lsumask_wnez : Lsumask<2>;
def lsumask_weqz : Lsumask<3>;
def lsumask_mt : Lsumask<4>;
def lsumask_mf : Lsumask<5>;
def lsumask_mtc : Lsumask<6>;
def lsumask_mfc : Lsumask<7>;

class Lsupack<int N> : PatLeaf<(i32 N)>;
def lsupack_ : Lsupack<0>;
def lsupack_q : Lsupack<1>;
def lsupack_d : Lsupack<2>;
def lsupack_w : Lsupack<3>;
def lsupack_h : Lsupack<4>;
def lsupack_b : Lsupack<5>;

class Hindex<int N> : PatLeaf<(i32 N)>;
def hindex_h0 : Hindex<0>;
def hindex_h1 : Hindex<1>;

class Qindex<int N> : PatLeaf<(i32 N)>;
def qindex_q0 : Qindex<0>;
def qindex_q1 : Qindex<1>;
def qindex_q2 : Qindex<2>;
def qindex_q3 : Qindex<3>;

class Cachelev<int N> : PatLeaf<(i32 N)>;
def cachelev_l1 : Cachelev<0>;
def cachelev_l2 : Cachelev<1>;

class Accesses<int N> : PatLeaf<(i32 N)>;
def accesses_ : Accesses<0>;
def accesses_w : Accesses<1>;
def accesses_r : Accesses<2>;
def accesses_wa : Accesses<3>;

class Channel<int N> : PatLeaf<(i32 N)>;
def channel_f : Channel<0>;
def channel_b : Channel<1>;
