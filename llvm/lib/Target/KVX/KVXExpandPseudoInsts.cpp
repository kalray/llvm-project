//===-- KVXExpandPseudoInsts.cpp - Expand pseudo instructions -------------===//
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

#include "KVX.h"
#include "KVXInstrInfo.h"
#include "KVXTargetMachine.h"

#include "llvm/CodeGen/LivePhysRegs.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"

using namespace llvm;

#define KVX_EXPAND_PSEUDO_NAME "KVX pseudo instruction expansion pass"
#define DEBUG_TYPE "expand-pseudo"

namespace {

class KVXExpandPseudo : public MachineFunctionPass {
public:
  const KVXInstrInfo *TII;
  static char ID;

  KVXExpandPseudo() : MachineFunctionPass(ID) {
    initializeKVXExpandPseudoPass(*PassRegistry::getPassRegistry());
  }

  bool runOnMachineFunction(MachineFunction &MF) override;

  StringRef getPassName() const override { return KVX_EXPAND_PSEUDO_NAME; }

private:
  bool expandMBB(MachineBasicBlock &MBB);
  bool expandMI(MachineBasicBlock &MBB, MachineBasicBlock::iterator MBBI,
                MachineBasicBlock::iterator &NextMBBI);
};

char KVXExpandPseudo::ID = 0;

bool KVXExpandPseudo::runOnMachineFunction(MachineFunction &MF) {
  TII = static_cast<const KVXInstrInfo *>(MF.getSubtarget().getInstrInfo());
  bool Modified = false;
  for (auto &MBB : MF)
    Modified |= expandMBB(MBB);
  return Modified;
}

bool KVXExpandPseudo::expandMBB(MachineBasicBlock &MBB) {
  bool Modified = false;

  MachineBasicBlock::iterator MBBI = MBB.begin(), E = MBB.end();
  while (MBBI != E) {
    MachineBasicBlock::iterator NMBBI = std::next(MBBI);
    Modified |= expandMI(MBB, MBBI, NMBBI);
    MBBI = NMBBI;
  }

  return Modified;
}

static void InsertCMOVEInstr(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                             MachineBasicBlock::iterator MBBI, unsigned CmpReg,
                             unsigned DestReg, unsigned Operand,
                             unsigned Comp) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  switch (MI.getOperand(Operand).getType()) {
  case MachineOperand::MO_GlobalAddress:
    BuildMI(MBB, MBBI, DL, TII->get(KVX::CMOVEDri64), DestReg)
        .addReg(CmpReg)
        .addGlobalAddress(MI.getOperand(Operand).getGlobal())
        .addImm(Comp);
    break;
  case MachineOperand::MO_Register: {
    unsigned BranchValue = MI.getOperand(Operand).getReg();

    BuildMI(MBB, MBBI, DL, TII->get(KVX::CMOVEDrr), DestReg)
        .addReg(CmpReg)
        .addReg(BranchValue)
        .addImm(Comp);
  } break;
  case MachineOperand::MO_Immediate: {
    int64_t BranchValueImm = MI.getOperand(Operand).getImm();

    BuildMI(MBB, MBBI, DL,
            TII->get(GetImmOpCode(BranchValueImm, KVX::CMOVEDri10,
                                  KVX::CMOVEDri37, KVX::CMOVEDri64)),
            DestReg)
        .addReg(CmpReg)
        .addImm(BranchValueImm)
        .addImm(Comp);
  } break;
  case MachineOperand::MO_FPImmediate: {
    const ConstantFP *Imm = MI.getOperand(Operand).getFPImm();

    BuildMI(MBB, MBBI, DL,
            TII->get(Imm->getType()->isFloatTy() ? KVX::CMOVEDri37
                                                 : KVX::CMOVEDri64),
            DestReg)
        .addReg(CmpReg)
        .addFPImm(Imm)
        .addImm(Comp);
  } break;
  default:
    llvm_unreachable("Operator type not handled");
    break;
  }
}

static bool expandSelectInstr(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                              MachineBasicBlock::iterator MBBI, bool Word) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();
  unsigned DestReg = MI.getOperand(0).getReg();
  unsigned ScratchReg = MI.getOperand(1).getReg();
  unsigned CmpReg = MI.getOperand(2).getReg();
  unsigned Reg = 0;
  int64_t Cond = MI.getOperand(5).getImm();
  int64_t InvCond = Cond % 2 == 0 ? Cond + 1 : Cond - 1;

  if (MI.getOperand(4).isImm() || MI.getOperand(4).isFPImm() ||
      MI.getOperand(4).isGlobal()) {
    if (MI.getOperand(3).isReg()) {
      Reg = MI.getOperand(3).getReg();
      if (Reg == DestReg) {
        InsertCMOVEInstr(TII, MBB, MBBI, CmpReg, Reg, 4, InvCond);
        Reg = 0;
      } else {
        BuildMI(MBB, MBBI, DL, TII->get(KVX::COPYD), ScratchReg).addReg(Reg);
        InsertCMOVEInstr(TII, MBB, MBBI, CmpReg, ScratchReg, 4, InvCond);
      }

    } else {
      unsigned DestCompReg = Word ? DestReg : ScratchReg;
      if (Word) // use SXWD as cheap copy
      {
        BuildMI(MBB, MBBI, DL, TII->get(KVX::SXWD), ScratchReg).addReg(CmpReg);
      }
      if (MI.getOperand(3).isImm()) {
        int64_t immVal = MI.getOperand(3).getImm();
        BuildMI(MBB, MBBI, DL, TII->get(GetImmMakeOpCode(immVal)), DestCompReg)
            .addImm(immVal);
      }
      if (MI.getOperand(3).isFPImm()) {
        int64_t immVal = MI.getOperand(3)
                             .getFPImm()
                             ->getValueAPF()
                             .bitcastToAPInt()
                             .getZExtValue();
        BuildMI(MBB, MBBI, DL, TII->get(GetImmMakeOpCode(immVal)), DestCompReg)
            .addImm(immVal);
      }
      if (MI.getOperand(3).isGlobal()) {
        BuildMI(MBB, MBBI, DL, TII->get(KVX::MAKEi64), DestCompReg)
            .addGlobalAddress(MI.getOperand(3).getGlobal());
      }
      InsertCMOVEInstr(TII, MBB, MBBI, Word ? ScratchReg : CmpReg, DestCompReg,
                       4, InvCond);
      if (!Word)
        BuildMI(MBB, MBBI, DL, TII->get(KVX::COPYD), DestReg)
            .addReg(ScratchReg);
    }
  } else {
    if (MI.getOperand(4).isReg()) {
      Reg = MI.getOperand(4).getReg();
      if (Reg == DestReg) {
        InsertCMOVEInstr(TII, MBB, MBBI, CmpReg, Reg, 3, Cond);
        Reg = 0;
      } else {
        BuildMI(MBB, MBBI, DL, TII->get(KVX::COPYD), ScratchReg).addReg(Reg);
        InsertCMOVEInstr(TII, MBB, MBBI, CmpReg, ScratchReg, 3, Cond);
      }
    }
  }

  if (Reg != 0)
    BuildMI(MBB, MBBI, DL, TII->get(KVX::COPYD), DestReg).addReg(ScratchReg);

  // Remove the present instruction
  MI.eraseFromParent();
  return true;
}

static bool expandFENCEInstr(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                             MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  unsigned syncScope = MI.getOperand(1).getImm();

  // for __atomic_thread_fence, insert fence instruction
  // for __atomic_signal_fence don't insert anything
  if (syncScope == SyncScope::System)
    BuildMI(MBB, MBBI, DL, TII->get(KVX::FENCE));

  MI.eraseFromParent();
  return true;
}

unsigned int getAtomicLoad(unsigned int opCode) {
  switch (opCode) {
  case KVX::ASWAP32_Instr:
  case KVX::ACMPSWAP32_Instr:
  case KVX::ALOADADD32_Instr:
  case KVX::ALOADSUB32_Instr:
  case KVX::ALOADAND32_Instr:
  case KVX::ALOADXOR32_Instr:
  case KVX::ALOADOR32_Instr:
  case KVX::ALOADNAND32_Instr:
    return KVX::LWZp;
  case KVX::ASWAP64_Instr:
  case KVX::ACMPSWAP64_Instr:
  case KVX::ALOADADD64_Instr:
  case KVX::ALOADSUB64_Instr:
  case KVX::ALOADAND64_Instr:
  case KVX::ALOADXOR64_Instr:
  case KVX::ALOADOR64_Instr:
  case KVX::ALOADNAND64_Instr:
    return KVX::LDp;
  default:
    llvm_unreachable("invalid opCode");
  }
}

unsigned int getAtomicCopy(unsigned int opCode) {
  switch (opCode) {
  case KVX::ASWAP32_Instr:
  case KVX::ACMPSWAP32_Instr:
  case KVX::ALOADADD32_Instr:
  case KVX::ALOADSUB32_Instr:
  case KVX::ALOADAND32_Instr:
  case KVX::ALOADXOR32_Instr:
  case KVX::ALOADOR32_Instr:
  case KVX::ALOADNAND32_Instr:
    return KVX::COPYW;
  case KVX::ASWAP64_Instr:
  case KVX::ACMPSWAP64_Instr:
  case KVX::ALOADADD64_Instr:
  case KVX::ALOADSUB64_Instr:
  case KVX::ALOADAND64_Instr:
  case KVX::ALOADXOR64_Instr:
  case KVX::ALOADOR64_Instr:
  case KVX::ALOADNAND64_Instr:
    return KVX::COPYD;
  default:
    llvm_unreachable("invalid opCode");
  }
}

unsigned int getAtomicSwap(int64_t offset, unsigned int opCode) {
  switch (opCode) {
  case KVX::ASWAP32_Instr:
  case KVX::ACMPSWAP32_Instr:
  case KVX::ALOADADD32_Instr:
  case KVX::ALOADSUB32_Instr:
  case KVX::ALOADAND32_Instr:
  case KVX::ALOADXOR32_Instr:
  case KVX::ALOADOR32_Instr:
  case KVX::ALOADNAND32_Instr:
    return isInt<10>(offset) ? KVX::ACSWAPWri10 : KVX::ACSWAPWri37;
  case KVX::ASWAP64_Instr:
  case KVX::ACMPSWAP64_Instr:
  case KVX::ALOADADD64_Instr:
  case KVX::ALOADSUB64_Instr:
  case KVX::ALOADAND64_Instr:
  case KVX::ALOADXOR64_Instr:
  case KVX::ALOADOR64_Instr:
  case KVX::ALOADNAND64_Instr:
    return isInt<10>(offset) ? KVX::ACSWAPDri10 : KVX::ACSWAPDri37;
  default:
    llvm_unreachable("invalid opCode");
  }
}

unsigned int getAtomicComp(unsigned int opCode) {
  switch (opCode) {
  case KVX::ASWAP32_Instr:
  case KVX::ACMPSWAP32_Instr:
  case KVX::ALOADADD32_Instr:
  case KVX::ALOADSUB32_Instr:
  case KVX::ALOADAND32_Instr:
  case KVX::ALOADXOR32_Instr:
  case KVX::ALOADOR32_Instr:
  case KVX::ALOADNAND32_Instr:
    return KVX::COMPWrr;
  case KVX::ASWAP64_Instr:
  case KVX::ACMPSWAP64_Instr:
  case KVX::ALOADADD64_Instr:
  case KVX::ALOADSUB64_Instr:
  case KVX::ALOADAND64_Instr:
  case KVX::ALOADXOR64_Instr:
  case KVX::ALOADOR64_Instr:
  case KVX::ALOADNAND64_Instr:
    return KVX::COMPDrr;
  default:
    llvm_unreachable("invalid opCode");
  }
}

unsigned int getAtomicOp(unsigned int opCode) {
  switch (opCode) {
  case KVX::ALOADADD32_Instr:
    return KVX::ADDWrr;
  case KVX::ALOADADD64_Instr:
    return KVX::ADDDrr;
  case KVX::ALOADSUB32_Instr:
    return KVX::SBFWrr;
  case KVX::ALOADSUB64_Instr:
    return KVX::SBFDrr;
  case KVX::ALOADAND32_Instr:
  case KVX::ALOADNAND32_Instr:
    return KVX::ANDWrr;
  case KVX::ALOADAND64_Instr:
  case KVX::ALOADNAND64_Instr:
    return KVX::ANDDrr;
  case KVX::ALOADXOR32_Instr:
    return KVX::XORWrr;
  case KVX::ALOADXOR64_Instr:
    return KVX::XORDrr;
  case KVX::ALOADOR32_Instr:
    return KVX::ORWrr;
  case KVX::ALOADOR64_Instr:
    return KVX::ORDrr;
  default:
    llvm_unreachable("invalid opCode");
  }
}

unsigned int getAtomicNand(unsigned int opCode) {
  switch (opCode) {
  case KVX::ALOADNAND32_Instr:
    return KVX::NOTW;
  case KVX::ALOADNAND64_Instr:
    return KVX::NOTD;
  default:
    llvm_unreachable("invalid opCode");
  }
}

unsigned int getAtomicCompReg(unsigned int opCode) {
  switch (opCode) {
  case KVX::ASWAP32_Instr:
  case KVX::ACMPSWAP32_Instr:
    return KVX::COMPWrr;
  case KVX::ASWAP64_Instr:
  case KVX::ACMPSWAP64_Instr:
    return KVX::COMPDrr;
  default:
    llvm_unreachable("invalid opCode");
  }
}

int64_t getAtomicCBVar(unsigned int opCode) {
  switch (opCode) {
  case KVX::ASWAP32_Instr:
  case KVX::ACMPSWAP32_Instr:
  case KVX::ALOADADD32_Instr:
  case KVX::ALOADSUB32_Instr:
  case KVX::ALOADAND32_Instr:
  case KVX::ALOADXOR32_Instr:
  case KVX::ALOADOR32_Instr:
  case KVX::ALOADNAND32_Instr:
    return KVXMOD::SCALARCOND_WNEZ;
  case KVX::ASWAP64_Instr:
  case KVX::ACMPSWAP64_Instr:
  case KVX::ALOADADD64_Instr:
  case KVX::ALOADSUB64_Instr:
  case KVX::ALOADAND64_Instr:
  case KVX::ALOADXOR64_Instr:
  case KVX::ALOADOR64_Instr:
  case KVX::ALOADNAND64_Instr:
    return KVXMOD::SCALARCOND_DNEZ;
  default:
    llvm_unreachable("invalid opCode");
  }
}

static bool expandAtomicSwap8(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                              MachineBasicBlock::iterator MBBI,
                              MachineBasicBlock::iterator &NextMBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  //    fence
  //    copyw scratchVal = valreg
  //    if(offset!=0) addd (scratchBase), (baseReg), (offset)
  //    if(offset!=0) andd (scratchPairedReg,2) = scratchBase, 3
  //    if(offset==0) andd (scratchPairedReg,2) = basereg, 3
  //    notw (scratchPairedReg,1) = (scratchPairedReg,2)
  //    andd scratchBase =
  //       baseReg (offset=0)/scatch_base(offset!=0),
  //       (scratchPairedReg,1)
  //    muld (shiftCount) = (scratchPairedReg,2), 8
  //    sllw scratch_value = scratchVal, (shiftCount)
  // .loop:
  //    lwz.u (scratchPairedReg,2), (0)[scratchBase]
  //    copyw (scratchPairedReg,1), (scratchPairedReg,2)
  //    orwd (scratchPairedReg,1), (scratchPairedReg,1) , scratchVal
  //    acswapw (0)[scratchBase], (scratchPairedReg)
  //    compw.ne (scratchPairedReg,1) = (scratchPairedReg,1),1
  //    cb.wnez (scratchPairedReg,1),(loop)
  // .done:
  //    copyw (outputReg), (scratchPairedReg,2)
  //    sraw (outputReg) = (outputReg), (shiftCount)
  //    fence

  MachineFunction *MF = MBB.getParent();
  const KVXRegisterInfo *TRI =
      (const KVXRegisterInfo *)MF->getSubtarget().getRegisterInfo();

  unsigned outputReg = MI.getOperand(0).getReg();
  unsigned scratchPairedReg = MI.getOperand(1).getReg();
  unsigned scratchBase = MI.getOperand(2).getReg();
  unsigned scratchVal = MI.getOperand(3).getReg();
  unsigned shiftCount = MI.getOperand(4).getReg();
  unsigned offset = MI.getOperand(5).getImm();
  unsigned baseReg = MI.getOperand(6).getReg();
  unsigned valReg = MI.getOperand(7).getReg();

  unsigned compReg = TRI->getSubReg(scratchPairedReg, 1);

  BuildMI(MBB, MBBI, DL, TII->get(KVX::FENCE));

  BuildMI(MBB, MBBI, DL, TII->get(KVX::COPYW), scratchVal).addReg(valReg);

  if (offset != 0) {
    BuildMI(MBB, MBBI, DL, TII->get(GetImmOpCode(offset, KVX::ADDDri10,
                                                 KVX::ADDDri37, KVX::ADDDri64)),
            scratchBase)
        .addReg(baseReg)
        .addImm(offset);
    BuildMI(MBB, MBBI, DL, TII->get(KVX::ANDDri10),
            TRI->getSubReg(scratchPairedReg, 2))
        .addReg(scratchBase)
        .addImm(3);
  } else {
    BuildMI(MBB, MBBI, DL, TII->get(KVX::ANDDri10),
            TRI->getSubReg(scratchPairedReg, 2))
        .addReg(baseReg)
        .addImm(3);
  }
  BuildMI(MBB, MBBI, DL, TII->get(KVX::NOTW),
          TRI->getSubReg(scratchPairedReg, 1))
      .addReg(TRI->getSubReg(scratchPairedReg, 2));
  BuildMI(MBB, MBBI, DL, TII->get(KVX::ANDDrr), scratchBase)
      .addReg(offset == 0 ? baseReg : scratchBase)
      .addReg(TRI->getSubReg(scratchPairedReg, 1));
  BuildMI(MBB, MBBI, DL, TII->get(KVX::MULDri10), shiftCount)
      .addReg(TRI->getSubReg(scratchPairedReg, 2))
      .addImm(8);

  BuildMI(MBB, MBBI, DL, TII->get(KVX::SLLWrr), scratchVal)
      .addReg(scratchVal)
      .addReg(shiftCount);

  auto LoopMBB = MF->CreateMachineBasicBlock(MBB.getBasicBlock());
  auto DoneMBB = MF->CreateMachineBasicBlock(MBB.getBasicBlock());

  // Insert new MBBs.
  MF->insert(++MBB.getIterator(), LoopMBB);
  MF->insert(++LoopMBB->getIterator(), DoneMBB);

  // Set up successors and transfer remaining instructions to DoneMBB.
  LoopMBB->addSuccessor(LoopMBB);
  LoopMBB->addSuccessor(DoneMBB);

  BuildMI(DoneMBB, DL, TII->get(KVX::COPYW), outputReg)
      .addReg(TRI->getSubReg(scratchPairedReg, 2));

  BuildMI(DoneMBB, DL, TII->get(KVX::SRLWrr), outputReg)
      .addReg(outputReg)
      .addReg(shiftCount);

  BuildMI(DoneMBB, DL, TII->get(KVX::FENCE));

  DoneMBB->splice(DoneMBB->end(), &MBB, MI, MBB.end());
  DoneMBB->transferSuccessors(&MBB);
  MBB.addSuccessor(LoopMBB);
  MBB.addSuccessor(DoneMBB);

  BuildMI(LoopMBB, DL, TII->get(KVX::LWZp), TRI->getSubReg(scratchPairedReg, 2))
      .addImm(0)
      .addReg(scratchBase)
      .addImm(KVXMOD::VARIANT_U);

  BuildMI(LoopMBB, DL, TII->get(KVX::COPYW), compReg)
      .addReg(TRI->getSubReg(scratchPairedReg, 2));

  BuildMI(LoopMBB, DL, TII->get(KVX::ORWrr), compReg).addReg(compReg).addReg(
      scratchVal);

  BuildMI(LoopMBB, DL, TII->get(KVX::ACSWAPWri10), scratchPairedReg)
      .addImm(0)
      .addReg(scratchBase)
      .addReg(scratchPairedReg);

  BuildMI(LoopMBB, DL, TII->get(KVX::COMPWri), compReg)
      .addReg(compReg)
      .addImm(1)
      .addImm(KVXMOD::COMPARISON_NE);

  BuildMI(LoopMBB, DL, TII->get(KVX::CB))
      .addReg(compReg)
      .addMBB(LoopMBB)
      .addImm(KVXMOD::SCALARCOND_WNEZ);

  NextMBBI = MBB.end();
  MI.eraseFromParent();

  return true;
}

static bool expandASWAPInstr(unsigned int opCode, const KVXInstrInfo *TII,
                             MachineBasicBlock &MBB,
                             MachineBasicBlock::iterator MBBI,
                             MachineBasicBlock::iterator &NextMBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  //    fence
  // .loop:
  //    lwz.u (scratchPairedReg,2), (addr)
  //    copyw  (scratchPairedReg,1),(valReg)
  //    acswapw (addr), (scratchPairedReg)
  //    compw.ne (scratchPairedReg,1) = (scratchPairedReg,1),1
  //    cb.wnez (scratchPairedReg,1),(loop)
  // .done:
  //    copyw (outputReg), (scratchPairedReg,2)
  //    fence

  MachineFunction *MF = MBB.getParent();
  const KVXRegisterInfo *TRI =
      (const KVXRegisterInfo *)MF->getSubtarget().getRegisterInfo();

  unsigned outputReg = MI.getOperand(0).getReg();
  unsigned scratchPairedReg = MI.getOperand(1).getReg();
  int64_t offset = MI.getOperand(2).getImm();
  unsigned baseReg = MI.getOperand(3).getReg();
  unsigned valReg = MI.getOperand(4).getReg();

  unsigned compReg = TRI->getSubReg(scratchPairedReg, 1);

  BuildMI(MBB, MBBI, DL, TII->get(KVX::FENCE));

  auto LoopMBB = MF->CreateMachineBasicBlock(MBB.getBasicBlock());
  auto DoneMBB = MF->CreateMachineBasicBlock(MBB.getBasicBlock());

  // Insert new MBBs.
  MF->insert(++MBB.getIterator(), LoopMBB);
  MF->insert(++LoopMBB->getIterator(), DoneMBB);

  // Set up successors and transfer remaining instructions to DoneMBB.
  LoopMBB->addSuccessor(LoopMBB);
  LoopMBB->addSuccessor(DoneMBB);
  //    copyw  (outputReg, (scratchPairedReg,2)
  BuildMI(DoneMBB, DL, TII->get(getAtomicCopy(opCode)), outputReg)
      .addReg(TRI->getSubReg(scratchPairedReg, 2));
  BuildMI(DoneMBB, DL, TII->get(KVX::FENCE));
  DoneMBB->splice(DoneMBB->end(), &MBB, MI, MBB.end());
  DoneMBB->transferSuccessors(&MBB);
  MBB.addSuccessor(LoopMBB);

  BuildMI(LoopMBB, DL, TII->get(getAtomicLoad(opCode)),
          TRI->getSubReg(scratchPairedReg, 2))
      .addImm(offset)
      .addReg(baseReg)
      .addImm(KVXMOD::VARIANT_U);

  BuildMI(LoopMBB, DL, TII->get(getAtomicCopy(opCode)), compReg).addReg(valReg);

  BuildMI(LoopMBB, DL, TII->get(getAtomicSwap(offset, opCode)),
          scratchPairedReg)
      .addImm(offset)
      .addReg(baseReg)
      .addReg(scratchPairedReg);

  BuildMI(LoopMBB, DL, TII->get(getAtomicComp(opCode)), compReg)
      .addReg(compReg)
      .addImm(1)
      .addImm(KVXMOD::COMPARISON_NE);

  BuildMI(LoopMBB, DL, TII->get(KVX::CB))
      .addReg(compReg)
      .addMBB(LoopMBB)
      .addImm(getAtomicCBVar(opCode));

  NextMBBI = MBB.end();
  MI.eraseFromParent();

  return true;
}

static bool isNandOp(unsigned int opCode) {
  return opCode == KVX::ALOADNAND32_Instr || opCode == KVX::ALOADNAND64_Instr;
}

static bool expandALOADOPInstr(unsigned int opCode, const KVXInstrInfo *TII,
                               MachineBasicBlock &MBB,
                               MachineBasicBlock::iterator MBBI,
                               MachineBasicBlock::iterator &NextMBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  // fence
  // .loop:
  //    lwz.u (scratchPairedReg,2), (addr)
  //    copyw (scratchPairedReg,1), (scratchPairedReg,2)
  //    (op)  (scratchPairedReg,1) = (valReg), (scratchPairedReg,1)
  //    (notw/d) (scratchPairedReg,1), (scratchPairedReg,1) for NAND only
  //    acswapw (addr), (scratchPairedReg)
  //    compw.ne (scratchPairedReg,1) = (scratchPairedReg,1),1
  //    cb.wnez (scratchPairedReg,1),(loop)
  // .done:
  //    copyw (outputreg), (scratchPairedReg,2)
  //    fence

  MachineFunction *MF = MBB.getParent();
  const KVXRegisterInfo *TRI =
      (const KVXRegisterInfo *)MF->getSubtarget().getRegisterInfo();

  unsigned outputReg = MI.getOperand(0).getReg();
  unsigned scratchPairedReg = MI.getOperand(1).getReg();
  int64_t offset = MI.getOperand(2).getImm();
  unsigned baseReg = MI.getOperand(3).getReg();
  unsigned valReg = MI.getOperand(4).getReg();

  unsigned compReg = TRI->getSubReg(scratchPairedReg, 1);

  BuildMI(MBB, MBBI, DL, TII->get(KVX::FENCE));

  auto LoopMBB = MF->CreateMachineBasicBlock(MBB.getBasicBlock());
  auto DoneMBB = MF->CreateMachineBasicBlock(MBB.getBasicBlock());

  // Insert new MBBs.
  MF->insert(++MBB.getIterator(), LoopMBB);
  MF->insert(++LoopMBB->getIterator(), DoneMBB);

  // Set up successors and transfer remaining instructions to DoneMBB.
  LoopMBB->addSuccessor(LoopMBB);
  LoopMBB->addSuccessor(DoneMBB);

  BuildMI(DoneMBB, DL, TII->get(getAtomicCopy(opCode)), outputReg)
      .addReg(TRI->getSubReg(scratchPairedReg, 2));

  BuildMI(DoneMBB, DL, TII->get(KVX::FENCE));

  DoneMBB->splice(DoneMBB->end(), &MBB, MI, MBB.end());
  DoneMBB->transferSuccessors(&MBB);
  MBB.addSuccessor(LoopMBB);

  BuildMI(LoopMBB, DL, TII->get(getAtomicLoad(opCode)),
          TRI->getSubReg(scratchPairedReg, 2))
      .addImm(offset)
      .addReg(baseReg)
      .addImm(KVXMOD::VARIANT_U);

  BuildMI(LoopMBB, DL, TII->get(getAtomicCopy(opCode)), compReg)
      .addReg(TRI->getSubReg(scratchPairedReg, 2));

  BuildMI(LoopMBB, DL, TII->get(getAtomicOp(opCode)), compReg)
      .addReg(valReg)
      .addReg(compReg);

  if (isNandOp(opCode)) {
    BuildMI(LoopMBB, DL, TII->get(getAtomicNand(opCode)), compReg)
        .addReg(compReg);
  }

  BuildMI(LoopMBB, DL, TII->get(getAtomicSwap(offset, opCode)),
          scratchPairedReg)
      .addImm(offset)
      .addReg(baseReg)
      .addReg(scratchPairedReg);

  BuildMI(LoopMBB, DL, TII->get(getAtomicComp(opCode)), compReg)
      .addReg(compReg)
      .addImm(1)
      .addImm(KVXMOD::COMPARISON_NE);

  BuildMI(LoopMBB, DL, TII->get(KVX::CB))
      .addReg(compReg)
      .addMBB(LoopMBB)
      .addImm(getAtomicCBVar(opCode));

  NextMBBI = MBB.end();
  MI.eraseFromParent();

  return true;
}

static bool expandACMPSWAPInstr(unsigned int opCode, const KVXInstrInfo *TII,
                                MachineBasicBlock &MBB,
                                MachineBasicBlock::iterator MBBI,
                                MachineBasicBlock::iterator &NextMBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  MachineFunction *MF = MBB.getParent();
  const KVXRegisterInfo *TRI =
      (const KVXRegisterInfo *)MF->getSubtarget().getRegisterInfo();

  unsigned outputReg = MI.getOperand(0).getReg();
  unsigned scratchPairedReg = MI.getOperand(1).getReg();

  int64_t offset = MI.getOperand(2).getImm();   // addr
  unsigned baseReg = MI.getOperand(3).getReg(); // addr
  unsigned expectedReg = MI.getOperand(4).getReg();
  unsigned desiredReg = MI.getOperand(5).getReg();

  unsigned compReg = TRI->getSubReg(scratchPairedReg, 1);

  //    fence
  //    copyw  (scratchPairedReg,2),(expectedReg)
  // .loop:
  //    copyw  (scratchPairedReg,1),(desiredReg)
  //    acswapw (addr), (scratchPairedReg)
  //    compw.eq (scratchPairedReg,1) = (scratchPairedReg,1),1
  //    cb.wnez (scratchPairedReg,1),(success)
  //    lwz.u (outputReg) (addr)
  //    compw.eq (scratchPairedReg,1) = (scratchReg), (scratchPairedReg,2)
  //    cb.wnez (scratchPairedReg),(loop)
  //    goto (done)
  // .success:
  //    copyw (outputReg),(scratchPairedReg,2)
  // .done:

  BuildMI(MBB, MBBI, DL, TII->get(KVX::FENCE));
  BuildMI(MBB, MBBI, DL, TII->get(getAtomicCopy(opCode)),
          TRI->getSubReg(scratchPairedReg, 2)).addReg(expectedReg);

  auto LoopMBB = MF->CreateMachineBasicBlock(MBB.getBasicBlock());
  auto SuccessMBB = MF->CreateMachineBasicBlock(MBB.getBasicBlock());
  auto DoneMBB = MF->CreateMachineBasicBlock(MBB.getBasicBlock());

  // Insert new MBBs.
  MF->insert(++MBB.getIterator(), LoopMBB);
  MF->insert(++LoopMBB->getIterator(), SuccessMBB);
  MF->insert(++SuccessMBB->getIterator(), DoneMBB);

  // Set up successors and transfer remaining instructions to DoneMBB.
  LoopMBB->addSuccessor(LoopMBB);
  LoopMBB->addSuccessor(SuccessMBB);
  LoopMBB->addSuccessor(DoneMBB);

  DoneMBB->splice(DoneMBB->end(), &MBB, MI, MBB.end());
  DoneMBB->transferSuccessors(&MBB);
  MBB.addSuccessor(LoopMBB);
  MBB.addSuccessor(SuccessMBB);
  MBB.addSuccessor(DoneMBB);

  BuildMI(LoopMBB, DL, TII->get(getAtomicCopy(opCode)), compReg)
      .addReg(desiredReg);

  BuildMI(LoopMBB, DL, TII->get(getAtomicSwap(offset, opCode)),
          scratchPairedReg)
      .addImm(offset)
      .addReg(baseReg)
      .addReg(scratchPairedReg);

  BuildMI(LoopMBB, DL, TII->get(getAtomicComp(opCode)), compReg)
      .addReg(compReg)
      .addImm(1)
      .addImm(KVXMOD::COMPARISON_EQ);

  BuildMI(LoopMBB, DL, TII->get(KVX::CB))
      .addReg(compReg)
      .addMBB(SuccessMBB)
      .addImm(getAtomicCBVar(opCode));

  BuildMI(LoopMBB, DL, TII->get(getAtomicLoad(opCode)), outputReg)
      .addImm(offset)
      .addReg(baseReg)
      .addImm(KVXMOD::VARIANT_U);

  BuildMI(LoopMBB, DL, TII->get(getAtomicCompReg(opCode)), compReg)
      .addReg(outputReg)
      .addReg(TRI->getSubReg(scratchPairedReg, 2))
      .addImm(KVXMOD::COMPARISON_EQ);

  BuildMI(LoopMBB, DL, TII->get(KVX::CB))
      .addReg(compReg)
      .addMBB(LoopMBB)
      .addImm(getAtomicCBVar(opCode));

  BuildMI(LoopMBB, DL, TII->get(KVX::GOTO)).addMBB(DoneMBB);

  BuildMI(SuccessMBB, DL, TII->get(getAtomicCopy(opCode)), outputReg)
      .addReg(TRI->getSubReg(scratchPairedReg, 2));

  NextMBBI = MBB.end();
  MI.eraseFromParent();

  return true;
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

static bool expandUnaryPairedRegInstrOpcode(unsigned int OpCode,
                                            const KVXInstrInfo *TII,
                                            MachineBasicBlock &MBB,
                                            MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  MachineFunction *MF = MBB.getParent();
  const KVXRegisterInfo *TRI =
      (const KVXRegisterInfo *)MF->getSubtarget().getRegisterInfo();

  unsigned outReg = MI.getOperand(0).getReg();
  unsigned inReg = MI.getOperand(1).getReg();

  BuildMI(MBB, MBBI, DL, TII->get(OpCode), TRI->getSubReg(outReg, 1))
      .addReg(TRI->getSubReg(inReg, 1));
  BuildMI(MBB, MBBI, DL, TII->get(OpCode), TRI->getSubReg(outReg, 2))
      .addReg(TRI->getSubReg(inReg, 2));

  MI.eraseFromParent();
  return true;
}

static bool expandBinaryPairedRegInstrOpcode(unsigned int OpCode,
                                             const KVXInstrInfo *TII,
                                             MachineBasicBlock &MBB,
                                             MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  MachineFunction *MF = MBB.getParent();
  const KVXRegisterInfo *TRI =
      (const KVXRegisterInfo *)MF->getSubtarget().getRegisterInfo();

  unsigned outReg = MI.getOperand(0).getReg();
  unsigned v1Reg = MI.getOperand(1).getReg();
  unsigned v2Reg = MI.getOperand(2).getReg();

  BuildMI(MBB, MBBI, DL, TII->get(OpCode), TRI->getSubReg(outReg, 1))
      .addReg(TRI->getSubReg(v1Reg, 1))
      .addReg(TRI->getSubReg(v2Reg, 1));
  BuildMI(MBB, MBBI, DL, TII->get(OpCode), TRI->getSubReg(outReg, 2))
      .addReg(TRI->getSubReg(v1Reg, 2))
      .addReg(TRI->getSubReg(v2Reg, 2));

  MI.eraseFromParent();
  return true;
}

static bool expandRoundingPairInstrOpcodes(unsigned int OpCode1,
                                           unsigned int OpCode2,
                                           const KVXInstrInfo *TII,
                                           MachineBasicBlock &MBB,
                                           MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  MachineFunction *MF = MBB.getParent();
  const KVXRegisterInfo *TRI =
      (const KVXRegisterInfo *)MF->getSubtarget().getRegisterInfo();

  unsigned outReg = MI.getOperand(0).getReg();
  unsigned v1Reg = MI.getOperand(1).getReg();
  unsigned v2Reg = MI.getOperand(2).getReg();
  int64_t rounding = MI.getOperand(3).getImm();

  BuildMI(MBB, MBBI, DL, TII->get(OpCode1), TRI->getSubReg(outReg, 1))
      .addReg(TRI->getSubReg(v1Reg, 1))
      .addReg(TRI->getSubReg(v2Reg, 1))
      .addImm(rounding)
      .addImm(KVXMOD::SILENT_);
  BuildMI(MBB, MBBI, DL, TII->get(OpCode2), TRI->getSubReg(outReg, 2))
      .addReg(TRI->getSubReg(v1Reg, 2))
      .addReg(TRI->getSubReg(v2Reg, 2))
      .addImm(rounding)
      .addImm(KVXMOD::SILENT_);

  MI.eraseFromParent();
  return true;
}

static bool expandFMULDCInstr(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                              MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  MachineFunction *MF = MBB.getParent();
  const KVXRegisterInfo *TRI =
      (const KVXRegisterInfo *)MF->getSubtarget().getRegisterInfo();

  unsigned outReg = MI.getOperand(0).getReg();
  unsigned v1Reg = MI.getOperand(1).getReg();
  unsigned v2Reg = MI.getOperand(2).getReg();
  int64_t rounding = MI.getOperand(3).getImm();

  BuildMI(MBB, MBBI, DL, TII->get(KVX::FMULDrr), TRI->getSubReg(outReg, 1))
      .addReg(TRI->getSubReg(v1Reg, 1))
      .addReg(TRI->getSubReg(v2Reg, 1))
      .addImm(rounding)
      .addImm(KVXMOD::SILENT_);
  BuildMI(MBB, MBBI, DL, TII->get(KVX::FFMSDrr), TRI->getSubReg(outReg, 1))
      .addReg(TRI->getSubReg(outReg, 1))
      .addReg(TRI->getSubReg(v1Reg, 2))
      .addReg(TRI->getSubReg(v2Reg, 2))
      .addImm(rounding)
      .addImm(KVXMOD::SILENT_);
  BuildMI(MBB, MBBI, DL, TII->get(KVX::FMULDrr), TRI->getSubReg(outReg, 2))
      .addReg(TRI->getSubReg(v1Reg, 1))
      .addReg(TRI->getSubReg(v2Reg, 2))
      .addImm(rounding)
      .addImm(KVXMOD::SILENT_);
  BuildMI(MBB, MBBI, DL, TII->get(KVX::FFMADrr), TRI->getSubReg(outReg, 2))
      .addReg(TRI->getSubReg(outReg, 2))
      .addReg(TRI->getSubReg(v2Reg, 1))
      .addReg(TRI->getSubReg(v1Reg, 2))
      .addImm(rounding)
      .addImm(KVXMOD::SILENT_);

  MI.eraseFromParent();
  return true;
}

static bool expandFMULCDCInstr(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                               MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  MachineFunction *MF = MBB.getParent();
  const KVXRegisterInfo *TRI =
      (const KVXRegisterInfo *)MF->getSubtarget().getRegisterInfo();

  unsigned outReg = MI.getOperand(0).getReg();
  unsigned Scratch = MI.getOperand(1).getReg();
  unsigned v1Reg = MI.getOperand(2).getReg();
  unsigned v2Reg = MI.getOperand(3).getReg();
  int64_t rounding = MI.getOperand(4).getImm();

  BuildMI(MBB, MBBI, DL, TII->get(KVX::FMULDrr), Scratch)
      .addReg(TRI->getSubReg(v1Reg, 1))
      .addReg(TRI->getSubReg(v2Reg, 1))
      .addImm(rounding)
      .addImm(KVXMOD::SILENT_);
  BuildMI(MBB, MBBI, DL, TII->get(KVX::COPYD), TRI->getSubReg(outReg, 1))
      .addReg(TRI->getSubReg(v2Reg, 2));
  BuildMI(MBB, MBBI, DL, TII->get(KVX::FFMADrr), TRI->getSubReg(outReg, 1))
      .addReg(TRI->getSubReg(outReg, 1))
      .addReg(Scratch)
      .addReg(TRI->getSubReg(v1Reg, 2))
      .addImm(rounding)
      .addImm(KVXMOD::SILENT_);
  BuildMI(MBB, MBBI, DL, TII->get(KVX::FMULDrr), Scratch)
      .addReg(TRI->getSubReg(v2Reg, 1))
      .addReg(TRI->getSubReg(v1Reg, 2))
      .addImm(rounding)
      .addImm(KVXMOD::SILENT_);
  BuildMI(MBB, MBBI, DL, TII->get(KVX::COPYD), TRI->getSubReg(outReg, 2))
      .addReg(TRI->getSubReg(v2Reg, 2));
  BuildMI(MBB, MBBI, DL, TII->get(KVX::FFMSDrr), TRI->getSubReg(outReg, 2))
      .addReg(TRI->getSubReg(outReg, 2))
      .addReg(Scratch)
      .addReg(TRI->getSubReg(v1Reg, 1))
      .addImm(rounding)
      .addImm(KVXMOD::SILENT_);

  MI.eraseFromParent();
  return true;
}

static bool
expandRoundingPairedRegInOutInstr(unsigned int OpCode, const KVXInstrInfo *TII,
                                  MachineBasicBlock &MBB,
                                  MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  MachineFunction *MF = MBB.getParent();
  const KVXRegisterInfo *TRI =
      (const KVXRegisterInfo *)MF->getSubtarget().getRegisterInfo();

  unsigned outReg = MI.getOperand(0).getReg();
  unsigned v1Reg = MI.getOperand(1).getReg();
  unsigned v2Reg = MI.getOperand(2).getReg();
  int64_t rounding = MI.getOperand(4).getImm();

  BuildMI(MBB, MBBI, DL, TII->get(OpCode), TRI->getSubReg(outReg, 1))
      .addReg(TRI->getSubReg(outReg, 1))
      .addReg(TRI->getSubReg(v1Reg, 1))
      .addReg(TRI->getSubReg(v2Reg, 1))
      .addImm(rounding)
      .addImm(KVXMOD::SILENT_);

  BuildMI(MBB, MBBI, DL, TII->get(OpCode), TRI->getSubReg(outReg, 2))
      .addReg(TRI->getSubReg(outReg, 2))
      .addReg(TRI->getSubReg(v1Reg, 2))
      .addReg(TRI->getSubReg(v2Reg, 2))
      .addImm(rounding)
      .addImm(KVXMOD::SILENT_);

  MI.eraseFromParent();
  return true;
}

static bool expandRoundingInOutInstr(unsigned int OpCode,
                                     const KVXInstrInfo *TII,
                                     MachineBasicBlock &MBB,
                                     MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  unsigned outReg = MI.getOperand(0).getReg();
  unsigned v1Reg = MI.getOperand(1).getReg();
  unsigned v2Reg = MI.getOperand(2).getReg();
  int64_t rounding = MI.getOperand(4).getImm();

  BuildMI(MBB, MBBI, DL, TII->get(OpCode), outReg)
      .addReg(outReg)
      .addReg(v1Reg)
      .addReg(v2Reg)
      .addImm(rounding)
      .addImm(KVXMOD::SILENT_);

  MI.eraseFromParent();
  return true;
}

static bool expandStore(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                        MachineBasicBlock::iterator MBBI, unsigned ri10,
                        unsigned ri37, unsigned ri64) {

  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  int64_t offset = MI.getOperand(0).getImm();
  unsigned base = MI.getOperand(1).getReg();
  unsigned val = MI.getOperand(2).getReg();

  BuildMI(MBB, MBBI, DL, TII->get(GetImmOpCode(offset, ri10, ri37, ri64)))
      .addImm(offset)
      .addReg(base)
      .addReg(val);

  MI.eraseFromParent();
  return true;
}

static bool expandLoad(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                       MachineBasicBlock::iterator MBBI, unsigned ri10,
                       unsigned ri37, unsigned ri64) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  unsigned outputReg = MI.getOperand(0).getReg();
  int64_t offset = MI.getOperand(1).getImm();
  unsigned base = MI.getOperand(2).getReg();
  int64_t variant = MI.getOperand(3).getImm();

  BuildMI(MBB, MBBI, DL, TII->get(GetImmOpCode(offset, ri10, ri37, ri64)),
          outputReg)
      .addImm(offset)
      .addReg(base)
      .addImm(variant);

  MI.eraseFromParent();
  return true;
}

static bool expandMADDW(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                        MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  unsigned outputReg = MI.getOperand(0).getReg();
  unsigned aReg = MI.getOperand(1).getReg();
  unsigned bReg = MI.getOperand(2).getReg();
  unsigned cReg = 0;
  int64_t cVal;
  if (MI.getOperand(3).isReg())
    cReg = MI.getOperand(3).getReg();
  else
    cVal = MI.getOperand(3).getImm();

  if (outputReg == aReg) {
    if (cReg != 0)
      BuildMI(MBB, MBBI, DL, TII->get(KVX::MADDWrr), outputReg)
          .addReg(outputReg)
          .addReg(bReg)
          .addReg(cReg);
    else
      BuildMI(MBB, MBBI, DL, TII->get(KVX::MADDWri), outputReg)
          .addReg(outputReg)
          .addReg(bReg)
          .addImm(cVal);
  } else {
    if (cReg != 0)
      BuildMI(MBB, MBBI, DL, TII->get(KVX::MULWrr), outputReg)
          .addReg(bReg)
          .addReg(cReg);
    else
      BuildMI(MBB, MBBI, DL, TII->get(KVX::MULWri), outputReg)
          .addReg(bReg)
          .addImm(cVal);

    BuildMI(MBB, MBBI, DL, TII->get(KVX::ADDWrr), outputReg)
        .addReg(aReg)
        .addReg(outputReg);
  }

  MI.eraseFromParent();
  return true;
}

static bool expandEXTFZ(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                        MachineBasicBlock::iterator MBBI, bool Word) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  unsigned outputReg = MI.getOperand(0).getReg();
  unsigned valReg = MI.getOperand(1).getReg();
  int64_t andmask = MI.getOperand(2).getImm();
  int64_t shiftcount = MI.getOperand(3).getImm();

  int count = 0, maxcount = 0;
  int64_t mask = 1;
  int MaxBit = (Word ? 32 : 64) - shiftcount;
  for (int i = 0; i < MaxBit; i++) {
    if ((andmask & mask) != 0) {
      if (maxcount != 0) {
        maxcount = 0;
        count = 0;
        break;
      }
      count++;
    } else {
      if (i == 0)
        break;
      maxcount = count;
    }
    mask <<= 1;
  }
  if (maxcount == 0 && count > 0)
    maxcount = count;
  LLVM_DEBUG(dbgs() << "EXTFZ word: " << Word << " andmask: " << andmask << " shiftcount: " << shiftcount
                    << " maxcount: " << maxcount << "\n");
  if (maxcount > 0) {
    BuildMI(MBB, MBBI, DL, TII->get(KVX::EXTFZ), outputReg)
        .addReg(valReg)
        .addImm(shiftcount + maxcount - 1)
        .addImm(shiftcount);
  } else {
    unsigned OpCode;
    BuildMI(MBB, MBBI, DL, TII->get(Word ? KVX::SRLWri : KVX::SRLDri),
            outputReg)
        .addReg(valReg)
        .addImm(shiftcount);

    if (Word)
      OpCode = GetImmOpCode(andmask, KVX::ANDWri10, KVX::ANDWri37, KVX::NOP);
    else
      OpCode =
          GetImmOpCode(andmask, KVX::ANDDri10, KVX::ANDDri37, KVX::ANDDri64);

    BuildMI(MBB, MBBI, DL, TII->get(OpCode), outputReg)
        .addReg(outputReg)
        .addImm(andmask);
  }

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
    llvm_unreachable("Cache instruction not supported");
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

bool KVXExpandPseudo::expandMI(MachineBasicBlock &MBB,
                               MachineBasicBlock::iterator MBBI,
                               MachineBasicBlock::iterator &NextMBBI) {
  switch (MBBI->getOpcode()) {
  case KVX::Select32p:
    expandSelectInstr(TII, MBB, MBBI, true);
    return true;
  case KVX::Select64p:
    expandSelectInstr(TII, MBB, MBBI, false);
    return true;
  case KVX::FENCE_Instr:
    expandFENCEInstr(TII, MBB, MBBI);
    return true;
  case KVX::ASWAP8_Instr:
    expandAtomicSwap8(TII, MBB, MBBI, NextMBBI);
    return true;
  case KVX::ASWAP32_Instr:
  case KVX::ASWAP64_Instr:
    expandASWAPInstr(MBBI->getOpcode(), TII, MBB, MBBI, NextMBBI);
    return true;
  case KVX::ACMPSWAP32_Instr:
  case KVX::ACMPSWAP64_Instr:
    expandACMPSWAPInstr(MBBI->getOpcode(), TII, MBB, MBBI, NextMBBI);
    return true;
  case KVX::ALOADADD32_Instr:
  case KVX::ALOADADD64_Instr:
  case KVX::ALOADSUB32_Instr:
  case KVX::ALOADSUB64_Instr:
  case KVX::ALOADAND32_Instr:
  case KVX::ALOADAND64_Instr:
  case KVX::ALOADXOR32_Instr:
  case KVX::ALOADXOR64_Instr:
  case KVX::ALOADOR32_Instr:
  case KVX::ALOADOR64_Instr:
  case KVX::ALOADNAND32_Instr:
  case KVX::ALOADNAND64_Instr:
    expandALOADOPInstr(MBBI->getOpcode(), TII, MBB, MBBI, NextMBBI);
    return true;
  case KVX::GET_Instr:
    expandGetInstr(TII, MBB, MBBI);
    return true;
  case KVX::WFXL_Instr:
    expandSystemRegValueInstr(KVX::WFXLrst4, TII, MBB, MBBI);
    return true;
  case KVX::WFXM_Instr:
    expandSystemRegValueInstr(KVX::WFXMrst4, TII, MBB, MBBI);
    return true;
  case KVX::SET_Instr:
    expandSystemRegValueInstr(KVX::SETrst4, TII, MBB, MBBI);
    return true;
  case KVX::FABSWQ_Instr:
    expandUnaryPairedRegInstrOpcode(KVX::FABSWP, TII, MBB, MBBI);
    return true;
  case KVX::FABSDP_Instr:
    expandUnaryPairedRegInstrOpcode(KVX::FABSD, TII, MBB, MBBI);
    return true;
  case KVX::FNEGWQ_Instr:
    expandUnaryPairedRegInstrOpcode(KVX::FNEGWP, TII, MBB, MBBI);
    return true;
  case KVX::FNEGDP_Instr:
    expandUnaryPairedRegInstrOpcode(KVX::FNEGD, TII, MBB, MBBI);
    return true;
  case KVX::FMAXWQ_Instr:
    expandBinaryPairedRegInstrOpcode(KVX::FMAXWP, TII, MBB, MBBI);
    return true;
  case KVX::FMAXDP_Instr:
    expandBinaryPairedRegInstrOpcode(KVX::FMAXD, TII, MBB, MBBI);
    return true;
  case KVX::FMINWQ_Instr:
    expandBinaryPairedRegInstrOpcode(KVX::FMINWP, TII, MBB, MBBI);
    return true;
  case KVX::FMINDP_Instr:
    expandBinaryPairedRegInstrOpcode(KVX::FMIND, TII, MBB, MBBI);
    return true;
  case KVX::FMULWCP_Instr:
    expandRoundingPairInstrOpcodes(KVX::FMULWCrr, KVX::FMULWCrr, TII, MBB,
                                   MBBI);
    return true;
  case KVX::FMULCWCP_Instr:
    expandRoundingPairInstrOpcodes(KVX::FMULCWCrr, KVX::FMULCWCrr, TII, MBB,
                                   MBBI);
    return true;
  case KVX::FMULDP_Instr:
    expandRoundingPairInstrOpcodes(KVX::FMULDrr, KVX::FMULDrr, TII, MBB, MBBI);
    return true;
  case KVX::FMULDC_Instr:
    expandFMULDCInstr(TII, MBB, MBBI);
    return true;
  case KVX::FMULCDC_Instr:
    expandFMULCDCInstr(TII, MBB, MBBI);
    return true;
  case KVX::FFMAWP_Instr:
    expandRoundingInOutInstr(KVX::FFMAWPrr, TII, MBB, MBBI);
    return true;
  case KVX::FFMAWQ_Instr:
    expandRoundingPairedRegInOutInstr(KVX::FFMAWPrr, TII, MBB, MBBI);
    return true;
  case KVX::FFMADP_Instr:
    expandRoundingPairedRegInOutInstr(KVX::FFMADrr, TII, MBB, MBBI);
    return true;
  case KVX::FMM2AWQ_Instr:
    expandRoundingInOutInstr(KVX::FMM2AWQ, TII, MBB, MBBI);
    return true;
  case KVX::FFMSWP_Instr:
    expandRoundingInOutInstr(KVX::FFMSWPrr, TII, MBB, MBBI);
    return true;
  case KVX::FFMSWQ_Instr:
    expandRoundingPairedRegInOutInstr(KVX::FFMSWPrr, TII, MBB, MBBI);
    return true;
  case KVX::FFMSDP_Instr:
    expandRoundingPairedRegInOutInstr(KVX::FFMSDrr, TII, MBB, MBBI);
    return true;
  case KVX::FMM2SWQ_Instr:
    expandRoundingInOutInstr(KVX::FMM2SWQ, TII, MBB, MBBI);
    return true;
  case KVX::SBp:
    expandStore(TII, MBB, MBBI, KVX::SBri10, KVX::SBri37, KVX::SBri64);
    return true;
  case KVX::SHp:
    expandStore(TII, MBB, MBBI, KVX::SHri10, KVX::SHri37, KVX::SHri64);
    return true;
  case KVX::SWp:
    expandStore(TII, MBB, MBBI, KVX::SWri10, KVX::SWri37, KVX::SWri64);
    return true;
  case KVX::SDp:
    expandStore(TII, MBB, MBBI, KVX::SDri10, KVX::SDri37, KVX::SDri64);
    return true;
  case KVX::SQp:
    expandStore(TII, MBB, MBBI, KVX::SQri10, KVX::SQri37, KVX::SQri64);
    return true;
  case KVX::SOp:
    expandStore(TII, MBB, MBBI, KVX::SOri10, KVX::SOri37, KVX::SOri64);
    return true;
  case KVX::LBSp:
    expandLoad(TII, MBB, MBBI, KVX::LBSri10, KVX::LBSri37, KVX::LBSri64);
    return true;
  case KVX::LBZp:
    expandLoad(TII, MBB, MBBI, KVX::LBZri10, KVX::LBZri37, KVX::LBZri64);
    return true;
  case KVX::LHSp:
    expandLoad(TII, MBB, MBBI, KVX::LHSri10, KVX::LHSri37, KVX::LHSri64);
    return true;
  case KVX::LHZp:
    expandLoad(TII, MBB, MBBI, KVX::LHZri10, KVX::LHZri37, KVX::LHZri64);
    return true;
  case KVX::LWSp:
    expandLoad(TII, MBB, MBBI, KVX::LWSri10, KVX::LWSri37, KVX::LWSri64);
    return true;
  case KVX::LWZp:
    expandLoad(TII, MBB, MBBI, KVX::LWZri10, KVX::LWZri37, KVX::LWZri64);
    return true;
  case KVX::LDp:
    expandLoad(TII, MBB, MBBI, KVX::LDri10, KVX::LDri37, KVX::LDri64);
    return true;
  case KVX::LQp:
    expandLoad(TII, MBB, MBBI, KVX::LQri10, KVX::LQri37, KVX::LQri64);
    return true;
  case KVX::LOp:
    expandLoad(TII, MBB, MBBI, KVX::LOri10, KVX::LOri37, KVX::LOri64);
    return true;
  case KVX::MADDWp:
    expandMADDW(TII, MBB, MBBI);
    return true;
  case KVX::EXTFZWp:
    expandEXTFZ(TII, MBB, MBBI, true);
    return true;
  case KVX::EXTFZDp:
    expandEXTFZ(TII, MBB, MBBI, false);
    return true;
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

INITIALIZE_PASS(KVXExpandPseudo, "kvx-expand-pseudo", KVX_EXPAND_PSEUDO_NAME,
                false, false)
namespace llvm {

FunctionPass *createKVXExpandPseudoPass() { return new KVXExpandPseudo(); }

} // end of namespace llvm
