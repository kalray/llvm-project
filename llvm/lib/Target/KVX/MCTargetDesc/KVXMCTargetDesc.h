//===-- KVXMCTargetDesc.h - KVX Target Descriptions -------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file provides KVX specific target descriptions.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_KVX_MCTARGETDESC_KVXMCTARGETDESC_H
#define LLVM_LIB_TARGET_KVX_MCTARGETDESC_KVXMCTARGETDESC_H

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

namespace KVX_MC {
StringRef selectKVXCPU(StringRef CPU);
}

Target &getTheKVXTarget();

MCCodeEmitter *createKVXMCCodeEmitter(const MCInstrInfo &MCII,
                                      const MCRegisterInfo &MRI,
                                      MCContext &Ctx);
MCAsmBackend *createKVXAsmBackend(const Target &T, const MCSubtargetInfo &STI,
                                  const MCRegisterInfo &MRI,
                                  const MCTargetOptions &Options);
std::unique_ptr<MCObjectTargetWriter> createKVXELFObjectWriter(bool Is64Bit,
                                                               uint8_t OSABI);
} // namespace llvm

#define GET_REGINFO_ENUM
#include "KVXGenRegisterInfo.inc"

#define GET_INSTRINFO_ENUM
#define GET_INSTRINFO_SCHED_ENUM
#include "KVXGenInstrInfo.inc"

#define GET_SUBTARGETINFO_ENUM
#include "KVXGenSubtargetInfo.inc"

static inline unsigned getSPReg() { return llvm::KVX::R12; }
static inline unsigned getFPReg() { return llvm::KVX::R14; }

#endif // LLVM_LIB_TARGET_KVX_MCTARGETDESC_KVXMCTARGETDESC_H
