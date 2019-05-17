//==-- K1CMCInstLower.cpp - Convert K1C MachineInstr to an MCInst ----------==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains code to lower K1C MachineInstrs to their corresponding
// MCInst records.
//
//===----------------------------------------------------------------------===//

#include "K1C.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineOperand.h"

using namespace llvm;

static bool LowerK1CMachineOperandToMCOperand(const MachineOperand &MO,
                                              MCOperand &MCOp, AsmPrinter &AP) {
  switch (MO.getType()) {
  default:
    llvm_unreachable("unknown operand typey");
    break;
  case MachineOperand::MO_Register:
    if (MO.isImplicit())
      return false;
    MCOp = MCOperand::createReg(MO.getReg());
    break;
  case MachineOperand::MO_Immediate:
    MCOp = MCOperand::createImm(MO.getImm());
    break;
  case MachineOperand::MO_RegisterMask:
    return false;
  case MachineOperand::MO_GlobalAddress:
    MCOp = MCOperand::createExpr(
        MCSymbolRefExpr::create(AP.getSymbol(MO.getGlobal()), AP.OutContext));
    break;
  }

  return true;
}

void llvm::LowerK1CMachineInstrToMCInst(const MachineInstr *MI, MCInst &OutMI,
                                        AsmPrinter &AP) {
  OutMI.setOpcode(MI->getOpcode());

  for (const MachineOperand &MO : MI->operands()) {
    MCOperand MCOp;
    if (LowerK1CMachineOperandToMCOperand(MO, MCOp, AP))
      OutMI.addOperand(MCOp);
  }
}
