// RUN: %clang_cc1 -triple kvx-kalray-cos -emit-llvm -o - %s | FileCheck %s

// CHECK: _Z2f3Pu8__tca256
void f3(__tca256 *vq) {}

// CHECK: _Z2f3Pu8__tca512
void f3(__tca512 *vp) {}

// CHECK: _Z2f3Pu9__tca1024
void f3(__tca1024 *vp) {}
