; RUN: llc < %s -mtriple=kvx-kalray-cos | FileCheck %s

define float @sinf32(float %x) {
  %tmp = call float @llvm.sin.f32(float %x)
  ret float %tmp
  ; CHECK: sinf32:
  ; CHECK: call sinf
  ; CHECK: ret
}

define double @sinf64(double %x) {
  %tmp = call double @llvm.sin.f64(double %x)
  ret double %tmp
  ; CHECK: sinf64:
  ; CHECK: call sin
  ; CHECK: ret
}

define <2 x float> @sinv2f32(<2 x float> %x) {
  %tmp = call <2 x float> @llvm.sin.v2f32(<2 x float> %x)
  ret <2 x float> %tmp
  ; CHECK: sinv2f32:
  ; CHECK: call sinf
  ; CHECK: call sinf
  ; CHECK: ret
}

define <2 x double> @sinv2f64(<2 x double> %x) {
  %tmp = call <2 x double> @llvm.sin.v2f64(<2 x double> %x)
  ret <2 x double> %tmp
  ; CHECK: sinv2f64:
  ; CHECK: call sin
  ; CHECK: call sin
  ; CHECK: ret
}

declare float @llvm.sin.f32(float)
declare double @llvm.sin.f64(double)
declare <2x float> @llvm.sin.v2f32(<2 x float>)
declare <2x double> @llvm.sin.v2f64(<2 x double>)
