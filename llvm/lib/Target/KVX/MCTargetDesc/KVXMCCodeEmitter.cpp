//===-- KVXMCCodeEmitter.cpp - Convert KVX code to machine code -----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the KVXMCCodeEmitter class.
//
//===----------------------------------------------------------------------===//

#include "KVXMCTargetDesc.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/MC/MCCodeEmitter.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

#define DEBUG_TYPE "mccodeemitter"

namespace {

class KVXMCCodeEmitter : public MCCodeEmitter {
  const MCInstrInfo &MCII __attribute__((unused));
  MCContext &Ctx __attribute__((unused));

public:
  KVXMCCodeEmitter(const MCInstrInfo &mcii, MCContext &ctx)
      : MCII(mcii), Ctx(ctx) {}
  KVXMCCodeEmitter(const KVXMCCodeEmitter &) = delete;
  KVXMCCodeEmitter &operator=(const KVXMCCodeEmitter &) = delete;
  ~KVXMCCodeEmitter() override = default;

  void encodeInstruction(const MCInst &MI, raw_ostream &OS,
                         SmallVectorImpl<MCFixup> &Fixups,
                         const MCSubtargetInfo &STI) const override;
};
} // end anonymous namespace

MCCodeEmitter *llvm::createKVXMCCodeEmitter(const MCInstrInfo &MCII,
                                            const MCRegisterInfo &MRI,
                                            MCContext &Ctx) {
  return new KVXMCCodeEmitter(MCII, Ctx);
}

void KVXMCCodeEmitter::encodeInstruction(const MCInst &MI, raw_ostream &OS,
                                         SmallVectorImpl<MCFixup> &Fixups,
                                         const MCSubtargetInfo &STI) const {
  // FIXME encodeInstruction() unimplemented
}
