// RUN: clang -mllvm --disable-kvx-loadstore-packing=false --target=kvx-cos -S %s -O2 -o - | FileCheck %s

long volatile v[50];

void foo();

long f_1_nopack() {
  long a = v[0];

  foo();

  return a;
  // CHECK: f_1_nopack
  // CHECK: sd 0[$r12] = $r18
  // CHECK: call foo
  // CHECK: ld $r18 = 0[$r12]
  // CHECK: ret
}

long f_2_pairpack() {
  long a = v[0];
  long b = v[1];

  foo();

  return a + b;
  // CHECK: f_2_pairpack
  // CHECK: sq 0[$r12] = $r18r19
  // CHECK: call foo
  // CHECK: lq $r18r19 = 0[$r12]
  // CHECK: ret
}

long f_3_pairpack() {
  long a = v[0];
  long b = v[1];
  long c = v[2];

  foo();

  return a + b + c;
  // CHECK: f_3_pairpack
  // CHECK: sd 16[$r12] = $r20
  // CHECK: sq 0[$r12] = $r18r19
  // CHECK: call foo
  // CHECK: lq $r18r19 = 0[$r12]
  // CHECK: ld $r20 = 16[$r12]
  // CHECK: ret
}

long f_4_quadpack() {
  long a = v[0];
  long b = v[1];
  long c = v[2];
  long d = v[3];

  foo();

  return a + b + c + d;
  // CHECK: f_4_quadpack
  // CHECK: so 0[$r12] = $r20r21r22r23
  // CHECK: call foo
  // CHECK: lo $r20r21r22r23 = 0[$r12]
  // CHECK: ret
}

long f_5_quadpack() {
  long a = v[0];
  long b = v[1];
  long c = v[2];
  long d = v[3];
  long e = v[4];

  foo();

  return a + b + c + d + e;
  // CHECK: f_5_quadpack
  // CHECK: so 8[$r12] = $r20r21r22r23
  // CHECK: sd 0[$r12] = $r18
  // CHECK: call foo
  // CHECK: ld $r18 = 0[$r12]
  // CHECK: lo $r20r21r22r23 = 8[$r12]
  // CHECK: ret
}

long f_6_1quad1pairpack() {
  long a = v[0];
  long b = v[1];
  long c = v[2];
  long d = v[3];
  long e = v[4];
  long f = v[5];

  foo();

  return a + b + c + d + e + f;
  // CHECK: f_6_1quad1pairpack
  // CHECK: so 16[$r12] = $r20r21r22r23
  // CHECK: sq 0[$r12] = $r18r19
  // CHECK: call foo
  // CHECK: lq $r18r19 = 0[$r12]
  // CHECK: lo $r20r21r22r23 = 16[$r12]
  // CHECK: ret
}

long f_14_3quad1pairpack() {
  long a = v[0];
  long b = v[1];
  long c = v[2];
  long d = v[3];
  long e = v[4];
  long f = v[5];
  long g = v[6];
  long h = v[7];
  long i = v[8];
  long j = v[9];
  long k = v[10];
  long l = v[11];
  long m = v[12];
  long n = v[13];

  foo();

  return a + b + c + d + e + f + g + h + i + j + k + l + m + n;
  // CHECK: f_14_3quad1pairpack
  // CHECK: so 80[$r12] = $r28r29r30r31
  // CHECK: so 48[$r12] = $r24r25r26r27
  // CHECK: so 16[$r12] = $r20r21r22r23
  // CHECK: sq 0[$r12] = $r18r19
  // CHECK: call foo
  // CHECK: lq $r18r19 = 0[$r12]
  // CHECK: lo $r20r21r22r23 = 16[$r12]
  // CHECK: lo $r24r25r26r27 = 48[$r12]
  // CHECK: lo $r28r29r30r31 = 80[$r12]
  // CHECK: ret
}

long f_15_3quad1pairpack() {
  long a = v[0];
  long b = v[1];
  long c = v[2];
  long d = v[3];
  long e = v[4];
  long f = v[5];
  long g = v[6];
  long h = v[7];
  long i = v[8];
  long j = v[9];
  long k = v[10];
  long l = v[11];
  long m = v[12];
  long n = v[13];
  long o = v[14];

  foo();

  return a + b + c + d + e + f + g + h + i + j + k + l + m + n + o;
  // CHECK: f_15_3quad1pairpack
  // CHECK-NOT: r32
  // CHECK: so 80[$r12] = $r28r29r30r31
  // CHECK: so 48[$r12] = $r24r25r26r27
  // CHECK: so 16[$r12] = $r20r21r22r23
  // CHECK: sq 0[$r12] = $r18r19
  // CHECK: call foo
  // CHECK: lq $r18r19 = 0[$r12]
  // CHECK: lo $r20r21r22r23 = 16[$r12]
  // CHECK: lo $r24r25r26r27 = 48[$r12]
  // CHECK: lo $r28r29r30r31 = 80[$r12]
  // CHECK: ret
}
