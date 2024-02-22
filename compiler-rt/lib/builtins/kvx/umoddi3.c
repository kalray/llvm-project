//===-- umoddi3.c - Implement __umoddi3 for the kvx target ---------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements __umoddi3 for the kvx compiler_rt library.
//
//===----------------------------------------------------------------------===//

#include "../int_lib.h"

du_int __umoddi3(du_int r, du_int den) {
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
