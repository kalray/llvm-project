; RUN: llc < %s -mtriple=kvx-kalray-cos | FileCheck %s

define float @expf32(float %x) {
  %tmp = call float @llvm.exp.f32(float %x)
  ret float %tmp
  ; CHECK: expf32:
  ; CHECK: call expf
  ; CHECK: ret
}

define double @expf64(double %x) {
  %tmp = call double @llvm.exp.f64(double %x)
  ret double %tmp
  ; CHECK: expf64:
  ; CHECK: call exp
  ; CHECK: ret
}

define <2 x float> @expv2f32(<2 x float> %x) {
  %tmp = call <2 x float> @llvm.exp.v2f32(<2 x float> %x)
  ret <2 x float> %tmp
  ; CHECK: expv2f32:
  ; CHECK: call expf
  ; CHECK: call expf
  ; CHECK: ret
}

define <2 x double> @expv2f64(<2 x double> %x) {
  %tmp = call <2 x double> @llvm.exp.v2f64(<2 x double> %x)
  ret <2 x double> %tmp
  ; CHECK: expv2f64:
  ; CHECK: call exp
  ; CHECK: call exp
  ; CHECK: ret
}

declare float @llvm.exp.f32(float)
declare double @llvm.exp.f64(double)
declare <2x float> @llvm.exp.v2f32(<2 x float>)
declare <2x double> @llvm.exp.v2f64(<2 x double>)
