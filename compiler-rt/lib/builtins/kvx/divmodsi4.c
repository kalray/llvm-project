//===-- divmodsi4 .c - Implement __divmodsi4 ------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements __divmodsi4  for the compiler_rt library.
//
//===----------------------------------------------------------------------===//

#include "../int_lib.h"

si_int __divmodsi4(si_int num, si_int den, si_int *modwanted) {
  int denNeg = den < 0;
  int numNeg = num < 0;

  su_int denU = denNeg ? -den : den;
  su_int numU = numNeg ? -num : num;

  if (denU > numU) {
    if (modwanted)
      *modwanted = num;

    return 0;
  }

  su_int q = 0;
  unsigned k = __builtin_clz(denU) - __builtin_clz(numU);
  denU <<= k;

  if (numU >= denU) {
    numU -= denU;
    q = 1LL << k;
  }

  if (k != 0) {
    denU >>= 1;
    su_int mask = (1 << k) - 1;

    for (int i = k; i > 0; --i)
      numU = __builtin_kvx_stsuw(denU, numU);

    q += numU & mask;
    numU >>= k;
  }

  if (modwanted)
    *modwanted = numNeg ? -numU : numU;

  return (denNeg ^ numNeg) ? -q : q;
}
