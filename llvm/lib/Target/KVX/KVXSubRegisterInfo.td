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
def sub_2K0 : SubRegIndex<2048>;
def sub_2K1 : SubRegIndex<2048,2048>;

def sub_m0 : SubRegIndex<1024>;
def sub_m1 : SubRegIndex<1024,1024>;
def sub_m2 : ComposedSubRegIndex<sub_2K1, sub_m0>;
def sub_m3 : ComposedSubRegIndex<sub_2K1, sub_m1>;

def sub_w0 : SubRegIndex<512>;
def sub_w1 : SubRegIndex<512,512>;
def sub_w2 : ComposedSubRegIndex<sub_m1, sub_w0>;
def sub_w3 : ComposedSubRegIndex<sub_m1, sub_w1>;
def sub_w4 : ComposedSubRegIndex<sub_m2, sub_w0>;
def sub_w5 : ComposedSubRegIndex<sub_m2, sub_w1>;
def sub_w6 : ComposedSubRegIndex<sub_m3, sub_w0>;
def sub_w7 : ComposedSubRegIndex<sub_m3, sub_w1>;

def sub_v0 : SubRegIndex<256>;
def sub_v1 : SubRegIndex<256,256>;
def sub_v2 : ComposedSubRegIndex<sub_w1, sub_v0>;
def sub_v3 : ComposedSubRegIndex<sub_w1, sub_v1>;
def sub_v4 : ComposedSubRegIndex<sub_w2, sub_v0>;
def sub_v5 : ComposedSubRegIndex<sub_w2, sub_v1>;
def sub_v6 : ComposedSubRegIndex<sub_w3, sub_v0>;
def sub_v7 : ComposedSubRegIndex<sub_w3, sub_v1>;
def sub_v8 : ComposedSubRegIndex<sub_w4, sub_v0>;
def sub_v9 : ComposedSubRegIndex<sub_w4, sub_v1>;
def sub_v10: ComposedSubRegIndex<sub_w5, sub_v0>;
def sub_v11: ComposedSubRegIndex<sub_w5, sub_v1>;
def sub_v12: ComposedSubRegIndex<sub_w6, sub_v0>;
def sub_v13: ComposedSubRegIndex<sub_w6, sub_v1>;
def sub_v14: ComposedSubRegIndex<sub_w7, sub_v0>;
def sub_v15: ComposedSubRegIndex<sub_w7, sub_v1>;

// Sub quad-word, common for CORE & TCA
def sub_q0 : SubRegIndex<128,  0>;
def sub_q1 : SubRegIndex<128,128>;
def sub_q2 : ComposedSubRegIndex<sub_v1, sub_q0>;
def sub_q3 : ComposedSubRegIndex<sub_v1, sub_q1>;

// Sub double-word, common for CORE & TCA
def sub_d0 : SubRegIndex<64,  0>;
def sub_d1 : SubRegIndex<64, 64>;
def sub_d2 : ComposedSubRegIndex<sub_q1, sub_d0>;
def sub_d3 : ComposedSubRegIndex<sub_q1, sub_d1>;
