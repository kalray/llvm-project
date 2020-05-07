; RUN: llc -relocation-model=pic < %s -mtriple=kvx-kalray-cos | FileCheck %s

; reduced testcase from T13087

declare dso_local i64 @get_x()
declare dso_local i64 @get_y()
declare dso_local i64 @get_z()

define i64 @foo(double*, double*, double*, { i32, [3 x i64], [3 x i64], [3 x i64], i8*, i32*, i32 }*, i64, i64, i64) {
  %8 = getelementptr { i32, [3 x i64], [3 x i64], [3 x i64], i8*, i32*, i32 }, { i32, [3 x i64], [3 x i64], [3 x i64], i8*, i32*, i32 }* %3, i64 0, i32 3, i64 0
  %9 = load i64, i64* %8, align 8
  %10 = getelementptr { i32, [3 x i64], [3 x i64], [3 x i64], i8*, i32*, i32 }, { i32, [3 x i64], [3 x i64], [3 x i64], i8*, i32*, i32 }* %3, i64 0, i32 2, i64 0
  %11 = load i64, i64* %10, align 8
  %12 = tail call i64 @get_x()
  %13 = tail call i64 @get_y()
  %14 = tail call i64 @get_z()
  %15 = mul i64 %9, %4
  %16 = add i64 %15, %11
  %17 = add i64 %16, %12
  ret i64 %17
; CHECK: foo
; CHECK: call get_x
; CHECK-NOT: copyd $r{{[0-9]+}} = $r0
; CHECK-NEXT: ;;
}
