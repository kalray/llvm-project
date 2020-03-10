// RUN: clang++ -target kvx-cos -S -v %s -o - |& FileCheck %s

// CHECK-NOT: -fexceptions
// CHECK-NOT: -fxx-exceptions
// CHECK: test

void test(void) {}
