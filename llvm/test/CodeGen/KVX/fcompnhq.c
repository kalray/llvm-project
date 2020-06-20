// RUN: clang -S %s -O3 -o - | FileCheck %s

typedef _Float16 v4comp __attribute__((__vector_size__(sizeof(_Float16) * 4)));
typedef _Float16 v4_Float16
    __attribute__((__vector_size__(sizeof(_Float16) * 4)));
v4comp eq(v4_Float16 a, v4_Float16 b) {
  return a == b;
  // CHECK: eq
  // CHECK: fcompnhq
  // CHECK: ret
}

v4comp neq(v4_Float16 a, v4_Float16 b) {
  return a != b;
  // CHECK: neq
  // CHECK: fcompnhq
  // CHECK: ret
}

v4comp gt(v4_Float16 a, v4_Float16 b) {
  return a > b;
  // CHECK: gt
  // CHECK: fcompnhq
  // CHECK: ret
}

v4comp lt(v4_Float16 a, v4_Float16 b) {
  return a < b;
  // CHECK: lt
  // CHECK: fcompnhq
  // CHECK: ret
}

v4comp gte(v4_Float16 a, v4_Float16 b) {
  return a >= b;
  // CHECK: gte
  // CHECK: fcompnhq
  // CHECK: ret
}

v4comp lte(v4_Float16 a, v4_Float16 b) {
  return a <= b;
  // CHECK: lte
  // CHECK: fcompnhq
  // CHECK: ret
}
