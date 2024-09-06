// RUN: %clang_cc1 -target-cpu kv3-1 -triple kvx-kalray-cos -O2 -emit-llvm -o - %s | FileCheck %s

// CHECK-LABEL: @set_1(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !2, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_1(long v) {
  __builtin_kvx_set(1, v);
}

// CHECK-LABEL: @set_2(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !3, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_2(long v) {
  __builtin_kvx_set(2, v);
}

// CHECK-LABEL: @set_3(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !4, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_3(long v) {
  __builtin_kvx_set(3, v);
}

// CHECK-LABEL: @set_4(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !5, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_4(long v) {
  __builtin_kvx_set(4, v);
}

// CHECK-LABEL: @set_5(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !6, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_5(long v) {
  __builtin_kvx_set(5, v);
}

// CHECK-LABEL: @set_6(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !7, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_6(long v) {
  __builtin_kvx_set(6, v);
}

// CHECK-LABEL: @set_7(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !8, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_7(long v) {
  __builtin_kvx_set(7, v);
}

// CHECK-LABEL: @set_8(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !9, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_8(long v) {
  __builtin_kvx_set(8, v);
}

// CHECK-LABEL: @set_9(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !10, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_9(long v) {
  __builtin_kvx_set(9, v);
}

// CHECK-LABEL: @set_10(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !11, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_10(long v) {
  __builtin_kvx_set(10, v);
}

// CHECK-LABEL: @set_11(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !12, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_11(long v) {
  __builtin_kvx_set(11, v);
}

// CHECK-LABEL: @set_12(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !13, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_12(long v) {
  __builtin_kvx_set(12, v);
}

// CHECK-LABEL: @set_13(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !14, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_13(long v) {
  __builtin_kvx_set(13, v);
}

// CHECK-LABEL: @set_14(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !15, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_14(long v) {
  __builtin_kvx_set(14, v);
}

// CHECK-LABEL: @set_15(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !16, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_15(long v) {
  __builtin_kvx_set(15, v);
}

// CHECK-LABEL: @set_16(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !17, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_16(long v) {
  __builtin_kvx_set(16, v);
}

// CHECK-LABEL: @set_17(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !18, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_17(long v) {
  __builtin_kvx_set(17, v);
}

// CHECK-LABEL: @set_18(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !19, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_18(long v) {
  __builtin_kvx_set(18, v);
}

// CHECK-LABEL: @set_19(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !20, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_19(long v) {
  __builtin_kvx_set(19, v);
}

// CHECK-LABEL: @set_20(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !21, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_20(long v) {
  __builtin_kvx_set(20, v);
}

// CHECK-LABEL: @set_21(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !22, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_21(long v) {
  __builtin_kvx_set(21, v);
}

// CHECK-LABEL: @set_22(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !23, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_22(long v) {
  __builtin_kvx_set(22, v);
}

// CHECK-LABEL: @set_23(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !24, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_23(long v) {
  __builtin_kvx_set(23, v);
}

// CHECK-LABEL: @set_24(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !25, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_24(long v) {
  __builtin_kvx_set(24, v);
}

// CHECK-LABEL: @set_25(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !26, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_25(long v) {
  __builtin_kvx_set(25, v);
}

// CHECK-LABEL: @set_26(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !27, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_26(long v) {
  __builtin_kvx_set(26, v);
}

// CHECK-LABEL: @set_27(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !28, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_27(long v) {
  __builtin_kvx_set(27, v);
}

// CHECK-LABEL: @set_28(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !29, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_28(long v) {
  __builtin_kvx_set(28, v);
}

// CHECK-LABEL: @set_29(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !30, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_29(long v) {
  __builtin_kvx_set(29, v);
}

// CHECK-LABEL: @set_30(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !31, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_30(long v) {
  __builtin_kvx_set(30, v);
}

// CHECK-LABEL: @set_40(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !32, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_40(long v) {
  __builtin_kvx_set(40, v);
}

// CHECK-LABEL: @set_41(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !33, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_41(long v) {
  __builtin_kvx_set(41, v);
}

// CHECK-LABEL: @set_42(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !34, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_42(long v) {
  __builtin_kvx_set(42, v);
}

// CHECK-LABEL: @set_43(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !35, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_43(long v) {
  __builtin_kvx_set(43, v);
}

// CHECK-LABEL: @set_44(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !36, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_44(long v) {
  __builtin_kvx_set(44, v);
}

// CHECK-LABEL: @set_45(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !37, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_45(long v) {
  __builtin_kvx_set(45, v);
}

// CHECK-LABEL: @set_46(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !38, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_46(long v) {
  __builtin_kvx_set(46, v);
}

// CHECK-LABEL: @set_64(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !39, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_64(long v) {
  __builtin_kvx_set(64, v);
}

// CHECK-LABEL: @set_65(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !40, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_65(long v) {
  __builtin_kvx_set(65, v);
}

// CHECK-LABEL: @set_66(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !41, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_66(long v) {
  __builtin_kvx_set(66, v);
}

// CHECK-LABEL: @set_67(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !42, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_67(long v) {
  __builtin_kvx_set(67, v);
}

// CHECK-LABEL: @set_72(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !43, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_72(long v) {
  __builtin_kvx_set(72, v);
}

// CHECK-LABEL: @set_73(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !44, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_73(long v) {
  __builtin_kvx_set(73, v);
}

// CHECK-LABEL: @set_74(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !45, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_74(long v) {
  __builtin_kvx_set(74, v);
}

// CHECK-LABEL: @set_75(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !46, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_75(long v) {
  __builtin_kvx_set(75, v);
}

// CHECK-LABEL: @set_76(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !47, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_76(long v) {
  __builtin_kvx_set(76, v);
}

// CHECK-LABEL: @set_77(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !48, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_77(long v) {
  __builtin_kvx_set(77, v);
}

// CHECK-LABEL: @set_78(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !49, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_78(long v) {
  __builtin_kvx_set(78, v);
}

// CHECK-LABEL: @set_79(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !50, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_79(long v) {
  __builtin_kvx_set(79, v);
}

// CHECK-LABEL: @set_80(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !51, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_80(long v) {
  __builtin_kvx_set(80, v);
}

// CHECK-LABEL: @set_81(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !52, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_81(long v) {
  __builtin_kvx_set(81, v);
}

// CHECK-LABEL: @set_82(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !53, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_82(long v) {
  __builtin_kvx_set(82, v);
}

// CHECK-LABEL: @set_83(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !54, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_83(long v) {
  __builtin_kvx_set(83, v);
}

// CHECK-LABEL: @set_84(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !55, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_84(long v) {
  __builtin_kvx_set(84, v);
}

// CHECK-LABEL: @set_85(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !56, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_85(long v) {
  __builtin_kvx_set(85, v);
}

// CHECK-LABEL: @set_86(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !57, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_86(long v) {
  __builtin_kvx_set(86, v);
}

// CHECK-LABEL: @set_87(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !58, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_87(long v) {
  __builtin_kvx_set(87, v);
}

// CHECK-LABEL: @set_96(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !59, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_96(long v) {
  __builtin_kvx_set(96, v);
}

// CHECK-LABEL: @set_97(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !60, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_97(long v) {
  __builtin_kvx_set(97, v);
}

// CHECK-LABEL: @set_98(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !61, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_98(long v) {
  __builtin_kvx_set(98, v);
}

// CHECK-LABEL: @set_99(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !62, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_99(long v) {
  __builtin_kvx_set(99, v);
}

// CHECK-LABEL: @set_100(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !63, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_100(long v) {
  __builtin_kvx_set(100, v);
}

// CHECK-LABEL: @set_101(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !64, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_101(long v) {
  __builtin_kvx_set(101, v);
}

// CHECK-LABEL: @set_128(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !65, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_128(long v) {
  __builtin_kvx_set(128, v);
}

// CHECK-LABEL: @set_132(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !66, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_132(long v) {
  __builtin_kvx_set(132, v);
}

// CHECK-LABEL: @set_136(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !67, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_136(long v) {
  __builtin_kvx_set(136, v);
}

// CHECK-LABEL: @set_140(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !68, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_140(long v) {
  __builtin_kvx_set(140, v);
}

// CHECK-LABEL: @set_144(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !69, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_144(long v) {
  __builtin_kvx_set(144, v);
}

// CHECK-LABEL: @set_148(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !70, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_148(long v) {
  __builtin_kvx_set(148, v);
}

// CHECK: !2 = !{!"$ps"}
// CHECK-NEXT: !3 = !{!"$pcr"}
// CHECK-NEXT: !4 = !{!"$ra"}
// CHECK-NEXT: !5 = !{!"$cs"}
// CHECK-NEXT: !6 = !{!"$csit"}
// CHECK-NEXT: !7 = !{!"$aespc"}
// CHECK-NEXT: !8 = !{!"$ls"}
// CHECK-NEXT: !9 = !{!"$le"}
// CHECK-NEXT: !10 = !{!"$lc"}
// CHECK-NEXT: !11 = !{!"$ipe"}
// CHECK-NEXT: !12 = !{!"$men"}
// CHECK-NEXT: !13 = !{!"$pmc"}
// CHECK-NEXT: !14 = !{!"$pm0"}
// CHECK-NEXT: !15 = !{!"$pm1"}
// CHECK-NEXT: !16 = !{!"$pm2"}
// CHECK-NEXT: !17 = !{!"$pm3"}
// CHECK-NEXT: !18 = !{!"$pmsa"}
// CHECK-NEXT: !19 = !{!"$tcr"}
// CHECK-NEXT: !20 = !{!"$t0v"}
// CHECK-NEXT: !21 = !{!"$t1v"}
// CHECK-NEXT: !22 = !{!"$t0r"}
// CHECK-NEXT: !23 = !{!"$t1r"}
// CHECK-NEXT: !24 = !{!"$wdv"}
// CHECK-NEXT: !25 = !{!"$wdr"}
// CHECK-NEXT: !26 = !{!"$ile"}
// CHECK-NEXT: !27 = !{!"$ill"}
// CHECK-NEXT: !28 = !{!"$ilr"}
// CHECK-NEXT: !29 = !{!"$mmc"}
// CHECK-NEXT: !30 = !{!"$tel"}
// CHECK-NEXT: !31 = !{!"$teh"}
// CHECK-NEXT: !32 = !{!"$s40"}
// CHECK-NEXT: !33 = !{!"$dba0"}
// CHECK-NEXT: !34 = !{!"$dba1"}
// CHECK-NEXT: !35 = !{!"$dwa0"}
// CHECK-NEXT: !36 = !{!"$dwa1"}
// CHECK-NEXT: !37 = !{!"$mes"}
// CHECK-NEXT: !38 = !{!"$ws"}
// CHECK-NEXT: !39 = !{!"$spc_pl0"}
// CHECK-NEXT: !40 = !{!"$spc_pl1"}
// CHECK-NEXT: !41 = !{!"$spc_pl2"}
// CHECK-NEXT: !42 = !{!"$spc_pl3"}
// CHECK-NEXT: !43 = !{!"$ea_pl0"}
// CHECK-NEXT: !44 = !{!"$ea_pl1"}
// CHECK-NEXT: !45 = !{!"$ea_pl2"}
// CHECK-NEXT: !46 = !{!"$ea_pl3"}
// CHECK-NEXT: !47 = !{!"$ev_pl0"}
// CHECK-NEXT: !48 = !{!"$ev_pl1"}
// CHECK-NEXT: !49 = !{!"$ev_pl2"}
// CHECK-NEXT: !50 = !{!"$ev_pl3"}
// CHECK-NEXT: !51 = !{!"$sr_pl0"}
// CHECK-NEXT: !52 = !{!"$sr_pl1"}
// CHECK-NEXT: !53 = !{!"$sr_pl2"}
// CHECK-NEXT: !54 = !{!"$sr_pl3"}
// CHECK-NEXT: !55 = !{!"$es_pl0"}
// CHECK-NEXT: !56 = !{!"$es_pl1"}
// CHECK-NEXT: !57 = !{!"$es_pl2"}
// CHECK-NEXT: !58 = !{!"$es_pl3"}
// CHECK-NEXT: !59 = !{!"$syow"}
// CHECK-NEXT: !60 = !{!"$htow"}
// CHECK-NEXT: !61 = !{!"$itow"}
// CHECK-NEXT: !62 = !{!"$dow"}
// CHECK-NEXT: !63 = !{!"$mow"}
// CHECK-NEXT: !64 = !{!"$psow"}
// CHECK-NEXT: !65 = !{!"$spc"}
// CHECK-NEXT: !66 = !{!"$sps"}
// CHECK-NEXT: !67 = !{!"$ea"}
// CHECK-NEXT: !68 = !{!"$ev"}
// CHECK-NEXT: !69 = !{!"$sr"}
// CHECK-NEXT: !70 = !{!"$es"}
