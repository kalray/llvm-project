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

#ifndef LLVM_LIB_TARGET_K1C_INSTPRINTER_K1CINSTPRINTER_H
#define LLVM_LIB_TARGET_K1C_INSTPRINTER_K1CINSTPRINTER_H

#include "MCTargetDesc/K1CMCTargetDesc.h"
#include "llvm/MC/MCInstPrinter.h"

namespace llvm {
class MCOperand;

class K1CInstPrinter : public MCInstPrinter {
public:
  K1CInstPrinter(const MCAsmInfo &MAI, const MCInstrInfo &MII,
                 const MCRegisterInfo &MRI)
      : MCInstPrinter(MAI, MII, MRI) {}

  void printInst(const MCInst *MI, raw_ostream &O, StringRef Annot,
                 const MCSubtargetInfo &STI) override;
  void printRegName(raw_ostream &O, unsigned RegNo) const override;

  void printOperand(const MCInst *MI,
                    unsigned OpNo, /*const MCSubtargetInfo &STI,*/
                    raw_ostream &O, const char *Modifier = nullptr);

  // Autogenerated by tblgen.
  void printInstruction(const MCInst *MI, const MCSubtargetInfo &STI,
                        raw_ostream &O);
  void printInstruction(const MCInst *MI, /*const MCSubtargetInfo &STI,*/
                        raw_ostream &O);
  bool printAliasInstr(const MCInst *MI, const MCSubtargetInfo &STI,
                       raw_ostream &O);
  bool printAliasInstr(const MCInst *MI, /*const MCSubtargetInfo &STI,*/
                       raw_ostream &O);

  static const char *getRegisterName(unsigned RegNo);

  void printVariantMod(const MCInst *MI, unsigned OpNo,
                       /*const MCSubtargetInfo &STI,*/ raw_ostream &O);

  void printScalingMod(const MCInst *MI, unsigned OpNo,
                       /*const MCSubtargetInfo &STI,*/ raw_ostream &O);

  void printScalarcondMod(const MCInst *MI, unsigned OpNo,
                          /*const MCSubtargetInfo &STI,*/ raw_ostream &O);

  void printMemOperand(const MCInst *MI, unsigned OpNo,
                       /*const MCSubtargetInfo &STI,*/ raw_ostream &O);

  void printComparisonMod(const MCInst *MI, unsigned OpNo,
                          /*const MCSubtargetInfo &STI,*/ raw_ostream &O);

  void printRoundingMod(const MCInst *MI, unsigned OpNo, raw_ostream &O);
  void printSilentMod(const MCInst *MI, unsigned OpNo, raw_ostream &O);

  void printBinary16ImmOperand(const MCInst *MI, unsigned OpNo, raw_ostream &O);
  void printBinary32ImmOperand(const MCInst *MI, unsigned OpNo, raw_ostream &O);
  void printBinary64ImmOperand(const MCInst *MI, unsigned OpNo, raw_ostream &O);
  void printFPImmOperand(const MCInst *MI, unsigned OpNo, unsigned Size,
                         raw_ostream &O);
};
} // namespace llvm

#endif
