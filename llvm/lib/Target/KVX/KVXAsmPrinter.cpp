//===- KVXAsmPrinter.cpp - KVX LLVM assembly writer -----------------------===//
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

#include "KVXAsmPrinter.h"
#include "KVXGenMCPseudoLowering.inc"

void KVXAsmPrinter::EmitInstruction(const MachineInstr *MI) {
  // Do any auto-generated pseudo lowerings.
  if (emitPseudoExpansionLowering(*OutStreamer, MI))
    return;

  if (MI->getOpcode() == KVX::ENDLOOP)
    return;

  if (MI->isBundle()) {
    for (auto MII = ++MI->getIterator();
         MII != MI->getParent()->instr_end() && MII->isInsideBundle(); ++MII) {
      MCInst TmpInst;
      LowerKVXMachineInstrToMCInst(&*MII, TmpInst, *this);
      EmitToStreamer(*OutStreamer, TmpInst);
    }
  } else {
    MCInst TmpInst;
    LowerKVXMachineInstrToMCInst(MI, TmpInst, *this);
    EmitToStreamer(*OutStreamer, TmpInst);
  }

  OutStreamer->EmitRawText(StringRef("\t;;\n"));
}

bool KVXAsmPrinter::PrintAsmOperand(const MachineInstr *MI, unsigned OpNo,
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
      OS << KVXInstPrinter::getRegisterName(MO.getReg());
      return false;
    default:
      break;
    }
  }

  return true;
}

bool KVXAsmPrinter::PrintAsmMemoryOperand(const MachineInstr *MI, unsigned OpNo,
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

    OS << "0(" << KVXInstPrinter::getRegisterName(MO.getReg()) << ")";
    return false;
  }

  return AsmPrinter::PrintAsmMemoryOperand(MI, OpNo, AsmVariant, ExtraCode, OS);
}

void KVXAsmPrinter::EmitDebugValue(const MCExpr *Value, unsigned Size) const {
  if (Value->getKind() == llvm::MCBinaryExpr::ExprKind::SymbolRef) {
    switch (dyn_cast<MCSymbolRefExpr>(Value)->getKind()) {
    // Do not emit debug value for TLS data
    case MCSymbolRefExpr::VK_KVX_TLSLE:
      return;
    default:
      break;
    }
  }

  AsmPrinter::EmitDebugValue(Value, Size);
}

void KVXAsmPrinter::emitInlineAsmEnd(const MCSubtargetInfo &StartInfo,
                                     const MCSubtargetInfo *EndInfo) const {
  OutStreamer->EmitRawText(StringRef("\t;;\n"));
}

extern "C" void LLVMInitializeKVXAsmPrinter() {
  RegisterAsmPrinter<KVXAsmPrinter> X(getTheKVXTarget());
}
