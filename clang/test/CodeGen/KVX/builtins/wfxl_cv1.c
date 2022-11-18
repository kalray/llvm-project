// RUN: %clang_cc1 -target-cpu kv3-1 -triple kvx-kalray-cos -S -O2 -emit-llvm -o - %s | FileCheck %s

// CHECK-LABEL: @wfxl_1(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.wfx(metadata !2, i64 [[V:%.*]], i32 0)
// CHECK-NEXT:    ret void
//
void wfxl_1(long v) {
  __builtin_kvx_wfxl(1, v);
}

// CHECK-LABEL: @wfxl_2(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.wfx(metadata !3, i64 [[V:%.*]], i32 0)
// CHECK-NEXT:    ret void
//
void wfxl_2(long v) {
  __builtin_kvx_wfxl(2, v);
}

// CHECK-LABEL: @wfxl_4(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.wfx(metadata !4, i64 [[V:%.*]], i32 0)
// CHECK-NEXT:    ret void
//
void wfxl_4(long v) {
  __builtin_kvx_wfxl(4, v);
}

// CHECK-LABEL: @wfxl_5(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.wfx(metadata !5, i64 [[V:%.*]], i32 0)
// CHECK-NEXT:    ret void
//
void wfxl_5(long v) {
  __builtin_kvx_wfxl(5, v);
}

// CHECK-LABEL: @wfxl_10(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.wfx(metadata !6, i64 [[V:%.*]], i32 0)
// CHECK-NEXT:    ret void
//
void wfxl_10(long v) {
  __builtin_kvx_wfxl(10, v);
}

// CHECK-LABEL: @wfxl_11(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.wfx(metadata !7, i64 [[V:%.*]], i32 0)
// CHECK-NEXT:    ret void
//
void wfxl_11(long v) {
  __builtin_kvx_wfxl(11, v);
}

// CHECK-LABEL: @wfxl_12(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.wfx(metadata !8, i64 [[V:%.*]], i32 0)
// CHECK-NEXT:    ret void
//
void wfxl_12(long v) {
  __builtin_kvx_wfxl(12, v);
}

// CHECK-LABEL: @wfxl_18(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.wfx(metadata !9, i64 [[V:%.*]], i32 0)
// CHECK-NEXT:    ret void
//
void wfxl_18(long v) {
  __builtin_kvx_wfxl(18, v);
}

// CHECK-LABEL: @wfxl_25(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.wfx(metadata !10, i64 [[V:%.*]], i32 0)
// CHECK-NEXT:    ret void
//
void wfxl_25(long v) {
  __builtin_kvx_wfxl(25, v);
}

// CHECK-LABEL: @wfxl_26(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.wfx(metadata !11, i64 [[V:%.*]], i32 0)
// CHECK-NEXT:    ret void
//
void wfxl_26(long v) {
  __builtin_kvx_wfxl(26, v);
}

// CHECK-LABEL: @wfxl_27(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.wfx(metadata !12, i64 [[V:%.*]], i32 0)
// CHECK-NEXT:    ret void
//
void wfxl_27(long v) {
  __builtin_kvx_wfxl(27, v);
}

// CHECK-LABEL: @wfxl_28(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.wfx(metadata !13, i64 [[V:%.*]], i32 0)
// CHECK-NEXT:    ret void
//
void wfxl_28(long v) {
  __builtin_kvx_wfxl(28, v);
}

// CHECK-LABEL: @wfxl_29(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.wfx(metadata !14, i64 [[V:%.*]], i32 0)
// CHECK-NEXT:    ret void
//
void wfxl_29(long v) {
  __builtin_kvx_wfxl(29, v);
}

// CHECK-LABEL: @wfxl_30(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.wfx(metadata !15, i64 [[V:%.*]], i32 0)
// CHECK-NEXT:    ret void
//
void wfxl_30(long v) {
  __builtin_kvx_wfxl(30, v);
}

// CHECK-LABEL: @wfxl_40(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.wfx(metadata !16, i64 [[V:%.*]], i32 0)
// CHECK-NEXT:    ret void
//
void wfxl_40(long v) {
  __builtin_kvx_wfxl(40, v);
}

// CHECK-LABEL: @wfxl_45(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.wfx(metadata !17, i64 [[V:%.*]], i32 0)
// CHECK-NEXT:    ret void
//
void wfxl_45(long v) {
  __builtin_kvx_wfxl(45, v);
}

// CHECK-LABEL: @wfxl_46(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.wfx(metadata !18, i64 [[V:%.*]], i32 0)
// CHECK-NEXT:    ret void
//
void wfxl_46(long v) {
  __builtin_kvx_wfxl(46, v);
}

// CHECK-LABEL: @wfxl_84(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.wfx(metadata !19, i64 [[V:%.*]], i32 0)
// CHECK-NEXT:    ret void
//
void wfxl_84(long v) {
  __builtin_kvx_wfxl(84, v);
}

// CHECK-LABEL: @wfxl_85(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.wfx(metadata !20, i64 [[V:%.*]], i32 0)
// CHECK-NEXT:    ret void
//
void wfxl_85(long v) {
  __builtin_kvx_wfxl(85, v);
}

// CHECK-LABEL: @wfxl_86(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.wfx(metadata !21, i64 [[V:%.*]], i32 0)
// CHECK-NEXT:    ret void
//
void wfxl_86(long v) {
  __builtin_kvx_wfxl(86, v);
}

// CHECK-LABEL: @wfxl_87(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.wfx(metadata !22, i64 [[V:%.*]], i32 0)
// CHECK-NEXT:    ret void
//
void wfxl_87(long v) {
  __builtin_kvx_wfxl(87, v);
}

// CHECK-LABEL: @wfxl_96(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.wfx(metadata !23, i64 [[V:%.*]], i32 0)
// CHECK-NEXT:    ret void
//
void wfxl_96(long v) {
  __builtin_kvx_wfxl(96, v);
}

// CHECK-LABEL: @wfxl_97(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.wfx(metadata !24, i64 [[V:%.*]], i32 0)
// CHECK-NEXT:    ret void
//
void wfxl_97(long v) {
  __builtin_kvx_wfxl(97, v);
}

// CHECK-LABEL: @wfxl_98(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.wfx(metadata !25, i64 [[V:%.*]], i32 0)
// CHECK-NEXT:    ret void
//
void wfxl_98(long v) {
  __builtin_kvx_wfxl(98, v);
}

// CHECK-LABEL: @wfxl_99(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.wfx(metadata !26, i64 [[V:%.*]], i32 0)
// CHECK-NEXT:    ret void
//
void wfxl_99(long v) {
  __builtin_kvx_wfxl(99, v);
}

// CHECK-LABEL: @wfxl_100(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.wfx(metadata !27, i64 [[V:%.*]], i32 0)
// CHECK-NEXT:    ret void
//
void wfxl_100(long v) {
  __builtin_kvx_wfxl(100, v);
}

// CHECK-LABEL: @wfxl_101(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.wfx(metadata !28, i64 [[V:%.*]], i32 0)
// CHECK-NEXT:    ret void
//
void wfxl_101(long v) {
  __builtin_kvx_wfxl(101, v);
}

// CHECK-LABEL: @wfxl_132(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.wfx(metadata !29, i64 [[V:%.*]], i32 0)
// CHECK-NEXT:    ret void
//
void wfxl_132(long v) {
  __builtin_kvx_wfxl(132, v);
}

// CHECK-LABEL: @wfxl_148(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.wfx(metadata !30, i64 [[V:%.*]], i32 0)
// CHECK-NEXT:    ret void
//
void wfxl_148(long v) {
  __builtin_kvx_wfxl(148, v);
}

// CHECK: !2 = !{!"$ps"}
// CHECK-NEXT: !3 = !{!"$pcr"}
// CHECK-NEXT: !4 = !{!"$cs"}
// CHECK-NEXT: !5 = !{!"$csit"}
// CHECK-NEXT: !6 = !{!"$ipe"}
// CHECK-NEXT: !7 = !{!"$men"}
// CHECK-NEXT: !8 = !{!"$pmc"}
// CHECK-NEXT: !9 = !{!"$tcr"}
// CHECK-NEXT: !10 = !{!"$ile"}
// CHECK-NEXT: !11 = !{!"$ill"}
// CHECK-NEXT: !12 = !{!"$ilr"}
// CHECK-NEXT: !13 = !{!"$mmc"}
// CHECK-NEXT: !14 = !{!"$tel"}
// CHECK-NEXT: !15 = !{!"$teh"}
// CHECK-NEXT: !16 = !{!"$s40"}
// CHECK-NEXT: !17 = !{!"$mes"}
// CHECK-NEXT: !18 = !{!"$ws"}
// CHECK-NEXT: !19 = !{!"$es_pl0"}
// CHECK-NEXT: !20 = !{!"$es_pl1"}
// CHECK-NEXT: !21 = !{!"$es_pl2"}
// CHECK-NEXT: !22 = !{!"$es_pl3"}
// CHECK-NEXT: !23 = !{!"$syow"}
// CHECK-NEXT: !24 = !{!"$htow"}
// CHECK-NEXT: !25 = !{!"$itow"}
// CHECK-NEXT: !26 = !{!"$dow"}
// CHECK-NEXT: !27 = !{!"$mow"}
// CHECK-NEXT: !28 = !{!"$psow"}
// CHECK-NEXT: !29 = !{!"$sps"}
// CHECK-NEXT: !30 = !{!"$es"}