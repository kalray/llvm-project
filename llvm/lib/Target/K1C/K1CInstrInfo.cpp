#include "K1CInstrInfo.h"
#include "K1C.h"
#include "K1CTargetMachine.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/RegisterScavenging.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/TargetRegistry.h"

#define GET_INSTRINFO_CTOR_DTOR
#include "K1CGenInstrInfo.inc"

using namespace llvm;

K1CInstrInfo::K1CInstrInfo()
    : K1CGenInstrInfo(K1C::ADJCALLSTACKDOWN, K1C::ADJCALLSTACKUP) {}

void K1CInstrInfo::copyPhysReg(MachineBasicBlock &MBB,
                               MachineBasicBlock::iterator MBBI,
                               const DebugLoc &DL, unsigned DstReg,
                               unsigned SrcReg, bool KillSrc) const {
  if (K1C::SingleRegRegClass.contains(DstReg, SrcReg)) {
    BuildMI(MBB, MBBI, DL, get(K1C::COPYD), DstReg)
        .addReg(SrcReg, getKillRegState(KillSrc));
    return;
  }
}

void K1CInstrInfo::loadRegFromStackSlot(MachineBasicBlock &MBB,
                                          MachineBasicBlock::iterator I,
                                          unsigned DstReg, int FI,
                                          const TargetRegisterClass *RC,
                                          const TargetRegisterInfo *TRI) const {
  DebugLoc DL;
  if (I != MBB.end())
    DL = I->getDebugLoc();

  if (K1C::SingleRegRegClass.hasSubClassEq(RC))
  {
      BuildMI(MBB, I, DL, get(K1C::LDd0), DstReg).addFrameIndex(FI).addReg(K1C::R12, 0).addImm(0);
  }
  
}

void K1CInstrInfo::storeRegToStackSlot(MachineBasicBlock &MBB,
                                       MachineBasicBlock::iterator I,
                                       unsigned SrcReg, bool IsKill, int FI,
                                       const TargetRegisterClass *RC,
                                       const TargetRegisterInfo *TRI) const {
  DebugLoc DL;
  if (I != MBB.end())
    DL = I->getDebugLoc();

  /*MachineFunction *MF = MBB.getParent();
  const MachineFrameInfo &MFI = MF->getFrameInfo();
  MachineMemOperand *MMO = MF->getMachineMemOperand(
      MachinePointerInfo::getFixedStack(*MF, FI), MachineMemOperand::MOStore,
      MFI.getObjectSize(FI), MFI.getObjectAlignment(FI)
  );*/

  if (K1C::SingleRegRegClass.hasSubClassEq(RC)) {
    BuildMI(MBB, I, DL, get(K1C::SDd0))
        .addFrameIndex(FI)        
        .addReg(K1C::R12, 0)
        .addReg(SrcReg, getKillRegState(IsKill)); //.addMemOperand(MMO)
  }
}