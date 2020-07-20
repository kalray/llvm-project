; RUN: llc < %s -mtriple=kvx-kalray-cos | FileCheck %s

define float @truncf32(float %x) {
  %tmp = call float @llvm.trunc.f32(float %x)
  ret float %tmp
  ; CHECK: truncf32:
  ; CHECK: call truncf
  ; CHECK: ret
}

define double @truncf64(double %x) {
  %tmp = call double @llvm.trunc.f64(double %x)
  ret double %tmp
  ; CHECK: truncf64:
  ; CHECK: call trunc
  ; CHECK: ret
}

define <2 x float> @truncv2f32(<2 x float> %x) {
  %tmp = call <2 x float> @llvm.trunc.v2f32(<2 x float> %x)
  ret <2 x float> %tmp
  ; CHECK: truncv2f32:
  ; CHECK: call truncf
  ; CHECK: call truncf
  ; CHECK: ret
}

define <2 x double> @truncv2f64(<2 x double> %x) {
  %tmp = call <2 x double> @llvm.trunc.v2f64(<2 x double> %x)
  ret <2 x double> %tmp
  ; CHECK: truncv2f64:
  ; CHECK: call trunc
  ; CHECK: call trunc
  ; CHECK: ret
}

declare float @llvm.trunc.f32(float)
declare double @llvm.trunc.f64(double)
declare <2x float> @llvm.trunc.v2f32(<2 x float>)
declare <2x double> @llvm.trunc.v2f64(<2 x double>)
