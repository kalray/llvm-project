; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -O2 < %s | FileCheck %s
target triple = "kvx-kalray-cos"

; EXTRACT ELEMENTS PATTERNS
; FROM <4 X DOUBLE>
define double @f64x4_extract_element_0(<4 x double> %0) {
; CHECK-LABEL: f64x4_extract_element_0:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ext = extractelement <4 x double> %0, i32 0
  ret double %ext
}

define double @f64x4_extract_element_0_not_aligned(i32 %i, <4 x double> %0) {
; CHECK-LABEL: f64x4_extract_element_0_not_aligned:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r0 = $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ext = extractelement <4 x double> %0, i32 0
  ret double %ext
}

define double @f64x4_extract_element_1(<4 x double> %0) {
; CHECK-LABEL: f64x4_extract_element_1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r0 = $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ext = extractelement <4 x double> %0, i32 1
  ret double %ext
}

define double @f64x4_extract_element_1_not_aligned(i32 %i, <4 x double> %0) {
; CHECK-LABEL: f64x4_extract_element_1_not_aligned:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r0 = $r2
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ext = extractelement <4 x double> %0, i32 1
  ret double %ext
}

define double @f64x4_extract_element_2(<4 x double> %0) {
; CHECK-LABEL: f64x4_extract_element_2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r0 = $r2
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ext = extractelement <4 x double> %0, i32 2
  ret double %ext
}

define double @f64x4_extract_element_3(<4 x double> %0) {
; CHECK-LABEL: f64x4_extract_element_3:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r0 = $r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ext = extractelement <4 x double> %0, i32 3
  ret double %ext
}

define <2 x double> @f64x4_extract_elements_01(<4 x double> %0) {
; CHECK-LABEL: f64x4_extract_elements_01:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ext = shufflevector <4 x double> %0, <4 x double> undef, <2 x i32> <i32 0, i32 1>
  ret <2 x double> %ext
}

; TODO: Vector swap can be done in 1 bunddle. And it could be a single copyq.
define <2 x double> @f64x4_extract_elements_10(<4 x double> %0) {
; CHECK-LABEL: f64x4_extract_elements_10:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r2 = $r0
; CHECK-NEXT:    copyd $r0 = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r1 = $r2
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ext = shufflevector <4 x double> %0, <4 x double> undef, <2 x i32> <i32 1, i32 0>
  ret <2 x double> %ext
}

define <2 x double> @f64x4_extract_elements_23(<4 x double> %0) {
; CHECK-LABEL: f64x4_extract_elements_23:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r1 = $r3
; CHECK-NEXT:    copyd $r0 = $r2
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ext = shufflevector <4 x double> %0, <4 x double> undef, <2 x i32> <i32 2, i32 3>
  ret <2 x double> %ext
}

define <2 x double> @f64x4_extract_elements_32(<4 x double> %0) {
; CHECK-LABEL: f64x4_extract_elements_32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r0 = $r3
; CHECK-NEXT:    copyd $r1 = $r2
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ext = shufflevector <4 x double> %0, <4 x double> undef, <2 x i32> <i32 3, i32 2>
  ret <2 x double> %ext
}

; FROM <4 X i64>
define i64 @i64x4_extract_element_0(<4 x i64> %0) {
; CHECK-LABEL: i64x4_extract_element_0:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ext = extractelement <4 x i64> %0, i32 0
  ret i64 %ext
}

define i64 @i64x4_extract_element_1(<4 x i64> %0) {
; CHECK-LABEL: i64x4_extract_element_1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r0 = $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ext = extractelement <4 x i64> %0, i32 1
  ret i64 %ext
}

define i64 @i64x4_extract_element_2(<4 x i64> %0) {
; CHECK-LABEL: i64x4_extract_element_2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r0 = $r2
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ext = extractelement <4 x i64> %0, i32 2
  ret i64 %ext
}

define i64 @i64x4_extract_element_3(<4 x i64> %0) {
; CHECK-LABEL: i64x4_extract_element_3:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r0 = $r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ext = extractelement <4 x i64> %0, i32 3
  ret i64 %ext
}

define <2 x i64> @i64x4_extract_elements_01(<4 x i64> %0) {
; CHECK-LABEL: i64x4_extract_elements_01:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ext = shufflevector <4 x i64> %0, <4 x i64> undef, <2 x i32> <i32 0, i32 1>
  ret <2 x i64> %ext
}

define <2 x i64> @i64x4_extract_elements_10(<4 x i64> %0) {
; CHECK-LABEL: i64x4_extract_elements_10:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r2 = $r0
; CHECK-NEXT:    copyd $r0 = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r1 = $r2
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ext = shufflevector <4 x i64> %0, <4 x i64> undef, <2 x i32> <i32 1, i32 0>
  ret <2 x i64> %ext
}

define <2 x i64> @i64x4_extract_elements_23(<4 x i64> %0) {
; CHECK-LABEL: i64x4_extract_elements_23:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r1 = $r3
; CHECK-NEXT:    copyd $r0 = $r2
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ext = shufflevector <4 x i64> %0, <4 x i64> undef, <2 x i32> <i32 2, i32 3>
  ret <2 x i64> %ext
}

define <2 x i64> @i64x4_extract_elements_32(<4 x i64> %0) {
; CHECK-LABEL: i64x4_extract_elements_32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r0 = $r3
; CHECK-NEXT:    copyd $r1 = $r2
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ext = shufflevector <4 x i64> %0, <4 x i64> undef, <2 x i32> <i32 3, i32 2>
  ret <2 x i64> %ext
}

; INSERT ELEMENTS PATTERNS
; TO <4 X DOUBLE>
define <4 x double> @f64x4_insert_elements_0(<4 x double> %0, double %1) {
; CHECK-LABEL: f64x4_insert_elements_0:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r0 = $r4
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ins = insertelement <4 x double> %0, double %1, i32 0
  ret <4 x double> %ins
}

define <4 x double> @f64x4_insert_elements_1(<4 x double> %0, double %1) {
; CHECK-LABEL: f64x4_insert_elements_1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r1 = $r4
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ins = insertelement <4 x double> %0, double %1, i32 1
  ret <4 x double> %ins
}

define <4 x double> @f64x4_insert_elements_2(<4 x double> %0, double %1) {
; CHECK-LABEL: f64x4_insert_elements_2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r2 = $r4
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ins = insertelement <4 x double> %0, double %1, i32 2
  ret <4 x double> %ins
}

define <4 x double> @f64x4_insert_elements_3(<4 x double> %0, double %1) {
; CHECK-LABEL: f64x4_insert_elements_3:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r3 = $r4
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ins = insertelement <4 x double> %0, double %1, i32 3
  ret <4 x double> %ins
}

; TODO: Single copyq
define <4 x double> @f64x4_insert_elements_01_1(<4 x double> %0, double %1) {
; CHECK-LABEL: f64x4_insert_elements_01_1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r0 = $r4
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r1 = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ins = insertelement <4 x double> %0, double %1, i32 0
  %ins2 = insertelement <4 x double> %ins, double %1, i32 1
  ret <4 x double> %ins2
}

define <4 x double> @f64x4_insert_elements_01(<4 x double> %0, double %1, double %2) {
; CHECK-LABEL: f64x4_insert_elements_01:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r1 = $r5
; CHECK-NEXT:    copyd $r0 = $r4
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ins = insertelement <4 x double> %0, double %1, i32 0
  %ins2 = insertelement <4 x double> %ins, double %2, i32 1
  ret <4 x double> %ins2
}

define <4 x double> @f64x4_insert_elements_10(<4 x double> %0, double %1, double %2) {
; CHECK-LABEL: f64x4_insert_elements_10:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r0 = $r5
; CHECK-NEXT:    copyd $r1 = $r4
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ins = insertelement <4 x double> %0, double %1, i32 1
  %ins2 = insertelement <4 x double> %ins, double %2, i32 0
  ret <4 x double> %ins2
}

define <4 x double> @f64x4_insert_elements_23_1(<4 x double> %0, double %1) {
; CHECK-LABEL: f64x4_insert_elements_23_1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r2 = $r4
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r3 = $r2
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ins = insertelement <4 x double> %0, double %1, i32 2
  %ins2 = insertelement <4 x double> %ins, double %1, i32 3
  ret <4 x double> %ins2
}

define <4 x double> @f64x4_insert_elements_23(<4 x double> %0, double %1, double %2) {
; CHECK-LABEL: f64x4_insert_elements_23:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r3 = $r5
; CHECK-NEXT:    copyd $r2 = $r4
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ins = insertelement <4 x double> %0, double %1, i32 2
  %ins2 = insertelement <4 x double> %ins, double %2, i32 3
  ret <4 x double> %ins2
}

define <4 x double> @f64x4_insert_elements_32(<4 x double> %0, double %1, double %2) {
; CHECK-LABEL: f64x4_insert_elements_32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r2 = $r5
; CHECK-NEXT:    copyd $r3 = $r4
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ins = insertelement <4 x double> %0, double %1, i32 3
  %ins2 = insertelement <4 x double> %ins, double %2, i32 2
  ret <4 x double> %ins2
}

define <4 x double> @f64x4_insert_elements_30(<4 x double> %0, double %1, double %2) {
; CHECK-LABEL: f64x4_insert_elements_30:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r0 = $r5
; CHECK-NEXT:    copyd $r3 = $r4
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ins = insertelement <4 x double> %0, double %1, i32 3
  %ins2 = insertelement <4 x double> %ins, double %2, i32 0
  ret <4 x double> %ins2
}

; TO <4 X i64>
define <4 x i64> @i64x4_insert_elements_0(<4 x i64> %0, i64 %1) {
; CHECK-LABEL: i64x4_insert_elements_0:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r0 = $r4
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ins = insertelement <4 x i64> %0, i64 %1, i32 0
  ret <4 x i64> %ins
}

define <4 x i64> @i64x4_insert_elements_1(<4 x i64> %0, i64 %1) {
; CHECK-LABEL: i64x4_insert_elements_1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r1 = $r4
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ins = insertelement <4 x i64> %0, i64 %1, i32 1
  ret <4 x i64> %ins
}

define <4 x i64> @i64x4_insert_elements_2(<4 x i64> %0, i64 %1) {
; CHECK-LABEL: i64x4_insert_elements_2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r2 = $r4
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ins = insertelement <4 x i64> %0, i64 %1, i32 2
  ret <4 x i64> %ins
}

define <4 x i64> @i64x4_insert_elements_3(<4 x i64> %0, i64 %1) {
; CHECK-LABEL: i64x4_insert_elements_3:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r3 = $r4
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ins = insertelement <4 x i64> %0, i64 %1, i32 3
  ret <4 x i64> %ins
}

define <4 x i64> @i64x4_insert_elements_01_1(<4 x i64> %0, i64 %1) {
; CHECK-LABEL: i64x4_insert_elements_01_1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r0 = $r4
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r1 = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ins = insertelement <4 x i64> %0, i64 %1, i32 0
  %ins2 = insertelement <4 x i64> %ins, i64 %1, i32 1
  ret <4 x i64> %ins2
}

define <4 x i64> @i64x4_insert_elements_01(<4 x i64> %0, i64 %1, i64 %2) {
; CHECK-LABEL: i64x4_insert_elements_01:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r1 = $r5
; CHECK-NEXT:    copyd $r0 = $r4
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ins = insertelement <4 x i64> %0, i64 %1, i32 0
  %ins2 = insertelement <4 x i64> %ins, i64 %2, i32 1
  ret <4 x i64> %ins2
}

define <4 x i64> @i64x4_insert_elements_10(<4 x i64> %0, i64 %1, i64 %2) {
; CHECK-LABEL: i64x4_insert_elements_10:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r0 = $r5
; CHECK-NEXT:    copyd $r1 = $r4
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ins = insertelement <4 x i64> %0, i64 %1, i32 1
  %ins2 = insertelement <4 x i64> %ins, i64 %2, i32 0
  ret <4 x i64> %ins2
}
;
define <4 x i64> @i64x4_insert_elements_23_1(<4 x i64> %0, i64 %1) {
; CHECK-LABEL: i64x4_insert_elements_23_1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r2 = $r4
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r3 = $r2
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ins = insertelement <4 x i64> %0, i64 %1, i32 2
  %ins2 = insertelement <4 x i64> %ins, i64 %1, i32 3
  ret <4 x i64> %ins2
}

; TODO: Can optiomize to a single copyq
define <4 x i64> @i64x4_insert_elements_23(<4 x i64> %0, i64 %1, i64 %2) {
; CHECK-LABEL: i64x4_insert_elements_23:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r3 = $r5
; CHECK-NEXT:    copyd $r2 = $r4
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ins = insertelement <4 x i64> %0, i64 %1, i32 2
  %ins2 = insertelement <4 x i64> %ins, i64 %2, i32 3
  ret <4 x i64> %ins2
}

; TODO: Can optiomize to a single copyq
define <4 x i64> @i64x4_insert_elements_32(<4 x i64> %0, i64 %1, i64 %2) {
; CHECK-LABEL: i64x4_insert_elements_32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r2 = $r5
; CHECK-NEXT:    copyd $r3 = $r4
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ins = insertelement <4 x i64> %0, i64 %1, i32 3
  %ins2 = insertelement <4 x i64> %ins, i64 %2, i32 2
  ret <4 x i64> %ins2
}

define <4 x i64> @i64x4_insert_elements_20(<4 x i64> %0, i64 %1, i64 %2) {
; CHECK-LABEL: i64x4_insert_elements_20:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r0 = $r5
; CHECK-NEXT:    copyd $r2 = $r4
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ins = insertelement <4 x i64> %0, i64 %1, i32 2
  %ins2 = insertelement <4 x i64> %ins, i64 %2, i32 0
  ret <4 x i64> %ins2
}

define <4 x i64> @i64x4_insert_elements_12(<4 x i64> %0, i64 %1, i64 %2) {
; CHECK-LABEL: i64x4_insert_elements_12:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r2 = $r5
; CHECK-NEXT:    copyd $r1 = $r4
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ins = insertelement <4 x i64> %0, i64 %1, i32 1
  %ins2 = insertelement <4 x i64> %ins, i64 %2, i32 2
  ret <4 x i64> %ins2
}

; TODO: The copy can be in a single copyq
define <4 x i64> @i64x4_insert_elements_21_1(<4 x i64> %0, i64 %1) {
; CHECK-LABEL: i64x4_insert_elements_21_1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r1 = $r4
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r2 = $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %ins = insertelement <4 x i64> %0, i64 %1, i32 2
  %ins2 = insertelement <4 x i64> %ins, i64 %1, i32 1
  ret <4 x i64> %ins2
}

; TODOO: Eliminate redundant copyq
define void @v4i64_upper_half_extract(<4 x i64> *%0,  <2 x i64> * %1){
; CHECK-LABEL: v4i64_upper_half_extract:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lo $r4r5r6r7 = 0[$r0]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sq 0[$r1] = $r6r7
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %2 = load <4 x i64>, <4 x i64> * %0, align 32
  %3 = shufflevector <4 x i64> %2, <4 x i64> undef, <2 x i32> <i32 2, i32 3>
  store <2 x i64> %3, <2 x i64> * %1, align 16
  ret void
}

define void @v4i64_upper_half_extract_unaligned(i32 %i, <4 x i64> %0,  <2 x i64> * %1){
; CHECK-LABEL: v4i64_upper_half_extract_unaligned:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    copyd $r1 = $r4
; CHECK-NEXT:    copyd $r0 = $r3
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sq 0[$r5] = $r0r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %2 = shufflevector <4 x i64> %0, <4 x i64> undef, <2 x i32> <i32 2, i32 3>
  store <2 x i64> %2, <2 x i64> * %1, align 16
  ret void
}


define void @v4i64_lower_half_extract(<4 x i64> * %0,  <2 x i64> * %1){
; CHECK-LABEL: v4i64_lower_half_extract:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lo $r4r5r6r7 = 0[$r0]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sq 0[$r1] = $r4r5
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %2 = load <4 x i64>, <4 x i64> * %0, align 32
  %3 = shufflevector <4 x i64> %2, <4 x i64> undef, <2 x i32> <i32 0, i32 1>
  store <2 x i64> %3, <2 x i64> * %1, align 16
  ret void
}

define void @v4i64_middle_extract(<4 x i64> *%0,  <2 x i64> * %1){
; CHECK-LABEL: v4i64_middle_extract:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lo $r4r5r6r7 = 0[$r0]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r2 = $r5
; CHECK-NEXT:    copyd $r3 = $r6
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sq 0[$r1] = $r2r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %2 = load <4 x i64>, <4 x i64> * %0, align 32
  %3 = shufflevector <4 x i64> %2, <4 x i64> undef, <2 x i32> <i32 1, i32 2>
  store <2 x i64> %3, <2 x i64> * %1, align 16
  ret void
}

define void @v2i64_concat_v4i64(<2 x i64> *%0, <2 x i64> *%1, <4 x i64> *%2){
; CHECK-LABEL: v2i64_concat_v4i64:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lq $r4r5 = 0[$r0]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lq $r6r7 = 0[$r1]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    so 0[$r2] = $r4r5r6r7
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %3 = load <2 x i64>, <2 x i64> * %0, align 16
  %4 = load <2 x i64>, <2 x i64> * %1, align 16
  %5 = shufflevector <2 x i64> %3, <2 x i64> %4, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  store <4 x i64> %5, <4 x i64> * %2, align 32
  ret void
}


define void @v4double_upper_half_extract(<4 x double> *%0,  <2 x double> * %1){
; CHECK-LABEL: v4double_upper_half_extract:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lo $r4r5r6r7 = 0[$r0]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sq 0[$r1] = $r6r7
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %2 = load <4 x double>, <4 x double> * %0, align 32
  %3 = shufflevector <4 x double> %2, <4 x double> undef, <2 x i32> <i32 2, i32 3>
  store <2 x double> %3, <2 x double> * %1, align 16
  ret void
}

define void @v4double_lower_half_extract(<4 x double> *%0,  <2 x double> * %1){
; CHECK-LABEL: v4double_lower_half_extract:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lo $r4r5r6r7 = 0[$r0]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sq 0[$r1] = $r4r5
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %2 = load <4 x double>, <4 x double> * %0, align 32
  %3 = shufflevector <4 x double> %2, <4 x double> undef, <2 x i32> <i32 0, i32 1>
  store <2 x double> %3, <2 x double> * %1, align 16
  ret void
}

define void @v4double_middle_extract(<4 x double> *%0,  <2 x double> * %1){
; CHECK-LABEL: v4double_middle_extract:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lo $r4r5r6r7 = 0[$r0]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r2 = $r5
; CHECK-NEXT:    copyd $r3 = $r6
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sq 0[$r1] = $r2r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %2 = load <4 x double>, <4 x double> * %0, align 32
  %3 = shufflevector <4 x double> %2, <4 x double> undef, <2 x i32> <i32 1, i32 2>
  store <2 x double> %3, <2 x double> * %1, align 16
  ret void
}

define void @v2double_concat_v4double(<2 x double> *%0, <2 x double> *%1, <4 x double> *%2){
; CHECK-LABEL: v2double_concat_v4double:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lq $r4r5 = 0[$r0]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lq $r6r7 = 0[$r1]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    so 0[$r2] = $r4r5r6r7
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %3 = load <2 x double>, <2 x double> * %0, align 16
  %4 = load <2 x double>, <2 x double> * %1, align 16
  %5 = shufflevector <2 x double> %3, <2 x double> %4, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  store <4 x double> %5, <4 x double> * %2, align 32
  ret void
}

define void @v2double_concat_v4double_unaligned(double * align 1 %0, <4 x double>* %out){
; CHECK-LABEL: v2double_concat_v4double_unaligned:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lq $r4r5 = 0[$r0]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lq $r6r7 = 64[$r0]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    so 0[$r1] = $r4r5r6r7
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %1 = bitcast double* %0 to <2 x double> *
  %2 = getelementptr <2 x double>, <2 x double>* %1, i32 4
  %3 = load <2 x double>, <2 x double> * %1
  %4 = load <2 x double>, <2 x double> * %2
  %5 = shufflevector <2 x double> %3, <2 x double> %4, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  store <4 x double> %5, <4 x double> * %out, align 32
  ret void
}

define void @v2i64_concat_v4i64_unaligned(i64 * align 1 %0, <4 x i64>* %out){
; CHECK-LABEL: v2i64_concat_v4i64_unaligned:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lq $r4r5 = 0[$r0]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lq $r6r7 = 64[$r0]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    so 0[$r1] = $r4r5r6r7
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %1 = bitcast i64* %0 to <2 x i64> *
  %2 = getelementptr <2 x i64>, <2 x i64>* %1, i32 4
  %3 = load <2 x i64>, <2 x i64> * %1
  %4 = load <2 x i64>, <2 x i64> * %2
  %5 = shufflevector <2 x i64> %3, <2 x i64> %4, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  store <4 x i64> %5, <4 x i64> * %out, align 32
  ret void
}

define void @v2i64_concat_v4i64_unaligned2(i64* nocapture readonly %0){
; CHECK-LABEL: v2i64_concat_v4i64_unaligned2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    lq $r4r5 = 0[$r0]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_def_cfa_offset 32
; CHECK-NEXT:    lq $r6r7 = 64[$r0]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    so 0[$r12] = $r4r5r6r7
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %2 = alloca <4 x i64>, align 32
  %3 = bitcast i64* %0 to <2 x i64>*
  %4 = load <2 x i64>, <2 x i64>* %3, align 8
  %5 = getelementptr inbounds i64, i64* %0, i64 8
  %6 = bitcast i64* %5 to <2 x i64>*
  %7 = load <2 x i64>, <2 x i64>* %6, align 8
  %8 = bitcast <4 x i64>* %2 to i8*
  %9 = shufflevector <2 x i64> %4, <2 x i64> %7, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  store volatile <4 x i64> %9, <4 x i64>* %2, align 32
  ret void
}
