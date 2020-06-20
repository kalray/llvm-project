// RUN: clang -S %s -O3 -o - | FileCheck %s

typedef signed int v2comp
    __attribute__((__vector_size__(sizeof(signed int) * 2)));
typedef signed int v2signed_int
    __attribute__((__vector_size__(sizeof(signed int) * 2)));

v2comp eq(v2signed_int a, v2signed_int b) {
  return a == b;
  // CHECK: eq
  // CHECK: compnwp
  // CHECK: ret
}

v2comp neq(v2signed_int a, v2signed_int b) {
  return a != b;
  // CHECK: neq
  // CHECK: compnwp
  // CHECK: ret
}

v2comp gt(v2signed_int a, v2signed_int b) {
  return a > b;
  // CHECK: gt
  // CHECK: compnwp
  // CHECK: ret
}

v2comp lt(v2signed_int a, v2signed_int b) {
  return a < b;
  // CHECK: lt
  // CHECK: compnwp
  // CHECK: ret
}

v2comp gte(v2signed_int a, v2signed_int b) {
  return a >= b;
  // CHECK: gte
  // CHECK: compnwp
  // CHECK: ret
}

v2comp lte(v2signed_int a, v2signed_int b) {
  return a <= b;
  // CHECK: lte
  // CHECK: compnwp
  // CHECK: ret
}
