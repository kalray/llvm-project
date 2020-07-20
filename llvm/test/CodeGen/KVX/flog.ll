; RUN: llc < %s -mtriple=kvx-kalray-cos | FileCheck %s

define float @logf32(float %x) {
  %tmp = call float @llvm.log.f32(float %x)
  ret float %tmp
  ; CHECK: logf32:
  ; CHECK: call logf
  ; CHECK: ret
}

define double @logf64(double %x) {
  %tmp = call double @llvm.log.f64(double %x)
  ret double %tmp
  ; CHECK: logf64:
  ; CHECK: call log
  ; CHECK: ret
}

define <2 x float> @logv2f32(<2 x float> %x) {
  %tmp = call <2 x float> @llvm.log.v2f32(<2 x float> %x)
  ret <2 x float> %tmp
  ; CHECK: logv2f32:
  ; CHECK: call logf
  ; CHECK: call logf
  ; CHECK: ret
}

define <2 x double> @logv2f64(<2 x double> %x) {
  %tmp = call <2 x double> @llvm.log.v2f64(<2 x double> %x)
  ret <2 x double> %tmp
  ; CHECK: logv2f64:
  ; CHECK: call log
  ; CHECK: call log
  ; CHECK: ret
}

declare float @llvm.log.f32(float)
declare double @llvm.log.f64(double)
declare <2x float> @llvm.log.v2f32(<2 x float>)
declare <2x double> @llvm.log.v2f64(<2 x double>)
