//===-- divmodv4hi4.c - Implement __divmodv4hi4 ---------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements __divmodv4hi4 for the kvx compiler_rt library.
//
//===----------------------------------------------------------------------===//

typedef __kvx_v4hu v4u16;
typedef __kvx_v4su v4u32;
typedef __kvx_v4du v4u64;

typedef __kvx_v4hi v4i16;

#include "vecMacros.h"

v4i16 __divmodv4hi4(v4i16 a, v4i16 b, v4i16 *r) {
  v4u16 absa = __builtin_elementwise_abs(a);
  v4u16 absb = __builtin_elementwise_abs(b);

  v4u16 uq;
  udiv_16(v4u16, v4u64, v4u32, dq, wq, uq, absa, absb);
  v4i16 q = __builtin_convertvector(uq, v4i16);
  q = __builtin_kvx_selecthq(-q, q, a ^ b, ".ltz");
  if (r)
    *r = a - b * q;

  return q;
}
