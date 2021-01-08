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

struct KVXHardwareLoops : public MachineFunctionPass {
public:
  static char ID;

  const KVXInstrInfo *TII;
  MachineRegisterInfo *MRI;

  KVXHardwareLoops() : MachineFunctionPass(ID) {
    auto *PR = PassRegistry::getPassRegistry();
    initializeKVXHardwareLoopsPass(*PR);
  }

  bool runOnMachineFunction(MachineFunction &MF) override;
  bool runOnLoop(MachineLoop *Loop);

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addRequired<MachineDominatorTree>();
    AU.addRequired<LoopInfoWrapperPass>();
    AU.addRequired<MachineLoopInfo>();
    MachineFunctionPass::getAnalysisUsage(AU);
  }

private:
  StringRef getPassName() const override;
};

#endif // LLVM_LIB_TARGET_KVX_KVXHARDWARELOOPS_H
