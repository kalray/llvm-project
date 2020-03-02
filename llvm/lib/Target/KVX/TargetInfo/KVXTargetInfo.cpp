//===-- KVXTargetInfo.cpp - KVX Target Implementation ---------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "llvm/Target/TargetMachine.h"
#include "llvm/Support/TargetRegistry.h"
using namespace llvm;

namespace llvm {
Target &getTheKVXTarget() {
  static Target TheKVXTarget;
  return TheKVXTarget;
}
} // namespace llvm

extern "C" void LLVMInitializeKVXTargetInfo() {
  RegisterTarget<Triple::kvx> X(getTheKVXTarget(), "kvx", "KVX", "KVX");
}
