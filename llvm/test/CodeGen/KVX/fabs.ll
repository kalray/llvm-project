; RUN: llc < %s -mtriple=kvx-kalray-fabs | FileCheck %s

define float @fabsf32(float %x) {
  %tmp = call float @llvm.fabs.f32(float %x)
  ret float %tmp
  ; CHECK: fabsf32:
  ; CHECK: fabsw
  ; CHECK: ret
}

define double @fabsf64(double %x) {
  %tmp = call double @llvm.fabs.f64(double %x)
  ret double %tmp
  ; CHECK: fabsf64:
  ; CHECK: fabsd
  ; CHECK: ret
}

define <2 x float> @fabsv2f32(<2 x float> %x) {
  %tmp = call <2 x float> @llvm.fabs.v2f32(<2 x float> %x)
  ret <2 x float> %tmp
  ; CHECK: fabsv2f32:
  ; CHECK: fabswp
  ; CHECK: ret
}

define <2 x double> @fabsv2f64(<2 x double> %x) {
  %tmp = call <2 x double> @llvm.fabs.v2f64(<2 x double> %x)
  ret <2 x double> %tmp
  ; CHECK: fabsv2f64:
  ; CHECK: fabsd
  ; CHECK: fabsd
  ; CHECK: ret
}

declare float @llvm.fabs.f32(float)
declare double @llvm.fabs.f64(double)
declare <2x float> @llvm.fabs.v2f32(<2 x float>)
declare <2x double> @llvm.fabs.v2f64(<2 x double>)
