// NOTE: Assertions have been autogenerated by utils/update_cc_test_checks.py
// RUN: %clang_cc1 -triple kvx-kalray-cos -S -O2 -emit-llvm -o - %s | FileCheck %s
#include "vector-types.h"

// CHECK-LABEL: @floatd_limit(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call double @llvm.kvx.floatd(i64 [[X:%.*]], i32 63, i32 3, i32 0)
// CHECK-NEXT:    ret double [[TMP0]]
//
double floatd_limit(long x) { return __builtin_kvx_floatd(x, 63, ".rz"); }

// CHECK-LABEL: @floatd_s(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call double @llvm.kvx.floatd(i64 [[X:%.*]], i32 3, i32 0, i32 1)
// CHECK-NEXT:    ret double [[TMP0]]
//
double floatd_s(long x) { return __builtin_kvx_floatd(x, 3, ".rn.s"); }

// CHECK-LABEL: @floatd(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call double @llvm.kvx.floatd(i64 [[X:%.*]], i32 3, i32 7, i32 0)
// CHECK-NEXT:    ret double [[TMP0]]
//
double floatd(long x) { return __builtin_kvx_floatd(x, 3, ""); }

// CHECK-LABEL: @floatdp_s(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = extractelement <2 x i64> [[V:%.*]], i64 0
// CHECK-NEXT:    [[TMP1:%.*]] = tail call double @llvm.kvx.floatd(i64 [[TMP0]], i32 3, i32 0, i32 1)
// CHECK-NEXT:    [[TMP2:%.*]] = extractelement <2 x i64> [[V]], i64 1
// CHECK-NEXT:    [[TMP3:%.*]] = tail call double @llvm.kvx.floatd(i64 [[TMP2]], i32 3, i32 0, i32 1)
// CHECK-NEXT:    [[TMP4:%.*]] = insertelement <2 x double> undef, double [[TMP1]], i64 0
// CHECK-NEXT:    [[TMP5:%.*]] = insertelement <2 x double> [[TMP4]], double [[TMP3]], i64 1
// CHECK-NEXT:    ret <2 x double> [[TMP5]]
//
v2f64 floatdp_s(v2i64 v) { return __builtin_kvx_floatdp(v, 3, ".rn.s"); }

// CHECK-LABEL: @floatdp(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = extractelement <2 x i64> [[V:%.*]], i64 0
// CHECK-NEXT:    [[TMP1:%.*]] = tail call double @llvm.kvx.floatd(i64 [[TMP0]], i32 3, i32 0, i32 0)
// CHECK-NEXT:    [[TMP2:%.*]] = extractelement <2 x i64> [[V]], i64 1
// CHECK-NEXT:    [[TMP3:%.*]] = tail call double @llvm.kvx.floatd(i64 [[TMP2]], i32 3, i32 0, i32 0)
// CHECK-NEXT:    [[TMP4:%.*]] = insertelement <2 x double> undef, double [[TMP1]], i64 0
// CHECK-NEXT:    [[TMP5:%.*]] = insertelement <2 x double> [[TMP4]], double [[TMP3]], i64 1
// CHECK-NEXT:    ret <2 x double> [[TMP5]]
//
v2f64 floatdp(v2i64 v) { return __builtin_kvx_floatdp(v, 3, ".rn"); }

// CHECK-LABEL: @floatdq(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = extractelement <4 x i64> [[V:%.*]], i64 0
// CHECK-NEXT:    [[TMP1:%.*]] = tail call double @llvm.kvx.floatd(i64 [[TMP0]], i32 3, i32 0, i32 0)
// CHECK-NEXT:    [[TMP2:%.*]] = extractelement <4 x i64> [[V]], i64 1
// CHECK-NEXT:    [[TMP3:%.*]] = tail call double @llvm.kvx.floatd(i64 [[TMP2]], i32 3, i32 0, i32 0)
// CHECK-NEXT:    [[TMP4:%.*]] = extractelement <4 x i64> [[V]], i64 2
// CHECK-NEXT:    [[TMP5:%.*]] = tail call double @llvm.kvx.floatd(i64 [[TMP4]], i32 3, i32 0, i32 0)
// CHECK-NEXT:    [[TMP6:%.*]] = extractelement <4 x i64> [[V]], i64 3
// CHECK-NEXT:    [[TMP7:%.*]] = tail call double @llvm.kvx.floatd(i64 [[TMP6]], i32 3, i32 0, i32 0)
// CHECK-NEXT:    [[TMP8:%.*]] = insertelement <4 x double> undef, double [[TMP1]], i64 0
// CHECK-NEXT:    [[TMP9:%.*]] = insertelement <4 x double> [[TMP8]], double [[TMP3]], i64 1
// CHECK-NEXT:    [[TMP10:%.*]] = insertelement <4 x double> [[TMP9]], double [[TMP5]], i64 2
// CHECK-NEXT:    [[TMP11:%.*]] = insertelement <4 x double> [[TMP10]], double [[TMP7]], i64 3
// CHECK-NEXT:    ret <4 x double> [[TMP11]]
//
v4f64 floatdq(v4i64 v) { return __builtin_kvx_floatdq(v, 3, ".rn"); }

// CHECK-LABEL: @floatud(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call double @llvm.kvx.floatud(i64 [[X:%.*]], i32 3, i32 3, i32 0)
// CHECK-NEXT:    ret double [[TMP0]]
//
double floatud(unsigned long x) { return __builtin_kvx_floatud(x, 3, ".rz"); }

// CHECK-LABEL: @floatudp(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = extractelement <2 x i64> [[V:%.*]], i64 0
// CHECK-NEXT:    [[TMP1:%.*]] = tail call double @llvm.kvx.floatud(i64 [[TMP0]], i32 3, i32 0, i32 0)
// CHECK-NEXT:    [[TMP2:%.*]] = extractelement <2 x i64> [[V]], i64 1
// CHECK-NEXT:    [[TMP3:%.*]] = tail call double @llvm.kvx.floatud(i64 [[TMP2]], i32 3, i32 0, i32 0)
// CHECK-NEXT:    [[TMP4:%.*]] = insertelement <2 x double> undef, double [[TMP1]], i64 0
// CHECK-NEXT:    [[TMP5:%.*]] = insertelement <2 x double> [[TMP4]], double [[TMP3]], i64 1
// CHECK-NEXT:    ret <2 x double> [[TMP5]]
//
v2f64 floatudp(v2u64 v) { return __builtin_kvx_floatudp(v, 3, ".rn"); }

// CHECK-LABEL: @floatudq(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = extractelement <4 x i64> [[V:%.*]], i64 0
// CHECK-NEXT:    [[TMP1:%.*]] = tail call double @llvm.kvx.floatud(i64 [[TMP0]], i32 3, i32 0, i32 0)
// CHECK-NEXT:    [[TMP2:%.*]] = extractelement <4 x i64> [[V]], i64 1
// CHECK-NEXT:    [[TMP3:%.*]] = tail call double @llvm.kvx.floatud(i64 [[TMP2]], i32 3, i32 0, i32 0)
// CHECK-NEXT:    [[TMP4:%.*]] = extractelement <4 x i64> [[V]], i64 2
// CHECK-NEXT:    [[TMP5:%.*]] = tail call double @llvm.kvx.floatud(i64 [[TMP4]], i32 3, i32 0, i32 0)
// CHECK-NEXT:    [[TMP6:%.*]] = extractelement <4 x i64> [[V]], i64 3
// CHECK-NEXT:    [[TMP7:%.*]] = tail call double @llvm.kvx.floatud(i64 [[TMP6]], i32 3, i32 0, i32 0)
// CHECK-NEXT:    [[TMP8:%.*]] = insertelement <4 x double> undef, double [[TMP1]], i64 0
// CHECK-NEXT:    [[TMP9:%.*]] = insertelement <4 x double> [[TMP8]], double [[TMP3]], i64 1
// CHECK-NEXT:    [[TMP10:%.*]] = insertelement <4 x double> [[TMP9]], double [[TMP5]], i64 2
// CHECK-NEXT:    [[TMP11:%.*]] = insertelement <4 x double> [[TMP10]], double [[TMP7]], i64 3
// CHECK-NEXT:    ret <4 x double> [[TMP11]]
//
v4f64 floatudq(v4u64 v) { return __builtin_kvx_floatudq(v, 3, ".rn"); }

// CHECK-LABEL: @floatuw(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call float @llvm.kvx.floatuw(i32 [[X:%.*]], i32 3, i32 3, i32 0)
// CHECK-NEXT:    ret float [[TMP0]]
//
float floatuw(unsigned int x) { return __builtin_kvx_floatuw(x, 3, ".rz"); }

// CHECK-LABEL: @floatuwo(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = shufflevector <8 x i32> [[V:%.*]], <8 x i32> poison, <2 x i32> <i32 0, i32 1>
// CHECK-NEXT:    [[TMP1:%.*]] = tail call <2 x float> @llvm.kvx.floatuwp(<2 x i32> [[TMP0]], i32 3, i32 0, i32 0)
// CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <8 x i32> [[V]], <8 x i32> poison, <2 x i32> <i32 2, i32 3>
// CHECK-NEXT:    [[TMP3:%.*]] = tail call <2 x float> @llvm.kvx.floatuwp(<2 x i32> [[TMP2]], i32 3, i32 0, i32 0)
// CHECK-NEXT:    [[TMP4:%.*]] = shufflevector <8 x i32> [[V]], <8 x i32> poison, <2 x i32> <i32 4, i32 5>
// CHECK-NEXT:    [[TMP5:%.*]] = tail call <2 x float> @llvm.kvx.floatuwp(<2 x i32> [[TMP4]], i32 3, i32 0, i32 0)
// CHECK-NEXT:    [[TMP6:%.*]] = shufflevector <8 x i32> [[V]], <8 x i32> poison, <2 x i32> <i32 6, i32 7>
// CHECK-NEXT:    [[TMP7:%.*]] = tail call <2 x float> @llvm.kvx.floatuwp(<2 x i32> [[TMP6]], i32 3, i32 0, i32 0)
// CHECK-NEXT:    [[TMP8:%.*]] = shufflevector <2 x float> [[TMP1]], <2 x float> [[TMP3]], <4 x i32> <i32 0, i32 1, i32 2, i32 3>
// CHECK-NEXT:    [[TMP9:%.*]] = shufflevector <2 x float> [[TMP5]], <2 x float> [[TMP7]], <4 x i32> <i32 0, i32 1, i32 2, i32 3>
// CHECK-NEXT:    [[TMP10:%.*]] = shufflevector <4 x float> [[TMP8]], <4 x float> [[TMP9]], <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
// CHECK-NEXT:    ret <8 x float> [[TMP10]]
//
v8f32 floatuwo(v8u32 v) { return __builtin_kvx_floatuwo(v, 3, ".rn"); }

// CHECK-LABEL: @floatuwp(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call <2 x float> @llvm.kvx.floatuwp(<2 x i32> [[V:%.*]], i32 3, i32 0, i32 0)
// CHECK-NEXT:    ret <2 x float> [[TMP0]]
//
v2f32 floatuwp(v2u32 v) { return __builtin_kvx_floatuwp(v, 3, ".rn"); }

// CHECK-LABEL: @floatuwq(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = shufflevector <4 x i32> [[V:%.*]], <4 x i32> poison, <2 x i32> <i32 0, i32 1>
// CHECK-NEXT:    [[TMP1:%.*]] = tail call <2 x float> @llvm.kvx.floatuwp(<2 x i32> [[TMP0]], i32 3, i32 0, i32 0)
// CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <4 x i32> [[V]], <4 x i32> poison, <2 x i32> <i32 2, i32 3>
// CHECK-NEXT:    [[TMP3:%.*]] = tail call <2 x float> @llvm.kvx.floatuwp(<2 x i32> [[TMP2]], i32 3, i32 0, i32 0)
// CHECK-NEXT:    [[TMP4:%.*]] = shufflevector <2 x float> [[TMP1]], <2 x float> [[TMP3]], <4 x i32> <i32 0, i32 1, i32 2, i32 3>
// CHECK-NEXT:    ret <4 x float> [[TMP4]]
//
v4f32 floatuwq(v4u32 v) { return __builtin_kvx_floatuwq(v, 3, ".rn"); }

// CHECK-LABEL: @floatw_s(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call float @llvm.kvx.floatw(i32 [[X:%.*]], i32 3, i32 0, i32 1)
// CHECK-NEXT:    ret float [[TMP0]]
//
float floatw_s(int x) { return __builtin_kvx_floatw(x, 3, ".rn.s"); }

// CHECK-LABEL: @floatw(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call float @llvm.kvx.floatw(i32 [[X:%.*]], i32 3, i32 0, i32 0)
// CHECK-NEXT:    ret float [[TMP0]]
//
float floatw(int x) { return __builtin_kvx_floatw(x, 3, ".rn"); }

// CHECK-LABEL: @floatwo(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = shufflevector <8 x i32> [[V:%.*]], <8 x i32> poison, <2 x i32> <i32 0, i32 1>
// CHECK-NEXT:    [[TMP1:%.*]] = tail call <2 x float> @llvm.kvx.floatwp(<2 x i32> [[TMP0]], i32 3, i32 0, i32 0)
// CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <8 x i32> [[V]], <8 x i32> poison, <2 x i32> <i32 2, i32 3>
// CHECK-NEXT:    [[TMP3:%.*]] = tail call <2 x float> @llvm.kvx.floatwp(<2 x i32> [[TMP2]], i32 3, i32 0, i32 0)
// CHECK-NEXT:    [[TMP4:%.*]] = shufflevector <8 x i32> [[V]], <8 x i32> poison, <2 x i32> <i32 4, i32 5>
// CHECK-NEXT:    [[TMP5:%.*]] = tail call <2 x float> @llvm.kvx.floatwp(<2 x i32> [[TMP4]], i32 3, i32 0, i32 0)
// CHECK-NEXT:    [[TMP6:%.*]] = shufflevector <8 x i32> [[V]], <8 x i32> poison, <2 x i32> <i32 6, i32 7>
// CHECK-NEXT:    [[TMP7:%.*]] = tail call <2 x float> @llvm.kvx.floatwp(<2 x i32> [[TMP6]], i32 3, i32 0, i32 0)
// CHECK-NEXT:    [[TMP8:%.*]] = shufflevector <2 x float> [[TMP1]], <2 x float> [[TMP3]], <4 x i32> <i32 0, i32 1, i32 2, i32 3>
// CHECK-NEXT:    [[TMP9:%.*]] = shufflevector <2 x float> [[TMP5]], <2 x float> [[TMP7]], <4 x i32> <i32 0, i32 1, i32 2, i32 3>
// CHECK-NEXT:    [[TMP10:%.*]] = shufflevector <4 x float> [[TMP8]], <4 x float> [[TMP9]], <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
// CHECK-NEXT:    ret <8 x float> [[TMP10]]
//
v8f32 floatwo(v8i32 v) { return __builtin_kvx_floatwo(v, 3, ".rn"); }

// CHECK-LABEL: @floatwp(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call <2 x float> @llvm.kvx.floatwp(<2 x i32> [[V:%.*]], i32 3, i32 0, i32 0)
// CHECK-NEXT:    ret <2 x float> [[TMP0]]
//
v2f32 floatwp(v2i32 v) { return __builtin_kvx_floatwp(v, 3, ".rn"); }

// CHECK-LABEL: @floatwq_s(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = shufflevector <4 x i32> [[V:%.*]], <4 x i32> poison, <2 x i32> <i32 0, i32 1>
// CHECK-NEXT:    [[TMP1:%.*]] = tail call <2 x float> @llvm.kvx.floatwp(<2 x i32> [[TMP0]], i32 3, i32 0, i32 1)
// CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <4 x i32> [[V]], <4 x i32> poison, <2 x i32> <i32 2, i32 3>
// CHECK-NEXT:    [[TMP3:%.*]] = tail call <2 x float> @llvm.kvx.floatwp(<2 x i32> [[TMP2]], i32 3, i32 0, i32 1)
// CHECK-NEXT:    [[TMP4:%.*]] = shufflevector <2 x float> [[TMP1]], <2 x float> [[TMP3]], <4 x i32> <i32 0, i32 1, i32 2, i32 3>
// CHECK-NEXT:    ret <4 x float> [[TMP4]]
//
v4f32 floatwq_s(v4i32 v) { return __builtin_kvx_floatwq(v, 3, ".rn.s"); }

// CHECK-LABEL: @floatwq(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = shufflevector <4 x i32> [[V:%.*]], <4 x i32> poison, <2 x i32> <i32 0, i32 1>
// CHECK-NEXT:    [[TMP1:%.*]] = tail call <2 x float> @llvm.kvx.floatwp(<2 x i32> [[TMP0]], i32 3, i32 0, i32 0)
// CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <4 x i32> [[V]], <4 x i32> poison, <2 x i32> <i32 2, i32 3>
// CHECK-NEXT:    [[TMP3:%.*]] = tail call <2 x float> @llvm.kvx.floatwp(<2 x i32> [[TMP2]], i32 3, i32 0, i32 0)
// CHECK-NEXT:    [[TMP4:%.*]] = shufflevector <2 x float> [[TMP1]], <2 x float> [[TMP3]], <4 x i32> <i32 0, i32 1, i32 2, i32 3>
// CHECK-NEXT:    ret <4 x float> [[TMP4]]
//
v4f32 floatwq(v4i32 v) { return __builtin_kvx_floatwq(v, 3, ".rn"); }
