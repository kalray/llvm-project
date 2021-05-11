; RUN: opt < %s -ajt -S | FileCheck %s

; Check unfolding of select instructions.
;
; '%state.13' is a phi-function using values from select instructions.
; It also has incoming constants and values from other phi-functions.
; Select instructions '%.' and '%.1' must be found and unfolded.
; A select instruction '%.2' must not be unfolded because one operand is not
; a constant.

; CHECK: select i1 %v16
; CHECK: select.unfold:
; CHECK: select.unfold1:

target datalayout = "e-m:e-p:32:32-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "thumbv8m.main-arm-none-eabi"

; Function Attrs: norecurse nounwind
define hidden arm_aapcs_vfpcc i32 @core_state_transition(i8** nocapture %instr, i32* nocapture %transition_count) local_unnamed_addr #0 {
entry:
  %0 = load i8*, i8** %instr, align 4
  %1 = load i8, i8* %0, align 1
  %tobool15 = icmp eq i8 %1, 0
  br i1 %tobool15, label %for.end, label %for.body.lr.ph

for.body.lr.ph:                                   ; preds = %entry
  %arrayidx36 = getelementptr inbounds i32, i32* %transition_count, i32 2
  br label %for.body

for.body:                                         ; preds = %for.body.lr.ph, %for.inc
  %2 = phi i8 [ %1, %for.body.lr.ph ], [ %v18, %for.inc ]
  %state.017 = phi i32 [ 0, %for.body.lr.ph ], [ %state.13, %for.inc ]
  %str.016 = phi i8* [ %0, %for.body.lr.ph ], [ %incdec.ptr109, %for.inc ]
  %cmp3 = icmp eq i8 %2, 44
  br i1 %cmp3, label %if.then, label %if.end

if.then:                                          ; preds = %for.body
  %state.017.lcssa = phi i32 [ %state.017, %for.body ]
  %str.016.lcssa = phi i8* [ %str.016, %for.body ]
  %incdec.ptr = getelementptr inbounds i8, i8* %str.016.lcssa, i32 1
  br label %for.end

if.end:                                           ; preds = %for.body
  switch i32 %state.017, label %for.inc [
    i32 0, label %sw.bb
    i32 2, label %sw.bb25
    i32 4, label %sw.bb43
    i32 5, label %sw.bb58
    i32 3, label %sw.bb77
    i32 6, label %sw.bb92
    i32 7, label %sw.bb102
  ]

sw.bb:                                            ; preds = %if.end
  %c.off.i = add i8 %2, -48
  %3 = icmp ugt i8 %c.off.i, 9
  br i1 %3, label %if.else, label %if.end22

if.else:                                          ; preds = %sw.bb
  switch i8 %2, label %if.else19 [
    i8 43, label %if.end22
    i8 45, label %if.end22
    i8 46, label %if.end22.fold.split
  ]

if.else19:                                        ; preds = %if.else
  br label %if.end22

if.end22.fold.split:                              ; preds = %if.else
  br label %if.end22

if.end22:                                         ; preds = %if.else, %if.else, %if.end22.fold.split, %if.else19, %sw.bb
  %state.3 = phi i32 [ 4, %sw.bb ], [ 2, %if.else ], [ 1, %if.else19 ], [ 2, %if.else ], [ 5, %if.end22.fold.split ]
  br label %for.inc

sw.bb25:                                          ; preds = %if.end
  %c.off.i10 = add i8 %2, -48
  %v6 = icmp ugt i8 %c.off.i10, 9
  br i1 %v6, label %if.else31, label %if.then28

if.then28:                                        ; preds = %sw.bb25
  br label %for.inc

if.else31:                                        ; preds = %sw.bb25
  %cmp33 = icmp eq i8 %2, 46
  %v8 = load i32, i32* %arrayidx36, align 4
  %inc37 = add i32 %v8, 1
  store i32 %inc37, i32* %arrayidx36, align 4
  %. = select i1 %cmp33, i32 5, i32 1
  br label %for.inc

sw.bb43:                                          ; preds = %if.end
  %cmp45 = icmp eq i8 %2, 46
  br i1 %cmp45, label %if.then47, label %if.else50

if.then47:                                        ; preds = %sw.bb43
  br label %for.inc

if.else50:                                        ; preds = %sw.bb43
  %c.off.i8 = add i8 %2, -48
  %v10 = icmp ugt i8 %c.off.i8, 9
  br i1 %v10, label %for.inc.thread, label %for.inc

sw.bb58:                                          ; preds = %if.end
  switch i8 %2, label %if.else69 [
    i8 69, label %if.then66
    i8 101, label %if.then66
  ]

if.then66:                                        ; preds = %sw.bb58, %sw.bb58
  br label %for.inc

if.else69:                                        ; preds = %sw.bb58
  %c.off.i6 = add i8 %2, -48
  %v12 = icmp ugt i8 %c.off.i6, 9
  br i1 %v12, label %for.inc.thread, label %for.inc

sw.bb77:                                          ; preds = %if.end
  switch i8 %2, label %for.inc.thread [
    i8 43, label %if.then85
    i8 45, label %if.then85
  ]

if.then85:                                        ; preds = %sw.bb77, %sw.bb77
  br label %for.inc

sw.bb92:                                          ; preds = %if.end
  %c.off.i4 = add i8 %2, -48
  %v14 = icmp ugt i8 %c.off.i4, 9
  %.1 = select i1 %v14, i32 1, i32 7
  br label %for.inc

sw.bb102:                                         ; preds = %if.end
  %c.off.i2 = add i8 %2, -48
  %v16 = icmp ugt i8 %c.off.i2, 9
  %v17 = load i32, i32* %arrayidx36, align 4
  %.2 = select i1 %v16, i32 %v17, i32 7
  br i1 %v16, label %for.inc.thread, label %for.inc

for.inc.thread:                                   ; preds = %if.else50, %sw.bb102, %sw.bb77, %if.else69
  br label %for.end

for.inc:                                          ; preds = %sw.bb92, %if.else31, %if.end22, %if.then28, %if.else50, %if.then47, %if.else69, %if.then66, %if.then85, %sw.bb102, %if.end
  %state.13 = phi i32 [ %state.3, %if.end22 ], [ 4, %if.then28 ], [ 5, %if.then47 ], [ 4, %if.else50 ], [ 3, %if.then66 ], [ 5, %if.else69 ], [ 6, %if.then85 ], [ %.2, %sw.bb102 ], [ %state.017, %if.end ], [ %., %if.else31 ], [ %.1, %sw.bb92 ]
  %incdec.ptr109 = getelementptr inbounds i8, i8* %str.016, i32 1
  %v18 = load i8, i8* %incdec.ptr109, align 1
  %tobool = icmp ne i8 %v18, 0
  %cmp = icmp ne i32 %state.13, 1
  %or.cond = and i1 %cmp, %tobool
  br i1 %or.cond, label %for.body, label %for.end.loopexit

for.end.loopexit:                                 ; preds = %for.inc
  %state.13.lcssa = phi i32 [ %state.13, %for.inc ]
  br label %for.end

for.end:                                          ; preds = %for.end.loopexit, %for.inc.thread, %entry, %if.then
  %state.013 = phi i32 [ %state.017.lcssa, %if.then ], [ 0, %entry ], [ 1, %for.inc.thread ], [ %state.13.lcssa, %for.end.loopexit ]
  ret i32 %state.013
}

attributes #0 = { norecurse nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "denormal-fp-math"="preserve-sign" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="true" "no-jump-tables"="false" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m33" "target-features"="+d16,+dsp,+fp-armv8,+fp-only-sp,+hwdiv,+thumb-mode,-crc,-crypto,-dotprod,-fullfp16,-hwdiv-arm,-neon,-ras" "unsafe-fp-math"="false" "use-soft-float"="false" }

