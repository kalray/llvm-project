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

#include "KVXHazardRecognizer.h"
#include "KVXSubtarget.h"
#include "llvm/ADT/SmallSet.h"
#include "llvm/CodeGen/RegisterScavenging.h"
#include "llvm/MC/MCDwarf.h"

using namespace llvm;
#define DEBUG_TYPE "KVX-isel"

static cl::opt<bool> KVXCondTailCall(
    "kvx-conditional-tailcalls",
    cl::desc("Enable generation of conditional tail calls for KVX."),
    cl::init(false), cl::cat(KVXclOpts));

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
    LLVM_DEBUG(dbgs() << "It is a PairedReg, 2xcopyd.\n");
    BuildMI(MBB, MBBI, DL, get(KVX::COPYD), TRI->getSubReg(DstReg, KVX::sub_d0))
        .addReg(TRI->getSubReg(SrcReg, KVX::sub_d0), getKillRegState(KillSrc));
    BuildMI(MBB, MBBI, DL, get(KVX::COPYD), TRI->getSubReg(DstReg, KVX::sub_d1))
        .addReg(TRI->getSubReg(SrcReg, KVX::sub_d1), getKillRegState(KillSrc));
    return;
  }
  if (KVX::SingleRegRegClass.contains(DstReg, SrcReg)) {
    LLVM_DEBUG(dbgs() << "It is a SingleReg copyd.\n");
    BuildMI(MBB, MBBI, DL, get(KVX::COPYD), DstReg)
        .addReg(SrcReg, getKillRegState(KillSrc));
    return;
  }
  // TCA registers to GPR
  if (!Subtarget.isV1()) {
    if (KVX::QuadRegRegClass.contains(DstReg) &&
        KVX::VectorRegRegClass.contains(SrcReg)) {
      LLVM_DEBUG(dbgs() << "It is a TCA VectorReg to GPR QuadReg xmovefo.\n");
      BuildMI(MBB, MBBI, DL, get(KVX::XMOVEFO), DstReg)
          .addReg(SrcReg, getKillRegState(KillSrc));
      return;
    }
  } else {
    if (KVX::QuadRegRegClass.contains(DstReg)) {
      if (KVX::VectorRegERegClass.contains(SrcReg)) {
        LLVM_DEBUG(
            dbgs() << "It is a TCA VectorRegE to GPR QuadReg xmovefore.\n");
        BuildMI(MBB, MBBI, DL, get(KVX::MOVEFOre), DstReg)
            .addReg(SrcReg, getKillRegState(KillSrc));
        return;
      }
      if (KVX::VectorRegORegClass.contains(SrcReg)) {
        LLVM_DEBUG(
            dbgs() << "It is a TCA VectorRegE to GPR QuadReg xmoveforo.\n");
        BuildMI(MBB, MBBI, DL, get(KVX::MOVEFOro), DstReg)
            .addReg(SrcReg, getKillRegState(KillSrc));
        return;
      }
    }
  }
  // GPR registers to TCA
  if (KVX::PairedRegRegClass.contains(SrcReg)) {
    if (KVX::BlockRegERegClass.contains(DstReg)) {
      LLVM_DEBUG(
          dbgs() << "It is a GPR PairedReg to TCA BlockRegE movetqrrbe.\n");
      BuildMI(MBB, MBBI, DL, get(KVX::XMOVETQrrbe), DstReg)
          .addReg(TRI->getSubReg(SrcReg, KVX::sub_d0), getKillRegState(KillSrc))
          .addReg(TRI->getSubReg(SrcReg, KVX::sub_d1),
                  getKillRegState(KillSrc));

      return;
    }
    if (KVX::BlockRegORegClass.contains(DstReg)) {
      LLVM_DEBUG(
          dbgs() << "It is a GPR PairedReg to TCA BlockRegO movetqrrbo.\n");
      BuildMI(MBB, MBBI, DL, get(KVX::XMOVETQrrbo), DstReg)
          .addReg(TRI->getSubReg(SrcReg, KVX::sub_d0), getKillRegState(KillSrc))
          .addReg(TRI->getSubReg(SrcReg, KVX::sub_d1),
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
                  "instructions, a xmovetqrrbo and a xmovetqrrbe.\n");

    MCRegister SubReg1 = TRI->getSubReg(DstReg, KVX::sub_q0);
    MCRegister SubReg2 = TRI->getSubReg(DstReg, KVX::sub_q1);

    if (!KVX::BlockRegRegClass.contains(SubReg1, SubReg2))
      report_fatal_error("One of these are not a BlockReg: (" +
                         TRI->getRegAsmName(SubReg1.id()) + ", " +
                         TRI->getRegAsmName(SubReg2.id()) + ").\n");
    BuildMI(MBB, MBBI, DL,
            get(Subtarget.isV1() ? KVX::MOVETQrrbe : KVX::XMOVETQrrbe), SubReg1)
        .addReg(TRI->getSubReg(SrcReg, KVX::sub_d0), getKillRegState(KillSrc))
        .addReg(TRI->getSubReg(SrcReg, KVX::sub_d1), getKillRegState(KillSrc));
    BuildMI(MBB, MBBI, DL,
            get(Subtarget.isV1() ? KVX::MOVETQrrbo : KVX::XMOVETQrrbo), SubReg2)
        .addReg(TRI->getSubReg(SrcReg, KVX::sub_d2), getKillRegState(KillSrc))
        .addReg(TRI->getSubReg(SrcReg, KVX::sub_d3), getKillRegState(KillSrc));
    return;
  }

  if (KVX::GetRegRegClass.contains(SrcReg) &&
      KVX::SingleRegRegClass.contains(DstReg) &&
      ((Subtarget.isV1() && !KVX::GetNotCV1RegRegClass.contains(SrcReg)) ||
       (Subtarget.isV2() &&
        !KVX::GetSetFxNotCV2RegRegClass.contains(SrcReg)))) {
    LLVM_DEBUG(dbgs() << "It is a GET.\n");
    BuildMI(MBB, MBBI, DL, get(KVX::GET), DstReg)
        .addReg(SrcReg, RegState::InternalRead | getKillRegState(KillSrc));
    return;
  }

  if (KVX::SingleRegRegClass.contains(SrcReg) &&
      KVX::SetRegRegClass.contains(DstReg) &&
      ((Subtarget.isV1() && !KVX::SetFxNotCV1RegRegClass.contains(DstReg)) ||
       (Subtarget.isV2() &&
        !KVX::GetSetFxNotCV2RegRegClass.contains(DstReg)))) {
    if (KVX::AloneRegRegClass.contains(DstReg)) {
      LLVM_DEBUG(dbgs() << "It is a SETrsa.\n");
      BuildMI(MBB, MBBI, DL, get(KVX::SETrsa), DstReg)
          .addReg(SrcReg, getKillRegState(KillSrc));
      return;
    }
    LLVM_DEBUG(dbgs() << "It is a SETrst3.\n");
    BuildMI(MBB, MBBI, DL, get(KVX::SETrst3), DstReg)
        .addReg(SrcReg, getKillRegState(KillSrc));
    return;
  }

  // Between TCA registers
  if (!Subtarget.isV1()) {
    if (KVX::Buffer16RegRegClass.contains(DstReg, SrcReg)) {
      LLVM_DEBUG(dbgs() << "It is a TCA Buffer16, use 4x xcopyv.\n");
      for (auto SubVec : {KVX::sub_m0, KVX::sub_m1, KVX::sub_m2, KVX::sub_m3}) {
        auto Src = TRI->getSubReg(SrcReg, SubVec);
        auto Dst = TRI->getSubReg(DstReg, SubVec);
        BuildMI(MBB, MBBI, DL, get(KVX::XCOPYV), Dst)
            .addReg(Src, getKillRegState(KillSrc))
            .addImm(0);
      }
      return;
    }
    if (KVX::Buffer8RegRegClass.contains(DstReg, SrcReg)) {
      LLVM_DEBUG(dbgs() << "It is a TCA Buffer8, use 2x xcopyv.\n");
      for (auto SubVec : {KVX::sub_m0, KVX::sub_m1}) {
        auto Src = TRI->getSubReg(SrcReg, SubVec);
        auto Dst = TRI->getSubReg(DstReg, SubVec);
        BuildMI(MBB, MBBI, DL, get(KVX::XCOPYV), Dst)
            .addReg(Src, getKillRegState(KillSrc))
            .addImm(0);
      }
      return;
    }
    if (KVX::MatrixRegRegClass.contains(SrcReg, DstReg)) {
      BuildMI(MBB, MBBI, DL, get(KVX::XCOPYV), DstReg)
          .addReg(SrcReg, getKillRegState(KillSrc))
          .addImm(0);
      return;
    }
    if (KVX::WideRegRegClass.contains(SrcReg, DstReg)) {
      BuildMI(MBB, MBBI, DL, get(KVX::XCOPYX), DstReg)
          .addReg(SrcReg, getKillRegState(KillSrc))
          .addImm(0);
      return;
    }
    if (KVX::VectorRegRegClass.contains(SrcReg, DstReg)) {
      BuildMI(MBB, MBBI, DL, get(KVX::XCOPYO), DstReg)
          .addReg(SrcReg, getKillRegState(KillSrc));
      return;
    }
  } else {
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

    if (KVX::WideRegRegClass.contains(DstReg, SrcReg)) {
      LLVM_DEBUG(dbgs() << "It is a TCA WideReg, use 2x xcopyv.\n");

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

    if (KVX::MatrixRegRegClass.contains(DstReg, SrcReg)) {
      LLVM_DEBUG(dbgs() << "It is a TCA MatrixReg, use 4x xcopyv.\n");
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
    if (KVX::Buffer8RegRegClass.contains(DstReg, SrcReg)) {
      LLVM_DEBUG(dbgs() << "It is a TCA Buffer8, use 8x xcopyv.\n");
      auto VecType = KVX::COPYVre;
      for (auto SubVec : {KVX::sub_v0, KVX::sub_v1, KVX::sub_v2, KVX::sub_v3,
                          KVX::sub_v4, KVX::sub_v5, KVX::sub_v6, KVX::sub_v7}) {
        auto Src = TRI->getSubReg(SrcReg, SubVec);
        auto Dst = TRI->getSubReg(DstReg, SubVec);
        BuildMI(MBB, MBBI, DL, get(VecType), Dst)
            .addReg(Src, getKillRegState(KillSrc));
        VecType = VecType == KVX::COPYVre ? KVX::COPYVro : KVX::COPYVre;
      }
      return;
    }
    if (KVX::Buffer16RegRegClass.contains(DstReg, SrcReg)) {
      LLVM_DEBUG(dbgs() << "It is a TCA Buffer16, use 8x xcopyv.\n");
      auto VecType = KVX::COPYVre;
      for (auto SubVec :
           {KVX::sub_v0, KVX::sub_v1, KVX::sub_v2, KVX::sub_v3, KVX::sub_v4,
            KVX::sub_v5, KVX::sub_v6, KVX::sub_v7, KVX::sub_v8, KVX::sub_v9,
            KVX::sub_v10, KVX::sub_v11, KVX::sub_v12, KVX::sub_v13,
            KVX::sub_v14, KVX::sub_v15}) {
        auto Src = TRI->getSubReg(SrcReg, SubVec);
        auto Dst = TRI->getSubReg(DstReg, SubVec);
        BuildMI(MBB, MBBI, DL, get(VecType), Dst)
            .addReg(Src, getKillRegState(KillSrc));
        VecType = VecType == KVX::COPYVre ? KVX::COPYVro : KVX::COPYVre;
      }
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
  for (int I = 0; CSRegs[I]; ++I)
    RS.setRegUsed(CSRegs[I]);

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
                                        const TargetRegisterInfo *TRI,
                                        Register VReg) const {
  return loadRegFromStackSlot(MBB, I, DstReg, FI, RC, TRI, VReg, false,
                              DebugLoc());
}

void KVXInstrInfo::loadRegFromStackSlot(
    MachineBasicBlock &MBB, MachineBasicBlock::iterator I, Register DstReg,
    int FI, const TargetRegisterClass *RC, const TargetRegisterInfo *TRI,
    Register VReg, bool IsEpilogue, DebugLoc DL) const {
  LLVM_DEBUG(dbgs() << "Loading from stack to register (" << DstReg << ").\n");
  if (I != MBB.end())
    DL = I->getDebugLoc();
  unsigned Width = 1;
  int Pseudo = 0;
  if (KVX::SingleRegRegClass.hasSubClassEq(RC)) {
    LLVM_DEBUG(dbgs() << "It is a single GPR, loading using LDp.\n");
    Pseudo = KVX::LDp;
  } else if (KVX::PairedRegRegClass.hasSubClassEq(RC)) {
    Width = 2;
    LLVM_DEBUG(dbgs() << "It is a paired GPR, loading using LQp.\n");
    Pseudo = KVX::LQp;
  } else if (KVX::QuadRegRegClass.hasSubClassEq(RC)) {
    Width = 4;
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
    LLVM_DEBUG(dbgs() << "It is the RA register, using LDp and SETrsta.\n");

    Register ScratchReg = findScratchRegister(MBB, true, KVX::R16);
    auto LDp = BuildMI(MBB, I, DL, get(KVX::LDp), ScratchReg)
                   .addImm(0)
                   .addFrameIndex(FI)
                   .addImm(KVXMOD::VARIANT_);
    if (IsEpilogue)
      LDp.setMIFlag(MachineInstr::FrameDestroy);

    auto SRA = BuildMI(MBB, I, DL, get(KVX::SETrst3), KVX::RA)
                   .addReg(ScratchReg, RegState::Kill);
    if (IsEpilogue) {
      SRA.setMIFlag(MachineInstr::FrameDestroy);
      unsigned CFIIndex =
          MBB.getParent()->addFrameInst(MCCFIInstruction::createRestore(
              nullptr, TRI->getDwarfRegNum(KVX::RA, false)));

      BuildMI(MBB, SRA.getInstr()->getNextNode(), DL,
              get(TargetOpcode::CFI_INSTRUCTION))
          .addCFIIndex(CFIIndex)
          .setMIFlag(MachineInstr::FrameDestroy);
    }
    return;
  } else
    report_fatal_error("Don't know how to load register from the stack.");

  auto MIB = BuildMI(MBB, I, DL, get(Pseudo))
                 .addReg(DstReg, getDefRegState(true))
                 .addImm(0)
                 .addFrameIndex(FI)
                 .addImm(KVXMOD::VARIANT_);
  if (IsEpilogue)
    MIB.setMIFlag(MachineInstr::FrameDestroy);

  LLVM_DEBUG(dbgs() << "Created Load: "; MIB->dump());

  if (!IsEpilogue)
    return;

  if (Width == 1) {
    unsigned CFIIndex =
        MBB.getParent()->addFrameInst(MCCFIInstruction::createRestore(
            nullptr, TRI->getDwarfRegNum(DstReg, false)));

    BuildMI(MBB, MIB.getInstr()->getNextNode(), DL,
            get(TargetOpcode::CFI_INSTRUCTION))
        .addCFIIndex(CFIIndex)
        .setMIFlag(MachineInstr::FrameDestroy);
    return;
  }

  for (unsigned SR = 0; SR < Width; ++SR) {
    const uint16_t SubIndx[] = {KVX::sub_d0, KVX::sub_d1, KVX::sub_d2,
                                KVX::sub_d3};

    Register SubReg = TRI->getSubReg(DstReg, SubIndx[SR]);
    unsigned CFIIndex =
        MBB.getParent()->addFrameInst(MCCFIInstruction::createRestore(
            nullptr, TRI->getDwarfRegNum(SubReg, false)));

    MIB = BuildMI(MBB, MIB.getInstr()->getNextNode(), DL,
                  get(TargetOpcode::CFI_INSTRUCTION))
              .addCFIIndex(CFIIndex)
              .setMIFlag(MachineInstr::FrameDestroy);
  }
}

void KVXInstrInfo::storeRegToStackSlot(MachineBasicBlock &MBB,
                                       MachineBasicBlock::iterator I,
                                       Register SrcReg, bool IsKill, int FI,
                                       const TargetRegisterClass *RC,
                                       const TargetRegisterInfo *TRI,
                                       Register VReg) const {
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
    LLVM_DEBUG(dbgs() << "It is a RA register, using GET and SDp.\n");

    Register ScratchReg = findScratchRegister(MBB, false, KVX::R16);
    BuildMI(MBB, I, DL, get(KVX::GET), ScratchReg)
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

ScheduleHazardRecognizer *
KVXInstrInfo::CreateTargetMIHazardRecognizer(const InstrItineraryData *II,
                                             const ScheduleDAGMI *DAG) const {
  return new KVXHazardRecognizer(II, (const ScheduleDAG *)DAG);
}

size_t KVXInstrInfo::getBBSizeInBytes(const MachineBasicBlock &MBB) const {
  size_t Sz = 0;
  for (const auto &I : MBB)
    Sz += getInstSizeInBytes(I);

  return Sz;
}

/// Return size in bytes of MachineFunction.
size_t KVXInstrInfo::getFuncSizeInBytes(const MachineFunction &MF) const {
  size_t Sz = 0;
  for (const MachineBasicBlock &MBB : MF)
    for (const auto &I : MBB)
      Sz += getInstSizeInBytes(I);

  return Sz;
}

static bool parseCondBranch(MachineInstr &LastInst, MachineBasicBlock *&Target,
                            SmallVectorImpl<MachineOperand> &Cond) {
  // Block ends with fall-through condbranch.
  assert(LastInst.getDesc().isConditionalBranch() &&
         "Unknown conditional branch");
  LLVM_DEBUG(dbgs() << "Obtaining conditional branch BB and condition.\n");
  if (LastInst.getOperand(1).isMBB())
    Target = LastInst.getOperand(1).getMBB();
  else
    return true;
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

  // Handle tail calls
  switch (I->getOpcode()) {
  default:
    break;
  case KVX::CTAIL:
  case KVX::TAIL:
  case KVX::ITAIL:
    LLVM_DEBUG(dbgs() << "Can't analyse tail calls." << *I << ".\n");
    return true;
  }

  // Handle a single unconditional branch.
  if (NumTerminators == 1 && I->getDesc().isUnconditionalBranch()) {
    LLVM_DEBUG(dbgs() << "Single unconditional branch: " << *I << ".\n");

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

bool KVXInstrInfo::analyzeBranchPipeliner(MachineBasicBlock &MBB,
                                          MachineBasicBlock *&TBB,
                                          MachineBasicBlock *&FBB,
                                          SmallVectorImpl<MachineOperand> &Cond,
                                          bool AllowModify) const {
  MachineInstr *MI = &*MBB.instr_rbegin();
  if (MI->getOpcode() == KVX::ENDLOOP) {
    LLVM_DEBUG(dbgs() << "Hardware loop with ENDLOOP branch.\n");
    TBB = MI->getOperand(0).getMBB();
    FBB = MI->getOperand(1).getMBB();
    Cond.push_back(MachineOperand::CreateImm(KVX::ENDLOOP));
    Cond.push_back(MI->getOperand(0));
    Cond.push_back(MI->getOperand(1));
    Cond.push_back(MI->getOperand(2));
    return false;
  }

  return analyzeBranch(MBB, TBB, FBB, Cond, AllowModify);
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
  assert(Cond.size() <= 4 && Cond.size() != 2 &&
         "Unhandled size for Cond array");

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

  // ENDLOOP
  if (Cond.size() == 4 && Cond[0].isImm() && Cond[0].getImm() == KVX::ENDLOOP) {
    MachineInstr &MI = *BuildMI(&MBB, DL, get(KVX::ENDLOOP))
                            .addMBB(TBB)
                            .addMBB(FBB)
                            .add(Cond[3]); // Cond[3] is the MCSymbol
    if (BytesAdded)
      *BytesAdded += MI.getDesc().Size;
    return 1;
  }

  // Either a one or two-way conditional branch.
  unsigned Opc = Cond[0].getImm();
  MachineInstr &CondMI =
      *BuildMI(&MBB, DL, get(Opc))
           .addUse(Cond[1].getReg(), getKillRegState(Cond[1].isKill()),
                   Cond[1].getSubReg())
           .addMBB(TBB)
           .add(Cond[2]);
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

  if (I->getOpcode() == KVX::ENDLOOP) {
    if (BytesRemoved)
      *BytesRemoved = getInstSizeInBytes(*I);
    I->eraseFromParent();
    return 1;
  }

  if (!I->getDesc().isUnconditionalBranch() &&
      !I->getDesc().isConditionalBranch())
    return 0;

  if (BytesRemoved)
    *BytesRemoved = getInstSizeInBytes(*I);

  // Remove the last branch.
  I->eraseFromParent();

  I = MBB.end();

  if (I == MBB.begin())
    return 1;
  --I;
  if (!I->getDesc().isConditionalBranch())
    return 1;

  // Remove the CB
  if (BytesRemoved)
    *BytesRemoved += getInstSizeInBytes(*I);

  I->eraseFromParent();
  return 2;
}

bool KVXInstrInfo::reverseBranchCondition(
    SmallVectorImpl<MachineOperand> &Cond) const {
  if (Cond.size() != 3) {
    LLVM_DEBUG(dbgs() << "reverseBranchCondition: can't reverse\n");
    return true;
  }

  LLVM_DEBUG(dbgs() << "reverseBranchCondition: " << Cond[2].getImm());
  Cond[2].setImm(getOppositeBranchOpcode(Cond[2].getImm()));
  LLVM_DEBUG(dbgs() << " --> " << Cond[2].getImm() << '\n');
  return false;
}

bool KVXInstrInfo::isProlog(const MachineInstr *MI) const {
  if (MI->getFlag(MachineInstr::FrameSetup)) {
    switch (MI->getOpcode()) {
    case KVX::ADDDri10:
    case KVX::ADDDri37:
    case KVX::ADDDri64:
      if (MI->getOperand(0).getReg() == KVX::R12) // SP
        return true;
    }
  }
  return false;
}

bool KVXInstrInfo::isEpilog(const MachineInstr *MI) const {
  if (MI->getFlag(MachineInstr::FrameDestroy)) {
    switch (MI->getOpcode()) {
    case KVX::ADDDri10:
    case KVX::ADDDri37:
    case KVX::ADDDri64:
      if (MI->getOperand(1).getReg() == KVX::R12) // SP
        return true;
    }
  }
  return false;
}

bool KVXInstrInfo::isSoloInstruction(const MachineInstr &MI) const {
  if (MI.isInlineAsm() || MI.isDebugInstr() || MI.isCFIInstruction() ||
      MI.isLabel() || MI.isBundle())
    return true;

  if (MI.getNumOperands() > 0 && MI.getOperand(0).isReg() &&
      KVX::AloneRegRegClass.contains(MI.getOperand(0).getReg() &&
                                     MI.getOperand(0).isDef()))
    return true;

  if (MI.getDesc().implicit_defs().empty())
    return false;

  for (const MCPhysReg &ImpDef : MI.getDesc().implicit_defs())
    if (KVX::AloneRegRegClass.contains((Register)(ImpDef)))
      return true;

  return false;
}

/// Gets the position of the first memory operand
/// Returns -1 if the instruction has no memory operand
static int getFirstMemOpPos(const MachineInstr &MI) {
  assert(MI.mayLoadOrStore());

  // Some exceptions to the general rule..
  switch (MI.getOpcode()) {
  case KVX::DTOUCHLri10:
  case KVX::DTOUCHLri37:
  case KVX::DTOUCHLri64:
  case KVX::DTOUCHLrr:
  case KVX::DTOUCHLrrc:
  case KVX::DTOUCHLri27c:
  case KVX::DTOUCHLri54c:
    return 0;
  }

  return MI.mayLoad() ? 1 : 0;
}

// Get memory mod (like .xs or .u) from a memory instruction
// Need the position and the mask defined in KVXII
// Returns -1 if the mod could not be found
static int getMemMod(const MachineInstr &MI, unsigned Pos, unsigned Mask) {
  unsigned ModRelPos = llvm::KVXII::getKVXFlag(MI, Pos, Mask);

  if (!ModRelPos)
    return -1;

  int FirstMemOpPos = getFirstMemOpPos(MI);
  if (FirstMemOpPos < 0)
    return -1;

  unsigned ModPos = FirstMemOpPos + ModRelPos;
  return MI.getOperand(ModPos).getImm();
}

// Returns true if the instruction has .u modifier set.
// Uses the VariantModRelPos TSFlag
static bool hasUncachedVariant(const MachineInstr &MI) {
  int VariantVal =
      getMemMod(MI, KVXII::VariantModRelPosPos, KVXII::VariantModRelPosMask);
  if (VariantVal < 0)
    return false;
  return VariantVal == KVXMOD::VARIANT_U || VariantVal == KVXMOD::VARIANT_US;
}

bool KVXInstrInfo::isUncachedLoad(const MachineInstr *MI) const {
  if (!MI->mayLoad())
    return false;
  if (getKVXFlag(*MI, KVXII::AlwaysUncachedPos, KVXII::AlwaysUncachedMask))
    return true;
  return hasUncachedVariant(*MI);
}

// A cached access takes 3 cycles at best case
// An uncached access takes 22 cycles at best case: penalty of 19 cycles
// On CV1, the penalty is 20 cycles
unsigned KVXInstrInfo::getUncachedPenalty(void) const {
  if (Subtarget.isV1())
    return 20;
  return 19;
}

bool KVXInstrInfo::isSchedulingBoundary(const MachineInstr &MI,
                                        const MachineBasicBlock *MBB,
                                        const MachineFunction &MF) const {
  switch (MI.getOpcode()) {
  case KVX::ENDLOOP:
  case KVX::LOOPDO:
  case TargetOpcode::EH_LABEL:
    return true;
  case KVX::COPY: {
    return MI.getOperand(1).isMetadata() ||
           Subtarget.getRegisterInfo()->isVolatilePhysReg(
               MI.getOperand(1).getReg());
  }
  default:
    break;
  }
  return TargetInstrInfo::isSchedulingBoundary(MI, MBB, MF);
}

bool KVXInstrInfo::isSchedulingBoundaryPostRA(const MachineInstr &MI,
                                              const MachineBasicBlock *MBB,
                                              const MachineFunction &MF) const {
  // Relax scheduling boundary for epilog and prolog.
  // This is required to have bundling at the beginning and end of functions.
  if (isProlog(&MI) || isEpilog(&MI))
    return false;

  return TargetInstrInfo::isSchedulingBoundaryPostRA(MI, MBB, MF);
}

/// Returns true if the memory instruction only has base operand
/// Uses the hasNoOffset TSFlag
static bool hasOnlyBaseMemOp(const MachineInstr &MI) {
  unsigned F = MI.getDesc().TSFlags;
  return (F >> KVXII::hasNoOffsetPos & 1);
}

static bool getBaseAndOffsetPositionGeneric(const MachineInstr &MI,
                                            unsigned &BasePos,
                                            unsigned &OffsetPos) {
  if (!MI.mayLoadOrStore() || hasOnlyBaseMemOp(MI))
    return false;

  int FirstMemOpPos = getFirstMemOpPos(MI);
  if (FirstMemOpPos < 0)
    return false;

  OffsetPos = FirstMemOpPos;
  BasePos = OffsetPos + 1;

  return true;
}

// Used by MachinePipeliner
bool KVXInstrInfo::getBaseAndOffsetPosition(const MachineInstr &MI,
                                            unsigned &BasePos,
                                            unsigned &OffsetPos) const {
  if (!getBaseAndOffsetPositionGeneric(MI, BasePos, OffsetPos))
    return false;

  // Check that they are indeed registers to prevent cases such as
  // (LWZp 0, %stack.0.x) messing with MachinePipeliner
  if (!MI.getOperand(BasePos).isReg() || !MI.getOperand(OffsetPos).isReg())
    return false;

  return true;
}

/// Gets the width of the memory access.
/// Uses the MemoryAccessWidth TSFlag
static bool getMemWidth(const MachineInstr &MI, LocationSize &Width) {
  unsigned WidthType =
      getKVXFlag(MI, KVXII::MemAccessSizePos, KVXII::MemAccessSizeMask);

  if (!WidthType)
    return false;

  Width = 1 << (WidthType - 1);
  return true;
}

/// Returns true if the instruction has .xs modifier set.
/// Uses the XSModRelPos TSFlag
static bool hasXSMod(const MachineInstr &MI) {
  int XSModVal = getMemMod(MI, KVXII::XSModRelPosPos, KVXII::XSModRelPosMask);
  if (XSModVal < 0)
    return false;
  return XSModVal == KVXMOD::DOSCALE_XS;
}

bool KVXInstrInfo::getMemOperandsWithOffsetWidth(
    const MachineInstr &MI, SmallVectorImpl<const MachineOperand *> &BaseOps,
    int64_t &Offset, bool &OffsetIsScalable, LocationSize &Width,
    const TargetRegisterInfo *TRI) const {

  unsigned BasePos, OffsetPos;

  OffsetIsScalable = hasXSMod(MI);

  if (!getMemWidth(MI, Width))
    return false;

  // Only base register -> offset is 0
  if (hasOnlyBaseMemOp(MI)) {
    Offset = 0;

    int FirstMemOpPos = getFirstMemOpPos(MI);
    if (FirstMemOpPos < 0)
      return false;

    BasePos = FirstMemOpPos;
    BaseOps.push_back(&MI.getOperand(BasePos));
    return true;
  }

  if (!getBaseAndOffsetPositionGeneric(MI, BasePos, OffsetPos))
    return false;

  // We are unable to get an immediate for the offset since it is a register
  if (MI.getOperand(OffsetPos).isReg())
    return false;

  BaseOps.push_back(&MI.getOperand(BasePos));
  Offset = MI.getOperand(OffsetPos).getImm();
  return true;
}

bool KVXInstrInfo::areMemAccessesTriviallyDisjoint(
    const MachineInstr &MI1, const MachineInstr &MI2) const {

  assert(MI1.mayLoadOrStore() && MI2.mayLoadOrStore());

  if (MI1.hasUnmodeledSideEffects() || MI2.hasUnmodeledSideEffects() ||
      MI1.hasOrderedMemoryRef() || MI2.hasOrderedMemoryRef())
    return false;

  SmallVector<const MachineOperand *, 1> BaseOp1{}, BaseOp2{};
  int64_t Offset1, Offset2;
  bool OffsetIsScalable1, OffsetIsScalable2;
  LocationSize Width1(0), Width2(0);

  if (!getMemOperandsWithOffsetWidth(MI1, BaseOp1, Offset1, OffsetIsScalable1,
                                     Width1, nullptr))
    return false;

  if (OffsetIsScalable1)
    Offset1 *= Width1.getValue();

  if (!getMemOperandsWithOffsetWidth(MI2, BaseOp2, Offset2, OffsetIsScalable2,
                                     Width2, nullptr))
    return false;

  if (OffsetIsScalable2)
    Offset2 *= Width2.getValue();

  assert(BaseOp1.size() == 1 && BaseOp2.size() == 1 &&
         "More than 1 base operand not supported");

  // Must be the same base register to prove disjointness
  if (BaseOp1.front()->getReg() != BaseOp2.front()->getReg())
    return false;

  int64_t LowOffset = std::min(Offset1, Offset2);
  int64_t HighOffset = std::max(Offset1, Offset2);
  int64_t LowWidth = (LowOffset == Offset1) ? Width1.getValue() : Width2.getValue();

  return (LowOffset + LowWidth <= HighOffset);
}

bool KVXInstrInfo::getIncrementValue(const MachineInstr &MI, int &Value) const {
  switch (MI.getOpcode()) {
  case KVX::ADDDri10:
  case KVX::ADDDri37:
  case KVX::ADDWri10:
  case KVX::ADDWri37:
    break;
  default:
    return false;
  }

  int64_t Imm = MI.getOperand(2).getImm();
  assert(isInt<32>(Imm) && "Increment value should not be more than 32 bits");
  if (!isInt<32>(Imm))
    return false;

  Value = Imm;
  return true;
}

// MachinePipeliner debug
#define MP_DEBUG(expr)                                                         \
  DEBUG_WITH_TYPE("pipeliner", dbgs() << "KVX pipelining: " << expr)

/// Holds information about trip count on our target
class KVXTripCount {
  /// Instruction defining the trip-count value
  MachineInstr *DefMI;
  /// The LOOPDO instruction
  MachineInstr *LoopdoMI;
  /// The actual trip-count value if known statically
  std::optional<int> TC;

  const KVXInstrInfo *TII;
  MachineBasicBlock *TripCountBB;
  MachineFunction *MF;

public:
  /// Create a KVXTripCount from the instruction defining it.
  /// If that instruction is a MAKE the trip count is known statically
  KVXTripCount(MachineInstr *DefMI, MachineInstr *LoopdoMI,
               const KVXInstrInfo *TII)
      : DefMI(DefMI), LoopdoMI(LoopdoMI), TII(TII),
        TripCountBB(DefMI->getParent()), MF(TripCountBB->getParent()) {
    MP_DEBUG("Analyzing trip count with this DefMI: "; DefMI->dump());
    assert(DefMI->getOpcode() != KVX::MAKEi64 && "Unexpected MAKEi64");
    switch (DefMI->getOpcode()) {
    case KVX::MAKEi16:
    case KVX::MAKEi43:
      int64_t Imm = DefMI->getOperand(1).getImm();
      assert(isInt<32>(Imm));
      TC = Imm;
      return;
    }

    MP_DEBUG("Not a MAKE: we do not know the value statically\n");
    TC = {};
  }

  /// Return true/false if the trip count is greater/lower than Val.
  /// nullopt if the trip count is not known statically
  std::optional<bool> isGreaterThan(int Val) {
    if (!TC.has_value())
      return {};
    return TC > Val;
  }

  /// Get the register holding the trip-count value
  Register getReg() { return DefMI->getOperand(0).getReg(); }

  /// Smartly adjust the trip-count value by OriginalTC + Value:
  ///   - If the value is statically known (from a MAKE), just change it
  ///   - If the value was produced from an ADDDri, add the adjustment to the
  ///     immediate
  ///   - Else, generate an ADDDri to perform the adjustment
  ///
  /// The new trip-count value is stored in a fresh register to avoid breaking
  /// code in the case where the trip-count value register is used more than
  /// once.
  void adjust(int Value) {
    // Value known statically: just modify it.
    if (TC.has_value()) {
      int NewTC = TC.value() + Value;
      TC = NewTC;

      auto DefMII = DefMI->getIterator();
      DefMI = MF->CloneMachineInstr(DefMI);
      TripCountBB->insert(DefMII, DefMI);

      Register Fresh =
          MF->getRegInfo().createVirtualRegister(&KVX::SingleRegRegClass);
      DefMI->getOperand(0).setReg(Fresh);
      LoopdoMI->getOperand(0).setReg(Fresh);

      modifyImmediate(DefMI, 1, NewTC,
                      {KVX::MAKEi16, KVX::MAKEi43, KVX::MAKEi64}, {16, 43, 64});

      return;
    }

    // Value not known statically.
    // If it is defined by an ADDDri, we can adjust the immediate
    switch (DefMI->getOpcode()) {
    case KVX::ADDDri10:
    case KVX::ADDDri37:
    case KVX::ADDDri64:
      int64_t NewValue = DefMI->getOperand(2).getImm() + Value;

      auto DefMII = DefMI->getIterator();
      DefMI = MF->CloneMachineInstr(DefMI);
      TripCountBB->insert(DefMII, DefMI);

      Register Fresh =
          MF->getRegInfo().createVirtualRegister(&KVX::SingleRegRegClass);
      DefMI->getOperand(0).setReg(Fresh);
      LoopdoMI->getOperand(0).setReg(Fresh);

      modifyImmediate(DefMI, 2, NewValue,
                      {KVX::ADDDri10, KVX::ADDDri37, KVX::ADDDri64},
                      {10, 37, 64});
      return;
    }

    // Nothing is known: build an ADDDri to make the adjustment
    unsigned Opcode = isInt<10>(Value) ? KVX::ADDDri10 : KVX::ADDDri37;
    Register NewTC =
        MF->getRegInfo().createVirtualRegister(&KVX::SingleRegRegClass);
    MachineInstr *NewDefMI =
        BuildMI(*MF, DefMI->getDebugLoc(), TII->get(Opcode), NewTC)
            .addReg(DefMI->getOperand(0).getReg())
            .addImm(Value);

    if (DefMI->isPHI()) {
      /* We cannot insert in the middle of PHI instructions: we must skip them
       */
      auto Where = TripCountBB->SkipPHIsAndLabels(DefMI->getIterator());
      /* All PHIs (including DefMI) have been skipped. We can insert just
       * there.*/
      TripCountBB->insert(Where, NewDefMI);
    } else
      TripCountBB->insertAfter(DefMI->getIterator(), NewDefMI);

    DefMI = NewDefMI;
    LoopdoMI->getOperand(0).setReg(NewTC);
  }

private:
  /// Change the immediate-operand ImmOp of MI to NewValue.
  /// If the new value is adapted to the immediate format, just modify it.
  /// If it is not, replace MI with a clone that has the new opcode and the new
  /// value.
  /// OPri and BitLimits must be sorted from smallest to highest.
  void modifyImmediate(MachineInstr *&MI, unsigned ImmOp, int64_t NewValue,
                       std::vector<unsigned> OPri,
                       std::vector<unsigned> BitLimits) {
    assert(MI->getOperand(ImmOp).isImm() && "No immediate operand found!");

    unsigned NewOpcode = -1;
    unsigned NumBits = APInt(64, NewValue).getActiveBits();
    for (int I = 0; I < static_cast<int>(BitLimits.size()); I++) {
      if (NumBits <= BitLimits[I]) {
        NewOpcode = OPri[I];
        break;
      }
    }
    assert(NewOpcode != -1u && "Could not find a fitting format");

    if (NewOpcode == MI->getOpcode()) {
      // No need to change the opcode: just modify the instruction in place
      MI->getOperand(ImmOp).setImm(NewValue);
      return;
    }

    // Clone the MI, then set the immediate to the new value
    MachineInstr *NewMI = MF->CloneMachineInstr(MI);
    NewMI->getOperand(ImmOp).setImm(NewValue);
    TripCountBB->insertAfter(MI->getIterator(), NewMI);
    MI->eraseFromParent();
    MI = NewMI;
  }
};

/// Scans the preheader to find the LOOPDO instruction and the instruction
/// definining the trip count.
static bool scanPreheader(MachineBasicBlock *Preheader,
                          MachineInstr *&LoopInstr,
                          MachineInstr *&TripCountDef) {
  if (!Preheader) {
    MP_DEBUG("no preheader was given to scan");
    return false;
  }

  if (!Preheader->size()) {
    MP_DEBUG("the preheader is empty, nothing to scan");
    return false;
  }

  // Find the trip-count register: the one used by LOOPDO
  // LOOPDO should be the first terminator of the Preheader
  auto FirstTerminatorII = Preheader->getFirstTerminator();
  if (FirstTerminatorII == Preheader->end()) {
    MP_DEBUG("No LOOPDO found in preheader");
    return false;
  }

  LoopInstr = &*FirstTerminatorII;
  if (LoopInstr->getOpcode() != KVX::LOOPDO) {
    MP_DEBUG("The first terminator of the preheader is not a LOOPDO");
    return false;
  }
  Register TripCountReg = LoopInstr->getOperand(0).getReg();

  // Find the instruction defining the trip-count reg
  // Start from Preheader, then seek upwards the predecessor blocks
  SmallVector<MachineBasicBlock *, 4> ToExploreBBs = {Preheader};
  SmallSet<MachineBasicBlock *, 4> ExploredBBs = {};
  while (!ToExploreBBs.empty()) {
    MachineBasicBlock *ToExploreBB = ToExploreBBs.pop_back_val();
    for (auto II = ToExploreBB->instr_rbegin(); II != ToExploreBB->instr_rend();
         II++) {
      if (!II->getNumOperands())
        continue;
      MachineOperand &MO = II->getOperand(0);
      if (MO.isReg() && MO.isDef() && MO.getReg() == TripCountReg) {
        TripCountDef = &*II;
        return true;
      }
    }
    ExploredBBs.insert(ToExploreBB);
    for (auto *MBB : ToExploreBB->predecessors())
      if (!ExploredBBs.contains(MBB))
        ToExploreBBs.push_back(MBB);
  }

  MP_DEBUG("could not find the instruction defining the trip-count reg\n");
  return false;
}

class KVXPipelinerLoopInfo : public TargetInstrInfo::PipelinerLoopInfo {
  MachineFunction *MF;
  const KVXInstrInfo *TII;
  KVXTripCount TC;
  MachineInstr *LoopdoMI;
  DebugLoc DL;

public:
  /// KVXPipelinerLoopInfo constructor.
  /// TripCountDefMI: instruction defining the trip count
  KVXPipelinerLoopInfo(MachineFunction *MF, MachineInstr *TripCountDefMI,
                       MachineInstr *LoopdoMI)
      : MF(MF), TII(MF->getSubtarget<KVXSubtarget>().getInstrInfo()),
        TC(TripCountDefMI, LoopdoMI, TII), LoopdoMI(LoopdoMI),
        DL(LoopdoMI->getDebugLoc()) {}

  /// Not used by LLVM. Dead code.
  bool shouldIgnoreForPipelining(const MachineInstr *MI) const override {
    return false;
  };

  /// Returns true (or false) if the loop trip count is greater (or not)
  /// than TC.
  /// Returns nullopt if the trip count is not known statically.
  /// In that case, generates a COMPD for the comparison and fill Cond with
  /// operands to be later used in TII->insertBranch
  std::optional<bool> createTripCountGreaterCondition(
      int TC, MachineBasicBlock &MBB,
      SmallVectorImpl<MachineOperand> &Cond) override {
    std::optional<bool> IsGT = this->TC.isGreaterThan(TC);
    if (IsGT.has_value()) {
      return IsGT;
    }

    Register CompReg =
        MF->getRegInfo().createVirtualRegister(&KVX::SingleRegRegClass);

    unsigned CompOp = isInt<10>(TC) ? KVX::COMPDri10 : KVX::COMPDri37;
    MachineInstr *Compare =
        BuildMI(&MBB, DL, TII->get(CompOp), CompReg)
            .addReg(this->TC.getReg())
            .addImm(TC)
            .addImm(static_cast<int>(KVX::ComparisonMod::GT));

    Cond.push_back(MachineOperand::CreateImm(KVX::CB));
    Cond.push_back(Compare->getOperand(0));
    Cond.push_back(
        MachineOperand::CreateImm(static_cast<int>(KVX::ScalarcondMod::EVEN)));

    return {};
  }

  void adjustTripCount(int TripCountAdjust) override {
    TC.adjust(TripCountAdjust);
  }

  void setPreheader(MachineBasicBlock *NewPreheader) override {
    auto II = NewPreheader->getFirstTerminator();

    if (II->getOpcode() == KVX::CB) {
      // Normally, the LOOPDO should be inserted between the CB and the last
      // terminator: CB; LOOPDO; GOTO;
      // But that does not behave well with register allocation when the
      // loop-count is spilled.
      // To prevent that, we create a fresh basic block to insert the LOOPDO

      /** Create a FreshBB and place the LOOPDO inside */
      MachineBasicBlock *FreshBB = MF->CreateMachineBasicBlock();
      MachineBasicBlock *FallthroughBB = NewPreheader->getFallThrough();
      MF->insert(FallthroughBB->getIterator(), FreshBB);
      FreshBB->splice(FreshBB->instr_begin(), LoopdoMI->getParent(), LoopdoMI);

      /** Transform NewPreheader -> Fallthrough into NewPreheader -> Fresh ->
       * Fallthrough */
      NewPreheader->replaceSuccessor(FallthroughBB, FreshBB);
      FreshBB->addSuccessor(FallthroughBB, BranchProbability::getOne());

      /** Possibly modify GOTO from NewPreheader to point to FreshBB */
      MachineInstr *LastMI = &*NewPreheader->instr_rbegin();
      if (LastMI->getOpcode() == KVX::GOTO)
        LastMI->getOperand(0).setMBB(FreshBB);

      /** Update PHI instructions from FallthroughBB, as we just changed its
       * predecessor */
      for (auto &Phi : FallthroughBB->phis())
        for (auto &Op : Phi.operands())
          if (Op.isMBB() && Op.getMBB() == NewPreheader)
            Op.setMBB(FreshBB);

      return;
    }

    NewPreheader->splice(II, LoopdoMI->getParent(), LoopdoMI);
  }

  void disposed() override { LoopdoMI->eraseFromParent(); }
};

std::unique_ptr<TargetInstrInfo::PipelinerLoopInfo>
KVXInstrInfo::analyzeLoopForPipelining(MachineBasicBlock *LoopBB) const {

  if (LoopBB->pred_size() != 2) {
    MP_DEBUG("LoopBB must have exactly two predecessors: itself and the "
             "preheader\n");
    return nullptr;
  }

  if (LoopBB->size() > 10000) {
    MP_DEBUG("LoopBB is too big: " << LoopBB->size() << " > 10000\n");
    return nullptr;
  }

  auto PredIter = LoopBB->predecessors().begin();
  if (*PredIter == LoopBB)
    PredIter++;
  MachineBasicBlock *PreheaderBB = *PredIter;
  assert(PreheaderBB != LoopBB);

  MachineInstr *LoopdoMI, *TripCountMI;
  if (!scanPreheader(PreheaderBB, LoopdoMI, TripCountMI)) {
    MP_DEBUG("unable to scan preheader\n");
    return nullptr;
  }

  return std::make_unique<KVXPipelinerLoopInfo>(LoopBB->getParent(),
                                                TripCountMI, LoopdoMI);
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
  DEBUG_WITH_TYPE("if-converter", dbgs() << "IsPredicable? " << MI);
  if (MI.isPredicable() &&
      PredicateInstruction(const_cast<MachineInstr &>(MI), {})) {
    DEBUG_WITH_TYPE("if-converter", dbgs() << "true\n");
    return true;
  }
  DEBUG_WITH_TYPE("if-converter", dbgs() << "false\n");
  return false;
}

bool KVXInstrInfo::isPredicated(const MachineInstr &MI) const {
  DEBUG_WITH_TYPE("if-converter", dbgs() << "IsPredicated? " << MI);

  // A predicable instruction is not predicated
  if (MI.isPredicable()) {
    DEBUG_WITH_TYPE("if-converter", dbgs() << "false\n");
    return false;
  }
  switch (MI.getOpcode()) {
  // A CMOVED is predicated
  case KVX::CMOVEDri10:
  case KVX::CMOVEDri37:
  case KVX::CMOVEDri64:
  case KVX::CMOVEDrr:
    DEBUG_WITH_TYPE("if-converter", dbgs() << "true\n");
    return true;
  // The remaining mem instructions are predicated
  default:
    DEBUG_WITH_TYPE(
        "if-converter",
        dbgs() << ((MI.mayLoad() || MI.mayStore()) ? "true\n" : "false\n"));
    return MI.mayLoad() || MI.mayStore();
  }
}

bool KVXInstrInfo::canInsertSelect(const MachineBasicBlock &MBB,
                                   ArrayRef<MachineOperand> Cond,
                                   Register DstReg, Register TrueReg,
                                   Register FalseReg, int &CondCycles,
                                   int &TrueCycles, int &FalseCycles) const {
  DEBUG_WITH_TYPE("if-converter", dbgs() << "canInsertSelect? ");

  if (!(DstReg.isVirtual() == TrueReg.isVirtual() &&
        DstReg.isVirtual() == FalseReg.isVirtual()))
    report_fatal_error(
        "Error: Insert select with mixed real/virtual registers.\n");

  if (!DstReg.isVirtual()) {
    if (!(KVX::SingleRegRegClass.contains(DstReg) ||
          KVX::PairedRegRegClass.contains(DstReg) ||
          KVX::QuadRegRegClass.contains(DstReg)))
      return false;
  } else {
    const auto *RClass = MBB.getParent()->getRegInfo().getRegClass(DstReg);
    if (!(&KVX::SingleRegRegClass == RClass ||
          &KVX::PairedRegRegClass == RClass || &KVX::QuadRegRegClass == RClass))
      return false;
  }

  CondCycles = FalseCycles = 1;
  // If we are comparing a value to zero, we don't need
  // a comparison instruction
  if (Cond[2].isCImm() && Cond[2].getCImm()->isZero())
    CondCycles = 0;

  DEBUG_WITH_TYPE("if-converter", dbgs() << "true\n");
  return true;
}

void KVXInstrInfo::insertSelect(MachineBasicBlock &MBB,
                                MachineBasicBlock::iterator I,
                                const DebugLoc &DL, Register DstReg,
                                ArrayRef<MachineOperand> Cond, Register TrueReg,
                                Register FalseReg) const {

  DEBUG_WITH_TYPE("if-converter", dbgs() << "InsertSelect\n");
  DEBUG_WITH_TYPE("if-converter", dbgs() << "I: "; I->dump());
  DEBUG_WITH_TYPE("if-converter", dbgs() << "DstReg:" << DstReg << '\n');
  DEBUG_WITH_TYPE("if-converter", dbgs() << "TrueReg:" << TrueReg << '\n');
  DEBUG_WITH_TYPE("if-converter", dbgs() << "FalseReg:" << FalseReg << '\n');
  DEBUG_WITH_TYPE("if-converter", dbgs() << "Cond:");
  DEBUG_WITH_TYPE("if-converter", for (auto &V : Cond) V.dump(););

  auto Mop = Cond[1];
  Mop.setIsKill(false);

  if (DstReg.isVirtual()) {
    MachineRegisterInfo &MRI = MBB.getParent()->getRegInfo();
    if (&KVX::SingleRegRegClass == MRI.getRegClass(DstReg)) {
      BuildMI(MBB, I, DL, get(KVX::CMOVEDrr), DstReg)
          .add(Mop)
          .addReg(FalseReg)
          .addReg(TrueReg)
          .add(Cond[2]);
      return;
    }
    if (&KVX::PairedRegRegClass == MRI.getRegClass(DstReg)) {
      for (auto Sub : {KVX::sub_d0, KVX::sub_d1})
        BuildMI(MBB, I, DL, get(KVX::CMOVEDrr))
            .addReg(DstReg, RegState::Define, Sub)
            .add(Mop)
            .addReg(FalseReg, 0, Sub)
            .addReg(TrueReg, 0, Sub)
            .add(Cond[2]);
      return;
    }
    if (&KVX::QuadRegRegClass == MRI.getRegClass(DstReg)) {
      for (auto Sub : {KVX::sub_d0, KVX::sub_d1, KVX::sub_d2, KVX::sub_d3})
        BuildMI(MBB, I, DL, get(KVX::CMOVEDrr))
            .addReg(DstReg, RegState::Define, Sub)
            .add(Mop)
            .addReg(FalseReg, 0, Sub)
            .addReg(TrueReg, 0, Sub)
            .add(Cond[2]);
      return;
    }
    report_fatal_error("Unhandled virtual register type for select.\n");
  }
  if (KVX::SingleRegRegClass.contains(DstReg)) {
    BuildMI(MBB, I, DL, get(KVX::CMOVEDrr), DstReg)
        .add(Mop)
        .addReg(FalseReg)
        .addReg(TrueReg)
        .add(Cond[2]);
    return;
  }
  const KVXRegisterInfo *TRI = Subtarget.getRegisterInfo();
  if (KVX::PairedRegRegClass.contains(DstReg)) {
    for (auto Sub : {KVX::sub_d0, KVX::sub_d1}) {
      BuildMI(MBB, I, DL, get(KVX::CMOVEDrr))
          .addReg(TRI->getSubReg(DstReg, Sub), RegState::Define)
          .add(Mop)
          .addReg(TRI->getSubReg(FalseReg, Sub))
          .addReg(TRI->getSubReg(TrueReg, Sub))
          .add(Cond[2]);
    }
    return;
  }
  if (KVX::QuadRegRegClass.contains(DstReg)) {
    for (auto Sub : {KVX::sub_d0, KVX::sub_d1, KVX::sub_d2, KVX::sub_d3}) {
      BuildMI(MBB, I, DL, get(KVX::CMOVEDrr))
          .addReg(TRI->getSubReg(DstReg, Sub), RegState::Define)
          .add(Mop)
          .addReg(TRI->getSubReg(FalseReg, Sub))
          .addReg(TRI->getSubReg(TrueReg, Sub))
          .add(Cond[2]);
    }
    return;
  }
  report_fatal_error("Unhandled real register type for select.\n");
}

// TODO: Better understand what are the possible costs here.
unsigned KVXInstrInfo::getPredicationCost(const MachineInstr &MI) const {
  DEBUG_WITH_TYPE("if-converter", dbgs() << "getPredicationCost for: ");
  DEBUG_WITH_TYPE("if-converter", MI.dump());

  return 0;
}

/// Calculate number of instructions excluding the debug instructions.
static unsigned nonDbgMICount(const MachineBasicBlock &BB) {
  unsigned Count = 0;
  for (auto MIB = BB.instr_begin(), MIE = BB.instr_end(); MIB != MIE; ++MIB)
    if (!MIB->isDebugInstr())
      ++Count;

  return Count;
}

// A branch has cost of 2 cycles stall. So only if-convert if we have
// no more than 2 instructions to predicate.
// FIXME: if-convert fails to detect instructions that clobber the
// predicate condition value, so we limit it to single instruction
// that writes to a register and it must be the last instruction.
bool KVXInstrInfo::isProfitableToIfCvt(MachineBasicBlock &MBB,
                                       unsigned NumCycles,
                                       unsigned ExtraPredCycles,
                                       BranchProbability Probability) const {
  if (nonDbgMICount(MBB) > 2)
    return false;

  bool OneDefines = false;
  for (const auto &I : MBB) {
    if (I.isDebugInstr() || !I.getNumExplicitDefs())
      continue;

    if (OneDefines)
      return false;

    OneDefines = true;
  }
  return true;
}

bool KVXInstrInfo::PredicateInstruction(MachineInstr &MI,
                                        ArrayRef<MachineOperand> Pred) const {
  DEBUG_WITH_TYPE("if-converter", dbgs() << "PredicateInstruction: ");
  DEBUG_WITH_TYPE("if-converter", MI.dump());
  assert(!isPredicated(MI) &&
         "Can't predicate an already predicated instruction");
  unsigned Oprrc, Opri27c, Opri54c;
  bool IsRR = false;
  bool IsInplace = false;
  int IsBranchToCB = 0;
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
  case KVX::LVrrcs:
    IsRR = true;
    LLVM_FALLTHROUGH;
  case KVX::LVri10cs:
  case KVX::LVri37cs:
  case KVX::LVri64cs:
    IsInplace = true;
    Oprrc = KVX::LVrrccs;
    Opri27c = KVX::LVri27ccs;
    Opri54c = KVX::LVri54ccs;
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
  case KVX::XLOrrq:
    IsRR = true;
    LLVM_FALLTHROUGH;
  case KVX::XLOri10:
  case KVX::XLOri37:
  case KVX::XLOri64:
    Oprrc = KVX::XLOrrc;
    Opri27c = KVX::XLOri27c;
    Opri54c = KVX::XLOri54c;
    break;
  case KVX::XLOrr:
    IsRR = true;
    LLVM_FALLTHROUGH;
  case KVX::XLOri10q:
  case KVX::XLOri37q:
  case KVX::XLOri64q:
    Oprrc = KVX::XLOrrcq;
    Opri27c = KVX::XLOri27cq;
    Opri54c = KVX::XLOri54cq;
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
  case KVX::XSOrr:
    IsRR = true;
    LLVM_FALLTHROUGH;
  case KVX::XSOri10:
  case KVX::XSOri37:
  case KVX::XSOri64:
    Oprrc = KVX::XSOrrc;
    Opri27c = KVX::XSOri27c;
    Opri54c = KVX::XSOri54c;
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
  case KVX::TAIL:
    if (!KVXCondTailCall.getValue())
      return false;
    ++IsBranchToCB;
    LLVM_FALLTHROUGH;
  case KVX::GOTO:
    if (Pred.empty())
      return true;
    ++IsBranchToCB;
    break;
  }
  DEBUG_WITH_TYPE("if-converter", dbgs() << "Checking if we can predicate: ";
                  MI.dump());
  if (IsBranchToCB) {
    DEBUG_WITH_TYPE("if-converter",
                    dbgs() << "if-converting goto/tailcall to cb.\n");
    if (Pred[0].getImm() != KVX::CB)
      report_fatal_error("Predicate does not come from a CB.\n");

    auto To = MI.getOperand(0);
    while (MI.getNumOperands())
      MI.removeOperand(0);

    MI.setDesc(get(IsBranchToCB == 1 ? KVX::CB : KVX::CTAIL));
    MI.addOperand(Pred[1]);
    MI.addOperand(To);
    MI.addOperand(Pred[2]);
    DEBUG_WITH_TYPE("if-converter", dbgs() << "if-converted goto/tailcall to:";
                    MI.dump(););
    return true;
  }
  unsigned NewOpcode = 0;
  bool MustRemoveOffset = false;
  // TODO: Allow to predicate register copy and MAKE operations
  if (IsRR) {
    auto DoScale = MI.getOperand(MI.mayLoad() ? 4 : 3);
    if (!DoScale.isImm() || DoScale.getImm() != 0) {
      DEBUG_WITH_TYPE(
          "if-converter",
          dbgs() << "TODO: Allow predicated load/store with scaled offset.\n");
      return false;
    }
    auto Offset = MI.getOperand(MI.mayLoad() ? 1 : 0);
    if (!Offset.isImm() || Offset.getImm() != 0) {
      DEBUG_WITH_TYPE(
          "if-converter",
          dbgs() << "TODO: Allow predicated rr load with non-zero offset.\n");
      return false;
    }
    NewOpcode = Oprrc;
  } else {
    auto Imm = MI.getOperand(MI.mayLoad() ? 1 : 0);
    if (!Imm.isImm()) {
      DEBUG_WITH_TYPE("if-converter", MI.dump());
      report_fatal_error("Expected an immediate value as offset.\n");
    }
    int64_t Val = Imm.getImm();
    if (Val == 0) {
      NewOpcode = Oprrc;
      MustRemoveOffset = true;
      DEBUG_WITH_TYPE("if-converter",
                      dbgs() << "Offset is zero, can use rrc variant.\n");
    } else if (isInt<27>(Val)) {
      NewOpcode = Opri27c;
      DEBUG_WITH_TYPE("if-converter", dbgs() << "Offset fits 27 bits.\n");
    } else if (isInt<54>(Val)) {
      DEBUG_WITH_TYPE("if-converter", dbgs() << "Offset fits 54 bits.\n");
      NewOpcode = Opri54c;
    } else {
      DEBUG_WITH_TYPE(
          "if-converter",
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
    // TODO: Allow predicating register copies into cmoves.

    // Remove doScale argument
    MI.removeOperand(MI.mayLoad() ? 4 : 3);
    // Remove zero offset operand
    MI.removeOperand(MI.mayLoad() ? 1 : 0);
  } else if (MustRemoveOffset)
    MI.removeOperand(MI.mayLoad() ? 1 : 0);

  MI.setDesc(get(NewOpcode));

  // If we may load, our last register is used to tell the reg-alloc that
  // the register we are writting to is also used as argument, as it may
  // live through. However at this position the compiler does not provide
  // yet which is the register containing the value if we do not perform
  // the operation (load e.g). To avoid the machine verifier, we do set it
  // as undef.
  if (MI.mayLoad() && !IsInplace) {
    MachineRegisterInfo &MRI = MI.getParent()->getParent()->getRegInfo();
    Register R = MI.getOperand(0).getReg();
    if (R.isVirtual()) {
      auto VR =
          MRI.createVirtualRegister(MRI.getRegClass(MI.getOperand(0).getReg()));
      BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), get(KVX::IMPLICIT_DEF),
              VR);
      MachineInstrBuilder(*MI.getParent()->getParent(), MI)
          .addReg(VR, RegState::Undef)
          .addImm(Pred[2].getImm())
          .addReg(Pred[1].getReg());
    } else {
      MachineInstrBuilder(*MI.getParent()->getParent(), MI)
          .addReg(R, RegState::InternalRead)
          .addImm(Pred[2].getImm())
          .addReg(Pred[1].getReg());
    }
  } else {
    MachineInstrBuilder(*MI.getParent()->getParent(), MI)
        .addImm(Pred[2].getImm())
        .addReg(Pred[1].getReg());
  }
  DEBUG_WITH_TYPE("if-converter", dbgs() << "Predicated instruction now is: ";
                  MI.dump());
  return true;
}

unsigned KVXInstrInfo::getInstSizeInBytes(const MachineInstr &MI) const {
  if (MI.isBundle()) {
    MachineBasicBlock::const_instr_iterator I = MI.getIterator();
    unsigned Size = 0;
    while (I->isBundledWithSucc()) {
      ++I;
      Size += getInstSizeInBytes(*I);
    }

    return Size;
  }

  if (MI.isMetaInstruction())
    return 0;

  if (MI.getOpcode() == ISD::INLINEASM)
    return std::max((unsigned)(MI.getDesc().Size), 4U);

  return MI.getDesc().Size;
}

// TODO: Evaluate when it is profitable. Just be optimistic now for enabling
// if-conversion
bool KVXInstrInfo::isProfitableToDupForIfCvt(
    MachineBasicBlock &MBB, unsigned NumCycles,
    BranchProbability Probability) const {
  return true;
}

/// Returns true if the first specified predicate
/// subsumes the second, e.g. GE subsumes GT,
/// in other words, Pred2 -> Pred1 or |Pred1| contains |Pred2|.
bool KVXInstrInfo::SubsumesPredicate(ArrayRef<MachineOperand> Pred1,
                                     ArrayRef<MachineOperand> Pred2) const {
  // Be conservative. Only test if the instructions Pred[0] are the same and
  // from a CB
  if (Pred1[0].getImm() != Pred2[0].getImm() || Pred1[0].getImm() != KVX::CB ||
      Pred1[1].getReg() != Pred2[1].getReg())
    return false;

  if (Pred1[2].getImm() == Pred2[2].getImm())
    return true;

  switch (Pred1[2].getImm()) {
  case KVXMOD::SCALARCOND_DNEZ:
    switch (Pred2[2].getImm()) {
    case KVXMOD::SCALARCOND_DGTZ:
    case KVXMOD::SCALARCOND_DLTZ:
    case KVXMOD::SCALARCOND_ODD:
    case KVXMOD::SCALARCOND_WGTZ:
    case KVXMOD::SCALARCOND_WLTZ:
    case KVXMOD::SCALARCOND_WNEZ:
      return true;
    default:
      return false;
    }

  case KVXMOD::SCALARCOND_DLEZ:
    return Pred2[2].getImm() == KVXMOD::SCALARCOND_DLTZ ||
           Pred2[2].getImm() == KVXMOD::SCALARCOND_DEQZ;

  case KVXMOD::SCALARCOND_DGEZ:
    return Pred2[2].getImm() == KVXMOD::SCALARCOND_DGTZ ||
           Pred2[2].getImm() == KVXMOD::SCALARCOND_DEQZ;
    ;

  case KVXMOD::SCALARCOND_WNEZ:
    switch (Pred2[2].getImm()) {
    case KVXMOD::SCALARCOND_ODD:
    case KVXMOD::SCALARCOND_WGTZ:
    case KVXMOD::SCALARCOND_WLTZ:
      return true;
    default:
      return false;
    }
  case KVXMOD::SCALARCOND_WEQZ:
    return Pred2[2].getImm() == KVXMOD::SCALARCOND_DEQZ;

  case KVXMOD::SCALARCOND_WGEZ:
    switch (Pred2[2].getImm()) {
    case KVXMOD::SCALARCOND_WGTZ:
    case KVXMOD::SCALARCOND_WEQZ:
    case KVXMOD::SCALARCOND_DEQZ:
      return true;
    default:
      return false;
    }

  case KVXMOD::SCALARCOND_WLEZ:
    switch (Pred2[2].getImm()) {
    case KVXMOD::SCALARCOND_WLTZ:
    case KVXMOD::SCALARCOND_DEQZ:
    case KVXMOD::SCALARCOND_WEQZ:
      return true;
    default:
      return false;
    }

  case KVXMOD::SCALARCOND_EVEN:
    switch (Pred2[2].getImm()) {
    case KVXMOD::SCALARCOND_WEQZ:
    case KVXMOD::SCALARCOND_DEQZ:
      return true;
    default:
      return false;
    }
  default:
    return false;
  }
}

const KVXSubtarget &KVXInstrInfo::getSubtarget() const { return Subtarget; }

bool KVXInstrInfo::isBranchOffsetInRange(unsigned BranchOpc,
                                         int64_t BrOffset) const {
  switch (BranchOpc) {
  case KVX::GOTO:
    return isInt<27>(BrOffset);
  case KVX::IGOTO:
    return true;
  case KVX::CB:
    return isInt<17>(BrOffset);
  default: {
    errs() << "Opcode: " << BranchOpc << '\n';
    report_fatal_error("Unknown branch opcode.");
  }
  }
}

void KVXInstrInfo::insertIndirectBranch(MachineBasicBlock &MBB,
                                        MachineBasicBlock &NewDestBB,
                                        MachineBasicBlock &RestoreBB,
                                        const DebugLoc &DL, int64_t BrOffset,
                                        RegScavenger *RS) const {
  Register Reg = findScratchRegister(MBB, true);
  if (!Reg)
    return;

  BuildMI(&MBB, DL, get(KVX::MAKEi64), Reg).addMBB(&NewDestBB);
  BuildMI(&MBB, DL, get(KVX::IGOTO)).addReg(Reg, getKillRegState(true));
}

bool KVXInstrInfo::isSafeToMoveRegClassDefs(
    const TargetRegisterClass *RC) const {
  return (RC != &KVX::SwapRegRegClass) && (RC != &KVX::SystemRegRegClass) &&
         (RC != &KVX::GetRegRegClass) && (RC != &KVX::SetRegRegClass) &&
         (RC != &KVX::GetReg_and_SetRegRegClass) &&
         (RC != &KVX::FxRegRegClass) &&
         (RC != &KVX::FxReg_and_GetRegRegClass) &&
         (RC != &KVX::SetFxNotCV1RegRegClass) &&
         (RC != &KVX::GetNotCV1RegRegClass) &&
         (RC != &KVX::GetNotCV1Reg_and_SetFxNotCV1RegRegClass) &&
         (RC != &KVX::AloneRegRegClass) &&
         (RC != &KVX::FxReg_and_GetNotCV1RegRegClass) &&
         (RC != &KVX::FxReg_and_SetFxNotCV1RegRegClass) &&
         (RC != &KVX::AloneReg_and_GetRegRegClass) &&
         (RC != &KVX::GetNotCV1Reg_and_FxReg_and_SetFxNotCV1RegRegClass) &&
         (RC != &KVX::AloneReg_and_GetNotCV1RegRegClass) &&
         (RC != &KVX::GetSetFxNotCV2RegRegClass) &&
         (RC != &KVX::OnlyraRegRegClass);
}

bool KVXInstrInfo::isUnconditionalTailCall(const MachineInstr &MI) const {
  switch (MI.getOpcode()) {
  case KVX::TAIL:
  case KVX::ITAIL:
    return KVXCondTailCall.getValue();
  default:
    return false;
  }
}

bool KVXInstrInfo::canMakeTailCallConditional(
    SmallVectorImpl<MachineOperand> &Cond, const MachineInstr &TailCall) const {
  if ((!KVXCondTailCall) || (TailCall.getOpcode() != KVX::TAIL))
    return false;

  auto Symb = TailCall.getOperand(0);
  if (Symb.isSymbol())
    return false;
  // CB has a 17 bit offset. If the function is over 2^15 bytes, it's rather
  // unsafe using CB for calling another function.
  return isUInt<15>(getFuncSizeInBytes(*TailCall.getParent()->getParent()));
}

void KVXInstrInfo::replaceBranchWithTailCall(MachineBasicBlock &MBB,
                                        SmallVectorImpl<MachineOperand> &Cond,
                                        const MachineInstr &TailCall) const {
  MachineBasicBlock::iterator I = MBB.end();
  for (--I; I != MBB.begin(); --I) {
    if (I->isDebugInstr() || !I->isConditionalBranch() || I->getNumOperands() != 3)
      continue;

    if (!I->isBranch())
      return;

    auto Predicate = I->getOperand(0);
    if (!Predicate.isReg() || Predicate.getReg() != Cond[1].getReg())
      continue;

    auto Condition = I->getOperand(2);
    if (Condition.isImm() && Condition.getImm() == Cond[2].getImm())
      break;
  }

  if (!I->isConditionalBranch())
    return;

  auto MIB = BuildMI(MBB, I, MBB.findDebugLoc(I), get(KVX::CTAIL));
  MIB.addUse(Cond[1].getReg(), getKillRegState(Cond[1].isKill())); // Predicate.
  MIB->addOperand(TailCall.getOperand(0)); // Destination.
  MIB->addOperand(Cond[2]);                // Condition.

  I->eraseFromParent();
}
