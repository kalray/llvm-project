//==-- K1CTargetMachine.h - Define TargetMachine for K1C ---------*- C++ -*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares the K1C specific subclass of TargetMachine.
//
//===----------------------------------------------------------------------===//

#include "K1CTargetMachine.h"
#include "K1C.h"
#include "K1CTargetObjectFile.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"
#include "llvm/CodeGen/TargetPassConfig.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Support/FormattedStream.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Target/TargetOptions.h"

using namespace llvm;

extern "C" void LLVMInitializeK1CTarget() {
  RegisterTargetMachine<K1CTargetMachine> X(getTheK1CTarget());
}

static Reloc::Model getEffectiveRelocModel(const Triple &TT,
                                           Optional<Reloc::Model> RM) {
  if (!RM.hasValue())
    return Reloc::Static;
  return *RM;
}

K1CTargetMachine::K1CTargetMachine(const Target &T, const Triple &TT,
                                   StringRef CPU, StringRef FS,
                                   const TargetOptions &Options,
                                   Optional<Reloc::Model> RM,
                                   Optional<CodeModel::Model> CM,
                                   CodeGenOpt::Level OL, bool JIT)
    : LLVMTargetMachine(T, "e-m:e-p:64:64-i64:64-i128:128-n64-S128", TT, CPU,
                        FS, Options, getEffectiveRelocModel(TT, RM),
                        getEffectiveCodeModel(CM, CodeModel::Small), OL),
      TLOF(make_unique<K1CELFTargetObjectFile>()),
      Subtarget(TT, CPU, FS, *this) {
  initAsmInfo();
}

namespace {
class K1CPassConfig : public TargetPassConfig {
public:
  K1CPassConfig(K1CTargetMachine &TM, PassManagerBase &PM)
      : TargetPassConfig(TM, PM) {}

  K1CTargetMachine &getK1CTargetMachine() const {
    return getTM<K1CTargetMachine>();
  }

  bool addInstSelector() override;
};
} // namespace

TargetPassConfig *K1CTargetMachine::createPassConfig(PassManagerBase &PM) {
  return new K1CPassConfig(*this, PM);
}

bool K1CPassConfig::addInstSelector() {
  addPass(createK1CISelDag(getK1CTargetMachine()));

  return false;
}
