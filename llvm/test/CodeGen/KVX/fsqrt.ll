; RUN: llc < %s -mtriple=kvx-kalray-sqrt | FileCheck %s

define float @sqrtf32(float %x) {
  %tmp = call float @llvm.sqrt.f32(float %x)
  ret float %tmp
  ; CHECK: sqrtf32:
  ; CHECK: call sqrtf
  ; CHECK: ret
}

define double @sqrtf64(double %x) {
  %tmp = call double @llvm.sqrt.f64(double %x)
  ret double %tmp
  ; CHECK: sqrtf64:
  ; CHECK: call sqrt
  ; CHECK: ret
}

define <2 x float> @sqrtv2f32(<2 x float> %x) {
  %tmp = call <2 x float> @llvm.sqrt.v2f32(<2 x float> %x)
  ret <2 x float> %tmp
  ; CHECK: sqrtv2f32:
  ; CHECK: call sqrtf
  ; CHECK: call sqrtf
  ; CHECK: ret
}

define <2 x double> @sqrtv2f64(<2 x double> %x) {
  %tmp = call <2 x double> @llvm.sqrt.v2f64(<2 x double> %x)
  ret <2 x double> %tmp
  ; CHECK: sqrtv2f64:
  ; CHECK: call sqrt
  ; CHECK: call sqrt
  ; CHECK: ret
}

declare float @llvm.sqrt.f32(float)
declare double @llvm.sqrt.f64(double)
declare <2x float> @llvm.sqrt.v2f32(<2 x float>)
declare <2x double> @llvm.sqrt.v2f64(<2 x double>)
