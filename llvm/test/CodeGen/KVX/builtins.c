// RUN: clang -target kvx-cos -S -O2 %s -o - | FileCheck %s

typedef int __attribute__((__vector_size__(8))) v2i32;

void await() {
  __builtin_kvx_await();
  // CHECK-LABEL: await:
  // CHECK-NEXT: await
}

char lbzu(char *p) {
  return __builtin_kvx_lbzu(p);
  // CHECK-LABEL: lbzu:
  // CHECK-NEXT: lbz.u $r0 = 0[$r0]
  // CHECK-NEXT: ret
}

short lhzu(short *p) {
  return __builtin_kvx_lhzu(p);
  // CHECK-LABEL: lhzu:
  // CHECK-NEXT: lhz.u $r0 = 0[$r0]
  // CHECK-NEXT: ret
}

int lwzu(int *p) {
  return __builtin_kvx_lwzu(p);
  // CHECK-LABEL: lwzu:
  // CHECK-NEXT: lwz.u $r0 = 0[$r0]
  // CHECK-NEXT: ret
}

long ctzd(long l) {
  // CHECK-LABEL: ctzd:
  // CHECK-NEXT: ctzd $r0 = $r0
  // CHECK-NEXT: ret
  return __builtin_kvx_ctzd(l);
}

int ctzw(int i) {
  // CHECK-LABEL: ctzw:
  // CHECK-NEXT: ctzw $r0 = $r0
  // CHECK-NEXT: ret
  return __builtin_kvx_ctzw(i);
}

v2i32 ctzwp(v2i32 v) {
  // CHECK-LABEL: ctzwp:
  // CHECK-NEXT: ctzwp $r0 = $r0
  // CHECK-NEXT: ret
  return __builtin_kvx_ctzwp(v);
}

long clzd(long l) {
  // CHECK-LABEL: clzd:
  // CHECK-NEXT: clzd $r0 = $r0
  // CHECK-NEXT: ret
  return __builtin_kvx_clzd(l);
}

int clzw(int i) {
  // CHECK-LABEL: clzw:
  // CHECK-NEXT: clzw $r0 = $r0
  // CHECK-NEXT: ret
  return __builtin_kvx_clzw(i);
}

v2i32 clzwp(v2i32 v) {
  // CHECK-LABEL: clzwp:
  // CHECK-NEXT: clzwp $r0 = $r0
  // CHECK-NEXT: ret
  return __builtin_kvx_clzwp(v);
}

long clsd(long l) {
  // CHECK-LABEL: clsd:
  // CHECK-NEXT: clsd $r0 = $r0
  // CHECK-NEXT: ret
  return __builtin_kvx_clsd(l);
}

int clsw(int i) {
  // CHECK-LABEL: clsw:
  // CHECK-NEXT: clsw $r0 = $r0
  // CHECK-NEXT: ret
  return __builtin_kvx_clsw(i);
}

v2i32 clswp(v2i32 v) {
  // CHECK-LABEL: clswp:
  // CHECK-NEXT: clswp $r0 = $r0
  // CHECK-NEXT: ret
  return __builtin_kvx_clswp(v);
}

long cbsd(long l) {
  // CHECK-LABEL: cbsd:
  // CHECK-NEXT: cbsd $r0 = $r0
  // CHECK-NEXT: ret
  return __builtin_kvx_cbsd(l);
}

int cbsw(int i) {
  // CHECK-LABEL: cbsw:
  // CHECK-NEXT: cbsw $r0 = $r0
  // CHECK-NEXT: ret
  return __builtin_kvx_cbsw(i);
}

v2i32 cbswp(v2i32 v) {
  // CHECK-LABEL: cbswp:
  // CHECK-NEXT: cbswp $r0 = $r0
  // CHECK-NEXT: ret
  return __builtin_kvx_cbswp(v);
}
