//===-- K1CMCTargetDesc.h - K1C Target Descriptions -------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file provides K1C specific target descriptions.
//
//===----------------------------------------------------------------------===//

#include "InstPrinter/K1CInstPrinter.h"
#include "K1CAsmInfo.h"
#include "K1CMCTargetDesc.h"
#include "K1CTargetStreamer.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/TargetRegistry.h"

#define GET_INSTRINFO_MC_DESC
#include "K1CGenInstrInfo.inc"

#define GET_REGINFO_MC_DESC
#include "K1CGenRegisterInfo.inc"

#define GET_SUBTARGETINFO_MC_DESC
#include "K1CGenSubtargetInfo.inc"

using namespace llvm;

static MCInstrInfo *createK1CMCInstrInfo() {
  MCInstrInfo *X = new MCInstrInfo();
  InitK1CMCInstrInfo(X);
  return X;
}

static MCRegisterInfo *createK1CMCRegisterInfo(const Triple &TT) {
  MCRegisterInfo *X = new MCRegisterInfo();
  InitK1CMCRegisterInfo(X, K1C::RA);
  return X;
}

static MCAsmInfo *createK1CMCAsmInfo(const MCRegisterInfo &MRI,
                                     const Triple &TT) {
  return new K1CMCAsmInfo(TT);
}

static MCInstPrinter *createK1CMCInstPrinter(const Triple &T,
                                             unsigned SyntaxVariant,
                                             const MCAsmInfo &MAI,
                                             const MCInstrInfo &MII,
                                             const MCRegisterInfo &MRI) {
  return new K1CInstPrinter(MAI, MII, MRI);
}

static MCSubtargetInfo *createK1CMCSubtargetInfo(const Triple &TT,
                                                 StringRef CPU, StringRef FS) {
  return createK1CMCSubtargetInfoImpl(TT, CPU, FS);
}

static MCTargetStreamer *createK1CTargetStreamer(MCStreamer &S,
                                                 formatted_raw_ostream &OS,
                                                 MCInstPrinter *InstPrint,
                                                 bool isVerboseAsm) {
  return new K1CTargetStreamer(S);
}

static StringRef DefaultArch = "k1c";
static StringRef DefaultSubarch = "v1";
StringRef K1C_MC::selectK1CCPU(StringRef CPU) {
  if (CPU.empty() || CPU.equals(DefaultArch.str() + DefaultSubarch.str()))
    return DefaultArch;
  return CPU;
}

extern "C" void LLVMInitializeK1CTargetMC() {
  TargetRegistry::RegisterMCAsmInfo(getTheK1CTarget(), createK1CMCAsmInfo);
  TargetRegistry::RegisterMCInstrInfo(getTheK1CTarget(), createK1CMCInstrInfo);
  TargetRegistry::RegisterMCRegInfo(getTheK1CTarget(), createK1CMCRegisterInfo);
  TargetRegistry::RegisterMCInstPrinter(getTheK1CTarget(),
                                        createK1CMCInstPrinter);
  TargetRegistry::RegisterAsmTargetStreamer(getTheK1CTarget(),
                                            createK1CTargetStreamer);
  TargetRegistry::RegisterMCSubtargetInfo(getTheK1CTarget(),
                                          createK1CMCSubtargetInfo);
  TargetRegistry::RegisterMCAsmBackend(getTheK1CTarget(), createK1CAsmBackend);
  TargetRegistry::RegisterMCCodeEmitter(getTheK1CTarget(),
                                        createK1CMCCodeEmitter);
}
