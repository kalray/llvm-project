// RUN: clang -S -g -O2 %s -o - | FileCheck %s

void f() {
  char a;
  int b;
  int c;
  int d;
  char e;
  // CHECK: f
  // CHECK: .cfi_sections
  // CHECK-NEXT: .cfi_startproc
}

void g() {
  char a;
  char b;
  int c;
  int d;
  int e;
  // CHECK: g
  // CHECK: .cfi_startproc
}

char h() {
  char a[4] = {-1, -2, -3, -4};
  char b[4];

  b[0] = -1;
  b[1] = -2;
  b[2] = -3;
  b[3] = -4;

  return a[0] + a[1] + a[2] + a[3] + b[0] + b[1] + b[2] + b[3];
  // CHECK: h
  // CHECK: .cfi_startproc
}
