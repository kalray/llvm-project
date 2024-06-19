//===- KVXLoadLatencyMutation.h - Mutation for load latency --------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Uncached memory loads have a higher best-case latency than cached loads
// although they use the same instruction.
//
// Since this differentiation is done by a modifier (an operand on a load
// instruction), we do not have an easy way to modify the latency from TableGen
//
// To handle this, we apply a ScheduleDAGMutation that scans the DAG and
// updates the load latencies accordingly.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_KVX_KVXLOADLATENCYMUTATION_H
#define LLVM_LIB_TARGET_KVX_KVXLOADLATENCYMUTATION_H

#include "llvm/CodeGen/ScheduleDAGMutation.h"

#include <memory>

namespace llvm {
class KVXLoadLatencyMutation : public ScheduleDAGMutation {
public:
  KVXLoadLatencyMutation() {}
  void apply(ScheduleDAGInstrs *DAG) override;
};

inline std::unique_ptr<ScheduleDAGMutation> createKVXLoadLatencyMutation() {
  return std::make_unique<KVXLoadLatencyMutation>();
}

} // namespace llvm

#endif
