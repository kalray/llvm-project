// RUN: clang -target kvx-cos -S -O2 %s -o - | FileCheck %s

typedef int __attribute__((__vector_size__(8))) v2i32;

v2i32 ctzwp(v2i32 v) {
  // CHECK-LABEL: ctzwp:
  // CHECK-NEXT: ctzwp $r0 = $r0
  // CHECK-NEXT: ret
  return __builtin_kvx_ctzwp(v);
}

v2i32 clzwp(v2i32 v) {
  // CHECK-LABEL: clzwp:
  // CHECK-NEXT: clzwp $r0 = $r0
  // CHECK-NEXT: ret
  return __builtin_kvx_clzwp(v);
}

v2i32 clswp(v2i32 v) {
  // CHECK-LABEL: clswp:
  // CHECK-NEXT: clswp $r0 = $r0
  // CHECK-NEXT: ret
  return __builtin_kvx_clswp(v);
}

v2i32 cbswp(v2i32 v) {
  // CHECK-LABEL: cbswp:
  // CHECK-NEXT: cbswp $r0 = $r0
  // CHECK-NEXT: ret
  return __builtin_kvx_cbswp(v);
}
