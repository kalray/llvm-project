// RUN: clang -S %s -O3 -o - | FileCheck %s

_Bool test1(_Bool a) {
  _Bool c = !a;
  return !c;
  // CHECK: test1
  // CHECK-NOT: sxwd
  // CHECK: ret
}

short test2(short b) {
  return b + 2;
  // CHECK: test2
  // CHECK-NOT: sxwd
  // CHECK: ret
}
