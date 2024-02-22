//===-- KVXISelLowering.cpp - KVX DAG Lowering Implementation  ------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the TCA rules for the KVXTargetLowering class.
//
//===----------------------------------------------------------------------===//

#include "KVXISelLowering.h"
#include "KVXRegisterInfo.h"

using namespace llvm;

void KVXTargetLowering::initializeTCARegisters() {
  addRegisterClass(MVT::v64i1, &KVX::CoproRegRegClass);
  addRegisterClass(MVT::v128i1, &KVX::BlockRegRegClass);
  addRegisterClass(MVT::v256i1, &KVX::VectorRegRegClass);
  addRegisterClass(MVT::v512i1, &KVX::WideRegRegClass);
  addRegisterClass(MVT::v1024i1, &KVX::MatrixRegRegClass);
  addRegisterClass(MVT::v2048i1, &KVX::Buffer8RegRegClass);
  addRegisterClass(MVT::v4096i1, &KVX::Buffer16RegRegClass);
}

void KVXTargetLowering::initializeTCALowering() {
  auto LegalTypes = {MVT::v64i1, MVT::v128i1, MVT::v256i1, MVT::v512i1,
                     MVT::v1024i1, MVT::v2048i1, MVT::v4096i1};
  // First, set all operations to expand, and then clear
  // out those that are legal.
  for (auto VT : LegalTypes) {
    for (int NodeType = ISD::TokenFactor; NodeType < ISD::BUILTIN_OP_END;
         NodeType++)
      setOperationAction(NodeType, VT, Expand);

    for (auto NodeType :
         {ISD::READ_REGISTER, ISD::WRITE_REGISTER, ISD::INTRINSIC_WO_CHAIN,
          ISD::INTRINSIC_W_CHAIN, ISD::INTRINSIC_VOID, ISD::INLINEASM,
          ISD::INLINEASM_BR, ISD::SRCVALUE, ISD::HANDLENODE, ISD::UNDEF,
          ISD::EXTRACT_SUBVECTOR})
      setOperationAction(NodeType, VT, Legal);
  }

  // Special rules for v256i1, as these map to a vector register.
  for (auto NodeType :
       {ISD::CopyToReg, ISD::CopyFromReg, ISD::LOAD, ISD::STORE, ISD::PREFETCH,
        ISD::ATOMIC_LOAD, ISD::ATOMIC_STORE, ISD::ATOMIC_SWAP})
    setOperationAction(NodeType, MVT::v256i1, Legal);

  for (auto VT : {MVT::v512i1, MVT::v1024i1, MVT::v2048i1, MVT::v4096i1}) {
    // Set STORE / LOAD to legal, but at last dag combine
    // they are splitted into 256 bit sequences.
    setOperationAction(ISD::LOAD, VT, Legal);
    setOperationAction(ISD::STORE, VT, Legal);
    setOperationAction(ISD::MERGE_VALUES, VT, Legal);
    setOperationAction(ISD::CONCAT_VECTORS, VT, Legal);
  }

  for (auto VT :
       {MVT::v256i1, MVT::v512i1, MVT::v1024i1, MVT::v2048i1, MVT::v4096i1}) {
    setOperationAction(ISD::SELECT, VT, Legal);
    setOperationAction(ISD::SPLAT_VECTOR, VT, Custom);
    setOperationAction(ISD::BUILD_VECTOR, VT, Custom);
  }
}

SDValue KVXTargetLowering::lowerTCAZeroInit(SDValue Op,
                                            SelectionDAG &DAG) const {
  // For now we only use TCA registers BUILD_VECTOR as a zeroinit operation
  switch (Op->getSimpleValueType(0).SimpleTy) {
  case MVT::v256i1:
  case MVT::v512i1:
  case MVT::v1024i1:
  case MVT::v2048i1:
  case MVT::v4096i1:
    break;
  default:
    report_fatal_error("Not a TCA type");
  }

  if (ISD::isConstantSplatVectorAllZeros(Op.getNode()))
    return Op;

  return SDValue();
}
