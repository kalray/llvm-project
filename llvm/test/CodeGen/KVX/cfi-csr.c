// RUN: clang -mllvm --disable-kvx-loadstore-packing=false --target=kvx-cos -S %s -O2 -g -o - | FileCheck %s

long volatile v[50];

void foo();

long f_1_nopack() {
  long a = v[0];

  foo();

  return a;
  // CHECK: f_1_nopack
  // CHECK: get $r16 = $ra
  // CHECK: ;;
  // CHECK-NEXT: .cfi_def_cfa_offset 32
  // CHECK: sd 8[$r12] = $r16
  // CHECK: ;;
  // CHECK-NEXT: .cfi_offset 67, -24
  // CHECK: sd 0[$r12] = $r18
  // CHECK: ;;
  // CHECK-NEXT: .cfi_offset 18, -32
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
  // CHECK: get $r16 = $ra
  // CHECK: ;;
  // CHECK-NEXT: .cfi_def_cfa_offset 32
  // CHECK: sd 16[$r12] = $r16
  // CHECK: ;;
  // CHECK-NEXT: .cfi_offset 67, -16
  // CHECK: sq 0[$r12] = $r18r19
  // CHECK: ;;
  // CHECK-NEXT: .cfi_offset 19, -24
  // CHECK-NEXT: .cfi_offset 18, -32
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
  // CHECK: get $r16 = $ra
  // CHECK: ;;
  // CHECK-NEXT: .cfi_def_cfa_offset 32
  // CHECK: sd 24[$r12] = $r16
  // CHECK: ;;
  // CHECK-NEXT: .cfi_offset 67, -8
  // CHECK: sd 16[$r12] = $r20
  // CHECK: ;;
  // CHECK-NEXT: .cfi_offset 20, -16
  // CHECK: sq 0[$r12] = $r18r19
  // CHECK: ;;
  // CHECK-NEXT: .cfi_offset 19, -24
  // CHECK-NEXT: .cfi_offset 18, -32
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

  // CHECK-LABEL: f_4_quadpack:
  // CHECK: get $r16 = $ra
  // CHECK: ;;
  // CHECK-NEXT: .cfi_def_cfa_offset 64
  // CHECK: sd 32[$r12] = $r16
  // CHECK: ;;
  // CHECK-NEXT .cfi_offset 67, -32
  // CHECK sq 16[$r12] = $r20r21
  // CHECK: ;;
  // CHECK-NEXT: .cfi_offset 21, -40
  // CHECK-NEXT: .cfi_offset 20, -48
  // CHECK: sq 0[$r12] = $r18r19
  // CHECK: call foo
  // CHECK: lq $r18r19 = 0[$r12]
  // CHECK: lq $r20r21 = 16[$r12]
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

  // CHECK-LABEL: f_5_quadpack:
  // CHECK: get $r16 = $ra
  // CHECK: ;;
  // CHECK-NEXT: .cfi_def_cfa_offset 64
  // CHECK: sd 40[$r12] = $r16
  // CHECK: ;;
  // CHECK-NEXT: .cfi_offset 67, -24
  // CHECK: sd 32[$r12] = $r22
  // CHECK: ;;
  // CHECK-NEXT .cfi_offset 67, -32
  // CHECK sq 16[$r12] = $r20r21
  // CHECK: ;;
  // CHECK-NEXT: .cfi_offset 21, -40
  // CHECK-NEXT: .cfi_offset 20, -48
  // CHECK: sq 0[$r12] = $r18r19
  // CHECK: call foo
  // CHECK: lq $r18r19 = 0[$r12]
  // CHECK: lq $r20r21 = 16[$r12]
  // CHECK: ld $r22 = 32[$r12]
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
  // CHECK: get $r16 = $ra
  // CHECK: ;;
  // CHECK-NEXT: .cfi_def_cfa_offset 64
  // CHECK: sd 48[$r12] = $r16
  // CHECK: ;;
  // CHECK-NEXT: .cfi_offset 67, -16
  // CHECK: so 16[$r12] = $r20r21r22r23
  // CHECK: ;;
  // CHECK-NEXT: .cfi_offset 23, -24
  // CHECK-NEXT: .cfi_offset 22, -32
  // CHECK-NEXT: .cfi_offset 21, -40
  // CHECK-NEXT: .cfi_offset 20, -48
  // CHECK: sq 0[$r12] = $r18r19
  // CHECK: ;;
  // CHECK-NEXT: .cfi_offset 19, -56
  // CHECK-NEXT: .cfi_offset 18, -64
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
  // CHECK: get $r16 = $ra
  // CHECK: ;;
  // CHECK-NEXT: .cfi_def_cfa_offset 128
  // CHECK: sd 112[$r12] = $r16
  // CHECK: ;;
  // CHECK-NEXT: .cfi_offset 67, -16
  // CHECK: so 80[$r12] = $r28r29r30r31
  // CHECK: ;;
  // CHECK-NEXT: .cfi_offset 31, -24
  // CHECK-NEXT: .cfi_offset 30, -32
  // CHECK-NEXT: .cfi_offset 29, -40
  // CHECK-NEXT: .cfi_offset 28, -48
  // CHECK: so 48[$r12] = $r24r25r26r27
  // CHECK: ;;
  // CHECK-NEXT: .cfi_offset 27, -56
  // CHECK-NEXT: .cfi_offset 26, -64
  // CHECK-NEXT: .cfi_offset 25, -72
  // CHECK-NEXT: .cfi_offset 24, -80
  // CHECK: so 16[$r12] = $r20r21r22r23
  // CHECK: ;;
  // CHECK-NEXT: .cfi_offset 23, -88
  // CHECK-NEXT: .cfi_offset 22, -96
  // CHECK-NEXT: .cfi_offset 21, -104
  // CHECK-NEXT: .cfi_offset 20, -112
  // CHECK: sq 0[$r12] = $r18r19
  // CHECK: ;;
  // CHECK-NEXT: .cfi_offset 19, -120
  // CHECK-NEXT: .cfi_offset 18, -128
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
  // CHECK: get $r16 = $ra
  // CHECK: ;;
  // CHECK-NEXT: .cfi_def_cfa_offset 128
  // CHECK: sd 112[$r12] = $r16
  // CHECK: ;;
  // CHECK-NEXT: .cfi_offset 67, -16
  // CHECK-NOT: r32
  // CHECK: so 80[$r12] = $r28r29r30r31
  // CHECK: ;;
  // CHECK-NEXT: .cfi_offset 31, -24
  // CHECK-NEXT: .cfi_offset 30, -32
  // CHECK-NEXT: .cfi_offset 29, -40
  // CHECK-NEXT: .cfi_offset 28, -48
  // CHECK: so 48[$r12] = $r24r25r26r27
  // CHECK: ;;
  // CHECK-NEXT: .cfi_offset 27, -56
  // CHECK-NEXT: .cfi_offset 26, -64
  // CHECK-NEXT: .cfi_offset 25, -72
  // CHECK-NEXT: .cfi_offset 24, -80
  // CHECK: so 16[$r12] = $r20r21r22r23
  // CHECK: ;;
  // CHECK-NEXT: .cfi_offset 23, -88
  // CHECK-NEXT: .cfi_offset 22, -96
  // CHECK-NEXT: .cfi_offset 21, -104
  // CHECK-NEXT: .cfi_offset 20, -112
  // CHECK: sq 0[$r12] = $r18r19
  // CHECK: ;;
  // CHECK-NEXT: .cfi_offset 19, -120
  // CHECK-NEXT: .cfi_offset 18, -128
  // CHECK: call foo
  // CHECK: lq $r18r19 = 0[$r12]
  // CHECK: lo $r20r21r22r23 = 16[$r12]
  // CHECK: lo $r24r25r26r27 = 48[$r12]
  // CHECK: lo $r28r29r30r31 = 80[$r12]
  // CHECK: ret
}

typedef __builtin_va_list va_list;
#define va_start(v, l) __builtin_va_start(v, l)
#define va_end(v) __builtin_va_end(v)
#define va_arg(v, l) __builtin_va_arg(v, l)
#define va_copy(d, s) __builtin_va_copy(d, s)

int other(int x);

int fsum6_sum(int first, int second, ...) {
  int result = first + second;
  va_list args, args2;
  va_start(args, second);
  va_copy(args2, args);
  int v;
  while ((v = va_arg(args, int)) > 0) {
    result += other(v);
  }
  va_end(args);
  while ((v = va_arg(args2, int)) > 0)
    result += 1;
  va_end(args2);
  return result;
  // CHECK: fsum6_sum
  // CHECK: get $r16 = $ra
  // CHECK: ;;
  // CHECK-NEXT: .cfi_def_cfa_offset 128
  // CHECK: sd 8[$r12] = $r16
  // CHECK: ;;
  // CHECK-NEXT: .cfi_offset 67, -120
  // CHECK: sd 0[$r12] = $r18
  // CHECK: ;;
  // CHECK: .cfi_offset 18, -128
  // CHECK: ret
}
