//=- K1CMachineFunctionInfo.h - K1C machine function info ---------*- C++ -*-=//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares K1C-specific per-machine-function information.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_K1C_K1CMACHINEFUNCTIONINFO_H
#define LLVM_LIB_TARGET_K1C_K1CMACHINEFUNCTIONINFO_H

#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/SelectionDAGNodes.h"

namespace llvm {

/// K1CMachineFunctionInfo - This class is derived from MachineFunctionInfo
/// and contains private K1C-specific information for each MachineFunction.
class K1CMachineFunctionInfo : public MachineFunctionInfo {
private:
  /// FrameIndex for start of varargs area
  int VarArgsFrameIndex = 0;
  /// Size of the save area used for varargs
  unsigned VarArgsSaveSize = 0;
  /// Max size of outgoing args
  unsigned OutgoingArgsMaxSize = 0;
  // Arguments passed in memory size
  unsigned MemArgsSaveSize = 0;
  /// Min-max index for CSR
  std::pair<int, int> CSRIndices = { 0, 0 };
  // SRET register
  unsigned SRETReg;

public:
  //  K1CMachineFunctionInfo() = default;

  K1CMachineFunctionInfo(MachineFunction &MF) {}

  int getVarArgsFrameIndex() const { return VarArgsFrameIndex; }
  void setVarArgsFrameIndex(int Index) { VarArgsFrameIndex = Index; }

  unsigned getVarArgsSaveSize() const { return VarArgsSaveSize; }
  void setVarArgsSaveSize(unsigned Size) { VarArgsSaveSize = Size; }

  unsigned getOutgoingArgsMaxSize() const { return OutgoingArgsMaxSize; }
  void setOutgoingArgsMaxSize(unsigned Size) {
    if (Size > OutgoingArgsMaxSize)
      OutgoingArgsMaxSize = Size;
  }

  unsigned getMemArgsSaveSize() const { return MemArgsSaveSize; }
  void setMemArgsSaveSize(unsigned Size) { MemArgsSaveSize = Size; }

  const std::pair<int, int> &getCSRIndices() const { return CSRIndices; }
  void setCSRIndices(const std::pair<int, int> &Indices) {
    CSRIndices = Indices;
  }

  unsigned getSRETReg() { return SRETReg; }
  void setSRETReg(unsigned Reg) { SRETReg = Reg; }
};

} // end namespace llvm

#endif // LLVM_LIB_TARGET_K1C_K1CMACHINEFUNCTIONINFO_H
