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

    BuildMI(MBB, MBBI, DL, TII->get(K1C::CMOVEDd3))
        .addReg(ScratchReg)
        .addReg(CmpReg)
        .addReg(BranchValue)
        .addImm(Comp); /* DNEZ */
  } break;
  case MachineOperand::MO_Immediate: {
    int64_t BranchValueImm = MI.getOperand(Operand).getImm();

    BuildMI(MBB, MBBI, DL,
            TII->get(GetImmOpCode(BranchValueImm, K1C::CMOVEDd0, K1C::CMOVEDd1,
                                  K1C::CMOVEDd2)))
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
    return K1C::LWZri;
  case K1C::ASWAP64_Instr:
  case K1C::ACMPSWAP64_Instr:
  case K1C::ALOADADD64_Instr:
  case K1C::ALOADSUB64_Instr:
  case K1C::ALOADAND64_Instr:
  case K1C::ALOADXOR64_Instr:
  case K1C::ALOADOR64_Instr:
  case K1C::ALOADNAND64_Instr:
    return K1C::LDri;
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

unsigned int getAtomicSwap(unsigned int opCode) {
  switch (opCode) {
  case K1C::ASWAP32_Instr:
  case K1C::ACMPSWAP32_Instr:
  case K1C::ALOADADD32_Instr:
  case K1C::ALOADSUB32_Instr:
  case K1C::ALOADAND32_Instr:
  case K1C::ALOADXOR32_Instr:
  case K1C::ALOADOR32_Instr:
  case K1C::ALOADNAND32_Instr:
    return K1C::ACSWAPWd1;
  case K1C::ASWAP64_Instr:
  case K1C::ACMPSWAP64_Instr:
  case K1C::ALOADADD64_Instr:
  case K1C::ALOADSUB64_Instr:
  case K1C::ALOADAND64_Instr:
  case K1C::ALOADXOR64_Instr:
  case K1C::ALOADOR64_Instr:
  case K1C::ALOADNAND64_Instr:
    return K1C::ACSWAPDd1;
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
    return K1C::COMPWd1;
  case K1C::ASWAP64_Instr:
  case K1C::ACMPSWAP64_Instr:
  case K1C::ALOADADD64_Instr:
  case K1C::ALOADSUB64_Instr:
  case K1C::ALOADAND64_Instr:
  case K1C::ALOADXOR64_Instr:
  case K1C::ALOADOR64_Instr:
  case K1C::ALOADNAND64_Instr:
    return K1C::COMPDd1;
  default:
    llvm_unreachable("invalid opCode");
  }
}

unsigned int getAtomicOp(unsigned int opCode) {
  switch (opCode) {
  case K1C::ALOADADD32_Instr:
    return K1C::ADDWd0;
  case K1C::ALOADADD64_Instr:
    return K1C::ADDDd0;
  case K1C::ALOADSUB32_Instr:
    return K1C::SBFWd0;
  case K1C::ALOADSUB64_Instr:
    return K1C::SBFDd0;
  case K1C::ALOADAND32_Instr:
  case K1C::ALOADNAND32_Instr:
    return K1C::ANDWd0;
  case K1C::ALOADAND64_Instr:
  case K1C::ALOADNAND64_Instr:
    return K1C::ANDDd0;
  case K1C::ALOADXOR32_Instr:
    return K1C::XORWd0;
  case K1C::ALOADXOR64_Instr:
    return K1C::XORDd0;
  case K1C::ALOADOR32_Instr:
    return K1C::ORWd0;
  case K1C::ALOADOR64_Instr:
    return K1C::ORDd0;
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
    return K1C::COMPWd0;
  case K1C::ASWAP64_Instr:
  case K1C::ACMPSWAP64_Instr:
    return K1C::COMPDd0;
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
        TII->get(GetImmOpCode(offset, K1C::ADDDd1, K1C::ADDDd2, K1C::ADDDd3)),
        scratchBase)
        .addReg(baseReg)
        .addImm(offset);
    BuildMI(MBB, MBBI, DL, TII->get(K1C::ANDDd1),
            TRI->getSubReg(scratchPairedReg, 2))
        .addReg(scratchBase)
        .addImm(3);
  } else {
    BuildMI(MBB, MBBI, DL, TII->get(K1C::ANDDd1),
            TRI->getSubReg(scratchPairedReg, 2))
        .addReg(baseReg)
        .addImm(3);
  }
  BuildMI(MBB, MBBI, DL, TII->get(K1C::NOTW),
          TRI->getSubReg(scratchPairedReg, 1))
      .addReg(TRI->getSubReg(scratchPairedReg, 2));
  BuildMI(MBB, MBBI, DL, TII->get(K1C::ANDDd0), scratchBase)
      .addReg(offset == 0 ? baseReg : scratchBase)
      .addReg(TRI->getSubReg(scratchPairedReg, 1));
  BuildMI(MBB, MBBI, DL, TII->get(K1C::MULDd1), shiftCount)
      .addReg(TRI->getSubReg(scratchPairedReg, 2))
      .addImm(8);

  BuildMI(MBB, MBBI, DL, TII->get(K1C::SLLWd0), scratchVal)
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

  BuildMI(DoneMBB, DL, TII->get(K1C::SRLWd0), outputReg)
      .addReg(outputReg)
      .addReg(shiftCount);

  BuildMI(DoneMBB, DL, TII->get(K1C::FENCE));

  DoneMBB->splice(DoneMBB->end(), &MBB, MI, MBB.end());
  DoneMBB->transferSuccessors(&MBB);
  MBB.addSuccessor(LoopMBB);
  MBB.addSuccessor(DoneMBB);

  BuildMI(LoopMBB, DL, TII->get(K1C::LWZri),
          TRI->getSubReg(scratchPairedReg, 2))
      .addImm(0)
      .addReg(scratchBase)
      .addImm(2 /*uncached*/);

  BuildMI(LoopMBB, DL, TII->get(K1C::COPYW), compReg)
      .addReg(TRI->getSubReg(scratchPairedReg, 2));

  BuildMI(LoopMBB, DL, TII->get(K1C::ORWd0), compReg)
      .addReg(compReg)
      .addReg(scratchVal);

  BuildMI(LoopMBB, DL, TII->get(K1C::ACSWAPWd1), compReg)
      .addImm(0)
      .addReg(scratchBase)
      .addReg(scratchPairedReg);

  BuildMI(LoopMBB, DL, TII->get(K1C::COMPWd1), compReg)
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
  unsigned offset = MI.getOperand(2).getImm();
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

  BuildMI(LoopMBB, DL, TII->get(getAtomicSwap(opCode)), compReg)
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
          TII->get(GetImmOpCode(offset, K1C::AFADDWd0, K1C::AFADDWd1,
                                K1C::AFADDWd2)),
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
          TII->get(GetImmOpCode(offset, K1C::AFADDDd0, K1C::AFADDDd1,
                                K1C::AFADDDd2)),
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
  unsigned offset = MI.getOperand(2).getImm();
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

  BuildMI(LoopMBB, DL, TII->get(getAtomicSwap(opCode)), compReg)
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

  unsigned offset = MI.getOperand(2).getImm();  // addr
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

  BuildMI(LoopMBB, DL, TII->get(getAtomicSwap(opCode)), compReg)
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

  BuildMI(MBB, MBBI, DL, TII->get(K1C::GET), DestReg)
      .addReg(K1C::SystemRegRegClass.getRegister(regNo));

  MI.eraseFromParent();
  return true;
}

static bool expandWFXLInstr(const K1CInstrInfo *TII, MachineBasicBlock &MBB,
                            MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  unsigned int sysReg =
      K1C::SystemRegRegClass.getRegister(MI.getOperand(0).getImm());
  unsigned valReg = MI.getOperand(1).getReg();

  BuildMI(MBB, MBBI, DL, TII->get(K1C::WFXLd0), sysReg).addReg(valReg);

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

    BuildMI(MBB, MBBI, DL, TII->get(K1C::SBMM8d0), outReg)
        .addReg(inReg)
        .addReg(valReg);
  } else {
    int64_t imm = MI.getOperand(2).getImm();

    BuildMI(
        MBB, MBBI, DL,
        TII->get(GetImmOpCode(imm, K1C::SBMM8d1, K1C::SBMM8d2, K1C::SBMM8d3)),
        outReg)
        .addReg(inReg)
        .addImm(imm);
  }

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
    expandWFXLInstr(TII, MBB, MBBI);
    return true;
  case K1C::SBMM8rr_Instr:
  case K1C::SBMM8ri_Instr:
    expandSBMM8Instr(TII, MBB, MBBI);
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
