// RUN: clang -target kvx-cos -S -O2 %s -o - |& FileCheck %s

void imm10(int *p, int a) {
  *p = a;
  // CHECK-LABEL: imm10:
  // CHECK-NEXT: sw 0[$r0] = $r1
  // CHECK-NEXT: ret
}

void imm37(int *p, int a) {
  *(p + 0xffffffff) = a;
  // CHECK-LABEL: imm37:
  // CHECK-NEXT: sw 17179869180[$r0] = $r1
  // CHECK-NEXT: ret
}

void imm64(int *p, int a) {
  *(p + 0xffffffffffff) = a;
  // CHECK-LABEL: imm64:
  // CHECK-NEXT: sw 1125899906842620[$r0] = $r1
  // CHECK-NEXT: ret
}

void reg(int *p, long a, long b) {
  *(p + b) = a;
  // CHECK-LABEL: reg:
  // CHECK: sw.xs $r2[$r0] = $r1
  // CHECK-NEXT: ret
}

typedef int v4i __attribute__((__vector_size__(sizeof(int) * 4)));
v4i test0(v4i v, unsigned char i) {
  v[i] = -5;
  return v;
  // CHECK-LABEL: test0
  // CHECK: andd $r0 = $r2, 3
  // CHECK: make $r1 = 4294967291
  // CHECK: addd $r2 = $r12, 16

  // CHECK: sw.xs $r0[$r2] = $r1
  // CHECK: ret
}

int test1(int *p, int *m, int a) {
  p[a] = m[a];
  return 0;
  // CHECK-LABEL: test1
  // CHECK: lwz.xs
  // CHECK: sw.xs
  // CHECK: ret
}

int g1 = 0;
void test2(int a, char *p) {
  if (g1 != 0)
    return;
  if (!g1) {
    g1 = 1;
  }
  // CHECK-LABEL: test2
  // CHECK: make $r0 = g1
  // CHECK: lwz $r1 = 0[$r0]
  // CHECK: make $r1 = 1
  // CHECK: sw 0[$r0] = $r1
  // CHECK: ret
}
