//===- KVXFrameLowering.cpp - KVX Frame Lowering ---------------*- C++ -*-====//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the KVX implementation of TargetFrameLowering class.
//
// The stack grows downwards, and is delimited by the value of the stack pointer
// ($sp) register that points to its lowest address.
//
// The stack pointer must always be aligned on a 32-byte boundary. This implies
// that all stack frames must be a multiple of 32 bytes in size. A function
// stack frame comprises up to six regions, listed from the highest address to
// the lowest address in the stack frame:
//
//                ~                                            ~
//                |                                            |
//                | Incoming Arguments                         |
//                |                                            |
//  Caller Frame  |                         [256-bits aligned] | <- incoming $sp
// ============== +============================================+ ===============
//  Callee Frame  |                                            |
//                | Anonymous Arguments                        |
//                |                                            |
//                +--------------------------------------------+
//                |                                            |
//                | Frame Marker                               |
//                |   $ra (if needed)                          |
//                |   caller $fp (if needed)                   | <- $fp
//                |                                            |
//                | Register Save                              |
//                |                                            |
//                +--------------------------------------------+
//                |                                            |
//                | Local Variables                            |
//                |                                            |
//                +--------------------------------------------+
//                |                                            |
//                | Dynamic Area                               |
//                |                                            |
//                +--------------------------------------------+
//                |                                            |
//                | Outgoing Arguments                         |
//                |                         [256-bits aligned] | <- $sp
// ============== +============================================+ ===============
//
// When composing a function stack frame, small object sizes and alignment are
// rounded up to 8 bytes on the Outgoing Arguments Area as per ABI
// specifications. Objects that have stricter alignment than 8 bytes are
// assigned a slot that ensures this stricter alignment, typically by allocating
// more stack slots at compile time then rounding the address at execution time.
//
// == Anonymous Arguments ==
// This region is used for incoming anonymous arguments of variadic functions
// that exceed the registers usage. Anonymous arguments, also known as unnamed
// arguments, are those passed at position starting at ellipsis '...' in the
// prototype of a variadic function (in C/C++).
//
// == Frame Marker ==
// This region contains information required for unwinding the stack at
// run-time, and is pointed to by the $fp register. It contains a pointer to the
// previous frame marker (the caller $fp), and the return address of the
// function. The pointer is NULL if there is no previous frame marker. This
// region is optional when there is no Dynamic Area.
//
// == Registers Save ==
// A function may store callee-saved (preserved) registers ($r14, $18--$r31) in
// this region before reusing them. A function may also store caller-saved
// (scratch) registers ($r0--$r11, $r15--$r17, $r32--$r63) in this region before
// calling a function.
//
// == Local Variables ==
// A function may store local variables and compiler temporaries in this region.
//
// == Dynamic Area ==
// This region is variable-sized and it is only created if the callee function
// has any calls to alloca() or declares ISO C99 variable length arrays.
//
// == Outgoing Arguments ==
// Successive arguments are passed in argument slots, with the first twelve ones
// located in registers $r0-$r11, and the other on the stack in the Outgoing
// Arguments region. The Outgoing Argument region on the stack is sized as the
// maximum required by all functions called from the current one. Stack space is
// not allocated for the arguments that are passed in registers, whether named
// or anonymous.
//
//===----------------------------------------------------------------------===//

#include "KVXFrameLowering.h"
#include "KVXInstrInfo.h"
#include "KVXMachineFunctionInfo.h"
#include "KVXSubtarget.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/MC/MCDwarf.h"
#include "llvm/Target/TargetMachine.h"

using namespace llvm;

#define DEBUG_TYPE "KVXFrameLowering"

Register findScratchRegister(MachineBasicBlock &MBB, bool UseAtEnd,
                             Register Scratch = KVX::R4);

// Emit instruction to move the stack pointer.
void KVXFrameLowering::emitAdjustSPReg(MachineBasicBlock &MBB,
                                       MachineBasicBlock::iterator MBBI,
                                       const DebugLoc &DL, unsigned Opcode,
                                       int64_t StackSize,
                                       MachineInstr::MIFlag Flag) const {
  const KVXInstrInfo *TII = STI.getInstrInfo();

  BuildMI(MBB, MBBI, DL, TII->get(Opcode), getSPReg())
      .addReg(getSPReg())
      .addImm(StackSize)
      .setMIFlag(Flag);
}

// Emit prologue code.
void KVXFrameLowering::emitPrologue(MachineFunction &MF,
                                    MachineBasicBlock &MBB) const {
  assert(&(*MF.begin()) == &MBB && "Shrink-wrapping not yet supported");

  auto *KVXFI = MF.getInfo<KVXMachineFunctionInfo>();
  MachineBasicBlock::iterator MBBI = MBB.begin();
  MachineFrameInfo &MFI = MF.getFrameInfo();

  int64_t StackSize = MFI.getStackSize();
  LLVM_DEBUG(dbgs() << "VarArgsSaveSize=" << KVXFI->getVarArgsSaveSize()
                    << "\n");
  LLVM_DEBUG(dbgs() << "StackSize=" << StackSize << "\n");
  LLVM_DEBUG(dbgs() << "LocalMaxAlign=" << KVXFI->getMaxAlignment() << "\n");

  if (StackSize == 0) {
    LLVM_DEBUG(dbgs() << "Stack size is 0, nothing to emit in Prologue.\n");
    return; // Nothing to do.
  }

  // In case any local object has an alignment greater than the default
  // StackAlign, FP must be readjusted on the maximum alignment of the local
  // objects. Reserve space on stack to realign the local area.
  if (KVXFI->isAdjustLocalAreaSP()) {
    StackSize = alignTo(StackSize + KVXFI->getMaxAlignment(), 32);
    MFI.setStackSize(StackSize);

    LLVM_DEBUG(dbgs() << "Local/Alloca reAlign=" << KVXFI->getMaxAlignment()
                      << "\n");
    LLVM_DEBUG(dbgs() << "new StackSize=" << MFI.getStackSize() << "\n");
  }

  // Debug location must be unknown since the first debug location is used
  // to determine the end of the prologue.
  DebugLoc DL;
  const KVXInstrInfo *TII = STI.getInstrInfo();

  // Emit stack check code, -fstack-limit-register)
  if (hasStackLimitRegister())
    emitStackCheck(MF, MBB);

  // Reserve space on stack.
  unsigned Opcode = getStackADDOpcode(-StackSize);
  emitAdjustSPReg(MBB, MBBI, DL, Opcode, -StackSize, MachineInstr::FrameSetup);

  // Emit dwarf information.
  unsigned CFIIndex =
      MF.addFrameInst(MCCFIInstruction::cfiDefCfaOffset(nullptr, StackSize));

  BuildMI(MBB, MBBI, DL, TII->get(TargetOpcode::CFI_INSTRUCTION))
      .addCFIIndex(CFIIndex)
      .setMIFlags(MachineInstr::FrameSetup);

  LLVM_DEBUG(dbgs() << "Prologue has been generated.\n");
}

// Emit epilogue code.
void KVXFrameLowering::emitEpilogue(MachineFunction &MF,
                                    MachineBasicBlock &MBB) const {

  MachineFrameInfo &MFI = MF.getFrameInfo();
  uint64_t StackSize = MFI.getStackSize();

  if (StackSize == 0) {
    LLVM_DEBUG(dbgs() << "Stack size is 0, nothing to emit in Epilogue.\n");
    return; // Nothing to do.
  }

  MachineBasicBlock::iterator MBBI = MBB.getLastNonDebugInstr();
  DebugLoc DL = MBBI->getDebugLoc();

  // Deallocate stack.
  unsigned Opcode = getStackADDOpcode(StackSize);
  emitAdjustSPReg(MBB, MBBI, DL, Opcode, StackSize, MachineInstr::FrameDestroy);

  // Emit .cfi_def_cfa_offset 0
  const KVXInstrInfo *TII = STI.getInstrInfo();
  unsigned CFIIndex =
      MF.addFrameInst(MCCFIInstruction::cfiDefCfaOffset(nullptr, 0));
  BuildMI(MBB, MBBI, DL, TII->get(TargetOpcode::CFI_INSTRUCTION))
      .addCFIIndex(CFIIndex)
      .setMIFlags(MachineInstr::FrameDestroy);

  LLVM_DEBUG(dbgs() << "Epilogue has been generated.\n");
}

// Get stack offset from FrameIndex.
StackOffset KVXFrameLowering::getFrameIndexReference(const MachineFunction &MF,
                                                     int FI,
                                                     Register &FrameReg) const {
  const MachineFrameInfo &MFI = MF.getFrameInfo();

  LLVM_DEBUG(dbgs() << "compute FrameIndexReference for FI(" << FI
                    << "), object (size, align, offset, fixed): ("
                    << MFI.getObjectSize(FI) << ", "
                    << MFI.getObjectAlign(FI).value() << ", "
                    << MFI.getObjectOffset(FI) << ", "
                    << MFI.isFixedObjectIndex(FI) << ")\n");

  auto *KVXFI = MF.getInfo<KVXMachineFunctionInfo>();
  auto const &Indexes = KVXFI->getMinMaxCSFrameIndexes();

  if (FI >= Indexes.first && FI <= Indexes.second)
    FrameReg = getSPReg();
  else if (KVXFI->isAdjustLocalAreaSP())
    FrameReg = MFI.isFixedObjectIndex(FI) ? getSPReg() : KVXFI->getAdjustedSP();
  else
    FrameReg = hasFP(MF) ? getFPReg() : getSPReg();

  // Always return Offset relative to frame base for correct Dwarf information.
  // Offset is adjusted when FrameIndex is eliminated.
  int Offset = MFI.getObjectOffset(FI);

  return StackOffset::getFixed(Offset);
}

// Determine registers to save.
void KVXFrameLowering::determineCalleeSaves(MachineFunction &MF,
                                            BitVector &SavedRegs,
                                            RegScavenger *RS) const {

  TargetFrameLowering::determineCalleeSaves(MF, SavedRegs, RS);

  // Spill RA and FP if the function uses a frame pointer.
  if (hasFP(MF)) {
    SavedRegs.set(KVX::RA);
    SavedRegs.set(getFPReg());
  }

  const KVXRegisterInfo *TRI =
      (const KVXRegisterInfo *)MF.getSubtarget().getRegisterInfo();

  if (TRI->needsLocalAreaRealignment(MF))
    SavedRegs.set(KVX::R31);
}

// Spill callee saved registers.
// TODO: Perform store packing at LoadStorePacking pass?
bool KVXFrameLowering::spillCalleeSavedRegisters(
    MachineBasicBlock &MBB, MachineBasicBlock::iterator MI,
    ArrayRef<CalleeSavedInfo> CSI, const TargetRegisterInfo *TRI) const {

  const KVXInstrInfo *TII = STI.getInstrInfo();
  MachineFunction &MF = *MBB.getParent();

  SmallVector<unsigned, 8> RegSaved;
  SmallVector<const TargetRegisterClass *, 8> RCSaved;
  SmallVector<int, 8> FrameIdxSaved;

  // Pack CSR stores
  for (const CalleeSavedInfo &CS : CSI) {
    Register Reg = CS.getReg();
    const TargetRegisterClass *RC = TRI->getMinimalPhysRegClass(Reg);

    // Try to merge single regs into paired regs.
    MCRegister PairedReg =
        TRI->getMatchingSuperReg(Reg, KVX::sub_d0, &KVX::PairedRegRegClass);

    if (!RegSaved.empty() && PairedReg && RegSaved.back() - 1 == Reg &&
        FrameIdxSaved.back() + 1 == CS.getFrameIdx()) {
      if (RCSaved.back() == &KVX::SingleRegRegClass) {
        RegSaved.pop_back();
        RCSaved.pop_back();
        FrameIdxSaved.pop_back();

        // Try to merge paired regs into quad regs.
        MCRegister QuadReg =
            TRI->getMatchingSuperReg(Reg, KVX::sub_d0, &KVX::QuadRegRegClass);
        if (!RegSaved.empty() && RCSaved.back() == &KVX::PairedRegRegClass &&
            QuadReg && RegSaved.back() - 1 == PairedReg) {
          Reg = QuadReg;
          RC = &KVX::QuadRegRegClass;
          RegSaved.pop_back();
          RCSaved.pop_back();
          FrameIdxSaved.pop_back();
        } else {
          Reg = PairedReg;
          RC = &KVX::PairedRegRegClass;
        }
      }
    }

    RegSaved.push_back(Reg);
    RCSaved.push_back(RC);
    FrameIdxSaved.push_back(CS.getFrameIdx());
  }

  auto *KVXFI = MF.getInfo<KVXMachineFunctionInfo>();
  // Emit store instructions.
  // TODO: Optimization: stack objects can be reordered in order to save stack
  // space (see orderFrameObjects).
  const TargetSubtargetInfo &STI = MF.getSubtarget();
  const MCRegisterInfo *MRI = STI.getRegisterInfo();
  DebugLoc DL = MBB.findDebugLoc(MI);
  int64_t DwarfOffset = -(int64_t)(KVXFI->getVarArgsSaveSize());
  Register DwarfReg;
  unsigned CFIIndex;

  for (unsigned I = 0; I < RegSaved.size(); ++I) {
    TII->storeRegToStackSlot(MBB, MI, RegSaved[I], true, FrameIdxSaved[I],
                             RCSaved[I], TRI, Register());

    // Emit .cfi_offset for each packed SingleRegs.
    for (auto SubReg : TRI->subregs_inclusive(RegSaved[I])) {
      // Only for SingleRegs.
      if (KVX::SingleRegRegClass.contains(SubReg) ||
          KVX::OnlyraRegRegClass.contains(SubReg)) {
        DwarfOffset -= 8;
        DwarfReg = MRI->getDwarfRegNum(SubReg, true);
        CFIIndex = MF.addFrameInst(
            MCCFIInstruction::createOffset(nullptr, DwarfReg, DwarfOffset));
        BuildMI(MBB, MI, DL, TII->get(TargetOpcode::CFI_INSTRUCTION))
            .addCFIIndex(CFIIndex)
            .setMIFlags(MachineInstr::FrameSetup);
      }
    }

    // Set FP.
    if (hasFP(MF) && RegSaved[I] == getFPReg()) {
      KVXFI->setFPIndex(FrameIdxSaved[I]);
      // Correct ADDDri variant is selected at eliminateFrameIndex.
      BuildMI(MBB, MI, DL, TII->get(KVX::ADDDri64), getFPReg())
          .addReg(getSPReg())
          .addFrameIndex(FrameIdxSaved[I])
          .setMIFlags(MachineInstr::FrameSetup);

      CFIIndex = MF.addFrameInst(
          MCCFIInstruction::cfiDefCfa(nullptr, DwarfReg, -DwarfOffset));
      BuildMI(MBB, MI, DL, TII->get(TargetOpcode::CFI_INSTRUCTION))
          .addCFIIndex(CFIIndex)
          .setMIFlags(MachineInstr::FrameSetup);
    }
  }

  // Save CSR FrameIndex range.
  KVXFI->setMinMaxCSFrameIndexes(
      {CSI.front().getFrameIdx(), CSI.back().getFrameIdx()});

  const MachineFrameInfo &MFI = MF.getFrameInfo();
  const KVXRegisterInfo *KTRI =
      (const KVXRegisterInfo *)MF.getSubtarget().getRegisterInfo();

  // Readjust stack alignement if realignment is required for any local object.
  if (KTRI->needsLocalAreaRealignment(MF)) {
    KVXFI->setAdjustLocalAreaSP(true);
    KVXFI->setMaxAlignment(KTRI->getLocalAreaAlignment(MF));
    KVXFI->setAdjustedSP(KTRI->getLARReg());
    // Stack space is already reserved: only readjust SP alignment.
    unsigned Opcode = getStackANDOpcode(-(int)MFI.getMaxAlign().value());

    BuildMI(MBB, MI, DL, TII->get(Opcode), KVXFI->getAdjustedSP())
        .addReg(getSPReg())
        .addImm(-(int)MFI.getMaxAlign().value())
        .setMIFlag(MachineInstr::FrameSetup);
  }

  return true;
}

// Restore callee saved registers.
// TODO: Perform load packing at LoadStorePacking pass?
bool KVXFrameLowering::restoreCalleeSavedRegisters(
    MachineBasicBlock &MBB, MachineBasicBlock::iterator MI,
    MutableArrayRef<CalleeSavedInfo> CSI, const TargetRegisterInfo *TRI) const {

  const KVXInstrInfo *TII = STI.getInstrInfo();
  DebugLoc DL = MBB.findDebugLoc(MI);
  MachineFunction &MF = *MBB.getParent();

  MI = MBB.getFirstTerminator();

  SmallVector<Register, 8> RegSaved;
  SmallVector<const TargetRegisterClass *, 8> RCSaved;
  SmallVector<int, 8> FrameIdxSaved;

  for (const CalleeSavedInfo &CS : reverse(CSI)) {
    Register Reg = CS.getReg();
    const TargetRegisterClass *RC = TRI->getMinimalPhysRegClass(Reg);

    // COPY the ITAIL target address before CSR restoration.
    if (MI->getOpcode() == KVX::ITAIL && MI->getOperand(0).getReg() == Reg) {
      Register ScratchReg = findScratchRegister(MBB, true);
      BuildMI(MBB, MI, DL, TII->get(KVX::COPY), ScratchReg).addReg(Reg);
      MI->getOperand(0).setReg(ScratchReg);
      MBB.addLiveIn(ScratchReg);
    }

    // Pack CSR loads.
    // Try to merge single regs into paired regs
    unsigned PairedReg =
        TRI->getMatchingSuperReg(Reg, KVX::sub_d1, &KVX::PairedRegRegClass);
    if (!RegSaved.empty() && PairedReg && RegSaved.back() + 1 == Reg &&
        FrameIdxSaved.back() - 1 == CS.getFrameIdx()) {
      if (RCSaved.back() == &KVX::SingleRegRegClass) {
        RegSaved.pop_back();
        RCSaved.pop_back();

        // Try to merge paired regs into quad regs
        unsigned QuadReg =
            TRI->getMatchingSuperReg(Reg, KVX::sub_d3, &KVX::QuadRegRegClass);
        if (!RegSaved.empty() && RCSaved.back() == &KVX::PairedRegRegClass &&
            QuadReg && RegSaved.back() + 1 == PairedReg) {
          Reg = QuadReg;
          RC = &KVX::QuadRegRegClass;
          RegSaved.pop_back();
          RCSaved.pop_back();
          FrameIdxSaved.pop_back();
        } else {
          Reg = PairedReg;
          RC = &KVX::PairedRegRegClass;
        }
      }
    } else {
      FrameIdxSaved.push_back(CS.getFrameIdx());
    }

    RegSaved.push_back(Reg);
    RCSaved.push_back(RC);
  }

  auto *KVXFI = MF.getInfo<KVXMachineFunctionInfo>();
  MachineFrameInfo &MFI = MF.getFrameInfo();
  uint64_t StackSize = MFI.getStackSize();
  if (KVXFI->isAdjustLocalAreaSP()) {
    StackSize = alignTo(StackSize + KVXFI->getMaxAlignment(), 32);
    MFI.setStackSize(StackSize);

    LLVM_DEBUG(dbgs() << "Local/Alloca reAlign=" << KVXFI->getMaxAlignment()
                      << "\n");
    LLVM_DEBUG(dbgs() << "new StackSize=" << MFI.getStackSize() << "\n");
  }
  // Restore SP from FP first.
  if (hasFP(MF)) {
    if (!MFI.getStackSize()) {
      LLVM_DEBUG(dbgs() << "Enforcing StackSize to 32 bytes.\n");
      MFI.setStackSize(32);
    }
    // SUBDri64 is translated to ADDDri at FrameIndexElimination.
    BuildMI(MBB, MI, DL, TII->get(KVX::SUBDri64), getSPReg())
        .addReg(getFPReg())
        .addFrameIndex(KVXFI->getFPIndex())
        .setMIFlags(MachineInstr::FrameDestroy);

    auto CFIIndex = MF.addFrameInst(MCCFIInstruction::cfiDefCfa(
        nullptr, TRI->getDwarfRegNum(getSPReg(), true),
        MF.getFrameInfo().getStackSize()));

    BuildMI(MBB, MI, DL, TII->get(TargetOpcode::CFI_INSTRUCTION))
        .addCFIIndex(CFIIndex)
        .setMIFlags(MachineInstr::FrameDestroy);
  }

  // Emit load instructions.
  for (unsigned I = 0; I < RegSaved.size(); ++I) {
    TII->loadRegFromStackSlot(MBB, MI, RegSaved[I], FrameIdxSaved[I],
                              RCSaved[I], TRI, Register(), true, DL);
  }

  return true;
}

bool KVXFrameLowering::hasFP(const MachineFunction &MF) const {
  if (MF.getFunction().hasFnAttribute(Attribute::Naked))
    return false;

  if (MF.getTarget().Options.DisableFramePointerElim(MF))
    return true;

  const TargetRegisterInfo *RegInfo = MF.getSubtarget().getRegisterInfo();

  const auto &MFI = MF.getFrameInfo();

  return RegInfo->hasStackRealignment(MF) || MFI.isFrameAddressTaken() ||
         MFI.hasVarSizedObjects() || hasStackLimitRegister();
}

bool KVXFrameLowering::hasReservedCallFrame(const MachineFunction &MF) const {
  return !hasFP(MF);
}

MachineBasicBlock::iterator KVXFrameLowering::eliminateCallFramePseudoInstr(
    MachineFunction &MF, MachineBasicBlock &MBB,
    MachineBasicBlock::iterator MI) const {

  DebugLoc DL = MBB.findDebugLoc(MI);

  if (!hasReservedCallFrame(MF)) {
    LLVM_DEBUG(dbgs() << "eliminateCallFramePseudo\n");

    // If space has not been reserved for a call frame, ADJCALLSTACKDOWN and
    // ADJCALLSTACKUP must be converted to instructions manipulating the stack
    // pointer. This is necessary when there is a variable length stack
    // allocation (e.g. alloca), which means it's not possible to allocate
    // space for outgoing arguments from within the function prologue.
    int64_t Amount = MI->getOperand(0).getImm();

    if (Amount != 0) {
      LLVM_DEBUG(dbgs() << "Adjust SP for call frame pseudo elimination\n");

      // Ensure the stack remains aligned after adjustment.
      Amount = alignSPAdjust(Amount);

      if (MI->getOpcode() == KVX::ADJCALLSTACKDOWN)
        Amount = -Amount;

      unsigned Opcode = getStackADDOpcode(Amount);
      emitAdjustSPReg(MBB, MI, DL, Opcode, Amount, MachineInstr::NoFlags);
    }
  }

  return MBB.erase(MI);
}

TargetFrameLowering::DwarfFrameBase
KVXFrameLowering::getDwarfFrameBase(const MachineFunction &MF) const {
  return {DwarfFrameBase::CFA, {0}};
}

void KVXFrameLowering::emitStackCheck(MachineFunction &MF,
                                      MachineBasicBlock &MBB) const {
  MachineFrameInfo &MFI = MF.getFrameInfo();

  int64_t StackSize = (int64_t)MFI.getStackSize();

  DebugLoc DL;
  unsigned SPReg = getSPReg();

  const KVXInstrInfo *TII = STI.getInstrInfo();

  auto *CheckMBB = MF.CreateMachineBasicBlock();
  auto *CallMBB = MF.CreateMachineBasicBlock();

  MF.insert(MBB.getIterator(), CheckMBB);
  MF.insert(MBB.getIterator(), CallMBB);

  CheckMBB->addSuccessor(&MBB);
  CheckMBB->addSuccessor(CallMBB);

  CallMBB->setLabelMustBeEmitted();

  auto *KVXFI = MF.getInfo<KVXMachineFunctionInfo>();
  KVXFI->setOverflowMBB(CallMBB);

  Register StackLimitReg = findScratchRegister(MBB, false, KVX::R17);
  Register NewSPReg = findScratchRegister(MBB, false, KVX::R16);
  MachineBasicBlock::iterator CheckI = CheckMBB->begin();
  BuildMI(*CheckMBB, CheckI, DL, TII->get(KVX::GET), StackLimitReg)
      .addReg(KVX::SR)
      .setMIFlag(MachineInstr::FrameSetup);
  BuildMI(*CheckMBB, CheckI, DL, TII->get(getStackADDOpcode(StackSize)),
          NewSPReg)
      .addReg(SPReg)
      .addImm(-StackSize)
      .setMIFlag(MachineInstr::FrameSetup);

  BuildMI(*CheckMBB, CheckI, DL, TII->get(KVX::SBFDrr), NewSPReg)
      .addReg(NewSPReg)
      .addReg(StackLimitReg, RegState::Kill)
      .setMIFlags(MachineInstr::FrameSetup);
  BuildMI(*CheckMBB, CheckI, DL, TII->get(KVX::CB))
      .addReg(NewSPReg, RegState::Kill)
      .addMBB(&MBB)
      .addImm(KVXMOD::SCALARCOND_DLEZ)
      .setMIFlags(MachineInstr::FrameSetup);

  MachineBasicBlock::iterator CallI = CallMBB->begin();
  BuildMI(*CallMBB, CallI, DL, TII->get(KVX::GET), KVX::R0)
      .addReg(KVX::PC)
      .setMIFlags(MachineInstr::FrameSetup);
  BuildMI(*CallMBB, CallI, DL, TII->get(KVX::COPYD), KVX::R1).addReg(SPReg);
  BuildMI(*CallMBB, CallI, DL, TII->get(KVX::CALL))
      .addExternalSymbol("__stack_overflow_detected")
      .setMIFlags(MachineInstr::FrameSetup);
}
