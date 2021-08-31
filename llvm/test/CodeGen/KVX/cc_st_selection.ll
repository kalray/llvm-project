; RUN: llc %s -o - -stop-before=greedy | FileCheck %s
target triple = "kvx-kalray-cos"


define void @st(i32* nocapture %0, i32 %1, i32 %2) {
; CHECK: SWrrc %0, %1, 8, %2

  %4 = icmp eq i32 %2, 0
  br i1 %4, label %6, label %5

5:
  store i32 %1, i32* %0, align 4
  br label %6

6:
  ret void
}
define void @sw_weven(i32* nocapture %0, i32 %1, i32 %2) {
; CHECK: SWrrc %0, %1, 7, %2
  %4 = and i32 %2, 1
  %5 = icmp eq i32 %4, 0
  br i1 %5, label %6, label %7

6:
  store i32 %1, i32* %0, align 4
  br label %7

7:
  ret void
}

define void @sw_wodd(i32* nocapture %0, i32 %1, i32 %2) {
; CHECK: SWrrc %0, %1, 6, %2
  %4 = and i32 %2, 1
  %5 = icmp eq i32 %4, 0
  br i1 %5, label %7, label %6

6:
  store i32 %1, i32* %0, align 4
  br label %7

7:
  ret void
}

define void @sw_wgtz(i32* nocapture %0, i32 %1, i32 %2) {
; CHECK: SWrrc %0, %1, 13, %2
  %4 = icmp sgt i32 %2, 0
  br i1 %4, label %5, label %6

5:
  store i32 %1, i32* %0, align 4
  br label %6

6:
  ret void
}

define void @sw_wltz(i32* nocapture %0, i32 %1, i32 %2) {
; CHECK: SWrrc %0, %1, 10, %2
  %4 = icmp slt i32 %2, 0
  br i1 %4, label %5, label %6

5:
  store i32 %1, i32* %0, align 4
  br label %6

6:
  ret void
}

define void @sw_wlez(i32* nocapture %0, i32 %1, i32 %2) {
; CHECK: SWrrc %0, %1, 12, %2
  %4 = icmp slt i32 %2, 1
  br i1 %4, label %5, label %6

5:
  store i32 %1, i32* %0, align 4
  br label %6

6:
  ret void
}

define void @sw_wgez(i32* nocapture %0, i32 %1, i32 %2) {
; CHECK: SWrrc %0, %1, 11, %2
  %4 = icmp sgt i32 %2, -1
  br i1 %4, label %5, label %6

5:
  store i32 %1, i32* %0, align 4
  br label %6

6:
  ret void
}

define void @sw_weqz(i32* nocapture %0, i32 %1, i32 %2) {
; CHECK: SWrrc %0, %1, 9, %2
  %4 = icmp eq i32 %2, 0
  br i1 %4, label %5, label %6

5:
  store i32 %1, i32* %0, align 4
  br label %6

6:
  ret void
}

define void @sw_wnez(i32* nocapture %0, i32 %1, i32 %2) {
; CHECK: SWrrc %0, %1, 8, %2
  %4 = icmp eq i32 %2, 0
  br i1 %4, label %6, label %5

5:
  store i32 %1, i32* %0, align 4
  br label %6

6:
  ret void
}

define void @sw_wnez2(i32* nocapture %0, i32 %1, i32 %2, i32 %3) {
; CHECK: SWri27c 4, %0, %1, 8, %2
  %5 = icmp eq i32 %2, 0
  br i1 %5, label %8, label %6

6:
  %7 = getelementptr inbounds i32, i32* %0, i64 1
  store i32 %1, i32* %7, align 4
  br label %8

8:
  ret void
}

define void @sw_and_cond1(i32* nocapture %0, i32 %1, i32 %2) {
; CHECK: SWrrc %0, %1, 8, %3
  %4 = and i32 %2, 62285
  %5 = icmp eq i32 %4, 0
  br i1 %5, label %7, label %6

6:
  store i32 %1, i32* %0, align 4
  br label %7

7:
  ret void
}

define void @sw_compw_cond1(i32* nocapture %0, i32 %1, i32 %2) {
; CHECK: SWrrc %0, %1, 7, %3
  %4 = icmp sgt i32 %2, 62285
  br i1 %4, label %5, label %6

5:
  store i32 %1, i32* %0, align 4
  br label %6

6:
  ret void
}

define void @sw_ri27(i8* nocapture %0, i8 %1, i32 %2) {
; CHECK: SBri27c 67108863, %0, %3, 8, %2
  %4 = icmp eq i32 %2, 0
  br i1 %4, label %7, label %5

5:
  %6 = getelementptr inbounds i8, i8* %0, i64 67108863
  store i8 %1, i8* %6, align 1
  br label %7

7:
  ret void
}

define void @sw_ri54(i8* nocapture %0, i8 %1, i32 %2) {
; CHECK: SBri54c 67108864, %0, %3, 8, %2
  %4 = icmp eq i32 %2, 0
  br i1 %4, label %7, label %5

5:
  %6 = getelementptr inbounds i8, i8* %0, i64 67108864
  store i8 %1, i8* %6, align 1
  br label %7

7:
  ret void
}

define void @sw_ri54_max(i8* nocapture %0, i8 %1, i32 %2) {
; CHECK: SBri54c 9007199254740991, %0, %3, 8, %2
  %4 = icmp eq i32 %2, 0
  br i1 %4, label %7, label %5

5:
  %6 = getelementptr inbounds i8, i8* %0, i64 9007199254740991
  store i8 %1, i8* %6, align 1
  br label %7

7:
  ret void
}

define void @sw_ri54_over_max(i8* nocapture %0, i8 %1, i32 %2) {
; CHECK: SBri64 9007199254740992, %0, %3
  %4 = icmp eq i32 %2, 0
  br i1 %4, label %7, label %5

5:
  %6 = getelementptr inbounds i8, i8* %0, i64 9007199254740992
  store i8 %1, i8* %6, align 1
  br label %7

7:
  ret void
}

define void @sw_ri54_min(i8* nocapture %0, i8 %1, i32 %2) {
; CHECK: SBri54c -9007199254740992, %0, %3, 8, %2
  %4 = icmp eq i32 %2, 0
  br i1 %4, label %7, label %5

5:
  %6 = getelementptr inbounds i8, i8* %0, i64 -9007199254740992
  store i8 %1, i8* %6, align 1
  br label %7

7:
  ret void
}

define void @sw_ri54_sub_min(i8* nocapture %0, i8 %1, i32 %2) {
; CHECK: SBri64 -9007199254740993, %0, %3
  %4 = icmp eq i32 %2, 0
  br i1 %4, label %7, label %5

5:
  %6 = getelementptr inbounds i8, i8* %0, i64 -9007199254740993
  store i8 %1, i8* %6, align 1
  br label %7

7:
  ret void
}

define void @sw_rr(i8* nocapture %0, i8 %1, i64 %2) {
; CHECK: SBrrc %0, %3, 0, %2
  %4 = icmp eq i64 %2, 0
  br i1 %4, label %6, label %5

5:
  store i8 %1, i8* %0, align 1
  br label %6

6:
  ret void
}

define void @sw_rr_scale(i32* nocapture %0, i32 %1, i64 %2) {
; CHECK: SWrr %2, %0, %1, 1
  %4 = icmp eq i64 %2, 0
  br i1 %4, label %7, label %5

5:
  %6 = getelementptr inbounds i32, i32* %0, i64 %2
  store i32 %1, i32* %6, align 4
  br label %7

7:
  ret void
}

define void @sw_rr_scale_offset(i32* nocapture %0, i32 %1, i64 %2) {
; CHECK: SWrr %2, %0, %1, 1
  %4 = icmp eq i64 %2, 0
  br i1 %4, label %7, label %5

5:
  %6 = getelementptr inbounds i32, i32* %0, i64 %2
  store i32 %1, i32* %6, align 4
  br label %7

7:
  ret void
}

define void @sw_rr_offset(i8* nocapture %0, i8 %1, i64 %2) {
; CHECK: SBrr %2, %0, %3, 0
  %4 = icmp eq i64 %2, 0
  br i1 %4, label %7, label %5

5:
  %6 = getelementptr inbounds i8, i8* %0, i64 %2
  store i8 %1, i8* %6, align 1
  br label %7

7:
  ret void
}
