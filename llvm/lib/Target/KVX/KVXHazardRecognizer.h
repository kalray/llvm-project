//===- KVXHazardRecognizer.h - KVX Hazard Recognizer ----------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// KVXHazardRecognizer: instance of ScoreboardHazardRecognizer that handles
// properly dependent multi-stage reservations for the specific case of having
// all reservations at cycle 0 of an instruction
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_KVX_KVXHAZARDRECOGNIZER_H
#define LLVM_LIB_TARGET_KVX_KVXHAZARDRECOGNIZER_H

#include "llvm/CodeGen/ScoreboardHazardRecognizer.h"
#include "llvm/MC/MCInstrItineraries.h"

namespace llvm {
class KVXHazardRecognizer : public ScoreboardHazardRecognizer {
public:
  KVXHazardRecognizer(const InstrItineraryData *II, const ScheduleDAG *DAG,
                      const char *ParentDebugType = "")
      : ScoreboardHazardRecognizer(II, DAG, ParentDebugType) {}

private:
  // Activates handling of dependent multi-stage reservations
  bool shouldUpdateBetweenStages() const override { return true; }
};
} // namespace llvm

#endif
