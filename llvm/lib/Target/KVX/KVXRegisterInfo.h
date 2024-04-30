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

#ifndef LLVM_LIB_TARGET_KVX_KVXREGISTERINFO_H
#define LLVM_LIB_TARGET_KVX_KVXREGISTERINFO_H

#include "llvm/CodeGen/TargetRegisterInfo.h"

#define GET_REGINFO_HEADER
#include "KVXGenRegisterInfo.inc"

namespace llvm {

struct KVXRegisterInfo : public KVXGenRegisterInfo {

  KVXRegisterInfo(unsigned HwMode);

  const uint32_t *getCallPreservedMask(const MachineFunction &MF,
                                       CallingConv::ID) const override;
  const MCPhysReg *getCalleeSavedRegs(const MachineFunction *MF) const override;
  BitVector getReservedRegs(const MachineFunction &MF) const override;

  bool needsLocalAreaRealignment(const MachineFunction &MF) const;
  unsigned getLocalAreaAlignment(const MachineFunction &MF) const;
  Register getLARReg() const;

  bool eliminateFrameIndex(MachineBasicBlock::iterator MI,
                                   int SPAdj, unsigned FIOperandNum,
                                   RegScavenger *RS = nullptr) const override;

  llvm::Register getFrameRegister(const MachineFunction &MF) const override;

  bool trackLivenessAfterRegAlloc(const MachineFunction &MF) const override {
    return true;
  }

  bool useFPForScavengingIndex(const MachineFunction &MF) const override {
    return false;
  }

  // bool isConstantPhysReg(MCRegister PhysReg) const override;
  bool isVolatilePhysReg(MCRegister PhysReg) const override;
  const uint32_t *getNoPreservedMask() const override;

  ArrayRef<MCPhysReg>
  getIntraCallClobberedRegs(const MachineFunction *MF) const override;
};

} // namespace llvm

#endif
