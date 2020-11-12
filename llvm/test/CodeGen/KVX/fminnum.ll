; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=kvx-kalray-cos | FileCheck %s

define float @fminw(float %a, float %b) {
; CHECK-LABEL: fminw:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    get $r16 = $ra
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_def_cfa_offset 32
; CHECK-NEXT:    sd 0[$r12] = $r16
; CHECK-NEXT:    call fminf
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_offset 67, -32
; CHECK-NEXT:    ld $r16 = 0[$r12]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    set $ra = $r16
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_def_cfa_offset 0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %res = call float @llvm.minnum.f32(float %a, float %b)
  ret float %res
}

define dso_local float @fminw_fast(float %a, float %b) {
; CHECK-LABEL: fminw_fast:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    fminw $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = tail call fast float @llvm.minnum.f32(float %a, float %b)
  ret float %0
}

declare float @llvm.minnum.f32(float, float)

define double @fmind(double %a, double %b) {
; CHECK-LABEL: fmind:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    get $r16 = $ra
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_def_cfa_offset 32
; CHECK-NEXT:    sd 0[$r12] = $r16
; CHECK-NEXT:    call fmin
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_offset 67, -32
; CHECK-NEXT:    ld $r16 = 0[$r12]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    set $ra = $r16
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_def_cfa_offset 0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %res = call double @llvm.minnum.f64(double %a, double %b)
  ret double %res
}

define dso_local double @fmind_fast(double %a, double %b) {
; CHECK-LABEL: fmind_fast:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    fmind $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = tail call fast double @llvm.minnum.f64(double %a, double %b)
  ret double %0
}

declare double @llvm.minnum.f64(double, double)
