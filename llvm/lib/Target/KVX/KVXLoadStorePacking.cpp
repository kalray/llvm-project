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

class KVXLoadStorePackingPass : public MachineFunctionPass {

  using PairM = std::pair<MachineInstr *, unsigned>;
  using Vec = SmallVector<PairM, 8>;

public:
  static char ID;

  KVXLoadStorePackingPass() : MachineFunctionPass(ID) {
    auto PR = PassRegistry::getPassRegistry();
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

  unsigned getPackOpcode(const bool isPair, const int64_t Index,
                         const unsigned *Opcode);

  void packAndReplaceLoad(Vec::iterator ItStart, unsigned Count);
  void packAndReplaceStore(Vec::iterator ItStart, unsigned Count);

  bool packBlock(MachineBasicBlock &MBB);
  bool reorderInstr(llvm::DenseMap<MachineOperand, Vec> &, unsigned, unsigned);
};

} // end anonymous namespace

char KVXLoadStorePackingPass::ID = 0;
// FIXME: support rr insn
static const unsigned LoadOpcodes[] = { KVX::LQri10, KVX::LQri37, KVX::LQri64,
                                        KVX::LOri10, KVX::LOri37, KVX::LOri64 };
static const unsigned StoreOpcodes[] = {
  KVX::SQri10, KVX::SQri37, KVX::SQri64, KVX::SOri10, KVX::SOri37, KVX::SOri64
};

bool KVXLoadStorePackingPass::runOnMachineFunction(MachineFunction &MF) {
  bool Changed = false;
  MRI = std::addressof(MF.getRegInfo());
  TII = static_cast<const KVXInstrInfo *>(MF.getSubtarget().getInstrInfo());
  TRI = MF.getSubtarget().getRegisterInfo();
  AA = &getAnalysis<AAResultsWrapperPass>().getAAResults();

  for (MachineBasicBlock &MBB : MF) {
    Changed |= packBlock(MBB);
  }

  return Changed;
}

unsigned KVXLoadStorePackingPass::getPackOpcode(const bool isPair,
                                                const int64_t Index,
                                                const unsigned *Opcodes) {
  unsigned Opcode = isPair ? Opcodes[2] : Opcodes[5];
  if (isInt<10>(Index)) {
    Opcode = isPair ? Opcodes[0] : Opcodes[3];
  } else if (isInt<37>(Index)) {
    Opcode = isPair ? Opcodes[1] : Opcodes[4];
  }

  return Opcode;
}

void KVXLoadStorePackingPass::packAndReplaceLoad(Vec::iterator ItStart,
                                                 unsigned Count) {
  const bool isPair = Count == 2;
  const unsigned Opcode = getPackOpcode(
      isPair, (*ItStart).first->getOperand(1).getImm(), LoadOpcodes);
  const TargetRegisterClass *TRC =
      isPair ? &KVX::PairedRegRegClass : &KVX::QuadRegRegClass;

  auto LocMII = ItStart;
  for (auto CurrentMII = ItStart; CurrentMII != ItStart + Count; ++CurrentMII) {
    if (CurrentMII->second < LocMII->second)
      LocMII = CurrentMII;
  }

  unsigned Reg = MRI->createVirtualRegister(TRC);
  MachineInstrBuilder mib =
      BuildMI(*LocMII->first->getParent(), LocMII->first,
              LocMII->first->getDebugLoc(), TII->get(Opcode), Reg);

  mib.add(ItStart->first->getOperand(1))
      .add(ItStart->first->getOperand(2))
      .add(ItStart->first->getOperand(3));

  LLVM_DEBUG(dbgs() << "added " << *mib << "\n");

  unsigned Ind = KVX::sub_s0;
  while (Count--) {
    unsigned re = ItStart->first->getOperand(0).getReg();
    ItStart->first->eraseFromParent();

    for (MachineRegisterInfo::reg_iterator RI = MRI->reg_begin(re),
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

  LLVM_DEBUG(dbgs() << "added(2) " << *mib << "\n");
}

void KVXLoadStorePackingPass::packAndReplaceStore(Vec::iterator ItStart,
                                                  unsigned Count) {

  const bool isPair = Count == 2;
  const unsigned Opcode = getPackOpcode(
      isPair, ItStart->first->getOperand(0).getImm(), StoreOpcodes);
  const TargetRegisterClass *TRC =
      isPair ? &KVX::PairedRegRegClass : &KVX::QuadRegRegClass;

  auto LocMII = ItStart;
  for (auto CurrentMII = ItStart; CurrentMII != ItStart + Count; ++CurrentMII) {
    if (CurrentMII->second > LocMII->second)
      LocMII = CurrentMII;
  }

  unsigned Reg = MRI->createVirtualRegister(TRC);

  unsigned SingleRegs[4];
  auto SeqMI = BuildMI(*ItStart->first->getParent(), LocMII->first,
                       ItStart->first->getDebugLoc(),
                       TII->get(TargetOpcode::REG_SEQUENCE), Reg);

  for (unsigned i = 0; i < Count; ++i) {
    SingleRegs[i] = MRI->createVirtualRegister(&KVX::SingleRegRegClass);
    SeqMI.addReg(SingleRegs[i]).addImm(KVX::sub_s0 + i);
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

// This should be a enum: NONE, LOAD, STORE
static int getOpType(MachineBasicBlock::iterator MBBI) {
  switch (MBBI->getOpcode()) {
  default:
    return 0;
  case KVX::LDp:
  case KVX::LDri10:
  case KVX::LDri37:
  case KVX::LDri64:
    return 1;
  case KVX::SDp:
  case KVX::SDri10:
  case KVX::SDri37:
  case KVX::SDri64:
    return 2;
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
// Really bad name, it ain't reorder only, but sort and pack
bool KVXLoadStorePackingPass::reorderInstr(
    llvm::DenseMap<MachineOperand, Vec> &Map, unsigned Type,
    unsigned OffsetInd) {
  bool Changed = false;
  for (auto DM : Map) {
    if (DM.getSecond().size() < 2)
      continue;

    llvm::sort(DM.getSecond().begin(), DM.getSecond().end(),
               [OffsetInd](PairM const &a, PairM const &b) -> bool {
                 return a.first->getOperand(OffsetInd).getImm() <
                        b.first->getOperand(OffsetInd).getImm();
               });

    auto It = DM.getSecond().begin();
    auto ItE = DM.getSecond().end();
    while (It != ItE) {
      auto ItStart = It;
      auto NIt = std::next(It);
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
        // What happens if count == 3?
        if (Type == 1)
          packAndReplaceLoad(ItStart, Count == 4 ? Count : 2);
        else if (Type == 2)
          packAndReplaceStore(ItStart, Count == 4 ? Count : 2);

        Changed = true;
      }

      ++It;
    }
  }

  return Changed;
}

bool KVXLoadStorePackingPass::packBlock(MachineBasicBlock &MBB) {
  auto MBBI = MBB.begin();
  auto E = MBB.end();
  bool Changed = false;

  llvm::DenseMap<MachineOperand, Vec> LdMap;
  llvm::DenseMap<MachineOperand, Vec> StMap;

  unsigned MIInd = 0;
  int const MaxJumps = 4;
  while (MBBI != E) {
    int Jumps = MaxJumps;

    for (; MBBI != E; ++MBBI, ++MIInd) {
      if (MBBI->isDebugInstr())
        continue;

      if (--Jumps == 0)
        break;

      auto Type = getOpType(MBBI);

      if (!Type) {
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

      if (Type == 1) { // If it is a load, check alias against stores
        bool isalias = false;
        // Way over-conservative check below. We only need to check against
        // operations that are inside the window of operations which we can
        // merge to, not against all mem operations we've seen so far.
        for (auto &v : StMap)
          for (auto &i : v.second)
            if (!isalias && MBBI->mayAlias(AA, *(i.first), /*UseTBAA*/ false)) {
              ++MBBI;
              ++MIInd;
              isalias = true;
            }

        if (isalias)
          break;

        Jumps = MaxJumps;
        LdMap[MBBI->getOperand(2)].push_back(std::make_pair(&*MBBI, MIInd));
      } else if (Type == 2) { // If it is a store, check alias against stores
        // BUG?? Stores must check against loads as well???
        bool isalias = false;
        for (auto &v : StMap)
          for (auto &i : v.second)
            if (!isalias && MBBI->mayAlias(AA, *(i.first), /*UseTBAA*/ false)) {
              ++MBBI;
              ++MIInd;
              isalias = true;
            }

        if (isalias)
          break;

        Jumps = MaxJumps;
        StMap[MBBI->getOperand(1)].push_back(std::make_pair(&*MBBI, MIInd));
      }
    }

    Changed |= reorderInstr(LdMap, 1, 1);
    Changed |= reorderInstr(StMap, 2, 0);

    LdMap.clear();
    StMap.clear();
  }

  return Changed;
}

INITIALIZE_PASS(KVXLoadStorePackingPass, KVXLOADSTOREPACKING_NAME,
                KVXLOADSTOREPACKING_DESC, false, false)

FunctionPass *llvm::createKVXLoadStorePackingPass() {
  return new KVXLoadStorePackingPass();
}
