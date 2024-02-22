//===-- divmodv16hi4.c - Implement __divmodv16hi4 -------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements __divmodv16hi4 for the kvx compiler_rt library.
//
//===----------------------------------------------------------------------===//

typedef __kvx_v16hu v16u16;
typedef __kvx_v16su v16u32;
typedef __kvx_v16du v16u64;
typedef __kvx_v16hi v16i16;

#include "vecMacros.h"
v16i16 __divmodv16hi4(v16i16 a, v16i16 b, v16i16 *r) {
  v16u16 absa = __builtin_elementwise_abs(a);
  v16u16 absb = __builtin_elementwise_abs(b);

  v16u16 uq;
  udiv_16(v16u16, v16u64, v16u32, dx, wx, uq, absa, absb);
  v16i16 q = __builtin_convertvector(uq, v16i16);
  q = __builtin_kvx_selecthx(-q, q, a ^ b, ".ltz");
  if (r)
    *r = a - b * q;

  return q;
}
