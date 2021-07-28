//===--- KVXSubtarget.h - Define Subtarget for the KVX ---------*- C++ -*--===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares the KVX specific subclass of TargetSubtarget.
//
//===----------------------------------------------------------------------===//

#include "KVXSubtarget.h"
#include "KVX.h"
#include "KVXFrameLowering.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

#define DEBUG_TYPE "kvx-subtarget"

#define GET_SUBTARGETINFO_TARGET_DESC
#define GET_SUBTARGETINFO_CTOR
#include "KVXGenSubtargetInfo.inc"

void KVXSubtarget::anchor() {}

KVXSubtarget &KVXSubtarget::initializeSubtargetDependencies(StringRef CPU,
                                                            StringRef FS) {

  if (CPU.empty())
    CPU = "kv3-1";

  ParseSubtargetFeatures(CPU, /* TuneCPU */ CPU, FS);

  return *this;
}

KVXSubtarget::KVXSubtarget(const Triple &TT, StringRef CPU,
                           const std::string &FS, const TargetMachine &TM)
    : KVXGenSubtargetInfo(TT, CPU, /* TuneCPU */ CPU, FS),
      OptLevel(TM.getOptLevel()), FrameLowering(*this), InstrInfo(initializeSubtargetDependencies(CPU, FS)),
      RegInfo(getHwMode()), TLInfo(TM, *this),
      InstrItins(getInstrItineraryForCPU(KVX_MC::selectKVXCPU(CPU))) {
  assert(InstrItins.Itineraries != nullptr && "InstrItins not initialized");
}

bool KVXSubtarget::enableAdvancedRASplitCost() const {
  return OptLevel > CodeGenOpt::Default;
};
bool KVXSubtarget::enableMachineScheduler() const { return true; }
bool KVXSubtarget::enableMachineSchedDefaultSched() const { return false; }
bool KVXSubtarget::enablePostRAScheduler() const { return true; }
bool KVXSubtarget::enableSubRegLiveness() const {
  return OptLevel > CodeGenOpt::Less;
}
bool KVXSubtarget::useAA() const { return (OptLevel != CodeGenOpt::None); }
bool KVXSubtarget::isV1() const { return IsV1; }
