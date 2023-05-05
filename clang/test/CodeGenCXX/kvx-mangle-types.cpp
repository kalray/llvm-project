// RUN: %clang_cc1 -triple kvx-kalray-cos -emit-llvm -o - %s | FileCheck %s

// CHECK: __kvx_x256
void f3(__kvx_x256 *vq) {}

// CHECK: __kvx_x512
void f3(__kvx_x512 *vp) {}

// CHECK: __kvx_x1024
void f3(__kvx_x1024 *vp) {}

// CHECK: __kvx_x2048
void f4(__kvx_x2048 *vp) {}

// CHECK: __kvx_x4096
void f5(__kvx_x4096 *vp) {}
