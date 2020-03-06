// RUN: clang -target kvx-cos -S -g -O3 %s -o - | FileCheck %s
#define SHIFT_SIZE 1

long long f1(long long a, long long b) {
  return a - (b << SHIFT_SIZE);
  // CHECK: f1
  // CHECK: sbfx2d
  // CHECK: ret
}

long long f2(long long a, long long b) {
  return a - (b * 2);
  // CHECK: f2
  // CHECK: sbfx2d
  // CHECK: ret
}

int f3(int a, int b) {
  return a - (b << SHIFT_SIZE);
  // CHECK: f3
  // CHECK: sbfx2w
  // CHECK: ret
}

int f4(int a, int b) {
  return a - (b * 2);
  // CHECK: f4
  // CHECK: sbfx2w
  // CHECK: ret
}

long long f5(long long a, unsigned b) {
  return a - (b << SHIFT_SIZE);
  // CHECK: f5
  // CHECK: sbfx2uwd
  // CHECK: ret
}

long long f6(long long a, unsigned b) {
  return a - (b * 2);
  // CHECK: f6
  // CHECK: sbfx2uwd
  // CHECK: ret
}

long long f7(long long a, int b) {
  return a - (b << SHIFT_SIZE);
  // CHECK: f7
  // CHECK: sbfx2wd
  // CHECK: ret
}

long long f1imm(long long b) {
  return 12345678901 - (b << SHIFT_SIZE);
  // CHECK: f1imm
  // CHECK: make
  // CHECK: sbfx2d
  // CHECK: ret
}

long long f2imm(long long b) {
  return 12345678901 - (b * 2);
  // CHECK: f2imm
  // CHECK: make
  // CHECK: sbfx2d
  // CHECK: ret
}

int f3imm(int b) {
  return -23456 - (b << SHIFT_SIZE);
  // CHECK: f3imm
  // CHECK: sbfx2w
  // CHECK: ret
}

int f4imm(int b) {
  return -23456 - (b * 2);
  // CHECK: f4imm
  // CHECK: sbfx2w
  // CHECK: ret
}

unsigned long long f5imm(unsigned b) {
  return 123456LL - (b << SHIFT_SIZE);
  // CHECK: f5imm
  // CHECK: sbfx2uwd
  // CHECK: ret
}

unsigned long long f6imm(unsigned b) {
  return 123456LL - (b * 2);
  // CHECK: f6imm
  // CHECK: sbfx2uwd
  // CHECK: ret
}

long long f7imm(int b) {
  return -23456LL - (b << SHIFT_SIZE);
  // CHECK: f7imm
  // CHECK: sbfx2wd
  // CHECK: ret
}
