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
//===----------------------------------------------------------------------===//

#include "llvm/ADT/StringRef.h"
#include "llvm/CodeGen/MachineDominators.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineLoopInfo.h"
#include "llvm/InitializePasses.h"

#include "KVX.h"
#include "KVXHardwareLoops.h"
#include "KVXInstrInfo.h"
#include "KVXSubtarget.h"
using namespace llvm;

#define DEBUG_TYPE "hwloops"

#define KVXHARDWARELOOPS_NAME "kvx-hardware-loops"
#define KVXHARDWARELOOPS_DESC "Hardware loops"

using instr_iterator = MachineBasicBlock::instr_iterator;

char KVXHardwareLoops::ID = 0;

INITIALIZE_PASS_BEGIN(KVXHardwareLoops, KVXHARDWARELOOPS_NAME,
                      KVXHARDWARELOOPS_DESC, false, false)
INITIALIZE_PASS_DEPENDENCY(MachineDominatorTree)
INITIALIZE_PASS_DEPENDENCY(MachineLoopInfo)
INITIALIZE_PASS_END(KVXHardwareLoops, KVXHARDWARELOOPS_NAME,
                    KVXHARDWARELOOPS_DESC, false, false)

static bool isAddOperator(unsigned opcode) {
  switch (opcode) {
  case KVX::ADDWri10:
  case KVX::ADDWri37:
  case KVX::ADDWrr:
  case KVX::ADDDri10:
  case KVX::ADDDri37:
  case KVX::ADDDri64:
  case KVX::ADDDrr:
    return true;
  default:
    return false;
  }

  return false;
}

static bool isSubOperator(unsigned opcode) {
  switch (opcode) {
  case KVX::SBFDri10:
  case KVX::SBFDri37:
  case KVX::SBFDri64:
  case KVX::SBFDrr:
  case KVX::SBFWri10:
  case KVX::SBFWri37:
  case KVX::SBFWrr:
    return true;
  default:
    return false;
  }

  return false;
}

static bool isMakeOperator(unsigned opcode) {
  switch (opcode) {
  case KVX::MAKEi16:
  case KVX::MAKEi43:
  case KVX::MAKEi64:
    return true;
  default:
    return false;
  }
  return false;
}

static bool isExtensionOperator(unsigned opcode) {
  switch (opcode) {
  case KVX::ZXWD:
  case KVX::ZXBD:
  case KVX::ZXHD:
  case KVX::SXBD:
  case KVX::SXHD:
  case KVX::SXWD:
    return true;
  default:
    return false;
  }
  return false;
}

static bool isCompOperator(unsigned opcode) {
  switch (opcode) {
  case KVX::COMPWri:
  case KVX::COMPWrr:
  case KVX::COMPDri10:
  case KVX::COMPDri37:
  case KVX::COMPDri64:
  case KVX::COMPDrr:
    return true;
  default:
    return false;
  }

  return false;
}

bool KVXHardwareLoops::IsEligibleForHardwareLoop(MachineLoop *L) {

  // Eligibility check: A loop can be optimized if:
  // - The preheader and the header are not empty
  // - There is no function call under the loop
  // - There is no indirect branching (multiple exit points loop) in the loop

  if (!HeaderMBB || !PreheaderMBB || !ExitMBB) {
    LLVM_DEBUG(llvm::dbgs() << "HW Loop - The loop does not have a "
                               "header/preheader/exit basic block.\n");
    return false;
  }

  if (PreheaderMBB->instr_begin() == PreheaderMBB->instr_end()) {
    LLVM_DEBUG(llvm::dbgs() << "HW Loop - The loop preheader is empty.\n");
    return false;
  }

  if (HeaderMBB->instr_begin() == HeaderMBB->instr_end()) {
    LLVM_DEBUG(llvm::dbgs() << "HW Loop - The loop header is empty.\n");
    return false;
  }

  for (instr_iterator I = HeaderMBB->instr_begin(), E = HeaderMBB->instr_end();
       I != E; ++I) {

    // Hardware loops should not contain internal calls
    if (I->getOpcode() == KVX::CALL) {
      LLVM_DEBUG(
          llvm::dbgs() << "HW Loop - The loop contains internal calls.\n");
      return false;
    }

    // The HW loop should not contain branches (other than the single loop
    // stopping condition)
    if (I->isIndirectBranch()) {
      LLVM_DEBUG(
          llvm::dbgs() << "HW Loop - The loop contains an indirect branch.\n");
      return false;
    }
  }

  return true;
}

/**
 * The BackTraceRegValue traces the register @regToSearchFor starting from the
 * @headerIt machine instruction. If the register is found to be initialized
 * (using MAKE), the value is assigned to CmpVal. During this search, also the
 * @Bump value is searched for by checking what operations are applied on the
 * traced register.
 * @return Returns true if the value was traced, false otherwise.
 */
bool KVXHardwareLoops::BackTraceRegValue(MachineLoop *L,
                                         instr_iterator headerIt,
                                         unsigned regToSearchFor,
                                         MachineOperand &CmpVal, int64_t &Bump,
                                         bool &IsDefinedInBody) {

  unsigned regNr = regToSearchFor;
  bool Done = false;
  IsDefinedInBody = false;

  headerIt = std::prev(headerIt);
  // Condition basick block register backtrace
  do {
    if (headerIt->getOpcode() == KVX::PHI &&
        headerIt->getOperand(0).getReg() == regNr) {
      regNr = headerIt->getOperand(1).getReg();
      CmpVal = headerIt->getOperand(1);
    }

    if (isAddOperator(headerIt->getOpcode()) &&
        headerIt->getOperand(0).getReg() == regNr &&
        headerIt->getOperand(2).isImm()) {
      regNr = headerIt->getOperand(1).getReg();
      Bump = headerIt->getOperand(2).getImm();
      CmpVal = headerIt->getOperand(1);
    }

    if (isSubOperator(headerIt->getOpcode()) &&
        headerIt->getOperand(0).getReg() == regNr &&
        headerIt->getOperand(2).isImm()) {
      regNr = headerIt->getOperand(1).getReg();
      Bump = headerIt->getOperand(2).getImm();
      CmpVal = headerIt->getOperand(1);
    }

    for (auto OutputOp = headerIt->defs().begin();
         OutputOp != headerIt->defs().end(); ++OutputOp) {
      if (OutputOp->getReg() == regNr) {
        IsDefinedInBody = true;
        break;
      }
    }

    if (headerIt == HeaderMBB->begin())
      Done = true;
    else
      headerIt = std::prev(headerIt);
  } while (!Done);

  Done = false;
  // Iterate through the preheader
  instr_iterator I = PreheaderMBB->instr_end();
  I = std::prev(I);
  do {
    if (isMakeOperator(I->getOpcode()) &&
        (I->getOperand(0).getReg() == regNr)) {
      CmpVal = I->getOperand(1);
      return true;
    }

    if (isExtensionOperator(I->getOpcode()) &&
        (I->getOperand(0).getReg() == regNr)) {
      CmpVal = I->getOperand(1);
      return true;
    }

    if (I == PreheaderMBB->instr_begin()) {
      Done = true;
    } else {
      I = std::prev(I);
    }
  } while (!Done);

  return false;
}

bool KVXHardwareLoops::ParseLoop(MachineLoop *L, MachineOperand &EndVal,
                                 int &Cond, MachineOperand &StartVal,
                                 int64_t &Bump) {
  for (instr_iterator I = HeaderMBB->instr_begin(), E = HeaderMBB->instr_end();
       I != E; ++I) {
    // The parsing starts when a COMPD instruction is found
    if (isCompOperator(I->getOpcode())) {

      // Sanity check for the comparison type (LT, GT etc)/
      if (I->getOperand(3).isImm()) {
        Cond = I->getOperand(3).getImm();
      } else {
        LLVM_DEBUG(llvm::dbgs() << "HW Loop - The loop comparison type(LT, GT "
                                   "etc) is not an immediate.\n");
        return false;
      }
      // REG-IMM case
      if (I->getOperand(1).isReg() && I->getOperand(2).isImm()) {
        bool IsDefinedInBody;
        // If the register's value could not be traced, then the loop can not
        // be parsed
        if (BackTraceRegValue(L, I, I->getOperand(1).getReg(), StartVal, Bump,
                              IsDefinedInBody)) {
          if (StartVal.isReg() && Bump == -1)
            EndVal = StartVal;
          else
            EndVal = I->getOperand(2);
        } else {
          LLVM_DEBUG(
              llvm::dbgs()
              << "HW Loop - [REG-IMM] The register could not be traced.\n");
          return false;
        }
      } // REG-IMM case
      // REG-REG case
      else if (I->getOperand(1).isReg() && I->getOperand(2).isReg()) {

        int64_t BumpOp1 = 0;
        int64_t BumpOp2 = 0;
        MachineOperand StartValOp1 = MachineOperand::CreateImm(0);
        MachineOperand StartValOp2 = MachineOperand::CreateImm(0);
        bool IsDefinedInBody1;
        bool IsDefinedInBody2;
        bool BacktraceOp1 =
            BackTraceRegValue(L, I, I->getOperand(1).getReg(), StartValOp1,
                              BumpOp1, IsDefinedInBody1);
        bool BacktraceOp2 =
            BackTraceRegValue(L, I, I->getOperand(2).getReg(), StartValOp2,
                              BumpOp2, IsDefinedInBody2);

        // If the register's value could not be traced, then the loop can not
        // be parsed
        if (BacktraceOp1 && StartValOp1.isImm() && BumpOp2 == 0) {
          if (IsDefinedInBody2)
            return false;
          Bump = BumpOp1;
          StartVal = StartValOp1;

          // This line should be removed when cases for Bump != 1 and StartVal
          // != 1 are implemented
          if (Bump != 1 || StartVal.getImm() != 0) {
            LLVM_DEBUG(llvm::dbgs() << "HW Loop - [REG-REG] The bump value is "
                                       "not 1 or the start value is not 0.\n");
            return false;
          }
          EndVal = I->getOperand(2);
        } else {
          // If the register's value could not be traced, then the loop can not
          // be parsed
          if (BacktraceOp2 && StartValOp2.isImm() && BumpOp1 == 0) {
            if (IsDefinedInBody1)
              return false;

            Bump = BumpOp2;
            StartVal = StartValOp2;

            // This line should be removed when cases for Bump != 1 and StartVal
            // != 1 are implemented
            if (Bump != 1 || StartVal.getImm() != 0) {
              LLVM_DEBUG(llvm::dbgs()
                         << "HW Loop - [REG-REG] The bump value is not 1 or "
                            "the start value is not 0.\n");
              return false;
            }

            EndVal = I->getOperand(1);
          } else {
            LLVM_DEBUG(llvm::dbgs() << "HW Loop - [REG-REG] Neither of the "
                                       "registers coud be traced.\n");
            return false;
          }
        }
      } // REG-REG case
    }   // isCompOperator check
  }

  return true;
}

bool KVXHardwareLoops::GetLOOPDOArgs(MachineLoop *L,
                                     MachineOperand &StepsCount) {

  MachineOperand StartVal = MachineOperand::CreateImm(0);
  int64_t Bump = 0;

  int Cond = -1;

  MachineOperand EndVal = MachineOperand::CreateImm(0);

  bool CanRetrieveEndingCond = ParseLoop(L, EndVal, Cond, StartVal, Bump);

  if (!CanRetrieveEndingCond) {
    LLVM_DEBUG(llvm::dbgs() << "HW Loop - Could not retrieve the end "
                               "value/start value/bump/condition type.\n");
    return false;
  }
  int64_t steps = 0;
  if (EndVal.isReg()) {
    StepsCount = EndVal;
    return true;
  }

  if (Bump == 0) {
    LLVM_DEBUG(llvm::dbgs() << "HW Loop - The found bump value is 0.\n");
    return false;
  }

  switch (Cond) {
  case KVXMOD::COMPARISON_NE:
  case KVXMOD::COMPARISON_GE:
  case KVXMOD::COMPARISON_LE:
  case KVXMOD::COMPARISON_GEU:
  case KVXMOD::COMPARISON_LEU: {
    if (StartVal.getImm() == EndVal.getImm())
      return false;
    steps = ((EndVal.getImm() - StartVal.getImm()) / Bump);
    break;
  }
  case KVXMOD::COMPARISON_LT:
  case KVXMOD::COMPARISON_GT:
  case KVXMOD::COMPARISON_LTU:
  case KVXMOD::COMPARISON_GTU: {
    steps = ((EndVal.getImm() - StartVal.getImm() + Bump + (Bump < 0) -
              (Bump > 0)) /
             Bump);
    break;
  }
  default:
    return false;
  }
  StepsCount = MachineOperand::CreateImm(steps);
  return true;
}

bool KVXHardwareLoops::RemoveBranchingInstr(MachineLoop *L) {

  instr_iterator PreheaderGoto = PreheaderMBB->instr_end();

  for (instr_iterator I = PreheaderMBB->instr_begin(),
                      E = PreheaderMBB->instr_end();
       I != E; ++I) {
    if (I->getOpcode() == KVX::GOTO) {
      PreheaderGoto = I;
      break;
    }
  }

  instr_iterator HeaderGoto = HeaderMBB->instr_end();
  instr_iterator HeaderComp = HeaderMBB->instr_end();
  instr_iterator HeaderCB = HeaderMBB->instr_end();

  for (instr_iterator I = HeaderMBB->instr_begin(); I != HeaderMBB->instr_end();
       ++I) {
    if (isCompOperator(I->getOpcode())) {
      HeaderComp = I;
      I++;
      // There are cases (in the Hexagon CodeGen tests) where add instructions
      // are between the COMPD and CB, this case is not supported now.
      if (I == HeaderMBB->instr_end() || I->getOpcode() != KVX::CB) {
        LLVM_DEBUG(llvm::dbgs() << "HW Loop - The comparison instruction is "
                                   "not followed by a CB instruction.\n");
        return false;
      } else {
        HeaderCB = I;
        I++;
        if (I == HeaderMBB->instr_end() || I->getOpcode() != KVX::GOTO) {
          LLVM_DEBUG(llvm::dbgs() << "HW Loop - The comparison instruction is "
                                     "not followed by a GOTO instruction.\n");
          return false;
        } else {
          HeaderGoto = I;
        }
      }
    }
  }

  // The goto instruction in the preheader will be replaced with loopdo
  if (PreheaderGoto != PreheaderMBB->instr_end())
    PreheaderGoto->eraseFromParent();

  // The comparison is removed as is not necessary anymore
  if (HeaderComp != HeaderMBB->instr_end())
    HeaderComp->eraseFromParent();
  if (HeaderCB != HeaderMBB->instr_end())
    HeaderCB->eraseFromParent();
  if (HeaderGoto != HeaderMBB->instr_end())
    HeaderGoto->eraseFromParent();

  return true;
}

bool KVXHardwareLoops::ConvertToHardwareLoop(MachineFunction &MF,
                                             MachineLoop *L) {
  // This is just for sanity.
  assert(L->getHeader() && "Loop without a header?");
  bool Changed = false;

  PreheaderMBB = L->getLoopPreheader();
  HeaderMBB = L->getHeader();
  ExitMBB = L->getExitBlock();

  // Process nested loops first.
  for (MachineLoop::iterator I = L->begin(), E = L->end(); I != E; ++I) {
    Changed |= ConvertToHardwareLoop(MF, *I);
  }

  // If a nested loop has been converted, then we can't convert this loop.
  if (Changed)
    return Changed;

  MachineBasicBlock *LastMBB = L->findLoopControlBlock();
  // Don't generate hw loop if the loop has more than one exit.
  if (!LastMBB) {
    return false;
  }

  MachineBasicBlock::iterator LastI = LastMBB->getFirstTerminator();
  if (LastI == LastMBB->end())
    return false;

  if (!IsEligibleForHardwareLoop(L))
    return false;

  // Are we able to determine the trip count for the loop?
  MachineOperand TripCount = MachineOperand::CreateImm(0);

  bool CanRetrieveTripCount = GetLOOPDOArgs(L, TripCount);

  if (!CanRetrieveTripCount) {
    LLVM_DEBUG(
        llvm::dbgs() << "HW Loop - Could not retrieve the loop count.\n");
    return false;
  }

  bool CanRemoveBranchingInstr = RemoveBranchingInstr(L);
  if (!CanRemoveBranchingInstr) {
    LLVM_DEBUG(llvm::dbgs()
               << "HW Loop - Could not remove the branching instruction.\n");
    return false;
  }

  MachineBasicBlock::iterator InsertPos = PreheaderMBB->instr_end();

  DebugLoc DL;

  MachineBasicBlock *DoneMBB = ExitMBB;
  if (!HeaderMBB->isLayoutSuccessor(ExitMBB)) {
    DoneMBB = MF.CreateMachineBasicBlock(NULL);
    BuildMI(*DoneMBB, DoneMBB->instr_end(), DL, TII->get(KVX::GOTO))
        .addMBB(ExitMBB);
    MF.insert(++HeaderMBB->getIterator(), DoneMBB);

    DoneMBB->transferSuccessorsAndUpdatePHIs(HeaderMBB);
    HeaderMBB->addSuccessor(DoneMBB);
  }

  if (TripCount.isReg()) {

    BuildMI(*PreheaderMBB, InsertPos, DL, TII->get(KVX::CB))
        .add(TripCount)
        .addMBB(DoneMBB)
        .addImm(1); // DEQZ

    BuildMI(*PreheaderMBB, InsertPos, DL, TII->get(KVX::LOOPDO))
        .add(TripCount)
        .addMBB(DoneMBB);
  } else {
    unsigned CountReg = MRI->createVirtualRegister(&KVX::SingleRegRegClass);

    BuildMI(*PreheaderMBB, InsertPos, DL, TII->get(KVX::MAKEi64), CountReg)
        .add(TripCount);

    BuildMI(*PreheaderMBB, InsertPos, DL, TII->get(KVX::LOOPDO))
        .addReg(CountReg)
        .addMBB(DoneMBB);
  }

  BuildMI(*HeaderMBB, HeaderMBB->instr_end(), DL, TII->get(KVX::ENDLOOP));
  return true;
}

bool KVXHardwareLoops::runOnMachineFunction(MachineFunction &MF) {
  bool Changed = false;

  MLI = &getAnalysis<MachineLoopInfo>();
  MRI = std::addressof(MF.getRegInfo());
  const KVXSubtarget &HST = MF.getSubtarget<KVXSubtarget>();
  TII = HST.getInstrInfo();

  for (auto &L : *MLI) {
    if (!L->getParentLoop()) {
      LLVM_DEBUG(
          llvm::dbgs() << "HW Loop - For function " << MF.getName()
                       << ", loop detected at "
                       << printMBBReference(**L->block_begin())
                       << ", attempt to replace it with a hardware loop.\n");

      if (ConvertToHardwareLoop(MF, L)) {
        LLVM_DEBUG(
            llvm::dbgs() << "HW Loop - Hardware Loop successfully inserted.\n");
        Changed = true;
      } else {
        LLVM_DEBUG(
            llvm::dbgs() << "HW Loop - Hardware Loop was NOT inserted.\n");
      }
    }
  }

  if (!Changed) {
    LLVM_DEBUG(llvm::dbgs() << "HW Loop - For function " << MF.getName()
                            << ", no loop found.\n");
  }

  return Changed;
}

FunctionPass *llvm::createKVXHardwareLoopsPass() {
  return new KVXHardwareLoops();
}
