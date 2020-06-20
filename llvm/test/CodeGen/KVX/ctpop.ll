; RUN: llc < %s -mtriple=kvx-kalray-cos | FileCheck %s

define i16 @ctpopi16(i16 %a) {
  %res = call i16 @llvm.ctpop.i16(i16 %a)
  ret i16 %res
  ; CHECK: cbsw $r0 = $r0
  ; CHECK-NEXT: ret
}

define i32 @cbsw(i32 %a) {
  %res = call i32 @llvm.ctpop.i32(i32 %a)
  ret i32 %res
  ; CHECK: cbsw $r0 = $r0
  ; CHECK-NEXT: ret
}

define i64 @cbsd(i64 %a) {
  %res = call i64 @llvm.ctpop.i64(i64 %a)
  ret i64 %res
  ; CHECK: cbsd $r0 = $r0
  ; CHECK: ret
}

define <2 x i16> @ctpopv2i16(<2 x i16> %a) {
  %res = call <2 x i16> @llvm.ctpop.v2i16(<2 x i16> %a)
  ret <2 x i16> %res
  ; FIXME: Can it be expanded using two cbsw insns?
  ; CHECK: srlhqs
  ; CHECK: sbfhq
  ; CHECK: srlhqs
  ; CHECK: addhq
  ; CHECK: srlhqs
  ; CHECK: addhq
  ; CHECK: mulhq
  ; CHECK: srlhqs
  ; CHECK-NEXT: ret
}

define <2 x i32> @cbswp(<2 x i32> %a) {
  %res = call <2 x i32> @llvm.ctpop.v2i32(<2 x i32> %a)
  ret <2 x i32> %res
  ; CHECK: cbswp $r0 = $r0
  ; CHECK-NEXT: ret
}

define <2 x i64> @ctpopv2i64(<2 x i64> %a) {
  %res = call <2 x i64> @llvm.ctpop.v2i64(<2 x i64> %a)
  ret <2 x i64> %res
  ; CHECK: cbsd $r2 = $r0
  ; CHECK-NEXT: cbsd $r3 = $r1
  ; CHECK: copyd $r0 = $r2
  ; CHECK-NEXT: copyd $r1 = $r3
  ; CHECK-NEXT: ret
}

declare i16 @llvm.ctpop.i16(i16)
declare i32 @llvm.ctpop.i32(i32)
declare i64 @llvm.ctpop.i64(i64)
declare <2 x i16> @llvm.ctpop.v2i16(<2 x i16>)
declare <2 x i32> @llvm.ctpop.v2i32(<2 x i32>)
declare <2 x i64> @llvm.ctpop.v2i64(<2 x i64>)
