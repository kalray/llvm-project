; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc --disable-kvx-hwloops=false < %s -O2 | FileCheck %s
target triple = "kvx-kalray-cos"

@x = common global i32* null, align 8

define i32* @f(i32 %s, i32 %c){
; CHECK-LABEL: f:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    make $r0 = x
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r0 = 0[$r0]
; CHECK-NEXT:    make $r1 = -1004
; CHECK-NEXT:    ;;
; CHECK-NEXT:    make $r1 = 0xfffffc18
; CHECK-NEXT:    make $r2 = 0xfffffffffffff060
; CHECK-NEXT:    make $r3 = 126
; CHECK-NEXT:    ;;
; CHECK-NEXT:    loopdo $r3, .LBB0_1
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB0_2: # %for.body
; CHECK-NEXT:    # =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    sw $r2[$r0] = $r1
; CHECK-NEXT:    addw $r1 = $r1, 4
; CHECK-NEXT:    addd $r2 = $r2, 16
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB0_1: # Block address taken
; CHECK-NEXT:    # %for.cond.cleanup
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = load i32*, i32** @x, align 8
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.body
  ret i32* %0

for.body:                                         ; preds = %entry, %for.body
  %indvars.iv = phi i64 [ -1000, %entry ], [ %indvars.iv.next, %for.body ]
  %arrayidx = getelementptr inbounds i32, i32* %0, i64 %indvars.iv
  %1 = trunc i64 %indvars.iv to i32
  store i32 %1, i32* %arrayidx, align 4
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 4
  %cmp = icmp slt i64 %indvars.iv, -503
  br i1 %cmp, label %for.body, label %for.cond.cleanup
}

define i32* @g(i32 %s, i32 %c){
; CHECK-LABEL: g:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    make $r0 = x
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r0 = 0[$r0]
; CHECK-NEXT:    make $r1 = -1004
; CHECK-NEXT:    ;;
; CHECK-NEXT:    make $r1 = 0xfffffc18
; CHECK-NEXT:    make $r2 = 0xfffffffffffff060
; CHECK-NEXT:    make $r3 = 125
; CHECK-NEXT:    ;;
; CHECK-NEXT:    loopdo $r3, .LBB1_1
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB1_2: # %for.body
; CHECK-NEXT:    # =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    sw $r2[$r0] = $r1
; CHECK-NEXT:    addw $r1 = $r1, 4
; CHECK-NEXT:    addd $r2 = $r2, 16
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB1_1: # Block address taken
; CHECK-NEXT:    # %for.cond.cleanup
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = load i32*, i32** @x, align 8
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.body
  ret i32* %0

for.body:                                         ; preds = %entry, %for.body
  %indvars.iv = phi i64 [ -1000, %entry ], [ %indvars.iv.next, %for.body ]
  %arrayidx = getelementptr inbounds i32, i32* %0, i64 %indvars.iv
  %1 = trunc i64 %indvars.iv to i32
  store i32 %1, i32* %arrayidx, align 4
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 4
  %cmp = icmp slt i64 %indvars.iv, -504
  br i1 %cmp, label %for.body, label %for.cond.cleanup
}

