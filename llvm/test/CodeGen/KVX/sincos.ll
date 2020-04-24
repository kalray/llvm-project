; RUN: llc < %s -mtriple=kvx-kalray-cos | FileCheck %s

define float @f1rn(float %x) {
  %tmp1 = call float @sinf(float %x) readnone
  %tmp2 = call float @cosf(float %x) readnone
  %add = fadd float %tmp1, %tmp2
  ret float %add
  ; CHECK: f1rn:
  ; CHECK: call sinf
  ; CHECK: call cosf
  ; CHECK: ret
}

define float @f1(float %x) {
  %tmp1 = call float @sinf(float %x)
  %tmp2 = call float @cosf(float %x)
  %add = fadd float %tmp1, %tmp2
  ret float %add
  ; CHECK: f1:
  ; CHECK: call sinf
  ; CHECK: call cosf
  ; CHECK: ret
}

define double @f2rn(double %x) {
  %tmp1 = call double @sin(double %x) readnone
  %tmp2 = call double @cos(double %x) readnone
  %add = fadd double %tmp1, %tmp2
  ret double %add
  ; CHECK: f2rn:
  ; CHECK: call sin
  ; CHECK: call cos
  ; CHECK: ret
}

define double @f2(double %x) {
  %tmp1 = call double @sin(double %x)
  %tmp2 = call double @cos(double %x)
  %add = fadd double %tmp1, %tmp2
  ret double %add
  ; CHECK: f2:
  ; CHECK: call sin
  ; CHECK: call cos
  ; CHECK: ret
}

declare float @sinf(float)
declare double @sin(double)
declare float @cosf(float)
declare double @cos(double)
