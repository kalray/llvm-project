// RUN: clang -S -O3 %s -o - | FileCheck %s

long f1(long a, long b) {
  if (a > b)
    return b;
  return a;
  // CHECK: f1
  // CHECK: mind
  // CHECK: ret
}

long f2(long a, long b) {
  return a > b ? b : a;
  // CHECK: f2
  // CHECK: mind
  // CHECK: ret
}

unsigned long f3(unsigned long a, unsigned long b) {
  if (a > b)
    return b;
  return a;
  // CHECK: f3
  // CHECK: minud
  // CHECK: ret
}

unsigned long f4(unsigned long a, unsigned long b) {
  return a > b ? b : a;
  // CHECK: f4
  // CHECK: minud
  // CHECK: ret
}

long f5(long a) {
  return a > 10 ? 10 : a;
  // CHECK: f5
  // CHECK: mind
  // CHECK: ret
}
