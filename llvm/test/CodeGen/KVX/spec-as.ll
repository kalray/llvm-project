; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -O2 | FileCheck %s
target triple = "kvx-kalray-cos"

%struct.S = type { i32, i32, i32, i32 }

define i8 @speculative_i8(i8 addrspace(258)* nocapture readonly %i){
; CHECK-LABEL: speculative_i8:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lbz.s $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = load i8, i8 addrspace(258)* %i, align 1
  ret i8 %0
}

define i16 @speculative_i16(i16 addrspace(258)* nocapture readonly %i){
; CHECK-LABEL: speculative_i16:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lhz.s $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = load i16, i16 addrspace(258)* %i, align 2
  ret i16 %0
}

define i32 @speculative_i32(i32 addrspace(258)* nocapture readonly %i){
; CHECK-LABEL: speculative_i32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz.s $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = load i32, i32 addrspace(258)* %i, align 4
  ret i32 %0
}

define i64 @speculative_i64(i64 addrspace(258)* nocapture readonly %i){
; CHECK-LABEL: speculative_i64:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    ld.s $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = load i64, i64 addrspace(258)* %i, align 8
  ret i64 %0
}

define float @fspeculative_f32(float addrspace(258)* nocapture readonly %f){
; CHECK-LABEL: fspeculative_f32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz.s $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = load float, float addrspace(258)* %f, align 4
  ret float %0
}

define double @fspeculative_f64(double addrspace(258)* nocapture readonly %d){
; CHECK-LABEL: fspeculative_f64:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    ld.s $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = load double, double addrspace(258)* %d, align 8
  ret double %0
}

define <2 x float> @fspeculative_v2f32(<2 x float> addrspace(258)* nocapture readonly %v){
; CHECK-LABEL: fspeculative_v2f32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    ld.s $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = load <2 x float>, <2 x float> addrspace(258)* %v, align 8
  ret <2 x float> %0
}

define <4 x float> @fspeculative_v4f32(<4 x float> addrspace(258)* nocapture readonly %v){
; CHECK-LABEL: fspeculative_v4f32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lq.s $r0r1 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = load <4 x float>, <4 x float> addrspace(258)* %v, align 16
  ret <4 x float> %0
}

define i32 @foo_speculative_a(%struct.S addrspace(258)* nocapture readonly %s){
; CHECK-LABEL: foo_speculative_a:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz.s $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %a = getelementptr inbounds %struct.S, %struct.S addrspace(258)* %s, i64 0, i32 0
  %0 = load i32, i32 addrspace(258)* %a, align 4
  ret i32 %0
}

define i32 @foo_speculative_b(%struct.S addrspace(258)* nocapture readonly %s){
; CHECK-LABEL: foo_speculative_b:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz.s $r0 = 4[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %b = getelementptr inbounds %struct.S, %struct.S addrspace(258)* %s, i64 0, i32 1
  %0 = load i32, i32 addrspace(258)* %b, align 4
  ret i32 %0
}

define i32 @foo_speculative_c(%struct.S addrspace(258)* nocapture readonly %s){
; CHECK-LABEL: foo_speculative_c:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz.s $r0 = 8[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %c = getelementptr inbounds %struct.S, %struct.S addrspace(258)* %s, i64 0, i32 2
  %0 = load i32, i32 addrspace(258)* %c, align 4
  ret i32 %0
}

define i32 @foo_speculative_d(%struct.S addrspace(258)* nocapture readonly %s){
; CHECK-LABEL: foo_speculative_d:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz.s $r0 = 12[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %d = getelementptr inbounds %struct.S, %struct.S addrspace(258)* %s, i64 0, i32 3
  %0 = load i32, i32 addrspace(258)* %d, align 4
  ret i32 %0
}

define i32 @foo_speculative_3(<4 x i32> addrspace(258)* nocapture readonly %v){
; CHECK-LABEL: foo_speculative_3:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz.s $r0 = 12[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = load <4 x i32>, <4 x i32> addrspace(258)* %v, align 16
  %vecext = extractelement <4 x i32> %0, i32 3
  ret i32 %vecext
}

define i32 @foo_speculative_x(<4 x i32> addrspace(258)* nocapture readonly %v, i32 %x){
; CHECK-LABEL: foo_speculative_x:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sxwd $r1 = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lwz.s.xs $r0 = $r1[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = load <4 x i32>, <4 x i32> addrspace(258)* %v, align 16
  %vecext = extractelement <4 x i32> %0, i32 %x
  ret i32 %vecext
}
