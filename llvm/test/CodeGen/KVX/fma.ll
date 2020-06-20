; RUN: llc < %s -mtriple=kvx-kalray-cos | FileCheck %s

define float @ffmaw(float %a, float %b, float %c) {
  %res = call float @llvm.fma.f32(float %a, float %b, float %c)
  ret float %res
  ; CHECK: ffmaw $r2 = $r0, $r1
}

define float @ffmaw_i(float %a, float %b) {
  %res = call float @llvm.fma.f32(float %a, float %b, float 1.0)
  ret float %res
  ; CHECK: ffmaw $r0 = $r1, 0x3f800000
}

define double @ffmad(double %a, double %b, double %c) {
  %res = call double @llvm.fma.f64(double %a, double %b, double %c)
  ret double %res
  ; CHECK: ffmad $r2 = $r0, $r1
}

define double @ffmad_i(double %a, double %b) {
  %res = call double @llvm.fma.f64(double %a, double %b, double 1.0)
  ret double %res
  ; CHECK: ffmad $r0 = $r1, 0x3ff0000000000000
}

define <2 x float> @ffmawp(<2 x float> %a, <2 x float> %b, <2 x float> %c) {
  %res = call <2 x float> @llvm.fma.v2f32(<2 x float> %a, <2 x float> %b, <2 x float> %c)
  ret <2 x float> %res
  ; CHECK: ffmawp $r2 = $r0, $r1
}

define half @ffmaf16(half %a, half %b, half %c) {
  %res = call half @llvm.fma.f16(half %a, half %b, half %c)
  ret half %res
  ; CHECK: ffmahq $r2 = $r0, $r1
}

define <4 x half> @ffmahq(<4 x half> %a, <4 x half> %b, <4 x half> %c) {
  %res = call <4 x half> @llvm.fma.v4f16(<4 x half> %a, <4 x half> %b, <4 x half> %c)
  ret <4 x half> %res
  ; CHECK: ffmahq $r2 = $r0, $r1
}

define <2 x double> @ffmav2f64(<2 x double> %a, <2 x double> %b, <2 x double> %c) {
  %res = call <2 x double> @llvm.fma.v2f64(<2 x double> %a, <2 x double> %b, <2 x double> %c)
  ret <2 x double> %res
  ; CHECK: ffmad $r5 = $r1, $r3
  ; CHECK: ffmad $r4 = $r0, $r2
}

declare half @llvm.fma.f16(half, half, half)
declare float @llvm.fma.f32(float, float, float)
declare double @llvm.fma.f64(double, double, double)
declare <2 x float> @llvm.fma.v2f32(<2 x float>, <2 x float>, <2 x float>)
declare <4 x half> @llvm.fma.v4f16(<4 x half>, <4 x half>, <4 x half>)
declare <2 x double> @llvm.fma.v2f64(<2 x double>, <2 x double>, <2 x double>)
