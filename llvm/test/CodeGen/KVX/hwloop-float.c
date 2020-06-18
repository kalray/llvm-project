// RUN: clang -mllvm --disable-kvx-hwloops=false -target kvx-cos -S %s -O2 -o -
// | FileCheck %s

void f32(float *x) {
  for (float i = 0.5; i < 100; ++i)
    x[(int)i] = i;
  // CHECK: loopdo
}

void f64(double *x) {
  for (double i = 0.5; i < 100; ++i)
    x[(int)i] = i;
  // CHECK: loopdo
}
