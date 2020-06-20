// RUN: clang -S %s -O3 -o - | FileCheck %s

short a;

void test1(short b, short c) {
  a = b << c;
  // CHECK: test1
  // CHECK: sxhd
  // CHECK-NOT: sxhd
  // CHECK-NOT: sraw
  // CHECK: sllw
  // CHECK: ret
}
