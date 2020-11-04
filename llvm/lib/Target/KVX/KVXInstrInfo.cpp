//===- KVXInstrInfo.h - KVX Instruction Information -------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the KVX implementation of the TargetInstrInfo class.
//
//===----------------------------------------------------------------------===//

#include "KVXInstrInfo.h"
#include "KVX.h"
#include "KVXTargetMachine.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/RegisterScavenging.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;
#define DEBUG_TYPE "KVX-isel"

#define GET_INSTRINFO_CTOR_DTOR
#include "KVXGenDFAPacketizer.inc"
#include "KVXGenInstrInfo.inc"

KVXInstrInfo::KVXInstrInfo()
    : KVXGenInstrInfo(KVX::ADJCALLSTACKDOWN, KVX::ADJCALLSTACKUP) {}

void KVXInstrInfo::copyPhysReg(MachineBasicBlock &MBB,
                               MachineBasicBlock::iterator MBBI,
                               const DebugLoc &DL, MCRegister DstReg,
                               MCRegister SrcReg, bool KillSrc) const {
  MachineFunction *MF = MBB.getParent();
  const KVXRegisterInfo *TRI =
      (const KVXRegisterInfo *)MF->getSubtarget().getRegisterInfo();

  LLVM_DEBUG(dbgs() << "Copy register (" + TRI->getRegAsmName(SrcReg.id()) +
                           ") to (" + TRI->getRegAsmName(DstReg.id()) + ").\n");

  // GPR to GPR
  if (KVX::QuadRegRegClass.contains(DstReg, SrcReg)) {
    LLVM_DEBUG(dbgs() << "It is a QuadReg copyo.\n");
    BuildMI(MBB, MBBI, DL, get(KVX::COPYO), DstReg)
        .addReg(SrcReg, getKillRegState(KillSrc));
    return;
  }
  if (KVX::PairedRegRegClass.contains(DstReg, SrcReg)) {
    LLVM_DEBUG(dbgs() << "It is a PairedReg copyq.\n");
    BuildMI(MBB, MBBI, DL, get(KVX::COPYQ), DstReg)
        .addReg(TRI->getSubReg(SrcReg, KVX::sub_s0), getKillRegState(KillSrc))
        .addReg(TRI->getSubReg(SrcReg, KVX::sub_s1), getKillRegState(KillSrc));
    return;
  }
  if (KVX::SingleRegRegClass.contains(DstReg, SrcReg)) {
    LLVM_DEBUG(dbgs() << "It is a SingleReg copyd.\n");
    BuildMI(MBB, MBBI, DL, get(KVX::COPYD), DstReg)
        .addReg(SrcReg, getKillRegState(KillSrc));
    return;
  }
  // TCA registers to GPR
  if (KVX::QuadRegRegClass.contains(DstReg)) {
    if (KVX::VectorRegERegClass.contains(SrcReg)) {
      LLVM_DEBUG(dbgs() << "It is a TCA VectorRegE to GPR QuadReg movefore.\n");
      BuildMI(MBB, MBBI, DL, get(KVX::MOVEFOre), DstReg)
          .addReg(SrcReg, getKillRegState(KillSrc));
      return;
    }
    if (KVX::VectorRegORegClass.contains(SrcReg)) {
      LLVM_DEBUG(dbgs() << "It is a TCA VectorRegE to GPR QuadReg moveforo.\n");
      BuildMI(MBB, MBBI, DL, get(KVX::MOVEFOro), DstReg)
          .addReg(SrcReg, getKillRegState(KillSrc));
      return;
    }
  }

  // GPR registers to TCA
  if (KVX::PairedRegRegClass.contains(SrcReg)) {
    if (KVX::BlockRegERegClass.contains(DstReg)) {
      LLVM_DEBUG(
          dbgs() << "It is a GPR PairedReg to TCA BlockRegE movetqrrbe.\n");
      BuildMI(MBB, MBBI, DL, get(KVX::MOVETQrrbe), DstReg)
          .addReg(TRI->getSubReg(SrcReg, KVX::sub_s0), getKillRegState(KillSrc))
          .addReg(TRI->getSubReg(SrcReg, KVX::sub_s1),
                  getKillRegState(KillSrc));

      return;
    }
    if (KVX::BlockRegORegClass.contains(SrcReg)) {
      LLVM_DEBUG(
          dbgs() << "It is a GPR PairedReg to TCA BlockRegO movetqrrbo.\n");
      BuildMI(MBB, MBBI, DL, get(KVX::MOVETQrrbo), DstReg)
          .addReg(TRI->getSubReg(SrcReg, KVX::sub_s0), getKillRegState(KillSrc))
          .addReg(TRI->getSubReg(SrcReg, KVX::sub_s1),
                  getKillRegState(KillSrc));
      return;
    }
  }
  if (KVX::QuadRegRegClass.contains(SrcReg) &&
      KVX::VectorRegRegClass.contains(DstReg)) {
    // There is no straight way to copy 256 bits from GPR to TCAR
    // However, we can easely break the QuadReg in 4
    // The tricky part is to break the VectorReg in 2 BlockReg
    LLVM_DEBUG(
        dbgs() << "It is a GPR QuadReg to TCA VectorReg, it requires two "
                  "instructions, a movetqrrbo and a movetqrrbe.\n");

    MCRegister SubReg1 = TRI->getSubReg(DstReg, KVX::sub_b0);
    MCRegister SubReg2 = TRI->getSubReg(DstReg, KVX::sub_b1);

    if (!KVX::BlockRegRegClass.contains(SubReg1, SubReg2))
      report_fatal_error("One of these are not a BlockReg: (" +
                         TRI->getRegAsmName(SubReg1.id()) + ", " +
                         TRI->getRegAsmName(SubReg2.id()) + ").\n");
    BuildMI(MBB, MBBI, DL, get(KVX::MOVETQrrbe), SubReg1)
        .addReg(TRI->getSubReg(SrcReg, KVX::sub_s0), getKillRegState(KillSrc))
        .addReg(TRI->getSubReg(SrcReg, KVX::sub_s1), getKillRegState(KillSrc));
    BuildMI(MBB, MBBI, DL, get(KVX::MOVETQrrbo), SubReg2)
        .addReg(TRI->getSubReg(SrcReg, KVX::sub_s2), getKillRegState(KillSrc))
        .addReg(TRI->getSubReg(SrcReg, KVX::sub_s3), getKillRegState(KillSrc));

    return;
  }

  // Between TCA registers
  if (KVX::VectorRegRegClass.contains(DstReg)) {
    if (KVX::VectorRegERegClass.contains(SrcReg)) {
      LLVM_DEBUG(dbgs() << "It is a TCA VectorRegE copyvre.\n");
      BuildMI(MBB, MBBI, DL, get(KVX::COPYVre), DstReg)
          .addReg(SrcReg, getKillRegState(KillSrc));
      return;
    }
    if (KVX::VectorRegORegClass.contains(SrcReg)) {
      LLVM_DEBUG(dbgs() << "It is a TCA VectorRegO copyvro.\n");
      BuildMI(MBB, MBBI, DL, get(KVX::COPYVro), DstReg)
          .addReg(SrcReg, getKillRegState(KillSrc));
      return;
    }
  }

  report_fatal_error("Don't know how to handle register copy from (" +
                     TRI->getRegAsmName(SrcReg.id()) + ") to (" +
                     TRI->getRegAsmName(DstReg.id()) + ").\n");
}

Register findScratchRegister(MachineBasicBlock &MBB, bool UseAtEnd,
                             Register Scratch = KVX::R4) {
  RegScavenger RS;

  if (UseAtEnd)
    RS.enterBasicBlockEnd(MBB);
  else
    RS.enterBasicBlock(MBB);

  // Get the list of callee-saved registers for the target.
  MachineFunction *MF = MBB.getParent();
  const KVXSubtarget &Subtarget = MF->getSubtarget<KVXSubtarget>();
  const KVXRegisterInfo &RegInfo = *Subtarget.getRegisterInfo();
  const MCPhysReg *CSRegs = RegInfo.getCalleeSavedRegs(MBB.getParent());

  // We shouldn't use return registers as scratch register as they appear killed
  RS.setRegUsed(KVX::R0);
  RS.setRegUsed(KVX::R1);
  RS.setRegUsed(KVX::R2);
  RS.setRegUsed(KVX::R3);

  // We shouldn't use callee-saved registers as scratch registers as they may be
  // available when looking for a candidate block for shrink wrapping but not
  // available when the actual prologue/epilogue is being emitted because they
  // were added as live-in to the prologue block by PrologueEpilogueInserter.
  for (int i = 0; CSRegs[i]; ++i)
    RS.setRegUsed(CSRegs[i]);

  if (RS.isRegUsed(Scratch)) {
    Scratch = RS.FindUnusedReg(&KVX::SingleRegRegClass);
    // TODO: Shouldn't be a fatal error. Should be handled by the caller.
    if (Scratch == 0)
      report_fatal_error("Unable to find a scratch register");
  }

  return Scratch;
}

void KVXInstrInfo::loadRegFromStackSlot(MachineBasicBlock &MBB,
                                        MachineBasicBlock::iterator I,
                                        unsigned DstReg, int FI,
                                        const TargetRegisterClass *RC,
                                        const TargetRegisterInfo *TRI) const {
  LLVM_DEBUG(dbgs() << "Loading from stack to register (" << DstReg << ").\n");
  DebugLoc DL;
  if (I != MBB.end())
    DL = I->getDebugLoc();

  int Pseudo = 0;
  if (KVX::SingleRegRegClass.hasSubClassEq(RC)) {
    LLVM_DEBUG(dbgs() << "It is a single GPR, loading using LDp.\n");
    Pseudo = KVX::LDp;
  } else if (KVX::PairedRegRegClass.hasSubClassEq(RC)) {
    LLVM_DEBUG(dbgs() << "It is a paired GPR, loading using LQp.\n");
    Pseudo = KVX::LQp;
  } else if (KVX::QuadRegRegClass.hasSubClassEq(RC)) {
    LLVM_DEBUG(dbgs() << "It is a quad GPR, loading using LOp.\n");
    Pseudo = KVX::LOp;
  } else if (KVX::BlockRegRegClass.hasSubClassEq(RC)) {
    report_fatal_error(
        "Do not know how to load TCA sub-register from the stack.");
  } else if (KVX::VectorRegRegClass.hasSubClassEq(RC)) {
    LLVM_DEBUG(dbgs() << "It is a vector TCA register, loading using LVp.\n");
    Pseudo = KVX::LVp;
  } else if (KVX::WideRegRegClass.hasSubClassEq(RC)) {
    LLVM_DEBUG(dbgs() << "It is a wide TCA register, loading using LWIDEp.\n");
    Pseudo = KVX::LWIDEp;
  } else if (KVX::MatrixRegRegClass.hasSubClassEq(RC)) {
    Pseudo = KVX::LMATRIXp;
    LLVM_DEBUG(
        dbgs() << "It is a matrix TCA register, loading using LMATRIXp.\n");
  } else if (KVX::OnlyraRegRegClass.hasSubClassEq(RC)) {
    LLVM_DEBUG(dbgs() << "It is a RA register, using LDp and SETrsta.\n");
    Register ScratchReg = findScratchRegister(MBB, true, KVX::R16);
    BuildMI(MBB, I, DL, get(KVX::LDp), ScratchReg)
        .addImm(0)
        .addFrameIndex(FI)
        .addImm(KVXMOD::VARIANT_);
    BuildMI(MBB, I, DL, get(KVX::SETrsra), KVX::RA)
        .addReg(ScratchReg, RegState::Kill);
    return;
  } else
    report_fatal_error("Don't know how to load register from the stack.");

  BuildMI(MBB, I, DL, get(Pseudo), DstReg)
      .addImm(0)
      .addFrameIndex(FI)
      .addImm(KVXMOD::VARIANT_);
  return;
}

void KVXInstrInfo::storeRegToStackSlot(MachineBasicBlock &MBB,
                                       MachineBasicBlock::iterator I,
                                       unsigned SrcReg, bool IsKill, int FI,
                                       const TargetRegisterClass *RC,
                                       const TargetRegisterInfo *TRI) const {
  LLVM_DEBUG(dbgs() << "Storing register (" << SrcReg << ") to the stack.\n");

  DebugLoc DL;
  if (I != MBB.end())
    DL = I->getDebugLoc();
  int Pseudo = 0;
  if (KVX::SingleRegRegClass.hasSubClassEq(RC)) {
    LLVM_DEBUG(dbgs() << "It is a single GPR, storing using SDp.\n");
    Pseudo = KVX::SDp;
  } else if (KVX::PairedRegRegClass.hasSubClassEq(RC)) {
    LLVM_DEBUG(dbgs() << "It is a paired GPR, storing using SQp.\n");
    Pseudo = KVX::SQp;
  } else if (KVX::QuadRegRegClass.hasSubClassEq(RC)) {
    LLVM_DEBUG(dbgs() << "It is a quad GPR, storing using SOp.\n");
    Pseudo = KVX::SOp;
  } else if (KVX::BlockRegRegClass.hasSubClassEq(RC)) {
    report_fatal_error(
        "Do not know how to store TCA sub-register to the stack.");
  } else if (KVX::VectorRegRegClass.hasSubClassEq(RC)) {
    LLVM_DEBUG(dbgs() << "It is a vector TCA register, storing using SVp.\n");
    Pseudo = KVX::SVp;
  } else if (KVX::WideRegRegClass.hasSubClassEq(RC)) {
    LLVM_DEBUG(
        dbgs() << "It is a vector TCA register, storing using SWIDEp.\n");
    Pseudo = KVX::SWIDEp;
  } else if (KVX::MatrixRegRegClass.hasSubClassEq(RC)) {
    Pseudo = KVX::SMATRIXp;
    LLVM_DEBUG(
        dbgs() << "It is a vector TCA register, storing using SMATRIXp.\n");
  } else if (KVX::OnlyraRegRegClass.hasSubClassEq(RC)) {
    LLVM_DEBUG(dbgs() << "It is a RA register, using GETss2 and SDp.\n");
    Register ScratchReg = findScratchRegister(MBB, false, KVX::R16);
    BuildMI(MBB, I, DL, get(KVX::GETss2), ScratchReg)
        .addReg(KVX::RA)
        .setMIFlags(MachineInstr::FrameSetup);

    BuildMI(MBB, I, DL, get(KVX::SDp))
        .addImm(0)
        .addFrameIndex(FI)
        .addReg(ScratchReg, RegState::Kill);
    return;
  } else
    report_fatal_error("Don't know how to store register to the stack.");

  BuildMI(MBB, I, DL, get(Pseudo))
      .addImm(0)
      .addFrameIndex(FI)
      .addReg(SrcReg, getKillRegState(IsKill))
      .setMIFlags(MachineInstr::FrameSetup);
}

DFAPacketizer *
KVXInstrInfo::CreateTargetScheduleState(const TargetSubtargetInfo &STI) const {
  const InstrItineraryData *II = STI.getInstrItineraryData();
  return static_cast<const KVXSubtarget &>(STI).createDFAPacketizer(II);
}

static void parseCondBranch(MachineInstr &LastInst, MachineBasicBlock *&Target,
                            SmallVectorImpl<MachineOperand> &Cond) {
  // Block ends with fall-through condbranch.
  assert(LastInst.getDesc().isConditionalBranch() &&
         "Unknown conditional branch");
  Target = LastInst.getOperand(1).getMBB();
  Cond.push_back(MachineOperand::CreateImm(LastInst.getOpcode()));
  Cond.push_back(LastInst.getOperand(0));
  Cond.push_back(LastInst.getOperand(2));
}

static unsigned getOppositeBranchOpcode(int Opc) {
  switch (Opc) {
  case KVXMOD::SCALARCOND_DNEZ:
    return KVXMOD::SCALARCOND_DEQZ;
  case KVXMOD::SCALARCOND_DEQZ:
    return KVXMOD::SCALARCOND_DNEZ;
  case KVXMOD::SCALARCOND_DLTZ:
    return KVXMOD::SCALARCOND_DGEZ;
  case KVXMOD::SCALARCOND_DGEZ:
    return KVXMOD::SCALARCOND_DLTZ;
  case KVXMOD::SCALARCOND_DLEZ:
    return KVXMOD::SCALARCOND_DGTZ;
  case KVXMOD::SCALARCOND_DGTZ:
    return KVXMOD::SCALARCOND_DLEZ;
  case KVXMOD::SCALARCOND_ODD:
    return KVXMOD::SCALARCOND_EVEN;
  case KVXMOD::SCALARCOND_EVEN:
    return KVXMOD::SCALARCOND_ODD;
  case KVXMOD::SCALARCOND_WNEZ:
    return KVXMOD::SCALARCOND_WEQZ;
  case KVXMOD::SCALARCOND_WEQZ:
    return KVXMOD::SCALARCOND_WNEZ;
  case KVXMOD::SCALARCOND_WLTZ:
    return KVXMOD::SCALARCOND_WGEZ;
  case KVXMOD::SCALARCOND_WGEZ:
    return KVXMOD::SCALARCOND_WLTZ;
  case KVXMOD::SCALARCOND_WLEZ:
    return KVXMOD::SCALARCOND_WGTZ;
  case KVXMOD::SCALARCOND_WGTZ:
    return KVXMOD::SCALARCOND_WLEZ;
  }
  llvm_unreachable("invalid branch opcode condition");
}

bool KVXInstrInfo::analyzeBranch(MachineBasicBlock &MBB,
                                 MachineBasicBlock *&TBB,
                                 MachineBasicBlock *&FBB,
                                 SmallVectorImpl<MachineOperand> &Cond,
                                 bool AllowModify) const {

  TBB = FBB = nullptr;
  Cond.clear();

  // If the block has no terminators, it just falls into the block after it.
  MachineBasicBlock::iterator I = MBB.getLastNonDebugInstr();
  if (I == MBB.end() || !isUnpredicatedTerminator(*I))
    return false;

  // Count the number of terminators and find the first unconditional or
  // indirect branch.
  MachineBasicBlock::iterator FirstUncondOrIndirectBr = MBB.end();
  int NumTerminators = 0;
  for (auto J = I.getReverse(); J != MBB.rend() && isUnpredicatedTerminator(*J);
       J++) {
    NumTerminators++;
    if (J->getDesc().isUnconditionalBranch() ||
        J->getDesc().isIndirectBranch()) {
      FirstUncondOrIndirectBr = J.getReverse();
    }
  }

  // If AllowModify is true, we can erase any terminators after
  // FirstUncondOrIndirectBR.
  if (AllowModify && FirstUncondOrIndirectBr != MBB.end()) {
    while (std::next(FirstUncondOrIndirectBr) != MBB.end()) {
      std::next(FirstUncondOrIndirectBr)->eraseFromParent();
      NumTerminators--;
    }
    I = FirstUncondOrIndirectBr;
  }

  // We can't handle blocks that end in an indirect branch.
  if (I->getDesc().isIndirectBranch())
    return true;

  // We can't handle blocks with more than 2 terminators.
  if (NumTerminators > 2)
    return true;

  // Handle a single unconditional branch.
  if (NumTerminators == 1 && I->getDesc().isUnconditionalBranch()) {
    if (I->getOpcode() == KVX::TAIL) {
      TBB = &MBB; // not used
      Cond.push_back(I->getOperand(0));
      return false;
    }
    TBB = I->getOperand(0).getMBB();
    return false;
  }

  // Handle a single conditional branch.
  if (NumTerminators == 1 && I->getDesc().isConditionalBranch()) {

    parseCondBranch(*I, TBB, Cond);
    return false;
  }

  // Handle a conditional branch followed by an unconditional branch.
  if (NumTerminators == 2 && std::prev(I)->getDesc().isConditionalBranch() &&
      I->getDesc().isUnconditionalBranch() && I->getOpcode() == KVX::GOTO) {
    parseCondBranch(*std::prev(I), TBB, Cond);
    FBB = I->getOperand(0).getMBB();
    // fix for hardware loops to pin ExitMBB (not optimize it)
    if (I->getParent()->hasAddressTaken()) {
      I->getParent()->removeSuccessor(FBB);
      I->getParent()->addSuccessor(FBB, BranchProbability::getOne());
    }
    return false;
  }

  // Otherwise, we can't handle this.
  return true;
}

unsigned KVXInstrInfo::insertBranch(MachineBasicBlock &MBB,
                                    MachineBasicBlock *TBB,
                                    MachineBasicBlock *FBB,
                                    ArrayRef<MachineOperand> Cond,
                                    const DebugLoc &DL, int *BytesAdded) const {
  if (BytesAdded)
    *BytesAdded = 0;

  // Shouldn't be a fall through.
  assert(TBB && "InsertBranch must not be told to insert a fallthrough");
  assert((Cond.size() == 3 || Cond.size() == 0 || Cond.size() == 1) &&
         "KVX branch conditions have two components!");

  // Unconditional branch / GOTO.
  if (Cond.empty()) {
    MachineInstr &MI = *BuildMI(&MBB, DL, get(KVX::GOTO)).addMBB(TBB);
    if (BytesAdded)
      *BytesAdded += MI.getDesc().Size;
    return 1;
  }

  // Unconditional branch / TAIL.
  if (Cond.size() == 1) {
    MachineInstr &MI = *BuildMI(&MBB, DL, get(KVX::TAIL))
                            .addGlobalAddress(Cond[0].getGlobal());
    if (BytesAdded)
      *BytesAdded += MI.getDesc().Size;
    return 1;
  }

  // Either a one or two-way conditional branch.
  unsigned Opc = Cond[0].getImm();
  MachineInstr &CondMI =
      *BuildMI(&MBB, DL, get(Opc)).add(Cond[1]).addMBB(TBB).add(Cond[2]);
  if (BytesAdded)
    *BytesAdded += CondMI.getDesc().Size;

  // One-way conditional branch.
  if (!FBB)
    return 1;

  // Two-way conditional branch.
  MachineInstr &MI = *BuildMI(&MBB, DL, get(KVX::GOTO)).addMBB(FBB);
  if (BytesAdded)
    *BytesAdded += MI.getDesc().Size;
  return 2;
}

unsigned KVXInstrInfo::removeBranch(MachineBasicBlock &MBB,
                                    int *BytesRemoved) const {
  if (BytesRemoved)
    *BytesRemoved = 0;

  MachineBasicBlock::iterator I = MBB.getLastNonDebugInstr();
  if (I == MBB.end())
    return 0;

  if (!I->getDesc().isUnconditionalBranch() &&
      !I->getDesc().isConditionalBranch())
    return 0;
  // Remove the branch.
  I->eraseFromParent();

  I = MBB.end();

  if (I == MBB.begin())
    return 1;
  --I;
  if (!I->getDesc().isConditionalBranch())
    return 1;

  // Remove the branch.
  if (BytesRemoved)
    *BytesRemoved += I->getDesc().Size;
  I->eraseFromParent();
  return 2;
}

bool KVXInstrInfo::reverseBranchCondition(
    SmallVectorImpl<MachineOperand> &Cond) const {
  assert((Cond.size() == 3) && "Invalid branch condition!");
  Cond[2].setImm(getOppositeBranchOpcode(Cond[2].getImm()));
  return false;
}
