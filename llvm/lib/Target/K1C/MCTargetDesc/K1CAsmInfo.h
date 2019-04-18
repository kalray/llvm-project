#ifndef LLVM_LIB_TARGET_K1C_MCTARGETDESC_K1CMCASMINFO_H
#define LLVM_LIB_TARGET_K1C_MCTARGETDESC_K1CMCASMINFO_H

#include "llvm/MC/MCAsmInfoELF.h"

namespace llvm {
class Triple;

class K1CMCAsmInfo : public MCAsmInfoELF {
  void anchor() override;

public:
  explicit K1CMCAsmInfo(const Triple &TargetTriple);
};

} // namespace llvm

#endif