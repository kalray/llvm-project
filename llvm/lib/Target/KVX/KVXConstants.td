//===-- KVXConstants.td - Constants used in patterns -------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

class i32_const<int N> : PatLeaf<(i32 N)>;
def i32_max : i32_const<2147483647>;
def i32_min : i32_const<-2147483648>;
def i32_i16umax : i32_const<65535>;
def i32_i8umax : i32_const<255>;

class i64_const<int N> : PatLeaf<(i64 N)>;
def i64_i32_max : i64_const<2147483647>;
def i64_i32_min : i64_const<-2147483648>;
def i64_ui32_max : i64_const<4294967295>;

class UnSignMod<int N> : PatLeaf<(i32 N)>;
def UnSignMod_S  : UnSignMod<0>;
def UnSignMod_SU : UnSignMod<1>;
def UnSignMod_U  : UnSignMod<2>;
def UnSignMod_US : UnSignMod<3>;

class ExtendMul<int N> : PatLeaf<(i32 N)>;
def ExtendMul_S  : ExtendMul<0>;
def ExtendMul_SU : ExtendMul<1>;
def ExtendMul_U  : ExtendMul<2>;
