; RUN: llc --disable-kvx-loadstore-packing=false < %s | FileCheck %s

define dso_local i64 @f2(i64* nocapture readonly %a) {
entry:
  %0 = load i64, i64* %a, align 8
  %arrayidx1 = getelementptr inbounds i64, i64* %a, i64 1
  %1 = load i64, i64* %arrayidx1, align 8
  %add = add nsw i64 %1, %0
  ret i64 %add

; CHECK-LABEL: f2:
; CHECK: lq $r0r1 = 0[$r0]
; CHECK: ret
}

define dso_local i64 @f4(i64* nocapture readonly %a) {
entry:
  %0 = load i64, i64* %a, align 8
  %arrayidx1 = getelementptr inbounds i64, i64* %a, i64 1
  %1 = load i64, i64* %arrayidx1, align 8
  %add = add nsw i64 %1, %0
  %arrayidx2 = getelementptr inbounds i64, i64* %a, i64 2
  %2 = load i64, i64* %arrayidx2, align 8
  %add3 = add nsw i64 %add, %2
  %arrayidx4 = getelementptr inbounds i64, i64* %a, i64 3
  %3 = load i64, i64* %arrayidx4, align 8
  %add5 = add nsw i64 %add3, %3
  ret i64 %add5

; CHECK-LABEL: f4:
; CHECK: lo $r0r1r2r3 = 0[$r0]
; CHECK: ret
}

define dso_local i64 @f2_2(i64* nocapture readonly %a, i64* nocapture readonly %b) {
entry:
  %arrayidx = getelementptr inbounds i64, i64* %a, i64 1
  %0 = load i64, i64* %arrayidx, align 8
  %1 = load i64, i64* %a, align 8
  %arrayidx2 = getelementptr inbounds i64, i64* %b, i64 1
  %2 = load i64, i64* %arrayidx2, align 8
  %3 = load i64, i64* %b, align 8
  %factor = shl i64 %1, 1
  %add3 = add i64 %2, %0
  %add5 = add i64 %add3, %factor
  %add7 = add i64 %add5, %3
  ret i64 %add7

; CHECK-LABEL: f2_2
; CHECK: lq $r2r3 = 0[$r0]
; CHECK: lq $r0r1 = 0[$r1]
; CHECK: ret

}

define dso_local i64 @force(i64 %a, i64 %b, i64 %c, i64 %d) {
entry:
  %add = add nsw i64 %b, %a
  %add1 = add nsw i64 %add, %c
  %add2 = add nsw i64 %add1, %d
  ret i64 %add2
}

define dso_local i64 @f4_force(i64* nocapture readonly %a) {
entry:
  %0 = load i64, i64* %a, align 8
  %arrayidx1 = getelementptr inbounds i64, i64* %a, i64 1
  %1 = load i64, i64* %arrayidx1, align 8
  %arrayidx2 = getelementptr inbounds i64, i64* %a, i64 2
  %2 = load i64, i64* %arrayidx2, align 8
  %arrayidx3 = getelementptr inbounds i64, i64* %a, i64 3
  %3 = load i64, i64* %arrayidx3, align 8
  %add.i = add nsw i64 %1, %0
  %add1.i = add nsw i64 %add.i, %2
  %add2.i = add nsw i64 %add1.i, %3
  ret i64 %add2.i

; CHECK-LABEL: f4_force:
; CHECK: lo $r0r1r2r3 = 0[$r0]
; CHECK: ret
}
