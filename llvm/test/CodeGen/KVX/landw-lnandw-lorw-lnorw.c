// RUN: clang -S -O3 %s -o - | FileCheck %s

_Bool f1(int a, int b) {
  return a && b;
  // CHECK: f1
  // CHECK: landw
  // CHECK: ret
}

_Bool f2(int a, int b) {
  return !(a && b);
  // CHECK: f2
  // CHECK: lnandw
  // CHECK: ret
}

_Bool f3(int a, int b) {
  return !a && !b;
  // CHECK: f3
  // CHECK: lnorw
  // CHECK: ret
}

_Bool f4(int a, int b) {
  return a || b;
  // CHECK: f4
  // CHECK: lorw
  // CHECK: ret
}

_Bool f5(int a, int b) {
  return !a || !b;
  // CHECK: f5
  // CHECK: lnandw
  // CHECK: ret
}

_Bool f6(int a, int b) {
  return !(a || b);
  // CHECK: f6
  // CHECK: lnorw
  // CHECK: ret
}
