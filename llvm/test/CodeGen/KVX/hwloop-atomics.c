// RUN: clang -mllvm -disable-kvx-hwloops=false -S -g -O2 %s -o - | FileCheck %s

void set(int *x, int num) {
  for (int i = 0; i != num; i++) {
    int a = i;
    int b = 4;

    __atomic_sub_fetch(&a, b, __ATOMIC_RELAXED);
    x[i] = b * b;
  }
  // CHECK-NOT: loopdo
}
