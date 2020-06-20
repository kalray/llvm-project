// RUN: clang -S -O3 %s -o - | FileCheck %s

typedef int __attribute__((__vector_size__(8))) v2i32;
typedef unsigned int __attribute__((__vector_size__(8))) uv2i32;

v2i32 f1(v2i32 a, v2i32 b) {
  v2i32 r;
  for (int i = 0; i < 2; i++)
    r[i] = a[i] < b[i] ? b[i] : a[i];
  return r;
  // CHECK: f1:
  // CHECK-NEXT: maxwp $r0 = $r0, $r1
  // CHECK-NEXT: ret
}

v2i32 f2(v2i32 a, v2i32 b) {
  v2i32 r;
  r[0] = a[0] < b[0] ? b[0] : a[0];
  r[1] = a[1] < b[1] ? b[1] : a[1];
  return r;
  // CHECK: f2:
  // CHECK-NEXT: maxwp $r0 = $r0, $r1
  // CHECK-NEXT: ret
}

uv2i32 f3(uv2i32 a, uv2i32 b) {
  uv2i32 r;
  for (int i = 0; i < 2; i++)
    r[i] = a[i] < b[i] ? b[i] : a[i];
  return r;
  // CHECK: f3:
  // CHECK-NEXT: maxuwp $r0 = $r0, $r1
  // CHECK-NEXT: ret
}

uv2i32 f4(uv2i32 a, uv2i32 b) {
  uv2i32 r;
  r[0] = a[0] < b[0] ? b[0] : a[0];
  r[1] = a[1] < b[1] ? b[1] : a[1];
  return r;
  // CHECK: f4:
  // CHECK-NEXT: maxuwp $r0 = $r0, $r1
  // CHECK-NEXT: ret
}

v2i32 f5(v2i32 a, v2i32 b) {
  v2i32 r;
  for (int i = 0; i < 2; i++)
    r[i] = a[i] < 20 ? 20 : a[i];
  return r;
  // CHECK: f5:
  // CHECK: maxwp $r0 = $r0, $r1
  // CHECK-NEXT: ret
}

uv2i32 f6(uv2i32 a, uv2i32 b) {
  uv2i32 r;
  for (int i = 0; i < 2; i++)
    r[i] = a[i] < 20 ? 20 : a[i];
  return r;
  // CHECK: f6:
  // CHECK: maxuwp $r0 = $r0, $r1
  // CHECK-NEXT: ret
}
