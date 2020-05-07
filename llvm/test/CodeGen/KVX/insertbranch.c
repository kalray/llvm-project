// RUN: clang -target kvx-cos -O3 -S %s -o - | FileCheck %s

int global;

int foo(int a) {
  global = global + 2 * a;

  if (a == 0) {
    return global;
  } else {
    return foo(a - 1) - 1;
  }
  // CHECK: foo
  // CHECK: call foo
  // CHECK: goto .LBB0_3
  // CHECK: ret
}
