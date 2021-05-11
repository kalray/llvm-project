; RUN: opt < %s -ajt -S | FileCheck %s
; RUN: opt < %s -passes="ajt" -S | FileCheck %s

define void @test(i8* nocapture readonly %s, i32* nocapture dereferenceable(4) %zeros, i32* nocapture dereferenceable(4) %ones) nounwind {
entry:
  store i32 0, i32* %zeros, align 4
  store i32 0, i32* %ones, align 4
  %0 = load i8, i8* %s, align 1
  %tobool16 = icmp eq i8 %0, 0
  br i1 %tobool16, label %for.end, label %for.body

for.body:                                         ; preds = %entry, %for.inc
  %1 = phi i8 [ %8, %for.inc ], [ %0, %entry ]
  %state.018 = phi i32 [ %state.1, %for.inc ], [ -1, %entry ]
  %s.addr.017 = phi i8* [ %incdec.ptr, %for.inc ], [ %s, %entry ]
  switch i32 %state.018, label %for.inc [
    i32 -1, label %sw.bb
    i32 0, label %sw.bb7
    i32 1, label %sw.bb20
    i32 2, label %sw.bb33
  ]

sw.bb:                                            ; preds = %for.body
  switch i8 %1, label %for.inc [
    i8 48, label %if.then
    i8 49, label %if.then3
  ]

if.then:                                          ; preds = %sw.bb
  %2 = load i32, i32* %zeros, align 4
  %inc = add nsw i32 %2, 1
  store i32 %inc, i32* %zeros, align 4
  br label %for.inc

if.then3:                                         ; preds = %sw.bb
  %3 = load i32, i32* %ones, align 4
  %inc4 = add nsw i32 %3, 1
  store i32 %inc4, i32* %ones, align 4
  br label %for.inc

sw.bb7:                                           ; preds = %for.body
  switch i8 %1, label %for.inc [
    i8 48, label %if.then10
    i8 49, label %if.then15
  ]

if.then10:                                        ; preds = %sw.bb7
  %4 = load i32, i32* %zeros, align 4
  %inc11 = add nsw i32 %4, 1
  store i32 %inc11, i32* %zeros, align 4
  br label %for.inc

if.then15:                                        ; preds = %sw.bb7
  %5 = load i32, i32* %ones, align 4
  %inc16 = add nsw i32 %5, 1
  store i32 %inc16, i32* %ones, align 4
  br label %for.inc

sw.bb20:                                          ; preds = %for.body
  switch i8 %1, label %for.inc [
    i8 48, label %if.then23
    i8 49, label %if.then28
  ]

if.then23:                                        ; preds = %sw.bb20
  %6 = load i32, i32* %zeros, align 4
  %inc24 = add nsw i32 %6, 1
  store i32 %inc24, i32* %zeros, align 4
  br label %for.inc

if.then28:                                        ; preds = %sw.bb20
  %7 = load i32, i32* %ones, align 4
  %inc29 = add nsw i32 %7, 1
  store i32 %inc29, i32* %ones, align 4
  br label %for.inc

sw.bb33:                                          ; preds = %for.body
  store i32 -1, i32* %zeros, align 4
  store i32 -1, i32* %ones, align 4
  br label %for.end

for.inc:                                          ; preds = %sw.bb20, %sw.bb7, %sw.bb, %for.body, %if.then3, %if.then, %if.then15, %if.then10, %if.then28, %if.then23
  %state.1 = phi i32 [ %state.018, %for.body ], [ 0, %if.then23 ], [ 1, %if.then28 ], [ 0, %if.then10 ], [ 1, %if.then15 ], [ 0, %if.then ], [ 1, %if.then3 ], [ 2, %sw.bb ], [ 2, %sw.bb7 ], [ 2, %sw.bb20 ]
  %incdec.ptr = getelementptr inbounds i8, i8* %s.addr.017, i64 1
  %8 = load i8, i8* %incdec.ptr, align 1
  %tobool = icmp eq i8 %8, 0
  br i1 %tobool, label %for.end, label %for.body

for.end:                                          ; preds = %for.inc, %entry, %sw.bb33
  ret void
; CHECK: for.inc.c1:
; CHECK: for.inc.c2:
; CHECK: for.inc.c3:
; CHECK: for.inc.c9:

}

