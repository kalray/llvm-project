//===-- K1CISelLowering.cpp - K1C DAG Lowering Implementation  ------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the K1CTargetLowering class.
//
//===----------------------------------------------------------------------===//

#include "K1CISelLowering.h"
#include "K1C.h"
#include "K1CMachineFunctionInfo.h"
#include "K1CTargetMachine.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/CodeGen/CallingConvLower.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"
#include "llvm/CodeGen/ValueTypes.h"
#include "llvm/IR/DiagnosticInfo.h"
#include "llvm/IR/DiagnosticPrinter.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

#define DEBUG_TYPE "K1CISelLowering"

STATISTIC(NumTailCalls, "Number of tail calls");

#include "K1CGenCallingConv.inc"

static bool CC_SRET_K1C(unsigned ValNo, MVT ValVT, MVT LocVT,
                        CCValAssign::LocInfo LocInfo, ISD::ArgFlagsTy ArgFlags,
                        CCState &State) {
  if (ArgFlags.isSRet()) {
    if (unsigned Reg = State.AllocateReg(K1C::R15)) {
      State.addLoc(CCValAssign::getReg(ValNo, ValVT, Reg, LocVT, LocInfo));
      return false;
    }
    return true;
  }

  return CC_K1C(ValNo, ValVT, LocVT, LocInfo, ArgFlags, State);
}

K1CTargetLowering::K1CTargetLowering(const TargetMachine &TM,
                                     const K1CSubtarget &STI)
    : TargetLowering(TM), Subtarget(STI) {

  (void)Subtarget;
  // set up the register classes
  addRegisterClass(MVT::i32, &K1C::SingleRegRegClass);
  addRegisterClass(MVT::i64, &K1C::SingleRegRegClass);
  addRegisterClass(MVT::v2i16, &K1C::SingleRegRegClass);
  addRegisterClass(MVT::v2i32, &K1C::SingleRegRegClass);
  addRegisterClass(MVT::v4i16, &K1C::SingleRegRegClass);
  addRegisterClass(MVT::v2i16, &K1C::SingleRegRegClass);

  addRegisterClass(MVT::f16, &K1C::SingleRegRegClass);
  addRegisterClass(MVT::f32, &K1C::SingleRegRegClass);
  addRegisterClass(MVT::f64, &K1C::SingleRegRegClass);
  addRegisterClass(MVT::v4f16, &K1C::SingleRegRegClass);
  addRegisterClass(MVT::v2f16, &K1C::SingleRegRegClass);
  addRegisterClass(MVT::v2f32, &K1C::SingleRegRegClass);
  addRegisterClass(MVT::v4f32, &K1C::PairedRegRegClass);

  // Compute derived properties from the register classes
  computeRegisterProperties(STI.getRegisterInfo());

  setStackPointerRegisterToSaveRestore(getSPReg());

  setSchedulingPreference(Sched::Source);

  setOperationAction(ISD::SDIV, MVT::i32, Promote);
  setOperationAction(ISD::SDIVREM, MVT::i32, Promote);
  setOperationAction(ISD::SREM, MVT::i32, Promote);
  setOperationAction(ISD::UDIV, MVT::i32, Promote);
  setOperationAction(ISD::UDIVREM, MVT::i32, Promote);
  setOperationAction(ISD::UREM, MVT::i32, Promote);

  setOperationAction(ISD::SDIV, MVT::i64, Expand);
  setOperationAction(ISD::SDIVREM, MVT::i64, Expand);
  setOperationAction(ISD::SREM, MVT::i64, Expand);
  setOperationAction(ISD::UDIV, MVT::i64, Expand);
  setOperationAction(ISD::UDIVREM, MVT::i64, Expand);
  setOperationAction(ISD::UREM, MVT::i64, Expand);

  setOperationAction(ISD::MULHU, MVT::v4i16, Custom);
  setOperationAction(ISD::MULHS, MVT::v4i16, Custom);

  setLoadExtAction(ISD::ZEXTLOAD, MVT::v2i32, MVT::v2i16, Expand);
  setLoadExtAction(ISD::EXTLOAD, MVT::v2i32, MVT::v2i16, Expand);
  setLoadExtAction(ISD::SEXTLOAD, MVT::v2i32, MVT::v2i16, Expand);

  setLoadExtAction(ISD::ZEXTLOAD, MVT::v2i32, MVT::v2i8, Expand);
  setLoadExtAction(ISD::EXTLOAD, MVT::v2i32, MVT::v2i8, Expand);
  setLoadExtAction(ISD::SEXTLOAD, MVT::v2i32, MVT::v2i8, Expand);

  setLoadExtAction(ISD::ZEXTLOAD, MVT::v4i16, MVT::v4i8, Expand);
  setLoadExtAction(ISD::EXTLOAD, MVT::v4i16, MVT::v4i8, Expand);
  setLoadExtAction(ISD::SEXTLOAD, MVT::v4i16, MVT::v4i8, Expand);

  setTruncStoreAction(MVT::v2i32, MVT::v2i16, Expand);
  setTruncStoreAction(MVT::v2i32, MVT::v2i8, Expand);
  setTruncStoreAction(MVT::v4i16, MVT::v4i8, Expand);

  setOperationAction(ISD::TRUNCATE, MVT::v2i16, Expand);
  setOperationAction(ISD::EXTRACT_SUBVECTOR, MVT::v2i16, Expand);

  setOperationAction(ISD::AND, MVT::v8i8, Expand);
  setOperationAction(ISD::OR, MVT::v8i8, Expand);
  setOperationAction(ISD::XOR, MVT::v8i8, Expand);

  setOperationAction(ISD::SIGN_EXTEND_INREG, MVT::v2i16, Expand);
  setOperationAction(ISD::SIGN_EXTEND_INREG, MVT::v2i32, Expand);

  setOperationAction(ISD::BUILD_VECTOR, MVT::v2i16, Custom);
  setOperationAction(ISD::BUILD_VECTOR, MVT::v2f16, Custom);

  setOperationAction(ISD::EXTRACT_VECTOR_ELT, MVT::v2f16, Custom);
  setOperationAction(ISD::EXTRACT_VECTOR_ELT, MVT::v2i16, Custom);

  for (auto VT : {MVT::v2i32, MVT::v4i16, MVT::v2i16, MVT::v4f32}) {
    setOperationAction(ISD::UDIV, VT, Expand);
    setOperationAction(ISD::SDIV, VT, Expand);
    setOperationAction(ISD::VECTOR_SHUFFLE, VT, Expand);
    setOperationAction(ISD::SCALAR_TO_VECTOR, VT, Expand);

    setOperationAction(ISD::SETCC, VT, Expand);

    setOperationAction(ISD::SDIV, VT, Expand);
    setOperationAction(ISD::SDIVREM, VT, Expand);
    setOperationAction(ISD::SREM, VT, Expand);
    setOperationAction(ISD::UDIV, VT, Expand);
    setOperationAction(ISD::UDIVREM, VT, Expand);
    setOperationAction(ISD::UREM, VT, Expand);
    setOperationAction(ISD::SHL, VT, Expand);
    setOperationAction(ISD::SRL, VT, Expand);
    setOperationAction(ISD::SRA, VT, Expand);
  }

  setOperationAction(ISD::INSERT_VECTOR_ELT, MVT::v4i16, Expand);
  setOperationAction(ISD::INSERT_VECTOR_ELT, MVT::v2i32, Custom);
  setOperationAction(ISD::INSERT_VECTOR_ELT, MVT::v2f32, Custom);
  setOperationAction(ISD::INSERT_VECTOR_ELT, MVT::v4f32, Custom);
  setOperationAction(ISD::EXTRACT_VECTOR_ELT, MVT::v2i32, Custom);
  setOperationAction(ISD::EXTRACT_VECTOR_ELT, MVT::v2f32, Custom);
  setOperationAction(ISD::EXTRACT_VECTOR_ELT, MVT::v2i16, Custom);
  setOperationAction(ISD::EXTRACT_VECTOR_ELT, MVT::v4i16, Expand);
  setOperationAction(ISD::EXTRACT_VECTOR_ELT, MVT::v4f32, Custom);

  setOperationAction(ISD::INSERT_VECTOR_ELT, MVT::v2i16, Custom);
  setOperationAction(ISD::INSERT_VECTOR_ELT, MVT::v2f16, Custom);

  setOperationAction(ISD::EXTRACT_SUBVECTOR, MVT::v2f32, Expand);

  setOperationAction(ISD::MULHU, MVT::v2i32, Expand);
  setOperationAction(ISD::MULHS, MVT::v2i32, Expand);

  for (auto VT : {MVT::v2f32, MVT::v4f16, MVT::v4f32}) {
    setOperationAction(ISD::FDIV, VT, Expand);
    setOperationAction(ISD::VECTOR_SHUFFLE, VT, Expand);
    setOperationAction(ISD::SCALAR_TO_VECTOR, VT, Expand);
  }
  setOperationAction(ISD::INSERT_VECTOR_ELT, MVT::v4f16, Expand);
  setOperationAction(ISD::EXTRACT_VECTOR_ELT, MVT::v4f16, Expand);
  setOperationAction(ISD::EXTRACT_VECTOR_ELT, MVT::v2f16, Expand);
  setOperationAction(ISD::EXTRACT_VECTOR_ELT, MVT::v2f32, Custom);

  for (auto VT : { MVT::i32, MVT::i64 }) {
    setOperationAction(ISD::SMUL_LOHI, VT, Expand);
    setOperationAction(ISD::UMUL_LOHI, VT, Expand);
    setOperationAction(ISD::MULHS, VT, Expand);
    setOperationAction(ISD::MULHU, VT, Expand);

    setOperationAction(ISD::SELECT_CC, VT, Expand);
    setOperationAction(ISD::SELECT, VT, Custom);

    setOperationAction(ISD::BR_CC, VT, Expand);

    setOperationAction(ISD::BSWAP, VT, Expand);

    setOperationAction(ISD::CTPOP, VT, Expand);
  }
  setOperationAction(ISD::ROTL, MVT::i64, Expand);
  setOperationAction(ISD::ROTR, MVT::i64, Expand);

  setOperationAction(ISD::BlockAddress, MVT::i64, Custom);
  setOperationAction(ISD::GlobalAddress, MVT::i64, Custom);
  setOperationAction(ISD::GlobalTLSAddress, MVT::i64, Custom);
  setOperationAction(ISD::VASTART, MVT::Other, Custom);
  setOperationAction(ISD::VAARG, MVT::Other, Custom);
  setOperationAction(ISD::VACOPY, MVT::Other, Expand);
  setOperationAction(ISD::VAEND, MVT::Other, Expand);

  setOperationAction(ISD::STACKSAVE, MVT::Other, Expand);
  setOperationAction(ISD::STACKRESTORE, MVT::Other, Expand);
  setOperationAction(ISD::DYNAMIC_STACKALLOC, MVT::i64, Expand);

  setOperationAction(ISD::BR_JT, MVT::Other, Expand);

  for (unsigned im = (unsigned)ISD::PRE_INC;
       im != (unsigned)ISD::LAST_INDEXED_MODE; ++im) {
    setIndexedLoadAction(im, MVT::i32, Legal);
    setIndexedStoreAction(im, MVT::i32, Legal);
  }

  for (auto VT : { MVT::f16, MVT::f32, MVT::f64 }) {
    setOperationAction(ISD::ConstantFP, VT, Legal);

    setOperationAction(ISD::FABS, VT, Legal);
    setOperationAction(ISD::FNEG, VT, Legal);
    setOperationAction(ISD::BR_CC, VT, Expand);

    setOperationAction(ISD::FDIV, VT, VT == MVT::f16 ? Promote : Expand);
    setOperationAction(ISD::FREM, VT, VT == MVT::f16 ? Promote : Expand);
    setOperationAction(ISD::FSQRT, VT, VT == MVT::f16 ? Promote : Expand);
    setOperationAction(ISD::FSIN, VT, VT == MVT::f16 ? Promote : Expand);
    setOperationAction(ISD::FCOS, VT, VT == MVT::f16 ? Promote : Expand);

    setOperationAction(ISD::SELECT_CC, VT, Expand);
    setOperationAction(ISD::SELECT, VT, Custom);
  }

  for (MVT VT : MVT::fp_valuetypes()) {
    setLoadExtAction(ISD::EXTLOAD, VT, MVT::f16, Expand);
    setLoadExtAction(ISD::EXTLOAD, VT, MVT::f32, Expand);
    setLoadExtAction(ISD::EXTLOAD, VT, MVT::f64, Expand);
  }

  for (auto VT : {MVT::v2i32, MVT::v2f32, MVT::v4f32}) {
    setOperationAction(ISD::BUILD_VECTOR, VT, Custom);
  }

  setMaxAtomicSizeInBitsSupported(64);
  setMinCmpXchgSizeInBits(32);

  setOperationAction(ISD::INTRINSIC_VOID, MVT::Other, Custom);

  // Effectively disable jump table generation.
  setMinimumJumpTableEntries(INT_MAX);
}

EVT K1CTargetLowering::getSetCCResultType(const DataLayout &DL, LLVMContext &C,
                                          EVT VT) const {
  if (!VT.isVector())
    return MVT::i32;
  return EVT::getVectorVT(C, MVT::i32, VT.getVectorNumElements());
}

const char *K1CTargetLowering::getTargetNodeName(unsigned Opcode) const {
  switch (Opcode) {
  case K1CISD::RET:
    return "K1C::RET";
  case K1CISD::CALL:
    return "K1C::CALL";
  case K1CISD::WRAPPER:
    return "K1C::WRAPPER";
  case K1CISD::SELECT_CC:
    return "K1C::SELECT_CC";
  case K1CISD::PICInternIndirection:
    return "K1C::PICInternIndirection";
  case K1CISD::PICExternIndirection:
    return "K1C::PICExternIndirection";
  case K1CISD::PICPCRelativeGOTAddr:
    return "K1C::PICPCRelativeGOTAddr";
  case K1CISD::TAIL:
    return "K1C::TAIL";
  case K1CISD::FENCE:
    return "K1C::FENCE";
  case K1CISD::DINVAL:
    return "K1C::DINVAL";
  default:
    return NULL;
  }
}

bool K1CTargetLowering::CanLowerReturn(
    CallingConv::ID CallConv, MachineFunction &MF, bool IsVarArg,
    const SmallVectorImpl<ISD::OutputArg> &Outs, LLVMContext &Context) const {

  return true;
}

SDValue
K1CTargetLowering::LowerReturn(SDValue Chain, CallingConv::ID CallConv,
                               bool IsVarArg,
                               const SmallVectorImpl<ISD::OutputArg> &Outs,
                               const SmallVectorImpl<SDValue> &OutVals,
                               const SDLoc &DL, SelectionDAG &DAG) const {

  SmallVector<CCValAssign, 16> RVLocs;

  CCState CCInfo(CallConv, IsVarArg, DAG.getMachineFunction(), RVLocs,
                 *DAG.getContext());

  CCInfo.AnalyzeReturn(Outs, RetCC_K1C);

  SDValue Flag;
  SmallVector<SDValue, 4> RetOps(1, Chain);

  for (unsigned int i = 0; i != RVLocs.size(); ++i) {
    CCValAssign &VA = RVLocs[i];
    assert(VA.isRegLoc() && "Can only return in registers!");
    SDValue Arg = OutVals[i];
    Chain = DAG.getCopyToReg(Chain, DL, VA.getLocReg(), Arg, Flag);
    Flag = Chain.getValue(1);
    RetOps.push_back(DAG.getRegister(VA.getLocReg(), VA.getLocVT()));
  }

  RetOps[0] = Chain; // Update chain.

  return DAG.getNode(K1CISD::RET, DL, MVT::Other, RetOps);
}

static const MCPhysReg ArgGPRs[] = { K1C::R0, K1C::R1, K1C::R2,  K1C::R3,
                                     K1C::R4, K1C::R5, K1C::R6,  K1C::R7,
                                     K1C::R8, K1C::R9, K1C::R10, K1C::R11 };

SDValue K1CTargetLowering::LowerFormalArguments(
    SDValue Chain, CallingConv::ID CallConv, bool IsVarArg,
    const SmallVectorImpl<ISD::InputArg> &Ins, const SDLoc &DL,
    SelectionDAG &DAG, SmallVectorImpl<SDValue> &InVals) const {

  switch (CallConv) {
  default:
    report_fatal_error("Unsupported calling convention");
  case CallingConv::C:
  case CallingConv::Fast:
  case CallingConv::SPIR_KERNEL:
    break;
  }

  MachineFunction &MF = DAG.getMachineFunction();
  MachineRegisterInfo &RegInfo = MF.getRegInfo();
  std::vector<SDValue> OutChains;

  SmallVector<CCValAssign, 16> ArgLocs;
  CCState CCInfo(CallConv, IsVarArg, DAG.getMachineFunction(), ArgLocs,
                 *DAG.getContext());
  CCInfo.AnalyzeFormalArguments(Ins, CC_SRET_K1C);

  unsigned MemArgsSaveSize = 0;

  for (auto &VA : ArgLocs) {
    if (VA.isRegLoc()) {
      EVT RegVT = VA.getLocVT();

      unsigned VReg;
      if (VA.getValVT() == MVT::v4f32)
        VReg = RegInfo.createVirtualRegister(&K1C::PairedRegRegClass);
      else
        VReg = RegInfo.createVirtualRegister(&K1C::SingleRegRegClass);
      RegInfo.addLiveIn(VA.getLocReg(), VReg);
      SDValue ArgIn = DAG.getCopyFromReg(Chain, DL, VReg, RegVT);

      InVals.push_back(ArgIn);
      continue;
    }

    assert(VA.isMemLoc());

    unsigned Offset = VA.getLocMemOffset();
    int FI = MF.getFrameInfo().CreateFixedObject(8, Offset, false);
    InVals.push_back(
        DAG.getLoad(VA.getValVT(), DL, Chain,
                    DAG.getFrameIndex(FI, getPointerTy(MF.getDataLayout())),
                    MachinePointerInfo::getFixedStack(MF, FI)));

    MemArgsSaveSize += 8;
  }

  K1CMachineFunctionInfo *K1CFI = MF.getInfo<K1CMachineFunctionInfo>();

  if (IsVarArg) {
    ArrayRef<MCPhysReg> ArgRegs = makeArrayRef(ArgGPRs);
    unsigned Idx = CCInfo.getFirstUnallocated(ArgRegs);
    int VarArgsOffset = CCInfo.getNextStackOffset();
    int VarArgsSaveSize = 0;
    MachineFrameInfo &MFI = MF.getFrameInfo();
    const unsigned ArgRegsSize = ArgRegs.size();
    int FI;

    if (Idx >= ArgRegsSize) {
      FI = MFI.CreateFixedObject(8, VarArgsOffset, true);
      MemArgsSaveSize += 8;
    } else {
      FI = -(int)(MFI.getNumFixedObjects() + 1);
      VarArgsOffset = (Idx - ArgRegs.size()) * 8;
      VarArgsSaveSize = -VarArgsOffset;
    }

    K1CFI->setVarArgsFrameIndex(FI);
    K1CFI->setVarArgsSaveSize(VarArgsSaveSize);

    // Copy the integer registers that may have been used for passing varargs
    // to the vararg save area.
    for (unsigned I = Idx; I < ArgRegs.size(); ++I, VarArgsOffset += 8) {
      const unsigned Reg =
          RegInfo.createVirtualRegister(&K1C::SingleRegRegClass);
      RegInfo.addLiveIn(ArgRegs[I], Reg);
      SDValue ArgValue = DAG.getCopyFromReg(Chain, DL, Reg, MVT::i64);
      int FI = MFI.CreateFixedObject(8, VarArgsOffset, true);
      SDValue PtrOff = DAG.getFrameIndex(FI, getPointerTy(DAG.getDataLayout()));
      SDValue Store = DAG.getStore(Chain, DL, ArgValue, PtrOff,
                                   MachinePointerInfo::getFixedStack(MF, FI));
      OutChains.push_back(Store);
    }
  }

  K1CFI->setMemArgsSaveSize(MemArgsSaveSize);

  // All stores are grouped in one node to allow the matching between
  // the size of Ins and InVals. This only happens for vararg functions.
  if (!OutChains.empty()) {
    OutChains.push_back(Chain);
    Chain = DAG.getNode(ISD::TokenFactor, DL, MVT::Other, OutChains);
  }

  return Chain;
}

SDValue K1CTargetLowering::LowerCall(CallLoweringInfo &CLI,
                                     SmallVectorImpl<SDValue> &InVals) const {
  SelectionDAG &DAG = CLI.DAG;
  SDLoc &DL = CLI.DL;
  SmallVectorImpl<ISD::OutputArg> &Outs = CLI.Outs;
  SmallVectorImpl<SDValue> &OutVals = CLI.OutVals;
  SmallVectorImpl<ISD::InputArg> &Ins = CLI.Ins;
  SDValue Chain = CLI.Chain;
  SDValue Callee = CLI.Callee;
  bool &IsTailCall = CLI.IsTailCall;
  CallingConv::ID CallConv = CLI.CallConv;
  bool isVarArg = CLI.IsVarArg;
  EVT PtrVT = getPointerTy(DAG.getDataLayout());
  MachineFunction &MF = DAG.getMachineFunction();
  K1CMachineFunctionInfo *FuncInfo = MF.getInfo<K1CMachineFunctionInfo>();

  // Analyze operands of the call, assigning locations to each operand.
  SmallVector<CCValAssign, 16> ArgLocs;
  CCState CCInfo(CallConv, isVarArg, DAG.getMachineFunction(), ArgLocs,
                 *DAG.getContext());
  CCInfo.AnalyzeCallOperands(Outs, CC_SRET_K1C);

  if (IsTailCall)
    IsTailCall = IsEligibleForTailCallOptimization(CCInfo, CLI, MF, ArgLocs);

  if (IsTailCall)
    ++NumTailCalls;
  else if (CLI.CS && CLI.CS.isMustTailCall())
    report_fatal_error("failed to perform tail call elimination on a call"
                       "site marked musttail");

  // Get the size of the outgoing arguments stack space requirement.
  unsigned ArgsSize = CCInfo.getNextStackOffset();

  // Keep stack frames 8-byte aligned.
  ArgsSize = (ArgsSize + 7) & ~7;

  // Create local copies for byval args
  SmallVector<SDValue, 8> ByValArgs;
  for (unsigned i = 0, e = Outs.size(); i != e; ++i) {
    ISD::ArgFlagsTy Flags = Outs[i].Flags;
    if (!Flags.isByVal())
      continue;

    SDValue Arg = OutVals[i];
    unsigned Size = Flags.getByValSize();
    unsigned Align = Flags.getByValAlign();

    int FI = MF.getFrameInfo().CreateStackObject(Size, Align, /*isSS=*/false);
    SDValue FIPtr = DAG.getFrameIndex(FI, getPointerTy(DAG.getDataLayout()));
    SDValue SizeNode = DAG.getConstant(Size, DL, MVT::i64);

    Chain = DAG.getMemcpy(Chain, DL, FIPtr, Arg, SizeNode, Align,
                          /*IsVolatile=*/false,
                          /*AlwaysInline=*/false, false /*IsTailCall*/,
                          MachinePointerInfo(), MachinePointerInfo());
    ByValArgs.push_back(FIPtr);
  }

  if (!IsTailCall)
    Chain = DAG.getCALLSEQ_START(Chain, ArgsSize, 0, DL);

  SmallVector<std::pair<unsigned, SDValue>, 8> RegsToPass;
  SmallVector<SDValue, 8> MemOpChains;
  SDValue StackPtr;

  for (unsigned i = 0, j = 0, e = ArgLocs.size(); i != e; ++i) {
    CCValAssign &VA = ArgLocs[i];
    SDValue ArgValue = OutVals[i];
    ISD::ArgFlagsTy Flags = Outs[i].Flags;

    if (Flags.isByVal())
      ArgValue = ByValArgs[j++];

    if (VA.isRegLoc()) {
      // Queue up the argument copies and emit them at the end.
      RegsToPass.push_back(std::make_pair(VA.getLocReg(), ArgValue));
    } else {
      assert(VA.isMemLoc() && "Argument not register or memory");
      assert(!IsTailCall && "Tail call not allowed if stack is used "
                            "for passing parameters");

      // Work out the address of the stack slot.
      if (!StackPtr.getNode())
        StackPtr = DAG.getCopyFromReg(Chain, DL, getSPReg(), PtrVT);

      // Create a store off the stack pointer for this argument.
      SDValue PtrOff = DAG.getIntPtrConstant(VA.getLocMemOffset(), DL);
      PtrOff = DAG.getNode(ISD::ADD, DL, MVT::i64, StackPtr, PtrOff);
      MemOpChains.push_back(
          DAG.getStore(Chain, DL, ArgValue, PtrOff, MachinePointerInfo()));
    }
  }

  FuncInfo->setOutgoingArgsMaxSize(ArgsSize);

  // Join the stores, which are independent of one another.
  if (!MemOpChains.empty())
    Chain = DAG.getNode(ISD::TokenFactor, DL, MVT::Other, MemOpChains);

  SDValue Glue;

  // Build a sequence of copy-to-reg nodes, chained and glued together.
  for (auto &Reg : RegsToPass) {
    Chain = DAG.getCopyToReg(Chain, DL, Reg.first, Reg.second, Glue);
    Glue = Chain.getValue(1);
  }

  if (ExternalSymbolSDNode *S = dyn_cast<ExternalSymbolSDNode>(Callee)) {
    Callee = DAG.getTargetExternalSymbol(S->getSymbol(), PtrVT, 0);
  }

  SmallVector<SDValue, 8> Ops;
  Ops.push_back(Chain);
  Ops.push_back(Callee);
  for (auto &Reg : RegsToPass)
    Ops.push_back(DAG.getRegister(Reg.first, Reg.second.getValueType()));

  if (!IsTailCall) {
    // Add a register mask operand representing the call-preserved registers.
    const TargetRegisterInfo *TRI = Subtarget.getRegisterInfo();
    const uint32_t *Mask = TRI->getCallPreservedMask(MF, CallConv);
    assert(Mask && "Missing call preserved mask for calling convention");
    Ops.push_back(DAG.getRegisterMask(Mask));
  }

  // Glue the call to the argument copies, if any.
  if (Glue.getNode())
    Ops.push_back(Glue);

  // Emit the call.
  SDVTList NodeTys = DAG.getVTList(MVT::Other, MVT::Glue);

  if (IsTailCall) {
    MF.getFrameInfo().setHasTailCall();
    return DAG.getNode(K1CISD::TAIL, DL, NodeTys, Ops);
  }

  Chain = DAG.getNode(K1CISD::CALL, DL, NodeTys, Ops);
  Glue = Chain.getValue(1);

  // Mark the end of the call, which is glued to the call itself.
  Chain = DAG.getCALLSEQ_END(Chain, DAG.getConstant(ArgsSize, DL, PtrVT, true),
                             DAG.getConstant(0, DL, PtrVT, true), Glue, DL);
  Glue = Chain.getValue(1);

  // Assign locations to each value returned by this call.
  SmallVector<CCValAssign, 16> RVLocs;
  CCState RetCCInfo(CallConv, CLI.IsVarArg, MF, RVLocs, *DAG.getContext());
  RetCCInfo.AnalyzeCallResult(Ins, RetCC_K1C);
  // analyzeInputArgs(MF, RetCCInfo, Ins, /*IsRet=*/true);

  // Copy all of the result registers out of their specified physreg.
  for (auto &VA : RVLocs) {
    // Copy the value out
    SDValue RetValue =
        DAG.getCopyFromReg(Chain, DL, VA.getLocReg(), VA.getLocVT(), Glue);
    // Glue the RetValue to the end of the call sequence
    Chain = RetValue.getValue(1);
    Glue = RetValue.getValue(2);

    InVals.push_back(RetValue);
  }

  return Chain;
}

SDValue K1CTargetLowering::LowerOperation(SDValue Op, SelectionDAG &DAG) const {
  switch (Op.getOpcode()) {
  default:
    report_fatal_error("unimplemented operand");
  case ISD::GlobalAddress:
    return lowerGlobalAddress(Op, DAG);
  case ISD::GlobalTLSAddress:
    return lowerGlobalTLSAddress(Op, DAG);
  case ISD::VASTART:
    return lowerVASTART(Op, DAG);
  case ISD::VAARG:
    return lowerVAARG(Op, DAG);
  case ISD::FRAMEADDR:
    return lowerFRAMEADDR(Op, DAG);
  case ISD::SELECT:
    return lowerSELECT(Op, DAG);
  case ISD::MULHS:
    return lowerMULHV4I16(Op, DAG, true);
  case ISD::MULHU:
    return lowerMULHV4I16(Op, DAG, false);
  case ISD::BlockAddress:
    return lowerBlockAddress(Op, DAG);
  case ISD::INTRINSIC_VOID:
    return lowerINTRINSIC_VOID(Op, DAG);
  case ISD::BUILD_VECTOR:
    return lowerBUILD_VECTOR(Op, DAG);
  case ISD::INSERT_VECTOR_ELT:
    return lowerINSERT_VECTOR_ELT(Op, DAG);
  case ISD::EXTRACT_VECTOR_ELT:
    return lowerEXTRACT_VECTOR_ELT(Op, DAG);
  }
}

Instruction *K1CTargetLowering::emitLeadingFence(IRBuilder<> &Builder,
                                                 Instruction *Inst,
                                                 AtomicOrdering Ord) const {
  if (isa<LoadInst>(Inst) && Ord == AtomicOrdering::SequentiallyConsistent)
    return Builder.CreateFence(Ord);
  if (isa<StoreInst>(Inst) && Ord != AtomicOrdering::Monotonic)
    return Builder.CreateFence(Ord);
  return nullptr;
}

Instruction *K1CTargetLowering::emitTrailingFence(IRBuilder<> &Builder,
                                                  Instruction *Inst,
                                                  AtomicOrdering Ord) const {
  if (isa<LoadInst>(Inst) && isAcquireOrStronger(Ord))
    return Builder.CreateFence(AtomicOrdering::Acquire);
  if (isa<StoreInst>(Inst) && Ord == AtomicOrdering::SequentiallyConsistent)
    return Builder.CreateFence(Ord);

  return nullptr;
}

SDValue K1CTargetLowering::lowerGlobalAddress(SDValue Op,
                                              SelectionDAG &DAG) const {
  LLVM_DEBUG(dbgs() << "== K1CTargetLowering::lowerGlobalAddress(Op, DAG)"
                    << '\n');
  LLVM_DEBUG(dbgs() << "Op: " << '\n'; Op.dump());
  LLVM_DEBUG(dbgs() << "DAG: " << '\n'; DAG.dump());

  SDLoc DL(Op);
  auto PtrVT = getPointerTy(DAG.getDataLayout());
  GlobalAddressSDNode *N = cast<GlobalAddressSDNode>(Op);
  const GlobalValue *GV = N->getGlobal();
  int64_t Offset = N->getOffset();
  SDValue Result;

  // -fPIC enabled
  if (isPositionIndependent()) {
    LLVM_DEBUG(dbgs() << "LT: " << GV->getLinkage()
                      << " isPrivate: " << GV->hasPrivateLinkage() << '\n');

    GlobalValue::LinkageTypes LT = GV->getLinkage();
    switch (LT) {
    case GlobalValue::CommonLinkage:
    case GlobalValue::ExternalLinkage: {
      LLVM_DEBUG(dbgs() << "@got(sym)[gaddr]" << '\n');

      SDValue GlobalSymbol = DAG.getTargetGlobalAddress(GV, DL, PtrVT);
      SDValue GOTAddr = DAG.getNode(K1CISD::PICPCRelativeGOTAddr, DL, PtrVT);

      // Indirect global symbol using GOT with
      // @got(GLOBALSYMBOL)[GOTADDR] asm macro.  Note: function
      // symbols don't need indirection since everything is handled by
      // the loader. Consequently, call indirections are ignored at
      // insn selection.
      SDValue DataPtr = DAG.getNode(K1CISD::PICExternIndirection, DL, PtrVT,
                                    GOTAddr, GlobalSymbol);

      if (Offset != 0)
        Result = DAG.getNode(ISD::ADD, DL, PtrVT, DataPtr,
                             DAG.getConstant(Offset, DL, PtrVT));
      else
        Result = DataPtr;

    } break;
    case GlobalValue::InternalLinkage:
    case GlobalValue::PrivateLinkage: {
      LLVM_DEBUG(dbgs() << "@gotoff(sym)" << '\n');

      SDValue GlobalSymbol = DAG.getTargetGlobalAddress(GV, DL, PtrVT);
      SDValue GOTAddr = DAG.getNode(K1CISD::PICPCRelativeGOTAddr, DL, PtrVT);

      // Indirect global symbol using GOT with @gotoff(GLOBALSYMBOL)
      // asm macro.
      SDValue DataPtr = DAG.getNode(K1CISD::PICInternIndirection, DL, PtrVT,
                                    GOTAddr, GlobalSymbol);

      if (Offset != 0)
        Result = DAG.getNode(ISD::ADD, DL, PtrVT, DataPtr,
                             DAG.getConstant(Offset, DL, PtrVT));
      else
        Result = DataPtr;

    } break;
    default:
      llvm_unreachable("Unsupported LinkageType");
    }
  } else {
    Result = DAG.getTargetGlobalAddress(GV, DL, PtrVT, 0);
    Result = DAG.getNode(K1CISD::WRAPPER, DL, PtrVT, Result);

    if (Offset != 0) {
      SDValue PtrOff = DAG.getIntPtrConstant(Offset, DL);
      Result = DAG.getNode(ISD::ADD, DL, MVT::i64, Result, PtrOff);
    }
  }

  LLVM_DEBUG(dbgs() << "Result: " << '\n'; Result.dump());
  return Result;
}

SDValue K1CTargetLowering::lowerGlobalTLSAddress(SDValue Op,
                                                 SelectionDAG &DAG) const {

  MachineFunction &MF = DAG.getMachineFunction();
  GlobalAddressSDNode *N = cast<GlobalAddressSDNode>(Op);
  const GlobalValue *GV = N->getGlobal();
  TLSModel::Model model = DAG.getTarget().getTLSModel(GV);

  switch (model) {
  default:
    if (MF.getSubtarget().getTargetTriple().isOSClusterOS())
      report_fatal_error("ClusterOS only supports TLS model LocalExec");
    else
      report_fatal_error("Unknown TLSModel");
  case TLSModel::LocalExec:
    SDLoc DL(Op);
    int64_t Offset = N->getOffset();
    EVT PtrVT = getPointerTy(DAG.getDataLayout());

    SDValue Result = DAG.getTargetGlobalAddress(GV, DL, PtrVT, Offset);
    Result = DAG.getNode(K1CISD::WRAPPER, DL, PtrVT, Result);
    Result = DAG.getNode(ISD::ADD, DL, PtrVT,
                         DAG.getRegister(K1C::R13, MVT::i64), Result);
    return Result;
  }

  return SDValue();
}

SDValue K1CTargetLowering::lowerVASTART(SDValue Op, SelectionDAG &DAG) const {
  MachineFunction &MF = DAG.getMachineFunction();
  K1CMachineFunctionInfo *FuncInfo = MF.getInfo<K1CMachineFunctionInfo>();

  SDLoc DL(Op);
  SDValue FI = DAG.getFrameIndex(FuncInfo->getVarArgsFrameIndex(),
                                 getPointerTy(MF.getDataLayout()));

  // vastart just stores the address of the VarArgsFrameIndex slot into the
  // memory location argument.
  const Value *SV = cast<SrcValueSDNode>(Op.getOperand(2))->getValue();
  return DAG.getStore(Op.getOperand(0), DL, FI, Op.getOperand(1),
                      MachinePointerInfo(SV));
}

SDValue K1CTargetLowering::lowerVAARG(SDValue Op, SelectionDAG &DAG) const {
  SDNode *Node = Op.getNode();
  EVT VT = Node->getValueType(0);
  SDValue InChain = Node->getOperand(0);
  SDValue VAListPtr = Node->getOperand(1);
  EVT PtrVT = VAListPtr.getValueType();
  const Value *SV = cast<SrcValueSDNode>(Node->getOperand(2))->getValue();
  SDLoc DL(Node);
  SDValue VAList =
      DAG.getLoad(PtrVT, DL, InChain, VAListPtr, MachinePointerInfo(SV));
  // Increment the pointer, VAList, to the next vaarg.
  // Increment va_list pointer to the next multiple of 64 bits / 8 bytes
  int increment = (VT.getSizeInBits() + 63) / 64 * 8;
  SDValue NextPtr = DAG.getNode(ISD::ADD, DL, PtrVT, VAList,
                                DAG.getIntPtrConstant(increment, DL));
  // Store the incremented VAList to the legalized pointer.
  InChain = DAG.getStore(VAList.getValue(1), DL, NextPtr, VAListPtr,
                         MachinePointerInfo(SV));
  // Load the actual argument out of the pointer VAList.
  // We can't count on greater alignment than the word size.
  return DAG.getLoad(VT, DL, InChain, VAList, MachinePointerInfo(), 8);
}

SDValue K1CTargetLowering::lowerFRAMEADDR(SDValue Op, SelectionDAG &DAG) const {
  MachineFunction &MF = DAG.getMachineFunction();
  MachineFrameInfo &MFI = MF.getFrameInfo();
  MFI.setFrameAddressIsTaken(true);
  unsigned FrameReg = getSPReg();
  int XLenInBytes = 8;

  EVT VT = Op.getValueType();
  SDLoc DL(Op);
  SDValue FrameAddr = DAG.getCopyFromReg(DAG.getEntryNode(), DL, FrameReg, VT);
  unsigned Depth = cast<ConstantSDNode>(Op.getOperand(0))->getZExtValue();
  while (Depth--) {
    int Offset = -(XLenInBytes * 2);
    SDValue Ptr = DAG.getNode(ISD::ADD, DL, VT, FrameAddr,
                              DAG.getIntPtrConstant(Offset, DL));
    FrameAddr =
        DAG.getLoad(VT, DL, DAG.getEntryNode(), Ptr, MachinePointerInfo());
  }
  return FrameAddr;
}

SDValue K1CTargetLowering::lowerSELECT(SDValue Op, SelectionDAG &DAG) const {

  SDValue CondV = Op.getOperand(0);
  SDValue TrueV = Op.getOperand(1);
  SDValue FalseV = Op.getOperand(2);
  SDLoc DL(Op);

  SDVTList VTs = DAG.getVTList(Op.getValueType());
  SDValue Zero = DAG.getConstant(0, DL, MVT::i64);
  SDValue Ops[] = { CondV, Zero, TrueV, FalseV };

  SDValue result = DAG.getNode(K1CISD::SELECT_CC, DL, VTs, Ops);

  return result;
}

SDValue K1CTargetLowering::lowerINTRINSIC_VOID(SDValue Op,
                                               SelectionDAG &DAG) const {
  unsigned IntNo = cast<ConstantSDNode>(Op.getOperand(1))->getZExtValue();
  SDLoc DL(Op);

  SDValue Chain = Op.getOperand(0);

  switch (IntNo) {
  default:
    return {}; // Don't custom lower most intrinsics.

  case Intrinsic::k1c_fence: {
    return DAG.getNode(K1CISD::FENCE, DL, MVT::Other, Chain);
  }
  case Intrinsic::k1c_dinval: {
    return DAG.getNode(K1CISD::DINVAL, DL, MVT::Other, Chain);
  }
  }
}

bool K1CTargetLowering::IsEligibleForTailCallOptimization(
    CCState &CCInfo, CallLoweringInfo &CLI, MachineFunction &MF,
    const SmallVector<CCValAssign, 16> &ArgsLocs) const {
  auto &Callee = CLI.Callee;
  auto CalleeCC = CLI.CallConv;
  auto IsVarArg = CLI.IsVarArg;
  auto &Outs = CLI.Outs;
  auto &Caller = MF.getFunction();
  auto CallerCC = Caller.getCallingConv();

  // Do not tail call opt functions with "disable-tail-calls" attribute.
  if (Caller.getFnAttribute("disable-tail-calls").getValueAsString() == "true")
    return false;

  // Do not tail call opt functions with varargs, unless arguments are all
  // passed in registers.
  if (IsVarArg)
    for (unsigned Idx = 0, End = ArgsLocs.size(); Idx != End; ++Idx)
      if (!ArgsLocs[Idx].isRegLoc())
        return false;

  // Do not tail call opt if the stack is used to pass parameters.
  if (CCInfo.getNextStackOffset() != 0)
    return false;

  // Do not tail call opt if either caller or callee uses struct return
  // semantics.
  auto IsCallerStructRet = Caller.hasStructRetAttr();
  auto IsCalleeStructRet = Outs.empty() ? false : Outs[0].Flags.isSRet();
  if (IsCallerStructRet || IsCalleeStructRet)
    return false;

  // Externally-defined functions with weak linkage should not be
  // tail-called. The behaviour of branch instructions in this situation (as
  // used for tail calls) is implementation-defined, so we cannot rely on the
  // linker replacing the tail call with a return.
  if (GlobalAddressSDNode *G = dyn_cast<GlobalAddressSDNode>(Callee)) {
    const GlobalValue *GV = G->getGlobal();
    if (GV->hasExternalWeakLinkage())
      return false;
  }

  // The callee has to preserve all registers the caller needs to preserve.
  if (CalleeCC != CallerCC) {
    const K1CRegisterInfo *TRI = Subtarget.getRegisterInfo();
    const uint32_t *CallerPreserved = TRI->getCallPreservedMask(MF, CallerCC);
    const uint32_t *CalleePreserved = TRI->getCallPreservedMask(MF, CalleeCC);
    if (!TRI->regmaskSubsetEqual(CallerPreserved, CalleePreserved))
      return false;
  }

  return true;
}

SDValue K1CTargetLowering::lowerBlockAddress(SDValue Op,
                                             SelectionDAG &DAG) const {
  BlockAddressSDNode *N = cast<BlockAddressSDNode>(Op);
  const BlockAddress *BA = N->getBlockAddress();
  int64_t Offset = N->getOffset();
  auto PtrVT = getPointerTy(DAG.getDataLayout());

  SDLoc DL(Op);

  SDValue Result = DAG.getTargetBlockAddress(BA, PtrVT, Offset);

  // -fPIC
  if (isPositionIndependent())
    Result = DAG.getNode(K1CISD::PICWRAPPER, DL, PtrVT, Result);
  else
    Result = DAG.getNode(K1CISD::WRAPPER, DL, PtrVT, Result);

  return Result;
}

#define GET_REGISTER_MATCHER
#include "K1CGenAsmMatcher.inc"

std::pair<unsigned, const TargetRegisterClass *>
K1CTargetLowering::getRegForInlineAsmConstraint(const TargetRegisterInfo *TRI,
                                                StringRef Constraint,
                                                MVT VT) const {
  if (Constraint.size() == 1) {
    switch (Constraint[0]) {
    case 'r':
      if (VT == MVT::i32 || VT == MVT::i64)
        return std::make_pair(0U, &K1C::SingleRegRegClass);
      llvm_unreachable("unsuported register type");
    default:
      break;
    }
  }
  if (Constraint.size() >= 4 && Constraint.front() == '{' &&
      Constraint.back() == '}') {
    StringRef regName = Constraint.substr(1, Constraint.size() - 2);
    unsigned RegNo = MatchRegisterName(regName);
    if (RegNo == 0) {
      RegNo = MatchRegisterAltName(regName);
    }
    if (K1C::SingleRegRegClass.contains(RegNo))
      return std::make_pair(RegNo, &K1C::SingleRegRegClass);
  }

  return TargetLowering::getRegForInlineAsmConstraint(TRI, Constraint, VT);
}

SDValue K1CTargetLowering::lowerMULHV4I16(SDValue Op, SelectionDAG &DAG,
                                          bool Signed) const {
  SDLoc DL(Op);

  ISD::NodeType ExtensionType = Signed ? ISD::SIGN_EXTEND : ISD::ZERO_EXTEND;

  SDValue A1 =
      DAG.getNode(ISD::EXTRACT_VECTOR_ELT, DL, MVT::i16,
                  {Op.getOperand(0), DAG.getConstant(0, DL, MVT::i64)});
  SDValue A1Ext = DAG.getNode(ExtensionType, DL, MVT::i32, A1);

  SDValue A2 =
      DAG.getNode(ISD::EXTRACT_VECTOR_ELT, DL, MVT::i16,
                  {Op.getOperand(0), DAG.getConstant(1, DL, MVT::i64)});
  SDValue A2Ext = DAG.getNode(ExtensionType, DL, MVT::i32, A2);

  SDValue A3 =
      DAG.getNode(ISD::EXTRACT_VECTOR_ELT, DL, MVT::i16,
                  {Op.getOperand(0), DAG.getConstant(2, DL, MVT::i64)});
  SDValue A3Ext = DAG.getNode(ExtensionType, DL, MVT::i32, A3);

  SDValue A4 =
      DAG.getNode(ISD::EXTRACT_VECTOR_ELT, DL, MVT::i16,
                  {Op.getOperand(0), DAG.getConstant(3, DL, MVT::i64)});
  SDValue A4Ext = DAG.getNode(ExtensionType, DL, MVT::i32, A4);

  SDValue B1 =
      DAG.getNode(ISD::EXTRACT_VECTOR_ELT, DL, MVT::i16,
                  {Op.getOperand(1), DAG.getConstant(0, DL, MVT::i64)});
  SDValue B1Ext = DAG.getNode(ExtensionType, DL, MVT::i32, B1);

  SDValue B2 =
      DAG.getNode(ISD::EXTRACT_VECTOR_ELT, DL, MVT::i16,
                  {Op.getOperand(1), DAG.getConstant(1, DL, MVT::i64)});
  SDValue B2Ext = DAG.getNode(ExtensionType, DL, MVT::i32, B2);

  SDValue B3 =
      DAG.getNode(ISD::EXTRACT_VECTOR_ELT, DL, MVT::i16,
                  {Op.getOperand(1), DAG.getConstant(2, DL, MVT::i64)});
  SDValue B3Ext = DAG.getNode(ExtensionType, DL, MVT::i32, B3);

  SDValue B4 =
      DAG.getNode(ISD::EXTRACT_VECTOR_ELT, DL, MVT::i16,
                  {Op.getOperand(1), DAG.getConstant(3, DL, MVT::i64)});
  SDValue B4Ext = DAG.getNode(ExtensionType, DL, MVT::i32, B4);

  // Multiplying each element and shifting it in order to keep only the most
  // significant 16 bits
  SDValue R1 = DAG.getNode(ISD::SRL, DL, MVT::i32,
                           DAG.getNode(ISD::MUL, DL, MVT::i32, {A1Ext, B1Ext}),
                           DAG.getConstant(16, DL, MVT::i32));
  SDValue R2 = DAG.getNode(ISD::SRL, DL, MVT::i32,
                           DAG.getNode(ISD::MUL, DL, MVT::i32, {A2Ext, B2Ext}),
                           DAG.getConstant(16, DL, MVT::i32));
  SDValue R3 = DAG.getNode(ISD::SRL, DL, MVT::i32,
                           DAG.getNode(ISD::MUL, DL, MVT::i32, {A3Ext, B3Ext}),
                           DAG.getConstant(16, DL, MVT::i32));
  SDValue R4 = DAG.getNode(ISD::SRL, DL, MVT::i32,
                           DAG.getNode(ISD::MUL, DL, MVT::i32, {A4Ext, B4Ext}),
                           DAG.getConstant(16, DL, MVT::i32));

  // Building a vector from the computed values
  return DAG.getNode(ISD::BUILD_VECTOR, DL, MVT::v4i16, {R1, R2, R3, R4});
}

SDValue K1CTargetLowering::lowerBUILD_VECTOR(SDValue Op,
                                             SelectionDAG &DAG) const {
  if (Op.getValueType() == MVT::v2f32 || Op.getValueType() == MVT::v2i32)
    return lowerBUILD_VECTOR_V2_64bit(Op, DAG);

  if (Op.getValueType() == MVT::v2i16 || Op.getValueType() == MVT::v2f16)
    return lowerBUILD_VECTOR_V2_32bit(Op, DAG);

  if (Op.getValueType() == MVT::v4f32)
    return lowerBUILD_VECTOR_V4_128bit(Op, DAG);

  llvm_unreachable("Unsupported lowering for this type!");
}

SDValue K1CTargetLowering::lowerBUILD_VECTOR_V2_32bit(SDValue Op,
                                                      SelectionDAG &DAG) const {
  SDLoc DL(Op);

  SDValue Op1 = Op.getOperand(0);
  SDValue Op2 = Op.getOperand(1);

  uint64_t Op1Val;
  uint64_t Op2Val;

  bool IsOp1Const = false;
  bool IsOp2Const = false;

  if (isa<ConstantSDNode>(Op1)) {
    auto *Op1Const = dyn_cast<ConstantSDNode>(Op1);
    Op1Val = Op1Const->getZExtValue();
    IsOp1Const = true;
  } else if (isa<ConstantFPSDNode>(Op1)) {
    auto *Op1Const = dyn_cast<ConstantFPSDNode>(Op1);
    Op1Val = Op1Const->getValueAPF().bitcastToAPInt().getZExtValue();
    IsOp1Const = true;
  }

  if (isa<ConstantSDNode>(Op2)) {
    auto *Op2Const = dyn_cast<ConstantSDNode>(Op2);
    Op2Val = Op2Const->getZExtValue();
    IsOp2Const = true;
  } else if (isa<ConstantFPSDNode>(Op2)) {
    auto *Op2Const = dyn_cast<ConstantFPSDNode>(Op2);
    Op2Val = Op2Const->getValueAPF().bitcastToAPInt().getZExtValue();
    IsOp2Const = true;
  }

  // imm imm
  if (IsOp1Const && IsOp2Const) {
    uint64_t R = ((Op2Val << 16) | (Op1Val & 0xFFFF));

    return DAG.getBitcast(Op.getValueType(), DAG.getConstant(R, DL, MVT::i32));
  } else {
    return SDValue(
        DAG.getMachineNode(K1C::INSF, DL, Op.getValueType(),
                           {Op1, Op2, DAG.getTargetConstant(31, DL, MVT::i64),
                            DAG.getTargetConstant(16, DL, MVT::i64)}),
        0);
  }
}

SDValue K1CTargetLowering::lowerBUILD_VECTOR_V2_64bit(SDValue Op,
                                                      SelectionDAG &DAG,
                                                      bool useINSF) const {
  SDLoc DL(Op);

  if (Op.isUndef())
    return Op;

  SDValue Op1 = Op.getOperand(0);
  SDValue Op2 = Op.getOperand(1);

  bool IsOp1Const = false;
  bool IsOp2Const = false;

  uint64_t Op1Val;
  uint64_t Op2Val;

  if (isa<ConstantSDNode>(Op1)) {
    auto *Op1Const = dyn_cast<ConstantSDNode>(Op1);
    Op1Val = Op1Const->getZExtValue();
    IsOp1Const = true;
  } else if (isa<ConstantFPSDNode>(Op1)) {
    auto *Op1Const = dyn_cast<ConstantFPSDNode>(Op1);
    Op1Val = Op1Const->getValueAPF().bitcastToAPInt().getZExtValue();
    IsOp1Const = true;
  }

  if (isa<ConstantSDNode>(Op2)) {
    auto *Op2Const = dyn_cast<ConstantSDNode>(Op2);
    Op2Val = Op2Const->getZExtValue();
    IsOp2Const = true;
  } else if (isa<ConstantFPSDNode>(Op2)) {
    auto *Op2Const = dyn_cast<ConstantFPSDNode>(Op2);
    Op2Val = Op2Const->getValueAPF().bitcastToAPInt().getZExtValue();
    IsOp2Const = true;
  }

  if (IsOp1Const && IsOp2Const) { // imm imm
    uint64_t R = ((Op2Val << 32) | (Op1Val & 0xFFFFFFFF));

    return DAG.getBitcast(Op.getValueType(), DAG.getConstant(R, DL, MVT::i64));
  } else if (IsOp1Const) { // imm reg
    Op1Val &= 0xFFFFFFFF;

    SDValue ShiftedOp2 = DAG.getNode(
        ISD::SHL, DL, MVT::i64,
        {SDValue(DAG.getMachineNode(TargetOpcode::COPY, DL, MVT::i64,
                                    DAG.getBitcast(MVT::i32, Op2)),
                 0),
         DAG.getConstant(32, DL, MVT::i32)});

    return DAG.getBitcast(
        Op.getValueType(),
        DAG.getNode(ISD::OR, DL, MVT::i64,
                    {ShiftedOp2, DAG.getConstant(Op1Val, DL, MVT::i64)}));
  } else if (IsOp2Const) { // reg imm
    Op2Val <<= 32;

    SDValue Op1Val = DAG.getNode(ISD::ZERO_EXTEND, DL, MVT::i64,
                                 DAG.getBitcast(MVT::i32, Op1));

    return DAG.getBitcast(
        Op.getValueType(),
        DAG.getNode(ISD::OR, DL, MVT::i64,
                    {Op1Val, DAG.getConstant(Op2Val, DL, MVT::i64)}));
  } else { // reg reg
    if (Op1.isUndef() && Op2.isUndef())
      return SDValue(
          DAG.getMachineNode(TargetOpcode::IMPLICIT_DEF, DL, Op.getValueType()),
          0);
    if (useINSF) {
      return SDValue(
          DAG.getMachineNode(K1C::INSF, DL, Op.getValueType(),
                             {Op1, Op2, DAG.getTargetConstant(63, DL, MVT::i64),
                              DAG.getTargetConstant(32, DL, MVT::i64)}),
          0);
    } else {
      SDValue ShiftedOp2 = DAG.getNode(
          ISD::SHL, DL, MVT::i64,
          {SDValue(DAG.getMachineNode(TargetOpcode::COPY, DL, MVT::i64,
                                      DAG.getBitcast(MVT::i32, Op2)),
                   0),
           DAG.getConstant(32, DL, MVT::i32)});
      SDValue Op1Val = DAG.getNode(ISD::ZERO_EXTEND, DL, MVT::i64,
                                   DAG.getBitcast(MVT::i32, Op1));

      return DAG.getBitcast(
          Op.getValueType(),
          DAG.getNode(ISD::OR, DL, MVT::i64, {Op1Val, ShiftedOp2}));
    }
  }
}

SDValue
K1CTargetLowering::lowerBUILD_VECTOR_V4_128bit(SDValue Op,
                                               SelectionDAG &DAG) const {
  SDLoc DL(Op);
  SDValue V1 = Op.getOperand(0);
  SDValue V2 = Op.getOperand(1);
  SDValue V3 = Op.getOperand(2);
  SDValue V4 = Op.getOperand(3);

  EVT VT = Op.getValueType();
  LLVMContext &Ctx = *DAG.getContext();
  EVT HalfVT = VT.getHalfNumVectorElementsVT(Ctx);

  SDValue VecLow = lowerBUILD_VECTOR_V2_64bit(
      DAG.getNode(ISD::BUILD_VECTOR, DL, HalfVT, {V1, V2}), DAG, false);
  SDValue VecHi = lowerBUILD_VECTOR_V2_64bit(
      DAG.getNode(ISD::BUILD_VECTOR, DL, HalfVT, {V3, V4}), DAG, false);

  SDValue ImpV =
      SDValue(DAG.getMachineNode(TargetOpcode::IMPLICIT_DEF, DL, VT), 0);
  SDValue InsLow =
      SDValue(DAG.getMachineNode(
                  TargetOpcode::INSERT_SUBREG, DL, VT,
                  {ImpV, VecLow, DAG.getTargetConstant(1, DL, MVT::i64)}),
              0);
  if (VecHi.isUndef())
    return InsLow;
  return SDValue(DAG.getMachineNode(
                     TargetOpcode::INSERT_SUBREG, DL, VT,
                     {InsLow, VecHi, DAG.getTargetConstant(2, DL, MVT::i64)}),
                 0);
}

SDValue K1CTargetLowering::lowerINSERT_VECTOR_ELT(SDValue Op,
                                                  SelectionDAG &DAG) const {

  EVT ScalarVT = Op.getValueType().getScalarType();

  uint64_t ElementBitSize = ScalarVT.getSizeInBits();

  uint64_t Mask = (ElementBitSize == 16) ? 0xFFFF : 0xFFFFFFFF;

  auto TotalSizeType = (ElementBitSize == 16) ? MVT::i32 : MVT::i64;

  SDValue Vec = Op->getOperand(0);
  SDValue Val = Op->getOperand(1);
  SDValue Idx = Op->getOperand(2);
  SDLoc dl(Op);
  if (ConstantSDNode *InsertPos = dyn_cast<ConstantSDNode>(Idx)) {
    if (Vec.getValueType() == MVT::v4f32)
      return lowerINSERT_VECTOR_ELT_V4_128bit(dl, DAG, Vec, Val,
                                              InsertPos->getZExtValue());

    bool IsImm = false;
    uint64_t ImmVal;
    if (isa<ConstantSDNode>(Val)) {
      IsImm = true;
      ImmVal = dyn_cast<ConstantSDNode>(Val)->getZExtValue();
    } else if (isa<ConstantFPSDNode>(Val)) {
      IsImm = true;
      ImmVal = dyn_cast<ConstantFPSDNode>(Val)
                   ->getValueAPF()
                   .bitcastToAPInt()
                   .getZExtValue();
    }
    if (IsImm) {
      if (InsertPos->getZExtValue() == 0) {
        SDValue V = DAG.getNode(
            ISD::AND, dl, TotalSizeType, DAG.getBitcast(TotalSizeType, Vec),
            DAG.getConstant((Mask << ElementBitSize), dl, TotalSizeType));
        return DAG.getBitcast(Op.getValueType(),
                              DAG.getNode(ISD::OR, dl, TotalSizeType,
                                          {V, DAG.getConstant(ImmVal & Mask, dl,
                                                              TotalSizeType)}));
      } else {
        SDValue V = DAG.getNode(ISD::AND, dl, TotalSizeType,
                                DAG.getBitcast(TotalSizeType, Vec),
                                DAG.getConstant(Mask, dl, TotalSizeType));
        return DAG.getBitcast(
            Op.getValueType(),
            DAG.getNode(ISD::OR, dl, TotalSizeType,
                        {V, DAG.getConstant(ImmVal << ElementBitSize, dl,
                                            TotalSizeType)}));
      }
    } else {
      SDValue stopbit, startbit;
      uint64_t StartIdx = InsertPos->getZExtValue() * ElementBitSize;
      stopbit =
          DAG.getTargetConstant(StartIdx + ElementBitSize - 1, dl, MVT::i64);
      startbit = DAG.getTargetConstant(StartIdx, dl, MVT::i64);
      return SDValue(DAG.getMachineNode(K1C::INSF, dl, MVT::i64,
                                        {Vec, Val, stopbit, startbit}),
                     0);
    }
  }
  SDValue Tmp1 = Vec;
  SDValue Tmp2 = Val;
  SDValue Tmp3 = Idx;

  EVT VT = Tmp1.getValueType();
  EVT EltVT = VT.getVectorElementType();
  SDValue StackPtr = DAG.CreateStackTemporary(VT);

  int SPFI = cast<FrameIndexSDNode>(StackPtr.getNode())->getIndex();

  // Store the vector.
  SDValue Ch = DAG.getStore(
      DAG.getEntryNode(), dl, Tmp1, StackPtr,
      MachinePointerInfo::getFixedStack(DAG.getMachineFunction(), SPFI));

  SDValue StackPtr2 = getVectorElementPointer(DAG, StackPtr, VT, Tmp3);

  // Store the scalar value.
  Ch = DAG.getTruncStore(Ch, dl, Tmp2, StackPtr2, MachinePointerInfo(), EltVT);
  // Load the updated vector.
  return DAG.getLoad(
      VT, dl, Ch, StackPtr,
      MachinePointerInfo::getFixedStack(DAG.getMachineFunction(), SPFI));
}

SDValue K1CTargetLowering::lowerINSERT_VECTOR_ELT_V4_128bit(
    SDLoc &dl, SelectionDAG &DAG, SDValue Vec, SDValue Val,
    uint64_t index) const {
  SDValue v1, subRegIdx, mask;
  if (index % 2 == 0) {
    subRegIdx = DAG.getTargetConstant(index == 0 ? 1 : 2, dl, MVT::i32);
    v1 = DAG.getNode(ISD::ZERO_EXTEND, dl, MVT::i64,
                     DAG.getBitcast(MVT::i32, Val));
    mask = DAG.getConstant(0xffffffff00000000, dl, MVT::i64);
  } else {
    subRegIdx = DAG.getTargetConstant(index == 1 ? 1 : 2, dl, MVT::i32);
    SDValue val32 = SDValue(DAG.getMachineNode(TargetOpcode::COPY, dl, MVT::i64,
                                               DAG.getBitcast(MVT::i32, Val)),
                            0);
    v1 = DAG.getNode(ISD::SHL, dl, MVT::i64,
                     {val32, DAG.getConstant(32, dl, MVT::i32)});
    mask = DAG.getConstant(0xffffffff, dl, MVT::i64);
  }
  SDValue subreg = SDValue(DAG.getMachineNode(TargetOpcode::EXTRACT_SUBREG, dl,
                                              MVT::i64, {Vec, subRegIdx}),
                           0);

  SDValue v2 = DAG.getNode(ISD::AND, dl, MVT::i64, {subreg, mask});

  SDValue orResult = DAG.getNode(ISD::OR, dl, MVT::i64, {v1, v2});
  return SDValue(DAG.getMachineNode(TargetOpcode::INSERT_SUBREG, dl, MVT::v4f32,
                                    {Vec, orResult, subRegIdx}),
                 0);
}

SDValue K1CTargetLowering::lowerEXTRACT_VECTOR_ELT(SDValue Op,
                                                   SelectionDAG &DAG) const {
  SDValue Vec = Op.getOperand(0);

  if (Vec.getValueType() == MVT::v2f32 || Vec.getValueType() == MVT::v2i32 ||
      Vec.getValueType() == MVT::v4f32)
    return lowerEXTRACT_VECTOR_ELT_TDPATTERN(Op, DAG);

  if (Vec.getValueType() == MVT::v2i16 || Vec.getValueType() == MVT::v2f16)
    return lowerEXTRACT_VECTOR_ELT_V2_32bit(Op, DAG);

  llvm_unreachable("Unsupported lowering for this type!");
}

SDValue
K1CTargetLowering::lowerEXTRACT_VECTOR_ELT_REGISTER(SDValue Op,
                                                    SelectionDAG &DAG) const {
  SDValue Vec = Op.getOperand(0);
  SDValue Idx = Op.getOperand(1);
  SDLoc dl(Op);

  EVT VecVT = Vec.getValueType();
  SDValue StackPtr = DAG.CreateStackTemporary(VecVT);
  SDValue Ch =
      DAG.getStore(DAG.getEntryNode(), dl, Vec, StackPtr, MachinePointerInfo());

  StackPtr = getVectorElementPointer(DAG, StackPtr, VecVT, Idx);

  SDValue NewLoad;

  if (Op.getValueType().isVector())
    NewLoad =
        DAG.getLoad(Op.getValueType(), dl, Ch, StackPtr, MachinePointerInfo());
  else
    NewLoad =
        DAG.getExtLoad(ISD::EXTLOAD, dl, Op.getValueType(), Ch, StackPtr,
                       MachinePointerInfo(), VecVT.getVectorElementType());

  DAG.ReplaceAllUsesOfValueWith(Ch, SDValue(NewLoad.getNode(), 1));

  SmallVector<SDValue, 6> NewLoadOperands(NewLoad->op_begin(),
                                          NewLoad->op_end());
  NewLoadOperands[0] = Ch;
  NewLoad =
      SDValue(DAG.UpdateNodeOperands(NewLoad.getNode(), NewLoadOperands), 0);
  return NewLoad;
}

SDValue
K1CTargetLowering::lowerEXTRACT_VECTOR_ELT_V2_32bit(SDValue Op,
                                                    SelectionDAG &DAG) const {
  SDValue Vec = Op.getOperand(0);
  SDValue Idx = Op.getOperand(1);
  SDLoc dl(Op);

  bool IsIdxConst = isa<ConstantSDNode>(Idx);

  if (IsIdxConst) {
    uint64_t IdxVal = dyn_cast<ConstantSDNode>(Idx)->getZExtValue();
    if (IdxVal == 0) {
      return DAG.getNode(ISD::AND, dl, MVT::i32,
                         {DAG.getBitcast(MVT::i32, Vec),
                          DAG.getConstant(0xFFFF, dl, MVT::i32)});
    } else if (IdxVal == 1) {
      SDValue ShiftedVec = DAG.getNode(
          ISD::SRA, dl, MVT::i32,
          {DAG.getBitcast(MVT::i32, Vec), DAG.getConstant(16, dl, MVT::i32)});

      return DAG.getNode(ISD::AND, dl, MVT::i32, ShiftedVec,
                         DAG.getConstant(0xFFFF, dl, MVT::i32));
    }
    llvm_unreachable("Unsupported lowering for this index!");
  }
  return lowerEXTRACT_VECTOR_ELT_REGISTER(Op, DAG);
}

SDValue
K1CTargetLowering::lowerEXTRACT_VECTOR_ELT_TDPATTERN(SDValue Op,
                                                     SelectionDAG &DAG) const {
  SDValue Idx = Op.getOperand(1);

  if (isa<ConstantSDNode>(Idx)) {
    // use patterns in td
    return Op;
  }

  return lowerEXTRACT_VECTOR_ELT_REGISTER(Op, DAG);
}
