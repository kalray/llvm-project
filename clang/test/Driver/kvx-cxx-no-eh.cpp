// RUN: %clang++ -fno-exceptions -target kvx-cos -S -v %s -o - |& FileCheck %s

// CHECK-NOT: -fcxx-exceptions
// CHECK-NOT: -fexceptions
// CHECK: test
extern void foo();
void test(void) {
  foo();
}
