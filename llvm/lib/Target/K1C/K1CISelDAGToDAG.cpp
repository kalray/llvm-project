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
#include "K1CGenDAGISel.inc"
};
} // namespace

void K1CDAGToDAGISel::Select(SDNode *Node) {
  if (Node->isMachineOpcode()) {
    Node->setNodeId(-1);
    return; // Already selected.
  }
  SelectCode(Node);
}

FunctionPass *llvm::createK1CISelDag(K1CTargetMachine &TM) {
  return new K1CDAGToDAGISel(TM);
}
