//=- KVXMachineFunctionInfo.h - KVX machine function info ---------*- C++ -*-=//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares KVX-specific per-machine-function information.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_KVX_KVXMACHINEFUNCTIONINFO_H
#define LLVM_LIB_TARGET_KVX_KVXMACHINEFUNCTIONINFO_H

#include "KVXSubtarget.h"
#include "llvm/CodeGen/MachineFunction.h"

namespace llvm {

/// KVXMachineFunctionInfo - This class is derived from MachineFunctionInfo
/// and contains private KVX-specific information for each MachineFunction.
class KVXMachineFunctionInfo : public MachineFunctionInfo {
private:
  /// FrameIndex for start of varargs area
  int VarArgsFrameIndex = 0;
  /// Size of the save area used for varargs
  unsigned VarArgsSaveSize = 0;
  /// Min-max index for callee saved frame indexes
  std::pair<int, int> MinMaxCSFrameIndexes = {0, 0};
  // FP index
  unsigned FPIndex = 0;
  // SRET register
  unsigned SRETReg;
  // SP is dynamically realigned
  bool AdjustLocalAreaSP = false;

  unsigned MaxAlignment = 0;

  Register AdjustedSP;

  MachineBasicBlock *OverflowMBB = nullptr;

public:
  KVXMachineFunctionInfo(const Function &MF, const KVXSubtarget *STI) {}

  MachineBasicBlock *getOverflowMBB() { return OverflowMBB; }
  void setOverflowMBB(MachineBasicBlock *MBB) { OverflowMBB = MBB; }

  int getVarArgsFrameIndex() const { return VarArgsFrameIndex; }
  void setVarArgsFrameIndex(int Index) { VarArgsFrameIndex = Index; }

  unsigned getVarArgsSaveSize() const { return VarArgsSaveSize; }
  void setVarArgsSaveSize(unsigned Size) { VarArgsSaveSize = Size; }

  const std::pair<int, int> &getMinMaxCSFrameIndexes() const {
    return MinMaxCSFrameIndexes;
  }
  void setMinMaxCSFrameIndexes(const std::pair<int, int> &Indexes) {
    MinMaxCSFrameIndexes = Indexes;
  }

  unsigned getFPIndex() const { return FPIndex; }
  void setFPIndex(unsigned FI) { FPIndex = FI; }

  unsigned getMaxAlignment() const { return MaxAlignment; }
  void setMaxAlignment(unsigned Align) {
    MaxAlignment = std::max(Align, MaxAlignment);
  }

  bool isAdjustLocalAreaSP() const { return AdjustLocalAreaSP; }
  void setAdjustLocalAreaSP(bool Adjust) { AdjustLocalAreaSP = Adjust; }

  unsigned getSRETReg() { return SRETReg; }
  void setSRETReg(unsigned Reg) { SRETReg = Reg; }

  unsigned getAdjustedSP() const { return AdjustedSP; }
  void setAdjustedSP(unsigned Reg) { AdjustedSP = Reg; }

  MachineFunctionInfo *clone(BumpPtrAllocator &Allocator, MachineFunction &DestMF,
      const DenseMap<MachineBasicBlock *, MachineBasicBlock *> &Src2DstMBB) const override {
        return DestMF.cloneInfo<KVXMachineFunctionInfo>(*this);
  }
};

} // end namespace llvm

#endif // LLVM_LIB_TARGET_KVX_KVXMACHINEFUNCTIONINFO_H
