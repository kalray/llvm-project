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

#include "KVXAsmPrinter.h"
#include "InstPrinter/KVXInstPrinter.h"
#include "KVXGenMCPseudoLowering.inc"
#include "llvm/CodeGen/TargetSubtargetInfo.h"
#include "llvm/MC/TargetRegistry.h"

static inline bool sortStr(const MCInst &Lhs, const MCInst &Rhs) {
  // Sort them in a string comparison manner
  std::string LhsStr, RhsStr;
  raw_string_ostream LhsStream(LhsStr), RhsStream(RhsStr);
  Lhs.print(LhsStream);
  Rhs.print(RhsStream);
  return strcmp(LhsStr.c_str(), RhsStr.c_str()) <= 0;
}

bool comparePairs(const MCInst &Lhs, const MCInst &Rhs) {
  // Put `ret` at the end
  if (Lhs.getOpcode() == KVX::RET)
    return false;

  if (Rhs.getOpcode() == KVX::RET)
    return true;

  // Instructions without operands at the end
  if (Lhs.getNumOperands() == 0) {
    if (Rhs.getNumOperands() == 0)
      return sortStr(Lhs, Rhs);
    return false;
  }
  if (Rhs.getNumOperands() == 0)
    return true;

  // Immediates before regs
  if (Lhs.getOperand(0).isImm()) {
    if (Rhs.getOperand(0).isImm()) {
      if (Lhs.getOperand(0).getImm() == Rhs.getOperand(0).getImm())
        return sortStr(Lhs, Rhs);
      return Lhs.getOperand(0).getImm() < Rhs.getOperand(0).getImm();
    }
    return true;
  }
  if (Rhs.getOperand(0).isImm())
    return false;

  // Sort by first operand register
  if (Lhs.getOperand(0).isReg()) {
    if (Rhs.getOperand(0).isReg()) {
      if (Lhs.getOperand(0).getReg() == Rhs.getOperand(0).getReg())
        return sortStr(Lhs, Rhs);

      return Lhs.getOperand(0).getReg() < Rhs.getOperand(0).getReg();
    }
    return true;
  }
  if (Rhs.getOperand(0).isReg())
    return false;

  return sortStr(Lhs, Rhs);
}

bool KVXAsmPrinter::runOnMachineFunction(MachineFunction &MF) {
  TRI = MF.getSubtarget().getRegisterInfo();
  return AsmPrinter::runOnMachineFunction(MF);
}

void KVXAsmPrinter::emitInstruction(const MachineInstr *MI) {
  // Do any auto-generated pseudo lowerings.
  if (emitPseudoExpansionLowering(*OutStreamer, MI))
    return;

  // Some MCYCLESp are not bundled: print them separately
  if (MI->getOpcode() == KVX::MCYCLESp) {
    unsigned Cycles = MI->getOperand(0).getImm();
    OutStreamer->emitRawText("\t        # (here cycle " +
                             std::to_string(Cycles) + ")");
    return;
  }

  SmallVector<MCInst, 8> Bundle;
  if (MI->isBundle()) {
    // Sort instructions in bundle.
    for (auto MII = ++MI->getIterator();
         MII != MI->getParent()->instr_end() && MII->isInsideBundle(); ++MII) {
      switch (MII->getOpcode()) {
      case KVX::MCYCLESp:
        continue;
      case KVX::IMPLICIT_DEF:
        if (isVerbose())
          AsmPrinter::emitImplicitDef(&*MII);
        continue;
      case KVX::KILL:
        if (isVerbose())
          AsmPrinter::emitKill(&*MII);
        continue;
      }
      MCInst TmpInst;
      LowerKVXMachineInstrToMCInst(&*MII, TmpInst, *this);
      Bundle.push_back(TmpInst);
    }
    std::sort(Bundle.begin(), Bundle.end(), comparePairs);

    for (MCInst &I : Bundle)
      EmitToStreamer(*OutStreamer, I);
  } else {
    MCInst TmpInst;
    LowerKVXMachineInstrToMCInst(MI, TmpInst, *this);
    EmitToStreamer(*OutStreamer, TmpInst);
  }

  std::string BundleEnd = "\t;;";
  auto NextMII = std::next(MI->getIterator());
  if (NextMII != MI->getParent()->end() &&
      NextMII->getOpcode() == KVX::MCYCLESp) {
    // Special treatment of MCYCLESp
    unsigned Cycles = NextMII->getOperand(0).getImm();
    BundleEnd += "      # (end cycle " + std::to_string(Cycles) + ")";
  }

  // TODO: Implement ELF object emitter.
  // MC target streamer requires implementing both ASM writter
  // as object file writer. KVX only really implements the ASM
  // one, and the object writer is a dummy one that does nothing.
  // To avoid test crashes dumping a stack trace, avoid
  // using emitRawText when requested to emit object files.
  if (OutStreamer->hasRawTextSupport())
    OutStreamer->emitRawText(BundleEnd);
}

bool KVXAsmPrinter::PrintAsmOperand(const MachineInstr *MI, unsigned OpNo,
                                    const char *ExtraCode, raw_ostream &OS) {

  // First try the generic code, which knows about modifiers like 'c' and 'n'.
  if (!AsmPrinter::PrintAsmOperand(MI, OpNo, ExtraCode, OS))
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
                                          const char *ExtraCode,
                                          raw_ostream &OS) {
  if (ExtraCode)
    return true;

  const MachineOperand &MO = MI->getOperand(OpNo);
  // For now, we only support register memory operands in registers and
  // assume there is no addend
  if (!MO.isReg())
    return true;

  OS << "0[" << KVXInstPrinter::getRegisterName(MO.getReg()) << "]";
  return false;
}

void KVXAsmPrinter::emitDebugValue(const MCExpr *Value, unsigned Size) const {
  if (Value->getKind() == llvm::MCBinaryExpr::ExprKind::SymbolRef) {
    auto V = dyn_cast<MCSymbolRefExpr>(Value)->getKind();
    switch (V) {
    // Do not emit debug value for TLS data
    case MCSymbolRefExpr::VK_KVX_TLSLE:
      return;
    default:
      return AsmPrinter::emitDebugValue(Value, Size);
    }
  }
}

void KVXAsmPrinter::emitInlineAsmEnd(const MCSubtargetInfo &StartInfo,
                                     const MCSubtargetInfo *EndInfo) const {
  OutStreamer->emitRawText(StringRef("\t;;\n"));
}

extern "C" LLVM_EXTERNAL_VISIBILITY void LLVMInitializeKVXAsmPrinter() {
  RegisterAsmPrinter<KVXAsmPrinter> X(getTheKVXTarget());
}
