; RUN: llc -O1 < %s | FileCheck %s

@callf = dso_local local_unnamed_addr global i32 (i32)* @f, align 8

declare dso_local i32 @f(i32)

; Function Attrs: nounwind
define dso_local i32 @g(i32 %x) local_unnamed_addr {
entry:
  %0 = load i32 (i32)*, i32 (i32)** @callf, align 8
  %call = tail call i32 %0(i32 %x)
  ret i32 %call

; CHECK: igoto $r1
}
