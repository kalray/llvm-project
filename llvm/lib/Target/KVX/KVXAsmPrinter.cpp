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

#include "KVX.h"

#include "InstPrinter/KVXInstPrinter.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/Support/TargetRegistry.h"

namespace {
using namespace llvm;
class KVXAsmPrinter : public AsmPrinter {
public:
  explicit KVXAsmPrinter(TargetMachine &TM,
                         std::unique_ptr<MCStreamer> Streamer)
      : AsmPrinter(TM, std::move(Streamer)) {}

  StringRef getPassName() const override { return "KVX Assembly Printer"; }

  void emitInstruction(const MachineInstr *MI) override;

  bool emitPseudoExpansionLowering(MCStreamer &OutStreamer,
                                   const MachineInstr *MI);

  bool PrintAsmOperand(const MachineInstr *MI, unsigned OpNo,
                       const char *ExtraCode, raw_ostream &OS) override;
  bool PrintAsmMemoryOperand(const MachineInstr *MI, unsigned OpNo,
                             const char *ExtraCode, raw_ostream &OS) override;

  void emitDebugValue(const MCExpr *Value, unsigned Size) const override;

  void emitInlineAsmEnd(const MCSubtargetInfo &StartInfo,
                        const MCSubtargetInfo *EndInfo) const override;
};

#include "KVXGenMCPseudoLowering.inc"

void KVXAsmPrinter::emitInstruction(const MachineInstr *MI) {
  // Do any auto-generated pseudo lowerings.
  if (emitPseudoExpansionLowering(*OutStreamer, MI))
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
  // TODO: Implement ELF object emitter.
  // MC target streamer requires implementing both ASM writter
  // as object file writer. KVX only really implements the ASM
  // one, and the object writer is a dummy one that does nothing.
  // To avoid test crashes dumping a stack trace, avoid
  // using emitRawText when requested to emit object files.
  if (OutStreamer->hasRawTextSupport())
    OutStreamer->emitRawText(StringRef("\t;;\n"));
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

  if (!ExtraCode) {
    const MachineOperand &MO = MI->getOperand(OpNo);
    // For now, we only support register memory operands in registers and
    // assume there is no addend
    if (!MO.isReg())
      return true;

    OS << "0(" << KVXInstPrinter::getRegisterName(MO.getReg()) << ")";
    return false;
  }

  return AsmPrinter::PrintAsmMemoryOperand(MI, OpNo, ExtraCode, OS);
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

} // namespace

extern "C" LLVM_EXTERNAL_VISIBILITY void LLVMInitializeKVXAsmPrinter() {
  RegisterAsmPrinter<KVXAsmPrinter> X(getTheKVXTarget());
}
