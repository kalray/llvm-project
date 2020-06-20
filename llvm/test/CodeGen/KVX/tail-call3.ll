; RUN: llc -O1 < %s | FileCheck %s

%struct.Y = type { i64, i64 }

define dso_local %struct.Y @f(i64 %x.coerce0, i64 %x.coerce1, i64 %x.coerce2, i64 %x.coerce3, i64 %x.coerce4, i64 %x.coerce5, i64 %x.coerce6, i64 %x.coerce7, i64 %x.coerce8, i64 %x.coerce9, i64 %x.coerce10, i64 %x.coerce11, i64 %x.coerce12, i64 %x.coerce13) local_unnamed_addr {
entry:
  %x.sroa.30 = alloca i64, align 8
  store i64 %x.coerce13, i64* %x.sroa.30, align 8
  %add = add nsw i64 %x.coerce0, 10
  %call = tail call %struct.Y @g(i64 %add, i64 %x.coerce1, i64 %x.coerce2, i64 %x.coerce3, i64 %x.coerce4, i64 %x.coerce5, i64 %x.coerce6, i64 %x.coerce7, i64 %x.coerce8, i64 %x.coerce9, i64 %x.coerce10, i64 %x.coerce11, i64 %x.coerce12, i64 %x.coerce13)
  %0 = extractvalue %struct.Y %call, 0
  %x.sroa.30.0.x.sroa.30.0.x.sroa.30.104. = load volatile i64, i64* %x.sroa.30, align 8
  %add2 = add nsw i64 %x.sroa.30.0.x.sroa.30.0.x.sroa.30.104., 10
  store volatile i64 %add2, i64* %x.sroa.30, align 8
  %conv = trunc i64 %add to i32
  %x.sroa.30.0.x.sroa.30.0.x.sroa.30.104.11 = load volatile i64, i64* %x.sroa.30, align 8
  %call5 = tail call %struct.Y (i32, ...) @h(i32 %conv, i64 %x.sroa.30.0.x.sroa.30.0.x.sroa.30.104.11, i64 %x.coerce1)
  ret %struct.Y %call5

; CHECK: call g
; CHECK: goto h
}

declare dso_local %struct.Y @g(i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64) local_unnamed_addr

declare dso_local %struct.Y @h(i32, ...) local_unnamed_addr
