//===-- K1CMCTargetDesc.h - K1C Target Descriptions -------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file provides K1C specific target descriptions.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_K1C_MCTARGETDESC_K1CMCTARGETDESC_H
#define LLVM_LIB_TARGET_K1C_MCTARGETDESC_K1CMCTARGETDESC_H

#include "llvm/Support/DataTypes.h"

#include <memory>

namespace llvm {
class MCAsmBackend;
class MCCodeEmitter;
class MCInstrInfo;
class MCContext;
class MCObjectTargetWriter;
class MCTargetOptions;
class MCRegisterInfo;
class MCSubtargetInfo;
class Target;
class StringRef;

namespace K1C_MC {
StringRef selectK1CCPU(StringRef CPU);
}

Target &getTheK1CTarget();

MCCodeEmitter *createK1CMCCodeEmitter(const MCInstrInfo &MCII,
                                      const MCRegisterInfo &MRI,
                                      MCContext &Ctx);
MCAsmBackend *createK1CAsmBackend(const Target &T, const MCSubtargetInfo &STI,
                                  const MCRegisterInfo &MRI,
                                  const MCTargetOptions &Options);
std::unique_ptr<MCObjectTargetWriter> createK1CELFObjectWriter(bool Is64Bit,
                                                               uint8_t OSABI);
} // namespace llvm

#define GET_REGINFO_ENUM
#include "K1CGenRegisterInfo.inc"

#define GET_INSTRINFO_ENUM
#define GET_INSTRINFO_SCHED_ENUM
#include "K1CGenInstrInfo.inc"

#define GET_SUBTARGETINFO_ENUM
#include "K1CGenSubtargetInfo.inc"

static inline unsigned getSPReg() { return llvm::K1C::R12; }
static inline unsigned getFPReg() { return llvm::K1C::R14; }

#endif // LLVM_LIB_TARGET_K1C_MCTARGETDESC_K1CMCTARGETDESC_H
