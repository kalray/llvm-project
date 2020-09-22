// RUN: clang -target kvx-cos -S -O2 %s -o - | FileCheck %s

int abdw(int v1, int v2) {
  return __builtin_kvx_abdw(v1, v2);
  // CHECK-LABEL: abdw:
  // CHECK: abdw
  // CHECK: ret
}

long abdd(long v1, long v2) {
  return __builtin_kvx_abdd(v1, v2);
  // CHECK-LABEL: abdd:
  // CHECK: abdd
  // CHECK: ret
}

int addsw(int v1, int v2) {
  return __builtin_kvx_addsw(v1, v2);
  // CHECK-LABEL: addsw:
  // CHECK: addsw
  // CHECK: ret
}

long addsd(long v1, long v2) {
  return __builtin_kvx_addsd(v1, v2);
  // CHECK-LABEL: addsd:
  // CHECK: addsd
  // CHECK: ret
}

int sbfsw(int v1, int v2) {
  return __builtin_kvx_sbfsw(v1, v2);
  // CHECK-LABEL: sbfsw:
  // CHECK: sbfsw
  // CHECK: ret
}

long sbfsd(long v1, long v2) {
  return __builtin_kvx_sbfsd(v1, v2);
  // CHECK-LABEL: sbfsd:
  // CHECK: sbfsd
  // CHECK: ret
}

long adddc(long v1, long v2) {
  return __builtin_kvx_addd(v1, v2, ".c");
  // CHECK-LABEL: adddc:
  // CHECK: addd.c
  // CHECK: ret
}

long adddci(long v1, long v2) {
  return __builtin_kvx_addd(v1, v2, ".ci");
  // CHECK-LABEL: adddci:
  // CHECK: addd.ci
  // CHECK: ret
}

long sbfdc(long v1, long v2) {
  return __builtin_kvx_sbfd(v1, v2, ".c");
  // CHECK-LABEL: sbfdc:
  // CHECK: sbfd.c
  // CHECK: ret
}

long sbfdci(long v1, long v2) {
  return __builtin_kvx_sbfd(v1, v2, ".ci");
  // CHECK-LABEL: sbfdci:
  // CHECK: sbfd.ci
  // CHECK: ret
}

int avgw(int v1, int v2) {
  return __builtin_kvx_avgw(v1, v2);
  // CHECK-LABEL: avgw:
  // CHECK: avgw
  // CHECK: ret
}

unsigned int avguw(unsigned int v1, unsigned int v2) {
  return __builtin_kvx_avguw(v1, v2);
  // CHECK-LABEL: avguw:
  // CHECK: avguw
  // CHECK: ret
}

int avgrw(int v1, int v2) {
  return __builtin_kvx_avgrw(v1, v2);
  // CHECK-LABEL: avgrw:
  // CHECK: avgrw
  // CHECK: ret
}

unsigned int avgruw(int v1, int v2) {
  return __builtin_kvx_avgruw(v1, v2);
  // CHECK-LABEL: avgruw:
  // CHECK: avgruw
  // CHECK: ret
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

float fabsw(float v) {
  return __builtin_kvx_fabsw(v);
  // CHECK-LABEL: fabsw:
  // CHECK: fabsw
  // CHECK: ret
}

double fabsd(double v) {
  return __builtin_kvx_fabsd(v);
  // CHECK-LABEL: fabsd:
  // CHECK: fabsd
  // CHECK: ret
}

float fnegw(float v) {
  return __builtin_kvx_fnegw(v);
  // CHECK-LABEL: fnegw:
  // CHECK: fnegw
  // CHECK: ret
}

double fnegd(double v) {
  return __builtin_kvx_fnegd(v);
  // CHECK-LABEL: fnegd:
  // CHECK: fnegd
  // CHECK: ret
}

float fmaxw(float v1, float v2) {
  return __builtin_kvx_fmaxw(v1, v2);
  // CHECK-LABEL: fmaxw:
  // CHECK: fmaxw
  // CHECK: ret
}

double fmaxd(double v1, double v2) {
  return __builtin_kvx_fmaxd(v1, v2);
  // CHECK-LABEL: fmaxd:
  // CHECK: fmaxd
  // CHECK: ret
}

float fminw(float v1, float v2) {
  return __builtin_kvx_fminw(v1, v2);
  // CHECK-LABEL: fminw:
  // CHECK: fminw
  // CHECK: ret
}

double fmind(double v1, double v2) {
  return __builtin_kvx_fmind(v1, v2);
  // CHECK-LABEL: fmind:
  // CHECK: fmind
  // CHECK: ret
}

float frecw(float a) {
  // CHECK-LABEL: frecw:
  // CHECK: frecw.rz
  // CHECK: ret
  return __builtin_kvx_frecw(a, ".rz");
}

float frsrw(float a) {
  // CHECK-LABEL: frsrw:
  // CHECK: frsrw.rz
  // CHECK: ret
  return __builtin_kvx_frsrw(a, ".rz");
}

float faddw(float v1, float v2) {
  return __builtin_kvx_faddw(v1, v2, ".rz");
  // CHECK-LABEL: faddw:
  // CHECK: faddw.rz
  // CHECK: ret
}

double faddd(float v1, float v2) {
  return __builtin_kvx_faddd(v1, v2, ".rz");
  // CHECK-LABEL: faddd:
  // CHECK: faddd.rz
  // CHECK: ret
}

float fsbfw(float v1, float v2) {
  return __builtin_kvx_fsbfw(v1, v2, ".rz");
  // CHECK-LABEL: fsbfw:
  // CHECK: fsbfw.rz
  // CHECK: ret
}

double fsbfd(double v1, double v2) {
  return __builtin_kvx_fsbfd(v1, v2, ".rz");
  // CHECK-LABEL: fsbfd:
  // CHECK: fsbfd.rz
  // CHECK: ret
}

float fmulw(float v1, float v2) {
  return __builtin_kvx_fmulw(v1, v2, ".rz");
  // CHECK-LABEL: fmulw:
  // CHECK: fmulw.rz
  // CHECK: ret
}

double fmuld(double v1, double v2) {
  return __builtin_kvx_fmuld(v1, v2, ".rz");
  // CHECK-LABEL: fmuld:
  // CHECK: fmuld.rz
  // CHECK: ret
}

double fmulwd(float v1, float v2) {
  return __builtin_kvx_fmulwd(v1, v2, ".rz");
  // CHECK-LABEL: fmulwd:
  // CHECK: fmulwd.rz
  // CHECK: ret
}

float ffmaw(float a, float b, float c) {
  // CHECK-LABEL: ffmaw:
  // CHECK: ffmaw.rz
  // CHECK: ret
  return __builtin_kvx_ffmaw(a, b, c, ".rz");
}

double ffmad(double a, double b, double c) {
  // CHECK-LABEL: ffmad:
  // CHECK: ffmad.rz
  // CHECK: ret
  return __builtin_kvx_ffmad(a, b, c, ".rz");
}

double ffmawd(float a, float b, double c) {
  // CHECK-LABEL: ffmawd:
  // CHECK: ffmawd.rz
  // CHECK: ret
  return __builtin_kvx_ffmawd(a, b, c, ".rz");
}

float ffmsw(float a, float b, float c) {
  // CHECK-LABEL: ffmsw:
  // CHECK: ffmsw.rz
  // CHECK: ret
  return __builtin_kvx_ffmsw(a, b, c, ".rz");
}

double ffmsd(double a, double b, double c) {
  // CHECK-LABEL: ffmsd:
  // CHECK: ffmsd.rz
  // CHECK: ret
  return __builtin_kvx_ffmsd(a, b, c, ".rz");
}

double ffmswd(float a, float b, double c) {
  // CHECK-LABEL: ffmswd:
  // CHECK: ffmswd.rz
  // CHECK: ret
  return __builtin_kvx_ffmswd(a, b, c, ".rz");
}

float floatw(int x) {
  // CHECK-LABEL: floatw:
  // CHECK-NEXT: floatw.rn $r0 = $r0, 3
  // CHECK-NEXT: ret
  return __builtin_kvx_floatw(x, 3, ".rn");
}

double floatd(long x) {
  // CHECK-LABEL: floatd:
  // CHECK-NEXT: floatd.rn $r0 = $r0, 3
  // CHECK-NEXT: ret
  return __builtin_kvx_floatd(x, 3, ".rn");
}

float floatuw(unsigned int x) {
  // CHECK-LABEL: floatuw:
  // CHECK-NEXT: floatuw.rz $r0 = $r0, 3
  // CHECK-NEXT: ret
  return __builtin_kvx_floatuw(x, 3, ".rz");
}

double floatud(unsigned long x) {
  // CHECK-LABEL: floatud:
  // CHECK-NEXT: floatud.rz $r0 = $r0, 3
  // CHECK-NEXT: ret
  return __builtin_kvx_floatud(x, 3, ".rz");
}

int fixedw(float x) {
  // CHECK-LABEL: fixedw:
  // CHECK-NEXT: fixedw.rn $r0 = $r0, 3
  // CHECK-NEXT: ret
  return __builtin_kvx_fixedw(x, 3, ".rn");
}

long fixedd(double x) {
  // CHECK-LABEL: fixedd:
  // CHECK-NEXT: fixedd.rn $r0 = $r0, 3
  // CHECK-NEXT: ret
  return __builtin_kvx_fixedd(x, 3, ".rn");
}

unsigned int fixeduw(float x) {
  // CHECK-LABEL: fixeduw:
  // CHECK-NEXT: fixeduw.rz $r0 = $r0, 3
  // CHECK-NEXT: ret
  return __builtin_kvx_fixeduw(x, 3, ".rz");
}

unsigned long fixedud(double x) {
  // CHECK-LABEL: fixedud:
  // CHECK-NEXT: fixedud.rz $r0 = $r0, 3
  // CHECK-NEXT: ret
  return __builtin_kvx_fixedud(x, 3, ".rz");
}

float fcdivw(float v1, float v2) {
  return __builtin_kvx_fcdivw(v1, v2);
  // CHECK-LABEL: fcdivw:
  // CHECK: fcdivw
  // CHECK: ret
}

double fcdivd(double v1, double v2) {
  return __builtin_kvx_fcdivd(v1, v2);
  // CHECK-LABEL: fcdivd:
  // CHECK: fcdivd
  // CHECK: ret
}

float fsdivw(float v1, float v2) {
  return __builtin_kvx_fsdivw(v1, v2);
  // CHECK-LABEL: fsdivw:
  // CHECK: fsdivw
  // CHECK: ret
}

double fsdivd(double v1, double v2) {
  return __builtin_kvx_fsdivd(v1, v2);
  // CHECK-LABEL: fsdivd:
  // CHECK: fsdivd
  // CHECK: ret
}

float fsrecw(double v) {
  return __builtin_kvx_fsrecw(v);
  // CHECK-LABEL: fsrecw:
  // CHECK: fsrecw
  // CHECK: ret
}

double fsrecd(double v) {
  return __builtin_kvx_fsrecd(v);
  // CHECK-LABEL: fsrecd:
  // CHECK: fsrecd
  // CHECK: ret
}

long sbmm8(long a, long b) {
  return __builtin_kvx_sbmm8(a, b);
  // CHECK-LABEL: sbmm8:
  // CHECK: sbmm8
  // CHECK: ret
}

long sbmmt8(long a, long b) {
  return __builtin_kvx_sbmmt8(a, b);
  // CHECK-LABEL: sbmmt8:
  // CHECK: sbmmt8
  // CHECK: ret
}

long satd(long v, unsigned char b) {
  return __builtin_kvx_satd(v, b);
  // CHECK-LABEL: satd:
  // CHECK: satd
  // CHECK: ret
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

float fwidenlhw(unsigned int v) {
  return __builtin_kvx_fwidenlhw(v);
  // CHECK-LABEL: fwidenlhw:
  // CHECK: fwidenlhw
  // CHECK: ret
}

float fwidenmhw(unsigned int v) {
  return __builtin_kvx_fwidenmhw(v);
  // CHECK-LABEL: fwidenmhw:
  // CHECK: fwidenmhw
  // CHECK: ret
}

unsigned short fnarrowwh(float v) {
  return __builtin_kvx_fnarrowwh(v);
  // CHECK-LABEL: fnarrowwh:
  // CHECK: fnarrowwh
  // CHECK: ret
}
