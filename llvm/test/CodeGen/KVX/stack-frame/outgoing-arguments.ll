; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc --frame-pointer=none < %s | FileCheck -check-prefix=FP-NONE %s
; RUN: llc --frame-pointer=all < %s | FileCheck -check-prefix=FP-ALL %s

target triple = "kvx-kalray-cos"

; Original C code:
;
; int add(int n, ...);
;
; int fn(int *a) {
;   return add(a[0], a[1], a[2], a[3], a[4], a[5],
;              a[6], a[7], a[8], a[9], a[10], a[11],
;              a[12], a[13], a[14]) +
;          add(a[0], a[2], a[3], a[4], a[5], a[6],
;              a[7], a[8], a[9], a[10], a[11],
;              a[12], a[13], a[14]);
; }

define i32 @fn(i32* nocapture readonly %a) {
; FP-NONE-LABEL: fn:
; FP-NONE:       # %bb.0: # %entry
; FP-NONE-NEXT:    addd $r12 = $r12, -64
; FP-NONE-NEXT:    get $r16 = $ra
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    .cfi_def_cfa_offset 64
; FP-NONE-NEXT:    .cfi_register 67, 16
; FP-NONE-NEXT:    sd 56[$r12] = $r16
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    .cfi_offset 67, -8
; FP-NONE-NEXT:    sq 40[$r12] = $r18r19
; FP-NONE-NEXT:    copyd $r18 = $r0
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    .cfi_offset 18, -16
; FP-NONE-NEXT:    .cfi_offset 19, -24
; FP-NONE-NEXT:    lwz $r0 = 0[$r18]
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    lwz $r1 = 4[$r18]
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    lwz $r2 = 8[$r18]
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    lwz $r3 = 12[$r18]
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    lwz $r4 = 16[$r18]
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    lwz $r5 = 20[$r18]
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    lwz $r6 = 24[$r18]
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    lwz $r7 = 28[$r18]
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    lwz $r8 = 32[$r18]
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    lwz $r9 = 36[$r18]
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    lwz $r10 = 40[$r18]
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    lwz $r11 = 44[$r18]
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    lwz $r15 = 48[$r18]
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    lwz $r16 = 52[$r18]
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    lwz $r17 = 56[$r18]
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    sw 16[$r12] = $r17
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    sw 8[$r12] = $r16
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    sw 0[$r12] = $r15
; FP-NONE-NEXT:    call add
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    copyd $r19 = $r0
; FP-NONE-NEXT:    lwz $r0 = 0[$r18]
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    lwz $r1 = 8[$r18]
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    lwz $r2 = 12[$r18]
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    lwz $r3 = 16[$r18]
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    lwz $r4 = 20[$r18]
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    lwz $r5 = 24[$r18]
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    lwz $r6 = 28[$r18]
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    lwz $r7 = 32[$r18]
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    lwz $r8 = 36[$r18]
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    lwz $r9 = 40[$r18]
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    lwz $r10 = 44[$r18]
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    lwz $r11 = 48[$r18]
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    lwz $r15 = 52[$r18]
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    lwz $r16 = 56[$r18]
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    sw 8[$r12] = $r16
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    sw 0[$r12] = $r15
; FP-NONE-NEXT:    call add
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    addw $r0 = $r0, $r19
; FP-NONE-NEXT:    lq $r18r19 = 40[$r12]
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    ld $r16 = 56[$r12]
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    set $ra = $r16
; FP-NONE-NEXT:    addd $r12 = $r12, 64
; FP-NONE-NEXT:    ;;
; FP-NONE-NEXT:    ret
; FP-NONE-NEXT:    ;;
;
; FP-ALL-LABEL: fn:
; FP-ALL:       # %bb.0: # %entry
; FP-ALL-NEXT:    addd $r12 = $r12, -32
; FP-ALL-NEXT:    get $r16 = $ra
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    .cfi_def_cfa_offset 32
; FP-ALL-NEXT:    .cfi_register 67, 16
; FP-ALL-NEXT:    sd 24[$r12] = $r16
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    .cfi_offset 67, -8
; FP-ALL-NEXT:    sd 16[$r12] = $r14
; FP-ALL-NEXT:    addd $r14 = $r12, 16
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    .cfi_offset 14, -16
; FP-ALL-NEXT:    .cfi_def_cfa 14, 16
; FP-ALL-NEXT:    sq 0[$r12] = $r18r19
; FP-ALL-NEXT:    copyd $r18 = $r0
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    .cfi_offset 18, -24
; FP-ALL-NEXT:    .cfi_offset 19, -32
; FP-ALL-NEXT:    lwz $r0 = 0[$r18]
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    lwz $r1 = 4[$r18]
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    lwz $r2 = 8[$r18]
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    lwz $r3 = 12[$r18]
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    lwz $r4 = 16[$r18]
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    lwz $r5 = 20[$r18]
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    lwz $r6 = 24[$r18]
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    lwz $r7 = 28[$r18]
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    lwz $r8 = 32[$r18]
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    lwz $r9 = 36[$r18]
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    lwz $r10 = 40[$r18]
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    lwz $r11 = 44[$r18]
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    lwz $r15 = 48[$r18]
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    lwz $r16 = 52[$r18]
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    lwz $r17 = 56[$r18]
; FP-ALL-NEXT:    addd $r12 = $r12, -32
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    sw 16[$r12] = $r17
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    sw 8[$r12] = $r16
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    sw 0[$r12] = $r15
; FP-ALL-NEXT:    call add
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    addd $r12 = $r12, 32
; FP-ALL-NEXT:    copyd $r19 = $r0
; FP-ALL-NEXT:    lwz $r0 = 0[$r18]
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    lwz $r1 = 8[$r18]
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    lwz $r2 = 12[$r18]
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    lwz $r3 = 16[$r18]
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    lwz $r4 = 20[$r18]
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    lwz $r5 = 24[$r18]
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    lwz $r6 = 28[$r18]
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    lwz $r7 = 32[$r18]
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    lwz $r8 = 36[$r18]
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    lwz $r9 = 40[$r18]
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    lwz $r10 = 44[$r18]
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    lwz $r11 = 48[$r18]
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    lwz $r15 = 52[$r18]
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    lwz $r16 = 56[$r18]
; FP-ALL-NEXT:    addd $r12 = $r12, -32
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    sw 8[$r12] = $r16
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    sw 0[$r12] = $r15
; FP-ALL-NEXT:    call add
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    addd $r12 = $r12, 32
; FP-ALL-NEXT:    addw $r0 = $r0, $r19
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    addd $r12 = $r14, -16
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    lq $r18r19 = 0[$r12]
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    ld $r14 = 16[$r12]
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    ld $r16 = 24[$r12]
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    set $ra = $r16
; FP-ALL-NEXT:    addd $r12 = $r12, 32
; FP-ALL-NEXT:    ;;
; FP-ALL-NEXT:    ret
; FP-ALL-NEXT:    ;;
entry:
  %0 = load i32, i32* %a, align 4
  %arrayidx1 = getelementptr inbounds i32, i32* %a, i64 1
  %1 = load i32, i32* %arrayidx1, align 4
  %arrayidx2 = getelementptr inbounds i32, i32* %a, i64 2
  %2 = load i32, i32* %arrayidx2, align 4
  %arrayidx3 = getelementptr inbounds i32, i32* %a, i64 3
  %3 = load i32, i32* %arrayidx3, align 4
  %arrayidx4 = getelementptr inbounds i32, i32* %a, i64 4
  %4 = load i32, i32* %arrayidx4, align 4
  %arrayidx5 = getelementptr inbounds i32, i32* %a, i64 5
  %5 = load i32, i32* %arrayidx5, align 4
  %arrayidx6 = getelementptr inbounds i32, i32* %a, i64 6
  %6 = load i32, i32* %arrayidx6, align 4
  %arrayidx7 = getelementptr inbounds i32, i32* %a, i64 7
  %7 = load i32, i32* %arrayidx7, align 4
  %arrayidx8 = getelementptr inbounds i32, i32* %a, i64 8
  %8 = load i32, i32* %arrayidx8, align 4
  %arrayidx9 = getelementptr inbounds i32, i32* %a, i64 9
  %9 = load i32, i32* %arrayidx9, align 4
  %arrayidx10 = getelementptr inbounds i32, i32* %a, i64 10
  %10 = load i32, i32* %arrayidx10, align 4
  %arrayidx11 = getelementptr inbounds i32, i32* %a, i64 11
  %11 = load i32, i32* %arrayidx11, align 4
  %arrayidx12 = getelementptr inbounds i32, i32* %a, i64 12
  %12 = load i32, i32* %arrayidx12, align 4
  %arrayidx13 = getelementptr inbounds i32, i32* %a, i64 13
  %13 = load i32, i32* %arrayidx13, align 4
  %arrayidx14 = getelementptr inbounds i32, i32* %a, i64 14
  %14 = load i32, i32* %arrayidx14, align 4
  %call = tail call i32 (i32, ...) @add(i32 %0, i32 %1, i32 %2, i32 %3, i32 %4, i32 %5, i32 %6, i32 %7, i32 %8, i32 %9, i32 %10, i32 %11, i32 %12, i32 %13, i32 %14)
  %15 = load i32, i32* %a, align 4
  %16 = load i32, i32* %arrayidx2, align 4
  %17 = load i32, i32* %arrayidx3, align 4
  %18 = load i32, i32* %arrayidx4, align 4
  %19 = load i32, i32* %arrayidx5, align 4
  %20 = load i32, i32* %arrayidx6, align 4
  %21 = load i32, i32* %arrayidx7, align 4
  %22 = load i32, i32* %arrayidx8, align 4
  %23 = load i32, i32* %arrayidx9, align 4
  %24 = load i32, i32* %arrayidx10, align 4
  %25 = load i32, i32* %arrayidx11, align 4
  %26 = load i32, i32* %arrayidx12, align 4
  %27 = load i32, i32* %arrayidx13, align 4
  %28 = load i32, i32* %arrayidx14, align 4
  %call29 = tail call i32 (i32, ...) @add(i32 %15, i32 %16, i32 %17, i32 %18, i32 %19, i32 %20, i32 %21, i32 %22, i32 %23, i32 %24, i32 %25, i32 %26, i32 %27, i32 %28)
  %add = add nsw i32 %call29, %call
  ret i32 %add
}

declare i32 @add(i32, ...)
