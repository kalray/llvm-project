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
#include "llvm/CodeGen/SelectionDAGISel.h"

using namespace llvm;

#define DEBUG_TYPE "kvx-isel"

namespace {

class KVXDAGToDAGISel final : public SelectionDAGISel {

  const KVXSubtarget *Subtarget;

public:
  explicit KVXDAGToDAGISel(KVXTargetMachine &tm,
                  CodeGenOptLevel OptLevel)
      : SelectionDAGISel(tm, OptLevel), Subtarget(nullptr) {}

  bool runOnMachineFunction(MachineFunction &MF) override {
    Subtarget = &MF.getSubtarget<KVXSubtarget>();
    return SelectionDAGISel::runOnMachineFunction(MF);
  }

  void Select(SDNode *Node) override;

  bool selectAddrFI(SDValue Addr, SDValue &Base);
  bool selectAddrRR(SDValue Addr, SDValue &Index, SDValue &Base);

  MachineSDNode *buildMake(SDLoc &DL, SDNode *Imm, EVT VT) const;
  bool SelectInlineAsmMemoryOperand(const SDValue &Op,
                               InlineAsm::ConstraintCode ConstraintID,
                               std::vector<SDValue> &OutOps) override;

#include "KVXGenDAGISel.inc"
};

struct KVXDAGToDAGISelLegacy final : public SelectionDAGISelLegacy {
  static char ID;
  StringRef getPassName() const override { return "KVX DAG->DAG Pattern Instruction Selection"; }

  explicit KVXDAGToDAGISelLegacy(KVXTargetMachine &tm,
                                     CodeGenOptLevel OptLevel)
      : SelectionDAGISelLegacy(
            ID, std::make_unique<KVXDAGToDAGISel>(tm, OptLevel)) {}
};

} // namespace
char KVXDAGToDAGISelLegacy::ID = 0;

bool KVXDAGToDAGISel::selectAddrFI(SDValue Addr, SDValue &Base) {
  if (auto *FIN = dyn_cast<FrameIndexSDNode>(Addr)) {
    Base = CurDAG->getTargetFrameIndex(
        FIN->getIndex(), TLI->getPointerTy(CurDAG->getDataLayout()));
    return true;
  }
  return false;
}

bool KVXDAGToDAGISel::selectAddrRR(SDValue Addr, SDValue &Index,
                                   SDValue &Base) {
  if (auto *FIN = dyn_cast<FrameIndexSDNode>(Addr)) {
    Base = CurDAG->getTargetFrameIndex(
        FIN->getIndex(), TLI->getPointerTy(CurDAG->getDataLayout()));
    Index = CurDAG->getTargetConstant(0, SDLoc(Addr), MVT::i64);
    return true;
  }
  if (auto *BaseReg = dyn_cast<RegisterSDNode>(Addr)) {
    Base = CurDAG->getRegister(BaseReg->getReg(), MVT::i64);
    Index = CurDAG->getTargetConstant(0, SDLoc(Addr), MVT::i64);
    return true;
  }

  if (Addr.getOpcode() == ISD::ADD ||
      (Addr.getOpcode() == ISD::OR &&
       CurDAG->haveNoCommonBitsSet(Addr.getOperand(0), Addr.getOperand(1)))) {

    auto *FIN = dyn_cast<FrameIndexSDNode>(Addr.getOperand(0));
    auto *CN = dyn_cast<ConstantSDNode>(Addr.getOperand(1));

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
    }
    if (CN) {
      Index =
          CurDAG->getTargetConstant(CN->getZExtValue(), SDLoc(Addr), MVT::i64);
      Base = Addr.getOperand(0);
      return true;
    }

    Index = Addr.getOperand(1);
    Base = Addr.getOperand(0);
    return true;
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

FunctionPass *llvm::createKVXISelDag(KVXTargetMachine &TM, CodeGenOptLevel OptLevel) {
  return new KVXDAGToDAGISelLegacy(TM, OptLevel);
}

bool KVXDAGToDAGISel::SelectInlineAsmMemoryOperand(const SDValue &Op,
                               InlineAsm::ConstraintCode ConstraintID,
                               std::vector<SDValue> &OutOps) {
  switch (ConstraintID) {
  default:
    break;

    // From
    // https://gcc.gnu.org/onlinedocs/gcc/Simple-Constraints.html#Simple-Constraints
    // 'm'
    // A memory operand is allowed, with any kind of address that the machine
    // supports in general. Note that the letter used for the general memory
    // constraint can be re-defined by a back end using the
    // TARGET_MEM_CONSTRAINT macro.

    // 'o'
    //     A memory operand is allowed, but only if the address is offsettable.
    //     This means that adding a small integer (actually, the width in bytes
    //     of the operand, as determined by its machine mode) may be added to
    //     the address and the result is also a valid memory address. For
    //     example, an address which is constant is offsettable; so is an
    //     address that is the sum of a register and a constant (as long as a
    //     slightly larger constant is also within the range of address-offsets
    //     supported by the machine); but an autoincrement or autodecrement
    //     address is not offsettable. More complicated indirect/indexed
    //     addresses may or may not be offsettable depending on the other
    //     addressing modes that the machine supports. Note that in an output
    //     operand which can be matched by another operand, the constraint
    //     letter 'o' is valid only when accompanied by both '<' (if the target
    //     machine has predecrement addressing) and '>' (if the target machine
    //     has preincrement addressing).

  case InlineAsm::ConstraintCode::m:
    // This allows to use memory operands in inline asm.
    // No special treatment is required as it can live
    // in any of our gpr registers.

    // TODO: At the moment the memory operands such as
    // N[X] will appear as N * elementSize + X, as kvx
    // backen is not capable to interpret the inline asm.

    OutOps.push_back(Op);
    return false;
  }
  return true;
}
