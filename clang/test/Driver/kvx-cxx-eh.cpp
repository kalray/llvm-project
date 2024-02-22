// RUN: %clang++ -target kvx-cos -S -v %s -o - |& FileCheck %s

// CHECK: -fcxx-exceptions
// CHECK: -fexceptions
// CHECK: test

extern void foo();
void test(void) {
    try {
        foo();
    }
    catch (...){
    }
}
