// RUN: clang -target kvx-cos -S -O2 %s -o - | FileCheck %s

typedef int __attribute__((__vector_size__(8))) v2i32;
typedef short __attribute__((__vector_size__(4 * sizeof(short)))) v4i16;
typedef short __attribute__((__vector_size__(8 * sizeof(short)))) v8i16;
typedef short __attribute__((__vector_size__(16 * sizeof(short)))) v16i16;
typedef int __attribute__((__vector_size__(2 * sizeof(int)))) v2i32;
typedef int __attribute__((__vector_size__(4 * sizeof(int)))) v4i32;
typedef int __attribute__((__vector_size__(8 * sizeof(int)))) v8i32;
typedef long __attribute__((__vector_size__(2 * sizeof(long)))) v2i64;
typedef long __attribute__((__vector_size__(4 * sizeof(long)))) v4i64;

typedef unsigned int __attribute__((__vector_size__(2 * sizeof(unsigned int))))
v2u32;
typedef unsigned int __attribute__((__vector_size__(4 * sizeof(unsigned int))))
v4u32;
typedef unsigned int __attribute__((__vector_size__(8 * sizeof(unsigned int))))
v8u32;

typedef unsigned long
    __attribute__((__vector_size__(2 * sizeof(unsigned long)))) v2u64;
typedef unsigned long
    __attribute__((__vector_size__(4 * sizeof(unsigned long)))) v4u64;

typedef float __attribute__((__vector_size__(2 * sizeof(float)))) v2f32;
typedef float __attribute__((__vector_size__(4 * sizeof(float)))) v4f32;
typedef float __attribute__((__vector_size__(8 * sizeof(float)))) v8f32;

typedef double __attribute__((__vector_size__(2 * sizeof(double)))) v2f64;
typedef double __attribute__((__vector_size__(4 * sizeof(double)))) v4f64;

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

v4i16 cmovehq(v4i16 v1, v4i16 v2, v4i16 c) {
  return __builtin_kvx_cmovehq(v1, v2, c, ".nez");
  // CHECK-LABEL: cmovehq:
  // CHECK: cmovehq.nez $r2 ? $r0 = $r1
  // CHECK: ret
}

v8i16 cmoveho(v8i16 v1, v8i16 v2, v8i16 c) {
  return __builtin_kvx_cmoveho(v1, v2, c, ".nez");
  // CHECK-LABEL: cmoveho:
  // CHECK: cmovehq.nez $r4 ? $r0 = $r2
  // CHECK: cmovehq.nez $r5 ? $r1 = $r3
  // CHECK: ret
}

v16i16 cmovehx(v16i16 v1, v16i16 v2, v16i16 c) {
  return __builtin_kvx_cmovehx(v1, v2, c, ".nez");
  // CHECK-LABEL: cmovehx:
  // CHECK: cmovehq.nez $r8 ? $r0 = $r4
  // CHECK: cmovehq.nez $r9 ? $r1 = $r5
  // CHECK: cmovehq.nez $r10 ? $r2 = $r6
  // CHECK: cmovehq.nez $r11 ? $r3 = $r7
  // CHECK: ret
}

v2i32 cmovewp(v2i32 v1, v2i32 v2, v2i32 c) {
  return __builtin_kvx_cmovewp(v1, v2, c, ".nez");
  // CHECK-LABEL: cmovewp:
  // CHECK: cmovewp.nez $r2 ? $r0 = $r1
  // CHECK: ret
}

v4i32 cmovewq(v4i32 v1, v4i32 v2, v4i32 c) {
  return __builtin_kvx_cmovewq(v1, v2, c, ".nez");
  // CHECK-LABEL: cmovewq:
  // CHECK: cmovewp.nez $r4 ? $r0 = $r2
  // CHECK: cmovewp.nez $r5 ? $r1 = $r3
  // CHECK: ret
}

v8i32 cmovewo(v8i32 v1, v8i32 v2, v8i32 c) {
  return __builtin_kvx_cmovewo(v1, v2, c, ".nez");
  // CHECK-LABEL: cmovewo:
  // CHECK: cmovewp.nez $r8 ? $r0 = $r4
  // CHECK: cmovewp.nez $r9 ? $r1 = $r5
  // CHECK: cmovewp.nez $r10 ? $r2 = $r6
  // CHECK: cmovewp.nez $r11 ? $r3 = $r7
  // CHECK: ret
}

v2i64 cmovedp(v2i64 v1, v2i64 v2, v2i64 c) {
  return __builtin_kvx_cmovedp(v1, v2, c, ".nez");
  // CHECK-LABEL: cmovedp:
  // CHECK: cmoved.dnez $r4 ? $r0 = $r2
  // CHECK: cmoved.dnez $r5 ? $r1 = $r3
  // CHECK: ret
}

v4i64 cmovedq(v4i64 v1, v4i64 v2, v4i64 c) {
  return __builtin_kvx_cmovedq(v1, v2, c, ".nez");
  // CHECK-LABEL: cmovedq:
  // CHECK: cmoved.dnez $r8 ? $r0 = $r4
  // CHECK: cmoved.dnez $r9 ? $r1 = $r5
  // CHECK: cmoved.dnez $r10 ? $r2 = $r6
  // CHECK: cmoved.dnez $r11 ? $r3 = $r7
  // CHECK: ret
}

v2f32 cmovefwp(v2f32 v1, v2f32 v2, v2i32 c) {
  return __builtin_kvx_cmovefwp(v1, v2, c, ".nez");
  // CHECK-LABEL: cmovefwp:
  // CHECK: cmovewp.nez $r2 ? $r0 = $r1
  // CHECK: ret
}

v4f32 cmovefwq(v4f32 v1, v4f32 v2, v4i32 c) {
  return __builtin_kvx_cmovefwq(v1, v2, c, ".nez");
  // CHECK-LABEL: cmovefwq:
  // CHECK: cmovewp.nez $r4 ? $r0 = $r2
  // CHECK: cmovewp.nez $r5 ? $r1 = $r3
  // CHECK: ret
}

v8f32 cmovefwo(v8f32 v1, v8f32 v2, v8i32 c) {
  return __builtin_kvx_cmovefwo(v1, v2, c, ".nez");
  // CHECK-LABEL: cmovefwo:
  // CHECK: cmovewp.nez $r8 ? $r0 = $r4
  // CHECK: cmovewp.nez $r9 ? $r1 = $r5
  // CHECK: cmovewp.nez $r10 ? $r2 = $r6
  // CHECK: cmovewp.nez $r11 ? $r3 = $r7
  // CHECK: ret
}

v2f64 cmovefdp(v2f64 v1, v2f64 v2, v2i64 c) {
  return __builtin_kvx_cmovefdp(v1, v2, c, ".nez");
  // CHECK-LABEL: cmovefdp:
  // CHECK: cmoved.dnez $r4 ? $r0 = $r2
  // CHECK: cmoved.dnez $r5 ? $r1 = $r3
  // CHECK: ret
}

v4f64 cmovefdq(v4f64 v1, v4f64 v2, v4i64 c) {
  return __builtin_kvx_cmovefdq(v1, v2, c, ".nez");
  // CHECK-LABEL: cmovefdq:
  // CHECK: cmoved.dnez $r8 ? $r0 = $r4
  // CHECK: cmoved.dnez $r10 ? $r2 = $r6
  // CHECK: cmoved.dnez $r9 ? $r1 = $r5
  // CHECK: cmoved.dnez $r11 ? $r3 = $r7
  // CHECK: ret
}

v2f32 fabswp(v2f32 v) {
  return __builtin_kvx_fabswp(v);
  // CHECK-LABEL: fabswp:
  // CHECK: fabswp $r0 = $r0
  // CHECK: ret
}

v4f32 fabswq(v4f32 v) {
  return __builtin_kvx_fabswq(v);
  // CHECK-LABEL: fabswq:
  // CHECK: fabswp $r0 = $r0
  // CHECK: fabswp $r1 = $r1
  // CHECK: ret
}

v8f32 fabswo(v8f32 v) {
  return __builtin_kvx_fabswo(v);
  // CHECK-LABEL: fabswo:
  // CHECK: fabswp $r0 = $r0
  // CHECK: fabswp $r1 = $r1
  // CHECK: fabswp $r2 = $r2
  // CHECK: fabswp $r3 = $r3
  // CHECK: ret
}

v2f64 fabsdp(v2f64 v) {
  return __builtin_kvx_fabsdp(v);
  // CHECK-LABEL: fabsdp:
  // CHECK: fabsd $r0 = $r0
  // CHECK: fabsd $r1 = $r1
  // CHECK: ret
}

v4f64 fabsdq(v4f64 v) {
  return __builtin_kvx_fabsdq(v);
  // CHECK-LABEL: fabsdq:
  // CHECK: fabsd $r0 = $r0
  // CHECK: fabsd $r1 = $r1
  // CHECK: fabsd $r2 = $r2
  // CHECK: fabsd $r3 = $r3
  // CHECK: ret
}

v2f32 fnegwp(v2f32 v) {
  return __builtin_kvx_fnegwp(v);
  // CHECK-LABEL: fnegwp:
  // CHECK: fnegwp $r0 = $r0
  // CHECK: ret
}

v4f32 fnegwq(v4f32 v) {
  return __builtin_kvx_fnegwq(v);
  // CHECK-LABEL: fnegwq:
  // CHECK: fnegwp $r0 = $r0
  // CHECK: fnegwp $r1 = $r1
  // CHECK: ret
}

v8f32 fnegwo(v8f32 v) {
  return __builtin_kvx_fnegwo(v);
  // CHECK-LABEL: fnegwo:
  // CHECK: fnegwp $r0 = $r0
  // CHECK: fnegwp $r1 = $r1
  // CHECK: fnegwp $r2 = $r2
  // CHECK: fnegwp $r3 = $r3
  // CHECK: ret
}

v2f64 fnegdp(v2f64 v) {
  return __builtin_kvx_fnegdp(v);
  // CHECK-LABEL: fnegdp:
  // CHECK: fnegd $r0 = $r0
  // CHECK: fnegd $r1 = $r1
  // CHECK: ret
}

v4f64 fnegdq(v4f64 v) {
  return __builtin_kvx_fnegdq(v);
  // CHECK-LABEL: fnegdq:
  // CHECK: fnegd $r0 = $r0
  // CHECK: fnegd $r1 = $r1
  // CHECK: fnegd $r2 = $r2
  // CHECK: fnegd $r3 = $r3
  // CHECK: ret
}

v2f32 fmaxwp(v2f32 v1, v2f32 v2) {
  return __builtin_kvx_fmaxwp(v1, v2);
  // CHECK-LABEL: fmaxwp:
  // CHECK: fmaxwp $r0 = $r0, $r1
  // CHECK: ret
}

v4f32 fmaxwq(v4f32 v1, v4f32 v2) {
  return __builtin_kvx_fmaxwq(v1, v1);
  // CHECK-LABEL: fmaxwq:
  // CHECK: fmaxwp $r0 = $r0, $r0
  // CHECK: fmaxwp $r1 = $r1, $r1
  // CHECK: ret
}

v8f32 fmaxwo(v8f32 v1, v8f32 v2) {
  return __builtin_kvx_fmaxwo(v1, v2);
  // CHECK-LABEL: fmaxwo:
  // CHECK: fmaxwp $r0 = $r0, $r4
  // CHECK: fmaxwp $r1 = $r1, $r5
  // CHECK: fmaxwp $r2 = $r2, $r6
  // CHECK: fmaxwp $r3 = $r3, $r7
  // CHECK: ret
}

v2f64 fmaxdp(v2f64 v1, v2f64 v2) {
  return __builtin_kvx_fmaxdp(v1, v2);
  // CHECK-LABEL: fmaxdp:
  // CHECK: fmaxd $r0 = $r0, $r2
  // CHECK: fmaxd $r1 = $r1, $r3
  // CHECK: ret
}

v4f64 fmaxdq(v4f64 v1, v4f64 v2) {
  return __builtin_kvx_fmaxdq(v1, v2);
  // CHECK-LABEL: fmaxdq
  // CHECK: fmaxd $r0 = $r0, $r4
  // CHECK: fmaxd $r1 = $r1, $r5
  // CHECK: fmaxd $r2 = $r2, $r6
  // CHECK: fmaxd $r3 = $r3, $r7
  // CHECK: ret
}

v2f32 fminwp(v2f32 v1, v2f32 v2) {
  return __builtin_kvx_fminwp(v1, v2);
  // CHECK-LABEL: fminwp:
  // CHECK: fminwp $r0 = $r0, $r1
  // CHECK: ret
}

v4f32 fminwq(v4f32 v1, v4f32 v2) {
  return __builtin_kvx_fminwq(v1, v2);
  // CHECK-LABEL: fminwq:
  // CHECK: fminwp $r0 = $r0, $r2
  // CHECK: fminwp $r1 = $r1, $r3
  // CHECK: ret
}

v8f32 fminwo(v8f32 v1, v8f32 v2) {
  return __builtin_kvx_fminwo(v1, v2);
  // CHECK-LABEL: fminwo:
  // CHECK: fminwp $r0 = $r0, $r4
  // CHECK: fminwp $r1 = $r1, $r5
  // CHECK: fminwp $r2 = $r2, $r6
  // CHECK: fminwp $r3 = $r3, $r7
  // CHECK: ret
}

v2f64 fmindp(v2f64 v1, v2f64 v2) {
  return __builtin_kvx_fmindp(v1, v2);
  // CHECK-LABEL: fmindp:
  // CHECK: fmind $r0 = $r0, $r2
  // CHECK: fmind $r1 = $r1, $r3
  // CHECK: ret
}

v4f64 fmindq(v4f64 v1, v4f64 v2) {
  return __builtin_kvx_fmindq(v1, v2);
  // CHECK-LABEL: fmindq:
  // CHECK: fmind $r0 = $r0, $r4
  // CHECK: fmind $r1 = $r1, $r5
  // CHECK: fmind $r2 = $r2, $r6
  // CHECK: fmind $r3 = $r3, $r7
  // CHECK: ret
}

v2f32 faddwp(v2f32 v1, v2f32 v2) {
  return __builtin_kvx_faddwp(v1, v2, ".rn");
  // CHECK-LABEL: faddwp:
  // CHECK: faddwp.rn $r0 = $r0, $r1
  // CHECK: ret
}

v4f32 faddwq(v4f32 v1, v4f32 v2) {
  return __builtin_kvx_faddwq(v1, v2, ".rn");
  // CHECK-LABEL: faddwq:
  // CHECK: faddwq.rn $r0r1 = $r0r1, $r2r3
  // CHECK: ret
}

v8f32 faddwo(v8f32 v1, v8f32 v2) {
  return __builtin_kvx_faddwo(v1, v2, ".rn");
  // CHECK-LABEL: faddwo:
  // CHECK: faddwq.rn $r0r1 = $r0r1, $r4r5
  // CHECK: faddwq.rn $r2r3 = $r2r3, $r6r7
  // CHECK: ret
}

v2f64 fadddp(v2f64 v1, v2f64 v2) {
  return __builtin_kvx_fadddp(v1, v2, ".rn");
  // CHECK-LABEL: fadddp:
  // CHECK: fadddp.rn $r0r1 = $r0r1, $r2r3
  // CHECK: ret
}

v4f64 fadddq(v4f64 v1, v4f64 v2) {
  return __builtin_kvx_fadddq(v1, v2, ".rn");
  // CHECK-LABEL: fadddq:
  // CHECK: fadddp.rn $r0r1 = $r0r1, $r4r5
  // CHECK: fadddp.rn $r2r3 = $r2r3, $r6r7
  // CHECK: ret
}

v2f32 faddcwc(v2f32 v1, v2f32 v2) {
  return __builtin_kvx_faddcwc(v1, v1, ".rn");
  // CHECK-LABEL: faddcwc:
  // CHECK: faddcwc.rn $r0 = $r0, $r0
  // CHECK: ret
}

v4f32 faddcwcp(v4f32 v1, v4f32 v2) {
  return __builtin_kvx_faddcwcp(v1, v2, ".rn");
  // CHECK-LABEL: faddcwcp:
  // CHECK: faddcwcp.rn $r0r1 = $r0r1, $r2r3
  // CHECK: ret
}

v8f32 faddcwcq(v8f32 v1, v8f32 v2) {
  return __builtin_kvx_faddcwcq(v1, v2, ".rn");
  // CHECK-LABEL: faddcwcq:
  // CHECK: faddcwcp.rn $r0r1 = $r0r1, $r4r5
  // CHECK: faddcwcp.rn $r2r3 = $r2r3, $r6r7
  // CHECK: ret
}

v2f64 faddcdc(v2f64 v1, v2f64 v2) {
  return __builtin_kvx_faddcdc(v1, v2, ".rn");
  // CHECK-LABEL: faddcdc:
  // CHECK: faddcdc.rn $r0r1 = $r0r1, $r2r3
  // CHECK: ret
}

v4f64 faddcdcp(v4f64 v1, v4f64 v2) {
  return __builtin_kvx_faddcdcp(v1, v2, ".rn");
  // CHECK-LABEL: faddcdcp:
  // CHECK: faddcdc.rn $r0r1 = $r0r1, $r4r5
  // CHECK: faddcdc.rn $r2r3 = $r2r3, $r6r7
  // CHECK: ret
}

v2f32 fsbfwp(v2f32 v1, v2f32 v2) {
  return __builtin_kvx_fsbfwp(v1, v2, ".rn");
  // CHECK-LABEL: fsbfwp:
  // CHECK: fsbfwp.rn $r0 = $r0, $r1
  // CHECK: ret
}

v4f32 fsbfwq(v4f32 v1, v4f32 v2) {
  return __builtin_kvx_fsbfwq(v1, v2, ".rn");
  // CHECK-LABEL: fsbfwq:
  // CHECK: fsbfwq.rn $r0r1 = $r0r1, $r2r3
  // CHECK: ret
}

v8f32 fsbfwo(v8f32 v1, v8f32 v2) {
  return __builtin_kvx_fsbfwo(v1, v2, ".rn");
  // CHECK-LABEL: fsbfwo:
  // CHECK: fsbfwq.rn $r0r1 = $r0r1, $r4r5
  // CHECK: fsbfwq.rn $r2r3 = $r2r3, $r6r7
  // CHECK: ret
}

v2f64 fsbfdp(v2f64 v1, v2f64 v2) {
  return __builtin_kvx_fsbfdp(v1, v2, ".rn");
  // CHECK-LABEL: fsbfdp:
  // CHECK: fsbfdp.rn $r0r1 = $r0r1, $r2r3
  // CHECK: ret
}

v4f64 fsbfdq(v4f64 v1, v4f64 v2) {
  return __builtin_kvx_fsbfdq(v1, v2, ".rn");
  // CHECK-LABEL: fsbfdq:
  // CHECK: fsbfdp.rn $r0r1 = $r0r1, $r4r5
  // CHECK: fsbfdp.rn $r2r3 = $r2r3, $r6r7
  // CHECK: ret
}

v2f32 fsbfcwc(v2f32 v1, v2f32 v2) {
  return __builtin_kvx_fsbfcwc(v1, v2, ".rn");
  // CHECK-LABEL: fsbfcwc:
  // CHECK: fsbfcwc.rn $r0 = $r0, $r1
  // CHECK: ret
}

v4f32 fsbfcwcp(v4f32 v1, v4f32 v2) {
  return __builtin_kvx_fsbfcwcp(v1, v2, ".rn");
  // CHECK-LABEL: fsbfcwcp:
  // CHECK: fsbfcwcp.rn $r0r1 = $r0r1, $r2r3
  // CHECK: ret
}

v8f32 fsbfcwcq(v8f32 v1, v8f32 v2) {
  return __builtin_kvx_fsbfcwcq(v1, v2, ".rn");
  // CHECK-LABEL: fsbfcwcq:
  // CHECK: fsbfcwcp.rn $r0r1 = $r0r1, $r4r5
  // CHECK: fsbfcwcp.rn $r2r3 = $r2r3, $r6r7
  // CHECK: ret
}

v2f64 fsbfcdc(v2f64 v1, v2f64 v2) {
  return __builtin_kvx_fsbfcdc(v1, v2, ".rn");
  // CHECK-LABEL: fsbfcdc:
  // CHECK: fsbfcdc.rn $r0r1 = $r0r1, $r2r3
  // CHECK: ret
}

v4f64 fsbfcdcp(v4f64 v1, v4f64 v2) {
  return __builtin_kvx_fsbfcdcp(v1, v2, ".rn");
  // CHECK-LABEL: fsbfcdcp:
  // CHECK: fsbfcdc.rn $r0r1 = $r0r1, $r4r5
  // CHECK: fsbfcdc.rn $r2r3 = $r2r3, $r6r7
  // CHECK: ret
}

v2f32 fmulwp(v2f32 v1, v2f32 v2) {
  return __builtin_kvx_fmulwp(v1, v2, ".rn");
  // CHECK-LABEL: fmulwp:
  // CHECK: fmulwp.rn $r0 = $r0, $r1
  // CHECK: ret
}

v4f32 fmulwq(v4f32 v1, v4f32 v2) {
  return __builtin_kvx_fmulwq(v1, v2, ".rn");
  // CHECK-LABEL: fmulwq:
  // CHECK: fmulwq.rn $r0r1 = $r0r1, $r2r3
  // CHECK: ret
}

v8f32 fmulwo(v8f32 v1, v8f32 v2) {
  return __builtin_kvx_fmulwo(v1, v2, ".rn");
  // CHECK-LABEL: fmulwo:
  // CHECK: fmulwq.rn $r0r1 = $r0r1, $r4r5
  // CHECK: fmulwq.rn $r2r3 = $r2r3, $r6r7
  // CHECK: ret
}

v2f64 fmuldp(v2f64 v1, v2f64 v2) {
  return __builtin_kvx_fmuldp(v1, v2, ".rn");
  // CHECK-LABEL: fmuldp:
  // CHECK: fmuld.rn $r0 = $r0, $r2
  // CHECK: fmuld.rn $r1 = $r1, $r3
  // CHECK: ret
}

v4f64 fmuldq(v4f64 v1, v4f64 v2) {
  return __builtin_kvx_fmuldq(v1, v2, ".rn");
  // CHECK-LABEL: fmuldq:
  // CHECK: fmuld.rn $r0 = $r0, $r4
  // CHECK: fmuld.rn $r1 = $r1, $r5
  // CHECK: fmuld.rn $r2 = $r2, $r6
  // CHECK: fmuld.rn $r3 = $r3, $r7
  // CHECK: ret
}

v2f32 fmulwc(v2f32 v1, v2f32 v2) {
  return __builtin_kvx_fmulwc(v1, v2, ".rn");
  // CHECK-LABEL: fmulwc:
  // CHECK: fmulwc.rn $r0 = $r0, $r1
  // CHECK: ret
}

v4f32 fmulwcp(v4f32 v1, v4f32 v2) {
  return __builtin_kvx_fmulwcp(v1, v2, ".rn");
  // CHECK-LABEL: fmulwcp:
  // CHECK: fmulwc.rn $r0 = $r0, $r2
  // CHECK: fmulwc.rn $r1 = $r1, $r3
  // CHECK: ret
}

v8f32 fmulwcq(v8f32 v1, v8f32 v2) {
  return __builtin_kvx_fmulwcq(v1, v2, ".rn");
  // CHECK-LABEL: fmulwcq:
  // CHECK: fmulwc.rn $r0 = $r0, $r4
  // CHECK: fmulwc.rn $r1 = $r1, $r5
  // CHECK: fmulwc.rn $r2 = $r2, $r6
  // CHECK: fmulwc.rn $r3 = $r3, $r7
  // CHECK: ret
}

v2f32 fmulcwc(v2f32 v1, v2f32 v2) {
  return __builtin_kvx_fmulcwc(v1, v2, ".rn");
  // CHECK-LABEL: fmulcwc:
  // CHECK: fmulcwc.rn $r0 = $r0, $r1
  // CHECK: ret
}

v4f32 fmulcwcp(v4f32 v1, v4f32 v2) {
  return __builtin_kvx_fmulcwcp(v1, v2, ".rn");
  // CHECK-LABEL: fmulcwcp:
  // CHECK: fmulcwc.rn $r0 = $r0, $r2
  // CHECK: fmulcwc.rn $r1 = $r1, $r3
  // CHECK: ret
}

v8f32 fmulcwcq(v8f32 v1, v8f32 v2) {
  return __builtin_kvx_fmulcwcq(v1, v2, ".rn");
  // CHECK-LABEL: fmulcwcq:
  // CHECK: fmulcwc.rn $r0 = $r0, $r4
  // CHECK: fmulcwc.rn $r1 = $r1, $r5
  // CHECK: fmulcwc.rn $r2 = $r2, $r6
  // CHECK: fmulcwc.rn $r3 = $r3, $r7
  // CHECK: ret
}

v2f64 fmuldc(v2f64 v1, v2f64 v2) {
  return __builtin_kvx_fmuldc(v1, v2, ".rn");
  // CHECK-LABEL: fmuldc:
  // CHECK: fmuld.rn $r4 = $r0, $r2
  // CHECK: ffmsd.rn $r4 = $r1, $r3
  // CHECK: fmuld.rn $r5 = $r0, $r3
  // CHECK: ffmad.rn $r5 = $r2, $r1
  // CHECK: ret
}

v4f64 fmuldcp(v4f64 v1, v4f64 v2) {
  return __builtin_kvx_fmuldcp(v1, v2, ".rn");
  // CHECK-LABEL: fmuldcp:
  // CHECK: fmuld.rn $r8 = $r0, $r4
  // CHECK: ffmsd.rn $r8 = $r1, $r5
  // CHECK: fmuld.rn $r9 = $r0, $r5
  // CHECK: ffmad.rn $r9 = $r4, $r1
  // CHECK: fmuld.rn $r4 = $r2, $r6
  // CHECK: ffmsd.rn $r4 = $r3, $r7
  // CHECK: fmuld.rn $r5 = $r2, $r7
  // CHECK: ffmad.rn $r5 = $r6, $r3
  // CHECK: ret
}

v2f64 fmulcdc(v2f64 v1, v2f64 v2) {
  return __builtin_kvx_fmulcdc(v1, v2, ".rn");
  // CHECK-LABEL: fmulcdc:
  // CHECK: fmuld.rn $r6 = $r0, $r2
  // CHECK: ffmad.rn $r4 = $r6, $r1
  // CHECK: fmuld.rn $r6 = $r2, $r1
  // CHECK: ffmsd.rn $r5 = $r6, $r0
  // CHECK: ret
}

v4f64 fmulcdcp(v4f64 v1, v4f64 v2) {
  return __builtin_kvx_fmulcdcp(v1, v2, ".rn");
  // CHECK-LABEL: fmulcdcp:
  // CHECK: fmuld.rn $r10 = $r0, $r4
  // CHECK: ffmad.rn $r8 = $r10, $r1
  // CHECK: fmuld.rn $r10 = $r4, $r1
  // CHECK: ffmsd.rn $r9 = $r10, $r0
  // CHECK: fmuld.rn $r0 = $r2, $r6
  // CHECK: ffmad.rn $r4 = $r0, $r3
  // CHECK: fmuld.rn $r0 = $r6, $r3
  // CHECK: ffmsd.rn $r5 = $r0, $r2
  // CHECK: ret
}

v4f32 fmm212w(v2f32 v1, v2f32 v2) {
  return __builtin_kvx_fmm212w(v1, v2, ".rn");
  // CHECK-LABEL: fmm212w:
  // CHECK: fmm212w.rn $r0r1 = $r0, $r1
  // CHECK: ret
}

v4f32 fmma212w(v2f32 v1, v2f32 v2, v4f32 v3) {
  return __builtin_kvx_fmma212w(v1, v2, v3, ".rn");
  // CHECK-LABEL: fmma212w:
  // CHECK: fmma212w.rn $r2r3 = $r0, $r1
  // CHECK: ret
}

v4f32 fmms212w(v2f32 v1, v2f32 v2, v4f32 v3) {
  return __builtin_kvx_fmms212w(v1, v2, v3, ".rn");
  // CHECK-LABEL: fmms212w:
  // CHECK: fmms212w.rn $r2r3 = $r0, $r1
  // CHECK: ret
}

v2f32 ffmawp(v2f32 v1, v2f32 v2, v2f32 v3) {
  return __builtin_kvx_ffmawp(v1, v2, v3, ".rn");
  // CHECK-LABEL: ffmawp:
  // CHECK: ffmawp.rn $r2 = $r0, $r1
  // CHECK: ret
}

v4f32 ffmawq(v4f32 v1, v4f32 v2, v4f32 v3) {
  return __builtin_kvx_ffmawq(v1, v2, v3, ".rn");
  // CHECK-LABEL: ffmawq:
  // CHECK: ffmawp.rn $r4 = $r0, $r2
  // CHECK: ffmawp.rn $r5 = $r1, $r3
  // CHECK: ret
}

v8f32 ffmawo(v8f32 v1, v8f32 v2, v8f32 v3) {
  return __builtin_kvx_ffmawo(v1, v2, v3, ".rn");
  // CHECK-LABEL: ffmawo:
  // CHECK: ffmawp.rn $r8 = $r0, $r4
  // CHECK: ffmawp.rn $r9 = $r1, $r5
  // CHECK: ffmawp.rn $r10 = $r2, $r6
  // CHECK: ffmawp.rn $r11 = $r3, $r7
  // CHECK: ret
}

v2f64 ffmadp(v2f64 v1, v2f64 v2, v2f64 v3) {
  return __builtin_kvx_ffmadp(v1, v2, v3, ".rn");
  // CHECK-LABEL: ffmadp:
  // CHECK: ffmad.rn $r4 = $r0, $r2
  // CHECK: ffmad.rn $r5 = $r1, $r3
  // CHECK: ret
}

v4f64 ffmadq(v4f64 v1, v4f64 v2, v4f64 v3) {
  return __builtin_kvx_ffmadq(v1, v2, v3, ".rn");
  // CHECK-LABEL: ffmadq:
  // CHECK: ffmad.rn $r8 = $r0, $r4
  // CHECK: ffmad.rn $r9 = $r1, $r5
  // CHECK: ffmad.rn $r10 = $r2, $r6
  // CHECK: ffmad.rn $r11 = $r3, $r7
  // CHECK: ret
}

v2f32 ffmswp(v2f32 v1, v2f32 v2, v2f32 v3) {
  return __builtin_kvx_ffmswp(v1, v2, v3, ".rn");
  // CHECK-LABEL: ffmswp:
  // CHECK: ffmswp.rn $r2 = $r0, $r1
  // CHECK: ret
}

v4f32 ffmswq(v4f32 v1, v4f32 v2, v4f32 v3) {
  return __builtin_kvx_ffmswq(v1, v2, v3, ".rn");
  // CHECK-LABEL: ffmswq:
  // CHECK: ffmswp.rn $r4 = $r0, $r2
  // CHECK: ffmswp.rn $r5 = $r1, $r3
  // CHECK: ret
}

v8f32 ffmswo(v8f32 v1, v8f32 v2, v8f32 v3) {
  return __builtin_kvx_ffmswo(v1, v2, v3, ".rn");
  // CHECK-LABEL: ffmswo:
  // CHECK: ffmswp.rn $r8 = $r0, $r4
  // CHECK: ffmswp.rn $r9 = $r1, $r5
  // CHECK: ffmswp.rn $r10 = $r2, $r6
  // CHECK: ffmswp.rn $r11 = $r3, $r7
  // CHECK: ret
}

v2f64 ffmsdp(v2f64 v1, v2f64 v2, v2f64 v3) {
  return __builtin_kvx_ffmsdp(v1, v2, v3, ".rn");
  // CHECK-LABEL: ffmsdp:
  // CHECK: ffmsd.rn $r4 = $r0, $r2
  // CHECK: ffmsd.rn $r5 = $r1, $r3
  // CHECK: ret
}

v4f64 ffmsdq(v4f64 v1, v4f64 v2, v4f64 v3) {
  return __builtin_kvx_ffmsdq(v1, v2, v3, ".rn");
  // CHECK-LABEL: ffmsdq:
  // CHECK: ffmsd.rn $r8 = $r0, $r4
  // CHECK: ffmsd.rn $r9 = $r1, $r5
  // CHECK: ffmsd.rn $r10 = $r2, $r6
  // CHECK: ffmsd.rn $r11 = $r3, $r7
  // CHECK: ret
}

v2f32 floatwp(v2i32 v) {
  return __builtin_kvx_floatwp(v, 3, ".rn");
  // CHECK-LABEL: floatwp:
  // CHECK: floatwp.rn $r0 = $r0, 3
  // CHECK: ret
}

v4f32 floatwq(v4i32 v) {
  return __builtin_kvx_floatwq(v, 3, ".rn");
  // CHECK-LABEL: floatwq:
  // CHECK: floatwp.rn $r0 = $r0, 3
  // CHECK: floatwp.rn $r1 = $r1, 3
  // CHECK: ret
}

v8f32 floatwo(v8i32 v) {
  return __builtin_kvx_floatwo(v, 3, ".rn");
  // CHECK-LABEL: floatwo:
  // CHECK: floatwp.rn $r0 = $r0, 3
  // CHECK: floatwp.rn $r1 = $r1, 3
  // CHECK: floatwp.rn $r2 = $r2, 3
  // CHECK: floatwp.rn $r3 = $r3, 3
  // CHECK: ret
}

v2f64 floatdp(v2i64 v) {
  return __builtin_kvx_floatdp(v, 3, ".rn");
  // CHECK-LABEL: floatdp:
  // CHECK: floatd.rn $r0 = $r0, 3
  // CHECK: floatd.rn $r1 = $r1, 3
  // CHECK: ret
}

v4f64 floatdq(v4i64 v) {
  return __builtin_kvx_floatdq(v, 3, ".rn");
  // CHECK-LABEL: floatdq:
  // CHECK: floatd.rn $r0 = $r0, 3
  // CHECK: floatd.rn $r1 = $r1, 3
  // CHECK: floatd.rn $r2 = $r2, 3
  // CHECK: floatd.rn $r3 = $r3, 3
  // CHECK: ret
}

v2f32 floatuwp(v2u32 v) {
  return __builtin_kvx_floatuwp(v, 3, ".rn");
  // CHECK-LABEL: floatuwp:
  // CHECK: floatuwp.rn $r0 = $r0, 3
  // CHECK: ret
}

v4f32 floatuwq(v4u32 v) {
  return __builtin_kvx_floatuwq(v, 3, ".rn");
  // CHECK-LABEL: floatuwq:
  // CHECK: floatuwp.rn $r0 = $r0, 3
  // CHECK: floatuwp.rn $r1 = $r1, 3
  // CHECK: ret
}

v8f32 floatuwo(v8u32 v) {
  return __builtin_kvx_floatuwo(v, 3, ".rn");
  // CHECK-LABEL: floatuwo:
  // CHECK: floatuwp.rn $r0 = $r0, 3
  // CHECK: floatuwp.rn $r1 = $r1, 3
  // CHECK: floatuwp.rn $r2 = $r2, 3
  // CHECK: floatuwp.rn $r3 = $r3, 3
  // CHECK: ret
}

v2f64 floatudp(v2u64 v) {
  return __builtin_kvx_floatudp(v, 3, ".rn");
  // CHECK-LABEL: floatudp:
  // CHECK: floatud.rn $r0 = $r0, 3
  // CHECK: floatud.rn $r1 = $r1, 3
  // CHECK: ret
}

v4f64 floatudq(v4u64 v) {
  return __builtin_kvx_floatudq(v, 3, ".rn");
  // CHECK-LABEL: floatudq:
  // CHECK: floatud.rn $r0 = $r0, 3
  // CHECK: floatud.rn $r1 = $r1, 3
  // CHECK: floatud.rn $r2 = $r2, 3
  // CHECK: floatud.rn $r3 = $r3, 3
  // CHECK: ret
}

v2i32 fixedwp(v2f32 v) {
  return __builtin_kvx_fixedwp(v, 3, ".rn");
  // CHECK-LABEL: fixedwp:
  // CHECK: fixedwp.rn $r0 = $r0, 3
  // CHECK: ret
}

v4i32 fixedwq(v4f32 v) {
  return __builtin_kvx_fixedwq(v, 3, ".rn");
  // CHECK-LABEL: fixedwq:
  // CHECK: fixedwp.rn $r0 = $r0, 3
  // CHECK: fixedwp.rn $r1 = $r1, 3
  // CHECK: ret
}

v8f32 fixedwo(v8i32 v) {
  return __builtin_kvx_fixedwo(v, 3, ".rn");
  // CHECK-LABEL: fixedwo:
  // CHECK: fixedwp.rn $r4 = $r0, 3
  // CHECK: fixedwp.rn $r5 = $r1, 3
  // CHECK: fixedwp.rn $r0 = $r2, 3
  // CHECK: fixedwp.rn $r1 = $r3, 3
  // CHECK: ret
}

v2f64 fixeddp(v2i64 v) {
  return __builtin_kvx_fixeddp(v, 3, ".rn");
  // CHECK-LABEL: fixeddp:
  // CHECK: fixedd.rn $r2 = $r0, 3
  // CHECK: fixedd.rn $r3 = $r1, 3
  // CHECK: ret
}

v4f64 fixeddq(v4i64 v) {
  return __builtin_kvx_fixeddq(v, 3, ".rn");
  // CHECK-LABEL: fixeddq:
  // CHECK: fixedd.rn $r4 = $r0, 3
  // CHECK: fixedd.rn $r6 = $r2, 3
  // CHECK: fixedd.rn $r5 = $r1, 3
  // CHECK: fixedd.rn $r7 = $r3, 3
  // CHECK: ret
}

v2u32 fixeduwp(v2f32 v) {
  return __builtin_kvx_fixeduwp(v, 3, ".rn");
  // CHECK-LABEL: fixeduwp:
  // CHECK: fixeduwp.rn $r0 = $r0, 3
  // CHECK: ret
}

v4u32 fixeduwq(v4f32 v) {
  return __builtin_kvx_fixeduwq(v, 3, ".rn");
  // CHECK-LABEL: fixeduwq:
  // CHECK: fixeduwp.rn $r0 = $r0, 3
  // CHECK: fixeduwp.rn $r1 = $r1, 3
  // CHECK: ret
}

v8f32 fixeduwo(v8i32 v) {
  return __builtin_kvx_fixeduwo(v, 3, ".rn");
  // CHECK-LABEL: fixeduwo:
  // CHECK: fixeduwp.rn $r4 = $r0, 3
  // CHECK: fixeduwp.rn $r5 = $r1, 3
  // CHECK: fixeduwp.rn $r0 = $r2, 3
  // CHECK: fixeduwp.rn $r1 = $r3, 3
  // CHECK: ret
}

v2f64 fixedudp(v2u64 v) {
  return __builtin_kvx_fixedudp(v, 3, ".rn");
  // CHECK-LABEL: fixedudp:
  // CHECK: fixedud.rn $r2 = $r0, 3
  // CHECK: fixedud.rn $r3 = $r1, 3
  // CHECK: ret
}

v4f64 fixedudq(v4u64 v) {
  return __builtin_kvx_fixedudq(v, 3, ".rn");
  // CHECK-LABEL: fixedudq:
  // CHECK: fixedud.rn $r4 = $r0, 3
  // CHECK: fixedud.rn $r6 = $r2, 3
  // CHECK: fixedud.rn $r5 = $r1, 3
  // CHECK: fixedud.rn $r7 = $r3, 3
  // CHECK: ret
}
