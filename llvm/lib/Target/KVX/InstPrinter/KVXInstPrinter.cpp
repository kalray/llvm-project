//===-- KVXInstPrinter.h - Convert KVX MCInst to assembly syntax ----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This class prints a KVX MCInst to a .s file.
//
//===----------------------------------------------------------------------===//

#include "KVXInstPrinter.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/FormattedStream.h"
#include <sstream>

using namespace llvm;

#define DEBUG_TYPE "asm-printer"

// Include the auto-generated portion of the assembly writer.
#define PRINT_ALIAS_INSTR
#include "KVXGenAsmWriter.inc"

void KVXInstPrinter::printInst(const MCInst *MI, uint64_t Address, StringRef Annot,
                               const MCSubtargetInfo &STI, raw_ostream &O) {
  printInstruction(MI, Address, O);
}

void KVXInstPrinter::printRegName(raw_ostream &O, unsigned RegNo) const {
  O << getRegisterName(RegNo);
}

void
KVXInstPrinter::printOperand(const MCInst *MI, unsigned OpNo,
                             /*const MCSubtargetInfo &STI,*/ raw_ostream &O,
                             const char *Modifier) {
  if (!(Modifier == 0 || Modifier[0] == 0))
    report_fatal_error("No modifiers supported");

  const MCOperand &MO = MI->getOperand(OpNo);

  if (MO.isReg()) {
    printRegName(O, MO.getReg());
    return;
  }

  if (MO.isFPImm()) {
    unsigned Opcode = MI->getOpcode();
    switch (Opcode) {
    // FP is a half
    case KVX::MAKEi16:
      printBinary16ImmOperand(MI, OpNo, O);
      break;
    // FP is a float
    case KVX::MAKEi43:
    case KVX::CMOVEDri37:
      printBinary32ImmOperand(MI, OpNo, O);
      break;
    // FP is a double
    case KVX::MAKEi64:
    case KVX::CMOVEDri64:
      printBinary64ImmOperand(MI, OpNo, O);
      break;
    default:
      report_fatal_error("unable to determine FPImm size");
    }
    return;
  }

  if (MO.isImm()) {
    std::stringstream s;
    if (std::abs(MO.getImm()) > 1024)
      s << "0x" << std::hex << MO.getImm();
    else
      s << MO.getImm();

    O << s.str();
    return;
  }

  if (!MO.isExpr())
    report_fatal_error("Unknown operand kind in printOperand");

  MO.getExpr()->print(O, &MAI);
}

void KVXInstPrinter::printVariantMod(
    const MCInst *MI, unsigned OpNo,
    /*const MCSubtargetInfo &STI,*/ raw_ostream &O) {
  const MCOperand &MO = MI->getOperand(OpNo);
  int variant = MO.getImm();
  switch (variant) {
  case 0:
    break;
  case 1:
    O << ".s";
    break;
  case 2:
    O << ".u";
    break;
  case 3:
    O << ".us";
    break;
  }
}

void KVXInstPrinter::printDoscaleMod(
    const MCInst *MI, unsigned OpNo,
    /*const MCSubtargetInfo &STI,*/ raw_ostream &O) {
  const MCOperand &MO = MI->getOperand(OpNo);
  int variant = MO.getImm();
  switch (variant) {
  case 0:
    break;
  case 1:
    O << ".xs";
    break;
  }
}

void KVXInstPrinter::printRoundintMod(const MCInst *MI, unsigned OpNo,
                                      raw_ostream &O) {
  O << ".r";
  int V = MI->getOperand(OpNo).getImm();
  switch (V) {
  case 0:
    O << 'n';
    break;
  case 1:
    O << 'u';
    break;
  case 2:
    O << 'd';
    break;
  case 3:
    O << 'z';
    break;
  case 4:
    O << "hu";
    break;
  default:
    llvm::errs() << "\nUnexpected value for int rounding mode: " << V << "\n";
    report_fatal_error("Invalid rounding mode.");
    break;
  }
}

void KVXInstPrinter::printSaturateMod(const MCInst *MI, unsigned OpNo,
                                      raw_ostream &O) {
  O << ".sat";
  const int V = MI->getOperand(OpNo).getImm();
  if (V) {
    if (V == 1)
      O << 'u';
    else {
      llvm::errs() << "\nUnexpected value for int saturation mode: " << V
                   << "\n";
      report_fatal_error("Invalid saturation mode.");
    }
  }
}

void KVXInstPrinter::printRectifyMod(const MCInst *MI, unsigned OpNo,
                                     raw_ostream &O) {
  const int V = MI->getOperand(OpNo).getImm();
  if (V) {
    if (V == 1)
      O << ".relu";
    else {
      llvm::errs() << "\nUnexpected value for rectify mode: " << V << "\n";
      report_fatal_error("Invalid rectify mode.");
    }
  }
}

void KVXInstPrinter::printScalarcondMod(
    const MCInst *MI, unsigned OpNo,
    /*const MCSubtargetInfo &STI,*/ raw_ostream &O) {
  const MCOperand &MO = MI->getOperand(OpNo);
  int variant = MO.getImm();
  switch (variant) {
  case 0:
    O << ".dnez";
    break;
  case 1:
    O << ".deqz";
    break;
  case 2:
    O << ".dltz";
    break;
  case 3:
    O << ".dgez";
    break;
  case 4:
    O << ".dlez";
    break;
  case 5:
    O << ".dgtz";
    break;
  case 6:
    O << ".odd";
    break;
  case 7:
    O << ".even";
    break;
  case 8:
    O << ".wnez";
    break;
  case 9:
    O << ".weqz";
    break;
  case 10:
    O << ".wltz";
    break;
  case 11:
    O << ".wgez";
    break;
  case 12:
    O << ".wlez";
    break;
  case 13:
    O << ".wgtz";
    break;
  }
}

void KVXInstPrinter::printSimplecondMod(
    const MCInst *MI, unsigned OpNo,
    /*const MCSubtargetInfo &STI,*/ raw_ostream &O) {
  int Variant = MI->getOperand(OpNo).getImm();
  const char *VariantList[] = {".nez", ".eqz", ".ltz", ".gez",
                               ".lez", ",gtz", ".odd", ".even"};
  if (Variant < 8)
    O << VariantList[Variant];
  else
    report_fatal_error("Unexpected simple condition value: ");
}

void KVXInstPrinter::printComparisonMod(
    const MCInst *MI, unsigned OpNo,
    /*const MCSubtargetInfo &STI,*/ raw_ostream &O) {
  const MCOperand &MO = MI->getOperand(OpNo);
  int variant = MO.getImm();
  switch (variant) {
  case 0:
    O << ".ne";
    break;
  case 1:
    O << ".eq";
    break;
  case 2:
    O << ".lt";
    break;
  case 3:
    O << ".ge";
    break;
  case 4:
    O << ".le";
    break;
  case 5:
    O << ".gt";
    break;
  case 6:
    O << ".ltu";
    break;
  case 7:
    O << ".geu";
    break;
  case 8:
    O << ".leu";
    break;
  case 9:
    O << ".gtu";
    break;
  case 10:
    O << ".all";
    break;
  case 11:
    O << ".nall";
    break;
  case 12:
    O << ".any";
    break;
  case 13:
    O << ".none";
    break;
  }
}

void KVXInstPrinter::printMemOperand(
    const MCInst *MI, unsigned OpNo,
    /*const MCSubtargetInfo &STI,*/ raw_ostream &O) {
  printOperand(MI, OpNo, O);
  O << "[";
  printOperand(MI, OpNo + 1, O);
  O << "]";
}

void KVXInstPrinter::printRoundingMod(const MCInst *MI, unsigned OpNo,
                                      raw_ostream &O) {
  const MCOperand &MO = MI->getOperand(OpNo);
  int rounding = MO.getImm();
  switch (rounding) {
  case 0: // Round to Nearest, ties to Even
    O << ".rn";
    break;
  case 1: // Round Upward
    O << ".ru";
    break;
  case 2: // Round Downward
    O << ".rd";
    break;
  case 3: // Round toward Zero
    O << ".rz";
    break;
  case 4: // Round to Nearest, ties Away from zero
    O << ".rna";
    break;
  case 5: // Round no Nearest, ties to Zero
    O << ".rnz";
    break;
  case 6: // Round to Odd
    O << ".ro";
    break;
  case 7: // Use CS rounding
    break;
  default:
    report_fatal_error("illegal rounding mode");
  }
}

void KVXInstPrinter::printSilentMod(const MCInst *MI, unsigned OpNo,
                                    raw_ostream &O) {
  const MCOperand &MO = MI->getOperand(OpNo);
  int Silent = MO.getImm();
  switch (Silent) {
  case 0: // Effects on CS
    break;
  case 1: // Silent on CS
    O << ".s";
    break;
  default:
    report_fatal_error("illegal silent mode");
  }
}

void KVXInstPrinter::printSpeculateMod(const MCInst *MI, unsigned OpNo,
                                       raw_ostream &O) {
  // Can use silent mode: 0 = normal = "" / 1 = speculative = ".s"
  printSilentMod(MI, OpNo, O);
}

void KVXInstPrinter::printColumnMod(const MCInst *MI, unsigned OpNo,
                                    raw_ostream &O) {
  int Column = MI->getOperand(OpNo).getImm();
  if (!isUInt<2>(Column))
    report_fatal_error("Unexpected column value for load matrix column, should "
                       "be in range [0, 3].");

  O << ".c" << Column;
}

void KVXInstPrinter::printFloatcompMod(const MCInst *MI, unsigned OpNo,
                                       raw_ostream &O) {
  const MCOperand &MO = MI->getOperand(OpNo);
  int floatcomp = MO.getImm();
  switch (floatcomp) {
  case 0: // Ordered and Not Equal
    O << ".one";
    break;
  case 1: // Unordered or Equal
    O << ".ueq";
    break;
  case 2: // Ordered and Equal
    O << ".oeq";
    break;
  case 3: // Unordered and Not Equal
    O << ".une";
    break;
  case 4: // Ordered and Less Than
    O << ".olt";
    break;
  case 5: // Unordered or Greater Than or Equal
    O << ".uge";
    break;
  case 6: // Ordered and Greater Than or Equal
    O << ".oge";
    break;
  case 7: // Unordered or Less Than
    O << ".ult";
    break;
  default:
    report_fatal_error("illegal rounding mode");
  }
}

void KVXInstPrinter::printBinary16ImmOperand(const MCInst *MI, unsigned OpNo,
                                             raw_ostream &O) {
  printFPImmOperand(MI, OpNo, 16, O);
  return;
}
void KVXInstPrinter::printBinary32ImmOperand(const MCInst *MI, unsigned OpNo,
                                             raw_ostream &O) {
  printFPImmOperand(MI, OpNo, 32, O);
  return;
}
void KVXInstPrinter::printBinary64ImmOperand(const MCInst *MI, unsigned OpNo,
                                             raw_ostream &O) {
  printFPImmOperand(MI, OpNo, 64, O);
  return;
}

void KVXInstPrinter::printFPImmOperand(const MCInst *MI, unsigned OpNo,
                                       unsigned Size, raw_ostream &O) {
  const MCOperand &MO = MI->getOperand(OpNo);
  if (!MO.isFPImm()) {
    if (MO.isImm())
      return printOperand(MI, OpNo, O);

    LLVM_DEBUG(MI->dump(); errs() << "Bad FP operand:"; MO.dump());
    report_fatal_error("illegal fp operand");
  }
  switch (Size) {
  // FP is a half
  case 16: {
    // Convert FPImm to an hexadecimal integer string.
    std::stringstream s;
    // MC can't converts half to double, so half float value holds
    // on the 16 least significant bits of a double)
    double i = MO.getFPImm();
    s << "0x" << std::hex << *reinterpret_cast<uint16_t *>(&i);
    O << s.str();
  } break;
  // FP is a float
  case 32: {
    // Convert FPImm to an hexadecimal integer string
    std::stringstream s;
    // MC converts all floating point immediate operands to double.
    // Convert them back to float should be safe except for nan
    // payload values.
    auto f = float(MO.getFPImm());
    s << "0x" << std::hex << *reinterpret_cast<uint32_t *>(&f);
    O << s.str();
  } break;
  // FP is a double
  case 64: {
    // Convert FPImm to an hexadecimal integer string
    std::stringstream s;
    double i = MO.getFPImm();
    s << "0x" << std::hex << *reinterpret_cast<uint64_t *>(&i);
    O << s.str();
  } break;
  default:
    report_fatal_error("illegal size");
  }
  return;
}

void KVXInstPrinter::printSplat32Mod(const MCInst *MI, unsigned OpNo,
                                     raw_ostream &O) {
  const MCOperand &MO = MI->getOperand(OpNo);
  int variant = MO.getImm();
  switch (variant) {
  case 0:
    break;
  case 1:
    O << ".@";
    break;
  }
}

void KVXInstPrinter::printConjugateMod(const MCInst *MI, unsigned OpNo,
                                       raw_ostream &O) {
  const MCOperand &MO = MI->getOperand(OpNo);
  int variant = MO.getImm();
  switch (variant) {
  case 0:
    break;
  case 1:
    O << ".c";
    break;
  }
}

// Emits 32-bits integer litteral values.
//
// Use the hexadecimal bit representation when the absolute value is above a
// given Threshold. The goal is to make sure negative values do not end-up as
// 64-bits hexa value.
template <int Threshold>
void KVXInstPrinter::printHexaBitsImm32(const MCInst *MI, unsigned OpNo,
                                        raw_ostream &O) {
  int64_t imm = MI->getOperand(OpNo).getImm();

  if (std::abs(imm) <= Threshold) {
    O << imm;
  } else {
    uint64_t i = imm & ((1ULL << 32) - 1);
    O << formatHex(i);
  }
}
