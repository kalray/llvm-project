#ifndef LLVM_LIB_TARGET_K1C_K1CTARGETOBJECTFILE_H
#define LLVM_LIB_TARGET_K1C_K1CTARGETOBJECTFILE_H

#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"

namespace llvm {
class K1CTargetMachine;

/// This implementation is used for RISCV ELF targets.
class K1CELFTargetObjectFile : public TargetLoweringObjectFileELF {
  void Initialize(MCContext &Ctx, const TargetMachine &TM) override;
};

} // end namespace llvm

#endif