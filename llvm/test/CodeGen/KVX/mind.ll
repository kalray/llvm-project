; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -O2 | FileCheck %s
target triple = "kvx-kalray-cos"

define i64 @f1(i64 %a, i64 %b){
; CHECK-LABEL: f1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mind $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %cmp = icmp sgt i64 %a, %b
  %b.a = select i1 %cmp, i64 %b, i64 %a
  ret i64 %b.a
}

define i64 @f2(i64 %a, i64 %b){
; CHECK-LABEL: f2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mind $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %cmp = icmp sgt i64 %a, %b
  %cond = select i1 %cmp, i64 %b, i64 %a
  ret i64 %cond
}

define i64 @f3(i64 %a, i64 %b){
; CHECK-LABEL: f3:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    minud $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %cmp = icmp ugt i64 %a, %b
  %b.a = select i1 %cmp, i64 %b, i64 %a
  ret i64 %b.a
}

define i64 @f4(i64 %a, i64 %b){
; CHECK-LABEL: f4:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    minud $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %cmp = icmp ugt i64 %a, %b
  %cond = select i1 %cmp, i64 %b, i64 %a
  ret i64 %cond
}

define i64 @f5(i64 %a){
; CHECK-LABEL: f5:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mind $r0 = $r0, 10
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = icmp slt i64 %a, 10
  %cond = select i1 %0, i64 %a, i64 10
  ret i64 %cond
}

