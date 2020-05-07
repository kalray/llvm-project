//===- KVXVLIWPacketizer.cpp - KVX Packetizer Class -----------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the KVX Packetizer class implementation.
//
//===----------------------------------------------------------------------===//

#include "KVXVLIWPacketizer.h"
#include "KVX.h"
#include "KVXInstrInfo.h"
#include "KVXTargetMachine.h"

#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/CodeGen/MachineDominators.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineLoopInfo.h"
#include "llvm/CodeGen/ScheduleDAG.h"
#include "llvm/CodeGen/TargetSchedule.h"

#define MAX_SYLLABLES_BYTE_COUNT (8 /* Syllables */ * 4 /* 32 bits words */)

using namespace llvm;

#define DEBUG_TYPE "kvx-bundling"

namespace {

class KVXPacketizer : public MachineFunctionPass {
public:
  static char ID;

  KVXPacketizer(bool ValidOptLevel = false)
      : MachineFunctionPass(ID), ValidOptLevel(ValidOptLevel) {}

  StringRef getPassName() const override { return "KVX Packetizer"; }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesCFG();
    AU.addRequired<AAResultsWrapperPass>();
    AU.addRequired<MachineDominatorTree>();
    AU.addRequired<MachineLoopInfo>();
    AU.addPreserved<MachineDominatorTree>();
    AU.addPreserved<MachineLoopInfo>();
    MachineFunctionPass::getAnalysisUsage(AU);
  }

  bool runOnMachineFunction(MachineFunction &Fn) override;

private:
  bool ValidOptLevel;
};

} // end anonymous namespace

char KVXPacketizer::ID = 0;
INITIALIZE_PASS_BEGIN(KVXPacketizer, "kvx-packetizer", "KVX Packetizer", false,
                      false)
INITIALIZE_PASS_DEPENDENCY(MachineDominatorTree)
INITIALIZE_PASS_DEPENDENCY(MachineLoopInfo)
INITIALIZE_PASS_DEPENDENCY(AAResultsWrapperPass)
INITIALIZE_PASS_END(KVXPacketizer, "kvx-packetizer", "KVX Packetizer", false,
                    false)

KVXPacketizerList::KVXPacketizerList(MachineFunction &MF, MachineLoopInfo &MLI,
                                     AliasAnalysis *AA, bool ValidOptLevel)
    : VLIWPacketizerList(MF, MLI, AA), PacketSize(0),
      ValidOptLevel(ValidOptLevel) {}

bool KVXPacketizerList::shouldAddToPacket(const MachineInstr &MI) {
  return MI.getDesc().getSize() + PacketSize <= MAX_SYLLABLES_BYTE_COUNT;
}

MachineBasicBlock::iterator KVXPacketizerList::addToPacket(MachineInstr &MI) {
  PacketSize += MI.getDesc().getSize();

  return VLIWPacketizerList::addToPacket(MI);
}

void KVXPacketizerList::endPacket(MachineBasicBlock *MBB,
                                  MachineBasicBlock::iterator MI) {
  // Reset the packet info
  PacketSize = 0;

  VLIWPacketizerList::endPacket(MBB, MI);
}

bool KVXPacketizerList::isSoloInstruction(const MachineInstr &MI) {
  if (MI.isInlineAsm())
    return true;

  // WFXL, WFXM, and SET instructions have to be alone in a bundle if they write
  // an AloneReg register.
  if (isSetOrWFXLOrWFXM(MI.getOpcode()))
    return KVX::AloneRegRegClass.contains(MI.getOperand(0).getReg());

  return !ValidOptLevel || MI.getDesc().getSchedClass() == KVX::Sched::ALL;
}

bool KVXPacketizerList::usesCarry(unsigned Opcode) {
  switch (Opcode) {
  default:
    return false;
  case KVX::ADDCD:
  case KVX::ADDCID:
  case KVX::SBFCD:
  case KVX::SBFCID:
    return true;
  }
}

// Ignore bundling of pseudo instructions.
bool KVXPacketizerList::ignorePseudoInstruction(const MachineInstr &MI,
                                                const MachineBasicBlock *) {
  if (MI.isDebugInstr()) {
    LLVM_DEBUG(dbgs() << "ignorePseudoInstruction::isDebugInst "; MI.dump(););
    return true;
  }

  if (MI.isPosition()) {
    LLVM_DEBUG(dbgs() << "ignorePseudoInstruction::isPosition "; MI.dump(););
    return true;
  }

  return false;
}

bool KVXPacketizerList::isALU(unsigned ScheduleCode) {
  switch (ScheduleCode) {
  default:
    return false;
  case KVX::Sched::ALU_FULL:
  case KVX::Sched::ALU_LITE:
  case KVX::Sched::ALU_LITE_CRWH:
  case KVX::Sched::ALU_LITE_CRWL:
  case KVX::Sched::ALU_NOP:
  case KVX::Sched::ALU_TINY:
  case KVX::Sched::ALU_FULL_X:
  case KVX::Sched::ALU_LITE_X:
  case KVX::Sched::ALU_TINY_X:
  case KVX::Sched::ALU_FULL_Y:
  case KVX::Sched::ALU_LITE_Y:
  case KVX::Sched::ALU_TINY_Y:
    return true;
  }
}

bool KVXPacketizerList::isMAU(unsigned ScheduleCode) {
  switch (ScheduleCode) {
  default:
    return false;
  case KVX::Sched::MAU:
  case KVX::Sched::MAU_X:
  case KVX::Sched::MAU_Y:
  case KVX::Sched::MAU_AUXR:
  case KVX::Sched::MAU_AUXR_X:
  case KVX::Sched::MAU_AUXR_Y:
    return true;
  }
}

bool KVXPacketizerList::useFloatingPointIEEE754(unsigned Opcode) {
  switch (Opcode) {
  default:
    return false;
  case KVX::FADDCDC:
  case KVX::FADDCWCri:
  case KVX::FADDCWCrr:
  case KVX::FADDCWCP:
  case KVX::FADDDrr:
  case KVX::FADDDri:
  case KVX::FADDDP:
  case KVX::FADDHQrr:
  case KVX::FADDHQri:
  case KVX::FADDWPri:
  case KVX::FADDWPrr:
  case KVX::FADDWQ:
  case KVX::FCDIVD:
  case KVX::FCDIVW:
  case KVX::FCDIVWP:
  case KVX::FINVW:
  case KVX::FDOT2Wri:
  case KVX::FDOT2Wrr:
  case KVX::FDOT2WDri:
  case KVX::FDOT2WDrr:
  case KVX::FDOT2WDP:
  case KVX::FDOT2WZP:
  case KVX::FFMADri:
  case KVX::FFMADrr:
  case KVX::FFMAHQri:
  case KVX::FFMAHQrr:
  case KVX::FFMAHWri:
  case KVX::FFMAHWrr:
  case KVX::FFMAHWQri:
  case KVX::FFMAHWQrr:
  case KVX::FFMAWri:
  case KVX::FFMAWrr:
  case KVX::FFMAWDri:
  case KVX::FFMAWDrr:
  case KVX::FFMAWDPri:
  case KVX::FFMAWDPrr:
  case KVX::FFMAWPri:
  case KVX::FFMAWPrr:
  case KVX::FFMSDri:
  case KVX::FFMSDrr:
  case KVX::FFMSHWQri:
  case KVX::FFMSHWQrr:
  case KVX::FFMSWri:
  case KVX::FFMSWrr:
  case KVX::FFMSWDri:
  case KVX::FFMSWDrr:
  case KVX::FFMSWDPri:
  case KVX::FFMSWDPrr:
  case KVX::FISRW:
  case KVX::FIXEDD:
  case KVX::FIXEDUD:
  case KVX::FIXEDUW:
  case KVX::FIXEDUWP:
  case KVX::FIXEDW:
  case KVX::FIXEDWP:
  case KVX::FLOATD:
  case KVX::FLOATUD:
  case KVX::FLOATUW:
  case KVX::FLOATUWP:
  case KVX::FLOATW:
  case KVX::FLOATWP:
  case KVX::FMM2AWQ:
  case KVX::FMM2SWQ:
  case KVX::FMM2WQ:
  case KVX::FMULCWCri:
  case KVX::FMULCWCrr:
  case KVX::FMULCWDCri:
  case KVX::FMULCWDCrr:
  case KVX::FMULDri:
  case KVX::FMULDrr:
  case KVX::FMULHQri:
  case KVX::FMULHQrr:
  case KVX::FMULHWri:
  case KVX::FMULHWrr:
  case KVX::FMULHWQri:
  case KVX::FMULHWQrr:
  case KVX::FMULWri:
  case KVX::FMULWrr:
  case KVX::FMULWCri:
  case KVX::FMULWCrr:
  case KVX::FMULWDri:
  case KVX::FMULWDrr:
  case KVX::FMULWDCri:
  case KVX::FMULWDCrr:
  case KVX::FMULWDPri:
  case KVX::FMULWDPrr:
  case KVX::FMULWPri:
  case KVX::FMULWPrr:
  case KVX::FMULWQ:
  case KVX::FNARROWDW:
  case KVX::FNARROWDWP:
  case KVX::FNARROWWH:
  case KVX::FNARROWWHQ:
  case KVX::FSBFCDC:
  case KVX::FSBFCWCrr:
  case KVX::FSBFCWCri:
  case KVX::FSBFCWCP:
  case KVX::FSBFDri:
  case KVX::FSBFDrr:
  case KVX::FSBFDP:
  case KVX::FSBFHQri:
  case KVX::FSBFHQrr:
  case KVX::FSBFWri:
  case KVX::FSBFWrr:
  case KVX::FSBFWPri:
  case KVX::FSBFWPrr:
  case KVX::FSBFWQ:
  case KVX::FSDIVD:
  case KVX::FSDIVW:
  case KVX::FSDIVWP:
  case KVX::FSINVD:
  case KVX::FSINVW:
  case KVX::FSINVWP:
  case KVX::FWIDENLHW:
  case KVX::FWIDENLHWP:
  case KVX::FWIDENLWD:
  case KVX::FWIDENMHW:
  case KVX::FWIDENMHWP:
  case KVX::FWIDENMWD:
    return true;
  }
}

bool KVXPacketizerList::shouldBeLastInBundle(unsigned opcode) {
  switch (opcode) {
  default:
    return false;
  case KVX::ICALL:
  case KVX::CALL:
  case KVX::CALLPLT:
  case KVX::SCALLr:
  case KVX::SCALLs:
  case KVX::IGOTO:
  case KVX::BARRIER:
  case KVX::STOP:
  case KVX::SLEEP:
  case KVX::AWAIT:
  case KVX::CB:
    return true;
  }
}

static MachineBasicBlock::instr_iterator
moveInstrOut(MachineInstr &MI, MachineBasicBlock::iterator BundleIt,
             MachineBasicBlock::instr_iterator InsertPt) {

  MachineBasicBlock &B = *MI.getParent();
  // The instruction should at least be bundled with the preceding instruction
  // (there will always be one, i.e. BUNDLE, if nothing else).
  assert(MI.isBundledWithPred());
  if (MI.isBundledWithSucc()) {
    MI.clearFlag(MachineInstr::BundledSucc);
    MI.clearFlag(MachineInstr::BundledPred);
  } else {
    // If it's not bundled with the successor (i.e. it is the last one
    // in the bundle), then we can simply unbundle it from the predecessor,
    // which will take care of updating the predecessor's flag.
    MI.unbundleFromPred();
  }
  B.splice(InsertPt, &B, MI.getIterator());

  // Get the size of the bundle without asserting.
  MachineBasicBlock::const_instr_iterator I = BundleIt.getInstrIterator();
  MachineBasicBlock::const_instr_iterator E = B.instr_end();
  unsigned Size = 0;
  for (++I; I != E && I->isBundledWithPred(); ++I)
    ++Size;

  // If there are still two or more instructions, then there is nothing
  // else to be done.
  if (Size > 1)
    return InsertPt;

  // Otherwise, extract the single instruction out and delete the bundle.
  MachineInstr &SingleI = *BundleIt->getNextNode();
  SingleI.unbundleFromPred();
  assert(!SingleI.isBundledWithSucc());
  BundleIt->eraseFromParent();
  return InsertPt;
}

void KVXPacketizerList::moveCFIDebugInstructions(MachineFunction &MF) {
  for (auto &B : MF) {
    MachineBasicBlock::iterator BundleIt;
    MachineBasicBlock::instr_iterator NextI;

    MachineBasicBlock::instr_iterator LastLocation = B.instr_begin();
    MachineBasicBlock::iterator LastBundle = B.instr_end();

    for (auto I = B.instr_begin(), E = B.instr_end(); I != E; I = NextI) {
      NextI = std::next(I);
      MachineInstr &MI = *I;

      if (MI.isBundle()) {
        BundleIt = I;
      }

      if (!MI.isInsideBundle())
        continue;

      if (MI.isCFIInstruction()) {
        if (LastBundle == BundleIt)
          LastLocation = moveInstrOut(MI, BundleIt, LastLocation);
        else
          LastLocation = moveInstrOut(MI, BundleIt,
                                      std::next(BundleIt).getInstrIterator());

        LastBundle = BundleIt;
      }

      if (MI.isDebugInstr() || MI.isLabel()) {
        moveInstrOut(MI, BundleIt, BundleIt.getInstrIterator());
      }
    }
  }
}

bool KVXPacketizerList::isSetOrWFXL(unsigned Opcode) {
  switch (Opcode) {
  default:
    return false;
  case KVX::SETrst3:
  case KVX::SETrsa:
  case KVX::SETrsra:
  case KVX::SETrst4:
  case KVX::WFXLrst2:
  case KVX::WFXLrsa:
  case KVX::WFXLrst4:
    return true;
  }
}

bool KVXPacketizerList::isSetOrWFXLOrWFXM(unsigned Opcode) {
  return isSetOrWFXL(Opcode) || Opcode == KVX::WFXMrst2 ||
         Opcode == KVX::WFXMrsa || Opcode == KVX::WFXMrst4;
}

bool KVXPacketizerList::isALUCarryWithSetOrWFXL(unsigned ISchedClass,
                                                unsigned IOpcode,
                                                unsigned JOpcode) {
  return isALU(ISchedClass) && usesCarry(IOpcode) && isSetOrWFXL(JOpcode);
}

bool KVXPacketizerList::isALUFP754OrMAUFP754WithSetOrWFX_(unsigned ISchedClass,
                                                          unsigned IOpcode,
                                                          unsigned JOpcode) {
  return ((isALU(ISchedClass) && useFloatingPointIEEE754(IOpcode)) ||
          (isMAU(ISchedClass) && useFloatingPointIEEE754(IOpcode))) &&
         isSetOrWFXLOrWFXM(JOpcode);
}

bool KVXPacketizerList::isLegalToPacketizeTogether(SUnit *SUI, SUnit *SUJ) {
  assert(SUI->getInstr() && SUJ->getInstr());
  MachineInstr &I = *SUI->getInstr();
  MachineInstr &J = *SUJ->getInstr();

  if (shouldBeLastInBundle(J.getOpcode())) {
    LLVM_DEBUG(dbgs() << "  (kvx)shouldBeLastInBundle ";);
    return false;
  }

  MachineFunction *MF = I.getParent()->getParent();
  const KVXRegisterInfo *TRI =
      (const KVXRegisterInfo *)MF->getSubtarget().getRegisterInfo();

  if (J.getNumOperands() > 0 && J.getDesc().getNumDefs() == 1 &&
      J.getOperand(0).isReg() && !J.getOperand(0).isImplicit()) {

    // Rule 1
    // Handle Write after Write case
    // Handle Read after Write case

    // Iterate all subregs including self reg of J output operand of instr J
    for (MCSubRegIterator JSubRegs(J.getOperand(0).getReg(), TRI,
                                   /*IncludeSelf=*/true);
         JSubRegs.isValid(); ++JSubRegs) {
      int JReg = *JSubRegs;

      // Iterate all operands of I
      for (unsigned IInd = 0; IInd < I.getNumOperands(); ++IInd) {
        if (I.getOperand(IInd).isReg() && !I.getOperand(IInd).isImplicit()) {
          // Iterate all subregs including self reg of IInd operand of instr I
          for (MCSubRegIterator ISubRegs(I.getOperand(IInd).getReg(), TRI,
                                         /*IncludeSelf=*/true);
               ISubRegs.isValid(); ++ISubRegs) {
            int IReg = *ISubRegs;
            if (JReg == IReg) {
              LLVM_DEBUG(
                  dbgs() << "  (kvx)write after write/read after write\n";);
              return false;
            }
          }
        }
      }
    }
  }

  // Rule 2
  // Two instructions of the same bundle must not target the same architectural
  // resource, otherwise the update value of this resource is unpredictable.
  // Implemented by itineraries -- see KVXSchedule.td

  unsigned ISchedClass = I.getDesc().getSchedClass();
  unsigned JSchedClass = J.getDesc().getSchedClass();

  // Rule 3 (Specialization of Rule 2) An ALU instruction that produces a carry
  // must not be bundled with a set or wfxl instruction on CS.
  if (isALUCarryWithSetOrWFXL(ISchedClass, I.getOpcode(), J.getOpcode()) ||
      isALUCarryWithSetOrWFXL(JSchedClass, J.getOpcode(), I.getOpcode())) {
    LLVM_DEBUG(dbgs() << "  (kvx)rule 3\n";);
    return false;
  }

  // Rule 4 (Specialization of Rule 2) An ALU or MAU instruction that produces
  // an IEEE 754 float- ing point flag must not be bundled with a set or wfx*
  // instruction on CS.

  if (isALUFP754OrMAUFP754WithSetOrWFX_(ISchedClass, I.getOpcode(),
                                        J.getOpcode()) ||
      isALUFP754OrMAUFP754WithSetOrWFX_(JSchedClass, J.getOpcode(),
                                        I.getOpcode())) {
    LLVM_DEBUG(dbgs() << "  (kvx)rule 4\n";);
    return false;
  }

  // Rule 5 If a (i)get or waitit instruction is issued within a bundle, then
  // the BCU and the tiny ALU unit inside the MAU are used. As a consequence: -
  // No MAU instruction is allowed in this bundle - Only 2 tiny ALU instructions
  // may be used in this bundle (one on each ALU). This rule is implicit and
  // covered by the instruction reservation tables.

  return true;
}

bool KVXPacketizer::runOnMachineFunction(MachineFunction &MF) {

  auto &MLI = getAnalysis<MachineLoopInfo>();
  auto *AA = &getAnalysis<AAResultsWrapperPass>().getAAResults();

  MF.getProperties().set(MachineFunctionProperties::Property::TracksLiveness);
  KVXPacketizerList Packetizer(MF, MLI, AA, ValidOptLevel);

  for (auto &MB : MF) {
    auto End = MB.end();
    auto MI = MB.begin();
    while (MI != End) {
      auto NextI = std::next(MI);
      if (MI->isKill() || MI->isImplicitDef()) {
        MB.erase(MI);
        End = MB.end();
      }
      MI = NextI;
    }
  }

  for (auto &MB : MF) {
    Packetizer.PacketizeMIs(&MB, MB.begin(), MB.end());
  }

  Packetizer.moveCFIDebugInstructions(MF);

  return true;
}

FunctionPass *llvm::createKVXPacketizerPass(bool ValidOptLevel) {
  return new KVXPacketizer(ValidOptLevel);
}
