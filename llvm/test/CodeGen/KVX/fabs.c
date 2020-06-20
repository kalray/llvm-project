// RUN: clang -S -g -O2 %s -o - | FileCheck %s

_Float16 f_float16(_Float16 x) {
  return fabs(x);
  // CHECK: fabshq
}

float f_float(float x) {
  return fabs(x);
  // CHECK: fabsw
}

double f_double(double x) {
  return fabs(x);
  // CHECK: fabsd
}
