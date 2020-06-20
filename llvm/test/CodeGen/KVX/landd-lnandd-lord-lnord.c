// RUN: clang -S -O3 %s -o - | FileCheck %s

_Bool f1(long a, long b) {
  return a && b;
  // CHECK: f1
  // CHECK: landd
  // CHECK: ret
}

_Bool f2(long a, long b) {
  return !(a && b);
  // CHECK: f2
  // CHECK: lnandd
  // CHECK: ret
}

_Bool f3(long a, long b) {
  return !a && !b;
  // CHECK: f3
  // CHECK: lnord
  // CHECK: ret
}

_Bool f4(long a, long b) {
  return a || b;
  // CHECK: f4
  // CHECK: lord
  // CHECK: ret
}

_Bool f5(long a, long b) {
  return !a || !b;
  // CHECK: f5
  // CHECK: lnandd
  // CHECK: ret
}

_Bool f6(long a, long b) {
  return !(a || b);
  // CHECK: f6
  // CHECK: lnord
  // CHECK: ret
}
