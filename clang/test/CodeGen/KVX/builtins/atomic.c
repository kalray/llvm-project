// NOTE: Assertions have been autogenerated by utils/update_cc_test_checks.py
// RUN: %clang_cc1 -triple kvx-kalray-cos -S -O2 -emit-llvm -o - %s | FileCheck %s

// CHECK-LABEL: @acswapw(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i32 @llvm.kvx.acswapw(ptr [[P:%.*]], i32 [[A:%.*]], i32 [[B:%.*]], i32 1, i32 0)
// CHECK-NEXT:    ret i32 [[TMP0]]
//
int acswapw(int *p, int a, int b) {
  return __builtin_kvx_acswapw(p, a, b);
}

// CHECK-LABEL: @acswapw10(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i32, ptr [[P:%.*]], i64 20
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i32 @llvm.kvx.acswapw(ptr nonnull [[ARRAYIDX]], i32 [[A:%.*]], i32 [[B:%.*]], i32 1, i32 0)
// CHECK-NEXT:    ret i32 [[TMP0]]
//
int acswapw10(int *p, int a, int b) {
  return __builtin_kvx_acswapw(&p[20], a, b);
}

// CHECK-LABEL: @acswapw37(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i32, ptr [[P:%.*]], i64 17179869183
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i32 @llvm.kvx.acswapw(ptr nonnull [[ARRAYIDX]], i32 [[A:%.*]], i32 [[B:%.*]], i32 1, i32 0)
// CHECK-NEXT:    ret i32 [[TMP0]]
//
int acswapw37(int *p, int a, int b) {
  return __builtin_kvx_acswapw(&p[17179869183], a, b);
}

// CHECK-LABEL: @acswapw64(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i32, ptr [[P:%.*]], i64 17179869188
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i32 @llvm.kvx.acswapw(ptr nonnull [[ARRAYIDX]], i32 [[A:%.*]], i32 [[B:%.*]], i32 1, i32 0)
// CHECK-NEXT:    ret i32 [[TMP0]]
//
int acswapw64(int *p, int a, int b) {
  return __builtin_kvx_acswapw(&p[17179869188], a, b);
}

// CHECK-LABEL: @acswapwxs(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[IDXPROM:%.*]] = sext i32 [[OFF:%.*]] to i64
// CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i32, ptr [[P:%.*]], i64 [[IDXPROM]]
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i32 @llvm.kvx.acswapw(ptr [[ARRAYIDX]], i32 [[A:%.*]], i32 [[B:%.*]], i32 1, i32 0)
// CHECK-NEXT:    ret i32 [[TMP0]]
//
int acswapwxs(int *p, int a, int b, int off) {
  return __builtin_kvx_acswapw(&p[off], a, b);
}

// CHECK-LABEL: @acswapd(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.kvx.acswapd(ptr [[P:%.*]], i64 [[A:%.*]], i64 [[B:%.*]], i32 1, i32 0)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long acswapd(long *p, long a, long b) {
  return __builtin_kvx_acswapd(p, a, b);
}

// CHECK-LABEL: @acswapd10(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i64, ptr [[P:%.*]], i64 20
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.kvx.acswapd(ptr nonnull [[ARRAYIDX]], i64 [[A:%.*]], i64 [[B:%.*]], i32 1, i32 0)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long acswapd10(long *p, long a, long b) {
  return __builtin_kvx_acswapd(&p[20], a, b);
}

// CHECK-LABEL: @acswapd37(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i64, ptr [[P:%.*]], i64 8589934591
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.kvx.acswapd(ptr nonnull [[ARRAYIDX]], i64 [[A:%.*]], i64 [[B:%.*]], i32 1, i32 0)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long acswapd37(long *p, long a, long b) {
  return __builtin_kvx_acswapd(&p[8589934591], a, b);
}

// CHECK-LABEL: @acswapd64(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i64, ptr [[P:%.*]], i64 8589934594
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.kvx.acswapd(ptr nonnull [[ARRAYIDX]], i64 [[A:%.*]], i64 [[B:%.*]], i32 1, i32 0)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long acswapd64(long *p, long a, long b) {
  return __builtin_kvx_acswapd(&p[8589934594], a, b);
}

// CHECK-LABEL: @acswapdxs(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i64, ptr [[P:%.*]], i64 [[OFF:%.*]]
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.kvx.acswapd(ptr [[ARRAYIDX]], i64 [[A:%.*]], i64 [[B:%.*]], i32 1, i32 0)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long acswapdxs(long *p, long a, long b, long off) {
  return __builtin_kvx_acswapd(&p[off], a, b);
}

// CHECK-LABEL: @aladdd(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.kvx.aladdd(ptr [[P:%.*]], i64 [[V:%.*]])
// CHECK-NEXT:    ret i64 [[TMP0]]
//
unsigned long aladdd(void *p, long v) {
  return __builtin_kvx_aladdd(p, v);
}

// CHECK-LABEL: @aladdw(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i32 @llvm.kvx.aladdw(ptr [[P:%.*]], i32 [[V:%.*]])
// CHECK-NEXT:    ret i32 [[TMP0]]
//
unsigned int aladdw(void *p, int v) {
  return __builtin_kvx_aladdw(p, v);
}

// CHECK-LABEL: @alclrdrr(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.kvx.alclr.i64(ptr [[P:%.*]])
// CHECK-NEXT:    ret i64 [[TMP0]]
//
unsigned long alclrdrr(void *p) {
  return __builtin_kvx_alclrd(p);
}

// CHECK-LABEL: @alcldri10(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i64, ptr [[P:%.*]], i64 10
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.kvx.alclr.i64(ptr nonnull [[ARRAYIDX]])
// CHECK-NEXT:    ret i64 [[TMP0]]
//
unsigned long alcldri10(long *p) {
  return __builtin_kvx_alclrd((void *)&p[10]);
}

// CHECK-LABEL: @alcldri37(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i64, ptr [[P:%.*]], i64 100
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.kvx.alclr.i64(ptr nonnull [[ARRAYIDX]])
// CHECK-NEXT:    ret i64 [[TMP0]]
//
unsigned long alcldri37(long *p) {
  return __builtin_kvx_alclrd((void *)&p[100]);
}

// CHECK-LABEL: @alcldrixs(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[IDXPROM:%.*]] = sext i32 [[C:%.*]] to i64
// CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i64, ptr [[P:%.*]], i64 [[IDXPROM]]
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.kvx.alclr.i64(ptr [[ARRAYIDX]])
// CHECK-NEXT:    ret i64 [[TMP0]]
//
unsigned long alcldrixs(long *p, int c) {
  return __builtin_kvx_alclrd(&p[c]);
}

// CHECK-LABEL: @alclrw(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i32 @llvm.kvx.alclr.i32(ptr [[P:%.*]])
// CHECK-NEXT:    ret i32 [[TMP0]]
//
unsigned int alclrw(void *p) {
  return __builtin_kvx_alclrw(p);
}

// CHECK-LABEL: @alclrwi10(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i32, ptr [[P:%.*]], i64 10
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i32 @llvm.kvx.alclr.i32(ptr nonnull [[ARRAYIDX]])
// CHECK-NEXT:    ret i32 [[TMP0]]
//
unsigned int alclrwi10(int *p) {
  return __builtin_kvx_alclrw((void *)&p[10]);
}

// CHECK-LABEL: @alclwri37(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i32, ptr [[P:%.*]], i64 100
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i32 @llvm.kvx.alclr.i32(ptr nonnull [[ARRAYIDX]])
// CHECK-NEXT:    ret i32 [[TMP0]]
//
unsigned int alclwri37(int *p) {
  return __builtin_kvx_alclrw((void *)&p[100]);
}

// CHECK-LABEL: @alclwrixs(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[IDXPROM:%.*]] = sext i32 [[C:%.*]] to i64
// CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i32, ptr [[P:%.*]], i64 [[IDXPROM]]
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i32 @llvm.kvx.alclr.i32(ptr [[ARRAYIDX]])
// CHECK-NEXT:    ret i32 [[TMP0]]
//
unsigned int alclwrixs(int *p, int c) {
  return __builtin_kvx_alclrw(&p[c]);
}
