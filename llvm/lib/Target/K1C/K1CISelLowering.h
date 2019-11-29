//==-- K1CISelLowering.h - K1C DAG Lowering Interface ------------*- C++ -*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines the interfaces that K1C uses to lower LLVM code into a
// selection DAG.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_K1C_K1CISELLOWERING_H
#define LLVM_LIB_TARGET_K1C_K1CISELLOWERING_H

#include "K1C.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include "llvm/CodeGen/TargetLowering.h"

// K1CISD = K1C Instruction Selection DAG

namespace llvm {

class K1CSubtarget;

namespace K1CISD {
enum NodeType : unsigned {
  FIRST_NUMBER = ISD::BUILTIN_OP_END,
  RET,
  CALL,
  WRAPPER,
  SELECT_CC,
  TAIL,
  PICInternIndirection,
  PICExternIndirection,
  PICPCRelativeGOTAddr,
  PICWRAPPER,
  FENCE,
  DINVAL
};
} // namespace K1CISD

class K1CTargetLowering : public TargetLowering {
  const K1CSubtarget &Subtarget;

public:
  explicit K1CTargetLowering(const TargetMachine &TM, const K1CSubtarget &STI);

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

  SDValue lowerGlobalAddress(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerGlobalTLSAddress(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerVASTART(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerVAARG(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerFRAMEADDR(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerSELECT(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerMULHV4I16(SDValue Op, SelectionDAG &DAG, bool Signed) const;
  SDValue lowerBlockAddress(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerINTRINSIC_VOID(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerBUILD_VECTOR(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerBUILD_VECTOR_V2_32bit(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerBUILD_VECTOR_V2_64bit(SDValue Op, SelectionDAG &DAG,
                                     bool useINSF = true) const;
  SDValue lowerBUILD_VECTOR_V4_128bit(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerINSERT_VECTOR_ELT(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerINSERT_VECTOR_ELT_V4_128bit(SDLoc &DL, SelectionDAG &DAG,
                                           SDValue Vec, SDValue Val,
                                           uint64_t index) const;
  SDValue lowerEXTRACT_VECTOR_ELT(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerEXTRACT_VECTOR_ELT_REGISTER(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerEXTRACT_VECTOR_ELT_V2_32bit(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerEXTRACT_VECTOR_ELT_TDPATTERN(SDValue Op,
                                            SelectionDAG &DAG) const;

  bool IsEligibleForTailCallOptimization(
      CCState &CCInfo, CallLoweringInfo &CLI, MachineFunction &MF,
      const SmallVector<CCValAssign, 16> &ArgsLocs) const;

  std::pair<unsigned, const TargetRegisterClass *>
  getRegForInlineAsmConstraint(const TargetRegisterInfo *TRI,
                               StringRef Constraint, MVT VT) const override;
};

} // namespace llvm

#endif
