// RUN: clang -S %s -O3 -o - | FileCheck %s

typedef short __attribute__((__vector_size__(2 * sizeof(short)))) v2i16;
typedef short __attribute__((__vector_size__(4 * sizeof(short)))) v4i16;
typedef int __attribute__((__vector_size__(2 * sizeof(int)))) v2i32;

int f_i32(int x) {
  return ~x;
  // CHECK: f_i32
  // CHECK: notw
}

long f_i64(long x) {
  return ~x;
  // CHECK: f_i64
  // CHECK: notd
}

v2i32 f_v2i32_imp(v2i32 x) {
  return ~x;
  // CHECK: f_v2i32_imp
  // CHECK: notd
}

v2i32 f_v2i32_exp(v2i32 x) {
  v2i32 y;
  y[0] = -1;
  y[1] = -1;

  return x ^ y;
  // CHECK: f_v2i32_exp
  // CHECK: notd
}

v2i16 f_v2i16_imp(v2i16 x) {
  return ~x;
  // CHECK: f_v2i16_imp
  // CHECK: notw
}

v2i16 f_v2i16_exp(v2i16 x) {
  v2i16 y;
  y[0] = -1;
  y[1] = -1;
  return x ^ y;

  // CHECK: f_v2i16_exp
  // CHECK: notw
}

v4i16 f_v4i16_imp(v4i16 x) {
  return ~x;
  // CHECK: f_v4i16_imp
  // CHECK: notd
}

v4i16 f_v4i16_exp(v4i16 x) {
  v4i16 y;
  y[0] = -1;
  y[1] = -1;
  y[2] = -1;
  y[3] = -1;
  return x ^ y;
  // CHECK: f_v4i16_exp
  // CHECK: notd
}
