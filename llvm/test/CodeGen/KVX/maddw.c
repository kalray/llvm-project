// RUN: clang -target kvx-cos -O3 -S %s -o - | FileCheck %s

int f_maddwrr(int a, int b, int c) {
  a += b * c;
  return a;
  // CHECK: f_maddwrr
  // CHECK: maddw $r0 = {{\$r[0-9]+}}, {{\$r[0-9]+}}
  // CHECK: ret
}

int f_maddwri_1(int a, int b) {
  a += b * 11;
  return a;
  // CHECK: f_maddwri_1
  // CHECK: maddw $r0 = {{\$r[0-9]+}}, 11
  // CHECK: ret
}

int f_maddwri_2(int a, int b) {
  a += 11 * b;
  return a;
  // CHECK: f_maddwri_2
  // CHECK: maddw $r0 = {{\$r[0-9]+}}, 11
  // CHECK: ret
}

int f_not_maddw(int a, int b) {
  int c = a * b;
  int d = a + b;
  return c + d;
  // CHECK: f_not_maddw
  // CHECK: addw
  // CHECK: mulw
  // CHECK: addw
  // CHECK: ret
}
