#ifndef LLVM_LIB_TARGET_K1C_K1C_H
#define LLVM_LIB_TARGET_K1C_K1C_H

#include "llvm/Target/TargetMachine.h"

namespace llvm
{
class FunctionPass;
class K1CTargetMachine;

FunctionPass *createK1CISelDag(K1CTargetMachine &TM);
}

#endif // LLVM_LIB_TARGET_K1C_K1C_H