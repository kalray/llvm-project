; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -passes=instcombine -S | FileCheck %s

define i1 @reduce_umax_self(<8 x i1> %x) {
; CHECK-LABEL: @reduce_umax_self(
; CHECK-NEXT:    [[TMP1:%.*]] = call i1 @llvm.vector.reduce.or.v8i1(<8 x i1> [[X:%.*]])
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %res = call i1 @llvm.vector.reduce.umax.v8i32(<8 x i1> %x)
  ret i1 %res
}

define i32 @reduce_umax_sext(<4 x i1> %x) {
; CHECK-LABEL: @reduce_umax_sext(
; CHECK-NEXT:    [[TMP1:%.*]] = call i1 @llvm.vector.reduce.or.v4i1(<4 x i1> [[X:%.*]])
; CHECK-NEXT:    [[TMP2:%.*]] = sext i1 [[TMP1]] to i32
; CHECK-NEXT:    ret i32 [[TMP2]]
;
  %sext = sext <4 x i1> %x to <4 x i32>
  %res = call i32 @llvm.vector.reduce.umax.v4i32(<4 x i32> %sext)
  ret i32 %res
}

define i64 @reduce_umax_zext(<8 x i1> %x) {
; CHECK-LABEL: @reduce_umax_zext(
; CHECK-NEXT:    [[TMP1:%.*]] = call i1 @llvm.vector.reduce.or.v8i1(<8 x i1> [[X:%.*]])
; CHECK-NEXT:    [[TMP2:%.*]] = zext i1 [[TMP1]] to i64
; CHECK-NEXT:    ret i64 [[TMP2]]
;
  %zext = zext <8 x i1> %x to <8 x i64>
  %res = call i64 @llvm.vector.reduce.umax.v8i64(<8 x i64> %zext)
  ret i64 %res
}

define i16 @reduce_umax_sext_same(<16 x i1> %x) {
; CHECK-LABEL: @reduce_umax_sext_same(
; CHECK-NEXT:    [[TMP1:%.*]] = call i1 @llvm.vector.reduce.or.v16i1(<16 x i1> [[X:%.*]])
; CHECK-NEXT:    [[TMP2:%.*]] = sext i1 [[TMP1]] to i16
; CHECK-NEXT:    ret i16 [[TMP2]]
;
  %sext = sext <16 x i1> %x to <16 x i16>
  %res = call i16 @llvm.vector.reduce.umax.v16i16(<16 x i16> %sext)
  ret i16 %res
}

define i8 @reduce_umax_zext_long(<128 x i1> %x) {
; CHECK-LABEL: @reduce_umax_zext_long(
; CHECK-NEXT:    [[TMP1:%.*]] = call i1 @llvm.vector.reduce.or.v128i1(<128 x i1> [[X:%.*]])
; CHECK-NEXT:    [[TMP2:%.*]] = sext i1 [[TMP1]] to i8
; CHECK-NEXT:    ret i8 [[TMP2]]
;
  %sext = sext <128 x i1> %x to <128 x i8>
  %res = call i8 @llvm.vector.reduce.umax.v128i8(<128 x i8> %sext)
  ret i8 %res
}

@glob = external global i8, align 1
define i8 @reduce_umax_zext_long_external_use(<128 x i1> %x) {
; CHECK-LABEL: @reduce_umax_zext_long_external_use(
; CHECK-NEXT:    [[TMP1:%.*]] = call i1 @llvm.vector.reduce.or.v128i1(<128 x i1> [[X:%.*]])
; CHECK-NEXT:    [[TMP2:%.*]] = sext i1 [[TMP1]] to i8
; CHECK-NEXT:    [[TMP3:%.*]] = extractelement <128 x i1> [[X]], i64 0
; CHECK-NEXT:    [[EXT:%.*]] = sext i1 [[TMP3]] to i8
; CHECK-NEXT:    store i8 [[EXT]], i8* @glob, align 1
; CHECK-NEXT:    ret i8 [[TMP2]]
;
  %sext = sext <128 x i1> %x to <128 x i8>
  %res = call i8 @llvm.vector.reduce.umax.v128i8(<128 x i8> %sext)
  %ext = extractelement <128 x i8> %sext, i32 0
  store i8 %ext, i8* @glob, align 1
  ret i8 %res
}

@glob1 = external global i64, align 8
define i64 @reduce_umax_zext_external_use(<8 x i1> %x) {
; CHECK-LABEL: @reduce_umax_zext_external_use(
; CHECK-NEXT:    [[TMP1:%.*]] = call i1 @llvm.vector.reduce.or.v8i1(<8 x i1> [[X:%.*]])
; CHECK-NEXT:    [[TMP2:%.*]] = zext i1 [[TMP1]] to i64
; CHECK-NEXT:    [[TMP3:%.*]] = extractelement <8 x i1> [[X]], i64 0
; CHECK-NEXT:    [[EXT:%.*]] = zext i1 [[TMP3]] to i64
; CHECK-NEXT:    store i64 [[EXT]], i64* @glob1, align 8
; CHECK-NEXT:    ret i64 [[TMP2]]
;
  %zext = zext <8 x i1> %x to <8 x i64>
  %res = call i64 @llvm.vector.reduce.umax.v8i64(<8 x i64> %zext)
  %ext = extractelement <8 x i64> %zext, i32 0
  store i64 %ext, i64* @glob1, align 8
  ret i64 %res
}

declare i1 @llvm.vector.reduce.umax.v8i32(<8 x i1> %a)
declare i32 @llvm.vector.reduce.umax.v4i32(<4 x i32> %a)
declare i64 @llvm.vector.reduce.umax.v8i64(<8 x i64> %a)
declare i16 @llvm.vector.reduce.umax.v16i16(<16 x i16> %a)
declare i8 @llvm.vector.reduce.umax.v128i8(<128 x i8> %a)
