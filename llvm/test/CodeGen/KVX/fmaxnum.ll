; RUN: llc < %s -mtriple=kvx-kalray-cos | FileCheck %s

define float @fmaxw(float %a, float %b) {
  %res = call float @llvm.maxnum.f32(float %a, float %b)
  ret float %res
  ; CHECK: fmaxw $r0 = $r0, $r1
}
declare float @llvm.maxnum.f32(float, float)

define double @fmaxd(double %a, double %b) {
  %res = call double @llvm.maxnum.f64(double %a, double %b)
  ret double %res
  ; CHECK: fmaxd $r0 = $r0, $r1
}
declare double @llvm.maxnum.f64(double, double)
