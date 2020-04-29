// RUN: clang -target kvx-cos -S %s -O2 -o - | FileCheck %s

// The test ensures no regressions after T12847 bugfix:
//   from llvm-test-suite/SingleSource/UnitTests/2008-04-20-LoopBug2.c

void foo(int i, int *p) {
  int j = 3;
  do {
    p[j] = p[j - 1];
    j--;
  } while (j > i);
  // CHECK: sbfd
  // Check that the loop body is at least executed once:
  // CHECK: cb.dlez
  // CHECK: loopdo
}
