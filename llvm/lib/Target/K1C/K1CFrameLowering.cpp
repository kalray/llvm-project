#include "K1CFrameLowering.h"
#include "K1CSubtarget.h"
#include "MCTargetDesc/K1CMCTargetDesc.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/RegisterScavenging.h"

using namespace llvm;

static unsigned getSPReg(const K1CSubtarget &STI) { return K1C::R12; }

void K1CFrameLowering::adjustStack(MachineFunction &MF) const {
  MachineFrameInfo &MFI = MF.getFrameInfo();
  const K1CRegisterInfo *RI = STI.getRegisterInfo();

  // Get the real stack size.
  uint64_t StackSize = MFI.getStackSize();

  // Get the alignment.

  uint64_t StackAlign = RI->needsStackRealignment(MF) ? MFI.getMaxAlignment()
                                                      : getStackAlignment();

  // Align the stack.
  StackSize = alignTo(StackSize, StackAlign);

  // Update with the aligned stack.
  MFI.setStackSize(StackSize);
}

void K1CFrameLowering::adjustReg(MachineBasicBlock &MBB,
                                 MachineBasicBlock::iterator MBBI,
                                 const DebugLoc &DL, unsigned OpCode,
                                 unsigned DestReg, unsigned SrcReg, int64_t Val,
                                 MachineInstr::MIFlag Flag) const {

  const K1CInstrInfo *TII = STI.getInstrInfo();
  BuildMI(MBB, MBBI, DL, TII->get(OpCode), DestReg)
      .addReg(SrcReg)
      .addImm(Val)
      .setMIFlag(Flag);
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

void K1CFrameLowering::emitPrologue(MachineFunction &MF,
                                    MachineBasicBlock &MBB) const {
  assert(&MF.front() == &MBB && "Shrink-wrapping not yet supported");

  MachineBasicBlock::iterator MBBI = MBB.begin();
  MachineFrameInfo &MFI = MF.getFrameInfo();

  adjustStack(MF);

  int64_t StackSize = (int64_t)MFI.getStackSize();

  if (StackSize == 0 && !MFI.adjustsStack())
    return;

  DebugLoc DL;
  unsigned SPReg = getSPReg(STI);

  adjustReg(MBB, MBBI, DL, GetStackOpCode((uint64_t)StackSize), SPReg, SPReg, -StackSize,
            MachineInstr::FrameSetup);

  const K1CInstrInfo *TII = STI.getInstrInfo();

  if (!isLeafProc(MF)) {
    unsigned ScratchReg = findScratchRegister(MBB, false);
    assert(ScratchReg != K1C::NoRegister);

    BuildMI(MBB, MBBI, DL, TII->get(K1C::GET), ScratchReg)
        .addReg(K1C::RA)
        .setMIFlag(MachineInstr::FrameSetup);
    BuildMI(MBB, MBBI, DL, TII->get(K1C::SDd0))
        .addImm(0)
        .addReg(SPReg)
        .addReg(ScratchReg, RegState::Kill)
        .setMIFlag(MachineInstr::FrameSetup);
  }
}

bool K1CFrameLowering::isLeafProc(MachineFunction &MF) const {
  // MachineRegisterInfo &MRI = MF.getRegInfo();
  MachineFrameInfo &MFI = MF.getFrameInfo();

  return !(MFI.hasCalls() /* || hasFP(MF)*/);
}

void K1CFrameLowering::emitEpilogue(MachineFunction &MF,
                                    MachineBasicBlock &MBB) const {
  MachineBasicBlock::iterator MBBI = MBB.getLastNonDebugInstr();
  MachineFrameInfo &MFI = MF.getFrameInfo();

  uint64_t StackSize = MFI.getStackSize();

  unsigned SPReg = getSPReg(STI);
  if (StackSize == 0)
    return;

  DebugLoc DL = MBBI->getDebugLoc();

  const K1CInstrInfo *TII = STI.getInstrInfo();

  if (!isLeafProc(MF)) {
    unsigned ScratchReg = findScratchRegister(MBB, true);
    assert(ScratchReg != K1C::NoRegister);

    BuildMI(MBB, MBBI, DL, TII->get(K1C::LDd0), ScratchReg)
        .addImm(0)
        .addReg(SPReg)
        .addImm(0)
        .setMIFlag(MachineInstr::FrameDestroy);
    BuildMI(MBB, MBBI, DL, TII->get(K1C::SETd2), K1C::RA)
        .addReg(ScratchReg, RegState::Kill)
        .setMIFlag(MachineInstr::FrameDestroy);
  }

  // Deallocate stack
  adjustReg(MBB, MBBI, DL, GetStackOpCode(StackSize), SPReg, SPReg, StackSize,
            MachineInstr::FrameDestroy);
}

int K1CFrameLowering::getFrameIndexReference(const MachineFunction &MF, int FI,
                                             unsigned &FrameReg) const {
  const MachineFrameInfo &MFI = MF.getFrameInfo();
  const TargetRegisterInfo *RI = MF.getSubtarget().getRegisterInfo();
  FrameReg = RI->getFrameRegister(MF);
  int Offset = MFI.getObjectOffset(FI) - getOffsetOfLocalArea() +
               MFI.getOffsetAdjustment();

  Offset += MF.getFrameInfo().getStackSize();

  return Offset;
}

void K1CFrameLowering::determineCalleeSaves(MachineFunction &MF,
                                            BitVector &SavedRegs,
                                            RegScavenger *RS) const {
  TargetFrameLowering::determineCalleeSaves(MF, SavedRegs, RS);

  // SavedRegs.set(K1C::RA);
  // Unconditionally spill RA and FP only if the function uses a frame
  // pointer.
  if (hasFP(MF)) {
    SavedRegs.set(K1C::R14);
  }
}

void K1CFrameLowering::processFunctionBeforeFrameFinalized(
    MachineFunction &MF, RegScavenger *RS) const {}

bool K1CFrameLowering::hasFP(const MachineFunction &MF) const {
  const TargetRegisterInfo *RegInfo = MF.getSubtarget().getRegisterInfo();

  const MachineFrameInfo &MFI = MF.getFrameInfo();
  return MF.getTarget().Options.DisableFramePointerElim(MF) ||
         RegInfo->needsStackRealignment(MF) || MFI.hasVarSizedObjects() ||
         MFI.isFrameAddressTaken();
}

bool K1CFrameLowering::hasReservedCallFrame(const MachineFunction &MF) const {
  return !MF.getFrameInfo().hasVarSizedObjects();
}

MachineBasicBlock::iterator K1CFrameLowering::eliminateCallFramePseudoInstr(
    MachineFunction &MF, MachineBasicBlock &MBB,
    MachineBasicBlock::iterator MI) const {

  unsigned SPReg = K1C::R12;
  DebugLoc DL = MI->getDebugLoc();

  if (!hasReservedCallFrame(MF)) {
    // If space has not been reserved for a call frame, ADJCALLSTACKDOWN and
    // ADJCALLSTACKUP must be converted to instructions manipulating the stack
    // pointer. This is necessary when there is a variable length stack
    // allocation (e.g. alloca), which means it's not possible to allocate
    // space for outgoing arguments from within the function prologue.
    int64_t Amount = MI->getOperand(0).getImm();

    if (Amount != 0) {
      // Ensure the stack remains aligned after adjustment.
      Amount = alignSPAdjust(Amount);

      if (MI->getOpcode() == K1C::ADJCALLSTACKDOWN)
        Amount = -Amount;

      adjustReg(MBB, MI, DL, GetStackOpCode(Amount), SPReg, SPReg, Amount,
                MachineInstr::NoFlags);
    }
  }

  return MBB.erase(MI);
}
