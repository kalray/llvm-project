//===-- modv16hi3.c - Implement __modv16hi3 ------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements __modv16hi3 for the kvx compiler_rt library.
//
//===----------------------------------------------------------------------===//

typedef __kvx_v16hu v16u16;
typedef __kvx_v16su v16u32;
typedef __kvx_v16du v16u64;
typedef __kvx_v16hi v16i16;

#include "vecMacros.h"
v16i16 __modv16hi3(v16i16 a, v16i16 b) {
  v16u16 absa = __builtin_elementwise_abs(a);
  v16u16 absb = __builtin_elementwise_abs(b);

  v16u16 ur;
  umod_16(v16u16, v16u64, v16u32, dx, wx, ur, absa, absb);
  v16i16 r = __builtin_convertvector(ur, v16i16);
  return __builtin_kvx_selecthx(-r, r, a, ".ltz");
}
