; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -slp-vectorizer -S %s | FileCheck %s

target datalayout = "e-m:e-p:32:32-p270:32:32-p271:32:32-p272:64:64-f64:32:64-f80:32-n8:16:32-S128"
target triple = "i386-unknown-linux-gnu"

; Make sure we do not crash while computing the cost for @test.
define i1 @test(float* %p1, float* %p2, i8* %p3, i1 %c) #0 {
; CHECK-LABEL: @test(
; CHECK-NEXT:    [[SCEVGEP21:%.*]] = getelementptr float, float* [[P1:%.*]], i32 0
; CHECK-NEXT:    [[L0:%.*]] = icmp ult float* [[P2:%.*]], [[SCEVGEP21]]
; CHECK-NEXT:    [[UMIN:%.*]] = select i1 [[L0]], float* [[P2]], float* [[SCEVGEP21]]
; CHECK-NEXT:    [[UMIN22:%.*]] = bitcast float* [[UMIN]] to i8*
; CHECK-NEXT:    [[SCEVGEP31:%.*]] = getelementptr float, float* [[P1]], i32 1
; CHECK-NEXT:    [[L1:%.*]] = icmp ult float* [[SCEVGEP31]], [[P2]]
; CHECK-NEXT:    [[UMIN33:%.*]] = select i1 [[L1]], float* [[SCEVGEP31]], float* [[P2]]
; CHECK-NEXT:    [[UMIN3334:%.*]] = bitcast float* [[UMIN33]] to i8*
; CHECK-NEXT:    [[BOUND0:%.*]] = icmp ugt i8* [[P3:%.*]], [[UMIN22]]
; CHECK-NEXT:    [[FOUND_CONFLICT:%.*]] = and i1 [[BOUND0]], [[C:%.*]]
; CHECK-NEXT:    [[BOUND042:%.*]] = icmp ugt i8* [[P3]], [[UMIN3334]]
; CHECK-NEXT:    [[FOUND_CONFLICT44:%.*]] = and i1 [[BOUND042]], [[C]]
; CHECK-NEXT:    [[OP_RDX:%.*]] = or i1 [[FOUND_CONFLICT]], [[FOUND_CONFLICT44]]
; CHECK-NEXT:    [[OP_RDX1:%.*]] = or i1 [[C]], [[OP_RDX]]
; CHECK-NEXT:    ret i1 [[OP_RDX1]]
;
  %scevgep21 = getelementptr float, float* %p1, i32 0
  %l0 = icmp ult float* %p2, %scevgep21
  %umin = select i1 %l0, float* %p2, float* %scevgep21
  %umin22 = bitcast float* %umin to i8*
  %scevgep31 = getelementptr float, float* %p1, i32 1
  %l1 = icmp ult float* %scevgep31, %p2
  %umin33 = select i1 %l1, float* %scevgep31, float* %p2
  %umin3334 = bitcast float* %umin33 to i8*
  %bound0 = icmp ugt i8* %p3, %umin22
  %found.conflict = and i1 %bound0, %c
  %conflict.rdx = or i1 %found.conflict, %c
  %bound042 = icmp ugt i8* %p3, %umin3334
  %found.conflict44 = and i1 %bound042, %c
  %conflict.rdx45 = or i1 %conflict.rdx, %found.conflict44
  %conflict.rdx49 = or i1 %conflict.rdx45, %c
  ret i1 %conflict.rdx49
}

attributes #0 = { "target-cpu"="pentium-m" }
