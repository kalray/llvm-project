// RUN: clang -target kvx-cos -S -O2 %s -o - |& FileCheck %s

int imm10(int *p) {
  return *p;
  // CHECK-LABEL: imm10:
  // CHECK-NEXT: lwz $r0 = 0[$r0]
  // CHECK-NEXT: ret
}

int imm37(int *p) {
  return *(p + 0xffffffff);
  // CHECK-LABEL: imm37:
  // CHECK-NEXT: lwz $r0 = 0x3fffffffc[$r0]
  // CHECK-NEXT: ret
}

int imm64(int *p) {
  return *(p + 0xffffffffffff);
  // CHECK-LABEL: imm64:
  // CHECK-NEXT: lwz $r0 = 0x3fffffffffffc[$r0]
  // CHECK-NEXT: ret
}

int reg(int *p, long a) {
  return *(p + a);
  // CHECK-LABEL: reg:
  // CHECK: lwz.xs $r0 = $r1[$r0]
}

unsigned test0(int a, unsigned *p) {
  return p[a];
  // CHECK-LABEL: test0
  // CHECK: lwz.xs $r0 = $r0[$r1]
  // CHECK-NEXT: ret
}

int test1(int a, int *p) {
  return p[a];
  // CHECK-LABEL: test1
  // CHECK: lwz.xs $r0 = $r0[$r1]
  // CHECK-NEXT: ret
}

unsigned long test2(int a, unsigned *p) {
  return p[a];
  // CHECK-LABEL: test2
  // CHECK: lwz.xs $r0 = $r0[$r1]
  // CHECK-NEXT: ret
}

float test3(int a, float *p) {
  return p[a];
  // CHECK-LABEL: test3
  // CHECK: lwz.xs $r0 = $r0[$r1]
  // CHECK-NEXT: ret
}

int test4(int a, int *p) {
  if (a == 0)
    return p[0];
  else
    return a;
  // CHECK-LABEL: test4
  // CHECK: lwz $r0 = 0[$r1]
  // CHECK: ret
}

int g1 = 0;
void test5(int a, char *p) {
  if (g1 != 0)
    return;
  if (!g1) {
    g1 = 1;
  }
  // CHECK-LABEL: test5
  // CHECK: make $r0 = g1
  // CHECK: lwz $r1 = 0[$r0]
  // CHECK: make $r1 = 1
  // CHECK: sw 0[$r0] = $r1
  // CHECK: ret
}

int test6(long a, long b, int **p) {
  return p[a][b];
  // CHECK-LABEL: test6
  // CHECK: ld.xs $r0 = $r0[$r2]
  // CHECK: lwz.xs $r0 = $r1[$r0]
  // CHECK: ret
}

unsigned test7(int a, unsigned *p) {
  return p[a << 1];
  // CHECK-LABEL: test7
  // CHECK: sllw $r0 = $r0, 1
  // CHECK: sxwd $r0 = $r0
  // CHECK: lwz.xs $r0 = $r0[$r1]
  // CHECK-NEXT: ret
}

unsigned test8(long a, unsigned *p) {
  return p[a << 1];
  // CHECK-LABEL: test8
  // CHECK: slld $r0 = $r0, 3
  // CHECK: lwz $r0 = $r0[$r1]
  // CHECK-NEXT: ret
}
