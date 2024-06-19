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

#include "KVX.h"
#include "KVXMachineFunctionInfo.h"
#include "KVXLoadLatencyMutation.h"
#include "KVXPostScheduler.h"
#include "KVXTargetMachine.h"
#include "KVXTargetObjectFile.h"
#include "KVXTargetTransformInfo.h"
#include "llvm/CodeGen/MachineScheduler.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/TargetPassConfig.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Target/TargetOptions.h"
#include "llvm/Transforms/Scalar.h"

using namespace llvm;

cl::OptionCategory KVXclOpts("KVX Target Machine Options");
static cl::opt<bool>
    DisableLOOPDO("disable-kvx-hwloops", cl::Hidden, cl::init(false),
                  cl::desc("Disable Hardware Loops for KVX target"),
                  cl::cat(KVXclOpts));

static cl::opt<bool>
    ForceDisableBundling("disable-kvx-bundling", cl::Hidden,
                         cl::desc("Disable Bundling for KVX target"),
                         cl::cat(KVXclOpts));

static cl::opt<bool>
    SwitchOldBundling("switch-old-bundling", cl::Hidden, cl::init(false),
                      cl::desc("Use old bundling (VLIWPacketizer) instead of "
                               "new bundling (MachineScheduler)"),
                      cl::cat(KVXclOpts));

static cl::opt<bool> DisableLoadStorePacking(
    "disable-kvx-loadstore-packing", cl::Hidden, cl::init(false),
    cl::desc("Disable Load/Store Packing Pass for KVX target"),
    cl::cat(KVXclOpts));

static cl::opt<bool> DisableCycleEmission(
    "disable-kvx-cycles", cl::Hidden, cl::init(false),
    cl::desc("Disable machine-cycle emission on KVX target"),
    cl::cat(KVXclOpts));

static cl::opt<bool>
    EnablePipeliner("enable-kvx-pipeliner", cl::Hidden, cl::init(false),
                    cl::desc("Enable MachinePipeliner Pass for KVX target"),
                    cl::cat(KVXclOpts));

static cl::opt<bool>
    DisablePipeliner("disable-kvx-pipeliner", cl::Hidden, cl::init(false),
                     cl::desc("Disable MachinePipeliner Pass for KVX target"),
                     cl::cat(KVXclOpts));

static cl::opt<std::string>
    StackLimitRegister("fstack-limit-register",
                       cl::desc("verify stack with a register for KVX"),
                       cl::cat(KVXclOpts));

extern "C" LLVM_EXTERNAL_VISIBILITY void LLVMInitializeKVXTarget() {
  RegisterTargetMachine<KVXTargetMachine> X(getTheKVXTarget());
  auto *PR = PassRegistry::getPassRegistry();
  initializeKVXCodeGenPreparePass(*PR);
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
                                           std::optional<Reloc::Model> RM) {
  if (!RM.has_value())
    return Reloc::Static;
  return *RM;
}

KVXTargetMachine::KVXTargetMachine(const Target &T, const Triple &TT,
                                   StringRef CPU, StringRef FS,
                                   const TargetOptions &Opts,
                                   std::optional<Reloc::Model> RM,
                                   std::optional<CodeModel::Model> CM,
                                   CodeGenOptLevel OL, bool JIT)
    : LLVMTargetMachine(T,
                        "e-S256-p:64:64-i1:8-i8:8-i16:16-i32:32-i64:64-"
                        "v64:64-v128:128-v256:256-v512:256-v1024:256-"
                        "f16:16-f32:32-f64:64-a:0:64-m:e-n32:64",
                        TT, KVX_MC::selectKVXCPU(CPU), FS, Opts,
                        getEffectiveRelocModel(TT, RM),
                        getEffectiveCodeModel(CM, CodeModel::Small), OL),
      TLOF(std::make_unique<KVXELFTargetObjectFile>()) {

  Options.DisableIntegratedAS = true;
  Options.BinutilsVersion = {2, 40};
  Options.EnableFastISel = false;
  Options.EnableGlobalISel = false;
  Options.EnableCFIFixup = true;
  Options.EnableDebugEntryValues = true;
  Options.MCOptions.CompressDebugSections = DebugCompressionType::None;
  Options.DebuggerTuning = DebuggerKind::GDB;
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
    if (TM.getOptLevel() != CodeGenOptLevel::None)
      disablePass(&PostRASchedulerID);
  }

  KVXTargetMachine &getKVXTargetMachine() const {
    return getTM<KVXTargetMachine>();
  }

  ScheduleDAGInstrs *
  createMachineScheduler(MachineSchedContext *C) const override {
    ScheduleDAGMILive *DAG = createGenericSchedLive(C);
    DAG->addMutation(createKVXLoadLatencyMutation());
    // TODO - These two mutations require to implement shouldClusterMemOps()
    // DAG->addMutation(createLoadClusterDAGMutation(DAG->TII, DAG->TRI));
    // DAG->addMutation(createStoreClusterDAGMutation(DAG->TII, DAG->TRI));
    return DAG;
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
  // Disable bundling at -O0 and -O1
  bool DisableBundling = SwitchOldBundling || ForceDisableBundling ||
                         getOptLevel() <= CodeGenOptLevel::Less;
  if (DisableBundling)
    return new KVXScheduleDAGMI(C, std::make_unique<PostGenericScheduler>(C),
                                /*RemoveKillFlags=*/true, true);
  return new KVXScheduleDAGMI(
      C, std::make_unique<KVXPostScheduler>(C, DisableCycleEmission),
      /*RemoveKillFlags=*/true, false);
}

void KVXPassConfig::addIRPasses() {
  addPass(createAtomicExpandLegacyPass());
  if (getOptLevel() >= CodeGenOptLevel::Less) {
    addPass(createDeadCodeEliminationPass());
    if (getOptLevel() >= CodeGenOptLevel::Default) {
      addPass(createCFGSimplificationPass(SimplifyCFGOptions()
                                              .forwardSwitchCondToPhi(true)
                                          .convertSwitchRangeToICmp(true)
                                          .convertSwitchToLookupTable(true)
                                          .needCanonicalLoops(false)
                                          .hoistCommonInsts(true)
                                          .sinkCommonInsts(true)));
    }
  }
  TargetPassConfig::addIRPasses();
}

bool KVXPassConfig::addInstSelector() {
  addPass(createKVXISelDag(getKVXTargetMachine(), getOptLevel()));

  return false;
}

void KVXPassConfig::addPreRegAlloc() {
  addPass(createKVXExpandPseudoPass(KVX::PRE_RA));
  if (getOptLevel() >= CodeGenOptLevel::Default) {
    if (!DisableLoadStorePacking)
      addPass(createKVXLoadStorePackingPass());
    if (!DisableLOOPDO)
      addPass(createKVXHardwareLoopsPass());
    if ((getOptLevel() >= CodeGenOptLevel::Aggressive || EnablePipeliner) &&
        !DisablePipeliner)
      addPass(&MachinePipelinerID);
  }
}

void KVXPassConfig::addPreSched2() {
  addPass(createKVXExpandPseudoPass(KVX::PRE_SCHED2));
  if (getOptLevel() != CodeGenOptLevel::None)
    addPass(&IfConverterID);
}

void KVXPassConfig::addPreEmitPass() {
  addPass(createKVXExpandPseudoPass(KVX::PRE_BUNDLE));
  addPass(&BranchRelaxationPassID);
  if (getOptLevel() != CodeGenOptLevel::None) {
    addPass(&PostMachineSchedulerID);
    if (SwitchOldBundling)
      addPass(createKVXPacketizerPass());
  }

  addPass(createKVXExpandPseudoPass(KVX::PRE_EMIT));
}

bool KVXPassConfig::addPreISel() {
  auto Opt = TM->getOptLevel();
  if (Opt >= CodeGenOptLevel::Default && !DisableLOOPDO) {
    addPass(createHardwareLoopsLegacyPass());
    addPass(createKVXHardwareLoopsPreparePass());
  }

  if (Opt > CodeGenOptLevel::None)
    addPass(createKVXCodeGenPreparePass(getKVXTargetMachine().isV1()));

  return false;
}

TargetTransformInfo
KVXTargetMachine::getTargetTransformInfo(const Function &F) const {
  return TargetTransformInfo(KVXTTIImpl(this, F));
}

bool KVXTargetMachine::isNoopAddrSpaceCast(unsigned SrcAS,
                                           unsigned DestAS) const {
  // Addrspacecasts are always noops.
  return true;
}

MachineFunctionInfo *KVXTargetMachine::createMachineFunctionInfo(
    BumpPtrAllocator &Allocator, const Function &F,
    const TargetSubtargetInfo *STI) const {
      
  return KVXMachineFunctionInfo::create<KVXMachineFunctionInfo, KVXSubtarget>(
      Allocator, F, static_cast<const KVXSubtarget *>(STI));
}
