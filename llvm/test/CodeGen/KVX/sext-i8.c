// RUN: clang -S %s -O3 -o - | FileCheck %s
char a;

void test2(char b, char c) {
  a = b << c;
  // CHECK: test2
  // CHECK: sxbd
  // CHECK-NOT: sxbd
  // CHECK-NOT: sraw
  // CHECK: sllw
  // CHECK: ret
}
