// RUN: clang -S %s -O3 -o - | FileCheck %s
typedef float v2float __attribute__((__vector_size__(sizeof(float) * 2)));
typedef float v2comp __attribute__((__vector_size__(sizeof(float) * 2)));

v2comp eq(v2float a, v2float b) {
  return a == b;
  // CHECK: eq
  // CHECK: fcompnwp
  // CHECK: ret
}

v2comp neq(v2float a, v2float b) {
  return a != b;
  // CHECK: neq
  // CHECK: fcompnwp
  // CHECK: ret
}

v2comp gt(v2float a, v2float b) {
  return a > b;
  // CHECK: gt
  // CHECK: fcompnwp
  // CHECK: ret
}

v2comp lt(v2float a, v2float b) {
  return a < b;
  // CHECK: lt
  // CHECK: fcompnwp
  // CHECK: ret
}

v2comp gte(v2float a, v2float b) {
  return a >= b;
  // CHECK: gte
  // CHECK: fcompnwp
  // CHECK: ret
}

v2comp lte(v2float a, v2float b) {
  return a <= b;
  // CHECK: lte
  // CHECK: fcompnwp
  // CHECK: ret
}
