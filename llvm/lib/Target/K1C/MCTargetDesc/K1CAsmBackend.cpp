//===-- K1CAsmBackend.cpp - K1C Assembler Backend -------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/K1CMCTargetDesc.h"
#include "llvm/MC/MCAsmBackend.h"
#include "llvm/MC/MCELFObjectWriter.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCFixupKindInfo.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCValue.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

namespace {
class K1CAsmBackend : public MCAsmBackend {
protected:
  const Target &TheTarget;
  bool Is64Bit;

public:
  K1CAsmBackend(const Target &T)
      : MCAsmBackend(support::little), TheTarget(T), Is64Bit(true) {}

  bool mayNeedRelaxation(const MCInst &Inst, const MCSubtargetInfo &STI) const
      override {
    // FIXME mayNeedRelaxation() unimplemented
    return false;
  }

  bool writeNopData(raw_ostream &OS, uint64_t Count) const override {
    // FIXME writeNopData() unimplemented
    return true;
  }
};

class ELFK1CAsmBackend : public K1CAsmBackend {
  Triple::OSType OSType;

public:
  ELFK1CAsmBackend(const Target &T, Triple::OSType OSType)
      : K1CAsmBackend(T), OSType(OSType) {}

  void applyFixup(const MCAssembler &Asm, const MCFixup &Fixup,
                  const MCValue &Target, MutableArrayRef<char> Data,
                  uint64_t Value, bool IsResolved,
                  const MCSubtargetInfo *STI) const override {
    // FIXME applyFixup() unimplemented
  }

  unsigned getNumFixupKinds() const override {
    // FIXME getNumFixupKinds() unimplemented
    return 0;
  }

  bool fixupNeedsRelaxation(const MCFixup &Fixup, uint64_t Value,
                            const MCRelaxableFragment *DF,
                            const MCAsmLayout &Layout) const override {
    // FIXME fixupNeedsRelaxation() unimplemented
    return false;
  }

  void relaxInstruction(const MCInst &Inst, const MCSubtargetInfo &STI,
                        MCInst &Res) const override {
    // FIXME relaxInstruction() unimplemented
  }

  std::unique_ptr<MCObjectTargetWriter> createObjectTargetWriter() const
      override {
    uint8_t OSABI = MCELFObjectTargetWriter::getOSABI(OSType);
    return createK1CELFObjectWriter(Is64Bit, OSABI);
  }
};
}

MCAsmBackend *llvm::createK1CAsmBackend(const Target &T,
                                        const MCSubtargetInfo &STI,
                                        const MCRegisterInfo &MRI,
                                        const MCTargetOptions &Options) {
  return new ELFK1CAsmBackend(T, STI.getTargetTriple().getOS());
}
