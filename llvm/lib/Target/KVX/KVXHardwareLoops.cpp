//===-- KVXHardwareLoops.cpp - Hardware loops optimization step -*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains a pass that attempts to optimize a loop using the
// LOOPDO Kalray instruction
//
// This pass converts LOOPDOp pseudo instructions to the actual LOOPDO hardware
// loop instruction. It's syntax is:
// LOOPDO #iterations  LoopExitSymbol
// ;;
// LOOP_START
//
// The activation of the automatic back-branch only happens when the pc is
// incremented to the value of LoopExitSymbol. If we branch to it, it
// won't triggers the automatic pc replacement to the header allowing cases
// with early loop exits, such as, in C/C++ break instructions.
//
// The ENDLOOP pseudo instruction is placed in the postion where the
// latch branch is taken, replacing the pseudo-instruction LOOPDO_ENDp.
// It is used to preserve the loop structure, and avoid the compiler to
// do dead code elimination or branch fusion.
// The ENDLOOP is converted to the LoopExitSymbol when lowering to MC.
//===----------------------------------------------------------------------===//

#include "KVXHardwareLoops.h"
#include "KVXSubtarget.h"
#include "llvm/CodeGen/MachineDominators.h"
#include "llvm/MC/MCContext.h"
#include <sstream>

using namespace llvm;
using MBB = MachineBasicBlock;

#define DEBUG_TYPE "hardware-loops"

#define KVXHARDWARELOOPS_NAME "kvx-hardware-loops"
#define KVXHARDWARELOOPS_DESC "KVX Hardware loops"

char KVXHardwareLoops::ID = 0;
static unsigned LoopC = 0;
INITIALIZE_PASS_BEGIN(KVXHardwareLoops, KVXHARDWARELOOPS_NAME,
                      KVXHARDWARELOOPS_DESC, false, false)
INITIALIZE_PASS_DEPENDENCY(MachineDominatorTree)
INITIALIZE_PASS_DEPENDENCY(MachineLoopInfo)
INITIALIZE_PASS_END(KVXHardwareLoops, KVXHARDWARELOOPS_NAME,
                    KVXHARDWARELOOPS_DESC, false, false)

/// Transformation required by MachinePipeliner (else it will not pipeline the
/// loop).
///
/// Extracts the ENDLOOP from Exiting and changes the successors of Header and
/// Exiting blocks so that the loop has only one MBB by removing the
/// Exiting->Header edge and adding Header->Header edge.
void KVXHardwareLoops::turnIntoOneMBBLoop(MachineLoop *Loop) const {
  LLVM_DEBUG(dbgs() << "Transform it into a one-MBB loop..\n");

  if (Loop->getNumBlocks() != 2) {
    LLVM_DEBUG(dbgs() << "\tThe loop has not exactly 2 MBBs: bailing out\n");
    return;
  }

  MachineBasicBlock *Header = Loop->getHeader();

  /** Find the Exiting, Exit blocks and the edge probabilities */

  MachineBasicBlock *Exiting = Loop->getExitingBlock();
  if (!Exiting) {
    LLVM_DEBUG(
        dbgs() << "\tNo exiting block found in hardware loop, bailing out\n");
    return;
  }

  if (Exiting->size() != 1) {
    LLVM_DEBUG(dbgs() << "\tExiting block does not have exactly 1 instruction, "
                         "bailing out\n");
    return;
  }

  bool ExitingHasTwoSuccessors = Exiting->succ_size() == 2;
  if (!ExitingHasTwoSuccessors) {
    LLVM_DEBUG(dbgs() << "\tExiting block does not have exactly two "
                         "successors, bainling out\n");
    return;
  }

  auto FindExit = Exiting->succ_begin();
  if (*FindExit == Header)
    FindExit++;
  assert(*FindExit != Header && "Two successor edges to the same header?");

  MachineBasicBlock *Exit = *FindExit;

  auto LoopProbability = MBPI->getEdgeProbability(Exiting, Header);
  auto ExitProbability = MBPI->getEdgeProbability(Exiting, Exit);

  /**
   * Extract ENDLOOP from Exiting, insert it at the end of Header
   * Replace it with a GOTO to Exit
   */

  MachineInstr *EndloopMI = Exiting->remove(&*Exiting->begin());
  Header->push_back(EndloopMI);
  MachineBasicBlock *FBB = EndloopMI->getOperand(1).getMBB();
  EndloopMI->getOperand(1).setMBB(Exiting);

  BuildMI(Exiting, EndloopMI->getDebugLoc(), TII->get(KVX::GOTO)).addMBB(FBB);

  /**
   * Remove Exiting->Header edge, then create new Header->Header edge with
   * the right probability and assign the exit probability to Header->Exiting
   */

  Exiting->removeSuccessor(Header);
  Exiting->normalizeSuccProbs();

  Header->setSuccProbability(Header->succ_begin(), ExitProbability);
  Header->addSuccessor(Header, LoopProbability);
  Header->validateSuccProbs();

  /** Update Header PHI instructions */
  for (auto &Phi : Header->phis())
    for (auto &Op : Phi.operands())
      if (Op.isMBB() && Op.getMBB() == Exiting)
        Op.setMBB(Header);
}

bool KVXHardwareLoops::runOnLoop(MachineLoop *Loop) {
  bool Changed = false;
  for (auto *SubLoop : *Loop)
    Changed |= runOnLoop(SubLoop);

  MBB *Header = Loop->getHeader();
  if (!Header)
    return Changed;

  LLVM_DEBUG(dbgs() << "At loop with header:" << Header->getName() << ".\n");

  auto LoopdoPseudo = Header->begin();
  for (auto E = Header->end(); LoopdoPseudo != E; LoopdoPseudo++)
    if (LoopdoPseudo->getOpcode() == KVX::LOOPDOp)
      break;
  // 1st step, check if we have the loopdo pseudo
  if (LoopdoPseudo == Header->end()) {
    LLVM_DEBUG(
        dbgs()
        << "\tDoes not hold a LOOPDO pseudo instruction, bailing out.\n");
    return Changed;
  }
  LLVM_DEBUG(dbgs() << "\tFound LOOPDO-pseudo: " << *LoopdoPseudo << "\n");

  if (Changed)
    report_fatal_error("Nested LOOPDO pseudo-instructions found.\n");

  // 2nd step, find the loopdo_end pseudo
  MBB *Latch = Loop->findLoopControlBlock();
  MBB::iterator LoopEndPseudo;
  if (!Latch) {
    SmallVector<MBB *, 4> Latches;
    Loop->getLoopLatches(Latches);
    for (auto *BB : Latches)
      for (MBB::iterator I : *BB)
        if (I->getOpcode() == KVX::LOOPDO_ENDp) {
          if (!Latch) {
            Latch = BB;
            LoopEndPseudo = I;
            continue;
          }
          report_fatal_error(
              "A malformed hwloop with multiple LOOPDO_ENDp operands.\n");
        }
    if (!Latch)
      report_fatal_error("A malformed hwloop without a LOOPDO_ENDp.\n");
  } else {
    for (MBB::iterator I : *Latch)
      if (I->getOpcode() == KVX::LOOPDO_ENDp) {
        LoopEndPseudo = I;
        break;
      }
  }

  LLVM_DEBUG(dbgs() << "\tThe latch BB is: " << Latch->getName() << ".\n");
  // The correct place to set the symbol should be at the position of the
  // conditional branch that uses the value of the pseudo-instruction.
  auto CBranch = std::next(LoopEndPseudo);
  for (auto E = Latch->end(); CBranch != E; CBranch++) {
    if (CBranch->isBranch()) {
      if (!CBranch->isConditionalBranch())
        report_fatal_error(
            "Expected conditional branch using loopend condition.");
      if (CBranch->getOperand(0).getReg() ==
          LoopEndPseudo->getOperand(0).getReg())
        break;
    }
  }
  LLVM_DEBUG(dbgs() << "\tConditional branch in the latch: " << *CBranch);

  if (CBranch == Latch->end())
    report_fatal_error("Expected conditional branch using loopend condition.");

  // Found the conditional branch. Now must find the unconditional branch (or
  // fallthrough). When merging both conditional and unconditional branches in
  // a single pseudo-instruction pseudo ENDLOOP $LpHead $LpExit, any
  // instructions between them must be moved into a new basic block. If the
  // unconditional branch goes to the loop exit the block must be placed between
  // the exit edge. If the last branch goes to the loop header,
  // these instructions should not run on the last iteration nor during
  // the loop entry. So the new bb is placed in the latch edge.
  bool MustMoveInstrs = false;
  auto Branch = std::next(CBranch);
  if (Branch != Latch->end() && !Branch->isUnconditionalBranch()) {
    MustMoveInstrs = true;
    while (++Branch != Latch->end() && !Branch->isUnconditionalBranch())
      ;
  }
  LLVM_DEBUG(dbgs() << "\tMust move instructions out? " << MustMoveInstrs
                    << ".\n");

  MBB *BranchMBB = (Branch == Latch->end()) ? Latch->getFallThrough()
                                            : Branch->getOperand(0).getMBB();

  MBB *CondBMBB = CBranch->getOperand(1).getMBB();
  if (BranchMBB != Header && CondBMBB != Header)
    report_fatal_error("Did not find loop latch edge.");

  MBB *ExitMBB = (BranchMBB == Header) ? CondBMBB : BranchMBB;
  MachineFunction *MF = Latch->getParent();

  if (MustMoveInstrs) {
    MBB *Edge = MF->CreateMachineBasicBlock();
    Edge->splice(Edge->end(), Latch, std::next(CBranch), Latch->end());
    // We don't care where we insert it, cfg optimizations will take care of it.
    MF->insert(MF->end(), Edge);
    Latch->replaceSuccessor(BranchMBB, Edge);
    Edge->addSuccessor(BranchMBB, BranchProbability::getOne());
    LLVM_DEBUG(dbgs() << "loopdo latch after moving instructions:";
               Latch->dump());
    LLVM_DEBUG(dbgs() << "New basic block with the moved instructions:";
               Edge->dump());
  }

  std::stringstream EndLoopLabel;
  EndLoopLabel << ".__LOOPDO_" << LoopC++ << "_END_";
  MCSymbol *ENDS =
      Header->getParent()->getContext().getOrCreateSymbol(EndLoopLabel.str());

  LLVM_DEBUG(dbgs() << "\tLoop symbol: " << *ENDS << ".\n");

  BuildMI(*Latch, CBranch, LoopdoPseudo->getDebugLoc(), TII->get(KVX::ENDLOOP))
      .addMBB(Header)
      .addMBB(ExitMBB)
      .addSym(ENDS);

  CBranch->eraseFromParent();
  if (Branch != Latch->end())
    Branch->eraseFromParent();

  LoopEndPseudo->eraseFromParent();
  LLVM_DEBUG(dbgs() << "\tloopdo latch MBB after replacements:\n";
             Latch->dump());

  // Must find the correct place to insert the loopdo instruction
  // so that phi-nodes at the loop header will correctly be dominated
  // by it.
  MBB *Prehead = Loop->getLoopPreheader();
  auto &DT = getAnalysis<MachineDominatorTree>();
  auto *NumIt = MRI->getVRegDef(LoopdoPseudo->getOperand(0).getReg());
  MBB *NumItBB = NumIt->getParent();
  if (!Prehead) {
    LLVM_DEBUG(dbgs() << "Inserting loopdo at the beginning of loop header: "
                      << Header->getName() << '\n');
    BuildMI(*Header, LoopdoPseudo, Loop->getStartLoc(), TII->get(KVX::LOOPDO))
        .addReg(LoopdoPseudo->getOperand(0).getReg())
        .addSym(ENDS);
    LLVM_DEBUG(dbgs() << "Erasing the loopdo pseudo.\n");
    LoopdoPseudo->eraseFromParent();

    turnIntoOneMBBLoop(Loop);
    return true;
  }
  auto InsertPos = Prehead->getLastNonDebugInstr();
  if (InsertPos == Prehead->end()) {
    LLVM_DEBUG(dbgs() << "\tPlacing loopdo at the end of preheader.\n");
  } else if (!InsertPos->isBranch()) {
    LLVM_DEBUG(dbgs() << "\tPlacing loopdo in preheader after: " << *InsertPos);
    ++InsertPos;
  } else if (TII->getBranchDestBlock(*InsertPos) != Header) {
    // Be safe and place in the header it self.
    LLVM_DEBUG(dbgs() << "\tInserting loopdo at the beginning of loop header: "
                      << Header->getName() << '\n');
    BuildMI(*Header, LoopdoPseudo, Loop->getStartLoc(), TII->get(KVX::LOOPDO))
        .addReg(LoopdoPseudo->getOperand(0).getReg())
        .addSym(ENDS);
    LLVM_DEBUG(dbgs() << "\tErasing the loopdo pseudo.\n");
    LoopdoPseudo->eraseFromParent();

    turnIntoOneMBBLoop(Loop);
    return true;
  }

  if (!DT.dominates(NumItBB, Prehead)) {
    LLVM_DEBUG(dbgs() << "\tMoving loop counter definition to the"
                         " preheader bb.\n");
    Prehead->splice(InsertPos, NumItBB, NumIt);
  }
  BuildMI(*Prehead, InsertPos, Loop->getStartLoc(), TII->get(KVX::LOOPDO))
      .addReg(LoopdoPseudo->getOperand(0).getReg())
      .addSym(ENDS);

  LLVM_DEBUG(dbgs() << "\tErasing the loopdo pseudo. Preheader now:\n";
             Prehead->dump());
  LoopdoPseudo->eraseFromParent();

  turnIntoOneMBBLoop(Loop);
  return true;
}

bool KVXHardwareLoops::runOnMachineFunction(MachineFunction &MF) {
  bool Changed = false;

  MachineLoopInfo &MLI = getAnalysis<MachineLoopInfo>();
  TII = MF.getSubtarget<KVXSubtarget>().getInstrInfo();
  MRI = std::addressof(MF.getRegInfo());
  MBPI = &getAnalysis<MachineBranchProbabilityInfo>();

  for (auto &Loop : MLI)
    Changed |= runOnLoop(Loop);

  return Changed;
}

FunctionPass *llvm::createKVXHardwareLoopsPass() {
  return new KVXHardwareLoops();
}

StringRef KVXHardwareLoops::getPassName() const {
  return KVXHARDWARELOOPS_DESC;
}
