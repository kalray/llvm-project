//===-- KVXPreRAExpandPseudoInsts.cpp - Expand pseudo instructions --------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains a pass that expands pseudo instructions into target
// instructions. This pass should be run before register allocation.
//
//===----------------------------------------------------------------------===//

#include "KVX.h"
#include "KVXInstrInfo.h"
#include "KVXTargetMachine.h"

#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"

using namespace llvm;

#define KVX_PRERA_EXPAND_PSEUDO_NAME                                           \
  "KVX pre regalloc pseudo instruction expansion pass"
#define DEBUG_TYPE "pre-ra-expand-pseudo"

namespace {

class KVXPreRAExpandPseudo : public MachineFunctionPass {
public:
  const KVXInstrInfo *TII;
  static char ID;

  KVXPreRAExpandPseudo() : MachineFunctionPass(ID) {
    initializeKVXPreRAExpandPseudoPass(*PassRegistry::getPassRegistry());
  }

  bool runOnMachineFunction(MachineFunction &MF) override;

  StringRef getPassName() const override {
    return KVX_PRERA_EXPAND_PSEUDO_NAME;
  }

private:
  bool expandMBB(MachineBasicBlock &MBB);
  bool expandMI(MachineBasicBlock &MBB, MachineBasicBlock::iterator MBBI,
                MachineBasicBlock::iterator &NextMBBI);
};

char KVXPreRAExpandPseudo::ID = 0;

bool KVXPreRAExpandPseudo::runOnMachineFunction(MachineFunction &MF) {
  TII = static_cast<const KVXInstrInfo *>(MF.getSubtarget().getInstrInfo());
  bool Modified = false;
  for (auto &MBB : MF)
    Modified |= expandMBB(MBB);
  return Modified;
}

bool KVXPreRAExpandPseudo::expandMBB(MachineBasicBlock &MBB) {
  bool Modified = false;

  MachineBasicBlock::iterator MBBI = MBB.begin(), E = MBB.end();
  while (MBBI != E) {
    MachineBasicBlock::iterator NMBBI = std::next(MBBI);
    Modified |= expandMI(MBB, MBBI, NMBBI);
    MBBI = NMBBI;
  }

  return Modified;
}

static bool expandGetInstr(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                           MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  unsigned DestReg = MI.getOperand(0).getReg();
  int64_t regNo = MI.getOperand(1).getImm();

  BuildMI(MBB, MBBI, DL, TII->get(KVX::GETss3), DestReg)
      .addReg(KVX::SystemRegRegClass.getRegister(regNo));

  MI.eraseFromParent();
  return true;
}

static bool expandSystemRegValueInstr(unsigned int Opcode,
                                      const KVXInstrInfo *TII,
                                      MachineBasicBlock &MBB,
                                      MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  unsigned int sysReg =
      KVX::SystemRegRegClass.getRegister(MI.getOperand(0).getImm());
  unsigned valReg = MI.getOperand(1).getReg();

  BuildMI(MBB, MBBI, DL, TII->get(Opcode), sysReg).addReg(valReg);

  MI.eraseFromParent();
  return true;
}

static bool expandCacheInstruction(const KVXInstrInfo *TII,
                                   MachineBasicBlock &MBB,
                                   MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();
  unsigned Base = MI.getOperand(1).getReg();

  bool OffsetIsReg = MI.getOperand(0).isReg();
  if (!OffsetIsReg)
    assert(MI.getOperand(0).isImm() && "Cache instruction operand unsupported");

  unsigned OpCode;
  switch (MBBI->getOpcode()) {
  case KVX::DINVALLp:
    OpCode = OffsetIsReg
                 ? KVX::DINVALLrr
                 : GetImmOpCode(MI.getOperand(0).getImm(), KVX::DINVALLri10,
                                KVX::DINVALLri37, KVX::DINVALLri64);
    break;
  case KVX::DTOUCHLp:
    OpCode = OffsetIsReg
                 ? KVX::DTOUCHLrr
                 : GetImmOpCode(MI.getOperand(0).getImm(), KVX::DTOUCHLri10,
                                KVX::DTOUCHLri37, KVX::DTOUCHLri64);
    break;
  case KVX::DZEROLp:
    OpCode = OffsetIsReg
                 ? KVX::DZEROLrr
                 : GetImmOpCode(MI.getOperand(0).getImm(), KVX::DZEROLri10,
                                KVX::DZEROLri37, KVX::DZEROLri64);
    break;
  case KVX::IINVALSp:
    OpCode = OffsetIsReg
                 ? KVX::IINVALSrr
                 : GetImmOpCode(MI.getOperand(0).getImm(), KVX::IINVALSri10,
                                KVX::IINVALSri37, KVX::IINVALSri64);
    break;
  default:
    report_fatal_error("Cache instruction not supported");
  }

  if (OffsetIsReg)
    BuildMI(MBB, MBBI, DL, TII->get(OpCode))
        .addReg(MI.getOperand(0).getReg())
        .addReg(Base);
  else
    BuildMI(MBB, MBBI, DL, TII->get(OpCode))
        .addImm(MI.getOperand(0).getImm())
        .addReg(Base);

  MI.eraseFromParent();
  return true;
}

bool KVXPreRAExpandPseudo::expandMI(MachineBasicBlock &MBB,
                                    MachineBasicBlock::iterator MBBI,
                                    MachineBasicBlock::iterator &NextMBBI) {
  switch (MBBI->getOpcode()) {
  case KVX::GETp:
    return expandGetInstr(TII, MBB, MBBI);
  case KVX::WFXLp:
    return expandSystemRegValueInstr(KVX::WFXLrst4, TII, MBB, MBBI);
  case KVX::WFXMp:
    return expandSystemRegValueInstr(KVX::WFXMrst4, TII, MBB, MBBI);
  case KVX::SETp:
    return expandSystemRegValueInstr(KVX::SETrst4, TII, MBB, MBBI);
  case KVX::DINVALLp:
  case KVX::DTOUCHLp:
  case KVX::DZEROLp:
  case KVX::IINVALSp:
    return expandCacheInstruction(TII, MBB, MBBI);
  default:
    break;
  }

  return false;
}

} // end of anonymous namespace

INITIALIZE_PASS(KVXPreRAExpandPseudo, "kvx-prera-expand-pseudo",
                KVX_PRERA_EXPAND_PSEUDO_NAME, false, false)
namespace llvm {

FunctionPass *createKVXPreRAExpandPseudoPass() {
  return new KVXPreRAExpandPseudo();
}

} // end of namespace llvm
