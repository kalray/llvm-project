; RUN: llc -o - %s -mtriple=kvx -exception-model sjlj | FileCheck --check-prefixes=CHECK,ALL %s
; RUN: llc -o - %s -mtriple=kvx -relocation-model=pic -exception-model sjlj | FileCheck --check-prefixes=PIC,ALL %s

define i8* @test_lsda() {
; ALL-LABEL: test_lsda:
; ALL:       # %bb.0:

; CHECK-NEXT:    make $r0 = GCC_except_table0

; PIC-NEXT:    pcrel $r0 = @gotaddr()
; PIC-NEXT:    ;;
; PIC-NEXT:    addd $r0 = $r0, @gotoff( GCC_except_table0 )

; ALL-NEXT:    ret
; ALL-NEXT:    ;;
  %ret = call i8* @llvm.eh.sjlj.lsda()
  ret i8* %ret
}

declare i8* @llvm.eh.sjlj.lsda()
