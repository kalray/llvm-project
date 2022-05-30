; RUN: llc < %s -mtriple=kvx -exception-model sjlj | FileCheck --check-prefixes=CHECK,ALL %s
; RUN: llc < %s -mtriple=kvx -relocation-model=pic -exception-model sjlj | FileCheck --check-prefixes=PIC,ALL %s

%struct.__jmp_buf_tag = type { [25 x i64], i64, [16 x i64] }

@buf = common global [1 x %struct.__jmp_buf_tag] zeroinitializer, align 8

define void @f_longjump() noreturn {
; ALL-LABEL: f_longjump:
; ALL:       # %bb.0:
; ALL-NEXT:    addd $r12 = $r12, -32
; ALL-NEXT:    ;;

; ALL-NEXT:    sd 24[$r12] = $r14
; CHECK-NEXT:  make $r0 = buf
; PIC-NEXT:    pcrel $r0 = @gotaddr()

; PIC-NEXT:    ;;
; PIC-NEXT:    ld $r0 = @got( buf )[$r0]

; ALL-NEXT:    ;;
; ALL-NEXT:    ld $r1 = 8[$r0]
; ALL-NEXT:    ;;
; ALL-NEXT:    ld $r14 = 0[$r0]
; ALL-NEXT:    ;;
; ALL-NEXT:    igoto $r1
; ALL-NEXT:    ld $r12 = 16[$r0]
; ALL-NEXT:    ;;
   tail call void @llvm.eh.sjlj.longjmp(i8* bitcast ([1 x %struct.__jmp_buf_tag]* @buf to i8*)) noreturn
   unreachable
}

declare void @llvm.eh.sjlj.longjmp(i8*) noreturn
