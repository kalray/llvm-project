// RUN: clang -target kvx-cos -S -O2 %s -o - | FileCheck %s

int acswapw(int *p, int a, int b) {
  // CHECK-LABEL: acswapw:
  // CHECK-NEXT: copyd $r3 = $r2
  // CHECK-NEXT: copyd $r2 = $r1
  // CHECK-NEXT: ;;
  // CHECK-NEXT: acswapw 0[$r0] = $r2r3
  // CHECK-NEXT: ;;
  // CHECK-NEXT: copyd $r0 = $r3
  // CHECK-NEXT: ret
  return __builtin_kvx_acswapw(p, a, b);
}

long acswapd(int *p, long a, long b) {
  // CHECK-LABEL: acswapd:
  // CHECK-NEXT: copyd $r3 = $r2
  // CHECK-NEXT: copyd $r2 = $r1
  // CHECK-NEXT: ;;
  // CHECK-NEXT: acswapd 0[$r0] = $r2r3
  // CHECK-NEXT: ;;
  // CHECK-NEXT: copyd $r0 = $r3
  // CHECK-NEXT: ret
  return __builtin_kvx_acswapd(p, a, b);
}

unsigned long aladdd(void *p, long v) {
  return __builtin_kvx_aladdd(p, v);
  // CHECK-LABEL: aladdd:
  // CHECK: aladdd
  // CHECK: ret
}

unsigned int aladdw(void *p, int v) {
  return __builtin_kvx_aladdw(p, v);
  // CHECK-LABEL: aladdw:
  // CHECK: aladdw
  // CHECK: ret
}
