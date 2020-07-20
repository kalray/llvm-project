; RUN: llc < %s -mtriple=kvx-kalray-cos | FileCheck %s

define float @cosf32(float %x) {
  %tmp = call float @llvm.cos.f32(float %x)
  ret float %tmp
  ; CHECK: cosf32:
  ; CHECK: call cosf
  ; CHECK: ret
}

define double @cosf64(double %x) {
  %tmp = call double @llvm.cos.f64(double %x)
  ret double %tmp
  ; CHECK: cosf64:
  ; CHECK: call cos
  ; CHECK: ret
}

define <2 x float> @cosv2f32(<2 x float> %x) {
  %tmp = call <2 x float> @llvm.cos.v2f32(<2 x float> %x)
  ret <2 x float> %tmp
  ; CHECK: cosv2f32:
  ; CHECK: call cosf
  ; CHECK: call cosf
  ; CHECK: ret
}

define <2 x double> @cosv2f64(<2 x double> %x) {
  %tmp = call <2 x double> @llvm.cos.v2f64(<2 x double> %x)
  ret <2 x double> %tmp
  ; CHECK: cosv2f64:
  ; CHECK: call cos
  ; CHECK: call cos
  ; CHECK: ret
}

declare float @llvm.cos.f32(float)
declare double @llvm.cos.f64(double)
declare <2x float> @llvm.cos.v2f32(<2 x float>)
declare <2x double> @llvm.cos.v2f64(<2 x double>)
