; RUN: llc < %s -mtriple=kvx-kalray-cos | FileCheck %s

define i32 @f32min(i32 *%src, i32 %b) {
; CHECK-LABEL: f32min:
; CHECK: call __sync_fetch_and_min_4
  %res = atomicrmw min i32 *%src, i32 %b seq_cst
  ret i32 %res
}

define i32 @f32max(i32 *%src, i32 %b) {
; CHECK-LABEL: f32max:
; CHECK: call __sync_fetch_and_max_4
  %res = atomicrmw max i32 *%src, i32 %b seq_cst
  ret i32 %res
}

define i32 @f32umin(i32 *%src, i32 %b) {
; CHECK-LABEL: f32umin:
; CHECK: call __sync_fetch_and_umin_4
  %res = atomicrmw umin i32 *%src, i32 %b seq_cst
  ret i32 %res
}

define i32 @f32umax(i32 *%src, i32 %b) {
; CHECK-LABEL: f32umax:
; CHECK: call __sync_fetch_and_umax_4
  %res = atomicrmw umax i32 *%src, i32 %b seq_cst
  ret i32 %res
}

define i64 @f64min(i64 *%src, i64 %b) {
; CHECK-LABEL: f64min:
; CHECK: call __sync_fetch_and_min_8
  %res = atomicrmw min i64 *%src, i64 %b seq_cst
  ret i64 %res
}

define i64 @f64max(i64 *%src, i64 %b) {
; CHECK-LABEL: f64max:
; CHECK: call __sync_fetch_and_max_8
  %res = atomicrmw max i64 *%src, i64 %b seq_cst
  ret i64 %res
}

define i64 @f64umin(i64 *%src, i64 %b) {
; CHECK-LABEL: f64umin:
; CHECK: call __sync_fetch_and_umin_8
  %res = atomicrmw umin i64 *%src, i64 %b seq_cst
  ret i64 %res
}

define i64 @f64umax(i64 *%src, i64 %b) {
; CHECK-LABEL: f64umax:
; CHECK: call __sync_fetch_and_umax_8
  %res = atomicrmw umax i64 *%src, i64 %b seq_cst
  ret i64 %res
}
