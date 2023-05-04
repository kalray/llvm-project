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
#include "KVXFrameLowering.h"
#include "KVXMachineFunctionInfo.h"
#include "KVXSubtarget.h"
#include "MCTargetDesc/KVXMCTargetDesc.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/RegisterScavenging.h"
#include "llvm/CodeGen/TargetFrameLowering.h"
#include "llvm/CodeGen/TargetInstrInfo.h"
#include "llvm/MC/MCDwarf.h"
#include "llvm/Support/ErrorHandling.h"

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

  // Reserve a register if dynamic objects need stack realignment.
  if (needsLocalAreaRealignment(MF)) {
    // TODO: can reuse FPReg if FP is not needed.
    markSuperRegs(Reserved, getLARReg());
  }

  return Reserved;
}

// Stack's locals area needs realignment when any object from this area has an
// alignment greater than the default stack alignment.
bool KVXRegisterInfo::needsLocalAreaRealignment(
    const MachineFunction &MF) const {
  const TargetFrameLowering *TFI = getFrameLowering(MF);
  const MachineFrameInfo &MFI = MF.getFrameInfo();

  for (int fi = MFI.getObjectIndexBegin(); fi < MFI.getObjectIndexEnd(); fi++) {
    if (!MFI.isVariableSizedObjectIndex(fi)) {
      if (MFI.getObjectAlign(fi).value() > TFI->getStackAlignment()) {
        return true;
      }
    }
  }

  return false;
}

// Get maximum alignment of the local area.
unsigned
KVXRegisterInfo::getLocalAreaAlignment(const MachineFunction &MF) const {
  const TargetFrameLowering *TFI = getFrameLowering(MF);
  const MachineFrameInfo &MFI = MF.getFrameInfo();

  unsigned long Align = TFI->getStackAlignment();

  for (int fi = MFI.getObjectIndexBegin(); fi < MFI.getObjectIndexEnd(); fi++) {
    if (!MFI.isVariableSizedObjectIndex(fi)) {
      if (MFI.getObjectAlign(fi).value() > TFI->getStackAlignment()) {
        Align = std::max(Align, MFI.getObjectAlign(fi).value());
      }
    }
  }

  return Align;
}

// Local Area Realigned Register.
Register KVXRegisterInfo::getLARReg() const { return KVX::R31; }

void KVXRegisterInfo::eliminateFrameIndex(MachineBasicBlock::iterator II,
                                          int SPAdj, unsigned FIOperandNum,
                                          RegScavenger *RS) const {
  MachineInstr &MI = *II;
  MachineFunction &MF = *MI.getParent()->getParent();

  DebugLoc DL = MI.getDebugLoc();

  int FrameIndex = MI.getOperand(FIOperandNum).getIndex();
  Register FrameReg;
  long Offset;

  auto *KVXFI = MF.getInfo<KVXMachineFunctionInfo>();
  auto const &Indexes = KVXFI->getMinMaxCSFrameIndexes();
  const TargetFrameLowering *TFI = getFrameLowering(MF);

  // Adjust Offset.
  if (TFI->hasFP(MF) &&
      (Indexes.first > FrameIndex || FrameIndex > Indexes.second) &&
      !KVXFI->isAdjustLocalAreaSP()) {
    // If hasFP, Offset is relative to FP (i.e., ObjectOffset + distance between
    // caller SP and callee FP)
    Offset = -MF.getFrameInfo().getObjectOffset(KVXFI->getFPIndex());
  } else {
    // Offset is relative to callee SP.
    Offset = MF.getFrameInfo().getStackSize();
  }

  // Check if the previous operand is immediate, if true replace it with the
  // computed value.
  if (FIOperandNum > 0 && MI.getOperand(FIOperandNum - 1).isImm()) {
    Offset += getFrameLowering(MF)
                  ->getFrameIndexReference(MF, FrameIndex, FrameReg)
                  .getFixed() +
              MI.getOperand(FIOperandNum - 1).getImm();

    MI.getOperand(FIOperandNum).ChangeToRegister(FrameReg, false, false, false);
    MI.getOperand(FIOperandNum - 1).ChangeToImmediate(Offset);
  } else {
    // Check if the next operand is immediate, if true replace it with the
    // computed value.
    if (FIOperandNum + 1 < MI.getNumOperands() &&
        MI.getOperand(FIOperandNum + 1).isImm()) {
      Offset += getFrameLowering(MF)
                    ->getFrameIndexReference(MF, FrameIndex, FrameReg)
                    .getFixed() +
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
      // Simply replace FI with the corresponding offset.
      Offset += getFrameLowering(MF)
                    ->getFrameIndexReference(MF, FrameIndex, FrameReg)
                    .getFixed();

      if (MI.getOpcode() == KVX::SUBDri64) {
        const KVXInstrInfo *TII =
            static_cast<const KVXInstrInfo *>(MF.getSubtarget().getInstrInfo());

        Offset = -Offset;
        MI.setDesc(TII->get(
            GetImmOpCode(Offset, KVX::ADDDri10, KVX::ADDDri37, KVX::ADDDri64)));
      }

      MI.getOperand(FIOperandNum).ChangeToImmediate(Offset);
    }
  }
}

llvm::Register
KVXRegisterInfo::getFrameRegister(const MachineFunction &MF) const {
  const TargetFrameLowering *TFI = getFrameLowering(MF);

  return TFI->hasFP(MF) ? getFPReg() : getSPReg();
}
