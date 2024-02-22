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
#include "KVXInstrInfo.h"
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

void KVXInstPrinter::printInst(const MCInst *MI, uint64_t Address,
                               StringRef Annot, const MCSubtargetInfo &STI,
                               raw_ostream &O) {
  return printInstruction(MI, Address, O);
}

void KVXInstPrinter::printRegName(raw_ostream &OS, MCRegister Reg) const {
  OS << getRegisterName(Reg);
}

void KVXInstPrinter::printBuffer(const MCInst *MI, unsigned OpNo,
                                 raw_ostream &O, const char *Modifier) {
  const MCOperand &MO = MI->getOperand(OpNo);
  O << getRegisterName(MO.getReg(), KVX::BuffName);
}

void KVXInstPrinter::printOperand(
    const MCInst *MI, unsigned OpNo,
    /*const MCSubtargetInfo &STI,*/ raw_ostream &O, const char *Modifier) {
  if (!(Modifier == 0 || Modifier[0] == 0))
    report_fatal_error("No modifiers supported");

  const MCOperand &MO = MI->getOperand(OpNo);

  if (MO.isReg()) {
    printRegName(O, MO.getReg());
    return;
  }

  if (MO.isDFPImm() || MO.isSFPImm()) {
    report_fatal_error("No fp immediate should be used in MachineOperands.");
    return;
  }

  if (MO.isImm()) {
    std::stringstream s;
    if (MO.getImm() > 1024 || MO.getImm() < -1024)
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

void KVXInstPrinter::printScalarcondMod(const MCInst *MI, unsigned OpNo,
                                        raw_ostream &O) {
  using ScalarcondMod = KVX::ScalarcondMod;

  const MCOperand &MO = MI->getOperand(OpNo);
  auto Variant = static_cast<ScalarcondMod>(MO.getImm());
  if (!(Variant >= ScalarcondMod::DNEZ && Variant <= ScalarcondMod::WGTZ))
    report_fatal_error("Unhandled value for Scalarcond modifier");
  switch (Variant) {
  case ScalarcondMod::DNEZ:
    O << ".dnez";
    break;
  case ScalarcondMod::DEQZ:
    O << ".deqz";
    break;
  case ScalarcondMod::DLTZ:
    O << ".dltz";
    break;
  case ScalarcondMod::DGEZ:
    O << ".dgez";
    break;
  case ScalarcondMod::DLEZ:
    O << ".dlez";
    break;
  case ScalarcondMod::DGTZ:
    O << ".dgtz";
    break;
  case ScalarcondMod::ODD:
    O << ".odd";
    break;
  case ScalarcondMod::EVEN:
    O << ".even";
    break;
  case ScalarcondMod::WNEZ:
    O << ".wnez";
    break;
  case ScalarcondMod::WEQZ:
    O << ".weqz";
    break;
  case ScalarcondMod::WLTZ:
    O << ".wltz";
    break;
  case ScalarcondMod::WGEZ:
    O << ".wgez";
    break;
  case ScalarcondMod::WLEZ:
    O << ".wlez";
    break;
  case ScalarcondMod::WGTZ:
    O << ".wgtz";
    break;
  }
}

void KVXInstPrinter::printLsomaskMod(
    const MCInst *MI, unsigned OpNo,
    /*const MCSubtargetInfo &STI,*/ raw_ostream &O) {
  const MCOperand &MO = MI->getOperand(OpNo);
  int Variant = MO.getImm();
  switch (Variant) {
  case 0:
  case 1:
  case 2:
  case 3:
    report_fatal_error("Got .u0/.u1/.u2/.u3 for lsomask modifier");
  case 4:
    O << ".mt";
    break;
  case 5:
    O << ".mf";
    break;
  case 6:
    O << ".mtc";
    break;
  case 7:
    O << ".mfc";
    break;
  default:
    report_fatal_error("Unhandled value for lsomask modifier");
  }
}

void KVXInstPrinter::printSimplecondMod(
    const MCInst *MI, unsigned OpNo,
    /*const MCSubtargetInfo &STI,*/ raw_ostream &O) {
  int Variant = MI->getOperand(OpNo).getImm();
  /* TODO - add CodeGen tests for these variants */
  const char *VariantList[] = {".nez", ".eqz", ".ltz", ".gez",
                               ".lez", ".gtz", ".odd", ".even"};
  if (Variant < 8)
    O << VariantList[Variant];
  else
    report_fatal_error("Unexpected simple condition value: ");
}

void KVXInstPrinter::printComparisonMod(const MCInst *MI, unsigned OpNo,
                                        raw_ostream &O) {
  using ComparisonMod = KVX::ComparisonMod;

  const MCOperand &MO = MI->getOperand(OpNo);
  ComparisonMod Variant = static_cast<ComparisonMod>(MO.getImm());
  if (!(Variant >= ComparisonMod::NE && Variant <= ComparisonMod::NONE))
    report_fatal_error("Unhandled value for Comparison modifier");
  switch (Variant) {
  case ComparisonMod::NE:
    O << ".ne";
    break;
  case ComparisonMod::EQ:
    O << ".eq";
    break;
  case ComparisonMod::LT:
    O << ".lt";
    break;
  case ComparisonMod::GE:
    O << ".ge";
    break;
  case ComparisonMod::LE:
    O << ".le";
    break;
  case ComparisonMod::GT:
    O << ".gt";
    break;
  case ComparisonMod::LTU:
    O << ".ltu";
    break;
  case ComparisonMod::GEU:
    O << ".geu";
    break;
  case ComparisonMod::LEU:
    O << ".leu";
    break;
  case ComparisonMod::GTU:
    O << ".gtu";
    break;
  case ComparisonMod::ALL:
    O << ".all";
    break;
  case ComparisonMod::NALL:
    O << ".nall";
    break;
  case ComparisonMod::ANY:
    O << ".any";
    break;
  case ComparisonMod::NONE:
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

// Hack, we use the VARIANT modifier (0..3) at codegen to detect
// addrspace, and we filter the speculate modifier from it.
void KVXInstPrinter::printSpeculateMod(const MCInst *MI, unsigned OpNo,
                                       raw_ostream &O) {
  const MCOperand &MO = MI->getOperand(OpNo);
  int Silent = MO.getImm();
  if (Silent > 3)
    report_fatal_error("illegal silent mode");

  if (Silent & 1)
    O << "s";
}

void KVXInstPrinter::printQindexMod(const MCInst *MI, unsigned OpNo,
                                    raw_ostream &O) {
  const MCOperand &MO = MI->getOperand(OpNo);
  unsigned Q = MO.getImm();
  if (Q > 3)
    report_fatal_error("illegal qindex value.");

  O << ".q" << Q;
}

void KVXInstPrinter::printLsumaskMod(const MCInst *MI, unsigned OpNo,
                                     raw_ostream &O) {
  const MCOperand &MO = MI->getOperand(OpNo);
  unsigned M = MO.getImm();
  switch (M) {
  case 0:
    O << ".dnez";
    return;
  case 1:
    O << ".deqz";
    return;
  case 2:
    O << ".wnez";
    return;
  case 3:
    O << ".weqz";
    return;
  case 4:
    O << ".mt";
    return;
  case 5:
    O << ".mf";
    return;
  case 6:
    O << ".mtc";
    return;
  case 7:
    O << ".mfc";
    return;
  default:
    report_fatal_error("illegal lsumask value.");
  }
}

void KVXInstPrinter::printLsupackMod(const MCInst *MI, unsigned OpNo,
                                     raw_ostream &O) {
  const MCOperand &MO = MI->getOperand(OpNo);
  unsigned M = MO.getImm();
  if (!M)
    return;

  if (M > 5)
    report_fatal_error("illegal lsupack value.");

  const static std::string S = " qdwhb";
  O << '.' << S[M];
}

void KVXInstPrinter::printAccessesMod(const MCInst *MI, unsigned OpNo,
                                      raw_ostream &O) {
  const MCOperand &MO = MI->getOperand(OpNo);
  unsigned M = MO.getImm();
  if (!M)
    return;

  if (M > 3)
    report_fatal_error("illegal accesses value.");

  const static std::array<const char *const, 4> S = {"", "w", "r", "wa"};
  O << '.' << S[M];
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

void KVXInstPrinter::printFPImmOperand(const MCInst *MI, unsigned OpNo,
                                       raw_ostream &O) {
  int64_t Im = MI->getOperand(OpNo).getImm();
  std::stringstream S;
  S << "0x" << std::hex << Im;
  O << S.str();
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

void KVXInstPrinter::printTransposeMod(const MCInst *MI, unsigned OpNo,
                                       raw_ostream &O) {
  const MCOperand &MO = MI->getOperand(OpNo);
  int Transpose = MO.getImm();
  switch (Transpose) {
  case 0: // NormalNormal
    break;
  case 1: // TransposedNormal
    O << ".tn";
    break;
  case 2: // NormalTransposed
    O << ".nt";
    break;
  case 3: // TransposedTransposed
    O << ".tt";
    break;
  default:
    report_fatal_error("illegal transpose modifier");
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

void KVXInstPrinter::printBoolcasMod(const MCInst *MI, unsigned OpNo,
                                     raw_ostream &O) {
  const MCOperand &MO = MI->getOperand(OpNo);
  int Variant = MO.getImm();
  switch (Variant) {
  case 0:
    O << ".v";
    break;
  case 1:
    break;
  }
}

void KVXInstPrinter::printCoherencyMod(const MCInst *MI, unsigned OpNo,
                                       raw_ostream &O) {
  const MCOperand &MO = MI->getOperand(OpNo);
  int Variant = MO.getImm();
  switch (Variant) {
  case 0:
    break;
  case 1:
    O << ".g";
    break;
  default:
    report_fatal_error("Invalid CoherencyMod value to print.");
    // System is not possible at the moment.
    // case 2:
    //   O << ".s";
    //   break;
  }
}

// Emits 32-bits integer litteral values.
//
// Use the hexadecimal bit representation when the absolute value is above a
// given Threshold. The goal is to make sure negative values do not end-up as
// 64-bits hexa value.
template <int Threshold>
void KVXInstPrinter::printHexaBitsImm32(const MCInst *MI, unsigned OpNo,
                                        raw_ostream &O, bool SplatAt) {
  int64_t imm = MI->getOperand(OpNo).getImm();

  if (std::abs(imm) <= Threshold) {
    O << imm;
  } else {
    uint64_t i = imm & ((1ULL << 32) - 1);
    O << formatHex(i);
  }

  if (SplatAt)
    O << ".@";
}

void KVXInstPrinter::printCacheLevelMod(const MCInst *MI, unsigned OpNo,
                                        raw_ostream &O) {
  uint32_t I = MI->getOperand(OpNo).getImm();

  if (I > 1)
    report_fatal_error("Invalid cache level value.");

  O << ((I != 0) ? ".l2" : ".l1");
}

void KVXInstPrinter::printChannelMod(const MCInst *MI, unsigned OpNo,
                                     raw_ostream &O) {
  uint32_t I = MI->getOperand(OpNo).getImm();

  if (I > 1)
    report_fatal_error("Invalid channel value.");

  O << ((I == 0) ? ".f" : ".b");
}

void KVXInstPrinter::printShuffleVMod(const MCInst *MI, unsigned OpNo,
                                      raw_ostream &O) {
  uint32_t I = MI->getOperand(OpNo).getImm();
  if (I > 1)
    report_fatal_error("Invalid ShuffleXMod value to print.");

  if (!I)
    return;

  O << ".td";
}

void KVXInstPrinter::printShuffleXMod(const MCInst *MI, unsigned OpNo,
                                      raw_ostream &O) {
  uint32_t I = MI->getOperand(OpNo).getImm();
  static const char *Shuffles[] = {"", "zd", "ud", "tq", "tw", "zw", "uw"};
  if (I > 6)
    report_fatal_error("Invalid ShuffleXMod value to print.");
  if (I)
    O << '.' << Shuffles[I];
}
