//==- KVXLoadStorePacking.cpp - KVX Load/Store Packing Pass ------*- C++ -*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
//  This file contains the KVX load/store packing pass implementation.
//  This will fuse operations such as
//    ld $r0 = 0[$r2]
//    ld $r1 = 8[$r2]
//    >>>> lq $r0r1 = 0[$r2]
//    Also works for lo and stores operations (sd -> sq/so).
//
//  How it works:
//    - It makes a vector of consecutive loads(stores) and sorts them by
//    the registers used for loading(storing) data and the offset. Then
//    consecutive loads(stores) of 2 or 4 (if possible) are merged together.
//
//  Future improvements:
//    - This currently relies that loads and store are already placed
//  together. It should be more flexible and check pass other intructions
//  and validate if there are enough registers at the time or if is a dependency
//  between the instructions.
//    - Stores packing works only if there was already made a load pack of the
//  same, which is highly inefficient.
//    - Add implementation for lw/sw to fuse into highter loads/stores, but
//  must take care of data unpacking before any computation.
//
//===----------------------------------------------------------------------===//

#include "KVX.h"
#include "KVXInstrInfo.h"

#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"

#include <unordered_map>

using namespace llvm;

#define KVXLOADSTOREPACKING_NAME "kvx-load-store-packing"
#define KVXLOADSTOREPACKING_DESC "Load/store packing"

#define DEBUG_TYPE KVXLOADSTOREPACKING_NAME

namespace {

typedef enum { NOT_LDST, LOAD, LOAD_PSEUDO, STORE, STORE_PSEUDO } OpType;

using PairM = std::pair<MachineInstr *, unsigned>;
using Vec = SmallVector<PairM, 8>;
using BaseptrMap = llvm::DenseMap<MachineOperand, Vec>;

class KVXLoadStorePackingPass : public MachineFunctionPass {

public:
  static char ID;

  KVXLoadStorePackingPass() : MachineFunctionPass(ID) {
    auto *PR = PassRegistry::getPassRegistry();
    initializeKVXLoadStorePackingPassPass(*PR);
  }

  StringRef getPassName() const override { return KVXLOADSTOREPACKING_NAME; }

  bool runOnMachineFunction(MachineFunction &MF) override;

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addRequired<AAResultsWrapperPass>();
    MachineFunctionPass::getAnalysisUsage(AU);
  }

private:
  MachineRegisterInfo *MRI;
  const KVXInstrInfo *TII;
  const TargetRegisterInfo *TRI;
  AliasAnalysis *AA;

  unsigned getPackOpcode(const bool IsPair, const int64_t Index,
                         const bool IsPseudo, const unsigned *Opcode);

  void packAndReplaceLoad(Vec::iterator ItStart, unsigned Count,
                          const bool IsPseudo);
  void packAndReplaceStore(Vec::iterator ItStart, unsigned Count,
                           const bool IsPseudo);

  bool packBlock(MachineBasicBlock &MBB);
  bool sortAndPack(BaseptrMap &, OpType, unsigned);
};

} // end anonymous namespace

char KVXLoadStorePackingPass::ID = 0;
// FIXME: support rr insn
static const unsigned LoadOpcodes[] = {KVX::LQri10, KVX::LQri37, KVX::LQri64,
                                       KVX::LQp,    KVX::LOri10, KVX::LOri37,
                                       KVX::LOri64, KVX::LOp};

static const unsigned StoreOpcodes[] = {KVX::SQri10, KVX::SQri37, KVX::SQri64,
                                        KVX::SQp,    KVX::SOri10, KVX::SOri37,
                                        KVX::SOri64, KVX::SOp};

bool KVXLoadStorePackingPass::runOnMachineFunction(MachineFunction &MF) {

  LLVM_DEBUG(dbgs() << "Running on function " << MF.getName() << '\n');
  bool Changed = false;
  MRI = std::addressof(MF.getRegInfo());
  TII = static_cast<const KVXInstrInfo *>(MF.getSubtarget().getInstrInfo());
  TRI = MF.getSubtarget().getRegisterInfo();
  AA = &getAnalysis<AAResultsWrapperPass>().getAAResults();

  for (MachineBasicBlock &MBB : MF)
    Changed |= packBlock(MBB);

  return Changed;
}

unsigned KVXLoadStorePackingPass::getPackOpcode(const bool IsPair,
                                                const int64_t Index,
                                                const bool IsPseudo,
                                                const unsigned *Opcodes) {
  enum { Qri10, Qri37, Qri64, Qp, Ori10, Ori37, Ori64, Op };

  if (IsPseudo)
    return IsPair ? Opcodes[Qp] : Opcodes[Op];

  if (isInt<10>(Index))
    return IsPair ? Opcodes[Qri10] : Opcodes[Ori10];

  if (isInt<37>(Index))
    return IsPair ? Opcodes[Qri37] : Opcodes[Ori37];

  return IsPair ? Opcodes[Qri64] : Opcodes[Ori64];
  ;
}

void KVXLoadStorePackingPass::packAndReplaceLoad(Vec::iterator ItStart,
                                                 unsigned Count,
                                                 bool IsPseudo) {
  const bool IsPair = Count == 2;
  const unsigned Opcode = getPackOpcode(
      IsPair, (*ItStart).first->getOperand(1).getImm(), IsPseudo, LoadOpcodes);

  const TargetRegisterClass *TRC =
      IsPair ? &KVX::PairedRegRegClass : &KVX::QuadRegRegClass;

  auto *LocMII = ItStart;
  for (auto *CurrentMII = ItStart; CurrentMII != ItStart + Count;
       ++CurrentMII) {

    if (CurrentMII->second < LocMII->second)
      LocMII = CurrentMII;
  }

  Register Reg = MRI->createVirtualRegister(TRC);
  MachineInstrBuilder Mib =
      BuildMI(*LocMII->first->getParent(), LocMII->first,
              LocMII->first->getDebugLoc(), TII->get(Opcode), Reg);

  Mib.add(ItStart->first->getOperand(1))
      .add(ItStart->first->getOperand(2))
      .add(ItStart->first->getOperand(3));

  LLVM_DEBUG(dbgs() << "added " << *Mib << "\n");

  unsigned Ind = KVX::sub_d0;
  while (Count--) {
    Register Re = ItStart->first->getOperand(0).getReg();
    ItStart->first->eraseFromParent();

    for (MachineRegisterInfo::reg_iterator RI = MRI->reg_begin(Re),
                                           RE = MRI->reg_end();
         RI != RE;) {
      MachineOperand &O = *RI;
      LLVM_DEBUG(dbgs() << "substVirtReg " << O.getReg() << " with " << Reg
                        << "\n");
      ++RI;
      O.substVirtReg(Reg, Ind, *TRI);
    }
    ++Ind;
    LLVM_DEBUG(dbgs() << "removed " << *(ItStart->first) << "\n");

    ++ItStart;
  }

  LLVM_DEBUG(dbgs() << "added(2) " << *Mib << "\n");
}

void KVXLoadStorePackingPass::packAndReplaceStore(Vec::iterator ItStart,
                                                  unsigned Count,
                                                  bool IsPseudo) {

  const bool IsPair = Count == 2;

  const unsigned Opcode = getPackOpcode(
      IsPair, ItStart->first->getOperand(0).getImm(), IsPseudo, StoreOpcodes);

  const TargetRegisterClass *TRC =
      IsPair ? &KVX::PairedRegRegClass : &KVX::QuadRegRegClass;

  auto *LocMII = ItStart;
  for (auto *CurrentMII = ItStart; CurrentMII != ItStart + Count;
       ++CurrentMII) {
    if (CurrentMII->second > LocMII->second)
      LocMII = CurrentMII;
  }

  Register Reg = MRI->createVirtualRegister(TRC);

  unsigned SingleRegs[4];
  auto SeqMI = BuildMI(*ItStart->first->getParent(), LocMII->first,
                       ItStart->first->getDebugLoc(),
                       TII->get(TargetOpcode::REG_SEQUENCE), Reg);

  for (unsigned I = 0; I < Count; ++I) {
    SingleRegs[I] = MRI->createVirtualRegister(&KVX::SingleRegRegClass);
    SeqMI.addReg(SingleRegs[I]).addImm(KVX::sub_d0 + I);
  }

  auto NewSt = BuildMI(*ItStart->first->getParent(), LocMII->first,
                       ItStart->first->getDebugLoc(), TII->get(Opcode))
                   .addImm(ItStart->first->getOperand(0).getImm())
                   .add(ItStart->first->getOperand(1))
                   .addReg(Reg);

  unsigned Ind = 0;
  while (Count--) {
    BuildMI(*NewSt->getParent(), *SeqMI, NewSt->getDebugLoc(),
            TII->get(TargetOpcode::COPY), SingleRegs[Ind])
        .add(ItStart->first->getOperand(2));

    ItStart->first->eraseFromParent();
    ++ItStart;
    ++Ind;
    LLVM_DEBUG(dbgs() << "removed " << *ItStart->first << "\n");
  }
}

// TODO: This is limited to pack 64 bits instructions together.
// Should be able to pack {64 128 64} -> 256 bits for example.
// Packing sub-64 bits would require fields extraction, not
// sure it would be a good idea.
static OpType getOpType(MachineBasicBlock::iterator MBBI) {
  switch (MBBI->getOpcode()) {
  default:
    return NOT_LDST;
  case KVX::LDp:
    return LOAD_PSEUDO;
  case KVX::LDri10:
  case KVX::LDri37:
  case KVX::LDri64:
    return LOAD;
  case KVX::SDp:
    return STORE_PSEUDO;
  case KVX::SDri10:
  case KVX::SDri37:
  case KVX::SDri64:
    return STORE;
  };
}

static int isValidMemoryOp(MachineBasicBlock::iterator MBBI) {
  if (MBBI->memoperands_empty())
    return false;

  const MachineMemOperand &MMO = **(MBBI->memoperands_begin());
  if (MMO.isVolatile() || MMO.isAtomic())
    return false;

  return true;
}

bool KVXLoadStorePackingPass::sortAndPack(BaseptrMap &Map, OpType Type,
                                          unsigned OffsetInd) {

  bool Changed = false;
  for (auto DM : Map) {
    LLVM_DEBUG(DM.first.print(errs());
               dbgs() << " == " << DM.second.size() << '\n');
    if (DM.getSecond().size() < 2)
      continue;

    llvm::sort(DM.getSecond().begin(), DM.getSecond().end(),
               [OffsetInd](PairM const &A, PairM const &B) -> bool {
                 return A.first->getOperand(OffsetInd).getImm() <
                        B.first->getOperand(OffsetInd).getImm();
               });

    auto *It = DM.getSecond().begin();
    auto *ItE = DM.getSecond().end();
    while (It != ItE) {
      LLVM_DEBUG(dbgs() << "Testing from: "; It->first->dump());
      auto *ItStart = It;
      auto *NIt = std::next(It);
      if (NIt == ItE)
        break;

      unsigned Count = 1;
      unsigned LocC = ItStart->second;
      auto FirstInstr = *ItStart;
      while (NIt != ItE && Count < 4 &&
             (*It).first->getOperand(OffsetInd).getImm() + 8 ==
                 (*NIt).first->getOperand(OffsetInd).getImm()) {
        if (LocC > NIt->second) {
          FirstInstr = *NIt;
          LocC = NIt->second;
        }
        It = NIt;
        ++NIt;
        ++Count;
      }

      if (Count > 1) {
        if (Type == LOAD || Type == LOAD_PSEUDO)
          packAndReplaceLoad(ItStart, Count == 4 ? Count : 2,
                             Type == LOAD_PSEUDO);
        else
          packAndReplaceStore(ItStart, Count == 4 ? Count : 2,
                              Type == STORE_PSEUDO);

        Changed = true;
      }

      ++It;
    }
  }

  return Changed;
}

bool KVXLoadStorePackingPass::packBlock(MachineBasicBlock &MBB) {
  LLVM_DEBUG(dbgs() << "Running on BB: " << MBB.getName() << '\n');
  auto MBBI = MBB.begin();
  auto E = MBB.end();
  bool Changed = false;

  BaseptrMap LdMap, StMap, LdpMap, StpMap;

  unsigned MIInd = 0;
  int constexpr MaxJumps = 6;
  while (MBBI != E) {
    int Jumps = MaxJumps;
    LLVM_DEBUG(dbgs() << "Can still jump up to " << Jumps << " instruction.\n");

    for (; MBBI != E; ++MBBI, ++MIInd) {
      if (MBBI->isDebugInstr()) {
        LLVM_DEBUG(dbgs() << "Ignore debug instruction: "; MBBI->dump());
        continue;
      }

      if (--Jumps == 0) {
        LLVM_DEBUG(dbgs() << "Did search too long, bailing out.\n");
        break;
      }

      auto Type = getOpType(MBBI);
      if (Type == NOT_LDST) {
        // FIXME: hasUnmodeledSideEffects unusable now, should be added here
        if (MBBI->isCall() || MBBI->isTerminator()) {
          ++MBBI;
          ++MIInd;
          break;
        }

        continue;
      }

      if (!isValidMemoryOp(MBBI))
        continue;

      // TODO: Implement this hook
      // TII->getMemOperandWithOffset(*MBBI, BaseOp, Offset, OffsetIsScalable,
      // TRI);

      BaseptrMap *AddToP;
      LLVM_DEBUG(dbgs() << "Adding to map ");
      switch (Type) {
      default: {
        LLVM_DEBUG(dbgs() << "Store instruction: ";);
        AddToP = &StMap;
        break;
      }
      case STORE_PSEUDO: {
        LLVM_DEBUG(dbgs() << "Store pseudo: ";);
        AddToP = &StpMap;
        break;
      }
      case LOAD: {
        LLVM_DEBUG(dbgs() << "load instruction: ";);
        AddToP = &LdMap;
        break;
      }
      case LOAD_PSEUDO: {
        LLVM_DEBUG(dbgs() << "load pseudo: ";);
        AddToP = &LdpMap;
        break;
      }
      }
      LLVM_DEBUG(MBBI->dump());
      MachineOperand BaseOp = MBBI->getOperand(MBBI->mayStore() ? 1 : 2);
      BaseptrMap &Map = *AddToP;
      // TODO: The alias check is over-conservative. It should only check
      // between instructions that overlap in execution time. E.g: Stores that
      // all come after loads don't need to be checked against the loads for
      // packing.
      SmallVector<BaseptrMap *, 4> MapsToCheck = {&StMap, &StpMap};
      if (Type == STORE || Type == STORE_PSEUDO) {
        MapsToCheck.push_back(&LdMap);
        MapsToCheck.push_back(&LdpMap);
      }

      for (auto *Map : MapsToCheck)
        for (auto &V : *Map)
          for (auto &I : V.second)
            // TODO: Implement method: TII->areMemAccessesTriviallyDisjoint
            if (MBBI->mayAlias(AA, *(I.first), /*UseTBAA*/ false)) {
              ++MBBI;
              ++MIInd;
              LLVM_DEBUG(dbgs() << "Ignoring it, as it aliases with: ";
                         I.first->dump(););
              goto IS_ALIAS;
            }

      Jumps = MaxJumps;
      Map[BaseOp].push_back(std::make_pair(&*MBBI, MIInd));
    }
  IS_ALIAS:
    LLVM_DEBUG(dbgs() << "Sort and pack " << LdMap.size()
                      << " load instructions.\n");
    Changed |= sortAndPack(LdMap, LOAD, 1);
    LLVM_DEBUG(dbgs() << "Sort and pack " << LdpMap.size()
                      << " load pseudos.\n");
    Changed |= sortAndPack(LdpMap, LOAD_PSEUDO, 1);
    LLVM_DEBUG(dbgs() << "Sort and pack " << StMap.size()
                      << " store instructions.\n");
    Changed |= sortAndPack(StMap, STORE, 0);
    LLVM_DEBUG(dbgs() << "Sort and pack " << StpMap.size()
                      << " store pseudos.\n");
    Changed |= sortAndPack(StpMap, STORE_PSEUDO, 0);

    LdMap.clear();
    StMap.clear();
    LdpMap.clear();
    StpMap.clear();
  }

  return Changed;
}

INITIALIZE_PASS(KVXLoadStorePackingPass, KVXLOADSTOREPACKING_NAME,
                KVXLOADSTOREPACKING_DESC, false, false)

FunctionPass *llvm::createKVXLoadStorePackingPass() {
  return new KVXLoadStorePackingPass();
}
