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

#include "InstPrinter/K1CInstPrinter.h"
#include "K1C.h"
#include "MCTargetDesc/K1CMCTargetDesc.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/Support/TargetRegistry.h"

#include "K1CAsmPrinter.h"
#include "K1CGenMCPseudoLowering.inc"

void K1CAsmPrinter::EmitInstruction(const MachineInstr *MI) {
  // Do any auto-generated pseudo lowerings.
  if (emitPseudoExpansionLowering(*OutStreamer, MI))
    return;

  if (MI->getOpcode() == K1C::ENDLOOP)
    return;

  if (MI->isBundle()) {
    for (auto MII = ++MI->getIterator();
         MII != MI->getParent()->instr_end() && MII->isInsideBundle(); ++MII) {
      MCInst TmpInst;
      LowerK1CMachineInstrToMCInst(&*MII, TmpInst, *this);
      EmitToStreamer(*OutStreamer, TmpInst);
    }
  } else {
    MCInst TmpInst;
    LowerK1CMachineInstrToMCInst(MI, TmpInst, *this);
    EmitToStreamer(*OutStreamer, TmpInst);
  }

  OutStreamer->EmitRawText(StringRef("\t;;\n"));
}

bool K1CAsmPrinter::PrintAsmOperand(const MachineInstr *MI, unsigned OpNo,
                                    unsigned AsmVariant, const char *ExtraCode,
                                    raw_ostream &OS) {
  if (AsmVariant != 0)
    report_fatal_error("There are no defined alternate asm variants");

  // First try the generic code, which knows about modifiers like 'c' and 'n'.
  if (!AsmPrinter::PrintAsmOperand(MI, OpNo, AsmVariant, ExtraCode, OS))
    return false;

  if (!ExtraCode) {
    const MachineOperand &MO = MI->getOperand(OpNo);
    switch (MO.getType()) {
    case MachineOperand::MO_Immediate:
      OS << MO.getImm();
      return false;
    case MachineOperand::MO_Register:
      OS << K1CInstPrinter::getRegisterName(MO.getReg());
      return false;
    default:
      break;
    }
  }

  return true;
}

bool K1CAsmPrinter::PrintAsmMemoryOperand(const MachineInstr *MI, unsigned OpNo,
                                          unsigned AsmVariant,
                                          const char *ExtraCode,
                                          raw_ostream &OS) {
  if (AsmVariant != 0)
    report_fatal_error("There are no defined alternate asm variants");

  if (!ExtraCode) {
    const MachineOperand &MO = MI->getOperand(OpNo);
    // For now, we only support register memory operands in registers and
    // assume there is no addend
    if (!MO.isReg())
      return true;

    OS << "0(" << K1CInstPrinter::getRegisterName(MO.getReg()) << ")";
    return false;
  }

  return AsmPrinter::PrintAsmMemoryOperand(MI, OpNo, AsmVariant, ExtraCode, OS);
}

void K1CAsmPrinter::EmitDebugValue(const MCExpr *Value, unsigned Size) const {
  if (Value->getKind() == llvm::MCBinaryExpr::ExprKind::SymbolRef) {
    switch (dyn_cast<MCSymbolRefExpr>(Value)->getKind()) {
      // Do not emit debug value for TLS data
    case MCSymbolRefExpr::VK_K1C_TLSLE:
      return;
    default:
      break;
    }
  }

  AsmPrinter::EmitDebugValue(Value, Size);
}

extern "C" void LLVMInitializeK1CAsmPrinter() {
  RegisterAsmPrinter<K1CAsmPrinter> X(getTheK1CTarget());
}
