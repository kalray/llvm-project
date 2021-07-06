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

// TCA opaque data types:
typedef __tca256 tca256_t;   // Maps to a variable that is held in a VectorReg
typedef __tca512 tca512_t;   // Maps to a variable that is held in a WideReg
typedef __tca1024 tca1024_t; // Maps to a variable that is held in a MatrixReg

/// Tca registers layout:
/// The base unit is a Vector Register (__tca256).
/// The Wide Register (__tca512) is built with two Vector Registers.
/// The Matrix Register (__tca1024) is built with four Vector Registers or two
/// Wide Registers.
/// Every most significant half part of a matrix or wide can be addressed as
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

/// Modifer type [Accepted modifiers strings. A single dot '.' can be omitted.]
/// Rectify: [. .relu]
/// Roundint: [.rn .ru .rd .rz .rhu]
/// Saturate: [.sat .satu]
/// ScalarCond: [ .dnez .deqz .dltz .dgez .dlez .dgtz .odd .even .wnez .weqz .wltz .wgez .wlez .wgtz ]
/// Speculate: [. .s]
/// silent2: [. .s]
/// xrounding: [.rn .ru .rd .rz .rna .rnz .ro .]

/// Inplace set high half of a tca256_t type V to (h,l).
// tca256_t __builtin_kvx_movetohi (tca256_t V, int64_t h, int64_t l);

/// Inplace set lower half of a tca256_t type V to (h,l).
// tca256_t __builtin_kvx_movetolo (tca256_t V, int64_t h, int64_t l);

/// Build vector type (hh, hl, lh, ll).
// tca256_t __builtin_kvx_moveto (int64_t hh, int64_t hl, int64_t lh, int64_t ll);

/// Copy 256 bits to a vector type from a core QuadRegister.
// tca256_t __builtin_kvx_moveoto (long4 Oct);

/// Copy 256 bits from a tca register to a core register.
// long4 __builtin_kvx_movefo (tca256_t V);

/// Insert wide type W into matrix type M in position p [0-1]
// tca1024_t __builtin_kvx_insertwm (tca1024_t M, tca512_t W, unsigned p);

/// Insert vector type V into matrix type M in position p [0-3]
// tca1024_t __builtin_kvx_insertvm (tca1024_t M, tca256_t V, unsigned p);

/// Insert vector type V into wide type W in position p [0-1]
// tca512_t __builtin_kvx_insertvw (tca512_t W tca256_t V, unsigned p);

/// Retrieve wide type W at position p [0-1] from matrix type M
// tca512_t W, __builtin_kvx_movefmw (tca1024_t M, unsigned p);

/// Retrieve vector type V at position p [0-3] from matrix type M
// tca256_t __builtin_kvx_movefmv (tca1024_t M, unsigned p);

/// Retrieve vector type V at position p [0-1] from wide type W
// tca256_t __builtin_kvx_movefwv (tca512_t W, unsigned p);

/// Build a matrix type from the four vectors V0,V1,V2,V3
// tca1024_t __builtin_kvx_buildfvm (tca256_t V0, tca256_t V1, tca256_t V2, tca256_t V3);

/// Build a matrix type from the two wide W0,W1
// tca1024_t __builtin_kvx_buildfwm (tca512_t W0, tca512_t W1);

/// Build a wide from the two vectors V0,V1
// tca512_t __builtin_kvx_buildfvw (tca256_t V0, tca256_t V1);

/// tca256_t Funnel-logical-shift-bytes-right vectors V0 and V1.
/// V0 = {V0, V1} >> 8 * sh.
//  0 <= sh < 64. Shift number of bytes.
// tca256_t __builtin_kvx_alignv (tca256_t V0, tca256_t V1, uint64_t sh);

/// tca256_t Funnel-logical-shift-bytes-right vectors V0 and V1.
/// Output to the core.
/// long4 = {V0, V1} >> 8 * sh.
//  0 <= sh < 64. Shift number of bytes.
// long4 __builtin_kvx_alignov (tca256_t V0, tca256_t V1, uint64_t sh);

/// Swap values of a tca256_t and a core QuadRegister.
// void __builtin_kvx_swapvo (long4 *gpr, tca256_t *v);

/// Truncate the lower half matrix (4x2) of a 4x4 matrix of doubles M to a 4x2
/// matrix of halfs and write it to the lower part of vector V. If the assigned
/// vector is not the input vector V, a copy of V is performed before to the
/// output, as to preserve the upper half.
/// Modifiers: Roundint, Saturate
// tca256_t  __builtin_kvx_convdhv0 (tca256_t V, tca1024_t M, const char *mods);

/// Truncate the upper half matrix (4x2) of a 4x4 matrix of doubles M to a 4x2
/// matrix of halfs and write it to the upper part of vector V. If the assigned
/// vector is not the input vector V, a copy of V is performed before to the
/// output, as to preserve the lower half.
/// Modifiers: Roundint, Saturate
// tca256_t  __builtin_kvx_convdhv1 (tca256_t V, tca1024_t M, const char *mods);

/// Truncate the 4x4 matrix of doubles M to a 4x4 matrix of halfs.
/// Modifiers: Roundint, Saturate
// tca256_t __builtin_kvx_convdhv (tca1024_t M, const char *mods);

/// Trucante the first quarter (2x4) of a 4x8 matrix of integers M to a 2x4
/// matrix of chars and write in the first quarter of vector V. If the assigned
/// vector is not the input vector V, a copy of V is performed before to the
/// output, as to preserve other quarters.
/// Modifiers: Roundint, Saturate
// tca256_t  __builtin_kvx_convwbv0 (tca256_t V, tca1024_t M, const char *mods);

/// Trucante the second quarter (2x4) of a 4x8 matrix of integers M to a 2x4
/// matrix of chars and write in the second quarter of vector V. If the assigned
/// vector is not the input vector V, a copy of V is performed before to the
/// output, as to preserve other quarters.
/// Modifiers: Roundint, Saturate
// tca256_t  __builtin_kvx_convwbv1 (tca256_t V, tca1024_t M, const char *mods);

/// Trucante the third quarter (2x4) of a 4x8 matrix of integers to a 2x4 matrix
/// of chars and write in the third quarter of vector V.
/// If the assigned vector is not the input vector V, a copy of V is performed
/// before to the output, as to preserve other quarters.
/// Modifiers: Roundint, Saturate
// tca256_t  __builtin_kvx_convwbv2 (tca256_t V, tca1024_t M, const char *mods);

/// Trucante the last quarter (2x4) of a 4x8 matrix of integers M to a 2x4
/// matrix of chars and write in the last quarter of vector V. If the assigned
/// vector is not the input vector V, a copy of V is performed before to the
/// output, as to preserve other quarters.
/// Modifiers: Roundint, Saturate
// tca256_t  __builtin_kvx_convwbv3 (tca256_t V, tca1024_t M, const char *mods);

/// Trucante the 4x8 matrix of integers M to a 4x8 matrix of chars.
/// Modifiers: Roundint, Saturate
// tca256_t __builtin_kvx_convwbv (tca1024_t M, const char *mods);

/// Let W be a 4x4 matrix of floats, V1 and V2 be 2x4 matrixes of half floats.
/// Add the first quarter (2x2) of W to the matrix multiply of V0 by the
/// transposed (V1).
/// Returns W[0] = W[0] + V0 X T(V1)
/// The output is written to the lower half of the vector V0. If the assigned
/// vector is not the same variable as V0, possibly a copy is done before, as to
/// preserve the other values of the vector.
// tca256_t __builtin_kvx_fmma242hw0 (tca256_t V0,  tca512_t W,  tca256_t V1, tca256_t V2);

/// Let W be a 4x4 matrix of floats, V1 and V2 be 2x4 matrixes of half floats.
/// Add the second quarter (2x2) of W to the matrix multiply of V0 by the
/// transposed (V1).
/// Returns W[0] = W[0] + V0 X T(V1)
/// The output is written to the upper half of the vector V0. If the assigned
/// vector is not the same variable as V0, possibly a copy is done before, as to
/// preserve the other values of the vector.
// tca256_t __builtin_kvx_fmma242hw1 (tca256_t V0,  tca512_t W,  tca256_t V1, tca256_t V2);

/// Let W be a 4x4 matrix of floats, V1 and V2 be 2x4 matrixes of half floats.
/// Add the third quarter (2x2) of W to the matrix multiply of V0 by the
/// transposed (V1).
/// Returns W[0] = W[0] + V0 X T(V1)
/// The output is written to the lower half of the vector V0. If the assigned
/// vector is not the same variable as V0, possibly a copy is done before, as to
/// preserve the other values of the vector.
// tca256_t __builtin_kvx_fmma242hw2 (tca256_t V0,  tca512_t W,  tca256_t V1, tca256_t V2);

/// Let W be a 4x4 matrix of floats, V1 and V2 be 2x4 matrixes of half floats.
/// Add the last quarter (2x2) of W to the matrix multiply of V0 by the
/// transposed (V1).
/// W[0] = W[0] + V0 X T(V1)
/// The output is written to the upper half of the vector V0. If the assigned
/// vector is not the same variable as V0, possibly a copy is done before, as to
/// preserve the other values of the vector.
// tca256_t __builtin_kvx_fmma242hw3 (tca256_t V0,  tca512_t W,  tca256_t V1, tca256_t V2);

/// Let W be a 4x4 matrix of floats, V0 and V1 be 2x4 matrixes of half floats.
/// Add to each quarter of W the the matrix multiply of V0 by the transposed
/// (V1). W = W[0-3] + V0 X T(V1).
// tca512_t __builtin_kvx_fmma444hw (tca512_t W, tca256_t V0, tca256_t V1);

/// Let M be a 4x4 matrix of int64_t,
/// V0 a 4x4 matrix of signed short and
/// V1 a 4x4 matrix of int64_t interpreted as a 4x4 matrix of char.
/// Returns M + V0 x transposed (V1).
// tca1024_t __builtin_kvx_mma444hbd0 (tca1024_t M, tca256_t V0, tca256_t V1);

/// Let M be a 4x4 matrix of int64_t,
/// V0 a 4x4 matrix of signed short and
/// V1 a 4x4 matrix of int64_t.
/// T is a 4x4 matrix of int64_t interpreted as a 4x4 matrix of char obtained
/// obtained from the lower char of the upper word of each int64_t element.
/// Returns M + V0 x transposed (T)
// tca1024_t __builtin_kvx_mma444hbd1 (tca1024_t M, tca256_t V0, tca256_t V1);

/// Let M be a 4x4 matrix of int64_t,
/// V0 and V1 4x4 matrixes of signed short.
/// Returns M + V0 x transposed (V1).
// tca1024_t __builtin_kvx_mma444hd (tca1024_t M, tca256_t V0, tca256_t V1);

/// Let M be a 4x4 matrix of int64_t,
/// V0 a 4x4 matrix of signed short and
/// V1 a 4x4 matrix of int64_t interpreted as a 4x4 matrix of unsigned char.
/// Returns the 4x4 matrix of int64_t = M + V0 x transposed (V1).
// tca1024_t __builtin_kvx_mma444suhbd0 (tca1024_t M, tca256_t V0, tca256_t V1);

/// Let M be a 4x4 matrix of int64_t,
/// V0 a 4x4 matrix of signed short and
/// V1 a 4x4 matrix of int64_t interpreted as a 4x4 matrix of unsigned char,
/// obtained from the lower char of the upper word of each int64_t element.
/// Returns the 4x4 matrix of int64_t = M + V0 x transposed (V1).
// tca1024_t __builtin_kvx_mma444suhbd1 (tca1024_t M, tca256_t V0, tca256_t V1);

/// Let M be a 4x4 matrix of int64_t,
/// V0 a 4x4 matrixes of signed short and
/// V1 a 4x4 matrixes of unsigned short.
/// Returns M + V0 x transposed (V1).
// tca1024_t __builtin_kvx_mma444suhd (tca1024_t M, tca256_t V0, tca256_t V1);

/// Let M be a 4x4 matrix of int64_t,
/// V0 is a 4x4 matrix of unsigned short,
/// V1 a 4x4 matrix of int64_t interpreted as a 4x4 matrix of unsigned char.
/// Returns the 4x4 matrix of int64_t = M + V0 x transposed (V1)
// tca1024_t __builtin_kvx_mma444uhbd0 (tca1024_t M, tca256_t V0, tca256_t V1);

/// Let M be a 4x4 matrix of int64_t,
/// V0 a 4x4 matrix of unsigned short.
/// V1 a 4x4 matrix of int64_t interpreted as a 4x4 matrix of unsigned char,
/// obtained from the lower char of the upper word of each int64_t element.
/// Returns the 4x4 matrix of int64_t = M + V0 x transposed (V1)
// tca1024_t __builtin_kvx_mma444uhbd1 (tca1024_t M, tca256_t V0, tca256_t V1);

/// Let M be a 4x4 matrix of int64_t,
/// V0 and V1 4x4 matrixes of unsigned short.
/// Returns the 4x4 matrix of int64_t M + V0 x transposed(V1)
// tca1024_t __builtin_kvx_mma444uhd (tca1024_t M, tca256_t V0, tca256_t V1);

/// Let M be a 4x4 matrix of int64_t,
/// V0 a 4x4 matrix of unsigned short and
/// V1 a 4x4 matrix of int64_t interpreted as a 4x4 matrix of char.
/// Returns the 4x4 matrix of int64_t = M + V0 x transposed (V1).
// tca1024_t __builtin_kvx_mma444ushbd0 (tca1024_t M, tca256_t V0, tca256_t V1);

/// Let M be a 4x4 matrix of int64_t,
/// V0 a 4x4 matrix of unsigned short,
/// V1 a 4x4 matrix of int64_t interpreted as a 4x4 matrix of char,
/// obtained from the lower char of the upper word of each int64_t element.
/// Returns the 4x4 matrix of int64_t = M + V0 x transposed (V1)
// tca1024_t __builtin_kvx_mma444ushbd1 (tca1024_t M, tca256_t V0, tca256_t V1);

/// Let M be a 4x4 matrix of int64_t,
/// V0 is 4x4 matrixes of unsigned short and
/// V1 is 4x4 matrixes of signed short.
/// Returns the 4x4 matrix of int64_t M + V0 x transposed (V1).
// tca1024_t __builtin_kvx_mma444ushd (tca1024_t M, tca256_t V0, tca256_t V1);

/// Let W be a 4x4 matrix of int32_t,
/// V0 and V1 4x8 matrixes of char.
/// Returns W + V0 x transposed (V1).
// tca512_t __builtin_kvx_mma484bw (tca512_t W, tca256_t V0, tca256_t V1);

/// Let W be a 4x4 matrix of int32_t,
/// V0 a 4x8 matrix of char and
/// V1 a 4x8 matrix of unsigned char.
/// Returns W + V0 x transposed (V1).
// tca512_t __builtin_kvx_mma484subw (tca512_t W, tca256_t V0, tca256_t V1);

/// Let W be a 4x4 matrix of int32_t,
/// V0 and V1 4x8 matrixes of unsigned char.
/// Returns W + V0 x transposed (V1).
// tca512_t __builtin_kvx_mma484ubw (tca512_t W, tca256_t V0, tca256_t V1);

/// Lew W be a 4x4 matrix of int32_t,
/// V0 a 4x8 matrix of unsigned char and
/// V1 a 4x8 matrix of char.
/// Returns w + V0 x transposed (V1).
// tca512_t __builtin_kvx_mma484usbw (tca512_t W, tca256_t V0, tca256_t V1);

/// Transpose a 4x4 matrix of double words.
// tca1024_t __builtin_kvx_mt44d (tca1024_t M);

/// Scales the vector of 8 floats V by the power of 2 given in the
/// xrounding modifier.
/// Modifiers: xrounding, silent2, rectify
// tca256_t __builtin_kvx_fscalewv (tca256_t V, const char *mods);

/// Truncates the vector of 16 floats to a vector of 16 halfs, following the
/// rounding defined by xrounding.
/// Modifers: xrounding, silent2
// tca256_t __builtin_kvx_fnarrowwhv (tca512_t W, const char *mods);

/// Load a tca256_t V from memory address p.
/// Modifiers: speculate
// tca256_t __builtin_kvx_lv (tca256_t *ptr, const char *mods);

/// Conditionally load a tca256_t V from memory address p if
// (evaluate (ScalarCond, condition)) == true.
/// Modifer: ScalarCond
// tca256_t __builtin_kvx_lv_cond (tca256_t V, tca256_t *p, int64_t condition, const char *mods);

/// Thinking as M being a 4x4 matrix of int64_t, this loads a 1x4 matrix of int64_t,
/// and transpose it into the `column` of M.
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
/// Modifer: SpeculateMod
// tca1024_t __builtin_kvx_lvc (tca1024_t M, tca256_t *p, int32_t column, const char *mods);

/// Thinking as M being a 4x4 matrix of int64_t, this conditionally loads a 1x4
/// matrix of int64_t, and transpose it into the `column` of M if (evaluated true
/// (ScalarCond, condition)).
/// Modifer: SpeculateMod, ScalarCond
// tca1024_t __builtin_kvx_lvc_cond (tca1024_t M, tca256_t *p, int32_t column, int64_t condition, const char *mods);

/// Store a tca256_t V to memory address p
// void __builtin_kvx_sv (tca256_t *p, tca256_t V);

/// Conditionally store a tca256_t V to memory address p if (evaluate
/// (ScalarCond, condition)).
/// Modifiers: ScalarCond
// void __builtin_kvx_sv_cond (tca256_t *p, tca256_t V, int64_t condition, const char *mods);

#endif // __KVXTCAINTRIN_H_
