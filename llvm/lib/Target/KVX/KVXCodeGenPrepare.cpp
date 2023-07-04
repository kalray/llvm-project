//===-- KVXCodeGenPrepare.cpp - KVX instcombine before selection dag -*- C++
//-*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
/// \file
/// This file contains the pass implementation that performs inst-combine alike
/// transformation to prepare code to the KVX backend.
//===----------------------------------------------------------------------===//

#include "KVXCodeGenPrepare.h"
#include "KVX.h"

#include "llvm/CodeGen/TargetPassConfig.h"
#include "llvm/IR/Constant.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/IntrinsicsKVX.h"
#include "llvm/IR/PatternMatch.h"

using namespace llvm;
using namespace PatternMatch;

#define DEBUG_TYPE "kvx-codegen-prepare"

#define KVX_CODEGEN_PREPARE_NAME DEBUG_TYPE
#define KVX_CODEGEN_PREPARE_DESC "KVX CodeGen Prepare"

char KVXCodeGenPrepare::ID = 0;

INITIALIZE_PASS(KVXCodeGenPrepare, KVX_CODEGEN_PREPARE_NAME,
                KVX_CODEGEN_PREPARE_DESC, false, false)

FunctionPass *llvm::createKVXCodeGenPreparePass(bool V1) {
  return new KVXCodeGenPrepare(V1);
}

KVXCodeGenPrepare::KVXCodeGenPrepare(bool V1) : FunctionPass(ID), IsV1((V1)) {
  auto *PR = PassRegistry::getPassRegistry();
  initializeKVXCodeGenPreparePass(*PR);
}

// Reverse the instruction-combine that converts icmp(vector_reduce_(and/or))
// into
static bool visitICmp(Instruction &I, const bool IsV1) {
  ICmpInst::Predicate PredCast, PredVec;
  Value *LHS, *RHS;
  Instruction *VecIcmp;
  if (match(&I, m_ICmp(PredCast,
                       m_BitCast(m_CombineAnd(
                           m_Instruction(VecIcmp),
                           m_ICmp(PredVec, m_Value(LHS), m_Value(RHS)))),
                       m_ZeroInt()))) {

    VectorType *VecTy = dyn_cast_or_null<VectorType>(LHS->getType());

    if (!VecTy || VecTy->getScalarSizeInBits() > 64)
      return false;

    LLVM_DEBUG(dbgs() << "Converting vector_icmp/bitcast/icmp into "
                         "kvx_vector_cmp/vector_reduce/icmp");

    LLVMContext &Ctx = I.getParent()->getContext();
    IRBuilder<> Builder(Ctx);
    Builder.SetInsertPoint(&I);
    // Element sizes = 64, make it scalar
    if (VecTy->getScalarSizeInBits() == 64) {
      Type *EltTy = VecTy->getScalarType();
      SmallVector<Value *, 4> Values;
      for (unsigned Elt = 0, End = VecTy->getElementCount().getKnownMinValue();
           Elt < End; ++Elt) {
        Value *LhsE = Builder.CreateExtractElement(
            LHS, ConstantInt::get(EltTy, Elt, false));
        Value *RhsE = Builder.CreateExtractElement(
            RHS, ConstantInt::get(EltTy, Elt, false));
        Value *Cmp = Builder.CreateICmp(PredVec, LhsE, RhsE);
        Value *Ext = Builder.CreateZExt(Cmp, EltTy);
        Values.push_back(Ext);
      }
      do {
        SmallVector<Value *, 4> NewValues;
        while (Values.size() > 1) {
          Value *V1 = Values.pop_back_val();
          Value *V2 = Values.pop_back_val();
          NewValues.push_back(Builder.CreateOr(V1, V2, "kvx_join_vec_cmp"));
        }
        if (Values.size())
          NewValues.emplace_back(Values.pop_back_val());

        Values = std::move(NewValues);
      } while (Values.size() > 1);
      Value *R = Builder.CreateICmp(PredCast, Values.pop_back_val(),
                                    ConstantInt::getNullValue(EltTy));
      I.replaceAllUsesWith(R);
      return true;
    }

    KVXMOD::COMPARISON CmpPred;
    switch (PredVec) {
    case CmpInst::ICMP_EQ:
      CmpPred = KVXMOD::COMPARISON_EQ;
      break;
    case CmpInst::ICMP_NE:
      CmpPred = KVXMOD::COMPARISON_NE;
      break;
    case CmpInst::ICMP_UGT:
      CmpPred = KVXMOD::COMPARISON_GTU;
      break;
    case CmpInst::ICMP_UGE:
      CmpPred = KVXMOD::COMPARISON_GEU;
      break;
    case CmpInst::ICMP_ULT:
      CmpPred = KVXMOD::COMPARISON_LTU;
      break;
    case CmpInst::ICMP_ULE:
      CmpPred = KVXMOD::COMPARISON_LEU;
      break;
    case CmpInst::ICMP_SGT:
      CmpPred = KVXMOD::COMPARISON_GT;
      break;
    case CmpInst::ICMP_SGE:
      CmpPred = KVXMOD::COMPARISON_GE;
      break;
    case CmpInst::ICMP_SLT:
      CmpPred = KVXMOD::COMPARISON_LT;
      break;
    case CmpInst::ICMP_SLE:
      CmpPred = KVXMOD::COMPARISON_LE;
      break;
    default:
      return false;
    }

    if (IsV1 && VecTy->getScalarSizeInBits() == 8) {
      VectorType *ExtVecTy = VectorType::getExtendedElementVectorType(VecTy);
      if (PredVec < CmpInst::ICMP_SGT) {
        LHS = Builder.CreateZExt(LHS, ExtVecTy);
        RHS = Builder.CreateZExt(RHS, ExtVecTy);
      } else {
        LHS = Builder.CreateSExt(LHS, ExtVecTy);
        RHS = Builder.CreateSExt(RHS, ExtVecTy);
      }
      VecTy = ExtVecTy;
    }
    unsigned PrimSz = VecTy->getPrimitiveSizeInBits();
    unsigned CmpSz = PrimSz >= 64 ? 64 : 32;
    Type *CmpType = IntegerType::get(Ctx, CmpSz);
    Type *I32Ty = IntegerType::getInt32Ty(Ctx);
    Constant *Cst = ConstantInt::get(I32Ty, CmpPred, false);
    if (PrimSz <= 64) {
      CallInst *CI =
          Builder.CreateIntrinsic(Intrinsic::kvx_vec_cmp, {CmpType, VecTy},
                                  {LHS, RHS, Cst}, nullptr, "kvx_vec_cmp");
      Value *R =
          Builder.CreateCmp(PredCast, CI, ConstantInt::getNullValue(CmpType));
      I.replaceAllUsesWith(R);
      return true;
    }
    const int IdxStep = 64 / VecTy->getScalarSizeInBits();
    const int Parts = PrimSz / 64;

    VectorType *SubVecTy =
        VectorType::get(VecTy->getElementType(), IdxStep, false);

    SmallVector<Value *, 4> Values;

    for (int Part = 0; Part < Parts; ++Part) {
      Constant *Idx = ConstantInt::get(CmpType, IdxStep * Part, false);
      CallInst *SubLHS = Builder.CreateExtractVector(SubVecTy, LHS, Idx);
      CallInst *SubRHS = Builder.CreateExtractVector(SubVecTy, RHS, Idx);
      Values.push_back(Builder.CreateIntrinsic(
          Intrinsic::kvx_vec_cmp, {CmpType, SubVecTy}, {SubLHS, SubRHS, Cst},
          nullptr, "kvx_vec_cmp"));
    }
    do {
      SmallVector<Value *, 4> NewValues;
      while (Values.size() > 1) {
        Value *V1 = Values.pop_back_val();
        Value *V2 = Values.pop_back_val();
        NewValues.push_back(Builder.CreateOr(V1, V2, "kvx_join_vec_cmp"));
      }
      if (Values.size())
        NewValues.emplace_back(Values.pop_back_val());

      Values = std::move(NewValues);
    } while (Values.size() > 1);

    Value *R = Builder.CreateCmp(PredCast, Values.pop_back_val(),
                                 ConstantInt::getNullValue(CmpType));
    I.replaceAllUsesWith(R);
    return true;
  }
  return false;
}

bool KVXCodeGenPrepare::runOnFunction(Function &F) {
  if (skipFunction(F))
    return false;

  auto *TPC = getAnalysisIfAvailable<TargetPassConfig>();
  if (!TPC)
    return false;

  bool Changed = false;

#define VISIT(X)                                                               \
  case Instruction::X:                                                         \
    Changed |= visit##X(*I, IsV1);                                             \
    break

  for (BasicBlock &BB : F.getBasicBlockList()) {
    for (auto I = BB.rbegin(), E = BB.rend(); I != E; ++I) {
      if (I->isDebugOrPseudoInst())
        continue;

      switch (I->getOpcode()) {
      default:
        break;
        VISIT(ICmp);
      }
    }
  }
  return Changed;
}
