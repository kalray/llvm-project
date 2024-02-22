//===-- udivmoddi4.c - Implement __udivmoddi4------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements __udivmodsi4 for the compiler_rt library.
//
//===----------------------------------------------------------------------===//

#include "../int_lib.h"

su_int __udivmodsi4(su_int num, su_int den, su_int *modwanted) {
  su_int r = num, q = 0;

  if (den <= r) {
    unsigned k = __builtin_clz(den) - __builtin_clz(r);
    den = den << k;

    if (r >= den) {
      r = r - den;
      q = 1LL << k;
    }

    if (k != 0) {
      unsigned i = k;
      den = den >> 1;

      do {
        r = __builtin_kvx_stsuw(den, r);
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
