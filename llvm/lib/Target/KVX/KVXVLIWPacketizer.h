//===- KVXVLIWPacketizer.h - KVX Packetizer Class -------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the KVX Packetizer class implementation.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_KVX_KVXVLIWPACKETIZER_H
#define LLVM_LIB_TARGET_KVX_KVXVLIWPACKETIZER_H

#include "llvm/CodeGen/DFAPacketizer.h"

namespace llvm {

class KVXPacketizerList : public VLIWPacketizerList {

public:
  KVXPacketizerList(MachineFunction &MF, MachineLoopInfo &MLI,
                    AliasAnalysis *AA, bool ValidOptLevel);

  bool isSoloInstruction(const MachineInstr &MI) override;
  bool isLegalToPacketizeTogether(SUnit *SUI, SUnit *SUJ) override;

  bool shouldAddToPacket(const MachineInstr &MI) override;

  MachineBasicBlock::iterator addToPacket(MachineInstr &MI) override;

  void endPacket(MachineBasicBlock *MBB,
                 MachineBasicBlock::iterator MI) override;

  int getSchedClassIssueSize(const MachineInstr &MI);

  bool ignorePseudoInstruction(const MachineInstr &MI,
                               const MachineBasicBlock *) override;

  void moveCFIDebugInstructions(MachineFunction &MF);

private:
  int PacketSize;
  bool ValidOptLevel;

  bool isScheduledAlone(unsigned opcode);

  bool usesCarry(unsigned opcode);
  bool isSetOrWFXL(unsigned Opcode);
  bool isSetOrWFXLOrWFXM(unsigned Opcode);
  bool useFloatingPointIEEE754(unsigned opcode);

  bool isALU(unsigned scheduleCode);
  bool isMAU(unsigned scheduleCode);
  bool isALUCarryWithSetOrWFXL(unsigned ISchedClass, unsigned IOpcode,
                               unsigned JOpcode);
  bool isALUFP754OrMAUFP754WithSetOrWFX_(unsigned ISchedClass, unsigned IOpcode,
                                         unsigned JOpcode);

  bool shouldBeLastInBundle(unsigned opcode);
};

} // end namespace llvm

#endif // LLVM_LIB_TARGET_KVX_KVXVLIWPACKETIZER_H
