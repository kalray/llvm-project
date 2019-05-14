//===-- K1CCallingConv.td - K1C Calling Convention ---------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

def CSR : CalleeSavedRegs<(add (sequence "R%u", 18, 31))>;
