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

int g1, g2, g3, g4, g5, g6, g7, g8, g9, g10, g11, g12, g13, g14, g15, g16, g17,
    g18, g19, g20, g21, g22, g23, g24, g25, g26, g27, g28, g29, g30, g31, g32,
    g33, g34, g35, g36, g37, g38, g39, g40, g41, g42, g43, g44, g45, g46, g47,
    g48, g49, g50, g51, g52, g53, g54, g55, g56, g57, g58, g59, g60, g61, g62,
    g63, g64, g65;

int other4(int *, int, more_aligned_int *, int, int, int, int, int, int, int,
           int, int, int, int, int, int, int, int, int, int, int, int, int, int,
           int, int, int, int, int, int, int, int, int, int, int, int, int, int,
           int, int, int, int, int, int, int, int, int, int, int, int, int, int,
           int, int, int, int, int, int, int, int, int, int, int, int, int, int,
           int, int);

int stackrealign4(int n) {
  int *av = (int *)alloca(sizeof(int) * n);
  for (int j = 0; j < n; j++)
    av[j] = n - j;
  more_aligned_int i = 1234;
  return other4(av, n, &i, g1, g2, g3, g4, g5, g6, g7, g8, g9, g10, g11, g12,
                g13, g14, g15, g16, g17, g18, g19, g20, g21, g22, g23, g24, g25,
                g26, g27, g28, g29, g30, g31, g32, g33, g34, g35, g36, g37, g38,
                g39, g40, g41, g42, g43, g44, g45, g46, g47, g48, g49, g50, g51,
                g52, g53, g54, g55, g56, g57, g58, g59, g60, g61, g62, g63, g64,
                g65);
  // CHECK: stackrealign4:
  // CHECK: addd $r12 = $r12, -384
  // CHECK: copyd $r32 = $r12
  // CHECK: addd $r12 = $r12, 96
  // CHECK: andd $r12 = $r12, -128
  // CHECK: copyd $r31 = $r32
  // CHECK: copyd $r14 = $r12
  // CHECK-NOT: make $r31
  // CHECK: copyd $r32 = $r31
  // CHECK: copyd $r12 = $r14
  // CHECK: copyd $r12 = $r32
  // CHECK: addd $r12 = $r12, 384
  // CHECK: ret
}
