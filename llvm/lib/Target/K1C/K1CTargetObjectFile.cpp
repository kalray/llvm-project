//===-- K1CTargetObjectFile.h - K1C Object Info ---------*- C++ ---------*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "K1CTargetObjectFile.h"
#include "K1CTargetMachine.h"

using namespace llvm;

void K1CELFTargetObjectFile::Initialize(MCContext &Ctx,
                                        const TargetMachine &TM) {
  TargetLoweringObjectFileELF::Initialize(Ctx, TM);
  InitializeELF(TM.Options.UseInitArray);
}

const MCExpr *
K1CELFTargetObjectFile::getDebugThreadLocalSymbol(const MCSymbol *Sym) const {
  return MCSymbolRefExpr::create(Sym, MCSymbolRefExpr::VK_K1C_TLSLE,
                                 getContext());
}
