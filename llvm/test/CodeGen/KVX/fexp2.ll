; RUN: llc < %s -mtriple=kvx-kalray-cos | FileCheck %s

define float @exp2f32(float %x) {
  %tmp = call float @llvm.exp2.f32(float %x)
  ret float %tmp
  ; CHECK: exp2f32:
  ; CHECK: call exp2f
  ; CHECK: ret
}

define double @exp2f64(double %x) {
  %tmp = call double @llvm.exp2.f64(double %x)
  ret double %tmp
  ; CHECK: exp2f64:
  ; CHECK: call exp2
  ; CHECK: ret
}

define <2 x float> @exp2v2f32(<2 x float> %x) {
  %tmp = call <2 x float> @llvm.exp2.v2f32(<2 x float> %x)
  ret <2 x float> %tmp
  ; CHECK: exp2v2f32:
  ; CHECK: call exp2f
  ; CHECK: call exp2f
  ; CHECK: ret
}

define <2 x double> @exp2v2f64(<2 x double> %x) {
  %tmp = call <2 x double> @llvm.exp2.v2f64(<2 x double> %x)
  ret <2 x double> %tmp
  ; CHECK: exp2v2f64:
  ; CHECK: call exp2
  ; CHECK: call exp2
  ; CHECK: ret
}

declare float @llvm.exp2.f32(float)
declare double @llvm.exp2.f64(double)
declare <2x float> @llvm.exp2.v2f32(<2 x float>)
declare <2x double> @llvm.exp2.v2f64(<2 x double>)
