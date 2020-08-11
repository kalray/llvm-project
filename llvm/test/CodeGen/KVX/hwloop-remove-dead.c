// RUN: clang -mllvm --disable-kvx-hwloops=false -target kvx-cos -S %s -O2 -o - | FileCheck %s

void matrix_add_const(unsigned int N, short *A, short val) {
  unsigned int i, j;
  for (i = 0; i < N; i++) {
    for (j = 0; j < N; j++) {
      A[i * N + j] += val;
    }
  }
  // CHECK-LABEL: matrix_add_const:
  // CHECK-LABEL: .LBB0_8:
  // CHECK: loopdo $r17, .LBB0_10
  // CHECK-NOT: addd $r15 = $r15, -1
  // CHECK-LABEL: .LBB0_10:
  // CHECK: ret
}
