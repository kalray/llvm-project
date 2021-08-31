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
#include "llvm/MC/MCDwarf.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;
#define DEBUG_TYPE "KVX-isel"

#define GET_INSTRINFO_CTOR_DTOR
#include "KVXGenDFAPacketizer.inc"
#include "KVXGenInstrInfo.inc"

KVXInstrInfo::KVXInstrInfo(KVXSubtarget &ST)
    : KVXGenInstrInfo(KVX::ADJCALLSTACKDOWN, KVX::ADJCALLSTACKUP),
      Subtarget(ST) {}

void KVXInstrInfo::copyPhysReg(MachineBasicBlock &MBB,
                               MachineBasicBlock::iterator MBBI,
                               const DebugLoc &DL, MCRegister DstReg,
                               MCRegister SrcReg, bool KillSrc) const {

  const KVXRegisterInfo *TRI = Subtarget.getRegisterInfo();

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

  if (KVX::SingleRegRegClass.contains(DstReg) &&
      KVX::OnlygetRegRegClass.contains(SrcReg)) {
    LLVM_DEBUG(dbgs() << "It is a GETss2.\n");
    BuildMI(MBB, MBBI, DL, get(KVX::GETss2), DstReg).addReg(SrcReg);
    return;
  }
  if (KVX::SingleRegRegClass.contains(DstReg) &&
      KVX::SystemRegRegClass.contains(SrcReg)) {
    LLVM_DEBUG(dbgs() << "It is a GETss3.\n");
    BuildMI(MBB, MBBI, DL, get(KVX::GETss3), DstReg).addReg(SrcReg);
    return;
  }

  // Between TCA registers
  if (KVX::VectorRegRegClass.contains(DstReg)) {
    if (KVX::VectorRegERegClass.contains(SrcReg) ||
        KVX::ZeroVectorRegERegClass.contains(SrcReg)) {
      LLVM_DEBUG(dbgs() << "It is a TCA VectorRegE copyvre.\n");
      BuildMI(MBB, MBBI, DL, get(KVX::COPYVre), DstReg)
          .addReg(SrcReg, getKillRegState(KillSrc));
      return;
    }
    if (KVX::VectorRegORegClass.contains(SrcReg) ||
        KVX::ZeroVectorRegORegClass.contains(SrcReg)) {
      LLVM_DEBUG(dbgs() << "It is a TCA VectorRegO copyvro.\n");
      BuildMI(MBB, MBBI, DL, get(KVX::COPYVro), DstReg)
          .addReg(SrcReg, getKillRegState(KillSrc));
      return;
    }
  }

  if (KVX::WideRegRegClass.contains(DstReg) &&
      (KVX::WideRegRegClass.contains(SrcReg) ||
       KVX::ZeroWideRegRegClass.contains(SrcReg))) {
    LLVM_DEBUG(dbgs() << "It is a TCA WideReg, use 2x copyv.\n");

    auto Src = TRI->getSubReg(SrcReg, KVX::sub_v0);
    auto Dst = TRI->getSubReg(DstReg, KVX::sub_v0);
    BuildMI(MBB, MBBI, DL, get(KVX::COPYVre), Dst)
        .addReg(Src, getKillRegState(KillSrc));
    Src = TRI->getSubReg(SrcReg, KVX::sub_v1);
    Dst = TRI->getSubReg(DstReg, KVX::sub_v1);
    BuildMI(MBB, MBBI, DL, get(KVX::COPYVro), Dst)
        .addReg(Src, getKillRegState(KillSrc));
    return;
  }

  if (KVX::MatrixRegRegClass.contains(DstReg) &&
      (KVX::MatrixRegRegClass.contains(SrcReg) ||
       KVX::ZeroMatrixRegRegClass.contains(SrcReg))) {
    LLVM_DEBUG(dbgs() << "It is a TCA MatrixReg, use 4x copyv.\n");
    auto VecType = KVX::COPYVre;
    for (auto SubVec : {KVX::sub_v0, KVX::sub_v1, KVX::sub_v2, KVX::sub_v3}) {
      auto Src = TRI->getSubReg(SrcReg, SubVec);
      auto Dst = TRI->getSubReg(DstReg, SubVec);
      BuildMI(MBB, MBBI, DL, get(VecType), Dst)
          .addReg(Src, getKillRegState(KillSrc));
      VecType = VecType == KVX::COPYVre ? KVX::COPYVro : KVX::COPYVre;
    }
    return;
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
                                        Register DstReg, int FI,
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

  auto MIB = BuildMI(MBB, I, DL, get(Pseudo))
                 .addReg(DstReg, RegState::DefineNoRead)
                 .addImm(0)
                 .addFrameIndex(FI)
                 .addImm(KVXMOD::VARIANT_);
  LLVM_DEBUG(dbgs() << "Created Load: "; MIB->dump());
  (void)MIB;
  return;
}

void KVXInstrInfo::storeRegToStackSlot(MachineBasicBlock &MBB,
                                       MachineBasicBlock::iterator I,
                                       Register SrcReg, bool IsKill, int FI,
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
    // TODO: Using pseudo-instruction for wide and matrix is
    // really sub-optimal, as it can't be correctly scheduled.
    // Should find a way to avoid it.

    LLVM_DEBUG(dbgs() << "Wide TCA register, storing using SWIDEp.\n");
    Pseudo = KVX::SWIDEp;
  } else if (KVX::MatrixRegRegClass.hasSubClassEq(RC)) {
    Pseudo = KVX::SMATRIXp;
    LLVM_DEBUG(dbgs() << "Matrix TCA register, storing using SMATRIXp.\n");
  } else if (KVX::OnlyraRegRegClass.hasSubClassEq(RC)) {
    LLVM_DEBUG(dbgs() << "It is a RA register, using GETss2 and SDp.\n");

    MachineFunction &MF = *MBB.getParent();
    const TargetSubtargetInfo &STI = MF.getSubtarget();
    const TargetInstrInfo *TII = STI.getInstrInfo();
    const MCRegisterInfo *MRI = STI.getRegisterInfo();

    Register ScratchReg = findScratchRegister(MBB, false, KVX::R16);
    BuildMI(MBB, I, DL, get(KVX::GETss2), ScratchReg)
        .addReg(KVX::RA)
        .setMIFlags(MachineInstr::FrameSetup);

    unsigned CFIIndex = MF.addFrameInst(MCCFIInstruction::createRegister(
        nullptr, MRI->getDwarfRegNum(KVX::RA, true),
        MRI->getDwarfRegNum(ScratchReg, true)));
    BuildMI(MBB, I, DL, TII->get(TargetOpcode::CFI_INSTRUCTION))
        .addCFIIndex(CFIIndex)
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

static bool parseCondBranch(MachineInstr &LastInst, MachineBasicBlock *&Target,
                            SmallVectorImpl<MachineOperand> &Cond) {
  // Block ends with fall-through condbranch.
  assert(LastInst.getDesc().isConditionalBranch() &&
         "Unknown conditional branch");
  LLVM_DEBUG(dbgs() << "Obtaining conditional branch BB and condition.\n");
  Target = LastInst.getOperand(1).getMBB();
  Cond.push_back(MachineOperand::CreateImm(LastInst.getOpcode()));
  Cond.push_back(LastInst.getOperand(0));
  Cond.push_back(LastInst.getOperand(2));
  return false;
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

  LLVM_DEBUG(dbgs() << "Analyze branch from MBB: " << MBB.getName() << ".\n");

  TBB = FBB = nullptr;
  Cond.clear();

  // If the block has no terminators, it just falls into the block after it.
  MachineBasicBlock::iterator I = MBB.getLastNonDebugInstr();
  if (I == MBB.end() || !isUnpredicatedTerminator(*I)) {
    LLVM_DEBUG(dbgs() << "Can only fallthrough.\n");
    return false;
  }

  // Count the number of terminators and find the first unconditional or
  // indirect branch.
  MachineBasicBlock::iterator FirstUncondOrIndirectBr = MBB.end();
  int NumTerminators = 0;
  for (auto J = I.getReverse(); J != MBB.rend() && isUnpredicatedTerminator(*J);
       J++) {
    LLVM_DEBUG(dbgs() << "This is a terminator: " << *J);
    NumTerminators++;
    if (J->getDesc().isUnconditionalBranch() ||
        J->getDesc().isIndirectBranch()) {
      LLVM_DEBUG(
          dbgs() << "This is the first unconditional or indirect branch: "
                 << *J);
      FirstUncondOrIndirectBr = J.getReverse();
    }
  }

  // If AllowModify is true, we can erase any terminators after
  // FirstUncondOrIndirectBR.
  if (AllowModify && FirstUncondOrIndirectBr != MBB.end()) {
    LLVM_DEBUG(dbgs() << "Dead code in block: "; MBB.dump());
    for (auto I = std::next(FirstUncondOrIndirectBr); I != MBB.end();
         I = std::next(FirstUncondOrIndirectBr)) {
      LLVM_DEBUG(dbgs() << "Eliminating dead instruction: " << *I);
      std::next(FirstUncondOrIndirectBr)->eraseFromParent();
      NumTerminators--;
    }
    I = FirstUncondOrIndirectBr;
    LLVM_DEBUG(dbgs() << "Block reduced to: "; MBB.dump());
  }

  // We can't handle blocks that end in an indirect branch.
  if (I->getDesc().isIndirectBranch()) {
    LLVM_DEBUG(dbgs() << "Can't handle indirect branch: " << *I);
    return true;
  }

  if (I->getOpcode() == KVX::ENDLOOP) {
    LLVM_DEBUG(dbgs() << "Disable tail merging ENDLOOP block.\n");
    return true;
  }

  // We can't handle blocks with more than 2 terminators.
  if (NumTerminators > 2) {
    LLVM_DEBUG(dbgs() << "Can't handle more than 2 terminators\n");
    return true;
  }

  // Handle a single unconditional branch.
  if (NumTerminators == 1 && I->getDesc().isUnconditionalBranch()) {
    LLVM_DEBUG(dbgs() << "Single unconditional branch: " << *I << ".\n");
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
    LLVM_DEBUG(dbgs() << "Single conditional branch: " << *I << ".\n");
    return parseCondBranch(*I, TBB, Cond);
  }

  auto Prev = std::prev(I);
  // Handle a conditional branch followed by an unconditional branch.
  if (NumTerminators == 2 && Prev->getDesc().isConditionalBranch() &&
      I->getDesc().isUnconditionalBranch() && I->getOpcode() == KVX::GOTO) {
    LLVM_DEBUG(dbgs() << "Has two branch instructions: " << *I
                      << " and: " << *Prev);

    FBB = I->getOperand(0).getMBB();
    return parseCondBranch(*std::prev(I), TBB, Cond);
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

bool KVXInstrInfo::isSchedulingBoundary(const MachineInstr &MI,
                                        const MachineBasicBlock *MBB,
                                        const MachineFunction &MF) const {
  switch (MI.getOpcode()) {
  case KVX::FENCE:
  case KVX::ENDLOOP:
  case KVX::LOOPDO:
  case TargetOpcode::EH_LABEL:
    return true;
  default:
    break;
  }
  return TargetInstrInfo::isSchedulingBoundary(MI, MBB, MF);
}

MachineBasicBlock *
KVXInstrInfo::getBranchDestBlock(const MachineInstr &MI) const {
  switch (MI.getOpcode()) {
  case KVX::GOTO:
    return MI.getOperand(0).getMBB();
  case KVX::CB:
    return MI.getOperand(1).getMBB();
  }
  return nullptr;
}

bool KVXInstrInfo::isPredicable(const MachineInstr &MI) const {
  LLVM_DEBUG(dbgs() << "IsPredicable? " << MI);
  if (MI.isPredicable()) {
    // It's ok to const_cast, we won't modify if passing an empty
    // second argument (Pred).
    if (PredicateInstruction(const_cast<MachineInstr &>(MI), {})) {
      LLVM_DEBUG(dbgs() << "true\n");
      // TODO: This only allows store operations
      // We must change LLVM to pass the true/false
      // instructions when adding performing a select
      // of the produced value.
      return MI.mayStore() && !MI.mayLoad();
    }
  }
  LLVM_DEBUG(dbgs() << "false\n");
  return false;
}

bool KVXInstrInfo::isPredicated(const MachineInstr &MI) const {
  LLVM_DEBUG(dbgs() << "IsPredicated? " << MI);

  // A predicable instruction is not predicated
  if (MI.isPredicable()) {
    LLVM_DEBUG(dbgs() << "false\n");
    return false;
  }
  switch (MI.getOpcode()) {
  // A CMOVED is predicated
  case KVX::CMOVEDri10:
  case KVX::CMOVEDri37:
  case KVX::CMOVEDri64:
  case KVX::CMOVEDrr:
    LLVM_DEBUG(dbgs() << "true\n");
    return true;
  // The remaining mem instructions are predicated
  default:
    LLVM_DEBUG(
        dbgs() << ((MI.mayLoad() || MI.mayStore()) ? "true\n" : "false\n"));
    return MI.mayLoad() || MI.mayStore();
  }
}

bool KVXInstrInfo::canInsertSelect(const MachineBasicBlock &MBB,
                                   ArrayRef<MachineOperand> Cond,
                                   Register DstReg, Register TrueReg,
                                   Register FalseReg, int &CondCycles,
                                   int &TrueCycles, int &FalseCycles) const {
  LLVM_DEBUG(dbgs() << "canInsertSelect? ");
  const MachineRegisterInfo &MRI = MBB.getParent()->getRegInfo();
  if (&KVX::SingleRegRegClass != MRI.getRegClass(DstReg)) {
    LLVM_DEBUG(dbgs() << "false\n");
    return false;
  }
  CondCycles = FalseCycles = 1;
  // If we are comparing a value to zero, we don't need
  // a comparison instruction
  if (Cond[2].isCImm() && Cond[2].getCImm()->isZero())
    CondCycles = 0;

  LLVM_DEBUG(dbgs() << "true\n");
  return true;
}

void KVXInstrInfo::insertSelect(MachineBasicBlock &MBB,
                                MachineBasicBlock::iterator I,
                                const DebugLoc &DL, Register DstReg,
                                ArrayRef<MachineOperand> Cond, Register TrueReg,
                                Register FalseReg) const {
  auto BBEnd = MBB.end();
  auto TrueMI = BBEnd;
  auto FalseMI = TrueMI;
  for (auto BI = MBB.begin(), C = I; C != BI; --C) {
    if (C->getOperand(0).isReg() && C->getOperand(0).getReg() == TrueReg) {
      LLVM_DEBUG(dbgs() << "Print: Got TrueReg instr:"; C->dump());
      TrueMI = C;
      if (FalseMI != BBEnd)
        break;
    }
    if (C->getOperand(0).isReg() && C->getOperand(0).getReg() == FalseReg) {
      LLVM_DEBUG(dbgs() << "Print: Got FalseReg instr:"; C->dump());
      FalseMI = C;
      if (TrueMI != BBEnd)
        break;
    }
  }
  assert(TrueMI != FalseMI && "True and False instructions can't be the same!");
  LLVM_DEBUG(dbgs() << "InsertSelect\n");
  LLVM_DEBUG(dbgs() << "I: "; I->dump());
  LLVM_DEBUG(dbgs() << "DstReg:" << DstReg << '\n');
  LLVM_DEBUG(dbgs() << "TrueReg:" << TrueReg << '\n');
  LLVM_DEBUG(dbgs() << "FalseReg:" << FalseReg << '\n');
  LLVM_DEBUG(dbgs() << "Cond:");
  LLVM_DEBUG(for (auto &V : Cond) V.dump(););
  // TODO: For the moment we just try to predicate the last
  // executed of the true/false instruction.
  // We could detect if one is a copy instruction, and avoid
  // predicting it, but predicting the first instruction, and
  // setting the input of the copy as the result of it.
  MachineRegisterInfo &MRI = MBB.getParent()->getRegInfo();
  if (&KVX::SingleRegRegClass != MRI.getRegClass(DstReg))
    report_fatal_error("Can only select between 64 bit registers.");

  // We can prevent adding an CMOVE over the two instructions in these cases:
  // select (copy[d] Reg0), (copy[d] Reg1)  -> cmoved (Reg0), (Reg1)
  // select (copy[d] Reg), (make Imm)  -> cmoved (Reg), (Imm)
  // select (make Imm1), (make Imm2)  -> cmoved (make Imm1), Imm2

  // If it does not sit in one of those conditions, create
  // DstReg = cmoved (FalseReg), (TrueReg)
  if (!(!isPredicated(*TrueMI) && !isPredicated(*FalseMI) &&
        (TrueMI->isFullCopy() || TrueMI->isMoveImmediate() ||
         TrueMI->isMoveReg()) &&
        (FalseMI->isFullCopy() || FalseMI->isMoveImmediate() ||
         FalseMI->isMoveReg()))) {
    BuildMI(MBB, I, DL, get(KVX::CMOVEDrr), DstReg)
        .add(Cond[1])
        .addReg(FalseReg)
        .addReg(TrueReg)
        .add(Cond[2]);
    return;
  }

  auto TrueOp = TrueMI->getOperand(1);
  auto FalseOp = FalseMI->getOperand(1);
  // select (copy[d] Reg0), (copy[d] Reg1)  -> cmoved (Reg0), (Reg1)
  if (!TrueOp.isImm() && !FalseOp.isImm()) {
    // TwoAddressInstructionPass does not accept non-virtual registers
    Register TReg = TrueOp.getReg();
    Register FReg = FalseOp.getReg();
    if (!TReg.isVirtual())
      TReg = TrueReg;
    if (!FReg.isVirtual())
      FReg = FalseReg;
    BuildMI(MBB, I, DL, get(KVX::CMOVEDrr), DstReg)
        .add(Cond[1])
        .addReg(FReg)
        .addReg(TReg)
        .add(Cond[2]);
    return;
  }
  int64_t Val;
  if (TrueOp.isImm())
    Val = TrueOp.getImm();
  else
    Val = FalseOp.getImm();
  unsigned Opcode;
  if (isInt<10>(Val))
    Opcode = KVX::CMOVEDri10;
  else if (isInt<37>(Val))
    Opcode = KVX::CMOVEDri37;
  else
    Opcode = KVX::CMOVEDri64;
  // select (make Imm1), (make Imm2)  -> cmoved (make Imm1), Imm2
  if (TrueOp.isImm() && FalseOp.isImm()) {
    LLVM_DEBUG(dbgs() << "Generated CMOVEDri (make " << FalseOp.getImm()
                      << "), " << Val << '\n');
    BuildMI(MBB, I, DL, get(Opcode), DstReg)
        .add(Cond[1])
        .addReg(FalseReg)
        .addImm(Val)
        .add(Cond[2]);
    return;
  }
  // select (copy[d] FalseOp), (make Imm)  -> cmoved FalseOp, Imm
  if (TrueOp.isImm()) {
    Register FReg = FalseOp.getReg();
    if (!FReg.isVirtual())
      FReg = FalseReg;

    LLVM_DEBUG(dbgs() << "Generated CMOVEDri (" << FalseOp << "), " << Val
                      << '\n');
    BuildMI(MBB, I, DL, get(Opcode), DstReg)
        .add(Cond[1])
        .addReg(FReg)
        .addImm(Val)
        .add(Cond[2]);
    return;
  }
  // We must invert the true/false sides and test condition
  LLVM_DEBUG(dbgs() << "Generated inverted condition CMOVEDri (make " << TrueOp
                    << "), " << FalseOp.getImm() << '\n');
  Register TReg = TrueOp.getReg();
  if (!TReg.isVirtual())
    TReg = TrueReg;
  BuildMI(MBB, I, DL, get(Opcode), DstReg)
      .add(Cond[1])
      .addReg(TReg)
      .addImm(Val)
      .addImm(getOppositeBranchOpcode(Cond[2].getImm()));
  return;
};

unsigned KVXInstrInfo::getPredicationCost(const MachineInstr &MI) const {
  LLVM_DEBUG(dbgs() << "getPredicationCost: 0\n");
  // For the moment we only deal with cases without predication costs,
  // where we can simply replace the opcode and add the test operands.
  return 0;
}

bool KVXInstrInfo::isProfitableToIfCvt(MachineBasicBlock &MBB,
                                       unsigned NumCycles,
                                       unsigned ExtraPredCycles,
                                       BranchProbability Probability) const {
  // TODO: Improve the cost model. For now, just assume we
  // always want to convert the if.
  LLVM_DEBUG(dbgs() << "isProfitableToIfCvt: true\n");
  return true;
};

bool KVXInstrInfo::PredicateInstruction(MachineInstr &MI,
                                        ArrayRef<MachineOperand> Pred) const {
  LLVM_DEBUG(dbgs() << "PredicateInstruction\n");
  assert(!isPredicated(MI) &&
         "Can't predicate an already predicated instruction");
  unsigned Oprrc, Opri27c, Opri54c;
  bool IsRR = false;

  switch (MI.getOpcode()) {
  default:
    return false;
  case KVX::LBSrr:
    IsRR = true;
    LLVM_FALLTHROUGH;
  case KVX::LBSri10:
  case KVX::LBSri37:
  case KVX::LBSri64:
    Oprrc = KVX::LBSrrc;
    Opri27c = KVX::LBSri27c;
    Opri54c = KVX::LBSri54c;
    break;
  case KVX::LBZrr:
    IsRR = true;
    LLVM_FALLTHROUGH;
  case KVX::LBZri10:
  case KVX::LBZri37:
  case KVX::LBZri64:
    Oprrc = KVX::LBZrrc;
    Opri27c = KVX::LBZri27c;
    Opri54c = KVX::LBZri54c;
    break;
  case KVX::LDrr:
    IsRR = true;
    LLVM_FALLTHROUGH;
  case KVX::LDri10:
  case KVX::LDri37:
  case KVX::LDri64:
    Oprrc = KVX::LDrrc;
    Opri27c = KVX::LDri27c;
    Opri54c = KVX::LDri54c;
    break;
  case KVX::LHSrr:
    IsRR = true;
    LLVM_FALLTHROUGH;
  case KVX::LHSri10:
    Oprrc = KVX::LHSrrc;
    Opri27c = KVX::LHSri27c;
    Opri54c = KVX::LHSri54c;
    break;
  case KVX::LHZrr:
    IsRR = true;
    LLVM_FALLTHROUGH;
  case KVX::LHZri10:
  case KVX::LHZri37:
  case KVX::LHZri64:
    Oprrc = KVX::LHZrrc;
    Opri27c = KVX::LHZri27c;
    Opri54c = KVX::LHZri54c;
    break;
  case KVX::LOrr:
    IsRR = true;
    LLVM_FALLTHROUGH;
  case KVX::LOri10:
  case KVX::LOri37:
  case KVX::LOri64:
    Oprrc = KVX::LOrrc;
    Opri27c = KVX::LOri27c;
    Opri54c = KVX::LOri54c;
    break;
  case KVX::LQrr:
    IsRR = true;
    LLVM_FALLTHROUGH;
  case KVX::LQri10:
  case KVX::LQri37:
  case KVX::LQri64:
    Oprrc = KVX::LQrrc;
    Opri27c = KVX::LQri27c;
    Opri54c = KVX::LQri54c;
    break;
  case KVX::LVmrrcs:
    IsRR = true;
    LLVM_FALLTHROUGH;
  case KVX::LVmri10cs:
  case KVX::LVmri37cs:
  case KVX::LVmri64cs:
    Oprrc = KVX::LVmrrcs;
    Opri27c = KVX::LVmri27ccs;
    Opri54c = KVX::LVmri54ccs;
    break;
  case KVX::LVrr:
    IsRR = true;
    LLVM_FALLTHROUGH;
  case KVX::LVri10:
  case KVX::LVri37:
  case KVX::LVri64:
    Oprrc = KVX::LVrrc;
    Opri27c = KVX::LVri27c;
    Opri54c = KVX::LVri54c;
    break;
  case KVX::LVrrcs:
    IsRR = true;
    LLVM_FALLTHROUGH;
  case KVX::LVri10cs:
  case KVX::LVri37cs:
  case KVX::LVri64cs:
    Oprrc = KVX::LVrrccs;
    Opri27c = KVX::LVri27ccs;
    Opri54c = KVX::LVri54ccs;
    break;
  case KVX::LWSrr:
    IsRR = true;
    LLVM_FALLTHROUGH;
  case KVX::LWSri10:
  case KVX::LWSri37:
  case KVX::LWSri64:
    Oprrc = KVX::LWSrrc;
    Opri27c = KVX::LWSri27c;
    Opri54c = KVX::LWSri54c;
    break;
  case KVX::LWZrr:
    IsRR = true;
    LLVM_FALLTHROUGH;
  case KVX::LWZri10:
  case KVX::LWZri37:
  case KVX::LWZri64:
    Oprrc = KVX::LWZrrc;
    Opri27c = KVX::LWZri27c;
    Opri54c = KVX::LWZri54c;
    break;
  case KVX::SBrr:
    IsRR = true;
    LLVM_FALLTHROUGH;
  case KVX::SBri10:
  case KVX::SBri37:
  case KVX::SBri64:
    Oprrc = KVX::SBrrc;
    Opri27c = KVX::SBri27c;
    Opri54c = KVX::SBri54c;
    break;
  case KVX::SDrr:
    IsRR = true;
    LLVM_FALLTHROUGH;
  case KVX::SDri10:
  case KVX::SDri37:
  case KVX::SDri64:
    Oprrc = KVX::SDrrc;
    Opri27c = KVX::SDri27c;
    Opri54c = KVX::SDri54c;
    break;
  case KVX::SHrr:
    IsRR = true;
    LLVM_FALLTHROUGH;
  case KVX::SHri10:
  case KVX::SHri37:
  case KVX::SHri64:
    Oprrc = KVX::SHrrc;
    Opri27c = KVX::SHri27c;
    Opri54c = KVX::SHri54c;
    break;
  case KVX::SOrr:
    IsRR = true;
    LLVM_FALLTHROUGH;
  case KVX::SOri10:
  case KVX::SOri37:
  case KVX::SOri64:
    Oprrc = KVX::SOrrc;
    Opri27c = KVX::SOri27c;
    Opri54c = KVX::SOri54c;
    break;
  case KVX::SQrr:
    IsRR = true;
    LLVM_FALLTHROUGH;
  case KVX::SQri10:
  case KVX::SQri37:
  case KVX::SQri64:
    Oprrc = KVX::SQrrc;
    Opri27c = KVX::SQri27c;
    Opri54c = KVX::SQri54c;
    break;
  case KVX::SVrr:
    IsRR = true;
    LLVM_FALLTHROUGH;
  case KVX::SVri10:
  case KVX::SVri37:
  case KVX::SVri64:
    Oprrc = KVX::SVrrc;
    Opri27c = KVX::SVri27c;
    Opri54c = KVX::SVri54c;
    break;
  case KVX::SWrr:
    IsRR = true;
    LLVM_FALLTHROUGH;
  case KVX::SWri10:
  case KVX::SWri37:
  case KVX::SWri64:
    Oprrc = KVX::SWrrc;
    Opri27c = KVX::SWri27c;
    Opri54c = KVX::SWri54c;
    break;
  }
  LLVM_DEBUG(dbgs() << "Checking if we can predicate: "; MI.dump());
  unsigned NewOpcode = 0;
  bool MustRemoveOffset = false;
  if (IsRR) {
    auto DoScale = MI.getOperand(MI.mayLoad() ? 4 : 3);
    if (!DoScale.isImm() || DoScale.getImm() != 0) {
      LLVM_DEBUG(
          dbgs() << "TODO: Allow predicated load/store with scaled offset.\n");
      return false;
    }
    auto Offset = MI.getOperand(MI.mayLoad() ? 1 : 0);
    if (!Offset.isImm() || Offset.getImm() != 0) {
      LLVM_DEBUG(
          dbgs() << "TODO: Allow predicated rr load with non-zero offset.\n");
      return false;
    }
    NewOpcode = Oprrc;
  } else {
    auto Imm = MI.getOperand(MI.mayLoad() ? 1 : 0);
    if (!Imm.isImm()) {
      LLVM_DEBUG(MI.dump());
      report_fatal_error("Expected an immediate value as offset.\n");
    }
    int64_t Val = Imm.getImm();
    if (Val == 0) {
      NewOpcode = Oprrc;
      MustRemoveOffset = true;
      LLVM_DEBUG(dbgs() << "Offset is zero, can use rrc variant.\n");
    } else if (isInt<27>(Val)) {
      NewOpcode = Opri27c;
      LLVM_DEBUG(dbgs() << "Offset fits 27 bits.\n");
    } else if (isInt<54>(Val)) {
      LLVM_DEBUG(dbgs() << "Offset fits 54 bits.\n");
      NewOpcode = Opri54c;
    } else {
      LLVM_DEBUG(
          dbgs() << "TODO: We don't yet suport materializing immediates.\n");
      return false;
    }
  }

  assert(NewOpcode);
  // We use this to allow detecting if we actually are ment to
  // modify the instruction or we are just checking if we can
  // predicate it.
  if (Pred.empty())
    return true;

  if (Pred[0].getImm() != KVX::CB)
    report_fatal_error("Predicate does not come from a CB.\n");

  // The conditional version does not hold offset or doScale arguments.
  if (IsRR) {
    // TODO: Allow non-zero offset.
    // TODO: Allow scalled values.
    // TODO: Allow predicating loads.
    // TODO: Allow predicating register copies into cmoves.
    if (MI.mayLoad())
      report_fatal_error(
          "TODO: Can't predicate loads, must insert output as input.");
    else {
      // Remove doScale argument
      MI.RemoveOperand(3);
      // Remove zero offset operand
      MI.RemoveOperand(0);
    }
  } else if (MustRemoveOffset) {
    if (MI.mayLoad())
      report_fatal_error(
          "TODO: Can't predicate loads, must insert output as input.");
    else
      MI.RemoveOperand(0);
  }

  MI.setDesc(get(NewOpcode));
  MachineInstrBuilder(*MI.getParent()->getParent(), MI)
      .addImm(Pred[2].getImm())
      .addReg(Pred[1].getReg());

  LLVM_DEBUG(dbgs() << "Predicated instruction now is: "; MI.dump());
  return true;
}
