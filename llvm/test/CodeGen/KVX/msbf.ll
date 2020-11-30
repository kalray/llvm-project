; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -O2 | FileCheck %s
target triple = "kvx-kalray-cos"

define i32 @f_msbfwrr(i32 %a, i32 %b, i32 %c){
; CHECK-LABEL: f_msbfwrr:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    msbfw $r0 = $r1, $r2
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %mul = mul nsw i32 %b, %c
  %sub = sub nsw i32 %a, %mul
  ret i32 %sub
}

define i32 @f_msbfwri(i32 %a, i32 %b){
; CHECK-LABEL: f_msbfwri:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    msbfw $r0 = $r1, 11
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %mul = mul nsw i32 %b, 11
  %sub = sub nsw i32 %a, %mul
  ret i32 %sub
}

define i32 @f_msbfwrrr_1(i32 %a, i32 %b){
; CHECK-LABEL: f_msbfwrrr_1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sbfw $r2 = $r0, $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    msbfw $r2 = $r0, $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r0 = $r2
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %sub = sub nsw i32 %b, %a
  %mul = mul nsw i32 %a, %b
  %sub2 = sub nsw i32 %sub, %mul
  ret i32 %sub2
}

define i32 @f_msbfwri_1(i32 %a, i32 %b){
; CHECK-LABEL: f_msbfwri_1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addw $r2 = $r1, -1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    msbfw $r1 = $r2, $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r0 = $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %sub = sub nsw i32 %b, 1
  %mul = mul nsw i32 %sub, %a
  %sub2 = sub nsw i32 %b, %mul
  ret i32 %sub2
}

define i64 @f_msbfd(i64 %a, i64 %b, i64 %c){
; CHECK-LABEL: f_msbfd:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    msbfd $r0 = $r1, $r2
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %mul = mul nsw i64 %b, %c
  %sub = sub nsw i64 %a, %mul
  ret i64 %sub
}
