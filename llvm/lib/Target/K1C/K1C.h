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

namespace K1CMOD {
enum SCALARCOND {
  SCALARCOND_DNEZ,
  SCALARCOND_DEQZ,
  SCALARCOND_DLTZ,
  SCALARCOND_DGEZ,
  SCALARCOND_DLEZ,
  SCALARCOND_DGTZ,
  SCALARCOND_ODD,
  SCALARCOND_EVEN,
  SCALARCOND_WNEZ,
  SCALARCOND_WEQZ,
  SCALARCOND_WLTZ,
  SCALARCOND_WGEZ,
  SCALARCOND_WLEZ,
  SCALARCOND_WGTZ
};

enum SIMPLECOND {
  SIMPLECOND_NEZ,
  SIMPLECOND_EQZ,
  SIMPLECOND_LTZ,
  SIMPLECOND_GEZ,
  SIMPLECOND_LEZ,
  SIMPLECOND_GTZ,
  SIMPLECOND_ODD,
  SIMPLECOND_EVEN
};

enum COMPARISON {
  COMPARISON_NE,
  COMPARISON_EQ,
  COMPARISON_LT,
  COMPARISON_GE,
  COMPARISON_LE,
  COMPARISON_GT,
  COMPARISON_LTU,
  COMPARISON_GEU,
  COMPARISON_LEU,
  COMPARISON_GTU,
  COMPARISON_ALL,
  COMPARISON_NALL,
  COMPARISON_ANY,
  COMPARISON_NONE
};

enum FLOATCOMP {
  FLOATCOMP_ONE,
  FLOATCOMP_UEQ,
  FLOATCOMP_OEQ,
  FLOATCOMP_UNE,
  FLOATCOMP_OLT,
  FLOATCOMP_UGE,
  FLOATCOMP_OGE,
  FLOATCOMP_ULT
};

enum ROUNDING {
  ROUNDING_RN,
  ROUNDING_RU,
  ROUNDING_RD,
  ROUNDING_RZ,
  ROUNDING_RNA,
  ROUNDING_RNZ,
  ROUNDING_RO,
  ROUNDING_
};

enum SILENT { SILENT_, SILENT_S };

enum ROUNDINT {
  ROUNDINT_RN,
  ROUNDINT_RU,
  ROUNDINT_RD,
  ROUNDINT_RZ,
  ROUNDINT_RHU
};

enum SATURATE { SATURATE_SAT, SATURATE_SATU };

enum RECTIFY { RECTIFY_, RECTIFY_RELU };

enum VARIANT { VARIANT_, VARIANT_S, VARIANT_U, VARIANT_US };

enum SPECULATE { SPECULATE_, SPECULATE_S };

enum COLUMN { COLUMN_C0, COLUMN_C1, COLUMN_C2, COLUMN_C3 };

enum SCALING { SCALING_, SCALING_XS };

enum SPLAT32 { SPLAT32_, SPLAT32_AT };

} // namespace K1CMOD

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
