//===- K1CVLIWPacketizer.cpp - K1C Packetizer Class -----------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the K1C Packetizer class implementation.
//
//===----------------------------------------------------------------------===//

#include "K1CVLIWPacketizer.h"
#include "K1C.h"
#include "K1CInstrInfo.h"
#include "K1CTargetMachine.h"

#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineLoopInfo.h"
#include "llvm/CodeGen/ScheduleDAG.h"
#include "llvm/CodeGen/TargetSchedule.h"

#define MAX_SYLLABLES_BYTE_COUNT (8 /* Syllables */ * 4 /* 32 bits words */)

using namespace llvm;

namespace {

class K1CPacketizer : public MachineFunctionPass {
public:
  static char ID;

  K1CPacketizer(bool ValidOptLevel = false)
      : MachineFunctionPass(ID), ValidOptLevel(ValidOptLevel) {}

  StringRef getPassName() const override { return "K1C Packetizer"; }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesCFG();
    AU.addRequired<AAResultsWrapperPass>();
    AU.addRequired<MachineLoopInfo>();
    MachineFunctionPass::getAnalysisUsage(AU);
  }

  bool runOnMachineFunction(MachineFunction &Fn) override;

private:
  bool ValidOptLevel;
};

} // end anonymous namespace

char K1CPacketizer::ID = 0;
INITIALIZE_PASS_BEGIN(K1CPacketizer, "k1c-packetizer", "K1C Packetizer", false,
                      false)
INITIALIZE_PASS_DEPENDENCY(AAResultsWrapperPass)
INITIALIZE_PASS_DEPENDENCY(MachineLoopInfo)
INITIALIZE_PASS_END(K1CPacketizer, "k1c-packetizer", "K1C Packetizer", false,
                    false)

K1CPacketizerList::K1CPacketizerList(MachineFunction &MF, MachineLoopInfo &MLI,
                                     AliasAnalysis *AA, bool ValidOptLevel)
    : VLIWPacketizerList(MF, MLI, AA), PacketSize(0),
      ValidOptLevel(ValidOptLevel) {}

bool K1CPacketizerList::shouldAddToPacket(const MachineInstr &MI) {
  return MI.getDesc().getSize() + PacketSize <= MAX_SYLLABLES_BYTE_COUNT;
}

MachineBasicBlock::iterator K1CPacketizerList::addToPacket(MachineInstr &MI) {
  PacketSize += MI.getDesc().getSize();

  return VLIWPacketizerList::addToPacket(MI);
}

void K1CPacketizerList::endPacket(MachineBasicBlock *MBB,
                                  MachineBasicBlock::iterator MI) {
  // Reset the packet info
  PacketSize = 0;

  VLIWPacketizerList::endPacket(MBB, MI);
}

bool K1CPacketizerList::isSoloInstruction(const MachineInstr &MI) {
  if (MI.isInlineAsm())
    return true;
  return !ValidOptLevel || MI.getDesc().getSchedClass() == K1C::Sched::ALL;
}

bool K1CPacketizerList::usesCarry(unsigned Opcode) {
  switch (Opcode) {
  default:
    return false;
  case K1C::ADDCD:
  case K1C::ADDCID:
  case K1C::SBFCD:
  case K1C::SBFCID:
    return true;
  }
}

// Ignore bundling of pseudo instructions.
bool K1CPacketizerList::ignorePseudoInstruction(const MachineInstr &MI,
                                                const MachineBasicBlock *) {
  if (MI.isDebugInstr())
    return true;

  if (MI.isPosition())
    return true;

  return false;
}

bool K1CPacketizerList::isALU(unsigned ScheduleCode) {
  switch (ScheduleCode) {
  default:
    return false;
  case K1C::Sched::ALU_FULL:
  case K1C::Sched::ALU_LITE:
  case K1C::Sched::ALU_LITE_CRWH:
  case K1C::Sched::ALU_LITE_CRWL:
  case K1C::Sched::ALU_NOP:
  case K1C::Sched::ALU_TINY:
  case K1C::Sched::ALU_FULL_X:
  case K1C::Sched::ALU_LITE_X:
  case K1C::Sched::ALU_TINY_X:
  case K1C::Sched::ALU_FULL_Y:
  case K1C::Sched::ALU_LITE_Y:
  case K1C::Sched::ALU_TINY_Y:
    return true;
  }
}

bool K1CPacketizerList::isMAU(unsigned ScheduleCode) {
  switch (ScheduleCode) {
  default:
    return false;
  case K1C::Sched::MAU:
  case K1C::Sched::MAU_X:
  case K1C::Sched::MAU_Y:
  case K1C::Sched::MAU_AUXR:
  case K1C::Sched::MAU_AUXR_X:
  case K1C::Sched::MAU_AUXR_Y:
    return true;
  }
}

bool K1CPacketizerList::useFloatingPointIEEE754(unsigned Opcode) {
  switch (Opcode) {
  default:
    return false;
  case K1C::FADDCDC:
  case K1C::FADDCWCd0:
  case K1C::FADDCWCd1:
  case K1C::FADDCWCd2:
  case K1C::FADDCWCd3:
  case K1C::FADDCWCP:
  case K1C::FADDDri:
  case K1C::FADDDrr:
  case K1C::FADDDP:
  case K1C::FADDHQri:
  case K1C::FADDHQrr:
  case K1C::FADDWPd0:
  case K1C::FADDWPd1:
  case K1C::FADDWPd2:
  case K1C::FADDWPd3:
  case K1C::FADDWQ:
  case K1C::FCDIVD:
  case K1C::FCDIVW:
  case K1C::FCDIVWP:
  case K1C::FINVW:
  case K1C::FDOT2Wd0:
  case K1C::FDOT2Wd1:
  case K1C::FDOT2Wd2:
  case K1C::FDOT2Wd3:
  case K1C::FDOT2WDd0:
  case K1C::FDOT2WDd1:
  case K1C::FDOT2WDd2:
  case K1C::FDOT2WDd3:
  case K1C::FDOT2WDP:
  case K1C::FDOT2WZP:
  case K1C::FFMADd0:
  case K1C::FFMADd1:
  case K1C::FFMADd2:
  case K1C::FFMADd3:
  case K1C::FFMAHQd0:
  case K1C::FFMAHQd1:
  case K1C::FFMAHQd2:
  case K1C::FFMAHQd3:
  case K1C::FFMAHWd0:
  case K1C::FFMAHWd1:
  case K1C::FFMAHWd2:
  case K1C::FFMAHWd3:
  case K1C::FFMAHWQd0:
  case K1C::FFMAHWQd1:
  case K1C::FFMAHWQd2:
  case K1C::FFMAHWQd3:
  case K1C::FFMAWd0:
  case K1C::FFMAWd1:
  case K1C::FFMAWd2:
  case K1C::FFMAWd3:
  case K1C::FFMAWDd0:
  case K1C::FFMAWDd1:
  case K1C::FFMAWDd2:
  case K1C::FFMAWDd3:
  case K1C::FFMAWDPd0:
  case K1C::FFMAWDPd1:
  case K1C::FFMAWDPd2:
  case K1C::FFMAWDPd3:
  case K1C::FFMAWPd0:
  case K1C::FFMAWPd1:
  case K1C::FFMAWPd2:
  case K1C::FFMAWPd3:
  case K1C::FFMSDd0:
  case K1C::FFMSDd1:
  case K1C::FFMSDd2:
  case K1C::FFMSDd3:
  case K1C::FFMSHWQd0:
  case K1C::FFMSHWQd1:
  case K1C::FFMSHWQd2:
  case K1C::FFMSHWQd3:
  case K1C::FFMSWd0:
  case K1C::FFMSWd1:
  case K1C::FFMSWd2:
  case K1C::FFMSWd3:
  case K1C::FFMSWDd0:
  case K1C::FFMSWDd1:
  case K1C::FFMSWDd2:
  case K1C::FFMSWDd3:
  case K1C::FFMSWDPd0:
  case K1C::FFMSWDPd1:
  case K1C::FFMSWDPd2:
  case K1C::FFMSWDPd3:
  case K1C::FISRW:
  case K1C::FIXEDD:
  case K1C::FIXEDUD:
  case K1C::FIXEDUW:
  case K1C::FIXEDUWP:
  case K1C::FIXEDW:
  case K1C::FIXEDWP:
  case K1C::FLOATD:
  case K1C::FLOATUD:
  case K1C::FLOATUW:
  case K1C::FLOATUWP:
  case K1C::FLOATW:
  case K1C::FLOATWP:
  case K1C::FMM2AWQ:
  case K1C::FMM2SWQ:
  case K1C::FMM2WQ:
  case K1C::FMULCWCd0:
  case K1C::FMULCWCd1:
  case K1C::FMULCWCd2:
  case K1C::FMULCWCd3:
  case K1C::FMULCWDCd0:
  case K1C::FMULCWDCd1:
  case K1C::FMULCWDCd2:
  case K1C::FMULCWDCd3:
  case K1C::FMULDri:
  case K1C::FMULDrr:
  case K1C::FMULHQri:
  case K1C::FMULHQrr:
  case K1C::FMULHWd0:
  case K1C::FMULHWd1:
  case K1C::FMULHWd2:
  case K1C::FMULHWd3:
  case K1C::FMULHWQd0:
  case K1C::FMULHWQd1:
  case K1C::FMULHWQd2:
  case K1C::FMULHWQd3:
  case K1C::FMULWri:
  case K1C::FMULWrr:
  case K1C::FMULWCd0:
  case K1C::FMULWCd1:
  case K1C::FMULWCd2:
  case K1C::FMULWCd3:
  case K1C::FMULWDd0:
  case K1C::FMULWDd1:
  case K1C::FMULWDd2:
  case K1C::FMULWDd3:
  case K1C::FMULWDCd0:
  case K1C::FMULWDCd1:
  case K1C::FMULWDCd2:
  case K1C::FMULWDCd3:
  case K1C::FMULWDPd0:
  case K1C::FMULWDPd1:
  case K1C::FMULWDPd2:
  case K1C::FMULWDPd3:
  case K1C::FMULWPd0:
  case K1C::FMULWPd1:
  case K1C::FMULWPd2:
  case K1C::FMULWPd3:
  case K1C::FMULWQ:
  case K1C::FNARROWDW:
  case K1C::FNARROWDWP:
  case K1C::FNARROWWH:
  case K1C::FNARROWWHQ:
  case K1C::FSBFCDC:
  case K1C::FSBFCWCd0:
  case K1C::FSBFCWCd1:
  case K1C::FSBFCWCd2:
  case K1C::FSBFCWCd3:
  case K1C::FSBFCWCP:
  case K1C::FSBFDri:
  case K1C::FSBFDrr:
  case K1C::FSBFDP:
  case K1C::FSBFHQri:
  case K1C::FSBFHQrr:
  case K1C::FSBFWri:
  case K1C::FSBFWrr:
  case K1C::FSBFWPd0:
  case K1C::FSBFWPd1:
  case K1C::FSBFWPd2:
  case K1C::FSBFWPd3:
  case K1C::FSBFWQ:
  case K1C::FSDIVD:
  case K1C::FSDIVW:
  case K1C::FSDIVWP:
  case K1C::FSINVD:
  case K1C::FSINVW:
  case K1C::FSINVWP:
  case K1C::FWIDENLHW:
  case K1C::FWIDENLHWP:
  case K1C::FWIDENLWD:
  case K1C::FWIDENMHW:
  case K1C::FWIDENMHWP:
  case K1C::FWIDENMWD:
    return true;
  }
}

bool K1CPacketizerList::shouldBeLastInBundle(unsigned opcode) {
  switch (opcode) {
  default:
    return false;
  case K1C::ICALL:
  case K1C::CALL:
  case K1C::SCALLd0:
  case K1C::SCALLd1:
  case K1C::IGOTO:
  case K1C::BARRIER:
  case K1C::STOP:
  case K1C::SLEEP:
  case K1C::AWAIT:
  case K1C::CB:
    return true;
  }
}

static MachineBasicBlock::iterator
moveInstrOut(MachineInstr &MI, MachineBasicBlock::iterator BundleIt,
             bool Before) {
  MachineBasicBlock::instr_iterator InsertPt;
  if (Before)
    InsertPt = BundleIt.getInstrIterator();
  else
    InsertPt = std::next(BundleIt).getInstrIterator();

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
    return BundleIt;
  // Otherwise, extract the single instruction out and delete the bundle.
  MachineBasicBlock::iterator NextIt = std::next(BundleIt);
  MachineInstr &SingleI = *BundleIt->getNextNode();
  SingleI.unbundleFromPred();
  assert(!SingleI.isBundledWithSucc());
  BundleIt->eraseFromParent();
  return NextIt;
}

void K1CPacketizerList::moveCFIDebugInstructions(MachineFunction &MF) {
  for (auto &B : MF) {
    MachineBasicBlock::iterator BundleIt;
    MachineBasicBlock::instr_iterator NextI;
    for (auto I = B.instr_begin(), E = B.instr_end(); I != E; I = NextI) {
      NextI = std::next(I);
      MachineInstr &MI = *I;
      if (MI.isBundle())
        BundleIt = I;
      if (!MI.isInsideBundle())
        continue;
      bool InsertBeforeBundle;

      if (MI.isCFIInstruction()) {
        // Insert at the begining of the next bundle
        InsertBeforeBundle = false;
      } else if (MI.isDebugInstr() || MI.isLabel()) {
        InsertBeforeBundle = true;
      } else {
        continue;
      }

      BundleIt = moveInstrOut(MI, BundleIt, InsertBeforeBundle);
    }
  }
}

bool K1CPacketizerList::isSetOrWFXL(unsigned Opcode) {
  switch (Opcode) {
  default:
    return false;
    // case K1C::SETd0: Not defined yet
    // case K1C::SETd1: Not defined yet
  case K1C::SETd2:
  case K1C::WFXLd0:
    // case K1C::WFXLd1: Not defined yet
    return true;
  }
}

bool K1CPacketizerList::isALUCarryWithSetOrWFXL(unsigned ISchedClass,
                                                unsigned IOpcode,
                                                unsigned JOpcode) {
  return isALU(ISchedClass) && usesCarry(IOpcode) && isSetOrWFXL(JOpcode);
}

bool K1CPacketizerList::isALUFP754OrMAUFP754WithSetOrWFX_(unsigned ISchedClass,
                                                          unsigned IOpcode,
                                                          unsigned JOpcode) {
  return ((isALU(ISchedClass) && useFloatingPointIEEE754(IOpcode)) ||
          (isMAU(ISchedClass) && useFloatingPointIEEE754(IOpcode))) &&
         (isSetOrWFXL(JOpcode) /*|| JOpcode == K1C::WFXM*/);
}

bool K1CPacketizerList::isLegalToPacketizeTogether(SUnit *SUI, SUnit *SUJ) {
  assert(SUI->getInstr() && SUJ->getInstr());
  MachineInstr &I = *SUI->getInstr();
  MachineInstr &J = *SUJ->getInstr();

  if (shouldBeLastInBundle(J.getOpcode()))
    return false;

  if (J.getNumOperands() > 0 && J.getDesc().getNumDefs() == 1 &&
      J.getOperand(0).isReg()) {
    // Handle Write after Write case
    // Handle Read after Write case
    for (unsigned IInd = 0; IInd < I.getNumOperands(); ++IInd)
      if (I.getOperand(IInd).isReg() &&
          J.getOperand(0).getReg() == I.getOperand(IInd).getReg() &&
          J.getOperand(0).getSubReg() == I.getOperand(IInd).getSubReg())
        return false;
  }

  // Rule 1
  // Two data dependent instructions may not be scheduled within a single bundle
  for (unsigned JInd = 0; JInd < SUJ->Succs.size(); ++JInd) {
    if (SUJ->Succs[JInd].getSUnit() != SUI)
      continue;

    SDep::Kind DepType = SUJ->Succs[JInd].getKind();

    if (DepType == SDep::Data)
      return false;
  }

  // Rule 2
  // Two instructions of the same bundle must not target the same architectural
  // resource, otherwise the update value of this resource is unpredictable.
  // Implemented by itineraries -- see K1CSchedule.td

  unsigned ISchedClass = I.getDesc().getSchedClass();
  unsigned JSchedClass = J.getDesc().getSchedClass();

  // Rule 3 (Specialization of Rule 2) An ALU instruction that produces a carry
  // must not be bundled with a set or wfxl instruction on CS.
  if (isALUCarryWithSetOrWFXL(ISchedClass, I.getOpcode(), J.getOpcode()) ||
      isALUCarryWithSetOrWFXL(JSchedClass, J.getOpcode(), I.getOpcode()))
    return false;

  // Rule 4 (Specialization of Rule 2) An ALU or MAU instruction that produces
  // an IEEE 754 float- ing point flag must not be bundled with a set or wfx*
  // instruction on CS.

  if (isALUFP754OrMAUFP754WithSetOrWFX_(ISchedClass, I.getOpcode(),
                                        J.getOpcode()) ||
      isALUFP754OrMAUFP754WithSetOrWFX_(JSchedClass, J.getOpcode(),
                                        I.getOpcode()))
    return false;

  // Rule 5 If a (i)get or waitit instruction is issued within a bundle, then
  // the BCU and the tiny ALU unit inside the MAU are used. As a consequence: -
  // No MAU instruction is allowed in this bundle - Only 2 tiny ALU instructions
  // may be used in this bundle (one on each ALU). This rule is implicit and
  // covered by the instruction reservation tables.

  return true;
}

bool K1CPacketizer::runOnMachineFunction(MachineFunction &MF) {

  auto &MLI = getAnalysis<MachineLoopInfo>();
  auto *AA = &getAnalysis<AAResultsWrapperPass>().getAAResults();

  MF.getProperties().set(MachineFunctionProperties::Property::TracksLiveness);
  K1CPacketizerList Packetizer(MF, MLI, AA, ValidOptLevel);

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

FunctionPass *llvm::createK1CPacketizerPass(bool ValidOptLevel) {
  return new K1CPacketizer(ValidOptLevel);
}
