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
  AddrWrapper,
  BRCOND,
  CALL,
  COMP,
  FENCE,
  GetSystemReg,
  JT,
  JT_PCREL,
  SEXT_MUL,
  SZEXT_MUL,
  ZEXT_MUL,
  PICAddrWrapper,
  PICExternIndirection,
  PICInternIndirection,
  PICPCRelativeGOTAddr,
  RET,
  TAIL,
};
} // namespace KVXISD

class KVXTargetLowering : public TargetLowering {
  const KVXSubtarget &Subtarget;
  void initializeTCARegisters();
  void initializeTCALowering();
  SDValue lowerTCAZeroInit(SDValue Op, SelectionDAG &DAG) const;

public:
  explicit KVXTargetLowering(const TargetMachine &TM, const KVXSubtarget &STI);

  const char *getTargetNodeName(unsigned Opcode) const override;

  SDValue LowerOperation(SDValue Op, SelectionDAG &DAG) const override;

  bool shouldInsertFencesForAtomic(const Instruction *I) const override;

  Instruction *emitLeadingFence(IRBuilder<> &Builder, Instruction *Inst,
                                AtomicOrdering Ord) const override;
  Instruction *emitTrailingFence(IRBuilder<> &Builder, Instruction *Inst,
                                 AtomicOrdering Ord) const override;

  TargetLoweringBase::LegalizeTypeAction
  getPreferredVectorAction(MVT VT) const override;

  bool isZExtFree(SDValue Val, EVT VT2) const override;

  // FIXME: These should be thought through
  // Returns true if the target allows unaligned memory accesses of the
  // specified type.
  bool allowsMisalignedMemoryAccesses(
      EVT VT, unsigned AddrSpace = 0, unsigned Align = 1,
      MachineMemOperand::Flags Flags = MachineMemOperand::MONone,
      bool *Fast = nullptr) const override {
    if (Fast)
      *Fast = (Align >= 32);
    return true;
  }
  // LLT variant.
  bool allowsMisalignedMemoryAccesses(LLT Ty, unsigned AddrSpace,
                                      Align Alignment,
                                      MachineMemOperand::Flags Flags,
                                      bool *Fast = nullptr) const override {
    if (Fast)
      *Fast = (Alignment >= Align(32));
    return true;
  }

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
  SDValue lowerMULHVectorGeneric(SDValue Op, SelectionDAG &DAG,
                                 bool Signed) const;
  SDValue lowerBlockAddress(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerBUILD_VECTOR(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerBUILD_VECTOR_V2_64bit(SDValue Op, SelectionDAG &DAG,
                                     bool useINSF = true) const;
  SDValue lowerBUILD_VECTOR_V4_128bit(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerINSERT_VECTOR_ELT(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerINSERT_VECTOR_ELT_V4_128bit(SDLoc &DL, SelectionDAG &DAG,
                                           SDValue Vec, SDValue Val,
                                           uint64_t index) const;
  SDValue lowerINSERT_VECTOR_ELT_64bit_elt(SDLoc &DL, SelectionDAG &DAG,
                                           SDValue Vec, SDValue val,
                                           uint64_t index) const;
  SDValue lowerEXTRACT_VECTOR_ELT(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerEXTRACT_VECTOR_ELT_REGISTER(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerCONCAT_VECTORS(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerBR_CC(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerJumpTable(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerADDRSPACECAST(SDValue Op, SelectionDAG &DAG) const;

  SDValue lowerStackCheckAlloca(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerSTORE(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerMulExtend(const unsigned Opcode, SDValue Op,
                         SelectionDAG &DAG) const;

  SDValue lowerIntToFP(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerATOMIC_FENCE(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerATOMIC_LOAD_OP(SDValue Op, SelectionDAG &DAG) const;

  bool IsEligibleForTailCallOptimization(
      CCState &CCInfo, CallLoweringInfo &CLI, MachineFunction &MF,
      const SmallVector<CCValAssign, 16> &ArgsLocs) const;

  Register getRegisterByName(const char *RegName, LLT Ty,
                             const MachineFunction &MF) const override;
  std::pair<unsigned, const TargetRegisterClass *>
  getRegForInlineAsmConstraint(const TargetRegisterInfo *TRI,
                               StringRef Constraint, MVT VT) const override;
  ConstraintType getConstraintType(StringRef Constraint) const override;

  unsigned getComparisonCondition(ISD::CondCode CCOpcode) const;
  unsigned getBranchCondition(ISD::CondCode CCOpcode, bool Word) const;

  SDValue PerformDAGCombine(SDNode *N, DAGCombinerInfo &DCI) const override;

  void ReplaceNodeResults(SDNode *N, SmallVectorImpl<SDValue> &Results,
                          SelectionDAG &DAG) const override;

  // Return true if the addressing mode represented by AM is legal for this
  // target, for a load/store of the specified type.
  bool isLegalAddressingMode(const DataLayout &DL, const AddrMode &AM, Type *Ty,
                             unsigned AS,
                             Instruction *I = nullptr) const override;
  bool isLegalStoreImmediate(int64_t Imm) const override;
  bool isStoreBitCastBeneficial(EVT StoreVT, EVT BitcastVT,
                                const SelectionDAG &DAG,
                                const MachineMemOperand &MMO) const override;
  bool isOpFree(const SDNode *) const override;
  bool isTruncateFree(Type *SrcTy, Type *DstTy) const override;
  bool isTruncateFree(EVT SrcVT, EVT DstVT) const override;
  bool isFMAFasterThanFMulAndFAdd(const MachineFunction &MF,
                                  EVT VT) const override;

  bool isFMAFasterThanFMulAndFAdd(const Function &F, Type *) const override;

  bool hasAndNot(SDValue X) const override;
  bool enableAggressiveFMAFusion(EVT VT) const override;
  bool isCheapToSpeculateCttz() const override { return true; }

  bool isCheapToSpeculateCtlz() const override { return true; }

  bool isCtlzFast() const override { return true; }

  // TODO: This does not affect vectors. Should do the
  // same for xor/and instructions in patterns.
  bool hasBitPreservingFPLogic(EVT VT) const override {
    return VT == MVT::f16 || VT == MVT::f32 || VT == MVT::f64;
  }
};

} // namespace llvm

namespace KVX_LOW {
llvm::SDValue buildImmVector(llvm::SDNode &N, llvm::SelectionDAG &CurDag,
                             bool IsFp = false, unsigned long Negative = 0);

bool isImmVecOfLeqNbits(llvm::SDNode *N, llvm::SelectionDAG *CurDag,
                        unsigned short B);

bool isKVXSplat32ImmVec(llvm::SDNode *N, llvm::SelectionDAG *CurDag,
                        bool SplatAT);

bool isExtended(llvm::SDNode *N, llvm::SelectionDAG *CurDag, bool SignExt);
} // namespace KVX_LOW

#endif
