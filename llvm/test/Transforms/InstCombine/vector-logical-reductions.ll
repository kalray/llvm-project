; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -passes=instcombine -S | FileCheck %s

define i1 @reduction_logical_or(<4 x i1> %x) {
; CHECK-LABEL: @reduction_logical_or(
; CHECK-NEXT:    [[R:%.*]] = call i1 @llvm.vector.reduce.or.v4i1(<4 x i1> [[X:%.*]])
; CHECK-NEXT:    ret i1 [[R]]
;
  %r = call i1 @llvm.vector.reduce.or.v4i1(<4 x i1> %x)
  ret i1 %r
}

define i1 @reduction_logical_and(<4 x i1> %x) {
; CHECK-LABEL: @reduction_logical_and(
; CHECK-NEXT:    [[R:%.*]] = call i1 @llvm.vector.reduce.and.v4i1(<4 x i1> [[X:%.*]])
; CHECK-NEXT:    ret i1 [[R]]
;
  %r = call i1 @llvm.vector.reduce.and.v4i1(<4 x i1> %x)
  ret i1 %r
}

declare i1 @llvm.vector.reduce.or.v4i1(<4 x i1>)
declare i1 @llvm.vector.reduce.and.v4i1(<4 x i1>)
