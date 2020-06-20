; RUN: llc < %s -mtriple=kvx-kalray-cos | FileCheck %s

define i16 @ctlzi16(i16 %a) {
  %res = call i16 @llvm.ctlz.i16(i16 %a)
  ret i16 %res
  ; CHECK: clzw $r0 = $r1
  ; CHECK: addw $r0 = $r0, -16
  ; CHECK: ret
}

define i32 @clzw(i32 %a) {
  %res = call i32 @llvm.ctlz.i32(i32 %a)
  ret i32 %res
  ; CHECK: clzw $r0 = $r1
  ; CHECK: ret
}

define i64 @clzd(i64 %a) {
  %res = call i64 @llvm.ctlz.i64(i64 %a)
  ret i64 %res
  ; CHECK: clzd $r0 = $r1
  ; CHECK: ret
}

define <2 x i16> @ctlzv2i16(<2 x i16> %a) {
  %res = call <2 x i16> @llvm.ctlz.v2i16(<2 x i16> %a)
  ret <2 x i16> %res
  ; CHECK: clzw $r1 = $r1
  ; CHECK-NEXT: clzw $r0 = $r0
  ; CHECK: addw $r1 = $r1, -16
  ; CHECK-NEXT: addw $r0 = $r0, -16
  ; CHECK: insf $r0 = $r1, 31, 16
  ; CHECK-NEXT: ret
}

define <2 x i32> @clzwp(<2 x i32> %a) {
  %res = call <2 x i32> @llvm.ctlz.v2i32(<2 x i32> %a)
  ret <2 x i32> %res
  ; CHECK: clzwp $r0 = $r0
  ; CHECK: ret
}

define <2 x i64> @ctlzv2i64(<2 x i64> %a) {
  %res = call <2 x i64> @llvm.ctlz.v2i64(<2 x i64> %a)
  ret <2 x i64> %res
  ; CHECK: clzd $r2 = $r0
  ; CHECK-NEXT: clzd $r3 = $r1
  ; CHECK: copyd $r0 = $r2
  ; CHECK-NEXT: copyd $r1 = $r3
  ; CHECK-NEXT: ret
}

declare i16 @llvm.ctlz.i16(i16)
declare i32 @llvm.ctlz.i32(i32)
declare i64 @llvm.ctlz.i64(i64)
declare <2 x i16> @llvm.ctlz.v2i16(<2 x i16>)
declare <2 x i32> @llvm.ctlz.v2i32(<2 x i32>)
declare <2 x i64> @llvm.ctlz.v2i64(<2 x i64>)
