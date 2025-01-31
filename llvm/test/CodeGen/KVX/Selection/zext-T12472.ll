; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; llc -o - %s | FileCheck %s --implicit-check-not zxbd
; RUN: llc -o - %s -O2 | FileCheck %s

; RUN: clang -O2 -c -o /dev/null %s
target triple = "kvx-kalray-cos"

; The test ensures no regressions of useless zero_extend generation (see
; T12472).

define i32 @__strncmp(i8* nocapture readonly %s1, i8* nocapture readonly %s2, i32 %n){
; CHECK-LABEL: __strncmp:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cb.weqz $r2 ? .LBB0_8
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.1: # %land.rhs.preheader
; CHECK-NEXT:    lbz $r3 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    cb.weqz $r3 ? .LBB0_9
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.2: # %land.rhs.preheader
; CHECK-NEXT:    addw $r4 = $r2, -1
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    cb.weqz $r4 ? .LBB0_9
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.3: # %land.rhs.preheader
; CHECK-NEXT:    lbz $r4 = 0[$r1]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    compw.ne $r3 = $r3, $r4
; CHECK-NEXT:    ;; # (end cycle 3)
; CHECK-NEXT:    cb.odd $r3 ? .LBB0_9
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.4: # %if.end11.preheader
; CHECK-NEXT:    addw $r3 = $r2, -2
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:  .LBB0_5: # %if.end11
; CHECK-NEXT:    # =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    addd $r0 = $r0, 1
; CHECK-NEXT:    addd $r2 = $r1, 1
; CHECK-NEXT:    lbz $r4 = 1[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    cb.weqz $r4 ? .LBB0_10
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.6: # %if.end11
; CHECK-NEXT:    # in Loop: Header=BB0_5 Depth=1
; CHECK-NEXT:    cb.weqz $r3 ? .LBB0_10
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.7: # %if.end11
; CHECK-NEXT:    # in Loop: Header=BB0_5 Depth=1
; CHECK-NEXT:    lbz $r1 = 1[$r1]
; CHECK-NEXT:    addw $r3 = $r3, -1
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    copyd $r1 = $r2
; CHECK-NEXT:    compw.eq $r4 = $r4, $r1
; CHECK-NEXT:    ;; # (end cycle 3)
; CHECK-NEXT:    cb.odd $r4 ? .LBB0_5
; CHECK-NEXT:    ;;
; CHECK-NEXT:    goto .LBB0_10
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB0_8:
; CHECK-NEXT:    make $r0 = 0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:  .LBB0_9:
; CHECK-NEXT:    copyd $r2 = $r1
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:  .LBB0_10: # %while.end
; CHECK-NEXT:    lbz $r0 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    lbz $r1 = 0[$r2]
; CHECK-NEXT:    ;; # (end cycle 1)
; CHECK-NEXT:    sbfw $r0 = $r1, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 4)
entry:
  %cmp = icmp eq i32 %n, 0
  br i1 %cmp, label %return, label %land.rhs.preheader

land.rhs.preheader:                               ; preds = %entry
  %dec2731 = add nsw i32 %n, -1
  %0 = load i8, i8* %s1, align 1
  %1 = load i8, i8* %s2, align 1
  %cmp332 = icmp ne i8 %0, %1
  %cmp533 = icmp eq i32 %dec2731, 0
  %or.cond34 = or i1 %cmp533, %cmp332
  %cmp835 = icmp eq i8 %0, 0
  %or.cond2236 = or i1 %cmp835, %or.cond34
  br i1 %or.cond2236, label %while.end, label %if.end11

if.end11:                                         ; preds = %land.rhs.preheader, %if.end11
  %dec2739 = phi i32 [ %dec27, %if.end11 ], [ %dec2731, %land.rhs.preheader ]
  %s1.addr.02538 = phi i8* [ %incdec.ptr, %if.end11 ], [ %s1, %land.rhs.preheader ]
  %s2.addr.02637 = phi i8* [ %incdec.ptr12, %if.end11 ], [ %s2, %land.rhs.preheader ]
  %incdec.ptr = getelementptr inbounds i8, i8* %s1.addr.02538, i64 1
  %incdec.ptr12 = getelementptr inbounds i8, i8* %s2.addr.02637, i64 1
  %dec27 = add nsw i32 %dec2739, -1
  %2 = load i8, i8* %incdec.ptr, align 1
  %3 = load i8, i8* %incdec.ptr12, align 1
  %cmp3 = icmp ne i8 %2, %3
  %cmp5 = icmp eq i32 %dec27, 0
  %or.cond = or i1 %cmp5, %cmp3
  %cmp8 = icmp eq i8 %2, 0
  %or.cond22 = or i1 %cmp8, %or.cond
  br i1 %or.cond22, label %while.end, label %if.end11

while.end:                                        ; preds = %if.end11, %land.rhs.preheader
  %s2.addr.026.lcssa = phi i8* [ %s2, %land.rhs.preheader ], [ %incdec.ptr12, %if.end11 ]
  %s1.addr.025.lcssa = phi i8* [ %s1, %land.rhs.preheader ], [ %incdec.ptr, %if.end11 ]
  %4 = load i8, i8* %s1.addr.025.lcssa, align 1
  %conv13 = zext i8 %4 to i32
  %5 = load i8, i8* %s2.addr.026.lcssa, align 1
  %conv14 = zext i8 %5 to i32
  %sub = sub nsw i32 %conv13, %conv14
  br label %return

return:                                           ; preds = %entry, %while.end
  %retval.0 = phi i32 [ %sub, %while.end ], [ 0, %entry ]
  ret i32 %retval.0
}
