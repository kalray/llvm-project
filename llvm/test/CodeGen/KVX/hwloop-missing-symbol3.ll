; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -disable-kvx-hwloops=false -O2 -o - %s | FileCheck %s
target triple = "kvx-kalray-cos"

@a = common global i32 0, align 4
@b = common global i32* null, align 8
@e = common global i32* null, align 8
@c = common global i32* null, align 8

define i32 @f()  {
; CHECK-LABEL: f:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    make $r0 = a
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lwz $r1 = 0[$r0]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    compw.lt $r0 = $r1, 3
; CHECK-NEXT:    ;;
; CHECK-NEXT:    cb.odd $r0 ? .LBB0_8
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.1: # %for.body.lr.ph
; CHECK-NEXT:    make $r0 = b
; CHECK-NEXT:    zxwd $r2 = $r1
; CHECK-NEXT:    compw.eq $r3 = $r1, 3
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r0 = 0[$r0]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw.xs $r2[$r0] = $r1
; CHECK-NEXT:    cb.odd $r3 ? .LBB0_8
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.2: # %for.body.for.body_crit_edge.preheader
; CHECK-NEXT:    minud $r1 = $r2, 4
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sbfd $r1 = $r1, $r2
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addd $r3 = $r1, 1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    andd $r4 = $r3, 7
; CHECK-NEXT:    ;;
; CHECK-NEXT:    cb.deqz $r4 ? .LBB0_3
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.4: # %for.body.for.body_crit_edge.prol
; CHECK-NEXT:    make $r5 = a
; CHECK-NEXT:    addd $r3 = $r2, -1
; CHECK-NEXT:    compd.ne $r7 = $r4, 1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lwz $r6 = 0[$r5]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw.xs $r3[$r0] = $r6
; CHECK-NEXT:    cb.even $r7 ? .LBB0_5
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.9: # %for.body.for.body_crit_edge.prol.1
; CHECK-NEXT:    lwz $r5 = 0[$r5]
; CHECK-NEXT:    addd $r3 = $r2, -2
; CHECK-NEXT:    compd.eq $r6 = $r4, 2
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw.xs $r3[$r0] = $r5
; CHECK-NEXT:    cb.odd $r6 ? .LBB0_5
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.10: # %for.body.for.body_crit_edge.prol.2
; CHECK-NEXT:    make $r5 = a
; CHECK-NEXT:    addd $r3 = $r2, -3
; CHECK-NEXT:    compd.eq $r7 = $r4, 3
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lwz $r6 = 0[$r5]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw.xs $r3[$r0] = $r6
; CHECK-NEXT:    cb.odd $r7 ? .LBB0_5
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.11: # %for.body.for.body_crit_edge.prol.3
; CHECK-NEXT:    lwz $r5 = 0[$r5]
; CHECK-NEXT:    addd $r3 = $r2, -4
; CHECK-NEXT:    compd.eq $r6 = $r4, 4
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw.xs $r3[$r0] = $r5
; CHECK-NEXT:    cb.odd $r6 ? .LBB0_5
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.12: # %for.body.for.body_crit_edge.prol.4
; CHECK-NEXT:    make $r5 = a
; CHECK-NEXT:    addd $r3 = $r2, -5
; CHECK-NEXT:    compd.eq $r7 = $r4, 5
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lwz $r6 = 0[$r5]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw.xs $r3[$r0] = $r6
; CHECK-NEXT:    cb.odd $r7 ? .LBB0_5
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.13: # %for.body.for.body_crit_edge.prol.5
; CHECK-NEXT:    lwz $r5 = 0[$r5]
; CHECK-NEXT:    addd $r3 = $r2, -6
; CHECK-NEXT:    compd.eq $r4 = $r4, 6
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw.xs $r3[$r0] = $r5
; CHECK-NEXT:    cb.odd $r4 ? .LBB0_5
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.14: # %for.body.for.body_crit_edge.prol.6
; CHECK-NEXT:    make $r3 = a
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lwz $r4 = 0[$r3]
; CHECK-NEXT:    addd $r3 = $r2, -7
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw.xs $r3[$r0] = $r4
; CHECK-NEXT:    goto .LBB0_5
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB0_3:
; CHECK-NEXT:    copyd $r3 = $r2
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB0_5: # %for.body.for.body_crit_edge.prol.loopexit
; CHECK-NEXT:    compd.ltu $r1 = $r1, 7
; CHECK-NEXT:    ;;
; CHECK-NEXT:    cb.odd $r1 ? .LBB0_8
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.6: # %for.body.for.body_crit_edge.preheader1
; CHECK-NEXT:    mind $r1 = $r3, 11
; CHECK-NEXT:    addx4d $r0 = $r3, $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sbfd $r1 = $r1, $r3
; CHECK-NEXT:    addd $r0 = $r0, -16
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addd $r1 = $r1, 7
; CHECK-NEXT:    ;;
; CHECK-NEXT:    srld $r1 = $r1, 3
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addd $r2 = $r1, 1
; CHECK-NEXT:    make $r1 = a
; CHECK-NEXT:    ;;
; CHECK-NEXT:    loopdo $r2, .__LOOPDO_0_END_
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB0_7: # %for.body.for.body_crit_edge
; CHECK-NEXT:    # =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    lwz $r2 = 0[$r1]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw 12[$r0] = $r2
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lwz $r2 = 0[$r1]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw 8[$r0] = $r2
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lwz $r2 = 0[$r1]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw 4[$r0] = $r2
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lwz $r2 = 0[$r1]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw 0[$r0] = $r2
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lwz $r2 = 0[$r1]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw -4[$r0] = $r2
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lwz $r2 = 0[$r1]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw -8[$r0] = $r2
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lwz $r2 = 0[$r1]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw -12[$r0] = $r2
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lwz $r2 = 0[$r1]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw -16[$r0] = $r2
; CHECK-NEXT:    addd $r0 = $r0, -32
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .__LOOPDO_0_END_:
; CHECK-NEXT:  .LBB0_8: # %for.end
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = load i32, i32* @a, align 4
  %cmp5 = icmp sgt i32 %0, 2
  br i1 %cmp5, label %for.body.lr.ph, label %for.end

for.body.lr.ph:
  %1 = load i32*, i32** @b, align 8
  %2 = zext i32 %0 to i64
  %arrayidx7 = getelementptr inbounds i32, i32* %1, i64 %2
  store i32 %0, i32* %arrayidx7, align 4
  %cmp8 = icmp eq i32 %0, 3
  br i1 %cmp8, label %for.end, label %for.body.for.body_crit_edge.preheader

for.body.for.body_crit_edge.preheader:
  %3 = add nuw nsw i64 %2, 1
  %4 = icmp ult i64 %2, 4
  %smin = select i1 %4, i64 %2, i64 4
  %5 = sub nsw i64 %3, %smin
  %6 = sub nsw i64 %2, %smin
  %xtraiter = and i64 %5, 7
  %lcmp.mod = icmp eq i64 %xtraiter, 0
  br i1 %lcmp.mod, label %for.body.for.body_crit_edge.prol.loopexit, label %for.body.for.body_crit_edge.prol

for.body.for.body_crit_edge.prol:
  %indvars.iv.next.prol = add nsw i64 %2, -1
  %.pre.prol = load i32, i32* @a, align 4
  %arrayidx.prol = getelementptr inbounds i32, i32* %1, i64 %indvars.iv.next.prol
  store i32 %.pre.prol, i32* %arrayidx.prol, align 4
  %prol.iter.cmp = icmp eq i64 %xtraiter, 1
  br i1 %prol.iter.cmp, label %for.body.for.body_crit_edge.prol.loopexit, label %for.body.for.body_crit_edge.prol.1

for.body.for.body_crit_edge.prol.loopexit:
  %indvars.iv9.unr = phi i64 [ %2, %for.body.for.body_crit_edge.preheader ], [ %indvars.iv.next.prol, %for.body.for.body_crit_edge.prol ], [ %indvars.iv.next.prol.1, %for.body.for.body_crit_edge.prol.1 ], [ %indvars.iv.next.prol.2, %for.body.for.body_crit_edge.prol.2 ], [ %indvars.iv.next.prol.3, %for.body.for.body_crit_edge.prol.3 ], [ %indvars.iv.next.prol.4, %for.body.for.body_crit_edge.prol.4 ], [ %indvars.iv.next.prol.5, %for.body.for.body_crit_edge.prol.5 ], [ %indvars.iv.next.prol.6, %for.body.for.body_crit_edge.prol.6 ]
  %7 = icmp ult i64 %6, 7
  br i1 %7, label %for.end, label %for.body.for.body_crit_edge

for.body.for.body_crit_edge:
  %indvars.iv9 = phi i64 [ %indvars.iv.next.7, %for.body.for.body_crit_edge ], [ %indvars.iv9.unr, %for.body.for.body_crit_edge.prol.loopexit ]
  %indvars.iv.next = add nsw i64 %indvars.iv9, -1
  %.pre = load i32, i32* @a, align 4
  %arrayidx = getelementptr inbounds i32, i32* %1, i64 %indvars.iv.next
  store i32 %.pre, i32* %arrayidx, align 4
  %indvars.iv.next.1 = add nsw i64 %indvars.iv9, -2
  %.pre.1 = load i32, i32* @a, align 4
  %arrayidx.1 = getelementptr inbounds i32, i32* %1, i64 %indvars.iv.next.1
  store i32 %.pre.1, i32* %arrayidx.1, align 4
  %indvars.iv.next.2 = add nsw i64 %indvars.iv9, -3
  %.pre.2 = load i32, i32* @a, align 4
  %arrayidx.2 = getelementptr inbounds i32, i32* %1, i64 %indvars.iv.next.2
  store i32 %.pre.2, i32* %arrayidx.2, align 4
  %indvars.iv.next.3 = add nsw i64 %indvars.iv9, -4
  %.pre.3 = load i32, i32* @a, align 4
  %arrayidx.3 = getelementptr inbounds i32, i32* %1, i64 %indvars.iv.next.3
  store i32 %.pre.3, i32* %arrayidx.3, align 4
  %indvars.iv.next.4 = add nsw i64 %indvars.iv9, -5
  %.pre.4 = load i32, i32* @a, align 4
  %arrayidx.4 = getelementptr inbounds i32, i32* %1, i64 %indvars.iv.next.4
  store i32 %.pre.4, i32* %arrayidx.4, align 4
  %indvars.iv.next.5 = add nsw i64 %indvars.iv9, -6
  %.pre.5 = load i32, i32* @a, align 4
  %arrayidx.5 = getelementptr inbounds i32, i32* %1, i64 %indvars.iv.next.5
  store i32 %.pre.5, i32* %arrayidx.5, align 4
  %indvars.iv.next.6 = add nsw i64 %indvars.iv9, -7
  %.pre.6 = load i32, i32* @a, align 4
  %arrayidx.6 = getelementptr inbounds i32, i32* %1, i64 %indvars.iv.next.6
  store i32 %.pre.6, i32* %arrayidx.6, align 4
  %indvars.iv.next.7 = add nsw i64 %indvars.iv9, -8
  %.pre.7 = load i32, i32* @a, align 4
  %arrayidx.7 = getelementptr inbounds i32, i32* %1, i64 %indvars.iv.next.7
  store i32 %.pre.7, i32* %arrayidx.7, align 4
  %cmp.7 = icmp sgt i64 %indvars.iv9, 11
  br i1 %cmp.7, label %for.body.for.body_crit_edge, label %for.end

for.end:
  ret i32 undef

for.body.for.body_crit_edge.prol.1:
  %indvars.iv.next.prol.1 = add nsw i64 %2, -2
  %.pre.prol.1 = load i32, i32* @a, align 4
  %arrayidx.prol.1 = getelementptr inbounds i32, i32* %1, i64 %indvars.iv.next.prol.1
  store i32 %.pre.prol.1, i32* %arrayidx.prol.1, align 4
  %prol.iter.cmp.1 = icmp eq i64 %xtraiter, 2
  br i1 %prol.iter.cmp.1, label %for.body.for.body_crit_edge.prol.loopexit, label %for.body.for.body_crit_edge.prol.2

for.body.for.body_crit_edge.prol.2:
  %indvars.iv.next.prol.2 = add nsw i64 %2, -3
  %.pre.prol.2 = load i32, i32* @a, align 4
  %arrayidx.prol.2 = getelementptr inbounds i32, i32* %1, i64 %indvars.iv.next.prol.2
  store i32 %.pre.prol.2, i32* %arrayidx.prol.2, align 4
  %prol.iter.cmp.2 = icmp eq i64 %xtraiter, 3
  br i1 %prol.iter.cmp.2, label %for.body.for.body_crit_edge.prol.loopexit, label %for.body.for.body_crit_edge.prol.3

for.body.for.body_crit_edge.prol.3:
  %indvars.iv.next.prol.3 = add nsw i64 %2, -4
  %.pre.prol.3 = load i32, i32* @a, align 4
  %arrayidx.prol.3 = getelementptr inbounds i32, i32* %1, i64 %indvars.iv.next.prol.3
  store i32 %.pre.prol.3, i32* %arrayidx.prol.3, align 4
  %prol.iter.cmp.3 = icmp eq i64 %xtraiter, 4
  br i1 %prol.iter.cmp.3, label %for.body.for.body_crit_edge.prol.loopexit, label %for.body.for.body_crit_edge.prol.4

for.body.for.body_crit_edge.prol.4:
  %indvars.iv.next.prol.4 = add nsw i64 %2, -5
  %.pre.prol.4 = load i32, i32* @a, align 4
  %arrayidx.prol.4 = getelementptr inbounds i32, i32* %1, i64 %indvars.iv.next.prol.4
  store i32 %.pre.prol.4, i32* %arrayidx.prol.4, align 4
  %prol.iter.cmp.4 = icmp eq i64 %xtraiter, 5
  br i1 %prol.iter.cmp.4, label %for.body.for.body_crit_edge.prol.loopexit, label %for.body.for.body_crit_edge.prol.5

for.body.for.body_crit_edge.prol.5:
  %indvars.iv.next.prol.5 = add nsw i64 %2, -6
  %.pre.prol.5 = load i32, i32* @a, align 4
  %arrayidx.prol.5 = getelementptr inbounds i32, i32* %1, i64 %indvars.iv.next.prol.5
  store i32 %.pre.prol.5, i32* %arrayidx.prol.5, align 4
  %prol.iter.cmp.5 = icmp eq i64 %xtraiter, 6
  br i1 %prol.iter.cmp.5, label %for.body.for.body_crit_edge.prol.loopexit, label %for.body.for.body_crit_edge.prol.6

for.body.for.body_crit_edge.prol.6:
  %indvars.iv.next.prol.6 = add nsw i64 %2, -7
  %.pre.prol.6 = load i32, i32* @a, align 4
  %arrayidx.prol.6 = getelementptr inbounds i32, i32* %1, i64 %indvars.iv.next.prol.6
  store i32 %.pre.prol.6, i32* %arrayidx.prol.6, align 4
  br label %for.body.for.body_crit_edge.prol.loopexit
}

define i32 @g(i32 %h)  {
; CHECK-LABEL: g:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    get $r16 = $ra
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_def_cfa_offset 32
; CHECK-NEXT:    sd 0[$r12] = $r16
; CHECK-NEXT:    make $r1 = e
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_offset 67, -32
; CHECK-NEXT:    ld $r1 = 0[$r1]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lwz $r2 = 0[$r1]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    cb.weqz $r2 ? .LBB1_11
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.1: # %for.body.preheader
; CHECK-NEXT:    addd $r2 = $r1, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB1_2: # %for.body
; CHECK-NEXT:    # =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    lwz $r3 = -28[$r2]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    cb.weqz $r3 ? .LBB1_12
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.3: # %for.body.1
; CHECK-NEXT:    # in Loop: Header=BB1_2 Depth=1
; CHECK-NEXT:    lwz $r3 = -24[$r2]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    cb.weqz $r3 ? .LBB1_13
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.4: # %for.body.2
; CHECK-NEXT:    # in Loop: Header=BB1_2 Depth=1
; CHECK-NEXT:    lwz $r3 = -20[$r2]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    cb.weqz $r3 ? .LBB1_14
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.5: # %for.body.3
; CHECK-NEXT:    # in Loop: Header=BB1_2 Depth=1
; CHECK-NEXT:    lwz $r3 = -16[$r2]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    cb.weqz $r3 ? .LBB1_15
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.6: # %for.body.4
; CHECK-NEXT:    # in Loop: Header=BB1_2 Depth=1
; CHECK-NEXT:    lwz $r3 = -12[$r2]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    cb.weqz $r3 ? .LBB1_16
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.7: # %for.body.5
; CHECK-NEXT:    # in Loop: Header=BB1_2 Depth=1
; CHECK-NEXT:    lwz $r3 = -8[$r2]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    cb.weqz $r3 ? .LBB1_17
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.8: # %for.body.6
; CHECK-NEXT:    # in Loop: Header=BB1_2 Depth=1
; CHECK-NEXT:    lwz $r3 = -4[$r2]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    cb.weqz $r3 ? .LBB1_18
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.9: # %for.body.7
; CHECK-NEXT:    # in Loop: Header=BB1_2 Depth=1
; CHECK-NEXT:    lwz $r3 = 0[$r2]
; CHECK-NEXT:    addw $r1 = $r1, 8
; CHECK-NEXT:    addd $r2 = $r2, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    cb.wnez $r3 ? .LBB1_2
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.10: # %while.cond.preheader.split.loop.exit
; CHECK-NEXT:    addw $r3 = $r1, -1
; CHECK-NEXT:    addd $r2 = $r2, -32
; CHECK-NEXT:    goto .LBB1_19
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB1_11: # %while.cond.preheader.thread
; CHECK-NEXT:    make $r1 = c
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r2 = 0[$r1]
; CHECK-NEXT:    goto .LBB1_20
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB1_12: # %while.cond.preheader.split.loop.exit42
; CHECK-NEXT:    addw $r4 = $r1, 1
; CHECK-NEXT:    copyd $r3 = $r1
; CHECK-NEXT:    addd $r2 = $r2, -28
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r1 = $r4
; CHECK-NEXT:    goto .LBB1_19
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB1_13: # %while.cond.preheader.split.loop.exit38
; CHECK-NEXT:    addw $r3 = $r1, 1
; CHECK-NEXT:    addw $r1 = $r1, 2
; CHECK-NEXT:    addd $r2 = $r2, -24
; CHECK-NEXT:    goto .LBB1_19
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB1_14: # %while.cond.preheader.split.loop.exit34
; CHECK-NEXT:    addw $r3 = $r1, 2
; CHECK-NEXT:    addw $r1 = $r1, 3
; CHECK-NEXT:    addd $r2 = $r2, -20
; CHECK-NEXT:    goto .LBB1_19
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB1_15: # %while.cond.preheader.split.loop.exit30
; CHECK-NEXT:    addw $r3 = $r1, 3
; CHECK-NEXT:    addw $r1 = $r1, 4
; CHECK-NEXT:    addd $r2 = $r2, -16
; CHECK-NEXT:    goto .LBB1_19
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB1_16: # %while.cond.preheader.split.loop.exit26
; CHECK-NEXT:    addw $r3 = $r1, 4
; CHECK-NEXT:    addw $r1 = $r1, 5
; CHECK-NEXT:    addd $r2 = $r2, -12
; CHECK-NEXT:    goto .LBB1_19
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB1_17: # %while.cond.preheader.split.loop.exit22
; CHECK-NEXT:    addw $r3 = $r1, 5
; CHECK-NEXT:    addw $r1 = $r1, 6
; CHECK-NEXT:    addd $r2 = $r2, -8
; CHECK-NEXT:    goto .LBB1_19
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB1_18: # %while.cond.preheader.split.loop.exit18
; CHECK-NEXT:    addw $r3 = $r1, 6
; CHECK-NEXT:    addw $r1 = $r1, 7
; CHECK-NEXT:    addd $r2 = $r2, -4
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB1_19: # %while.cond.preheader
; CHECK-NEXT:    make $r4 = e
; CHECK-NEXT:    make $r5 = c
; CHECK-NEXT:    compw.ge $r3 = $r3, $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sd 0[$r4] = $r2
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r2 = 0[$r5]
; CHECK-NEXT:    cb.odd $r3 ? .LBB1_23
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB1_20: # %while.body.lr.ph
; CHECK-NEXT:    sxwd $r1 = $r1
; CHECK-NEXT:    sxwd $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    maxd $r3 = $r1, $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sbfd $r3 = $r1, $r3
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addd $r4 = $r3, 1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    andd $r4 = $r4, 7
; CHECK-NEXT:    ;;
; CHECK-NEXT:    cb.deqz $r4 ? .LBB1_27
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.21: # %while.body.prol
; CHECK-NEXT:    make $r5 = 0
; CHECK-NEXT:    compd.ne $r6 = $r4, 1
; CHECK-NEXT:    addd $r7 = $r1, 1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw.xs $r1[$r2] = $r5
; CHECK-NEXT:    cb.odd $r6 ? .LBB1_25
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB1_22:
; CHECK-NEXT:    copyd $r1 = $r7
; CHECK-NEXT:    goto .LBB1_27
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB1_23: # %while.end
; CHECK-NEXT:    cb.dnez $r2 ? .LBB1_30
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.24: # %if.then
; CHECK-NEXT:    call abort
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB1_25: # %while.body.prol.1
; CHECK-NEXT:    compd.eq $r8 = $r4, 2
; CHECK-NEXT:    addd $r6 = $r1, 2
; CHECK-NEXT:    sw.xs $r7[$r2] = $r5
; CHECK-NEXT:    ;;
; CHECK-NEXT:    cb.even $r8 ? .LBB1_31
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB1_26:
; CHECK-NEXT:    copyd $r1 = $r6
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB1_27: # %while.body.prol.loopexit
; CHECK-NEXT:    compd.ltu $r3 = $r3, 7
; CHECK-NEXT:    ;;
; CHECK-NEXT:    cb.odd $r3 ? .LBB1_30
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.28: # %while.body.preheader
; CHECK-NEXT:    addd $r3 = $r1, 7
; CHECK-NEXT:    ;;
; CHECK-NEXT:    maxd $r0 = $r3, $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sbfd $r0 = $r1, $r0
; CHECK-NEXT:    addx4d $r1 = $r1, $r2
; CHECK-NEXT:    ;;
; CHECK-NEXT:    srld $r0 = $r0, 3
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addd $r2 = $r0, 1
; CHECK-NEXT:    addd $r0 = $r1, 16
; CHECK-NEXT:    make $r1 = 0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    loopdo $r2, .__LOOPDO_1_END_
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB1_29: # %while.body
; CHECK-NEXT:    # =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    sw -16[$r0] = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw -12[$r0] = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw -8[$r0] = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw -4[$r0] = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw 0[$r0] = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw 4[$r0] = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw 8[$r0] = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw 12[$r0] = $r1
; CHECK-NEXT:    addd $r0 = $r0, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .__LOOPDO_1_END_:
; CHECK-NEXT:  .LBB1_30: # %if.end
; CHECK-NEXT:    ld $r16 = 0[$r12]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    set $ra = $r16
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_def_cfa_offset 0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB1_31: # %while.body.prol.2
; CHECK-NEXT:    make $r5 = 0
; CHECK-NEXT:    compd.eq $r8 = $r4, 3
; CHECK-NEXT:    addd $r7 = $r1, 3
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw.xs $r6[$r2] = $r5
; CHECK-NEXT:    cb.odd $r8 ? .LBB1_22
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.32: # %while.body.prol.3
; CHECK-NEXT:    compd.eq $r8 = $r4, 4
; CHECK-NEXT:    addd $r6 = $r1, 4
; CHECK-NEXT:    sw.xs $r7[$r2] = $r5
; CHECK-NEXT:    ;;
; CHECK-NEXT:    cb.odd $r8 ? .LBB1_26
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.34: # %while.body.prol.4
; CHECK-NEXT:    make $r5 = 0
; CHECK-NEXT:    compd.eq $r8 = $r4, 5
; CHECK-NEXT:    addd $r7 = $r1, 5
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw.xs $r6[$r2] = $r5
; CHECK-NEXT:    cb.odd $r8 ? .LBB1_22
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.35: # %while.body.prol.5
; CHECK-NEXT:    compd.eq $r6 = $r4, 6
; CHECK-NEXT:    addd $r4 = $r1, 6
; CHECK-NEXT:    sw.xs $r7[$r2] = $r5
; CHECK-NEXT:    ;;
; CHECK-NEXT:    cb.even $r6 ? .LBB1_37
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.36:
; CHECK-NEXT:    copyd $r1 = $r4
; CHECK-NEXT:    goto .LBB1_27
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB1_37: # %while.body.prol.6
; CHECK-NEXT:    make $r5 = 0
; CHECK-NEXT:    addd $r1 = $r1, 7
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw.xs $r4[$r2] = $r5
; CHECK-NEXT:    goto .LBB1_27
; CHECK-NEXT:    ;;
entry:
  %0 = load i32*, i32** @e, align 8
  %1 = load i32, i32* %0, align 4
  %tobool11 = icmp eq i32 %1, 0
  br i1 %tobool11, label %while.cond.preheader.thread, label %for.body

while.cond.preheader.thread:
  %2 = load i32*, i32** @c, align 8
  br label %while.body.lr.ph

while.cond.preheader.split.loop.exit:
  %inc.6.le47 = add nsw i32 %i.012, 7
  br label %while.cond.preheader

while.cond.preheader.split.loop.exit18:
  %inc.5.le51 = add nsw i32 %i.012, 6
  %inc.6.le = add nsw i32 %i.012, 7
  %incdec.ptr.6.le = getelementptr inbounds i32, i32* %12, i64 7
  br label %while.cond.preheader

while.cond.preheader.split.loop.exit22:
  %inc.4.le55 = add nsw i32 %i.012, 5
  %inc.5.le = add nsw i32 %i.012, 6
  %incdec.ptr.5.le = getelementptr inbounds i32, i32* %12, i64 6
  br label %while.cond.preheader

while.cond.preheader.split.loop.exit26:
  %inc.3.le59 = add nsw i32 %i.012, 4
  %inc.4.le = add nsw i32 %i.012, 5
  %incdec.ptr.4.le = getelementptr inbounds i32, i32* %12, i64 5
  br label %while.cond.preheader

while.cond.preheader.split.loop.exit30:
  %inc.2.le63 = add nsw i32 %i.012, 3
  %inc.3.le = add nsw i32 %i.012, 4
  %incdec.ptr.3.le = getelementptr inbounds i32, i32* %12, i64 4
  br label %while.cond.preheader

while.cond.preheader.split.loop.exit34:
  %inc.1.le67 = add nsw i32 %i.012, 2
  %inc.2.le = add nsw i32 %i.012, 3
  %incdec.ptr.2.le = getelementptr inbounds i32, i32* %12, i64 3
  br label %while.cond.preheader

while.cond.preheader.split.loop.exit38:
  %inc.le71 = add nsw i32 %i.012, 1
  %inc.1.le = add nsw i32 %i.012, 2
  %incdec.ptr.1.le = getelementptr inbounds i32, i32* %12, i64 2
  br label %while.cond.preheader

while.cond.preheader.split.loop.exit42:
  %inc.le = add nsw i32 %i.012, 1
  %incdec.ptr.le = getelementptr inbounds i32, i32* %12, i64 1
  br label %while.cond.preheader

while.cond.preheader:
  %i.012.lcssa = phi i32 [ %inc.6.le47, %while.cond.preheader.split.loop.exit ], [ %inc.5.le51, %while.cond.preheader.split.loop.exit18 ], [ %inc.4.le55, %while.cond.preheader.split.loop.exit22 ], [ %inc.3.le59, %while.cond.preheader.split.loop.exit26 ], [ %inc.2.le63, %while.cond.preheader.split.loop.exit30 ], [ %inc.1.le67, %while.cond.preheader.split.loop.exit34 ], [ %inc.le71, %while.cond.preheader.split.loop.exit38 ], [ %i.012, %while.cond.preheader.split.loop.exit42 ]
  %inc.lcssa = phi i32 [ %inc.7, %while.cond.preheader.split.loop.exit ], [ %inc.6.le, %while.cond.preheader.split.loop.exit18 ], [ %inc.5.le, %while.cond.preheader.split.loop.exit22 ], [ %inc.4.le, %while.cond.preheader.split.loop.exit26 ], [ %inc.3.le, %while.cond.preheader.split.loop.exit30 ], [ %inc.2.le, %while.cond.preheader.split.loop.exit34 ], [ %inc.1.le, %while.cond.preheader.split.loop.exit38 ], [ %inc.le, %while.cond.preheader.split.loop.exit42 ]
  %incdec.ptr.lcssa = phi i32* [ %incdec.ptr.7, %while.cond.preheader.split.loop.exit ], [ %incdec.ptr.6.le, %while.cond.preheader.split.loop.exit18 ], [ %incdec.ptr.5.le, %while.cond.preheader.split.loop.exit22 ], [ %incdec.ptr.4.le, %while.cond.preheader.split.loop.exit26 ], [ %incdec.ptr.3.le, %while.cond.preheader.split.loop.exit30 ], [ %incdec.ptr.2.le, %while.cond.preheader.split.loop.exit34 ], [ %incdec.ptr.1.le, %while.cond.preheader.split.loop.exit38 ], [ %incdec.ptr.le, %while.cond.preheader.split.loop.exit42 ]
  store i32* %incdec.ptr.lcssa, i32** @e, align 8
  %cmp9 = icmp slt i32 %i.012.lcssa, %h
  %3 = load i32*, i32** @c, align 8
  br i1 %cmp9, label %while.body.lr.ph, label %while.end

while.body.lr.ph:
  %4 = phi i32* [ %2, %while.cond.preheader.thread ], [ %3, %while.cond.preheader ]
  %i.0.lcssa16 = phi i32 [ undef, %while.cond.preheader.thread ], [ %inc.lcssa, %while.cond.preheader ]
  %5 = sext i32 %i.0.lcssa16 to i64
  %6 = sext i32 %h to i64
  %7 = icmp sgt i64 %5, %6
  %smax = select i1 %7, i64 %5, i64 %6
  %8 = add nsw i64 %smax, 1
  %9 = sub nsw i64 %8, %5
  %10 = sub nsw i64 %smax, %5
  %xtraiter = and i64 %9, 7
  %lcmp.mod = icmp eq i64 %xtraiter, 0
  br i1 %lcmp.mod, label %while.body.prol.loopexit, label %while.body.prol

while.body.prol:
  %indvars.iv.next.prol = add nsw i64 %5, 1
  %arrayidx3.prol = getelementptr inbounds i32, i32* %4, i64 %5
  store i32 0, i32* %arrayidx3.prol, align 4
  %prol.iter.cmp = icmp eq i64 %xtraiter, 1
  br i1 %prol.iter.cmp, label %while.body.prol.loopexit, label %while.body.prol.1

while.body.prol.loopexit:
  %indvars.iv.unr = phi i64 [ %5, %while.body.lr.ph ], [ %indvars.iv.next.prol, %while.body.prol ], [ %indvars.iv.next.prol.1, %while.body.prol.1 ], [ %indvars.iv.next.prol.2, %while.body.prol.2 ], [ %indvars.iv.next.prol.3, %while.body.prol.3 ], [ %indvars.iv.next.prol.4, %while.body.prol.4 ], [ %indvars.iv.next.prol.5, %while.body.prol.5 ], [ %indvars.iv.next.prol.6, %while.body.prol.6 ]
  %11 = icmp ult i64 %10, 7
  br i1 %11, label %if.end, label %while.body

for.body:
  %12 = phi i32* [ %incdec.ptr.7, %for.body.7 ], [ %0, %entry ]
  %i.012 = phi i32 [ %inc.7, %for.body.7 ], [ undef, %entry ]
  %incdec.ptr = getelementptr inbounds i32, i32* %12, i64 1
  %13 = load i32, i32* %incdec.ptr, align 4
  %tobool = icmp eq i32 %13, 0
  br i1 %tobool, label %while.cond.preheader.split.loop.exit42, label %for.body.1

while.body:
  %indvars.iv = phi i64 [ %indvars.iv.next.7, %while.body ], [ %indvars.iv.unr, %while.body.prol.loopexit ]
  %indvars.iv.next = add nsw i64 %indvars.iv, 1
  %arrayidx3 = getelementptr inbounds i32, i32* %4, i64 %indvars.iv
  store i32 0, i32* %arrayidx3, align 4
  %indvars.iv.next.1 = add nsw i64 %indvars.iv, 2
  %arrayidx3.1 = getelementptr inbounds i32, i32* %4, i64 %indvars.iv.next
  store i32 0, i32* %arrayidx3.1, align 4
  %indvars.iv.next.2 = add nsw i64 %indvars.iv, 3
  %arrayidx3.2 = getelementptr inbounds i32, i32* %4, i64 %indvars.iv.next.1
  store i32 0, i32* %arrayidx3.2, align 4
  %indvars.iv.next.3 = add nsw i64 %indvars.iv, 4
  %arrayidx3.3 = getelementptr inbounds i32, i32* %4, i64 %indvars.iv.next.2
  store i32 0, i32* %arrayidx3.3, align 4
  %indvars.iv.next.4 = add nsw i64 %indvars.iv, 5
  %arrayidx3.4 = getelementptr inbounds i32, i32* %4, i64 %indvars.iv.next.3
  store i32 0, i32* %arrayidx3.4, align 4
  %indvars.iv.next.5 = add nsw i64 %indvars.iv, 6
  %arrayidx3.5 = getelementptr inbounds i32, i32* %4, i64 %indvars.iv.next.4
  store i32 0, i32* %arrayidx3.5, align 4
  %indvars.iv.next.6 = add nsw i64 %indvars.iv, 7
  %arrayidx3.6 = getelementptr inbounds i32, i32* %4, i64 %indvars.iv.next.5
  store i32 0, i32* %arrayidx3.6, align 4
  %indvars.iv.next.7 = add nsw i64 %indvars.iv, 8
  %arrayidx3.7 = getelementptr inbounds i32, i32* %4, i64 %indvars.iv.next.6
  store i32 0, i32* %arrayidx3.7, align 4
  %cmp.7 = icmp slt i64 %indvars.iv.next.6, %6
  br i1 %cmp.7, label %while.body, label %if.end

while.end:
  %cmp4 = icmp eq i32* %3, null
  br i1 %cmp4, label %if.then, label %if.end

if.then:
  tail call void @llvm.trap()
  unreachable

if.end:
  ret i32 undef

while.body.prol.1:
  %indvars.iv.next.prol.1 = add nsw i64 %5, 2
  %arrayidx3.prol.1 = getelementptr inbounds i32, i32* %4, i64 %indvars.iv.next.prol
  store i32 0, i32* %arrayidx3.prol.1, align 4
  %prol.iter.cmp.1 = icmp eq i64 %xtraiter, 2
  br i1 %prol.iter.cmp.1, label %while.body.prol.loopexit, label %while.body.prol.2

while.body.prol.2:
  %indvars.iv.next.prol.2 = add nsw i64 %5, 3
  %arrayidx3.prol.2 = getelementptr inbounds i32, i32* %4, i64 %indvars.iv.next.prol.1
  store i32 0, i32* %arrayidx3.prol.2, align 4
  %prol.iter.cmp.2 = icmp eq i64 %xtraiter, 3
  br i1 %prol.iter.cmp.2, label %while.body.prol.loopexit, label %while.body.prol.3

while.body.prol.3:
  %indvars.iv.next.prol.3 = add nsw i64 %5, 4
  %arrayidx3.prol.3 = getelementptr inbounds i32, i32* %4, i64 %indvars.iv.next.prol.2
  store i32 0, i32* %arrayidx3.prol.3, align 4
  %prol.iter.cmp.3 = icmp eq i64 %xtraiter, 4
  br i1 %prol.iter.cmp.3, label %while.body.prol.loopexit, label %while.body.prol.4

while.body.prol.4:
  %indvars.iv.next.prol.4 = add nsw i64 %5, 5
  %arrayidx3.prol.4 = getelementptr inbounds i32, i32* %4, i64 %indvars.iv.next.prol.3
  store i32 0, i32* %arrayidx3.prol.4, align 4
  %prol.iter.cmp.4 = icmp eq i64 %xtraiter, 5
  br i1 %prol.iter.cmp.4, label %while.body.prol.loopexit, label %while.body.prol.5

while.body.prol.5:
  %indvars.iv.next.prol.5 = add nsw i64 %5, 6
  %arrayidx3.prol.5 = getelementptr inbounds i32, i32* %4, i64 %indvars.iv.next.prol.4
  store i32 0, i32* %arrayidx3.prol.5, align 4
  %prol.iter.cmp.5 = icmp eq i64 %xtraiter, 6
  br i1 %prol.iter.cmp.5, label %while.body.prol.loopexit, label %while.body.prol.6

while.body.prol.6:
  %indvars.iv.next.prol.6 = add nsw i64 %5, 7
  %arrayidx3.prol.6 = getelementptr inbounds i32, i32* %4, i64 %indvars.iv.next.prol.5
  store i32 0, i32* %arrayidx3.prol.6, align 4
  br label %while.body.prol.loopexit

for.body.1:
  %incdec.ptr.1 = getelementptr inbounds i32, i32* %12, i64 2
  %14 = load i32, i32* %incdec.ptr.1, align 4
  %tobool.1 = icmp eq i32 %14, 0
  br i1 %tobool.1, label %while.cond.preheader.split.loop.exit38, label %for.body.2

for.body.2:
  %incdec.ptr.2 = getelementptr inbounds i32, i32* %12, i64 3
  %15 = load i32, i32* %incdec.ptr.2, align 4
  %tobool.2 = icmp eq i32 %15, 0
  br i1 %tobool.2, label %while.cond.preheader.split.loop.exit34, label %for.body.3

for.body.3:
  %incdec.ptr.3 = getelementptr inbounds i32, i32* %12, i64 4
  %16 = load i32, i32* %incdec.ptr.3, align 4
  %tobool.3 = icmp eq i32 %16, 0
  br i1 %tobool.3, label %while.cond.preheader.split.loop.exit30, label %for.body.4

for.body.4:
  %incdec.ptr.4 = getelementptr inbounds i32, i32* %12, i64 5
  %17 = load i32, i32* %incdec.ptr.4, align 4
  %tobool.4 = icmp eq i32 %17, 0
  br i1 %tobool.4, label %while.cond.preheader.split.loop.exit26, label %for.body.5

for.body.5:
  %incdec.ptr.5 = getelementptr inbounds i32, i32* %12, i64 6
  %18 = load i32, i32* %incdec.ptr.5, align 4
  %tobool.5 = icmp eq i32 %18, 0
  br i1 %tobool.5, label %while.cond.preheader.split.loop.exit22, label %for.body.6

for.body.6:
  %incdec.ptr.6 = getelementptr inbounds i32, i32* %12, i64 7
  %19 = load i32, i32* %incdec.ptr.6, align 4
  %tobool.6 = icmp eq i32 %19, 0
  br i1 %tobool.6, label %while.cond.preheader.split.loop.exit18, label %for.body.7

for.body.7:
  %inc.7 = add nsw i32 %i.012, 8
  %incdec.ptr.7 = getelementptr inbounds i32, i32* %12, i64 8
  %20 = load i32, i32* %incdec.ptr.7, align 4
  %tobool.7 = icmp eq i32 %20, 0
  br i1 %tobool.7, label %while.cond.preheader.split.loop.exit, label %for.body
}

declare void @llvm.trap()
