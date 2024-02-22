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
  KVXPacketizerList(MachineFunction &MF, MachineLoopInfo &MLI, AAResults *AA);

  bool shouldAddToPacket(const MachineInstr &MI) override;
  MachineBasicBlock::iterator addToPacket(MachineInstr &MI) override;
  void endPacket(MachineBasicBlock *MBB,
                 MachineBasicBlock::iterator MBBI) override;
  bool isSoloInstruction(const MachineInstr &MI) override;
  bool ignorePseudoInstruction(const MachineInstr &MI,
                               const MachineBasicBlock *) override;
  bool isLegalToPacketizeTogether(SUnit *SUI, SUnit *SUJ) override;

  void moveDebugInstructionsOut(MachineFunction &MF);

private:
  unsigned PacketSize, MaxPacketSize;
};

} // end namespace llvm

#endif // LLVM_LIB_TARGET_KVX_KVXVLIWPACKETIZER_H
