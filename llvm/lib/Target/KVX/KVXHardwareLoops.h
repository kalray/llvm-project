//===-- KVXHardwareLoops.cpp - Hardware loops optimization step -*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_KVX_KVXHARDWARELOOPS_H
#define LLVM_LIB_TARGET_KVX_KVXHARDWARELOOPS_H

#include "llvm/Analysis/LoopInfo.h"
#include "llvm/CodeGen/MachineBranchProbabilityInfo.h"
#include "llvm/CodeGen/MachineDominators.h"
#include "llvm/CodeGen/MachineLoopInfo.h"
#include "llvm/InitializePasses.h"
#include "llvm/Pass.h"

#include "KVX.h"
#include "KVXInstrInfo.h"

using namespace llvm;

struct KVXHardwareLoops : public MachineFunctionPass {
public:
  static char ID;

  const KVXInstrInfo *TII;
  MachineRegisterInfo *MRI;
  MachineBranchProbabilityInfo *MBPI;

  KVXHardwareLoops() : MachineFunctionPass(ID) {
    auto *PR = PassRegistry::getPassRegistry();
    initializeKVXHardwareLoopsPass(*PR);
  }

  bool runOnMachineFunction(MachineFunction &MF) override;
  bool runOnLoop(MachineLoop *Loop);

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addRequired<MachineDominatorTreeWrapperPass>();
    AU.addRequired<LoopInfoWrapperPass>();
    AU.addRequired<MachineLoopInfoWrapperPass>();
    AU.addRequired<MachineBranchProbabilityInfoWrapperPass>();

    MachineFunctionPass::getAnalysisUsage(AU);
  }

private:
  StringRef getPassName() const override;
  void turnIntoOneMBBLoop(MachineLoop *Loop) const;
};

#endif // LLVM_LIB_TARGET_KVX_KVXHARDWARELOOPS_H
