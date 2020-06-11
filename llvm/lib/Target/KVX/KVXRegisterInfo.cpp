//==- KVXRegisterInfo.h - KVX Register Information Impl ----------*- C++ -*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the KVX implementation of the RegisterInfo class.
//
//===----------------------------------------------------------------------===//

#include "KVXRegisterInfo.h"
#include "KVX.h"
#include "KVXSubtarget.h"
#include "MCTargetDesc/KVXMCTargetDesc.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/RegisterScavenging.h"
#include "llvm/CodeGen/TargetFrameLowering.h"
#include "llvm/CodeGen/TargetInstrInfo.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/MC/MCDwarf.h"

#define GET_REGINFO_TARGET_DESC
#include "KVXGenRegisterInfo.inc"

using namespace llvm;

KVXRegisterInfo::KVXRegisterInfo(unsigned HwMode)
    : KVXGenRegisterInfo(KVX::RA, /*DwarfFlavour*/ 0,
                         /*EHFlavor*/ 0,
                         /*PC*/ 0, HwMode) {}
const uint32_t *
KVXRegisterInfo::getCallPreservedMask(const MachineFunction &MF,
                                      CallingConv::ID /*CC*/) const {
  return CSR_RegMask;
}

const MCPhysReg *
KVXRegisterInfo::getCalleeSavedRegs(const MachineFunction *MF) const {
  return CSR_SaveList;
}

BitVector KVXRegisterInfo::getReservedRegs(const MachineFunction &MF) const {
  BitVector Reserved(getNumRegs());

  // Use markSuperRegs to ensure any register aliases are also reserved
  markSuperRegs(Reserved, getSPReg());
  markSuperRegs(Reserved, KVX::R13);
  markSuperRegs(Reserved, getFPReg());
  markSuperRegs(Reserved, KVX::RA);
  if (MF.getFrameInfo().hasVarSizedObjects() &&
      MF.getSubtarget().getRegisterInfo()->needsStackRealignment(MF))
    markSuperRegs(Reserved, KVX::R31);
  return Reserved;
}

void KVXRegisterInfo::eliminateFrameIndex(MachineBasicBlock::iterator II,
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
  if (FIOperandNum > 0 && MI.getOperand(FIOperandNum - 1).isImm()) {
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
      if (MI.getOpcode() == KVX::ADDDri64) {
        const KVXInstrInfo *TII =
            static_cast<const KVXInstrInfo *>(MF.getSubtarget().getInstrInfo());
        MI.setDesc(TII->get(
            GetImmOpCode(Offset, KVX::ADDDri10, KVX::ADDDri37, KVX::ADDDri64)));
      }
    } else {
      llvm_unreachable("could not eliminate frame index");
    }
  }
}

llvm::Register
KVXRegisterInfo::getFrameRegister(const MachineFunction &MF) const {
  const TargetFrameLowering *TFI = getFrameLowering(MF);
  return TFI->hasFP(MF) ? getFPReg() : getSPReg();
}
