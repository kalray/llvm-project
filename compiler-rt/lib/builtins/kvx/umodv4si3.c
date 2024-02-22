//===--  umodv4si3.c - Implement __umodv4si3 ------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===---------------------------------------------------------------------===//
//
// This file implements __umodv4si3 for the kvx compiler_rt library.
//
//===----------------------------------------------------------------------===//

typedef __kvx_v4su v4u32;
typedef __kvx_v4du v4u64;

#include "vecMacros.h"

v4u32 __umodv4si3(v4u32 a, v4u32 b) {
  v4u32 rem;
  umod(v4u32, 32, v4u64, dq, rem, a, b);

  return rem;
}
