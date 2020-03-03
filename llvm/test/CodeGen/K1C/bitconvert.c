// RUN: clang -target k1c-cos -S -O2 %s -o - | FileCheck %s

typedef _Float16 __attribute__((__vector_size__(4 * sizeof(_Float16)))) v4f16;
typedef short __attribute__((__vector_size__(4 * sizeof(short)))) v4i16;

v4i16 v4f16_to_v4i16(v4f16 x) {
  return (v4i16)x;
  // CHECK: v4f16_to_v4i16:
  // CHECK-NEXT: ret
}

v4f16 v4i16_to_v4f16(v4i16 x) {
  return (v4f16)x;
  // CHECK: v4i16_to_v4f16:
  // CHECK-NEXT: ret
}
