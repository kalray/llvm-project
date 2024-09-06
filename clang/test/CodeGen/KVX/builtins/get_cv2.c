// RUN: %clang_cc1 -target-cpu kv3-2 -triple kvx-kalray-cos -O2 -emit-llvm -o - %s | FileCheck %s

// CHECK-LABEL: @get_0(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !2)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_0() {
  return __builtin_kvx_get(0);
}

// CHECK-LABEL: @get_1(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !3)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_1() {
  return __builtin_kvx_get(1);
}

// CHECK-LABEL: @get_2(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !4)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_2() {
  return __builtin_kvx_get(2);
}

// CHECK-LABEL: @get_3(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !5)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_3() {
  return __builtin_kvx_get(3);
}

// CHECK-LABEL: @get_4(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !6)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_4() {
  return __builtin_kvx_get(4);
}

// CHECK-LABEL: @get_5(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !7)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_5() {
  return __builtin_kvx_get(5);
}

// CHECK-LABEL: @get_6(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !8)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_6() {
  return __builtin_kvx_get(6);
}

// CHECK-LABEL: @get_7(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !9)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_7() {
  return __builtin_kvx_get(7);
}

// CHECK-LABEL: @get_8(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !10)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_8() {
  return __builtin_kvx_get(8);
}

// CHECK-LABEL: @get_9(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !11)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_9() {
  return __builtin_kvx_get(9);
}

// CHECK-LABEL: @get_10(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !12)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_10() {
  return __builtin_kvx_get(10);
}

// CHECK-LABEL: @get_11(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !13)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_11() {
  return __builtin_kvx_get(11);
}

// CHECK-LABEL: @get_12(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !14)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_12() {
  return __builtin_kvx_get(12);
}

// CHECK-LABEL: @get_13(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !15)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_13() {
  return __builtin_kvx_get(13);
}

// CHECK-LABEL: @get_14(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !16)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_14() {
  return __builtin_kvx_get(14);
}

// CHECK-LABEL: @get_15(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !17)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_15() {
  return __builtin_kvx_get(15);
}

// CHECK-LABEL: @get_16(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !18)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_16() {
  return __builtin_kvx_get(16);
}

// CHECK-LABEL: @get_17(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !19)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_17() {
  return __builtin_kvx_get(17);
}

// CHECK-LABEL: @get_18(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !20)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_18() {
  return __builtin_kvx_get(18);
}

// CHECK-LABEL: @get_19(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !21)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_19() {
  return __builtin_kvx_get(19);
}

// CHECK-LABEL: @get_20(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !22)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_20() {
  return __builtin_kvx_get(20);
}

// CHECK-LABEL: @get_21(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !23)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_21() {
  return __builtin_kvx_get(21);
}

// CHECK-LABEL: @get_22(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !24)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_22() {
  return __builtin_kvx_get(22);
}

// CHECK-LABEL: @get_23(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !25)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_23() {
  return __builtin_kvx_get(23);
}

// CHECK-LABEL: @get_24(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !26)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_24() {
  return __builtin_kvx_get(24);
}

// CHECK-LABEL: @get_25(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !27)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_25() {
  return __builtin_kvx_get(25);
}

// CHECK-LABEL: @get_26(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !28)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_26() {
  return __builtin_kvx_get(26);
}

// CHECK-LABEL: @get_27(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !29)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_27() {
  return __builtin_kvx_get(27);
}

// CHECK-LABEL: @get_28(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !30)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_28() {
  return __builtin_kvx_get(28);
}

// CHECK-LABEL: @get_29(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !31)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_29() {
  return __builtin_kvx_get(29);
}

// CHECK-LABEL: @get_30(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !32)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_30() {
  return __builtin_kvx_get(30);
}

// CHECK-LABEL: @get_31(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !33)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_31() {
  return __builtin_kvx_get(31);
}

// CHECK-LABEL: @get_32(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !34)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_32() {
  return __builtin_kvx_get(32);
}

// CHECK-LABEL: @get_33(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !35)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_33() {
  return __builtin_kvx_get(33);
}

// CHECK-LABEL: @get_34(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !36)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_34() {
  return __builtin_kvx_get(34);
}

// CHECK-LABEL: @get_35(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !37)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_35() {
  return __builtin_kvx_get(35);
}

// CHECK-LABEL: @get_36(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !38)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_36() {
  return __builtin_kvx_get(36);
}

// CHECK-LABEL: @get_37(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !39)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_37() {
  return __builtin_kvx_get(37);
}

// CHECK-LABEL: @get_38(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !40)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_38() {
  return __builtin_kvx_get(38);
}

// CHECK-LABEL: @get_39(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !41)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_39() {
  return __builtin_kvx_get(39);
}

// CHECK-LABEL: @get_41(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !42)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_41() {
  return __builtin_kvx_get(41);
}

// CHECK-LABEL: @get_42(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !43)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_42() {
  return __builtin_kvx_get(42);
}

// CHECK-LABEL: @get_43(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !44)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_43() {
  return __builtin_kvx_get(43);
}

// CHECK-LABEL: @get_44(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !45)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_44() {
  return __builtin_kvx_get(44);
}

// CHECK-LABEL: @get_45(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !46)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_45() {
  return __builtin_kvx_get(45);
}

// CHECK-LABEL: @get_46(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !47)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_46() {
  return __builtin_kvx_get(46);
}

// CHECK-LABEL: @get_47(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !48)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_47() {
  return __builtin_kvx_get(47);
}

// CHECK-LABEL: @get_48(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !49)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_48() {
  return __builtin_kvx_get(48);
}

// CHECK-LABEL: @get_49(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !50)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_49() {
  return __builtin_kvx_get(49);
}

// CHECK-LABEL: @get_50(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !51)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_50() {
  return __builtin_kvx_get(50);
}

// CHECK-LABEL: @get_51(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !52)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_51() {
  return __builtin_kvx_get(51);
}

// CHECK-LABEL: @get_52(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !53)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_52() {
  return __builtin_kvx_get(52);
}

// CHECK-LABEL: @get_53(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !54)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_53() {
  return __builtin_kvx_get(53);
}

// CHECK-LABEL: @get_54(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !55)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_54() {
  return __builtin_kvx_get(54);
}

// CHECK-LABEL: @get_55(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !56)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_55() {
  return __builtin_kvx_get(55);
}

// CHECK-LABEL: @get_56(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !57)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_56() {
  return __builtin_kvx_get(56);
}

// CHECK-LABEL: @get_57(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !58)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_57() {
  return __builtin_kvx_get(57);
}

// CHECK-LABEL: @get_58(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !59)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_58() {
  return __builtin_kvx_get(58);
}

// CHECK-LABEL: @get_59(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !60)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_59() {
  return __builtin_kvx_get(59);
}

// CHECK-LABEL: @get_60(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !61)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_60() {
  return __builtin_kvx_get(60);
}

// CHECK-LABEL: @get_61(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !62)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_61() {
  return __builtin_kvx_get(61);
}

// CHECK-LABEL: @get_62(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !63)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_62() {
  return __builtin_kvx_get(62);
}

// CHECK-LABEL: @get_63(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !64)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_63() {
  return __builtin_kvx_get(63);
}

// CHECK-LABEL: @get_64(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !65)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_64() {
  return __builtin_kvx_get(64);
}

// CHECK-LABEL: @get_65(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !66)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_65() {
  return __builtin_kvx_get(65);
}

// CHECK-LABEL: @get_66(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !67)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_66() {
  return __builtin_kvx_get(66);
}

// CHECK-LABEL: @get_67(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !68)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_67() {
  return __builtin_kvx_get(67);
}

// CHECK-LABEL: @get_68(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !69)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_68() {
  return __builtin_kvx_get(68);
}

// CHECK-LABEL: @get_69(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !70)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_69() {
  return __builtin_kvx_get(69);
}

// CHECK-LABEL: @get_70(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !71)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_70() {
  return __builtin_kvx_get(70);
}

// CHECK-LABEL: @get_71(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !72)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_71() {
  return __builtin_kvx_get(71);
}

// CHECK-LABEL: @get_72(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !73)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_72() {
  return __builtin_kvx_get(72);
}

// CHECK-LABEL: @get_73(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !74)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_73() {
  return __builtin_kvx_get(73);
}

// CHECK-LABEL: @get_74(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !75)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_74() {
  return __builtin_kvx_get(74);
}

// CHECK-LABEL: @get_75(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !76)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_75() {
  return __builtin_kvx_get(75);
}

// CHECK-LABEL: @get_76(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !77)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_76() {
  return __builtin_kvx_get(76);
}

// CHECK-LABEL: @get_77(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !78)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_77() {
  return __builtin_kvx_get(77);
}

// CHECK-LABEL: @get_78(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !79)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_78() {
  return __builtin_kvx_get(78);
}

// CHECK-LABEL: @get_79(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !80)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_79() {
  return __builtin_kvx_get(79);
}

// CHECK-LABEL: @get_80(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !81)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_80() {
  return __builtin_kvx_get(80);
}

// CHECK-LABEL: @get_81(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !82)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_81() {
  return __builtin_kvx_get(81);
}

// CHECK-LABEL: @get_82(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !83)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_82() {
  return __builtin_kvx_get(82);
}

// CHECK-LABEL: @get_83(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !84)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_83() {
  return __builtin_kvx_get(83);
}

// CHECK-LABEL: @get_84(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !85)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_84() {
  return __builtin_kvx_get(84);
}

// CHECK-LABEL: @get_85(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !86)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_85() {
  return __builtin_kvx_get(85);
}

// CHECK-LABEL: @get_86(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !87)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_86() {
  return __builtin_kvx_get(86);
}

// CHECK-LABEL: @get_87(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !88)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_87() {
  return __builtin_kvx_get(87);
}

// CHECK-LABEL: @get_88(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !89)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_88() {
  return __builtin_kvx_get(88);
}

// CHECK-LABEL: @get_89(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !90)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_89() {
  return __builtin_kvx_get(89);
}

// CHECK-LABEL: @get_90(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !91)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_90() {
  return __builtin_kvx_get(90);
}

// CHECK-LABEL: @get_91(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !92)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_91() {
  return __builtin_kvx_get(91);
}

// CHECK-LABEL: @get_92(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !93)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_92() {
  return __builtin_kvx_get(92);
}

// CHECK-LABEL: @get_93(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !94)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_93() {
  return __builtin_kvx_get(93);
}

// CHECK-LABEL: @get_94(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !95)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_94() {
  return __builtin_kvx_get(94);
}

// CHECK-LABEL: @get_95(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !96)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_95() {
  return __builtin_kvx_get(95);
}

// CHECK-LABEL: @get_104(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !97)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_104() {
  return __builtin_kvx_get(104);
}

// CHECK-LABEL: @get_105(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !98)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_105() {
  return __builtin_kvx_get(105);
}

// CHECK-LABEL: @get_106(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !99)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_106() {
  return __builtin_kvx_get(106);
}

// CHECK-LABEL: @get_107(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !100)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_107() {
  return __builtin_kvx_get(107);
}

// CHECK-LABEL: @get_128(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !101)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_128() {
  return __builtin_kvx_get(128);
}

// CHECK-LABEL: @get_132(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !102)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_132() {
  return __builtin_kvx_get(132);
}

// CHECK-LABEL: @get_136(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !103)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_136() {
  return __builtin_kvx_get(136);
}

// CHECK-LABEL: @get_140(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !104)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_140() {
  return __builtin_kvx_get(140);
}

// CHECK-LABEL: @get_144(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !105)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_144() {
  return __builtin_kvx_get(144);
}

// CHECK-LABEL: @get_148(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !106)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_148() {
  return __builtin_kvx_get(148);
}

// CHECK-LABEL: @get_152(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !107)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_152() {
  return __builtin_kvx_get(152);
}

// CHECK-LABEL: @get_156(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !108)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_156() {
  return __builtin_kvx_get(156);
}

// CHECK-LABEL: @get_168(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !109)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long get_168() {
  return __builtin_kvx_get(168);
}

// CHECK: !2 = !{!"$pc"}
// CHECK-NEXT: !3 = !{!"$ps"}
// CHECK-NEXT: !4 = !{!"$pcr"}
// CHECK-NEXT: !5 = !{!"$ra"}
// CHECK-NEXT: !6 = !{!"$cs"}
// CHECK-NEXT: !7 = !{!"$csit"}
// CHECK-NEXT: !8 = !{!"$aespc"}
// CHECK-NEXT: !9 = !{!"$ls"}
// CHECK-NEXT: !10 = !{!"$le"}
// CHECK-NEXT: !11 = !{!"$lc"}
// CHECK-NEXT: !12 = !{!"$ipe"}
// CHECK-NEXT: !13 = !{!"$men"}
// CHECK-NEXT: !14 = !{!"$pmc"}
// CHECK-NEXT: !15 = !{!"$pm0"}
// CHECK-NEXT: !16 = !{!"$pm1"}
// CHECK-NEXT: !17 = !{!"$pm2"}
// CHECK-NEXT: !18 = !{!"$pm3"}
// CHECK-NEXT: !19 = !{!"$pmsa"}
// CHECK-NEXT: !20 = !{!"$tcr"}
// CHECK-NEXT: !21 = !{!"$t0v"}
// CHECK-NEXT: !22 = !{!"$t1v"}
// CHECK-NEXT: !23 = !{!"$t0r"}
// CHECK-NEXT: !24 = !{!"$t1r"}
// CHECK-NEXT: !25 = !{!"$wdv"}
// CHECK-NEXT: !26 = !{!"$wdr"}
// CHECK-NEXT: !27 = !{!"$ile"}
// CHECK-NEXT: !28 = !{!"$ill"}
// CHECK-NEXT: !29 = !{!"$ilr"}
// CHECK-NEXT: !30 = !{!"$mmc"}
// CHECK-NEXT: !31 = !{!"$tel"}
// CHECK-NEXT: !32 = !{!"$teh"}
// CHECK-NEXT: !33 = !{!"$ixc"}
// CHECK-NEXT: !34 = !{!"$syo"}
// CHECK-NEXT: !35 = !{!"$hto"}
// CHECK-NEXT: !36 = !{!"$ito"}
// CHECK-NEXT: !37 = !{!"$do"}
// CHECK-NEXT: !38 = !{!"$mo"}
// CHECK-NEXT: !39 = !{!"$pso"}
// CHECK-NEXT: !40 = !{!"$s38"}
// CHECK-NEXT: !41 = !{!"$s39"}
// CHECK-NEXT: !42 = !{!"$dba0"}
// CHECK-NEXT: !43 = !{!"$dba1"}
// CHECK-NEXT: !44 = !{!"$dwa0"}
// CHECK-NEXT: !45 = !{!"$dwa1"}
// CHECK-NEXT: !46 = !{!"$mes"}
// CHECK-NEXT: !47 = !{!"$ws"}
// CHECK-NEXT: !48 = !{!"$s47"}
// CHECK-NEXT: !49 = !{!"$s48"}
// CHECK-NEXT: !50 = !{!"$s49"}
// CHECK-NEXT: !51 = !{!"$s50"}
// CHECK-NEXT: !52 = !{!"$s51"}
// CHECK-NEXT: !53 = !{!"$s52"}
// CHECK-NEXT: !54 = !{!"$s53"}
// CHECK-NEXT: !55 = !{!"$s54"}
// CHECK-NEXT: !56 = !{!"$s55"}
// CHECK-NEXT: !57 = !{!"$s56"}
// CHECK-NEXT: !58 = !{!"$s57"}
// CHECK-NEXT: !59 = !{!"$s58"}
// CHECK-NEXT: !60 = !{!"$s59"}
// CHECK-NEXT: !61 = !{!"$s60"}
// CHECK-NEXT: !62 = !{!"$s61"}
// CHECK-NEXT: !63 = !{!"$s62"}
// CHECK-NEXT: !64 = !{!"$s63"}
// CHECK-NEXT: !65 = !{!"$spc_pl0"}
// CHECK-NEXT: !66 = !{!"$spc_pl1"}
// CHECK-NEXT: !67 = !{!"$spc_pl2"}
// CHECK-NEXT: !68 = !{!"$spc_pl3"}
// CHECK-NEXT: !69 = !{!"$sps_pl0"}
// CHECK-NEXT: !70 = !{!"$sps_pl1"}
// CHECK-NEXT: !71 = !{!"$sps_pl2"}
// CHECK-NEXT: !72 = !{!"$sps_pl3"}
// CHECK-NEXT: !73 = !{!"$ea_pl0"}
// CHECK-NEXT: !74 = !{!"$ea_pl1"}
// CHECK-NEXT: !75 = !{!"$ea_pl2"}
// CHECK-NEXT: !76 = !{!"$ea_pl3"}
// CHECK-NEXT: !77 = !{!"$ev_pl0"}
// CHECK-NEXT: !78 = !{!"$ev_pl1"}
// CHECK-NEXT: !79 = !{!"$ev_pl2"}
// CHECK-NEXT: !80 = !{!"$ev_pl3"}
// CHECK-NEXT: !81 = !{!"$sr_pl0"}
// CHECK-NEXT: !82 = !{!"$sr_pl1"}
// CHECK-NEXT: !83 = !{!"$sr_pl2"}
// CHECK-NEXT: !84 = !{!"$sr_pl3"}
// CHECK-NEXT: !85 = !{!"$es_pl0"}
// CHECK-NEXT: !86 = !{!"$es_pl1"}
// CHECK-NEXT: !87 = !{!"$es_pl2"}
// CHECK-NEXT: !88 = !{!"$es_pl3"}
// CHECK-NEXT: !89 = !{!"$s88"}
// CHECK-NEXT: !90 = !{!"$s89"}
// CHECK-NEXT: !91 = !{!"$s90"}
// CHECK-NEXT: !92 = !{!"$s91"}
// CHECK-NEXT: !93 = !{!"$s92"}
// CHECK-NEXT: !94 = !{!"$s93"}
// CHECK-NEXT: !95 = !{!"$s94"}
// CHECK-NEXT: !96 = !{!"$s95"}
// CHECK-NEXT: !97 = !{!"$s104"}
// CHECK-NEXT: !98 = !{!"$s105"}
// CHECK-NEXT: !99 = !{!"$s106"}
// CHECK-NEXT: !100 = !{!"$s107"}
// CHECK-NEXT: !101 = !{!"$spc"}
// CHECK-NEXT: !102 = !{!"$sps"}
// CHECK-NEXT: !103 = !{!"$ea"}
// CHECK-NEXT: !104 = !{!"$ev"}
// CHECK-NEXT: !105 = !{!"$sr"}
// CHECK-NEXT: !106 = !{!"$es"}
// CHECK-NEXT: !107 = !{!"$s152"}
// CHECK-NEXT: !108 = !{!"$s156"}
// CHECK-NEXT: !109 = !{!"$s168"}
