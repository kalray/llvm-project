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

COMPILER_RT_ABI du_int __udivmoddi4(du_int num, du_int den, du_int *modwanted) {
  du_int r = num, q = 0;

  if (den <= r) {
    unsigned k = __builtin_clzll(den) - __builtin_clzll(r);
    den = den << k;

    if (r >= den) {
      r = r - den;
      q = 1LL << k;
    }

    if (k != 0) {
      unsigned i = k;
      den = den >> 1;

      do {
        r = __builtin_kvx_stsud(den, r);
        i--;
      } while (i != 0);

      q = q + r;
      r = r >> k;
      q = q - (r << k);
    }
  }

  if (modwanted)
    *modwanted = r;

  return q;
}
