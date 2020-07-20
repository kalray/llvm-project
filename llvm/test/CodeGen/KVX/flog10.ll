; RUN: llc < %s -mtriple=kvx-kalray-cos | FileCheck %s

define float @log10f32(float %x) {
  %tmp = call float @llvm.log10.f32(float %x)
  ret float %tmp
  ; CHECK: log10f32:
  ; CHECK: call log10f
  ; CHECK: ret
}

define double @log10f64(double %x) {
  %tmp = call double @llvm.log10.f64(double %x)
  ret double %tmp
  ; CHECK: log10f64:
  ; CHECK: call log10
  ; CHECK: ret
}

define <2 x float> @log10v2f32(<2 x float> %x) {
  %tmp = call <2 x float> @llvm.log10.v2f32(<2 x float> %x)
  ret <2 x float> %tmp
  ; CHECK: log10v2f32:
  ; CHECK: call log10f
  ; CHECK: call log10f
  ; CHECK: ret
}

define <2 x double> @log10v2f64(<2 x double> %x) {
  %tmp = call <2 x double> @llvm.log10.v2f64(<2 x double> %x)
  ret <2 x double> %tmp
  ; CHECK: log10v2f64:
  ; CHECK: call log10
  ; CHECK: call log10
  ; CHECK: ret
}

declare float @llvm.log10.f32(float)
declare double @llvm.log10.f64(double)
declare <2x float> @llvm.log10.v2f32(<2 x float>)
declare <2x double> @llvm.log10.v2f64(<2 x double>)
