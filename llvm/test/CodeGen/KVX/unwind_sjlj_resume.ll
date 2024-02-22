; RUN: llc -o - %s | FileCheck %s
; CHECK: call _Unwind_SjLj_Resume

%union.anon.2 = type { [2 x i64] }
%struct.Id = type { ptr, i32, i32, i32, %union.anon.2 }

%union.anon.3 = type { ptr }
%union.anon.4 = type { i32 }
%union.anon.5 = type { ptr }
%struct.Exp = type { ptr, i32, i32, i32, ptr, ptr, %union.anon.3, %union.anon.4, %union.anon.5 }
%struct.Exp_ = type { i32, i32, i32, i32, ptr }
@.str = private unnamed_addr constant [3 x i8] c"%i\00"

declare noundef nonnull ptr @_Znam(i64 noundef)
declare noundef nonnull ptr @_Znwm(i64 noundef)
@bufflength = external global i32
@ch = external global i32
@currpc = external global i32
@inbuff = external global ptr
declare noundef i32 @sprintf(ptr noalias nocapture noundef writeonly, ptr nocapture noundef readonly, ...)
@stkptr = external global ptr

declare void @_ZdlPv(ptr noundef) local_unnamed_addr
declare i32 @__gxx_personality_sj0(...)

define noundef i32 @_Z7pushimmP9Classfile(ptr nocapture noundef readnone %0) personality ptr @__gxx_personality_sj0 {
  %2 = load i32, ptr @currpc
  %3 = add i32 %2, -1
  %4 = add i32 %2, 1
  store i32 %4, ptr @currpc
  %5 = load i32, ptr @bufflength
  %6 = add nsw i32 %5, -1
  store i32 %6, ptr @bufflength
  %7 = load ptr, ptr @inbuff
  %8 = getelementptr inbounds i8, ptr %7, i64 1
  store ptr %8, ptr @inbuff
  %9 = load i8, ptr %7
  %10 = sext i8 %9 to i32
  %11 = load i32, ptr @ch
  %12 = icmp eq i32 %11, 17
  br i1 %12, label %13, label %21

13:
  %14 = shl nsw i32 %10, 8
  %15 = add i32 %2, 2
  store i32 %15, ptr @currpc
  %16 = add nsw i32 %5, -2
  store i32 %16, ptr @bufflength
  %17 = getelementptr inbounds i8, ptr %7, i64 2
  store ptr %17, ptr @inbuff
  %18 = load i8, ptr %8
  %19 = zext i8 %18 to i32
  %20 = or i32 %14, %19
  br label %21

21:
  %22 = phi i32 [ %20, %13 ], [ %10, %1 ]
  %23 = tail call noalias noundef nonnull dereferenceable(32) ptr @_Znam(i64 noundef 32)
  %24 = tail call i32 (ptr, ptr, ...) @sprintf(ptr noundef nonnull %23, ptr noundef nonnull @.str, i32 noundef %22)
  %25 = tail call noalias noundef nonnull dereferenceable(64) ptr @_Znwm(i64 noundef 64)
  %26 = invoke noalias noundef nonnull dereferenceable(40) ptr @_Znwm(i64 noundef 40)
          to label %27 unwind label %38

27:
  store ptr %23, ptr %26
  %28 = getelementptr inbounds %struct.Id, ptr %26, i64 0, i32 1
  store <2 x i32> <i32 4, i32 1>, ptr %28
  %29 = getelementptr inbounds %struct.Id, ptr %26, i64 0, i32 3
  store i32 0, ptr %29
  %30 = getelementptr inbounds %struct.Exp, ptr %25, i64 0, i32 1
  store i32 1, ptr %30
  %31 = getelementptr inbounds %struct.Exp, ptr %25, i64 0, i32 3
  store i32 %3, ptr %31
  %32 = getelementptr inbounds %struct.Exp, ptr %25, i64 0, i32 2
  store i32 %3, ptr %32
  %33 = invoke noalias noundef nonnull dereferenceable(24) ptr @_Znwm(i64 noundef 24)
          to label %34 unwind label %38

34:
  store <4 x i32> <i32 0, i32 1, i32 4, i32 39>, ptr %33
  %35 = getelementptr inbounds %struct.Exp_, ptr %33, i64 0, i32 4
  store ptr %26, ptr %35
  store ptr %33, ptr %25
  %36 = load ptr, ptr @stkptr
  %37 = getelementptr inbounds ptr, ptr %36, i64 1
  store ptr %37, ptr @stkptr
  store ptr %25, ptr %36
  ret i32 0

38:
  %39 = landingpad { ptr, i32 }
          cleanup
  tail call void @_ZdlPv(ptr noundef nonnull %25)
  resume { ptr, i32 } %39
}
