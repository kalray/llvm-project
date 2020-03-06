// RUN: clang -target kvx-cos -S -g -O3 %s -o - | FileCheck %s
#define SHIFT_SIZE 4

long long f1(long long a, long long b) {
  return a + (b << SHIFT_SIZE);
  // CHECK: f1
  // CHECK: addx16d
  // CHECK: ret
}

long long f2(long long a, long long b) {
  return (b << SHIFT_SIZE) + a;
  // CHECK: f2
  // CHECK: addx16d
  // CHECK: ret
}

int f3(int a, int b) {
  return a + (b << SHIFT_SIZE);
  // CHECK: f3
  // CHECK: addx16w
  // CHECK: ret
}

int f4(int a, int b) {
  return (b << SHIFT_SIZE) + a;
  // CHECK: f4
  // CHECK: addx16w
  // CHECK: ret
}

long long f5(long long a, unsigned b) {
  return a + (b << SHIFT_SIZE);
  // CHECK: f5
  // CHECK: addx16uwd
  // CHECK: ret
}

long long f6(long long a, unsigned b) {
  return (b << SHIFT_SIZE) + a;
  // CHECK: f6
  // CHECK: addx16uwd
  // CHECK: ret
}

long long f7(long long a, int b) {
  return a + (b << SHIFT_SIZE);
  // CHECK: f7
  // CHECK: addx16wd
  // CHECK: ret
}

long long f8(long long a, int b) {
  return (b << SHIFT_SIZE) + a;
  // CHECK: f8
  // CHECK: addx16wd
  // CHECK: ret
}

long long f1imm(long long b) {
  return 12345678901 + (b << SHIFT_SIZE);
  // CHECK: f1imm
  // CHECK: make
  // CHECK: addx16d
  // CHECK: ret
}

long long f2imm(long long b) {
  return (b << SHIFT_SIZE) + 12345678901;
  // CHECK: f2imm
  // CHECK: make
  // CHECK: addx16d
  // CHECK: ret
}

int f3imm(int b) {
  return -23456 + (b << SHIFT_SIZE);
  // CHECK: f3imm
  // CHECK: addx16w
  // CHECK: ret
}

int f4imm(int b) {
  return (b << SHIFT_SIZE) - 23456;
  // CHECK: f4imm
  // CHECK: addx16w
  // CHECK: ret
}

unsigned long long f5imm(unsigned b) {
  return 123456LL + (b << SHIFT_SIZE);
  // CHECK: f5imm
  // CHECK: addx16uwd
  // CHECK: ret
}

long long f6imm(unsigned b) {
  return (b << SHIFT_SIZE) + 123456LL;
  // CHECK: f6imm
  // CHECK: addx16uwd
  // CHECK: ret
}

long long f7imm(int b) {
  return -23456LL + (b << SHIFT_SIZE);
  // CHECK: f7imm
  // CHECK: addx16wd
  // CHECK: ret
}

long long f8imm(int b) {
  return (b << SHIFT_SIZE) - 23456LL;
  // CHECK: f8imm
  // CHECK: addx16wd
  // CHECK: ret
}
