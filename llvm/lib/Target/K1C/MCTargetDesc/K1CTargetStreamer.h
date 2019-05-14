//===-- K1CTargetStreamer.h - K1C Target Streamer --------------*- C++ -*--===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_K1C_K1CTARGETSTREAMER_H
#define LLVM_LIB_TARGET_K1C_K1CTARGETSTREAMER_H

#include "llvm/MC/MCStreamer.h"
#include "llvm/Support/FormattedStream.h"

namespace llvm {

class K1CTargetStreamer : public MCTargetStreamer {
  formatted_raw_ostream &OS;

public:
  K1CTargetStreamer(MCStreamer &S, formatted_raw_ostream &OS);
};

} // namespace llvm
#endif
