// RUN: clang -target kvx-cos -O3 -S %s -o - | FileCheck %s

int f_select_cc_i32(int c, int c2, int a, int b) {
  return c > c2 ? a : b;
  // CHECK: f_select_cc_i32
  // CHECK: cmoved.wnez
  // CHECK: ret
}

int f_select_cc_i64(long c, long c2, int a, int b) {
  return c > c2 ? a : b;
  // CHECK: f_select_cc_i64
  // CHECK: cmoved.wnez
  // CHECK: ret
}
