// RUN: clang -target k1c-cos -S -O2 %s -o - | FileCheck %s
#include <math.h>

float fmaxw(float a, float b) {
  return fmaxf(a, b);
  // CHECK: fmaxw $r0 = $r0, $r1
}

double fmaxd(double a, double b) {
  return fmax(a, b);
  // CHECK: fmaxd $r0 = $r0, $r1
}

long double fmaxdl(long double a, long double b) {
  return fmaxl(a, b);
  // CHECK: fmaxd $r0 = $r0, $r1
}

// TODO: fmaxwp can be matched via builtin and custom lowering
// TODO: fmaxhq can be matched via builtin and custom lowering
