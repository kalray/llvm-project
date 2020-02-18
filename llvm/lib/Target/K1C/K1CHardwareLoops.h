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
// Algorithm description:
// 1. LLVM analyses the loop instructions through the getAnalysis method.
//
// 2. For every loop, a preheader, a header and an exit block is
// extracted.(Using LLVM functions) From LLVM terminology, the preheader is the
// basic block preceeding the loop (where initializations are done). The header
// is (in our case, O2, O3 compilation) the basic block containing the ending
// condition and the content of the loop The exit block is the block coming
// after the loop ends.
//
// 3. The loop is done recursively, meaning that in the case of nested loops,
// only the ones that do NOT contain other loops will be replaced with hardware
// loops.
//
// 4. Eligibility check: A loop can be optimized if:
// - The preheader and the header are not empty
// - There is no function call under the loop
// - There is no indirect branching (multiple exit points loop) in the loop
//
// 5 The LOOPDO instruction arguments are:
//   - The number of iterations
//   - The exit basic block which MUST succeed the header
// In order to find the number of iterations, GetLOOPDOArgs is called, under
// this function the parsing of the machine instruction is done.
//
// 6. The parsing:
// The comparison instruction is searched for and the type (less than, greather
// than etc) is extracted. From here there two cases: reg-reg comparison and
// reg-imm comparison.
// - reg-imm case: The imm is the loop end value, it will be stored for later
// user.
// - reg-reg case: This case is split into two:
//   - The value in one of the two registers can be found by tracing the
//   register usage, in this case, the found value is the starting index.
//   - Neither of the two values can be tracked, in this case, hardware loop
//   does not take place.
// Thus after the parsing we have the comparison type, the starting/ending
// value, the ending register (for the reg-reg case) Observation: The reg-reg
// case handles only the case where the bump is 1 and the starting value is 0.
//
// 7. The backtracking of a register starts in the header from the COMPD
// instruction and ends in the preheader. During the backtracking, upon the
// register can be applied the following operations: load, store, add, subtract
// and make. The MAKE instruction is the stopping condition.
//
// 8. After the parsing(Under GetLOOPDOArgs) there are two cases:
//   - Both the starting value and the ending value of the iteration are know.
//   In this case, a difference
// is computed based on the COMPD sign and the number of steps are returned.
//   - Only the Starting value is known. In this case, the ending value is
//   returned as a register.
//
// 9. The loop comparison is removed(RemoveBranchingInstr) meaning the COMP and
// GOTO instruction.
//
// 10. There are cases(fp1.c test) when the exit block is not immediately after
// the header which leads to an undefined behaviour. To avoid this, a new basic
// block is created and inserted immediately after the header. This new basic
// block will contain a GOTO instruction to the exit block.
//
// 11. In the reg-imm case, a make and a loopdo instruction will be inserted at
// the end of the preheader. In the reg-reg case, a CB and a LOOPDO instruction
// will be inserted at the end of the preheader. The purpose of the CB
// instruction is to check that the register is not 0, in which case it jumps
// directly to the exit block.
//
// Further work:
// - In the reg-reg case, add instructions for handling the cases where the
// bumping value is different than 1 and the starting value is different than 0.
// - Add reg-reg memory addressing
// - Add the cases in which the step of the loop is a multiplication or a
// division.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_K1C_K1CHARDWARELOOPS_H
#define LLVM_LIB_TARGET_K1C_K1CHARDWARELOOPS_H

#include "llvm/ADT/StringRef.h"
#include "llvm/CodeGen/MachineDominators.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineLoopInfo.h"
#include "llvm/InitializePasses.h"

#include "K1C.h"
#include "K1CInstrInfo.h"
#include "K1CSubtarget.h"

using namespace llvm;

using instr_iterator = MachineBasicBlock::instr_iterator;

struct K1CHardwareLoops : public MachineFunctionPass {
public:
  static char ID;

  const K1CInstrInfo *TII;
  MachineLoopInfo *MLI;
  MachineRegisterInfo *MRI;

  K1CHardwareLoops() : MachineFunctionPass(ID) {
    auto PR = PassRegistry::getPassRegistry();
    initializeK1CHardwareLoopsPass(*PR);
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

  bool ParseLoop(MachineLoop *L, MachineOperand &EndVal, int &Cond,
                 int64_t &StartVal, int64_t &Bump);

  bool IsEligibleForHardwareLoop(MachineLoop *L);

  bool BackTraceRegValue(MachineLoop *L, instr_iterator MII,
                         unsigned RegToBacktrace, int64_t &CmpVal,
                         int64_t &Bump);

  bool GetLOOPDOArgs(MachineLoop *L, MachineOperand &StepsCount);

  bool ConvertToHardwareLoop(MachineFunction &MF, MachineLoop *L);

  bool RemoveBranchingInstr(MachineLoop *L);

  StringRef getPassName() const override { return "K1C Hardware Loops"; }
};

#endif // LLVM_LIB_TARGET_K1C_K1CHARDWARELOOPS_H
