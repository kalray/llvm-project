// RUN: %clang_cc1 -triple kvx-kalray-cos -S -verify %s

typedef float __attribute__((__vector_size__(4 * sizeof(float)))) v4f32;

v4f32 fmms222w(v4f32 lhs, v4f32 rhs, v4f32 acc){
    return __builtin_kvx_fmms222w(lhs, rhs, acc, ".t"); // expected-error {{invalid rounding modifier}} expected-error {{invalid silent modifier}} expected-error {{Invalid matrix transpose modifier.}} expected-error {{cannot compile this builtin function yet}}
}
