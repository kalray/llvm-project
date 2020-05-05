// RUN: clang -target kvx-cos -S -O2 %s -o - | FileCheck %s

// Ensure correct convertion from float to int (round to zero).
// See also: T13115.
int test1(float f) {
  return (int)f;
  // CHECK-LABEL: test1:
  // CHECK-NEXT: fixedw.rz $r0 = $r0, 0
  // CHECK-NEXT: ret
}

// Ensure correct convertion from int to float (rount to nearest).
float test2(int i) {
  return (float)i;
  // CHECK-LABEL: test2:
  // CHECK-NEXT: floatw.rn $r0 = $r0, 0
  // CHECK-NEXT: ret
}
