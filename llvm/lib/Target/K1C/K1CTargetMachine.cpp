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

static cl::opt<bool>
    DisableHardwareLoops("disable-k1c-hwloops", cl::Hidden,
                         cl::desc("Disable Hardware Loops for K1C target"));

extern "C" void LLVMInitializeK1CTarget() {
  RegisterTargetMachine<K1CTargetMachine> X(getTheK1CTarget());
  auto PR = PassRegistry::getPassRegistry();
  initializeK1CExpandPseudoPass(*PR);
  initializeK1CLoadStorePackingPassPass(*PR);
  initializeK1CPacketizerPass(*PR);
  initializeK1CHardwareLoopsPass(*PR);
}

unsigned llvm::GetImmOpCode(int64_t imm, unsigned i10code, unsigned i37code,
                            unsigned i64code) {
  if (isInt<10>(imm))
    return i10code;
  else if (isInt<37>(imm))
    return i37code;
  else
    return i64code;
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
    : LLVMTargetMachine(
          T, "e-m:e-p:64:64-i64:64-i128:128-f16:16-f32:32-f64:64-n64-S128", TT,
          CPU, FS, Options, getEffectiveRelocModel(TT, RM),
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

  void addIRPasses() override;
  bool addInstSelector() override;
  void addPreRegAlloc() override;

  void addPreEmitPass() override;
};
} // namespace

const K1CSubtarget *
K1CTargetMachine::getSubtargetImpl(const Function &F) const {
  Attribute CPUAttr = F.getFnAttribute("target-cpu");
  Attribute FSAttr = F.getFnAttribute("target-features");

  std::string CPU = !CPUAttr.hasAttribute(Attribute::None)
                        ? CPUAttr.getValueAsString().str()
                        : TargetCPU;
  std::string FS = !FSAttr.hasAttribute(Attribute::None)
                       ? FSAttr.getValueAsString().str()
                       : TargetFS;

  auto &I = SubtargetMap[CPU + FS];
  if (!I) {
    // This needs to be done before we create a new subtarget since any
    // creation will depend on the TM and the code generation flags on the
    // function that reside in TargetOptions.
    resetTargetOptions(F);
    I = llvm::make_unique<K1CSubtarget>(TargetTriple, CPU, FS, *this);
  }
  return I.get();
}

TargetPassConfig *K1CTargetMachine::createPassConfig(PassManagerBase &PM) {
  return new K1CPassConfig(*this, PM);
}

void K1CPassConfig::addIRPasses() {
  addPass(createAtomicExpandPass());
  TargetPassConfig::addIRPasses();
}

bool K1CPassConfig::addInstSelector() {
  addPass(createK1CISelDag(getK1CTargetMachine()));

  return false;
}

void K1CPassConfig::addPreRegAlloc() {
  if (getOptLevel() >= CodeGenOpt::Default) {
    addPass(createK1CLoadStorePackingPass());
    if (!DisableHardwareLoops)
      addPass(createK1CHardwareLoopsPass());
  }
}

void K1CPassConfig::addPreEmitPass() {
  addPass(createK1CExpandPseudoPass());
  addPass(createK1CPacketizerPass(getOptLevel() >= CodeGenOpt::Default), false);
}
