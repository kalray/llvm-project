; RUN: opt < %s -ajt -S | FileCheck %s
; RUN: opt < %s -passes="ajt" -S | FileCheck %s

define void @test(i8* %s, i32* dereferenceable(4) %zeros, i32* dereferenceable(4) %ones) nounwind {
entry:
  store i32 0, i32* %zeros, align 4
  store i32 0, i32* %ones, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %state.0 = phi i32 [ -1, %entry ], [ %state.7, %for.inc ]
  %s.addr.0 = phi i8* [ %s, %entry ], [ %incdec.ptr, %for.inc ]
  %0 = load i8, i8* %s.addr.0, align 1
  %tobool = icmp ne i8 %0, 0
  br i1 %tobool, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  switch i32 %state.0, label %for.inc [
    i32 -1, label %sw.bb
    i32 0, label %sw.bb7
    i32 1, label %sw.bb20
    i32 2, label %sw.bb33
  ]

sw.bb:                                            ; preds = %for.body
  %1 = load i8, i8* %s.addr.0, align 1
  %conv = sext i8 %1 to i32
  %cmp = icmp eq i32 %conv, 48
  br i1 %cmp, label %if.then, label %if.else

if.then:                                          ; preds = %sw.bb
  %2 = load i32, i32* %zeros, align 4
  %inc = add nsw i32 %2, 1
  store i32 %inc, i32* %zeros, align 4
  br label %for.inc

if.else:                                          ; preds = %sw.bb
  %3 = load i8, i8* %s.addr.0, align 1
  %conv1 = sext i8 %3 to i32
  %cmp2 = icmp eq i32 %conv1, 49
  br i1 %cmp2, label %if.then3, label %for.inc

if.then3:                                         ; preds = %if.else
  %4 = load i32, i32* %ones, align 4
  %inc4 = add nsw i32 %4, 1
  store i32 %inc4, i32* %ones, align 4
  br label %for.inc

sw.bb7:                                           ; preds = %for.body
  %5 = load i8, i8* %s.addr.0, align 1
  %conv8 = sext i8 %5 to i32
  %cmp9 = icmp eq i32 %conv8, 48
  br i1 %cmp9, label %if.then10, label %if.else12

if.then10:                                        ; preds = %sw.bb7
  %6 = load i32, i32* %zeros, align 4
  %inc11 = add nsw i32 %6, 1
  store i32 %inc11, i32* %zeros, align 4
  br label %for.inc

if.else12:                                        ; preds = %sw.bb7
  %7 = load i8, i8* %s.addr.0, align 1
  %conv13 = sext i8 %7 to i32
  %cmp14 = icmp eq i32 %conv13, 49
  br i1 %cmp14, label %if.then15, label %for.inc

if.then15:                                        ; preds = %if.else12
  %8 = load i32, i32* %ones, align 4
  %inc16 = add nsw i32 %8, 1
  store i32 %inc16, i32* %ones, align 4
  br label %for.inc

sw.bb20:                                          ; preds = %for.body
  %9 = load i8, i8* %s.addr.0, align 1
  %conv21 = sext i8 %9 to i32
  %cmp22 = icmp eq i32 %conv21, 48
  br i1 %cmp22, label %if.then23, label %if.else25

if.then23:                                        ; preds = %sw.bb20
  %10 = load i32, i32* %zeros, align 4
  %inc24 = add nsw i32 %10, 1
  store i32 %inc24, i32* %zeros, align 4
  br label %for.inc

if.else25:                                        ; preds = %sw.bb20
  %11 = load i8, i8* %s.addr.0, align 1
  %conv26 = sext i8 %11 to i32
  %cmp27 = icmp eq i32 %conv26, 49
  br i1 %cmp27, label %if.then28, label %for.inc

if.then28:                                        ; preds = %if.else25
  %12 = load i32, i32* %ones, align 4
  %inc29 = add nsw i32 %12, 1
  store i32 %inc29, i32* %ones, align 4
  br label %for.inc

sw.bb33:                                          ; preds = %for.body
  store i32 -1, i32* %zeros, align 4
  store i32 -1, i32* %ones, align 4
  br label %for.end

for.inc:                                          ; preds = %for.body, %if.then3, %if.else, %if.then, %if.then15, %if.else12, %if.then10, %if.then28, %if.else25, %if.then23
  %state.7 = phi i32 [ %state.0, %for.body ], [ 0, %if.then ], [ 1, %if.then3 ], [ 2, %if.else ], [ %state.0, %if.then10 ], [ 1, %if.then15 ], [ 2, %if.else12 ], [ 0, %if.then23 ], [ %state.0, %if.then28 ], [ 2, %if.else25 ]
  %incdec.ptr = getelementptr inbounds i8, i8* %s.addr.0, i32 1
  br label %for.cond

for.end:                                          ; preds = %sw.bb33, %for.cond
  ret void

; CHECK: for.cond.c2
; CHECK: for.cond.c4
; CHECK: for.cond.c14

}

