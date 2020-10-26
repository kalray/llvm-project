//===-- KVXSubRegisterInfo.td - KVX Register defs ----------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
//  Declarations that describe the KVX sub-register files
//===----------------------------------------------------------------------===//
// TCA sub-registers
def sub_w0 : SubRegIndex<512>;
def sub_w1 : SubRegIndex<512,512>;

def sub_v0 : SubRegIndex<256>;
def sub_v1 : SubRegIndex<256,256>;
def sub_v2 : ComposedSubRegIndex<sub_w1, sub_v0>;
def sub_v3 : ComposedSubRegIndex<sub_w1, sub_v1>;

def sub_b0 : SubRegIndex<128,  0>;
def sub_b1 : SubRegIndex<128,128>;

def sub_c0 : SubRegIndex<64, 0>;
def sub_c1 : SubRegIndex<64,64>;
def sub_c2 : ComposedSubRegIndex<sub_b1,sub_c0>;
def sub_c3 : ComposedSubRegIndex<sub_b1,sub_c1>;

// TODO: GPR sub-registers
def sub_p0 : SubRegIndex<128,  0>;
def sub_p1 : SubRegIndex<128,128>;

def sub_s0 : SubRegIndex<64,  0>;
def sub_s1 : SubRegIndex<64, 64>;
def sub_s2 : ComposedSubRegIndex<sub_p1, sub_s0>;
def sub_s3 : ComposedSubRegIndex<sub_p1, sub_s1>;
