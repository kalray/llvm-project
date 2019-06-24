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

#define DEBUG_TYPE "K1C-lower"

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

  addRegisterClass(MVT::f16, &K1C::SingleRegRegClass);
  addRegisterClass(MVT::f32, &K1C::SingleRegRegClass);
  addRegisterClass(MVT::f64, &K1C::SingleRegRegClass);

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

  for (auto VT : { MVT::i1, MVT::i8, MVT::i16 }) {
    setOperationAction(ISD::SIGN_EXTEND_INREG, VT, Expand);
  }

  for (auto VT : { MVT::i32, MVT::i64 }) {
    setOperationAction(ISD::SMUL_LOHI, VT, Expand);
    setOperationAction(ISD::UMUL_LOHI, VT, Expand);
    setOperationAction(ISD::MULHS, VT, Expand);
    setOperationAction(ISD::MULHU, VT, Expand);

    setOperationAction(ISD::SELECT_CC, VT, Expand);
    setOperationAction(ISD::SELECT, VT, Custom);

    setOperationAction(ISD::TRUNCATE, VT, Custom);

    setOperationAction(ISD::SIGN_EXTEND_INREG, VT, Expand);

    setOperationAction(ISD::BR_CC, VT, Expand);

    setOperationAction(ISD::BSWAP, VT, Expand);
  }
  setOperationAction(ISD::ROTL, MVT::i64, Expand);
  setOperationAction(ISD::ROTR, MVT::i64, Expand);

  setOperationAction(ISD::GlobalAddress, MVT::i64, Custom);
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
  }

  for (MVT VT : MVT::fp_valuetypes()) {
    setLoadExtAction(ISD::EXTLOAD, VT, MVT::f16, Expand);
    setLoadExtAction(ISD::EXTLOAD, VT, MVT::f32, Expand);
    setLoadExtAction(ISD::EXTLOAD, VT, MVT::f64, Expand);
  }

  // Effectively disable jump table generation.
  setMinimumJumpTableEntries(INT_MAX);
}

EVT K1CTargetLowering::getSetCCResultType(const DataLayout &DL, LLVMContext &,
                                          EVT VT) const {
  if (!VT.isVector())
    return getPointerTy(DL);
  return VT.changeVectorElementTypeToInteger();
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
  case K1CISD::TRUNCATE:
    return "K1C::TRUNCATE";
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
  // RetOps.push_back(SDValue());

  const Function &F = DAG.getMachineFunction().getFunction();

  // Get caller attribute list for the return value to see what kind of extend
  // is needed
  AttributeList CallerAttrs = F.getAttributes();

  bool SExt = true;
  if (CallerAttrs.hasAttribute(AttributeList::ReturnIndex, Attribute::ZExt))
    SExt = false;

  for (unsigned int i = 0; i != RVLocs.size(); ++i) {
    CCValAssign &VA = RVLocs[i];
    assert(VA.isRegLoc() && "Can only return in registers!");
    SDValue Arg = OutVals[i];

    if (VA.getValVT().isScalarInteger()) {
      if (VA.getValVT() != MVT::i64) {
        if (SExt)
          Arg = DAG.getSExtOrTrunc(Arg, DL, MVT::i64);
        else
          Arg = DAG.getZExtOrTrunc(Arg, DL, MVT::i64);
      }
    }

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

      const unsigned VReg =
          RegInfo.createVirtualRegister(&K1C::SingleRegRegClass);
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
  bool &isTailCall = CLI.IsTailCall;
  CallingConv::ID CallConv = CLI.CallConv;
  bool isVarArg = CLI.IsVarArg;
  EVT PtrVT = getPointerTy(DAG.getDataLayout());
  MachineFunction &MF = DAG.getMachineFunction();
  K1CMachineFunctionInfo *FuncInfo = MF.getInfo<K1CMachineFunctionInfo>();

  isTailCall = false;

  // Analyze operands of the call, assigning locations to each operand.
  SmallVector<CCValAssign, 16> ArgLocs;
  CCState CCInfo(CallConv, isVarArg, DAG.getMachineFunction(), ArgLocs,
                 *DAG.getContext());
  CCInfo.AnalyzeCallOperands(Outs, CC_SRET_K1C);

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
                          /*AlwaysInline=*/false, false /*isTailCall*/,
                          MachinePointerInfo(), MachinePointerInfo());
    ByValArgs.push_back(FIPtr);
  }

  Chain = DAG.getCALLSEQ_START(Chain, ArgsSize, 0, DL);

  SmallVector<std::pair<unsigned, SDValue>, 8> RegsToPass;
  SmallVector<SDValue, 8> MemOpChains;
  SDValue StackPtr;
  unsigned OutgoingArgsSize = 0;

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
      assert(!isTailCall && "Tail call not allowed if stack is used "
                            "for passing parameters");

      // Work out the address of the stack slot.
      if (!StackPtr.getNode())
        StackPtr = DAG.getCopyFromReg(Chain, DL, getSPReg(), PtrVT);

      OutgoingArgsSize += 8;

      // Create a store off the stack pointer for this argument.
      SDValue PtrOff = DAG.getIntPtrConstant(VA.getLocMemOffset(), DL);
      PtrOff = DAG.getNode(ISD::ADD, DL, MVT::i64, StackPtr, PtrOff);
      MemOpChains.push_back(
          DAG.getStore(Chain, DL, ArgValue, PtrOff, MachinePointerInfo()));
    }
  }

  FuncInfo->setOutgoingArgsMaxSize(OutgoingArgsSize);

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

  if (!isTailCall) {
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
  case ISD::VASTART:
    return lowerVASTART(Op, DAG);
  case ISD::VAARG:
    return lowerVAARG(Op, DAG);
  case ISD::FRAMEADDR:
    return lowerFRAMEADDR(Op, DAG);
  case ISD::SELECT:
    return lowerSELECT(Op, DAG);
  case ISD::TRUNCATE:
    return lowerTRUNCATE(Op, DAG);
  }
}

SDValue K1CTargetLowering::lowerGlobalAddress(SDValue Op,
                                              SelectionDAG &DAG) const {
  SDLoc DL(Op);
  auto PtrVT = getPointerTy(DAG.getDataLayout());
  GlobalAddressSDNode *N = cast<GlobalAddressSDNode>(Op);
  const GlobalValue *GV = N->getGlobal();
  int64_t Offset = N->getOffset();

  if (isPositionIndependent())
    report_fatal_error("Unable to lowerGlobalAddress");

  SDValue Result = DAG.getTargetGlobalAddress(GV, DL, PtrVT, 0);
  Result = DAG.getNode(K1CISD::WRAPPER, DL, PtrVT, Result);

  if (Offset != 0) {
    SDValue PtrOff = DAG.getIntPtrConstant(Offset, DL);
    Result = DAG.getNode(ISD::ADD, DL, MVT::i64, Result, PtrOff);
  }

  return Result;
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

SDValue K1CTargetLowering::lowerTRUNCATE(SDValue Op, SelectionDAG &DAG) const {
  return DAG.getNode(K1CISD::TRUNCATE, SDLoc(Op),
                     DAG.getVTList(Op.getValueType()), { Op.getOperand(0) });
}
