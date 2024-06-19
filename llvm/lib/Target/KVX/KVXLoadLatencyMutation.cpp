//===- KVXLoadLatencyMutation.cpp - Mutation for load latency ------------===//
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

#include "KVXLoadLatencyMutation.h"
#include "KVXInstrInfo.h"
#include "llvm/CodeGen/ScheduleDAGInstrs.h"

#define DEBUG_TYPE "machine-scheduler"
#define OUR_PREFIX "KVXLoadLatencyMutation: "
#define OUR_DEBUG(BLOCK) LLVM_DEBUG(dbgs() << OUR_PREFIX; BLOCK dbgs() << "\n";)
#define ODEBUG(expr) LLVM_DEBUG(dbgs() << OUR_PREFIX << expr << "\n")

namespace llvm {

void KVXLoadLatencyMutation::apply(ScheduleDAGInstrs *DAG) {
  auto *KII = (const KVXInstrInfo *)DAG->TII;

  for (SUnit &SU : DAG->SUnits) {
    const MachineInstr *MI = SU.getInstr();
    if (!KII->isUncachedLoad(MI))
      continue;

    OUR_DEBUG({
      dbgs() << "Detected an uncached load: ";
      MI->dump();
    });

    for (SDep &DataDep : SU.Succs) {
      if (DataDep.getKind() != SDep::Data)
        continue;
      unsigned Latency = DataDep.getLatency();
      Latency += KII->getUncachedPenalty();
      ODEBUG("\tSetting edge latency to " << Latency);
      DataDep.setLatency(Latency);
    }
  }
}

} // namespace llvm
