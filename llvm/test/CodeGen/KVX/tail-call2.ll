; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -O1 < %s | FileCheck %s
target triple = "kvx-kalray-cos"

@z = common global [5 x i32] zeroinitializer, align 4

; Function Attrs: nounwind
define i32 @f(i32 %a1, i32 %a2, i32 %a3, i32 %a4, i32 %a5, i32 %a6, i32 %a7, i32 %a8, i32 %a9, i32 %a10, i32 %a11, i32 %a12, i32 %a13, i32 %a14, i32 %a15, i32 %a16) {
; CHECK-LABEL: f:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addd $r12 = $r12, -128
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_def_cfa_offset 128
; CHECK-NEXT:    get $r16 = $ra
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sd 96[$r12] = $r16
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_offset 67, -16
; CHECK-NEXT:    sd 88[$r12] = $r14
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_offset 14, -24
; CHECK-NEXT:    sd 80[$r12] = $r26
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_offset 26, -32
; CHECK-NEXT:    sq 64[$r12] = $r24r25
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_offset 25, -40
; CHECK-NEXT:    .cfi_offset 24, -48
; CHECK-NEXT:    so 32[$r12] = $r20r21r22r23
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_offset 23, -56
; CHECK-NEXT:    .cfi_offset 22, -64
; CHECK-NEXT:    .cfi_offset 21, -72
; CHECK-NEXT:    .cfi_offset 20, -80
; CHECK-NEXT:    sq 16[$r12] = $r18r19
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_offset 19, -88
; CHECK-NEXT:    .cfi_offset 18, -96
; CHECK-NEXT:    copyd $r14 = $r12
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_def_cfa_register 14
; CHECK-NEXT:    lwz $r15 = 152[$r14]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r18 = $r10
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r19 = $r7
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r20 = $r6
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r21 = $r5
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r22 = $r2
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r23 = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r24 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lwz $r2 = 144[$r14]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lwz $r1 = 136[$r14]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lwz $r0 = 128[$r14]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    zxwd $r5 = $r15
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addx4d $r6 = $r5, 31
; CHECK-NEXT:    ;;
; CHECK-NEXT:    andd $r6 = $r6, 0x7ffffffe0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sbfd $r6 = $r6, $r12
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r12 = $r6
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addw $r7 = $r23, $r24
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addw $r7 = $r7, $r22
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addw $r7 = $r7, $r3
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addw $r7 = $r7, $r4
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addw $r7 = $r7, $r21
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addw $r7 = $r7, $r20
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addw $r7 = $r7, $r19
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addw $r7 = $r7, $r8
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addw $r7 = $r7, $r9
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addw $r7 = $r7, $r18
; CHECK-NEXT:    ;;
; CHECK-NEXT:    make $r10 = z
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addw $r7 = $r7, $r11
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lwz $r25 = 0[$r10]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addw $r7 = $r7, $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addw $r7 = $r7, $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addw $r7 = $r7, $r2
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addw $r7 = $r7, $r15
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addw $r26 = $r7, $r25
; CHECK-NEXT:    ;;
; CHECK-NEXT:    cb.wlez $r15 ? .LBB0_3
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.1: # %for.body.preheader
; CHECK-NEXT:    make $r7 = 0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r10 = $r6
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB0_2: # %for.body
; CHECK-NEXT:    # =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    addd $r5 = $r5, -1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw 0[$r10] = $r7
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addw $r7 = $r7, 1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addd $r10 = $r10, 4
; CHECK-NEXT:    ;;
; CHECK-NEXT:    cb.dnez $r5 ? .LBB0_2
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB0_3: # %for.cond.cleanup
; CHECK-NEXT:    lwz $r5 = 40[$r6]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addd $r12 = $r12, -64
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw 48[$r12] = $r25
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw 40[$r12] = $r26
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw 32[$r12] = $r5
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw 24[$r12] = $r15
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw 16[$r12] = $r2
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw 8[$r12] = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw 0[$r12] = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r0 = $r24
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r1 = $r23
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r2 = $r22
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r5 = $r21
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r6 = $r20
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r7 = $r19
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r10 = $r18
; CHECK-NEXT:    ;;
; CHECK-NEXT:    call h
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addd $r12 = $r12, 64
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addw $r7 = $r0, $r26
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r0 = $r24
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r1 = $r23
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r2 = $r22
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r3 = $r21
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r4 = $r20
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r5 = $r19
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r6 = $r18
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r8 = $r25
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r12 = $r14
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_def_cfa_register 12
; CHECK-NEXT:    lq $r18r19 = 16[$r12]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lo $r20r21r22r23 = 32[$r12]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lq $r24r25 = 64[$r12]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r26 = 80[$r12]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r16 = 96[$r12]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    set $ra = $r16
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r14 = 88[$r12]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addd $r12 = $r12, 128
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_def_cfa_offset 0
; CHECK-NEXT:    goto g
; CHECK-NEXT:    ;;
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

}

declare i32 @h(i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32)

declare i32 @g(i32, i32, i32, i32, i32, i32, i32, i32, i32)
