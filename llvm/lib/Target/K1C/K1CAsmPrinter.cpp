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

bool LowerK1CMachineOperandToMCOperand(const MachineOperand &MO,
                                       MCOperand &MCOp, const AsmPrinter &AP) {
  switch (MO.getType()) {
  default:
    report_fatal_error(
        "LowerK1CMachineOperandToMCOperand: unknown operand type");
  case MachineOperand::MO_Register:
    // Ignore all implicit register operands.
    if (MO.isImplicit())
      return false;
    MCOp = MCOperand::createReg(MO.getReg());
    break;
  case MachineOperand::MO_RegisterMask:
    // Regmasks are like implicit defs.
    return false;
  case MachineOperand::MO_Immediate:
    MCOp = MCOperand::createImm(MO.getImm());
    break;
  case MachineOperand::MO_GlobalAddress:
    MCOp = MCOperand::createExpr(
        MCSymbolRefExpr::create(AP.getSymbol(MO.getGlobal()), AP.OutContext));
    break;
  }
  return true;
}

void LowerK1CMachineInstrToMCInst(const MachineInstr *MI, MCInst &OutMI,
                                  const AsmPrinter &AP) {
  OutMI.setOpcode(MI->getOpcode());
  for (const MachineOperand &MO : MI->operands()) {
    MCOperand MCOp;
    if (LowerK1CMachineOperandToMCOperand(MO, MCOp, AP))
      OutMI.addOperand(MCOp);
  }
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
