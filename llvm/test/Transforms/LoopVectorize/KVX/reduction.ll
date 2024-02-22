; Passing the test ensures the TTI is not requested to cost a bad cast instruction in extending reductions.
; RUN: opt -S -passes=loop-vectorize < %s

target datalayout = "e-S256-p:64:64-i1:8-i8:8-i16:16-i32:32-i64:64-v64:64-v128:128-v256:256-v512:256-v1024:256-f16:16-f32:32-f64:64-a:0:64-m:e-n32:64"
target triple = "kvx-kalray-cos"

define void @e() local_unnamed_addr #0 {
.lr.ph.preheader:
  br label %.lr.ph

.lr.ph:
  %0 = phi ptr [ %1, %.lr.ph ], [ null, %.lr.ph.preheader ]
  %.04 = phi i32 [ %5, %.lr.ph ], [ undef, %.lr.ph.preheader ]
  %1 = getelementptr inbounds i8, ptr %0, i64 -1
  %2 = sext i8 undef to i32
  %3 = sext i8 undef to i32
  %4 = mul nsw i32 %3, %2
  %5 = add i32 %4, %.04
  %.not = icmp ult ptr %1, undef
  br i1 %.not, label %._crit_edge.loopexit, label %.lr.ph, !llvm.loop !0

._crit_edge.loopexit:                             ; preds = %.lr.ph
  %.lcssa = phi i32 [ %5, %.lr.ph ]
  ret void
}

attributes #0 = { "target-cpu"="kv3-2" }

!0 = distinct !{!0, !1}
!1 = !{!"llvm.loop.mustprogress"}
