#ifndef LLVM_LIB_TARGET_K1_K1TARGETMACHINE_H
#define LLVM_LIB_TARGET_K1_K1TARGETMACHINE_H

#include "MCTargetDesc/K1MCTargetDesc.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {

class K1TargetMachine : public LLVMTargetMachine {
public:
    K1TargetMachine(const Target &T, const Triple &TT, StringRef CPU,
                     StringRef FS, const TargetOptions &Options,
                     Optional<Reloc::Model> RM, Optional<CodeModel::Model> CM,
                     CodeGenOpt::Level OL, bool JIT);
};

} // end namespace llvm

#endif // LLVM_LIB_TARGET_K1_K1TARGETMACHINE_H