//===- K1CAsmPrinter.cpp - K1C LLVM assembly writer -----------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains a printer that converts from our internal representation
// of machine-dependent LLVM code to the K1C assembly language.
//
//===----------------------------------------------------------------------===//

#include "K1C.h"
#include "MCTargetDesc/K1CMCTargetDesc.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

namespace {

class K1CAsmPrinter : public AsmPrinter {
public:
  explicit K1CAsmPrinter(TargetMachine &TM,
                         std::unique_ptr<MCStreamer> Streamer)
      : AsmPrinter(TM, std::move(Streamer)) {}

  StringRef getPassName() const override { return "K1C Assembly Printer"; }

  void EmitInstruction(const MachineInstr *MI) override;

  bool emitPseudoExpansionLowering(MCStreamer &OutStreamer,
                                   const MachineInstr *MI);
};

} // end of namespace

#include "K1CGenMCPseudoLowering.inc"

void LowerK1CMachineInstrToMCInst(const MachineInstr *MI, MCInst &OutMI,
                                  const AsmPrinter &AP) {
  OutMI.setOpcode(MI->getOpcode());
}

void K1CAsmPrinter::EmitInstruction(const MachineInstr *MI) {
  // Do any auto-generated pseudo lowerings.
  if (emitPseudoExpansionLowering(*OutStreamer, MI))
    return;

  MCInst TmpInst;
  LowerK1CMachineInstrToMCInst(MI, TmpInst, *this);
  EmitToStreamer(*OutStreamer, TmpInst);
  MCInst bundleInst;
  bundleInst.setOpcode(K1C::Bundle);
  EmitToStreamer(*OutStreamer, bundleInst);
}

extern "C" void LLVMInitializeK1CAsmPrinter() {
  RegisterAsmPrinter<K1CAsmPrinter> X(getTheK1CTarget());
}
