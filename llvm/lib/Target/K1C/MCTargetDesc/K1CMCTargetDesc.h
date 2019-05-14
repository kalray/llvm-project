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

#ifndef LLVM_LIB_TARGET_K1C_MCTARGETDESC_K1CMCTARGETDESC_H
#define LLVM_LIB_TARGET_K1C_MCTARGETDESC_K1CMCTARGETDESC_H

#include "llvm/Config/config.h"
#include "llvm/MC/MCTargetOptions.h"
#include "llvm/Support/DataTypes.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {
Target &getTheK1CTarget();
} // namespace llvm

#define GET_REGINFO_ENUM
#include "K1CGenRegisterInfo.inc"

#define GET_INSTRINFO_ENUM
#include "K1CGenInstrInfo.inc"

#endif // LLVM_LIB_TARGET_K1C_MCTARGETDESC_K1CMCTARGETDESC_H
