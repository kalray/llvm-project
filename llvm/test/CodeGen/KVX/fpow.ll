; RUN: llc < %s -mtriple=kvx-kalray-cos | FileCheck %s

define float @powf32(float %x, float %y) {
  %tmp = call float @llvm.pow.f32(float %x, float %y)
  ret float %tmp
  ; CHECK: powf32:
  ; CHECK: call powf
  ; CHECK: ret
}

define double @powf64(double %x, double %y) {
  %tmp = call double @llvm.pow.f64(double %x, double %y)
  ret double %tmp
  ; CHECK: powf64:
  ; CHECK: call pow
  ; CHECK: ret
}

define <2 x float> @powv2f32(<2 x float> %x, <2 x float> %y) {
  %tmp = call <2 x float> @llvm.pow.v2f32(<2 x float> %x, <2 x float> %y)
  ret <2 x float> %tmp
  ; CHECK: powv2f32:
  ; CHECK: call powf
  ; CHECK: call powf
  ; CHECK: ret
}

define <2 x double> @powv2f64(<2 x double> %x, <2 x double> %y) {
  %tmp = call <2 x double> @llvm.pow.v2f64(<2 x double> %x, <2 x double> %y)
  ret <2 x double> %tmp
  ; CHECK: powv2f64:
  ; CHECK: call pow
  ; CHECK: call pow
  ; CHECK: ret
}

declare float @llvm.pow.f32(float, float)
declare double @llvm.pow.f64(double, double)
declare <2x float> @llvm.pow.v2f32(<2 x float>, <2 x float>)
declare <2x double> @llvm.pow.v2f64(<2 x double>, <2 x double>)
