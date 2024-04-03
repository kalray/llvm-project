//==-- KVX.h - Top-level interface for KVX  ----------------------*- C++ -*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the entry points for global functions defined in the LLVM
// KVX back-end.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_KVX_KVX_H
#define LLVM_LIB_TARGET_KVX_KVX_H

#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/PassRegistry.h"
#include "llvm/Support/CodeGen.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Target/KVX/KVXCommon.h"

class KVXAsmPrinter;
extern llvm::cl::OptionCategory KVXclOpts;
namespace llvm {
class FunctionPass;
class KVXTargetMachine;
class MachineInstr;
class AsmPrinter;
class MCInst;

namespace KVXMOD {
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

enum SILENT {
  SILENT_,
  SILENT_S
};

enum ROUNDINT {
  ROUNDINT_RN,
  ROUNDINT_RU,
  ROUNDINT_RD,
  ROUNDINT_RZ,
  ROUNDINT_RHU
};

enum SATURATE {
  SATURATE_SAT,
  SATURATE_SATU
};

enum RECTIFY {
  RECTIFY_,
  RECTIFY_RELU
};

enum VARIANT {
  VARIANT_,
  VARIANT_S,
  VARIANT_U,
  VARIANT_US
};

enum SPECULATE {
  SPECULATE_,
  SPECULATE_S
};

enum COLUMN {
  COLUMN_C0,
  COLUMN_C1,
  COLUMN_C2,
  COLUMN_C3
};

enum DOSCALE {
  DOSCALE_,
  DOSCALE_XS
};

enum SPLAT32 {
  SPLAT32_,
  SPLAT32_AT
};

enum COHERENCY { COHERENCY_, COHERENCY_G, /*COHERENCY_S*/ };

enum BOOLCAS { BOOLCAS_V, BOOLCAS_ };

} // namespace KVXMOD

/// KVXII - This namespace holds all of the target specific flags that
/// instruction info tracks.
namespace KVXII {
// MCInstrDesc TSFlags
// *** Must match KVXInstrFormat.td ***
enum {
  /* --- bit 0 --- */
  hasNoOffsetPos = 0,
  hasNoOffsetMask = 1,

  /* --- bits 2-1 --- */
  XSModRelPosPos = 1,
  XSModRelPosMask = 0x3,

  /* --- bits 5-3 --- */
  MemAccessSizePos = 3,
  MemAccessSizeMask = 0x7

  /* --- bits 63-6 not allocated yet --- */
};

inline uint64_t getKVXFlag(const MachineInstr &MI, int Pos, int Mask) {
  uint64_t F = MI.getDesc().TSFlags;
  return F >> Pos & Mask;
}

} // namespace KVXII

namespace KVX {
enum STAGE { PRE_RA, PRE_SCHED2, PRE_BUNDLE, PRE_EMIT };

} // namespace KVX

bool isScalarcondWord(unsigned Cond);

bool hasStackLimitRegister();

unsigned GetImmOpCode(int64_t imm, unsigned i10code, unsigned i37code,
                      unsigned i64code);
unsigned GetImmMakeOpCode(int64_t imm);

FunctionPass *createKVXISelDag(KVXTargetMachine &TM, CodeGenOptLevel OptLevel);

void LowerKVXMachineInstrToMCInst(const MachineInstr *MI, MCInst &OutMI,
                                  KVXAsmPrinter &AP);

FunctionPass *createKVXExpandPseudoPass(KVX::STAGE);
FunctionPass *createKVXLoadStorePackingPass();
FunctionPass *createKVXHardwareLoopsPass();
FunctionPass *createKVXHardwareLoopsPreparePass();
FunctionPass *createKVXPacketizerPass();
FunctionPass *createKVXCodeGenPreparePass(bool V1);

void initializeKVXExpandPseudoPass(PassRegistry &);
void initializeKVXLoadStorePackingPassPass(PassRegistry &);
void initializeKVXPacketizerPass(PassRegistry &);
void initializeKVXHardwareLoopsPass(PassRegistry &);
void initializeKVXHardwareLoopsPreparePass(PassRegistry &);
void initializeKVXCodeGenPreparePass(PassRegistry &);
} // namespace llvm

#endif // LLVM_LIB_TARGET_KVX_KVX_H
