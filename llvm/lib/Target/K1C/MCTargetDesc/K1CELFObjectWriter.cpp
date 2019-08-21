//===-- K1CELFObjectWriter.cpp - K1C ELF Writer ---------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/K1CMCTargetDesc.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/MC/MCELFObjectWriter.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCValue.h"
#include "llvm/Support/ErrorHandling.h"

using namespace llvm;

namespace {
class K1CELFObjectWriter : public MCELFObjectTargetWriter {
public:
  K1CELFObjectWriter(bool Is64Bit, uint8_t OSABI)
      : MCELFObjectTargetWriter(Is64Bit, OSABI,
                                /*ELF::???*/ 0,
                                /*HasRelocationAddend*/ true) {}

  ~K1CELFObjectWriter() override {}

protected:
  unsigned getRelocType(MCContext &Ctx, const MCValue &Target,
                        const MCFixup &Fixup, bool IsPCRel) const override;

  bool needsRelocateWithSymbol(const MCSymbol &Sym, unsigned Type) const
      override;
};
}

unsigned K1CELFObjectWriter::getRelocType(MCContext &Ctx, const MCValue &Target,
                                          const MCFixup &Fixup,
                                          bool IsPCRel) const {
  // FIXME getRelocType() unimplemented
  return 0;
}

bool K1CELFObjectWriter::needsRelocateWithSymbol(const MCSymbol &Sym,
                                                 unsigned Type) const {
  // FIXME needsRelocateWithSymbol() unimplemented
  return false;
}

std::unique_ptr<MCObjectTargetWriter>
llvm::createK1CELFObjectWriter(bool Is64Bit, uint8_t OSABI) {
  return llvm::make_unique<K1CELFObjectWriter>(Is64Bit, OSABI);
}
