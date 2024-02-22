//===-- divmoddi4 .c - Implement __divmoddi4 ------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements __divmoddi4  for the compiler_rt library.
//
//===----------------------------------------------------------------------===//

#include "../int_lib.h"

di_int __divmoddi4(di_int num, di_int den, di_int *modwanted) {
  int denNeg = den < 0;
  int numNeg = num < 0;

  du_int denU = denNeg ? -den : den;
  du_int numU = numNeg ? -num : num;

  if (denU > numU) {
    if (modwanted)
      *modwanted = num;

    return 0;
  }

  du_int q = 0;
  unsigned k = __builtin_clzll(denU) - __builtin_clzll(numU);
  denU <<= k;

  if (numU >= denU) {
    numU -= denU;
    q = 1LL << k;
  }

  if (k != 0) {
    denU >>= 1;
    du_int mask = (1l << k) - 1;

    for (int i = k; i > 0; --i)
      numU = __builtin_kvx_stsud(denU, numU);

    q += numU & mask;
    numU >>= k;
  }

  if (modwanted)
    *modwanted = numNeg ? -numU : numU;

  return (denNeg ^ numNeg) ? -q : q;
}
