//===-- K1CTargetObjectFile.h - K1C Object Info ---------*- C++ ---------*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_K1C_K1CTARGETOBJECTFILE_H
#define LLVM_LIB_TARGET_K1C_K1CTARGETOBJECTFILE_H

#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"

namespace llvm {
class K1CTargetMachine;

class K1CELFTargetObjectFile : public TargetLoweringObjectFileELF {
  void Initialize(MCContext &Ctx, const TargetMachine &TM) override;
  const MCExpr *getDebugThreadLocalSymbol(const MCSymbol *Sym) const override;
};

} // end namespace llvm

#endif
