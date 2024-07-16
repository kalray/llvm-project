// RUN: %clang_cc1 -triple kvx-kalray-cos -emit-llvm -o - -O3 -x c %s | FileCheck %s --implicit-check-not='tail call i16 @llvm.convert.to.fp16.f16'
// CHECK: tail call half @llvm.fabs.f16(half %x)
typedef _Float16 half;
half f (half x) {
    return __builtin_fabsf16 (x);
}
