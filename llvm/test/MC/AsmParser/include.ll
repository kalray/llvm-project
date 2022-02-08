; RUN: llc -I %p/Inputs -filetype asm -o - %s | FileCheck %s
; REQUIRES: default_triple
; XFAIL: kvx
; kvx does not implement assembler parser yet.
module asm ".include \22module.x\22"

define void @f() {
entry:
  call void asm sideeffect ".include \22function.x\22", ""()
  ret void
}

; CHECK: .set MODULE, 1
; CHECK: .set FUNCTION, 1
