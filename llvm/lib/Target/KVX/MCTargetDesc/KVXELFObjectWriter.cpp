//===-- KVXELFObjectWriter.cpp - KVX ELF Writer ---------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/KVXMCTargetDesc.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/MC/MCELFObjectWriter.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCValue.h"
#include "llvm/Support/ErrorHandling.h"

using namespace llvm;

namespace {
class KVXELFObjectWriter : public MCELFObjectTargetWriter {
public:
  KVXELFObjectWriter(bool Is64Bit, uint8_t OSABI)
      : MCELFObjectTargetWriter(Is64Bit, OSABI,
                                /*ELF::???*/ 0,
                                /*HasRelocationAddend*/ true) {}

  ~KVXELFObjectWriter() override {}

protected:
  unsigned getRelocType(MCContext &Ctx, const MCValue &Target,
                        const MCFixup &Fixup, bool IsPCRel) const override;

  bool needsRelocateWithSymbol(const MCSymbol &Sym, unsigned Type) const
      override;
};
}

unsigned KVXELFObjectWriter::getRelocType(MCContext &Ctx, const MCValue &Target,
                                          const MCFixup &Fixup,
                                          bool IsPCRel) const {
  // FIXME getRelocType() unimplemented
  return 0;
}

bool KVXELFObjectWriter::needsRelocateWithSymbol(const MCSymbol &Sym,
                                                 unsigned Type) const {
  // FIXME needsRelocateWithSymbol() unimplemented
  return false;
}

std::unique_ptr<MCObjectTargetWriter>
llvm::createKVXELFObjectWriter(bool Is64Bit, uint8_t OSABI) {
  return llvm::make_unique<KVXELFObjectWriter>(Is64Bit, OSABI);
}
