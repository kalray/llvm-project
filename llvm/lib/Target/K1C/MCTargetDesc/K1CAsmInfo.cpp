#include "K1CAsmInfo.h"
#include "llvm/ADT/Triple.h"
using namespace llvm;

void K1CMCAsmInfo::anchor() {}

K1CMCAsmInfo::K1CMCAsmInfo(const Triple &TT) {
  CodePointerSize = CalleeSaveStackSlotSize = TT.isArch64Bit() ? 8 : 4;
  CommentString = "#";
  AlignmentIsInBytes = false;
  SupportsDebugInformation = true;
  Data16bitsDirective = "\t.half\t";
  Data32bitsDirective = "\t.word\t";
}