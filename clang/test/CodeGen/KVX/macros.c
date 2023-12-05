// RUN: %clang -target kvx-cos -S -o - %s -E -dM | FileCheck %s --check-prefix V1
// RUN: %clang -target kvx-cos -march=kv3-2 -S -o - %s -E -dM | FileCheck %s --check-prefix V2
// RUN: %clang -target kvx-cos -march=kv4-1 -S -o - %s -E -dM | FileCheck %s --check-prefix V2

// CHECK: #define __KVX_64__ 1
// V1: #define __KV3__ 1
// V2: #define __KV3__ 2
// CHECK: #define __KVX__ 3
// CHECK: #define __bypass __attribute__((address_space(9)))
// V1: #define __kv3__ 1
// V2: #define __kv3__ 2
// CHECK: #define __kvx__ 3
// V1: #define __kvxarch_kv3_1 1
// V2: #define __kvxarch_kv3_2 1
// CHECK: __preload __attribute__((address_space(10)))
// CHECK: __speculate __attribute__((address_space(11)))

void f(void) {
  return;
}
