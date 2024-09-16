//===-- KVXMCTargetDesc.h - KVX Target Descriptions -------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file provides KVX specific target descriptions.
//
//===----------------------------------------------------------------------===//

#include "KVXMCTargetDesc.h"
#include "InstPrinter/KVXInstPrinter.h"
#include "KVXAsmInfo.h"
#include "KVXTargetStreamer.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCDwarf.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/TargetRegistry.h"

#define GET_INSTRINFO_MC_DESC
#include "KVXGenInstrInfo.inc"

#define GET_REGINFO_MC_DESC
#include "KVXGenRegisterInfo.inc"

#define GET_SUBTARGETINFO_MC_DESC
#include "KVXGenSubtargetInfo.inc"

using namespace llvm;

static MCInstrInfo *createKVXMCInstrInfo() {
  MCInstrInfo *X = new MCInstrInfo();
  InitKVXMCInstrInfo(X);
  return X;
}

static MCRegisterInfo *createKVXMCRegisterInfo(const Triple &TT) {
  MCRegisterInfo *X = new MCRegisterInfo();
  InitKVXMCRegisterInfo(X, KVX::RA);
  return X;
}

static MCAsmInfo *createKVXMCAsmInfo(const MCRegisterInfo &MRI,
                                     const Triple &TT,
                                     const MCTargetOptions &Options) {
  MCAsmInfo *MAI = new KVXMCAsmInfo(TT);

  // Initial state of FP.
  unsigned Reg = MRI.getDwarfRegNum(KVX::R12, true);
  MCCFIInstruction Inst = MCCFIInstruction::cfiDefCfa(nullptr, Reg, 0);
  MAI->addInitialFrameState(Inst);

  return MAI;
}

static MCInstPrinter *createKVXMCInstPrinter(const Triple &T,
                                             unsigned SyntaxVariant,
                                             const MCAsmInfo &MAI,
                                             const MCInstrInfo &MII,
                                             const MCRegisterInfo &MRI) {
  return new KVXInstPrinter(MAI, MII, MRI);
}

static MCSubtargetInfo *createKVXMCSubtargetInfo(const Triple &TT,
                                                 StringRef CPU, StringRef FS) {
  return createKVXMCSubtargetInfoImpl(
      TT, KVX_MC::selectKVXCPU(CPU), /*TuneCPU*/ KVX_MC::selectKVXCPU(CPU), FS);
}

static MCTargetStreamer *createKVXTargetStreamer(MCStreamer &S,
                                                 formatted_raw_ostream &OS,
                                                 MCInstPrinter *InstPrint) {
  return new KVXTargetStreamer(S);
}

static StringRef DefaultArch = "kv3-1";
StringRef KVX_MC::selectKVXCPU(StringRef CPU) {
  if (CPU.empty())
    return DefaultArch;
  return CPU;
}

extern "C" LLVM_EXTERNAL_VISIBILITY void LLVMInitializeKVXTargetMC() {
  TargetRegistry::RegisterMCAsmInfo(getTheKVXTarget(), createKVXMCAsmInfo);
  TargetRegistry::RegisterMCInstrInfo(getTheKVXTarget(), createKVXMCInstrInfo);
  TargetRegistry::RegisterMCRegInfo(getTheKVXTarget(), createKVXMCRegisterInfo);
  TargetRegistry::RegisterMCInstPrinter(getTheKVXTarget(),
                                        createKVXMCInstPrinter);
  TargetRegistry::RegisterAsmTargetStreamer(getTheKVXTarget(),
                                            createKVXTargetStreamer);
  TargetRegistry::RegisterMCSubtargetInfo(getTheKVXTarget(),
                                          createKVXMCSubtargetInfo);
  TargetRegistry::RegisterMCAsmBackend(getTheKVXTarget(), nullptr);
  // This is a dummy RegisterMCCodeEmitter. Avoid functions it does not support.
  TargetRegistry::RegisterMCCodeEmitter(getTheKVXTarget(), nullptr);
}
