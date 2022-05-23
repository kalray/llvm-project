; REQUIRES: asserts
; RUN: llc -O3 -o - %s | FileCheck %s
; CHECK: End function
target triple = "kvx-kalray-cos"

define void @a() {
  br label %1

1:
  %2 = phi <512 x i1> [ %15, %14 ], [ undef, %0 ]
  %3 = phi i32 [ %4, %14 ], [ undef, %0 ]
  %4 = select i1 undef, i32 %3, i32 0
  %5 = sub i32 %4, %3
  %6 = urem i32 %5, 3
  %7 = trunc i32 %6 to i8
  %8 = add nuw nsw i8 %7, 1
  %9 = urem i8 %8, 3
  %10 = icmp eq i8 %9, 1
  %11 = select i1 %10, <512 x i1> %2, <512 x i1> zeroinitializer
  br i1 undef, label %14, label %12

12:
  br label %13

13:
  br i1 undef, label %13, label %14

14:
  %15 = phi <512 x i1> [ %11, %1 ], [ zeroinitializer, %13 ]
  %16 = tail call <1024 x i1> @llvm.kvx.xbuildfwm(<512 x i1> %15, <512 x i1> undef)
  %17 = tail call <256 x i1> @llvm.kvx.xconvwbv(<1024 x i1> %16, i32 3, i32 0)
  store <256 x i1> %17, <256 x i1>* undef, align 32
  br label %1
}

declare <1024 x i1> @llvm.kvx.xbuildfwm(<512 x i1>, <512 x i1>)

declare <256 x i1> @llvm.kvx.xconvwbv(<1024 x i1>, i32, i32)
