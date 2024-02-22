//===-- divmodv8si4.c - Implement __divmodv8si4  -------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements __divmodv8si4 for the kvx compiler_rt library.
//
//===----------------------------------------------------------------------===//

typedef __kvx_v8si v8i32;

typedef __kvx_v8su v8u32;
typedef __kvx_v8du v8u64;

#include "vecMacros.h"

v8i32 __divmodv8si4(v8i32 sa, v8i32 sb, v8i32 *r) {
  v8u32 a = __builtin_elementwise_abs(sa);
  v8u32 b = __builtin_elementwise_abs(sb);
  v8u32 uq;
  udiv(v8u32, 32, v8u64, do, uq, a, b);
  v8i32 q = __builtin_convertvector(uq, v8i32);
  q = __builtin_kvx_selectwo(-q, q, sa ^ sb, ".ltz");

  if (r)
    *r = sa - sb * q;

  return q;
}
