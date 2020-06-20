; RUN: llc -O1 < %s | FileCheck %s

@z = common dso_local global [5 x i32] zeroinitializer, align 4

; Function Attrs: nounwind
define dso_local i32 @f(i32 %a1, i32 %a2, i32 %a3, i32 %a4, i32 %a5, i32 %a6, i32 %a7, i32 %a8, i32 %a9, i32 %a10, i32 %a11, i32 %a12, i32 %a13, i32 %a14, i32 %a15, i32 %a16) local_unnamed_addr {
entry:
  %0 = zext i32 %a16 to i64
  %vla = alloca i32, i64 %0, align 4
  %1 = load volatile i32, i32* getelementptr inbounds ([5 x i32], [5 x i32]* @z, i64 0, i64 0), align 4
  %add = add nsw i32 %a2, %a1
  %add1 = add nsw i32 %add, %a3
  %add2 = add nsw i32 %add1, %a4
  %add3 = add nsw i32 %add2, %a5
  %add4 = add nsw i32 %add3, %a6
  %add5 = add nsw i32 %add4, %a7
  %add6 = add nsw i32 %add5, %a8
  %add7 = add nsw i32 %add6, %a9
  %add8 = add nsw i32 %add7, %a10
  %add9 = add nsw i32 %add8, %a11
  %add10 = add nsw i32 %add9, %a12
  %add11 = add nsw i32 %add10, %a13
  %add12 = add nsw i32 %add11, %a14
  %add13 = add nsw i32 %add12, %a15
  %add14 = add nsw i32 %add13, %a16
  %add15 = add nsw i32 %add14, %1
  %cmp54 = icmp sgt i32 %a16, 0
  br i1 %cmp54, label %for.body.preheader, label %for.cond.cleanup

for.body.preheader:                               ; preds = %entry
  %wide.trip.count = zext i32 %a16 to i64
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.body, %entry
  %arrayidx16 = getelementptr inbounds i32, i32* %vla, i64 10
  %2 = load volatile i32, i32* %arrayidx16, align 4
  %call = tail call i32 @h(i32 %a1, i32 %a2, i32 %a3, i32 %a4, i32 %a5, i32 %a6, i32 %a7, i32 %a8, i32 %a9, i32 %a10, i32 %a11, i32 %a12, i32 %a13, i32 %a14, i32 %a15, i32 %a16, i32 %2, i32 %add15, i32 %1)
  %add17 = add nsw i32 %call, %add15
  %call18 = tail call i32 @g(i32 %a1, i32 %a2, i32 %a3, i32 %a6, i32 %a7, i32 %a8, i32 %a11, i32 %add17, i32 %1)
  ret i32 %call18

for.body:                                         ; preds = %for.body, %for.body.preheader
  %indvars.iv = phi i64 [ 0, %for.body.preheader ], [ %indvars.iv.next, %for.body ]
  %arrayidx = getelementptr inbounds i32, i32* %vla, i64 %indvars.iv
  %3 = trunc i64 %indvars.iv to i32
  store volatile i32 %3, i32* %arrayidx, align 4
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv.next, %wide.trip.count
  br i1 %exitcond, label %for.cond.cleanup, label %for.body

; CHECK: call h
; CHECK: goto g
}

declare dso_local i32 @h(i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32) local_unnamed_addr

declare dso_local i32 @g(i32, i32, i32, i32, i32, i32, i32, i32, i32) local_unnamed_addr
