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

int fixedw(float x) {
  // CHECK-LABEL: fixedw:
  // CHECK-NEXT: fixedw.rn
  // CHECK-NEXT: ret
  return __builtin_kvx_fixedw(x, ".rn");
}

unsigned int fixeduw(float x) {
  // CHECK-LABEL: fixeduw:
  // CHECK-NEXT: fixeduw.rz
  // CHECK-NEXT: ret
  return __builtin_kvx_fixeduw(x, ".rz");
}

long fixedd(double x) {
  // CHECK-LABEL: fixedd:
  // CHECK-NEXT: fixedd.rn
  // CHECK-NEXT: ret
  return __builtin_kvx_fixedd(x, ".rn");
}

unsigned long fixedud(double x) {
  // CHECK-LABEL: fixedud:
  // CHECK-NEXT: fixedud.rz
  // CHECK-NEXT: ret
  return __builtin_kvx_fixedud(x, ".rz");
}

float floatw(int x) {
  // CHECK-LABEL: floatw:
  // CHECK-NEXT: floatw.rn
  // CHECK-NEXT: ret
  return __builtin_kvx_floatw(x, ".rn");
}

float floatuw(unsigned int x) {
  // CHECK-LABEL: floatuw:
  // CHECK-NEXT: floatuw.rz
  // CHECK-NEXT: ret
  return __builtin_kvx_floatuw(x, ".rz");
}

double floatd(long x) {
  // CHECK-LABEL: floatd:
  // CHECK-NEXT: floatd.rn
  // CHECK-NEXT: ret
  return __builtin_kvx_floatd(x, ".rn");
}

double floatud(unsigned long x) {
  // CHECK-LABEL: floatud:
  // CHECK-NEXT: floatud.rz
  // CHECK-NEXT: ret
  return __builtin_kvx_floatud(x, ".rz");
}

unsigned int stsuw(unsigned int x, unsigned int y) {
  // CHECK-LABEL: stsuw:
  // CHECK-NEXT: stsuw $r0 = $r0, $r1
  // CHECK-NEXT: ret
  return __builtin_kvx_stsuw(x, y);
}

unsigned long stsud(unsigned long x, unsigned long y) {
  // CHECK-LABEL: stsud:
  // CHECK-NEXT: stsud $r0 = $r0, $r1
  // CHECK-NEXT: ret
  return __builtin_kvx_stsud(x, y);
}

void dinval(void) {
  // CHECK-LABEL: dinval:
  // CHECK-NEXT: dinval
  // CHECK-NEXT: ret
  __builtin_kvx_dinval();
}

void fence(void) {
  // CHECK-LABEL: fence:
  // CHECK-NEXT: fence
  // CHECK-NEXT: ret
  __builtin_kvx_fence();
}

float ffmaw(float a, float b, float c) {
  // CHECK-LABEL: ffmaw:
  // CHECK: ffmaw.rz $r2 = $r0, $r1
  // CHECK: copyd $r0 = $r2
  // CHECK: ret
  return __builtin_kvx_ffmaw(a, b, c, ".rz");
}

float ffmsw(float a, float b, float c) {
  // CHECK-LABEL: ffmsw:
  // CHECK: ffmsw.rz $r2 = $r0, $r1
  // CHECK: copyd $r0 = $r2
  // CHECK: ret
  return __builtin_kvx_ffmsw(a, b, c, ".rz");
}

float frecw(float a) {
  // CHECK-LABEL: frecw:
  // CHECK: frecw.rz $r0 = $r0
  // CHECK: ret
  return __builtin_kvx_finvw(a, ".rz");
}
