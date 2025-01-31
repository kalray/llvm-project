; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -o - %s -O2 | FileCheck %s --check-prefixes=CHECK
; RUN: llc -mcpu=kv3-2 -o - %s -O2 | FileCheck %s --check-prefixes=CHECK
; RUN: clang -O2 -c -o /dev/null %s
; RUN: clang -O2 -march=kv3-2 -c -o /dev/null %s

target triple = "kvx-kalray-cos"

define i64 @ready_int(i32* nocapture readonly %0) {
; CHECK-LABEL: ready_int:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lwz $r0 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    iord $r0 = $r0, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 3)
  %2 = load i32, i32* %0
  %3 = tail call i64 (...) @llvm.kvx.ready(i32 %2)
  ret i64 %3
}

declare i64 @llvm.kvx.ready(...)

define i64 @ready_long(i64* nocapture readonly %0) {
; CHECK-LABEL: ready_long:
; CHECK:       # %bb.0:
; CHECK-NEXT:    ld $r0 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    iord $r0 = $r0, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 3)
  %2 = load i64, i64* %0
  %3 = tail call i64 (...) @llvm.kvx.ready(i64 %2)
  ret i64 %3
}

define i64 @ready_v2i8(<2 x i8>* nocapture readonly %0) {
; CHECK-LABEL: ready_v2i8:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lhz $r0 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    iord $r0 = $r0, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 3)
  %2 = bitcast <2 x i8>* %0 to half*
  %3 = load half, half* %2
  %4 = tail call i64 (...) @llvm.kvx.ready(half %3)
  ret i64 %4
}

define i64 @ready_v2i16(<2 x i16>* nocapture readonly %0) {
; CHECK-LABEL: ready_v2i16:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lwz $r0 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    iord $r0 = $r0, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 3)
  %2 = bitcast <2 x i16>* %0 to i32*
  %3 = load i32, i32* %2
  %4 = tail call i64 (...) @llvm.kvx.ready(i32 %3)
  ret i64 %4
}

define i64 @ready_v2i32(<2 x i32>* nocapture readonly %0) {
; CHECK-LABEL: ready_v2i32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    ld $r0 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    iord $r0 = $r0, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 3)
  %2 = bitcast <2 x i32>* %0 to i64*
  %3 = load i64, i64* %2
  %4 = tail call i64 (...) @llvm.kvx.ready(i64 %3)
  ret i64 %4
}

define i64 @ready_v2i64(<2 x i64>* nocapture readonly %0) {
; CHECK-LABEL: ready_v2i64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lq $r0r1 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    iord $r0 = $r0, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 3)
  %2 = load <2 x i64>, <2 x i64>* %0
  %3 = tail call i64 (...) @llvm.kvx.ready(<2 x i64> %2)
  ret i64 %3
}

define i64 @ready_v4i8(<4 x i8>* nocapture readonly %0) {
; CHECK-LABEL: ready_v4i8:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lwz $r0 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    iord $r0 = $r0, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 3)
  %2 = bitcast <4 x i8>* %0 to i32*
  %3 = load i32, i32* %2
  %4 = tail call i64 (...) @llvm.kvx.ready(i32 %3)
  ret i64 %4
}

define i64 @ready_v4i16(<4 x i16>* nocapture readonly %0) {
; CHECK-LABEL: ready_v4i16:
; CHECK:       # %bb.0:
; CHECK-NEXT:    ld $r0 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    iord $r0 = $r0, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 3)
  %2 = bitcast <4 x i16>* %0 to i64*
  %3 = load i64, i64* %2
  %4 = tail call i64 (...) @llvm.kvx.ready(i64 %3)
  ret i64 %4
}

define i64 @ready_v4i32(<4 x i32>* nocapture readonly %0) {
; CHECK-LABEL: ready_v4i32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lq $r0r1 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    iord $r0 = $r0, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 3)
  %2 = bitcast <4 x i32>* %0 to <2 x i64>*
  %3 = load <2 x i64>, <2 x i64>* %2
  %4 = tail call i64 (...) @llvm.kvx.ready(<2 x i64> %3)
  ret i64 %4
}

define i64 @ready_v4i64(<4 x i64>* nocapture readonly %0) {
; CHECK-LABEL: ready_v4i64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lo $r0r1r2r3 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    iord $r0 = $r0, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 3)
  %2 = load <4 x i64>, <4 x i64>* %0
  %3 = tail call i64 (...) @llvm.kvx.ready(<4 x i64> %2)
  ret i64 %3
}

define i64 @ready_v8i8(<8 x i8>* nocapture readonly %0) {
; CHECK-LABEL: ready_v8i8:
; CHECK:       # %bb.0:
; CHECK-NEXT:    ld $r0 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    iord $r0 = $r0, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 3)
  %2 = bitcast <8 x i8>* %0 to i64*
  %3 = load i64, i64* %2
  %4 = tail call i64 (...) @llvm.kvx.ready(i64 %3)
  ret i64 %4
}

define i64 @ready__Float16(half* nocapture readonly %0) {
; CHECK-LABEL: ready__Float16:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lhz $r0 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    iord $r0 = $r0, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 3)
  %2 = load half, half* %0
  %3 = tail call i64 (...) @llvm.kvx.ready(half %2)
  ret i64 %3
}

define i64 @ready_float(float* nocapture readonly %0) {
; CHECK-LABEL: ready_float:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lwz $r0 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    iord $r0 = $r0, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 3)
  %2 = load float, float* %0
  %3 = fpext float %2 to double
  %4 = bitcast double %3 to i64
  %5 = tail call i64 (...) @llvm.kvx.ready(i64 %4)
  ret i64 %5
}

define i64 @ready_double(double* nocapture readonly %0) {
; CHECK-LABEL: ready_double:
; CHECK:       # %bb.0:
; CHECK-NEXT:    ld $r0 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    iord $r0 = $r0, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 3)
  %2 = bitcast double* %0 to i64*
  %3 = load i64, i64* %2
  %4 = tail call i64 (...) @llvm.kvx.ready(i64 %3)
  ret i64 %4
}

define i64 @ready_v2f16(<2 x half>* nocapture readonly %0) {
; CHECK-LABEL: ready_v2f16:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lwz $r0 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    iord $r0 = $r0, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 3)
  %2 = bitcast <2 x half>* %0 to i32*
  %3 = load i32, i32* %2
  %4 = tail call i64 (...) @llvm.kvx.ready(i32 %3)
  ret i64 %4
}

define i64 @ready_v2f32(<2 x float>* nocapture readonly %0) {
; CHECK-LABEL: ready_v2f32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    ld $r0 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    iord $r0 = $r0, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 3)
  %2 = bitcast <2 x float>* %0 to i64*
  %3 = load i64, i64* %2
  %4 = tail call i64 (...) @llvm.kvx.ready(i64 %3)
  ret i64 %4
}

define i64 @ready_v2f64(<2 x double>* nocapture readonly %0) {
; CHECK-LABEL: ready_v2f64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lq $r0r1 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    iord $r0 = $r0, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 3)
  %2 = bitcast <2 x double>* %0 to <2 x i64>*
  %3 = load <2 x i64>, <2 x i64>* %2
  %4 = tail call i64 (...) @llvm.kvx.ready(<2 x i64> %3)
  ret i64 %4
}

define i64 @ready_v4f16(<4 x half>* nocapture readonly %0) {
; CHECK-LABEL: ready_v4f16:
; CHECK:       # %bb.0:
; CHECK-NEXT:    ld $r0 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    iord $r0 = $r0, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 3)
  %2 = bitcast <4 x half>* %0 to i64*
  %3 = load i64, i64* %2
  %4 = tail call i64 (...) @llvm.kvx.ready(i64 %3)
  ret i64 %4
}

define i64 @ready_v4f32(<4 x float>* nocapture readonly %0) {
; CHECK-LABEL: ready_v4f32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lq $r0r1 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    iord $r0 = $r0, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 3)
  %2 = bitcast <4 x float>* %0 to <2 x i64>*
  %3 = load <2 x i64>, <2 x i64>* %2
  %4 = tail call i64 (...) @llvm.kvx.ready(<2 x i64> %3)
  ret i64 %4
}

define i64 @ready_v4f64(<4 x double>* nocapture readonly %0) {
; CHECK-LABEL: ready_v4f64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lo $r0r1r2r3 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    iord $r0 = $r0, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 3)
  %2 = bitcast <4 x double>* %0 to <4 x i64>*
  %3 = load <4 x i64>, <4 x i64>* %2
  %4 = tail call i64 (...) @llvm.kvx.ready(<4 x i64> %3)
  ret i64 %4
}

define i64 @ready___int128(i128* nocapture readonly %0) {
; CHECK-LABEL: ready___int128:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lq $r0r1 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    iord $r0 = $r0, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 3)
  %2 = bitcast i128* %0 to <2 x i64>*
  %3 = load <2 x i64>, <2 x i64>* %2
  %4 = tail call i64 (...) @llvm.kvx.ready(<2 x i64> %3)
  ret i64 %4
}

define i64 @ready_v8i16(<8 x i16>* nocapture readonly %0) {
; CHECK-LABEL: ready_v8i16:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lq $r0r1 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    iord $r0 = $r0, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 3)
  %2 = bitcast <8 x i16>* %0 to <2 x i64>*
  %3 = load <2 x i64>, <2 x i64>* %2
  %4 = tail call i64 (...) @llvm.kvx.ready(<2 x i64> %3)
  ret i64 %4
}

define i64 @ready_v8i32(<8 x i32>* nocapture readonly %0) {
; CHECK-LABEL: ready_v8i32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lo $r0r1r2r3 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    iord $r0 = $r0, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 3)
  %2 = bitcast <8 x i32>* %0 to <4 x i64>*
  %3 = load <4 x i64>, <4 x i64>* %2
  %4 = tail call i64 (...) @llvm.kvx.ready(<4 x i64> %3)
  ret i64 %4
}

define i64 @ready_char(i8* nocapture readonly %0) {
; CHECK-LABEL: ready_char:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lbs $r0 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    iord $r0 = $r0, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 3)
  %2 = load i8, i8* %0
  %3 = sext i8 %2 to i32
  %4 = tail call i64 (...) @llvm.kvx.ready(i32 %3)
  ret i64 %4
}

define i64 @ready_int_v4f32(i32* nocapture readonly %0, <4 x float>* nocapture readonly %1) {
; CHECK-LABEL: ready_int_v4f32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lwz $r0 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    lq $r2r3 = 0[$r1]
; CHECK-NEXT:    ;; # (end cycle 1)
; CHECK-NEXT:    iord $r0 = $r0, $r2
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 4)
  %3 = load i32, i32* %0
  %4 = bitcast <4 x float>* %1 to <2 x i64>*
  %5 = load <2 x i64>, <2 x i64>* %4
  %6 = tail call i64 (...) @llvm.kvx.ready(i32 %3, <2 x i64> %5)
  ret i64 %6
}

define i64 @ready_long_int(i64* nocapture readonly %0, i32* nocapture readonly %1) {
; CHECK-LABEL: ready_long_int:
; CHECK:       # %bb.0:
; CHECK-NEXT:    ld $r0 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    lwz $r1 = 0[$r1]
; CHECK-NEXT:    ;; # (end cycle 1)
; CHECK-NEXT:    iord $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 4)
  %3 = load i64, i64* %0
  %4 = load i32, i32* %1
  %5 = tail call i64 (...) @llvm.kvx.ready(i64 %3, i32 %4)
  ret i64 %5
}

define i64 @ready_float_v8i8(float* nocapture readonly %0, <8 x i8>* nocapture readonly %1) {
; CHECK-LABEL: ready_float_v8i8:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lwz $r0 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    ld $r1 = 0[$r1]
; CHECK-NEXT:    ;; # (end cycle 1)
; CHECK-NEXT:    iord $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 4)
  %3 = load float, float* %0
  %4 = fpext float %3 to double
  %5 = bitcast double %4 to i64
  %6 = bitcast <8 x i8>* %1 to i64*
  %7 = load i64, i64* %6
  %8 = tail call i64 (...) @llvm.kvx.ready(i64 %5, i64 %7)
  ret i64 %8
}

define i64 @ready_int_long_float(i32* nocapture readonly %0, i64* nocapture readonly %1, float* nocapture readonly %2) {
; CHECK-LABEL: ready_int_long_float:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lwz $r0 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    ld $r1 = 0[$r1]
; CHECK-NEXT:    ;; # (end cycle 1)
; CHECK-NEXT:    lwz $r2 = 0[$r2]
; CHECK-NEXT:    ;; # (end cycle 2)
; CHECK-NEXT:    iord $r0 = $r0, $r1
; CHECK-NEXT:    iord $r0 = $r2, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 5)
  %4 = load i32, i32* %0
  %5 = load i64, i64* %1
  %6 = load float, float* %2
  %7 = fpext float %6 to double
  %8 = bitcast double %7 to i64
  %9 = tail call i64 (...) @llvm.kvx.ready(i32 %4, i64 %5, i64 %8)
  ret i64 %9
}

define i64 @ready___int128_v8i8_v2i64(i128* nocapture readonly %0, <8 x i8>* nocapture readonly %1, <2 x i64>* nocapture readonly %2) {
; CHECK-LABEL: ready___int128_v8i8_v2i64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lq $r4r5 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    ld $r0 = 0[$r1]
; CHECK-NEXT:    ;; # (end cycle 1)
; CHECK-NEXT:    lq $r2r3 = 0[$r2]
; CHECK-NEXT:    ;; # (end cycle 2)
; CHECK-NEXT:    iord $r0 = $r2, $r4
; CHECK-NEXT:    iord $r0 = $r4, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 5)
  %4 = bitcast i128* %0 to <2 x i64>*
  %5 = load <2 x i64>, <2 x i64>* %4
  %6 = bitcast <8 x i8>* %1 to i64*
  %7 = load i64, i64* %6
  %8 = load <2 x i64>, <2 x i64>* %2
  %9 = tail call i64 (...) @llvm.kvx.ready(<2 x i64> %5, i64 %7, <2 x i64> %8)
  ret i64 %9
}

define i64 @ready_char_short_double(i8* nocapture readonly %0, i16* nocapture readonly %1, double* nocapture readonly %2) {
; CHECK-LABEL: ready_char_short_double:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lbs $r0 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    lhs $r1 = 0[$r1]
; CHECK-NEXT:    ;; # (end cycle 1)
; CHECK-NEXT:    ld $r2 = 0[$r2]
; CHECK-NEXT:    ;; # (end cycle 2)
; CHECK-NEXT:    iord $r0 = $r0, $r1
; CHECK-NEXT:    iord $r0 = $r2, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 5)
  %4 = load i8, i8* %0
  %5 = sext i8 %4 to i32
  %6 = load i16, i16* %1
  %7 = sext i16 %6 to i32
  %8 = bitcast double* %2 to i64*
  %9 = load i64, i64* %8
  %10 = tail call i64 (...) @llvm.kvx.ready(i32 %5, i32 %7, i64 %9)
  ret i64 %10
}

define i64 @ready_char_short_int_long(i8* nocapture readonly %0, i16* nocapture readonly %1, i32* nocapture readonly %2, i64* nocapture readonly %3) {
; CHECK-LABEL: ready_char_short_int_long:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lbs $r0 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    lhs $r1 = 0[$r1]
; CHECK-NEXT:    ;; # (end cycle 1)
; CHECK-NEXT:    lwz $r2 = 0[$r2]
; CHECK-NEXT:    ;; # (end cycle 2)
; CHECK-NEXT:    ld $r3 = 0[$r3]
; CHECK-NEXT:    ;; # (end cycle 3)
; CHECK-NEXT:    iord $r0 = $r0, $r1
; CHECK-NEXT:    iord $r0 = $r2, $r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 6)
  %5 = load i8, i8* %0
  %6 = sext i8 %5 to i32
  %7 = load i16, i16* %1
  %8 = sext i16 %7 to i32
  %9 = load i32, i32* %2
  %10 = load i64, i64* %3
  %11 = tail call i64 (...) @llvm.kvx.ready(i32 %6, i32 %8, i32 %9, i64 %10)
  ret i64 %11
}

define i64 @ready__Float16_float_double_v4i64(half* nocapture readonly %0, float* nocapture readonly %1, double* nocapture readonly %2, <4 x i64>* nocapture readonly %3) {
; CHECK-LABEL: ready__Float16_float_double_v4i64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lhz $r0 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    lwz $r1 = 0[$r1]
; CHECK-NEXT:    ;; # (end cycle 1)
; CHECK-NEXT:    ld $r2 = 0[$r2]
; CHECK-NEXT:    ;; # (end cycle 2)
; CHECK-NEXT:    lo $r4r5r6r7 = 0[$r3]
; CHECK-NEXT:    ;; # (end cycle 3)
; CHECK-NEXT:    iord $r0 = $r0, $r1
; CHECK-NEXT:    iord $r0 = $r2, $r4
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 6)
  %5 = load half, half* %0
  %6 = load float, float* %1
  %7 = fpext float %6 to double
  %8 = bitcast double %7 to i64
  %9 = bitcast double* %2 to i64*
  %10 = load i64, i64* %9
  %11 = load <4 x i64>, <4 x i64>* %3
  %12 = tail call i64 (...) @llvm.kvx.ready(half %5, i64 %8, i64 %10, <4 x i64> %11)
  ret i64 %12
}

define i64 @ready_v8f32_v4i32___int128_char(<8 x float>* nocapture readonly %0, <4 x i32>* nocapture readonly %1, i128* nocapture readonly %2, i8* nocapture readonly %3) {
; CHECK-LABEL: ready_v8f32_v4i32___int128_char:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lo $r4r5r6r7 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    lq $r0r1 = 0[$r1]
; CHECK-NEXT:    ;; # (end cycle 1)
; CHECK-NEXT:    lq $r8r9 = 0[$r2]
; CHECK-NEXT:    ;; # (end cycle 2)
; CHECK-NEXT:    lbs $r2 = 0[$r3]
; CHECK-NEXT:    ;; # (end cycle 3)
; CHECK-NEXT:    iord $r0 = $r4, $r0
; CHECK-NEXT:    iord $r0 = $r8, $r2
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 6)
  %5 = bitcast <8 x float>* %0 to <4 x i64>*
  %6 = load <4 x i64>, <4 x i64>* %5
  %7 = bitcast <4 x i32>* %1 to <2 x i64>*
  %8 = load <2 x i64>, <2 x i64>* %7
  %9 = bitcast i128* %2 to <2 x i64>*
  %10 = load <2 x i64>, <2 x i64>* %9
  %11 = load i8, i8* %3
  %12 = sext i8 %11 to i32
  %13 = tail call i64 (...) @llvm.kvx.ready(<4 x i64> %6, <2 x i64> %8, <2 x i64> %10, i32 %12)
  ret i64 %13
}

