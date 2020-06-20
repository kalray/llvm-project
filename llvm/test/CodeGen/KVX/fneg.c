// RUN: clang -S -g -O2 %s -o - | FileCheck %s

_Float16 f_float16(_Float16 x) {
  _Float16 y = 0;
  return y - x;
  // CHECK: fneghq
}

float f_float(float x) {
  float y = 0;
  return y - x;
  // CHECK: fnegw
}

double f_double(double x) {
  double y = 0;
  return y - x;
  // CHECK: fnegd
}
