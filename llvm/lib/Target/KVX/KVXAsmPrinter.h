//===- KVXAsmPrinter.h - KVX LLVM assembly writer -------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains a printer that converts from our internal representation
// of machine-dependent LLVM code to the KVX assembly language.
//
//===----------------------------------------------------------------------===//

#include "InstPrinter/KVXInstPrinter.h"
#include "KVX.h"
#include "MCTargetDesc/KVXMCTargetDesc.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/Support/TargetRegistry.h"

#ifndef LLVM_LIB_TARGET_KVX_KVXASMPRINTER_H
#define LLVM_LIB_TARGET_KVX_KVXASMPRINTER_H

using namespace llvm;

namespace {

class KVXAsmPrinter : public AsmPrinter {
public:
  explicit KVXAsmPrinter(TargetMachine &TM,
                         std::unique_ptr<MCStreamer> Streamer)
      : AsmPrinter(TM, std::move(Streamer)) {}

  StringRef getPassName() const override { return "KVX Assembly Printer"; }

  void EmitInstruction(const MachineInstr *MI) override;

  bool emitPseudoExpansionLowering(MCStreamer &OutStreamer,
                                   const MachineInstr *MI);

  bool PrintAsmOperand(const MachineInstr *MI, unsigned OpNo,
                       const char *ExtraCode, raw_ostream &OS) override;
  bool PrintAsmMemoryOperand(const MachineInstr *MI, unsigned OpNo,
                             const char *ExtraCode, raw_ostream &OS) override;

  void EmitDebugValue(const MCExpr *Value, unsigned Size) const override;

  void emitInlineAsmEnd(const MCSubtargetInfo &StartInfo,
                        const MCSubtargetInfo *EndInfo) const override;
};

} // end of namespace

#endif // LLVM_LIB_TARGET_KVX_KVXASMPRINTER_H
