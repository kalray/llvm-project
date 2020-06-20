// RUN: clang -S -O3 %s -o - | FileCheck %s

int a;

void test3(int b, int c) {
  a = b << c;
  // CHECK: test3
  // CHECK-NOT: zxwd
  // CHECK-NOT: sraw
  // CHECK: sllw
  // CHECK: ret
}

void test6(int b, int c) {
  a = b << c;
  // CHECK: test6
  // CHECK-NOT: zxwd
  // CHECK: sllw
  // CHECK: ret
}

void test6b(int b, short c) {
  a = b << c;
  // CHECK: test6b
  // CHECK-NOT: sxhd
  // CHECK: sllw
  // CHECK: ret
}

void test6c(int b, unsigned short c) {
  a = b << c;
  // CHECK: test6c
  // CHECK-NOT: zxhd
  // CHECK: sllw
  // CHECK: ret
}

void test6d(int b, char c) {
  a = b << c;
  // CHECK: test6d
  // CHECK-NOT: sxbd
  // CHECK: sllw
  // CHECK: ret
}

void test6e(int b, unsigned char c) {
  a = b << c;
  // CHECK: test6e
  // CHECK-NOT: zxbd
  // CHECK: sllw
  // CHECK: ret
}
