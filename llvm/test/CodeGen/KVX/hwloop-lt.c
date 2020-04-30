// RUN: clang -mllvm --disable-kvx-hwloops=false -target kvx-cos -S %s -O2 -o - | FileCheck %s
int *x;
int *f(int s, int c) {

  for (int i = -1000; i <= -500; i += 4) {
    x[i] = i;
  }

  return x;
  // CHECK:f
  // CHECK:make {{\$r[0-9]+}} = 126
  // CHECK:loopdo
  // CHECK:ret
}

int *g(int s, int c) {

  for (int i = -1000; i < -500; i += 4) {
    x[i] = i;
  }

  return x;
  // CHECK:g
  // CHECK:make {{\$r[0-9]+}} = 125
  // CHECK:loopdo
  // CHECK:ret
}
