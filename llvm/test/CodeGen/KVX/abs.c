// RUN: clang -S -O2 %s -o - | FileCheck %s

int absw(int a) {
  return abs(a);
  // CHECK-LABEL: absw:
  // CHECK-NEXT: absw $r0 = $r0
  // CHECK-NEXT: ret
}

long absd(long a) {
  return labs(a);
  // CHECK-LABEL: absd:
  // CHECK-NEXT: absd $r0 = $r0
  // CHECK-NEXT: ret
}

typedef int __attribute__((__vector_size__(8))) v2i32;

v2i32 abswp1(v2i32 a) {
  v2i32 r;
  for (int i = 0; i < 2; i++)
    r[i] = abs(a[i]);
  return r;
  // CHECK-LABEL: abswp1:
  // CHECK-NEXT: abswp $r0 = $r0
  // CHECK-NEXT: ret
}

v2i32 abswp2(v2i32 a) {
  v2i32 r;
  r[0] = abs(a[0]);
  r[1] = abs(a[1]);
  return r;
  // CHECK-LABEL: abswp2:
  // CHECK-NEXT: abswp $r0 = $r0
  // CHECK-NEXT: ret
}

typedef short __attribute__((__vector_size__(4 * sizeof(short)))) v4i16;

v4i16 abshq1(v4i16 a) {
  v4i16 r;
  for (int i = 0; i < 4; i++)
    r[i] = abs(a[i]);
  return r;
  // CHECK-LABEL: abshq1:
  // CHECK-NEXT: abshq $r0 = $r0
  // CHECK-NEXT: ret
}

v4i16 abshq2(v4i16 a, v4i16 b) {
  v4i16 r;
  r[0] = abs(a[0]);
  r[1] = abs(a[1]);
  r[2] = abs(a[2]);
  r[3] = abs(a[3]);
  return r;
  // CHECK-LABEL: abshq2:
  // CHECK-NEXT: abshq $r0 = $r0
  // CHECK-NEXT: ret
}
