; RUN: llc -o - %s -O2 | FileCheck %s

target triple = "kvx-kalray-cos"

; CHECK: .globl  foo
; CHECK-NEXT: .p2align        6
; CHECK-NOT: .p2align        7

define i32 @foo(i32 %n, ptr nocapture %p) {
entry:
  %cmp16 = icmp sle i32 %n, 0
  %exitcond.peel = icmp eq i32 %n, 1
  %or.cond = or i1 %cmp16, %exitcond.peel
  br i1 %or.cond, label %for.cond.cleanup, label %for.cond1.preheader

for.cond1.preheader:                              ; preds = %entry, %for.cond1.preheader
  %indvars.iv20 = phi i32 [ %indvars.iv.next21, %for.cond1.preheader ], [ -1, %entry ]
  %indvars.iv = phi i32 [ %indvars.iv.next, %for.cond1.preheader ], [ 0, %entry ]
  %i.017 = phi i32 [ %inc6, %for.cond1.preheader ], [ 1, %entry ]
  %0 = zext i32 %indvars.iv to i33
  %1 = zext i32 %indvars.iv20 to i33
  %2 = mul i33 %0, %1
  %3 = lshr i33 %2, 1
  %4 = trunc i33 %3 to i32
  %p.promoted = load i32, ptr %p, align 4
  %5 = add i32 %p.promoted, %indvars.iv
  %6 = add i32 %5, %4
  store i32 %6, ptr %p, align 4
  %inc6 = add nuw nsw i32 %i.017, 1
  %indvars.iv.next = add nuw nsw i32 %indvars.iv, 1
  %indvars.iv.next21 = add nsw i32 %indvars.iv20, 1
  %exitcond = icmp eq i32 %inc6, %n
  br i1 %exitcond, label %for.cond.cleanup, label %for.cond1.preheader

for.cond.cleanup:                                 ; preds = %entry, %for.cond1.preheader
  ret i32 0
}
