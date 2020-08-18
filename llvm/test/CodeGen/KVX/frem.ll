; RUN: llc < %s -mtriple=kvx-kalray-cos | FileCheck %s

define float @remf32(float %x, float %y) {
  %tmp = frem float %x, %y
  ret float %tmp
  ; CHECK: remf32:
  ; CHECK: call fmodf
  ; CHECK: ret
}

define double @remf64(double %x, double %y) {
  %tmp = frem double %x, %y
  ret double %tmp
  ; CHECK: remf64:
  ; CHECK: call fmod
  ; CHECK: ret
}

define <2 x float> @remv2f32(<2 x float> %x, <2 x float> %y) {
  %tmp = frem <2 x float> %x, %y
  ret <2 x float> %tmp
  ; CHECK: remv2f32:
  ; CHECK: call fmodf
  ; CHECK: call fmodf
  ; CHECK: ret
}

define <2 x double> @remv2f64(<2 x double> %x, <2 x double> %y) {
  %tmp = frem <2 x double> %x, %y
  ret <2 x double> %tmp
  ; CHECK: remv2f64:
  ; CHECK: call fmod
  ; CHECK: call fmod
  ; CHECK: ret
}
