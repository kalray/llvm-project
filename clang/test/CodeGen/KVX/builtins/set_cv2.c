// RUN: %clang_cc1 -target-cpu kv3-2 -triple kvx-kalray-cos -S -O2 -emit-llvm -o - %s | FileCheck %s

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

// CHECK-LABEL: @set_31(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !32, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_31(long v) {
  __builtin_kvx_set(31, v);
}

// CHECK-LABEL: @set_38(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !33, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_38(long v) {
  __builtin_kvx_set(38, v);
}

// CHECK-LABEL: @set_39(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !34, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_39(long v) {
  __builtin_kvx_set(39, v);
}

// CHECK-LABEL: @set_41(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !35, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_41(long v) {
  __builtin_kvx_set(41, v);
}

// CHECK-LABEL: @set_42(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !36, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_42(long v) {
  __builtin_kvx_set(42, v);
}

// CHECK-LABEL: @set_43(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !37, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_43(long v) {
  __builtin_kvx_set(43, v);
}

// CHECK-LABEL: @set_44(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !38, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_44(long v) {
  __builtin_kvx_set(44, v);
}

// CHECK-LABEL: @set_45(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !39, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_45(long v) {
  __builtin_kvx_set(45, v);
}

// CHECK-LABEL: @set_46(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !40, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_46(long v) {
  __builtin_kvx_set(46, v);
}

// CHECK-LABEL: @set_47(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !41, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_47(long v) {
  __builtin_kvx_set(47, v);
}

// CHECK-LABEL: @set_48(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !42, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_48(long v) {
  __builtin_kvx_set(48, v);
}

// CHECK-LABEL: @set_49(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !43, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_49(long v) {
  __builtin_kvx_set(49, v);
}

// CHECK-LABEL: @set_50(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !44, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_50(long v) {
  __builtin_kvx_set(50, v);
}

// CHECK-LABEL: @set_51(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !45, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_51(long v) {
  __builtin_kvx_set(51, v);
}

// CHECK-LABEL: @set_52(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !46, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_52(long v) {
  __builtin_kvx_set(52, v);
}

// CHECK-LABEL: @set_53(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !47, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_53(long v) {
  __builtin_kvx_set(53, v);
}

// CHECK-LABEL: @set_54(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !48, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_54(long v) {
  __builtin_kvx_set(54, v);
}

// CHECK-LABEL: @set_55(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !49, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_55(long v) {
  __builtin_kvx_set(55, v);
}

// CHECK-LABEL: @set_56(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !50, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_56(long v) {
  __builtin_kvx_set(56, v);
}

// CHECK-LABEL: @set_57(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !51, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_57(long v) {
  __builtin_kvx_set(57, v);
}

// CHECK-LABEL: @set_58(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !52, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_58(long v) {
  __builtin_kvx_set(58, v);
}

// CHECK-LABEL: @set_59(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !53, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_59(long v) {
  __builtin_kvx_set(59, v);
}

// CHECK-LABEL: @set_60(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !54, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_60(long v) {
  __builtin_kvx_set(60, v);
}

// CHECK-LABEL: @set_61(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !55, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_61(long v) {
  __builtin_kvx_set(61, v);
}

// CHECK-LABEL: @set_62(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !56, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_62(long v) {
  __builtin_kvx_set(62, v);
}

// CHECK-LABEL: @set_63(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !57, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_63(long v) {
  __builtin_kvx_set(63, v);
}

// CHECK-LABEL: @set_64(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !58, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_64(long v) {
  __builtin_kvx_set(64, v);
}

// CHECK-LABEL: @set_65(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !59, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_65(long v) {
  __builtin_kvx_set(65, v);
}

// CHECK-LABEL: @set_66(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !60, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_66(long v) {
  __builtin_kvx_set(66, v);
}

// CHECK-LABEL: @set_67(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !61, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_67(long v) {
  __builtin_kvx_set(67, v);
}

// CHECK-LABEL: @set_68(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !62, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_68(long v) {
  __builtin_kvx_set(68, v);
}

// CHECK-LABEL: @set_69(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !63, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_69(long v) {
  __builtin_kvx_set(69, v);
}

// CHECK-LABEL: @set_70(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !64, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_70(long v) {
  __builtin_kvx_set(70, v);
}

// CHECK-LABEL: @set_71(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !65, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_71(long v) {
  __builtin_kvx_set(71, v);
}

// CHECK-LABEL: @set_72(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !66, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_72(long v) {
  __builtin_kvx_set(72, v);
}

// CHECK-LABEL: @set_73(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !67, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_73(long v) {
  __builtin_kvx_set(73, v);
}

// CHECK-LABEL: @set_74(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !68, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_74(long v) {
  __builtin_kvx_set(74, v);
}

// CHECK-LABEL: @set_75(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !69, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_75(long v) {
  __builtin_kvx_set(75, v);
}

// CHECK-LABEL: @set_76(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !70, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_76(long v) {
  __builtin_kvx_set(76, v);
}

// CHECK-LABEL: @set_77(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !71, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_77(long v) {
  __builtin_kvx_set(77, v);
}

// CHECK-LABEL: @set_78(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !72, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_78(long v) {
  __builtin_kvx_set(78, v);
}

// CHECK-LABEL: @set_79(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !73, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_79(long v) {
  __builtin_kvx_set(79, v);
}

// CHECK-LABEL: @set_80(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !74, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_80(long v) {
  __builtin_kvx_set(80, v);
}

// CHECK-LABEL: @set_81(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !75, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_81(long v) {
  __builtin_kvx_set(81, v);
}

// CHECK-LABEL: @set_82(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !76, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_82(long v) {
  __builtin_kvx_set(82, v);
}

// CHECK-LABEL: @set_83(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !77, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_83(long v) {
  __builtin_kvx_set(83, v);
}

// CHECK-LABEL: @set_84(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !78, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_84(long v) {
  __builtin_kvx_set(84, v);
}

// CHECK-LABEL: @set_85(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !79, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_85(long v) {
  __builtin_kvx_set(85, v);
}

// CHECK-LABEL: @set_86(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !80, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_86(long v) {
  __builtin_kvx_set(86, v);
}

// CHECK-LABEL: @set_87(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !81, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_87(long v) {
  __builtin_kvx_set(87, v);
}

// CHECK-LABEL: @set_88(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !82, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_88(long v) {
  __builtin_kvx_set(88, v);
}

// CHECK-LABEL: @set_89(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !83, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_89(long v) {
  __builtin_kvx_set(89, v);
}

// CHECK-LABEL: @set_90(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !84, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_90(long v) {
  __builtin_kvx_set(90, v);
}

// CHECK-LABEL: @set_91(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !85, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_91(long v) {
  __builtin_kvx_set(91, v);
}

// CHECK-LABEL: @set_92(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !86, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_92(long v) {
  __builtin_kvx_set(92, v);
}

// CHECK-LABEL: @set_93(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !87, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_93(long v) {
  __builtin_kvx_set(93, v);
}

// CHECK-LABEL: @set_94(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !88, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_94(long v) {
  __builtin_kvx_set(94, v);
}

// CHECK-LABEL: @set_95(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !89, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_95(long v) {
  __builtin_kvx_set(95, v);
}

// CHECK-LABEL: @set_96(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !90, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_96(long v) {
  __builtin_kvx_set(96, v);
}

// CHECK-LABEL: @set_97(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !91, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_97(long v) {
  __builtin_kvx_set(97, v);
}

// CHECK-LABEL: @set_98(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !92, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_98(long v) {
  __builtin_kvx_set(98, v);
}

// CHECK-LABEL: @set_99(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !93, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_99(long v) {
  __builtin_kvx_set(99, v);
}

// CHECK-LABEL: @set_100(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !94, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_100(long v) {
  __builtin_kvx_set(100, v);
}

// CHECK-LABEL: @set_101(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !95, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_101(long v) {
  __builtin_kvx_set(101, v);
}

// CHECK-LABEL: @set_104(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !96, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_104(long v) {
  __builtin_kvx_set(104, v);
}

// CHECK-LABEL: @set_105(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !97, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_105(long v) {
  __builtin_kvx_set(105, v);
}

// CHECK-LABEL: @set_106(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !98, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_106(long v) {
  __builtin_kvx_set(106, v);
}

// CHECK-LABEL: @set_107(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !99, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_107(long v) {
  __builtin_kvx_set(107, v);
}

// CHECK-LABEL: @set_128(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !100, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_128(long v) {
  __builtin_kvx_set(128, v);
}

// CHECK-LABEL: @set_132(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !101, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_132(long v) {
  __builtin_kvx_set(132, v);
}

// CHECK-LABEL: @set_136(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !102, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_136(long v) {
  __builtin_kvx_set(136, v);
}

// CHECK-LABEL: @set_140(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !103, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_140(long v) {
  __builtin_kvx_set(140, v);
}

// CHECK-LABEL: @set_144(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !104, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_144(long v) {
  __builtin_kvx_set(144, v);
}

// CHECK-LABEL: @set_148(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !105, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_148(long v) {
  __builtin_kvx_set(148, v);
}

// CHECK-LABEL: @set_152(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !106, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_152(long v) {
  __builtin_kvx_set(152, v);
}

// CHECK-LABEL: @set_156(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !107, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_156(long v) {
  __builtin_kvx_set(156, v);
}

// CHECK-LABEL: @set_168(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !108, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void set_168(long v) {
  __builtin_kvx_set(168, v);
}

// CHECK:!2 = !{!"$ps"}
// CHECK-NEXT:!3 = !{!"$pcr"}
// CHECK-NEXT:!4 = !{!"$ra"}
// CHECK-NEXT:!5 = !{!"$cs"}
// CHECK-NEXT:!6 = !{!"$csit"}
// CHECK-NEXT:!7 = !{!"$aespc"}
// CHECK-NEXT:!8 = !{!"$ls"}
// CHECK-NEXT:!9 = !{!"$le"}
// CHECK-NEXT:!10 = !{!"$lc"}
// CHECK-NEXT:!11 = !{!"$ipe"}
// CHECK-NEXT:!12 = !{!"$men"}
// CHECK-NEXT:!13 = !{!"$pmc"}
// CHECK-NEXT:!14 = !{!"$pm0"}
// CHECK-NEXT:!15 = !{!"$pm1"}
// CHECK-NEXT:!16 = !{!"$pm2"}
// CHECK-NEXT:!17 = !{!"$pm3"}
// CHECK-NEXT:!18 = !{!"$pmsa"}
// CHECK-NEXT:!19 = !{!"$tcr"}
// CHECK-NEXT:!20 = !{!"$t0v"}
// CHECK-NEXT:!21 = !{!"$t1v"}
// CHECK-NEXT:!22 = !{!"$t0r"}
// CHECK-NEXT:!23 = !{!"$t1r"}
// CHECK-NEXT:!24 = !{!"$wdv"}
// CHECK-NEXT:!25 = !{!"$wdr"}
// CHECK-NEXT:!26 = !{!"$ile"}
// CHECK-NEXT:!27 = !{!"$ill"}
// CHECK-NEXT:!28 = !{!"$ilr"}
// CHECK-NEXT:!29 = !{!"$mmc"}
// CHECK-NEXT:!30 = !{!"$tel"}
// CHECK-NEXT:!31 = !{!"$teh"}
// CHECK-NEXT:!32 = !{!"$ixc"}
// CHECK-NEXT:!33 = !{!"$s38"}
// CHECK-NEXT:!34 = !{!"$s39"}
// CHECK-NEXT:!35 = !{!"$dba0"}
// CHECK-NEXT:!36 = !{!"$dba1"}
// CHECK-NEXT:!37 = !{!"$dwa0"}
// CHECK-NEXT:!38 = !{!"$dwa1"}
// CHECK-NEXT:!39 = !{!"$mes"}
// CHECK-NEXT:!40 = !{!"$ws"}
// CHECK-NEXT:!41 = !{!"$s47"}
// CHECK-NEXT:!42 = !{!"$s48"}
// CHECK-NEXT:!43 = !{!"$s49"}
// CHECK-NEXT:!44 = !{!"$s50"}
// CHECK-NEXT:!45 = !{!"$s51"}
// CHECK-NEXT:!46 = !{!"$s52"}
// CHECK-NEXT:!47 = !{!"$s53"}
// CHECK-NEXT:!48 = !{!"$s54"}
// CHECK-NEXT:!49 = !{!"$s55"}
// CHECK-NEXT:!50 = !{!"$s56"}
// CHECK-NEXT:!51 = !{!"$s57"}
// CHECK-NEXT:!52 = !{!"$s58"}
// CHECK-NEXT:!53 = !{!"$s59"}
// CHECK-NEXT:!54 = !{!"$s60"}
// CHECK-NEXT:!55 = !{!"$s61"}
// CHECK-NEXT:!56 = !{!"$s62"}
// CHECK-NEXT:!57 = !{!"$s63"}
// CHECK-NEXT:!58 = !{!"$spc_pl0"}
// CHECK-NEXT:!59 = !{!"$spc_pl1"}
// CHECK-NEXT:!60 = !{!"$spc_pl2"}
// CHECK-NEXT:!61 = !{!"$spc_pl3"}
// CHECK-NEXT:!62 = !{!"$sps_pl0"}
// CHECK-NEXT:!63 = !{!"$sps_pl1"}
// CHECK-NEXT:!64 = !{!"$sps_pl2"}
// CHECK-NEXT:!65 = !{!"$sps_pl3"}
// CHECK-NEXT:!66 = !{!"$ea_pl0"}
// CHECK-NEXT:!67 = !{!"$ea_pl1"}
// CHECK-NEXT:!68 = !{!"$ea_pl2"}
// CHECK-NEXT:!69 = !{!"$ea_pl3"}
// CHECK-NEXT:!70 = !{!"$ev_pl0"}
// CHECK-NEXT:!71 = !{!"$ev_pl1"}
// CHECK-NEXT:!72 = !{!"$ev_pl2"}
// CHECK-NEXT:!73 = !{!"$ev_pl3"}
// CHECK-NEXT:!74 = !{!"$sr_pl0"}
// CHECK-NEXT:!75 = !{!"$sr_pl1"}
// CHECK-NEXT:!76 = !{!"$sr_pl2"}
// CHECK-NEXT:!77 = !{!"$sr_pl3"}
// CHECK-NEXT:!78 = !{!"$es_pl0"}
// CHECK-NEXT:!79 = !{!"$es_pl1"}
// CHECK-NEXT:!80 = !{!"$es_pl2"}
// CHECK-NEXT:!81 = !{!"$es_pl3"}
// CHECK-NEXT:!82 = !{!"$s88"}
// CHECK-NEXT:!83 = !{!"$s89"}
// CHECK-NEXT:!84 = !{!"$s90"}
// CHECK-NEXT:!85 = !{!"$s91"}
// CHECK-NEXT:!86 = !{!"$s92"}
// CHECK-NEXT:!87 = !{!"$s93"}
// CHECK-NEXT:!88 = !{!"$s94"}
// CHECK-NEXT:!89 = !{!"$s95"}
// CHECK-NEXT:!90 = !{!"$syow"}
// CHECK-NEXT:!91 = !{!"$htow"}
// CHECK-NEXT:!92 = !{!"$itow"}
// CHECK-NEXT:!93 = !{!"$dow"}
// CHECK-NEXT:!94 = !{!"$mow"}
// CHECK-NEXT:!95 = !{!"$psow"}
// CHECK-NEXT:!96 = !{!"$s104"}
// CHECK-NEXT:!97 = !{!"$s105"}
// CHECK-NEXT:!98 = !{!"$s106"}
// CHECK-NEXT:!99 = !{!"$s107"}
// CHECK-NEXT:!100 = !{!"$spc"}
// CHECK-NEXT:!101 = !{!"$sps"}
// CHECK-NEXT:!102 = !{!"$ea"}
// CHECK-NEXT:!103 = !{!"$ev"}
// CHECK-NEXT:!104 = !{!"$sr"}
// CHECK-NEXT:!105 = !{!"$es"}
// CHECK-NEXT:!106 = !{!"$s152"}
// CHECK-NEXT:!107 = !{!"$s156"}
// CHECK-NEXT:!108 = !{!"$s168"}
