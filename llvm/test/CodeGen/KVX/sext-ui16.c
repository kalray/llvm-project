// RUN: clang -S %s -O3 -o - | FileCheck %s

unsigned short a;

void test4(unsigned short b, unsigned short c) {
  a = b << c;
  // CHECK: test4
  // CHECK: zxhd
  // CHECK-NOT: zxhd
  // CHECK-NOT: sraw
  // CHECK: sllw
  // CHECK: ret
}

void test4b(unsigned short b, unsigned short c) {
  a = b >> c;
  // CHECK: test4b
  // CHECK: zxhd
  // CHECK-NOT: zxhd
  // CHECK: srlw
  // CHECK: ret
}
