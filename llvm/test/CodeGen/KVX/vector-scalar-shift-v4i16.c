// RUN: clang -S %s -O3 -o - | FileCheck %s

typedef signed short v4signed_short
    __attribute__((__vector_size__(sizeof(signed short) * 4)));

v4signed_short shiftR_imm(v4signed_short a) {
  v4signed_short s = a >> 3;
  return s;
  // CHECK: shiftR_imm
  // CHECK: srahqs
  // CHECK: ret
}

v4signed_short shiftL_imm(v4signed_short a) {
  v4signed_short s = a << 3;
  return s;
  // CHECK: shiftL_imm
  // CHECK: sllhqs
  // CHECK: ret
}

v4signed_short shiftR(v4signed_short a, unsigned c) {
  v4signed_short s = a >> c;
  return s;
  // CHECK: shiftR
  // CHECK: srahqs
  // CHECK: ret
}

v4signed_short shiftL(v4signed_short a, unsigned c) {
  v4signed_short s = a << c;
  return s;
  // CHECK: shiftL
  // CHECK: sllhqs
  // CHECK: ret
}
