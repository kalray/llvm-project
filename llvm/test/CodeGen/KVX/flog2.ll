; RUN: llc < %s -mtriple=kvx-kalray-cos | FileCheck %s

define float @log2f32(float %x) {
  %tmp = call float @llvm.log2.f32(float %x)
  ret float %tmp
  ; CHECK: log2f32:
  ; CHECK: call log2f
  ; CHECK: ret
}

define double @log2f64(double %x) {
  %tmp = call double @llvm.log2.f64(double %x)
  ret double %tmp
  ; CHECK: log2f64:
  ; CHECK: call log2
  ; CHECK: ret
}

define <2 x float> @log2v2f32(<2 x float> %x) {
  %tmp = call <2 x float> @llvm.log2.v2f32(<2 x float> %x)
  ret <2 x float> %tmp
  ; CHECK: log2v2f32:
  ; CHECK: call log2f
  ; CHECK: call log2f
  ; CHECK: ret
}

define <2 x double> @log2v2f64(<2 x double> %x) {
  %tmp = call <2 x double> @llvm.log2.v2f64(<2 x double> %x)
  ret <2 x double> %tmp
  ; CHECK: log2v2f64:
  ; CHECK: call log2
  ; CHECK: call log2
  ; CHECK: ret
}

declare float @llvm.log2.f32(float)
declare double @llvm.log2.f64(double)
declare <2x float> @llvm.log2.v2f32(<2 x float>)
declare <2x double> @llvm.log2.v2f64(<2 x double>)
