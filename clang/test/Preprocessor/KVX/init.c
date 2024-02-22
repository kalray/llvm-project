// RUN: %clang_cc1 -x c /dev/null -E -dM -triple=kvx-kalray-cos | FileCheck %s

// CHECK: #define __CHAR16_TYPE__ unsigned short
// CHECK: #define __CHAR32_TYPE__ unsigned int
// CHECK: #define __INT16_TYPE__ short
// CHECK: #define __INT32_TYPE__ int
// CHECK: #define __INT64_TYPE__ long int
// CHECK: #define __INT8_TYPE__ signed char
// CHECK: #define __INTMAX_TYPE__ long int
// CHECK: #define __INTPTR_TYPE__ long int
// CHECK: #define __INT_FAST16_TYPE__ short
// CHECK: #define __INT_FAST32_TYPE__ int
// CHECK: #define __INT_FAST64_TYPE__ long int
// CHECK: #define __INT_FAST8_TYPE__ signed char
// CHECK: #define __INT_LEAST16_TYPE__ short
// CHECK: #define __INT_LEAST32_TYPE__ int
// CHECK: #define __INT_LEAST64_TYPE__ long int
// CHECK: #define __INT_LEAST8_TYPE__ signed char
// CHECK: #define __PTRDIFF_TYPE__ long int
// CHECK: #define __SIZE_TYPE__ long unsigned int
// CHECK: #define __UINT16_TYPE__ unsigned short
// CHECK: #define __UINT32_TYPE__ unsigned int
// CHECK: #define __UINT64_TYPE__ long unsigned int
// CHECK: #define __UINT8_TYPE__ unsigned char
// CHECK: #define __UINTMAX_TYPE__ long unsigned int
// CHECK: #define __UINTPTR_TYPE__ long unsigned int
// CHECK: #define __UINT_FAST16_TYPE__ unsigned short
// CHECK: #define __UINT_FAST32_TYPE__ unsigned int
// CHECK: #define __UINT_FAST64_TYPE__ long unsigned int
// CHECK: #define __UINT_FAST8_TYPE__ unsigned char
// CHECK: #define __UINT_LEAST16_TYPE__ unsigned short
// CHECK: #define __UINT_LEAST32_TYPE__ unsigned int
// CHECK: #define __UINT_LEAST64_TYPE__ long unsigned int
// CHECK: #define __UINT_LEAST8_TYPE__ unsigned char
// CHECK: #define __WCHAR_TYPE__ int
// CHECK: #define __WINT_TYPE__ unsigned int
// KVX: #define __BIGGEST_ALIGNMENT__ 32
