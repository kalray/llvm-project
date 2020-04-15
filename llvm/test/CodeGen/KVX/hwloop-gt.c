// RUN: clang -target kvx-cos -S %s -O2 -o - | FileCheck %s
int *x;
int *f(int s, int c) {

  for (int i = 500; i >= -500; i -= 4) {
    x[i] = i;
  }

  return x;
  // CHECK: f
  // CHECK: make {{\$r[0-9]+}} = 251
  // CHECK: loopdo
  // CHECK: ret
}

int *g(int s, int c) {

  for (int i = 500; i > -500; i -= 4) {
    x[i] = i;
  }

  return x;
  // CHECK: g
  // CHECK: make {{\$r[0-9]+}} = 250
  // CHECK: loopdo
  // CHECK: ret
}
