; RUN: llc -O3 -o - %s | FileCheck %s
target triple = "kvx-kalray-cos"

; CHECK-LABEL: foo
; CHECK: sd [[STACKSLOT:[0-9]+\[\$r12\]]] = $r14
; CHECK: call bar
; CHECK: ld $r14 = [[STACKSLOT]]
; CHECK: ret
define i32 @foo(i32 %n, i32 %m) {
entry:
  %0 = zext i32 %n to i64
  %vla = alloca i32, i64 %0, align 4
  call void @bar(i32* nonnull %vla)
  %idxprom = sext i32 %m to i64
  %arrayidx = getelementptr inbounds i32, i32* %vla, i64 %idxprom
  %1 = load i32, i32* %arrayidx, align 4
  ret i32 %1
}

declare void @bar(i32*)
