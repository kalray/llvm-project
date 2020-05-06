; RUN: llc < %s -mtriple=kvx-kalray-cos | FileCheck %s

define float @powf32(float %x, float %y) {
  %tmp = call float @llvm.pow.f32(float %x, float %y)
  ret float %tmp
  ; CHECK: powf32:
  ; CHECK: call powf
  ; CHECK: ret
}

define double @powf64(double %x, double %y) {
  %tmp = call double @llvm.pow.f64(double %x, double %y)
  ret double %tmp
  ; CHECK: powf64:
  ; CHECK: call pow
  ; CHECK: ret
}

declare float @llvm.pow.f32(float, float)
declare double @llvm.pow.f64(double, double)
