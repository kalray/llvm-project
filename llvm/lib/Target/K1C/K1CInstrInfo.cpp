#include "K1CInstrInfo.h"
#include "K1C.h"
#include "K1CTargetMachine.h"
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
#include "K1CGenInstrInfo.inc"

using namespace llvm;

K1CInstrInfo::K1CInstrInfo()
    : K1CGenInstrInfo(K1C::ADJCALLSTACKDOWN, K1C::ADJCALLSTACKUP) {}

void K1CInstrInfo::copyPhysReg(MachineBasicBlock &MBB,
                               MachineBasicBlock::iterator MBBI,
                               const DebugLoc &DL, unsigned DstReg,
                               unsigned SrcReg, bool KillSrc) const {
  if (K1C::SingleRegRegClass.contains(DstReg, SrcReg)) {
    BuildMI(MBB, MBBI, DL, get(K1C::COPYD), DstReg)
        .addReg(SrcReg, getKillRegState(KillSrc));
    return;
  }
}

unsigned findScratchRegister(MachineBasicBlock &MBB, bool UseAtEnd) {
  RegScavenger RS;

  unsigned ScratchRegister = K1C::R16;

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
  const K1CSubtarget &Subtarget = MF->getSubtarget<K1CSubtarget>();
  const K1CRegisterInfo &RegInfo = *Subtarget.getRegisterInfo();
  const MCPhysReg *CSRegs = RegInfo.getCalleeSavedRegs(MBB.getParent());

  // Get all the available registers in the block.
  BitVector BV = RS.getRegsAvailable(&K1C::SingleRegRegClass);

  // We shouldn't use callee-saved registers as scratch registers as they may be
  // available when looking for a candidate block for shrink wrapping but not
  // available when the actual prologue/epilogue is being emitted because they
  // were added as live-in to the prologue block by PrologueEpilogueInserter.
  for (int i = 0; CSRegs[i]; ++i)
    BV.reset(CSRegs[i]);

  int FirstScratchReg = BV.find_first();
  ScratchRegister =
      FirstScratchReg == -1 ? (unsigned)K1C::NoRegister : FirstScratchReg;

  return ScratchRegister;
}

void K1CInstrInfo::loadRegFromStackSlot(MachineBasicBlock &MBB,
                                        MachineBasicBlock::iterator I,
                                        unsigned DstReg, int FI,
                                        const TargetRegisterClass *RC,
                                        const TargetRegisterInfo *TRI) const {
  DebugLoc DL;
  if (I != MBB.end())
    DL = I->getDebugLoc();

  if (K1C::SingleRegRegClass.hasSubClassEq(RC)) {
    BuildMI(MBB, I, DL, get(K1C::LDd0), DstReg)
        .addFrameIndex(FI)
        .addReg(K1C::R12, 0)
        .addImm(0);
  }
  if (K1C::RARegRegClass.hasSubClassEq(RC)) {
    unsigned ScratchReg = findScratchRegister(MBB, true);
    BuildMI(MBB, I, DL, get(K1C::LDd0), ScratchReg)
        .addFrameIndex(FI)
        .addReg(K1C::R12)
        .addImm(0)
        .setMIFlag(MachineInstr::FrameDestroy);
    BuildMI(MBB, I, DL, get(K1C::SETd2), K1C::RA)
        .addReg(ScratchReg, RegState::Kill)
        .setMIFlag(MachineInstr::FrameDestroy);
  }
}

void K1CInstrInfo::storeRegToStackSlot(MachineBasicBlock &MBB,
                                       MachineBasicBlock::iterator I,
                                       unsigned SrcReg, bool IsKill, int FI,
                                       const TargetRegisterClass *RC,
                                       const TargetRegisterInfo *TRI) const {
  DebugLoc DL;
  if (I != MBB.end())
    DL = I->getDebugLoc();

  if (K1C::SingleRegRegClass.hasSubClassEq(RC)) {
    BuildMI(MBB, I, DL, get(K1C::SDd0))
        .addFrameIndex(FI)
        .addReg(K1C::R12, 0)
        .addReg(SrcReg, getKillRegState(IsKill)); //.addMemOperand(MMO)
  }
  if (K1C::RARegRegClass.hasSubClassEq(RC)) {
    unsigned ScratchReg = findScratchRegister(MBB, false);
    BuildMI(MBB, I, DL, get(K1C::GET), ScratchReg)
        .addReg(K1C::RA)
        .setMIFlag(MachineInstr::FrameSetup);
    BuildMI(MBB, I, DL, get(K1C::SDd0))
        .addFrameIndex(FI)
        .addReg(K1C::R12)
        .addReg(ScratchReg, RegState::Kill)
        .setMIFlag(MachineInstr::FrameSetup);
  }
}
