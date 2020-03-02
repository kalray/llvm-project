//===-- KVXMCAsmInfo.h - KVX Asm Info --------------------------*- C++ -*--===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the declaration of the KVXMCAsmInfo class.
//
//===----------------------------------------------------------------------===//

#include "KVXAsmInfo.h"
#include "llvm/ADT/Triple.h"
using namespace llvm;

void KVXMCAsmInfo::anchor() {}

KVXMCAsmInfo::KVXMCAsmInfo(const Triple &TT) {
  CodePointerSize = CalleeSaveStackSlotSize = TT.isArch64Bit() ? 8 : 4;
  CommentString = "#";
  SupportsDebugInformation = true;
  Data64bitsDirective = "\t.8byte\t";
  DwarfRegNumForCFI = true;
  ExceptionsType = ExceptionHandling::DwarfCFI;
  UsesELFSectionDirectiveForBSS = true;
}
