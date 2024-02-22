//===-- modv8hi3.c - Implement __modv8hi3 ------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements __modv8hi3 for the kvx compiler_rt library.
//
//===----------------------------------------------------------------------===//

typedef __kvx_v8hu v8u16;
typedef __kvx_v8su v8u32;
typedef __kvx_v8du v8u64;

#include "vecMacros.h"
typedef __kvx_v8hi v8i16;
v8i16 __modv8hi3(v8i16 a, v8i16 b) {
  v8u16 absa = __builtin_elementwise_abs(a);
  v8u16 absb = __builtin_elementwise_abs(b);

  v8u16 umod;
  umod_16(v8u16, v8u64, v8u32, do, wo, umod, absa, absb);
  v8i16 mod = __builtin_convertvector(umod, v8i16);
  return __builtin_kvx_selectho(-mod, mod, a, ".ltz");
}
