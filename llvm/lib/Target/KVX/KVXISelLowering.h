//==-- KVXISelLowering.h - KVX DAG Lowering Interface ------------*- C++ -*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines the interfaces that KVX uses to lower LLVM code into a
// selection DAG.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_KVX_KVXISELLOWERING_H
#define LLVM_LIB_TARGET_KVX_KVXISELLOWERING_H

#include "KVX.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include "llvm/CodeGen/TargetLowering.h"

// KVXISD = KVX Instruction Selection DAG

namespace llvm {

class KVXSubtarget;

namespace KVXISD {
enum NodeType : unsigned {
  FIRST_NUMBER = ISD::BUILTIN_OP_END,
  RET,
  CALL,
  AddrWrapper,
  SELECT_CC,
  TAIL,
  GetSystemReg,
  PICInternIndirection,
  PICExternIndirection,
  PICPCRelativeGOTAddr,
  PICAddrWrapper,
  COMP,
  BRCOND,
  JT,
  JT_PCREL
};
} // namespace KVXISD

class KVXTargetLowering : public TargetLowering {
  const KVXSubtarget &Subtarget;

public:
  explicit KVXTargetLowering(const TargetMachine &TM, const KVXSubtarget &STI);

  const char *getTargetNodeName(unsigned Opcode) const override;

  SDValue LowerOperation(SDValue Op, SelectionDAG &DAG) const override;

  bool shouldInsertFencesForAtomic(const Instruction *I) const override {
    return isa<LoadInst>(I) || isa<StoreInst>(I);
  }

  Instruction *emitLeadingFence(IRBuilder<> &Builder, Instruction *Inst,
                                AtomicOrdering Ord) const override;
  Instruction *emitTrailingFence(IRBuilder<> &Builder, Instruction *Inst,
                                 AtomicOrdering Ord) const override;

private:
  SDValue LowerFormalArguments(SDValue Chain, CallingConv::ID CallConv,
                               bool IsVarArg,
                               const SmallVectorImpl<ISD::InputArg> &Ins,
                               const SDLoc &DL, SelectionDAG &DAG,
                               SmallVectorImpl<SDValue> &InVals) const override;
  bool CanLowerReturn(CallingConv::ID CallConv, MachineFunction &MF,
                      bool IsVarArg,
                      const SmallVectorImpl<ISD::OutputArg> &Outs,
                      LLVMContext &Context) const override;
  SDValue LowerReturn(SDValue Chain, CallingConv::ID CallConv, bool IsVarArg,
                      const SmallVectorImpl<ISD::OutputArg> &Outs,
                      const SmallVectorImpl<SDValue> &OutVals, const SDLoc &DL,
                      SelectionDAG &DAG) const override;

  SDValue LowerCall(TargetLowering::CallLoweringInfo &CLI,
                    SmallVectorImpl<SDValue> &InVals) const override;

  EVT getSetCCResultType(const DataLayout &DL, LLVMContext &Context,
                         EVT VT) const override;

  unsigned getNumRegistersForCallingConv(LLVMContext &Context,
                                         CallingConv::ID CC, EVT VT) const
      override;
  MVT getRegisterTypeForCallingConv(LLVMContext &Context, CallingConv::ID CC,
                                    EVT VT) const override;
  unsigned getVectorTypeBreakdownForCallingConv(LLVMContext &Context,
                                                CallingConv::ID CC, EVT VT,
                                                EVT &IntermediateVT,
                                                unsigned &NumIntermediates,
                                                MVT &RegisterVT) const override;

  SDValue lowerRETURNADDR(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerGlobalAddress(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerGlobalTLSAddress(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerVASTART(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerVAARG(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerFRAMEADDR(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerFSUB(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerSELECT(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerMULHVectorGeneric(SDValue Op, SelectionDAG &DAG,
                                 bool Signed) const;
  SDValue lowerBlockAddress(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerBUILD_VECTOR(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerBUILD_VECTOR_V2_32bit(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerBUILD_VECTOR_V2_64bit(SDValue Op, SelectionDAG &DAG,
                                     bool useINSF = true) const;
  SDValue lowerBUILD_VECTOR_V4_128bit(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerINSERT_VECTOR_ELT(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerINSERT_VECTOR_ELT_V4_128bit(SDLoc &DL, SelectionDAG &DAG,
                                           SDValue Vec, SDValue Val,
                                           uint64_t index) const;
  SDValue lowerINSERT_VECTOR_ELT_V2_128bit(SDLoc &DL, SelectionDAG &DAG,
                                           SDValue Vec, SDValue val,
                                           uint64_t index) const;
  SDValue lowerEXTRACT_VECTOR_ELT(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerEXTRACT_VECTOR_ELT_REGISTER(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerCONCAT_VECTORS(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerShiftVectorial(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerBR_CC(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerJumpTable(SDValue Op, SelectionDAG &DAG) const;

  bool canLowerToMINMAXWP(SDValue Op) const;
  SDValue lowerMINMAXWP(SDValue Op, SelectionDAG &DAG) const;
  bool canLowerToABSWP(SDValue Op) const;
  SDValue lowerABSWP(SDValue Op, SelectionDAG &DAG) const;

  bool canLowerShiftVectorial(SDValue Op) const;

  bool canLowerToMINMAXHQ(SDValue Op) const;
  bool canLowerToMINMAXUHQ(SDValue Op) const;
  bool canLowerToABSHQ(SDValue Op) const;
  SDValue lowerMINMAXHQ(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerMINMAXUHQ(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerABSHQ(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerIntToFP(SDValue Op, SelectionDAG &DAG) const;

  bool IsEligibleForTailCallOptimization(
      CCState &CCInfo, CallLoweringInfo &CLI, MachineFunction &MF,
      const SmallVector<CCValAssign, 16> &ArgsLocs) const;

  std::pair<unsigned, const TargetRegisterClass *>
  getRegForInlineAsmConstraint(const TargetRegisterInfo *TRI,
                               StringRef Constraint, MVT VT) const override;

  unsigned getComparisonCondition(ISD::CondCode CCOpcode) const;
  unsigned getBranchCondition(ISD::CondCode CCOpcode, bool Word) const;

  SDValue PerformDAGCombine(SDNode *N, DAGCombinerInfo &DCI) const override;
};

} // namespace llvm

#endif
