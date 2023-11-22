//===-- udivv8si3.c - Implement __udivv8si3  -------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements __udivv8si3 for the kvx compiler_rt library.
//
//===----------------------------------------------------------------------===//

typedef __kvx_v8su v8u32;
typedef __kvx_v8du v8u64;

#include "vecMacros.h"

v8u32 __udivv8si3(v8u32 a, v8u32 b) {
  v8u32 q;
  udiv(v8u32, 32, v8u64, do, q, a, b);

  return q;
}
