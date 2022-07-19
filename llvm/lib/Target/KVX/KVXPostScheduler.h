//===- KVXPostScheduler.h - KVX PostRA Scheduler --------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// KVXPostScheduler: an instance of PostGenericScheduler (from MachineScheduler)
// that uses the issue cycle information (TopReadyCycle) to packetize
// instructions.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_KVX_KVXPOSTSCHEDULER_H
#define LLVM_LIB_TARGET_KVX_KVXPOSTSCHEDULER_H

#include "llvm/CodeGen/DFAPacketizer.h"
#include "llvm/CodeGen/MachineBasicBlock.h"
#include "llvm/CodeGen/MachineScheduler.h"
#include "llvm/CodeGen/TargetInstrInfo.h"
#include "llvm/CodeGen/TargetRegisterInfo.h"

namespace llvm {

class KVXPostPacketizer {
public:
  KVXPostPacketizer(MachineBasicBlock *MBB) {
    this->MBB = MBB;
    MF = MBB->getParent();
    TRI = MF->getSubtarget().getRegisterInfo();

    TII = MF->getSubtarget().getInstrInfo();
    ResourceTracker = TII->CreateTargetScheduleState(MF->getSubtarget());
  }

  // Try packetizing. Move solo instructions (debug, inline asm, etc..) above
  // the packet as needed.
  // isLast is true if the packet is the last of the region
  void runOnPacket(std::vector<MachineInstr *> &Packet, bool IsLast,
                   unsigned LastCycle, SUnit *ExitSU);

private:
  MachineBasicBlock *MBB;
  MachineFunction *MF;
  const TargetRegisterInfo *TRI;
  const TargetInstrInfo *TII;
  // For checking resource constraints on terminator.
  // NOTE: requires itineraries!
  DFAPacketizer *ResourceTracker;
};

/// KVXPostScheduler is PostGenericScheduler with extra bundling feature
class KVXPostScheduler : public PostGenericScheduler {
public:
  KVXPostScheduler(const MachineSchedContext *C) : PostGenericScheduler(C) {}

  ~KVXPostScheduler() override = default;

  void enterMBB(MachineBasicBlock *MBB) override {
    Packetizer = new KVXPostPacketizer(MBB);
    PostGenericScheduler::enterMBB(MBB);
  }
  void leaveMBB() override {
    delete Packetizer;
    PostGenericScheduler::leaveMBB();
  }

  void schedNode(SUnit *SU, bool IsTopNode) override;
  void enterRegion() override;
  void leaveRegion() override;

private:
  std::map<unsigned, std::vector<MachineInstr *>> CycleToMIs;
  unsigned LastCycle;
  KVXPostPacketizer *Packetizer;
};

std::unique_ptr<ScheduleDAGMutation> createKVXPrologEpilogDAGMutation();
std::unique_ptr<ScheduleDAGMutation> createKVXExitMIDataDepsMutation();

class KVXScheduleDAGMI : public ScheduleDAGMI {
private:
  // A CFIEntry is a couple: (CFI, Attach) where Attach is the
  // MachineInstruction just before the CFI.
  // If CFIAtMBBStart is true, then the CFI is attached to the start of the
  // basicblock
  struct CFIEntry {
    MachineInstr *CFI, *Attach;
    bool CFIAtMBBStart;
  };

public:
  KVXScheduleDAGMI(MachineSchedContext *C,
                   std::unique_ptr<MachineSchedStrategy> S,
                   bool RemoveKillFlags, bool DisableBundling)
      : ScheduleDAGMI(C, std::move(S), RemoveKillFlags),
        DisableBundling(DisableBundling) {
    this->addMutation(createKVXPrologEpilogDAGMutation());
    this->addMutation(createKVXExitMIDataDepsMutation());
  }
  ~KVXScheduleDAGMI() override = default;

  // On startBlock, temporarily remove CFI instructions out of MBB
  // On finishBlock, put them back
  void startBlock(MachineBasicBlock *MBB) override;
  void finishBlock() override;

#ifndef NDEBUG
  // For debug purposes only, print the region
  void enterRegion(MachineBasicBlock *MBB, MachineBasicBlock::iterator Begin,
                   MachineBasicBlock::iterator End,
                   unsigned Regioninstrs) override;
#endif
  bool skipSingleInstrRegions() override { return false; }

private:
  bool DisableBundling;
  MachineBasicBlock *MBB;
  KVXPostPacketizer *Packetizer;
  std::vector<CFIEntry> CFIs;
};

} // namespace llvm

#endif // LLVM_LIB_TARGET_KVX_KVXPOSTSCHEDULER_H
