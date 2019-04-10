#include "K1TargetMachine.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

extern "C" void LLVMInitializeK1Target()
{
    RegisterTargetMachine<K1TargetMachine> X(getTheK1Target());
}

static Reloc::Model getEffectiveRelocModel(const Triple &TT,
                                           Optional<Reloc::Model> RM) {
  if (!RM.hasValue())
    return Reloc::Static;
  return *RM;
}

K1TargetMachine::K1TargetMachine(const Target &T, const Triple &TT,
                                       StringRef CPU, StringRef FS,
                                       const TargetOptions &Options,
                                       Optional<Reloc::Model> RM,
                                       Optional<CodeModel::Model> CM,
                                       CodeGenOpt::Level OL, bool JIT)
        : LLVMTargetMachine(T, "e-m:e-p:64:64-i64:64-i128:128-n64-S128", TT, CPU, FS, Options,
                        getEffectiveRelocModel(TT, RM),
                        getEffectiveCodeModel(CM, CodeModel::Small), OL)
{
  initAsmInfo();
}