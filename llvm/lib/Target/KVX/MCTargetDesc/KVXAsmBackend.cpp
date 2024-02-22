//===-- KVXAsmBackend.cpp - KVX Assembler Backend -------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/KVXMCTargetDesc.h"
#include "llvm/MC/MCAsmBackend.h"

using namespace llvm;

namespace {
class KVXAsmBackend : public MCAsmBackend {
protected:
  const Target &TheTarget;
  bool Is64Bit;

public:
  KVXAsmBackend(const Target &T)
      : MCAsmBackend(llvm::endianness::little), TheTarget(T), Is64Bit(true) {}

  bool mayNeedRelaxation(const MCInst &Inst, const MCSubtargetInfo &STI) const
      override {
    // FIXME mayNeedRelaxation() unimplemented
    return false;
  }

  bool writeNopData(raw_ostream &OS, uint64_t Count,
                    const MCSubtargetInfo *STI) const override {
    // FIXME writeNopData() unimplemented
    return true;
  }
};
}
