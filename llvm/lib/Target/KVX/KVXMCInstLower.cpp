//==-- KVXMCInstLower.cpp - Convert KVX MachineInstr to an MCInst ----------==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains code to lower KVX MachineInstrs to their corresponding
// MCInst records.
//
//===----------------------------------------------------------------------===//

#include "KVX.h"
#include "KVXAsmPrinter.h"
#include "llvm/CodeGen/TargetRegisterInfo.h"
#include "llvm/IR/Constants.h"

using namespace llvm;

static bool LowerKVXMachineOperandToMCOperand(const MachineOperand &MO,
                                              MCOperand &MCOp,
                                              KVXAsmPrinter &AP) {
  switch (MO.getType()) {
  default:
    errs() << "MachineOperand type #: " << (unsigned)(MO.getType()) << '\n';
    report_fatal_error("Can't lower this operand type");
    break;
  case MachineOperand::MO_MachineBasicBlock:
    MCOp = MCOperand::createExpr(
        MCSymbolRefExpr::create(MO.getMBB()->getSymbol(), AP.OutContext));
    break;
  case MachineOperand::MO_Register: {
    if (MO.isImplicit())
      return false;

    Register Reg = MO.getReg();
    if (MO.getSubReg())
      Reg = AP.TRI->getSubReg(Reg, MO.getSubReg());

    MCOp = MCOperand::createReg(Reg);
    break;
  }
  case MachineOperand::MO_FPImmediate: {
    const ConstantFP *Imm = MO.getFPImm();
    auto V = Imm->getValueAPF().bitcastToAPInt().getZExtValue();
    MCOp = MCOperand::createImm(V);
    break;
  }
  case MachineOperand::MO_Immediate:
    MCOp = MCOperand::createImm(MO.getImm());
    break;
  case MachineOperand::MO_RegisterMask:
    return false;
  case MachineOperand::MO_GlobalAddress:
    MCOp = MCOperand::createExpr(
        MCSymbolRefExpr::create(AP.getSymbol(MO.getGlobal()), AP.OutContext));
    break;
  case MachineOperand::MO_ExternalSymbol:
    MCOp = MCOperand::createExpr(MCSymbolRefExpr::create(
        AP.GetExternalSymbolSymbol(MO.getSymbolName()), AP.OutContext));
    break;
  case MachineOperand::MO_BlockAddress:
    MCOp = MCOperand::createExpr(MCSymbolRefExpr::create(
        AP.GetBlockAddressSymbol(MO.getBlockAddress()), AP.OutContext));
    break;
  case MachineOperand::MO_JumpTableIndex:
    MCOp = MCOperand::createExpr(
        MCSymbolRefExpr::create(AP.GetJTISymbol(MO.getIndex()), AP.OutContext));
    break;
  case MachineOperand::MO_MCSymbol:
    MCOp = MCOperand::createExpr(
        MCSymbolRefExpr::create(MO.getMCSymbol(), AP.OutContext));
    break;
  }

  return true;
}

void llvm::LowerKVXMachineInstrToMCInst(const MachineInstr *MI, MCInst &OutMI,
                                        KVXAsmPrinter &AP) {
  OutMI.setOpcode(MI->getOpcode());

  for (const MachineOperand &MO : MI->operands()) {
    MCOperand MCOp;
    if (LowerKVXMachineOperandToMCOperand(MO, MCOp, AP))
      OutMI.addOperand(MCOp);
  }
}
