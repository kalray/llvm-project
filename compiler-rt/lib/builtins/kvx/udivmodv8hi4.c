//===-- udivmodv8hi4.c - Implement __udivmodv8hi4 -------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements __udivmodv8hi4 for the kvx compiler_rt library.
//
//===----------------------------------------------------------------------===//

typedef __kvx_v8hu v8u16;
typedef __kvx_v8su v8u32;
typedef __kvx_v8du v8u64;

#include "vecMacros.h"

v8u16 __udivmodv8hi4(v8u16 a, v8u16 b, v8u16 *r) {
  v8u16 q;
  udiv_16(v8u16, v8u64, v8u32, do, wo, q, a, b);
  if (r)
    *r = a - b * q;

  return q;
}
