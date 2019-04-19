#ifndef LLVM_LIB_TARGET_K1C_K1CISELLOWERING_H
#define LLVM_LIB_TARGET_K1C_K1CISELLOWERING_H

#include "K1C.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include "llvm/CodeGen/TargetLowering.h"

// K1CISD = K1C Instruction Selection DAG

namespace llvm {

class K1CSubtarget;

namespace K1CISD {
enum NodeType : unsigned { FIRST_NUMBER = ISD::BUILTIN_OP_END, RET };
} // namespace K1CISD

class K1CTargetLowering : public TargetLowering {
  const K1CSubtarget &Subtarget;

public:
  explicit K1CTargetLowering(const TargetMachine &TM, const K1CSubtarget &STI);

  const char *getTargetNodeName(unsigned Opcode) const override;

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
};

} // namespace llvm

#endif