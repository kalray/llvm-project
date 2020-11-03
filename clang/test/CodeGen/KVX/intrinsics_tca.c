// RUN: %clang_cc1 -S -triple=kvx-kalray-cos -emit-llvm %s -o - -O0 | FileCheck %s
//---------------------------------------------------------------------------//
// GPR to TCA registers copy
//---------------------------------------------------------------------------//
// XFAIL: *
typedef char __attribute__((__vector_size__(8))) v8i8_t;
typedef char __attribute__((__vector_size__(16))) v16i8_t;

void test_movetohi_v8i8(v8i8_t a, v8i8_t b) {
  __builtin_kvx_movetohi((long)a, (long)b);
}

void test_movetobvlo_v8i8(v8i8_t a, v8i8_t b) {
  __builtin_kvx_movetolo((long)a, (long)b);
}

typedef short __attribute__((__vector_size__(8))) v4i16_t;
typedef short __attribute__((__vector_size__(16))) v8i16_t;
void test_movetobvhi_v4i16(v4i16_t a, v4i16_t b) {
  __builtin_kvx_movetohi((long)a, (long)b);
}

void test_movetobvlo_v4i16(v4i16_t a, v4i16_t b) {
  __builtin_kvx_movetolo((long)a, (long)b);
}

typedef int __attribute__((__vector_size__(8))) v2i32_t;
typedef int __attribute__((__vector_size__(16))) v4i32_t;
void test_movetobvhi_v2i32(v2i32_t a, v2i32_t b) {
  __builtin_kvx_movetohi((long)a, (long)b);
}

void test_movetobvlo_v2i32(v2i32_t a, v2i32_t b) {
  __builtin_kvx_movetolo((long)a, (long)b);
}

typedef long __attribute__((__vector_size__(16))) v2i64_t;
void test_movetobvhi_i64(long a, long b) {
  __builtin_kvx_movetohi(a, b);
}

void test_movetobvlo_i64(long a, long b) {
  __builtin_kvx_movetolo(a, b);
}

typedef float __attribute__((__vector_size__(8))) v2f32_t;
typedef float __attribute__((__vector_size__(16))) v4f32_t;
void test_movetobvhi_v2f32(v2f32_t a, v2f32_t b) {
  __builtin_kvx_movetohi((long)a, (long)b);
}

void test_movetobvlo_v2f32(v2f32_t a, v2f32_t b) {
  __builtin_kvx_movetolo((long)a, (long)b);
}

typedef double __attribute__((__vector_size__(16))) v2f64_t;
typedef union {
  long i;
  double f;
} double_t;

void test_movetobvhi_f64(double_t a, double_t b) {
  __builtin_kvx_movetohi(a.i, b.i);
}

void test_movetobvlo_f64(double_t a, double_t b) {
  __builtin_kvx_movetolo(a.i, b.i);
}
