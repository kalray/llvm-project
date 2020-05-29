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

int lwzu2(int **p, int a) {
  return __builtin_kvx_lwzu(p[a]);
  // CHECK: lwzu2:
  // CHECK: ld.xs $r0 = $r1[$r0]
  // CHECK: lwz.u $r0 = 0[$r0]
  // CHECK-NEXT: ret
}

long ldu(int *p) {
  return __builtin_kvx_ldu(p);
  // CHECK-LABEL: ldu:
  // CHECK-NEXT: ld.u $r0 = 0[$r0]
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

void barrier(void) {
  // CHECK-LABEL: barrier:
  // CHECK-NEXT: barrier
  // CHECK: ret
  __builtin_kvx_barrier();
}

void errop(void) {
  // CHECK-LABEL: errop:
  // CHECK-NEXT: errop
  // CHECK: ret
  __builtin_kvx_errop();
}

void sleep(void) {
  // CHECK-LABEL: sleep:
  // CHECK-NEXT: sleep
  // CHECK: ret
  __builtin_kvx_sleep();
}

void syncgroup(unsigned long sg) {
  // CHECK-LABEL: syncgroup:
  // CHECK-NEXT: syncgroup $r0
  // CHECK: ret
  __builtin_kvx_syncgroup(sg);
}

void tlbdinval(void) {
  // CHECK-LABEL: tlbdinval:
  // CHECK-NEXT: tlbdinval
  // CHECK: ret
  __builtin_kvx_tlbdinval();
}

void tlbiinval(void) {
  // CHECK-LABEL: tlbiinval:
  // CHECK-NEXT: tlbiinval
  // CHECK: ret
  __builtin_kvx_tlbiinval();
}

void tlbprobe(void) {
  // CHECK-LABEL: tlbprobe:
  // CHECK-NEXT: tlbprobe
  // CHECK: ret
  __builtin_kvx_tlbprobe();
}

void tlbread(void) {
  // CHECK-LABEL: tlbread:
  // CHECK-NEXT: tlbread
  // CHECK: ret
  __builtin_kvx_tlbread();
}

void tlbwrite(void) {
  // CHECK-LABEL: tlbwrite:
  // CHECK-NEXT: tlbwrite
  // CHECK: ret
  __builtin_kvx_tlbwrite();
}

void waitit(unsigned long sg) {
  // CHECK-LABEL: waitit:
  // CHECK-NEXT: waitit $r0
  // CHECK: ret
  __builtin_kvx_waitit(sg);
}

void dinvall(char *p) {
  // CHECK-LABEL: dinvall:
  // CHECK-NEXT: dinvall 0[$r0]
  // CHECK-NEXT: ret
  __builtin_kvx_dinvall(p);
}

void dtouchl(char *p) {
  // CHECK-LABEL: dtouchl:
  // CHECK-NEXT: dtouchl 0[$r0]
  // CHECK-NEXT: ret
  __builtin_kvx_dtouchl(p);
}

void dzerol(char *p) {
  // CHECK-LABEL: dzerol:
  // CHECK-NEXT: dzerol 0[$r0]
  // CHECK-NEXT: ret
  __builtin_kvx_dzerol(p);
}

void iinval(void) {
  // CHECK-LABEL: iinval:
  // CHECK-NEXT: iinval
  // CHECK-NEXT: ret
  __builtin_kvx_iinval();
}

void iinvals(char *p) {
  // CHECK-LABEL: iinvals:
  // CHECK-NEXT: iinvals 0[$r0]
  // CHECK-NEXT: ret
  __builtin_kvx_iinvals(p);
}

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
