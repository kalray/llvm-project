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
//    - It makes a vector of consecutives loads(stores) and sorts them by
//    the registers used for loading(storing) data and the offset. Then
//    consecutives loads(stores) of 2 or 4 (if possible) are merged together.
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

#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"

#include <unordered_map>

using namespace llvm;

#define KVXLOADSTOREPACKING_NAME "kvx-load-store-packing"
#define KVXLOADSTOREPACKING_DESC "Load/store packing"

#define DEBUG_TYPE KVXLOADSTOREPACKING_NAME

namespace {

class KVXLoadStorePackingPass : public MachineFunctionPass {

public:
  static char ID;

  KVXLoadStorePackingPass() : MachineFunctionPass(ID) {
    auto PR = PassRegistry::getPassRegistry();
    initializeKVXLoadStorePackingPassPass(*PR);
  }

  StringRef getPassName() const override { return KVXLOADSTOREPACKING_NAME; }

  bool runOnMachineFunction(MachineFunction &MF) override;

private:
  MachineRegisterInfo *MRI;
  const KVXInstrInfo *TII;
  const TargetRegisterInfo *TRI;
  std::unordered_map<unsigned, unsigned> ChangedRegs;

  bool isValidOpcodeLoad(unsigned Opcode);
  bool isValidOpcodeStore(unsigned Opcode);

  unsigned getPackOpcode(const bool isPair, const int64_t Index,
                         const unsigned *Opcode);

  void
  PackAndReplaceLoad(MachineBasicBlock::iterator LocInstr,
                     std::vector<MachineBasicBlock::iterator>::iterator ItStart,
                     unsigned Count);
  void PackAndReplaceStore(
      MachineBasicBlock::iterator LocInstr,
      std::vector<MachineBasicBlock::iterator>::iterator ItStart,
      unsigned Count);

  bool areEnoughRegisters(unsigned ExtraRegistersNeeded);

  template <typename FuncOpcode, typename FuncReplace>
  bool PackBlock(MachineBasicBlock &MBB, FuncOpcode isValidOpcode,
                 FuncReplace getClasses, unsigned OperandInd,
                 unsigned OperandReg);
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

  for (MachineBasicBlock &MBB : MF) {
    Changed |= PackBlock(
        MBB, [this](unsigned Opcode)
                 ->unsigned { return this->isValidOpcodeLoad(Opcode); },
        [this](MachineBasicBlock::iterator LocInstr,
               std::vector<MachineBasicBlock::iterator>::iterator ItStart,
               unsigned Count) {
          LLVM_DEBUG(dbgs() << "PackAndReplaceLoad " << *LocInstr);
          LLVM_DEBUG(dbgs() << "\nPackAndReplaceLoad Count=" << Count << "\n");
          this->PackAndReplaceLoad(LocInstr, ItStart, Count);
        },
        1, 2);

    Changed |= PackBlock(
        MBB, [this](unsigned Opcode)
                 ->unsigned { return this->isValidOpcodeStore(Opcode); },
        [this](MachineBasicBlock::iterator LocInstr,
               std::vector<MachineBasicBlock::iterator>::iterator ItStart,
               unsigned Count)
            ->void { this->PackAndReplaceStore(LocInstr, ItStart, Count); },
        0, 1);

    ChangedRegs.clear();
  }

  return Changed;
}

bool KVXLoadStorePackingPass::isValidOpcodeLoad(unsigned Opcode) {
  switch (Opcode) {
  default:
    return false;
  case KVX::LDp:
  case KVX::LDri10:
  case KVX::LDri37:
  case KVX::LDri64:
    return true;
  };
}

bool KVXLoadStorePackingPass::isValidOpcodeStore(unsigned Opcode) {
  switch (Opcode) {
  default:
    return false;
  case KVX::SDp:
  case KVX::SDri10:
  case KVX::SDri37:
  case KVX::SDri64:
    return true;
  }
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

void KVXLoadStorePackingPass::PackAndReplaceLoad(
    MachineBasicBlock::iterator LocInstr,
    std::vector<MachineBasicBlock::iterator>::iterator ItStart,
    unsigned Count) {
  if ((*LocInstr).getParent() == nullptr) {
    LLVM_DEBUG(dbgs() << "invalid instruction without valid MBB " << *LocInstr
                      << "\n");
    return;
  }
  const bool isPair = Count == 2;
  const unsigned Opcode =
      getPackOpcode(isPair, (*ItStart)->getOperand(1).getImm(), LoadOpcodes);
  const TargetRegisterClass *TRC =
      isPair ? &KVX::PairedRegRegClass : &KVX::QuadRegRegClass;

  unsigned Reg = MRI->createVirtualRegister(TRC);
  MachineInstrBuilder mib =
      BuildMI(*(*ItStart)->getParent(), LocInstr, (*ItStart)->getDebugLoc(),
              TII->get(Opcode), Reg);

  mib.addImm((*ItStart)->getOperand(1).getImm())
      .add((*ItStart)->getOperand(2))
      .addImm(0);

  LLVM_DEBUG(dbgs() << "added " << *mib << "\n");

  ChangedRegs[Reg] = Count;

  unsigned Ind = 1;
  while (Count--) {
    for (MachineRegisterInfo::reg_iterator
             RI = MRI->reg_begin((*ItStart)->getOperand(0).getReg()),
             RE = MRI->reg_end();
         RI != RE;) {
      MachineOperand &O = *RI;
      LLVM_DEBUG(dbgs() << "substVirtReg " << O.getReg() << " with " << Reg
                        << "\n");
      ++RI;
      O.substVirtReg(Reg, Ind, *TRI);
    }
    ++Ind;
    LLVM_DEBUG(dbgs() << "removed " << *(*ItStart) << "\n");

    (*ItStart)->eraseFromParent();
    ++ItStart;
  }

  LLVM_DEBUG(dbgs() << "added(2) " << *mib << "\n");
}

// FIXME: improve store packing, do not depends on loads
void KVXLoadStorePackingPass::PackAndReplaceStore(
    MachineBasicBlock::iterator LocInstr,
    std::vector<MachineBasicBlock::iterator>::iterator ItStart,
    unsigned Count) {
  if ((*LocInstr).getParent() == nullptr) {
    LLVM_DEBUG(dbgs() << "invalid instruction without valid MBB " << *LocInstr
                      << "\n");
    return;
  }
  const bool isPair = Count == 2;
  const unsigned Opcode =
      getPackOpcode(isPair, (*ItStart)->getOperand(0).getImm(), StoreOpcodes);
  unsigned Reg;
  if (ChangedRegs.find((*ItStart)->getOperand(2).getReg()) !=
          ChangedRegs.end() &&
      ChangedRegs[(*ItStart)->getOperand(2).getReg()] == Count) {
    auto ItCurr = ItStart;
    unsigned Ind = 1;
    Reg = (*ItCurr)->getOperand(2).getReg();
    while (Ind <= Count) {
      if ((*ItCurr)->getOperand(2).getSubReg() != Ind)
        return;

      ++Ind;
      ++ItCurr;
    }
  } else {
    return;
  }

  BuildMI(*(*ItStart)->getParent(), LocInstr, (*ItStart)->getDebugLoc(),
          TII->get(Opcode))
      .addImm((*ItStart)->getOperand(0).getImm())
      .add((*ItStart)->getOperand(1))
      .addReg(Reg);

  while (Count--) {
    (*ItStart)->eraseFromParent();
    ++ItStart;
  }
}

// FIXME: Test if there are enough physical register to move instructions
bool
KVXLoadStorePackingPass::areEnoughRegisters(unsigned ExtraRegistersNeeded) {
  return ExtraRegistersNeeded < 1;
}

template <typename FuncOpcode, typename FuncReplace>
bool KVXLoadStorePackingPass::PackBlock(MachineBasicBlock &MBB,
                                        FuncOpcode isValidOpcode,
                                        FuncReplace PackAndReplaceInstr,
                                        unsigned OperandInd,
                                        unsigned OperandReg) {
  auto MI = MBB.begin();
  auto E = MBB.end();
  int ExtraRegisters = 0;
  bool addExtraRegisters = false;

  std::vector<MachineBasicBlock::iterator> VInstr;
  std::unordered_map<unsigned, MachineBasicBlock::iterator> FirstInstr;

  while (MI != E) {
    auto NMI = std::next(MI);

    if (NMI != E && areEnoughRegisters(ExtraRegisters)) {
      // FIXME: add support for frame index
      if (isValidOpcode(MI->getOpcode()) &&
          MI->getOperand(OperandReg).isReg()) {
        VInstr.push_back(MI);
        if (FirstInstr.find(MI->getOperand(OperandReg).getReg()) ==
            FirstInstr.end())
          FirstInstr[MI->getOperand(OperandReg).getReg()] = MI;

        if (addExtraRegisters)
          ++ExtraRegisters;
      } else if (!VInstr.empty()) {
        addExtraRegisters = true;
        ++ExtraRegisters;
      }
    } else {
      if (1 < VInstr.size()) {
        std::sort(
            VInstr.begin(), VInstr.end(),
            [ OperandInd, OperandReg ](MachineBasicBlock::iterator const & a,
                                       MachineBasicBlock::iterator const & b)
                                          ->bool {
              return a->getOperand(OperandReg).getReg() <
                         b->getOperand(OperandReg).getReg() ||
                     (a->getOperand(OperandReg).getReg() ==
                          b->getOperand(OperandReg).getReg() &&
                      a->getOperand(OperandInd).getImm() <
                          b->getOperand(OperandInd).getImm());
            });

        auto It = VInstr.begin();
        auto ItE = VInstr.end();
        while (It != ItE) {
          auto ItStart = It;
          auto NIt = std::next(It);
          unsigned Count = 1;
          while (*NIt != *ItE && Count < 4 &&
                 (*It)->getOperand(OperandReg).getReg() ==
                     (*NIt)->getOperand(OperandReg).getReg() &&
                 (*It)->getOperand(OperandInd).getImm() + 8 ==
                     (*NIt)->getOperand(OperandInd).getImm()) {
            It = NIt;
            ++NIt;
            ++Count;
          }

          if (Count > 1 &&
              FirstInstr.find((*ItStart)->getOperand(OperandReg).getReg()) !=
                  FirstInstr.end()) {
            PackAndReplaceInstr(
                FirstInstr[(*ItStart)->getOperand(OperandReg).getReg()],
                ItStart, Count == 4 ? Count : 2);
          }

          ++It;
        }
      }

      FirstInstr.clear();
      VInstr.clear();
      ExtraRegisters = 0;
      addExtraRegisters = false;
    }

    MI = NMI;
  }

  return true;
}

INITIALIZE_PASS(KVXLoadStorePackingPass, KVXLOADSTOREPACKING_NAME,
                KVXLOADSTOREPACKING_DESC, false, false)

FunctionPass *llvm::createKVXLoadStorePackingPass() {
  return new KVXLoadStorePackingPass();
}
