; RUN: llc -stop-before=greedy -o - %s | FileCheck %s
; CHECK:  implicit-def early-clobber $cs

target triple = "kvx-kalray-cos"

define void @foo(i64 %0) {
  tail call void asm sideeffect "set $$cs = $0", "r,~{$cs}"(i64 %0)
  ret void
}
