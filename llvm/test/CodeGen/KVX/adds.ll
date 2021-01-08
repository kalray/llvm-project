; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -O2 -o - %s | FileCheck %s
target triple = "kvx-kalray-cos"

define i32 @sadd_sat32(i32 %a, i32 %b) {
; CHECK-LABEL: sadd_sat32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addsw $r0 = $r1, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = tail call i32 @llvm.sadd.sat.i32(i32 %b, i32 %a)
  ret i32 %0
}

define i32 @sadd_sat32_ri(i32 %a) {
; CHECK-LABEL: sadd_sat32_ri:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addsw $r0 = $r0, 0xcaca
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = tail call i32 @llvm.sadd.sat.i32(i32 %a, i32 51914)
  ret i32 %0
}

; TODO: This could be addshq, but i16 is not legal.
define signext i16 @sadd_sat16(i16 signext %a, i16 signext %b) {
; CHECK-LABEL: sadd_sat16:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sllw $r0 = $r0, 16
; CHECK-NEXT:    sllw $r1 = $r1, 16
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addsw $r0 = $r1, $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sraw $r0 = $r0, 16
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = tail call i16 @llvm.sadd.sat.i16(i16 %b, i16 %a)
  ret i16 %0
}

define signext i8 @sadd_sat8(i8 signext %a, i8 signext %b) {
; CHECK-LABEL: sadd_sat8:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sllw $r0 = $r0, 24
; CHECK-NEXT:    sllw $r1 = $r1, 24
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addsw $r0 = $r1, $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sraw $r0 = $r0, 24
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = tail call i8 @llvm.sadd.sat.i8(i8 %b, i8 %a)
  ret i8 %0
}

define signext i64 @sadd_sat64(i64 signext %a, i64 signext %b) {
; CHECK-LABEL: sadd_sat64:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addsd $r0 = $r1, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = tail call i64 @llvm.sadd.sat.i64(i64 %b, i64 %a)
  ret i64 %0
}

define signext i64 @sadd_sat64_ri10(i64 signext %a) {
; CHECK-LABEL: sadd_sat64_ri10:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addsd $r0 = $r0, -512
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = tail call i64 @llvm.sadd.sat.i64(i64 %a, i64 -512)
  ret i64 %0
}

define signext i64 @sadd_sat64_ri37(i64 signext %a) {
; CHECK-LABEL: sadd_sat64_ri37:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addsd $r0 = $r0, 0x1fffffffff
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = tail call i64 @llvm.sadd.sat.i64(i64 %a, i64 137438953471)
  ret i64 %0
}

define signext i64 @sadd_sat64_ri64(i64 signext %a) {
; CHECK-LABEL: sadd_sat64_ri64:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addsd $r0 = $r0, 0x7fffffffffffffff
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = tail call i64 @llvm.sadd.sat.i64(i64 %a, i64 9223372036854775807)
  ret i64 %0
}

define signext i4 @sadd_sat4(i4 signext %a, i4 signext %b) {
; CHECK-LABEL: sadd_sat4:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addw $r0 = $r1, $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    minw $r0 = $r0, 7
; CHECK-NEXT:    ;;
; CHECK-NEXT:    maxw $r0 = $r0, -8
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %conv = sext i4 %a to i32
  %conv1 = sext i4 %b to i32
  %add = add nsw i32 %conv1, %conv
  %0 = icmp slt i32 %add, 7
  %spec.store.select = select i1 %0, i32 %add, i32 7
  %1 = icmp sgt i32 %spec.store.select, -8
  %spec.store.select10 = select i1 %1, i32 %spec.store.select, i32 -8
  %conv9 = trunc i32 %spec.store.select10 to i4
  ret i4 %conv9
}

define <2 x i32> @sadd_satv2i32(<2 x i32> %a, <2 x i32> %b) {
; CHECK-LABEL: sadd_satv2i32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addswp $r0 = $r1, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = tail call <2 x i32> @llvm.sadd.sat.v2i32(<2 x i32> %b, <2 x i32> %a)
  ret <2 x i32> %0
}

define <2 x i32> @sadd_satv2i32_ri_(<2 x i32> %a) {
; CHECK-LABEL: sadd_satv2i32_ri_:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addswp $r0 = $r0, 15
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = tail call <2 x i32> @llvm.sadd.sat.v2i32(<2 x i32> %a, <2 x i32> <i32 15, i32 0>)
  ret <2 x i32> %0
}

define <2 x i32> @sadd_satv2i32_ri_at(<2 x i32> %a) {
; CHECK-LABEL: sadd_satv2i32_ri_at:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addswp.@ $r0 = $r0, 15
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = tail call <2 x i32> @llvm.sadd.sat.v2i32(<2 x i32> %a, <2 x i32> <i32 15, i32 15>)
  ret <2 x i32> %0
}

define <2 x i32> @sadd_satv2i32_rr(<2 x i32> %a) {
; CHECK-LABEL: sadd_satv2i32_rr:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    make $r1 = 0x1b58000002bc
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addswp $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = tail call <2 x i32> @llvm.sadd.sat.v2i32(<2 x i32> %a, <2 x i32> <i32 700, i32 7000>)
  ret <2 x i32> %0
}

define <2 x i16> @sadd_satv2i16(<2 x i16> %a, <2 x i16> %b) {
; CHECK-LABEL: sadd_satv2i16:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addshq $r0 = $r1, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = tail call <2 x i16> @llvm.sadd.sat.v2i16(<2 x i16> %b, <2 x i16> %a)
  ret <2 x i16> %0
}

define <2 x i16> @sadd_satv2i16_ri(<2 x i16> %a) {
; CHECK-LABEL: sadd_satv2i16_ri:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addshq $r0 = $r0, 0x10001
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = tail call <2 x i16> @llvm.sadd.sat.v2i16(<2 x i16> %a, <2 x i16> <i16 1, i16 1>)
  ret <2 x i16> %0
}

define <4 x i16> @sadd_satv4i16(<4 x i16> %a, <4 x i16> %b) {
; CHECK-LABEL: sadd_satv4i16:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addshq $r0 = $r1, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = tail call <4 x i16> @llvm.sadd.sat.v4i16(<4 x i16> %b, <4 x i16> %a)
  ret <4 x i16> %0
}

define <4 x i16> @sadd_satv4i16_ri_(<4 x i16> %a) {
; CHECK-LABEL: sadd_satv4i16_ri_:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addshq $r0 = $r0, 0x9e8f618
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = tail call <4 x i16> @llvm.sadd.sat.v4i16(<4 x i16> %a, <4 x i16> <i16 63000, i16 -63000, i16 0, i16 0>)
  ret <4 x i16> %0
}

define <4 x i16> @sadd_satv4i16_ri_at(<4 x i16> %a) {
; CHECK-LABEL: sadd_satv4i16_ri_at:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addshq.@ $r0 = $r0, 0x9e8f618
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = tail call <4 x i16> @llvm.sadd.sat.v4i16(<4 x i16> %a, <4 x i16> <i16 63000, i16 -63000, i16 63000, i16 -63000>)
  ret <4 x i16> %0
}

define <4 x i32> @sadd_satv4i32(<4 x i32> %a, <4 x i32> %b) {
; CHECK-LABEL: sadd_satv4i32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addswp $r0 = $r2, $r0
; CHECK-NEXT:    addswp $r1 = $r3, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = tail call <4 x i32> @llvm.sadd.sat.v4i32(<4 x i32> %b, <4 x i32> %a)
  ret <4 x i32> %0
}

; TODO: Could be simply zxwx(addsw)
define i32 @sadd_sat32_trunc(i32 %a, i32 %b) {
; CHECK-LABEL: sadd_sat32_trunc:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sxwd $r0 = $r0
; CHECK-NEXT:    sxwd $r1 = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addd $r0 = $r1, $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    mind $r0 = $r0, 0x7fff
; CHECK-NEXT:    ;;
; CHECK-NEXT:    maxd $r0 = $r0, 0xffffffffffff8000
; CHECK-NEXT:    ;;
; CHECK-NEXT:    zxwd $r0 = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %conv = sext i32 %a to i64
  %conv1 = sext i32 %b to i64
  %add = add nsw i64 %conv1, %conv
  %0 = icmp slt i64 %add, 32767
  %spec.store.select = select i1 %0, i64 %add, i64 32767
  %1 = icmp sgt i64 %spec.store.select, -32768
  %spec.store.select8 = select i1 %1, i64 %spec.store.select, i64 -32768
  %conv7 = trunc i64 %spec.store.select8 to i32
  ret i32 %conv7
}

define i32 @sadd_sat32_ext16(i32 %a, i16 %b) {
; CHECK-LABEL: sadd_sat32_ext16:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sxhd $r1 = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addsw $r0 = $r1, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = sext i16 %b to i32
  %1 = tail call i32 @llvm.sadd.sat.i32(i32 %0, i32 %a)
  ret i32 %1
}

; TODO: Could be simply addsw
define i32 @sadd_sat32_zext(i32 %a, i32 %b) {
; CHECK-LABEL: sadd_sat32_zext:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    zxwd $r0 = $r0
; CHECK-NEXT:    zxwd $r1 = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addd $r0 = $r1, $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    minud $r0 = $r0, 0x7fffffff
; CHECK-NEXT:    ;;
; CHECK-NEXT:    zxwd $r0 = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %conv = zext i32 %a to i64
  %conv1 = zext i32 %b to i64
  %add = add nuw nsw i64 %conv1, %conv
  %0 = icmp ult i64 %add, 2147483647
  %spec.store.select = select i1 %0, i64 %add, i64 2147483647
  %conv7 = trunc i64 %spec.store.select to i32
  ret i32 %conv7
}

define i64 @sadd_sat32_notrunc(i32 %a, i32 %b) {
; CHECK-LABEL: sadd_sat32_notrunc:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addsw $r0 = $r1, $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sxwd $r0 = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %0 = tail call i32 @llvm.sadd.sat.i32(i32 %b, i32 %a)
  %spec.store.select8 = sext i32 %0 to i64
  ret i64 %spec.store.select8
}

declare void @use64(i64)
declare i32 @llvm.sadd.sat.i32(i32, i32)
declare i16 @llvm.sadd.sat.i16(i16, i16)
declare i8 @llvm.sadd.sat.i8(i8, i8)
declare i64 @llvm.sadd.sat.i64(i64, i64)
declare <4 x i32> @llvm.sadd.sat.v4i32(<4 x i32>, <4 x i32>)
declare <4 x i16> @llvm.sadd.sat.v4i16(<4 x i16>, <4 x i16>)
declare <2 x i16> @llvm.sadd.sat.v2i16(<2 x i16>, <2 x i16>)
declare <2 x i32> @llvm.sadd.sat.v2i32(<2 x i32>, <2 x i32>)
