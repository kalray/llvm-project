; RUN: opt -S -dfa-jump-threading %s | FileCheck %s

; These tests check if selects are unfolded properly for jump threading
; opportunities. There are three different patterns to consider:
; 1) Both operands are constant and the false branch is unfolded by default
; 2) One operand is constant and the other is another select to be unfolded. In
;    this case a single select is sunk to a new block to unfold.
; 3) Both operands are a select, and both should be sunk to new blocks.
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

case1:
  br label %for.inc

case2:
; CHECK: %cmp = icmp
; CHECK-NOT: %sel = select i1 %cmp, i32 1, i32 2
; CHECK-NEXT: br i1 %cmp, label %for.inc
; CHECK: si.unfold.false
  %cmp = icmp slt i32 %count, 50
  %sel = select i1 %cmp, i32 1, i32 2
  br label %for.inc

; CHECK: si.unfold.false:
; CHECK-NEXT: br label %for.inc

for.inc:
; CHECK: for.inc.jt2:
; CHECK: %state.next.jt2 = phi i32
; CHECK: [ 2, %si.unfold.false ]
; CHECK: for.inc.jt1:
; CHECK: %state.next.jt1 = phi i32
; CHECK: [ 1, %case2 ]
  %state.next = phi i32 [ %sel, %case2 ], [ 1, %for.body ], [ 2, %case1 ]
  %inc = add nsw i32 %count, 1
  %cmp.exit = icmp slt i32 %inc, %num
  br i1 %cmp.exit, label %for.body, label %for.end

for.end:
  ret i32 0
}

define i32 @test2(i32 %num) {
entry:
  br label %for.body

for.body:
  %count = phi i32 [ 0, %entry ], [ %inc, %for.inc ]
  %state = phi i32 [ 1, %entry ], [ %state.next, %for.inc ]
  switch i32 %state, label %for.inc [
    i32 1, label %case1
    i32 2, label %case2
  ]

case1:
; CHECK: %cmp.c1 = icmp
; CHECK: %cmp2.c1 = icmp
; CHECK-NOT: select i1
; CHECK-NEXT: br i1 %cmp2.c1
  %cmp.c1 = icmp slt i32 %count, 50
  %cmp2.c1 = icmp slt i32 %count, 100
  %state1.1 = select i1 %cmp.c1, i32 1, i32 2
  %state1.2 = select i1 %cmp2.c1, i32 %state1.1, i32 3
  br label %for.inc

case2:
; CHECK: %cmp.c2 = icmp
; CHECK: %cmp2.c2 = icmp
; CHECK-NOT: select i1
; CHECK-NEXT: br i1 %cmp2.c2
  %cmp.c2 = icmp slt i32 %count, 50
  %cmp2.c2 = icmp sgt i32 %count, 100
  %state2.1 = select i1 %cmp.c2, i32 1, i32 2
  %state2.2 = select i1 %cmp2.c2, i32 3, i32 %state2.1
  br label %for.inc

; CHECK: si.unfold.false:
; CHECK-NEXT: br i1 %cmp.c2
; CHECK: si.unfold.false1:
; CHECK-NEXT: br label %for.inc
; CHECK: si.unfold.true:
; CHECK-NEXT: br i1 %cmp.c1
; CHECK: si.unfold.false2:
; CHECK-NEXT: br label %for.inc

for.inc:
; CHECK: for.inc.jt3:
; CHECK: [ 3, %case1 ], [ 3, %case2 ]
; CHECK: for.inc.jt2:
; CHECK: [ 2, %si.unfold.false1 ], [ 2, %si.unfold.false2 ]
; CHECK: for.inc.jt1:
; CHECK: [ 1, %si.unfold.false ], [ 1, %si.unfold.true ]
  %state.next = phi i32 [ %state1.2, %case1 ], [ %state2.2, %case2 ], [ 1, %for.body ]
  %inc = add nsw i32 %count, 1
  %cmp.exit = icmp slt i32 %inc, %num
  br i1 %cmp.exit, label %for.body, label %for.end

for.end:
  ret i32 0
}

define i32 @test3(i32 %num) {
entry:
  br label %for.body

for.body:
  %count = phi i32 [ 0, %entry ], [ %inc, %for.inc ]
  %state = phi i32 [ 1, %entry ], [ %state.next, %for.inc ]
  switch i32 %state, label %for.inc [
    i32 1, label %case1
    i32 2, label %case2
  ]

case1:
  br label %for.inc

case2:
; CHECK: %cmp.3 = icmp eq i32 %0, 0
; CHECK-NOT: select i1
; CHECK-NEXT: br i1 %cmp.3, label %si.unfold.true, label %si.unfold.false
  %cmp.1 = icmp slt i32 %count, 50
  %cmp.2 = icmp slt i32 %count, 100
  %0 = and i32 %count, 1
  %cmp.3 = icmp eq i32 %0, 0
  %sel.1 = select i1 %cmp.1, i32 1, i32 2
  %sel.2 = select i1 %cmp.2, i32 3, i32 4
  %sel.3 = select i1 %cmp.3, i32 %sel.1, i32 %sel.2
  br label %for.inc

; CHECK: si.unfold.true:
; CHECK-NEXT: br i1 %cmp.1
; CHECK: si.unfold.false:
; CHECK-NEXT: br i1 %cmp.2
; CHECK: si.unfold.false1:
; CHECK-NEXT: br label %for.inc
; CHECK: si.unfold.false2:
; CHECK-NEXT: br label %for.inc

for.inc:
; CHECK: for.inc.jt4:
; CHECK: [ 4, %si.unfold.false1 ]
; CHECK: for.inc.jt3:
; CHECK: [ 3, %si.unfold.false ]
; CHECK: for.inc.jt2:
; CHECK: [ 2, %si.unfold.false2 ]
; CHECK: for.inc.jt1:
; CHECK: [ 1, %si.unfold.true ]
  %state.next = phi i32 [ %sel.3, %case2 ], [ 1, %for.body ], [ 2, %case1 ]
  %inc = add nsw i32 %count, 1
  %cmp.exit = icmp slt i32 %inc, %num
  br i1 %cmp.exit, label %for.body, label %for.end

for.end:
  ret i32 0
}
