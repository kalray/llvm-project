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
// Algorithm description:
// 1. LLVM analyses the loop instructions through the getAnalysis method.
//
// 2. For every loop, a preheader, a header and an exit block is
// extracted.(Using LLVM functions) From LLVM terminology, the preheader is the
// basic block preceeding the loop (where initializations are done). The header
// is (in our case, O2, O3 compilation) the basic block containing the ending
// condition and/or the content of the loop. The exit block is the block coming
// after the loop ends.
//
// 3. The parsing is performed recursively, meaning that in the case of nested
// loops, only the ones that do NOT contain other loops will be replaced with
// hardware loops(the leafs of the loop tree).
//
// 4. Eligibility check: A loop can be optimized if:
// - The preheader, the header and the exit basic block exist and are not empty
// - There is no function call under the loop
// - There is no indirect branching (multiple exit points loop) in the loop
//
// 5 The LOOPDO instruction arguments are:
//   - The number of iterations
//   - The exit basic block which MUST succeed the header
// In order to find the number of iterations, GetLOOPDOArgs is called, under
// this function the parsing of the machine instructions is done.
//
// 6. The parsing:
// A seach inside the header is performed to find a CB instr that points
// to the header or to the exit basic block.
// Based on CB instruction there are two cases:
// a. The CB argument is computed in a COMPD instruction above.
// b. The CB argument is NOT computed in a COMPD instruction above.(
// in this case ususally is not profitable to replace with loopdo due to
// bundling)
// In order to enable/disable hwloop replace when CB only case, the CBOnlyHwLoop
// is used.
//
// Based on the CB/COMPD case, a backtrace of the register is done in order to
// detect the induction register.
// The BackTraceRegValue is used in this matter. It searches for the register
// to be part into an add operation(here the bump is extracted), to be part
// of a PHI instruction and to be defined outside of the header.
// As an optimization it also searches if the register is defined in a MAKE or
// sign extend operation.
// Based on this parsing the followig values are extracted:
// - The start value of the loop
// - The end value of the loop
// - The Bump value
// If the bump value is a register, no hwloop is inserted.
// If the bump value is 0, no hwloop is inserted.
// If the bump value is not incremental or decremental and the start value
// and the end value are not both IMM, no hwloop is inserted.
//
// Based on these values (the start and end value can be IMM/REG), there are
// the following cases:
// * IMM-IMM
// * IMM(zero) - REG
// * IMM(not zero)
// * REG-IMM(zero)
// * REG-IMM(not zero)
// * REG-REG
// Based on the above cases, the iteration count is computed. Either by
// inserting a NEGD, SBFD or MAKE instructions.
//
// 7. The loop comparison is removed(RemoveBranchingInstr) meaning the COMPD,
// CB, and GOTO instruction.
//
// 8. There are cases(fp1.c test) when the exit block is not immediately after
// the header which leads to an undefined behaviour. To avoid this, a new basic
// block is created and inserted immediately after the header. This new basic
// block will contain a GOTO instruction to the exit block.
//
// Further work:
// - In the reg-reg case, add instructions for handling the cases where the
// bumping value is different than 1 and the starting value is different than 0.
// - Add the cases in which the step of the loop is a multiplication or a
// division.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_KVX_KVXHARDWARELOOPS_H
#define LLVM_LIB_TARGET_KVX_KVXHARDWARELOOPS_H

#include "llvm/ADT/StringRef.h"
#include "llvm/CodeGen/MachineDominators.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineLoopInfo.h"
#include "llvm/InitializePasses.h"

#include "KVX.h"
#include "KVXInstrInfo.h"
#include "KVXSubtarget.h"

using namespace llvm;

using instr_iterator = MachineBasicBlock::instr_iterator;

struct KVXHardwareLoops : public MachineFunctionPass {
public:
  static char ID;

  const KVXInstrInfo *TII;
  MachineLoopInfo *MLI;
  MachineRegisterInfo *MRI;

  KVXHardwareLoops() : MachineFunctionPass(ID) {
    auto PR = PassRegistry::getPassRegistry();
    initializeKVXHardwareLoopsPass(*PR);
  }

  bool runOnMachineFunction(MachineFunction &MF) override;

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addRequired<MachineDominatorTree>();
    AU.addRequired<LoopInfoWrapperPass>();
    AU.addRequired<MachineLoopInfo>();
    MachineFunctionPass::getAnalysisUsage(AU);
  }

private:
  MachineBasicBlock *HeaderMBB;
  MachineBasicBlock *PreheaderMBB;
  MachineBasicBlock *ExitMBB;

  bool ParseLoop(MachineLoop *L, MachineOperand &EndVal, unsigned &Cond,
                 MachineOperand &StartVal, int64_t &Bump);

  bool IsEligibleForHardwareLoop(MachineLoop *L);

  bool BackTraceRegValue(MachineLoop *L, unsigned RegToBacktrace,
                         MachineOperand &CmpVal, int64_t &Bump,
                         bool &IsModified);

  bool GetLOOPDOArgs(MachineLoop *L, MachineOperand &StartVal,
                     MachineOperand &EndVal, int64_t &Bump);

  bool ConvertToHardwareLoop(MachineFunction &MF, MachineLoop *L,
                             unsigned Level);

  bool RemoveBranchingInstr(MachineLoop *L);

  StringRef getPassName() const override { return "KVX Hardware Loops"; }
};

#endif // LLVM_LIB_TARGET_KVX_KVXHARDWARELOOPS_H
