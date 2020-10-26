; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -disable-kvx-hwloops=false < %s -O2 | FileCheck %s
target triple = "kvx-kalray-cos"

; The test ensures no regressions after T12847 bugfix:
;   from llvm-test-suite/SingleSource/UnitTests/2008-04-20-LoopBug2.c

define void @foo(i32 %i, i32* nocapture %p){
; CHECK-LABEL: foo:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sxwd $r2 = $r0
; CHECK-NEXT:    addd $r0 = $r1, 12
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sbfd $r1 = $r2, 3
; CHECK-NEXT:    make $r2 = 3
; CHECK-NEXT:    ;;
; CHECK-NEXT:    cb.dlez $r1 ? .LBB0_1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    loopdo $r1, .LBB0_2
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB0_1: # %do.body
; CHECK-NEXT:    # =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    lwz $r1 = -4[$r0]
; CHECK-NEXT:    addd $r2 = $r0, -4
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw 0[$r0] = $r1
; CHECK-NEXT:    copyd $r0 = $r2
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB0_2: # Block address taken
; CHECK-NEXT:    # %do.end
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = sext i32 %i to i64
  br label %do.body

do.body:                                          ; preds = %do.body, %entry
  %indvars.iv = phi i64 [ %indvars.iv.next, %do.body ], [ 3, %entry ]
  %indvars.iv.next = add nsw i64 %indvars.iv, -1
  %arrayidx = getelementptr inbounds i32, i32* %p, i64 %indvars.iv.next
  %1 = load i32, i32* %arrayidx, align 4
  %arrayidx2 = getelementptr inbounds i32, i32* %p, i64 %indvars.iv
  store i32 %1, i32* %arrayidx2, align 4
  %cmp = icmp sgt i64 %indvars.iv.next, %0
  br i1 %cmp, label %do.body, label %do.end

do.end:                                           ; preds = %do.body
  ret void
}

