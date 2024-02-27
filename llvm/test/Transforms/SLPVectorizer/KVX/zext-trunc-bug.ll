; This not failing is enough
; RUN: opt -mcpu=kv3-1 -passes=loop-vectorize --disable-symbolication -S %s
; RUN: opt -mcpu=kv3-2 -passes=loop-vectorize --disable-symbolication -S %s

; RUN: opt -mcpu=kv3-1 -passes=slp-vectorizer --disable-symbolication -S %s
; RUN: opt -mcpu=kv3-2 -passes=slp-vectorizer --disable-symbolication -S %s

; RUN: opt -mcpu=kv3-1 -passes=aggressive-instcombine --disable-symbolication -S %s
; RUN: opt -mcpu=kv3-2 -passes=aggressive-instcombine --disable-symbolication -S %s

target triple = "kvx-kalray-cos"

@b = global i32 0
@a = global i32 0

define i32 @c() {
entry:
  %0 = load i32, ptr @b
  %conv = trunc i32 %0 to i16
  %sext = shl i32 %0, 16
  %conv1 = ashr exact i32 %sext, 16
  %a.promoted = load i32, ptr @a
  br label %for.cond

for.cond:
  %add2 = phi i32 [ %a.promoted, %entry ], [ %add.7, %for.cond ]
  %rem = srem i32 %add2, 2
  %idxprom = sext i32 %rem to i64
  %arrayidx = getelementptr inbounds i16, ptr @c, i64 %idxprom
  store i16 %conv, ptr %arrayidx
  %add = add nsw i32 %conv1, %add2
  %rem.1 = srem i32 %add, 2
  %idxprom.1 = sext i32 %rem.1 to i64
  %arrayidx.1 = getelementptr inbounds i16, ptr @c, i64 %idxprom.1
  store i16 %conv, ptr %arrayidx.1
  %add.1 = add nsw i32 %conv1, %add
  %rem.2 = srem i32 %add.1, 2
  %idxprom.2 = sext i32 %rem.2 to i64
  %arrayidx.2 = getelementptr inbounds i16, ptr @c, i64 %idxprom.2
  store i16 %conv, ptr %arrayidx.2
  %add.2 = add nsw i32 %conv1, %add.1
  %rem.3 = srem i32 %add.2, 2
  %idxprom.3 = sext i32 %rem.3 to i64
  %arrayidx.3 = getelementptr inbounds i16, ptr @c, i64 %idxprom.3
  store i16 %conv, ptr %arrayidx.3
  %add.3 = add nsw i32 %conv1, %add.2
  %rem.4 = srem i32 %add.3, 2
  %idxprom.4 = sext i32 %rem.4 to i64
  %arrayidx.4 = getelementptr inbounds i16, ptr @c, i64 %idxprom.4
  store i16 %conv, ptr %arrayidx.4
  %add.4 = add nsw i32 %conv1, %add.3
  %rem.5 = srem i32 %add.4, 2
  %idxprom.5 = sext i32 %rem.5 to i64
  %arrayidx.5 = getelementptr inbounds i16, ptr @c, i64 %idxprom.5
  store i16 %conv, ptr %arrayidx.5
  %add.5 = add nsw i32 %conv1, %add.4
  %rem.6 = srem i32 %add.5, 2
  %idxprom.6 = sext i32 %rem.6 to i64
  %arrayidx.6 = getelementptr inbounds i16, ptr @c, i64 %idxprom.6
  store i16 %conv, ptr %arrayidx.6
  %add.6 = add nsw i32 %conv1, %add.5
  %rem.7 = srem i32 %add.6, 2
  %idxprom.7 = sext i32 %rem.7 to i64
  %arrayidx.7 = getelementptr inbounds i16, ptr @c, i64 %idxprom.7
  store i16 %conv, ptr %arrayidx.7
  %add.7 = add nsw i32 %conv1, %add.6
  br label %for.cond
}

@z = global ptr null
@c2 = global i32 0

define i32 @d() {
  %1 = load i32, ptr @a
  %2 = icmp eq i32 %1, 0
  br i1 %2, label %19, label %3

3:
  %4 = load ptr, ptr @z
  %5 = sext i32 %1 to i64
  br label %6

6:
  %7 = phi i64 [ %5, %3 ], [ %14, %6 ]
  %8 = phi i32 [ undef, %3 ], [ %13, %6 ]
  %9 = getelementptr inbounds i32, ptr %4, i64 %7
  %10 = load i32, ptr %9
  %11 = trunc i64 %7 to i32
  %12 = mul i32 %10, %11
  %13 = add i32 %12, %8
  %14 = add nsw i64 %7, 1
  %15 = trunc i64 %14 to i32
  store i32 %15, ptr @a
  %16 = icmp eq i32 %15, 0
  br i1 %16, label %17, label %6

17:
  %18 = phi i32 [ %13, %6 ]
  br label %19

19:
  %20 = phi i32 [ undef, %0 ], [ %18, %17 ]
  store i32 %20, ptr @c2
  ret i32 undef
}

@a3 = global float 0.000000e+00
@b3 = global i32 0

define i32 @agressiveinstcombine() {
  %1 = load float, ptr @a3
  %2 = fptosi float %1 to i32
  %3 = call i32 @llvm.smin.i32(i32 %2, i32 127)
  %4 = call i32 @llvm.smax.i32(i32 %3, i32 -128)
  store i32 %4, ptr @b3
  ret i32 undef
}

declare i32 @llvm.smin.i32(i32, i32)

declare i32 @llvm.smax.i32(i32, i32)

@bb = global i32 0, align 4
@zz = global ptr null, align 8

define i32 @foo() {
entry:
  %.pr = load i32, ptr @bb, align 4
  %tobool.not4 = icmp eq i32 %.pr, 0
  br i1 %tobool.not4, label %for.end, label %for.body.lr.ph

for.body.lr.ph:
  %0 = load ptr, ptr @zz, align 8
  %1 = sext i32 %.pr to i64
  br label %for.body

for.body:
  %indvars.iv = phi i64 [ %1, %for.body.lr.ph ], [ %indvars.iv.next, %for.body ]
  %c.05 = phi i32 [ undef, %for.body.lr.ph ], [ %spec.select, %for.body ]
  %arrayidx = getelementptr inbounds i32, ptr %0, i64 %indvars.iv
  %2 = load i32, ptr %arrayidx, align 4
  %tobool1.not = icmp ne i32 %2, 0
  %inc = zext i1 %tobool1.not to i32
  %spec.select = add nsw i32 %c.05, %inc
  %indvars.iv.next = add nsw i64 %indvars.iv, 1
  %3 = trunc i64 %indvars.iv.next to i32
  store i32 %3, ptr @bb, align 4
  %tobool.not = icmp eq i32 %3, 0
  br i1 %tobool.not, label %for.end.loopexit, label %for.body

for.end.loopexit:
  %spec.select.lcssa = phi i32 [ %spec.select, %for.body ]
  br label %for.end

for.end:
  %c.0.lcssa = phi i32 [ undef, %entry ], [ %spec.select.lcssa, %for.end.loopexit ]
  ret i32 %c.0.lcssa
}

define void @loopvecfail() {
entry:
  br label %for.body

for.body:                                         ; preds = %for.body, %entry
  %indvars.iv = phi i64 [ undef, %entry ], [ %indvars.iv.next, %for.body ]
  %c.05 = phi i32 [ undef, %entry ], [ %spec.select, %for.body ]
  %inc = zext i1 undef to i32
  %spec.select = add nsw i32 %c.05, %inc
  %indvars.iv.next = add nsw i64 %indvars.iv, 1
  %0 = trunc i64 %indvars.iv.next to i32
  %tobool.not = icmp eq i32 %0, 0
  br i1 %tobool.not, label %for.end.loopexit, label %for.body

for.end.loopexit:                                 ; preds = %for.body
  %spec.select.lcssa = phi i32 [ %spec.select, %for.body ]
  ret void
}

define i32 @slpfail() {
entry:
  %rem.1 = srem i32 undef, 2
  %idxprom.1 = sext i32 %rem.1 to i64
  %arrayidx.1 = getelementptr inbounds i16, ptr @c, i64 %idxprom.1
  %rem.6 = srem i32 undef, 2
  %idxprom.6 = sext i32 %rem.6 to i64
  %arrayidx.6 = getelementptr inbounds i16, ptr @c, i64 %idxprom.6
  unreachable
}

define fastcc void @Fax3Encode2DRow(ptr %rp) #0 {
entry:
  %idxprom = zext i32 undef to i64
  %arrayidx18 = getelementptr inbounds i8, ptr %rp, i64 %idxprom
  %idx.ext.i150 = sext i32 0 to i64
  %add.ptr.i151 = getelementptr inbounds i8, ptr %rp, i64 %idx.ext.i150
  unreachable
}

attributes #0 = { "stack-protector-buffer-size"="8" }
