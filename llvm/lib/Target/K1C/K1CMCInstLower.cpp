#include "K1C.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineOperand.h"

using namespace llvm;

static MCOperand LowerOperand(const MachineInstr *MI, const MachineOperand &MO, AsmPrinter &AP) {
  switch (MO.getType()) {
    default:
      llvm_unreachable("unknown operand typey");
      break;
    case MachineOperand::MO_Register:
      if (MO.isImplicit())
        break;
      return MCOperand::createReg(MO.getReg());
    case MachineOperand::MO_Immediate:
      return MCOperand::createImm(MO.getImm());
    case MachineOperand::MO_RegisterMask:
      break;
  }

  return MCOperand();
}

void llvm::LowerK1CMachineInstrToMCInst(const MachineInstr *MI, MCInst &OutMI, AsmPrinter &AP) {
  OutMI.setOpcode(MI->getOpcode());

  for (const MachineOperand &MO : MI->operands()) {
    MCOperand MCOp = LowerOperand(MI, MO, AP);

    if (MCOp.isValid())
      OutMI.addOperand(MCOp);
  }
}
