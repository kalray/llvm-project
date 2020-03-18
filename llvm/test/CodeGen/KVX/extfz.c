// RUN: clang -target kvx-cos -O3 -S %s -o - | FileCheck %s

int f1(int v) {
  return (v >> 1) & 1;
  // CHECK: f1
  // CHECK: extfz $r0 = $r0, 1, 1
  // CHECK: ret
}

int f1_2(int v) {
  return (v >> 5) & 3;
  // CHECK: f1_2
  // CHECK: extfz $r0 = $r0, 6, 5
  // CHECK: ret
}

unsigned f1_3u(unsigned int v) {
  return (v >> 5) & 16383;
  // CHECK: f1_3u
  // CHECK: extfz $r0 = $r0, 18, 5
  // CHECK: ret
}

long f1d(long v) {
  return (v >> 1) & 1;
  // CHECK: f1d
  // CHECK: extfz $r0 = $r0, 1, 1
  // CHECK: ret
}

long f1_2d(long v) {
  return (v >> 5) & 3;
  // CHECK: f1_2d
  // CHECK: extfz $r0 = $r0, 6, 5
  // CHECK: ret
}

long f1_3d(long v) {
  return (v >> 1) & ((1L << 60) - 1);
  // CHECK: f1_3d
  // CHECK: extfz $r0 = $r0, 60, 1
  // CHECK: ret
}

int f3(int v) {
  return (v >> 1) & 3;
  // CHECK: f3
  // CHECK: extfz $r0 = $r0, 2, 1
  // CHECK: ret
}

int f7(int v) {
  return (v >> 1) & 7;
  // CHECK: f7
  // CHECK: extfz $r0 = $r0, 3, 1
  // CHECK: ret
}

int f15(int v) {
  return (v >> 1) & 15;
  // CHECK: f15
  // CHECK: extfz $r0 = $r0, 4, 1
  // CHECK: ret
}

int f31(int v) {
  return (v >> 1) & 31;
  // CHECK: f31
  // CHECK: extfz $r0 = $r0, 5, 1
  // CHECK: ret
}

int f127(int v) {
  return (v >> 1) & 127;
  // CHECK: f127
  // CHECK: extfz $r0 = $r0, 7, 1
  // CHECK: ret
}

int f255(int v) {
  return (v >> 1) & 255;
  // CHECK: f255
  // CHECK: extfz $r0 = $r0, 8, 1
  // CHECK: ret
}

int f511(int v) {
  return (v >> 1) & 511;
  // CHECK: f511
  // CHECK: extfz $r0 = $r0, 9, 1
  // CHECK: ret
}

int f1023(int v) {
  return (v >> 1) & 1023;
  // CHECK: f1023
  // CHECK: extfz $r0 = $r0, 10, 1
  // CHECK: ret
}

int f2047(int v) {
  return (v >> 1) & 2047;
  // CHECK: f2047
  // CHECK: extfz $r0 = $r0, 11, 1
  // CHECK: ret
}

int f4095(int v) {
  return (v >> 1) & 4095;
  // CHECK: f4095
  // CHECK: extfz $r0 = $r0, 12, 1
  // CHECK: ret
}

int f8191(int v) {
  return (v >> 1) & 8191;
  // CHECK: f8191
  // CHECK: extfz $r0 = $r0, 13, 1
  // CHECK: ret
}

int f16383(int v) {
  return (v >> 1) & 16383;
  // CHECK: f16383
  // CHECK: extfz $r0 = $r0, 14, 1
  // CHECK: ret
}

int f32767(int v) {
  return (v >> 1) & 32767;
  // CHECK: f32767
  // CHECK: extfz $r0 = $r0, 15, 1
  // CHECK: ret
}

int f65535(int v) {
  return (v >> 1) & 65535;
  // CHECK: f65535
  // CHECK: extfz $r0 = $r0, 16, 1
  // CHECK: ret
}

int f131071(int v) {
  return (v >> 1) & 131071;
  // CHECK: f131071
  // CHECK: extfz $r0 = $r0, 17, 1
  // CHECK: ret
}

int f33554431(int v) {
  return (v >> 1) & 33554431;
  // CHECK: f33554431
  // CHECK: extfz $r0 = $r0, 25, 1
  // CHECK: ret
}

int f1073741823(int v) {
  return (v >> 1) & 1073741823;
  // CHECK: f1073741823
  // CHECK: extfz $r0 = $r0, 30, 1
  // CHECK: ret
}
