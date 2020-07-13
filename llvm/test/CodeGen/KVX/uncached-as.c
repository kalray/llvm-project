// RUN: clang -target kvx-cos -O3 -S %s -o - | FileCheck %s

typedef int v4i32 __attribute__((vector_size(4 * sizeof(int))));
typedef float v2f32 __attribute__((vector_size(2 * sizeof(float))));
typedef float v4f32 __attribute__((vector_size(4 * sizeof(float))));

struct S {
  int a;
  int b;
  int c;
  int d;
};

char uncached_i8(__uncached char *i) {
  return *i;
  // CHECK-LABEL: uncached_i8:
  // CHECK: lbz.u
  // CHECK: ret
}

short uncached_i16(__uncached short *i) {
  return *i;
  // CHECK-LABEL: uncached_i16:
  // CHECK: lhz.u
  // CHECK: ret
}

int uncached_i32(__uncached int *i) {
  return *i;
  // CHECK-LABEL: uncached_i32:
  // CHECK: lwz.u
  // CHECK: ret
}

long uncached_i64(__uncached long *i) {
  return *i;
  // CHECK-LABEL: uncached_i64:
  // CHECK: ld.u
  // CHECK: ret
}

float funcached_f32(__uncached float *f) {
  // CHECK-LABEL: funcached_f32:
  // CHECK: lwz.u
  // CHECK: ret
  return *f;
}

double funcached_f64(__uncached double *d) {
  // CHECK-LABEL: funcached_f64:
  // CHECK: ld.u
  // CHECK: ret
  return *d;
}

v2f32 funcached_v2f32(__uncached v2f32 *v) {
  // CHECK-LABEL: funcached_v2f32:
  // CHECK: ld.u
  // CHECK: ret
  return *v;
}

v4f32 funcached_v4f32(__uncached v4f32 *v) {
  // CHECK-LABEL: funcached_v4f32:
  // CHECK: lq.u
  // CHECK: ret
  return *v;
}

int foo_uncached_a(__uncached struct S *s) {
  return s->a;
  // CHECK-LABEL: foo_uncached_a:
  // CHECK: lwz.u $r0 = 0[$r0]
  // CHECK: ret
}

int foo_uncached_b(__uncached struct S *s) {
  return s->b;
  // CHECK-LABEL: foo_uncached_b:
  // CHECK: lwz.u $r0 = 4[$r0]
  // CHECK: ret
}

int foo_uncached_c(__uncached struct S *s) {
  return s->c;
  // CHECK-LABEL: foo_uncached_c:
  // CHECK: lwz.u $r0 = 8[$r0]
  // CHECK: ret
}

int foo_uncached_d(__uncached struct S *s) {
  return s->d;
  // CHECK-LABEL: foo_uncached_d:
  // CHECK: lwz.u $r0 = 12[$r0]
  // CHECK: ret
}

int foo_uncached_3(__uncached v4i32 *v) {
  return (*v)[3];
  // CHECK-LABEL: foo_uncached_3:
  // CHECK: lwz.u $r0 = 12[$r0]
  // CHECK: ret
}

int foo_uncached_x(__uncached v4i32 *v, int x) {
  return (*v)[x];
  // CHECK-LABEL: foo_uncached_x:
  // CHECK: lwz.u.xs $r0 = $r1[$r0]
  // CHECK: ret
}

int foo_default(int *i) {
  return *i;
  // CHECK-LABEL: foo_default:
  // CHECK: lwz $r0 = 0[$r0]
  // CHECK: ret
}

int foo_default_a(struct S *s) {
  return s->a;
  // CHECK-LABEL: foo_default_a:
  // CHECK: lwz $r0 = 0[$r0]
  // CHECK: ret
}

int foo_default_b(struct S *s) {
  return s->b;
  // CHECK-LABEL: foo_default_b:
  // CHECK: lwz $r0 = 4[$r0]
  // CHECK: ret
}

int foo_default_c(struct S *s) {
  return s->c;
  // CHECK-LABEL: foo_default_c:
  // CHECK: lwz $r0 = 8[$r0]
  // CHECK: ret
}

int foo_default_d(struct S *s) {
  return s->d;
  // CHECK-LABEL: foo_default_d:
  // CHECK: lwz $r0 = 12[$r0]
  // CHECK: ret
}

int foo_default_3(v4i32 *v) {
  return (*v)[3];
  // CHECK-LABEL: foo_default_3:
  // CHECK: lwz $r0 = 12[$r0]
  // CHECK: ret
}

int foo_default_x(v4i32 *v, int x) {
  return (*v)[x];
  // CHECK-LABEL: foo_default_x:
  // CHECK: lwz.xs $r0 = $r1[$r0]
  // CHECK: ret
}
