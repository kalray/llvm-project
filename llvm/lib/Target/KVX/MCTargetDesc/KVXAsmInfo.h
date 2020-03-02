//===-- KVXMCAsmInfo.h - KVX Asm Info --------------------------*- C++ -*--===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the declaration of the KVXMCAsmInfo class.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_KVX_MCTARGETDESC_KVXMCASMINFO_H
#define LLVM_LIB_TARGET_KVX_MCTARGETDESC_KVXMCASMINFO_H

#include "llvm/MC/MCAsmInfoELF.h"

namespace llvm {
class Triple;

class KVXMCAsmInfo : public MCAsmInfoELF {
  void anchor() override;

public:
  explicit KVXMCAsmInfo(const Triple &TargetTriple);
};

} // namespace llvm

#endif
