//===- K1CInstrInfo.h - K1C Instruction Information -------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the K1C implementation of the TargetInstrInfo class.
//
//===----------------------------------------------------------------------===//

#include "K1CInstrInfo.h"
#include "K1C.h"
#include "K1CTargetMachine.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/RegisterScavenging.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/TargetRegistry.h"

#define GET_INSTRINFO_CTOR_DTOR
#include "K1CGenInstrInfo.inc"

using namespace llvm;

K1CInstrInfo::K1CInstrInfo()
    : K1CGenInstrInfo(K1C::ADJCALLSTACKDOWN, K1C::ADJCALLSTACKUP) {}
