; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -o - %s -O2 -verify-machineinstrs | FileCheck %s --check-prefixes=CHECK
; RUN: llc -mcpu=kv3-2 -o - %s -O2 -verify-machineinstrs | FileCheck %s --check-prefixes=CHECK
; RUN: clang -O2 -c -o /dev/null %s
; RUN: clang -O2 -march=kv3-2 -c -o /dev/null %s

target triple = "kvx-kalray-cos"

define void @storecbc(i8 %a, i8* %ptr, i64 %cond) {
; CHECK-LABEL: storecbc:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sb.dltz $r2 ? [$r1] = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %conv = zext i8 %a to i64
  %0 = bitcast i8* %ptr to i64*
  tail call void (i64, i64*, i32, i64, i32, i32, ...) @llvm.kvx.storec.i64(i64 %conv, i64* %0, i32 8, i64 %cond, i32 2, i32 -1)
  ret void
}

declare void @llvm.kvx.storec.i64(i64, i64*, i32, i64, i32, i32, ...)

define void @storecbl(i64 %a, i8* %ptr, i64 %cond) {
; CHECK-LABEL: storecbl:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sb.dltz $r2 ? [$r1] = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %0 = bitcast i8* %ptr to i64*
  tail call void (i64, i64*, i32, i64, i32, i32, ...) @llvm.kvx.storec.i64(i64 %a, i64* %0, i32 8, i64 %cond, i32 2, i32 -1)
  ret void
}

define void @storechs(i16 %a, i8* %ptr, i64 %cond) {
; CHECK-LABEL: storechs:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sh.dltz $r2 ? [$r1] = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %conv = zext i16 %a to i64
  %0 = bitcast i8* %ptr to i64*
  tail call void (i64, i64*, i32, i64, i32, i32, ...) @llvm.kvx.storec.i64(i64 %conv, i64* %0, i32 16, i64 %cond, i32 2, i32 -1)
  ret void
}

define void @storechl(i64 %a, i8* %ptr, i64 %cond) {
; CHECK-LABEL: storechl:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sh.dltz $r2 ? [$r1] = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %0 = bitcast i8* %ptr to i64*
  tail call void (i64, i64*, i32, i64, i32, i32, ...) @llvm.kvx.storec.i64(i64 %a, i64* %0, i32 16, i64 %cond, i32 2, i32 -1)
  ret void
}

define void @storecwi(i32 %a, i8* %ptr, i64 %cond) {
; CHECK-LABEL: storecwi:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sw.dltz $r2 ? [$r1] = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %conv = zext i32 %a to i64
  %0 = bitcast i8* %ptr to i64*
  tail call void (i64, i64*, i32, i64, i32, i32, ...) @llvm.kvx.storec.i64(i64 %conv, i64* %0, i32 32, i64 %cond, i32 2, i32 -1)
  ret void
}

define void @storecwl(i64 %a, i8* %ptr, i64 %cond) {
; CHECK-LABEL: storecwl:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sw.dltz $r2 ? [$r1] = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %0 = bitcast i8* %ptr to i64*
  tail call void (i64, i64*, i32, i64, i32, i32, ...) @llvm.kvx.storec.i64(i64 %a, i64* %0, i32 32, i64 %cond, i32 2, i32 -1)
  ret void
}

define void @storecdl(i64 %a, i8* %ptr, i64 %cond) {
; CHECK-LABEL: storecdl:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sd.dltz $r2 ? [$r1] = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %0 = bitcast i8* %ptr to i64*
  tail call void (i64, i64*, i32, i64, i32, i32, ...) @llvm.kvx.storec.i64(i64 %a, i64* %0, i32 64, i64 %cond, i32 2, i32 -1)
  ret void
}

define void @storecq(i128 %a, i8* %ptr, i64 %cond) {
; CHECK-LABEL: storecq:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sq.dltz $r3 ? [$r2] = $r0r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %0 = bitcast i128 %a to <2 x i64>
  %1 = bitcast i8* %ptr to <2 x i64>*
  tail call void (<2 x i64>, <2 x i64>*, i32, i64, i32, i32, ...) @llvm.kvx.storec.v2i64(<2 x i64> %0, <2 x i64>* %1, i32 128, i64 %cond, i32 2, i32 -1)
  ret void
}

declare void @llvm.kvx.storec.v2i64(<2 x i64>, <2 x i64>*, i32, i64, i32, i32, ...)

define void @storechf(half %a, i8* %ptr, i64 %cond) {
; CHECK-LABEL: storechf:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sh.dltz $r2 ? [$r1] = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %0 = bitcast i8* %ptr to half*
  tail call void (half, half*, i32, i64, i32, i32, ...) @llvm.kvx.storec.f16(half %a, half* %0, i32 16, i64 %cond, i32 2, i32 -1)
  ret void
}

declare void @llvm.kvx.storec.f16(half, half*, i32, i64, i32, i32, ...)

define void @storecwf(float %a, i8* %ptr, i64 %cond) {
; CHECK-LABEL: storecwf:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sw.dltz $r2 ? [$r1] = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %0 = bitcast i8* %ptr to float*
  tail call void (float, float*, i32, i64, i32, i32, ...) @llvm.kvx.storec.f32(float %a, float* %0, i32 32, i64 %cond, i32 2, i32 -1)
  ret void
}

declare void @llvm.kvx.storec.f32(float, float*, i32, i64, i32, i32, ...)

define void @storecdf(double %a, i8* %ptr, i64 %cond) {
; CHECK-LABEL: storecdf:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sd.dltz $r2 ? [$r1] = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %0 = bitcast i8* %ptr to double*
  tail call void (double, double*, i32, i64, i32, i32, ...) @llvm.kvx.storec.f64(double %a, double* %0, i32 64, i64 %cond, i32 2, i32 -1)
  ret void
}

declare void @llvm.kvx.storec.f64(double, double*, i32, i64, i32, i32, ...)

define void @storec64(<2 x i32> %a, i8* %ptr, i64 %cond) {
; CHECK-LABEL: storec64:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sd.dltz $r2 ? [$r1] = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %0 = bitcast i8* %ptr to <2 x i32>*
  tail call void (<2 x i32>, <2 x i32>*, i32, i64, i32, i32, ...) @llvm.kvx.storec.v2i32(<2 x i32> %a, <2 x i32>* %0, i32 64, i64 %cond, i32 2, i32 -1)
  ret void
}

declare void @llvm.kvx.storec.v2i32(<2 x i32>, <2 x i32>*, i32, i64, i32, i32, ...)

define void @storec64h(<4 x i16> %a, i8* %ptr, i64 %cond) {
; CHECK-LABEL: storec64h:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sd.dltz $r2 ? [$r1] = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %0 = bitcast <4 x i16> %a to <2 x i32>
  %1 = bitcast i8* %ptr to <2 x i32>*
  tail call void (<2 x i32>, <2 x i32>*, i32, i64, i32, i32, ...) @llvm.kvx.storec.v2i32(<2 x i32> %0, <2 x i32>* %1, i32 64, i64 %cond, i32 2, i32 -1)
  ret void
}

define void @storec128(<4 x i32> %a, i8* %ptr, i64 %cond) {
; CHECK-LABEL: storec128:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sq.dltz $r3 ? [$r2] = $r0r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %0 = bitcast <4 x i32> %a to <2 x i64>
  %1 = bitcast i8* %ptr to <2 x i64>*
  tail call void (<2 x i64>, <2 x i64>*, i32, i64, i32, i32, ...) @llvm.kvx.storec.v2i64(<2 x i64> %0, <2 x i64>* %1, i32 128, i64 %cond, i32 2, i32 -1)
  ret void
}

define void @storec128h(<8 x i16> %a, i8* %ptr, i64 %cond) {
; CHECK-LABEL: storec128h:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sq.dltz $r3 ? [$r2] = $r0r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %0 = bitcast <8 x i16> %a to <2 x i64>
  %1 = bitcast i8* %ptr to <2 x i64>*
  tail call void (<2 x i64>, <2 x i64>*, i32, i64, i32, i32, ...) @llvm.kvx.storec.v2i64(<2 x i64> %0, <2 x i64>* %1, i32 128, i64 %cond, i32 2, i32 -1)
  ret void
}

define void @storec256h(<16 x i16> %a, i8* %ptr, i64 %cond) {
; CHECK-LABEL: storec256h:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    so.dltz $r5 ? [$r4] = $r0r1r2r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %0 = bitcast <16 x i16> %a to <4 x i64>
  %1 = bitcast i8* %ptr to <4 x i64>*
  tail call void (<4 x i64>, <4 x i64>*, i32, i64, i32, i32, ...) @llvm.kvx.storec.v4i64(<4 x i64> %0, <4 x i64>* %1, i32 256, i64 %cond, i32 2, i32 -1)
  ret void
}

declare void @llvm.kvx.storec.v4i64(<4 x i64>, <4 x i64>*, i32, i64, i32, i32, ...)

define i32 @storecbc_r(i8 %a, i8* %ptr, i32* nocapture readonly %load, i64 %cond) {
; CHECK-LABEL: storecbc_r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz $r2 = 0[$r2]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    sb.dltz $r3 ? [$r1] = $r0
; CHECK-NEXT:    iord $r2 = $r2, $r2
; CHECK-NEXT:    ;; # (end cycle 3)
; CHECK-NEXT:    copyd $r0 = $r2
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 4)
entry:
  %0 = load i32, i32* %load
  %1 = tail call i64 (...) @llvm.kvx.ready(i32 %0)
  %conv = trunc i64 %1 to i32
  %conv1 = zext i8 %a to i64
  %2 = bitcast i8* %ptr to i64*
  tail call void (i64, i64*, i32, i64, i32, i32, ...) @llvm.kvx.storec.i64(i64 %conv1, i64* %2, i32 8, i64 %cond, i32 2, i32 -1, i32 %conv)
  ret i32 %conv
}

declare i64 @llvm.kvx.ready(...)

define i32 @storecbl_r(i64 %a, i8* %ptr, i32* nocapture readonly %load, i64 %cond) {
; CHECK-LABEL: storecbl_r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz $r2 = 0[$r2]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    sb.dltz $r3 ? [$r1] = $r0
; CHECK-NEXT:    iord $r2 = $r2, $r2
; CHECK-NEXT:    ;; # (end cycle 3)
; CHECK-NEXT:    copyd $r0 = $r2
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 4)
entry:
  %0 = load i32, i32* %load
  %1 = tail call i64 (...) @llvm.kvx.ready(i32 %0)
  %conv = trunc i64 %1 to i32
  %2 = bitcast i8* %ptr to i64*
  tail call void (i64, i64*, i32, i64, i32, i32, ...) @llvm.kvx.storec.i64(i64 %a, i64* %2, i32 8, i64 %cond, i32 2, i32 -1, i32 %conv)
  ret i32 %conv
}

define i32 @storechs_r(i16 %a, i8* %ptr, i32* nocapture readonly %load, i64 %cond) {
; CHECK-LABEL: storechs_r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz $r2 = 0[$r2]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    sh.dltz $r3 ? [$r1] = $r0
; CHECK-NEXT:    iord $r2 = $r2, $r2
; CHECK-NEXT:    ;; # (end cycle 3)
; CHECK-NEXT:    copyd $r0 = $r2
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 4)
entry:
  %0 = load i32, i32* %load
  %1 = tail call i64 (...) @llvm.kvx.ready(i32 %0)
  %conv = trunc i64 %1 to i32
  %conv1 = zext i16 %a to i64
  %2 = bitcast i8* %ptr to i64*
  tail call void (i64, i64*, i32, i64, i32, i32, ...) @llvm.kvx.storec.i64(i64 %conv1, i64* %2, i32 16, i64 %cond, i32 2, i32 -1, i32 %conv)
  ret i32 %conv
}

define i32 @storechl_r(i64 %a, i8* %ptr, i32* nocapture readonly %load, i64 %cond) {
; CHECK-LABEL: storechl_r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz $r2 = 0[$r2]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    sh.dltz $r3 ? [$r1] = $r0
; CHECK-NEXT:    iord $r2 = $r2, $r2
; CHECK-NEXT:    ;; # (end cycle 3)
; CHECK-NEXT:    copyd $r0 = $r2
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 4)
entry:
  %0 = load i32, i32* %load
  %1 = tail call i64 (...) @llvm.kvx.ready(i32 %0)
  %conv = trunc i64 %1 to i32
  %2 = bitcast i8* %ptr to i64*
  tail call void (i64, i64*, i32, i64, i32, i32, ...) @llvm.kvx.storec.i64(i64 %a, i64* %2, i32 16, i64 %cond, i32 2, i32 -1, i32 %conv)
  ret i32 %conv
}

define i32 @storecwi_r(i32 %a, i8* %ptr, i32* nocapture readonly %load, i64 %cond) {
; CHECK-LABEL: storecwi_r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz $r2 = 0[$r2]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    sw.dltz $r3 ? [$r1] = $r0
; CHECK-NEXT:    iord $r2 = $r2, $r2
; CHECK-NEXT:    ;; # (end cycle 3)
; CHECK-NEXT:    copyd $r0 = $r2
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 4)
entry:
  %0 = load i32, i32* %load
  %1 = tail call i64 (...) @llvm.kvx.ready(i32 %0)
  %conv = trunc i64 %1 to i32
  %conv1 = zext i32 %a to i64
  %2 = bitcast i8* %ptr to i64*
  tail call void (i64, i64*, i32, i64, i32, i32, ...) @llvm.kvx.storec.i64(i64 %conv1, i64* %2, i32 32, i64 %cond, i32 2, i32 -1, i32 %conv)
  ret i32 %conv
}

define i32 @storecwl_r(i64 %a, i8* %ptr, i32* nocapture readonly %load, i64 %cond) {
; CHECK-LABEL: storecwl_r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz $r2 = 0[$r2]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    sw.dltz $r3 ? [$r1] = $r0
; CHECK-NEXT:    iord $r2 = $r2, $r2
; CHECK-NEXT:    ;; # (end cycle 3)
; CHECK-NEXT:    copyd $r0 = $r2
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 4)
entry:
  %0 = load i32, i32* %load
  %1 = tail call i64 (...) @llvm.kvx.ready(i32 %0)
  %conv = trunc i64 %1 to i32
  %2 = bitcast i8* %ptr to i64*
  tail call void (i64, i64*, i32, i64, i32, i32, ...) @llvm.kvx.storec.i64(i64 %a, i64* %2, i32 32, i64 %cond, i32 2, i32 -1, i32 %conv)
  ret i32 %conv
}

define i32 @storecdl_r(i64 %a, i8* %ptr, i32* nocapture readonly %load, i64 %cond) {
; CHECK-LABEL: storecdl_r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz $r2 = 0[$r2]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    sd.dltz $r3 ? [$r1] = $r0
; CHECK-NEXT:    iord $r2 = $r2, $r2
; CHECK-NEXT:    ;; # (end cycle 3)
; CHECK-NEXT:    copyd $r0 = $r2
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 4)
entry:
  %0 = load i32, i32* %load
  %1 = tail call i64 (...) @llvm.kvx.ready(i32 %0)
  %conv = trunc i64 %1 to i32
  %2 = bitcast i8* %ptr to i64*
  tail call void (i64, i64*, i32, i64, i32, i32, ...) @llvm.kvx.storec.i64(i64 %a, i64* %2, i32 64, i64 %cond, i32 2, i32 -1, i32 %conv)
  ret i32 %conv
}

define i32 @storecq_r(i128 %a, i8* %ptr, i32* nocapture readonly %load, i64 %cond) {
; CHECK-LABEL: storecq_r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz $r3 = 0[$r3]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    sq.dltz $r4 ? [$r2] = $r0r1
; CHECK-NEXT:    iord $r3 = $r3, $r3
; CHECK-NEXT:    ;; # (end cycle 3)
; CHECK-NEXT:    copyd $r0 = $r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 4)
entry:
  %0 = load i32, i32* %load
  %1 = tail call i64 (...) @llvm.kvx.ready(i32 %0)
  %conv = trunc i64 %1 to i32
  %2 = bitcast i128 %a to <2 x i64>
  %3 = bitcast i8* %ptr to <2 x i64>*
  tail call void (<2 x i64>, <2 x i64>*, i32, i64, i32, i32, ...) @llvm.kvx.storec.v2i64(<2 x i64> %2, <2 x i64>* %3, i32 128, i64 %cond, i32 2, i32 -1, i32 %conv)
  ret i32 %conv
}

define i32 @storechf_r(half %a, i8* %ptr, i32* nocapture readonly %load, i64 %cond) {
; CHECK-LABEL: storechf_r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz $r2 = 0[$r2]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    sh.dltz $r3 ? [$r1] = $r0
; CHECK-NEXT:    iord $r2 = $r2, $r2
; CHECK-NEXT:    ;; # (end cycle 3)
; CHECK-NEXT:    copyd $r0 = $r2
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 4)
entry:
  %0 = load i32, i32* %load
  %1 = tail call i64 (...) @llvm.kvx.ready(i32 %0)
  %conv = trunc i64 %1 to i32
  %2 = bitcast i8* %ptr to half*
  tail call void (half, half*, i32, i64, i32, i32, ...) @llvm.kvx.storec.f16(half %a, half* %2, i32 16, i64 %cond, i32 2, i32 -1, i32 %conv)
  ret i32 %conv
}

define i32 @storecwf_r(float %a, i8* %ptr, i32* nocapture readonly %load, i64 %cond) {
; CHECK-LABEL: storecwf_r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz $r2 = 0[$r2]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    sw.dltz $r3 ? [$r1] = $r0
; CHECK-NEXT:    iord $r2 = $r2, $r2
; CHECK-NEXT:    ;; # (end cycle 3)
; CHECK-NEXT:    copyd $r0 = $r2
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 4)
entry:
  %0 = load i32, i32* %load
  %1 = tail call i64 (...) @llvm.kvx.ready(i32 %0)
  %conv = trunc i64 %1 to i32
  %2 = bitcast i8* %ptr to float*
  tail call void (float, float*, i32, i64, i32, i32, ...) @llvm.kvx.storec.f32(float %a, float* %2, i32 32, i64 %cond, i32 2, i32 -1, i32 %conv)
  ret i32 %conv
}

define i32 @storecdf_r(double %a, i8* %ptr, i32* nocapture readonly %load, i64 %cond) {
; CHECK-LABEL: storecdf_r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz $r2 = 0[$r2]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    sd.dltz $r3 ? [$r1] = $r0
; CHECK-NEXT:    iord $r2 = $r2, $r2
; CHECK-NEXT:    ;; # (end cycle 3)
; CHECK-NEXT:    copyd $r0 = $r2
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 4)
entry:
  %0 = load i32, i32* %load
  %1 = tail call i64 (...) @llvm.kvx.ready(i32 %0)
  %conv = trunc i64 %1 to i32
  %2 = bitcast i8* %ptr to double*
  tail call void (double, double*, i32, i64, i32, i32, ...) @llvm.kvx.storec.f64(double %a, double* %2, i32 64, i64 %cond, i32 2, i32 -1, i32 %conv)
  ret i32 %conv
}

define i32 @storec64_r(<2 x i32> %a, i8* %ptr, i32* nocapture readonly %load, i64 %cond) {
; CHECK-LABEL: storec64_r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz $r2 = 0[$r2]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    sd.dltz $r3 ? [$r1] = $r0
; CHECK-NEXT:    iord $r2 = $r2, $r2
; CHECK-NEXT:    ;; # (end cycle 3)
; CHECK-NEXT:    copyd $r0 = $r2
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 4)
entry:
  %0 = load i32, i32* %load
  %1 = tail call i64 (...) @llvm.kvx.ready(i32 %0)
  %conv = trunc i64 %1 to i32
  %2 = bitcast i8* %ptr to <2 x i32>*
  tail call void (<2 x i32>, <2 x i32>*, i32, i64, i32, i32, ...) @llvm.kvx.storec.v2i32(<2 x i32> %a, <2 x i32>* %2, i32 64, i64 %cond, i32 2, i32 -1, i32 %conv)
  ret i32 %conv
}

define i32 @storec64h_r(<4 x i16> %a, i8* %ptr, i32* nocapture readonly %load, i64 %cond) {
; CHECK-LABEL: storec64h_r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz $r2 = 0[$r2]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    sd.dltz $r3 ? [$r1] = $r0
; CHECK-NEXT:    iord $r2 = $r2, $r2
; CHECK-NEXT:    ;; # (end cycle 3)
; CHECK-NEXT:    copyd $r0 = $r2
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 4)
entry:
  %0 = load i32, i32* %load
  %1 = tail call i64 (...) @llvm.kvx.ready(i32 %0)
  %conv = trunc i64 %1 to i32
  %2 = bitcast <4 x i16> %a to <2 x i32>
  %3 = bitcast i8* %ptr to <2 x i32>*
  tail call void (<2 x i32>, <2 x i32>*, i32, i64, i32, i32, ...) @llvm.kvx.storec.v2i32(<2 x i32> %2, <2 x i32>* %3, i32 64, i64 %cond, i32 2, i32 -1, i32 %conv)
  ret i32 %conv
}

define i32 @storec128_r(<4 x i32> %a, i8* %ptr, i32* nocapture readonly %load, i64 %cond) {
; CHECK-LABEL: storec128_r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz $r3 = 0[$r3]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    sq.dltz $r4 ? [$r2] = $r0r1
; CHECK-NEXT:    iord $r3 = $r3, $r3
; CHECK-NEXT:    ;; # (end cycle 3)
; CHECK-NEXT:    copyd $r0 = $r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 4)
entry:
  %0 = load i32, i32* %load
  %1 = tail call i64 (...) @llvm.kvx.ready(i32 %0)
  %conv = trunc i64 %1 to i32
  %2 = bitcast <4 x i32> %a to <2 x i64>
  %3 = bitcast i8* %ptr to <2 x i64>*
  tail call void (<2 x i64>, <2 x i64>*, i32, i64, i32, i32, ...) @llvm.kvx.storec.v2i64(<2 x i64> %2, <2 x i64>* %3, i32 128, i64 %cond, i32 2, i32 -1, i32 %conv)
  ret i32 %conv
}

define i32 @storec128h_r(<8 x i16> %a, i8* %ptr, i32* nocapture readonly %load, i64 %cond) {
; CHECK-LABEL: storec128h_r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz $r3 = 0[$r3]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    sq.dltz $r4 ? [$r2] = $r0r1
; CHECK-NEXT:    iord $r3 = $r3, $r3
; CHECK-NEXT:    ;; # (end cycle 3)
; CHECK-NEXT:    copyd $r0 = $r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 4)
entry:
  %0 = load i32, i32* %load
  %1 = tail call i64 (...) @llvm.kvx.ready(i32 %0)
  %conv = trunc i64 %1 to i32
  %2 = bitcast <8 x i16> %a to <2 x i64>
  %3 = bitcast i8* %ptr to <2 x i64>*
  tail call void (<2 x i64>, <2 x i64>*, i32, i64, i32, i32, ...) @llvm.kvx.storec.v2i64(<2 x i64> %2, <2 x i64>* %3, i32 128, i64 %cond, i32 2, i32 -1, i32 %conv)
  ret i32 %conv
}

define i32 @storec256h_r(<16 x i16> %a, i8* %ptr, i32* nocapture readonly %load, i64 %cond) {
; CHECK-LABEL: storec256h_r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz $r5 = 0[$r5]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    so.dltz $r6 ? [$r4] = $r0r1r2r3
; CHECK-NEXT:    iord $r5 = $r5, $r5
; CHECK-NEXT:    ;; # (end cycle 3)
; CHECK-NEXT:    copyd $r0 = $r5
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 4)
entry:
  %0 = load i32, i32* %load
  %1 = tail call i64 (...) @llvm.kvx.ready(i32 %0)
  %conv = trunc i64 %1 to i32
  %2 = bitcast <16 x i16> %a to <4 x i64>
  %3 = bitcast i8* %ptr to <4 x i64>*
  tail call void (<4 x i64>, <4 x i64>*, i32, i64, i32, i32, ...) @llvm.kvx.storec.v4i64(<4 x i64> %2, <4 x i64>* %3, i32 256, i64 %cond, i32 2, i32 -1, i32 %conv)
  ret i32 %conv
}

define void @storec256_dltz(<8 x i32> %a, i8* %ptr, i64 %cond) {
; CHECK-LABEL: storec256_dltz:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    so.dltz $r5 ? [$r4] = $r0r1r2r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %0 = bitcast <8 x i32> %a to <4 x i64>
  %1 = bitcast i8* %ptr to <4 x i64>*
  tail call void (<4 x i64>, <4 x i64>*, i32, i64, i32, i32, ...) @llvm.kvx.storec.v4i64(<4 x i64> %0, <4 x i64>* %1, i32 256, i64 %cond, i32 2, i32 -1)
  ret void
}

define void @storec256_dnez(<8 x i32> %a, i8* %ptr, i64 %cond) {
; CHECK-LABEL: storec256_dnez:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    so.dnez $r5 ? [$r4] = $r0r1r2r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %0 = bitcast <8 x i32> %a to <4 x i64>
  %1 = bitcast i8* %ptr to <4 x i64>*
  tail call void (<4 x i64>, <4 x i64>*, i32, i64, i32, i32, ...) @llvm.kvx.storec.v4i64(<4 x i64> %0, <4 x i64>* %1, i32 256, i64 %cond, i32 0, i32 -1)
  ret void
}

define void @storec256_deqz(<8 x i32> %a, i8* %ptr, i64 %cond) {
; CHECK-LABEL: storec256_deqz:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    so.deqz $r5 ? [$r4] = $r0r1r2r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %0 = bitcast <8 x i32> %a to <4 x i64>
  %1 = bitcast i8* %ptr to <4 x i64>*
  tail call void (<4 x i64>, <4 x i64>*, i32, i64, i32, i32, ...) @llvm.kvx.storec.v4i64(<4 x i64> %0, <4 x i64>* %1, i32 256, i64 %cond, i32 1, i32 -1)
  ret void
}

define void @storec256_dgez(<8 x i32> %a, i8* %ptr, i64 %cond) {
; CHECK-LABEL: storec256_dgez:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    so.dgez $r5 ? [$r4] = $r0r1r2r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %0 = bitcast <8 x i32> %a to <4 x i64>
  %1 = bitcast i8* %ptr to <4 x i64>*
  tail call void (<4 x i64>, <4 x i64>*, i32, i64, i32, i32, ...) @llvm.kvx.storec.v4i64(<4 x i64> %0, <4 x i64>* %1, i32 256, i64 %cond, i32 3, i32 -1)
  ret void
}

define void @storec256_dlez(<8 x i32> %a, i8* %ptr, i64 %cond) {
; CHECK-LABEL: storec256_dlez:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    so.dlez $r5 ? [$r4] = $r0r1r2r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %0 = bitcast <8 x i32> %a to <4 x i64>
  %1 = bitcast i8* %ptr to <4 x i64>*
  tail call void (<4 x i64>, <4 x i64>*, i32, i64, i32, i32, ...) @llvm.kvx.storec.v4i64(<4 x i64> %0, <4 x i64>* %1, i32 256, i64 %cond, i32 4, i32 -1)
  ret void
}

define void @storec256_dgtz(<8 x i32> %a, i8* %ptr, i64 %cond) {
; CHECK-LABEL: storec256_dgtz:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    so.dgtz $r5 ? [$r4] = $r0r1r2r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %0 = bitcast <8 x i32> %a to <4 x i64>
  %1 = bitcast i8* %ptr to <4 x i64>*
  tail call void (<4 x i64>, <4 x i64>*, i32, i64, i32, i32, ...) @llvm.kvx.storec.v4i64(<4 x i64> %0, <4 x i64>* %1, i32 256, i64 %cond, i32 5, i32 -1)
  ret void
}

define void @storec256_odd(<8 x i32> %a, i8* %ptr, i64 %cond) {
; CHECK-LABEL: storec256_odd:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    so.odd $r5 ? [$r4] = $r0r1r2r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %0 = bitcast <8 x i32> %a to <4 x i64>
  %1 = bitcast i8* %ptr to <4 x i64>*
  tail call void (<4 x i64>, <4 x i64>*, i32, i64, i32, i32, ...) @llvm.kvx.storec.v4i64(<4 x i64> %0, <4 x i64>* %1, i32 256, i64 %cond, i32 6, i32 -1)
  ret void
}

define void @storec256_even(<8 x i32> %a, i8* %ptr, i64 %cond) {
; CHECK-LABEL: storec256_even:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    so.even $r5 ? [$r4] = $r0r1r2r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %0 = bitcast <8 x i32> %a to <4 x i64>
  %1 = bitcast i8* %ptr to <4 x i64>*
  tail call void (<4 x i64>, <4 x i64>*, i32, i64, i32, i32, ...) @llvm.kvx.storec.v4i64(<4 x i64> %0, <4 x i64>* %1, i32 256, i64 %cond, i32 7, i32 -1)
  ret void
}

define void @storec256_wnez(<8 x i32> %a, i8* %ptr, i64 %cond) {
; CHECK-LABEL: storec256_wnez:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    so.wnez $r5 ? [$r4] = $r0r1r2r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %0 = bitcast <8 x i32> %a to <4 x i64>
  %1 = bitcast i8* %ptr to <4 x i64>*
  tail call void (<4 x i64>, <4 x i64>*, i32, i64, i32, i32, ...) @llvm.kvx.storec.v4i64(<4 x i64> %0, <4 x i64>* %1, i32 256, i64 %cond, i32 8, i32 -1)
  ret void
}

define void @storec256_weqz(<8 x i32> %a, i8* %ptr, i64 %cond) {
; CHECK-LABEL: storec256_weqz:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    so.weqz $r5 ? [$r4] = $r0r1r2r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %0 = bitcast <8 x i32> %a to <4 x i64>
  %1 = bitcast i8* %ptr to <4 x i64>*
  tail call void (<4 x i64>, <4 x i64>*, i32, i64, i32, i32, ...) @llvm.kvx.storec.v4i64(<4 x i64> %0, <4 x i64>* %1, i32 256, i64 %cond, i32 9, i32 -1)
  ret void
}

define void @storec256_wltz(<8 x i32> %a, i8* %ptr, i64 %cond) {
; CHECK-LABEL: storec256_wltz:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    so.wltz $r5 ? [$r4] = $r0r1r2r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %0 = bitcast <8 x i32> %a to <4 x i64>
  %1 = bitcast i8* %ptr to <4 x i64>*
  tail call void (<4 x i64>, <4 x i64>*, i32, i64, i32, i32, ...) @llvm.kvx.storec.v4i64(<4 x i64> %0, <4 x i64>* %1, i32 256, i64 %cond, i32 10, i32 -1)
  ret void
}

define void @storec256_wgez(<8 x i32> %a, i8* %ptr, i64 %cond) {
; CHECK-LABEL: storec256_wgez:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    so.wgez $r5 ? [$r4] = $r0r1r2r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %0 = bitcast <8 x i32> %a to <4 x i64>
  %1 = bitcast i8* %ptr to <4 x i64>*
  tail call void (<4 x i64>, <4 x i64>*, i32, i64, i32, i32, ...) @llvm.kvx.storec.v4i64(<4 x i64> %0, <4 x i64>* %1, i32 256, i64 %cond, i32 11, i32 -1)
  ret void
}

define void @storec256_wlez(<8 x i32> %a, i8* %ptr, i64 %cond) {
; CHECK-LABEL: storec256_wlez:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    so.wlez $r5 ? [$r4] = $r0r1r2r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %0 = bitcast <8 x i32> %a to <4 x i64>
  %1 = bitcast i8* %ptr to <4 x i64>*
  tail call void (<4 x i64>, <4 x i64>*, i32, i64, i32, i32, ...) @llvm.kvx.storec.v4i64(<4 x i64> %0, <4 x i64>* %1, i32 256, i64 %cond, i32 12, i32 -1)
  ret void
}

define void @storec256_wgtz(<8 x i32> %a, i8* %ptr, i64 %cond) {
; CHECK-LABEL: storec256_wgtz:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    so.wgtz $r5 ? [$r4] = $r0r1r2r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %0 = bitcast <8 x i32> %a to <4 x i64>
  %1 = bitcast i8* %ptr to <4 x i64>*
  tail call void (<4 x i64>, <4 x i64>*, i32, i64, i32, i32, ...) @llvm.kvx.storec.v4i64(<4 x i64> %0, <4 x i64>* %1, i32 256, i64 %cond, i32 13, i32 -1)
  ret void
}

define void @storec_vol(i32 %a, i8* %ptr, i64 %cond) {
; CHECK-LABEL: storec_vol:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sxwd $r0 = $r0
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    sw.wgez $r2 ? [$r1] = $r0
; CHECK-NEXT:    ;; # (end cycle 1)
; CHECK-NEXT:    sw.wgez $r2 ? [$r1] = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 2)
entry:
  %conv = sext i32 %a to i64
  %0 = bitcast i8* %ptr to i64*
  tail call void (i64, i64*, i32, i64, i32, i32, ...) @llvm.kvx.storec.vol.i64(i64 %conv, i64* %0, i32 32, i64 %cond, i32 11, i32 -1)
  tail call void (i64, i64*, i32, i64, i32, i32, ...) @llvm.kvx.storec.vol.i64(i64 %conv, i64* %0, i32 32, i64 %cond, i32 11, i32 -1)
  ret void
}

declare void @llvm.kvx.storec.vol.i64(i64, i64*, i32, i64, i32, i32, ...)

define void @storec_novol(i32 %a, i8* %ptr, i64 %cond) {
; CHECK-LABEL: storec_novol:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sxwd $r0 = $r0
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    sw.wgez $r2 ? [$r1] = $r0
; CHECK-NEXT:    ;; # (end cycle 1)
; CHECK-NEXT:    sw.wgez $r2 ? [$r1] = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 2)
entry:
  %conv = sext i32 %a to i64
  %0 = bitcast i8* %ptr to i64*
  tail call void (i64, i64*, i32, i64, i32, i32, ...) @llvm.kvx.storec.i64(i64 %conv, i64* %0, i32 32, i64 %cond, i32 11, i32 -1)
  tail call void (i64, i64*, i32, i64, i32, i32, ...) @llvm.kvx.storec.i64(i64 %conv, i64* %0, i32 32, i64 %cond, i32 11, i32 -1)
  ret void
}

define i32 @storec_r_vol(i32 %a, i8* %ptr, i32* nocapture readonly %load, i64 %cond) {
; CHECK-LABEL: storec_r_vol:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz $r2 = 0[$r2]
; CHECK-NEXT:    sxwd $r4 = $r0
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    iord $r0 = $r2, $r2
; CHECK-NEXT:    sw.wgez $r3 ? [$r1] = $r4
; CHECK-NEXT:    ;; # (end cycle 3)
; CHECK-NEXT:    sw.wgez $r3 ? [$r1] = $r4
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 4)
entry:
  %0 = load i32, i32* %load
  %1 = tail call i64 (...) @llvm.kvx.ready(i32 %0)
  %conv = trunc i64 %1 to i32
  %conv1 = sext i32 %a to i64
  %2 = bitcast i8* %ptr to i64*
  tail call void (i64, i64*, i32, i64, i32, i32, ...) @llvm.kvx.storec.vol.i64(i64 %conv1, i64* %2, i32 32, i64 %cond, i32 11, i32 -1, i32 %conv)
  tail call void (i64, i64*, i32, i64, i32, i32, ...) @llvm.kvx.storec.vol.i64(i64 %conv1, i64* %2, i32 32, i64 %cond, i32 11, i32 -1, i32 %conv)
  ret i32 %conv
}

define i32 @storec_r_novol(i32 %a, i8* %ptr, i32* nocapture readonly %load, i64 %cond) {
; CHECK-LABEL: storec_r_novol:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz $r2 = 0[$r2]
; CHECK-NEXT:    sxwd $r4 = $r0
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    iord $r0 = $r2, $r2
; CHECK-NEXT:    sw.wgez $r3 ? [$r1] = $r4
; CHECK-NEXT:    ;; # (end cycle 3)
; CHECK-NEXT:    sw.wgez $r3 ? [$r1] = $r4
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 4)
entry:
  %0 = load i32, i32* %load
  %1 = tail call i64 (...) @llvm.kvx.ready(i32 %0)
  %conv = trunc i64 %1 to i32
  %conv1 = sext i32 %a to i64
  %2 = bitcast i8* %ptr to i64*
  tail call void (i64, i64*, i32, i64, i32, i32, ...) @llvm.kvx.storec.i64(i64 %conv1, i64* %2, i32 32, i64 %cond, i32 11, i32 -1, i32 %conv)
  tail call void (i64, i64*, i32, i64, i32, i32, ...) @llvm.kvx.storec.i64(i64 %conv1, i64* %2, i32 32, i64 %cond, i32 11, i32 -1, i32 %conv)
  ret i32 %conv
}

define void @ready_then_storec(i32* nocapture readonly %addr0, i32* nocapture readonly %addr1, i32* nocapture readonly %addr2, i32* %to0, i32* %to1, i32* %to2, i64 %cond) {
; CHECK-LABEL: ready_then_storec:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lws $r0 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    lws $r1 = 0[$r1]
; CHECK-NEXT:    ;; # (end cycle 1)
; CHECK-NEXT:    lws $r2 = 0[$r2]
; CHECK-NEXT:    ;; # (end cycle 2)
; CHECK-NEXT:    sw.wgez $r6 ? [$r3] = $r0
; CHECK-NEXT:    iord $r7 = $r0, $r1
; CHECK-NEXT:    iord $r7 = $r2, $r0
; CHECK-NEXT:    ;; # (end cycle 5)
; CHECK-NEXT:    sw.wgez $r6 ? [$r4] = $r1
; CHECK-NEXT:    ;; # (end cycle 6)
; CHECK-NEXT:    sw.wgez $r6 ? [$r5] = $r2
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 7)
entry:
  %0 = load i32, i32* %addr0
  %1 = load i32, i32* %addr1
  %2 = load i32, i32* %addr2
  %3 = tail call i64 (...) @llvm.kvx.ready(i32 %0, i32 %1, i32 %2)
  %conv = trunc i64 %3 to i32
  %conv1 = sext i32 %0 to i64
  %4 = bitcast i32* %to0 to i64*
  tail call void (i64, i64*, i32, i64, i32, i32, ...) @llvm.kvx.storec.i64(i64 %conv1, i64* %4, i32 32, i64 %cond, i32 11, i32 -1, i32 %conv)
  %conv2 = sext i32 %1 to i64
  %5 = bitcast i32* %to1 to i64*
  tail call void (i64, i64*, i32, i64, i32, i32, ...) @llvm.kvx.storec.i64(i64 %conv2, i64* %5, i32 32, i64 %cond, i32 11, i32 -1, i32 %conv)
  %conv3 = sext i32 %2 to i64
  %6 = bitcast i32* %to2 to i64*
  tail call void (i64, i64*, i32, i64, i32, i32, ...) @llvm.kvx.storec.i64(i64 %conv3, i64* %6, i32 32, i64 %cond, i32 11, i32 -1, i32 %conv)
  ret void
}

define void @load_then_storec(i32* nocapture readonly %addr0, i32* nocapture readonly %addr1, i32* nocapture readonly %addr2, i32* nocapture %to0, i32* nocapture %to1, i32* nocapture %to2, i64 %cond) {
; CHECK-LABEL: load_then_storec:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cb.dltz $r6 ? .LBB51_2
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.1: # %if.then
; CHECK-NEXT:    lwz $r2 = 0[$r2]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    lwz $r0 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 1)
; CHECK-NEXT:    lwz $r1 = 0[$r1]
; CHECK-NEXT:    ;; # (end cycle 2)
; CHECK-NEXT:    sw 0[$r3] = $r0
; CHECK-NEXT:    ;; # (end cycle 3)
; CHECK-NEXT:    sw 0[$r4] = $r1
; CHECK-NEXT:    ;; # (end cycle 4)
; CHECK-NEXT:    sw 0[$r5] = $r2
; CHECK-NEXT:    ;; # (end cycle 5)
; CHECK-NEXT:  .LBB51_2: # %if.end
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %cmp = icmp sgt i64 %cond, -1
  br i1 %cmp, label %if.then, label %if.end

if.then:
  %0 = load i32, i32* %addr2
  %1 = load i32, i32* %addr1
  %2 = load i32, i32* %addr0
  store i32 %2, i32* %to0
  store i32 %1, i32* %to1
  store i32 %0, i32* %to2
  br label %if.end

if.end:
  ret void
}

