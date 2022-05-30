; RUN: llc -O2 -o - %s | FileCheck --check-prefixes=CHECK,ALL %s
; RUN: llc -O2 -relocation-model=pic -o - %s | FileCheck --check-prefixes=PIC,ALL %s

target triple = "kvx-kalray-cos"

define void @f(i32* nocapture %x, i32 %state) {
; ALL-LABEL: f:
; ALL:       # %bb.0: # %entry
; ALL-NEXT:    compw.gtu $r2 = $r1, 8
; ALL-NEXT:    ;;
; ALL-NEXT:    cb.odd $r2 ? .LBB0_11
; ALL-NEXT:    ;;
; ALL-NEXT:  # %bb.1: # %entry
; ALL-NEXT:    zxwd $r1 = $r1

; CHECK-NEXT:    make $r2 = .LJTI0_0
; PIC-NEXT:     pcrel $r2 = @pcrel( .LJTI0_0 )

; ALL-NEXT:    ;;

; PIC-NEXT:    lws.xs $r1 = $r1[$r2]
; PIC-NEXT:    ;;

; ALL-NEXT:    make $r1 = 1
; CHECK-NEXT:    ld.xs $r2 = $r1[$r2]
; PIC-NEXT:    addwd $r2 = $r1, $r2

; ALL-NEXT:    ;;
; ALL-NEXT:    igoto $r2
; ALL-NEXT:    ;;
; ALL-NEXT:  .LBB0_2: # %sw.bb1
; ALL-NEXT:    addd $r0 = $r0, 4
; ALL-NEXT:    make $r1 = 2
; ALL-NEXT:    goto .LBB0_10
; ALL-NEXT:    ;;
; ALL-NEXT:  .LBB0_3: # %sw.bb3
; ALL-NEXT:    addd $r0 = $r0, 8
; ALL-NEXT:    make $r1 = 3
; ALL-NEXT:    goto .LBB0_10
; ALL-NEXT:    ;;
; ALL-NEXT:  .LBB0_4: # %sw.bb6
; ALL-NEXT:    addd $r0 = $r0, 12
; ALL-NEXT:    make $r1 = 4
; ALL-NEXT:    goto .LBB0_10
; ALL-NEXT:    ;;
; ALL-NEXT:  .LBB0_5: # %sw.bb9
; ALL-NEXT:    addd $r0 = $r0, 16
; ALL-NEXT:    make $r1 = 5
; ALL-NEXT:    goto .LBB0_10
; ALL-NEXT:    ;;
; ALL-NEXT:  .LBB0_6: # %sw.bb12
; ALL-NEXT:    addd $r0 = $r0, 20
; ALL-NEXT:    make $r1 = 6
; ALL-NEXT:    goto .LBB0_10
; ALL-NEXT:    ;;
; ALL-NEXT:  .LBB0_7: # %sw.bb15
; ALL-NEXT:    addd $r0 = $r0, 24
; ALL-NEXT:    make $r1 = 7
; ALL-NEXT:    goto .LBB0_10
; ALL-NEXT:    ;;
; ALL-NEXT:  .LBB0_8: # %sw.bb18
; ALL-NEXT:    addd $r0 = $r0, 28
; ALL-NEXT:    make $r1 = 8
; ALL-NEXT:    goto .LBB0_10
; ALL-NEXT:    ;;
; ALL-NEXT:  .LBB0_9: # %sw.bb21
; ALL-NEXT:    addd $r0 = $r0, 32
; ALL-NEXT:    make $r1 = 9
; ALL-NEXT:    ;;
; ALL-NEXT:  .LBB0_10: # %sw.epilog.sink.split
; ALL-NEXT:    lwz $r2 = 0[$r0]
; ALL-NEXT:    ;;
; ALL-NEXT:    addw $r1 = $r2, $r1
; ALL-NEXT:    ;;
; ALL-NEXT:    sw 0[$r0] = $r1
; ALL-NEXT:    ;;
; ALL-NEXT:  .LBB0_11: # %sw.epilog
; ALL-NEXT:    ret
; ALL-NEXT:    ;;

; The jump-table:

; PIC: 	.p2align	2
; CHECK:  	.p2align	3
; ALL-NEXT: .LJTI0_0:

; CHECK-NEXT:	.8byte	.LBB0_10
; CHECK-NEXT:	.8byte	.LBB0_2
; CHECK-NEXT:	.8byte	.LBB0_3
; CHECK-NEXT:	.8byte	.LBB0_4
; CHECK-NEXT:	.8byte	.LBB0_5
; CHECK-NEXT:	.8byte	.LBB0_6
; CHECK-NEXT:	.8byte	.LBB0_7
; CHECK-NEXT:	.8byte	.LBB0_8
; CHECK-NEXT:	.8byte	.LBB0_9

; PIC-NEXT:	.long	.LBB0_10-.LJTI0_0
; PIC-NEXT:	.long	.LBB0_2-.LJTI0_0
; PIC-NEXT:	.long	.LBB0_3-.LJTI0_0
; PIC-NEXT:	.long	.LBB0_4-.LJTI0_0
; PIC-NEXT:	.long	.LBB0_5-.LJTI0_0
; PIC-NEXT:	.long	.LBB0_6-.LJTI0_0
; PIC-NEXT:	.long	.LBB0_7-.LJTI0_0
; PIC-NEXT:	.long	.LBB0_8-.LJTI0_0
; PIC-NEXT:	.long	.LBB0_9-.LJTI0_0

entry:
  switch i32 %state, label %sw.epilog [
    i32 0, label %sw.epilog.sink.split
    i32 1, label %sw.bb1
    i32 2, label %sw.bb3
    i32 3, label %sw.bb6
    i32 4, label %sw.bb9
    i32 5, label %sw.bb12
    i32 6, label %sw.bb15
    i32 7, label %sw.bb18
    i32 8, label %sw.bb21
  ]

sw.bb1:
  %arrayidx2 = getelementptr inbounds i32, i32* %x, i64 1
  br label %sw.epilog.sink.split

sw.bb3:
  %arrayidx4 = getelementptr inbounds i32, i32* %x, i64 2
  br label %sw.epilog.sink.split

sw.bb6:
  %arrayidx7 = getelementptr inbounds i32, i32* %x, i64 3
  br label %sw.epilog.sink.split

sw.bb9:
  %arrayidx10 = getelementptr inbounds i32, i32* %x, i64 4
  br label %sw.epilog.sink.split

sw.bb12:
  %arrayidx13 = getelementptr inbounds i32, i32* %x, i64 5
  br label %sw.epilog.sink.split

sw.bb15:
  %arrayidx16 = getelementptr inbounds i32, i32* %x, i64 6
  br label %sw.epilog.sink.split

sw.bb18:
  %arrayidx19 = getelementptr inbounds i32, i32* %x, i64 7
  br label %sw.epilog.sink.split

sw.bb21:
  %arrayidx22 = getelementptr inbounds i32, i32* %x, i64 8
  br label %sw.epilog.sink.split

sw.epilog.sink.split:
  %arrayidx22.sink33 = phi i32* [ %arrayidx22, %sw.bb21 ], [ %arrayidx19, %sw.bb18 ], [ %arrayidx16, %sw.bb15 ], [ %arrayidx13, %sw.bb12 ], [ %arrayidx10, %sw.bb9 ], [ %arrayidx7, %sw.bb6 ], [ %arrayidx4, %sw.bb3 ], [ %arrayidx2, %sw.bb1 ], [ %x, %entry ]
  %.sink32 = phi i32 [ 9, %sw.bb21 ], [ 8, %sw.bb18 ], [ 7, %sw.bb15 ], [ 6, %sw.bb12 ], [ 5, %sw.bb9 ], [ 4, %sw.bb6 ], [ 3, %sw.bb3 ], [ 2, %sw.bb1 ], [ 1, %entry ]
  %0 = load i32, i32* %arrayidx22.sink33, align 4
  %add23 = add nsw i32 %0, %.sink32
  store i32 %add23, i32* %arrayidx22.sink33, align 4
  br label %sw.epilog

sw.epilog:
  ret void
}
