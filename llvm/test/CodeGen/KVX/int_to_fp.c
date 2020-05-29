// RUN: clang -target kvx-cos -O3 -S %s -o - | FileCheck %s

_Float16 ui32_to_f16(unsigned int x) {
  return x;
  // CHECK: ui32_to_f16
  // CHECK: floatuw.rn
  // CHECK: fnarrowwh.rn
  // CHECK: ret
}

_Float16 ui64_to_f16(unsigned long x) {
  return x;
  // CHECK: ui64_to_f16
  // CHECK: floatud.rn
  // CHECK: fnarrowdw.rn
  // CHECK: fnarrowwh.rn
  // CHECK: ret
}

float ui32_to_f32(unsigned int x) {
  return x;
  // CHECK: ui32_to_f32
  // CHECK: floatuw.rn
  // CHECK: ret
}

float ui64_to_f32(unsigned long x) {
  return x;
  // CHECK: ui64_to_f32
  // CHECK: call __floatundisf
  // CHECK: ret
}

double ui32_to_f64(unsigned int x) {
  // CHECK: ui64_to_f32
  // CHECK: zxwd
  // CHECK: floatud.rn
  // CHECK: ret
  return x;
}

double ui64_to_f64(unsigned long x) {
  return x;
  // CHECK: ui64_to_f64
  // CHECK: floatud.rn
  // CHECK: ret
}

_Float16 i32_to_f16(int x) {
  return x;
  // CHECK: i32_to_f16
  // CHECK: floatw.rn
  // CHECK: fnarrowwh.rn
  // CHECK: ret
}

_Float16 i64_to_f16(long x) {
  return x;
  // CHECK: i64_to_f16
  // CHECK: floatd.rn
  // CHECK: fnarrowdw.rn
  // CHECK: fnarrowwh.rn
  // CHECK: ret
}

float i32_to_f32(int x) {
  return x;
  // CHECK: i32_to_f32
  // CHECK: floatw.rn
  // CHECK: ret
}

float i64_to_f32(long x) {
  return x;
  // CHECK: i64_to_f32
  // CHECK: call __floatdisf
  // CHECK: ret
}

double i32_to_f64(int x) {
  return x;
  // CHECK: i32_to_f64
  // CHECK: sxwd
  // CHECK: floatd.rn
  // CHECK: ret
}

double i64_to_f64(long x) {
  return x;
  // CHECK: i64_to_f64
  // CHECK: floatd.rn
  // CHECK: ret
}
