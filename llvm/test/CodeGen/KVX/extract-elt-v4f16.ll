; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -O2 | FileCheck %s
target triple = "kvx-kalray-cos"

define half @f1(<4 x half> %v){
; CHECK-LABEL: f1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    extfz $r0 = $r0, 15, 0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %vecext = extractelement <4 x half> %v, i32 0
  ret half %vecext
}

define half @f2(<4 x half> %v){
; CHECK-LABEL: f2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    extfz $r0 = $r0, 31, 16
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %vecext = extractelement <4 x half> %v, i32 1
  ret half %vecext
}

define half @f3(<4 x half> %v){
; CHECK-LABEL: f3:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    extfz $r0 = $r0, 47, 32
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %vecext = extractelement <4 x half> %v, i32 2
  ret half %vecext
}

define half @f4(<4 x half> %v){
; CHECK-LABEL: f4:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    srld $r0 = $r0, 48
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %vecext = extractelement <4 x half> %v, i32 3
  ret half %vecext
}

define half @fidx(<4 x half> %v, i32 %idx){
; CHECK-LABEL: fidx:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_def_cfa_offset 32
; CHECK-NEXT:    sd 24[$r12] = $r0
; CHECK-NEXT:    andd $r0 = $r1, 3
; CHECK-NEXT:    addd $r1 = $r12, 24
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lhz.xs $r0 = $r0[$r1]
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %vecext = extractelement <4 x half> %v, i32 %idx
  ret half %vecext
}

