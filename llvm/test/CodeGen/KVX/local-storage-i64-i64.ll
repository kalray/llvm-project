; RUN: llc < %s | FileCheck %s

define dso_local void @f() {
  %1 = alloca i64, align 8
  %2 = alloca i32, align 4
  ret void
; CHECK: f:
; CHECK: addd {{.*}}, -32
; CHECK: addd {{.*}}, 32
; CHECK: ret
; CHECK-NEXT: ;;
}

define dso_local void @g() {
  %1 = alloca i64, align 8
  %2 = alloca i64, align 8
  %3 = alloca i32, align 4
  ret void
; CHECK: g:
; CHECK: addd {{.*}}, -32
; CHECK: addd {{.*}}, 32
; CHECK: ret
; CHECK-NEXT: ;;
}
