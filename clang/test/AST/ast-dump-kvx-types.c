// RUN: %clang_cc1 -triple kvx-cos-kalray \
// RUN:   -ast-dump -ast-dump-filter __kvx %s | FileCheck %s
// RUN: %clang_cc1 -triple x86_64-unknown-unknown -ast-dump %s | FileCheck %s \
// RUN:   --check-prefix=OTHER
// RUN: %clang_cc1 -triple aarch64-unknown-unknown -ast-dump %s | FileCheck %s \
// RUN:   --check-prefix=OTHER
// RUN: %clang_cc1 -triple riscv64-unknown-unknown -ast-dump %s | FileCheck %s \
// RUN:   --check-prefix=OTHER

// This test case checks that the KVX __kvx_x types are correctly defined.
// These types should only be defined on KVX targets.
// We also added checks on a couple of other targets
// to ensure the types are target-dependent.

// CHECK: TypedefDecl {{.*}} implicit __kvx_x256 '__kvx_x256'
// CHECK-NEXT: -BuiltinType {{.*}} '__kvx_x256'
// CHECK: TypedefDecl {{.*}} implicit __kvx_x512 '__kvx_x512'
// CHECK-NEXT: -BuiltinType {{.*}} '__kvx_x512'
// CHECK: TypedefDecl {{.*}} implicit __kvx_x1024 '__kvx_x1024'
// CHECK-NEXT: -BuiltinType {{.*}} '__kvx_x1024'
// CHECK: TypedefDecl {{.*}} implicit __kvx_x2048 '__kvx_x2048'
// CHECK-NEXT: -BuiltinType {{.*}} '__kvx_x2048'
// CHECK: TypedefDecl {{.*}} implicit __kvx_x4096 '__kvx_x4096'
// CHECK-NEXT: -BuiltinType {{.*}} '__kvx_x4096'

// OTHER-NOT: __kvx_x
