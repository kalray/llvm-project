; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -O2 | FileCheck %s
target triple = "kvx-kalray-cos"

define i64 @clsd(i64 %l){
; CHECK-LABEL: clsd:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    clsd $r0 = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = tail call i64 @llvm.kvx.clsd(i64 %l)
  ret i64 %0
}

declare i64 @llvm.kvx.clsd(i64) #1

define i32 @clsw(i32 %i){
; CHECK-LABEL: clsw:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    clsw $r0 = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = tail call i32 @llvm.kvx.clsw(i32 %i)
  ret i32 %0
}

declare i32 @llvm.kvx.clsw(i32) #1

define void @errop(){
; CHECK-LABEL: errop:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    errop
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  tail call void @llvm.kvx.errop()
  ret void
}

declare void @llvm.kvx.errop() #3

