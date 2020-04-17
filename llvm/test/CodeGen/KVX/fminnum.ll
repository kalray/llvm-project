; RUN: llc < %s -mtriple=kvx-kalray-cos | FileCheck %s

define float @fminw(float %a, float %b) {
  %res = call float @llvm.minnum.f32(float %a, float %b)
  ret float %res
  ; CHECK: fminw $r0 = $r0, $r1
}
declare float @llvm.minnum.f32(float, float)

define double @fmind(double %a, double %b) {
  %res = call double @llvm.minnum.f64(double %a, double %b)
  ret double %res
  ; CHECK: fmind $r0 = $r0, $r1
}
declare double @llvm.minnum.f64(double, double)
