#ifndef LLVM_LIB_TARGET_K1_MCTARGETDESC_K1MCTARGETDESC_H
#define LLVM_LIB_TARGET_K1_MCTARGETDESC_K1MCTARGETDESC_H

#include "llvm/Config/config.h"
#include "llvm/MC/MCTargetOptions.h"
#include "llvm/Support/DataTypes.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm
{
Target& getTheK1Target();
} // end llvm namespace

#define GET_REGINFO_ENUM
#include "K1GenRegisterInfo.inc"

#define GET_INSTRINFO_ENUM
#include "K1GenInstrInfo.inc"

#endif // LLVM_LIB_TARGET_K1_MCTARGETDESC_K1MCTARGETDESC_H