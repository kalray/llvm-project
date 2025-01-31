; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -verify-machineinstrs -o - %s -O2 | FileCheck %s --check-prefixes=CHECK
; RUN: llc -verify-machineinstrs -mcpu=kv3-2 -o - %s -O2 | FileCheck %s --check-prefixes=CHECK
; RUN: clang -O2 -c -o /dev/null %s
; RUN: clang -O2 -march=kv3-2 -c -o /dev/null %s

target triple = "kvx-kalray-cos"

@g1 = global i32 0, align 4

define void @imm10(i32* nocapture %0, i32 %1) {
; CHECK-LABEL: imm10:
; CHECK:       # %bb.0:
; CHECK-NEXT:    sw 0[$r0] = $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
  store i32 %1, i32* %0, align 4
  ret void
}

define void @imm37(i32* nocapture %0, i32 %1) {
; CHECK-LABEL: imm37:
; CHECK:       # %bb.0:
; CHECK-NEXT:    sw 0x3fffffffc[$r0] = $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
  %3 = getelementptr inbounds i32, i32* %0, i64 4294967295
  store i32 %1, i32* %3, align 4
  ret void
}

define void @imm64(i32* nocapture %0, i32 %1) {
; CHECK-LABEL: imm64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    sw 0x3fffffffffffc[$r0] = $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
  %3 = getelementptr inbounds i32, i32* %0, i64 281474976710655
  store i32 %1, i32* %3, align 4
  ret void
}

define void @reg(i32* nocapture %0, i64 %1, i64 %2) {
; CHECK-LABEL: reg:
; CHECK:       # %bb.0:
; CHECK-NEXT:    sw.xs $r2[$r0] = $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
  %4 = trunc i64 %1 to i32
  %5 = getelementptr inbounds i32, i32* %0, i64 %2
  store i32 %4, i32* %5, align 4
  ret void
}

define <4 x i32> @test0(<4 x i32> %0, i8 %1) #1 {
; CHECK-LABEL: test0:
; CHECK:       # %bb.0:
; CHECK-NEXT:    sxbd $r2 = $r2
; CHECK-NEXT:    make $r3 = 0x300000002
; CHECK-NEXT:    make $r4 = 0xfffffffb
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    insf $r2 = $r2, 63, 32
; CHECK-NEXT:    insf $r4 = $r4, 63, 32
; CHECK-NEXT:    make $r5 = 0x100000000
; CHECK-NEXT:    ;; # (end cycle 1)
; CHECK-NEXT:    compnwp.eq $r2 = $r5, $r2
; CHECK-NEXT:    compnwp.eq $r3 = $r3, $r2
; CHECK-NEXT:    ;; # (end cycle 2)
; CHECK-NEXT:    cmovewp.nez $r2 ? $r0 = $r4
; CHECK-NEXT:    cmovewp.nez $r3 ? $r1 = $r4
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 3)
  %3 = insertelement <4 x i32> %0, i32 -5, i8 %1
  ret <4 x i32> %3
}

define i32 @test1(i32* nocapture %0, i32* nocapture readonly %1, i32 %2) #2 {
; CHECK-LABEL: test1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    make $r0 = 0
; CHECK-NEXT:    sxwd $r2 = $r2
; CHECK-NEXT:    copyd $r3 = $r0
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    lwz.xs $r1 = $r2[$r1]
; CHECK-NEXT:    ;; # (end cycle 1)
; CHECK-NEXT:    sw.xs $r2[$r3] = $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 3)
  %4 = sext i32 %2 to i64
  %5 = getelementptr inbounds i32, i32* %1, i64 %4
  %6 = load i32, i32* %5, align 4
  %7 = getelementptr inbounds i32, i32* %0, i64 %4
  store i32 %6, i32* %7, align 4
  ret i32 0
}

define void @test2(i32 %0, i8* nocapture readnone %1) #2 {
; CHECK-LABEL: test2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    make $r0 = g1
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    lwz $r1 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 1)
; CHECK-NEXT:    cb.weqz $r1 ? .LBB6_2
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.1:
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB6_2:
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
