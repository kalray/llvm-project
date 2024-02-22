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
using namespace llvm;

void KVXMCAsmInfo::anchor() {}

KVXMCAsmInfo::KVXMCAsmInfo(const Triple &TT) {
  CodePointerSize = 8;
  CalleeSaveStackSlotSize = 8;
  CommentString = "#";
  Data64bitsDirective = "\t.8byte\t";
  DwarfRegNumForCFI = true;
  ExceptionsType = ExceptionHandling::SjLj;
  MaxInstLength = 12;
  MinInstAlignment = 4;
  SupportsDebugInformation = true;
  UseIntegratedAssembler = false;
  UsesELFSectionDirectiveForBSS = true;
  UsesCFIWithoutEH = true;
  ParseInlineAsmUsingAsmParser = false;
  PreserveAsmComments = true;
}
