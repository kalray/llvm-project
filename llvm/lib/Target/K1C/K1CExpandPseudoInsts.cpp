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

static void InsertCMOVEInstr(const K1CInstrInfo *TII, MachineBasicBlock &MBB,
                             MachineBasicBlock::iterator MBBI, unsigned CmpReg,
                             unsigned DestReg, unsigned Operand,
                             unsigned Comp) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  switch (MI.getOperand(Operand).getType()) {
  case MachineOperand::MO_GlobalAddress:
    BuildMI(MBB, MBBI, DL, TII->get(K1C::CMOVEDri64), DestReg)
        .addReg(CmpReg)
        .addGlobalAddress(MI.getOperand(Operand).getGlobal())
        .addImm(Comp);
    break;
  case MachineOperand::MO_Register: {
    unsigned BranchValue = MI.getOperand(Operand).getReg();

    BuildMI(MBB, MBBI, DL, TII->get(K1C::CMOVEDrr), DestReg)
        .addReg(CmpReg)
        .addReg(BranchValue)
        .addImm(Comp);
  } break;
  case MachineOperand::MO_Immediate: {
    int64_t BranchValueImm = MI.getOperand(Operand).getImm();

    BuildMI(MBB, MBBI, DL,
            TII->get(GetImmOpCode(BranchValueImm, K1C::CMOVEDri10,
                                  K1C::CMOVEDri37, K1C::CMOVEDri64)),
            DestReg)
        .addReg(CmpReg)
        .addImm(BranchValueImm)
        .addImm(Comp);
  } break;
  case MachineOperand::MO_FPImmediate: {
    const ConstantFP *Imm = MI.getOperand(Operand).getFPImm();

    BuildMI(
        MBB, MBBI, DL,
            TII->get(Imm->getType()->isFloatTy() ? K1C::CMOVEDri37
                                                 : K1C::CMOVEDri64),
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

static bool expandSelectInstr(const K1CInstrInfo *TII, MachineBasicBlock &MBB,
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
      InsertCMOVEInstr(TII, MBB, MBBI, CmpReg, Reg, 4, InvCond);
    } else {
      unsigned opCode;
      unsigned DestCompReg = Word ? DestReg : ScratchReg;
      if (Word) // use SXWD as cheap copy
        BuildMI(MBB, MBBI, DL, TII->get(K1C::SXWD), ScratchReg).addReg(CmpReg);
      if (MI.getOperand(3).isImm()) {
        int64_t immVal = MI.getOperand(3).getImm();
        // FIXME: GetImmOpCode is not OK with MAKE
        opCode = GetImmOpCode(immVal, K1C::MAKEi16, K1C::MAKEi43, K1C::MAKEi64);
        BuildMI(MBB, MBBI, DL, TII->get(opCode), DestCompReg).addImm(immVal);
      }
      if (MI.getOperand(3).isFPImm()) {
        int64_t immVal = MI.getOperand(3)
                             .getFPImm()
                             ->getValueAPF()
                             .bitcastToAPInt()
                             .getZExtValue();
        // FIXME: GetImmOpCode is not OK with MAKE
        opCode = GetImmOpCode(immVal, K1C::MAKEi16, K1C::MAKEi43, K1C::MAKEi64);
        BuildMI(MBB, MBBI, DL, TII->get(opCode), DestCompReg).addImm(immVal);
      }
      if (MI.getOperand(3).isGlobal()) {
        BuildMI(MBB, MBBI, DL, TII->get(K1C::MAKEi64), DestCompReg)
            .addGlobalAddress(MI.getOperand(3).getGlobal());
      }
      InsertCMOVEInstr(TII, MBB, MBBI, Word ? ScratchReg : CmpReg, DestCompReg,
                       4, InvCond);
      if (!Word)
        BuildMI(MBB, MBBI, DL, TII->get(K1C::COPYD), DestReg)
            .addReg(ScratchReg);
    }
  } else {
    if (MI.getOperand(4).isReg()) {
      Reg = MI.getOperand(4).getReg();
      InsertCMOVEInstr(TII, MBB, MBBI, CmpReg, Reg, 3, Cond);
    }
  }

  if (Reg != 0 && DestReg != Reg)
    BuildMI(MBB, MBBI, DL, TII->get(K1C::COPYD), DestReg).addReg(Reg);

  // Remove the present instruction
  MI.eraseFromParent();
  return true;
}

static bool expandFENCEInstr(const K1CInstrInfo *TII, MachineBasicBlock &MBB,
                             MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  unsigned syncScope = MI.getOperand(1).getImm();

  // for __atomic_thread_fence, insert fence instruction
  // for __atomic_signal_fence don't insert anything
  if (syncScope == SyncScope::System)
    BuildMI(MBB, MBBI, DL, TII->get(K1C::FENCE));

  MI.eraseFromParent();
  return true;
}

unsigned int getAtomicLoad(unsigned int opCode) {
  switch (opCode) {
  case K1C::ASWAP32_Instr:
  case K1C::ACMPSWAP32_Instr:
  case K1C::ALOADADD32_Instr:
  case K1C::ALOADSUB32_Instr:
  case K1C::ALOADAND32_Instr:
  case K1C::ALOADXOR32_Instr:
  case K1C::ALOADOR32_Instr:
  case K1C::ALOADNAND32_Instr:
    return K1C::LWZp;
  case K1C::ASWAP64_Instr:
  case K1C::ACMPSWAP64_Instr:
  case K1C::ALOADADD64_Instr:
  case K1C::ALOADSUB64_Instr:
  case K1C::ALOADAND64_Instr:
  case K1C::ALOADXOR64_Instr:
  case K1C::ALOADOR64_Instr:
  case K1C::ALOADNAND64_Instr:
    return K1C::LDp;
  default:
    llvm_unreachable("invalid opCode");
  }
}

unsigned int getAtomicCopy(unsigned int opCode) {
  switch (opCode) {
  case K1C::ASWAP32_Instr:
  case K1C::ACMPSWAP32_Instr:
  case K1C::ALOADADD32_Instr:
  case K1C::ALOADSUB32_Instr:
  case K1C::ALOADAND32_Instr:
  case K1C::ALOADXOR32_Instr:
  case K1C::ALOADOR32_Instr:
  case K1C::ALOADNAND32_Instr:
    return K1C::COPYW;
  case K1C::ASWAP64_Instr:
  case K1C::ACMPSWAP64_Instr:
  case K1C::ALOADADD64_Instr:
  case K1C::ALOADSUB64_Instr:
  case K1C::ALOADAND64_Instr:
  case K1C::ALOADXOR64_Instr:
  case K1C::ALOADOR64_Instr:
  case K1C::ALOADNAND64_Instr:
    return K1C::COPYD;
  default:
    llvm_unreachable("invalid opCode");
  }
}

unsigned int getAtomicSwap(int64_t offset, unsigned int opCode) {
  switch (opCode) {
  case K1C::ASWAP32_Instr:
  case K1C::ACMPSWAP32_Instr:
  case K1C::ALOADADD32_Instr:
  case K1C::ALOADSUB32_Instr:
  case K1C::ALOADAND32_Instr:
  case K1C::ALOADXOR32_Instr:
  case K1C::ALOADOR32_Instr:
  case K1C::ALOADNAND32_Instr:
    return isInt<10>(offset) ? K1C::ACSWAPWri10 : K1C::ACSWAPWri37;
  case K1C::ASWAP64_Instr:
  case K1C::ACMPSWAP64_Instr:
  case K1C::ALOADADD64_Instr:
  case K1C::ALOADSUB64_Instr:
  case K1C::ALOADAND64_Instr:
  case K1C::ALOADXOR64_Instr:
  case K1C::ALOADOR64_Instr:
  case K1C::ALOADNAND64_Instr:
    return isInt<10>(offset) ? K1C::ACSWAPDri10 : K1C::ACSWAPDri37;
  default:
    llvm_unreachable("invalid opCode");
  }
}

unsigned int getAtomicComp(unsigned int opCode) {
  switch (opCode) {
  case K1C::ASWAP32_Instr:
  case K1C::ACMPSWAP32_Instr:
  case K1C::ALOADADD32_Instr:
  case K1C::ALOADSUB32_Instr:
  case K1C::ALOADAND32_Instr:
  case K1C::ALOADXOR32_Instr:
  case K1C::ALOADOR32_Instr:
  case K1C::ALOADNAND32_Instr:
    return K1C::COMPWrr;
  case K1C::ASWAP64_Instr:
  case K1C::ACMPSWAP64_Instr:
  case K1C::ALOADADD64_Instr:
  case K1C::ALOADSUB64_Instr:
  case K1C::ALOADAND64_Instr:
  case K1C::ALOADXOR64_Instr:
  case K1C::ALOADOR64_Instr:
  case K1C::ALOADNAND64_Instr:
    return K1C::COMPDrr;
  default:
    llvm_unreachable("invalid opCode");
  }
}

unsigned int getAtomicOp(unsigned int opCode) {
  switch (opCode) {
  case K1C::ALOADADD32_Instr:
    return K1C::ADDWrr;
  case K1C::ALOADADD64_Instr:
    return K1C::ADDDrr;
  case K1C::ALOADSUB32_Instr:
    return K1C::SBFWrr;
  case K1C::ALOADSUB64_Instr:
    return K1C::SBFDrr;
  case K1C::ALOADAND32_Instr:
  case K1C::ALOADNAND32_Instr:
    return K1C::ANDWrr;
  case K1C::ALOADAND64_Instr:
  case K1C::ALOADNAND64_Instr:
    return K1C::ANDDrr;
  case K1C::ALOADXOR32_Instr:
    return K1C::XORWrr;
  case K1C::ALOADXOR64_Instr:
    return K1C::XORDrr;
  case K1C::ALOADOR32_Instr:
    return K1C::ORWrr;
  case K1C::ALOADOR64_Instr:
    return K1C::ORDrr;
  default:
    llvm_unreachable("invalid opCode");
  }
}

unsigned int getAtomicNand(unsigned int opCode) {
  switch (opCode) {
  case K1C::ALOADNAND32_Instr:
    return K1C::NOTW;
  case K1C::ALOADNAND64_Instr:
    return K1C::NOTD;
  default:
    llvm_unreachable("invalid opCode");
  }
}

unsigned int getAtomicCompReg(unsigned int opCode) {
  switch (opCode) {
  case K1C::ASWAP32_Instr:
  case K1C::ACMPSWAP32_Instr:
    return K1C::COMPWrr;
  case K1C::ASWAP64_Instr:
  case K1C::ACMPSWAP64_Instr:
    return K1C::COMPDrr;
  default:
    llvm_unreachable("invalid opCode");
  }
}

int64_t getAtomicCBVar(unsigned int opCode) {
  switch (opCode) {
  case K1C::ASWAP32_Instr:
  case K1C::ACMPSWAP32_Instr:
  case K1C::ALOADADD32_Instr:
  case K1C::ALOADSUB32_Instr:
  case K1C::ALOADAND32_Instr:
  case K1C::ALOADXOR32_Instr:
  case K1C::ALOADOR32_Instr:
  case K1C::ALOADNAND32_Instr:
    return 8; // wnez
  case K1C::ASWAP64_Instr:
  case K1C::ACMPSWAP64_Instr:
  case K1C::ALOADADD64_Instr:
  case K1C::ALOADSUB64_Instr:
  case K1C::ALOADAND64_Instr:
  case K1C::ALOADXOR64_Instr:
  case K1C::ALOADOR64_Instr:
  case K1C::ALOADNAND64_Instr:
    return 0; // dnez
  default:
    llvm_unreachable("invalid opCode");
  }
}

static bool expandAtomicSwap8(const K1CInstrInfo *TII, MachineBasicBlock &MBB,
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
  const K1CRegisterInfo *TRI =
      (const K1CRegisterInfo *)MF->getSubtarget().getRegisterInfo();

  unsigned outputReg = MI.getOperand(0).getReg();
  unsigned scratchPairedReg = MI.getOperand(1).getReg();
  unsigned scratchBase = MI.getOperand(2).getReg();
  unsigned scratchVal = MI.getOperand(3).getReg();
  unsigned shiftCount = MI.getOperand(4).getReg();
  unsigned offset = MI.getOperand(5).getImm();
  unsigned baseReg = MI.getOperand(6).getReg();
  unsigned valReg = MI.getOperand(7).getReg();

  unsigned compReg = TRI->getSubReg(scratchPairedReg, 1);

  BuildMI(MBB, MBBI, DL, TII->get(K1C::FENCE));

  BuildMI(MBB, MBBI, DL, TII->get(K1C::COPYW), scratchVal).addReg(valReg);

  if (offset != 0) {
    BuildMI(
        MBB, MBBI, DL,
            TII->get(GetImmOpCode(offset, K1C::ADDDri10, K1C::ADDDri37,
                                  K1C::ADDDri64)),
            scratchBase)
        .addReg(baseReg)
        .addImm(offset);
    BuildMI(MBB, MBBI, DL, TII->get(K1C::ANDDri10),
            TRI->getSubReg(scratchPairedReg, 2))
        .addReg(scratchBase)
        .addImm(3);
  } else {
    BuildMI(MBB, MBBI, DL, TII->get(K1C::ANDDri10),
            TRI->getSubReg(scratchPairedReg, 2))
        .addReg(baseReg)
        .addImm(3);
  }
  BuildMI(MBB, MBBI, DL, TII->get(K1C::NOTW),
          TRI->getSubReg(scratchPairedReg, 1))
      .addReg(TRI->getSubReg(scratchPairedReg, 2));
  BuildMI(MBB, MBBI, DL, TII->get(K1C::ANDDrr), scratchBase)
      .addReg(offset == 0 ? baseReg : scratchBase)
      .addReg(TRI->getSubReg(scratchPairedReg, 1));
  BuildMI(MBB, MBBI, DL, TII->get(K1C::MULDri10), shiftCount)
      .addReg(TRI->getSubReg(scratchPairedReg, 2))
      .addImm(8);

  BuildMI(MBB, MBBI, DL, TII->get(K1C::SLLWrr), scratchVal)
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

  BuildMI(DoneMBB, DL, TII->get(K1C::COPYW), outputReg)
      .addReg(TRI->getSubReg(scratchPairedReg, 2));

  BuildMI(DoneMBB, DL, TII->get(K1C::SRLWrr), outputReg)
      .addReg(outputReg)
      .addReg(shiftCount);

  BuildMI(DoneMBB, DL, TII->get(K1C::FENCE));

  DoneMBB->splice(DoneMBB->end(), &MBB, MI, MBB.end());
  DoneMBB->transferSuccessors(&MBB);
  MBB.addSuccessor(LoopMBB);
  MBB.addSuccessor(DoneMBB);

  BuildMI(LoopMBB, DL, TII->get(K1C::LWZp), TRI->getSubReg(scratchPairedReg, 2))
      .addImm(0)
      .addReg(scratchBase)
      .addImm(2 /*uncached*/);

  BuildMI(LoopMBB, DL, TII->get(K1C::COPYW), compReg)
      .addReg(TRI->getSubReg(scratchPairedReg, 2));

  BuildMI(LoopMBB, DL, TII->get(K1C::ORWrr), compReg)
      .addReg(compReg)
      .addReg(scratchVal);

  BuildMI(LoopMBB, DL, TII->get(K1C::ACSWAPWri10), scratchPairedReg)
      .addImm(0)
      .addReg(scratchBase)
      .addReg(scratchPairedReg);

  BuildMI(LoopMBB, DL, TII->get(K1C::COMPWri), compReg)
      .addReg(compReg)
      .addImm(1)
      .addImm(0 /*ne*/);

  BuildMI(LoopMBB, DL, TII->get(K1C::CB))
      .addReg(compReg)
      .addMBB(LoopMBB)
      .addImm(8 /*wnez*/);

  NextMBBI = MBB.end();
  MI.eraseFromParent();

  return true;
}

static bool expandASWAPInstr(unsigned int opCode, const K1CInstrInfo *TII,
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
  const K1CRegisterInfo *TRI =
      (const K1CRegisterInfo *)MF->getSubtarget().getRegisterInfo();

  unsigned outputReg = MI.getOperand(0).getReg();
  unsigned scratchPairedReg = MI.getOperand(1).getReg();
  int64_t offset = MI.getOperand(2).getImm();
  unsigned baseReg = MI.getOperand(3).getReg();
  unsigned valReg = MI.getOperand(4).getReg();

  unsigned compReg = TRI->getSubReg(scratchPairedReg, 1);

  BuildMI(MBB, MBBI, DL, TII->get(K1C::FENCE));

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
  BuildMI(DoneMBB, DL, TII->get(K1C::FENCE));
  DoneMBB->splice(DoneMBB->end(), &MBB, MI, MBB.end());
  DoneMBB->transferSuccessors(&MBB);
  MBB.addSuccessor(LoopMBB);

  BuildMI(LoopMBB, DL, TII->get(getAtomicLoad(opCode)),
          TRI->getSubReg(scratchPairedReg, 2))
      .addImm(offset)
      .addReg(baseReg)
      .addImm(2); // uncached

  BuildMI(LoopMBB, DL, TII->get(getAtomicCopy(opCode)), compReg).addReg(valReg);

  BuildMI(LoopMBB, DL, TII->get(getAtomicSwap(offset, opCode)),
          scratchPairedReg)
      .addImm(offset)
      .addReg(baseReg)
      .addReg(scratchPairedReg);

  BuildMI(LoopMBB, DL, TII->get(getAtomicComp(opCode)), compReg)
      .addReg(compReg)
      .addImm(1)
      .addImm(0); // ne

  BuildMI(LoopMBB, DL, TII->get(K1C::CB))
      .addReg(compReg)
      .addMBB(LoopMBB)
      .addImm(getAtomicCBVar(opCode));

  NextMBBI = MBB.end();
  MI.eraseFromParent();

  return true;
}

static bool isNandOp(unsigned int opCode) {
  return opCode == K1C::ALOADNAND32_Instr || opCode == K1C::ALOADNAND64_Instr;
}

static bool expandALOADADD32Instr(const K1CInstrInfo *TII,
                                  MachineBasicBlock &MBB,
                                  MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  unsigned outputReg = MI.getOperand(0).getReg();
  unsigned offset = MI.getOperand(1).getImm();
  unsigned baseReg = MI.getOperand(2).getReg();
  unsigned valReg = MI.getOperand(3).getReg();

  BuildMI(MBB, MBBI, DL, TII->get(K1C::FENCE));
  if (outputReg != valReg)
    BuildMI(MBB, MBBI, DL, TII->get(K1C::COPYW), outputReg).addReg(valReg);
  BuildMI(MBB, MBBI, DL,
          TII->get(GetImmOpCode(offset, K1C::ALADDWri10, K1C::ALADDWri37,
                                K1C::ALADDWri64)),
          outputReg)
      .addImm(offset)
      .addReg(baseReg)
      .addReg(outputReg);

  BuildMI(MBB, MBBI, DL, TII->get(K1C::FENCE));

  MI.eraseFromParent();
  return true;
}

static bool expandALOADADD64Instr(const K1CInstrInfo *TII,
                                  MachineBasicBlock &MBB,
                                  MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  unsigned outputReg = MI.getOperand(0).getReg();
  unsigned offset = MI.getOperand(1).getImm();
  unsigned baseReg = MI.getOperand(2).getReg();
  unsigned valReg = MI.getOperand(3).getReg();

  BuildMI(MBB, MBBI, DL, TII->get(K1C::FENCE));
  if (outputReg != valReg)
    BuildMI(MBB, MBBI, DL, TII->get(K1C::COPYD), outputReg).addReg(valReg);
  BuildMI(MBB, MBBI, DL,
          TII->get(GetImmOpCode(offset, K1C::ALADDDri10, K1C::ALADDDri37,
                                K1C::ALADDDri64)),
          outputReg)
      .addImm(offset)
      .addReg(baseReg)
      .addReg(outputReg);
  BuildMI(MBB, MBBI, DL, TII->get(K1C::FENCE));

  MI.eraseFromParent();
  return true;
}

static bool expandALOADOPInstr(unsigned int opCode, const K1CInstrInfo *TII,
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
  const K1CRegisterInfo *TRI =
      (const K1CRegisterInfo *)MF->getSubtarget().getRegisterInfo();

  unsigned outputReg = MI.getOperand(0).getReg();
  unsigned scratchPairedReg = MI.getOperand(1).getReg();
  int64_t offset = MI.getOperand(2).getImm();
  unsigned baseReg = MI.getOperand(3).getReg();
  unsigned valReg = MI.getOperand(4).getReg();

  unsigned compReg = TRI->getSubReg(scratchPairedReg, 1);

  BuildMI(MBB, MBBI, DL, TII->get(K1C::FENCE));

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

  BuildMI(DoneMBB, DL, TII->get(K1C::FENCE));

  DoneMBB->splice(DoneMBB->end(), &MBB, MI, MBB.end());
  DoneMBB->transferSuccessors(&MBB);
  MBB.addSuccessor(LoopMBB);

  BuildMI(LoopMBB, DL, TII->get(getAtomicLoad(opCode)),
          TRI->getSubReg(scratchPairedReg, 2))
      .addImm(offset)
      .addReg(baseReg)
      .addImm(2); // uncached

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
      .addImm(0); // ne

  BuildMI(LoopMBB, DL, TII->get(K1C::CB))
      .addReg(compReg)
      .addMBB(LoopMBB)
      .addImm(getAtomicCBVar(opCode));

  NextMBBI = MBB.end();
  MI.eraseFromParent();

  return true;
}

static bool expandACMPSWAPInstr(unsigned int opCode, const K1CInstrInfo *TII,
                                MachineBasicBlock &MBB,
                                MachineBasicBlock::iterator MBBI,
                                MachineBasicBlock::iterator &NextMBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  MachineFunction *MF = MBB.getParent();
  const K1CRegisterInfo *TRI =
      (const K1CRegisterInfo *)MF->getSubtarget().getRegisterInfo();

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

  BuildMI(MBB, MBBI, DL, TII->get(K1C::FENCE));
  BuildMI(MBB, MBBI, DL, TII->get(getAtomicCopy(opCode)),
          TRI->getSubReg(scratchPairedReg, 2))
      .addReg(expectedReg);

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
      .addImm(1); // eq

  BuildMI(LoopMBB, DL, TII->get(K1C::CB))
      .addReg(compReg)
      .addMBB(SuccessMBB)
      .addImm(getAtomicCBVar(opCode) /*wnez*/);

  BuildMI(LoopMBB, DL, TII->get(getAtomicLoad(opCode)),
          outputReg)
      .addImm(offset)
      .addReg(baseReg)
      .addImm(2); // uncached

  BuildMI(LoopMBB, DL, TII->get(getAtomicCompReg(opCode)), compReg)
      .addReg(outputReg)
      .addReg(TRI->getSubReg(scratchPairedReg, 2))
      .addImm(1); // eq

  BuildMI(LoopMBB, DL, TII->get(K1C::CB))
      .addReg(compReg)
      .addMBB(LoopMBB)
      .addImm(getAtomicCBVar(opCode) /*wnez*/);

  BuildMI(LoopMBB, DL, TII->get(K1C::GOTO)).addMBB(DoneMBB);

  BuildMI(SuccessMBB, DL, TII->get(getAtomicCopy(opCode)), outputReg)
      .addReg(TRI->getSubReg(scratchPairedReg, 2));

  NextMBBI = MBB.end();
  MI.eraseFromParent();

  return true;
}

static bool expandGetInstr(const K1CInstrInfo *TII, MachineBasicBlock &MBB,
                           MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  unsigned DestReg = MI.getOperand(0).getReg();
  int64_t regNo = MI.getOperand(1).getImm();

  BuildMI(MBB, MBBI, DL, TII->get(K1C::GETss3), DestReg)
      .addReg(K1C::SystemRegRegClass.getRegister(regNo));

  MI.eraseFromParent();
  return true;
}

static bool expandSystemRegValueInstr(unsigned int Opcode,
                                      const K1CInstrInfo *TII,
                                      MachineBasicBlock &MBB,
                                      MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  unsigned int sysReg =
      K1C::SystemRegRegClass.getRegister(MI.getOperand(0).getImm());
  unsigned valReg = MI.getOperand(1).getReg();

  BuildMI(MBB, MBBI, DL, TII->get(Opcode), sysReg).addReg(valReg);

  MI.eraseFromParent();
  return true;
}

static bool expandSBMM8Instr(const K1CInstrInfo *TII, MachineBasicBlock &MBB,
                             MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  unsigned outReg = MI.getOperand(0).getReg();
  unsigned inReg = MI.getOperand(1).getReg();

  if (MI.getOperand(2).isReg()) {
    unsigned valReg = MI.getOperand(2).getReg();

    BuildMI(MBB, MBBI, DL, TII->get(K1C::SBMM8rr), outReg)
        .addReg(inReg)
        .addReg(valReg);
  } else {
    int64_t imm = MI.getOperand(2).getImm();

    BuildMI(
        MBB, MBBI, DL,
            TII->get(GetImmOpCode(imm, K1C::SBMM8ri10, K1C::SBMM8ri37,
                                  K1C::SBMM8ri64)),
            outReg)
        .addReg(inReg)
        .addImm(imm);
  }

  MI.eraseFromParent();
  return true;
}

static bool expandUnaryPairedRegInstrOpcode(unsigned int OpCode,
                                            const K1CInstrInfo *TII,
                                            MachineBasicBlock &MBB,
                                            MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  MachineFunction *MF = MBB.getParent();
  const K1CRegisterInfo *TRI =
      (const K1CRegisterInfo *)MF->getSubtarget().getRegisterInfo();

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
                                             const K1CInstrInfo *TII,
                                             MachineBasicBlock &MBB,
                                             MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  MachineFunction *MF = MBB.getParent();
  const K1CRegisterInfo *TRI =
      (const K1CRegisterInfo *)MF->getSubtarget().getRegisterInfo();

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
                                           const K1CInstrInfo *TII,
                                           MachineBasicBlock &MBB,
                                           MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  MachineFunction *MF = MBB.getParent();
  const K1CRegisterInfo *TRI =
      (const K1CRegisterInfo *)MF->getSubtarget().getRegisterInfo();

  unsigned outReg = MI.getOperand(0).getReg();
  unsigned v1Reg = MI.getOperand(1).getReg();
  unsigned v2Reg = MI.getOperand(2).getReg();
  int64_t rounding = MI.getOperand(3).getImm();

  BuildMI(MBB, MBBI, DL, TII->get(OpCode1), TRI->getSubReg(outReg, 1))
      .addReg(TRI->getSubReg(v1Reg, 1))
      .addReg(TRI->getSubReg(v2Reg, 1))
      .addImm(rounding)
      .addImm(0);
  BuildMI(MBB, MBBI, DL, TII->get(OpCode2), TRI->getSubReg(outReg, 2))
      .addReg(TRI->getSubReg(v1Reg, 2))
      .addReg(TRI->getSubReg(v2Reg, 2))
      .addImm(rounding)
      .addImm(0);

  MI.eraseFromParent();
  return true;
}

static bool expandFMULDCInstr(const K1CInstrInfo *TII, MachineBasicBlock &MBB,
                              MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  MachineFunction *MF = MBB.getParent();
  const K1CRegisterInfo *TRI =
      (const K1CRegisterInfo *)MF->getSubtarget().getRegisterInfo();

  unsigned outReg = MI.getOperand(0).getReg();
  unsigned v1Reg = MI.getOperand(1).getReg();
  unsigned v2Reg = MI.getOperand(2).getReg();
  int64_t rounding = MI.getOperand(3).getImm();

  BuildMI(MBB, MBBI, DL, TII->get(K1C::FMULDrr), TRI->getSubReg(outReg, 1))
      .addReg(TRI->getSubReg(v1Reg, 1))
      .addReg(TRI->getSubReg(v2Reg, 1))
      .addImm(rounding)
      .addImm(0);
  BuildMI(MBB, MBBI, DL, TII->get(K1C::FFMSDrr), TRI->getSubReg(outReg, 1))
      .addReg(TRI->getSubReg(outReg, 1))
      .addReg(TRI->getSubReg(v1Reg, 2))
      .addReg(TRI->getSubReg(v2Reg, 2))
      .addImm(rounding)
      .addImm(0);
  BuildMI(MBB, MBBI, DL, TII->get(K1C::FMULDrr), TRI->getSubReg(outReg, 2))
      .addReg(TRI->getSubReg(v1Reg, 1))
      .addReg(TRI->getSubReg(v2Reg, 2))
      .addImm(rounding)
      .addImm(0);
  BuildMI(MBB, MBBI, DL, TII->get(K1C::FFMADrr), TRI->getSubReg(outReg, 2))
      .addReg(TRI->getSubReg(outReg, 2))
      .addReg(TRI->getSubReg(v2Reg, 1))
      .addReg(TRI->getSubReg(v1Reg, 2))
      .addImm(rounding)
      .addImm(0);

  MI.eraseFromParent();
  return true;
}

static bool expandFMULCDCInstr(const K1CInstrInfo *TII, MachineBasicBlock &MBB,
                               MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  MachineFunction *MF = MBB.getParent();
  const K1CRegisterInfo *TRI =
      (const K1CRegisterInfo *)MF->getSubtarget().getRegisterInfo();

  unsigned outReg = MI.getOperand(0).getReg();
  unsigned Scratch = MI.getOperand(1).getReg();
  unsigned v1Reg = MI.getOperand(2).getReg();
  unsigned v2Reg = MI.getOperand(3).getReg();
  int64_t rounding = MI.getOperand(4).getImm();

  BuildMI(MBB, MBBI, DL, TII->get(K1C::FMULDrr), Scratch)
      .addReg(TRI->getSubReg(v1Reg, 1))
      .addReg(TRI->getSubReg(v2Reg, 1))
      .addImm(rounding)
      .addImm(0);
  BuildMI(MBB, MBBI, DL, TII->get(K1C::COPYD), TRI->getSubReg(outReg, 1))
      .addReg(TRI->getSubReg(v2Reg, 2));
  BuildMI(MBB, MBBI, DL, TII->get(K1C::FFMADrr), TRI->getSubReg(outReg, 1))
      .addReg(TRI->getSubReg(outReg, 1))
      .addReg(Scratch)
      .addReg(TRI->getSubReg(v1Reg, 2))
      .addImm(rounding)
      .addImm(0);
  BuildMI(MBB, MBBI, DL, TII->get(K1C::FMULDrr), Scratch)
      .addReg(TRI->getSubReg(v2Reg, 1))
      .addReg(TRI->getSubReg(v1Reg, 2))
      .addImm(rounding)
      .addImm(0);
  BuildMI(MBB, MBBI, DL, TII->get(K1C::COPYD), TRI->getSubReg(outReg, 2))
      .addReg(TRI->getSubReg(v2Reg, 2));
  BuildMI(MBB, MBBI, DL, TII->get(K1C::FFMSDrr), TRI->getSubReg(outReg, 2))
      .addReg(TRI->getSubReg(outReg, 2))
      .addReg(Scratch)
      .addReg(TRI->getSubReg(v1Reg, 1))
      .addImm(rounding)
      .addImm(0);

  MI.eraseFromParent();
  return true;
}

static bool
expandRoundingPairedRegInOutInstr(unsigned int OpCode, const K1CInstrInfo *TII,
                                  MachineBasicBlock &MBB,
                                  MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  MachineFunction *MF = MBB.getParent();
  const K1CRegisterInfo *TRI =
      (const K1CRegisterInfo *)MF->getSubtarget().getRegisterInfo();

  unsigned outReg = MI.getOperand(0).getReg();
  unsigned v1Reg = MI.getOperand(1).getReg();
  unsigned v2Reg = MI.getOperand(2).getReg();
  int64_t rounding = MI.getOperand(4).getImm();

  BuildMI(MBB, MBBI, DL, TII->get(OpCode), TRI->getSubReg(outReg, 1))
      .addReg(TRI->getSubReg(outReg, 1))
      .addReg(TRI->getSubReg(v1Reg, 1))
      .addReg(TRI->getSubReg(v2Reg, 1))
      .addImm(rounding)
      .addImm(0);

  BuildMI(MBB, MBBI, DL, TII->get(OpCode), TRI->getSubReg(outReg, 2))
      .addReg(TRI->getSubReg(outReg, 2))
      .addReg(TRI->getSubReg(v1Reg, 2))
      .addReg(TRI->getSubReg(v2Reg, 2))
      .addImm(rounding)
      .addImm(0);

  MI.eraseFromParent();
  return true;
}

static bool expandRoundingInOutInstr(unsigned int OpCode,
                                     const K1CInstrInfo *TII,
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
      .addImm(0);

  MI.eraseFromParent();
  return true;
}

static bool expandStore(const K1CInstrInfo *TII, MachineBasicBlock &MBB,
                        MachineBasicBlock::iterator MBBI) {

  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  int64_t offset = 0;
  unsigned offsetReg = 0;
  unsigned base = MI.getOperand(1).getReg();
  unsigned val = MI.getOperand(2).getReg();

  unsigned OpCode;

  bool AddrIsReg = MI.getOperand(0).isReg();
  bool AddrIsImm = MI.getOperand(0).isImm();

  if (AddrIsReg) {
    offsetReg = MI.getOperand(0).getReg();
  } else if (AddrIsImm) {
    offset = MI.getOperand(0).getImm();
  } else {
    llvm_unreachable("Operator type not handled");
  }

  switch (MBBI->getOpcode()) {
  case K1C::SBp:
    OpCode = AddrIsReg
                 ? K1C::SBrr
                 : GetImmOpCode(offset, K1C::SBri10, K1C::SBri37, K1C::SBri64);
    break;
  case K1C::SHp:
    OpCode = AddrIsReg
                 ? K1C::SHrr
                 : GetImmOpCode(offset, K1C::SHri10, K1C::SHri37, K1C::SHri64);
    break;
  case K1C::SWp:
    OpCode = AddrIsReg
                 ? K1C::SWrr
                 : GetImmOpCode(offset, K1C::SWri10, K1C::SWri37, K1C::SWri64);
    break;
  case K1C::SDp:
    OpCode = AddrIsReg
                 ? K1C::SDrr
                 : GetImmOpCode(offset, K1C::SDri10, K1C::SDri37, K1C::SDri64);
    break;
  case K1C::SQp:
    OpCode = AddrIsReg
                 ? K1C::SQrr
                 : GetImmOpCode(offset, K1C::SQri10, K1C::SQri37, K1C::SQri64);
    break;
  case K1C::SOp:
    OpCode = AddrIsReg
                 ? K1C::SOrr
                 : GetImmOpCode(offset, K1C::SOri10, K1C::SOri37, K1C::SOri64);
    break;
  }

  if (AddrIsReg) {
    BuildMI(MBB, MBBI, DL, TII->get(OpCode))
        .addReg(offsetReg)
        .addReg(base)
        .addReg(val)
        .addImm(0);
  } else {
    BuildMI(MBB, MBBI, DL, TII->get(OpCode))
        .addImm(offset)
        .addReg(base)
        .addReg(val);
  }

  MI.eraseFromParent();
  return true;
}

static bool expandLoad(const K1CInstrInfo *TII, MachineBasicBlock &MBB,
                       MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  int64_t offset = 0;
  unsigned offsetReg = 0;

  unsigned outputReg = MI.getOperand(0).getReg();
  unsigned base = MI.getOperand(2).getReg();
  int64_t variant = MI.getOperand(3).getImm();

  bool AddrIsReg = MI.getOperand(1).isReg();
  bool AddrIsImm = MI.getOperand(1).isImm();

  if (AddrIsReg) {
    offsetReg = MI.getOperand(1).getReg();
  } else if (AddrIsImm) {
    offset = MI.getOperand(1).getImm();
  } else {
    llvm_unreachable("Operator type not handled");
  }

  unsigned OpCode;
  switch (MBBI->getOpcode()) {
  case K1C::LBSp:
    OpCode = AddrIsReg ? K1C::LBSrr
                       : GetImmOpCode(offset, K1C::LBSri10, K1C::LBSri37,
                                      K1C::LBSri64);
    break;
  case K1C::LBZp:
    OpCode = AddrIsReg ? K1C::LBZrr
                       : GetImmOpCode(offset, K1C::LBZri10, K1C::LBZri37,
                                      K1C::LBZri64);
    break;
  case K1C::LHSp:
    OpCode = AddrIsReg ? K1C::LHSrr
                       : GetImmOpCode(offset, K1C::LHSri10, K1C::LHSri37,
                                      K1C::LHSri64);
    break;
  case K1C::LHZp:
    OpCode = AddrIsReg ? K1C::LHZrr
                       : GetImmOpCode(offset, K1C::LHZri10, K1C::LHZri37,
                                      K1C::LHZri64);
    break;
  case K1C::LWSp:
    OpCode = AddrIsReg ? K1C::LWSrr
                       : GetImmOpCode(offset, K1C::LWSri10, K1C::LWSri37,
                                      K1C::LWSri64);
    break;
  case K1C::LWZp:
    OpCode = AddrIsReg ? K1C::LWZrr
                       : GetImmOpCode(offset, K1C::LWZri10, K1C::LWZri37,
                                      K1C::LWZri64);
    break;
  case K1C::LDp:
    OpCode = AddrIsReg
                 ? K1C::LDrr
                 : GetImmOpCode(offset, K1C::LDri10, K1C::LDri37, K1C::LDri64);
    break;
  case K1C::LQp:
    OpCode = AddrIsReg
                 ? K1C::LQrr
                 : GetImmOpCode(offset, K1C::LQri10, K1C::LQri37, K1C::LQri64);
    break;
  case K1C::LOp:
    OpCode = AddrIsReg
                 ? K1C::LOrr
                 : GetImmOpCode(offset, K1C::LOri10, K1C::LOri37, K1C::LOri64);
    break;
  }
  if (AddrIsReg) {
    BuildMI(MBB, MBBI, DL, TII->get(OpCode), outputReg)
        .addReg(offsetReg)
        .addReg(base)
        .addImm(variant)
        .addImm(0);
  } else {
    BuildMI(MBB, MBBI, DL, TII->get(OpCode), outputReg)
        .addImm(offset)
        .addReg(base)
        .addImm(variant);
  }

  MI.eraseFromParent();
  return true;
}

bool K1CExpandPseudo::expandMI(MachineBasicBlock &MBB,
                               MachineBasicBlock::iterator MBBI,
                               MachineBasicBlock::iterator &NextMBBI) {
  switch (MBBI->getOpcode()) {
  case K1C::Select32p:
    expandSelectInstr(TII, MBB, MBBI, true);
    return true;
  case K1C::Select64p:
    expandSelectInstr(TII, MBB, MBBI, false);
    return true;
  case K1C::FENCE_Instr:
    expandFENCEInstr(TII, MBB, MBBI);
    return true;
  case K1C::ASWAP8_Instr:
    expandAtomicSwap8(TII, MBB, MBBI, NextMBBI);
    return true;
  case K1C::ASWAP32_Instr:
  case K1C::ASWAP64_Instr:
    expandASWAPInstr(MBBI->getOpcode(), TII, MBB, MBBI, NextMBBI);
    return true;
  case K1C::ACMPSWAP32_Instr:
  case K1C::ACMPSWAP64_Instr:
    expandACMPSWAPInstr(MBBI->getOpcode(), TII, MBB, MBBI, NextMBBI);
    return true;
  case K1C::ALOADADD32_Instr:
    expandALOADADD32Instr(TII, MBB, MBBI);
    return true;
  case K1C::ALOADADD64_Instr:
    expandALOADADD64Instr(TII, MBB, MBBI);
    return true;
  case K1C::ALOADSUB32_Instr:
  case K1C::ALOADSUB64_Instr:
  case K1C::ALOADAND32_Instr:
  case K1C::ALOADAND64_Instr:
  case K1C::ALOADXOR32_Instr:
  case K1C::ALOADXOR64_Instr:
  case K1C::ALOADOR32_Instr:
  case K1C::ALOADOR64_Instr:
  case K1C::ALOADNAND32_Instr:
  case K1C::ALOADNAND64_Instr:
    expandALOADOPInstr(MBBI->getOpcode(), TII, MBB, MBBI, NextMBBI);
    return true;
  case K1C::GET_Instr:
    expandGetInstr(TII, MBB, MBBI);
    return true;
  case K1C::WFXL_Instr:
    expandSystemRegValueInstr(K1C::WFXLrst4, TII, MBB, MBBI);
    return true;
  case K1C::WFXM_Instr:
    expandSystemRegValueInstr(K1C::WFXMrst4, TII, MBB, MBBI);
    return true;
  case K1C::SET_Instr:
    expandSystemRegValueInstr(K1C::SETrst4, TII, MBB, MBBI);
    return true;
  case K1C::SBMM8rr_Instr:
  case K1C::SBMM8ri_Instr:
    expandSBMM8Instr(TII, MBB, MBBI);
    return true;
  case K1C::FABSWQ_Instr:
    expandUnaryPairedRegInstrOpcode(K1C::FABSWP, TII, MBB, MBBI);
    return true;
  case K1C::FABSDP_Instr:
    expandUnaryPairedRegInstrOpcode(K1C::FABSD, TII, MBB, MBBI);
    return true;
  case K1C::FNEGWQ_Instr:
    expandUnaryPairedRegInstrOpcode(K1C::FNEGWP, TII, MBB, MBBI);
    return true;
  case K1C::FNEGDP_Instr:
    expandUnaryPairedRegInstrOpcode(K1C::FNEGD, TII, MBB, MBBI);
    return true;
  case K1C::FMAXWQ_Instr:
    expandBinaryPairedRegInstrOpcode(K1C::FMAXWP, TII, MBB, MBBI);
    return true;
  case K1C::FMAXDP_Instr:
    expandBinaryPairedRegInstrOpcode(K1C::FMAXD, TII, MBB, MBBI);
    return true;
  case K1C::FMINWQ_Instr:
    expandBinaryPairedRegInstrOpcode(K1C::FMINWP, TII, MBB, MBBI);
    return true;
  case K1C::FMINDP_Instr:
    expandBinaryPairedRegInstrOpcode(K1C::FMIND, TII, MBB, MBBI);
    return true;
  case K1C::FMULWCP_Instr:
    expandRoundingPairInstrOpcodes(K1C::FMULWCrr, K1C::FMULWCrr, TII, MBB,
                                   MBBI);
    return true;
  case K1C::FMULCWCP_Instr:
    expandRoundingPairInstrOpcodes(K1C::FMULCWCrr, K1C::FMULCWCrr, TII, MBB,
                                   MBBI);
    return true;
  case K1C::FMULDP_Instr:
    expandRoundingPairInstrOpcodes(K1C::FMULDrr, K1C::FMULDrr, TII, MBB, MBBI);
    return true;
  case K1C::FMULDC_Instr:
    expandFMULDCInstr(TII, MBB, MBBI);
    return true;
  case K1C::FMULCDC_Instr:
    expandFMULCDCInstr(TII, MBB, MBBI);
    return true;
  case K1C::FFMAWP_Instr:
    expandRoundingInOutInstr(K1C::FFMAWPrr, TII, MBB, MBBI);
    return true;
  case K1C::FFMAWQ_Instr:
    expandRoundingPairedRegInOutInstr(K1C::FFMAWPrr, TII, MBB, MBBI);
    return true;
  case K1C::FFMADP_Instr:
    expandRoundingPairedRegInOutInstr(K1C::FFMADrr, TII, MBB, MBBI);
    return true;
  case K1C::FMM2AWQ_Instr:
    expandRoundingInOutInstr(K1C::FMM2AWQ, TII, MBB, MBBI);
    return true;
  case K1C::FFMSWP_Instr:
    expandRoundingInOutInstr(K1C::FFMSWPrr, TII, MBB, MBBI);
    return true;
  case K1C::FFMSWQ_Instr:
    expandRoundingPairedRegInOutInstr(K1C::FFMSWPrr, TII, MBB, MBBI);
    return true;
  case K1C::FFMSDP_Instr:
    expandRoundingPairedRegInOutInstr(K1C::FFMSDrr, TII, MBB, MBBI);
    return true;
  case K1C::FMM2SWQ_Instr:
    expandRoundingInOutInstr(K1C::FMM2SWQ, TII, MBB, MBBI);
    return true;
  case K1C::SBp:
  case K1C::SHp:
  case K1C::SWp:
  case K1C::SDp:
  case K1C::SQp:
  case K1C::SOp:
    expandStore(TII, MBB, MBBI);
    return true;
  case K1C::LBSp:
  case K1C::LBZp:
  case K1C::LHSp:
  case K1C::LHZp:
  case K1C::LWSp:
  case K1C::LWZp:
  case K1C::LDp:
  case K1C::LQp:
  case K1C::LOp:
    expandLoad(TII, MBB, MBBI);
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
