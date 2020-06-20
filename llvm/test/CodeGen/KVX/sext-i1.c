// RUN: clang -S %s -O3 -o - | FileCheck %s

_Bool test(_Bool a) {
  _Bool c = !a;
  return !c;
  // CHECK: test
  // CHECK: ret
}
