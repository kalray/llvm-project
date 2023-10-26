//===-- udivmoddi4.c - Implement __udivmoddi4------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements __udivmoddi4 for the compiler_rt library.
//
//===----------------------------------------------------------------------===//

#include "../int_lib.h"

du_int __udivmoddi4(du_int num, du_int den, du_int *modwanted) {
  if (den > num) {
    if (modwanted)
      *modwanted = num;

    return 0;
  }

  du_int q = 0;
  unsigned k = __builtin_clzll(den) - __builtin_clzll(num);
  den <<= k;

  if (num >= den) {
    num -= den;
    q = 1LL << k;
  }

  if (k != 0) {
    den >>= 1;
    du_int mask = (du_int)(-1l) << k;

    for (int i = k; i > 0; --i)
      num = __builtin_kvx_stsud(den, num);

    q += num - (num & mask);
    num >>= k;
  }

  if (modwanted)
    *modwanted = num;

  return q;
}
