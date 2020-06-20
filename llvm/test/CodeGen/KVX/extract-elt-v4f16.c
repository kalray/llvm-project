// RUN: clang -S -g -O2 %s -o - | FileCheck %s

typedef short __attribute__((__vector_size__(8))) v4i16;
typedef _Float16 __attribute__((__vector_size__(8))) v4f16;

_Float16 f1(v4f16 v) {
  return v[0];
  // CHECK: extfz
}

_Float16 f2(v4f16 v) {
  return v[1];
  // CHECK: extfz
}

_Float16 f3(v4f16 v) {
  return v[2];
  // CHECK: extfz
}

_Float16 f4(v4f16 v) {
  return v[3];
  // CHECK: srld
}

_Float16 fidx(v4f16 v, int idx) { return v[idx]; }
