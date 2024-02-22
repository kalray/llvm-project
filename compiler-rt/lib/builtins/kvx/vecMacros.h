//===----- vecMacros.h - Define general macros for udiv and umod ----------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Define general macros for udiv and umod methods.
// Based in gcc/libgcc/config/kvx/divmodvx* methods, thus TMS320C5x User Guide
//===----------------------------------------------------------------------===//
//   #define STSU(b, r) ( ((r) >= (b)) ? (((r) - (b)) << 1 | 1) : ((r) << 1) )
//
//      divmod_result_t
//      divmodu_3(uint16_t a, uint16_t b)
//      {
//          uint32_t acc = (uint32_t)a;
//          uint32_t src = (uint32_t)b << (16 - 1);
//          uint16_t q = 0, r = a;
//          if (b == 0) TRAP;
//          if (b > a)
//              goto end;
//          for (int i = 0; i < 16; i++) {
//            acc = STSU(src, acc);
//          }
//          q = acc;
//          r = acc >> 16;
//      end:;
//          return (divmod_result_t){ q, r };
//      }
//
// For SIMD execution, we make the if (b > a) path pass through the loop by
// setting src = b << 16 so iterating 16 times acc = STSU(src, acc) computes
// acc == a << 16 then q == 0 and r == a.
//
//      divmod_result_t
//      divmodu_4(uint16_t a, uint16_t b)
//      {
//          uint32_t acc = (uint32_t)a;
//          uint32_t src = (uint32_t)b << (16 - 1);
//          if (b == 0) TRAP;
//          if (b > a)
//            src <<= 1;
//          for (int i = 0; i < 16; i++) {
//            acc = STSU(src, acc);
//          }
//          uint16_t q = acc;
//          uint16_t r = acc >> 16;
//      end:;
//          return (divmod_result_t){ q, r };
//      }
//
//  -- Benoit Dupont de Dinechin (benoit.dinechin@kalray.eu)
//===----------------------------------------------------------------------===//

#define udiv(Ty, TyEltSz, Ety, Suffix, q, a, b)                                \
  Ety eb = __builtin_convertvector(b, Ety);                                    \
  Ety src = eb << (TyEltSz - 1);                                               \
  Ety acc = __builtin_convertvector(a, Ety);                                   \
  Ety src2 = eb << TyEltSz;                                                    \
  src = __builtin_kvx_select##Suffix(src2, src, (eb > acc), ".nez");           \
  for (int i = 0; i < TyEltSz; ++i)                                            \
    acc = __builtin_kvx_stsu##Suffix(src, acc);                                \
  q = __builtin_convertvector(acc, Ty)

#define umod(Ty, TyEltSz, Ety, Suffix, mod, a, b)                              \
  Ety eb = __builtin_convertvector(b, Ety);                                    \
  Ety src = eb << (TyEltSz - 1);                                               \
  Ety acc = __builtin_convertvector(a, Ety);                                   \
  Ety src2 = eb << TyEltSz;                                                    \
  src = __builtin_kvx_select##Suffix(src2, src, (eb > acc), ".nez");           \
  for (int i = 0; i < TyEltSz; ++i)                                            \
    acc = __builtin_kvx_stsu##Suffix(src, acc);                                \
  mod = __builtin_convertvector(acc >> TyEltSz, Ty)

#ifndef __kv3_2__
#define udiv_16(Ty, Ety, Ty32, Suffix64, Suffix32, q, a, b)                    \
  Ty32 eb = __builtin_convertvector(b, Ty32);                                  \
  Ty32 isrc = eb << 15;                                                        \
  Ty32 iacc = __builtin_convertvector(a, Ty32);                                \
  Ty32 src2 = eb << 16;                                                        \
  isrc = __builtin_kvx_select##Suffix32(src2, isrc, (eb > iacc), ".nez");      \
  Ety acc = __builtin_convertvector(iacc, Ety);                                \
  Ety src = __builtin_convertvector(isrc, Ety);                                \
  for (int i = 0; i < 16; ++i)                                                 \
    acc = __builtin_kvx_stsu##Suffix64(src, acc);                              \
  q = __builtin_convertvector(acc, Ty)

#define umod_16(Ty, Ty64, Ty32, Suffix64, Suffix32, mod, a, b)                 \
  Ty32 eb = __builtin_convertvector(b, Ty32);                                  \
  Ty32 isrc = eb << 15;                                                        \
  Ty32 iacc = __builtin_convertvector(a, Ty32);                                \
  Ty32 src2 = eb << 16;                                                        \
  isrc = __builtin_kvx_select##Suffix32(src2, isrc, (eb > iacc), ".nez");      \
  Ty64 src = __builtin_convertvector(isrc, Ty64);                              \
  Ty64 acc = __builtin_convertvector(iacc, Ty64);                              \
  for (int i = 0; i < 16; ++i)                                                 \
    acc = __builtin_kvx_stsu##Suffix64(src, acc);                              \
  mod = __builtin_convertvector(acc >> 16, Ty)
#else
#define udiv_16(Ty, Ty64, Ty32, Suffix64, Suffix32, q, a, b)                   \
  udiv(Ty, 16, Ty32, Suffix32, q, a, b)

#define umod_16(Ty, Ty64, Ty32, Suffix64, Suffix32, q, a, b)                   \
  umod(Ty, 16, Ty32, Suffix32, q, a, b)

#endif
