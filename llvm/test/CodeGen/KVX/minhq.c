// RUN: clang -S -O3 %s -o - | FileCheck %s

typedef short __attribute__((__vector_size__(4 * sizeof(short)))) v4i16;
typedef unsigned short __attribute__((__vector_size__(4 * sizeof(short))))
uv4i16;

v4i16 f1(v4i16 a, v4i16 b) {
  v4i16 r;
  for (int i = 0; i < 4; i++)
    r[i] = a[i] > b[i] ? b[i] : a[i];
  return r;
  // CHECK: f1:
  // CHECK-NEXT: minhq $r0 = $r0, $r1
  // CHECK-NEXT: ret
}

v4i16 f2(v4i16 a, v4i16 b) {
  v4i16 r;
  r[0] = a[0] > b[0] ? b[0] : a[0];
  r[1] = a[1] > b[1] ? b[1] : a[1];
  r[2] = a[2] > b[2] ? b[2] : a[2];
  r[3] = a[3] > b[3] ? b[3] : a[3];
  return r;
  // CHECK: f2:
  // CHECK-NEXT: minhq $r0 = $r0, $r1
  // CHECK-NEXT: ret
}

uv4i16 f3(uv4i16 a, uv4i16 b) {
  uv4i16 r;
  for (int i = 0; i < 4; i++)
    r[i] = a[i] > b[i] ? b[i] : a[i];
  return r;
  // CHECK: f3:
  // CHECK-NEXT: minuhq $r0 = $r0, $r1
  // CHECK-NEXT: ret
}

uv4i16 f4(uv4i16 a, uv4i16 b) {
  uv4i16 r;
  r[0] = a[0] > b[0] ? b[0] : a[0];
  r[1] = a[1] > b[1] ? b[1] : a[1];
  r[2] = a[2] > b[2] ? b[2] : a[2];
  r[3] = a[3] > b[3] ? b[3] : a[3];
  return r;
  // CHECK: f4:
  // CHECK-NEXT: minuhq $r0 = $r0, $r1
  // CHECK-NEXT: ret
}

v4i16 f5(v4i16 a, v4i16 b) {
  v4i16 r;
  for (int i = 0; i < 4; i++)
    r[i] = a[i] > 20 ? 20 : a[i];
  return r;
  // CHECK: f5:
  // CHECK: minhq $r0 = $r0, $r1
  // CHECK-NEXT: ret
}

uv4i16 f6(uv4i16 a, uv4i16 b) {
  uv4i16 r;
  for (int i = 0; i < 4; i++)
    r[i] = a[i] > 20 ? 20 : a[i];
  return r;
  // CHECK: f6:
  // CHECK: minuhq $r0 = $r0, $r1
  // CHECK-NEXT: ret
}
