//===--udivdi3.c - Implement __udivdi3      ------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements __udivdi3 for the kvx compiler_rt library.
//
//===----------------------------------------------------------------------===//

#include "../int_lib.h"

du_int __udivdi3(du_int r, du_int den) {
  if (den > r)
    return 0;

  du_int denLz = __builtin_clzll(den), rLz = __builtin_clzll(r);
  int k = denLz - rLz;

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
