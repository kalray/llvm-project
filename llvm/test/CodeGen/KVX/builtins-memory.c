// RUN: clang -target kvx-cos -S -O2 %s -o - | FileCheck %s

void dinval() {
  __builtin_kvx_dinval();
  // CHECK-LABEL: dinval:
  // CHECK: dinval
  // CHECK: ret
}

void dinvall(char *p) {
  __builtin_kvx_dinvall(p);
  // CHECK-LABEL: dinvall:
  // CHECK-NEXT: dinvall 0[$r0]
  // CHECK-NEXT: ret
}

void dtouchl(char *p) {
  __builtin_kvx_dtouchl(p);
  // CHECK-LABEL: dtouchl:
  // CHECK-NEXT: dtouchl 0[$r0]
  // CHECK-NEXT: ret
}

void dzerol(char *p) {
  __builtin_kvx_dzerol(p);
  // CHECK-LABEL: dzerol:
  // CHECK-NEXT: dzerol 0[$r0]
  // CHECK-NEXT: ret
}

void fence(void) {
  __builtin_kvx_fence();
  // CHECK-LABEL: fence:
  // CHECK-NEXT: fence
  // CHECK-NEXT: ret
}

void iinval(void) {
  __builtin_kvx_iinval();
  // CHECK-LABEL: iinval:
  // CHECK-NEXT: iinval
  // CHECK-NEXT: ret
}

void iinvals(char *p) {
  __builtin_kvx_iinvals(p);
  // CHECK-LABEL: iinvals:
  // CHECK-NEXT: iinvals 0[$r0]
  // CHECK-NEXT: ret
}

void tlbdinval(void) {
  __builtin_kvx_tlbdinval();
  // CHECK-LABEL: tlbdinval:
  // CHECK-NEXT: tlbdinval
  // CHECK: ret
}

void tlbiinval(void) {
  __builtin_kvx_tlbiinval();
  // CHECK-LABEL: tlbiinval:
  // CHECK-NEXT: tlbiinval
  // CHECK: ret
}

void tlbprobe(void) {
  __builtin_kvx_tlbprobe();
  // CHECK-LABEL: tlbprobe:
  // CHECK-NEXT: tlbprobe
  // CHECK: ret
}

void tlbread(void) {
  __builtin_kvx_tlbread();
  // CHECK-LABEL: tlbread:
  // CHECK-NEXT: tlbread
  // CHECK: ret
}

void tlbwrite(void) {
  __builtin_kvx_tlbwrite();
  // CHECK-LABEL: tlbwrite:
  // CHECK-NEXT: tlbwrite
  // CHECK: ret
}

unsigned char lbz(void *p) {
  return __builtin_kvx_lbz(p, ".u", 0);
  // CHECK-LABEL: lbz:
  // CHECK-NEXT: lbz.u $r0 = 0[$r0]
  // CHECK: ret
}

int lbs(void *p) {
  return __builtin_kvx_lbs(p, ".u", 0);
  // CHECK-LABEL: lbs:
  // CHECK-NEXT: lbs.u $r0 = 0[$r0]
  // CHECK: ret
}

unsigned short lhz(void *p) {
  return __builtin_kvx_lhz(p, ".u", 0);
  // CHECK-LABEL: lhz:
  // CHECK-NEXT: lhz.u $r0 = 0[$r0]
  // CHECK: ret
}

long lhs(void *p) {
  return __builtin_kvx_lhs(p, ".u", 0);
  // CHECK-LABEL: lhs:
  // CHECK-NEXT: lhs.u $r0 = 0[$r0]
  // CHECK: ret
}

unsigned int lwz(void *p) {
  return __builtin_kvx_lwz(p, ".u", 0);
  // CHECK-LABEL: lwz:
  // CHECK-NEXT: lwz.u $r0 = 0[$r0]
  // CHECK: ret
}

long lws(void *p) {
  return __builtin_kvx_lws(p, ".u", 0);
  // CHECK-LABEL: lws:
  // CHECK-NEXT: lws.u $r0 = 0[$r0]
  // CHECK: ret
}

float lwf(void *p) {
  return __builtin_kvx_lwf(p, ".s", 1);
  // CHECK-LABEL: lwf:
  // CHECK: lwz.s $r0 = 0[$r0]
  // CHECK: ret
}

long ld(void *p) {
  return __builtin_kvx_ld(p, ".s", 1);
  // CHECK-LABEL: ld:
  // CHECK: ld.s $r0 = 0[$r0]
  // CHECK: ret
}

double ldf(void *p) {
  return __builtin_kvx_ldf(p, ".s", 1);
  // CHECK-LABEL: ldf:
  // CHECK: ld.s $r0 = 0[$r0]
  // CHECK: ret
}

typedef char int8x8_t __attribute__((__vector_size__(8 * sizeof(char))));

int8x8_t ldbo(void *p) {
  return __builtin_kvx_ldbo(p, ".s", 1);
  // CHECK-LABEL: ldbo:
  // CHECK: ld.s $r0 = 0[$r0]
  // CHECK: ret
}

typedef short int16x4_t __attribute__((__vector_size__(4 * sizeof(short))));

int16x4_t ldhq(void *p) {
  return __builtin_kvx_ldhq(p, ".s", 1);
  // CHECK-LABEL: ldhq:
  // CHECK: ld.s $r0 = 0[$r0]
  // CHECK: ret
}

typedef int int32x2_t __attribute__((__vector_size__(2 * sizeof(int))));

int32x2_t ldwp(void *p) {
  return __builtin_kvx_ldwp(p, ".s", 1);
  // CHECK-LABEL: ldwp:
  // CHECK: ld.s $r0 = 0[$r0]
  // CHECK: ret
}

typedef float float32x2_t __attribute__((__vector_size__(2 * sizeof(float))));

float32x2_t ldfwp(void *p) {
  return __builtin_kvx_ldfwp(p, ".s", 1);
  // CHECK-LABEL: ldfwp:
  // CHECK: ld.s $r0 = 0[$r0]
  // CHECK: ret
}

void sdbo(void *p, int8x8_t v) {
  __builtin_kvx_sdbo(p, v, 1);
  // CHECK-LABEL: sdbo:
  // CHECK: sd 0[$r0] = $r1
  // CHECK: ret
}

void sdhq(void *p, int16x4_t v) {
  __builtin_kvx_sdhq(p, v, 1);
  // CHECK-LABEL: sdhq:
  // CHECK: sd 0[$r0] = $r1
  // CHECK: ret
}

void sdwp(void *p, int32x2_t v) {
  __builtin_kvx_sdwp(p, v, 1);
  // CHECK-LABEL: sdwp:
  // CHECK: sd 0[$r0] = $r1
  // CHECK: ret
}

void sdfwp(void *p, float32x2_t v) {
  __builtin_kvx_sdhq(p, v, 1);
  // CHECK-LABEL: sdfwp:
  // CHECK: sd 0[$r0] = $r1
  // CHECK: ret
}
