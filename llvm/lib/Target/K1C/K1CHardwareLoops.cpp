//===-- K1CHardwareLoops.cpp - Hardware loops optimization step -*- C++ -*-===//
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

#include "K1C.h"
#include "K1CHardwareLoops.h"
#include "K1CInstrInfo.h"
#include "K1CSubtarget.h"
using namespace llvm;

#define DEBUG_TYPE "hwloops"

#define K1CHARDWARELOOPS_NAME "k1c-hardware-loops"
#define K1CHARDWARELOOPS_DESC "Hardware loops"

using instr_iterator = MachineBasicBlock::instr_iterator;

char K1CHardwareLoops::ID = 0;

INITIALIZE_PASS_BEGIN(K1CHardwareLoops, K1CHARDWARELOOPS_NAME,
                      K1CHARDWARELOOPS_DESC, false, false)
INITIALIZE_PASS_DEPENDENCY(MachineDominatorTree)
INITIALIZE_PASS_DEPENDENCY(MachineLoopInfo)
INITIALIZE_PASS_END(K1CHardwareLoops, K1CHARDWARELOOPS_NAME,
                    K1CHARDWARELOOPS_DESC, false, false)

static bool isAddOperator(unsigned opcode) {
  switch (opcode) {
  case K1C::ADDWd0:
  case K1C::ADDWd1:
  case K1C::ADDWd2:
  case K1C::ADDDd0:
  case K1C::ADDDd1:
  case K1C::ADDDd2:
  case K1C::ADDDd3:
    return true;
  default:
    return false;
  }

  return false;
}

static bool isSubOperator(unsigned opcode) {
  switch (opcode) {
  case K1C::SBFDd0:
  case K1C::SBFDd1:
  case K1C::SBFDd2:
  case K1C::SBFDd3:
  case K1C::SBFWd0:
  case K1C::SBFWd1:
  case K1C::SBFWd2:
    return true;
  default:
    return false;
  }

  return false;
}

static bool isMakeOperator(unsigned opcode) {
  switch (opcode) {
  case K1C::MAKEd0:
  case K1C::MAKEd1:
    return true;
  default:
    return false;
  }

  return false;
}

static bool isCompOperator(unsigned opcode) {
  switch (opcode) {
  case K1C::COMPWd0:
  case K1C::COMPWd1:
  case K1C::COMPDd0:
  case K1C::COMPDd1:
  case K1C::COMPDd2:
  case K1C::COMPDd3:
    return true;
  default:
    return false;
  }

  return false;
}

bool K1CHardwareLoops::IsEligibleForHardwareLoop(MachineLoop *L) {

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
    if (I->getOpcode() == K1C::CALL) {
      LLVM_DEBUG(llvm::dbgs()
                 << "HW Loop - The loop contains internal calls.\n");
      return false;
    }

    // The HW loop should not contain branches (other than the single loop
    // stopping condition)
    if (I->isIndirectBranch()) {
      LLVM_DEBUG(llvm::dbgs()
                 << "HW Loop - The loop contains an indirect branch.\n");
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
bool K1CHardwareLoops::BackTraceRegValue(MachineLoop *L,
                                         instr_iterator headerIt,
                                         unsigned regToSearchFor,
                                         int64_t &CmpVal, int64_t &Bump) {

  unsigned regNr = regToSearchFor;
  bool Done = false;

  headerIt = std::prev(headerIt);
  // Condition basick block register backtrace
  do {
    if (headerIt->getOpcode() == K1C::PHI &&
        headerIt->getOperand(0).getReg() == regNr) {
      regNr = headerIt->getOperand(1).getReg();
    }

    if (isAddOperator(headerIt->getOpcode()) &&
        headerIt->getOperand(0).getReg() == regNr &&
        headerIt->getOperand(2).isImm()) {
      regNr = headerIt->getOperand(1).getReg();
      Bump = headerIt->getOperand(2).getImm();
    }

    if (isSubOperator(headerIt->getOpcode()) &&
        headerIt->getOperand(0).getReg() == regNr &&
        headerIt->getOperand(2).isImm()) {
      regNr = headerIt->getOperand(1).getReg();
      Bump = headerIt->getOperand(2).getImm();
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
      CmpVal = I->getOperand(1).getImm();
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

bool K1CHardwareLoops::ParseLoop(MachineLoop *L, int64_t &EndVal, int &Cond,
                                 int64_t &StartVal, bool &StopValIsReg,
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
        // If the register's value could not be traced, then the loop can not
        // be parsed
        if (!BackTraceRegValue(L, I, I->getOperand(1).getReg(), StartVal,
                               Bump)) {
          LLVM_DEBUG(
              llvm::dbgs()
              << "HW Loop - [REG-IMM] The register could not be traced.\n");
          return false;
        }
        EndVal = I->getOperand(2).getImm();
        StopValIsReg = false;
      } // REG-IMM case
      // REG-REG case
      else if (I->getOperand(1).isReg() && I->getOperand(2).isReg()) {

        int64_t BumpOp1 = 0;
        int64_t BumpOp2 = 0;
        int64_t StartValOp1 = 0;
        int64_t StartValOp2 = 0;
        bool BacktraceOp1 = BackTraceRegValue(L, I, I->getOperand(1).getReg(),
                                              StartValOp1, BumpOp1);
        bool BacktraceOp2 = BackTraceRegValue(L, I, I->getOperand(2).getReg(),
                                              StartValOp2, BumpOp2);

        // If the register's value could not be traced, then the loop can not
        // be parsed
        if (BacktraceOp1 && BumpOp2 == 0) {
          Bump = BumpOp1;
          StartVal = StartValOp1;

          // This line should be removed when cases for Bump != 1 and StartVal
          // != 1 are implemented
          if (Bump != 1 || StartVal != 0) {
            LLVM_DEBUG(llvm::dbgs() << "HW Loop - [REG-REG] The bump value is "
                                       "not 1 or the start value is not 0.\n");
            return false;
          }

          EndVal = I->getOperand(2).getReg();
          StopValIsReg = true;
        } else {
          // If the register's value could not be traced, then the loop can not
          // be parsed
          if (BacktraceOp2 && BumpOp1 == 0) {
            Bump = BumpOp2;
            StartVal = StartValOp2;

            // This line should be removed when cases for Bump != 1 and StartVal
            // != 1 are implemented
            if (Bump != 1 || StartVal != 0) {
              LLVM_DEBUG(llvm::dbgs()
                         << "HW Loop - [REG-REG] The bump value is not 1 or "
                            "the start value is not 0.\n");
              return false;
            }

            EndVal = I->getOperand(1).getReg();
            StopValIsReg = true;
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

bool K1CHardwareLoops::GetLOOPDOArgs(MachineLoop *L, unsigned &steps,
                                     bool &StepsCountValueIsReg) {

  int64_t StartVal = 0;
  int64_t EndVal = 0;
  int64_t Bump = 0;

  int Cond = -1;
  bool CanRetrieveEndingCond =
      ParseLoop(L, EndVal, Cond, StartVal, StepsCountValueIsReg, Bump);

  if (!CanRetrieveEndingCond) {
    LLVM_DEBUG(llvm::dbgs() << "HW Loop - Could not retrieve the end "
                               "value/start value/bump/condition type.\n");
    return false;
  }

  if (StepsCountValueIsReg) {
    steps = EndVal;
    return true;
  }

  if (Bump == 0) {
    LLVM_DEBUG(llvm::dbgs() << "HW Loop - The found bump value is 0.\n");
    return false;
  }

  switch (Cond) {
  /* Not Equal */
  case 0:
  /* Equal */
  case 1: {
    if (StartVal == EndVal)
      return false;
    steps = ((EndVal - StartVal) / Bump);
    return true;
  }
  /* Less Than */
  case 2:
  /* Greater Than or Equal */
  case 3:
  /* Less Than or Equal */
  case 4:
  /* Greater Than */
  case 5:
  /* Less Than Unsigned */
  case 6:
  /* Greater Than or Equal Unsigned */
  case 7:
  /* Less Than or Equal Unsigned */
  case 8:
  /* Greater Than Unsigned */
  case 9: {
    steps = ((EndVal - StartVal) / Bump) + 1;
    return true;
  }
  default:
    return false;
  }
}

bool K1CHardwareLoops::RemoveBranchingInstr(MachineLoop *L) {

  instr_iterator PreheaderGoto = PreheaderMBB->instr_end();

  for (instr_iterator I = PreheaderMBB->instr_begin(),
                      E = PreheaderMBB->instr_end();
       I != E; ++I) {
    if (I->getOpcode() == K1C::GOTO) {
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
      if (I == HeaderMBB->instr_end() || I->getOpcode() != K1C::CB) {
        LLVM_DEBUG(llvm::dbgs() << "HW Loop - The comparison instruction is "
                                   "not followed by a CB instruction.\n");
        return false;
      } else {
        HeaderCB = I;
        I++;
        if (I == HeaderMBB->instr_end() || I->getOpcode() != K1C::GOTO) {
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

bool K1CHardwareLoops::ConvertToHardwareLoop(MachineFunction &MF,
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
  unsigned TripCount = 0;
  bool IsReg = false;

  bool CanRetrieveTripCount = GetLOOPDOArgs(L, TripCount, IsReg);

  if (!CanRetrieveTripCount) {
    LLVM_DEBUG(llvm::dbgs()
               << "HW Loop - Could not retrieve the loop count.\n");
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

  MachineBasicBlock *DoneMBB = MF.CreateMachineBasicBlock(NULL);
  BuildMI(*DoneMBB, DoneMBB->instr_end(), DL, TII->get(K1C::GOTO))
      .addMBB(ExitMBB);
  MF.insert(++HeaderMBB->getIterator(), DoneMBB);

  DoneMBB->transferSuccessorsAndUpdatePHIs(HeaderMBB);
  HeaderMBB->addSuccessor(DoneMBB);

  if (IsReg) {

    BuildMI(*PreheaderMBB, InsertPos, DL, TII->get(K1C::CB))
        .addReg(TripCount)
        .addMBB(DoneMBB)
        .addImm(1); // DEQZ

    BuildMI(*PreheaderMBB, InsertPos, DL, TII->get(K1C::LOOPDO))
        .addReg(TripCount)
        .addMBB(DoneMBB);
  } else {
    unsigned CountReg = MRI->createVirtualRegister(&K1C::SingleRegRegClass);

    BuildMI(*PreheaderMBB, InsertPos, DL, TII->get(K1C::MAKEd2), CountReg)
        .addImm(TripCount);

    BuildMI(*PreheaderMBB, InsertPos, DL, TII->get(K1C::LOOPDO))
        .addReg(CountReg)
        .addMBB(DoneMBB);
  }

  BuildMI(*HeaderMBB, HeaderMBB->instr_end(), DL, TII->get(K1C::ENDLOOP));
  return true;
}

bool K1CHardwareLoops::runOnMachineFunction(MachineFunction &MF) {
  bool Changed = false;

  MLI = &getAnalysis<MachineLoopInfo>();
  MRI = std::addressof(MF.getRegInfo());
  const K1CSubtarget &HST = MF.getSubtarget<K1CSubtarget>();
  TII = HST.getInstrInfo();

  for (auto &L : *MLI) {
    if (!L->getParentLoop()) {
      LLVM_DEBUG(llvm::dbgs()
                 << "HW Loop - For function " << MF.getName()
                 << ", loop detected at "
                 << printMBBReference(**L->block_begin())
                 << ", attempt to replace it with a hardware loop.\n");

      if (ConvertToHardwareLoop(MF, L)) {
        LLVM_DEBUG(llvm::dbgs()
                   << "HW Loop - Hardware Loop successfully inserted.\n");
        Changed = true;
      } else {
        LLVM_DEBUG(llvm::dbgs()
                   << "HW Loop - Hardware Loop was NOT inserted.\n");
      }
    }
  }

  if (!Changed) {
    LLVM_DEBUG(llvm::dbgs() << "HW Loop - For function " << MF.getName()
                            << ", no loop found.\n");
  }

  return Changed;
}

FunctionPass *llvm::createK1CHardwareLoopsPass() {
  return new K1CHardwareLoops();
}
