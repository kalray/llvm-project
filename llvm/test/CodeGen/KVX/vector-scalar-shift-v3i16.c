// RUN: clang -S %s -O3 -o - | FileCheck %s

typedef signed short v3signed_short
    __attribute__((__vector_size__(sizeof(signed short) * 3)));

v3signed_short shiftR_imm(v3signed_short a) {
  v3signed_short s = a >> 3;
  return s;
  // CHECK: shiftR_imm
  // CHECK: srahqs
  // CHECK: ret
}

v3signed_short shiftL_imm(v3signed_short a) {
  v3signed_short s = a << 3;
  return s;
  // CHECK: shiftL_imm
  // CHECK: sllhqs
  // CHECK: ret
}

v3signed_short shiftR(v3signed_short a, signed short c) {
  v3signed_short s = a >> c;
  return s;
  // CHECK: shiftR
  // CHECK: srahqs
  // CHECK: ret
}

v3signed_short shiftL(v3signed_short a, signed short c) {
  v3signed_short s = a << c;
  return s;
  // CHECK: shiftL
  // CHECK: sllhqs
  // CHECK: ret
}
