// RUN: clang -S -O3 %s -o - | FileCheck %s

int f1(int a, int b) {
  if (a < b)
    return b;
  return a;
  // CHECK: f1
  // CHECK: maxw
  // CHECK: ret
}

int f2(int a, int b) {
  return a < b ? b : a;
  // CHECK: f2
  // CHECK: maxw
  // CHECK: ret
}

unsigned int f3(unsigned int a, unsigned int b) {
  if (a < b)
    return b;
  return a;
  // CHECK: f3
  // CHECK: maxuw
  // CHECK: ret
}

unsigned int f4(unsigned int a, unsigned int b) {
  return a < b ? b : a;
  // CHECK: f4
  // CHECK: maxuw
  // CHECK: ret
}

int f5(int a) {
  return a < 10 ? 10 : a;
  // CHECK: f5
  // CHECK: maxw
  // CHECK: ret
}
