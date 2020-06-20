// RUN: clang -S -g -O2 %s -o - | FileCheck %s

typedef short __attribute__((__vector_size__(4))) v2i16;
typedef short __attribute__((__vector_size__(8))) v4i16;
typedef int __attribute__((__vector_size__(8))) v2i32;
typedef _Float16 __attribute__((__vector_size__(4))) v2f16;
typedef _Float16 __attribute__((__vector_size__(8))) v4f16;
typedef float __attribute__((__vector_size__(8))) v2f32;

v2i16 foo_v2i16(v2i16 x) {
  return -x;
  // CHECK: neghq
}

v4i16 foo_v4i16(v4i16 x) {
  return -x;
  // CHECK: neghq
}

v2i32 foo_v2i32(v2i32 x) {
  return -x;
  // CHECK: negwp
}

v2f16 foo_v2f16(v2f16 x) {
  return -x;
  // CHECK: fneghq
}

v4f16 foo_v4f16(v4f16 x) {
  return -x;
  // CHECK: fneghq
}

v2f32 foo_v2f32(v2f32 x) {
  return -x;
  // CHECK: fnegwp
}

int foo_int(int x) {
  return -x;
  // CHECK: negw
}

long foo_long(long x) {
  return -x;
  // CHECK: negd
}
