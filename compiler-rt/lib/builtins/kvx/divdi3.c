//===-- divdi3.c - Implement __divdi3        ------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements __divdi3 for the kvx compiler_rt library.
//
//===----------------------------------------------------------------------===//

#include "../int_lib.h"

__inline static du_int UDIV(du_int r, du_int den) {
  du_int denLz = __builtin_clzll(den), rLz = __builtin_clzll(r);
  du_int k = denLz - rLz;

  // __divdi3 did already test for cases where den > r
  if (denLz == rLz)
    return 1;

  du_int q = 0;
  den <<= k;
  if (r >= den) {
    r -= den;
    q = 1LL << k;
  }

  den >>= 1;
  du_int mask = (du_int)(-1L) << k;

  for (int i = k; i > 0; --i)
    r = __builtin_kvx_stsud(den, r);

  return q + r - (r & mask);
}

di_int __divdi3(di_int a, di_int b) {
  du_int an = a < 0;
  di_int bn = b < 0;

  du_int au = (an) ? -a : a;
  du_int bu = (bn) ? -b : b;

  if (bu > au)
    return 0;

  du_int d = UDIV(au, bu);
  return (an ^ bn) ? -d : d;
}
