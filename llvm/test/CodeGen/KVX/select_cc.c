// RUN: clang -target kvx-cos -O3 -S %s -o - | FileCheck %s

int f_select_cc_i32(int c, int c2, int a, int b) {
  return c > c2 ? a : b;
  // CHECK: f_select_cc_i32
  // CHECK: cmoved.wnez
  // CHECK: ret
}

int f_select_cc_i64(long c, long c2, int a, int b) {
  return c > c2 ? a : b;
  // CHECK: f_select_cc_i64
  // CHECK: cmoved.wnez
  // CHECK: ret
}

typedef _Float16 __attribute__((__vector_size__(8))) v4f16;
v4f16 f_Select32PAT(v4f16 x, v4f16 y) {
  v4f16 z;
  z[0] = x[0] < y[0] ? y[0] : x[0];
  z[1] = x[1] < y[1] ? y[1] : x[1];
  z[2] = x[2] < y[2] ? y[2] : x[2];
  z[3] = x[3] < y[3] ? y[3] : x[3];
  return z;
  // CHECK: f_Select32PAT
  // CHECK: cmoved.wnez
  // CHECK: cmoved.wnez
  // CHECK: cmoved.wnez
  // CHECK: cmoved.wnez
  // CHECK: ret
}

_Float16 f_Select64PAT(long c, _Float16 a, _Float16 b) {
  return c == 0 ? a : b;
  // CHECK: f_Select64PAT
  // CHECK: cmoved.deqz
  // CHECK: ret
}

typedef float __attribute__((__vector_size__(8))) v2f32;
v2f32 f_select_cc_v2f32(int c, int c2, v2f32 a, v2f32 b) {
  return c > c2 ? a : b;
  // CHECK: f_select_cc_v2f32
  // CHECK: cmoved.weqz
  // CHECK: ret
}
