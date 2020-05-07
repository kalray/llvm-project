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
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/TargetRegistry.h"

#define GET_INSTRINFO_CTOR_DTOR
#include "KVXGenDFAPacketizer.inc"
#include "KVXGenInstrInfo.inc"

using namespace llvm;

KVXInstrInfo::KVXInstrInfo()
    : KVXGenInstrInfo(KVX::ADJCALLSTACKDOWN, KVX::ADJCALLSTACKUP) {}

void KVXInstrInfo::copyPhysReg(MachineBasicBlock &MBB,
                               MachineBasicBlock::iterator MBBI,
                               const DebugLoc &DL, unsigned DstReg,
                               unsigned SrcReg, bool KillSrc) const {
  if (KVX::SingleRegRegClass.contains(DstReg, SrcReg)) {
    BuildMI(MBB, MBBI, DL, get(KVX::COPYD), DstReg)
        .addReg(SrcReg, getKillRegState(KillSrc));
    return;
  }
  if (KVX::PairedRegRegClass.contains(DstReg, SrcReg)) {
    MachineFunction *MF = MBB.getParent();
    const KVXRegisterInfo *TRI =
        (const KVXRegisterInfo *)MF->getSubtarget().getRegisterInfo();

    BuildMI(MBB, MBBI, DL, get(KVX::COPYQ), DstReg)
        .addReg(TRI->getSubReg(SrcReg, 1), getKillRegState(KillSrc))
        .addReg(TRI->getSubReg(SrcReg, 2), getKillRegState(KillSrc));
    return;
  }
}

unsigned findScratchRegister(MachineBasicBlock &MBB, bool UseAtEnd) {
  RegScavenger RS;

  unsigned ScratchRegister = KVX::R16;

  RS.enterBasicBlock(MBB);

  if (UseAtEnd && !MBB.empty()) {
    // The scratch register will be used at the end of the block, so must
    // consider all registers used within the block

    MachineBasicBlock::iterator MBBI = MBB.getFirstTerminator();
    // If no terminator, back iterator up to previous instruction.
    if (MBBI == MBB.end())
      MBBI = std::prev(MBBI);

    if (MBBI != MBB.begin())
      RS.forward(MBBI);
  }

  if (!RS.isRegUsed(ScratchRegister))
    return ScratchRegister;

  // Get the list of callee-saved registers for the target.
  MachineFunction *MF = MBB.getParent();
  const KVXSubtarget &Subtarget = MF->getSubtarget<KVXSubtarget>();
  const KVXRegisterInfo &RegInfo = *Subtarget.getRegisterInfo();
  const MCPhysReg *CSRegs = RegInfo.getCalleeSavedRegs(MBB.getParent());

  // Get all the available registers in the block.
  BitVector BV = RS.getRegsAvailable(&KVX::SingleRegRegClass);

  // We shouldn't use return registers as scratch register as they appear killed
  BV.reset(KVX::R0, KVX::R4);

  // We shouldn't use callee-saved registers as scratch registers as they may be
  // available when looking for a candidate block for shrink wrapping but not
  // available when the actual prologue/epilogue is being emitted because they
  // were added as live-in to the prologue block by PrologueEpilogueInserter.
  for (int i = 0; CSRegs[i]; ++i)
    BV.reset(CSRegs[i]);

  int FirstScratchReg = BV.find_first();
  ScratchRegister =
      FirstScratchReg == -1 ? (unsigned)KVX::NoRegister : FirstScratchReg;

  return ScratchRegister;
}

void KVXInstrInfo::loadRegFromStackSlot(MachineBasicBlock &MBB,
                                        MachineBasicBlock::iterator I,
                                        unsigned DstReg, int FI,
                                        const TargetRegisterClass *RC,
                                        const TargetRegisterInfo *TRI) const {
  DebugLoc DL;
  if (I != MBB.end())
    DL = I->getDebugLoc();

  if (KVX::SingleRegRegClass.hasSubClassEq(RC)) {
    BuildMI(MBB, I, DL, get(KVX::LDp), DstReg)
        .addImm(0)
        .addFrameIndex(FI)
        .addImm(KVXMOD::VARIANT_);
  }
  if (KVX::PairedRegRegClass.hasSubClassEq(RC)) {
    BuildMI(MBB, I, DL, get(KVX::LQp), DstReg)
        .addImm(0)
        .addFrameIndex(FI)
        .addImm(KVXMOD::VARIANT_);
  }
  if (KVX::QuadRegRegClass.hasSubClassEq(RC)) {
    BuildMI(MBB, I, DL, get(KVX::LOp), DstReg)
        .addImm(0)
        .addFrameIndex(FI)
        .addImm(KVXMOD::VARIANT_);
  }
  if (KVX::OnlyraRegRegClass.hasSubClassEq(RC)) {
    unsigned ScratchReg = findScratchRegister(MBB, true);
    BuildMI(MBB, I, DL, get(KVX::LDp), ScratchReg)
        .addImm(0)
        .addFrameIndex(FI)
        .addImm(KVXMOD::VARIANT_);
    BuildMI(MBB, I, DL, get(KVX::SETrsra), KVX::RA)
        .addReg(ScratchReg, RegState::Kill);
  }
}

void KVXInstrInfo::storeRegToStackSlot(MachineBasicBlock &MBB,
                                       MachineBasicBlock::iterator I,
                                       unsigned SrcReg, bool IsKill, int FI,
                                       const TargetRegisterClass *RC,
                                       const TargetRegisterInfo *TRI) const {
  DebugLoc DL;
  if (I != MBB.end())
    DL = I->getDebugLoc();

  if (KVX::SingleRegRegClass.hasSubClassEq(RC)) {
    BuildMI(MBB, I, DL, get(KVX::SDp))
        .addImm(0)
        .addFrameIndex(FI)
        .addReg(SrcReg, getKillRegState(IsKill))
        .setMIFlags(MachineInstr::FrameSetup);
  }
  if (KVX::PairedRegRegClass.hasSubClassEq(RC)) {
    BuildMI(MBB, I, DL, get(KVX::SQp))
        .addImm(0)
        .addFrameIndex(FI)
        .addReg(SrcReg, getKillRegState(IsKill))
        .setMIFlags(MachineInstr::FrameSetup);
  }
  if (KVX::QuadRegRegClass.hasSubClassEq(RC)) {
    BuildMI(MBB, I, DL, get(KVX::SOp))
        .addImm(0)
        .addFrameIndex(FI)
        .addReg(SrcReg, getKillRegState(IsKill))
        .setMIFlags(MachineInstr::FrameSetup);
  }
  if (KVX::OnlyraRegRegClass.hasSubClassEq(RC)) {
    unsigned ScratchReg = findScratchRegister(MBB, false);
    BuildMI(MBB, I, DL, get(KVX::GETss2), ScratchReg)
        .addReg(KVX::RA)
        .setMIFlags(MachineInstr::FrameSetup);

    // set flag to mark that $ra is saved with this instruction
    // at frame index elimination cfi instruction will be added
    BuildMI(MBB, I, DL, get(KVX::SDp))
        .addImm(0)
        .addFrameIndex(FI)
        .addReg(ScratchReg, RegState::Kill)
        .setMIFlags(1 << 14);
  }
}

DFAPacketizer *
KVXInstrInfo::CreateTargetScheduleState(const TargetSubtargetInfo &STI) const {
  const InstrItineraryData *II = STI.getInstrItineraryData();
  return static_cast<const KVXSubtarget &>(STI).createDFAPacketizer(II);
}

bool KVXInstrInfo::analyzeBranch(MachineBasicBlock &MBB,
                                 MachineBasicBlock *&TBB,
                                 MachineBasicBlock *&FBB,
                                 SmallVectorImpl<MachineOperand> &Cond,
                                 bool AllowModify) const {

  TBB = FBB = nullptr;
  Cond.clear();

  MachineBasicBlock::iterator I = MBB.end();
  while (I != MBB.begin()) {
    --I;

    // Ignore debug instructions.
    if (I->isDebugInstr())
      continue;

    // Handle unconditional branches.
    if (I->getOpcode() == KVX::GOTO && AllowModify) {
      while (std::next(I) != MBB.end())
        std::next(I)->eraseFromParent();

      if (MBB.isLayoutSuccessor(I->getOperand(0).getMBB())) {
        I->eraseFromParent();
        I = MBB.end();
        continue;
      }
    }

    // Other cases are not understood.
    return true;
  }

  return false;
}

unsigned KVXInstrInfo::insertBranch(MachineBasicBlock &MBB,
                                    MachineBasicBlock *TBB,
                                    MachineBasicBlock *FBB,
                                    ArrayRef<MachineOperand> Cond,
                                    const DebugLoc &DL, int *BytesAdded) const {
  if (!FBB) {
    if (Cond.empty()) // Unconditional branch
    {
      BuildMI(&MBB, DL, get(KVX::GOTO)).addMBB(TBB);
      return 1;
    }
  }
  return 0;
}

unsigned KVXInstrInfo::removeBranch(MachineBasicBlock &MBB,
                                    int *BytesRemoved) const {
  assert(!BytesRemoved && "code size not handled");

  MachineBasicBlock::iterator I = MBB.end();
  unsigned Count = 0;
  while (I != MBB.begin()) {
    --I;
    if (I->isDebugInstr())
      continue;
    if (!I->isBranch())
      return Count;
    I->eraseFromParent();
    I = MBB.end();
    ++Count;
  }

  return Count;
}
