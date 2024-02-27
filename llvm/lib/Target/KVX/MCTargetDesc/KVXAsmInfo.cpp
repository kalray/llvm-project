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
  CalleeSaveStackSlotSize = 8;
  CodePointerSize = 8;
  CommentString = "#";
  CompressDebugSections = DebugCompressionType::None;
  Data64bitsDirective = "\t.8byte\t";
  DwarfRegNumForCFI = true;
  ExceptionsType = ExceptionHandling::SjLj;
  HasBasenameOnlyForFileDirective = false;
  MaxInstLength = 12;
  MinInstAlignment = 4;
  ParseInlineAsmUsingAsmParser = false;
  PreserveAsmComments = true;
  SupportsDebugInformation = true;
  UseIntegratedAssembler = false;
  UsesCFIForDebug = true;
  UsesCFIWithoutEH = false;
  UsesELFSectionDirectiveForBSS = false;
}

bool KVXMCAsmInfo::shouldOmitSectionDirective(StringRef SectionName) const {
  return false;
}
