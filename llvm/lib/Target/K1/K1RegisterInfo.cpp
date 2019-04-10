#include "K1RegisterInfo.h"
#include "K1.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/RegisterScavenging.h"
#include "llvm/CodeGen/TargetFrameLowering.h"
#include "llvm/CodeGen/TargetInstrInfo.h"
#include "llvm/Support/ErrorHandling.h"
#include "K1FrameLowering.h"

using namespace llvm;

#define GET_REGINFO_TARGET_DESC
#include "K1GenRegisterInfo.inc"

K1RegisterInfo::K1RegisterInfo() : K1GenRegisterInfo(K1::R0) {}
