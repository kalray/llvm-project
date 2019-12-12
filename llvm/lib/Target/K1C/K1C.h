//==-- K1C.h - Top-level interface for K1C  ----------------------*- C++ -*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the entry points for global functions defined in the LLVM
// K1C back-end.
//
//===----------------------------------------------------------------------===//

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

unsigned GetImmOpCode(int64_t imm, unsigned i10code, unsigned i37code,
                      unsigned i64code);

FunctionPass *createK1CISelDag(K1CTargetMachine &TM);

void LowerK1CMachineInstrToMCInst(const MachineInstr *MI, MCInst &OutMI,
                                  AsmPrinter &AP);

FunctionPass *createK1CExpandPseudoPass();
FunctionPass *createK1CLoadStorePackingPass();
FunctionPass *createK1CHardwareLoopsPass();
FunctionPass *createK1CPacketizerPass(bool ValidOptLevel);

void initializeK1CExpandPseudoPass(PassRegistry &);
void initializeK1CLoadStorePackingPassPass(PassRegistry &);
void initializeK1CPacketizerPass(PassRegistry &);
void initializeK1CHardwareLoopsPass(PassRegistry &);
} // namespace llvm

#endif // LLVM_LIB_TARGET_K1C_K1C_H
