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

char preload_i8(__preload char *i) {
  return *i;
  // CHECK-LABEL: preload_i8:
  // CHECK: lbz.us
  // CHECK: ret
}

short preload_i16(__preload short *i) {
  return *i;
  // CHECK-LABEL: preload_i16:
  // CHECK: lhz.us
  // CHECK: ret
}

int preload_i32(__preload int *i) {
  return *i;
  // CHECK-LABEL: preload_i32:
  // CHECK: lwz.us
  // CHECK: ret
}

long preload_i64(__preload long *i) {
  return *i;
  // CHECK-LABEL: preload_i64:
  // CHECK: ld.us
  // CHECK: ret
}

float fpreload_f32(__preload float *f) {
  // CHECK-LABEL: fpreload_f32:
  // CHECK: lwz.us
  // CHECK: ret
  return *f;
}

double fpreload_f64(__preload double *d) {
  // CHECK-LABEL: fpreload_f64:
  // CHECK: ld.us
  // CHECK: ret
  return *d;
}

v2f32 fpreload_v2f32(__preload v2f32 *v) {
  // CHECK-LABEL: fpreload_v2f32:
  // CHECK: ld.us
  // CHECK: ret
  return *v;
}

v4f32 fpreload_v4f32(__preload v4f32 *v) {
  // CHECK-LABEL: fpreload_v4f32:
  // CHECK: lq.us
  // CHECK: ret
  return *v;
}

int foo_preload_a(__preload struct S *s) {
  return s->a;
  // CHECK-LABEL: foo_preload_a:
  // CHECK: lwz.us $r0 = 0[$r0]
  // CHECK: ret
}

int foo_preload_b(__preload struct S *s) {
  return s->b;
  // CHECK-LABEL: foo_preload_b:
  // CHECK: lwz.us $r0 = 4[$r0]
  // CHECK: ret
}

int foo_preload_c(__preload struct S *s) {
  return s->c;
  // CHECK-LABEL: foo_preload_c:
  // CHECK: lwz.us $r0 = 8[$r0]
  // CHECK: ret
}

int foo_preload_d(__preload struct S *s) {
  return s->d;
  // CHECK-LABEL: foo_preload_d:
  // CHECK: lwz.us $r0 = 12[$r0]
  // CHECK: ret
}

int foo_preload_3(__preload v4i32 *v) {
  return (*v)[3];
  // CHECK-LABEL: foo_preload_3:
  // CHECK: lwz.us $r0 = 12[$r0]
  // CHECK: ret
}

int foo_preload_x(__preload v4i32 *v, int x) {
  return (*v)[x];
  // CHECK-LABEL: foo_preload_x:
  // CHECK: lwz.us.xs $r0 = $r1[$r0]
  // CHECK: ret
}
