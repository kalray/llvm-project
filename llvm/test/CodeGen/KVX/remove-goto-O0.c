// RUN: clang -S %s -O0 -o - | FileCheck %s

int factorial(int v) {
  if (v > 0) {
    v *= factorial(v - 1);
  }

  return v;
  // CHECK-LABEL: factorial:
  // CHECK-NOT: goto
  // CHECK: ret
}

int f(void) {
  int i, s = 0;
  for (i = 0; i < 4; i++) {
    s += i;
  }
  return 0;
  // CHECK-LABEL: f:
  // CHECK: goto
  // CHECK-NOT: goto
  // CHECK: ret
}
