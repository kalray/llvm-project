// Check the object file for this c file once, and only once
// RUN: %clang -target kvx-cos-kalray -o /dev/null -### 2>&1 %s | FileCheck %s
// RUN: %clang -target kvx-cos-kalray -rtlib=compiler-rt -o /dev/null -### 2>&1 %s | FileCheck %s

// CHECK: kvx-cos-ld
// CHECK: "{{[^ ]+}}no_duplicate_ld_files-{{[^ ]+}}.o"
// CHECK-NOT: "{{[^ ]+}}no_duplicate_ld_files-{{[^ ]+}}.o"
