//===-- KVXISelDAGToDAG.cpp - A dag to dag inst selector for KVX ----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines an instruction selector for the KVX target.
//
//===----------------------------------------------------------------------===//

#include "KVX.h"
#include "KVXTargetMachine.h"
#include "MCTargetDesc/KVXMCTargetDesc.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/MathExtras.h"
#include "llvm/Support/raw_ostream.h"
using namespace llvm;

#define DEBUG_TYPE "KVX-isel"

namespace {

class KVXDAGToDAGISel final : public SelectionDAGISel {
public:
  explicit KVXDAGToDAGISel(KVXTargetMachine &TargetMachine)
      : SelectionDAGISel(TargetMachine) {}

  StringRef getPassName() const override {
    return "KVX DAG->DAG Pattern Instruction Selection";
  }

  void Select(SDNode *Node) override;

  bool SelectAddrFI(SDValue Addr, SDValue &Base);
  bool SelectAddrRI(SDValue Addr, SDValue &Index, SDValue &Base);

  MachineSDNode *buildMake(SDLoc &DL, SDNode *Imm, EVT VT) const;
#include "KVXGenDAGISel.inc"
};

} // namespace

bool KVXDAGToDAGISel::SelectAddrFI(SDValue Addr, SDValue &Base) {
  if (auto FIN = dyn_cast<FrameIndexSDNode>(Addr)) {
    Base = CurDAG->getTargetFrameIndex(
        FIN->getIndex(), TLI->getPointerTy(CurDAG->getDataLayout()));
    return true;
  }
  return false;
}

bool KVXDAGToDAGISel::SelectAddrRI(SDValue Addr, SDValue &Index,
                                   SDValue &Base) {
  if (auto FIN = dyn_cast<FrameIndexSDNode>(Addr)) {
    Base = CurDAG->getTargetFrameIndex(
        FIN->getIndex(), TLI->getPointerTy(CurDAG->getDataLayout()));
    Index = CurDAG->getTargetConstant(0, SDLoc(Addr), MVT::i64);
    return true;
  }
  if (auto BaseReg = dyn_cast<RegisterSDNode>(Addr)) {
    Base = CurDAG->getRegister(BaseReg->getReg(), MVT::i64);
    Index = CurDAG->getTargetConstant(0, SDLoc(Addr), MVT::i64);
    return true;
  }

  if (Addr.getOpcode() == ISD::ADD || Addr.getOpcode() == ISD::OR) {

    auto FIN = dyn_cast<FrameIndexSDNode>(Addr.getOperand(0));
    auto CN = dyn_cast<ConstantSDNode>(Addr.getOperand(1));

    if (FIN) {
      if (CN) {
        Index = CurDAG->getTargetConstant(CN->getZExtValue(), SDLoc(Addr),
                                          MVT::i64);
        Base = CurDAG->getTargetFrameIndex(
            FIN->getIndex(), TLI->getPointerTy(CurDAG->getDataLayout()));
      } else {
        Index = Addr.getOperand(1);
        Base = Addr.getOperand(0);
      }

      return true;
    } else {
      if (CN) {
        Index = CurDAG->getTargetConstant(CN->getZExtValue(), SDLoc(Addr),
                                          MVT::i64);
        Base = Addr.getOperand(0);

        return true;
      }
    }
  }

  Base = Addr;
  Index = CurDAG->getTargetConstant(0, SDLoc(Addr), MVT::i64);
  return true;
}

void KVXDAGToDAGISel::Select(SDNode *Node) {
  if (Node->isMachineOpcode()) {
    Node->setNodeId(-1);
    return; // Already selected.
  }
  unsigned Opcode = Node->getOpcode();

  switch (Opcode) {
  case ISD::ConstantFP:
  case ISD::Constant:
    SDLoc DL(Node);
    ReplaceNode(Node, buildMake(DL, Node, Node->getValueType(0)));
    return;
  }
  SelectCode(Node);
}

// Select the correct variant of MAKE instruction based on the imm value
MachineSDNode *KVXDAGToDAGISel::buildMake(SDLoc &DL, SDNode *Imm,
                                          EVT VT) const {

  unsigned ImmCode = Imm->getOpcode();
  unsigned MakeCode = KVX::MAKEi64;
  MachineSDNode *MakeInsn;

  switch (ImmCode) {
  default:
    llvm_unreachable("unknown immediate opcode");

  case ISD::ConstantFP: {
    ConstantFPSDNode *CST = cast<ConstantFPSDNode>(Imm);
    unsigned BitWidth;

    if (CST->getConstantFPValue()->getType()->isHalfTy()) {
      MakeCode = KVX::MAKEi16;
      BitWidth = 16;
    } else if (CST->getConstantFPValue()->getType()->isFloatTy()) {
      MakeCode = KVX::MAKEi43;
      BitWidth = 32;
    } else if (CST->getConstantFPValue()->getType()->isDoubleTy()) {
      BitWidth = 64;
    } else
      llvm_unreachable("unknown floating point immediate type");

    MakeInsn = CurDAG->getMachineNode(
        MakeCode, DL, VT,
        CurDAG->getTargetConstantFP(CST->getValueAPF(), DL,
                                    MVT::getFloatingPointVT(BitWidth)));
  } break;

  case ISD::Constant: {
    ConstantSDNode *CST = cast<ConstantSDNode>(Imm);
    uint64_t Imm = CST->getZExtValue();

    if (isInt<16>(Imm))
      MakeCode = KVX::MAKEi16;
    else if (isInt<43>(Imm))
      MakeCode = KVX::MAKEi43;

    MakeInsn = CurDAG->getMachineNode(
        MakeCode, DL, VT, CurDAG->getTargetConstant(Imm, DL, MVT::i64));
  } break;
  }
  return MakeInsn;
}

FunctionPass *llvm::createKVXISelDag(KVXTargetMachine &TM) {
  return new KVXDAGToDAGISel(TM);
}
