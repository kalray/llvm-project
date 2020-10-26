; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -O2 | FileCheck %s
target triple = "kvx-kalray-cos"

define i64 @f1(i64 %a, i64 %b){
; CHECK-LABEL: f1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addx2d $r0 = $r1, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %shl = shl i64 %b, 1
  %add = add nsw i64 %shl, %a
  ret i64 %add
}

define i64 @f2(i64 %a, i64 %b){
; CHECK-LABEL: f2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addx2d $r0 = $r1, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %shl = shl i64 %b, 1
  %add = add nsw i64 %shl, %a
  ret i64 %add
}

define i32 @f3(i32 %a, i32 %b){
; CHECK-LABEL: f3:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addx2w $r0 = $r1, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %shl = shl i32 %b, 1
  %add = add nsw i32 %shl, %a
  ret i32 %add
}

define i32 @f4(i32 %a, i32 %b){
; CHECK-LABEL: f4:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addx2w $r0 = $r1, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %shl = shl i32 %b, 1
  %add = add nsw i32 %shl, %a
  ret i32 %add
}

define i64 @f5(i64 %a, i32 %b){
; CHECK-LABEL: f5:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addx2uwd $r0 = $r1, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %shl = shl i32 %b, 1
  %conv = zext i32 %shl to i64
  %add = add nsw i64 %conv, %a
  ret i64 %add
}

define i64 @f6(i64 %a, i32 %b){
; CHECK-LABEL: f6:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addx2uwd $r0 = $r1, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %shl = shl i32 %b, 1
  %conv = zext i32 %shl to i64
  %add = add nsw i64 %conv, %a
  ret i64 %add
}

define i64 @f7(i64 %a, i32 %b){
; CHECK-LABEL: f7:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addx2wd $r0 = $r1, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %shl = shl i32 %b, 1
  %conv = sext i32 %shl to i64
  %add = add nsw i64 %conv, %a
  ret i64 %add
}

define i64 @f8(i64 %a, i32 %b){
; CHECK-LABEL: f8:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addx2wd $r0 = $r1, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %shl = shl i32 %b, 1
  %conv = sext i32 %shl to i64
  %add = add nsw i64 %conv, %a
  ret i64 %add
}

define i64 @f1imm(i64 %b){
; CHECK-LABEL: f1imm:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    make $r1 = 0x2dfdc1c35
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addx2d $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %shl = shl i64 %b, 1
  %add = add nsw i64 %shl, 12345678901
  ret i64 %add
}

define i64 @f2imm(i64 %b){
; CHECK-LABEL: f2imm:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    make $r1 = 0x2dfdc1c35
; CHECK-NEXT:    ;;
; CHECK-NEXT:    addx2d $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %shl = shl i64 %b, 1
  %add = add nsw i64 %shl, 12345678901
  ret i64 %add
}

define i32 @f3imm(i32 %b){
; CHECK-LABEL: f3imm:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addx2w $r0 = $r0, 0xffffffffffffa460
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %shl = shl i32 %b, 1
  %add = add nsw i32 %shl, -23456
  ret i32 %add
}

define i32 @f4imm(i32 %b){
; CHECK-LABEL: f4imm:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addx2w $r0 = $r0, 0xffffffffffffa460
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %shl = shl i32 %b, 1
  %sub = add nsw i32 %shl, -23456
  ret i32 %sub
}

define i64 @f5imm(i32 %b){
; CHECK-LABEL: f5imm:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addx2uwd $r0 = $r0, 0x1e240
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %shl = shl i32 %b, 1
  %conv = zext i32 %shl to i64
  %add = add nuw nsw i64 %conv, 123456
  ret i64 %add
}

define i64 @f6imm(i32 %b){
; CHECK-LABEL: f6imm:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addx2uwd $r0 = $r0, 0x1e240
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %shl = shl i32 %b, 1
  %conv = zext i32 %shl to i64
  %add = add nuw nsw i64 %conv, 123456
  ret i64 %add
}

define i64 @f7imm(i32 %b){
; CHECK-LABEL: f7imm:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addx2wd $r0 = $r0, 0xffffffffffffa460
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %shl = shl i32 %b, 1
  %conv = sext i32 %shl to i64
  %add = add nsw i64 %conv, -23456
  ret i64 %add
}

define i64 @f8imm(i32 %b){
; CHECK-LABEL: f8imm:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addx2wd $r0 = $r0, 0xffffffffffffa460
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %shl = shl i32 %b, 1
  %conv = sext i32 %shl to i64
  %sub = add nsw i64 %conv, -23456
  ret i64 %sub
}

