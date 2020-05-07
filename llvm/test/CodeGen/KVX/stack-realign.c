// RUN: clang -target kvx-cos -S %s -O3 -o - | FileCheck %s

typedef int more_aligned_int __attribute__((aligned(128)));

int other(int *, more_aligned_int *);

int stackrealign1() {
  int c = 7;
  more_aligned_int i = 1234;
  return other(&c, &i);
  // CHECK: stackrealign1:
  // CHECK: addd $r12 = $r12, -384
  // CHECK: copyd $r32 = $r12
  // CHECK: addd $r12 = $r12, 96
  // CHECK: andd $r12 = $r12, -128
  // CHECK: copyd $r14 = $r32
  // CHECK: copyd $r32 = $r14
  // CHECK: copyd $r12 = $r32
  // CHECK: addd $r12 = $r12, 384
  // CHECK: ret
}

int other2(int *, int, more_aligned_int *);

int stackrealign2(int n) {
  int *av = (int *)alloca(sizeof(int) * n);
  for (int j = 0; j < n; j++)
    av[j] = n - j;
  more_aligned_int i = 1234;
  return other2(av, n, &i);
  // CHECK: stackrealign2:
  // CHECK: addd $r12 = $r12, -384
  // CHECK: copyd $r32 = $r12
  // CHECK: addd $r12 = $r12, 96
  // CHECK: andd $r12 = $r12, -128
  // CHECK: copyd $r31 = $r32
  // CHECK: copyd $r14 = $r12
  // CHECK: copyd $r32 = $r31
  // CHECK: copyd $r12 = $r14
  // CHECK: copyd $r12 = $r32
  // CHECK: addd $r12 = $r12, 384
  // CHECK: ret
}

typedef long v16i64 __attribute__((vector_size(128)));

v16i64 otherv(int *x, v16i64 *);

long int stackrealign3(int x) {
  v16i64 i = {16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1};
  int a = x;
  v16i64 v = otherv(&a, &i);
  return v[0] + x;
  // CHECK: stackrealign3:
  // CHECK: addd $r12 = $r12, -640
  // CHECK: copyd $r32 = $r12
  // CHECK: addd $r12 = $r12, 96
  // CHECK: andd $r12 = $r12, -128
  // CHECK: copyd $r14 = $r32
  // CHECK: copyd $r32 = $r14
  // CHECK: copyd $r12 = $r32
  // CHECK: addd $r12 = $r12, 640
  // CHECK: ret
}
