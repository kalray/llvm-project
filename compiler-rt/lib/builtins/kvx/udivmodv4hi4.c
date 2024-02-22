//===-- udivmodv4hi4.c - Implement __udivmodv4hi4 -------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements __udivmodv4hi4 for the kvx compiler_rt library.
//
//===----------------------------------------------------------------------===//

typedef __kvx_v4hu v4u16;
typedef __kvx_v4su v4u32;
typedef __kvx_v4du v4u64;

#include "vecMacros.h"

v4u16 __udivmodv4hi4(v4u16 a, v4u16 b, v4u16 *r) {
  v4u16 q;
  udiv_16(v4u16, v4u64, v4u32, dq, wq, q, a, b);
  if (r)
    *r = a - b * q;

  return q;
}
