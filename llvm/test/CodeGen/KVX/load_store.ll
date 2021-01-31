; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s | FileCheck %s
target triple = "kvx-kalray-cos"

define void @so_4xdouble_ri(<4 x double> %0, <4 x double>* %1) {
; CHECK-LABEL: so_4xdouble_ri:
; CHECK:       # %bb.0:
; CHECK-NEXT:    so 32[$r4] = $r0r1r2r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %3 = getelementptr inbounds <4 x double>, <4 x double>* %1, i64 1
  store volatile <4 x double> %0, <4 x double>* %3, align 32
  ret void
}

define void @so_4xdouble_rr(<4 x double> %0, <4 x double>* %1, i32 %2) {
; CHECK-LABEL: so_4xdouble_rr:
; CHECK:       # %bb.0:
; CHECK-NEXT:    sxwd $r5 = $r5
; CHECK-NEXT:    ;;
; CHECK-NEXT:    so.xs $r5[$r4] = $r0r1r2r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %4 = sext i32 %2 to i64
  %5 = getelementptr inbounds <4 x double>, <4 x double>* %1, i64 %4
  store volatile <4 x double> %0, <4 x double>* %5, align 32
  ret void
}

define void @lo_4xdouble_ri(<4 x double>* %0) {
; CHECK-LABEL: lo_4xdouble_ri:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lo $r0r1r2r3 = -32[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %2 = getelementptr inbounds <4 x double>, <4 x double>* %0, i64 -1
  %3 = load volatile <4 x double>, <4 x double>* %2, align 32
  ret void
}

define void @lo_4xdouble_rr(<4 x i64>* %0, i32 %1) {
; CHECK-LABEL: lo_4xdouble_rr:
; CHECK:       # %bb.0:
; CHECK-NEXT:    sxwd $r1 = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lo.xs $r0r1r2r3 = $r1[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %3 = sext i32 %1 to i64
  %4 = getelementptr inbounds <4 x i64>, <4 x i64>* %0, i64 %3
  %5 = load volatile <4 x i64>, <4 x i64>* %4, align 32
  ret void
}

define void @lo_4xdouble_ri_p(<4 x double> addrspace(257)* %0) {
; CHECK-LABEL: lo_4xdouble_ri_p:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lo.us $r0r1r2r3 = -32[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %2 = getelementptr inbounds <4 x double>, <4 x double> addrspace(257)* %0, i64 -1
  %3 = load volatile <4 x double>, <4 x double> addrspace(257)* %2, align 32
  ret void
}

define void @lo_4xdouble_rr_p(<4 x double> addrspace(257)* %0, i32 %1) {
; CHECK-LABEL: lo_4xdouble_rr_p:
; CHECK:       # %bb.0:
; CHECK-NEXT:    sxwd $r1 = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lo.us.xs $r0r1r2r3 = $r1[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %3 = sext i32 %1 to i64
  %4 = getelementptr inbounds <4 x double>, <4 x double> addrspace(257)* %0, i64 %3
  %5 = load volatile <4 x double>, <4 x double> addrspace(257)* %4, align 32
  ret void
}

define void @lo_4xdouble_ri_b(<4 x double> addrspace(256)* %0) {
; CHECK-LABEL: lo_4xdouble_ri_b:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lo.u $r0r1r2r3 = -32[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %2 = getelementptr inbounds <4 x double>, <4 x double> addrspace(256)* %0, i64 -1
  %3 = load volatile <4 x double>, <4 x double> addrspace(256)* %2, align 32
  ret void
}

define void @lo_4xdouble_rr_b(<4 x double> addrspace(256)* %0, i32 %1) {
; CHECK-LABEL: lo_4xdouble_rr_b:
; CHECK:       # %bb.0:
; CHECK-NEXT:    sxwd $r1 = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lo.u.xs $r0r1r2r3 = $r1[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %3 = sext i32 %1 to i64
  %4 = getelementptr inbounds <4 x double>, <4 x double> addrspace(256)* %0, i64 %3
  %5 = load volatile <4 x double>, <4 x double> addrspace(256)* %4, align 32
  ret void
}

define void @lo_4xdouble_ri_s(<4 x double> addrspace(258)* %0) {
; CHECK-LABEL: lo_4xdouble_ri_s:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lo.s $r0r1r2r3 = -32[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %2 = getelementptr inbounds <4 x double>, <4 x double> addrspace(258)* %0, i64 -1
  %3 = load volatile <4 x double>, <4 x double> addrspace(258)* %2, align 32
  ret void
}

define void @lo_4xdouble_rr_s(<4 x double> addrspace(258)* %0, i32 %1) {
; CHECK-LABEL: lo_4xdouble_rr_s:
; CHECK:       # %bb.0:
; CHECK-NEXT:    sxwd $r1 = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lo.s.xs $r0r1r2r3 = $r1[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %3 = sext i32 %1 to i64
  %4 = getelementptr inbounds <4 x double>, <4 x double> addrspace(258)* %0, i64 %3
  %5 = load volatile <4 x double>, <4 x double> addrspace(258)* %4, align 32
  ret void
}

define void @so_4xi64_ri(<4 x i64> %0, <4 x i64>* %1) {
; CHECK-LABEL: so_4xi64_ri:
; CHECK:       # %bb.0:
; CHECK-NEXT:    so 32[$r4] = $r0r1r2r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %3 = getelementptr inbounds <4 x i64>, <4 x i64>* %1, i64 1
  store volatile <4 x i64> %0, <4 x i64>* %3, align 32
  ret void
}

define void @so_4xi64_rr(<4 x i64> %0, <4 x i64>* %1, i32 %2) {
; CHECK-LABEL: so_4xi64_rr:
; CHECK:       # %bb.0:
; CHECK-NEXT:    sxwd $r5 = $r5
; CHECK-NEXT:    ;;
; CHECK-NEXT:    so.xs $r5[$r4] = $r0r1r2r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %4 = sext i32 %2 to i64
  %5 = getelementptr inbounds <4 x i64>, <4 x i64>* %1, i64 %4
  store volatile <4 x i64> %0, <4 x i64>* %5, align 32
  ret void
}

define void @lo_4xi64_ri(<4 x i64>* %0) {
; CHECK-LABEL: lo_4xi64_ri:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lo $r0r1r2r3 = -32[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %2 = getelementptr inbounds <4 x i64>, <4 x i64>* %0, i64 -1
  %3 = load volatile <4 x i64>, <4 x i64>* %2, align 32
  ret void
}

define void @lo_4xi64_rr(<4 x i64>* %0, i32 %1) {
; CHECK-LABEL: lo_4xi64_rr:
; CHECK:       # %bb.0:
; CHECK-NEXT:    sxwd $r1 = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lo.xs $r0r1r2r3 = $r1[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %3 = sext i32 %1 to i64
  %4 = getelementptr inbounds <4 x i64>, <4 x i64>* %0, i64 %3
  %5 = load volatile <4 x i64>, <4 x i64>* %4, align 32
  ret void
}

define void @lo_4xi64_ri_p(<4 x i64> addrspace(257)* %0) {
; CHECK-LABEL: lo_4xi64_ri_p:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lo.us $r0r1r2r3 = -32[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %2 = getelementptr inbounds <4 x i64>, <4 x i64> addrspace(257)* %0, i64 -1
  %3 = load volatile <4 x i64>, <4 x i64> addrspace(257)* %2, align 32
  ret void
}

define void @lo_4xi64_rr_p(<4 x i64> addrspace(257)* %0, i32 %1) {
; CHECK-LABEL: lo_4xi64_rr_p:
; CHECK:       # %bb.0:
; CHECK-NEXT:    sxwd $r1 = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lo.us.xs $r0r1r2r3 = $r1[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %3 = sext i32 %1 to i64
  %4 = getelementptr inbounds <4 x i64>, <4 x i64> addrspace(257)* %0, i64 %3
  %5 = load volatile <4 x i64>, <4 x i64> addrspace(257)* %4, align 32
  ret void
}

define void @lo_4xi64_ri_b(<4 x i64> addrspace(256)* %0) {
; CHECK-LABEL: lo_4xi64_ri_b:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lo.u $r0r1r2r3 = -32[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %2 = getelementptr inbounds <4 x i64>, <4 x i64> addrspace(256)* %0, i64 -1
  %3 = load volatile <4 x i64>, <4 x i64> addrspace(256)* %2, align 32
  ret void
}

define void @lo_4xi64_rr_b(<4 x i64> addrspace(256)* %0, i32 %1) {
; CHECK-LABEL: lo_4xi64_rr_b:
; CHECK:       # %bb.0:
; CHECK-NEXT:    sxwd $r1 = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lo.u.xs $r0r1r2r3 = $r1[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %3 = sext i32 %1 to i64
  %4 = getelementptr inbounds <4 x i64>, <4 x i64> addrspace(256)* %0, i64 %3
  %5 = load volatile <4 x i64>, <4 x i64> addrspace(256)* %4, align 32
  ret void
}

define void @lo_4xi64_ri_s(<4 x i64> addrspace(258)* %0) {
; CHECK-LABEL: lo_4xi64_ri_s:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lo.s $r0r1r2r3 = -32[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %2 = getelementptr inbounds <4 x i64>, <4 x i64> addrspace(258)* %0, i64 -1
  %3 = load volatile <4 x i64>, <4 x i64> addrspace(258)* %2, align 32
  ret void
}

define void @lo_4xi64_rr_s(<4 x i64> addrspace(258)* %0, i32 %1) {
; CHECK-LABEL: lo_4xi64_rr_s:
; CHECK:       # %bb.0:
; CHECK-NEXT:    sxwd $r1 = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lo.s.xs $r0r1r2r3 = $r1[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %3 = sext i32 %1 to i64
  %4 = getelementptr inbounds <4 x i64>, <4 x i64> addrspace(258)* %0, i64 %3
  %5 = load volatile <4 x i64>, <4 x i64> addrspace(258)* %4, align 32
  ret void
}

define void @lv_s_sv(<256 x i1> addrspace(258)* %0, i64 %1) {
; CHECK-LABEL: lv_s_sv:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lv.s.xs $a0 = $r1[$r0]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sv 0[$r0] = $a0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %2 = getelementptr inbounds <256 x i1>, <256 x i1> addrspace(258)* %0, i64 %1
  %3 = load volatile <256 x i1>, <256 x i1> addrspace(258)* %2, align 32
  store volatile <256 x i1> %3, <256 x i1>addrspace(258)* %0, align 32
  ret void
}

define void @lv_sv(<256 x i1> * %0, i64 %1) {
; CHECK-LABEL: lv_sv:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lv.xs $a0 = $r1[$r0]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sv 0[$r0] = $a0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %2 = getelementptr inbounds <256 x i1>, <256 x i1> * %0, i64 %1
  %3 = load volatile <256 x i1>, <256 x i1>* %2, align 32
  store volatile <256 x i1> %3, <256 x i1>* %0, align 32
  ret void
}

define void @lw_sw(<512 x i1> * %0, i64 %1) {
; CHECK-LABEL: lw_sw:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    slld $r1 = $r1, 6
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addd $r1 = $r0, $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lv $a1 = 32[$r1]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lv $a0 = 0[$r1]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sv 32[$r0] = $a1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sv 0[$r0] = $a0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %2 = getelementptr inbounds <512 x i1>, <512 x i1> * %0, i64 %1
  %3 = load <512 x i1>, <512 x i1>* %2, align 32
  store <512 x i1> %3, <512 x i1>* %0, align 32
  ret void
}

define void @lm_sm(<1024 x i1> * %0, i64 %1) {
; CHECK-LABEL: lm_sm:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    slld $r1 = $r1, 7
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addd $r1 = $r0, $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lv $a3 = 96[$r1]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lv $a2 = 64[$r1]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lv $a1 = 32[$r1]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lv $a0 = 0[$r1]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sv 96[$r0] = $a3
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sv 64[$r0] = $a2
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sv 32[$r0] = $a1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sv 0[$r0] = $a0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %2 = getelementptr inbounds <1024 x i1>, <1024 x i1> * %0, i64 %1
  %3 = load <1024 x i1>, <1024 x i1>* %2, align 32
  store <1024 x i1> %3, <1024 x i1>* %0, align 32
  ret void
}

define void @lo_4xi64_ri_unaligned(<4 x i64>* %0) {
; CHECK-LABEL: lo_4xi64_ri_unaligned:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lo $r0r1r2r3 = -32[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %2 = getelementptr inbounds <4 x i64>, <4 x i64>* %0, i64 -1
  %3 = load volatile <4 x i64>, <4 x i64>* %2, align 1
  ret void
}

define void @so_4xdouble_ri_unaligned(<4 x double> %0, <4 x double>* %1) {
; CHECK-LABEL: so_4xdouble_ri_unaligned:
; CHECK:       # %bb.0:
; CHECK-NEXT:    so 32[$r4] = $r0r1r2r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %3 = getelementptr inbounds <4 x double>, <4 x double>* %1, i64 1
  store volatile <4 x double> %0, <4 x double>* %3, align 1
  ret void
}

define <16 x half> @loadhalf16(<16 x half>* nocapture readonly %v) {
; CHECK-LABEL: loadhalf16:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lo $r0r1r2r3 = 96[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <16 x half>, <16 x half>* %v, i64 3
  %0 = load <16 x half>, <16 x half>* %arrayidx, align 32
  ret <16 x half> %0
}

define void @storehalf16(<16 x half> %v, <16 x half>* nocapture %p) {
; CHECK-LABEL: storehalf16:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    so 32[$r4] = $r0r1r2r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <16 x half>, <16 x half>* %p, i64 1
  store <16 x half> %v, <16 x half>* %arrayidx, align 32
  ret void
}

define <8 x float> @loadfloat8(<8 x float>* nocapture readonly %v) {
; CHECK-LABEL: loadfloat8:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lo $r0r1r2r3 = 96[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <8 x float>, <8 x float>* %v, i64 3
  %0 = load <8 x float>, <8 x float>* %arrayidx, align 32
  ret <8 x float> %0
}

define void @storefloat8(<8 x float> %v, <8 x float>* nocapture %p) {
; CHECK-LABEL: storefloat8:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    so 32[$r4] = $r0r1r2r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <8 x float>, <8 x float>* %p, i64 1
  store <8 x float> %v, <8 x float>* %arrayidx, align 32
  ret void
}

define <32 x i8> @loadchar32(<32 x i8>* nocapture readonly %v) {
; CHECK-LABEL: loadchar32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lo $r0r1r2r3 = 96[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <32 x i8>, <32 x i8>* %v, i64 3
  %0 = load <32 x i8>, <32 x i8>* %arrayidx, align 32
  ret <32 x i8> %0
}

define void @storechar32(<32 x i8> %v, <32 x i8>* nocapture %p) {
; CHECK-LABEL: storechar32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    so 32[$r4] = $r0r1r2r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <32 x i8>, <32 x i8>* %p, i64 1
  store <32 x i8> %v, <32 x i8>* %arrayidx, align 32
  ret void
}

define <32 x i8> @loaduchar32(<32 x i8>* nocapture readonly %v) {
; CHECK-LABEL: loaduchar32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lo $r0r1r2r3 = 96[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <32 x i8>, <32 x i8>* %v, i64 3
  %0 = load <32 x i8>, <32 x i8>* %arrayidx, align 32
  ret <32 x i8> %0
}

define void @storeuchar32(<32 x i8> %v, <32 x i8>* nocapture %p) {
; CHECK-LABEL: storeuchar32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    so 32[$r4] = $r0r1r2r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <32 x i8>, <32 x i8>* %p, i64 1
  store <32 x i8> %v, <32 x i8>* %arrayidx, align 32
  ret void
}

define <16 x i16> @loadshort16(<16 x i16>* nocapture readonly %v) {
; CHECK-LABEL: loadshort16:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lo $r0r1r2r3 = 96[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <16 x i16>, <16 x i16>* %v, i64 3
  %0 = load <16 x i16>, <16 x i16>* %arrayidx, align 32
  ret <16 x i16> %0
}

define void @storeshort16(<16 x i16> %v, <16 x i16>* nocapture %p) {
; CHECK-LABEL: storeshort16:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    so 32[$r4] = $r0r1r2r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <16 x i16>, <16 x i16>* %p, i64 1
  store <16 x i16> %v, <16 x i16>* %arrayidx, align 32
  ret void
}

define <16 x i16> @loadushort16(<16 x i16>* nocapture readonly %v) {
; CHECK-LABEL: loadushort16:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lo $r0r1r2r3 = 96[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <16 x i16>, <16 x i16>* %v, i64 3
  %0 = load <16 x i16>, <16 x i16>* %arrayidx, align 32
  ret <16 x i16> %0
}

define void @storeushort16(<16 x i16> %v, <16 x i16>* nocapture %p) {
; CHECK-LABEL: storeushort16:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    so 32[$r4] = $r0r1r2r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <16 x i16>, <16 x i16>* %p, i64 1
  store <16 x i16> %v, <16 x i16>* %arrayidx, align 32
  ret void
}

define <8 x i32> @loadint8(<8 x i32>* nocapture readonly %v) {
; CHECK-LABEL: loadint8:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lo $r0r1r2r3 = 96[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <8 x i32>, <8 x i32>* %v, i64 3
  %0 = load <8 x i32>, <8 x i32>* %arrayidx, align 32
  ret <8 x i32> %0
}

define void @storeint8(<8 x i32> %v, <8 x i32>* nocapture %p) {
; CHECK-LABEL: storeint8:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    so 32[$r4] = $r0r1r2r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <8 x i32>, <8 x i32>* %p, i64 1
  store <8 x i32> %v, <8 x i32>* %arrayidx, align 32
  ret void
}

define <8 x i32> @loaduint8(<8 x i32>* nocapture readonly %v) {
; CHECK-LABEL: loaduint8:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lo $r0r1r2r3 = 96[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <8 x i32>, <8 x i32>* %v, i64 3
  %0 = load <8 x i32>, <8 x i32>* %arrayidx, align 32
  ret <8 x i32> %0
}

define void @storeuint8(<8 x i32> %v, <8 x i32>* nocapture %p) {
; CHECK-LABEL: storeuint8:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    so 32[$r4] = $r0r1r2r3
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <8 x i32>, <8 x i32>* %p, i64 1
  store <8 x i32> %v, <8 x i32>* %arrayidx, align 32
  ret void
}
define <8 x half> @loadhalf8(<8 x half>* nocapture readonly %v) {
; CHECK-LABEL: loadhalf8:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lq $r0r1 = 48[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <8 x half>, <8 x half>* %v, i64 3
  %0 = load <8 x half>, <8 x half>* %arrayidx, align 16
  ret <8 x half> %0
}

define void @storehalf8(<8 x half> %v, <8 x half>* nocapture %p) {
; CHECK-LABEL: storehalf8:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sq 16[$r2] = $r0r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <8 x half>, <8 x half>* %p, i64 1
  store <8 x half> %v, <8 x half>* %arrayidx, align 16
  ret void
}

define <4 x float> @loadfloat4(<4 x float>* nocapture readonly %v) {
; CHECK-LABEL: loadfloat4:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lq $r0r1 = 48[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <4 x float>, <4 x float>* %v, i64 3
  %0 = load <4 x float>, <4 x float>* %arrayidx, align 16
  ret <4 x float> %0
}

define void @storefloat4(<4 x float> %v, <4 x float>* nocapture %p) {
; CHECK-LABEL: storefloat4:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sq 16[$r2] = $r0r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <4 x float>, <4 x float>* %p, i64 1
  store <4 x float> %v, <4 x float>* %arrayidx, align 16
  ret void
}

define <2 x double> @loaddouble2(<2 x double>* nocapture readonly %v) {
; CHECK-LABEL: loaddouble2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lq $r0r1 = 48[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <2 x double>, <2 x double>* %v, i64 3
  %0 = load <2 x double>, <2 x double>* %arrayidx, align 16
  ret <2 x double> %0
}

define void @storedouble2(<2 x double> %v, <2 x double>* nocapture %p) {
; CHECK-LABEL: storedouble2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sq 16[$r2] = $r0r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <2 x double>, <2 x double>* %p, i64 1
  store <2 x double> %v, <2 x double>* %arrayidx, align 16
  ret void
}

define <16 x i8> @loadchar16(<16 x i8>* nocapture readonly %v) {
; CHECK-LABEL: loadchar16:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lq $r0r1 = 48[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <16 x i8>, <16 x i8>* %v, i64 3
  %0 = load <16 x i8>, <16 x i8>* %arrayidx, align 16
  ret <16 x i8> %0
}

define void @storechar16(<16 x i8> %v, <16 x i8>* nocapture %p) {
; CHECK-LABEL: storechar16:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sq 16[$r2] = $r0r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <16 x i8>, <16 x i8>* %p, i64 1
  store <16 x i8> %v, <16 x i8>* %arrayidx, align 16
  ret void
}

define <16 x i8> @loaduchar16(<16 x i8>* nocapture readonly %v) {
; CHECK-LABEL: loaduchar16:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lq $r0r1 = 48[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <16 x i8>, <16 x i8>* %v, i64 3
  %0 = load <16 x i8>, <16 x i8>* %arrayidx, align 16
  ret <16 x i8> %0
}

define void @storeuchar16(<16 x i8> %v, <16 x i8>* nocapture %p) {
; CHECK-LABEL: storeuchar16:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sq 16[$r2] = $r0r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <16 x i8>, <16 x i8>* %p, i64 1
  store <16 x i8> %v, <16 x i8>* %arrayidx, align 16
  ret void
}

define <8 x i16> @loadshort8(<8 x i16>* nocapture readonly %v) {
; CHECK-LABEL: loadshort8:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lq $r0r1 = 48[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <8 x i16>, <8 x i16>* %v, i64 3
  %0 = load <8 x i16>, <8 x i16>* %arrayidx, align 16
  ret <8 x i16> %0
}

define void @storeshort8(<8 x i16> %v, <8 x i16>* nocapture %p) {
; CHECK-LABEL: storeshort8:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sq 16[$r2] = $r0r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <8 x i16>, <8 x i16>* %p, i64 1
  store <8 x i16> %v, <8 x i16>* %arrayidx, align 16
  ret void
}

define <8 x i16> @loadushort8(<8 x i16>* nocapture readonly %v) {
; CHECK-LABEL: loadushort8:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lq $r0r1 = 48[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <8 x i16>, <8 x i16>* %v, i64 3
  %0 = load <8 x i16>, <8 x i16>* %arrayidx, align 16
  ret <8 x i16> %0
}

define void @storeushort8(<8 x i16> %v, <8 x i16>* nocapture %p) {
; CHECK-LABEL: storeushort8:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sq 16[$r2] = $r0r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <8 x i16>, <8 x i16>* %p, i64 1
  store <8 x i16> %v, <8 x i16>* %arrayidx, align 16
  ret void
}

define <4 x i32> @loadint4(<4 x i32>* nocapture readonly %v) {
; CHECK-LABEL: loadint4:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lq $r0r1 = 48[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <4 x i32>, <4 x i32>* %v, i64 3
  %0 = load <4 x i32>, <4 x i32>* %arrayidx, align 16
  ret <4 x i32> %0
}

define void @storeint4(<4 x i32> %v, <4 x i32>* nocapture %p) {
; CHECK-LABEL: storeint4:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sq 16[$r2] = $r0r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <4 x i32>, <4 x i32>* %p, i64 1
  store <4 x i32> %v, <4 x i32>* %arrayidx, align 16
  ret void
}

define <4 x i32> @loaduint4(<4 x i32>* nocapture readonly %v) {
; CHECK-LABEL: loaduint4:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lq $r0r1 = 48[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <4 x i32>, <4 x i32>* %v, i64 3
  %0 = load <4 x i32>, <4 x i32>* %arrayidx, align 16
  ret <4 x i32> %0
}

define void @storeuint4(<4 x i32> %v, <4 x i32>* nocapture %p) {
; CHECK-LABEL: storeuint4:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sq 16[$r2] = $r0r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <4 x i32>, <4 x i32>* %p, i64 1
  store <4 x i32> %v, <4 x i32>* %arrayidx, align 16
  ret void
}

define <2 x i64> @loadlong2(<2 x i64>* nocapture readonly %v) {
; CHECK-LABEL: loadlong2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lq $r0r1 = 48[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <2 x i64>, <2 x i64>* %v, i64 3
  %0 = load <2 x i64>, <2 x i64>* %arrayidx, align 16
  ret <2 x i64> %0
}

define void @storelong2(<2 x i64> %v, <2 x i64>* nocapture %p) {
; CHECK-LABEL: storelong2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sq 16[$r2] = $r0r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <2 x i64>, <2 x i64>* %p, i64 1
  store <2 x i64> %v, <2 x i64>* %arrayidx, align 16
  ret void
}

define <2 x i64> @loadulong2(<2 x i64>* nocapture readonly %v) {
; CHECK-LABEL: loadulong2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lq $r0r1 = 48[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <2 x i64>, <2 x i64>* %v, i64 3
  %0 = load <2 x i64>, <2 x i64>* %arrayidx, align 16
  ret <2 x i64> %0
}

define void @storeulong2(<2 x i64> %v, <2 x i64>* nocapture %p) {
; CHECK-LABEL: storeulong2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sq 16[$r2] = $r0r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %arrayidx = getelementptr inbounds <2 x i64>, <2 x i64>* %p, i64 1
  store <2 x i64> %v, <2 x i64>* %arrayidx, align 16
  ret void
}
