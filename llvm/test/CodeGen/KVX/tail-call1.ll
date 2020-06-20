; RUN: llc -O1 < %s | FileCheck %s

@v = external dso_local local_unnamed_addr global [5 x i32], align 4

; Function Attrs: nounwind
define dso_local i32 @foo() local_unnamed_addr{
entry:
  %0 = load i32, i32* getelementptr inbounds ([5 x i32], [5 x i32]* @v, i64 0, i64 4), align 4
  %mul = mul nsw i32 %0, %0
  %call = tail call i32 @bar(i32 %mul)
  ret i32 %call

; CHECK: goto bar
}

declare dso_local i32 @bar(i32) local_unnamed_addr
