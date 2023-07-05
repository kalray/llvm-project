; This not failing is enough
; RUN: opt -slp-vectorizer -S --disable-symbolication %s

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

