//===-- K1CTargetStreamer.h - K1C Target Streamer --------------*- C++ -*--===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "K1CTargetStreamer.h"
#include "llvm/Support/FormattedStream.h"

using namespace llvm;

K1CTargetStreamer::K1CTargetStreamer(MCStreamer &S, formatted_raw_ostream &OS)
    : MCTargetStreamer(S), OS(OS) {}
