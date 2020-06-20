// RUN: clang -S -g -O2 %s -o - | FileCheck %s

typedef short __attribute__((__vector_size__(8))) v4i16;
typedef _Float16 __attribute__((__vector_size__(8))) v4f16;

v4f16 ff1(v4f16 v, _Float16 val) {
  v[0] = val;
  return v;
  // CHECK: insf
}

v4f16 ff2(v4f16 v, _Float16 val) {
  v[1] = val;
  return v;
  // CHECK: insf
}

v4f16 ff3(v4f16 v, _Float16 val) {
  v[2] = val;
  return v;
  // CHECK: insf
}

v4f16 ff4(v4f16 v, _Float16 val) {
  v[3] = val;
  return v;
  // CHECK: insf
}

v4f16 f1(v4f16 v) {
  v[0] = 10.5;
  return v;
  // CHECK: andd
  // CHECK: ord
}

v4f16 f2(v4f16 v) {
  v[1] = 10.6;
  return v;
  // CHECK: andd
  // CHECK: ord
}

v4f16 f3(v4f16 v) {
  v[2] = 10.7;
  return v;
  // CHECK: andd
  // CHECK: ord
}

v4f16 f4(v4f16 v) {
  v[3] = 10.8;
  return v;
  // CHECK: andd
  // CHECK: ord
}

v4f16 f5(v4f16 v) {
  v[0] = -10.5;
  return v;
  // CHECK: andd
  // CHECK: ord
}

v4f16 f6(v4f16 v) {
  v[1] = -10.6;
  return v;
  // CHECK: andd
  // CHECK: ord
}

v4f16 f7(v4f16 v) {
  v[2] = -10.7;
  return v;
  // CHECK: andd
  // CHECK: ord
}

v4f16 f8(v4f16 v) {
  v[3] = -10.8;
  return v;
  // CHECK: andd
  // CHECK: ord
}
