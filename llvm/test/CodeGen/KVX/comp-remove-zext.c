// RUN: clang -target kvx-cos -S -O3 %s -o - | FileCheck %s

int foo_i32_i32_lt(int a, int b) {
  return a < b;
  // CHECK: foo_i32_i32_lt
  // CHECK-NOT: and
  // CHECK: ret
}

int foo_i32_i32_le(int a, int b) {
  return a <= b;
  // CHECK: foo_i32_i32_le
  // CHECK-NOT: and
  // CHECK: ret
}

int foo_i32_i32_gt(int a, int b) {
  return a > b;
  // CHECK: foo_i32_i32_gt
  // CHECK-NOT: and
  // CHECK: ret
}

int foo_i32_i32_ge(int a, int b) {
  return a >= b;
  // CHECK: foo_i32_i32_ge
  // CHECK-NOT: and
  // CHECK: ret
}

int foo_i32_i32_ltu(unsigned a, unsigned b) {
  return a < b;
  // CHECK: foo_i32_i32_ltu
  // CHECK-NOT: and
  // CHECK: ret
}

int foo_i32_i32_leu(unsigned a, unsigned b) {
  return a <= b;
  // CHECK: foo_i32_i32_leu
  // CHECK-NOT: and
  // CHECK: ret
}

int foo_i32_i32_gtu(unsigned a, unsigned b) {
  return a > b;
  // CHECK: foo_i32_i32_gtu
  // CHECK-NOT: and
  // CHECK: ret
}

int foo_i32_i32_geu(unsigned a, unsigned b) {
  return a >= b;
  // CHECK: foo_i32_i32_geu
  // CHECK-NOT: and
  // CHECK: ret
}

int foo_i32_i32_eq(unsigned a, unsigned b) {
  return a == b;
  // CHECK: foo_i32_i32_eq
  // CHECK-NOT: and
  // CHECK: ret
}

int foo_i32_i32_neq(unsigned a, unsigned b) {
  return a != b;
  // CHECK: foo_i32_i32_neq
  // CHECK-NOT: and
  // CHECK: ret
}

long foo_i64_i32_lt(int a, int b) {
  return a < b;
  // CHECK: foo_i64_i32_lt
  // CHECK-NOT: and
  // CHECK: ret
}

long foo_i64_i32_le(int a, int b) {
  return a <= b;
  // CHECK: foo_i64_i32_le
  // CHECK-NOT: and
  // CHECK: ret
}

long foo_i64_i32_gt(int a, int b) {
  return a > b;
  // CHECK: foo_i64_i32_gt
  // CHECK-NOT: and
  // CHECK: ret
}

long foo_i64_i32_ge(int a, int b) {
  return a >= b;
  // CHECK: foo_i64_i32_ge
  // CHECK-NOT: and
  // CHECK: ret
}

long foo_i64_i32_ltu(unsigned a, unsigned b) {
  return a < b;
  // CHECK: foo_i64_i32_ltu
  // CHECK-NOT: and
  // CHECK: ret
}

long foo_i64_i32_leu(unsigned a, unsigned b) {
  return a <= b;
  // CHECK: foo_i64_i32_leu
  // CHECK-NOT: and
  // CHECK: ret
}

long foo_i64_i32_gtu(unsigned a, unsigned b) {
  return a > b;
  // CHECK: foo_i64_i32_gtu
  // CHECK-NOT: and
  // CHECK: ret
}

long foo_i64_i32_geu(unsigned a, unsigned b) {
  return a >= b;
  // CHECK: foo_i64_i32_geu
  // CHECK-NOT: and
  // CHECK: ret
}

long foo_i64_i32_eq(unsigned a, unsigned b) {
  return a == b;
  // CHECK: foo_i64_i32_eq
  // CHECK-NOT: and
  // CHECK: ret
}

long foo_i64_i32_neq(unsigned a, unsigned b) {
  return a != b;
  // CHECK: foo_i64_i32_neq
  // CHECK-NOT: and
  // CHECK: ret
}

int foo_i32_f32_lt(float a, float b) {
  return a < b;
  // CHECK: foo_i32_f32_lt
  // CHECK-NOT: and
  // CHECK: ret
}

int foo_i32_f32_le(float a, float b) {
  return a <= b;
  // CHECK: foo_i32_f32_le
  // CHECK-NOT: and
  // CHECK: ret
}

int foo_i32_f32_gt(float a, float b) {
  return a > b;
  // CHECK: foo_i32_f32_gt
  // CHECK-NOT: and
  // CHECK: ret
}

int foo_i32_f32_ge(float a, float b) {
  return a >= b;
  // CHECK: foo_i32_f32_ge
  // CHECK-NOT: and
  // CHECK: ret
}

int foo_i32_f32_eq(float a, float b) {
  return a == b;
  // CHECK: foo_i32_f32_eq
  // CHECK-NOT: and
  // CHECK: ret
}

int foo_i32_f32_neq(float a, float b) {
  return a != b;
  // CHECK: foo_i32_f32_neq
  // CHECK-NOT: and
  // CHECK: ret
}

long foo_i64_f32_lt(float a, float b) {
  return a < b;
  // CHECK: foo_i64_f32_lt
  // CHECK-NOT: and
  // CHECK: ret
}

long foo_i64_f32_le(float a, float b) {
  return a <= b;
  // CHECK: foo_i64_f32_le
  // CHECK-NOT: and
  // CHECK: ret
}

long foo_i64_f32_gt(float a, float b) {
  return a > b;
  // CHECK: foo_i64_f32_gt
  // CHECK-NOT: and
  // CHECK: ret
}

long foo_i64_f32_ge(float a, float b) {
  return a >= b;
  // CHECK: foo_i64_f32_ge
  // CHECK-NOT: and
  // CHECK: ret
}

long foo_i64_f32_eq(float a, float b) {
  return a == b;
  // CHECK: foo_i64_f32_eq
  // CHECK-NOT: and
  // CHECK: ret
}

long foo_i64_f32_neq(float a, float b) {
  return a != b;
  // CHECK: foo_i64_f32_neq
  // CHECK-NOT: and
  // CHECK: ret
}

int foo_i32_f16_eq(_Float16 a, _Float16 b) {
  return a != b;
  // CHECK: foo_i32_f16_eq
  // CHECK: and
  // CHECK: ret
}

long foo_i64_f16_eq(_Float16 a, _Float16 b) {
  return a != b;
  // CHECK: foo_i64_f16_eq
  // CHECK: and
  // CHECK: ret
}
