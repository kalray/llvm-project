//===-- K1CISelDAGToDAG.cpp - A dag to dag inst selector for K1C ----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines an instruction selector for the K1C target.
//
//===----------------------------------------------------------------------===//

#include "K1C.h"
#include "K1CTargetMachine.h"
#include "MCTargetDesc/K1CMCTargetDesc.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/MathExtras.h"
#include "llvm/Support/raw_ostream.h"
using namespace llvm;

#define DEBUG_TYPE "K1C-isel"

namespace {

class K1CDAGToDAGISel final : public SelectionDAGISel {
public:
  explicit K1CDAGToDAGISel(K1CTargetMachine &TargetMachine)
      : SelectionDAGISel(TargetMachine) {}

  StringRef getPassName() const override {
    return "K1C DAG->DAG Pattern Instruction Selection";
  }

  void Select(SDNode *Node) override;

  bool SelectAddrFI(SDValue Addr, SDValue &Base);
  bool SelectAddrRI(SDValue Addr, SDValue &Index, SDValue &Base);

  MachineSDNode *buildMake(SDLoc &DL, SDNode *Imm, EVT VT) const;
#include "K1CGenDAGISel.inc"
};

} // namespace

bool K1CDAGToDAGISel::SelectAddrFI(SDValue Addr, SDValue &Base) {
  if (auto FIN = dyn_cast<FrameIndexSDNode>(Addr)) {
    Base = CurDAG->getTargetFrameIndex(
        FIN->getIndex(), TLI->getPointerTy(CurDAG->getDataLayout()));
    return true;
  }
  return false;
}

bool K1CDAGToDAGISel::SelectAddrRI(SDValue Addr, SDValue &Index,
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

void K1CDAGToDAGISel::Select(SDNode *Node) {
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
MachineSDNode *K1CDAGToDAGISel::buildMake(SDLoc &DL, SDNode *Imm,
                                          EVT VT) const {

  unsigned ImmCode = Imm->getOpcode();
  unsigned MakeCode = K1C::MAKEi64;
  MachineSDNode *MakeInsn;

  switch (ImmCode) {
  default:
    llvm_unreachable("unknown immediate opcode");

  case ISD::ConstantFP: {
    ConstantFPSDNode *CST = cast<ConstantFPSDNode>(Imm);
    unsigned BitWidth;

    if (CST->getConstantFPValue()->getType()->isHalfTy()) {
      MakeCode = K1C::MAKEi16;
      BitWidth = 16;
    } else if (CST->getConstantFPValue()->getType()->isFloatTy()) {
      MakeCode = K1C::MAKEi43;
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
      MakeCode = K1C::MAKEi16;
    else if (isInt<43>(Imm))
      MakeCode = K1C::MAKEi43;

    MakeInsn = CurDAG->getMachineNode(
        MakeCode, DL, VT, CurDAG->getTargetConstant(Imm, DL, MVT::i64));
  } break;
  }
  return MakeInsn;
}

FunctionPass *llvm::createK1CISelDag(K1CTargetMachine &TM) {
  return new K1CDAGToDAGISel(TM);
}
