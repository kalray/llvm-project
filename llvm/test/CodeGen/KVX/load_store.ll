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
