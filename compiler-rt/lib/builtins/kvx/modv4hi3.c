//===-- modv4hi3.c - Implement __modv4hi3 ------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements __modv4hi3 for the kvx compiler_rt library.
//
//===----------------------------------------------------------------------===//

typedef __kvx_v4hu v4u16;
typedef __kvx_v4su v4u32;
typedef __kvx_v4du v4u64;

#include "vecMacros.h"
typedef __kvx_v4hi v4i16;
v4i16 __modv4hi3(v4i16 a, v4i16 b) {
  v4u16 absa = __builtin_elementwise_abs(a);
  v4u16 absb = __builtin_elementwise_abs(b);

  v4u16 umod;
  umod_16(v4u16, v4u64, v4u32, dq, wq, umod, absa, absb);
  v4i16 mod = __builtin_convertvector(umod, v4i16);
  return __builtin_kvx_selecthq(-mod, mod, a, ".ltz");
}
