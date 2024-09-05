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
  EH_SJLJ_LONGJMP,        // SjLj exception handling longjmp.
  EH_SJLJ_SETJMP,         // SjLj exception handling setjump.
  EH_SJLJ_SETUP_DISPATCH, // SjLj exception handling setup_dispatch.
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
  SRS,
  SRSNEG,
  VECREDUCE_ADD_SEXT,
  VECREDUCE_ADD_ZEXT,
  SZ_MUL,
};
} // namespace KVXISD

class KVXTargetLowering : public TargetLowering {
  const KVXSubtarget &Subtarget;
  void initializeTCARegisters();
  void initializeTCALowering();
  SDValue lowerTCAZeroInit(SDValue Op, SelectionDAG &DAG) const;

public:
  typedef std::map<MVT, StringRef> LibCalls;

  explicit KVXTargetLowering(const TargetMachine &TM, const KVXSubtarget &STI);

  const char *getTargetNodeName(unsigned Opcode) const override;

  SDValue LowerOperation(SDValue Op, SelectionDAG &DAG) const override;

  TargetLoweringBase::LegalizeTypeAction
  getPreferredVectorAction(MVT VT) const override;

  bool isZExtFree(SDValue Val, EVT VT2) const override;

  // FIXME: These should be thought through
  // Returns true if the target allows unaligned memory accesses of the
  // specified type.
bool allowsMisalignedMemoryAccesses(
      EVT VT, unsigned AddrSpace, Align Alignment,
      MachineMemOperand::Flags Flags,
      unsigned * Fast) const override {
    if (Fast)
      *Fast = (Alignment.value() >= VT.getStoreSize());
    return true;
  }

  // LLT variant.
    virtual bool allowsMisalignedMemoryAccesses(
      LLT VT, unsigned AddrSpace, Align Alignment,
      MachineMemOperand::Flags Flags,
      unsigned * Fast) const override {
    if (Fast)
      *Fast = (Alignment >= VT.getSizeInBytes());

    return true;
  }

  bool decomposeMulByConstant(LLVMContext &Context, EVT VT,
                              SDValue C) const override {
    return false;
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

  SDValue lowerBUILD_VECTOR_128bit(SDValue Op, SelectionDAG &DAG) const;
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

  bool isCheapToSpeculateCttz(Type *Ty) const override {
    auto Sz = Ty->getScalarSizeInBits();
    return (32 <= Sz) && (64 >= Sz);
  }

  bool isCheapToSpeculateCtlz(Type *Ty) const override {
    auto Sz = Ty->getScalarSizeInBits();
    return (32 <= Sz) && (64 >= Sz);
  }

  bool isCtlzFast() const override { return true; }

  bool shouldReplaceBy(SDNode *From, unsigned ToOpcode,
                       SmallVector<SDValue> ConcatOps = {}) const override;

  // For scalar types we reduce one instruction, as we do not require
  // to materialize the constant -1.
  bool shouldFoldMaskToVariableShiftPair(SDValue VT) const override {
    return !VT.getValueType().isVector();
  }

  SDValue LowerINTRINSIC(SDValue Op, SelectionDAG &DAG,
                         const KVXSubtarget *Subtarget, bool HasChain) const;
  MachineBasicBlock *
  EmitInstrWithCustomInserter(MachineInstr &MI,
                              MachineBasicBlock *MBB) const override;

  MachineBasicBlock *emitEHSjLjLongJmp(MachineInstr &MI,
                                       MachineBasicBlock *MBB) const;
  MachineBasicBlock *emitEHSjLjSetJmp(MachineInstr &MI,
                                      MachineBasicBlock *MBB) const;
  MachineBasicBlock *emitEHSjLjSetupDispatch(MachineInstr &MI,
                                             MachineBasicBlock *MBB) const;

  InlineAsm::ConstraintCode getInlineAsmMemConstraint(StringRef ConstraintCode) const override;

  bool isExtractVecEltCheap(EVT VT, unsigned Index) const override;

  SDValue BuildSDIVPow2(SDNode *N, const APInt &Divisor, SelectionDAG &DAG,
                        SmallVectorImpl<SDNode *> &Created) const override;

  MVT getScalarShiftAmountTy(const DataLayout &, EVT) const override {
    return MVT::i32;
  }

  EVT getShiftAmountTy(EVT LHSTy, const DataLayout &DL,
                       bool LegalTypes = true) const {
    if (LHSTy.isVector())
      return LHSTy.changeVectorElementTypeToInteger();

    return EVT(MVT::i32);
  }

  LLT getPreferredShiftAmountTy(LLT ShiftValueTy) const override {
    if (ShiftValueTy.isVector())
      return ShiftValueTy;

    return LLT(MVT::i32);
  }

  MVT getVectorIdxTy(const DataLayout &DL) const override { return MVT::i64; }

  bool isVectorShiftByScalarCheap(Type *Ty) const override { return true; }

  bool hasPairedLoad(EVT VT, Align &Alg) const override;

  bool mergeStoresAfterLegalization(EVT MemVT) const override {
    return MemVT.getScalarType() != MVT::i1;
  }
  SDValue expandVecLibCall(const LibCalls &Funcs, SDValue &Node, bool IsSigned,
                           SelectionDAG &DAG,
                           const bool CanTailCall = true) const;
  SDValue expandDivRemLibCall(const LibCalls &Funcs, SDValue &Node,
                              bool IsSigned, SelectionDAG &DAG,
                              bool PackReminder = false) const;
  SDValue combineIntDivAlike(SDNode *N, SelectionDAG &Dag) const;

  bool shouldSplitVecBinOp(const unsigned Opc, const EVT VT) const override;
  bool shouldProduceDivRem(const unsigned Opc, const EVT VT) const override;
  bool mayBeEmittedAsTailCall(const CallInst *CI) const override {
    return CI->isTailCall();
  }

  bool isUsedByReturnOnly(SDNode *, SDValue & /*Chain*/) const override;

  // Control extending atomics operations  at IR level:
  bool shouldInsertFencesForAtomic(const Instruction *I) const override;

  Instruction *emitLeadingFence(IRBuilderBase &Builder, Instruction *Inst,
                                AtomicOrdering Ord) const override;
  Instruction *emitTrailingFence(IRBuilderBase &Builder, Instruction *Inst,
                                 AtomicOrdering Ord) const override;

  AtomicExpansionKind
  shouldExpandAtomicRMWInIR(AtomicRMWInst *RMW) const override;
};

} // namespace llvm

namespace KVX_LOW {
uint64_t getImmVector(const llvm::BuildVectorSDNode *BV,
                      const llvm::SelectionDAG *CurDag,
                      unsigned long Negative = 0,
                      bool AllowRepeatExtend = false);

llvm::SDValue buildImmVector(const llvm::SDNode &N, llvm::SelectionDAG &CurDag,
                             unsigned long Negative = 0,
                             bool AllowRepeatExtend = false);

llvm::SDValue buildImmSplat(const llvm::SDNode &N, llvm::SelectionDAG &CurDag);

llvm::SDValue buildFdotImm(llvm::SDNode &N, llvm::SelectionDAG &CurDag,
                           bool SwapLoHi = false, unsigned long Negative = 0);

// N must be a splat build_vector, i.e. one that verifies isSplatBuildVec
llvm::SDValue extractSplatNode(const llvm::SDNode *N,
                               const llvm::SelectionDAG *CurDag);

bool isImmVecOfLeqNbits(llvm::SDNode *N, llvm::SelectionDAG *CurDag,
                        unsigned short B);

// Checks that N is a (build_vector x0 x1 ...) where x0 = x1 = ...
// Additionally, if ImmSizeCheck > 0, it checks that:
//   1) All operands are constant
//   2) The immediate encoding the build_vector fits in ImmSizeCheck bits
bool isSplatBuildVec(const llvm::SDNode *N, const llvm::SelectionDAG *CurDag,
                     unsigned ImmSizeCheck = 0);

bool isKVXSplat32ImmVec(llvm::SDNode *N, llvm::SelectionDAG *CurDag,
                        bool SplatAT, bool Negate = false);

bool isExtended(llvm::SDNode *N, llvm::SelectionDAG *CurDag, bool SignExt);
} // namespace KVX_LOW

#endif
