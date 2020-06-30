; RUN: llc < %s -mtriple=kvx-kalray-cos | FileCheck %s

define float @ceilf32(float %x) {
  %tmp = call float @llvm.ceil.f32(float %x)
  ret float %tmp
  ; CHECK: ceilf32:
  ; CHECK: call ceilf
  ; CHECK: ret
}

define double @ceilf64(double %x) {
  %tmp = call double @llvm.ceil.f64(double %x)
  ret double %tmp
  ; CHECK: ceilf64:
  ; CHECK: call ceil
  ; CHECK: ret
}

define <2 x float> @ceilv2f32(<2 x float> %x) {
  %tmp = call <2 x float> @llvm.ceil.v2f32(<2 x float> %x)
  ret <2 x float> %tmp
  ; CHECK: ceilv2f32:
  ; CHECK: call ceilf
  ; CHECK: call ceilf
  ; CHECK: ret
}

define <2 x double> @ceilv2f64(<2 x double> %x) {
  %tmp = call <2 x double> @llvm.ceil.v2f64(<2 x double> %x)
  ret <2 x double> %tmp
  ; CHECK: ceilv2f64:
  ; CHECK: call ceil
  ; CHECK: call ceil
  ; CHECK: ret
}

declare float @llvm.ceil.f32(float)
declare double @llvm.ceil.f64(double)
declare <2x float> @llvm.ceil.v2f32(<2 x float>)
declare <2x double> @llvm.ceil.v2f64(<2 x double>)
