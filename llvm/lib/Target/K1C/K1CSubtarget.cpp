//===--- K1CSubtarget.h - Define Subtarget for the K1C ---------*- C++ -*--===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares the K1C specific subclass of TargetSubtarget.
//
//===----------------------------------------------------------------------===//

#include "K1CSubtarget.h"
#include "K1C.h"
#include "K1CFrameLowering.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

#define DEBUG_TYPE "K1C-subtarget"

#define GET_SUBTARGETINFO_TARGET_DESC
#define GET_SUBTARGETINFO_CTOR
#include "K1CGenSubtargetInfo.inc"

void K1CSubtarget::anchor() {}

K1CSubtarget::K1CSubtarget(const Triple &TT, StringRef CPU,
                           const std::string &FS, const TargetMachine &TM)
    : K1CGenSubtargetInfo(TT, CPU, FS), OptLevel(TM.getOptLevel()),
      FrameLowering(*this), InstrInfo(), RegInfo(getHwMode()),
      TLInfo(TM, *this),
      InstrItins(getInstrItineraryForCPU(K1C_MC::selectK1CCPU(CPU))) {
  assert(InstrItins.Itineraries != nullptr && "InstrItins not initialized");
}
