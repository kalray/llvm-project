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
#include "llvm/CodeGen/MachineScheduler.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"
#include "llvm/CodeGen/TargetPassConfig.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Support/FormattedStream.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Target/TargetOptions.h"

using namespace llvm;

static cl::opt<bool>
    DisableLOOPDO("disable-kvx-hwloops", cl::Hidden, cl::init(false),
                  cl::desc("Disable Hardware Loops for KVX target"));

static cl::opt<bool>
DisableBundling("disable-kvx-bundling", cl::Hidden,
                cl::desc("Disable Bundling Pass for KVX target"));

static cl::opt<bool> DisableLoadStorePacking(
    "disable-kvx-loadstore-packing", cl::Hidden, cl::init(true),
    cl::desc("Disable Load/Store Packing Pass for KVX target"));

static cl::opt<std::string>
    StackLimitRegister("fstack-limit-register",
                       cl::desc("verify stack with a register for KVX"));

extern "C" LLVM_EXTERNAL_VISIBILITY void LLVMInitializeKVXTarget() {
  RegisterTargetMachine<KVXTargetMachine> X(getTheKVXTarget());
  auto *PR = PassRegistry::getPassRegistry();
  initializeKVXExpandPseudoPass(*PR);
  initializeKVXLoadStorePackingPassPass(*PR);
  initializeKVXPacketizerPass(*PR);
  initializeKVXHardwareLoopsPass(*PR);
  initializeKVXHardwareLoopsPreparePass(*PR);
}

bool llvm::isScalarcondWord(unsigned Cond) {
  switch (Cond) {
  case KVXMOD::SCALARCOND_ODD:
  case KVXMOD::SCALARCOND_EVEN:
  case KVXMOD::SCALARCOND_WNEZ:
  case KVXMOD::SCALARCOND_WEQZ:
  case KVXMOD::SCALARCOND_WLTZ:
  case KVXMOD::SCALARCOND_WGEZ:
  case KVXMOD::SCALARCOND_WLEZ:
  case KVXMOD::SCALARCOND_WGTZ:
    return true;
  default:
    return false;
  }
}

bool llvm::hasStackLimitRegister() {
  static int StackLimitRegisterValue = -1;

  if (StackLimitRegisterValue == -1) {
    StackLimitRegisterValue = StackLimitRegister.compare("sr") == 0;
    if (!StackLimitRegister.empty() && StackLimitRegisterValue == 0)
      report_fatal_error(
          "only sr register is supported for stack-limit-register", false);
  }
  return StackLimitRegisterValue != 0;
}

unsigned llvm::GetImmOpCode(int64_t Imm, unsigned I10code, unsigned I37code,
                            unsigned I64code) {
  if (isInt<10>(Imm))
    return I10code;
  if (isInt<37>(Imm))
    return I37code;
  return I64code;
}

unsigned llvm::GetImmMakeOpCode(int64_t Imm) {
  if (isInt<16>(Imm))
    return KVX::MAKEi16;
  if (isInt<43>(Imm))
    return KVX::MAKEi43;
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
                                   const TargetOptions &Opts,
                                   Optional<Reloc::Model> RM,
                                   Optional<CodeModel::Model> CM,
                                   CodeGenOpt::Level OL, bool JIT)
    : LLVMTargetMachine(T,
                        "e-S256-p:64:64-i1:8-i8:8-i16:16-i32:32-i64:64-"
                        "v64:64-v128:128-v256:256-v512:256-v1024:256-"
                        "f16:16-f32:32-f64:64-a:0:64-m:e-n32:64",
                        TT, KVX_MC::selectKVXCPU(CPU), FS, Opts,
                        getEffectiveRelocModel(TT, RM),
                        getEffectiveCodeModel(CM, CodeModel::Small), OL),
      TLOF(std::make_unique<KVXELFTargetObjectFile>()) {

  Options.DisableIntegratedAS = true;
  Options.BinutilsVersion = {2, 37};
  setSupportsDebugEntryValues(true);
  initAsmInfo();
}

namespace {
class KVXPassConfig : public TargetPassConfig {
public:
  KVXPassConfig(KVXTargetMachine &TM, PassManagerBase &PM)
      : TargetPassConfig(TM, PM) {
    if (!DisableLOOPDO) {
      disablePass(&EarlyTailDuplicateID);
    }
    if (TM.getOptLevel() != CodeGenOpt::None)
      substitutePass(&PostRASchedulerID, &PostMachineSchedulerID);
  }

  KVXTargetMachine &getKVXTargetMachine() const {
    return getTM<KVXTargetMachine>();
  }

  ScheduleDAGInstrs *
  createPostMachineScheduler(MachineSchedContext *C) const override;
  void addIRPasses() override;
  bool addInstSelector() override;
  void addPreRegAlloc() override;
  bool addPreISel() override;
  void addPreSched2() override;
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

ScheduleDAGInstrs *
KVXPassConfig::createPostMachineScheduler(MachineSchedContext *C) const {
  return createGenericSchedPostRA(C);
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
  addPass(createKVXExpandPseudoPass(KVX::PRE_RA));
  if (getOptLevel() >= CodeGenOpt::Default) {
    if (!DisableLoadStorePacking)
      addPass(createKVXLoadStorePackingPass());
    if (!DisableLOOPDO)
      addPass(createKVXHardwareLoopsPass());
  }
}

void KVXPassConfig::addPreSched2() {
  addPass(createKVXExpandPseudoPass(KVX::PRE_SCHED2));
  if (getOptLevel() != CodeGenOpt::None)
    addPass(&IfConverterID);
}

void KVXPassConfig::addPreEmitPass() {
  addPass(createKVXExpandPseudoPass(KVX::PRE_BUNDLE));
  if ((getOptLevel() >= CodeGenOpt::Default) && (!DisableBundling))
    addPass(createKVXPacketizerPass());

  addPass(createKVXExpandPseudoPass(KVX::PRE_EMIT));
}

bool KVXPassConfig::addPreISel() {
  if (TM->getOptLevel() >= CodeGenOpt::Default && !DisableLOOPDO) {
    addPass(createHardwareLoopsPass());
    addPass(createKVXHardwareLoopsPreparePass());
  }
  return false;
}

TargetTransformInfo
KVXTargetMachine::getTargetTransformInfo(const Function &F) {
  return TargetTransformInfo(KVXTTIImpl(this, F));
}

bool KVXTargetMachine::isNoopAddrSpaceCast(unsigned SrcAS,
                                           unsigned DestAS) const {
  // Addrspacecasts are always noops.
  return true;
}
