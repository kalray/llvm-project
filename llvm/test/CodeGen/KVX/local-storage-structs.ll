; RUN: llc < %s | FileCheck %s

%struct.X = type { i32, i32, i32, float* }

define dso_local void @f() {
  %1 = alloca %struct.X, align 8
  ret void
; CHECK: f:
; CHECK: addd {{.*}}, -32
; CHECK: addd {{.*}}, 32
; CHECK: ret
; CHECK-NEXT: ;;
}
