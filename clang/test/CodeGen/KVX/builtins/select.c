// NOTE: Assertions have been autogenerated by utils/update_cc_test_checks.py
// RUN: %clang_cc1 -target-cpu kv3-2 -triple kvx-kalray-cos -S -O2 -emit-llvm -o - %s | FileCheck %s
// RUN: %clang_cc1 -target-cpu kv3-1 -triple kvx-kalray-cos -S -O2 -emit-llvm -o - %s | FileCheck %s

#include "vector-types.h"

// CHECK-LABEL: @selectd(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.kvx.select.i64(i64 [[T:%.*]], i64 [[F:%.*]], i64 [[C:%.*]], i32 7)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
unsigned long long selectd(unsigned long long t, unsigned long long f, unsigned long long c) {
  return __builtin_kvx_selectd(t, f, c, ".even");
}

// CHECK-LABEL: @selectdp(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = extractelement <2 x i64> [[T:%.*]], i64 0
// CHECK-NEXT:    [[TMP1:%.*]] = extractelement <2 x i64> [[F:%.*]], i64 0
// CHECK-NEXT:    [[TMP2:%.*]] = extractelement <2 x i64> [[C:%.*]], i64 0
// CHECK-NEXT:    [[TMP3:%.*]] = tail call i64 @llvm.kvx.select.i64(i64 [[TMP0]], i64 [[TMP1]], i64 [[TMP2]], i32 7)
// CHECK-NEXT:    [[TMP4:%.*]] = extractelement <2 x i64> [[T]], i64 1
// CHECK-NEXT:    [[TMP5:%.*]] = extractelement <2 x i64> [[F]], i64 1
// CHECK-NEXT:    [[TMP6:%.*]] = extractelement <2 x i64> [[C]], i64 1
// CHECK-NEXT:    [[TMP7:%.*]] = tail call i64 @llvm.kvx.select.i64(i64 [[TMP4]], i64 [[TMP5]], i64 [[TMP6]], i32 7)
// CHECK-NEXT:    [[TMP8:%.*]] = insertelement <2 x i64> undef, i64 [[TMP3]], i64 0
// CHECK-NEXT:    [[TMP9:%.*]] = insertelement <2 x i64> [[TMP8]], i64 [[TMP7]], i64 1
// CHECK-NEXT:    ret <2 x i64> [[TMP9]]
//
v2i64 selectdp(v2i64 t, v2i64 f, v2i64 c) {
  return __builtin_kvx_selectdp(t, f, c, ".even");
}

// CHECK-LABEL: @selectdq(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = extractelement <4 x i64> [[T:%.*]], i64 0
// CHECK-NEXT:    [[TMP1:%.*]] = extractelement <4 x i64> [[F:%.*]], i64 0
// CHECK-NEXT:    [[TMP2:%.*]] = extractelement <4 x i64> [[C:%.*]], i64 0
// CHECK-NEXT:    [[TMP3:%.*]] = tail call i64 @llvm.kvx.select.i64(i64 [[TMP0]], i64 [[TMP1]], i64 [[TMP2]], i32 7)
// CHECK-NEXT:    [[TMP4:%.*]] = extractelement <4 x i64> [[T]], i64 1
// CHECK-NEXT:    [[TMP5:%.*]] = extractelement <4 x i64> [[F]], i64 1
// CHECK-NEXT:    [[TMP6:%.*]] = extractelement <4 x i64> [[C]], i64 1
// CHECK-NEXT:    [[TMP7:%.*]] = tail call i64 @llvm.kvx.select.i64(i64 [[TMP4]], i64 [[TMP5]], i64 [[TMP6]], i32 7)
// CHECK-NEXT:    [[TMP8:%.*]] = extractelement <4 x i64> [[T]], i64 2
// CHECK-NEXT:    [[TMP9:%.*]] = extractelement <4 x i64> [[F]], i64 2
// CHECK-NEXT:    [[TMP10:%.*]] = extractelement <4 x i64> [[C]], i64 2
// CHECK-NEXT:    [[TMP11:%.*]] = tail call i64 @llvm.kvx.select.i64(i64 [[TMP8]], i64 [[TMP9]], i64 [[TMP10]], i32 7)
// CHECK-NEXT:    [[TMP12:%.*]] = extractelement <4 x i64> [[T]], i64 3
// CHECK-NEXT:    [[TMP13:%.*]] = extractelement <4 x i64> [[F]], i64 3
// CHECK-NEXT:    [[TMP14:%.*]] = extractelement <4 x i64> [[C]], i64 3
// CHECK-NEXT:    [[TMP15:%.*]] = tail call i64 @llvm.kvx.select.i64(i64 [[TMP12]], i64 [[TMP13]], i64 [[TMP14]], i32 7)
// CHECK-NEXT:    [[TMP16:%.*]] = insertelement <4 x i64> undef, i64 [[TMP3]], i64 0
// CHECK-NEXT:    [[TMP17:%.*]] = insertelement <4 x i64> [[TMP16]], i64 [[TMP7]], i64 1
// CHECK-NEXT:    [[TMP18:%.*]] = insertelement <4 x i64> [[TMP17]], i64 [[TMP11]], i64 2
// CHECK-NEXT:    [[TMP19:%.*]] = insertelement <4 x i64> [[TMP18]], i64 [[TMP15]], i64 3
// CHECK-NEXT:    ret <4 x i64> [[TMP19]]
//
v4i64 selectdq(v4i64 t, v4i64 f, v4i64 c) {
  return __builtin_kvx_selectdq(t, f, c, ".even");
}

// CHECK-LABEL: @selectdo(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[T:%.*]] = load <8 x i64>, ptr [[TMP0:%.*]], align 32, !tbaa [[TBAA2:![0-9]+]]
// CHECK-NEXT:    [[F:%.*]] = load <8 x i64>, ptr [[TMP1:%.*]], align 32, !tbaa [[TBAA2]]
// CHECK-NEXT:    [[C:%.*]] = load <8 x i64>, ptr [[TMP2:%.*]], align 32, !tbaa [[TBAA2]]
// CHECK-NEXT:    [[TMP3:%.*]] = extractelement <8 x i64> [[T]], i64 0
// CHECK-NEXT:    [[TMP4:%.*]] = extractelement <8 x i64> [[F]], i64 0
// CHECK-NEXT:    [[TMP5:%.*]] = extractelement <8 x i64> [[C]], i64 0
// CHECK-NEXT:    [[TMP6:%.*]] = tail call i64 @llvm.kvx.select.i64(i64 [[TMP3]], i64 [[TMP4]], i64 [[TMP5]], i32 7)
// CHECK-NEXT:    [[TMP7:%.*]] = extractelement <8 x i64> [[T]], i64 1
// CHECK-NEXT:    [[TMP8:%.*]] = extractelement <8 x i64> [[F]], i64 1
// CHECK-NEXT:    [[TMP9:%.*]] = extractelement <8 x i64> [[C]], i64 1
// CHECK-NEXT:    [[TMP10:%.*]] = tail call i64 @llvm.kvx.select.i64(i64 [[TMP7]], i64 [[TMP8]], i64 [[TMP9]], i32 7)
// CHECK-NEXT:    [[TMP11:%.*]] = extractelement <8 x i64> [[T]], i64 2
// CHECK-NEXT:    [[TMP12:%.*]] = extractelement <8 x i64> [[F]], i64 2
// CHECK-NEXT:    [[TMP13:%.*]] = extractelement <8 x i64> [[C]], i64 2
// CHECK-NEXT:    [[TMP14:%.*]] = tail call i64 @llvm.kvx.select.i64(i64 [[TMP11]], i64 [[TMP12]], i64 [[TMP13]], i32 7)
// CHECK-NEXT:    [[TMP15:%.*]] = extractelement <8 x i64> [[T]], i64 3
// CHECK-NEXT:    [[TMP16:%.*]] = extractelement <8 x i64> [[F]], i64 3
// CHECK-NEXT:    [[TMP17:%.*]] = extractelement <8 x i64> [[C]], i64 3
// CHECK-NEXT:    [[TMP18:%.*]] = tail call i64 @llvm.kvx.select.i64(i64 [[TMP15]], i64 [[TMP16]], i64 [[TMP17]], i32 7)
// CHECK-NEXT:    [[TMP19:%.*]] = extractelement <8 x i64> [[T]], i64 4
// CHECK-NEXT:    [[TMP20:%.*]] = extractelement <8 x i64> [[F]], i64 4
// CHECK-NEXT:    [[TMP21:%.*]] = extractelement <8 x i64> [[C]], i64 4
// CHECK-NEXT:    [[TMP22:%.*]] = tail call i64 @llvm.kvx.select.i64(i64 [[TMP19]], i64 [[TMP20]], i64 [[TMP21]], i32 7)
// CHECK-NEXT:    [[TMP23:%.*]] = extractelement <8 x i64> [[T]], i64 5
// CHECK-NEXT:    [[TMP24:%.*]] = extractelement <8 x i64> [[F]], i64 5
// CHECK-NEXT:    [[TMP25:%.*]] = extractelement <8 x i64> [[C]], i64 5
// CHECK-NEXT:    [[TMP26:%.*]] = tail call i64 @llvm.kvx.select.i64(i64 [[TMP23]], i64 [[TMP24]], i64 [[TMP25]], i32 7)
// CHECK-NEXT:    [[TMP27:%.*]] = extractelement <8 x i64> [[T]], i64 6
// CHECK-NEXT:    [[TMP28:%.*]] = extractelement <8 x i64> [[F]], i64 6
// CHECK-NEXT:    [[TMP29:%.*]] = extractelement <8 x i64> [[C]], i64 6
// CHECK-NEXT:    [[TMP30:%.*]] = tail call i64 @llvm.kvx.select.i64(i64 [[TMP27]], i64 [[TMP28]], i64 [[TMP29]], i32 7)
// CHECK-NEXT:    [[TMP31:%.*]] = extractelement <8 x i64> [[T]], i64 7
// CHECK-NEXT:    [[TMP32:%.*]] = extractelement <8 x i64> [[F]], i64 7
// CHECK-NEXT:    [[TMP33:%.*]] = extractelement <8 x i64> [[C]], i64 7
// CHECK-NEXT:    [[TMP34:%.*]] = tail call i64 @llvm.kvx.select.i64(i64 [[TMP31]], i64 [[TMP32]], i64 [[TMP33]], i32 7)
// CHECK-NEXT:    [[TMP35:%.*]] = insertelement <8 x i64> undef, i64 [[TMP6]], i64 0
// CHECK-NEXT:    [[TMP36:%.*]] = insertelement <8 x i64> [[TMP35]], i64 [[TMP10]], i64 1
// CHECK-NEXT:    [[TMP37:%.*]] = insertelement <8 x i64> [[TMP36]], i64 [[TMP14]], i64 2
// CHECK-NEXT:    [[TMP38:%.*]] = insertelement <8 x i64> [[TMP37]], i64 [[TMP18]], i64 3
// CHECK-NEXT:    [[TMP39:%.*]] = insertelement <8 x i64> [[TMP38]], i64 [[TMP22]], i64 4
// CHECK-NEXT:    [[TMP40:%.*]] = insertelement <8 x i64> [[TMP39]], i64 [[TMP26]], i64 5
// CHECK-NEXT:    [[TMP41:%.*]] = insertelement <8 x i64> [[TMP40]], i64 [[TMP30]], i64 6
// CHECK-NEXT:    [[TMP42:%.*]] = insertelement <8 x i64> [[TMP41]], i64 [[TMP34]], i64 7
// CHECK-NEXT:    store <8 x i64> [[TMP42]], ptr [[AGG_RESULT:%.*]], align 32, !tbaa [[TBAA2]]
// CHECK-NEXT:    ret void
//
v8i64 selectdo(v8i64 t, v8i64 f, v8i64 c) {
  return __builtin_kvx_selectdo(t, f, c, ".even");
}

// CHECK-LABEL: @selectfd(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[CONV:%.*]] = fptoui double [[C:%.*]] to i64
// CHECK-NEXT:    [[TMP0:%.*]] = tail call double @llvm.kvx.select.f64(double [[T:%.*]], double [[F:%.*]], i64 [[CONV]], i32 7)
// CHECK-NEXT:    ret double [[TMP0]]
//
double selectfd(double t, double f, double c) {
  return __builtin_kvx_selectfd(t, f, c, ".even");
}

// CHECK-LABEL: @selectfdp(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = extractelement <2 x double> [[T:%.*]], i64 0
// CHECK-NEXT:    [[TMP1:%.*]] = extractelement <2 x double> [[F:%.*]], i64 0
// CHECK-NEXT:    [[TMP2:%.*]] = bitcast <2 x double> [[C:%.*]] to <2 x i64>
// CHECK-NEXT:    [[TMP3:%.*]] = extractelement <2 x i64> [[TMP2]], i64 0
// CHECK-NEXT:    [[TMP4:%.*]] = tail call double @llvm.kvx.select.f64(double [[TMP0]], double [[TMP1]], i64 [[TMP3]], i32 7)
// CHECK-NEXT:    [[TMP5:%.*]] = extractelement <2 x double> [[T]], i64 1
// CHECK-NEXT:    [[TMP6:%.*]] = extractelement <2 x double> [[F]], i64 1
// CHECK-NEXT:    [[TMP7:%.*]] = extractelement <2 x i64> [[TMP2]], i64 1
// CHECK-NEXT:    [[TMP8:%.*]] = tail call double @llvm.kvx.select.f64(double [[TMP5]], double [[TMP6]], i64 [[TMP7]], i32 7)
// CHECK-NEXT:    [[TMP9:%.*]] = insertelement <2 x double> undef, double [[TMP4]], i64 0
// CHECK-NEXT:    [[TMP10:%.*]] = insertelement <2 x double> [[TMP9]], double [[TMP8]], i64 1
// CHECK-NEXT:    ret <2 x double> [[TMP10]]
//
v2f64 selectfdp(v2f64 t, v2f64 f, v2f64 c) {
  return __builtin_kvx_selectfdp(t, f, c, ".even");
}

// CHECK-LABEL: @selectfdq(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = extractelement <4 x double> [[T:%.*]], i64 0
// CHECK-NEXT:    [[TMP1:%.*]] = extractelement <4 x double> [[F:%.*]], i64 0
// CHECK-NEXT:    [[TMP2:%.*]] = bitcast <4 x double> [[C:%.*]] to <4 x i64>
// CHECK-NEXT:    [[TMP3:%.*]] = extractelement <4 x i64> [[TMP2]], i64 0
// CHECK-NEXT:    [[TMP4:%.*]] = tail call double @llvm.kvx.select.f64(double [[TMP0]], double [[TMP1]], i64 [[TMP3]], i32 7)
// CHECK-NEXT:    [[TMP5:%.*]] = extractelement <4 x double> [[T]], i64 1
// CHECK-NEXT:    [[TMP6:%.*]] = extractelement <4 x double> [[F]], i64 1
// CHECK-NEXT:    [[TMP7:%.*]] = extractelement <4 x i64> [[TMP2]], i64 1
// CHECK-NEXT:    [[TMP8:%.*]] = tail call double @llvm.kvx.select.f64(double [[TMP5]], double [[TMP6]], i64 [[TMP7]], i32 7)
// CHECK-NEXT:    [[TMP9:%.*]] = extractelement <4 x double> [[T]], i64 2
// CHECK-NEXT:    [[TMP10:%.*]] = extractelement <4 x double> [[F]], i64 2
// CHECK-NEXT:    [[TMP11:%.*]] = extractelement <4 x i64> [[TMP2]], i64 2
// CHECK-NEXT:    [[TMP12:%.*]] = tail call double @llvm.kvx.select.f64(double [[TMP9]], double [[TMP10]], i64 [[TMP11]], i32 7)
// CHECK-NEXT:    [[TMP13:%.*]] = extractelement <4 x double> [[T]], i64 3
// CHECK-NEXT:    [[TMP14:%.*]] = extractelement <4 x double> [[F]], i64 3
// CHECK-NEXT:    [[TMP15:%.*]] = extractelement <4 x i64> [[TMP2]], i64 3
// CHECK-NEXT:    [[TMP16:%.*]] = tail call double @llvm.kvx.select.f64(double [[TMP13]], double [[TMP14]], i64 [[TMP15]], i32 7)
// CHECK-NEXT:    [[TMP17:%.*]] = insertelement <4 x double> undef, double [[TMP4]], i64 0
// CHECK-NEXT:    [[TMP18:%.*]] = insertelement <4 x double> [[TMP17]], double [[TMP8]], i64 1
// CHECK-NEXT:    [[TMP19:%.*]] = insertelement <4 x double> [[TMP18]], double [[TMP12]], i64 2
// CHECK-NEXT:    [[TMP20:%.*]] = insertelement <4 x double> [[TMP19]], double [[TMP16]], i64 3
// CHECK-NEXT:    ret <4 x double> [[TMP20]]
//
v4f64 selectfdq(v4f64 t, v4f64 f, v4f64 c) {
  return __builtin_kvx_selectfdq(t, f, c, ".even");
}

// CHECK-LABEL: @selectfw(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[CONV:%.*]] = fptoui float [[C:%.*]] to i64
// CHECK-NEXT:    [[TMP0:%.*]] = tail call float @llvm.kvx.select.f32(float [[T:%.*]], float [[F:%.*]], i64 [[CONV]], i32 7)
// CHECK-NEXT:    ret float [[TMP0]]
//
float selectfw(float t, float f, float c) {
  return __builtin_kvx_selectfw(t, f, c, ".even");
}

// CHECK-LABEL: @selectfwp(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call <2 x float> @llvm.kvx.select.vec.v2f32(<2 x float> [[T:%.*]], <2 x float> [[F:%.*]], <2 x i32> [[C:%.*]], i32 7)
// CHECK-NEXT:    ret <2 x float> [[TMP0]]
//
v2f32 selectfwp(v2f32 t, v2f32 f, v2i32 c) {
  return __builtin_kvx_selectfwp(t, f, c, ".even");
}

// CHECK-LABEL: @selectfwq(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = shufflevector <4 x float> [[T:%.*]], <4 x float> poison, <2 x i32> <i32 0, i32 1>
// CHECK-NEXT:    [[TMP1:%.*]] = shufflevector <4 x float> [[F:%.*]], <4 x float> poison, <2 x i32> <i32 0, i32 1>
// CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <4 x i32> [[C:%.*]], <4 x i32> poison, <2 x i32> <i32 0, i32 1>
// CHECK-NEXT:    [[TMP3:%.*]] = tail call <2 x float> @llvm.kvx.select.vec.v2f32(<2 x float> [[TMP0]], <2 x float> [[TMP1]], <2 x i32> [[TMP2]], i32 7)
// CHECK-NEXT:    [[TMP4:%.*]] = shufflevector <4 x float> [[T]], <4 x float> poison, <2 x i32> <i32 2, i32 3>
// CHECK-NEXT:    [[TMP5:%.*]] = shufflevector <4 x float> [[F]], <4 x float> poison, <2 x i32> <i32 2, i32 3>
// CHECK-NEXT:    [[TMP6:%.*]] = shufflevector <4 x i32> [[C]], <4 x i32> poison, <2 x i32> <i32 2, i32 3>
// CHECK-NEXT:    [[TMP7:%.*]] = tail call <2 x float> @llvm.kvx.select.vec.v2f32(<2 x float> [[TMP4]], <2 x float> [[TMP5]], <2 x i32> [[TMP6]], i32 7)
// CHECK-NEXT:    [[TMP8:%.*]] = shufflevector <2 x float> [[TMP3]], <2 x float> [[TMP7]], <4 x i32> <i32 0, i32 1, i32 2, i32 3>
// CHECK-NEXT:    ret <4 x float> [[TMP8]]
//
v4f32 selectfwq(v4f32 t, v4f32 f, v4i32 c) {
  return __builtin_kvx_selectfwq(t, f, c, ".even");
}

// CHECK-LABEL: @selectfwo(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = shufflevector <8 x float> [[T:%.*]], <8 x float> poison, <2 x i32> <i32 0, i32 1>
// CHECK-NEXT:    [[TMP1:%.*]] = shufflevector <8 x float> [[F:%.*]], <8 x float> poison, <2 x i32> <i32 0, i32 1>
// CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <8 x i32> [[C:%.*]], <8 x i32> poison, <2 x i32> <i32 0, i32 1>
// CHECK-NEXT:    [[TMP3:%.*]] = tail call <2 x float> @llvm.kvx.select.vec.v2f32(<2 x float> [[TMP0]], <2 x float> [[TMP1]], <2 x i32> [[TMP2]], i32 7)
// CHECK-NEXT:    [[TMP4:%.*]] = shufflevector <8 x float> [[T]], <8 x float> poison, <2 x i32> <i32 2, i32 3>
// CHECK-NEXT:    [[TMP5:%.*]] = shufflevector <8 x float> [[F]], <8 x float> poison, <2 x i32> <i32 2, i32 3>
// CHECK-NEXT:    [[TMP6:%.*]] = shufflevector <8 x i32> [[C]], <8 x i32> poison, <2 x i32> <i32 2, i32 3>
// CHECK-NEXT:    [[TMP7:%.*]] = tail call <2 x float> @llvm.kvx.select.vec.v2f32(<2 x float> [[TMP4]], <2 x float> [[TMP5]], <2 x i32> [[TMP6]], i32 7)
// CHECK-NEXT:    [[TMP8:%.*]] = shufflevector <8 x float> [[T]], <8 x float> poison, <2 x i32> <i32 4, i32 5>
// CHECK-NEXT:    [[TMP9:%.*]] = shufflevector <8 x float> [[F]], <8 x float> poison, <2 x i32> <i32 4, i32 5>
// CHECK-NEXT:    [[TMP10:%.*]] = shufflevector <8 x i32> [[C]], <8 x i32> poison, <2 x i32> <i32 4, i32 5>
// CHECK-NEXT:    [[TMP11:%.*]] = tail call <2 x float> @llvm.kvx.select.vec.v2f32(<2 x float> [[TMP8]], <2 x float> [[TMP9]], <2 x i32> [[TMP10]], i32 7)
// CHECK-NEXT:    [[TMP12:%.*]] = shufflevector <8 x float> [[T]], <8 x float> poison, <2 x i32> <i32 6, i32 7>
// CHECK-NEXT:    [[TMP13:%.*]] = shufflevector <8 x float> [[F]], <8 x float> poison, <2 x i32> <i32 6, i32 7>
// CHECK-NEXT:    [[TMP14:%.*]] = shufflevector <8 x i32> [[C]], <8 x i32> poison, <2 x i32> <i32 6, i32 7>
// CHECK-NEXT:    [[TMP15:%.*]] = tail call <2 x float> @llvm.kvx.select.vec.v2f32(<2 x float> [[TMP12]], <2 x float> [[TMP13]], <2 x i32> [[TMP14]], i32 7)
// CHECK-NEXT:    [[TMP16:%.*]] = shufflevector <2 x float> [[TMP3]], <2 x float> [[TMP7]], <4 x i32> <i32 0, i32 1, i32 2, i32 3>
// CHECK-NEXT:    [[TMP17:%.*]] = shufflevector <2 x float> [[TMP11]], <2 x float> [[TMP15]], <4 x i32> <i32 0, i32 1, i32 2, i32 3>
// CHECK-NEXT:    [[TMP18:%.*]] = shufflevector <4 x float> [[TMP16]], <4 x float> [[TMP17]], <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
// CHECK-NEXT:    ret <8 x float> [[TMP18]]
//
v8f32 selectfwo(v8f32 t, v8f32 f, v8i32 c) {
  return __builtin_kvx_selectfwo(t, f, c, ".even");
}

// CHECK-LABEL: @selectfho(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = shufflevector <8 x half> [[T:%.*]], <8 x half> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
// CHECK-NEXT:    [[TMP1:%.*]] = shufflevector <8 x half> [[F:%.*]], <8 x half> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
// CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <8 x i16> [[C:%.*]], <8 x i16> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
// CHECK-NEXT:    [[TMP3:%.*]] = tail call <4 x half> @llvm.kvx.select.vec.v4f16(<4 x half> [[TMP0]], <4 x half> [[TMP1]], <4 x i16> [[TMP2]], i32 7)
// CHECK-NEXT:    [[TMP4:%.*]] = shufflevector <8 x half> [[T]], <8 x half> poison, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
// CHECK-NEXT:    [[TMP5:%.*]] = shufflevector <8 x half> [[F]], <8 x half> poison, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
// CHECK-NEXT:    [[TMP6:%.*]] = shufflevector <8 x i16> [[C]], <8 x i16> poison, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
// CHECK-NEXT:    [[TMP7:%.*]] = tail call <4 x half> @llvm.kvx.select.vec.v4f16(<4 x half> [[TMP4]], <4 x half> [[TMP5]], <4 x i16> [[TMP6]], i32 7)
// CHECK-NEXT:    [[TMP8:%.*]] = shufflevector <4 x half> [[TMP3]], <4 x half> [[TMP7]], <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
// CHECK-NEXT:    ret <8 x half> [[TMP8]]
//
v8f16 selectfho(v8f16 t, v8f16 f, v8i16 c) {
  return __builtin_kvx_selectfho(t, f, c, ".even");
}

// CHECK-LABEL: @selectfhp(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call <2 x half> @llvm.kvx.select.vec.v2f16(<2 x half> [[T:%.*]], <2 x half> [[F:%.*]], <2 x i16> [[C:%.*]], i32 7)
// CHECK-NEXT:    ret <2 x half> [[TMP0]]
//
v2f16 selectfhp(v2f16 t, v2f16 f, v2i16 c) {
  return __builtin_kvx_selectfhp(t, f, c, ".even");
}

// CHECK-LABEL: @selectfhq(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call <4 x half> @llvm.kvx.select.vec.v4f16(<4 x half> [[T:%.*]], <4 x half> [[F:%.*]], <4 x i16> [[C:%.*]], i32 7)
// CHECK-NEXT:    ret <4 x half> [[TMP0]]
//
v4f16 selectfhq(v4f16 t, v4f16 f, v4i16 c) {
  return __builtin_kvx_selectfhq(t, f, c, ".even");
}

// CHECK-LABEL: @selectfhx(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = shufflevector <16 x half> [[T:%.*]], <16 x half> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
// CHECK-NEXT:    [[TMP1:%.*]] = shufflevector <16 x half> [[F:%.*]], <16 x half> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
// CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <16 x i16> [[C:%.*]], <16 x i16> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
// CHECK-NEXT:    [[TMP3:%.*]] = tail call <4 x half> @llvm.kvx.select.vec.v4f16(<4 x half> [[TMP0]], <4 x half> [[TMP1]], <4 x i16> [[TMP2]], i32 7)
// CHECK-NEXT:    [[TMP4:%.*]] = shufflevector <16 x half> [[T]], <16 x half> poison, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
// CHECK-NEXT:    [[TMP5:%.*]] = shufflevector <16 x half> [[F]], <16 x half> poison, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
// CHECK-NEXT:    [[TMP6:%.*]] = shufflevector <16 x i16> [[C]], <16 x i16> poison, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
// CHECK-NEXT:    [[TMP7:%.*]] = tail call <4 x half> @llvm.kvx.select.vec.v4f16(<4 x half> [[TMP4]], <4 x half> [[TMP5]], <4 x i16> [[TMP6]], i32 7)
// CHECK-NEXT:    [[TMP8:%.*]] = shufflevector <16 x half> [[T]], <16 x half> poison, <4 x i32> <i32 8, i32 9, i32 10, i32 11>
// CHECK-NEXT:    [[TMP9:%.*]] = shufflevector <16 x half> [[F]], <16 x half> poison, <4 x i32> <i32 8, i32 9, i32 10, i32 11>
// CHECK-NEXT:    [[TMP10:%.*]] = shufflevector <16 x i16> [[C]], <16 x i16> poison, <4 x i32> <i32 8, i32 9, i32 10, i32 11>
// CHECK-NEXT:    [[TMP11:%.*]] = tail call <4 x half> @llvm.kvx.select.vec.v4f16(<4 x half> [[TMP8]], <4 x half> [[TMP9]], <4 x i16> [[TMP10]], i32 7)
// CHECK-NEXT:    [[TMP12:%.*]] = shufflevector <16 x half> [[T]], <16 x half> poison, <4 x i32> <i32 12, i32 13, i32 14, i32 15>
// CHECK-NEXT:    [[TMP13:%.*]] = shufflevector <16 x half> [[F]], <16 x half> poison, <4 x i32> <i32 12, i32 13, i32 14, i32 15>
// CHECK-NEXT:    [[TMP14:%.*]] = shufflevector <16 x i16> [[C]], <16 x i16> poison, <4 x i32> <i32 12, i32 13, i32 14, i32 15>
// CHECK-NEXT:    [[TMP15:%.*]] = tail call <4 x half> @llvm.kvx.select.vec.v4f16(<4 x half> [[TMP12]], <4 x half> [[TMP13]], <4 x i16> [[TMP14]], i32 7)
// CHECK-NEXT:    [[TMP16:%.*]] = shufflevector <4 x half> [[TMP3]], <4 x half> [[TMP7]], <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
// CHECK-NEXT:    [[TMP17:%.*]] = shufflevector <4 x half> [[TMP11]], <4 x half> [[TMP15]], <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
// CHECK-NEXT:    [[TMP18:%.*]] = shufflevector <8 x half> [[TMP16]], <8 x half> [[TMP17]], <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
// CHECK-NEXT:    ret <16 x half> [[TMP18]]
//
v16f16 selectfhx(v16f16 t, v16f16 f, v16i16 c) {
  return __builtin_kvx_selectfhx(t, f, c, ".even");
}

// CHECK-LABEL: @selectho(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = shufflevector <8 x i16> [[T:%.*]], <8 x i16> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
// CHECK-NEXT:    [[TMP1:%.*]] = shufflevector <8 x i16> [[F:%.*]], <8 x i16> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
// CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <8 x i16> [[C:%.*]], <8 x i16> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
// CHECK-NEXT:    [[TMP3:%.*]] = tail call <4 x i16> @llvm.kvx.select.vec.v4i16(<4 x i16> [[TMP0]], <4 x i16> [[TMP1]], <4 x i16> [[TMP2]], i32 7)
// CHECK-NEXT:    [[TMP4:%.*]] = shufflevector <8 x i16> [[T]], <8 x i16> poison, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
// CHECK-NEXT:    [[TMP5:%.*]] = shufflevector <8 x i16> [[F]], <8 x i16> poison, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
// CHECK-NEXT:    [[TMP6:%.*]] = shufflevector <8 x i16> [[C]], <8 x i16> poison, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
// CHECK-NEXT:    [[TMP7:%.*]] = tail call <4 x i16> @llvm.kvx.select.vec.v4i16(<4 x i16> [[TMP4]], <4 x i16> [[TMP5]], <4 x i16> [[TMP6]], i32 7)
// CHECK-NEXT:    [[TMP8:%.*]] = shufflevector <4 x i16> [[TMP3]], <4 x i16> [[TMP7]], <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
// CHECK-NEXT:    ret <8 x i16> [[TMP8]]
//
v8i16 selectho(v8i16 t, v8i16 f, v8i16 c) {
  return __builtin_kvx_selectho(t, f, c, ".even");
}

// CHECK-LABEL: @selecthp(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call <2 x i16> @llvm.kvx.select.vec.v2i16(<2 x i16> [[T:%.*]], <2 x i16> [[F:%.*]], <2 x i16> [[C:%.*]], i32 7)
// CHECK-NEXT:    ret <2 x i16> [[TMP0]]
//
v2i16 selecthp(v2i16 t, v2i16 f, v2i16 c) {
  return __builtin_kvx_selecthp(t, f, c, ".even");
}

// CHECK-LABEL: @selecthq(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call <4 x i16> @llvm.kvx.select.vec.v4i16(<4 x i16> [[T:%.*]], <4 x i16> [[F:%.*]], <4 x i16> [[C:%.*]], i32 7)
// CHECK-NEXT:    ret <4 x i16> [[TMP0]]
//
v4i16 selecthq(v4i16 t, v4i16 f, v4i16 c) {
  return __builtin_kvx_selecthq(t, f, c, ".even");
}

// CHECK-LABEL: @selecthx(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = shufflevector <16 x i16> [[T:%.*]], <16 x i16> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
// CHECK-NEXT:    [[TMP1:%.*]] = shufflevector <16 x i16> [[F:%.*]], <16 x i16> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
// CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <16 x i16> [[C:%.*]], <16 x i16> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
// CHECK-NEXT:    [[TMP3:%.*]] = tail call <4 x i16> @llvm.kvx.select.vec.v4i16(<4 x i16> [[TMP0]], <4 x i16> [[TMP1]], <4 x i16> [[TMP2]], i32 7)
// CHECK-NEXT:    [[TMP4:%.*]] = shufflevector <16 x i16> [[T]], <16 x i16> poison, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
// CHECK-NEXT:    [[TMP5:%.*]] = shufflevector <16 x i16> [[F]], <16 x i16> poison, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
// CHECK-NEXT:    [[TMP6:%.*]] = shufflevector <16 x i16> [[C]], <16 x i16> poison, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
// CHECK-NEXT:    [[TMP7:%.*]] = tail call <4 x i16> @llvm.kvx.select.vec.v4i16(<4 x i16> [[TMP4]], <4 x i16> [[TMP5]], <4 x i16> [[TMP6]], i32 7)
// CHECK-NEXT:    [[TMP8:%.*]] = shufflevector <16 x i16> [[T]], <16 x i16> poison, <4 x i32> <i32 8, i32 9, i32 10, i32 11>
// CHECK-NEXT:    [[TMP9:%.*]] = shufflevector <16 x i16> [[F]], <16 x i16> poison, <4 x i32> <i32 8, i32 9, i32 10, i32 11>
// CHECK-NEXT:    [[TMP10:%.*]] = shufflevector <16 x i16> [[C]], <16 x i16> poison, <4 x i32> <i32 8, i32 9, i32 10, i32 11>
// CHECK-NEXT:    [[TMP11:%.*]] = tail call <4 x i16> @llvm.kvx.select.vec.v4i16(<4 x i16> [[TMP8]], <4 x i16> [[TMP9]], <4 x i16> [[TMP10]], i32 7)
// CHECK-NEXT:    [[TMP12:%.*]] = shufflevector <16 x i16> [[T]], <16 x i16> poison, <4 x i32> <i32 12, i32 13, i32 14, i32 15>
// CHECK-NEXT:    [[TMP13:%.*]] = shufflevector <16 x i16> [[F]], <16 x i16> poison, <4 x i32> <i32 12, i32 13, i32 14, i32 15>
// CHECK-NEXT:    [[TMP14:%.*]] = shufflevector <16 x i16> [[C]], <16 x i16> poison, <4 x i32> <i32 12, i32 13, i32 14, i32 15>
// CHECK-NEXT:    [[TMP15:%.*]] = tail call <4 x i16> @llvm.kvx.select.vec.v4i16(<4 x i16> [[TMP12]], <4 x i16> [[TMP13]], <4 x i16> [[TMP14]], i32 7)
// CHECK-NEXT:    [[TMP16:%.*]] = shufflevector <4 x i16> [[TMP3]], <4 x i16> [[TMP7]], <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
// CHECK-NEXT:    [[TMP17:%.*]] = shufflevector <4 x i16> [[TMP11]], <4 x i16> [[TMP15]], <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
// CHECK-NEXT:    [[TMP18:%.*]] = shufflevector <8 x i16> [[TMP16]], <8 x i16> [[TMP17]], <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
// CHECK-NEXT:    ret <16 x i16> [[TMP18]]
//
v16i16 selecthx(v16i16 t, v16i16 f, v16i16 c) {
  return __builtin_kvx_selecthx(t, f, c, ".even");
}

// CHECK-LABEL: @selectw(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[CONV:%.*]] = zext i32 [[C:%.*]] to i64
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i32 @llvm.kvx.select.i32(i32 [[T:%.*]], i32 [[F:%.*]], i64 [[CONV]], i32 7)
// CHECK-NEXT:    ret i32 [[TMP0]]
//
unsigned selectw(unsigned t, unsigned f, unsigned c) {
  return __builtin_kvx_selectw(t, f, c, ".even");
}

// CHECK-LABEL: @selectwo(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = shufflevector <8 x i32> [[T:%.*]], <8 x i32> poison, <2 x i32> <i32 0, i32 1>
// CHECK-NEXT:    [[TMP1:%.*]] = shufflevector <8 x i32> [[F:%.*]], <8 x i32> poison, <2 x i32> <i32 0, i32 1>
// CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <8 x i32> [[C:%.*]], <8 x i32> poison, <2 x i32> <i32 0, i32 1>
// CHECK-NEXT:    [[TMP3:%.*]] = tail call <2 x i32> @llvm.kvx.select.vec.v2i32(<2 x i32> [[TMP0]], <2 x i32> [[TMP1]], <2 x i32> [[TMP2]], i32 7)
// CHECK-NEXT:    [[TMP4:%.*]] = shufflevector <8 x i32> [[T]], <8 x i32> poison, <2 x i32> <i32 2, i32 3>
// CHECK-NEXT:    [[TMP5:%.*]] = shufflevector <8 x i32> [[F]], <8 x i32> poison, <2 x i32> <i32 2, i32 3>
// CHECK-NEXT:    [[TMP6:%.*]] = shufflevector <8 x i32> [[C]], <8 x i32> poison, <2 x i32> <i32 2, i32 3>
// CHECK-NEXT:    [[TMP7:%.*]] = tail call <2 x i32> @llvm.kvx.select.vec.v2i32(<2 x i32> [[TMP4]], <2 x i32> [[TMP5]], <2 x i32> [[TMP6]], i32 7)
// CHECK-NEXT:    [[TMP8:%.*]] = shufflevector <8 x i32> [[T]], <8 x i32> poison, <2 x i32> <i32 4, i32 5>
// CHECK-NEXT:    [[TMP9:%.*]] = shufflevector <8 x i32> [[F]], <8 x i32> poison, <2 x i32> <i32 4, i32 5>
// CHECK-NEXT:    [[TMP10:%.*]] = shufflevector <8 x i32> [[C]], <8 x i32> poison, <2 x i32> <i32 4, i32 5>
// CHECK-NEXT:    [[TMP11:%.*]] = tail call <2 x i32> @llvm.kvx.select.vec.v2i32(<2 x i32> [[TMP8]], <2 x i32> [[TMP9]], <2 x i32> [[TMP10]], i32 7)
// CHECK-NEXT:    [[TMP12:%.*]] = shufflevector <8 x i32> [[T]], <8 x i32> poison, <2 x i32> <i32 6, i32 7>
// CHECK-NEXT:    [[TMP13:%.*]] = shufflevector <8 x i32> [[F]], <8 x i32> poison, <2 x i32> <i32 6, i32 7>
// CHECK-NEXT:    [[TMP14:%.*]] = shufflevector <8 x i32> [[C]], <8 x i32> poison, <2 x i32> <i32 6, i32 7>
// CHECK-NEXT:    [[TMP15:%.*]] = tail call <2 x i32> @llvm.kvx.select.vec.v2i32(<2 x i32> [[TMP12]], <2 x i32> [[TMP13]], <2 x i32> [[TMP14]], i32 7)
// CHECK-NEXT:    [[TMP16:%.*]] = shufflevector <2 x i32> [[TMP3]], <2 x i32> [[TMP7]], <4 x i32> <i32 0, i32 1, i32 2, i32 3>
// CHECK-NEXT:    [[TMP17:%.*]] = shufflevector <2 x i32> [[TMP11]], <2 x i32> [[TMP15]], <4 x i32> <i32 0, i32 1, i32 2, i32 3>
// CHECK-NEXT:    [[TMP18:%.*]] = shufflevector <4 x i32> [[TMP16]], <4 x i32> [[TMP17]], <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
// CHECK-NEXT:    ret <8 x i32> [[TMP18]]
//
v8i32 selectwo(v8i32 t, v8i32 f, v8i32 c) {
  return __builtin_kvx_selectwo(t, f, c, ".even");
}

// CHECK-LABEL: @selectwx(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[T:%.*]] = load <16 x i32>, ptr [[TMP0:%.*]], align 32, !tbaa [[TBAA2]]
// CHECK-NEXT:    [[F:%.*]] = load <16 x i32>, ptr [[TMP1:%.*]], align 32, !tbaa [[TBAA2]]
// CHECK-NEXT:    [[C:%.*]] = load <16 x i32>, ptr [[TMP2:%.*]], align 32, !tbaa [[TBAA2]]
// CHECK-NEXT:    [[TMP3:%.*]] = shufflevector <16 x i32> [[T]], <16 x i32> poison, <2 x i32> <i32 0, i32 1>
// CHECK-NEXT:    [[TMP4:%.*]] = shufflevector <16 x i32> [[F]], <16 x i32> poison, <2 x i32> <i32 0, i32 1>
// CHECK-NEXT:    [[TMP5:%.*]] = shufflevector <16 x i32> [[C]], <16 x i32> poison, <2 x i32> <i32 0, i32 1>
// CHECK-NEXT:    [[TMP6:%.*]] = tail call <2 x i32> @llvm.kvx.select.vec.v2i32(<2 x i32> [[TMP3]], <2 x i32> [[TMP4]], <2 x i32> [[TMP5]], i32 7)
// CHECK-NEXT:    [[TMP7:%.*]] = shufflevector <16 x i32> [[T]], <16 x i32> poison, <2 x i32> <i32 2, i32 3>
// CHECK-NEXT:    [[TMP8:%.*]] = shufflevector <16 x i32> [[F]], <16 x i32> poison, <2 x i32> <i32 2, i32 3>
// CHECK-NEXT:    [[TMP9:%.*]] = shufflevector <16 x i32> [[C]], <16 x i32> poison, <2 x i32> <i32 2, i32 3>
// CHECK-NEXT:    [[TMP10:%.*]] = tail call <2 x i32> @llvm.kvx.select.vec.v2i32(<2 x i32> [[TMP7]], <2 x i32> [[TMP8]], <2 x i32> [[TMP9]], i32 7)
// CHECK-NEXT:    [[TMP11:%.*]] = shufflevector <16 x i32> [[T]], <16 x i32> poison, <2 x i32> <i32 4, i32 5>
// CHECK-NEXT:    [[TMP12:%.*]] = shufflevector <16 x i32> [[F]], <16 x i32> poison, <2 x i32> <i32 4, i32 5>
// CHECK-NEXT:    [[TMP13:%.*]] = shufflevector <16 x i32> [[C]], <16 x i32> poison, <2 x i32> <i32 4, i32 5>
// CHECK-NEXT:    [[TMP14:%.*]] = tail call <2 x i32> @llvm.kvx.select.vec.v2i32(<2 x i32> [[TMP11]], <2 x i32> [[TMP12]], <2 x i32> [[TMP13]], i32 7)
// CHECK-NEXT:    [[TMP15:%.*]] = shufflevector <16 x i32> [[T]], <16 x i32> poison, <2 x i32> <i32 6, i32 7>
// CHECK-NEXT:    [[TMP16:%.*]] = shufflevector <16 x i32> [[F]], <16 x i32> poison, <2 x i32> <i32 6, i32 7>
// CHECK-NEXT:    [[TMP17:%.*]] = shufflevector <16 x i32> [[C]], <16 x i32> poison, <2 x i32> <i32 6, i32 7>
// CHECK-NEXT:    [[TMP18:%.*]] = tail call <2 x i32> @llvm.kvx.select.vec.v2i32(<2 x i32> [[TMP15]], <2 x i32> [[TMP16]], <2 x i32> [[TMP17]], i32 7)
// CHECK-NEXT:    [[TMP19:%.*]] = shufflevector <16 x i32> [[T]], <16 x i32> poison, <2 x i32> <i32 8, i32 9>
// CHECK-NEXT:    [[TMP20:%.*]] = shufflevector <16 x i32> [[F]], <16 x i32> poison, <2 x i32> <i32 8, i32 9>
// CHECK-NEXT:    [[TMP21:%.*]] = shufflevector <16 x i32> [[C]], <16 x i32> poison, <2 x i32> <i32 8, i32 9>
// CHECK-NEXT:    [[TMP22:%.*]] = tail call <2 x i32> @llvm.kvx.select.vec.v2i32(<2 x i32> [[TMP19]], <2 x i32> [[TMP20]], <2 x i32> [[TMP21]], i32 7)
// CHECK-NEXT:    [[TMP23:%.*]] = shufflevector <16 x i32> [[T]], <16 x i32> poison, <2 x i32> <i32 10, i32 11>
// CHECK-NEXT:    [[TMP24:%.*]] = shufflevector <16 x i32> [[F]], <16 x i32> poison, <2 x i32> <i32 10, i32 11>
// CHECK-NEXT:    [[TMP25:%.*]] = shufflevector <16 x i32> [[C]], <16 x i32> poison, <2 x i32> <i32 10, i32 11>
// CHECK-NEXT:    [[TMP26:%.*]] = tail call <2 x i32> @llvm.kvx.select.vec.v2i32(<2 x i32> [[TMP23]], <2 x i32> [[TMP24]], <2 x i32> [[TMP25]], i32 7)
// CHECK-NEXT:    [[TMP27:%.*]] = shufflevector <16 x i32> [[T]], <16 x i32> poison, <2 x i32> <i32 12, i32 13>
// CHECK-NEXT:    [[TMP28:%.*]] = shufflevector <16 x i32> [[F]], <16 x i32> poison, <2 x i32> <i32 12, i32 13>
// CHECK-NEXT:    [[TMP29:%.*]] = shufflevector <16 x i32> [[C]], <16 x i32> poison, <2 x i32> <i32 12, i32 13>
// CHECK-NEXT:    [[TMP30:%.*]] = tail call <2 x i32> @llvm.kvx.select.vec.v2i32(<2 x i32> [[TMP27]], <2 x i32> [[TMP28]], <2 x i32> [[TMP29]], i32 7)
// CHECK-NEXT:    [[TMP31:%.*]] = shufflevector <16 x i32> [[T]], <16 x i32> poison, <2 x i32> <i32 14, i32 15>
// CHECK-NEXT:    [[TMP32:%.*]] = shufflevector <16 x i32> [[F]], <16 x i32> poison, <2 x i32> <i32 14, i32 15>
// CHECK-NEXT:    [[TMP33:%.*]] = shufflevector <16 x i32> [[C]], <16 x i32> poison, <2 x i32> <i32 14, i32 15>
// CHECK-NEXT:    [[TMP34:%.*]] = tail call <2 x i32> @llvm.kvx.select.vec.v2i32(<2 x i32> [[TMP31]], <2 x i32> [[TMP32]], <2 x i32> [[TMP33]], i32 7)
// CHECK-NEXT:    [[TMP35:%.*]] = shufflevector <2 x i32> [[TMP6]], <2 x i32> [[TMP10]], <4 x i32> <i32 0, i32 1, i32 2, i32 3>
// CHECK-NEXT:    [[TMP36:%.*]] = shufflevector <2 x i32> [[TMP14]], <2 x i32> [[TMP18]], <4 x i32> <i32 0, i32 1, i32 2, i32 3>
// CHECK-NEXT:    [[TMP37:%.*]] = shufflevector <2 x i32> [[TMP22]], <2 x i32> [[TMP26]], <4 x i32> <i32 0, i32 1, i32 2, i32 3>
// CHECK-NEXT:    [[TMP38:%.*]] = shufflevector <2 x i32> [[TMP30]], <2 x i32> [[TMP34]], <4 x i32> <i32 0, i32 1, i32 2, i32 3>
// CHECK-NEXT:    [[TMP39:%.*]] = shufflevector <4 x i32> [[TMP35]], <4 x i32> [[TMP36]], <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
// CHECK-NEXT:    [[TMP40:%.*]] = shufflevector <4 x i32> [[TMP37]], <4 x i32> [[TMP38]], <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
// CHECK-NEXT:    [[TMP41:%.*]] = shufflevector <8 x i32> [[TMP39]], <8 x i32> [[TMP40]], <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
// CHECK-NEXT:    store <16 x i32> [[TMP41]], ptr [[AGG_RESULT:%.*]], align 32, !tbaa [[TBAA2]]
// CHECK-NEXT:    ret void
//
v16i32 selectwx(v16i32 t, v16i32 f, v16i32 c) {
  return __builtin_kvx_selectwx(t, f, c, ".even");
}

// CHECK-LABEL: @selectwp(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call <2 x i32> @llvm.kvx.select.vec.v2i32(<2 x i32> [[T:%.*]], <2 x i32> [[F:%.*]], <2 x i32> [[C:%.*]], i32 7)
// CHECK-NEXT:    ret <2 x i32> [[TMP0]]
//
v2i32 selectwp(v2i32 t, v2i32 f, v2i32 c) {
  return __builtin_kvx_selectwp(t, f, c, ".even");
}

// CHECK-LABEL: @selectwq(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = shufflevector <4 x i32> [[T:%.*]], <4 x i32> poison, <2 x i32> <i32 0, i32 1>
// CHECK-NEXT:    [[TMP1:%.*]] = shufflevector <4 x i32> [[F:%.*]], <4 x i32> poison, <2 x i32> <i32 0, i32 1>
// CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <4 x i32> [[C:%.*]], <4 x i32> poison, <2 x i32> <i32 0, i32 1>
// CHECK-NEXT:    [[TMP3:%.*]] = tail call <2 x i32> @llvm.kvx.select.vec.v2i32(<2 x i32> [[TMP0]], <2 x i32> [[TMP1]], <2 x i32> [[TMP2]], i32 7)
// CHECK-NEXT:    [[TMP4:%.*]] = shufflevector <4 x i32> [[T]], <4 x i32> poison, <2 x i32> <i32 2, i32 3>
// CHECK-NEXT:    [[TMP5:%.*]] = shufflevector <4 x i32> [[F]], <4 x i32> poison, <2 x i32> <i32 2, i32 3>
// CHECK-NEXT:    [[TMP6:%.*]] = shufflevector <4 x i32> [[C]], <4 x i32> poison, <2 x i32> <i32 2, i32 3>
// CHECK-NEXT:    [[TMP7:%.*]] = tail call <2 x i32> @llvm.kvx.select.vec.v2i32(<2 x i32> [[TMP4]], <2 x i32> [[TMP5]], <2 x i32> [[TMP6]], i32 7)
// CHECK-NEXT:    [[TMP8:%.*]] = shufflevector <2 x i32> [[TMP3]], <2 x i32> [[TMP7]], <4 x i32> <i32 0, i32 1, i32 2, i32 3>
// CHECK-NEXT:    ret <4 x i32> [[TMP8]]
//
v4i32 selectwq(v4i32 t, v4i32 f, v4i32 c) {
  return __builtin_kvx_selectwq(t, f, c, ".even");
}
