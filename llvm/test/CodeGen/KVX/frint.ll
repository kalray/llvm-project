; RUN: llc < %s -mtriple=kvx-kalray-cos | FileCheck %s

define float @rintf32(float %x) {
  %tmp = call float @llvm.rint.f32(float %x)
  ret float %tmp
  ; CHECK: rintf32:
  ; CHECK: call rintf
  ; CHECK: ret
}

define double @rintf64(double %x) {
  %tmp = call double @llvm.rint.f64(double %x)
  ret double %tmp
  ; CHECK: rintf64:
  ; CHECK: call rint
  ; CHECK: ret
}

define <2 x float> @rintv2f32(<2 x float> %x) {
  %tmp = call <2 x float> @llvm.rint.v2f32(<2 x float> %x)
  ret <2 x float> %tmp
  ; CHECK: rintv2f32:
  ; CHECK: call rintf
  ; CHECK: call rintf
  ; CHECK: ret
}

define <2 x double> @rintv2f64(<2 x double> %x) {
  %tmp = call <2 x double> @llvm.rint.v2f64(<2 x double> %x)
  ret <2 x double> %tmp
  ; CHECK: rintv2f64:
  ; CHECK: call rint
  ; CHECK: call rint
  ; CHECK: ret
}

declare float @llvm.rint.f32(float)
declare double @llvm.rint.f64(double)
declare <2x float> @llvm.rint.v2f32(<2 x float>)
declare <2x double> @llvm.rint.v2f64(<2 x double>)
