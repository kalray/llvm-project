; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -O2 | FileCheck %s
target triple = "kvx-kalray-cos"

define <2 x i16> @sri_v2i16(<2 x i16> %a){
; CHECK-LABEL: sri_v2i16:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    make $r1 = 0x30003
; CHECK-NEXT:    ;;
; CHECK-NEXT:    srahqs $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %shr = ashr <2 x i16> %a, <i16 3, i16 3>
  ret <2 x i16> %shr
}

define <2 x i16> @sli_v2i16(<2 x i16> %a){
; CHECK-LABEL: sli_v2i16:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    make $r1 = 0x30003
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sllhqs $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %shl = shl <2 x i16> %a, <i16 3, i16 3>
  ret <2 x i16> %shl
}

define <2 x i16> @srr_v2i16(<2 x i16> %a, i16 %c){
; CHECK-LABEL: srr_v2i16:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    insf $r1 = $r1, 31, 16
; CHECK-NEXT:    ;;
; CHECK-NEXT:    srahqs $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = insertelement <2 x i16> undef, i16 %c, i32 0
  %sh_prom = shufflevector <2 x i16> %0, <2 x i16> undef, <2 x i32> zeroinitializer
  %shr = ashr <2 x i16> %a, %sh_prom
  ret <2 x i16> %shr
}

define <2 x i16> @slr_v2i16(<2 x i16> %a, i16 %c){
; CHECK-LABEL: slr_v2i16:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    insf $r1 = $r1, 31, 16
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sllhqs $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = insertelement <2 x i16> undef, i16 %c, i32 0
  %sh_prom = shufflevector <2 x i16> %0, <2 x i16> undef, <2 x i32> zeroinitializer
  %shl = shl <2 x i16> %a, %sh_prom
  ret <2 x i16> %shl
}

