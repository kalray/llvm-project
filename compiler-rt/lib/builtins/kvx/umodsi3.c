//===-- umodsi3.c - Implement __umodsi3 for the kvx target ---------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Implements compiler_rt __umodsi3 function for the KVX target.
//
//===----------------------------------------------------------------------===//

#include "../int_lib.h"

su_int __umodsi3(su_int r, su_int den) {
  if (den >= r)
    return den == r ? 0 : r;

  unsigned k = __builtin_clz(den) - __builtin_clz(r);
  den <<= k;

  if (r >= den)
    r -= den;

  if (!k)
    return r;

  den >>= 1;

  for (int i = k; i > 0; --i)
    r = __builtin_kvx_stsuw(den, r);

  return r >> k;
}
