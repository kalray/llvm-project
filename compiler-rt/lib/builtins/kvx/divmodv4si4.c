//===-- divmodv4si4.c - Implement __divmodv4si4
//------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements __divmodv4si4 for the kvx compiler_rt library.
//
//===----------------------------------------------------------------------===//

typedef __kvx_v4su v4u32;
typedef __kvx_v4du v4u64;
typedef __kvx_v4si v4i32;

#include "vecMacros.h"

v4i32 __divmodv4si4(v4i32 a, v4i32 b, v4i32 *r) {
  v4u32 absa = __builtin_elementwise_abs(a);
  v4u32 absb = __builtin_elementwise_abs(b);

  v4u32 uq;
  udiv(v4u32, 32, v4u64, dq, uq, absa, absb);
  v4i32 q = __builtin_convertvector(uq, v4i32);
  q = __builtin_kvx_selectwq(-q, q, a ^ b, ".ltz");

  if (r)
    *r = a - q * b;

  return q;
}
