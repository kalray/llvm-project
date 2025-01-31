; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -o - %s -O2 | FileCheck %s --check-prefixes=CHECK
; RUN: llc -mcpu=kv3-2 -o - %s -O2 | FileCheck %s --check-prefixes=CHECK
; RUN: clang -O2 -c -o /dev/null %s
; RUN: clang -O2 -march=kv3-2 -c -o /dev/null %s

target triple = "kvx-kalray-cos"

@a = common global i8 0, align 1

define void @test5(i8 %b, i8 %c){
; CHECK-LABEL: test5:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sllw $r0 = $r0, $r1
; CHECK-NEXT:    make $r1 = a
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    sb 0[$r1] = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 1)
entry:
  %conv = zext i8 %b to i32
  %conv1 = zext i8 %c to i32
  %shl = shl i32 %conv, %conv1
  %conv2 = trunc i32 %shl to i8
  store i8 %conv2, i8* @a, align 1
  ret void
}

define void @test5b(i8 %b, i8 %c){
; CHECK-LABEL: test5b:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    zxbd $r0 = $r0
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    srlw $r0 = $r0, $r1
; CHECK-NEXT:    make $r1 = a
; CHECK-NEXT:    ;; # (end cycle 1)
; CHECK-NEXT:    sb 0[$r1] = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 2)
entry:
  %conv = zext i8 %b to i32
  %conv1 = zext i8 %c to i32
  %shr = lshr i32 %conv, %conv1
  %conv2 = trunc i32 %shr to i8
  store i8 %conv2, i8* @a, align 1
  ret void
}

