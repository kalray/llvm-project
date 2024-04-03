//==-- KVX.h - Top-level interface for KVX  ----------------------*- C++ -*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains definitions that are common between the backend and the
// frontend.
//
//===----------------------------------------------------------------------===//

namespace llvm {
namespace KVX {
enum ADDRSPACE : int {
  AS_NORMAL = 0,
  AS_OCL_GLOBAL = 1,
  AS_OCL_CONSTANT = 2,
  AS_OCL_LOCAL = 3,
  AS_BYPASS = 256,
  AS_PRELOAD = 257,
  AS_SPECULATE = 258,
  AS_SCALL = 259, // pointer calls with this address space emit SCALL
};
} // namespace KVX
} // namespace llvm
