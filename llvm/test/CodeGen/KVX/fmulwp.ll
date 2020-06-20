; RUN: llc < %s | FileCheck %s

define <2 x float> @t(<2 x float> %a, <2 x float> %b) {
entry:
  %mul = fmul <2 x float> %a, %b
  ret <2 x float> %mul
; CHECK: t:
; CHECK: fmulwp
; CHECK: ret
; CHECK-NEXT: ;;
}
