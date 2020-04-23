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
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineOperand.h"

using namespace llvm;

static bool LowerKVXMachineOperandToMCOperand(const MachineOperand &MO,
                                              MCOperand &MCOp, AsmPrinter &AP) {
  switch (MO.getType()) {
  default:
    llvm_unreachable("unknown operand type");
    break;
  case MachineOperand::MO_MachineBasicBlock:
    MCOp = MCOperand::createExpr(
        MCSymbolRefExpr::create(MO.getMBB()->getSymbol(), AP.OutContext));
    break;
  case MachineOperand::MO_Register:
    if (MO.isImplicit())
      return false;
    MCOp = MCOperand::createReg(MO.getReg());
    break;
  case MachineOperand::MO_FPImmediate: {
    const ConstantFP *Imm = MO.getFPImm();
    if (Imm->getType()->isHalfTy()) {
      // force half value to hold in the 16 least significant bit of a double
      double d;
      uint64_t n = Imm->getValueAPF().bitcastToAPInt().getZExtValue();
      std::memcpy(&d, &n, sizeof n);
      MCOp = MCOperand::createFPImm(d);
    } else if (Imm->getType()->isFloatTy())
      MCOp = MCOperand::createFPImm(Imm->getValueAPF().convertToFloat());
    else if (Imm->getType()->isDoubleTy())
      MCOp = MCOperand::createFPImm(Imm->getValueAPF().convertToDouble());
    else
      llvm_unreachable("unknown floating point immediate type");
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
  }

  return true;
}

void llvm::LowerKVXMachineInstrToMCInst(const MachineInstr *MI, MCInst &OutMI,
                                        AsmPrinter &AP) {
  OutMI.setOpcode(MI->getOpcode());

  for (const MachineOperand &MO : MI->operands()) {
    MCOperand MCOp;
    if (LowerKVXMachineOperandToMCOperand(MO, MCOp, AP))
      OutMI.addOperand(MCOp);
  }
}
