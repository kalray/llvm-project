// RUN: clang -target kvx-cos -S %s -O3 -mllvm -disable-kvx-hwloops -o - | FileCheck %s

void loop_unrolling(int *t) {
  for (int i = 0; i < 1024; i++)
    t[i] = i;
  // CHECK-LABEL: loop_unrolling
  // CHECK: addd [[REG1:\$r[0-9]+]] = [[REG1]], 8
  // CHECK: compd.eq [[REG2:\$r[0-9]+]] = [[REG1]], 1024
  // CHECK: ret
}
