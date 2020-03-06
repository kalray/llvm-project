// RUN: clang -target kvx-cos -O3 -S %s -o - | FileCheck %s

unsigned long f_i10(int c) {
  return __builtin_k1_sbmm8(c, 0x010ULL);
  // CHECK: f_i10
  // CHECK: sbmm8 $r0 = $r0, 16
  // CHECK: ret
}

unsigned long f_i37(int c) {
  return __builtin_k1_sbmm8(c, 1LL << 40);
  // CHECK: f_i37
  // CHECK: sbmm8 $r0 = $r0, 1099511627776
  // CHECK: ret
}

unsigned long f_i64(int c) {
  return __builtin_k1_sbmm8(c, 0x0101010101010101ULL);
  // CHECK: f_i64
  // CHECK: sbmm8 $r0 = $r0, 72340172838076673
  // CHECK: ret
}

unsigned long f_rr(int c, unsigned long c2) {
  return __builtin_k1_sbmm8(c, c2);
  // CHECK: f_rr
  // CHECK: sbmm8 $r0 = $r0, $r1
  // CHECK: ret
}
