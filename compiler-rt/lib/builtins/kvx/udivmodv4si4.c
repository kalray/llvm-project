//===--  udivmodv4si4.c - Implement __udivmodv4si4 ------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements __udivmodv4si4 for the kvx compiler_rt library.
//
//===----------------------------------------------------------------------===//

typedef __kvx_v4su v4u32;
typedef __kvx_v4du v4u64;

#include "vecMacros.h"

v4u32 __udivmodv4si4(v4u32 a, v4u32 b, v4u32 *r) {
  v4u32 q;
  udiv(v4u32, 32, v4u64, dq, q, a, b);
  if (r)
    *r = a - q * b;

  return q;
}
