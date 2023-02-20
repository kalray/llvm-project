//===- KVXGenDFAPacketizer.cpp - KVX Instruction Information ----*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains KVXGenInstrInfo.inc and KVXGenDFAPacketizer.inc
//
//===----------------------------------------------------------------------===//

#include "KVXInstrInfo.h"
#include "KVXSubtarget.h"

using namespace llvm;

#define GET_INSTRINFO_CTOR_DTOR
#include "KVXGenDFAPacketizer.inc"
#include "KVXGenInstrInfo.inc"
