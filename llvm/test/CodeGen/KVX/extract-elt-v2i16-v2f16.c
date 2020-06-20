// RUN: clang -O2 -S %s -o - | FileCheck %s

typedef short __attribute__((__vector_size__(2 * sizeof(short)))) v2i16;
typedef unsigned short
    __attribute__((__vector_size__(2 * sizeof(unsigned short)))) v2i16u;
typedef _Float16 __attribute__((__vector_size__(2 * sizeof(_Float16)))) v2f16;

long ext_v2i16_0(v2i16 x, long y) {
  long z = x[0] + y;
  return z;
  // CHECK: ext_v2i16_0
  // CHECK: sxhd
  // CHECK-NEXT: ;;
  // CHECK-NEXT: addd
  // CHECK: ret
}

long ext_v2i16_1(v2i16 x, long y) {
  long z = x[1] + y;
  return z;

  // CHECK: ext_v2i16_1
  // CHECK: extfs
  // CHECK-NEXT: ;;
  // CHECK-NEXT: addd
  // CHECK: ret
}

short ext_v2i16_s_0(v2i16 x) {
  return x[0];

  // CHECK: ext_v2i16_s_0
  // CHECK: zxhd
  // CHECK-NEXT: ret
}

short ext_v2i16_s_1(v2i16 x) {
  return x[1];

  // CHECK: ext_v2i16_s_1
  // CHECK: srlw
  // CHECK-NEXT: ret
}

unsigned short ext_v2i16_us_0(v2i16 x) {
  return x[0];

  // CHECK: ext_v2i16_us_0
  // CHECK: zxhd
  // CHECK-NEXT: ret
}

unsigned short ext_v2i16_us_1(v2i16 x) {
  return x[1];

  // CHECK: ext_v2i16_us_1
  // CHECK: srlw
  // CHECK-NEXT: ret
}

_Float16 ext_v2f16_0(v2f16 x) {
  return x[0];

  // CHECK: ext_v2f16_0
  // CHECK: zxhd
  // CHECK-NEXT: ret
}

_Float16 ext_v2f16_1(v2f16 x) {
  return x[1];

  // CHECK: ext_v2f16_1
  // CHECK: srld
  // CHECK-NEXT: ret
}
