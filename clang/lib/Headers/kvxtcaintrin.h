/*===----- kvxtcaintrin.h - Kalray MPPA TCA intrinsics header file ----------===
 *
 * Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
 * See https://llvm.org/LICENSE.txt for license information.
 * SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
 *
 *===------------------------------------------------------------------------===
 */

#pragma once
#ifndef __KVXTCAINTRIN_H_
#define __KVXTCAINTRIN_H_

#warning "You are including kvxtcaintrin.h: this header file will be removed in\
ACB 4.10 in favor of the new TCA builtins. Please update your code to use the\
new builtins instead."

// FIXME: Generic vector types declarations should not be here.
typedef char  char32     __attribute__((vector_size(32 * sizeof(char))));
typedef short short16    __attribute__((vector_size(16 * sizeof(short))));
typedef int   int8       __attribute__((vector_size(8 *  sizeof(int))));
typedef long  long4      __attribute__((vector_size(4 *  sizeof(long))));

typedef _Float16 half16  __attribute__((vector_size(16 * sizeof(_Float16))));
typedef float    float8  __attribute__((vector_size(8 *  sizeof(float))));
typedef double   double4 __attribute__((vector_size(4 *  sizeof(double))));

// TCA opaque data types:
typedef __kvx_x256 tca256_t;   // Maps to a variable that is held in a VectorReg
typedef __kvx_x512 tca512_t;   // Maps to a variable that is held in a WideReg
typedef __kvx_x1024 tca1024_t; // Maps to a variable that is held in a MatrixReg

/// TCA registers layout:
/// The base unit is a Vector Register (__kvx_x256).
/// A Wide Register (__kvx_x512) is built with two Vector Registers.
/// A Matrix Register (__kvx_x1024) is built with four Vector Registers or two
/// Wide Registers.
/// Each most significant half part of a matrix or wide can be addressed as
/// the immediate smaller vector type Hi side. The least significant is the Lo
/// side.
/// A wide register always starts in a pair numbered Vector Register.
/// A matrix register always starts in a Vector Register multiple of 4 starting
/// from 0.
/// |--VecReg--|
/// |-------WideReg-------|
/// |-vecReg1--|-vecReg0--|
/// |-vecRegHi-|-vecRegLo-|
/// |-----------------MatrixReg-----------------|
/// |------WideRegHi------|------WideRegLo------|
/// |-vecReg3--|-vecReg2--|-vecReg1--|-vecReg0--|
/// |-vecRegK--|-vecRegZ--|-vecRegY--|-vecRegX--|

/// Modifier type [Accepted modifier strings. A single dot '.' can be omitted.]
/// Rectify: [. .relu]
/// Roundint: [.rn .ru .rd .rz .rhu]
/// Saturate: [.sat .satu]
/// ScalarCond: [ .dnez .deqz .dltz .dgez .dlez .dgtz .odd .even .wnez .weqz .wltz .wgez .wlez .wgtz ]
/// Speculate: [. .s]
/// silent2: [. .s]
/// xrounding: [.rn .ru .rd .rz .rna .rnz .ro .]

/// Inplace set high half of a tca256_t type V to (h,l).
// tca256_t __builtin_kvx_xmovetohi (tca256_t V, int64_t h, int64_t l);

/// Inplace set lower half of a tca256_t type V to (h,l).
// tca256_t __builtin_kvx_xmovetolo (tca256_t V, int64_t h, int64_t l);

/// Build vector type (hh, hl, lh, ll).
// tca256_t __builtin_kvx_xmoveto (int64_t hh, int64_t hl, int64_t lh, int64_t ll);

/// Copy 256 bits to a vector type from a core QuadRegister.
// tca256_t __builtin_kvx_xmoveoto (long4 Oct);

/// Copy 256 bits from a tca register to a core register.
// long4 __builtin_kvx_xmovefo (tca256_t V);

/// Insert wide type W into matrix type M in position p [0-1]
// tca1024_t __builtin_kvx_xinsertwm (tca1024_t M, tca512_t W, unsigned p);

/// Insert vector type V into matrix type M in position p [0-3]
// tca1024_t __builtin_kvx_xinsertvm (tca1024_t M, tca256_t V, unsigned p);

/// Insert vector type V into wide type W in position p [0-1]
// tca512_t __builtin_kvx_xinsertvw (tca512_t W, tca256_t V, unsigned p);

/// Retrieve wide type W at position p [0-1] from matrix type M
// tca512_t __builtin_kvx_xmovefmw (tca1024_t M, unsigned p);

/// Retrieve vector type V at position p [0-3] from matrix type M
// tca256_t __builtin_kvx_xmovefmv (tca1024_t M, unsigned p);

/// Retrieve vector type V at position p [0-1] from wide type W
// tca256_t __builtin_kvx_xmovefwv (tca512_t W, unsigned p);

/// Build a matrix type from the four vectors V0,V1,V2,V3
// tca1024_t __builtin_kvx_xbuildfvm (tca256_t V0, tca256_t V1, tca256_t V2, tca256_t V3);

/// Build a matrix type from the two wide W0,W1
// tca1024_t __builtin_kvx_xbuildfwm (tca512_t W0, tca512_t W1);

/// Build a wide from the two vectors V0,V1
// tca512_t __builtin_kvx_xbuildfvw (tca256_t V0, tca256_t V1);

/// tca256_t Funnel-logical-shift-bytes-right wide vector `buf`.
/// Returns `buf >> 8 * index` in a TCA VectorReg
/// Where 0 <= index < 64 is the shift number of bytes.
// tca256_t __builtin_kvx_xalign512o (tca512_t buf, uint64_t index);

/// tca256_t Funnel-logical-shift-bytes-right wide vector `buf`.
/// Returns `buf >> 8 * index` in a core QuadRegister.
//  Where 0 <= index < 64 is the shift number of bytes.
// long4 __builtin_kvx_xaccess512o (tca512_t buf, uint64_t index);

/// Swap values of a tca256_t and a core QuadRegister.
// long4 __builtin_kvx_xswap256 (tca256_t *v, long4 gpr);

/// Truncate the lower half matrix (4x2) of a 4x4 matrix of doubles M to a 4x2
/// matrix of halfs and write it to the lower part of vector V. If the assigned
/// vector is not the input vector V, a copy of V is performed before to the
/// output, as to preserve the upper half.
/// Modifiers: Roundint, Saturate
// tca256_t __builtin_kvx_xconvdhv0 (tca256_t V, tca1024_t M, const char *mods);

/// Truncate the upper half matrix (4x2) of a 4x4 matrix of doubles M to a 4x2
/// matrix of halfs and write it to the upper part of vector V. If the assigned
/// vector is not the input vector V, a copy of V is performed before to the
/// output, as to preserve the lower half.
/// Modifiers: Roundint, Saturate
// tca256_t __builtin_kvx_xconvdhv1 (tca256_t V, tca1024_t M, const char *mods);

/// Truncate the 4x4 matrix of doubles M to a 4x4 matrix of halfs.
/// Modifiers: Roundint, Saturate
// tca256_t __builtin_kvx_xconvdhv (tca1024_t M, const char *mods);

/// The behaviors of xconvwbv[0123]? depend on CS.XDROP
/// The description of these functions are only valid if CS.XDROP==0
/// If CS.XDROP != 0, these functions behave the same as their respective
/// instructions.

/// Truncate the first quarter (2x4) of a 4x8 matrix of integers M to a 2x4
/// matrix of chars and write in the first quarter of vector V. If the assigned
/// vector is not the input vector V, a copy of V is performed before to the
/// output, as to preserve other quarters.
/// Modifiers: Roundint, Saturate
// tca256_t __builtin_kvx_xconvwbv0 (tca256_t V, tca1024_t M, const char *mods);

/// Truncate the second quarter (2x4) of a 4x8 matrix of integers M to a 2x4
/// matrix of chars and write in the second quarter of vector V. If the assigned
/// vector is not the input vector V, a copy of V is performed before to the
/// output, as to preserve other quarters.
/// Modifiers: Roundint, Saturate
// tca256_t __builtin_kvx_xconvwbv1 (tca256_t V, tca1024_t M, const char *mods);

/// Truncate the third quarter (2x4) of a 4x8 matrix of integers to a 2x4 matrix
/// of chars and write in the third quarter of vector V.
/// If the assigned vector is not the input vector V, a copy of V is performed
/// before to the output, as to preserve other quarters.
/// Modifiers: Roundint, Saturate
// tca256_t __builtin_kvx_xconvwbv2 (tca256_t V, tca1024_t M, const char *mods);

/// Truncate the last quarter (2x4) of a 4x8 matrix of integers M to a 2x4
/// matrix of chars and write in the last quarter of vector V. If the assigned
/// vector is not the input vector V, a copy of V is performed before to the
/// output, as to preserve other quarters.
/// Modifiers: Roundint, Saturate
// tca256_t __builtin_kvx_xconvwbv3 (tca256_t V, tca1024_t M, const char *mods);

/// Truncate the 4x8 matrix of integers M to a 4x8 matrix of chars.
/// Modifiers: Roundint, Saturate
// tca256_t __builtin_kvx_xconvwbv (tca1024_t M, const char *mods);

/// Let W be a 4x4 matrix of floats, V1 and V2 be 2x4 matrixes of half floats
/// and V0 a matrix of 2x4 floats.
/// Add the first quarter (2x2) of W to the matrix multiply of V1 by the transposed (V2).
/// Write the result into the first half of V0 and return the resulting 2x4 matrix V0.
/// Makes V0 = {W[0] + V1 * T(V2), V0[1]}.
/// Returns V0.
// tca256_t __builtin_kvx_xfmma242hw0 (tca256_t V0,  tca512_t W,  tca256_t V1, tca256_t V2);

/// Let W be a 4x4 matrix of floats, V1 and V2 be 2x4 matrixes of half floats
/// and V0 a matrix of 2x4 floats.
/// Add the second quarter (2x2) of W to the matrix multiply of V1 by the transposed (V2).
/// Write the result into the second half of V0 and return the resulting 2x4 matrix V0.
/// Makes V0 = {V0[0], W[1] + V1 * T(V2)}.
/// Returns V0.
// tca256_t __builtin_kvx_xfmma242hw1 (tca256_t V0,  tca512_t W,  tca256_t V1, tca256_t V2);

/// Let W be a 4x4 matrix of floats, V1 and V2 be 2x4 matrixes of half floats
/// and V0 a matrix of 2x4 floats.
/// Add the third quarter (2x2) of W to the matrix multiply of V1 by the transposed (V2).
/// Write the result into the first half of V0 and return the resulting 2x4 matrix V0.
/// Makes V0 = {W[2] + V1 * T(V2), V0[1]}.
/// Returns V0.
// tca256_t __builtin_kvx_xfmma242hw2 (tca256_t V0,  tca512_t W,  tca256_t V1, tca256_t V2);

/// Let W be a 4x4 matrix of floats, V1 and V2 be 2x4 matrixes of half floats
/// and V0 a matrix of 2x4 floats.
/// Add the fourth quarter (2x2) of W to the matrix multiply of V1 by the transposed (V2).
/// Write the result into the second half of V0 and return the resulting 2x4 matrix V0.
/// Makes V0 = {V0[0], W[3] + V1 * T(V2)}.
/// Returns V0.
// tca256_t __builtin_kvx_xfmma242hw3 (tca256_t V0,  tca512_t W,  tca256_t V1, tca256_t V2);

/// Let W be a 4x4 matrix of floats, V0 and V1 be 2x4 matrixes of half floats.
/// Add to each quarter of W the matrix multiply of V0 by the transposed
/// (V1). W = W[0-3] + V0 X T(V1).
// tca512_t __builtin_kvx_xfmma444hw (tca512_t W, tca256_t V0, tca256_t V1);

/// Let M be a 4x4 matrix of int64_t,
/// V0 a 4x4 matrix of signed short and
/// V1 a 4x8 matrix of signed char.
/// V1' is the first half of V1, giving a 4x4 matrix of signed char.
/// Returns the 4x4 matrix of int64_t = M + V0 x transposed (V1').
// tca1024_t __builtin_kvx_xmma444hbd0 (tca1024_t M, tca256_t V0, tca256_t V1);

/// Let M be a 4x4 matrix of int64_t,
/// V0 a 4x4 matrix of signed short and
/// V1 a 4x8 matrix of char.
/// V1' is the second half of V1, giving a 4x4 matrix of char.
/// Returns the 4x4 matrix of int64_t = M + V0 x transposed (V1').
// tca1024_t __builtin_kvx_xmma444hbd1 (tca1024_t M, tca256_t V0, tca256_t V1);

/// Let M be a 4x4 matrix of int64_t,
/// V0 a 4x8 matrix of signed short and
/// V1 a 4x8 matrix of char.
/// Returns M + V0 x transposed (V1)
// tca1024_t __builtin_kvx_xmma484hbd (tca1024_t M, tca512_t V0, tca256_t V1);

/// Let M be a 4x4 matrix of int64_t,
/// V0 and V1 4x4 matrixes of signed short.
/// Returns the 4x4 matrix of int64_t = M + V0 x transposed (V1).
// tca1024_t __builtin_kvx_xmma444hd (tca1024_t M, tca256_t V0, tca256_t V1);

/// Let M be a 4x4 matrix of int64_t,
/// V0 a 4x4 matrix of signed short and
/// V1 a 4x8 matrix of unsigned char.
/// V1' is the second half of V1, giving a 4x4 matrix of unsigned char.
/// Returns the 4x4 matrix of int64_t = M + V0 x transposed (V1').
// tca1024_t __builtin_kvx_xmma444suhbd0 (tca1024_t M, tca256_t V0, tca256_t V1);

/// Let M be a 4x4 matrix of int64_t,
/// V0 a 4x4 matrix of signed short and
/// V1 a 4x8 matrix of unsigned char.
/// V1' is the second half of V1, giving a 4x4 matrix of unsigned char.
/// Returns the 4x4 matrix of int64_t = M + V0 x transposed (V1').
// tca1024_t __builtin_kvx_xmma444suhbd1 (tca1024_t M, tca256_t V0, tca256_t V1);

/// Let M be a 4x4 matrix of int64_t,
/// V0 a 4x8 matrix of signed short and
/// V1 a 4x8 matrix of unsigned char.
/// Returns the 4x4 matrix of int64_t = M + V0 x transposed (V1).
// tca1024_t __builtin_kvx_xmma484suhbd (tca1024_t M, tca512_t V0, tca256_t V1);

/// Let M be a 4x4 matrix of int64_t,
/// V0 a 4x4 matrixes of signed short and
/// V1 a 4x4 matrixes of unsigned short.
/// Returns M + V0 x transposed (V1).
// tca1024_t __builtin_kvx_xmma444suhd (tca1024_t M, tca256_t V0, tca256_t V1);

/// Let M be a 4x4 matrix of int64_t,
/// V0 a 4x4 matrix of unsigned short,
/// V1 a 4x8 matrix of unsigned char.
/// V1' is the second half of V1, giving a 4x4 matrix of unsigned char.
/// Returns the 4x4 matrix of int64_t = M + V0 x transposed (V1')
// tca1024_t __builtin_kvx_xmma444uhbd0 (tca1024_t M, tca256_t V0, tca256_t V1);

/// Let M be a 4x4 matrix of int64_t,
/// V0 a 4x4 matrix of unsigned short.
/// V1 a 4x8 matrix of unsigned char.
/// V1' is the second half of V1, giving a 4x4 matrix of unsigned char.
/// Returns the 4x4 matrix of int64_t = M + V0 x transposed (V1')
// tca1024_t __builtin_kvx_xmma444uhbd1 (tca1024_t M, tca256_t V0, tca256_t V1);

/// Let M be a 4x4 matrix of int64_t,
/// V0 a 4x8 matrix of unsigned short.
/// V1 a 4x8 matrix of unsigned char.
/// Returns the 4x4 matrix of int64_t = M + V0 x transposed (V1)
// tca1024_t __builtin_kvx_xmma484uhbd (tca1024_t M, tca512_t V0, tca256_t V1);

/// Let M be a 4x4 matrix of int64_t,
/// V0 and V1 4x4 matrixes of unsigned short.
/// Returns the 4x4 matrix of int64_t M + V0 x transposed(V1)
// tca1024_t __builtin_kvx_xmma444uhd (tca1024_t M, tca256_t V0, tca256_t V1);

/// Let M be a 4x4 matrix of int64_t,
/// V0 a 4x4 matrix of unsigned short and
/// V1 a 4x8 matrix of char.
/// V1' is the first half of V1, giving a 4x4 matrix of char.
/// Returns the 4x4 matrix of int64_t = M + V0 x transposed (V1').
// tca1024_t __builtin_kvx_xmma444ushbd0 (tca1024_t M, tca256_t V0, tca256_t V1);

/// Let M be a 4x4 matrix of int64_t,
/// V0 a 4x4 matrix of unsigned short,
/// V1 a 4x8 matrix of char.
/// V1' is the second half of V1, giving a 4x4 matrix of char.
/// Returns the 4x4 matrix of int64_t = M + V0 x transposed (V1')
// tca1024_t __builtin_kvx_xmma444ushbd1 (tca1024_t M, tca256_t V0, tca256_t V1);

/// Let M be a 4x4 matrix of int64_t,
/// V0 a 4x8 matrix of unsigned short,
/// V1 a 4x8 matrix of char.
/// Returns the 4x4 matrix of int64_t = M + V0 x transposed (V1)
// tca1024_t __builtin_kvx_xmma484ushbd (tca1024_t M, tca512_t V0, tca256_t V1);

/// Let M be a 4x4 matrix of int64_t,
/// V0 is 4x4 matrixes of unsigned short and
/// V1 is 4x4 matrixes of signed short.
/// Returns the 4x4 matrix of int64_t M + V0 x transposed (V1).
// tca1024_t __builtin_kvx_xmma444ushd (tca1024_t M, tca256_t V0, tca256_t V1);

/// Let W be a 4x4 matrix of int32_t,
/// V0 and V1 4x8 matrixes of char.
/// Returns W + V0 x transposed (V1).
// tca512_t __builtin_kvx_xmma484bw (tca512_t W, tca256_t V0, tca256_t V1);

/// Let W be a 4x4 matrix of int32_t,
/// V0 a 4x8 matrix of char and
/// V1 a 4x8 matrix of unsigned char.
/// Returns W + V0 x transposed (V1).
// tca512_t __builtin_kvx_xmma484subw (tca512_t W, tca256_t V0, tca256_t V1);

/// Let W be a 4x4 matrix of int32_t,
/// V0 and V1 4x8 matrixes of unsigned char.
/// Returns W + V0 x transposed (V1).
// tca512_t __builtin_kvx_xmma484ubw (tca512_t W, tca256_t V0, tca256_t V1);

/// Lew W be a 4x4 matrix of int32_t,
/// V0 a 4x8 matrix of unsigned char and
/// V1 a 4x8 matrix of char.
/// Returns w + V0 x transposed (V1).
// tca512_t __builtin_kvx_xmma484usbw (tca512_t W, tca256_t V0, tca256_t V1);

/// Transpose a 4x4 matrix of double words.
// tca1024_t __builtin_kvx_xmt44d (tca1024_t M);

/// Scales the vector of 8 floats V by the power of 2 given in the
/// xrounding modifier.
/// Modifiers: xrounding, silent2, rectify
// tca256_t __builtin_kvx_xfscalewv (tca256_t V, const char *mods);

/// Truncates the vector of 16 floats to a vector of 16 halfs, following the
/// rounding defined by xrounding.
/// Modifers: xrounding, silent2
// tca256_t __builtin_kvx_xfnarrowwhv (tca512_t W, const char *mods);

/// Load a tca256_t V from memory address p.
/// Modifiers: uncached speculate (".u" or ".us")
// tca256_t __builtin_kvx_xload256 (tca256_t *ptr, const char *mods);

/// Conditionally load a tca256_t V from memory address p if
// (evaluate (ScalarCond, condition)) == true.
/// Modifer: ScalarCond
// tca256_t __builtin_kvx_xloadc256 (tca256_t V, tca256_t *p, int64_t condition, const char *mods);

/// Assuming M is a 4x4 matrix of int64_t, this loads a 1x4 matrix of int64_t,
/// and transpose it into the `column` of M (q0 = column 0, q1 = column 1, etc.).
// Load a 256-bit data:
/// <----------------- 256-bit ----------------->
/// +----------+----------+----------+----------+
/// |    L0    |    L1    |    L2    |    L3    |
/// +----------+----------+----------+----------+
/// and dispatch into tca1024_t:
/// if column = 0:
/// +----------+----------+----------+----------+
/// |    L0    |          |          |          |
/// +----------+----------+----------+----------+
/// |    L1    |          |          |          |
/// +----------+----------+----------+----------+
/// |    L2    |          |          |          |
/// +----------+----------+----------+----------+
/// |    L3    |          |          |          |
/// +----------+----------+----------+----------+
/// if column = 1:
/// +----------+----------+----------+----------+
/// |          |    L0    |          |          |
/// +----------+----------+----------+----------+
/// |          |    L1    |          |          |
/// +----------+----------+----------+----------+
/// |          |    L2    |          |          |
/// +----------+----------+----------+----------+
/// |          |    L3    |          |          |
/// +----------+----------+----------+----------+
/// and so on for column = 2, 3
/// Modifier: SpeculateMod
// tca1024_t __builtin_kvx_xload1024q0 (tca1024_t M, tca256_t *p, const char *mods);
// tca1024_t __builtin_kvx_xload1024q1 (tca1024_t M, tca256_t *p, const char *mods);
// tca1024_t __builtin_kvx_xload1024q2 (tca1024_t M, tca256_t *p, const char *mods);
// tca1024_t __builtin_kvx_xload1024q3 (tca1024_t M, tca256_t *p, const char *mods);

/// Assuming M is a 4x4 matrix of int64_t, this conditionally loads a 1x4
/// matrix of int64_t, and transpose it into the `column` of M if (evaluated true
/// (ScalarCond, condition)).
/// Modifier: SpeculateMod, ScalarCond
// tca1024_t __builtin_kvx_xloadc1024q0 (tca1024_t M, tca256_t *p, int64_t condition, const char *mods);
// tca1024_t __builtin_kvx_xloadc1024q1 (tca1024_t M, tca256_t *p, int64_t condition, const char *mods);
// tca1024_t __builtin_kvx_xloadc1024q2 (tca1024_t M, tca256_t *p, int64_t condition, const char *mods);
// tca1024_t __builtin_kvx_xloadc1024q3 (tca1024_t M, tca256_t *p, int64_t condition, const char *mods);

/// Store a tca256_t V to memory address p
// void __builtin_kvx_xstore256 (tca256_t V, tca256_t *p);

/// Conditionally store a tca256_t V to memory address p if (evaluate
/// (ScalarCond, condition)).
/// Modifiers: ScalarCond
// void __builtin_kvx_xstorec256 (tca256_t *p, tca256_t V, int64_t condition, const char *mods);

/// Copy a 32 x char vector from the TCA to the core.
__attribute__((deprecated)) inline char32 __builtin_kvx_movefobv(tca256_t *v) {
  return (char32)__builtin_kvx_movefo(*v);
}

/// Copy a 16 x short vector from the TCA to the core.
__attribute__((deprecated)) inline short16 __builtin_kvx_movefohx(tca256_t *v) {
  return (short16)__builtin_kvx_movefo(*v);
}

/// Copy a 8 x int vector from the TCA to the core.
__attribute__((deprecated)) inline int8 __builtin_kvx_movefowo(__kvx_x256 *v) {
  return (int8)__builtin_kvx_movefo(*v);
}

/// Copy a 4 x long vector from the TCA to the core.
__attribute__((deprecated)) inline long4 __builtin_kvx_movefodq(__kvx_x256 *v) {
  return (long4)__builtin_kvx_movefo(*v);
}

/// Copy a 16 x _Float16 vector from the TCA to the core.
__attribute__((deprecated)) inline half16 __builtin_kvx_movefofhx(tca256_t *v) {
  return (half16)__builtin_kvx_movefo(*v);
}

/// Copy a 8 x float vector from the TCA to the core.
__attribute__((deprecated)) inline float8 __builtin_kvx_movefofwo(__kvx_x256 *v) {
  return (float8)__builtin_kvx_movefo(*v);
}

/// Copy a 4 x double vector from the TCA to the core.
__attribute__((deprecated)) inline double4 __builtin_kvx_movefofdq(__kvx_x256 *v) {
  return (double4)__builtin_kvx_movefo(*v);
}

/// tca256_t Funnel-logical-shift-bytes-right vectors V0 and V1.
/// Output to the core.
/// char32 = {V0, V1} >> 8 * sh.
//  0 <= sh < 64. Shift number of bytes.
__attribute__((deprecated)) inline char32 __builtin_kvx_alignobv(__kvx_x256 *v0, __kvx_x256 *v1,
                                     unsigned long byteshift) {
  return (char32)__builtin_kvx_alignov(*v0, *v1, byteshift);
}

/// tca256_t Funnel-logical-shift-bytes-right vectors V0 and V1.
/// Output to the core.
/// short16 = {V0, V1} >> 8 * sh.
//  0 <= sh < 64. Shift number of bytes.
__attribute__((deprecated)) inline short16 __builtin_kvx_alignohx(__kvx_x256 *v0, __kvx_x256 *v1,
                                      unsigned long byteshift) {
  return (short16)__builtin_kvx_alignov(*v0, *v1, byteshift);
}

/// tca256_t Funnel-logical-shift-bytes-right vectors V0 and V1.
/// Output to the core.
/// int8 = {V0, V1} >> 8 * sh.
//  0 <= sh < 64. Shift number of bytes.
__attribute__((deprecated)) inline int8 __builtin_kvx_alignowo(__kvx_x256 *v0, __kvx_x256 *v1,
                                   unsigned long byteshift) {
  return (int8)__builtin_kvx_alignov(*v0, *v1, byteshift);
}

/// tca256_t Funnel-logical-shift-bytes-right vectors V0 and V1.
/// Output to the core.
/// long4 = {V0, V1} >> 8 * sh.
//  0 <= sh < 64. Shift number of bytes.
__attribute__((deprecated)) inline long4 __builtin_kvx_alignodq(__kvx_x256 *v0, __kvx_x256 *v1,
                                    unsigned long byteshift) {
  return (long4)__builtin_kvx_alignov(*v0, *v1, byteshift);
}

/// tca256_t Funnel-logical-shift-bytes-right vectors V0 and V1.
/// Output to the core.
/// half16 = {V0, V1} >> 8 * sh.
//  0 <= sh < 64. Shift number of bytes.
__attribute__((deprecated)) inline half16 __builtin_kvx_alignofhx(__kvx_x256 *v0, __kvx_x256 *v1,
                                      unsigned long byteshift) {
  return (half16)__builtin_kvx_alignov(*v0, *v1, byteshift);
}

/// tca256_t Funnel-logical-shift-bytes-right vectors V0 and V1.
/// Output to the core.
/// float8 = {V0, V1} >> 8 * sh.
//  0 <= sh < 64. Shift number of bytes.
__attribute__((deprecated)) inline float8 __builtin_kvx_alignofwo(__kvx_x256 *v0, __kvx_x256 *v1,
                                      unsigned long byteshift) {
  return (float8)__builtin_kvx_alignov(*v0, *v1, byteshift);
}

/// tca256_t Funnel-logical-shift-bytes-right vectors V0 and V1.
/// Output to the core.
/// double4 = {V0, V1} >> 8 * sh.
//  0 <= sh < 64. Shift number of bytes.
__attribute__((deprecated)) inline double4 __builtin_kvx_alignofdq(__kvx_x256 *v0, __kvx_x256 *v1,
                                       unsigned long byteshift) {
  return (double4)__builtin_kvx_alignov(*v0, *v1, byteshift);
}

/// Copy a 32 x char vector from a core QuadRegister to the tca.
__attribute__((deprecated)) inline __kvx_x256 *__builtin_kvx_movetobv(char32 bv, __kvx_x256 *v) {
  *v = __builtin_kvx_moveoto(bv);
  return v;
}

/// Copy a 16 x short vector from a core QuadRegister to the tca.
__attribute__((deprecated)) inline __kvx_x256 *__builtin_kvx_movetohx(short16 hx, __kvx_x256 *v) {
  *v = __builtin_kvx_moveoto(hx);
  return v;
}

/// Copy a 8 x int vector from a core QuadRegister to the tca.
__attribute__((deprecated)) inline __kvx_x256 *__builtin_kvx_movetowo(int8 wo, __kvx_x256 *v) {
  *v = __builtin_kvx_moveoto(wo);
  return v;
}

/// Copy a 4 x long vector from a core QuadRegister to the tca.
__attribute__((deprecated)) inline __kvx_x256 *__builtin_kvx_movetodq(long4 dq, __kvx_x256 *v) {
  *v = __builtin_kvx_moveoto(dq);
  return v;
}

/// Copy a 16 x _Float16 vector from a core QuadRegister to the tca.
__attribute__((deprecated)) inline __kvx_x256 *__builtin_kvx_movetofhx(half16 fhx, __kvx_x256 *v) {
  *v = __builtin_kvx_moveoto(fhx);
  return v;
}

/// Copy a 8 x float vector from a core QuadRegister to the tca.
__attribute__((deprecated)) inline __kvx_x256 *__builtin_kvx_movetofo(float8 fo, __kvx_x256 *v) {
  *v = __builtin_kvx_moveoto(fo);
  return v;
}

/// Copy a 4 x double vector from a core QuadRegister to the tca.
__attribute__((deprecated)) inline __kvx_x256 *__builtin_kvx_movetofdq(double4 fdq, __kvx_x256 *v) {
  *v = __builtin_kvx_moveoto(fdq);
  return v;
}

/// Swap values of a tca256_t and a core QuadRegister holding a 32 x char
/// vector.
__attribute__((deprecated)) inline void __builtin_kvx_swapvobv(char32 *v0, __kvx_x256 *v1) {
  __builtin_kvx_swapvo((long4 *)v0, v1);
}

/// Swap values of a tca256_t and a core QuadRegister holding a 16 x short
/// vector.
__attribute__((deprecated)) inline void __builtin_kvx_swapvohx(short16 *v0, __kvx_x256 *v1) {
  __builtin_kvx_swapvo((long4 *)v0, v1);
}

/// Swap values of a tca256_t and a core QuadRegister holding a 8 x intvector.
__attribute__((deprecated)) inline void __builtin_kvx_swapvowo(int8 *v0, __kvx_x256 *v1) {
  __builtin_kvx_swapvo((long4 *)v0, v1);
}

/// Swap values of a tca256_t and a core QuadRegister holding a 4 x long vector.
__attribute__((deprecated)) inline void __builtin_kvx_swapvodq(long4 *v0, __kvx_x256 *v1) {
  __builtin_kvx_swapvo(v0, v1);
}

/// Swap values of a tca256_t and a core QuadRegister holding a 16 x _Float16
/// vector.
__attribute__((deprecated)) inline void __builtin_kvx_swapvofhx(half16 *v0, __kvx_x256 *v1) {
  __builtin_kvx_swapvo((long4 *)v0, v1);
}

/// Swap values of a tca256_t and a core QuadRegister holding a 16 x float
/// vector.
__attribute__((deprecated)) inline void __builtin_kvx_swapvofwo(float8 *v0, __kvx_x256 *v1) {
  __builtin_kvx_swapvo((long4 *)v0, v1);
}

/// Swap values of a tca256_t and a core QuadRegister holding a 16 x double
/// vector.
__attribute__((deprecated)) inline void __builtin_kvx_swapvofdq(double4 *v0, __kvx_x256 *v1) {
  __builtin_kvx_swapvo((long4 *)v0, v1);
}

#endif // __KVXTCAINTRIN_H_
