// RUN: clang -target kvx-cos -S -O3 %s -o - | FileCheck %s

unsigned long maddw_reg(unsigned a, unsigned b, unsigned c) {
  return a + b * c;
  // CHECK: maddw_reg:
  // CHECK: maddw
  // CHECK-NEXT: ret
}

unsigned long maddw_imm(unsigned int a, unsigned int b) {
  return a + b * 10;
  // CHECK: maddw_imm:
  // CHECK: maddw
  // CHECK-NEXT: ret
}

unsigned long addx2w_reg(unsigned int a, unsigned int b) {
  return a + (b << 1);
  // CHECK: addx2w_reg:
  // CHECK: addx2w
  // CHECK-NEXT: ret
}

unsigned long addx4w_reg(unsigned int a, unsigned int b) {
  return a + (b << 2);
  // CHECK: addx4w_reg:
  // CHECK: addx4w
  // CHECK-NEXT: ret
}

unsigned long addx8w_reg(unsigned int a, unsigned int b) {
  return a + (b << 3);
  // CHECK: addx8w_reg:
  // CHECK: addx8w
  // CHECK-NEXT: ret
}

unsigned long addx16w_reg(unsigned int a, unsigned int b) {
  return a + (b << 4);
  // CHECK: addx16w_reg:
  // CHECK: addx16w
  // CHECK-NEXT: ret
}

unsigned long addx2w_imm(unsigned int a, unsigned int b) {
  return 16 + (b << 1);
  // CHECK: addx2w_imm:
  // CHECK: addx2w
  // CHECK-NEXT: ret
}

unsigned long addx4w_imm(unsigned int a, unsigned int b) {
  return 16 + (b << 2);
  // CHECK: addx4w_imm:
  // CHECK: addx4w
  // CHECK-NEXT: ret
}

unsigned long addx8w_imm(unsigned int a, unsigned int b) {
  return 16 + (b << 3);
  // CHECK: addx8w_imm:
  // CHECK: addx8w
  // CHECK-NEXT: ret
}

unsigned long addx16w_imm(unsigned int a, unsigned int b) {
  return 16 + (b << 4);
  // CHECK: addx16w_imm:
  // CHECK: addx16w
  // CHECK-NEXT: ret
}

unsigned long sbfx2w_reg(unsigned int a, unsigned int b) {
  return a - (b << 1);
  // CHECK: sbfx2w_reg:
  // CHECK: sbfx2w
  // CHECK-NEXT: ret
}

unsigned long sbfx4w_reg(unsigned int a, unsigned int b) {
  return a - (b << 2);
  // CHECK: sbfx4w_reg:
  // CHECK: sbfx4w
  // CHECK-NEXT: ret
}

unsigned long sbfx8w_reg(unsigned int a, unsigned int b) {
  return a - (b << 3);
  // CHECK: sbfx8w_reg:
  // CHECK: sbfx8w
  // CHECK-NEXT: ret
}

unsigned long sbfx16w_reg(unsigned int a, unsigned int b) {
  return a - (b << 4);
  // CHECK: sbfx16w_reg:
  // CHECK: sbfx16w
  // CHECK-NEXT: ret
}

unsigned long sbfx2w_imm(unsigned int a, unsigned int b) {
  return 16 - (b << 1);
  // CHECK: sbfx2w_imm:
  // CHECK: sbfx2w
  // CHECK-NEXT: ret
}

unsigned long sbfx4w_imm(unsigned int a, unsigned int b) {
  return 16 - (b << 2);
  // CHECK: sbfx4w_imm:
  // CHECK: sbfx4w
  // CHECK-NEXT: ret
}

unsigned long sbfx8w_imm(unsigned int a, unsigned int b) {
  return 16 - (b << 3);
  // CHECK: sbfx8w_imm:
  // CHECK: sbfx8w
  // CHECK-NEXT: ret
}

unsigned long sbfx16w_imm(unsigned int a, unsigned int b) {
  return 16 - (b << 4);
  // CHECK: sbfx16w_imm:
  // CHECK: sbfx16w
  // CHECK-NEXT: ret
}

unsigned long andw_reg(unsigned a, unsigned b) {
  return a & b;
  // CHECK: andw_reg:
  // CHECK: andw
  // CHECK-NEXT: ret
}

unsigned long andw_imm10(unsigned a) {
  return a & 10;
  // CHECK: andw_imm10:
  // CHECK: andw
  // CHECK-NEXT: ret
}

unsigned long andw_imm37(unsigned a) {
  return a & (1 << 15);
  // CHECK: andw_imm37:
  // CHECK: andw
  // CHECK-NEXT: ret
}

unsigned long orw_reg(unsigned a, unsigned b) {
  return a ^ b;
  // CHECK: orw_reg:
  // CHECK: orw
  // CHECK-NEXT: ret
}

unsigned long orw_imm10(unsigned a) {
  return a ^ 10;
  // CHECK: orw_imm10:
  // CHECK: orw
  // CHECK-NEXT: ret
}

unsigned long orw_imm37(unsigned a) {
  return a ^ (1 << 15);
  // CHECK: orw_imm37:
  // CHECK: orw
  // CHECK-NEXT: ret
}

unsigned long sllw_reg(unsigned a, unsigned b) {
  return a << b;
  // CHECK: sllw_reg:
  // CHECK: sllw
  // CHECK-RET: ret
}

unsigned long sllw_imm(unsigned a) {
  return a << 10;
  // CHECK: sllw_imm:
  // CHECK: sllw
  // CHECK-NEXT: ret
}

unsigned long srlw_reg(unsigned a, unsigned b) {
  return a >> b;
  // CHECK: srlw_reg:
  // CHECK: srlw
  // CHECK-NEXT: ret
}

unsigned long srlw_imm(unsigned a) {
  return a >> 10;
  // CHECK: srlw_imm:
  // CHECK: srlw
  // CHECK-NEXT: ret
}

unsigned long xorw_reg(unsigned a, unsigned b) {
  return a ^ b;
  // CHECK: xorw_reg:
  // CHECK: xorw
  // CHECK-NEXT: ret
}

unsigned long xorw_imm10(unsigned a) {
  return a ^ 10;
  // CHECK: xorw_imm10:
  // CHECK: xorw
  // CHECK-NEXT: ret
}

unsigned long xorw_imm37(unsigned a) {
  return a ^ (1 << 15);
  // CHECK: xorw_imm37:
  // CHECK: xorw
  // CHECK-NEXT: ret
}

unsigned long minw_reg(unsigned a, unsigned b) {
  return a < b ? a : b;
  // CHECK: minw_reg:
  // CHECK: minuw
  // CHECK-NEXT: ret
}

unsigned long maxw_reg(unsigned a, unsigned b) {
  return a > b ? a : b;
  // CHECK: maxw_reg:
  // CHECK: maxuw
  // CHECK-NEXT: ret
}

unsigned long mulw_reg(unsigned a, unsigned b) {
  return a * b;
  // CHECK: mulw_reg:
  // CHECK: mulw
  // CHECK-NEXT: ret
}

unsigned long and_srl_to_extfz(unsigned a) {
  return (a >> 8) & 3;
  // CHECK: and_srl_to_extfz:
  // CHECK: extfz
  // CHECK-NEXT: ret
}

unsigned long shl_i8(unsigned a, char b) {
  return a << b;
  // CHECK: shl_i8:
  // CHECK: sllw
  // CHECK-NEXT: ret
}

unsigned long shl_u8(unsigned a, unsigned char b) {
  return a << b;
  // CHECK: shl_u8:
  // CHECK: sllw
  // CHECK-NEXT: ret
}

unsigned long shl_i16(unsigned a, short b) {
  return a << b;
  // CHECK: shl_i16:
  // CHECK: sllw
  // CHECK-NEXT: ret
}

unsigned long shl_u16(unsigned a, unsigned short b) {
  return a << b;
  // CHECK: shl_u16:
  // CHECK: sllw
  // CHECK-NEXT: ret
}

unsigned long shl_i32(unsigned a, int b) {
  return a << b;
  // CHECK: shl_i32:
  // CHECK: sllw
  // CHECK-NEXT: ret
}

unsigned long shl_u32(unsigned a, unsigned int b) {
  return a << b;
  // CHECK: shl_u32:
  // CHECK: sllw
  // CHECK-NEXT: ret
}

unsigned long shl_i64(unsigned a, long b) {
  return a << b;
  // CHECK: shl_i64:
  // CHECK: sllw
  // CHECK-NEXT: ret
}

unsigned long shl_u64(unsigned a, unsigned long b) {
  return a << b;
  // CHECK: shl_u64:
  // CHECK: sllw
  // CHECK-NEXT: ret
}

unsigned long srl_i8(unsigned a, char b) {
  return a >> b;
  // CHECK: srl_i8:
  // CHECK: srlw
  // CHECK-NEXT: ret
}

unsigned long srl_u8(unsigned a, unsigned char b) {
  return a >> b;
  // CHECK: srl_u8:
  // CHECK: srlw
  // CHECK-NEXT: ret
}

unsigned long srl_i16(unsigned a, short b) {
  return a >> b;
  // CHECK: srl_i16:
  // CHECK: srlw
  // CHECK-NEXT: ret
}

unsigned long srl_u16(unsigned a, unsigned short b) {
  return a >> b;
  // CHECK: srl_u16:
  // CHECK: srlw
  // CHECK-NEXT: ret
}

unsigned long srl_i32(unsigned a, int b) {
  return a >> b;
  // CHECK: srl_i32:
  // CHECK: srlw
  // CHECK-NEXT: ret
}

unsigned long srl_u32(unsigned a, unsigned int b) {
  return a >> b;
  // CHECK: srl_u32:
  // CHECK: srlw
  // CHECK-NEXT: ret
}

unsigned long srl_i64(unsigned a, long b) {
  return a >> b;
  // CHECK: srl_i64:
  // CHECK: srlw
  // CHECK-NEXT: ret
}

unsigned long srl_u64(unsigned a, unsigned long b) {
  return a >> b;
  // CHECK: srl_u64:
  // CHECK: srlw
  // CHECK-NEXT: ret
}
unsigned long landw_i64(unsigned a, unsigned b) {
  return (a != 0) && (b != 0);
  // CHECK: landw_i64:
  // CHECK: landw
  // CHECK-NEXT: ret
}

unsigned landw_i32(unsigned a, unsigned b) {
  return (a != 0) && (b != 0);
  // CHECK: landw_i32:
  // CHECK: landw
  // CHECK-NEXT: ret
}

unsigned long lnandw_i64(unsigned a, unsigned b) {
  return (a == 0) || (b == 0);
  // CHECK: lnandw_i64:
  // CHECK: lnandw
  // CHECK-NEXT: ret
}

unsigned lnandw_i32(unsigned a, unsigned b) {
  return (a == 0) || (b == 0);
  // CHECK: lnandw_i32:
  // CHECK: lnandw
  // CHECK-NEXT: ret
}

unsigned long landd_i64(long a, long b) {
  return (a != 0) && (b != 0);
  // CHECK: landd_i64:
  // CHECK: landd
  // CHECK-NEXT: ret
}

unsigned landd_i32(long a, long b) {
  return (a != 0) && (b != 0);
  // CHECK: landd_i32:
  // CHECK: landd
  // CHECK-NEXT: ret
}

unsigned long lnandd_i64(unsigned long a, unsigned long b) {
  return (a == 0) || (b == 0);
  // CHECK: lnandd_i64:
  // CHECK: lnandd
  // CHECK-NEXT: ret
}

unsigned lnandd_i32(unsigned long a, unsigned long b) {
  return (a == 0) || (b == 0);
  // CHECK: lnandd_i32:
  // CHECK: lnandd
  // CHECK-NEXT: ret
}

unsigned long lnandd_f16(_Float16 a, _Float16 b) {
  return (a == 0) || (b == 0);
  // CHECK: lnandd_f16:
  // CHECK: and
  // CHECK-NEXT: ret
}

unsigned long lorw_i32(int a, int b) {
  return (a | b) != 0;
  // CHECK: lorw_i32:
  // CHECK: lorw
  // CHECK-NEXT: ret
}

unsigned long lord_i64(long a, long b) {
  return (a | b) != 0;
  // CHECK: lord_i64:
  // CHECK: lord
  // CHECK-NEXT: ret
}

unsigned long lnorw_i32(int a, int b) {
  return (a | b) == 0;
  // CHECK: lnorw_i32:
  // CHECK: lnorw
  // CHECK-NEXT: ret
}

unsigned long lnord_i64(long a, long b) {
  return (a | b) == 0;
  // CHECK: lnord_i64:
  // CHECK: lnord
  // CHECK-NEXT: ret
}
