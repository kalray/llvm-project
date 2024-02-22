// RUN: %clang_cc1 -triple kvx-kalray-cos -emit-llvm-bc -o - -x c %s | llvm-dis | FileCheck %s

__attribute__((mppa_native)) void bar(void) {}

// CHECK-LABEL: @bar(
// CHECK-SAME: #0
// CHECK: attributes #0 = {{{.*}}mppa_native
