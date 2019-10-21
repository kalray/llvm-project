//===-- K1CExpandPseudoInsts.cpp - Expand pseudo instructions -------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains a pass that expands pseudo instructions into target
// instructions. This pass should be run after register allocation but before
// the post-regalloc scheduling pass.
//
//===----------------------------------------------------------------------===//

#include "K1C.h"
#include "K1CInstrInfo.h"
#include "K1CTargetMachine.h"

#include "llvm/CodeGen/LivePhysRegs.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"

using namespace llvm;

#define K1C_EXPAND_PSEUDO_NAME "K1C pseudo instruction expansion pass"

namespace {

class K1CExpandPseudo : public MachineFunctionPass {
public:
  const K1CInstrInfo *TII;
  static char ID;

  K1CExpandPseudo() : MachineFunctionPass(ID) {
    initializeK1CExpandPseudoPass(*PassRegistry::getPassRegistry());
  }

  bool runOnMachineFunction(MachineFunction &MF) override;

  StringRef getPassName() const override { return K1C_EXPAND_PSEUDO_NAME; }

private:
  bool expandMBB(MachineBasicBlock &MBB);
  bool expandMI(MachineBasicBlock &MBB, MachineBasicBlock::iterator MBBI,
                MachineBasicBlock::iterator &NextMBBI);
};

char K1CExpandPseudo::ID = 0;

bool K1CExpandPseudo::runOnMachineFunction(MachineFunction &MF) {
  TII = static_cast<const K1CInstrInfo *>(MF.getSubtarget().getInstrInfo());
  bool Modified = false;
  for (auto &MBB : MF)
    Modified |= expandMBB(MBB);
  return Modified;
}

bool K1CExpandPseudo::expandMBB(MachineBasicBlock &MBB) {
  bool Modified = false;

  MachineBasicBlock::iterator MBBI = MBB.begin(), E = MBB.end();
  while (MBBI != E) {
    MachineBasicBlock::iterator NMBBI = std::next(MBBI);
    Modified |= expandMI(MBB, MBBI, NMBBI);
    MBBI = NMBBI;
  }

  return Modified;
}

static unsigned GetCMOVEOpCode(__int128_t Value) {
  if (isInt<10>(Value)) {
    return K1C::CMOVEDd0;
  } else if (isInt<37>(Value)) {
    return K1C::CMOVEDd1;
  } else {
    return K1C::CMOVEDd2;
  }
}

static void InsertCMOVEInstr(const K1CInstrInfo *TII, MachineBasicBlock &MBB,
                             MachineBasicBlock::iterator MBBI, unsigned Operand,
                             unsigned Comp) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  unsigned CmpReg = MI.getOperand(1).getReg();
  unsigned ScratchReg = MI.getOperand(2).getReg();

  switch (MI.getOperand(Operand).getType()) {
  case MachineOperand::MO_GlobalAddress:
    BuildMI(MBB, MBBI, DL, TII->get(K1C::CMOVEDd3))
        .addReg(ScratchReg)
        .addReg(CmpReg)
        .addGlobalAddress(MI.getOperand(Operand).getGlobal())
        .addImm(Comp); /* DNEZ */
    break;
  case MachineOperand::MO_Register: {
    unsigned BranchValue = MI.getOperand(Operand).getReg();

    BuildMI(MBB, MBBI, DL, TII->get(GetCMOVEOpCode(BranchValue)))
        .addReg(ScratchReg)
        .addReg(CmpReg)
        .addReg(BranchValue)
        .addImm(Comp); /* DNEZ */
  } break;
  case MachineOperand::MO_Immediate: {
    __int128_t BranchValueImm = MI.getOperand(Operand).getImm();

    BuildMI(MBB, MBBI, DL, TII->get(GetCMOVEOpCode(BranchValueImm)))
        .addReg(ScratchReg)
        .addReg(CmpReg)
        .addImm(BranchValueImm)
        .addImm(Comp); /* DNEZ */
  } break;
  case MachineOperand::MO_FPImmediate: {
    const ConstantFP *Imm = MI.getOperand(Operand).getFPImm();

    BuildMI(
        MBB, MBBI, DL,
        TII->get(Imm->getType()->isFloatTy() ? K1C::CMOVEDd1 : K1C::CMOVEDd2))
        .addReg(ScratchReg)
        .addReg(CmpReg)
        .addFPImm(Imm)
        .addImm(Comp); /* DNEZ */
  } break;
  default:
    llvm_unreachable("Operator type not handled");
    break;
  }
}

static bool expandSelectInstr(const K1CInstrInfo *TII, MachineBasicBlock &MBB,
                              MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  unsigned DestReg = MI.getOperand(0).getReg();
  unsigned ScratchReg = MI.getOperand(2).getReg();

  InsertCMOVEInstr(TII, MBB, MBBI, 3, 0);
  InsertCMOVEInstr(TII, MBB, MBBI, 4, 1);

  BuildMI(MBB, MBBI, DL, TII->get(K1C::COPYD)).addReg(DestReg).addReg(
      ScratchReg);

  // Remove the present instruction
  MI.eraseFromParent();
  return true;
}

bool K1CExpandPseudo::expandMI(MachineBasicBlock &MBB,
                               MachineBasicBlock::iterator MBBI,
                               MachineBasicBlock::iterator &NextMBBI) {
  switch (MBBI->getOpcode()) {
  case K1C::Select_Instr:
    expandSelectInstr(TII, MBB, MBBI);
    return true;
  default:
    break;
  }

  return false;
}

} // end of anonymous namespace

INITIALIZE_PASS(K1CExpandPseudo, "k1c-expand-pseudo", K1C_EXPAND_PSEUDO_NAME,
                false, false)
namespace llvm {

FunctionPass *createK1CExpandPseudoPass() { return new K1CExpandPseudo(); }

} // end of namespace llvm
