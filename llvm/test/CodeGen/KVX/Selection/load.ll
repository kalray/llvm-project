; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -verify-machineinstrs -o - %s -O2 | FileCheck %s --check-prefixes=CHECK
; RUN: llc -verify-machineinstrs -mcpu=kv3-2 -o - %s -O2 | FileCheck %s --check-prefixes=CHECK
; RUN: clang -O2 -c -o /dev/null %s
; RUN: clang -O2 -march=kv3-2 -c -o /dev/null %s

target triple = "kvx-kalray-cos"

@g1 = global i32 0, align 4

define i32 @imm10(i32* nocapture readonly %0) {
; CHECK-LABEL: imm10:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lwz $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
  %2 = load i32, i32* %0, align 4
  ret i32 %2
}

define i32 @imm37(i32* nocapture readonly %0) {
; CHECK-LABEL: imm37:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lwz $r0 = 0x3fffffffc[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
  %2 = getelementptr inbounds i32, i32* %0, i64 4294967295
  %3 = load i32, i32* %2, align 4
  ret i32 %3
}

define i32 @imm64(i32* nocapture readonly %0) {
; CHECK-LABEL: imm64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lwz $r0 = 0x3fffffffffffc[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
  %2 = getelementptr inbounds i32, i32* %0, i64 281474976710655
  %3 = load i32, i32* %2, align 4
  ret i32 %3
}

define i32 @reg(i32* nocapture readonly %0, i64 %1) {
; CHECK-LABEL: reg:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lwz.xs $r0 = $r1[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
  %3 = getelementptr inbounds i32, i32* %0, i64 %1
  %4 = load i32, i32* %3, align 4
  ret i32 %4
}

define i32 @test0(i32 %0, i32* nocapture readonly %1) {
; CHECK-LABEL: test0:
; CHECK:       # %bb.0:
; CHECK-NEXT:    sxwd $r0 = $r0
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    lwz.xs $r0 = $r0[$r1]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 1)
  %3 = sext i32 %0 to i64
  %4 = getelementptr inbounds i32, i32* %1, i64 %3
  %5 = load i32, i32* %4, align 4
  ret i32 %5
}

define i32 @test1(i32 %0, i32* nocapture readonly %1) {
; CHECK-LABEL: test1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    sxwd $r0 = $r0
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    lwz.xs $r0 = $r0[$r1]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 1)
  %3 = sext i32 %0 to i64
  %4 = getelementptr inbounds i32, i32* %1, i64 %3
  %5 = load i32, i32* %4, align 4
  ret i32 %5
}

define i64 @test2(i32 %0, i32* nocapture readonly %1) {
; CHECK-LABEL: test2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    sxwd $r0 = $r0
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    lwz.xs $r0 = $r0[$r1]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 1)
  %3 = sext i32 %0 to i64
  %4 = getelementptr inbounds i32, i32* %1, i64 %3
  %5 = load i32, i32* %4, align 4
  %6 = zext i32 %5 to i64
  ret i64 %6
}

define float @test3(i32 %0, float* nocapture readonly %1) {
; CHECK-LABEL: test3:
; CHECK:       # %bb.0:
; CHECK-NEXT:    sxwd $r0 = $r0
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    lwz.xs $r0 = $r0[$r1]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 1)
  %3 = sext i32 %0 to i64
  %4 = getelementptr inbounds float, float* %1, i64 %3
  %5 = load float, float* %4, align 4
  ret float %5
}

define i32 @test4(i32 %0, i32* nocapture readonly %1) {
; CHECK-LABEL: test4:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lwz.weqz $r0 ? $r0 = [$r1]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
  %3 = icmp eq i32 %0, 0
  br i1 %3, label %4, label %6

4:
  %5 = load i32, i32* %1, align 4
  br label %6

6:
  %7 = phi i32 [ %5, %4 ], [ %0, %2 ]
  ret i32 %7
}

define void @test5(i32 %0, i8* nocapture readnone %1) {
; CHECK-LABEL: test5:
; CHECK:       # %bb.0:
; CHECK-NEXT:    make $r0 = g1
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    lwz $r1 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 1)
; CHECK-NEXT:    cb.weqz $r1 ? .LBB9_2
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.1:
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB9_2:
; CHECK-NEXT:    make $r1 = 1
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    sw 0[$r0] = $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 1)
  %3 = load i32, i32* @g1, align 4
  %4 = icmp eq i32 %3, 0
  br i1 %4, label %5, label %6

5:
  store i32 1, i32* @g1, align 4
  br label %6

6:
  ret void
}

define i32 @test6(i64 %0, i64 %1, i32** nocapture readonly %2) {
; CHECK-LABEL: test6:
; CHECK:       # %bb.0:
; CHECK-NEXT:    ld.xs $r0 = $r0[$r2]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    lwz.xs $r0 = $r1[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 3)
  %4 = getelementptr inbounds i32*, i32** %2, i64 %0
  %5 = load i32*, i32** %4, align 8
  %6 = getelementptr inbounds i32, i32* %5, i64 %1
  %7 = load i32, i32* %6, align 4
  ret i32 %7
}

define i32 @test7(i32 %0, i32* nocapture readonly %1) {
; CHECK-LABEL: test7:
; CHECK:       # %bb.0:
; CHECK-NEXT:    sllw $r0 = $r0, 1
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    sxwd $r0 = $r0
; CHECK-NEXT:    ;; # (end cycle 1)
; CHECK-NEXT:    lwz.xs $r0 = $r0[$r1]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 2)
  %3 = shl i32 %0, 1
  %4 = sext i32 %3 to i64
  %5 = getelementptr inbounds i32, i32* %1, i64 %4
  %6 = load i32, i32* %5, align 4
  ret i32 %6
}

define i32 @test8(i64 %0, i32* nocapture readonly %1) {
; CHECK-LABEL: test8:
; CHECK:       # %bb.0:
; CHECK-NEXT:    slld $r0 = $r0, 3
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    lwz $r0 = $r0[$r1]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 1)
  %3 = shl i64 %0, 1
  %4 = getelementptr inbounds i32, i32* %1, i64 %3
  %5 = load i32, i32* %4, align 4
  ret i32 %5
}
