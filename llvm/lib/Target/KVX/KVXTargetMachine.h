//==-- KVXTargetMachine.h - Define TargetMachine for KVX ---------*- C++ -*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares the KVX specific subclass of TargetMachine.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_KVX_KVXTARGETMACHINE_H
#define LLVM_LIB_TARGET_KVX_KVXTARGETMACHINE_H

#include "KVXSubtarget.h"
#include "MCTargetDesc/KVXMCTargetDesc.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {

class KVXTargetMachine : public LLVMTargetMachine {
  std::unique_ptr<TargetLoweringObjectFile> TLOF;
  mutable StringMap<std::unique_ptr<KVXSubtarget> > SubtargetMap;

public:
  KVXTargetMachine(const Target &T, const Triple &TT, StringRef CPU,
                   StringRef FS, const TargetOptions &Options,
                   std::optional<Reloc::Model> RM, std::optional<CodeModel::Model> CM,
                   CodeGenOptLevel OL, bool JIT);

  const KVXSubtarget *getSubtargetImpl(const Function &F) const override;

  TargetPassConfig *createPassConfig(PassManagerBase &PM) override;

  TargetTransformInfo getTargetTransformInfo(const Function &F) const override;

  TargetLoweringObjectFile *getObjFileLowering() const override {
    return TLOF.get();
  }

  MachineFunctionInfo *
  createMachineFunctionInfo(BumpPtrAllocator &Allocator, const Function &F,
                            const TargetSubtargetInfo *STI) const override;

  bool isNoopAddrSpaceCast(unsigned SrcAS, unsigned DestAS) const override;
  unsigned getSjLjDataSize() const override { return 64; }
  bool isV1() const { return TargetCPU == "kv3-1"; }
};

} // end namespace llvm

#endif // LLVM_LIB_TARGET_KVX_KVXTARGETMACHINE_H
