// RUN: clang -S %s -O3 -o - | FileCheck %s

typedef signed short v4comp
    __attribute__((__vector_size__(sizeof(signed short) * 4)));
typedef signed short v4signed_short
    __attribute__((__vector_size__(sizeof(signed short) * 4)));

v4comp eq(v4signed_short a, v4signed_short b) {
  return a == b;
  // CHECK: eq
  // CHECK: compnhq.eq
  // CHECK: ret
}

v4comp neq(v4signed_short a, v4signed_short b) {
  return a != b;
  // CHECK: neq
  // CHECK: compnhq.ne
  // CHECK: ret
}

v4comp gt(v4signed_short a, v4signed_short b) {
  return a > b;
  // CHECK: gt
  // CHECK: compnhq.gt
  // CHECK: ret
}

v4comp lt(v4signed_short a, v4signed_short b) {
  return a < b;
  // CHECK: lt
  // CHECK: compnhq.lt
  // CHECK: ret
}

v4comp gte(v4signed_short a, v4signed_short b) {
  return a >= b;
  // CHECK: gte
  // CHECK: compnhq.ge
  // CHECK: ret
}

v4comp lte(v4signed_short a, v4signed_short b) {
  return a <= b;
  // CHECK: lte
  // CHECK: compnhq.le
  // CHECK: ret
}
