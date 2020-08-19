; RUN: llc < %s -mtriple=kvx-kalray-cos | FileCheck %s

define i16 @bswapi16(i16 %a) {
  %res = call i16 @llvm.bswap.i16(i16 %a)
  ret i16 %res
  ; CHECK-COUNT-2: sllw
  ; CHECK: srlw
  ; CHECK: ret
}

define i32 @bswapi32(i32 %a) {
  %res = call i32 @llvm.bswap.i32(i32 %a)
  ret i32 %res
  ; CHECK-COUNT-2: srlw
  ; CHECK-COUNT-2: sllw
  ; CHECK: ret
}

define i64 @bswapi64(i64 %a) {
  %res = call i64 @llvm.bswap.i64(i64 %a)
  ret i64 %res
  ; CHECK-COUNT-3: srld
  ; CHECK: slld
  ; CHECK: srld
  ; CHECK-COUNT-3: slld
  ; CHECK: ret
}

define <2 x i16> @bswapv2i16(<2 x i16> %a) {
  %res = call <2 x i16> @llvm.bswap.v2i16(<2 x i16> %a)
  ret <2 x i16> %res
  ; CHECK-COUNT-4: extfz
  ; CHECK: ret
}

define <2 x i32> @bswapv2i32(<2 x i32> %a) {
  %res = call <2 x i32> @llvm.bswap.v2i32(<2 x i32> %a)
  ret <2 x i32> %res
  ; CHECK-COUNT-7: extfz
  ; CHECK: ret
}

define <2 x i64> @bswapv2i64(<2 x i64> %a) {
  %res = call <2 x i64> @llvm.bswap.v2i64(<2 x i64> %a)
  ret <2 x i64> %res
  ; CHECK-COUNT-7: extfz
  ; CHECK: ret
}

declare i16 @llvm.bswap.i16(i16)
declare i32 @llvm.bswap.i32(i32)
declare i64 @llvm.bswap.i64(i64)
declare <2 x i16> @llvm.bswap.v2i16(<2 x i16>)
declare <2 x i32> @llvm.bswap.v2i32(<2 x i32>)
declare <2 x i64> @llvm.bswap.v2i64(<2 x i64>)
