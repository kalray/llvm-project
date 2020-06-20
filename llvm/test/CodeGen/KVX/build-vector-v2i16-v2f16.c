// RUN: clang -O2 -S %s -o - | FileCheck %s

typedef short __attribute__((__vector_size__(2 * sizeof(short)))) v2i16;
typedef _Float16 __attribute__((__vector_size__(2 * sizeof(_Float16)))) v2f16;

v2i16 foo_v2i16(v2i16 x) {
  x[0] = -1;
  x[1] = -2;
  return x;

  // CHECK: make $r0
  // CHECK-NEXT: ret
}

v2f16 foo_v2f16(v2f16 x) {
  x[0] = -1.5;
  x[1] = -2.6;
  return x;

  // CHECK: make $r0
  // CHECK-NEXT: ret
}
