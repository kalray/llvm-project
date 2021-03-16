; RUN: llc -o - %s | FileCheck %s
; CHECK: .size   a, .Lfunc_end0-a
; Only check we printed all the way to end of function
; From the c src:
; a() {
;   int b = 0;
;   __tca256 c;
;   __tca512 d = __builtin_kvx_buildfvw(c, c);
;   for (int col;; col += 2) {
;     int e;
;     __tca512 f, g;
;     __tca1024 h;
;     __tca256 i;
; #pragma unroll 3
;     for (; e < b; ++e)
;       f = d;
;     h = __builtin_kvx_buildfwm(f, g);
;     i = __builtin_kvx_convwbv(h, ".rz.sat");
;     *(__tca256 *)col = i;
;   }
; }
target triple = "kvx-kalray-cos"

define i32 @a() {
  %1 = tail call <512 x i1> @llvm.kvx.buildfvw(<256 x i1> undef, <256 x i1> undef)
  br label %2

2:
  %3 = phi i64 [ %30, %25 ], [ 0, %0 ]
  %4 = phi <512 x i1> [ %26, %25 ], [ undef, %0 ]
  %5 = phi i32 [ %7, %25 ], [ undef, %0 ]
  %6 = icmp sgt i32 %5, 0
  %7 = select i1 %6, i32 %5, i32 0
  %8 = sub i32 %7, %5
  %9 = urem i32 %8, 3
  %10 = trunc i32 %9 to i8
  %11 = add nuw nsw i8 %10, 1
  %12 = urem i8 %11, 3
  %13 = icmp eq i8 %12, 1
  %14 = select i1 %13, <512 x i1> %4, <512 x i1> %1
  %15 = icmp ult i32 %8, 2
  br i1 %15, label %25, label %16

16:
  %17 = icmp eq i8 %12, 0
  %18 = select i1 %13, i32 1, i32 2
  %19 = select i1 %17, i32 0, i32 %18
  %20 = add nsw i32 %5, %19
  br label %21

21:
  %22 = phi i32 [ %24, %21 ], [ %20, %16 ]
  %23 = icmp slt i32 %22, -2
  %24 = add nsw i32 %22, 3
  br i1 %23, label %21, label %25

25:
  %26 = phi <512 x i1> [ %14, %2 ], [ %1, %21 ]
  %27 = tail call <1024 x i1> @llvm.kvx.buildfwm(<512 x i1> %26, <512 x i1> undef)
  %28 = tail call <256 x i1> @llvm.kvx.convwbv(<1024 x i1> %27, i32 3, i32 0)
  %29 = inttoptr i64 %3 to <256 x i1>*
  store <256 x i1> %28, <256 x i1>* %29, align 32
  %30 = add i64 %3, 2
  br label %2
}

declare <512 x i1> @llvm.kvx.buildfvw(<256 x i1>, <256 x i1>)

declare <1024 x i1> @llvm.kvx.buildfwm(<512 x i1>, <512 x i1>)

declare <256 x i1> @llvm.kvx.convwbv(<1024 x i1>, i32, i32)
