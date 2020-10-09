// RUN: clang -target kvx-cos -S %s -O2 -o - | FileCheck %s

typedef short v2i16 __attribute__((__vector_size__(sizeof(short) * 2)));

v2i16 sri_v2i16(v2i16 a) {
  v2i16 s = a >> 3;
  return s;
  // CHECK-LABEL: sri_v2i16:
  // CHECK: make $r1 = 0x30003
  // CHECK: srahqs $r0 = $r0, $r1
  // CHECK: ret
}

v2i16 sli_v2i16(v2i16 a) {
  v2i16 s = a << 3;
  return s;
  // CHECK-LABEL: sli_v2i16:
  // CHECK: make $r1 = 0x30003
  // CHECK: sllhqs $r0 = $r0, $r1
  // CHECK: ret
}

v2i16 srr_v2i16(v2i16 a, short c) {
  v2i16 s = a >> c;
  return s;
  // CHECK-LABEL: srr_v2i16:
  // CHECK: insf $r1 = $r1, 31, 16
  // CHECK: srahqs $r0 = $r0, $r1
  // CHECK: ret
}

v2i16 slr_v2i16(v2i16 a, short c) {
  v2i16 s = a << c;
  return s;
  // CHECK-LABEL: slr_v2i16:
  // CHECK: insf $r1 = $r1, 31, 16
  // CHECK: sllhqs $r0 = $r0, $r1
  // CHECK: ret
}
