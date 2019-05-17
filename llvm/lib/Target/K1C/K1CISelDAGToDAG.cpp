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

  bool SelectAddrFI(SDValue Addr, SDValue &FrameIndex);

  bool SelectAddrRI(SDValue Addr, SDValue &Base, SDValue &Index);
  bool SelectAddrRR(SDValue Addr, SDValue &Base, SDValue &Index);
#include "K1CGenDAGISel.inc"
};

} // namespace

bool K1CDAGToDAGISel::SelectAddrFI(SDValue Addr, SDValue &FrameIndex) {
  if (auto FIN = dyn_cast<FrameIndexSDNode>(Addr)) {
    FrameIndex = CurDAG->getTargetFrameIndex(FIN->getIndex(), MVT::i64);
    return true;
  }
  return false;
}

bool K1CDAGToDAGISel::SelectAddrRI(SDValue Addr, SDValue &Base,
                                   SDValue &Index) {
  if (FrameIndexSDNode *FIN = dyn_cast<FrameIndexSDNode>(Addr)) {
    Base = CurDAG->getRegister(K1C::R12, MVT::i64);
    Index = CurDAG->getTargetFrameIndex(
        FIN->getIndex(), TLI->getPointerTy(CurDAG->getDataLayout()));
    return true;
  }
  if (Addr.getOpcode() == ISD::ADD) {
    if (ConstantSDNode *CN = dyn_cast<ConstantSDNode>(Addr.getOperand(1))) {
      if (isInt<64>(CN->getSExtValue())) {
        if (FrameIndexSDNode *FIN =
                dyn_cast<FrameIndexSDNode>(Addr.getOperand(0))) {
          // Constant offset from frame ref
          return false;
        } else {
          Base = Addr.getOperand(0);
        }
        Index = CurDAG->getTargetConstant(CN->getZExtValue(), SDLoc(Addr),
                                          MVT::i64);
        return true;
      }
    }
  }
  Base = Addr;
  Index = CurDAG->getTargetConstant(0, SDLoc(Addr), MVT::i64);
  return true;
}

bool K1CDAGToDAGISel::SelectAddrRR(SDValue Addr, SDValue &Base,
                                   SDValue &Index) {
  return false;
}

void K1CDAGToDAGISel::Select(SDNode *Node) {
  if (Node->isMachineOpcode()) {
    Node->setNodeId(-1);
    return; // Already selected.
  }
  unsigned Opcode = Node->getOpcode();

  switch (Opcode) {
  case ISD::FrameIndex:
    int FI = cast<FrameIndexSDNode>(Node)->getIndex();
    printf("ISD::FrameIndex %i\n", FI);
    break;
  }
  SelectCode(Node);
}

FunctionPass *llvm::createK1CISelDag(K1CTargetMachine &TM) {
  return new K1CDAGToDAGISel(TM);
}
