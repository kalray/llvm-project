; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -O2 | FileCheck %s
target triple = "kvx-kalray-cos"

%struct.S = type { i32, i32, i32, i32 }

define i8 @bypass_i8(i8 addrspace(256)* nocapture readonly %i){
; CHECK-LABEL: bypass_i8:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lbz.u $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = load i8, i8 addrspace(256)* %i, align 1
  ret i8 %0
}

define i16 @bypass_i16(i16 addrspace(256)* nocapture readonly %i){
; CHECK-LABEL: bypass_i16:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lhz.u $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = load i16, i16 addrspace(256)* %i, align 2
  ret i16 %0
}

define i32 @bypass_i32(i32 addrspace(256)* nocapture readonly %i){
; CHECK-LABEL: bypass_i32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz.u $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = load i32, i32 addrspace(256)* %i, align 4
  ret i32 %0
}

define i64 @bypass_i64(i64 addrspace(256)* nocapture readonly %i){
; CHECK-LABEL: bypass_i64:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    ld.u $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = load i64, i64 addrspace(256)* %i, align 8
  ret i64 %0
}

define float @fbypass_f32(float addrspace(256)* nocapture readonly %f){
; CHECK-LABEL: fbypass_f32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz.u $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = load float, float addrspace(256)* %f, align 4
  ret float %0
}

define double @fbypass_f64(double addrspace(256)* nocapture readonly %d){
; CHECK-LABEL: fbypass_f64:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    ld.u $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = load double, double addrspace(256)* %d, align 8
  ret double %0
}

define <2 x float> @fbypass_v2f32(<2 x float> addrspace(256)* nocapture readonly %v){
; CHECK-LABEL: fbypass_v2f32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    ld.u $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = load <2 x float>, <2 x float> addrspace(256)* %v, align 8
  ret <2 x float> %0
}

define <4 x float> @fbypass_v4f32(<4 x float> addrspace(256)* nocapture readonly %v){
; CHECK-LABEL: fbypass_v4f32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lq.u $r0r1 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = load <4 x float>, <4 x float> addrspace(256)* %v, align 16
  ret <4 x float> %0
}

define i32 @foo_bypass_a(%struct.S addrspace(256)* nocapture readonly %s){
; CHECK-LABEL: foo_bypass_a:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz.u $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %a = getelementptr inbounds %struct.S, %struct.S addrspace(256)* %s, i64 0, i32 0
  %0 = load i32, i32 addrspace(256)* %a, align 4
  ret i32 %0
}

define i32 @foo_bypass_b(%struct.S addrspace(256)* nocapture readonly %s){
; CHECK-LABEL: foo_bypass_b:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz.u $r0 = 4[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %b = getelementptr inbounds %struct.S, %struct.S addrspace(256)* %s, i64 0, i32 1
  %0 = load i32, i32 addrspace(256)* %b, align 4
  ret i32 %0
}

define i32 @foo_bypass_c(%struct.S addrspace(256)* nocapture readonly %s){
; CHECK-LABEL: foo_bypass_c:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz.u $r0 = 8[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %c = getelementptr inbounds %struct.S, %struct.S addrspace(256)* %s, i64 0, i32 2
  %0 = load i32, i32 addrspace(256)* %c, align 4
  ret i32 %0
}

define i32 @foo_bypass_d(%struct.S addrspace(256)* nocapture readonly %s){
; CHECK-LABEL: foo_bypass_d:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz.u $r0 = 12[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %d = getelementptr inbounds %struct.S, %struct.S addrspace(256)* %s, i64 0, i32 3
  %0 = load i32, i32 addrspace(256)* %d, align 4
  ret i32 %0
}

define i32 @foo_bypass_3(<4 x i32> addrspace(256)* nocapture readonly %v){
; CHECK-LABEL: foo_bypass_3:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz.u $r0 = 12[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = load <4 x i32>, <4 x i32> addrspace(256)* %v, align 16
  %vecext = extractelement <4 x i32> %0, i32 3
  ret i32 %vecext
}

define i32 @foo_bypass_x(<4 x i32> addrspace(256)* nocapture readonly %v, i32 %x){
; CHECK-LABEL: foo_bypass_x:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sxwd $r1 = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lwz.u.xs $r0 = $r1[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = load <4 x i32>, <4 x i32> addrspace(256)* %v, align 16
  %vecext = extractelement <4 x i32> %0, i32 %x
  ret i32 %vecext
}

define i32 @foo_default(i32* nocapture readonly %i){
; CHECK-LABEL: foo_default:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = load i32, i32* %i, align 4
  ret i32 %0
}

define i32 @foo_default_a(%struct.S* nocapture readonly %s){
; CHECK-LABEL: foo_default_a:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %a = getelementptr inbounds %struct.S, %struct.S* %s, i64 0, i32 0
  %0 = load i32, i32* %a, align 4
  ret i32 %0
}

define i32 @foo_default_b(%struct.S* nocapture readonly %s){
; CHECK-LABEL: foo_default_b:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz $r0 = 4[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %b = getelementptr inbounds %struct.S, %struct.S* %s, i64 0, i32 1
  %0 = load i32, i32* %b, align 4
  ret i32 %0
}

define i32 @foo_default_c(%struct.S* nocapture readonly %s){
; CHECK-LABEL: foo_default_c:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz $r0 = 8[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %c = getelementptr inbounds %struct.S, %struct.S* %s, i64 0, i32 2
  %0 = load i32, i32* %c, align 4
  ret i32 %0
}

define i32 @foo_default_d(%struct.S* nocapture readonly %s){
; CHECK-LABEL: foo_default_d:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz $r0 = 12[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %d = getelementptr inbounds %struct.S, %struct.S* %s, i64 0, i32 3
  %0 = load i32, i32* %d, align 4
  ret i32 %0
}

define i32 @foo_default_3(<4 x i32>* nocapture readonly %v){
; CHECK-LABEL: foo_default_3:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz $r0 = 12[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = load <4 x i32>, <4 x i32>* %v, align 16
  %vecext = extractelement <4 x i32> %0, i32 3
  ret i32 %vecext
}

define i32 @foo_default_x(<4 x i32>* nocapture readonly %v, i32 %x){
; CHECK-LABEL: foo_default_x:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sxwd $r1 = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lwz.xs $r0 = $r1[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = load <4 x i32>, <4 x i32>* %v, align 16
  %vecext = extractelement <4 x i32> %0, i32 %x
  ret i32 %vecext
}
