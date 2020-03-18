// RUN: clang -target kvx-cos -O3 -S %s -o - | FileCheck %s

int f1(int v) {
  return (v >> 29) & 16383;
  // CHECK: f1
  // CHECK: extfs $r0 = $r0, 31, 29
  // CHECK: ret
}

long f1d(long v) {
  return (v >> 61) & 16383;
  // CHECK: f1d
  // CHECK: extfs $r0 = $r0, 63, 61
  // CHECK: ret
}

int f2(int v) {
  return (v >> 28) & 16383;
  // CHECK: f2
  // CHECK: extfs $r0 = $r0, 31, 28
  // CHECK: ret
}

long f2d(long v) {
  return (v >> 59) & 16383;
  // CHECK: f2d
  // CHECK: extfs $r0 = $r0, 63, 59
  // CHECK: ret
}
