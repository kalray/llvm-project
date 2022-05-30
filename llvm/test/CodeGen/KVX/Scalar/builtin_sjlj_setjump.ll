; RUN: llc < %s -mtriple=kvx -exception-model sjlj | FileCheck --check-prefixes=CHECK,ALL %s
; RUN: llc < %s -mtriple=kvx -relocation-model=pic -exception-model sjlj | FileCheck --check-prefixes=PIC,ALL %s

%struct.__jmp_buf_tag = type { [25 x i64], i64, [16 x i64] }

@buf = common global [1 x %struct.__jmp_buf_tag] zeroinitializer, align 8

define i32 @f_setjmp() {
; ALL-LABEL: f_setjmp:
; ALL:       # %bb.0:
; ALL-NEXT:    addd $r12 = $r12, -128
; ALL-NEXT:    get $r16 = $ra
; ALL-NEXT:    ;;
; ALL-NEXT:    sd 120[$r12] = $r16
; ALL-NEXT:    ;;
; ALL-NEXT:    sd 112[$r12] = $r14
; ALL-NEXT:    ;;
; ALL-NEXT:    so 80[$r12] = $r28r29r30r31
; ALL-NEXT:    ;;
; ALL-NEXT:    so 48[$r12] = $r24r25r26r27
; ALL-NEXT:    ;;
; ALL-NEXT:    so 16[$r12] = $r20r21r22r23
; ALL-NEXT:    ;;
; ALL-NEXT:    sq 0[$r12] = $r18r19

; CHECK-NEXT:    make $r0 = buf
; CHECK-NEXT:    make $r1 = .LBB0_3

; PIC-NEXT:    pcrel $r0 = @gotaddr()
; PIC-NEXT:    ;;
; PIC-NEXT:    ld $r0 = @got( buf )[$r0]
; PIC-NEXT:    pcrel $r1 = @pcrel( .LBB0_3 )

; CHECK-NEXT:    ;;
; CHECK-NEXT:    sd 8[$r0] = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.1:
; CHECK-NEXT:    make $r0 = 0
; CHECK-NEXT:    goto .LBB0_2
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB0_3: # Block address taken
; CHECK-NEXT:    make $r0 = 1
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB0_2:
; CHECK-NEXT:    lq $r18r19 = 0[$r12]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lo $r20r21r22r23 = 16[$r12]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lo $r24r25r26r27 = 48[$r12]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lo $r28r29r30r31 = 80[$r12]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r14 = 112[$r12]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r16 = 120[$r12]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    set $ra = $r16
; CHECK-NEXT:    addd $r12 = $r12, 128
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
;
   %1 = call i32 @llvm.eh.sjlj.setjmp(i8* bitcast ([1 x %struct.__jmp_buf_tag]* @buf to i8*))
   ret i32 %1
}

declare i32 @llvm.eh.sjlj.setjmp(i8*) nounwind
