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

class i64_const<int N> : PatLeaf<(i64 N)>;
def i64_i32_max : i64_const<2147483647>;
def i64_i32_min : i64_const<-2147483648>;
def i64_ui32_max : i64_const<4294967295>;
