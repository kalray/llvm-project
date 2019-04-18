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

K1CSubtarget::K1CSubtarget(const Triple &TT, const std::string &CPU,
                           const std::string &FS, const TargetMachine &TM)
    : K1CGenSubtargetInfo(TT, CPU, FS), FrameLowering(*this), InstrInfo(),
      RegInfo(getHwMode()), TLInfo(TM, *this) {}
