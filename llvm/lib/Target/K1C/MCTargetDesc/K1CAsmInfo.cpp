#include "K1CAsmInfo.h"
#include "llvm/ADT/Triple.h"
using namespace llvm;

void K1CMCAsmInfo::anchor() {}

K1CMCAsmInfo::K1CMCAsmInfo(const Triple &TT) {
  CodePointerSize = CalleeSaveStackSlotSize = TT.isArch64Bit() ? 8 : 4;
  CommentString = "#";
  SupportsDebugInformation = true;
  Data64bitsDirective = "\t.8byte\t";
}
