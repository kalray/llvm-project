#ifndef LLVM_LIB_TARGET_K1C_K1C_H
#define LLVM_LIB_TARGET_K1C_K1C_H

#include "MCTargetDesc/K1CMCTargetDesc.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {
class FunctionPass;
class K1CTargetMachine;
class MachineInstr;
class AsmPrinter;
class MCInst;

FunctionPass *createK1CISelDag(K1CTargetMachine &TM);

void LowerK1CMachineInstrToMCInst(const MachineInstr *MI, MCInst &OutMI, AsmPrinter &AP);

}

#endif // LLVM_LIB_TARGET_K1C_K1C_H
