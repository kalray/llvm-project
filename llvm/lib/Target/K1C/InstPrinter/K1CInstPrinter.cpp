//===-- K1CInstPrinter.h - Convert K1C MCInst to assembly syntax ----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This class prints a K1C MCInst to a .s file.
//
//===----------------------------------------------------------------------===//

#include "K1CInstPrinter.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/FormattedStream.h"

using namespace llvm;

#define DEBUG_TYPE "asm-printer"

// Include the auto-generated portion of the assembly writer.
#define PRINT_ALIAS_INSTR
#include "K1CGenAsmWriter.inc"

void K1CInstPrinter::printInst(const MCInst *MI, raw_ostream &O,
                               StringRef Annot, const MCSubtargetInfo &STI) {
  printInstruction(MI, /*STI,*/ O);
}

void K1CInstPrinter::printRegName(raw_ostream &O, unsigned RegNo) const {
  O << getRegisterName(RegNo);
}

void
K1CInstPrinter::printOperand(const MCInst *MI, unsigned OpNo,
                             /*const MCSubtargetInfo &STI,*/ raw_ostream &O,
                             const char *Modifier) {
  assert((Modifier == 0 || Modifier[0] == 0) && "No modifiers supported");
  const MCOperand &MO = MI->getOperand(OpNo);

  if (MO.isReg()) {
    printRegName(O, MO.getReg());
    return;
  }

  if (MO.isImm()) {
    O << MO.getImm();
    return;
  }

  assert(MO.isExpr() && "Unknown operand kind in printOperand");
  MO.getExpr()->print(O, &MAI);
}

void K1CInstPrinter::printVariantMod(
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

void K1CInstPrinter::printScalingMod(
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

void K1CInstPrinter::printScalarcondMod(
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

void K1CInstPrinter::printMemOperand(
    const MCInst *MI, unsigned OpNo,
    /*const MCSubtargetInfo &STI,*/ raw_ostream &O) {
  printOperand(MI, OpNo + 1, O);
  O << "[";
  printOperand(MI, OpNo, O);
  O << "]";
}
