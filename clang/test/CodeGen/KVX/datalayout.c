// RUN: %clang -target kvx-cos -S -emit-llvm %s -o - | FileCheck %s

// CHECK: target datalayout = "e-S256-p:64:64-i1:8-i8:8-i16:16-i32:32-i64:64-v64:64-v128:128-v256:256-v512:256-v1024:256-f16:16-f32:32-f64:64-a:0:64-m:e-n32:64"
// CHECK: main

int main(void) {
  return 0;
}
