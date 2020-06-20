; RUN: llc --disable-kvx-loadstore-packing=false < %s | FileCheck %s

; Function Attrs: norecurse nounwind
define dso_local void @f2(i64* nocapture readonly %a, i64* nocapture %b) local_unnamed_addr {
entry:
  %0 = load i64, i64* %a, align 8
  %arrayidx1 = getelementptr inbounds i64, i64* %a, i64 1
  %1 = load i64, i64* %arrayidx1, align 8
  store i64 %0, i64* %b, align 8
  %arrayidx3 = getelementptr inbounds i64, i64* %b, i64 1
  store i64 %1, i64* %arrayidx3, align 8
  ret void

; CHECK: lq $r2r3 = 0[$r0]
; CHECK: sq 0[$r1] = $r2r3
}

; Function Attrs: norecurse nounwind
define dso_local void @f4(i64* nocapture readonly %a, i64* nocapture %b) local_unnamed_addr {
entry:
  %0 = load i64, i64* %a, align 8
  %arrayidx1 = getelementptr inbounds i64, i64* %a, i64 1
  %1 = load i64, i64* %arrayidx1, align 8
  %arrayidx2 = getelementptr inbounds i64, i64* %a, i64 2
  %2 = load i64, i64* %arrayidx2, align 8
  %arrayidx3 = getelementptr inbounds i64, i64* %a, i64 3
  %3 = load i64, i64* %arrayidx3, align 8
  store i64 %0, i64* %b, align 8
  %arrayidx5 = getelementptr inbounds i64, i64* %b, i64 1
  store i64 %1, i64* %arrayidx5, align 8
  %arrayidx6 = getelementptr inbounds i64, i64* %b, i64 2
  store i64 %2, i64* %arrayidx6, align 8
  %arrayidx7 = getelementptr inbounds i64, i64* %b, i64 3
  store i64 %3, i64* %arrayidx7, align 8
  ret void

; CHECK: lo $r4r5r6r7 = 0[$r0]
; CHECK: so 0[$r1] = $r4r5r6r7
}
