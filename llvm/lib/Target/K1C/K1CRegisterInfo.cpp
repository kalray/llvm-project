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
#include "MCTargetDesc/K1CMCTargetDesc.h"
#include "K1C.h"
#include "K1CSubtarget.h"
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

const MCPhysReg *
K1CRegisterInfo::getCalleeSavedRegs(const MachineFunction *MF) const {
  return CSR_SaveList;
}

BitVector K1CRegisterInfo::getReservedRegs(const MachineFunction &MF) const {
  BitVector Reserved(getNumRegs());

  // Use markSuperRegs to ensure any register aliases are also reserved
  markSuperRegs(Reserved, K1C::R12);
  markSuperRegs(Reserved, K1C::R13);
  markSuperRegs(Reserved, K1C::R14);
  return Reserved;
}

void K1CRegisterInfo::eliminateFrameIndex(MachineBasicBlock::iterator II,
                                          int SPAdj, unsigned FIOperandNum,
                                          RegScavenger *RS) const {}

unsigned K1CRegisterInfo::getFrameRegister(const MachineFunction &MF) const {
  return K1C::R14;
}
