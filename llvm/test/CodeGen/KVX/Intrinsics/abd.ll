; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mcpu=kv3-1 -o - %s | FileCheck %s --check-prefixes=CHECK
; RUN: llc -mcpu=kv3-2 -o - %s | FileCheck %s --check-prefixes=CHECK
; RUN: clang -march=kv3-1 -c -o /dev/null %s
; RUN: clang -march=kv3-2 -c -o /dev/null %s

target triple = "kvx-kalray-cos"

declare i32 @llvm.abs.i32(i32, i1 immarg)
declare i64 @llvm.abs.i64(i64, i1 immarg)

define i64 @abdd_rr(i64 %a, i64 %b) {
; CHECK-LABEL: abdd_rr:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    abdd $r0 = $r1, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %sub = sub nsw i64 %a, %b
  %0 = tail call i64 @llvm.abs.i64(i64 %sub, i1 true)
  ret i64 %0
}

define i64 @abdd_ri10(i64 %0) {
; CHECK-LABEL: abdd_ri10:
; CHECK:       # %bb.0:
; CHECK-NEXT:    abdd $r0 = $r0, 15
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
  %2 = sub nsw i64 15, %0
  %3 = tail call i64 @llvm.abs.i64(i64 %2, i1 true)
  ret i64 %3
}

define i64 @abdd_ri37(i64 %0) {
; CHECK-LABEL: abdd_ri37:
; CHECK:       # %bb.0:
; CHECK-NEXT:    abdd $r0 = $r0, 0xfffffff317c6324c
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
  %2 = sub nsw i64 -55435709876, %0
  %3 = tail call i64 @llvm.abs.i64(i64 %2, i1 true)
  ret i64 %3
}

define i64 @abdd_ri64(i64 %0) {
; CHECK-LABEL: abdd_ri64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    abdd $r0 = $r0, 0x3f63879cfe5905b4
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
  %2 = sub nsw i64 4567643555435709876, %0
  %3 = tail call i64 @llvm.abs.i64(i64 %2, i1 true)
  ret i64 %3
}

define i32 @abdw_rr(i32 %a, i32 %b) {
; CHECK-LABEL: abdw_rr:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    abdw $r0 = $r1, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %sub = sub nsw i32 %a, %b
  %0 = tail call i32 @llvm.abs.i32(i32 %sub, i1 true)
  ret i32 %0
}

define i32 @abdw_ri10(i32 %0) {
; CHECK-LABEL: abdw_ri10:
; CHECK:       # %bb.0:
; CHECK-NEXT:    abdw $r0 = $r0, 15
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
  %2 = sub nsw i32 15, %0
  %3 = tail call i32 @llvm.abs.i32(i32 %2, i1 true)
  ret i32 %3
}

define i32 @abdw_ri37(i32 %0) {
; CHECK-LABEL: abdw_ri37:
; CHECK:       # %bb.0:
; CHECK-NEXT:    abdw $r0 = $r0, 0xb593d1d6
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
  %2 = sub nsw i32 -5543570986, %0
  %3 = tail call i32 @llvm.abs.i32(i32 %2, i1 true)
  ret i32 %3
}

