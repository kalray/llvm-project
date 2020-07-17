; RUN: llc < %s -mtriple=kvx-kalray-cos | FileCheck %s

define i32 @f32min(i32 *%src, i32 %b) {
; CHECK-LABEL: f32min:
; CHECK: minw
  %res = atomicrmw min i32 *%src, i32 %b seq_cst
  ret i32 %res
}

define i32 @f32max(i32 *%src, i32 %b) {
; CHECK-LABEL: f32max:
; CHECK: maxw
  %res = atomicrmw max i32 *%src, i32 %b seq_cst
  ret i32 %res
}

define i32 @f32umin(i32 *%src, i32 %b) {
; CHECK-LABEL: f32umin:
; CHECK: minuw
  %res = atomicrmw umin i32 *%src, i32 %b seq_cst
  ret i32 %res
}

define i32 @f32umax(i32 *%src, i32 %b) {
; CHECK-LABEL: f32umax:
; CHECK: maxuw
  %res = atomicrmw umax i32 *%src, i32 %b seq_cst
  ret i32 %res
}

define i64 @f64min(i64 *%src, i64 %b) {
; CHECK-LABEL: f64min:
; CHECK: mind
  %res = atomicrmw min i64 *%src, i64 %b seq_cst
  ret i64 %res
}

define i64 @f64max(i64 *%src, i64 %b) {
; CHECK-LABEL: f64max:
; CHECK: maxd
  %res = atomicrmw max i64 *%src, i64 %b seq_cst
  ret i64 %res
}

define i64 @f64umin(i64 *%src, i64 %b) {
; CHECK-LABEL: f64umin:
; CHECK: minud
  %res = atomicrmw umin i64 *%src, i64 %b seq_cst
  ret i64 %res
}

define i64 @f64umax(i64 *%src, i64 %b) {
; CHECK-LABEL: f64umax:
; CHECK: maxud
  %res = atomicrmw umax i64 *%src, i64 %b seq_cst
  ret i64 %res
}
