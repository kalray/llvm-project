// RUN: clang -S %s -O3 -o - | FileCheck %s

typedef signed int v2signed_int
    __attribute__((__vector_size__(sizeof(signed int) * 2)));

v2signed_int shiftR_imm(v2signed_int a) {
  v2signed_int s = a >> 3;
  return s;
  // CHECK: shiftR_imm
  // CHECK: srawps
  // CHECK: ret
}

v2signed_int shiftL_imm(v2signed_int a) {
  v2signed_int s = a << 3;
  return s;
  // CHECK: shiftL_imm
  // CHECK: sllwps
  // CHECK: ret
}

v2signed_int shiftR(v2signed_int a, unsigned c) {
  v2signed_int s = a >> c;
  return s;
  // CHECK: shiftR
  // CHECK: srawps
  // CHECK: ret
}

v2signed_int shiftL(v2signed_int a, unsigned c) {
  v2signed_int s = a << c;
  return s;
  // CHECK: shiftL
  // CHECK: sllwps
  // CHECK: ret
}
