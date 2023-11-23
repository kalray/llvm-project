//===-- udivv16hi3.c - Implement __udivv16hi3 -----------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements __udivv16hi3 for the kvx compiler_rt library.
//
//===----------------------------------------------------------------------===//

typedef __kvx_v16hu v16u16;
typedef __kvx_v16su v16u32;
typedef __kvx_v16du v16u64;

#include "vecMacros.h"
v16u16 __udivv16hi3(v16u16 a, v16u16 b) {
  v16u16 q;
  udiv_16(v16u16, v16u64, v16u32, dx, wx, q, a, b);
  return q;
}
