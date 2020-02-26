// RUN: clang -target k1c-cos -S -O2 %s -o - | FileCheck %s
#include <math.h>

float fminw(float a, float b) {
  return fminf(a, b);
  // CHECK: fminw $r0 = $r0, $r1
}

double fmind(double a, double b) {
  return fmin(a, b);
  // CHECK: fmind $r0 = $r0, $r1
}

long double fmindl(long double a, long double b) {
  return fminl(a, b);
  // CHECK: fmind $r0 = $r0, $r1
}

// TODO: fminwp can be matched via builtin and custom lowering
// TODO: fminhq can be matched via builtin and custom lowering
