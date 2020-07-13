; RUN: llc < %s -mtriple=kvx-kalray-cos | FileCheck %s

define float @floorf32(float %x) {
  %tmp = call float @llvm.floor.f32(float %x)
  ret float %tmp
  ; CHECK: floorf32:
  ; CHECK: call floorf
  ; CHECK: ret
}

define double @floorf64(double %x) {
  %tmp = call double @llvm.floor.f64(double %x)
  ret double %tmp
  ; CHECK: floorf64:
  ; CHECK: call floor
  ; CHECK: ret
}

define <2 x float> @floorv2f32(<2 x float> %x) {
  %tmp = call <2 x float> @llvm.floor.v2f32(<2 x float> %x)
  ret <2 x float> %tmp
  ; CHECK: floorv2f32:
  ; CHECK: call floorf
  ; CHECK: call floorf
  ; CHECK: ret
}

define <2 x double> @floorv2f64(<2 x double> %x) {
  %tmp = call <2 x double> @llvm.floor.v2f64(<2 x double> %x)
  ret <2 x double> %tmp
  ; CHECK: floorv2f64:
  ; CHECK: call floor
  ; CHECK: call floor
  ; CHECK: ret
}

declare float @llvm.floor.f32(float)
declare double @llvm.floor.f64(double)
declare <2x float> @llvm.floor.v2f32(<2 x float>)
declare <2x double> @llvm.floor.v2f64(<2 x double>)
