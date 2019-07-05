//==- K1CRegisterInfo.h - K1C Register Information Impl ----------*- C++ -*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the K1C implementation of the RegisterInfo class.
//
//===----------------------------------------------------------------------===//

#include "K1CRegisterInfo.h"
#include "K1C.h"
#include "K1CSubtarget.h"
#include "MCTargetDesc/K1CMCTargetDesc.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/RegisterScavenging.h"
#include "llvm/CodeGen/TargetFrameLowering.h"
#include "llvm/CodeGen/TargetInstrInfo.h"
#include "llvm/Support/ErrorHandling.h"

#define GET_REGINFO_TARGET_DESC
#include "K1CGenRegisterInfo.inc"

using namespace llvm;

K1CRegisterInfo::K1CRegisterInfo(unsigned HwMode)
    : K1CGenRegisterInfo(K1C::RA, /*DwarfFlavour*/ 0,
                         /*EHFlavor*/ 0,
                         /*PC*/ 0, HwMode) {}
const uint32_t *
K1CRegisterInfo::getCallPreservedMask(const MachineFunction &MF,
                                      CallingConv::ID /*CC*/) const {
  return CSR_RegMask;
}

const MCPhysReg *
K1CRegisterInfo::getCalleeSavedRegs(const MachineFunction *MF) const {
  return CSR_SaveList;
}

BitVector K1CRegisterInfo::getReservedRegs(const MachineFunction &MF) const {
  BitVector Reserved(getNumRegs());

  // Use markSuperRegs to ensure any register aliases are also reserved
  markSuperRegs(Reserved, getSPReg());
  markSuperRegs(Reserved, K1C::R13);
  markSuperRegs(Reserved, getFPReg());
  markSuperRegs(Reserved, K1C::RA);
  return Reserved;
}

void K1CRegisterInfo::eliminateFrameIndex(MachineBasicBlock::iterator II,
                                          int SPAdj, unsigned FIOperandNum,
                                          RegScavenger *RS) const {
  MachineInstr &MI = *II;
  MachineFunction &MF = *MI.getParent()->getParent();

  DebugLoc DL = MI.getDebugLoc();

  int FrameIndex = MI.getOperand(FIOperandNum).getIndex();
  unsigned FrameReg;
  int Offset;
  // Check if the previous operand is immediate, if true replace it with the
  // computed value
  if (MI.getOperand(FIOperandNum - 1).isImm()) {
    Offset =
        getFrameLowering(MF)->getFrameIndexReference(MF, FrameIndex, FrameReg) +
        MI.getOperand(FIOperandNum - 1).getImm();

    MI.getOperand(FIOperandNum).ChangeToRegister(FrameReg, false, false, false);
    MI.getOperand(FIOperandNum - 1).ChangeToImmediate(Offset);
  } else {
    // Check if the next operand is immediate, if true replace it with the
    // computed value
    if (FIOperandNum + 1 < MI.getNumOperands() &&
        MI.getOperand(FIOperandNum + 1).isImm()) {
      Offset = getFrameLowering(MF)
                   ->getFrameIndexReference(MF, FrameIndex, FrameReg) +
               MI.getOperand(FIOperandNum + 1).getImm();

      MI.getOperand(FIOperandNum)
          .ChangeToRegister(FrameReg, false, false, false);
      MI.getOperand(FIOperandNum + 1).ChangeToImmediate(Offset);
    } else {
      llvm_unreachable("could not eliminate frame index");
    }
  }
  // if the instruction is used to save $ra on the stack
  // cfi offset instruction is added
  if (MI.getFlags() & (1 << 14)) {
    MachineBasicBlock &MBB = *MI.getParent();
    const K1CSubtarget &Subtarget = MF.getSubtarget<K1CSubtarget>();
    const K1CRegisterInfo &RegInfo = *Subtarget.getRegisterInfo();
    const K1CInstrInfo &TII = *Subtarget.getInstrInfo();

    MachineFrameInfo &MFI = MF.getFrameInfo();
    int64_t StackSize = (int64_t)MFI.getStackSize();

    unsigned CFIOffset = MF.addFrameInst(MCCFIInstruction::createOffset(
        nullptr, RegInfo.getDwarfRegNum(K1C::RA, true), Offset - StackSize));
    BuildMI(MBB, MI, DL, TII.get(TargetOpcode::CFI_INSTRUCTION))
        .addCFIIndex(CFIOffset)
        .setMIFlags(MachineInstr::FrameSetup);
  }
}

unsigned K1CRegisterInfo::getFrameRegister(const MachineFunction &MF) const {
  const TargetFrameLowering *TFI = getFrameLowering(MF);
  return TFI->hasFP(MF) ? getFPReg() : getSPReg();
}
