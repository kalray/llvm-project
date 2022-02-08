// RUN: %clang_cc1 -fvisibility default -o - -emit-interface-stubs %s | FileCheck -check-prefix=CHECK-TAPI %s
// FIXME: remove -target x86_64 when kvx does implements all requirements
// RUN: %clang -target x86_64 -fvisibility=default -c -o - %s | llvm-nm - 2>&1 | FileCheck -check-prefix=CHECK-SYMBOLS %s

// CHECK-TAPI: data", Type: Object, Size: 4 }
// CHECK-SYMBOLS: data
int data = 42;
