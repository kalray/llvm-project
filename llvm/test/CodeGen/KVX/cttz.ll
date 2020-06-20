; RUN: llc < %s -mtriple=kvx-kalray-cos | FileCheck %s

define i16 @cttzi16(i16 %a) {
  %res = call i16 @llvm.cttz.i16(i16 %a)
  ret i16 %res
  ; CHECK: ctzw $r0 = $r1
  ; CHECK: ret
}

define i32 @ctzw(i32 %a) {
  %res = call i32 @llvm.cttz.i32(i32 %a)
  ret i32 %res
  ; CHECK: ctzw $r0 = $r1
  ; CHECK: ret
}

define i64 @ctzd(i64 %a) {
  %res = call i64 @llvm.cttz.i64(i64 %a)
  ret i64 %res
  ; CHECK: ctzd $r0 = $r1
  ; CHECK: ret
}

define <2 x i16> @cttzv2i16(<2 x i16> %a) {
  %res = call <2 x i16> @llvm.cttz.v2i16(<2 x i16> %a)
  ret <2 x i16> %res
  ; CHECK: ctzw $r1 = $r1
  ; CHECK-NEXT: ctzw $r0 = $r0
  ; CHECK: insf $r0 = $r1, 31, 16
  ; CHECK-NEXT: ret
}

define <2 x i32> @ctzwp(<2 x i32> %a) {
  %res = call <2 x i32> @llvm.cttz.v2i32(<2 x i32> %a)
  ret <2 x i32> %res
  ; CHECK: ctzwp $r0 = $r0
  ; CHECK: ret
}

define <2 x i64> @cttzv2i64(<2 x i64> %a) {
  %res = call <2 x i64> @llvm.cttz.v2i64(<2 x i64> %a)
  ret <2 x i64> %res
  ; CHECK: ctzd $r2 = $r0
  ; CHECK-NEXT: ctzd $r3 = $r1
  ; CHECK: copyd $r0 = $r2
  ; CHECK-NEXT: copyd $r1 = $r3
  ; CHECK-NEXT: ret
}

declare i16 @llvm.cttz.i16(i16)
declare i32 @llvm.cttz.i32(i32)
declare i64 @llvm.cttz.i64(i64)
declare <2 x i16> @llvm.cttz.v2i16(<2 x i16>)
declare <2 x i32> @llvm.cttz.v2i32(<2 x i32>)
declare <2 x i64> @llvm.cttz.v2i64(<2 x i64>)
