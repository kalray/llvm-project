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

char bypass_i8(__bypass char *i) {
  return *i;
  // CHECK-LABEL: bypass_i8:
  // CHECK: lbz.u
  // CHECK: ret
}

short bypass_i16(__bypass short *i) {
  return *i;
  // CHECK-LABEL: bypass_i16:
  // CHECK: lhz.u
  // CHECK: ret
}

int bypass_i32(__bypass int *i) {
  return *i;
  // CHECK-LABEL: bypass_i32:
  // CHECK: lwz.u
  // CHECK: ret
}

long bypass_i64(__bypass long *i) {
  return *i;
  // CHECK-LABEL: bypass_i64:
  // CHECK: ld.u
  // CHECK: ret
}

float fbypass_f32(__bypass float *f) {
  // CHECK-LABEL: fbypass_f32:
  // CHECK: lwz.u
  // CHECK: ret
  return *f;
}

double fbypass_f64(__bypass double *d) {
  // CHECK-LABEL: fbypass_f64:
  // CHECK: ld.u
  // CHECK: ret
  return *d;
}

v2f32 fbypass_v2f32(__bypass v2f32 *v) {
  // CHECK-LABEL: fbypass_v2f32:
  // CHECK: ld.u
  // CHECK: ret
  return *v;
}

v4f32 fbypass_v4f32(__bypass v4f32 *v) {
  // CHECK-LABEL: fbypass_v4f32:
  // CHECK: lq.u
  // CHECK: ret
  return *v;
}

int foo_bypass_a(__bypass struct S *s) {
  return s->a;
  // CHECK-LABEL: foo_bypass_a:
  // CHECK: lwz.u $r0 = 0[$r0]
  // CHECK: ret
}

int foo_bypass_b(__bypass struct S *s) {
  return s->b;
  // CHECK-LABEL: foo_bypass_b:
  // CHECK: lwz.u $r0 = 4[$r0]
  // CHECK: ret
}

int foo_bypass_c(__bypass struct S *s) {
  return s->c;
  // CHECK-LABEL: foo_bypass_c:
  // CHECK: lwz.u $r0 = 8[$r0]
  // CHECK: ret
}

int foo_bypass_d(__bypass struct S *s) {
  return s->d;
  // CHECK-LABEL: foo_bypass_d:
  // CHECK: lwz.u $r0 = 12[$r0]
  // CHECK: ret
}

int foo_bypass_3(__bypass v4i32 *v) {
  return (*v)[3];
  // CHECK-LABEL: foo_bypass_3:
  // CHECK: lwz.u $r0 = 12[$r0]
  // CHECK: ret
}

int foo_bypass_x(__bypass v4i32 *v, int x) {
  return (*v)[x];
  // CHECK-LABEL: foo_bypass_x:
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
