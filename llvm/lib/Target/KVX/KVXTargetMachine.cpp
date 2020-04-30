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

#include "KVXTargetMachine.h"
#include "KVX.h"
#include "KVXTargetObjectFile.h"
#include "KVXTargetTransformInfo.h"
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
    DisableHardwareLoops("disable-kvx-hwloops", cl::Hidden, cl::init(true),
                         cl::desc("Disable Hardware Loops for KVX target"));

static cl::opt<bool>
DisableBundling("disable-kvx-bundling", cl::Hidden,
                cl::desc("Disable Bundling Pass for KVX target"));

static cl::opt<bool> DisableLoadStorePacking(
    "disable-kvx-loadstore-packing", cl::Hidden, cl::init(true),
    cl::desc("Disable Load/Store Packing Pass for KVX target"));

extern "C" LLVM_EXTERNAL_VISIBILITY void LLVMInitializeKVXTarget() {
  RegisterTargetMachine<KVXTargetMachine> X(getTheKVXTarget());
  auto PR = PassRegistry::getPassRegistry();
  initializeKVXExpandPseudoPass(*PR);
  initializeKVXLoadStorePackingPassPass(*PR);
  initializeKVXPacketizerPass(*PR);
  initializeKVXHardwareLoopsPass(*PR);
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

unsigned llvm::GetImmMakeOpCode(int64_t imm) {
  if (isInt<16>(imm))
    return KVX::MAKEi16;
  else if (isInt<43>(imm))
    return KVX::MAKEi43;
  else
    return KVX::MAKEi64;
}

static Reloc::Model getEffectiveRelocModel(const Triple &TT,
                                           Optional<Reloc::Model> RM) {
  if (!RM.hasValue())
    return Reloc::Static;
  return *RM;
}

KVXTargetMachine::KVXTargetMachine(const Target &T, const Triple &TT,
                                   StringRef CPU, StringRef FS,
                                   const TargetOptions &Options,
                                   Optional<Reloc::Model> RM,
                                   Optional<CodeModel::Model> CM,
                                   CodeGenOpt::Level OL, bool JIT)
  : LLVMTargetMachine(T,
		      "e-S256-p:64:64-i1:8-i8:8-i16:16-i32:32-i64:64-"
		      "v64:64-v128:128-v256:256-v512:512-v1024:1024-"
		      "f16:16-f32:32-f64:64-a:0:64-m:e-n32:64",
		      TT, CPU, FS, Options, getEffectiveRelocModel(TT, RM),
		      getEffectiveCodeModel(CM, CodeModel::Small), OL),
    TLOF(std::make_unique<KVXELFTargetObjectFile>()) {
  initAsmInfo();
}

namespace {
class KVXPassConfig : public TargetPassConfig {
public:
  KVXPassConfig(KVXTargetMachine &TM, PassManagerBase &PM)
      : TargetPassConfig(TM, PM) {}

  KVXTargetMachine &getKVXTargetMachine() const {
    return getTM<KVXTargetMachine>();
  }

  void addIRPasses() override;
  bool addInstSelector() override;
  void addPreRegAlloc() override;

  void addPreEmitPass() override;
};
} // namespace

const KVXSubtarget *
KVXTargetMachine::getSubtargetImpl(const Function &F) const {
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
    I = std::make_unique<KVXSubtarget>(TargetTriple, CPU, FS, *this);
  }
  return I.get();
}

TargetPassConfig *KVXTargetMachine::createPassConfig(PassManagerBase &PM) {
  return new KVXPassConfig(*this, PM);
}

void KVXPassConfig::addIRPasses() {
  addPass(createAtomicExpandPass());
  TargetPassConfig::addIRPasses();
}

bool KVXPassConfig::addInstSelector() {
  addPass(createKVXISelDag(getKVXTargetMachine()));

  return false;
}

void KVXPassConfig::addPreRegAlloc() {
  if (getOptLevel() >= CodeGenOpt::Default) {
    if (!DisableLoadStorePacking)
      addPass(createKVXLoadStorePackingPass());
    if (!DisableHardwareLoops)
      addPass(createKVXHardwareLoopsPass());
  }
}

void KVXPassConfig::addPreEmitPass() {
  addPass(createKVXExpandPseudoPass());
  addPass(createKVXPacketizerPass(getOptLevel() >= CodeGenOpt::Default &&
                                  !DisableBundling),
          false);
}

TargetTransformInfo
KVXTargetMachine::getTargetTransformInfo(const Function &F) {
  if (getOptLevel() == CodeGenOpt::Aggressive)
    return TargetTransformInfo(KVXTTIImpl(this, F));
  else
    return LLVMTargetMachine::getTargetTransformInfo(F);
}
