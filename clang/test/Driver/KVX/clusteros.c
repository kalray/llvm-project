// RUN: %clang -### -target kvx-kalray-cos -L /path/to/check %s 2>&1 | FileCheck %s

// CHECK-NOT: warning: argument unused during compilation: '-L/path/to/check'
// CHECK: -L/path/to/check
