// NOTE: Assertions have been autogenerated by utils/update_cc_test_checks.py
// RUN: %clang_cc1 -triple kvx-kalray-cos -S -verify %s

#define half _Float16
typedef half __attribute__((__vector_size__(4 * sizeof(half)))) v4f16;

v4f16 xfail_shiftfhq_neg(v4f16 v, half b){
    return __builtin_kvx_shiftfhq(v, -1, b); // expected-error {{Unsigned immediate of 2 bits expected}} expected-error {{cannot compile this builtin function yet}}
}
