; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -O2 | FileCheck %s
target triple = "kvx-kalray-cos"

define i8 @lbz(i8* nocapture readonly %p){
; CHECK-LABEL: lbz:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lbz.u $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = addrspacecast i8* %p to i8 addrspace(256)*
  %1 = load i8, i8 addrspace(256)* %0, align 1
  ret i8 %1
}

define i32 @lbs_volatile(i8* %p){
; CHECK-LABEL: lbs_volatile:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lbs.us $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = addrspacecast i8* %p to i8 addrspace(257)*
  %1 = load volatile i8, i8 addrspace(257)* %0, align 1
  %conv = sext i8 %1 to i32
  ret i32 %conv
}

define i16 @lhz(i8* nocapture readonly %p){
; CHECK-LABEL: lhz:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lhz.u $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = bitcast i8* %p to i16*
  %1 = addrspacecast i16* %0 to i16 addrspace(256)*
  %2 = load i16, i16 addrspace(256)* %1, align 2
  ret i16 %2
}

define i32 @lhs_volatile(i8* %p){
; CHECK-LABEL: lhs_volatile:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lhs.us $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = bitcast i8* %p to i16*
  %1 = addrspacecast i16* %0 to i16 addrspace(257)*
  %2 = load volatile i16, i16 addrspace(257)* %1, align 2
  %conv = sext i16 %2 to i32
  ret i32 %conv
}

define i32 @lwz(i8* nocapture readonly %p){
; CHECK-LABEL: lwz:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz.u $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = bitcast i8* %p to i32*
  %1 = addrspacecast i32* %0 to i32 addrspace(256)*
  %2 = load i32, i32 addrspace(256)* %1, align 4
  ret i32 %2
}

define i32 @lws_volatile(i8* %p){
; CHECK-LABEL: lws_volatile:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz.us $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = bitcast i8* %p to i32*
  %1 = addrspacecast i32* %0 to i32 addrspace(257)*
  %2 = load volatile i32, i32 addrspace(257)* %1, align 4
  ret i32 %2
}

define float @lwf(i8* %p){
; CHECK-LABEL: lwf:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz.s $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = bitcast i8* %p to float*
  %1 = addrspacecast float* %0 to float addrspace(258)*
  %2 = load volatile float, float addrspace(258)* %1, align 4
  ret float %2
}

define i64 @ld(i8* %p){
; CHECK-LABEL: ld:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    ld.s $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = bitcast i8* %p to i64*
  %1 = addrspacecast i64* %0 to i64 addrspace(258)*
  %2 = load volatile i64, i64 addrspace(258)* %1, align 8
  ret i64 %2
}

define double @ldf(i8* %p){
; CHECK-LABEL: ldf:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    ld.s $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = bitcast i8* %p to double*
  %1 = addrspacecast double* %0 to double addrspace(258)*
  %2 = load volatile double, double addrspace(258)* %1, align 8
  ret double %2
}

define <8 x i8> @ldbo(i8* %p){
; CHECK-LABEL: ldbo:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    ld.s $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = bitcast i8* %p to <8 x i8>*
  %1 = addrspacecast <8 x i8>* %0 to <8 x i8> addrspace(258)*
  %2 = load volatile <8 x i8>, <8 x i8> addrspace(258)* %1, align 8
  ret <8 x i8> %2
}

define <4 x i16> @ldhq(i8* %p){
; CHECK-LABEL: ldhq:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    ld.s $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = bitcast i8* %p to <4 x i16>*
  %1 = addrspacecast <4 x i16>* %0 to <4 x i16> addrspace(258)*
  %2 = load volatile <4 x i16>, <4 x i16> addrspace(258)* %1, align 8
  ret <4 x i16> %2
}

define <2 x i32> @ldwp(i8* %p){
; CHECK-LABEL: ldwp:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    ld.s $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = bitcast i8* %p to <2 x i32>*
  %1 = addrspacecast <2 x i32>* %0 to <2 x i32> addrspace(258)*
  %2 = load volatile <2 x i32>, <2 x i32> addrspace(258)* %1, align 8
  ret <2 x i32> %2
}

define <2 x float> @ldfwp(i8* %p){
; CHECK-LABEL: ldfwp:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    ld.s $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = bitcast i8* %p to <2 x float>*
  %1 = addrspacecast <2 x float>* %0 to <2 x float> addrspace(258)*
  %2 = load volatile <2 x float>, <2 x float> addrspace(258)* %1, align 8
  ret <2 x float> %2
}

define void @sdbo(i8* %p, <8 x i8> %v){
; CHECK-LABEL: sdbo:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sd 0[$r0] = $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = bitcast i8* %p to <8 x i8>*
  store volatile <8 x i8> %v, <8 x i8>* %0, align 8
  ret void
}

define void @sdhq(i8* %p, <4 x i16> %v){
; CHECK-LABEL: sdhq:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sd 0[$r0] = $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = bitcast i8* %p to <4 x i16>*
  store volatile <4 x i16> %v, <4 x i16>* %0, align 8
  ret void
}

define void @sdwp(i8* %p, <2 x i32> %v){
; CHECK-LABEL: sdwp:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sd 0[$r0] = $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = bitcast i8* %p to <2 x i32>*
  store volatile <2 x i32> %v, <2 x i32>* %0, align 8
  ret void
}

define void @sdfwp(i8* %p, <2 x float> %v){
; CHECK-LABEL: sdfwp:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sd 0[$r0] = $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = bitcast i8* %p to <2 x float>*
  store volatile <2 x float> %v, <2 x float>* %0, align 8
  ret void
}

