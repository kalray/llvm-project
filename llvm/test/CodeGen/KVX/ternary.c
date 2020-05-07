// RUN: clang -target kvx-cos -S %s -O2 -o - | FileCheck %s

#ifndef __cplusplus
#define bool _Bool
#define true 1
#define false 0
#endif

long g1;
long g2;

long Int64TernaryRegImm(bool value, long v1) {
  return value ? v1 : 4;
  // CHECK: Int64TernaryRegImm
  // CHECK: copyd $r2 = $r1
  // CHECK: cmoved.weqz $r0 ? $r2 = 4
  // CHECK: ret
}

long Int64TernaryImmReg(bool value, long v2) {
  return value ? 3 : v2;
  // CHECK: Int64TernaryImmReg
  // CHECK: cmoved.wnez $r0 ? $r1 = 3
  // CHECK: ret
}

long Int64TernaryRegReg(bool value, long v1, long v2) {
  return value ? v1 : v2;
  // CHECK: Int64TernaryRegReg
  // CHECK: cmoved.wnez $r0 ? $r2 = $r1
  // CHECK: ret
}

long Int64TernaryImmImm(bool value) {
  return value ? 3 : 7;
  // CHECK: Int64TernaryImmImm
  // CHECK: make $r0 = 3
  // CHECK: moved.weqz $r1 ? $r0 = 7
  // CHECK: ret
}

long Int64TernaryGlobalGlobal(bool value) {
  return value ? g1 : g2;
  // CHECK: Int64TernaryGlobalGlobal
  // CHECK: make $r0 = g1
  // CHECK: cmoved.weqz $r1 ? $r0 = g2
  // CHECK: ret
}

long Int64TernaryGlobalImm(bool value) {
  return value ? g1 : 3;
  // CHECK: Int64TernaryGlobalImm
  // CHECK: make $r1 = g1
  // CHECK: copyd $r2 = $r1
  // CHECK: cmoved.weqz $r0 ? $r2 = 3
  // CHECK: ret
}

long Int64TernaryImmGlobal(bool value) {
  return value ? 3 : g1;
  // CHECK: Int64TernaryImmGlobal
  // CHECK: make $r1 = g1
  // CHECK: ld $r1 = 0[$r1]
  // CHECK: cmoved.wnez $r0 ? $r1 = 3
  // CHECK: ret
}

long Int64TernaryRegGlobal(bool value, long v1) {
  return value ? v1 : g1;
  // CHECK: Int64TernaryRegGlobal
  // CHECK: make $r2 = g1
  // CHECK: ld $r2 = 0[$r2]
  // CHECK: cmoved.wnez $r0 ? $r2 = $r1
  // CHECK: ret
}

long Int64TernaryGlobalReg(bool value, long v1) {
  return value ? g1 : v1;
  // CHECK: Int64TernaryGlobalReg
  // CHECK: make $r2 = g1
  // CHECK: ld $r2 = 0[$r2]
  // CHECK: cmoved.wnez $r0 ? $r1 = $r2
  // CHECK: ret
}

double gf1;
double gf2;

double FloatTernaryRegImm(bool value, double v1) {
  return value ? v1 : 4.0f;
  // CHECK: FloatTernaryRegImm
  // CHECK: copyd $r2 = $r1
  // CHECK: cmoved.weqz $r0 ? $r2 = 0x4010000000000000
  // CHECK: ret
}

double FloatTernaryImmReg(bool value, double v2) {
  return value ? 3.0f : v2;
  // CHECK: FloatTernaryImmReg
  // CHECK: cmoved.wnez $r0 ? $r1 = 0x4008000000000000
  // CHECK: ret
}

double FloatTernaryRegReg(bool value, double v1, double v2) {
  return value ? v1 : v2;
  // CHECK: FloatTernaryRegReg
  // CHECK: cmoved.wnez $r0 ? $r2 = $r1
  // CHECK: ret
}

double FloatTernaryImmImm(bool value) {
  return value ? 3.0f : 7.0f;
  // CHECK: FloatTernaryImmImm
  // CHECK: make $r0 = 4613937818241073152
  // CHECK: cmoved.weqz $r1 ? $r0 = 0x401c000000000000
  // CHECK: ret
}

double FloatTernaryGlobalGlobal(bool value) {
  return value ? gf1 : gf2;
  // CHECK: FloatTernaryGlobalGlobal
  // CHECK: make $r0 = gf1
  // CHECK: cmoved.weqz $r1 ? $r0 = gf2
  // CHECK: ret
}

double FloatTernaryGlobalImm(bool value) {
  return value ? gf1 : 3.0f;
  // CHECK: FloatTernaryGlobalImm
  // CHECK: make $r1 = gf1
  // CHECK: ld $r1 = 0[$r1]
  // CHECK: copyd $r2 = $r1
  // CHECK: cmoved.weqz $r0 ? $r2 = 0x4008000000000000
  // CHECK: ret
}

double FloatTernaryImmGlobal(bool value) {
  return value ? 3.0f : gf1;
  // CHECK: FloatTernaryImmGlobal
  // CHECK: make $r1 = gf1
  // CHECK: ld $r1 = 0[$r1]
  // CHECK: cmoved.wnez $r0 ? $r1 = 0x4008000000000000
  // CHECK: ret
}

double FloatTernaryRegGlobal(bool value, double v1) {
  return value ? v1 : gf1;
  // CHECK: FloatTernaryRegGlobal
  // CHECK: make $r2 = gf1
  // CHECK: ld $r2 = 0[$r2]
  // CHECK: cmoved.wnez $r0 ? $r2 = $r1
  // CHECK: ret
}

double FloatTernaryGlobalReg(bool value, double v1) {
  return value ? gf1 : v1;
  // CHECK: FloatTernaryGlobalReg
  // CHECK: make $r2 = gf1
  // CHECK: ld $r2 = 0[$r2]
  // CHECK: cmoved.wnez $r0 ? $r1 = $r2
  // CHECK: ret
}

int gi32_1;
int gi32_2;

int Int32TernaryRegImm(bool value, int v1) {
  return value ? v1 : 4;
  // CHECK: Int32TernaryRegImm
  // CHECK: copyd $r2 = $r1
  // CHECK: cmoved.weqz $r0 ? $r2 = 4
  // CHECK: ret
}

int Int32TernaryImmReg(bool value, int v2) {
  return value ? 3 : v2;
  // CHECK: Int32TernaryImmReg
  // CHECK: cmoved.wnez $r0 ? $r1 = 3
  // CHECK: ret
}

int Int32TernaryRegReg(bool value, int v1, int v2) {
  return value ? v1 : v2;
  // CHECK: Int32TernaryRegReg
  // CHECK: cmoved.wnez $r0 ? $r2 = $r1
  // CHECK: ret
}

int Int32TernaryImmImm(bool value) {
  return value ? 3 : 7;
  // CHECK: Int32TernaryImmImm
  // CHECK: make $r0 = 3
  // CHECK: cmoved.weqz $r1 ? $r0 = 7
  // CHECK: ret
}

int Int32TernaryGlobalGlobal(bool value) {
  return value ? gi32_1 : gi32_2;
  // CHECK: Int32TernaryGlobalGlobal
  // CHECK: make $r0 = gi32_1
  // CHECK: cmoved.weqz $r1 ? $r0 = gi32_2
  // CHECK: ret
}

int Int32TernaryGlobalImm(bool value) {
  return value ? gi32_1 : 3;
  // CHECK: Int32TernaryGlobalImm
  // CHECK: make $r1 = gi32_1
  // CHECK: lwz $r1 = 0[$r1]
  // CHECK: copyd $r2 = $r1
  // CHECK: cmoved.weqz $r0 ? $r2 = 3
  // CHECK: ret
}

int Int32TernaryImmGlobal(bool value) {
  return value ? 3 : gi32_1;
  // CHECK: Int32TernaryImmGlobal
  // CHECK: make $r1 = gi32_1
  // CHECK: lwz $r1 = 0[$r1]
  // CHECK: cmoved.wnez $r0 ? $r1 = 3
  // CHECK: ret
}

int Int32TernaryRegGlobal(bool value, int v1) {
  return value ? v1 : gi32_1;
  // CHECK: Int32TernaryRegGlobal
  // CHECK: make $r2 = gi32_1
  // CHECK: lwz $r2 = 0[$r2]
  // CHECK: cmoved.wnez $r0 ? $r2 = $r1
  // CHECK: ret
}

int Int32TernaryGlobalReg(bool value, int v1) {
  return value ? gi32_1 : v1;
  // CHECK: Int32TernaryGlobalReg
  // CHECK: make $r2 = gi32_1
  // CHECK: lwz $r2 = 0[$r2]
  // CHECK: cmoved.wnez $r0 ? $r1 = $r2
  // CHECK: ret
}

int Int32TernaryCond1(int v) {
  return v == 0 ? 5 : 7;
  // CHECK: Int32TernaryCond1
  // CHECK: make $r0 = 5
  // CHECK: cmoved.wnez $r1 ? $r0 = 7
  // CHECK: ret
}

int Int32TernaryCond2(int v) {
  return v != 0 ? 5 : 7;
  // CHECK: Int32TernaryCond2
  // CHECK: make $r0 = 7
  // CHECK: cmoved.wnez $r1 ? $r0 = 5
  // CHECK: ret
}

int Int32TernaryCond3(int v) {
  return v < 0 ? 5 : 7;
  // CHECK: Int32TernaryCond3
  // CHECK: make $r0 = 5
  // CHECK: cmoved.wgez $r1 ? $r0 = 7
  // CHECK: ret
}

int Int32TernaryCond4(int v) {
  return v >= 0 ? 5 : 7;
  // CHECK: Int32TernaryCond4
  // CHECK: make $r0 = 5
  // CHECK: cmoved.wltz $r1 ? $r0 = 7
  // CHECK: ret
}

int Int32TernaryCond5(int v) {
  return v <= 0 ? 5 : 7;
  // CHECK: Int32TernaryCond5
  // CHECK: make $r0 = 5
  // CHECK: cmoved.wgtz $r1 ? $r0 = 7
  // CHECK: ret
}

int Int32TernaryCond6(int v) {
  return v > 0 ? 5 : 7;
  // CHECK: Int32TernaryCond6
  // CHECK: make $r0 = 5
  // CHECK: cmoved.wlez $r1 ? $r0 = 7
  // CHECK: ret
}

int Int32TernaryCond7(int v) {
  return (v & 1) == 0 ? 5 : 7;
  // CHECK: Int32TernaryCond7
  // CHECK: make $r0 = 5
  // CHECK: cmoved.odd $r1 ? $r0 = 7
}

int Int32TernaryCond8(int v) {
  return (v & 1) == 1 ? 5 : 7;
  // CHECK: Int32TernaryCond8
  // CHECK: make $r0 = 7
  // CHECK: cmoved.odd $r1 ? $r0 = 5
  // CHECK: ret
}

long Int64TernaryCond1(long v) {
  return v == 0 ? 5 : 7;
  // CHECK: Int64TernaryCond1
  // CHECK: make $r1 = 5
  // CHECK: cmoved.dnez $r0 ? $r1 = 7
  // CHECK: ret
}

long Int64TernaryCond2(long v) {
  return v != 0 ? 5 : 7;
  // CHECK: Int64TernaryCond2
  // CHECK: make $r1 = 7
  // CHECK: cmoved.dnez $r0 ? $r1 = 5
  // CHECK: ret
}

long Int64TernaryCond3(long v) {
  return v < 0 ? 5 : 7;
  // CHECK: Int64TernaryCond3
  // CHECK: make $r1 = 5
  // CHECK: cmoved.dgez $r0 ? $r1 = 7
  // CHECK: ret
}

long Int64TernaryCond4(long v) {
  return v >= 0 ? 5 : 7;
  // CHECK: Int64TernaryCond4
  // CHECK: make $r1 = 5
  // CHECK: cmoved.dltz $r0 ? $r1 = 7
  // CHECK: ret
}

long Int64TernaryCond5(long v) {
  return v <= 0 ? 5 : 7;
  // CHECK: Int64TernaryCond5
  // CHECK: make $r1 = 5
  // CHECK: cmoved.dgtz $r0 ? $r1 = 7
  // CHECK: ret
}

long Int64TernaryCond6(long v) {
  return v > 0 ? 5 : 7;
  // CHECK: Int64TernaryCond6
  // CHECK: make $r1 = 5
  // CHECK: cmoved.dlez $r0 ? $r1 = 7
  // CHECK: ret
}

long Int64TernaryCond7(long v) {
  return (v & 1) == 0 ? 5 : 7;
  // CHECK: Int64TernaryCond7
  // CHECK: make $r1 = 5
  // CHECK: cmoved.odd $r0 ? $r1 = 7
  // CHECK: ret
}

long Int64TernaryCond8(long v) {
  return (v & 1) == 1 ? 5 : 7;
  // CHECK: Int64TernaryCond8
  // CHECK: make $r1 = 7
  // CHECK: cmoved.odd $r0 ? $r1 = 5
  // CHECK: ret
}

float FloatTernaryCond1(int v) {
  return v == 0 ? 5.0f : 7.0f;
  // CHECK: FloatTernaryCond1
  // CHECK: make $r0 = 1084227584
  // CHECK: cmoved.wnez $r1 ? $r0 = 0x40e00000
  // CHECK: ret
}

float FloatTernaryCond2(int v) {
  return v != 0 ? 5.0f : 7.0f;
  // CHECK: FloatTernaryCond2
  // CHECK: make $r0 = 1088421888
  // CHECK: cmoved.wnez $r1 ? $r0 = 0x40a00000
  // CHECK: ret
}

float FloatTernaryCond3(int v) {
  return v < 0 ? 5.0f : 7.0f;
  // CHECK: FloatTernaryCond3
  // CHECK: make $r0 = 1084227584
  // CHECK: cmoved.wgez $r1 ? $r0 = 0x40e00000
  // CHECK: ret
}

float FloatTernaryCond4(int v) {
  return v >= 0 ? 5.0f : 7.0f;
  // CHECK: FloatTernaryCond4
  // CHECK: make $r0 = 1084227584
  // CHECK: cmoved.wltz $r1 ? $r0 = 0x40e00000
  // CHECK: ret
}

float FloatTernaryCond5(int v) {
  return v <= 0 ? 5.0f : 7.0f;
  // CHECK: FloatTernaryCond5
  // CHECK: make $r0 = 1084227584
  // CHECK: cmoved.wgtz $r1 ? $r0 = 0x40e00000
  // CHECK: ret
}

float FloatTernaryCond6(int v) {
  return v > 0 ? 5.0f : 7.0f;
  // CHECK: FloatTernaryCond6
  // CHECK: make $r0 = 1084227584
  // CHECK: cmoved.wlez $r1 ? $r0 = 0x40e00000
  // CHECK: ret
}

float FloatTernaryCond7(int v) {
  return (v & 1) == 0 ? 5.0f : 7.0f;
  // CHECK: FloatTernaryCond7
  // CHECK: make $r0 = 1084227584
  // CHECK: cmoved.odd $r1 ? $r0 = 0x40e00000
  // CHECK: ret
}

float FloatTernaryCond8(int v) {
  return (v & 1) == 1 ? 5.0f : 7.0f;
  // CHECK: FloatTernaryCond8
  // CHECK: make $r0 = 1088421888
  // CHECK: cmoved.odd $r1 ? $r0 = 0x40a00000
  // CHECK: ret
}

double DoubleTernaryCond1(int v) {
  return v == 0 ? 5.0 : 7.0;
  // CHECK: DoubleTernaryCond1
  // CHECK: make $r0 = 4617315517961601024
  // CHECK: cmoved.wnez $r1 ? $r0 = 0x401c000000000000
  // CHECK: ret
}

double DoubleTernaryCond2(int v) {
  return v != 0 ? 5.0 : 7.0;
  // CHECK: DoubleTernaryCond2
  // CHECK: make $r0 = 4619567317775286272
  // CHECK: cmoved.wnez $r1 ? $r0 = 0x4014000000000000
  // CHECK: ret
}

double DoubleTernaryCond3(int v) {
  return v < 0 ? 5.0 : 7.0;
  // CHECK: DoubleTernaryCond3
  // CHECK: make $r0 = 4617315517961601024
  // CHECK: cmoved.wgez $r1 ? $r0 = 0x401c000000000000
  // CHECK: ret
}

double DoubleTernaryCond4(int v) {
  return v >= 0 ? 5.0 : 7.0;
  // CHECK: DoubleTernaryCond4
  // CHECK: make $r0 = 4617315517961601024
  // CHECK: cmoved.wltz $r1 ? $r0 = 0x401c000000000000
  // CHECK: ret
}

double DoubleTernaryCond5(int v) {
  return v <= 0 ? 5.0 : 7.0;
  // CHECK: DoubleTernaryCond5
  // CHECK: make $r0 = 4617315517961601024
  // CHECK: cmoved.wgtz $r1 ? $r0 = 0x401c000000000000
  // CHECK: ret
}

double DoubleTernaryCond6(int v) {
  return v > 0 ? 5.0 : 7.0;
  // CHECK: DoubleTernaryCond6
  // CHECK: make $r0 = 4617315517961601024
  // CHECK: cmoved.wlez $r1 ? $r0 = 0x401c000000000000
  // CHECK: ret
}

double DoubleTernaryCond7(int v) {
  return (v & 1) == 0 ? 5.0 : 7.0;
  // CHECK: DoubleTernaryCond7
  // CHECK: make $r0 = 4617315517961601024
  // CHECK: cmoved.odd $r1 ? $r0 = 0x401c000000000000
  // CHECK: ret
}

double DoubleTernaryCond8(int v) {
  return (v & 1) == 1 ? 5.0 : 7.0;
  // CHECK: DoubleTernaryCond8
  // CHECK: make $r0 = 4619567317775286272
  // CHECK: cmoved.odd $r1 ? $r0 = 0x4014000000000000
  // CHECK: ret
}

int Int32TernaryCondRegImm1(int v, int v1) {
  return v == 0 ? v1 : 7;
  // CHECK: Int32TernaryCondRegImm1
  // CHECK: copyd $r2 = $r1
  // CHECK: cmoved.wnez $r0 ? $r2 = 7
  // CHECK: ret
}

int Int32TernaryCondRegImm2(int v, int v1) {
  return v != 0 ? v1 : 7;
  // CHECK: Int32TernaryCondRegImm2
  // CHECK: cmoved.weqz $r0 ? $r1 = 7
  // CHECK: ret
}

int Int32TernaryCondRegImm3(int v, int v1) {
  return v < 0 ? v1 : 7;
  // CHECK: Int32TernaryCondRegImm3
  // CHECK: copyd $r2 = $r1
  // CHECK: cmoved.wgez $r0 ? $r2 = 7
  // CHECK: ret
}

int Int32TernaryCondRegImm4(int v, int v1) {
  return v >= 0 ? v1 : 7;
  // CHECK: Int32TernaryCondRegImm4
  // CHECK: copyd $r2 = $r1
  // CHECK: cmoved.wltz $r0 ? $r2 = 7
  // CHECK: ret
}

int Int32TernaryCondRegImm5(int v, int v1) {
  return v <= 0 ? v1 : 7;
  // CHECK: Int32TernaryCondRegImm5
  // CHECK: copyd $r2 = $r1
  // CHECK: cmoved.wgtz $r0 ? $r2 = 7
  // CHECK: ret
}

int Int32TernaryCondRegImm6(int v, int v1) {
  return v > 0 ? v1 : 7;
  // CHECK: Int32TernaryCondRegImm6
  // CHECK: copyd $r2 = $r1
  // CHECK: cmoved.wlez $r0 ? $r2 = 7
  // CHECK: ret
}

int Int32TernaryCondRegImm7(int v, int v1) {
  return (v & 1) == 0 ? v1 : 7;
  // CHECK: Int32TernaryCondRegImm7
  // CHECK: copyd $r2 = $r1
  // CHECK: cmoved.odd $r0 ? $r2 = 7
  // CHECK: ret
}

int Int32TernaryCondRegImm8(int v, int v1) {
  return (v & 1) == 1 ? v1 : 7;
  // CHECK: Int32TernaryCondRegImm8
  // CHECK: cmoved.even $r0 ? $r1 = 7
  // CHECK: ret
}

int Int32TernaryCondRegReg1(int v, int v1, int v2) {
  return v == 0 ? v1 : v2;
  // CHECK: Int32TernaryCondRegReg1
  // CHECK: cmoved.weqz $r0 ? $r2 = $r1
  // CHECK: ret
}

int Int32TernaryCondRegReg2(int v, int v1, int v2) {
  return v != 0 ? v1 : v2;
  // CHECK: Int32TernaryCondRegReg2
  // CHECK: cmoved.weqz $r0 ? $r1 = $r2
  // CHECK: ret
}

int Int32TernaryCondRegReg3(int v, int v1, int v2) {
  return v < 0 ? v1 : v2;
  // CHECK: Int32TernaryCondRegReg3
  // CHECK: cmoved.wltz $r0 ? $r2 = $r1
  // CHECK: ret
}

int Int32TernaryCondRegReg4(int v, int v1, int v2) {
  return v >= 0 ? v1 : v2;
  // CHECK: Int32TernaryCondRegReg4
  // CHECK: cmoved.wgez $r0 ? $r2 = $r1
  // CHECK: ret
}

int Int32TernaryCondRegReg5(int v, int v1, int v2) {
  return v <= 0 ? v1 : v2;
  // CHECK: Int32TernaryCondRegReg5
  // CHECK: cmoved.wlez $r0 ? $r2 = $r1
  // CHECK: ret
}

int Int32TernaryCondRegReg6(int v, int v1, int v2) {
  return v > 0 ? v1 : v2;
  // CHECK: Int32TernaryCondRegReg6
  // CHECK: cmoved.wgtz $r0 ? $r2 = $r1
  // CHECK: ret
}

int Int32TernaryCondRegReg7(int v, int v1, int v2) {
  return (v & 1) == 0 ? v1 : v2;
  // CHECK: Int32TernaryCondRegReg7
  // CHECK: cmoved.even $r0 ? $r2 = $r1
  // CHECK: ret
}

int Int32TernaryCondRegReg8(int v, int v1, int v2) {
  return (v & 1) == 1 ? v1 : v2;
  // CHECK: Int32TernaryCondRegReg8
  // CHECK: cmoved.even $r0 ? $r1 = $r2
  // CHECK: ret
}
