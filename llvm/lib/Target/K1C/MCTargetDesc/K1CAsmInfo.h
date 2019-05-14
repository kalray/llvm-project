//===-- K1CMCAsmInfo.h - K1C Asm Info --------------------------*- C++ -*--===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the declaration of the K1CMCAsmInfo class.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_K1C_MCTARGETDESC_K1CMCASMINFO_H
#define LLVM_LIB_TARGET_K1C_MCTARGETDESC_K1CMCASMINFO_H

#include "llvm/MC/MCAsmInfoELF.h"

namespace llvm {
class Triple;

class K1CMCAsmInfo : public MCAsmInfoELF {
  void anchor() override;

public:
  explicit K1CMCAsmInfo(const Triple &TargetTriple);
};

} // namespace llvm

#endif
