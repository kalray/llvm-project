//===-- KVXCallingConv.td - KVX Calling Convention ---------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

def CSR : CalleeSavedRegs<(add RA, R14, (sequence "R%u", 31, 18))>;

def CC_KVX : CallingConv<[
    CCIfType<[i8,i16,i32,i64,v8i8,v2i16,v4i16,v2i32,f16,f32,f64,v4f16,v2f16,v2f32], CCAssignToReg<[R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11]>>,
    CCIfType<[i8,i16,i32,i64,v8i8,v2i16,v4i16,v2i32,f16,f32,f64,v4f16,v2f16,v2f32], CCAssignToStack<8,8>>
]>;

def RetCC_KVX : CallingConv<[
    CCIfType<[i8,i16,i32,i64,v8i8,v2i16,v4i16,v2i32,f16,f32,f64,v4f16,v2f16,v2f32], CCAssignToReg<[R0,R1,R2,R3]>>
]>;
