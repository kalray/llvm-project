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

char speculative_i8(__speculative char *i) {
  return *i;
  // CHECK-LABEL: speculative_i8:
  // CHECK: lbz.s
  // CHECK: ret
}

short speculative_i16(__speculative short *i) {
  return *i;
  // CHECK-LABEL: speculative_i16:
  // CHECK: lhz.s
  // CHECK: ret
}

int speculative_i32(__speculative int *i) {
  return *i;
  // CHECK-LABEL: speculative_i32:
  // CHECK: lwz.s
  // CHECK: ret
}

long speculative_i64(__speculative long *i) {
  return *i;
  // CHECK-LABEL: speculative_i64:
  // CHECK: ld.s
  // CHECK: ret
}

float fspeculative_f32(__speculative float *f) {
  // CHECK-LABEL: fspeculative_f32:
  // CHECK: lwz.s
  // CHECK: ret
  return *f;
}

double fspeculative_f64(__speculative double *d) {
  // CHECK-LABEL: fspeculative_f64:
  // CHECK: ld.s
  // CHECK: ret
  return *d;
}

v2f32 fspeculative_v2f32(__speculative v2f32 *v) {
  // CHECK-LABEL: fspeculative_v2f32:
  // CHECK: ld.s
  // CHECK: ret
  return *v;
}

v4f32 fspeculative_v4f32(__speculative v4f32 *v) {
  // CHECK-LABEL: fspeculative_v4f32:
  // CHECK: lq.s
  // CHECK: ret
  return *v;
}

int foo_speculative_a(__speculative struct S *s) {
  return s->a;
  // CHECK-LABEL: foo_speculative_a:
  // CHECK: lwz.s $r0 = 0[$r0]
  // CHECK: ret
}

int foo_speculative_b(__speculative struct S *s) {
  return s->b;
  // CHECK-LABEL: foo_speculative_b:
  // CHECK: lwz.s $r0 = 4[$r0]
  // CHECK: ret
}

int foo_speculative_c(__speculative struct S *s) {
  return s->c;
  // CHECK-LABEL: foo_speculative_c:
  // CHECK: lwz.s $r0 = 8[$r0]
  // CHECK: ret
}

int foo_speculative_d(__speculative struct S *s) {
  return s->d;
  // CHECK-LABEL: foo_speculative_d:
  // CHECK: lwz.s $r0 = 12[$r0]
  // CHECK: ret
}

int foo_speculative_3(__speculative v4i32 *v) {
  return (*v)[3];
  // CHECK-LABEL: foo_speculative_3:
  // CHECK: lwz.s $r0 = 12[$r0]
  // CHECK: ret
}

int foo_speculative_x(__speculative v4i32 *v, int x) {
  return (*v)[x];
  // CHECK-LABEL: foo_speculative_x:
  // CHECK: lwz.s.xs $r0 = $r1[$r0]
  // CHECK: ret
}
