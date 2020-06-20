// RUN: clang -S %s -O3 -o - | FileCheck %s

short a;

void f1(long long b, short c) {
  a = b + c;
  // CHECK: f1
  // CHECK: zxwd
  // CHECK: addw
  // CHECK: ret
}
