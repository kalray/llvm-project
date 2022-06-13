//===- KVXVLIWPacketizer.cpp - KVX Packetizer Class -----------------------===//
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

#include "KVXVLIWPacketizer.h"
#include "KVX.h"
#include "KVXInstrInfo.h"
#include "KVXTargetMachine.h"

#include "llvm/InitializePasses.h"
#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/CodeGen/MachineDominators.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineLoopInfo.h"
#include "llvm/CodeGen/ScheduleDAG.h"
#include "llvm/CodeGen/TargetSchedule.h"

using namespace llvm;

#define PASS_NAME "KVX Packetizer"
#define DEBUG_TYPE "kvx-packetizer"

static cl::opt<bool> KVXKeepKILL("kvx-keep-kill-debug",
                                 cl::desc("Keep KILL debug instructions."),
                                 cl::init(false), cl::Hidden);

namespace {

class KVXPacketizer : public MachineFunctionPass {
public:
  static char ID;

  KVXPacketizer() : MachineFunctionPass(ID) {}

  StringRef getPassName() const override { return PASS_NAME; }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesCFG();
    AU.addRequired<AAResultsWrapperPass>();
    AU.addRequired<MachineDominatorTree>();
    AU.addRequired<MachineLoopInfo>();
    AU.addPreserved<MachineDominatorTree>();
    AU.addPreserved<MachineLoopInfo>();
    MachineFunctionPass::getAnalysisUsage(AU);
  }

  bool runOnMachineFunction(MachineFunction &Fn) override;

};

} // namespace

char KVXPacketizer::ID = 0;

INITIALIZE_PASS_BEGIN(KVXPacketizer, DEBUG_TYPE, PASS_NAME, false, false)
INITIALIZE_PASS_DEPENDENCY(MachineDominatorTree)
INITIALIZE_PASS_DEPENDENCY(MachineLoopInfo)
INITIALIZE_PASS_DEPENDENCY(AAResultsWrapperPass)
INITIALIZE_PASS_END(KVXPacketizer, DEBUG_TYPE, PASS_NAME, false, false)

bool KVXPacketizer::runOnMachineFunction(MachineFunction &MF) {

  LLVM_DEBUG(dbgs() << PASS_NAME << ": runOnMachineFunction -> " << MF.getName()
                    << '\n';);

  auto &MLI = getAnalysis<MachineLoopInfo>();
  auto *AA = &getAnalysis<AAResultsWrapperPass>().getAAResults();

  MF.getProperties().set(MachineFunctionProperties::Property::TracksLiveness);
  KVXPacketizerList Packetizer(MF, MLI, AA);

  // DFA state table should not be empty.
  assert(Packetizer.getResourceTracker() && "Empty DFA table!");

  // TODO: Implement VLIWResourceModel::isResourceAvailable in order to
  // packetize IMPLICIT_DEF instructions. Delete them for now.
  for (auto &MB : MF) {
    auto End = MB.end();
    auto MI = MB.begin();
    while (MI != End) {
      auto NextI = std::next(MI);
      if (MI->isImplicitDef()) {
        MB.erase(MI);
        End = MB.end();
      }
      MI = NextI;
    }
  }
  // End of TODO.

  // Loop over all of the basic blocks.
  // NOTE: What about the boundaries passed to PacketizeMIs (see Hexagon BE)?
  for (auto &MB : MF) {
    LLVM_DEBUG(dbgs() << PASS_NAME << ": MB -> " << MB.getName() << '\n';);
    Packetizer.PacketizeMIs(&MB, MB.begin(), MB.end());
  }

  Packetizer.moveDebugInstructionsOut(MF);
  return true;
}

FunctionPass *llvm::createKVXPacketizerPass() { return new KVXPacketizer(); }

KVXPacketizerList::KVXPacketizerList(MachineFunction &MF, MachineLoopInfo &MLI,
                                     AAResults *AA)
    : VLIWPacketizerList(MF, MLI, AA), PacketSize(0) {
  PacketSize = 0 /* in byte */;
  MaxPacketSize = 8 /* words (syllables) of */ * 4 /* bytes */;
}

bool KVXPacketizerList::shouldAddToPacket(const MachineInstr &MI) {
  return MI.getDesc().getSize() + PacketSize <= MaxPacketSize;
}

MachineBasicBlock::iterator KVXPacketizerList::addToPacket(MachineInstr &MI) {
  LLVM_DEBUG(dbgs() << PASS_NAME << ": + MI " << MI;);

  // PacketSize count the number of issue (syllables) added in a Packet.
  PacketSize += MI.getDesc().getSize();
  return VLIWPacketizerList::addToPacket(MI);
}

void KVXPacketizerList::endPacket(MachineBasicBlock *MBB,
                                  MachineBasicBlock::iterator MBBI) {
  if (!MBB->empty() && MBBI == MBB->end())
    PacketSize = MBB->back().getDesc().getSize();

  LLVM_DEBUG(dbgs() << PASS_NAME << ": ending packet (size: " << PacketSize / 4
                    << ", %: " << (float)PacketSize / MaxPacketSize * 100 << ")"
                    << '\n';);

  PacketSize = 0;
  VLIWPacketizerList::endPacket(MBB, MBBI);
}

bool KVXPacketizerList::isSoloInstruction(const MachineInstr &MI) {
  bool Solo = false;

  if (MI.isInlineAsm() || MI.isBundle() || MI.isEHLabel()) {
    Solo = true;
  } else {
    switch (MI.getOpcode()) {
    default:
      break;
    case KVX::SETrst3:
    case KVX::SETrsa:
    case KVX::SETrsra:
    case KVX::SETrst4:
    case KVX::WFXLrst2:
    case KVX::WFXLrsa:
    case KVX::WFXLrst4:
    case KVX::WFXMrst2:
    case KVX::WFXMrsa:
    case KVX::WFXMrst4:
      // SET, WFXL, and WFXM instructions have to be alone in a
      // bundle if they write an AloneReg register.
      Solo = KVX::AloneRegRegClass.contains(MI.getOperand(0).getReg());
      break;
    }
  }

  if (Solo)
    PacketSize = MI.getDesc().getSize();

  return Solo;
}

bool KVXPacketizerList::ignorePseudoInstruction(const MachineInstr &MI,
                                                const MachineBasicBlock *) {
  if (MI.isDebugInstr() || MI.isPosition()) {
    LLVM_DEBUG(dbgs() << PASS_NAME << ": ignoring " << MI;);
    return true;
  }

  return false;
}

bool KVXPacketizerList::isLegalToPacketizeTogether(SUnit *SUI, SUnit *SUJ) {
  // For each SUnits in the current packet, determine if it's legal to add SUI.
  assert(SUI->getInstr() && SUJ->getInstr());

  MachineInstr &MI = *SUI->getInstr();
  MachineInstr &MJ = *SUJ->getInstr();

  LLVM_DEBUG(dbgs() << PASS_NAME << ": try to add " << MI;);
  LLVM_DEBUG(dbgs() << PASS_NAME << ": in packet with " << MJ;);
  LLVM_DEBUG(dbgs() << PASS_NAME << " Depths: " << SUI->getDepth() << " vs. "
                    << SUJ->getDepth() << '\n';);

  // Always add RET to packet if resources allow it.
  if (MI.getOpcode() == KVX::RET)
    return true;

  // Calls and branches are packet barriers.
  if (MJ.isCall() || MJ.isBranch()) {
    LLVM_DEBUG(dbgs() << PASS_NAME
                      << ": not legal because prior MI is a bunble barrier"
                      << '\n';);
    return false;
  }

  bool Legal = false;

  // Not legal if MI is a successor of MJ.
  if (SUJ->isSucc(SUI)) {
    // Except if the dependency latency is 0.
    unsigned CumulatedLatency = 0;

    for (const SDep &Succ : SUJ->Succs)
      // Ignore WAW dependencies.
      if (Succ.getSUnit() == SUI &&
          (!MI.isCall() || Succ.getKind() == SDep::Data))
        CumulatedLatency += Succ.getLatency();

    if (!CumulatedLatency)
      Legal = true;
    else
      LLVM_DEBUG(dbgs() << PASS_NAME
                        << ": not legal because MI is a successor of MJ"
                        << '\n';);

  } else {
    Legal = true;
  }

  return Legal;
}

// CFIInstruction and debug related instructions must be moved out the bundle
// they belong to.
void KVXPacketizerList::moveDebugInstructionsOut(MachineFunction &MF) {
  for (auto &MBB : MF) {
    LLVM_DEBUG(dbgs() << MBB;);

    // Iterators for instructions (bundles included).
    MachineBasicBlock::iterator BundleCurr, Where;

    for (MachineBasicBlock::instr_iterator II = MBB.instr_begin(), NextII;
         II != MBB.instr_end(); II = NextII) {

      NextII = std::next(II);

      // Remove KILL pseudo instructions.
      if (II->isKill() && !KVXKeepKILL) {
        MBB.erase(II);
        continue;
      }

      if (II->isBundle()) {
        BundleCurr = II;
        Where = std::next(BundleCurr);
      }

      if (II->isInsideBundle()) {
        if (II->isCFIInstruction() || II->isDebugInstr() ||
            II->isImplicitDef() || II->isLabel() || II->isKill()) {

          assert(II->isBundledWithPred());
          if (II->isBundledWithSucc()) {
            II->clearFlag(MachineInstr::BundledSucc);
            II->clearFlag(MachineInstr::BundledPred);
          } else {
            II->unbundleFromPred();
          }

          LLVM_DEBUG(dbgs() << "move " << *II;);
          if (Where != MBB.instr_end())
            LLVM_DEBUG(dbgs() << "before " << *Where;);
          else
            LLVM_DEBUG(dbgs() << "at the end of the MBB" << '\n';);

          // Move labels and debug instrs before bundle.
          if (II->isLabel() || II->isDebugInstr())
            MBB.splice(BundleCurr, &MBB, II);
          else
            MBB.splice(Where, &MBB, II);
        }
      }
    }

    LLVM_DEBUG(dbgs() << MBB;);
  }
}
