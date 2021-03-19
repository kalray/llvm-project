; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -O2 | FileCheck %s
target triple = "kvx-kalray-cos"

define void @foo(){
; CHECK-LABEL: foo:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    get $r16 = $ra
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_def_cfa_offset 32
; CHECK-NEXT:    .cfi_register 67, 16
; CHECK-NEXT:    sd 24[$r12] = $r16
; CHECK-NEXT:    make $r0 = 0xfffffffffffffafb
; CHECK-NEXT:    call bar2
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_offset 67, -8
; CHECK-NEXT:    make $r0 = 0xf9fafb
; CHECK-NEXT:    call bar3
; CHECK-NEXT:    ;;
; CHECK-NEXT:    make $r0 = 0xfffffffff8f9fafb
; CHECK-NEXT:    call bar4
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r16 = 24[$r12]
; CHECK-NEXT:    make $r0 = 0xf4f5f6f7f8f9fafb
; CHECK-NEXT:    ;;
; CHECK-NEXT:    set $ra = $r16
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    goto bar8
; CHECK-NEXT:    ;;
entry:
  %call = tail call i8 @bar2(<2 x i8> <i8 -5, i8 -6>) #2
  %call1 = tail call i8 @bar3(<3 x i8> <i8 -5, i8 -6, i8 -7>) #2
  %call2 = tail call i8 @bar4(<4 x i8> <i8 -5, i8 -6, i8 -7, i8 -8>) #2
  %call3 = tail call i8 @bar8(<8 x i8> <i8 -5, i8 -6, i8 -7, i8 -8, i8 -9, i8 -10, i8 -11, i8 -12>) #2
  ret void
}

declare i8 @bar2(<2 x i8>) #1

declare i8 @bar3(<3 x i8>) #1

declare i8 @bar4(<4 x i8>) #1

declare i8 @bar8(<8 x i8>) #1

