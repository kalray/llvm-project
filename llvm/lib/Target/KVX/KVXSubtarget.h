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

#ifndef LLVM_LIB_TARGET_KVX_KVXSUBTARGET_H
#define LLVM_LIB_TARGET_KVX_KVXSUBTARGET_H

#include "KVXFrameLowering.h"
#include "KVXISelLowering.h"
#include "KVXInstrInfo.h"
#include "llvm/CodeGen/SelectionDAGTargetInfo.h"
#include "llvm/CodeGen/TargetSubtargetInfo.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/Target/TargetMachine.h"

#define GET_SUBTARGETINFO_HEADER
#include "KVXGenSubtargetInfo.inc"

namespace llvm {
class KVXSubtarget : public KVXGenSubtargetInfo {
  virtual void anchor();

  bool HasFPIMM = false;

  CodeGenOpt::Level OptLevel;
  KVXFrameLowering FrameLowering;
  KVXInstrInfo InstrInfo;
  KVXRegisterInfo RegInfo;
  KVXTargetLowering TLInfo;
  SelectionDAGTargetInfo TSInfo;
  InstrItineraryData InstrItins;

public:
  // Initializes the data members to match that of the specified triple.
  KVXSubtarget(const Triple &TT, StringRef CPU, const std::string &FS,
               const TargetMachine &TM);

  // Parses features string setting specified subtarget options. The
  // definition of this function is auto-generated by tblgen.
  void ParseSubtargetFeatures(StringRef CPU, StringRef FS);

  /// initializeSubtargetDependencies - Initializes using a CPU and feature
  /// string so that we can use initializer lists for subtarget initialization.
  KVXSubtarget &initializeSubtargetDependencies(StringRef CPU, StringRef FS);

  const KVXFrameLowering *getFrameLowering() const override {
    return &FrameLowering;
  }
  const KVXInstrInfo *getInstrInfo() const override { return &InstrInfo; }
  const KVXRegisterInfo *getRegisterInfo() const override { return &RegInfo; }
  const KVXTargetLowering *getTargetLowering() const override {
    return &TLInfo;
  }
  const SelectionDAGTargetInfo *getSelectionDAGInfo() const override {
    return &TSInfo;
  }
  const InstrItineraryData *getInstrItineraryData() const override {
    return &InstrItins;
  }

  bool enableAdvancedRASplitCost() const override;
  bool enableSubRegLiveness() const override;
  bool enableMachineSchedDefaultSched() const override;
  bool enablePostRAScheduler() const override;
  bool enableMachineScheduler() const override;
  bool hasFPIMM() const;
  bool useAA() const override;
};
} // namespace llvm

#endif
