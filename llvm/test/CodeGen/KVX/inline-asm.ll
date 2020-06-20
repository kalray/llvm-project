; RUN: llc < %s | FileCheck %s

define dso_local void @f() {
  %1 = alloca i32, align 4
  store i32 1234, i32* %1, align 4
  %2 = load i32, i32* %1, align 4
  call void asm sideeffect "addd $$tp = $0, 0\0A\09;;", "r,~{$r13}"(i32 %2)
  ret void
; CHECK: f:
; CHECK: make $r0 = 1234
; CHECK-NEXT: ;;
; CHECK: addd $tp = $r0, 0
; CHECK-NEXT: ;;
; CHECK: ret
; CHECK-NEXT: ;;
}
