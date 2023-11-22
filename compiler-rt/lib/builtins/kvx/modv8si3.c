//===-- modv8si3.c - Implement __modv8si3 ------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements __modv8si3 for the kvx compiler_rt library.
//
//===----------------------------------------------------------------------===//

typedef __kvx_v8su v8u32;
typedef __kvx_v8du v8u64;

#include "vecMacros.h"
typedef __kvx_v8si v8i32;
v8i32 __modv8si3(v8i32 a, v8i32 b) {
  v8u32 absa = __builtin_elementwise_abs(a);
  v8u32 absb = __builtin_elementwise_abs(b);

  v8u32 umod;
  umod(v8u32, 32, v8u64, do, umod, absa, absb);
  v8i32 mod = __builtin_convertvector(umod, v8i32);
  return __builtin_kvx_selectwo(-mod, mod, a, ".ltz");
}
