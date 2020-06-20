; RUN: llc < %s | FileCheck %s

define half @f1() {
entry:
  ret half 0xHBC00
; CHECK: f1
; CHECK: 0xbc00
}

define float @f2() {
entry:
  ret float 1.000000e+00
; CHECK: f2
; CHECK: 0x3f800000
}

define double @f3() {
entry:
  ret double 1.000000e+00
; CHECK: f3
; CHECK: 0x3ff0000000000000
}
