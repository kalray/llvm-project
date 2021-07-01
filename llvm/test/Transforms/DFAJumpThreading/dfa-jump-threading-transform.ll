; RUN: opt -S -dfa-jump-threading %s | FileCheck %s

; These tests check that the DFA jump threading transformation is applied
; properly to two CFGs. It checks that blocks are cloned, branches are updated,
; and SSA form is restored.
define i32 @test1(i32 %num) {
entry:
  br label %for.body

for.body:
  %count = phi i32 [ 0, %entry ], [ %inc, %for.inc ]
  %state = phi i32 [ 1, %entry ], [ %state.next, %for.inc ]
  switch i32 %state, label %for.inc [
    i32 1, label %case1
    i32 2, label %case2
  ]

; CHECK: for.body.jt2:
; CHECK-NEXT: %count.jt2
; CHECK-NEXT: %state.jt2
; CHECK-NEXT: br label %case2

; CHECK: for.body.jt1:
; CHECK-NEXT: %count.jt1
; CHECK-NEXT: %state.jt1
; CHECK-NEXT: br label %case1

case1:
  br label %for.inc

; CHECK: case1:
; CHECK-NEXT: %count2 = phi i32 [ %count.jt1, %for.body.jt1 ], [ %count, %for.body ]

case2:
  %cmp = icmp eq i32 %count, 50
  %sel = select i1 %cmp, i32 1, i32 2
  br label %for.inc

; CHECK: case2:
; CHECK-NEXT: %count1 = phi i32 [ %count.jt2, %for.body.jt2 ], [ %count, %for.body ]
; CHECK: br i1 %cmp, label %for.inc.jt1, label %si.unfold.false

; CHECK: si.unfold.false:
; CHECK-NEXT: br label %for.inc.jt2

for.inc:
  %state.next = phi i32 [ %sel, %case2 ], [ 1, %for.body ], [ 2, %case1 ]
  %inc = add nsw i32 %count, 1
  %cmp.exit = icmp slt i32 %inc, %num
  br i1 %cmp.exit, label %for.body, label %for.end

; CHECK: for.inc.jt2:
; CHECK-NEXT: %count4 = phi i32 [ %count1, %si.unfold.false ], [ %count2, %case1 ]
; CHECK: br i1 %cmp.exit.jt2, label %for.body.jt2, label %for.end

; CHECK: for.inc.jt1:
; CHECK-NEXT: %count3 = phi i32 [ %count1, %case2 ], [ %count, %for.body ]
; CHECK: br i1 %cmp.exit.jt1, label %for.body.jt1, label %for.end

for.end:
  ret i32 0
}


define i32 @test2(i32 %init) {
entry:
  %cmp = icmp eq i32 %init, 0
  %sel = select i1 %cmp, i32 0, i32 2
  br label %loop.1

; CHECK: si.unfold.false:
; CHECK-NEXT: br label %loop.1
; CHECK: si.unfold.false.jt2:
; CHECK-NEXT: br label %loop.1.jt2
; CHECK: si.unfold.false.jt4:
; CHECK-NEXT: br label %loop.1.jt4
; CHECK: si.unfold.false1:
; CHECK-NEXT: br label %loop.1

loop.1:
  %state.1 = phi i32 [ %sel, %entry ], [ %state.1.be2, %loop.1.backedge ]
  br label %loop.2

; CHECK: loop.1.jt2:
; CHECK :br label %loop.2.jt2
; CHECK: loop.1.jt4:
; CHECK: br label %loop.2.jt4
; CHECK: loop.1.jt1:
; CHECK: br label %loop.2.jt1

loop.2:
  %state.2 = phi i32 [ %state.1, %loop.1 ], [ %state.2.be, %loop.2.backedge ]
  br label %loop.3

; CHECK: loop.2.jt2:
; CHECK: br label %loop.3.jt2
; CHECK: loop.2.jt3:
; CHECK: br label %loop.3.jt3
; CHECK: loop.2.jt0:
; CHECK: br label %loop.3.jt0
; CHECK: loop.2.jt4:
; CHECK: br label %loop.3.jt4
; CHECK: loop.2.jt1:
; CHECK: br label %loop.3.jt1

loop.3:
  %state = phi i32 [ %state.2, %loop.2 ], [ 3, %case2 ]
  switch i32 %state, label %infloop.i [
    i32 2, label %case2
    i32 3, label %case3
    i32 4, label %case4
    i32 0, label %case0
    i32 1, label %case1
  ]

; CHECK: loop.3.jt2:
; CHECK: br label %case2
; CHECK: loop.3.jt0:
; CHECK: br label %case0
; CHECK: loop.3.jt4:
; CHECK: br label %case4
; CHECK: loop.3.jt1:
; CHECK: br label %case1
; CHECK: loop.3.jt3:
; CHECK: br label %case3

case2:
  br i1 %cmp, label %loop.3, label %loop.1.backedge

; CHECK: case2:
; CHECK-NEXT: br i1 %cmp, label %loop.3.jt3, label %loop.1.backedge.jt4

case3:
  br i1 %cmp, label %loop.2.backedge, label %case4

; CHECK: case3:
; CHECK-NEXT: br i1 %cmp, label %loop.2.backedge.jt0, label %case4

case4:
  br i1 %cmp, label %loop.2.backedge, label %loop.1.backedge

; CHECK: case4:
; CHECK-NEXT: br i1 %cmp, label %loop.2.backedge.jt3, label %loop.1.backedge.jt2

loop.1.backedge:
  %state.1.be = phi i32 [ 2, %case4 ], [ 4, %case2 ]
  %state.1.be2 = select i1 %cmp, i32 1, i32 %state.1.be
  br label %loop.1

; CHECK: loop.1.backedge.jt2:
; CHECK: br i1 %cmp, label %loop.1.jt1, label %si.unfold.false.jt2
; CHECK: loop.1.backedge.jt4:
; CHECK: br i1 %cmp, label %loop.1.jt1, label %si.unfold.false.jt4

loop.2.backedge:
  %state.2.be = phi i32 [ 3, %case4 ], [ 0, %case3 ]
  br label %loop.2

; CHECK: loop.2.backedge.jt3:
; CHECK: br label %loop.2.jt3
; CHECK: loop.2.backedge.jt0:
; CHECK: br label %loop.2.jt0

case0:
  br label %exit

case1:
  br label %exit

infloop.i:
  br label %infloop.i

exit:
  ret i32 0
}
