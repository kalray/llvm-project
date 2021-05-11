//===- AJT.cpp - Thread control through conditional blocks ----------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements the Aggressive Jump Threading pass.
//
//===----------------------------------------------------------------------===//

#include "llvm/Transforms/Scalar/AJT.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/DepthFirstIterator.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SetVector.h"
#include "llvm/Analysis/AssumptionCache.h"
#include "llvm/Analysis/ConstantFolding.h"
#include "llvm/Analysis/GlobalsModRef.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/Analysis/TargetLibraryInfo.h"
#include "llvm/Analysis/TargetTransformInfo.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Dominators.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/Verifier.h"
#include "llvm/InitializePasses.h"
#include "llvm/Pass.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Scalar.h"
#include "llvm/Transforms/Utils.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Transforms/Utils/Local.h"
#include "llvm/Transforms/Utils/LoopSimplify.h"
#include "llvm/Transforms/Utils/LoopUtils.h"
#include "llvm/Transforms/Utils/SSAUpdater.h"

#include <algorithm>
#include <list>
#include <memory>

using namespace llvm;

#define DEBUG_TYPE "ajt"

#ifndef NDEBUG
static const char AJTDbgMsgPrefix[] = "AJT: ";
static const bool ReportTODO = false;
#endif

namespace {

/// This class represents a point of the path consisting of phi-functions which
/// a constant goes through.
/// Const1 -> phi1 -> phi2 -> ... -> phiN -> nullptr
/// Example:
/// 1   3    4   5
/// |   |    |   |
/// v   v    v   v
/// -----    -----
///   |        |
///   v        v
///  phi1     phi2   2
///   |        |     |
///   v        v     v
///   ----------------
///        |
///        v
///       phi3
/// There are five paths for constants:
///    1 -> phi1 -> phi3
///    2 -> phi3
///    3 -> phi1 -> phi3
///    4 -> phi2 -> phi3
///    5 -> phi2 -> phi3
/// There are three phi-functions which are points in data flow paths: phi1, phi2, phi3
/// We just put the tree above into std::list: point and its parent.
/// There is information which points are start points (leaves in tree).
/// It is stored in IncomingConstantsContainer.
class PhiDataFlowPoint {
  PHINode *Phi;
  PhiDataFlowPoint *NextPoint;

public:
  PhiDataFlowPoint(PHINode *PHI, PhiDataFlowPoint *NextPoint)
      : Phi(PHI), NextPoint(NextPoint) {}

  PHINode *getPhi() { return Phi; }

  PhiDataFlowPoint *getNextPoint() { return NextPoint; }
};

/// This pass performs more aggressive jump threading than the JumpThreading
/// pass. The pass can jump over loop heads. As a result it can create
/// unnatural loops.
///
/// Supported terminators: SwitchInst and BranchInst with integer equality
/// comparison.
///
/// Main idea:
///   - if we know all constants incoming into a basic block and successors for
///     them we can jump over this basic block to the corresponding successor.
///   - as a source block of constant might not be an immediate predecessor of
///     of the basic block all basic block the constant passes through must be
///     copied to preserve CFG and DFG correctness.
///
/// Start function: run
class AJT {
public:
  typedef SmallVector<
      std::tuple<ConstantInt *, BasicBlock *, PhiDataFlowPoint *>, 16>
      IncomingConstantsContainer;

  AJT(TargetLibraryInfo *TLI, TargetTransformInfo *TTI) : TLI(TLI), TTI(TTI) {}

  bool run(Function &F);

private:
  typedef SmallPtrSet<const BasicBlock *, 16> SkipBlocksSet;
  typedef SetVector<BasicBlock *> OriginalBlocksSet;

  /// This is an abstract class which defines context needed to optimise
  /// terminator instructions:
  ///  - what constant are collected
  ///  - successors chosen for constants
  ///  - when it's profitable to transform
  class TerminatorContext {
  public:
    IncomingConstantsContainer &getIncomingConstants() {
      return IncomingConstants;
    }
    virtual BasicBlock *getTerminatorSuccForConstant(ConstantInt *C) = 0;
    void collectIncomingConstants();
    Instruction *getTerminator() { return Terminator; }
    PHINode *getStartingPoint() { return StartingPoint; }

  protected:
    TerminatorContext(PHINode *Phi, Instruction *T) : StartingPoint(Phi), Terminator(T) {
      assert(StartingPoint);
      assert(Terminator);
    }
    virtual ~TerminatorContext() {}
    TerminatorContext(const TerminatorContext &) = delete;
    TerminatorContext& operator=(const TerminatorContext &) = delete;
  private:
    PHINode *StartingPoint;
    Instruction *Terminator;
    IncomingConstantsContainer IncomingConstants;
    std::list<PhiDataFlowPoint> DataFlowPoints;
  };

  /// Define context needed to optimise switch instructions:
  ///  - successors chosen for constants
  ///  - when it's profitable to transform
  class SwitchInstContext: public TerminatorContext {
  public:
    explicit SwitchInstContext(PHINode *StartingPoint, SwitchInst *I) : TerminatorContext(StartingPoint, I) {
    }
    SwitchInstContext(const SwitchInstContext&) = delete;
    SwitchInstContext& operator=(const SwitchInstContext&) = delete;

    BasicBlock *getTerminatorSuccForConstant(ConstantInt *C) {
      assert(C);
      return cast<SwitchInst>(getTerminator())->findCaseValue(C)->getCaseSuccessor();
    }
  };

  OriginalBlocksSet        OriginalBlocks;
  SkipBlocksSet            SkipConstantSources;
  std::list<BasicBlock*>   UnfoldedOriginalBlocks;
  std::list<BasicBlock*>   DeletedBlocksBin;
  const TargetLibraryInfo *TLI = nullptr;
  const TargetTransformInfo *TTI = nullptr;
  int                      BasicBlockCopiesCounter = 0;

  bool isSupported(const BasicBlock &B);
  void init(Function &F);
  void createOriginalBlocksSet(Function &F);
  bool isBlockAllowedToCopy(BasicBlock &BB);
  bool applyAJT(BasicBlock &BB);
  void deleteDeadBlock(BasicBlock *BB);
  void mergeBlockWithSCPred(BasicBlock &BB);
  void changeBlockSuccToSuccOfSucc(BasicBlock *BB, BasicBlock *OldSucc,
                                   BasicBlock *NewSucc);
  bool redirectCFPathFromBlockToItsSuccForConst(BasicBlock *Block,
                                                BasicBlock *BlockSucc,
                                                ConstantInt *C,
                                                BasicBlock *ConstSourceBlock,
                                                PhiDataFlowPoint *DataFlowStartPoint);
  void changeBlockSuccToNewSuccCopy(BasicBlock *BB,
                                    BasicBlock *Succ,
                                    BasicBlock *SuccCopy,
                                    ValueToValueMapTy &V2VMap);
  bool createAlternativeCFPath(TerminatorContext &TerminatorCtxt);
  void simplifyCFG(Function &F);
  void
  findSelectInstructionsToUnfoldRec(PHINode *Phi,
                                    SmallPtrSetImpl<PHINode *> &SeenPhis,
                                    SetVector<SelectInst *> &SelectInsts);
  bool tryToUnfoldSelectInstructions(PHINode &StartPhi);
  PHINode *tryToUnfoldSelectInstruction(SelectInst &SI);
  void correctInstructionsAfterCopying(BasicBlock *OriginalBlock,
                                    BasicBlock *BlockCopy,
                                    BasicBlock *PredToRedirect,
                                    ValueToValueMapTy &V2VMap);
  void eraseDeletedBlocks() {
    while (!DeletedBlocksBin.empty()) {
      BasicBlock *B = DeletedBlocksBin.front();
      removeFromOriginalBlocks(B);
      SkipConstantSources.erase(B);
      DeletedBlocksBin.pop_front();
    }
  }
  void removeFromOriginalBlocks(const BasicBlock *BB);
  bool isAmountOfInstructionsToCopyBig(SmallVectorImpl<BasicBlock *> &BlocksToCopy);
  bool isBlockDeleted(BasicBlock *BB) {
    return (std::find(DeletedBlocksBin.begin(), DeletedBlocksBin.end(), BB)
            != DeletedBlocksBin.end());
  }
};

class AJTLegacyPass : public FunctionPass {
public:
  static char ID; // Pass identification

  AJTLegacyPass() : FunctionPass(ID) {}

  bool runOnFunction(Function &F) override {
    if (skipFunction(F))
      return false;

    auto *TLI = &getAnalysis<TargetLibraryInfoWrapperPass>().getTLI(F);
    auto *TTI = &getAnalysis<TargetTransformInfoWrapperPass>().getTTI(F);
    return AJT(TLI, TTI).run(F);
  }

  StringRef getPassName() const override { return "Aggressive Jump Threading"; }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addRequired<TargetLibraryInfoWrapperPass>();
    AU.addRequired<TargetTransformInfoWrapperPass>();
    AU.addRequiredID(LCSSAID);
    AU.addPreserved<GlobalsAAWrapperPass>();
  }
};
}

char AJTLegacyPass::ID = 0;
INITIALIZE_PASS_BEGIN(AJTLegacyPass, "ajt", "Aggressive Jump Threading", false,
                      false)
INITIALIZE_PASS_DEPENDENCY(TargetLibraryInfoWrapperPass)
INITIALIZE_PASS_DEPENDENCY(TargetTransformInfoWrapperPass)
INITIALIZE_PASS_DEPENDENCY(LCSSAWrapperPass)
INITIALIZE_PASS_END(AJTLegacyPass, "ajt", "Aggressive Jump Threading", false,
                    false)

FunctionPass *llvm::createAJTPass() { return new AJTLegacyPass(); }

static bool isBlockUnreachable(BasicBlock *B) {
  assert(B);
  return (pred_empty(B) || B->getUniquePredecessor() == B);
}

/// Returns true if the specified block is allowed to copy.
bool AJT::isBlockAllowedToCopy(BasicBlock &BB) {
  (void)(TTI);
  /*for (auto &Inst: BB.getInstList()) {
    // copying calls might increase pressure on hardware branch predictors.
    if (const auto *Call = dyn_cast<CallBase>(&Inst)) {
      if (TargetTransformInfo::TCC_Free !=
          TTI->getUserCost(Call, TargetTransformInfo::TCK_SizeAndLatency)) {
        LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix
          << "Not TCC_Free call: " << *Call << "\n");
        return false;
      }
    }
  }*/

  //copying such might increase pressure on hardware branch predictors.
  //return (BB.getTerminator()->getNumSuccessors() <= CopyableBlockMaxSuccessors);
  return true;
}

/// Blocks without incoming edges can be deleted as they are unreachable.
void AJT::deleteDeadBlock(BasicBlock *BB) {
  assert(BB);
  assert(isBlockUnreachable(BB) && "The block must not have predecessor.");

  DeleteDeadBlock(BB);
  DeletedBlocksBin.push_back(BB);
}

void AJT::removeFromOriginalBlocks(const BasicBlock *BB) {
  if (std::find(OriginalBlocks.begin(), OriginalBlocks.end(), BB) !=
      OriginalBlocks.end())
    OriginalBlocks.erase(
        std::find(OriginalBlocks.begin(), OriginalBlocks.end(), BB));
}

// Check if the specified basic block is singly connected to its predecessor.
static bool isPredecessorSinglyConnectedTo(const BasicBlock &BB) {
  if (const BasicBlock *SinglePred = BB.getSinglePredecessor()) {
    if (SinglePred->getTerminator()->getNumSuccessors() == 1 &&
        !BB.hasAddressTaken()) {
      assert(SinglePred != &BB && "Unreachable single node loop.");
      return true;
    }
  }
  return false;
}

/// Merge the specified basic block with its singly connected predecessor.
void AJT::mergeBlockWithSCPred(BasicBlock &BB) {
  assert(isPredecessorSinglyConnectedTo(BB));
  removeFromOriginalBlocks(BB.getSinglePredecessor());
  SkipConstantSources.erase(BB.getSinglePredecessor());
  MergeBasicBlockIntoOnlyPred(&BB);
}

/// Collect constants and their paths through phi-functions
///
/// \param CurPhi the current analysed phi-function
/// \param SeenPhis seen phi-functions
/// \param IncomingConstants the container where found incoming constants
///  and their start point to phi-functions are stored
/// \param DataFlowPoints storage for path consisting of linked phi-functions
/// \param NextPoint as constant is looked in up directions NextPoint is
/// a phi-function next to the current phi-function in down direction from the
/// source block of constant to the current block.
///
/// \returns true if constants have been found
static bool collectConstants(PHINode *CurPhi,
                             SmallPtrSetImpl<PHINode *> &SeenPhis,
                             AJT::IncomingConstantsContainer &IncomingConstants,
                             std::list<PhiDataFlowPoint> &DataFlowPoints,
                             PhiDataFlowPoint *NextPoint) {
  assert(CurPhi);
  if (!SeenPhis.insert(CurPhi).second)
    return false;

  // phi-functions might have several same incoming blocks
  SmallPtrSet<BasicBlock *, 8> SeenBlocks;
  SmallSetVector<PHINode *, 8> UniquePhis; // UniquePhis must have a deterministic ordered set
  SmallVector<unsigned, 8> InConstantsIds;
  for (unsigned I = 0, E = CurPhi->getNumIncomingValues(); I != E; ++I) {
    if (!SeenBlocks.insert(CurPhi->getIncomingBlock(I)).second) {
      continue;
    }

    Value *InValue = CurPhi->getIncomingValue(I);
    if (isa<ConstantInt>(InValue)) {
      InConstantsIds.push_back(I);
    } else if (PHINode *Phi = dyn_cast<PHINode>(InValue)) {
      if (!UniquePhis.insert(Phi) && !SeenPhis.count(Phi)) {
        assert(!ReportTODO && "Implement collecting constants for CF like diamonds etc.");
        LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix
                       << "<Collecting constants> Unsupported CF: phi-function "
                       << CurPhi->getName() << " has phi-function " << Phi->getName() << " incoming from different basic blocks.\n");

        return false;
      }
    }
  }

  DataFlowPoints.push_back(PhiDataFlowPoint{CurPhi, NextPoint});// create a new point
  PhiDataFlowPoint *CurrPoint = &DataFlowPoints.back();

  bool FoundConstants = !InConstantsIds.empty();
  for (unsigned Id: InConstantsIds) {
    IncomingConstants.push_back(std::make_tuple(cast<ConstantInt>(CurPhi->getIncomingValue(Id)),
                                                CurPhi->getIncomingBlock(Id),
                                                CurrPoint));
  }

  // FIXME: The ability of performing optimizations depends on the order we iterate
  for (PHINode *Phi: UniquePhis) {
    FoundConstants |= collectConstants(Phi, SeenPhis, IncomingConstants,
                                       DataFlowPoints, CurrPoint);
  }

  if (!FoundConstants)
    DataFlowPoints.pop_back();

  return FoundConstants;
}

/// Change terminator target.
static int changeteTerminatorTarget(Instruction *T, BasicBlock *OldSucc,
                                    BasicBlock *NewSucc) {
  assert(T);
  assert(OldSucc);
  assert(NewSucc);
  int NumEdgesToNewSucc = 0;
  for (unsigned I = 0, E = T->getNumSuccessors(); I < E; ++I) {
    if (T->getSuccessor(I) == OldSucc) {
      T->setSuccessor(I, NewSucc);
      ++NumEdgesToNewSucc;
    }
  }
  return NumEdgesToNewSucc;
}

/// \brief Change the successor of the block from the current successor to the
/// successor of the current successor. Update phi-funcions.
///
/// \param[in,out] BB the basic block which successor is changed
/// \param[in,out] CurBBSucc the current BB successor
/// \param[in,out] CurBBSuccSucc the successor of the successor of BB
void AJT::changeBlockSuccToSuccOfSucc(BasicBlock *BB, BasicBlock *CurBBSucc,
                                      BasicBlock *CurBBSuccSucc) {
  assert(BB);
  assert(CurBBSucc);
  assert(CurBBSuccSucc);
  assert(std::find(succ_begin(CurBBSucc), succ_end(CurBBSucc), CurBBSuccSucc) !=
         succ_end(CurBBSucc));
  assert(std::find(succ_begin(BB), succ_end(BB), CurBBSucc) != succ_end(BB));

  int NumEdgesToCurBBSuccFromBB = changeteTerminatorTarget(BB->getTerminator(), CurBBSucc, CurBBSuccSucc);
  assert(NumEdgesToCurBBSuccFromBB >= 1);

  // update phi-functions of CurBBSuccSucc to have an incoming value from BB.
  for (auto I = CurBBSuccSucc->begin(); isa<PHINode>(I);) {
    PHINode *Phi = cast<PHINode>(I++);
    if (Phi->use_empty()) {
      Phi->eraseFromParent();
      continue;
    }

    // Find a value coming from CurBBSucc. This value needs to come from BB
    // through all edges from BB to CurBBSuccSucc.
    for (unsigned Id = 0, IdE = Phi->getNumIncomingValues(); Id < IdE; ++Id) {
      if (Phi->getIncomingBlock(Id) != CurBBSucc)
        continue;

      Value *V = Phi->getIncomingValue(Id);
      if (PHINode *InPhi = dyn_cast<PHINode>(V)) {
        if (InPhi->getParent() == CurBBSucc) {
          V = InPhi->getIncomingValueForBlock(BB);
          assert(V);
        }
      }
      // If there are different values coming from BB they need to be changed to
      // V.
      for (unsigned Id1 = 0; Id1 < IdE; ++Id1) {
        if (Phi->getIncomingBlock(Id1) == BB &&
            Phi->getIncomingValue(Id1) != V) {
          Phi->setIncomingValue(Id1, V);
        }
      }
      for (int i = 0; i < NumEdgesToCurBBSuccFromBB; ++i) {
        Phi->addIncoming(V, BB);
      }
      break;
    }
  }

  if (isBlockUnreachable(CurBBSucc)) {
    for (auto I = CurBBSucc->begin(); isa<PHINode>(I);) {
      PHINode *Phi = cast<PHINode>(I++);

      assert(Phi->getBasicBlockIndex(BB) != -1);

      if (!Phi->use_empty()) {
        Value *V = Phi->getIncomingValue(0);
        Phi->replaceAllUsesWith(V);
      }
      Phi->eraseFromParent();
    }
  } else {
    // correct SSA form as phi-functions in CurBBSucc are changed
    SSAUpdater SSAUp;
    SmallVector<Use*, 16> UsesToRewrite;
    for (auto I = CurBBSucc->begin(); isa<PHINode>(I);) {
      PHINode *Phi = cast<PHINode>(I++);

      if (Phi->use_empty()) {
        Phi->eraseFromParent();
        continue;
      }

      assert(Phi->getBasicBlockIndex(BB) != -1);

      // As BB is disconnected from CurBBSucc all incoming values from BB
      // must be removed from Phi.
      const bool DontDeletePHIIfEmpty = false;
      Value *V = Phi->removeIncomingValue(BB, DontDeletePHIIfEmpty);
      for (int i = 1; i < NumEdgesToCurBBSuccFromBB; ++i) {
        Phi->removeIncomingValue(BB, DontDeletePHIIfEmpty);
      }
      if (!Phi->getNumOperands()) {
        Phi->replaceAllUsesWith(UndefValue::get(Phi->getType()));
        Phi->eraseFromParent();
        continue;
      }

      assert(Phi->getBasicBlockIndex(BB) == -1);

      // Find external uses of Phi
      for (Use &U : Phi->uses()) {
        if (Instruction *User = dyn_cast<Instruction>(U.getUser())) {
          if (PHINode *UserPN = dyn_cast<PHINode>(User)) {
            if (UserPN->getIncomingBlock(U) == CurBBSucc)
              continue;
          } else if (User->getParent() == CurBBSucc) {
            continue;
          }

          UsesToRewrite.push_back(&U);
        }
      }

      if (UsesToRewrite.empty())
        continue;

      SSAUp.Initialize(V->getType(), V->getName());
      SSAUp.AddAvailableValue(BB, V); // V comes form BB
      SSAUp.AddAvailableValue(CurBBSucc, Phi); // Phi comes form CurBBSucc
      while (!UsesToRewrite.empty())
        SSAUp.RewriteUse(*UsesToRewrite.pop_back_val());
    }
  }
}

/// \brief Correct instructions in OriginalBlock, its copy and successors of OriginalBlock.
///
/// \param[in,out] OriginalBlock  the original block
/// \param[in,out] BlockCopy      the copy of OriginalBlock
/// \param[in]      PredToRedirect the predecessor of OriginalBlock which is redirected to the copy
/// \param[in]      V2VMap mapping between instructions from OriginalBlock and their copies from BlockCopy
void AJT::correctInstructionsAfterCopying(BasicBlock *OriginalBlock,
                                          BasicBlock *BlockCopy,
                                          BasicBlock *PredToRedirect,
                                          ValueToValueMapTy &V2VMap) {
  assert(OriginalBlock);
  assert(BlockCopy);
  assert(PredToRedirect);

  // update phi-functions in OriginalBlock and BlockCopy:
  //   - for phi-functions from OriginalBlock incoming values from PredToRedirect are removed
  //   - for phi-functions from BlockCopy incoming values from PredToRedirect are added
  for (auto I = OriginalBlock->begin(); isa<PHINode>(I); ++I) {
    PHINode *Phi = cast<PHINode>(I);
    assert(V2VMap[Phi]);
    PHINode *PhiCopy = cast<PHINode>(V2VMap[Phi]);
    // As a copy block does not have incoming blocks yet all its phi-functions should empty.
    PHINode *EmptyPhi = PHINode::Create(PhiCopy->getType(), 0, PhiCopy->getName(), PhiCopy);
    PhiCopy->replaceAllUsesWith(EmptyPhi);
    V2VMap[&*I] = EmptyPhi;
    PhiCopy->eraseFromParent();
    PhiCopy = EmptyPhi;

    for (unsigned Id = 0; Id < Phi->getNumIncomingValues(); ) {
      if (Phi->getIncomingBlock(Id) != PredToRedirect) {
        ++Id;
        continue;
      }

      Value *V = Phi->getIncomingValue(Id);
      PhiCopy->addIncoming(V, PredToRedirect);
      Phi->removeIncomingValue(Id, false);
    }
    assert(Phi->getBasicBlockIndex(PredToRedirect) == -1);
  }

  // correct instructions in OriginalBlock and BlockCopy
  for (auto I = OriginalBlock->begin(), E = OriginalBlock->end(); I != E; ++I) {
    if (I->use_empty())
      continue;

    assert(isa<Instruction>(V2VMap[&*I]));
    Instruction *ICopy = cast<Instruction>(V2VMap[&*I]);

    SmallPtrSet<Instruction*, 16> UsersToUpdate;
    for (auto UseIt = I->use_begin(), UseE = I->use_end(); UseIt != UseE; ++UseIt) {
      if (Instruction *IUser = dyn_cast<Instruction>(UseIt->getUser())) {
        if (IUser->getParent() == OriginalBlock)
          continue; // don't need to updates users inside the original block

        if (IUser->getParent() == BlockCopy) {
          // uses inside the block copy must updated to uses of the instruction copy
          UsersToUpdate.insert(IUser);
          continue;
        }
      }
    }
    for (auto User: UsersToUpdate)
      User->replaceUsesOfWith(&*I, ICopy);
  }

  // Update phi-functions of OriginalBlock successors to take into account incoming values from BlockCopy
  SmallPtrSet<BasicBlock*, 16> SeenSuccessors;
  for (auto SuccIt = succ_begin(OriginalBlock), SuccItE = succ_end(OriginalBlock);
          SuccIt != SuccItE; ++SuccIt) {
    if (!SeenSuccessors.insert(*SuccIt).second)
      continue;
    for (auto I = SuccIt->begin(); isa<PHINode>(I); ++I) {
      PHINode *Phi = cast<PHINode>(I);
      Value *V = nullptr;
      int VCount = 0;
      for (unsigned Id = 0, IdE = Phi->getNumIncomingValues(); Id != IdE; ++Id) {
        if (Phi->getIncomingBlock(Id) != OriginalBlock)
          continue;

        V = Phi->getIncomingValue(Id);
        ++VCount;
      }

      assert(V);
      if (Instruction *Inst = dyn_cast<Instruction>(V)) {
        Value *InstCopy = V2VMap[Inst];
        if (InstCopy)
          V = InstCopy;
      }

      for (; VCount > 0; --VCount)
        Phi->addIncoming(V, BlockCopy);
    }
  }
}

/// \brief Change the successor of the specified block to successor copy and correct
/// phi-functions.
///
/// \param[in,out] BB the basic block which successor is changed
/// \param[in,out] Succ the current successor of BB
/// \param[in,out] SuccCopy the copy of the current successor Succ which becomes a successor instead of Succ
/// \param[in]      V2VMap mapping between instructions from Succ and their copies from SuccCopy
void AJT::changeBlockSuccToNewSuccCopy(BasicBlock *BB,
                                       BasicBlock *Succ,
                                       BasicBlock *SuccCopy,
                                       ValueToValueMapTy &V2VMap) {
  assert(BB);
  assert(Succ);
  assert(SuccCopy);
  assert(std::find(succ_begin(BB), succ_end(BB), SuccCopy) == succ_end(BB));
  assert(std::find(succ_begin(BB), succ_end(BB), Succ) != succ_end(BB));
  assert(std::find(succ_begin(Succ), succ_end(Succ), SuccCopy) ==
         succ_end(Succ));

  correctInstructionsAfterCopying(Succ, SuccCopy, BB, V2VMap);
  changeteTerminatorTarget(BB->getTerminator(), Succ, SuccCopy);

  // correct SSA form
  SSAUpdater SSAUp;
  SmallVector<Use*, 16> UsesToRewrite;
  for (auto I = Succ->begin(), E = Succ->end(); I != E; ++I) {
    for (Use &U : I->uses()) {
      Instruction *User = cast<Instruction>(U.getUser());
      assert(User->getParent() != SuccCopy);
      if (PHINode *UserPN = dyn_cast<PHINode>(User)) {
        if (UserPN->getIncomingBlock(U) == Succ)
          continue;
      } else if (User->getParent() == Succ) {
        continue;
      }

      UsesToRewrite.push_back(&U);
    }

    if (UsesToRewrite.empty())
      continue;

    assert(V2VMap[&*I]);
    assert(isa<Instruction>(V2VMap[&*I]));
    Instruction *ICopy = cast<Instruction>(V2VMap[&*I]);
    SSAUp.Initialize(I->getType(), I->getName());
    SSAUp.AddAvailableValue(Succ, &*I); // I comes form Succ
    SSAUp.AddAvailableValue(SuccCopy, ICopy); // ICopy comes form SuccCopy
    while (!UsesToRewrite.empty())
      SSAUp.RewriteUse(*UsesToRewrite.pop_back_val());
  }
}

// Recursively check that there is a data flow path from phi-function Phi1 to phi-function Phi2
static bool isPhiConnectedToPhiRec(PHINode *Phi1, PHINode *Phi2, SmallPtrSetImpl<PHINode *> &SeenPhis) {
  assert(Phi1);
  assert(Phi2);
  if (Phi2 == Phi1)
    return true; //reached

  if (!SeenPhis.insert(Phi2).second)
    return false; // Cannot reach Phi1 via this way

  for (Use &U: Phi2->operands()) {
    if (PHINode *Phi = dyn_cast<PHINode>(U.get())) {
      if (isPhiConnectedToPhiRec(Phi1, Phi, SeenPhis))
        return true;
    }
  }

  return false;
}

// Check if phi-function Phi1 is connected to phi-function Phi2
// (there is a data flow path from Phi1 to Phi2) via phi-function Phi3
static bool isPhiConnectedToPhiViaPhi(PHINode *Phi1, PHINode *Phi2, PHINode *Phi3) {
  SmallPtrSet<PHINode *, 16> SeenPhis;
  SeenPhis.insert(Phi2); // marked Phi2 as seen not to have loop
  return isPhiConnectedToPhiRec(Phi1, Phi3, SeenPhis);
}

// For phi-function PhiValue find a basic block from which the value defined by PhiValue comes to PhiUser.
// Note: Phi1 can be in a block which is not immediate predecessor of the parent block of Phi2.
// Note: There must be only incoming block into Phi1 for Phi2.
static BasicBlock *findBlockIncomingIntoPhiWithValueOfPhi(PHINode* PhiUser, PHINode* PhiValue) {
  // there should be only path from PhiValue to PredUser
  assert(std::count_if(PhiUser->op_begin(), PhiUser->op_end(),
                       [PhiUser, PhiValue](Use& U){
                          return isa<PHINode>(U.get())
                                 && isPhiConnectedToPhiViaPhi(PhiValue, PhiUser, cast<PHINode>(U.get()));
                       }) == 1);

  for (Use &U: PhiUser->operands()) {
    if (PHINode *Phi = dyn_cast<PHINode>(U.get())) {
      // There might be new created phi-functions between PhiUser and PredValue
      if (isPhiConnectedToPhiViaPhi(PhiValue, PhiUser, Phi))
        return PhiUser->getIncomingBlock(U);
    }
  }
  return nullptr;
}

/// \brief Collect all basic blocks between basic blocks of connected phi-functions.
template <typename OutputIt>
bool collectBlocksBetweenConnectedPhis(OutputIt OI, PHINode *PredPhi,
                                PHINode *Phi) {
  assert(PredPhi);
  assert(Phi);
  assert(PredPhi != Phi);
  assert(PredPhi->getParent() != Phi->getParent());

  // Go down and add all unique successors.
  // We can reach a block which does not have an unique successor and is not
  // a parent block of Phi. The previous seen block is stored into PrevB.
  BasicBlock *StoppedBlock = nullptr;
  for (BasicBlock *B = PredPhi->getParent()->getUniqueSuccessor(), *E = Phi->getParent();
          B; B = B->getUniqueSuccessor()) {
    if (B == E)
      return true; // Reached a parent block of Phi. All blocks are added.
    OI = B;
    ++OI;
    StoppedBlock = B;
  }

  if (!StoppedBlock) {
    assert(!ReportTODO && "implement copying CF: diamond/triangle control flow");
    return false;
  }

  SmallVector<BasicBlock *, 8> BBlocks;
  // Go up and add all unique predecessors
  for (BasicBlock *B = findBlockIncomingIntoPhiWithValueOfPhi(Phi, PredPhi);
       B != StoppedBlock; B = B->getUniquePredecessor()) {
    if (!B) {
      assert(!ReportTODO && "implement copying CF: diamond/triangle control flow");
      return false;
    }
    BBlocks.push_back(B);
  }
  std::copy(BBlocks.rbegin(), BBlocks.rend(), OI);
  return true;
}

// There are blocks between connected phi-functions when a basic block of one phi-function
// is not an incoming basic block of another phi-function.
static bool areThereBlocksBetweenConnectedPhis(PHINode *PredPhi, PHINode *Phi) {
  if (!PredPhi)
    return false;

  assert(Phi);

  return Phi->getBasicBlockIndex(PredPhi->getParent()) == -1;
}

/// \brief Create a list of blocks which need to be copied to preserve correctness of CF
/// after redirecting CF.
///
/// \param[out] OI output iterator which is an interface to storage where to put blocks
/// \param[in] DataFlowStartPoint This is a list of phi-function which the constant goes through.
/// \param[in] FinalBlock a final block which the constant comes in.
template <typename OutputIt>
void createListOfBlocksToCopy(OutputIt OI, PhiDataFlowPoint *DataFlowStartPoint,
                              BasicBlock *FinalBlock) {
  assert(DataFlowStartPoint);
  assert(DataFlowStartPoint->getPhi());
  assert(FinalBlock);

  PHINode *Phi = nullptr; // current phi-function
  PHINode *PrevPhi = nullptr; // previous phi-function
  PhiDataFlowPoint *DataFlowPoint = DataFlowStartPoint;
  while (DataFlowPoint && DataFlowPoint->getPhi()->getParent() != FinalBlock) {
    PrevPhi = Phi;
    Phi = DataFlowPoint->getPhi();
    // there might be blocks between the basic block of PrevPhi and the basic
    // block of the current Phi. They also must be out on the list.
    if (areThereBlocksBetweenConnectedPhis(PrevPhi, Phi)) {
      if (!collectBlocksBetweenConnectedPhis(OI, PrevPhi, Phi)) {
        LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix
                       << "<Create list of blocks to copy> Unsupported CF between phi-functions: "
                       << PrevPhi->getName() << " and " << Phi->getName() << '\n');
        return;
      }
    }

    OI = Phi->getParent();
    ++OI;
    DataFlowPoint = DataFlowPoint->getNextPoint();
  }

  if (DataFlowPoint) { // we reached FinalBlock
    PrevPhi = Phi;
    Phi = DataFlowPoint->getPhi();
    // add all blocks between basic blocks of phi-functions
    if (areThereBlocksBetweenConnectedPhis(PrevPhi, Phi)) {
      if (!collectBlocksBetweenConnectedPhis(OI, PrevPhi, Phi)) {
        LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix
                       << "<Create list of blocks to copy> Unsupported CF between phi-functions: "
                       << PrevPhi->getName() << " and " << Phi->getName() << '\n');
        return;
      }
    }
    return;
  }

  assert(Phi);

  // we need to add all block between FinalBlock and the basic block of the last
  // phi-function. As they don't have phi-functions they are unique predecessors
  // of each another.
  SmallVector<BasicBlock *, 8> BBlocks;
  for (BasicBlock *Pred = FinalBlock->getUniquePredecessor();
       Pred && Pred != Phi->getParent(); Pred = Pred->getUniquePredecessor()) {
    BBlocks.push_back(Pred);
  }
  if (!BBlocks.empty() && !BBlocks.back()->getUniquePredecessor()) {
    LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix
                   << "<Create list of blocks to copy> Unsupported CF: "
                   << BBlocks.back() << " does not have an unique predecessor.\n");
    return;
  }
  std::copy(BBlocks.rbegin(), BBlocks.rend(), OI);
}

/// Count executable instructions in the specified basic block.
static int countExecutableInstructionsInBlock(BasicBlock *B) {
  assert(B);
  int Count = 0;
  for (auto I = B->begin(), E = B->end(); I != E; ++I) {
    if (isa<PHINode>(I))
      continue;
    // Debugger intrinsics don't incur code size.
    if (isa<DbgInfoIntrinsic>(I))
      continue;

    // If this is a pointer->pointer bitcast, it is free.
    if (isa<BitCastInst>(I) && I->getType()->isPointerTy())
      continue;

    ++Count;
  }
  return Count;
}

// Define max allowed percent of instructions (comparing to instructions
// from original blocks) to be copied.
// TODO: Temporarily set 80% as it needs to be tuned.
static const int MaxPercentInstructionsToBeCopied = 80;

/// Assess if amount of instruction to be copied in not big.
bool AJT::isAmountOfInstructionsToCopyBig(SmallVectorImpl<BasicBlock*>& BlocksToCopy) {
  assert(!OriginalBlocks.empty()); // We always make copies from original blocks. Why is the set empty?
  assert(!BlocksToCopy.empty());   // No blocks to copy. Strange.
  assert(!ReportTODO && "Tune parameter: MaxPercentInstructionsToBeCopied");
  int OriginalBlocksExeInstrCount = 0;
  for (auto BB: OriginalBlocks) {
    // Check BB is not in DeletedBlocksBin
    if (isBlockDeleted(BB))
      continue;
    OriginalBlocksExeInstrCount += countExecutableInstructionsInBlock(BB);
  }

  int CopiedBlocksExeInstrCount = 0;
  for (auto BB: BlocksToCopy) {
    CopiedBlocksExeInstrCount += countExecutableInstructionsInBlock(BB);
  }
  LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix
               << "<Estimating amount instructions to copy>"
               << " Original blocks instructions count " << OriginalBlocksExeInstrCount
               << ". Copied blocks instructions count "   << CopiedBlocksExeInstrCount
               << ". %: " << ((CopiedBlocksExeInstrCount*100) / OriginalBlocksExeInstrCount)
               << ". Max % allowed: " << MaxPercentInstructionsToBeCopied
               << '\n');

  return (CopiedBlocksExeInstrCount*100) / OriginalBlocksExeInstrCount > MaxPercentInstructionsToBeCopied;
}

/// \brief Redirect CF path from Block to the block(BlockSucc) which is Block's
/// successor for incoming constant C.
///
/// As the block(ConstSourceBlock) which is a source of constant C might not be
/// an immediate predecessor of Block all blocks between ConstSourceBlock and Block
/// must be copied.
///
/// \param[in] Block This is a basic block from which CF is redirected to its successor.
/// \param[in] BlockSucc This is a block which is jumped to when an incoming constant is C.
/// \param[in] C The constant for which CF path is redirected.
/// \param[in] ConstSourceBlock The block which is a source of the constant.
/// \param[in] DataFlowStartPoint This is a list of phi-function which the constant goes through.
///            It's used to create a list of blocks to be copied.
///
/// \returns  true if CF path has been redirected.
bool AJT::redirectCFPathFromBlockToItsSuccForConst(BasicBlock *Block,
                                                   BasicBlock *BlockSucc,
                                                   ConstantInt *C,
                                                   BasicBlock *ConstSourceBlock,
                                                   PhiDataFlowPoint *DataFlowStartPoint) {
  assert(C);
  assert(ConstSourceBlock);
  assert(DataFlowStartPoint);
  assert(DataFlowStartPoint->getPhi());
  assert(Block);
  assert(BlockSucc);

  // from the previous runs it's known that redirecting this constant does not improve CF
  if (SkipConstantSources.count(ConstSourceBlock)) {
    LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix << "<Creating alternative path> Skipped: constant '" << *C
                 << "' from BB " << ConstSourceBlock->getName() << '\n');
    return false;
  }

  // The goal is to optimise the original CF.
  // Blocks sources of constants are not copied. So if we meet a block source of
  // constant which is not original. It is a result of simplifying of CF: merging empty blocks.
  // We will copy blocks which might be empty. After simplifying we will have the similar CF as before.
  // Then optimising this again the third copy of the same CF will be created and so on.
  // We have fallen into an infinitive copy cycle.
  if (!OriginalBlocks.count(ConstSourceBlock)) {
    LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix << "<Creating alternative path> Copy cycle "
                                       "detected. Skipped: constant '" << *C
                 << "' from BB " << ConstSourceBlock->getName() << '\n');
    SkipConstantSources.insert(ConstSourceBlock); // skip this constant in the future
    return false;
  }

  SmallVector<BasicBlock *, 16> BlocksToCopy;
  createListOfBlocksToCopy(std::back_inserter(BlocksToCopy), DataFlowStartPoint,
                           Block);

  // Another possible infinitive copy cycle:
  // Path of constant might look like:
  //    ConstSourceBlock -> BlockSucc -> SomeBlock -> Block -> BlockSucc
  // Alternative path will be created:
  //    ConstSourceBlock -> BlockSucc(copy) -> SomeBlock(copy) -> BlockSucc
  // 'ConstSourceBlock -> BlockSucc(copy) -> SomeBlock(copy)' might be merged into one block:
  //  ConstSourceBlock_new_merged_block
  // So there will be the same CF:
  //  ConstSourceBlock_new_merged_block -> BlockSucc -> SomeBlock -> Block
  if (std::find(BlocksToCopy.begin(), BlocksToCopy.end(), BlockSucc) !=
      BlocksToCopy.end()) {
    LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix << "<Creating alternative path> Copy cycle "
                                       "detected. Skipped: constant '" << *C
                 << "' from BB " << ConstSourceBlock->getName() << '\n');
    SkipConstantSources.insert(ConstSourceBlock);
    return false;
  }

  // Check if all blocks can be copied.
  if (std::any_of(
          BlocksToCopy.begin(), BlocksToCopy.end(),
          [this](BasicBlock *B) { return !this->isBlockAllowedToCopy(*B); })) {
    LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix
                 << "<Creating alternative path> Non-copyable node detected. "
                    "Skipped: constant '" << *C << "' from BB "
                 << ConstSourceBlock->getName() << '\n');
    return false;
  }

  // Check if a path to the final Block is constructed.
  // Only simple paths (without diamond-like structures etc.) are supported.
  // TODO: support diamonds.
  if (BlocksToCopy.empty()
      || std::find(succ_begin(BlocksToCopy.back()), succ_end(BlocksToCopy.back()), Block)
          == succ_end(BlocksToCopy.back())) {
    LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix
                 << "<Creating alternative path> Complicated path detected. "
                    "Skipped: constant '" << *C << "' from BB "
                 << ConstSourceBlock->getName() << '\n');
    return false;
  }

  if (isAmountOfInstructionsToCopyBig(BlocksToCopy)) {
    LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix
                 << "<Creating alternative path> Amount of instructions being copied is big. "
                    "Skipped: constant '" << *C << "' from BB "
                 << ConstSourceBlock->getName() << '\n');
    return false;
  }

  LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix
               << "<Creating alternative path> Copying blocks on path from "
               << ConstSourceBlock->getName() << "\n");
  // Copy blocks
  BasicBlock *BlockToRedirect = ConstSourceBlock;
  for (auto BB : BlocksToCopy) {
    // if a basic block has an unique predecessor there no other CF paths through it.
    // So we don't need to copy it.
    if (BB->getUniquePredecessor()) {
      BlockToRedirect = BB;
      continue;
    }

    ValueToValueMapTy V2VMap;
    BasicBlock *BBCopy = CloneBasicBlock(
        BB, V2VMap, ".c" + Twine(++BasicBlockCopiesCounter), BB->getParent());
    changeBlockSuccToNewSuccCopy(BlockToRedirect, BB, BBCopy, V2VMap);
    // IR must be valid after our transformations.
    assert(verifyFunction(*(BlockSucc->getParent()), &dbgs()) == false);

    BlockToRedirect = BBCopy;
    LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix
                 << "<Creating alternative path> Copied " << BB->getName()
                 << " as " << BBCopy->getName() << "\n");
  }

  // finally redirect CF from the specified block to its successor for constant C
  changeBlockSuccToSuccOfSucc(BlockToRedirect, Block, BlockSucc);
  assert(isBlockUnreachable(Block) || verifyFunction(*(BlockSucc->getParent()), &dbgs()) == false);
  LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix
                 << "<Creating alternative path> Redirected CF for " << BlockToRedirect->getName()
                 << " from " << Block->getName()
                 << " to "   << BlockSucc->getName() << "\n");
  return true;
}

/// \brief Unfold a select instruction.
/// The select is converted into the following:
///
/// Select Owner --
///  |            v
///  |          NewBB
///  |            |
///  |------------
///  v
/// BB
///
/// \returns phi-function which was an user of the select instruction or has been created.
///          nullptr is returned if the select instruction can not be unfolded for some reason.
PHINode *AJT::tryToUnfoldSelectInstruction(SelectInst &SI) {
  BasicBlock *BB = SI.getParent();
  assert(BB);

  // the select defined value should not be used in the basic block
  assert(!ReportTODO && "Implement unfolding a select instruction for the case: when there are users of it inside its basic block.");
  if (SI.isUsedInBasicBlock(BB)) {
    LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix
                   << "<Unsupported> Skipped select instruction '"
                   << SI.getName() << "' because it is used inside its basic block.\n");
    return nullptr;
  }

  // only IF-like basic blocks are supported
  assert(!ReportTODO && "Implement unfolding a select instruction for the case: Terminator is not BranchInst.");
  if (!isa<BranchInst>(BB->getTerminator())) {
    LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix
                   << "<Unsupported> Skipped select instruction '"
                   << SI.getName() << "' because its block Terminator is BranchInst.\n");
    return nullptr;
  }

  BranchInst *BI = cast<BranchInst>(BB->getTerminator());

  // only unconditional branches are supported
  assert(!ReportTODO && "Implement unfolding a select instruction for the case: BranchInst is conditional.");
  if (BI->isConditional()) {
    LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix
                   << "<Unsupported> Skipped select instruction '"
                   << SI.getName() << "' because its block BranchInst is conditional.\n");
    return nullptr;
  }

  // there should be no other instructions between the select and the terminator.
  // TODO: implement unfolding for such cases if they exist
  assert(!ReportTODO && "Implement unfolding a select instruction for the case: there are instructions between the select instruction and the terminator.");
  if (&(*(++BB->rbegin())) != &SI) {
    LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix
                   << "<Unsupported> Skipped select instruction '"
                   << SI.getName() << "' because there are instructions between the select instruction and the terminator.\n");
    return nullptr;
  }

  assert(BI->getNumSuccessors() == 1);
  BasicBlock *BBSucc = BI->getSuccessor(0);
  BasicBlock *NewBB = BasicBlock::Create(BB->getContext(), "select.unfold",
                                         BB->getParent(), BBSucc);
  LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix
                 << "<Unfold select> New basic block created '"
                 << NewBB->getName() << '\n');
  // Add the new block to the set of original blocks if the select's block is in it.
  if (OriginalBlocks.count(BB))
    UnfoldedOriginalBlocks.push_back(NewBB);

  // Move unconditional jump to the new created block
  BI->removeFromParent();
  NewBB->getInstList().push_back(BI);
  // Add conditional jump which uses select condition
  BranchInst::Create(BBSucc, NewBB, SI.getCondition(), BB);

  // If in the successor the select is used in a phi-function.
  // The phi-function will have two values and needs to be updated.
  PHINode *Phi = nullptr;
  for (User *U : SI.users()) {
    if (PHINode *P = dyn_cast<PHINode>(U)) {
      if (P->getParent() == BBSucc) {
        Phi = P;
        break;
      }
    }
  }

  if (Phi) {
    // remove incoming select value
    Phi->removeIncomingValue(BB, false);
  } else {
    // no phi-functions have been found, create a new one
    Phi = PHINode::Create(SI.getType(), 2, "", &BBSucc->front());
    LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix
                   << "<Unfold select> New phi-function created '"
                   << Phi->getName() << '\n');
    SI.replaceAllUsesWith(Phi);
  }

  Phi->addIncoming(SI.getTrueValue(), BB);
  Phi->addIncoming(SI.getFalseValue(), NewBB);
  LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix
                 << "<Unfold select> Deleted select instruction '"
                 << SI.getName() << '\n');
  SI.eraseFromParent();

  // The successor might have other phi-functions.
  // They need to be updated that the same value comes from the new created block.
  for (auto PhiI = BBSucc->begin(); PHINode *P = dyn_cast<PHINode>(PhiI);
       ++PhiI) {
    if (P != Phi)
      P->addIncoming(P->getIncomingValueForBlock(BB), NewBB);
  }
  return Phi;
}

/// \brief Try to recursively unfold select instructions which are sources of
/// constants to the specified phi-function.
///
/// \param[in]     Phi         phi-function to start searching select instructions from
/// \param[in,out] SeenPhis    phi-functions which have been seen
/// \param[out]    SelectInsts select insructions to unfold
///
/// \returns true if select instructions have been unfolded.
void AJT::findSelectInstructionsToUnfoldRec(
    PHINode *Phi, SmallPtrSetImpl<PHINode *> &SeenPhis,
    SetVector<SelectInst *> &SelectInsts) {
  assert(Phi);

  if (!SeenPhis.insert(Phi).second)
    return;

  // Phi-function might have more than one incoming edge from the same block.
  // Keep history which incoming blocks have been seen.
  SmallPtrSet<BasicBlock *, 16> SeenBlocks;

  // Analyse incoming values whether they might be constant.
  // If an incoming value is an instruction selecting constants
  // it is unfolded.
  for (unsigned I = 0, E = Phi->getNumIncomingValues(); I != E; ++I) {
    if (!SeenBlocks.insert(Phi->getIncomingBlock(I)).second)
      continue;

    Value *InValue = Phi->getIncomingValue(I);
    if (PHINode *P = dyn_cast<PHINode>(InValue)) {
      findSelectInstructionsToUnfoldRec(P, SeenPhis, SelectInsts);
    } else if (SelectInst *SI = dyn_cast<SelectInst>(InValue)) {
      if (!isa<ConstantInt>(SI->getTrueValue())
            || !isa<ConstantInt>(SI->getFalseValue())) {
          LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix
                         << "Skip select instruction '"
                         << SI->getName() << "' because one of operands or both are not constant.\n");
          continue;
      }
      SelectInsts.insert(SI);
    }
  }
}

/// \brief Try to unfold select instructions which are sources of constants to
/// the specified phi-function.
///
/// \returns true if select instructions have been unfolded.
bool AJT::tryToUnfoldSelectInstructions(PHINode &StartPhi) {
  SmallPtrSet<PHINode *, 16> SeenPhis;
  SetVector<SelectInst *> SelectInsts;
  findSelectInstructionsToUnfoldRec(&StartPhi, SeenPhis, SelectInsts);
  bool Changed = false;
  for (auto SI: SelectInsts)
    if (tryToUnfoldSelectInstruction(*SI))
      Changed |= true;
  return Changed;
}

/// \brief Collect all constants which come in the terminator's basic block and
/// which the terminator depends on.
void AJT::TerminatorContext::collectIncomingConstants() {
  SmallPtrSet<PHINode *, 16> SeenPhis;
  collectConstants(StartingPoint, SeenPhis, IncomingConstants, DataFlowPoints, nullptr);
}

/// \brief Try to create alternative control flow paths when there are a set of
/// current block incoming constants for which there are known terminator's successors.
///
/// There are different types of terminators (e.g. SwitchInst, BranchInst).
/// A set of incoming constants and corresponding successors depend on terminator's
/// context.
///
/// \returns true if alternative CF paths have been created or there have been any changes in CF.
bool AJT::createAlternativeCFPath(TerminatorContext &TerminatorCtxt) {
  // TODO: Maybe we can teach TerminatorContext::collectIncomingConstants to collect
  // constants without unfolding select instructions.
  bool Changed = tryToUnfoldSelectInstructions(*TerminatorCtxt.getStartingPoint());

  TerminatorCtxt.collectIncomingConstants();
  if (TerminatorCtxt.getIncomingConstants().empty())
    return Changed;

  BasicBlock *TerminatorBB = TerminatorCtxt.getTerminator()->getParent();
  LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix
                 << "Attempting to create alternative path to "
                 << TerminatorBB->getName() << '\n');
  assert(TerminatorBB);

  LLVM_DEBUG(
      dbgs() << AJTDbgMsgPrefix << "Incoming constants: ";
      for (auto IC : TerminatorCtxt.getIncomingConstants()) {
        dbgs() << " { " << std::get<0>(IC)->getValue()
               << ", "  << std::get<1>(IC)->getName()
               << " }";
      }
      dbgs() << "\n";
  );

  for (auto IC : TerminatorCtxt.getIncomingConstants()) {
    // IC is tuple of <ConstantInt*, BasicBlock* - source of the constant, path of the constant through phi-functions>
    ConstantInt *C = std::get<0>(IC);
    assert(C);

    // Get a basic block to which CF jumps in case of an incoming constant C.
    BasicBlock *TakenBB = TerminatorCtxt.getTerminatorSuccForConstant(C);
    assert(TakenBB);

    // The first phi-function which the constant comes in.
    PhiDataFlowPoint *DataFlowStartPoint = std::get<2>(IC);
    assert(DataFlowStartPoint);
    if (redirectCFPathFromBlockToItsSuccForConst(TerminatorBB, TakenBB, C, std::get<1>(IC), DataFlowStartPoint)) {
      Changed = true;
      if (isBlockUnreachable(TerminatorBB)) {
        LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix
                     << "<Processing terminator> Deleting unreachable block: "
                     << TerminatorBB->getName() << '\n');
        deleteDeadBlock(TerminatorBB);
        assert(verifyFunction(*(TakenBB->getParent()), &dbgs()) == false); // verify IR
        break; // the terminator's basic block has been deleted there is no need to create other alternative paths.
      }
    }
  }

  return Changed;
}

/// \brief Check if the specified basic block is kind of blocks supported by AJT.
///
/// \returns true if:
///               1. The block does not have non-phi instructions which are
///                  either calls or memory operations or define values used
///                  outside the block. As the block is going to be jumped over
///                  they won't be executed and there will incorrect data flow.
///                  (TODO: split a basic block to have them in one part and a terminator in another part).
///               2. And the block's terminator is a switch.
bool AJT::isSupported(const BasicBlock &B) {
  for (const auto &Inst: B.getInstList()) {
    if (!isa<PHINode>(&Inst)
        && (isa<CallInst>(&Inst)
            || isa<InvokeInst>(&Inst)
            || Inst.mayReadOrWriteMemory()
            || Inst.isUsedOutsideOfBlock(&B)
            || (!Inst.use_empty() && !Inst.isUsedInBasicBlock(&B)))) {
      assert(!ReportTODO && "Implement splitting basic blocks.");
      return false;
    }
  }

  for (auto Succ = succ_begin(&B), SuccE = succ_end(&B); Succ != SuccE; ++Succ) {
    for (auto I = Succ->begin(); isa<PHINode>(I); ++I) {
      const PHINode *Phi = cast<const PHINode>(I);
      assert(Phi->getBasicBlockIndex(&B) != -1);
      if (isa<Constant>(Phi->getIncomingValueForBlock(&B))) {
        return false;
      }
    }
  }

  const Instruction *Terminator = B.getTerminator();
  if (isa<SwitchInst>(Terminator))
    return true;

  return false;
}

/// \brief Apply the jump threading optimisation to the specified basic block.
/// If the optimisation can not be applied or there is no profit from it
/// the basic block is put on the skip list.
///
/// \returns true if changes have been made: CF edge(s) redirected, BB deleted/created.
bool AJT::applyAJT(BasicBlock &BB) {
  if (!isSupported(BB)) {
    LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix
                 << "<Threading> Skipped unsupported block: " << BB.getName() << '\n');
    return false;
  }

  bool Changed = false;
  Instruction *Terminator = BB.getTerminator();
  if (SwitchInst *SI = dyn_cast<SwitchInst>(Terminator)) {
    if (PHINode *StartingPoint = dyn_cast<PHINode>(SI->getCondition())) {
      SwitchInstContext Ctxt(StartingPoint, SI);
      Changed = createAlternativeCFPath(Ctxt);
    }
  } else {
    assert(0 && "Should not reach here");
  }

  return Changed;
}

/// \brief Initialise AJT.
///
/// It should be done before processing function CFG.
void AJT::init(Function &F) {
  UnfoldedOriginalBlocks.clear();
  DeletedBlocksBin.clear();
  OriginalBlocks.clear();
  SkipConstantSources.clear();
}

/// \brief Create a set of pointers to original blocks.
///
/// All unreachable blocks are removed before creating the set.
void AJT::createOriginalBlocksSet(Function &F) {
  removeUnreachableBlocks(F);
  auto I = F.begin();
  ++I;
  for (auto E = F.end(); I != E; ++I) {
    BasicBlock &BB = *I;
    OriginalBlocks.insert(&BB);
  }
}

/// Apply constant fold optimisation to all instructions of the specified basic block.
static void constantFoldInstructionsInBlock(BasicBlock &BB,
                                            const TargetLibraryInfo *TLI) {
  const DataLayout &DL = BB.getModule()->getDataLayout();
  for (auto I = BB.begin(), E = BB.end(); I != E;) {
    auto CurrI = I;
    ++I;
    if (Instruction *Inst = dyn_cast<Instruction>(CurrI)) {
      Value *SimpleVal = ConstantFoldInstruction(Inst, DL, TLI);
      if (SimpleVal) {
        Inst->replaceAllUsesWith(SimpleVal);
        Inst->eraseFromParent();
      }
    }
  }
}

/// \brief Simplify function CFG. After applying the jump threading the function
/// CFG can have oportunities for optimisations: unreachable blocks, constant folding,
/// changing terminator type from conditional to unconditional, merging blocks.
///
/// 1. Delete unreachable basic blocks which don't have predecessors.
/// 2. Apply constant folding to instructions in basic blocks.
/// 3. Apply constant folding to a basic block terminator. It can convert
///    conditional jumps into unconditional jumps.
/// 4. If two basic blocks are only connected they are merged onto one. The first
///    one (predecessor) is deleted. If two blocks make a loop they are not merged.
void AJT::simplifyCFG(Function& F) {
  assert(!F.empty());
    LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix
                 << "<Simplifying CF> Applying constant folding to instructions of the entry block: "
                 << F.begin()->getName() << '\n');
  constantFoldInstructionsInBlock(*F.begin(), TLI);

  LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix
               << "<Simplifying CF> Applying constant folding to terminator of the entry block: "
               << F.begin()->getName() << '\n');
  ConstantFoldTerminator(&F.front(), true, TLI);
  auto I = F.begin();
  ++I;
  for (auto E = F.end(); I != E;) {
    BasicBlock &BB = *I;
    ++I;

    if (isBlockUnreachable(&BB)) {
      LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix
                   << "<Simplifying CF> Deleting unreachable block: "
                   << BB.getName() << '\n');
      deleteDeadBlock(&BB);
      continue;
    }

    LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix
                 << "<Simplifying CF> Applying constant folding to instructions of : "
                 << BB.getName() << '\n');
    constantFoldInstructionsInBlock(BB, TLI);

    LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix
                 << "<Simplifying CF> Applying constant folding to terminator of : "
                 << BB.getName() << '\n');
    ConstantFoldTerminator(&BB, true, TLI);

    // Check there is no loop with the next block.
    if (isPredecessorSinglyConnectedTo(BB)
        && I != E && BB.getSinglePredecessor() != &*I) {
      LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix
                   << "<Simplifying CF> Merging block with predecessor: "
                   << BB.getName() << '\n');
      mergeBlockWithSCPred(BB);
      if (&F.getEntryBlock() == &BB)
        removeFromOriginalBlocks(&BB);
    }
  }
}

/// \brief Optimise control flow of the specified functions by jumping over
/// basic block when it is possible.
///
/// It works iteratively. If there have been control flow changes
/// during processing of a basic block then the process is restarted as
/// there might be new oportunities for optimisation.
///
/// Some basic block might be skipped because they should not be touched or
/// there is no performance gain from their optimisation or there are no
/// control flow paths to be optimised.
///
/// \returns true on changes of \p F
bool AJT::run(Function &F) {
  LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix << "Processing function '" << F.getName()
               << "'\n");
  init(F);
  createOriginalBlocksSet(F);

  bool Changed = false;
  bool Rerun;
  do {
    Rerun = false;
    assert(UnfoldedOriginalBlocks.empty());
    assert(DeletedBlocksBin.empty());
    for (auto BB: OriginalBlocks) {
      assert(&F.getEntryBlock() != BB);
      assert(BB);
      Rerun |= applyAJT(*BB);
    }
    Changed |= Rerun;
    if (Rerun) {
      LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix << "Function '" << F.getName()
                   << "' CF changed. Rerun pass.\n");
      OriginalBlocks.insert(UnfoldedOriginalBlocks.begin(), UnfoldedOriginalBlocks.end());
      UnfoldedOriginalBlocks.clear();
      simplifyCFG(F);
      eraseDeletedBlocks();
    }
  } while (Rerun);

  LLVM_DEBUG(dbgs() << AJTDbgMsgPrefix << "Completed function '" << F.getName()
               << "'\n");
  return Changed;
}

//===----------------------------------------------------------------------===//
//
// Pass Manager integration code
//
//===----------------------------------------------------------------------===//
PreservedAnalyses AJTPass::run(Function &F, FunctionAnalysisManager &AM) {
  auto &SE = AM.getResult<ScalarEvolutionAnalysis>(F);
  auto &LI = AM.getResult<LoopAnalysis>(F);
  auto &DT = AM.getResult<DominatorTreeAnalysis>(F);
  auto &AC = AM.getResult<AssumptionAnalysis>(F);
  auto &TLI = AM.getResult<TargetLibraryAnalysis>(F);
  auto &TTI = AM.getResult<TargetIRAnalysis>(F);

  bool Changed = false;
  for (auto &L : LI) {
    Changed |= simplifyLoop(L, &DT, &LI, &SE, &AC, nullptr, false /* PreserveLCSSA */);
    Changed |= formLCSSARecursively(*L, DT, &LI, &SE);
  }

  Changed |= AJT(&TLI, &TTI).run(F);

  if (!Changed)
    return PreservedAnalyses::all();

  PreservedAnalyses PA;
  PA.preserve<GlobalsAA>();
  return PA;
}
