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

declare float @llvm.fma.f32(float, float, float)
declare double @llvm.fma.f64(double, double, double)
