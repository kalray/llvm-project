//===-- divsi3.c - Implement __divsi3       ------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements __divsi3 for the kvx compiler_rt library.
//
//===----------------------------------------------------------------------===//

#include "../int_lib.h"

__inline static su_int UDIV(su_int r, su_int den) {
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

si_int __divsi3(si_int a, si_int b) {
  su_int an = a < 0;
  si_int bn = b < 0;

  su_int au = (an) ? -a : a;
  su_int bu = (bn) ? -b : b;

  if (bu > au)
    return 0;

  su_int d = UDIV(au, bu);
  return (an ^ bn) ? -d : d;
}
