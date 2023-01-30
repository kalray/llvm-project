//===- KVXPostScheduler.cpp - KVX PostRA Scheduler ------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Implementation of KVXPostScheduler
//
//===----------------------------------------------------------------------===//

#include "KVXPostScheduler.h"
#include "KVXInstrInfo.h"
#include "llvm/CodeGen/DFAPacketizer.h"
#include "llvm/CodeGen/MachineInstrBundle.h"
#include "llvm/CodeGen/MachineOperand.h"
#include "llvm/CodeGen/ScheduleDAG.h"
#include "llvm/CodeGen/SelectionDAGNodes.h"
#include "llvm/CodeGen/TargetInstrInfo.h"
#include "llvm/CodeGen/TargetRegisterInfo.h"
#include "llvm/CodeGen/TargetSubtargetInfo.h"
#include "llvm/IR/ModuleSlotTracker.h"
#include "llvm/MC/MCRegisterInfo.h"
#include <set>

#define DEBUG_TYPE "machine-scheduler"
#define KDEBUG(expr) LLVM_DEBUG(dbgs() << "KVXPostScheduler: " << expr << "\n")

namespace llvm {

// ========================================================================== //
//                             KVXPostPacketizer
// ========================================================================== //

// Returns the distance between the last instruction of the Packet and the
// terminator. Distance == 0 -> terminator should not be bundled.
static inline int canBundleWith(std::vector<MachineInstr *> Packet,
                                MachineInstr *ExitMI,
                                const TargetInstrInfo *TII,
                                const TargetRegisterInfo *TRI,
                                DFAPacketizer *ResourceTracker, SUnit *ExitSU,
                                unsigned LastCycle) {
  int Distance = 1;

  // Skip DBG_VALUE and DBG_LABEL until the terminator is reached
  auto ExitII = ExitMI->getIterator();
  while (ExitSU->getInstr() != nullptr && // the ExitSU exists
         &*ExitII != ExitSU->getInstr() &&
         (ExitII->isDebugValue() | ExitII->isDebugLabel())) {
    ++ExitII;
    ++Distance;
  }
  ExitMI = &*ExitII;
  assert(ExitSU->getInstr() == nullptr || ExitMI == ExitSU->getInstr());

  // At this point, ExitSU is not guaranteed to have an attached instruction.
  // Indeed, some solo instructions such as DBG_VALUE do not have
  // a SU attached. So we use ExitMI in the test below.
  if (TII->isSoloInstruction(*ExitMI)) {
    KDEBUG("Cannot bundle terminator: is a solo instruction");
    return false;
  }

  // Instructions that are not solo have a SU attached. So from now on, we can
  // use ExitSU directly.
  assert(ExitSU->getInstr() != nullptr);

  // Check for side effects
  if (ExitMI->getDesc().hasUnmodeledSideEffects()) {
    KDEBUG("Cannot bundle terminator: has side effects");
    return false;
  }

  // Check for dependencies
  std::set<unsigned> CheckReg{};
  for (const MachineOperand &TerminatorMO : ExitMI->operands()) {
    if (TerminatorMO.isReg() && !TerminatorMO.isImplicit()) {
      // Add all aliases of the register
      Register TerminatorReg = TerminatorMO.getReg();
      for (MCRegAliasIterator Alias(TerminatorReg, TRI, true); Alias.isValid();
           ++Alias)
        CheckReg.insert((*Alias).id());
    }
  }

  if (!CheckReg.empty()) {
    for (auto &SDep : ExitSU->Preds) {
      // Ignore WAR dependencies
      if (SDep.getLatency() == 0)
        continue;

      // Ignore artificial dependencies. Also ignore dependencies on implicit
      // operands.
      if (SDep.getKind() == SDep::Order || !CheckReg.count(SDep.getReg()))
        continue;

      // Check for RAW and WAW dependencies between the packet and the
      // terminator
      MachineInstr *DepMI = SDep.getSUnit()->getInstr();
      if (std::find(Packet.begin(), Packet.end(), DepMI) != Packet.end()) {
        KDEBUG("Cannot bundle terminator: a dependency would be broken");
        return false;
      }

      // Check for stalls
      unsigned MICycle = SDep.getSUnit()->TopReadyCycle;
      if (LastCycle < MICycle + SDep.getLatency()) {
        KDEBUG("Do not bundle terminator: it would insert stalls");
        return false;
      }
    }
  }

  // Check for resource constraints
  ResourceTracker->clearResources();
  constexpr int MaxPacketSize = 8 /* words (syllables) of */ * 4 /* bytes */;
  int PacketSize = 0;

  for (MachineInstr *MI : Packet) {
    ResourceTracker->reserveResources(*MI);
    PacketSize += MI->getDesc().getSize();
    assert(PacketSize <= MaxPacketSize &&
           "Packet is too big: the scheduler messed up");
  }

  int TerminatorSize = ExitMI->getDesc().getSize();
  if (TerminatorSize + PacketSize > MaxPacketSize) {
    KDEBUG("Cannot bundle terminator: not enough ISSUE resources");
    return false;
  }

  if (!ResourceTracker->canReserveResources(*ExitMI)) {
    KDEBUG("Cannot bundle terminator: not enough non-ISSUE resources");
    return false;
  }

  assert(Distance > 0);
  return Distance;
}

#ifndef NDEBUG
static void debugPrintPacket(MachineBasicBlock *MBB, MachineInstr *MIFirst,
                             MachineInstr *MILast, ModuleSlotTracker *MST) {
  for (auto II = MIFirst->getIterator();
       II != MBB->end() && II != std::next(MILast->getIterator()); ++II) {
    MachineInstr *MIP = &*II;
    LLVM_DEBUG(MIP->print(dbgs() << "\t", MST));
  }
}

static void debugPrintMBB(MachineBasicBlock *MBB, ModuleSlotTracker *MST) {
  if (MBB->size() == 0) {
    LLVM_DEBUG(dbgs() << "\tEmpty.\n");
    return;
  }
  debugPrintPacket(MBB, &*MBB->begin(), &*std::prev(MBB->end()), MST);
}
#endif

// Assumes the terminator is not included in the Packet
void KVXPostPacketizer::runOnPacket(std::vector<MachineInstr *> &Packet,
                                    bool IsLast, unsigned LastCycle,
                                    SUnit *ExitSU) {
  assert(!Packet.empty());

  // Move solo instructions above the future bundle
  // NOTE: not all instructions are scheduled (debug instrutions are not), so
  // we need to investigate all instructions between the beginning and the
  // end of the bundle.
  MachineInstr *MIFirst = Packet.front();
  auto MIFirstIter = MIFirst->getIterator();
  MachineInstr *MILast = Packet.back();
  MachineBasicBlock::iterator MISoloInsertPoint = MILast->getIterator();

#ifndef NDEBUG
  const Function &F = MBB->getParent()->getFunction();
  const Module *M = F.getParent();
  ModuleSlotTracker MST(M);
#endif

#ifndef NDEBUG
  KDEBUG("Potential packet to examine:");
  debugPrintPacket(MBB, MIFirst, MILast, &MST);
  KDEBUG("End of packet");
#endif

  KDEBUG("Moving solo instructions after the bundle...");
  auto PI = Packet.begin(); // manual iteration through the packet
  for (auto II = MIFirstIter, NII = std::next(II);
       II != MBB->end() && II != std::next(MILast->getIterator()); II = NII) {
    NII = std::next(II);

    MachineInstr &MI = *II;
    MachineInstr *MIP = &MI;

    if (TII->isSoloInstruction(MI)) {
      if (MIP != MILast) {
        KDEBUG("Moving this solo instruction after bundle\n-> ");
        LLVM_DEBUG(MIP->print(dbgs(), MST));
        // Moving after the last instruction.
        // Initially, the insert point is after the bundle. It is updated to
        // conserve the order of the moved instructions.
        MachineInstr *Removed = MBB->remove(MIP);
        MISoloInsertPoint = MBB->insertAfter(MISoloInsertPoint, Removed);
      }

      // Remove the instruction from Packet to prevent its bundling
      // We do this only if it actually is in the packet!
      // (indeed, some instructions are not scheduled, cf the NOTE)
      if (*PI == MIP) {
        PI = Packet.erase(PI);
      }
    } else if (*PI == MIP) {
      // Not a solo instruction, but it is in the packet. Advance the packet
      // iterator.
      ++PI;
    }
  }
  KDEBUG("Moving done.");

  // Do not bundle if the bundle became empty
  if (Packet.empty()) {
    KDEBUG("Bundle is now empty, skipping it");
    return;
  }

  // Reload iterators before bundling
  MIFirst = Packet.front();
  MIFirstIter = MIFirst->getIterator();
  MILast = Packet.back();
  auto MILastIter = MILast->getIterator();

  // There are 3 different cases to consider based on the region pattern
  // (cf MachineScheduler:getSchedRegions)
  // Below, I is MILast, T is right after, END is the end of MBB
  // Case 1: .... I; T; ... END; && isSchedBoundary(T) // T is terminator
  // Case 2: .... I; T=END; // T is terminator
  // Case 3: .... I=END; // There is no terminator (fallthrough)
  // Case 1 and 2 can be simplified to checking if MILastIter != MBB->end()
  // Case 3 means there is no terminator to bundle
  bool TerminatorExists = IsLast && std::next(MILastIter) != MBB->end();

#ifndef NDEBUG
  KDEBUG("Bundle content:");
  debugPrintPacket(MBB, MIFirst, MILast, &MST);
  KDEBUG("End of bundle content\n");
  if (TerminatorExists) {
    KDEBUG("Will attempt to bundle this terminator with it:");
    MachineInstr *MITerminator = &*std::next(MILastIter);
    LLVM_DEBUG(MITerminator->print(dbgs() << "\t", MST));
  }
#endif

  if (TerminatorExists) {
    // Try bundling the instruction after the last instruction of the packet
    MachineInstr *MITerminator = &*std::next(MILastIter);
#ifndef NDEBUG
    MachineInstr *ExitMI = ExitSU->getInstr();
    if (ExitMI) {
      KDEBUG("ExitSU instruction:");
      LLVM_DEBUG(ExitMI->print(dbgs(), MST));
    } else {
      KDEBUG("No ExitSU");
    }
#endif
    if (int Distance = canBundleWith(Packet, MITerminator, TII, TRI,
                                     ResourceTracker, ExitSU, LastCycle)) {
      // Bundling is authorized. Remove all the DEBUG_VALUE between the last
      // instruction of the packet and the ExitSU. Place all DEBUG_LABEL to
      // the start of the bundle.
      auto PacketStart = Packet.front()->getIterator();
      int DebugCount = Distance - 1;
      if (DebugCount > 0) {
        for (auto II = MITerminator->getIterator(), NII = std::next(II);
             DebugCount > 0; DebugCount--, II = NII) {
          NII = std::next(II);
          MachineInstr *MII = &*II;
          assert(MII->isDebugValue() || MII->isDebugLabel());
          MBB->remove(MII);
          if (MII->isDebugLabel())
            MBB->insert(PacketStart, MII);
        }
      }
      MILastIter++;
    }
  }

  // Avoid bundling single instructions
  if (MIFirstIter == MILastIter) {
    KDEBUG("Not bundling a single instruction.");
    return;
  }

  finalizeBundle(*MBB, MIFirstIter, std::next(MILastIter));
}

// ========================================================================== //
//                             KVXPostScheduler
// ========================================================================== /

void KVXPostScheduler::enterRegion() {
  CycleToMIs.clear();
  LastCycle = 0;
  PostGenericScheduler::enterRegion();
}

void KVXPostScheduler::schedNode(SUnit *SU, bool IsTopNode) {
  PostGenericScheduler::schedNode(SU, IsTopNode);

  unsigned Cycle = SU->TopReadyCycle;
  KDEBUG("adding this SU to cycle " << Cycle);
  CycleToMIs[Cycle].push_back(SU->getInstr());
  LastCycle = Cycle;
}

void KVXPostScheduler::leaveRegion() {
  KDEBUG("leaving region. Bundle instructions");

  // Iterate on each future packet of instructions
  for (auto &Pair : CycleToMIs) {
    auto &Packet = Pair.second;
    unsigned Cycle = Pair.first;
    Packetizer->runOnPacket(Packet, Cycle == LastCycle, LastCycle,
                            &DAG->ExitSU);
  }
  KDEBUG("End of bundling process");

  PostGenericScheduler::leaveRegion();
}

// ========================================================================== //
//                             KVXScheduleDAGMI
// ========================================================================== //

#ifndef NDEBUG
void KVXScheduleDAGMI::enterRegion(MachineBasicBlock *MBB,
                                   MachineBasicBlock::iterator Begin,
                                   MachineBasicBlock::iterator End,
                                   unsigned Regioninstrs) {
  LLVM_DEBUG(dbgs() << "\n");
  KDEBUG("Region content:");
  const Function &F = MBB->getParent()->getFunction();
  const Module *M = F.getParent();
  ModuleSlotTracker MST(M);
  auto PacketEnd = End == MBB->end() ? std::prev(End) : End;
  debugPrintPacket(MBB, &*Begin, &*PacketEnd, &MST);
  KDEBUG("End of region content\n");

  ScheduleDAGMI::enterRegion(MBB, Begin, End, Regioninstrs);
}
#endif

void KVXScheduleDAGMI::startBlock(MachineBasicBlock *MBB) {
  this->MBB = MBB;
  if (!DisableBundling)
    Packetizer = new KVXPostPacketizer(MBB);
  CFIs.clear();

  if (MBB->size() == 0) {
    KDEBUG("Empty MBB, skipping.");
    ScheduleDAGMI::startBlock(MBB);
    return;
  }

  KDEBUG("Temporarily remove CFIs from MBB.");
  KDEBUG("MBB content:");
#ifndef NDEBUG
  const Function &F = MBB->getParent()->getFunction();
  const Module *M = F.getParent();
  ModuleSlotTracker MST(M);
  debugPrintMBB(MBB, &MST);
  int CFICounter = 0;
#endif

  // Remove CFIs from MBB
  auto Begin = MBB->begin();
  bool IsMBBStart = true;
  for (auto II = Begin, NII = std::next(II); II != MBB->end(); II = NII) {
    NII = std::next(II);
    MachineInstr *MII = &*II;
    if (MII->isCFIInstruction()) {
      MachineInstr *Attach;
      Attach = IsMBBStart ? nullptr : &*std::prev(II);
      MachineInstr *CFI = MBB->remove(MII);
      CFIs.push_back({CFI, Attach, IsMBBStart});
#ifndef NDEBUG
      CFICounter++;
#endif
    } else {
      IsMBBStart = false;
    }
  }

#ifndef NDEBUG
  KDEBUG("Number of CFI instructions removed:" << CFICounter);
  if (CFICounter > 0) {
    KDEBUG("MBB content after CFIs removal:");
    debugPrintMBB(MBB, &MST);
  }
#endif

  ScheduleDAGMI::startBlock(MBB);
}

void KVXScheduleDAGMI::finishBlock() {
#ifndef NDEBUG
  const Function &F = MBB->getParent()->getFunction();
  const Module *M = F.getParent();
  ModuleSlotTracker MST(M);
  if (CFIs.size() > 0) {
    KDEBUG("Place CFI instructions back in the MBB");
    KDEBUG("MBB content:");
    debugPrintMBB(MBB, &MST);
  }
#endif

  for (auto Entry : CFIs) {
    MachineInstr *Attach = Entry.Attach, *CFI = Entry.CFI;

    if (Entry.CFIAtMBBStart) {
      MBB->insertAfter(MBB->begin(), CFI);
      continue;
    }

    auto II = Attach->getIterator();
    while (II->isBundledWithSucc())
      II++;

    // Do not place CFI after basic block terminator
    if (II->isTerminator())
      continue;

    MBB->insertAfterBundle(Attach->getIterator(), CFI);
  }

#ifndef NDEBUG
  if (CFIs.size() > 0) {
    KDEBUG("MBB content after replacing the CFIs:");
    debugPrintMBB(MBB, &MST);
  }
#endif

  if (!DisableBundling)
    delete Packetizer;
  ScheduleDAGMI::finishBlock();
}

// ========================================================================== //
//                             Mutations
// ========================================================================== //

// Ensures prolog (resp. epilog) is in first (resp. last) bundle
class PrologEpilogFreeze : public ScheduleDAGMutation {
public:
  PrologEpilogFreeze() {}
  void apply(ScheduleDAGInstrs *DAG) override {
    auto *KII = (const KVXInstrInfo *)DAG->TII;

    // Assume the frame-setup and frame-destroy are not present, until they
    // are found
    SUnit *PrologSU = nullptr, *EpilogSU = nullptr;
    std::vector<SUnit *> BodySUs{}; // all other instructions

    for (SUnit &SU : DAG->SUnits) {
      const MachineInstr *MI = SU.getInstr();
      if (KII->isProlog(MI)) {
        assert(!KII->isEpilog(MI));
        assert(!PrologSU && "Two prolog instructions: not supported");
        PrologSU = &SU;
      } else if (KII->isEpilog(MI)) {
        assert(!EpilogSU && "Two epilog instructions: not supported");
        EpilogSU = &SU;
      } else {
        BodySUs.push_back(&SU);
      }
    }

    // Artificial dependences between frame-setup and body
    if (PrologSU) {
      SUnit *FromSU = PrologSU;
      for (SUnit *ToSU : BodySUs)
        DAG->addEdge(ToSU, SDep(FromSU, SDep::Artificial));
    }

    // Artificial dependences between body and frame-destroy
    if (EpilogSU) {
      SUnit *ToSU = EpilogSU;
      for (SUnit *FromSU : BodySUs)
        DAG->addEdge(ToSU, SDep(FromSU, SDep::Artificial));
    }
  }
};

std::unique_ptr<ScheduleDAGMutation> createKVXPrologEpilogDAGMutation() {
  return std::make_unique<PrologEpilogFreeze>();
}

/// ScheduleDAGMI does not model the data dependencies between the SUs and
/// ExitMI, so we add them.
class ExitMIDataDeps : public ScheduleDAGMutation {
public:
  ExitMIDataDeps() {}
  void apply(ScheduleDAGInstrs *DAG) override {
    const TargetSubtargetInfo &ST = DAG->MF.getSubtarget();
    MachineInstr *TerminatorMI = DAG->ExitSU.getInstr();
    // TerminatorMI might not exist if it is a region with fallthrough
    if (!TerminatorMI)
      return;

    auto *SchedModel = DAG->getSchedModel();

    struct DefInfo {
      SUnit *From;
      unsigned OperIdx;
    };

    // Check for Read-After-Write and Write-After-Write dependencies with
    // ExitMI. Go through the list of SUs backwards, record the Writes.
    std::set<Register> Defs;
    std::map<Register, DefInfo> DefInfos;
    for (auto SUI = DAG->SUnits.rbegin(); SUI != DAG->SUnits.rend(); SUI++) {
      auto &SU = *SUI;
      MachineInstr *MI = SU.getInstr();
      for (unsigned J = 0, N = MI->getNumOperands(); J != N; ++J) {
        const MachineOperand &MO = MI->getOperand(J);
        if (!MO.isReg() || MO.isUse())
          continue;
        assert(MO.isDef());
        Register Reg = MO.getReg();
        // Skip if we already counted a Def on that register (the former takes
        // precedence)
        if (Defs.count(Reg))
          continue;
        Defs.insert(Reg);
        DefInfos[Reg] = {&SU, J};
      }
    }

    // Iterate through ExitMI's operand and create dependencies based on the
    // writes recorded earlier.
    for (unsigned I = 0, N = TerminatorMI->getNumOperands(); I != N; ++I) {
      const MachineOperand &TerminatorMO = TerminatorMI->getOperand(I);
      if (!TerminatorMO.isReg() || TerminatorMO.isImplicit() ||
          TerminatorMO.isDebug())
        continue;
      bool IsDef = TerminatorMO.isDef();
      Register TerminatorReg = TerminatorMO.getReg();
      assert(TerminatorReg && "Unhandled MachineOperand type");
      auto *TRI = DAG->MF.getSubtarget().getRegisterInfo();
      for (MCRegAliasIterator Alias(TerminatorReg, TRI, true); Alias.isValid();
           ++Alias) {
        Register Reg = (*Alias).id();
        DefInfo &Info = DefInfos[Reg];
        if (Defs.count(*Alias)) {
          SDep::Kind Kind = IsDef ? SDep::Output : SDep::Data;
          SDep Dep(Info.From, Kind, Reg);
          Dep.setLatency(SchedModel->computeOperandLatency(
              Info.From->getInstr(), Info.OperIdx, TerminatorMI, I));
          ST.adjustSchedDependency(Info.From, Info.OperIdx, &DAG->ExitSU, I,
                                   Dep);
          DAG->addEdge(&DAG->ExitSU, Dep);
        }
      }
    }
  }
};

std::unique_ptr<ScheduleDAGMutation> createKVXExitMIDataDepsMutation() {
  return std::make_unique<ExitMIDataDeps>();
}

} // namespace llvm
