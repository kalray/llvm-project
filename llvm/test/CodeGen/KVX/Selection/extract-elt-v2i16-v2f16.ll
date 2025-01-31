; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -o - %s -O2 | FileCheck %s --check-prefixes=CHECK
; RUN: llc -mcpu=kv3-2 -o - %s -O2 | FileCheck %s --check-prefixes=CHECK
; RUN: clang -O2 -c -o /dev/null %s
; RUN: clang -O2 -march=kv3-2 -c -o /dev/null %s

target triple = "kvx-kalray-cos"

define i64 @ext_v2i16_0(<2 x i16> %x, i64 %y) {
; CHECK-LABEL: ext_v2i16_0:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sxhd $r0 = $r0
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    addwd $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 1)
entry:
  %vecext = extractelement <2 x i16> %x, i32 0
  %conv = sext i16 %vecext to i64
  %add = add nsw i64 %conv, %y
  ret i64 %add
}

define i64 @ext_v2i16_1(<2 x i16> %x, i64 %y) {
; CHECK-LABEL: ext_v2i16_1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    extfs $r0 = $r0, 31, 16
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    addwd $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 1)
entry:
  %vecext = extractelement <2 x i16> %x, i32 1
  %conv = sext i16 %vecext to i64
  %add = add nsw i64 %conv, %y
  ret i64 %add
}

define i16 @ext_v2i16_s_0(<2 x i16> %x) {
; CHECK-LABEL: ext_v2i16_s_0:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    zxhd $r0 = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %vecext = extractelement <2 x i16> %x, i32 0
  ret i16 %vecext
}

define i16 @ext_v2i16_s_1(<2 x i16> %x) {
; CHECK-LABEL: ext_v2i16_s_1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    srlw $r0 = $r0, 16
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %vecext = extractelement <2 x i16> %x, i32 1
  ret i16 %vecext
}

define i16 @ext_v2i16_us_0(<2 x i16> %x) {
; CHECK-LABEL: ext_v2i16_us_0:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    zxhd $r0 = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %vecext = extractelement <2 x i16> %x, i32 0
  ret i16 %vecext
}

define i16 @ext_v2i16_us_1(<2 x i16> %x) {
; CHECK-LABEL: ext_v2i16_us_1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    srlw $r0 = $r0, 16
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %vecext = extractelement <2 x i16> %x, i32 1
  ret i16 %vecext
}

define half @ext_v2f16_0(<2 x half> %x) {
; CHECK-LABEL: ext_v2f16_0:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %vecext = extractelement <2 x half> %x, i32 0
  ret half %vecext
}

define half @ext_v2f16_1(<2 x half> %x) {
; CHECK-LABEL: ext_v2f16_1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    srlw $r0 = $r0, 16
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
entry:
  %vecext = extractelement <2 x half> %x, i32 1
  ret half %vecext
}
