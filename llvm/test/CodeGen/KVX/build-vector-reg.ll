; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -O1 -o - %s | FileCheck %s
target triple = "kvx-kalray-cos"

define <2 x i8> @bchar2(i8 %a, i8 %b) {
; CHECK-LABEL: bchar2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    insf $r0 = $r1, 15, 8
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %vecinit = insertelement <2 x i8> undef, i8 %a, i32 0
  %vecinit1 = insertelement <2 x i8> %vecinit, i8 %b, i32 1
  ret <2 x i8> %vecinit1
}

define <2 x i16> @bshort2(i16 %a, i16 %b) {
; CHECK-LABEL: bshort2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    insf $r0 = $r1, 31, 16
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %vecinit = insertelement <2 x i16> undef, i16 %a, i32 0
  %vecinit1 = insertelement <2 x i16> %vecinit, i16 %b, i32 1
  ret <2 x i16> %vecinit1
}

define <2 x i32> @bint2(i32 %a, i32 %b) {
; CHECK-LABEL: bint2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    insf $r0 = $r1, 63, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %vecinit = insertelement <2 x i32> undef, i32 %a, i32 0
  %vecinit1 = insertelement <2 x i32> %vecinit, i32 %b, i32 1
  ret <2 x i32> %vecinit1
}

define <2 x i64> @blong2(i64 %a, i64 %b) {
; CHECK-LABEL: blong2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %vecinit = insertelement <2 x i64> undef, i64 %a, i32 0
  %vecinit1 = insertelement <2 x i64> %vecinit, i64 %b, i32 1
  ret <2 x i64> %vecinit1
}

define <4 x i8> @bchar4(i8 %a, i8 %b, i8 %c, i8 %d) {
; CHECK-LABEL: bchar4:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    insf $r2 = $r3, 15, 8
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r0 = $r1, 15, 8
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r0 = $r2, 31, 16
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %vecinit = insertelement <4 x i8> undef, i8 %a, i32 0
  %vecinit1 = insertelement <4 x i8> %vecinit, i8 %b, i32 1
  %vecinit2 = insertelement <4 x i8> %vecinit1, i8 %c, i32 2
  %vecinit3 = insertelement <4 x i8> %vecinit2, i8 %d, i32 3
  ret <4 x i8> %vecinit3
}

define <4 x i16> @bshort4(i16 %a, i16 %b, i16 %c, i16 %d) {
; CHECK-LABEL: bshort4:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    insf $r2 = $r3, 31, 16
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r0 = $r1, 31, 16
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r0 = $r2, 63, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %vecinit = insertelement <4 x i16> undef, i16 %a, i32 0
  %vecinit1 = insertelement <4 x i16> %vecinit, i16 %b, i32 1
  %vecinit2 = insertelement <4 x i16> %vecinit1, i16 %c, i32 2
  %vecinit3 = insertelement <4 x i16> %vecinit2, i16 %d, i32 3
  ret <4 x i16> %vecinit3
}

define <4 x i32> @bint4(i32 %a, i32 %b, i32 %c, i32 %d) {
; CHECK-LABEL: bint4:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    insf $r0 = $r1, 63, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r2 = $r3, 63, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r1 = $r2
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %vecinit = insertelement <4 x i32> undef, i32 %a, i32 0
  %vecinit1 = insertelement <4 x i32> %vecinit, i32 %b, i32 1
  %vecinit2 = insertelement <4 x i32> %vecinit1, i32 %c, i32 2
  %vecinit3 = insertelement <4 x i32> %vecinit2, i32 %d, i32 3
  ret <4 x i32> %vecinit3
}

define <4 x i64> @blong4(i64 %a, i64 %b, i64 %c, i64 %d) {
; CHECK-LABEL: blong4:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %vecinit = insertelement <4 x i64> undef, i64 %a, i32 0
  %vecinit1 = insertelement <4 x i64> %vecinit, i64 %b, i32 1
  %vecinit2 = insertelement <4 x i64> %vecinit1, i64 %c, i32 2
  %vecinit3 = insertelement <4 x i64> %vecinit2, i64 %d, i32 3
  ret <4 x i64> %vecinit3
}

define <8 x i8> @bchar8(i8 %a, i8 %b, i8 %c, i8 %d, i8 %e, i8 %f, i8 %g, i8 %h) {
; CHECK-LABEL: bchar8:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    insf $r6 = $r7, 15, 8
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r4 = $r5, 15, 8
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r2 = $r3, 15, 8
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r0 = $r1, 15, 8
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r4 = $r6, 31, 16
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r0 = $r2, 31, 16
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r0 = $r4, 63, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %vecinit = insertelement <8 x i8> undef, i8 %a, i32 0
  %vecinit1 = insertelement <8 x i8> %vecinit, i8 %b, i32 1
  %vecinit2 = insertelement <8 x i8> %vecinit1, i8 %c, i32 2
  %vecinit3 = insertelement <8 x i8> %vecinit2, i8 %d, i32 3
  %vecinit4 = insertelement <8 x i8> %vecinit3, i8 %e, i32 4
  %vecinit5 = insertelement <8 x i8> %vecinit4, i8 %f, i32 5
  %vecinit6 = insertelement <8 x i8> %vecinit5, i8 %g, i32 6
  %vecinit7 = insertelement <8 x i8> %vecinit6, i8 %h, i32 7
  ret <8 x i8> %vecinit7
}

define <8 x i16> @bshort8(i16 %a, i16 %b, i16 %c, i16 %d, i16 %e, i16 %f, i16 %g, i16 %h) {
; CHECK-LABEL: bshort8:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    insf $r2 = $r3, 31, 16
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r0 = $r1, 31, 16
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r6 = $r7, 31, 16
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r4 = $r5, 31, 16
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r0 = $r2, 63, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r4 = $r6, 63, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r1 = $r4
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %vecinit = insertelement <8 x i16> undef, i16 %a, i32 0
  %vecinit1 = insertelement <8 x i16> %vecinit, i16 %b, i32 1
  %vecinit2 = insertelement <8 x i16> %vecinit1, i16 %c, i32 2
  %vecinit3 = insertelement <8 x i16> %vecinit2, i16 %d, i32 3
  %vecinit4 = insertelement <8 x i16> %vecinit3, i16 %e, i32 4
  %vecinit5 = insertelement <8 x i16> %vecinit4, i16 %f, i32 5
  %vecinit6 = insertelement <8 x i16> %vecinit5, i16 %g, i32 6
  %vecinit7 = insertelement <8 x i16> %vecinit6, i16 %h, i32 7
  ret <8 x i16> %vecinit7
}

define <8 x i32> @bint8(i32 %a, i32 %b, i32 %c, i32 %d, i32 %e, i32 %f, i32 %g, i32 %h) {
; CHECK-LABEL: bint8:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    insf $r0 = $r1, 63, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r2 = $r3, 63, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r4 = $r5, 63, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r6 = $r7, 63, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r1 = $r2
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r2 = $r4
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r3 = $r6
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %vecinit = insertelement <8 x i32> undef, i32 %a, i32 0
  %vecinit1 = insertelement <8 x i32> %vecinit, i32 %b, i32 1
  %vecinit2 = insertelement <8 x i32> %vecinit1, i32 %c, i32 2
  %vecinit3 = insertelement <8 x i32> %vecinit2, i32 %d, i32 3
  %vecinit4 = insertelement <8 x i32> %vecinit3, i32 %e, i32 4
  %vecinit5 = insertelement <8 x i32> %vecinit4, i32 %f, i32 5
  %vecinit6 = insertelement <8 x i32> %vecinit5, i32 %g, i32 6
  %vecinit7 = insertelement <8 x i32> %vecinit6, i32 %h, i32 7
  ret <8 x i32> %vecinit7
}

define void @blong8(<8 x i64>* noalias nocapture sret %agg.result, i64 %a, i64 %b, i64 %c, i64 %d, i64 %e, i64 %f, i64 %g, i64 %h) {
; CHECK-LABEL: blong8:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    so 32[$r15] = $r4r5r6r7
; CHECK-NEXT:    ;;
; CHECK-NEXT:    so 0[$r15] = $r0r1r2r3
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r0 = $r15
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %vecinit = insertelement <8 x i64> undef, i64 %a, i32 0
  %vecinit1 = insertelement <8 x i64> %vecinit, i64 %b, i32 1
  %vecinit2 = insertelement <8 x i64> %vecinit1, i64 %c, i32 2
  %vecinit3 = insertelement <8 x i64> %vecinit2, i64 %d, i32 3
  %vecinit4 = insertelement <8 x i64> %vecinit3, i64 %e, i32 4
  %vecinit5 = insertelement <8 x i64> %vecinit4, i64 %f, i32 5
  %vecinit6 = insertelement <8 x i64> %vecinit5, i64 %g, i32 6
  %vecinit7 = insertelement <8 x i64> %vecinit6, i64 %h, i32 7
  store <8 x i64> %vecinit7, <8 x i64>* %agg.result, align 32
  ret void
}

define <2 x half> @bhalf2(half %a, half %b) {
; CHECK-LABEL: bhalf2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    insf $r0 = $r1, 31, 16
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %vecinit = insertelement <2 x half> undef, half %a, i32 0
  %vecinit1 = insertelement <2 x half> %vecinit, half %b, i32 1
  ret <2 x half> %vecinit1
}

define <2 x float> @bfloat2(float %a, float %b) {
; CHECK-LABEL: bfloat2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    insf $r0 = $r1, 63, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %vecinit = insertelement <2 x float> undef, float %a, i32 0
  %vecinit1 = insertelement <2 x float> %vecinit, float %b, i32 1
  ret <2 x float> %vecinit1
}

define <2 x double> @bdouble2(double %a, double %b) {
; CHECK-LABEL: bdouble2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %vecinit = insertelement <2 x double> undef, double %a, i32 0
  %vecinit1 = insertelement <2 x double> %vecinit, double %b, i32 1
  ret <2 x double> %vecinit1
}

define <4 x half> @bhalf4(half %a, half %b, half %c, half %d) {
; CHECK-LABEL: bhalf4:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    insf $r2 = $r3, 31, 16
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r0 = $r1, 31, 16
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r0 = $r2, 63, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %vecinit = insertelement <4 x half> undef, half %a, i32 0
  %vecinit1 = insertelement <4 x half> %vecinit, half %b, i32 1
  %vecinit2 = insertelement <4 x half> %vecinit1, half %c, i32 2
  %vecinit3 = insertelement <4 x half> %vecinit2, half %d, i32 3
  ret <4 x half> %vecinit3
}

define <4 x float> @bfloat4(float %a, float %b, float %c, float %d) {
; CHECK-LABEL: bfloat4:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    insf $r0 = $r1, 63, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r2 = $r3, 63, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r1 = $r2
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %vecinit = insertelement <4 x float> undef, float %a, i32 0
  %vecinit1 = insertelement <4 x float> %vecinit, float %b, i32 1
  %vecinit2 = insertelement <4 x float> %vecinit1, float %c, i32 2
  %vecinit3 = insertelement <4 x float> %vecinit2, float %d, i32 3
  ret <4 x float> %vecinit3
}

define <4 x double> @bdouble4(double %a, double %b, double %c, double %d) {
; CHECK-LABEL: bdouble4:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %vecinit = insertelement <4 x double> undef, double %a, i32 0
  %vecinit1 = insertelement <4 x double> %vecinit, double %b, i32 1
  %vecinit2 = insertelement <4 x double> %vecinit1, double %c, i32 2
  %vecinit3 = insertelement <4 x double> %vecinit2, double %d, i32 3
  ret <4 x double> %vecinit3
}

define <8 x half> @bhalf8(half %a, half %b, half %c, half %d, half %e, half %f, half %g, half %h) {
; CHECK-LABEL: bhalf8:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    insf $r2 = $r3, 31, 16
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r0 = $r1, 31, 16
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r6 = $r7, 31, 16
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r4 = $r5, 31, 16
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r0 = $r2, 63, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r4 = $r6, 63, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r1 = $r4
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %vecinit = insertelement <8 x half> undef, half %a, i32 0
  %vecinit1 = insertelement <8 x half> %vecinit, half %b, i32 1
  %vecinit2 = insertelement <8 x half> %vecinit1, half %c, i32 2
  %vecinit3 = insertelement <8 x half> %vecinit2, half %d, i32 3
  %vecinit4 = insertelement <8 x half> %vecinit3, half %e, i32 4
  %vecinit5 = insertelement <8 x half> %vecinit4, half %f, i32 5
  %vecinit6 = insertelement <8 x half> %vecinit5, half %g, i32 6
  %vecinit7 = insertelement <8 x half> %vecinit6, half %h, i32 7
  ret <8 x half> %vecinit7
}

define <8 x float> @bfloat8(float %a, float %b, float %c, float %d, float %e, float %f, float %g, float %h) {
; CHECK-LABEL: bfloat8:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    insf $r0 = $r1, 63, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r2 = $r3, 63, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r4 = $r5, 63, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r6 = $r7, 63, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r1 = $r2
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r2 = $r4
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r3 = $r6
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %vecinit = insertelement <8 x float> undef, float %a, i32 0
  %vecinit1 = insertelement <8 x float> %vecinit, float %b, i32 1
  %vecinit2 = insertelement <8 x float> %vecinit1, float %c, i32 2
  %vecinit3 = insertelement <8 x float> %vecinit2, float %d, i32 3
  %vecinit4 = insertelement <8 x float> %vecinit3, float %e, i32 4
  %vecinit5 = insertelement <8 x float> %vecinit4, float %f, i32 5
  %vecinit6 = insertelement <8 x float> %vecinit5, float %g, i32 6
  %vecinit7 = insertelement <8 x float> %vecinit6, float %h, i32 7
  ret <8 x float> %vecinit7
}

define void @bdouble8(<8 x double>* noalias nocapture sret %agg.result, double %a, double %b, double %c, double %d, double %e, double %f, double %g, double %h) {
; CHECK-LABEL: bdouble8:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    so 32[$r15] = $r4r5r6r7
; CHECK-NEXT:    ;;
; CHECK-NEXT:    so 0[$r15] = $r0r1r2r3
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r0 = $r15
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %vecinit = insertelement <8 x double> undef, double %a, i32 0
  %vecinit1 = insertelement <8 x double> %vecinit, double %b, i32 1
  %vecinit2 = insertelement <8 x double> %vecinit1, double %c, i32 2
  %vecinit3 = insertelement <8 x double> %vecinit2, double %d, i32 3
  %vecinit4 = insertelement <8 x double> %vecinit3, double %e, i32 4
  %vecinit5 = insertelement <8 x double> %vecinit4, double %f, i32 5
  %vecinit6 = insertelement <8 x double> %vecinit5, double %g, i32 6
  %vecinit7 = insertelement <8 x double> %vecinit6, double %h, i32 7
  store <8 x double> %vecinit7, <8 x double>* %agg.result, align 32
  ret void
}
