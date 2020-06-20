// RUN: clang -S -O3 %s -o - | FileCheck %s

long long a;

void test7(long long b, char c) {
  a = b << c;
  // CHECK: test7
  // CHECK-NOT: zxbd
  // CHECK: slld
  // CHECK: ret
}

void test7b(long long b, unsigned char c) {
  a = b << c;
  // CHECK: test7b
  // CHECK-NOT: zxbd
  // CHECK: slld
  // CHECK: ret
}

void test7c(long long b, short c) {
  a = b << c;
  // CHECK: test7c
  // CHECK-NOT: zxhd
  // CHECK: slld
  // CHECK: ret
}

void test7d(long long b, unsigned short c) {
  a = b << c;
  // CHECK: test7d
  // CHECK-NOT: zxhd
  // CHECK: slld
  // CHECK: ret
}

void test7e(long long b, int c) {
  a = b << c;
  // CHECK: test7e
  // CHECK-NOT: zxwd
  // CHECK: slld
  // CHECK: ret
}

void test7f(long long b, unsigned int c) {
  a = b << c;
  // CHECK: test7f
  // CHECK-NOT: zxwd
  // CHECK: slld
  // CHECK: ret
}
