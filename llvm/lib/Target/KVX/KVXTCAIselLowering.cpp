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
#include "KVX.h"
#include "KVXMachineFunctionInfo.h"
#include "KVXTargetMachine.h"


using namespace llvm;

void KVXTargetLowering::initializeTCARegisters() {
  addRegisterClass(MVT::v64i1, &KVX::CoproRegRegClass);
  addRegisterClass(MVT::v128i1, &KVX::BlockRegRegClass);
  addRegisterClass(MVT::v256i1, &KVX::VectorRegRegClass);
  addRegisterClass(MVT::v512i1, &KVX::WideRegRegClass);
  addRegisterClass(MVT::v1024i1, &KVX::MatrixRegRegClass);
}

void KVXTargetLowering::initializeTCALowering() {
  auto LegalTypes = {MVT::v64i1, MVT::v128i1, MVT::v256i1, MVT::v512i1,
                     MVT::v1024i1};
  // First, set all operations to expand, and then clear
  // out those that are legal.
  for (auto VT : LegalTypes) {
    for (int NodeType = ISD::TokenFactor; NodeType < ISD::BUILTIN_OP_END;
         NodeType++)
      setOperationAction(NodeType, VT, Expand);

    for (auto NodeType : {
             ISD::READ_REGISTER,
             ISD::WRITE_REGISTER,
             ISD::INTRINSIC_WO_CHAIN,
             ISD::INTRINSIC_W_CHAIN,
             ISD::INTRINSIC_VOID,
             ISD::INLINEASM,
             ISD::INLINEASM_BR,
             ISD::SRCVALUE,
             ISD::HANDLENODE,
         })
      setOperationAction(NodeType, VT, Legal);
  }

  // Special rules for v256i1, as these map to a vector register.
  for (auto NodeType : {ISD::CopyToReg, ISD::CopyFromReg, ISD::EXTRACT_ELEMENT,
                        ISD::LOAD, ISD::STORE, ISD::PREFETCH, ISD::ATOMIC_LOAD,
                        ISD::ATOMIC_STORE, ISD::ATOMIC_SWAP})
    setOperationAction(NodeType, MVT::v256i1, Legal);
}
