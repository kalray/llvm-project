; RUN: llc < %s | FileCheck %s

define dso_local void @f() {
  %1 = alloca i32, align 4
  ret void
; CHECK: f:
; CHECK: addd {{.*}}, -32
; CHECK: addd {{.*}}, 32
; CHECK: ret
; CHECK-NEXT: ;;
}

define dso_local void @g() {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  ret void
; CHECK: g:
; CHECK: addd {{.*}}, -32
; CHECK: addd {{.*}}, 32
; CHECK: ret
; CHECK-NEXT: ;;
}

define dso_local void @h() {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  ret void
; CHECK: h:
; CHECK: addd {{.*}}, -32
; CHECK: addd {{.*}}, 32
; CHECK: ret
; CHECK-NEXT: ;;
}
