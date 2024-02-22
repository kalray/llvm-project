//===--udivsi3.c - Implement __udivsi3 for the kvx target -----------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements __udivsi3 for the kvx compiler_rt library.
//
//===----------------------------------------------------------------------===//

#include "../int_lib.h"

su_int __udivsi3(su_int r, su_int den) {
  if (den > r)
    return 0;

  su_int denLz = __builtin_clz(den), rLz = __builtin_clz(r);
  su_int k = denLz - rLz;

  if (denLz == rLz)
    return 1;

  su_int q = 0;
  den <<= k;
  if (r >= den) {
    r -= den;
    q = 1 << k;
  }

  den >>= 1;
  su_int mask = (su_int)(-1) << k;

  for (int i = k; i > 0; --i)
    r = __builtin_kvx_stsuw(den, r);

  return q + r - (r & mask);
}
