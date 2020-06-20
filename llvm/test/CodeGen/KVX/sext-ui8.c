// RUN: clang -S -O3 %s -o - | FileCheck %s

unsigned char a;

void test5(unsigned char b, unsigned char c) {
  a = b << c;
  // CHECK: test5
  // CHECK: zxbd
  // CHECK-NOT: zxbd
  // CHECK: sllw
  // CHECK: ret
}

void test5b(unsigned char b, unsigned char c) {
  a = b >> c;
  // CHECK: test5b
  // CHECK: zxbd
  // CHECK-NOT: zxbd
  // CHECK: srlw
  // CHECK: ret
}
