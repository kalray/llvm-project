//===-- K1CMCCodeEmitter.cpp - Convert K1C code to machine code -----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the K1CMCCodeEmitter class.
//
//===----------------------------------------------------------------------===//

#include "K1CMCTargetDesc.h"
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

class K1CMCCodeEmitter : public MCCodeEmitter {
  const MCInstrInfo &MCII __attribute__((unused));
  MCContext &Ctx __attribute__((unused));

public:
  K1CMCCodeEmitter(const MCInstrInfo &mcii, MCContext &ctx)
      : MCII(mcii), Ctx(ctx) {}
  K1CMCCodeEmitter(const K1CMCCodeEmitter &) = delete;
  K1CMCCodeEmitter &operator=(const K1CMCCodeEmitter &) = delete;
  ~K1CMCCodeEmitter() override = default;

  void encodeInstruction(const MCInst &MI, raw_ostream &OS,
                         SmallVectorImpl<MCFixup> &Fixups,
                         const MCSubtargetInfo &STI) const override;
};
} // end anonymous namespace

MCCodeEmitter *llvm::createK1CMCCodeEmitter(const MCInstrInfo &MCII,
                                            const MCRegisterInfo &MRI,
                                            MCContext &Ctx) {
  return new K1CMCCodeEmitter(MCII, Ctx);
}

void K1CMCCodeEmitter::encodeInstruction(const MCInst &MI, raw_ostream &OS,
                                         SmallVectorImpl<MCFixup> &Fixups,
                                         const MCSubtargetInfo &STI) const {
  // FIXME encodeInstruction() unimplemented
}
