// RUN: %clang_cc1 -triple kvx-cos-unknown \
// RUN:   -ast-dump -ast-dump-filter __tca %s | FileCheck %s
// RUN: %clang_cc1 -triple x86_64-unknown-unknown -ast-dump %s | FileCheck %s \
// RUN:   --check-prefix=X86_64
// RUN: %clang_cc1 -triple aarch64-unknown-unknown -ast-dump %s | FileCheck %s \
// RUN:   --check-prefix=ARM
// RUN: %clang_cc1 -triple riscv64-unknown-unknown -ast-dump %s | FileCheck %s \
// RUN:   --check-prefix=RISCV64

// This test case checks that the KVX __tca types are correctly defined.
// These types should only be defined on KVX targets.
// We also added checks on a couple of other targets
// to ensure the types are target-dependent.

// CHECK: TypedefDecl {{.*}} implicit __tca256 '__tca256'
// CHECK-NEXT: -BuiltinType {{.*}} '__tca256'
// CHECK: TypedefDecl {{.*}} implicit __tca512 '__tca512'
// CHECK-NEXT: -BuiltinType {{.*}} '__tca512'
// CHECK: TypedefDecl {{.*}} implicit __tca1024 '__tca1024'
// CHECK-NEXT: -BuiltinType {{.*}} '__tca1024'

// X86_64-NOT: __tca

// ARM-NOT: __tca

// RISCV64-NOT: __tca
