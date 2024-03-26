// RUN: %clang -### -target kvx-kalray-cos -L /path/to/check %s 2>&1 | FileCheck %s
// RUN: %clang -v --target=kvx -S -o /dev/null %s 2>&1 | FileCheck %s --check-prefix=TARGET

// CHECK-NOT: warning: argument unused during compilation: '-L/path/to/check'
// CHECK: -L/path/to/check


// RUN: %clang -### -v -march=kv3-1 -nostdlib %s 2>&1 | FileCheck %s --check-prefix=STDLIB 
// STDLIB-NOT: "-Tmppacos.ld"

// TARGET: kvx-kalray-cos
