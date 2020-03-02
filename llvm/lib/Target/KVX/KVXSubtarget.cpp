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

#define DEBUG_TYPE "KVX-subtarget"

#define GET_SUBTARGETINFO_TARGET_DESC
#define GET_SUBTARGETINFO_CTOR
#include "KVXGenSubtargetInfo.inc"

void KVXSubtarget::anchor() {}

KVXSubtarget::KVXSubtarget(const Triple &TT, StringRef CPU,
                           const std::string &FS, const TargetMachine &TM)
    : KVXGenSubtargetInfo(TT, CPU, FS), OptLevel(TM.getOptLevel()),
      FrameLowering(*this), InstrInfo(), RegInfo(getHwMode()),
      TLInfo(TM, *this),
      InstrItins(getInstrItineraryForCPU(KVX_MC::selectKVXCPU(CPU))) {
  assert(InstrItins.Itineraries != nullptr && "InstrItins not initialized");
}
