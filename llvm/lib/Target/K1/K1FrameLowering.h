#ifndef LLVM_LIB_TARGET_RISCV_RISCVFRAMELOWERING_H
#define LLVM_LIB_TARGET_RISCV_RISCVFRAMELOWERING_H

#include "llvm/CodeGen/TargetFrameLowering.h"

namespace llvm {

class K1FrameLowering : public TargetFrameLowering {
public:
  explicit K1FrameLowering()
      : TargetFrameLowering(StackGrowsDown,
                            /*StackAlignment=*/16,
                            /*LocalAreaOffset=*/0) {}
};
}
#endif
