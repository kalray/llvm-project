//===-- divmodv8hi4.c - Implement __divmodv8hi4  -------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements __divmodv8hi4 for the kvx compiler_rt library.
//
//===----------------------------------------------------------------------===//

typedef __kvx_v8hi v8i16;

typedef __kvx_v8hu v8u16;
typedef __kvx_v8su v8u32;
typedef __kvx_v8du v8u64;

#include "vecMacros.h"

v8i16 __divmodv8hi4(v8i16 sa, v8i16 sb, v8i16 *r) {
  v8u16 a = __builtin_elementwise_abs(sa);
  v8u16 b = __builtin_elementwise_abs(sb);
  v8u16 uq;
  udiv_16(v8u16, v8u64, v8u32, do, wo, uq, a, b);
  v8i16 q = __builtin_convertvector(uq, v8i16);
  q = __builtin_kvx_selectho(-q, q, sa ^ sb, ".ltz");

  if (r)
    *r = sa - sb * q;

  return q;
}
