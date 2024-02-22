//===--  moddi3.c - Implement  __moddi3 for the kvx target ---------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Implements compiler_rt __moddi3 function for the KVX target.
//
//===----------------------------------------------------------------------===//

#include "../int_lib.h"

__inline static du_int UREM(du_int r, du_int den) {
  if (den >= r)
    return den == r ? 0 : r;

  unsigned k = __builtin_clzll(den) - __builtin_clzll(r);
  den <<= k;

  if (r >= den)
    r -= den;

  if (!k)
    return r;

  den >>= 1;

  for (int i = k; i > 0; --i)
    r = __builtin_kvx_stsud(den, r);

  return r >> k;
}

di_int __moddi3(di_int a, di_int b) {
  di_int aneg = a < 0;

  du_int ua = (aneg) ? -a : a;
  du_int ub = (b < 0) ? -b : b;

  du_int r = UREM(ua, ub);

  return (aneg) ? -r : r;
}
