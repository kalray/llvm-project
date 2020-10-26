//===-- KVXPreEmitExpandPseudoInsts.cpp - Expand pseudo instructions ------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains a pass that expands pseudo instructions into target
// instructions. This pass should be run after register allocation but before
// the post-regalloc scheduling pass.
//
//===----------------------------------------------------------------------===//

#include "KVX.h"
#include "KVXInstrInfo.h"
#include "KVXTargetMachine.h"

#include "llvm/CodeGen/LivePhysRegs.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/Support/Debug.h"

using namespace llvm;

#define KVX_PREEMIT_EXPAND_PSEUDO_NAME                                         \
  "KVX pre emit pseudo instruction expansion pass"
#define DEBUG_TYPE "pre-emit-expand-pseudo"

namespace {

class KVXPreEmitExpandPseudo : public MachineFunctionPass {
public:
  const KVXInstrInfo *TII;
  static char ID;

  KVXPreEmitExpandPseudo() : MachineFunctionPass(ID) {
    initializeKVXPreEmitExpandPseudoPass(*PassRegistry::getPassRegistry());
  }

  bool runOnMachineFunction(MachineFunction &MF) override;

  StringRef getPassName() const override {
    return KVX_PREEMIT_EXPAND_PSEUDO_NAME;
  }

private:
  bool expandMBB(MachineBasicBlock &MBB);
  bool expandMI(MachineBasicBlock &MBB, MachineBasicBlock::iterator MBBI,
                MachineBasicBlock::iterator &NextMBBI);
};

char KVXPreEmitExpandPseudo::ID = 0;

bool KVXPreEmitExpandPseudo::runOnMachineFunction(MachineFunction &MF) {
  TII = static_cast<const KVXInstrInfo *>(MF.getSubtarget().getInstrInfo());
  bool Modified = false;
  for (auto &MBB : MF)
    Modified |= expandMBB(MBB);
  return Modified;
}

bool KVXPreEmitExpandPseudo::expandMBB(MachineBasicBlock &MBB) {
  bool Modified = false;

  MachineBasicBlock::iterator MBBI = MBB.begin(), E = MBB.end();
  while (MBBI != E) {
    MachineBasicBlock::iterator NMBBI = std::next(MBBI);
    Modified |= expandMI(MBB, MBBI, NMBBI);
    MBBI = NMBBI;
  }

  // TODO: Remove useless GOTOs. Should be done in a separate pass.
  if (!MBB.empty()) {
    MBBI = MBB.end();
    --MBBI;

    if (MBBI->getOpcode() == KVX::GOTO &&
        MBB.isLayoutSuccessor(MBBI->getOperand(0).getMBB())) {
      MBBI->eraseFromParent();
      Modified = true;
    }
  }

  return Modified;
}

// Build a KVX::CMOVED MachineInstr from SELECT.
static void BuildCMOVED(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                        MachineBasicBlock::iterator MBBI, Register DestReg,
                        Register ValReg, Register CondReg,
                        unsigned CondMod /*KVXMOD::SCALARCOND*/) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  switch (MI.getOperand(ValReg).getType()) {
  case MachineOperand::MO_GlobalAddress:
    BuildMI(MBB, MBBI, DL, TII->get(KVX::CMOVEDri64), DestReg)
        .addReg(CondReg)
        .addReg(DestReg)
        .addGlobalAddress(MI.getOperand(ValReg).getGlobal())
        .addImm(CondMod);
    break;
  case MachineOperand::MO_Register: {
    BuildMI(MBB, MBBI, DL, TII->get(KVX::CMOVEDrr), DestReg)
        .addReg(CondReg)
        .addReg(DestReg)
        .addReg(MI.getOperand(ValReg).getReg())
        .addImm(CondMod);
  } break;
  case MachineOperand::MO_Immediate: {
    int64_t ValImm = MI.getOperand(ValReg).getImm();
    BuildMI(MBB, MBBI, DL,
            TII->get(GetImmOpCode(ValImm, KVX::CMOVEDri10, KVX::CMOVEDri37,
                                  KVX::CMOVEDri64)),
            DestReg)
        .addReg(CondReg)
        .addReg(DestReg)
        .addImm(ValImm)
        .addImm(CondMod);
  } break;
  case MachineOperand::MO_FPImmediate: {
    const ConstantFP *ValImm = MI.getOperand(ValReg).getFPImm();
    BuildMI(MBB, MBBI, DL,
            TII->get(ValImm->getType()->isFloatTy() ? KVX::CMOVEDri37
                                                    : KVX::CMOVEDri64),
            DestReg)
        .addReg(CondReg)
        .addReg(DestReg)
        .addFPImm(ValImm)
        .addImm(CondMod);
  } break;
  default:
    llvm_unreachable("Operator type not handled");
    break;
  }
}

static bool expandSELECT(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                         MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  Register DestReg = MI.getOperand(0).getReg();
  Register ScratchReg = MI.getOperand(1).getReg();
  Register CondReg = MI.getOperand(2).getReg();
  unsigned TrueReg = 3;
  MachineOperand TrueVal = MI.getOperand(TrueReg);
  unsigned FalseReg = 4;
  MachineOperand FalseVal = MI.getOperand(FalseReg);
  unsigned CondMod = MI.getOperand(5).getImm();

  if (FalseVal.isImm() || FalseVal.isFPImm() || FalseVal.isGlobal()) {
    // FalseVal is an immediate, inverse the condition to select
    // FalseVal using faster CMOVED with immediate.
    // TODO: Use a method based on KVXMOD::SCALARCOND enum.
    CondMod = CondMod % 2 == 0 ? CondMod + 1 : CondMod - 1;

    if (TrueVal.isReg()) {
      Register Reg = TrueVal.getReg();

      if (Reg != DestReg) {
        BuildMI(MBB, MBBI, DL, TII->get(KVX::COPYD), ScratchReg).addReg(Reg);
        BuildCMOVED(TII, MBB, MBBI, ScratchReg, FalseReg, CondReg, CondMod);
        BuildMI(MBB, MBBI, DL, TII->get(KVX::COPYD), DestReg)
            .addReg(ScratchReg);
      } else {
        BuildCMOVED(TII, MBB, MBBI, Reg, FalseReg, CondReg, CondMod);
      }

    } else {

      if (DestReg == CondReg) {
        // Use ScartchReg to hold CondReg and optimize scheduling with
        // immediate materialization.
        unsigned COPY = isScalarcondWord(CondMod) ? KVX::COPYW : KVX::COPYD;
        BuildMI(MBB, MBBI, DL, TII->get(COPY), ScratchReg).addReg(CondReg);
        DestReg = CondReg;
      } else {
        ScratchReg = CondReg;
      }

      if (TrueVal.isImm()) {
        int64_t TrueImm = TrueVal.getImm();
        unsigned MAKEi = GetImmMakeOpCode(TrueImm);
        BuildMI(MBB, MBBI, DL, TII->get(MAKEi), DestReg).addImm(TrueImm);
      } else if (TrueVal.isFPImm()) {
        unsigned MAKEi;
        if (TrueVal.getFPImm()->getType()->isDoubleTy())
          MAKEi = KVX::MAKEi64;
        else if (TrueVal.getFPImm()->getType()->isFloatTy())
          MAKEi = KVX::MAKEi43;
        else
          MAKEi = KVX::MAKEi16;
        BuildMI(MBB, MBBI, DL, TII->get(MAKEi), DestReg)
            .addFPImm(TrueVal.getFPImm());
      } else if (TrueVal.isGlobal()) {
        BuildMI(MBB, MBBI, DL, TII->get(KVX::MAKEi64), DestReg)
            .addGlobalAddress(TrueVal.getGlobal());
      }

      BuildCMOVED(TII, MBB, MBBI, DestReg, FalseReg, ScratchReg, CondMod);
    }

  } else {
    assert(FalseVal.isReg());
    BuildCMOVED(TII, MBB, MBBI, FalseVal.getReg(), TrueReg, CondReg, CondMod);
  }

  MI.eraseFromParent();
  return true;
}

// Return load opcode used by atomic operations.
unsigned getLOADOpcode(uint64_t Size, const MachineOperand MO) {
  switch (Size) {
  case 4:
    return MO.isReg() ? KVX::LWZrr : KVX::LWZp;
  case 8:
    return MO.isReg() ? KVX::LDrr : KVX::LDp;
  default:
    llvm_unreachable("No LOAD Opcode for this Size");
  }
}

// Return acswap opcode used by atomic operations.
signed getACSWAPOpcode(uint64_t Size, const MachineOperand MO) {
  // Return -1 if MO is an immediate that doesn't fit in a 37-bit integer.
  switch (Size) {
  case 4:
    return MO.isReg() ? KVX::ACSWAPWrr
                      : isInt<10>(MO.getImm())
                            ? KVX::ACSWAPWri10
                            : isInt<37>(MO.getImm()) ? KVX::ACSWAPWri37 : -1;
  case 8:
    return MO.isReg() ? KVX::ACSWAPDrr
                      : isInt<10>(MO.getImm())
                            ? KVX::ACSWAPDri10
                            : isInt<37>(MO.getImm()) ? KVX::ACSWAPDri37 : -1;
  default:
    llvm_unreachable("No ACSWAP Opcode for this Size");
  }
}

// Return acswap opcode used by atomic operations. Modify memory addressing
// mode if it uses an immediate value that doesn't fix in a 37-bit integer.
signed getACSWAPOpcodeModifyAddr(const KVXInstrInfo *TII,
                                 MachineBasicBlock &MBB,
                                 MachineBasicBlock::iterator MBBI, DebugLoc DL,
                                 MachineOperand &Offset, Register Base,
                                 uint64_t Size, const MachineOperand MO) {
  signed ACSWAP = getACSWAPOpcode(Size, Offset);

  if (ACSWAP == -1) {
    // Offset is an immediate that doesn't fit in a 37-bit integer. Simply
    // generates an add instruction: `add $base = $base, $offset` and set
    // Offset to 0.
    // FIXME: Is modifying the Base register safe?
    // NOTE: Assume 64-bit mode.
    BuildMI(MBB, MBBI, DL, TII->get(KVX::ADDDri64), Base)
        .addReg(Base)
        .addImm(Offset.getImm());
    Offset.setImm(0);
    ACSWAP = getACSWAPOpcode(Size, Offset);
  }

  return ACSWAP;
}

// Return operation opcode used by the atomic_load_operation operations.
unsigned getAtomicOPOpcode(uint64_t Size, unsigned Pseudo) {
  assert((Size == 4 || Size == 8) && "Size isn't supported for AtomicOPOpcode");

  switch (Pseudo) {
  case KVX::ALOADADDp:
    return Size == 4 ? KVX::ADDWrr : KVX::ADDDrr;
  case KVX::ALOADSUBp:
    return Size == 4 ? KVX::SBFWrr : KVX::SBFDrr;
  case KVX::ALOADANDp:
    return Size == 4 ? KVX::ANDWrr : KVX::ANDDrr;
  case KVX::ALOADORp:
    return Size == 4 ? KVX::ORWrr : KVX::ORDrr;
  case KVX::ALOADXORp:
    return Size == 4 ? KVX::XORWrr : KVX::XORDrr;
  case KVX::ALOADNANDp:
    return Size == 4 ? KVX::NANDWrr : KVX::NANDDrr;
  case KVX::ALOADMINp:
    return Size == 4 ? KVX::MINWrr : KVX::MINDrr;
  case KVX::ALOADMAXp:
    return Size == 4 ? KVX::MAXWrr : KVX::MAXDrr;
  case KVX::ALOADUMINp:
    return Size == 4 ? KVX::MINUWrr : KVX::MINUDrr;
  case KVX::ALOADUMAXp:
    return Size == 4 ? KVX::MAXUWrr : KVX::MAXUDrr;
  case KVX::ASWAPp:
    return Size == 4 ? KVX::COPYW : KVX::COPYD;
  default:
    llvm_unreachable("Invalid ALOADOP Pseudo opcode");
  }
}

// Expand an atomic_load_operation operation.
static bool expandALOAD(unsigned int Opcode, const KVXInstrInfo *TII,
                        MachineBasicBlock &MBB,
                        MachineBasicBlock::iterator MBBI,
                        MachineBasicBlock::iterator &NextMBBI) {

  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();
  MachineFunction *MF = MBB.getParent();
  const KVXRegisterInfo *TRI =
      (const KVXRegisterInfo *)MF->getSubtarget().getRegisterInfo();

  LLVM_DEBUG(dbgs() << "expandALOAD: " << MI);
  LLVM_DEBUG(dbgs() << "  " << MI.getNumOperands() << " operands ("
                    << MI.getNumMemOperands() << " memoperands)" << '\n');

  assert(MI.getNumMemOperands() >= 1 &&
         "expandALOAD pseudo-instr expects MemOperands");

  // FIXME: Some instructions can have more than 1 MemOperand. We assume that
  // the first one is the right one.
  MachineMemOperand &MO = *MI.memoperands()[0];
  uint64_t MOSize = MO.getSize();

  assert(MO.isAtomic() && "MemOperand is not atomic");
  assert((MOSize == 4 || MOSize == 8) && "MemOperand size isn't supported");

  LLVM_DEBUG(dbgs() << "  memoperand size: " << MOSize << '\n');

  Register Output = MI.getOperand(0).getReg();
  MachineOperand Offset = MI.getOperand(2);
  Register Base = MI.getOperand(3).getReg();
  Register Value = MI.getOperand(4).getReg();

  // .csloop
  //   load.u $fetch = $offset[$base]
  //   op $update = $value, $fetch            # value first for sbf instr
  //   acswap $offset[$base] = $update$fetch
  //   cb.even $update ? .csloop              # acswap boolean status is
  // .done                                    #   stored in $update
  //   copy $output = $fetch

  Register UpdateFetch = MI.getOperand(1).getReg();
  Register Update = TRI->getSubReg(UpdateFetch, KVX::sub_s0);
  Register Fetch = TRI->getSubReg(UpdateFetch, KVX::sub_s1);

  unsigned COPY = MOSize == 4 ? KVX::COPYW : KVX::COPYD;
  unsigned LOAD = getLOADOpcode(MOSize, Offset);
  unsigned OP = getAtomicOPOpcode(MOSize, Opcode);
  signed ACSWAP = getACSWAPOpcodeModifyAddr(TII, MBB, MBBI, DL, Offset, Base,
                                            MOSize, Offset);

  // Create and link new MBBs.
  auto CSLoopMBB = MF->CreateMachineBasicBlock(MBB.getBasicBlock());
  auto DoneMBB = MF->CreateMachineBasicBlock(MBB.getBasicBlock());

  MF->insert(++MBB.getIterator(), CSLoopMBB);
  MF->insert(++CSLoopMBB->getIterator(), DoneMBB);

  CSLoopMBB->addSuccessor(CSLoopMBB);
  CSLoopMBB->addSuccessor(DoneMBB);

  DoneMBB->transferSuccessors(&MBB);
  MBB.addSuccessor(CSLoopMBB);

  // Populate DoneMBB.
  //   copy $output = $fetch
  BuildMI(DoneMBB, DL, TII->get(COPY), Output).addReg(Fetch);
  DoneMBB->splice(DoneMBB->end(), &MBB, MI, MBB.end());

  // Populate CSLoopMBB.
  //   load.u $fetch = $offset[$base]
  if (Offset.isReg())
    BuildMI(CSLoopMBB, DL, TII->get(LOAD), Fetch)
        .addReg(Offset.getReg())
        .addReg(Base)
        .addImm(KVXMOD::VARIANT_U)
        .addImm(KVXMOD::DOSCALE_);
  else
    BuildMI(CSLoopMBB, DL, TII->get(LOAD), Fetch)
        .addImm(Offset.getImm())
        .addReg(Base)
        .addImm(KVXMOD::VARIANT_U);
  //   op $update = $value, $fetch (or just equal to $value for KVX::ASWAPp)
  if (Opcode != KVX::ASWAPp)
    BuildMI(CSLoopMBB, DL, TII->get(OP), Update).addReg(Value).addReg(Fetch);
  else
    BuildMI(CSLoopMBB, DL, TII->get(OP), Update).addReg(Value);
  //   acswap $offset[$base] = $update$fetch
  if (Offset.isReg())
    BuildMI(CSLoopMBB, DL, TII->get(ACSWAP), UpdateFetch)
        .addReg(Offset.getReg())
        .addReg(Base)
        .addReg(UpdateFetch)
        .addImm(KVXMOD::DOSCALE_);
  else
    BuildMI(CSLoopMBB, DL, TII->get(ACSWAP), UpdateFetch)
        .addImm(Offset.getImm())
        .addReg(Base)
        .addReg(UpdateFetch);
  //   cb.even $update ? .csloop
  BuildMI(CSLoopMBB, DL, TII->get(KVX::CB))
      .addReg(Update)
      .addMBB(CSLoopMBB)
      .addImm(KVXMOD::SCALARCOND_EVEN);

  NextMBBI = MBB.end();
  MI.eraseFromParent();
  return true;
}

// Expand an atomic_swap operation (same codegen as for expandALOAD
// except that the operation is just a copy instruction).
static bool expandASWAP(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                        MachineBasicBlock::iterator MBBI,
                        MachineBasicBlock::iterator &NextMBBI) {
  return expandALOAD(KVX::ASWAPp, TII, MBB, MBBI, NextMBBI);
}

// Expand an atomic_swap operation for the special case of
// __atomic_test_and_set, i.e. atomicrmw xchg i8 *ptr, 1.
static bool expandATAS(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                       MachineBasicBlock::iterator MBBI,
                       MachineBasicBlock::iterator &NextMBBI) {

  MachineInstr &MI = *MBBI;

  assert(MI.hasOneMemOperand() &&
         "expandATAS pseudo-instr expects one MemOperand");

  assert(
      MI.memoperands()[0]->getSize() == 1 &&
      "expandATAS only support atomicrmw xchg i8*, 1 operation (test_and_set)");

  DebugLoc DL = MI.getDebugLoc();
  MachineFunction *MF = MBB.getParent();
  const KVXRegisterInfo *TRI =
      (const KVXRegisterInfo *)MF->getSubtarget().getRegisterInfo();

  Register Output = MI.getOperand(0).getReg();
  Register Base = MI.getOperand(6).getReg();
  Register Value = MI.getOperand(7).getReg();

  Register UpdateFetch = MI.getOperand(1).getReg();
  Register Update = TRI->getSubReg(UpdateFetch, KVX::sub_s0);
  Register Fetch = TRI->getSubReg(UpdateFetch, KVX::sub_s1);

  Register Pos = MI.getOperand(2).getReg();
  Register Mask = MI.getOperand(3).getReg();
  Register Offset = MI.getOperand(5).isReg() ? MI.getOperand(5).getReg()
                                             : MI.getOperand(4).getReg();

  //   addd $pos = $base, $offset    # iff $offset != 0
  //   andd $pos = $pos, 3           # find the place of the byte to
  //                                 #   test_and_set in the memory word
  //                                 #   ($pos is 0, 1, 2, or 3)
  //   sbfd $offset = $pos, $offset  # the address of the memory word
  //                                 #   containing the byte is
  //                                 #   ($base + $offset - $pos)
  //   slld $pos = $pos, 3           # $pos in bits: $pos * 8
  // .csloop
  //   lwz.u $fetch = $offset[$base]
  //   srlw $output = $fetch, $pos   # keep only the byte to test_and_set:
  //   andw $output = $output, 0xFF  #   ($fetch >> $pos) & 0xFF
  //   cb.wnez $output ? .done       # the byte is already set
  //   sllw $mask = $value, $pos     # new value to set:
  //   orw $update = $fetch, $mask   #   $fetch | ($value << $pos)
  //   acswapw $offset[$base] = $update$fetch
  //   cb.even $update ? .csloop
  // .done

  // Create and link new MBBs.
  auto CSLoopMBB = MF->CreateMachineBasicBlock(MBB.getBasicBlock());
  auto DoneMBB = MF->CreateMachineBasicBlock(MBB.getBasicBlock());

  MF->insert(++MBB.getIterator(), CSLoopMBB);
  MF->insert(++CSLoopMBB->getIterator(), DoneMBB);

  CSLoopMBB->addSuccessor(CSLoopMBB);
  CSLoopMBB->addSuccessor(DoneMBB);

  DoneMBB->transferSuccessors(&MBB);
  MBB.addSuccessor(CSLoopMBB);

  // Populate DoneMBB.
  DoneMBB->splice(DoneMBB->end(), &MBB, MI, MBB.end());
  DoneMBB->setLabelMustBeEmitted();

  // Populate MBB.
  if (MI.getOperand(5).isImm()) {
    uint64_t Imm = MI.getOperand(5).getImm();
    //   addd $pos = $base, $offset
    if (Imm != 0)
      BuildMI(&MBB, DL, TII->get(KVX::ADDDri64), Pos).addReg(Base).addImm(Imm);
    //   andd $pos = $pos/$base, 3     # find the place of the byte to
    //                                 #   test_and_set in the memory word
    //                                 #   ($pos is 0, 1, 2, or 3)
    BuildMI(&MBB, DL, TII->get(KVX::ANDDri10), Pos)
        .addReg(Imm != 0 ? Pos : Base)
        .addImm(3);
  } else {
    //   addd $pos = $base, $offset
    BuildMI(&MBB, DL, TII->get(KVX::ADDDrr), Pos).addReg(Base).addReg(Offset);
    //   andd $pos = $pos, 3           # find the place of the byte to
    //                                 #   test_and_set in the memory word
    //                                 #   ($pos is 0, 1, 2, or 3)
    BuildMI(&MBB, DL, TII->get(KVX::ANDDri10), Pos).addReg(Pos).addImm(3);
  }
  //   sbfd $offset = $pos, $offset  # the address of the memory word
  //                                 #   containing the byte is
  //                                 #   ($base + $offset - $pos)
  if (MI.getOperand(5).isImm()) {
    uint64_t Imm = MI.getOperand(5).getImm();
    BuildMI(&MBB, DL, TII->get(KVX::SBFDri64), Offset).addReg(Pos).addImm(Imm);
  } else {
    BuildMI(&MBB, DL, TII->get(KVX::SBFDrr), Offset).addReg(Pos).addReg(Offset);
  }
  //   slld $pos = $pos, 3           # $pos in bits: $pos * 8
  BuildMI(&MBB, DL, TII->get(KVX::SLLDri), Pos).addReg(Pos).addImm(3);

  // Populate CSLoopMBB (insns have been manually scheduled).
  //   lwz.u $fetch = $offset[$base]
  BuildMI(CSLoopMBB, DL, TII->get(KVX::LWZrr), Fetch)
      .addReg(Offset)
      .addReg(Base)
      .addImm(KVXMOD::VARIANT_U)
      .addImm(KVXMOD::DOSCALE_);
  //   srlw $output = $fetch, $pos   # keep only the byte to test_and_set:
  BuildMI(CSLoopMBB, DL, TII->get(KVX::SRLWrr), Output)
      .addReg(Fetch)
      .addReg(Pos);
  //   sllw $mask = $value, $pos     # new value to set:
  BuildMI(CSLoopMBB, DL, TII->get(KVX::SLLWrr), Mask).addReg(Value).addReg(Pos);
  //   andw $output = $output, 0xFF  #   ($fetch >> $pos) & 0xFF
  BuildMI(CSLoopMBB, DL, TII->get(KVX::ANDWri10), Output)
      .addReg(Output)
      .addImm(0xFF);
  //   orw $update = $fetch, $mask   #   $fetch | ($value << $pos)
  BuildMI(CSLoopMBB, DL, TII->get(KVX::ORWrr), Update)
      .addReg(Fetch)
      .addReg(Mask);
  //   cb.wnez $output ? .done       # the byte is already set
  BuildMI(CSLoopMBB, DL, TII->get(KVX::CB))
      .addReg(Output)
      .addMBB(DoneMBB)
      .addImm(KVXMOD::SCALARCOND_WNEZ);
  //   acswapw $offset[$base] = $update$fetch
  BuildMI(CSLoopMBB, DL, TII->get(KVX::ACSWAPWrr), UpdateFetch)
      .addReg(Offset)
      .addReg(Base)
      .addReg(UpdateFetch)
      .addImm(KVXMOD::DOSCALE_);
  //   cb.even $update ? .csloop
  BuildMI(CSLoopMBB, DL, TII->get(KVX::CB))
      .addReg(Update)
      .addMBB(CSLoopMBB)
      .addImm(KVXMOD::SCALARCOND_EVEN);

  NextMBBI = MBB.end();
  MI.eraseFromParent();
  return true;
}

// Expand an atomic_cmp_swap operation.
static bool expandACMPSWAP(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                           MachineBasicBlock::iterator MBBI,
                           MachineBasicBlock::iterator &NextMBBI) {

  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();
  MachineFunction *MF = MBB.getParent();
  const KVXRegisterInfo *TRI =
      (const KVXRegisterInfo *)MF->getSubtarget().getRegisterInfo();

  assert(MI.getNumMemOperands() >= 1 &&
         "expandACMPSWAP pseudo-instr expects MemOperands");

  // FIXME: Some instructions can have more than 1 MemOperand. We assume that
  // the first one is the right one.
  MachineMemOperand &MO = *MI.memoperands()[0];
  uint64_t MOSize = MO.getSize();

  Register Output = MI.getOperand(0).getReg();
  MachineOperand Offset = MI.getOperand(2);
  Register Base = MI.getOperand(3).getReg();
  Register Compare = MI.getOperand(4).getReg();
  Register Swap = MI.getOperand(5).getReg();

  Register DesiredExpected = MI.getOperand(1).getReg();
  Register Desired = TRI->getSubReg(DesiredExpected, KVX::sub_s0);
  Register Expected = TRI->getSubReg(DesiredExpected, KVX::sub_s1);

  //   copy $expected = $compare                  # iff $compare isn't a valid
  //                                              #   PairedReg subreg
  // .csloop
  //   copy $desired = $swap                      # restore $desired in case
  //                                              #   of loop
  //   acswap $offset[$base] = $desired$expected  # try the compare and swap
  //   cb.odd $desired ? .pass                    # return $expected
  //                                              #   on success
  //   load.u $output = $offset[$base]            # reload $expected value
  //                                              #   from memory on failure
  //                                              #   and retry if equal to
  //                                              #   expected input
  //   comp.eq $desired = $output, $expected      # desired use as temp reg
  //                                              #   for comp
  //   cb.odd $desired ? .csloop
  //   goto .done
  // .pass
  //   copy $output = $expected                   # output contains expected
  //                                              #   on success, loaded value
  //                                              #   on failure
  // .done

  unsigned COPY = MOSize == 4 ? KVX::COPYW : KVX::COPYD;
  unsigned COMP = MOSize == 4 ? KVX::COMPWrr : KVX::COMPDrr;
  signed ACSWAP = getACSWAPOpcodeModifyAddr(TII, MBB, MBBI, DL, Offset, Base,
                                            MOSize, Offset);
  unsigned LOAD = getLOADOpcode(MOSize, Offset);

  // Create and link new MBBs.
  auto CSLoopMBB = MF->CreateMachineBasicBlock(MBB.getBasicBlock());
  auto PassMBB = MF->CreateMachineBasicBlock(MBB.getBasicBlock());
  auto DoneMBB = MF->CreateMachineBasicBlock(MBB.getBasicBlock());

  MF->insert(++MBB.getIterator(), CSLoopMBB);
  MF->insert(++CSLoopMBB->getIterator(), PassMBB);
  MF->insert(++PassMBB->getIterator(), DoneMBB);

  CSLoopMBB->addSuccessor(CSLoopMBB);
  CSLoopMBB->addSuccessor(PassMBB);
  CSLoopMBB->addSuccessor(DoneMBB);

  DoneMBB->transferSuccessors(&MBB);
  MBB.addSuccessor(CSLoopMBB);

  // Populate DoneMBB.
  DoneMBB->splice(DoneMBB->end(), &MBB, MI, MBB.end());
  DoneMBB->setLabelMustBeEmitted();

  // Populate MBB.
  //   copy $expected = $compare                  # iff $compare isn't a valid
  //                                              #   PairedReg subreg
  if (Desired != Swap || Expected != Compare) {
    BuildMI(&MBB, DL, TII->get(COPY), Expected).addReg(Compare);
  }

  // Populate CSLoopMBB.
  //   copy $desired = $swap                      # restore $desired in case
  //                                              #   of loop
  BuildMI(CSLoopMBB, DL, TII->get(COPY), Desired).addReg(Swap);
  //   acswap $offset[$base] = $desired$expected  # try the compare and swap
  if (Offset.isReg())
    BuildMI(CSLoopMBB, DL, TII->get(ACSWAP), DesiredExpected)
        .addReg(Offset.getReg())
        .addReg(Base)
        .addReg(DesiredExpected)
        .addImm(KVXMOD::DOSCALE_);
  else
    BuildMI(CSLoopMBB, DL, TII->get(ACSWAP), DesiredExpected)
        .addImm(Offset.getImm())
        .addReg(Base)
        .addReg(DesiredExpected);
  //   cb.odd $desired ? .pass                    # return $expected on
  //                                              #   success
  BuildMI(CSLoopMBB, DL, TII->get(KVX::CB))
      .addReg(Desired)
      .addMBB(PassMBB)
      .addImm(KVXMOD::SCALARCOND_ODD);
  //   load.u $output = $offset[$base]            # reload $expected value
  //                                              #   from memory on failure
  //                                              #   and retry if equal to
  //                                              #   expected input
  if (Offset.isReg())
    BuildMI(CSLoopMBB, DL, TII->get(LOAD), Output)
        .addReg(Offset.getReg())
        .addReg(Base)
        .addImm(KVXMOD::VARIANT_U)
        .addImm(KVXMOD::DOSCALE_);
  else
    BuildMI(CSLoopMBB, DL, TII->get(LOAD), Output)
        .addImm(Offset.getImm())
        .addReg(Base)
        .addImm(KVXMOD::VARIANT_U);
  //   comp.eq $desired = $output, $expected      # desired use as temp reg
  //                                              #   for comp
  BuildMI(CSLoopMBB, DL, TII->get(COMP), Desired)
      .addReg(Output)
      .addReg(Expected)
      .addImm(KVXMOD::COMPARISON_EQ);
  //   cb.odd $desired ? .csloop
  BuildMI(CSLoopMBB, DL, TII->get(KVX::CB))
      .addReg(Desired)
      .addMBB(CSLoopMBB)
      .addImm(KVXMOD::SCALARCOND_ODD);
  //   goto .done
  BuildMI(CSLoopMBB, DL, TII->get(KVX::GOTO)).addMBB(DoneMBB);

  // Populate PassMBB.
  //   copy $output = $expected                   # output contains expected
  //                                              #   on success, loaded value
  //                                              #   on failure
  PassMBB->setLabelMustBeEmitted();
  BuildMI(PassMBB, DL, TII->get(COPY), Output).addReg(Expected);

  NextMBBI = MBB.end();
  MI.eraseFromParent();
  return true;
}

static bool expandRoundingPairInstrOpcodes(unsigned int OpCode1,
                                           unsigned int OpCode2,
                                           const KVXInstrInfo *TII,
                                           MachineBasicBlock &MBB,
                                           MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  MachineFunction *MF = MBB.getParent();
  const KVXRegisterInfo *TRI =
      (const KVXRegisterInfo *)MF->getSubtarget().getRegisterInfo();

  unsigned outReg = MI.getOperand(0).getReg();
  unsigned v1Reg = MI.getOperand(1).getReg();
  unsigned v2Reg = MI.getOperand(2).getReg();
  int64_t rounding = MI.getOperand(3).getImm();

  BuildMI(MBB, MBBI, DL, TII->get(OpCode1), TRI->getSubReg(outReg, KVX::sub_s0))
      .addReg(TRI->getSubReg(v1Reg, KVX::sub_s0))
      .addReg(TRI->getSubReg(v2Reg, KVX::sub_s0))
      .addImm(rounding)
      .addImm(KVXMOD::SILENT_);
  BuildMI(MBB, MBBI, DL, TII->get(OpCode2), TRI->getSubReg(outReg, KVX::sub_s1))
      .addReg(TRI->getSubReg(v1Reg, KVX::sub_s1))
      .addReg(TRI->getSubReg(v2Reg, KVX::sub_s1))
      .addImm(rounding)
      .addImm(KVXMOD::SILENT_);

  MI.eraseFromParent();
  return true;
}

static bool expandFMULDCInstr(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                              MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  MachineFunction *MF = MBB.getParent();
  const KVXRegisterInfo *TRI =
      (const KVXRegisterInfo *)MF->getSubtarget().getRegisterInfo();

  unsigned outReg = MI.getOperand(0).getReg();
  unsigned v1Reg = MI.getOperand(1).getReg();
  unsigned v2Reg = MI.getOperand(2).getReg();
  int64_t rounding = MI.getOperand(3).getImm();

  BuildMI(MBB, MBBI, DL, TII->get(KVX::FMULDrr),
          TRI->getSubReg(outReg, KVX::sub_s0))
      .addReg(TRI->getSubReg(v1Reg, KVX::sub_s0))
      .addReg(TRI->getSubReg(v2Reg, KVX::sub_s0))
      .addImm(rounding)
      .addImm(KVXMOD::SILENT_);
  BuildMI(MBB, MBBI, DL, TII->get(KVX::FFMSDrr),
          TRI->getSubReg(outReg, KVX::sub_s0))
      .addReg(TRI->getSubReg(outReg, KVX::sub_s0))
      .addReg(TRI->getSubReg(v1Reg, KVX::sub_s1))
      .addReg(TRI->getSubReg(v2Reg, KVX::sub_s1))
      .addImm(rounding)
      .addImm(KVXMOD::SILENT_);
  BuildMI(MBB, MBBI, DL, TII->get(KVX::FMULDrr),
          TRI->getSubReg(outReg, KVX::sub_s1))
      .addReg(TRI->getSubReg(v1Reg, KVX::sub_s0))
      .addReg(TRI->getSubReg(v2Reg, KVX::sub_s1))
      .addImm(rounding)
      .addImm(KVXMOD::SILENT_);
  BuildMI(MBB, MBBI, DL, TII->get(KVX::FFMADrr),
          TRI->getSubReg(outReg, KVX::sub_s1))
      .addReg(TRI->getSubReg(outReg, KVX::sub_s1))
      .addReg(TRI->getSubReg(v2Reg, KVX::sub_s0))
      .addReg(TRI->getSubReg(v1Reg, KVX::sub_s1))
      .addImm(rounding)
      .addImm(KVXMOD::SILENT_);

  MI.eraseFromParent();
  return true;
}

static bool expandFMULCDCInstr(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                               MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  MachineFunction *MF = MBB.getParent();
  const KVXRegisterInfo *TRI =
      (const KVXRegisterInfo *)MF->getSubtarget().getRegisterInfo();

  unsigned outReg = MI.getOperand(0).getReg();
  unsigned Scratch = MI.getOperand(1).getReg();
  unsigned v1Reg = MI.getOperand(2).getReg();
  unsigned v2Reg = MI.getOperand(3).getReg();
  int64_t rounding = MI.getOperand(4).getImm();

  BuildMI(MBB, MBBI, DL, TII->get(KVX::FMULDrr), Scratch)
      .addReg(TRI->getSubReg(v1Reg, KVX::sub_s0))
      .addReg(TRI->getSubReg(v2Reg, KVX::sub_s0))
      .addImm(rounding)
      .addImm(KVXMOD::SILENT_);
  BuildMI(MBB, MBBI, DL, TII->get(KVX::COPYD),
          TRI->getSubReg(outReg, KVX::sub_s0))
      .addReg(TRI->getSubReg(v2Reg, KVX::sub_s1));
  BuildMI(MBB, MBBI, DL, TII->get(KVX::FFMADrr),
          TRI->getSubReg(outReg, KVX::sub_s0))
      .addReg(TRI->getSubReg(outReg, KVX::sub_s0))
      .addReg(Scratch)
      .addReg(TRI->getSubReg(v1Reg, KVX::sub_s1))
      .addImm(rounding)
      .addImm(KVXMOD::SILENT_);
  BuildMI(MBB, MBBI, DL, TII->get(KVX::FMULDrr), Scratch)
      .addReg(TRI->getSubReg(v2Reg, KVX::sub_s0))
      .addReg(TRI->getSubReg(v1Reg, KVX::sub_s1))
      .addImm(rounding)
      .addImm(KVXMOD::SILENT_);
  BuildMI(MBB, MBBI, DL, TII->get(KVX::COPYD),
          TRI->getSubReg(outReg, KVX::sub_s1))
      .addReg(TRI->getSubReg(v2Reg, KVX::sub_s1));
  BuildMI(MBB, MBBI, DL, TII->get(KVX::FFMSDrr),
          TRI->getSubReg(outReg, KVX::sub_s1))
      .addReg(TRI->getSubReg(outReg, KVX::sub_s1))
      .addReg(Scratch)
      .addReg(TRI->getSubReg(v1Reg, KVX::sub_s0))
      .addImm(rounding)
      .addImm(KVXMOD::SILENT_);

  MI.eraseFromParent();
  return true;
}

static bool
expandRoundingPairedRegInOutInstr(unsigned int OpCode, const KVXInstrInfo *TII,
                                  MachineBasicBlock &MBB,
                                  MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  MachineFunction *MF = MBB.getParent();
  const KVXRegisterInfo *TRI =
      (const KVXRegisterInfo *)MF->getSubtarget().getRegisterInfo();

  unsigned outReg = MI.getOperand(0).getReg();
  unsigned v1Reg = MI.getOperand(1).getReg();
  unsigned v2Reg = MI.getOperand(2).getReg();
  int64_t rounding = MI.getOperand(4).getImm();

  BuildMI(MBB, MBBI, DL, TII->get(OpCode), TRI->getSubReg(outReg, KVX::sub_s0))
      .addReg(TRI->getSubReg(outReg, KVX::sub_s0))
      .addReg(TRI->getSubReg(v1Reg, KVX::sub_s0))
      .addReg(TRI->getSubReg(v2Reg, KVX::sub_s0))
      .addImm(rounding)
      .addImm(KVXMOD::SILENT_);

  BuildMI(MBB, MBBI, DL, TII->get(OpCode), TRI->getSubReg(outReg, KVX::sub_s1))
      .addReg(TRI->getSubReg(outReg, KVX::sub_s1))
      .addReg(TRI->getSubReg(v1Reg, KVX::sub_s1))
      .addReg(TRI->getSubReg(v2Reg, KVX::sub_s1))
      .addImm(rounding)
      .addImm(KVXMOD::SILENT_);

  MI.eraseFromParent();
  return true;
}

static bool expandStore(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                        MachineBasicBlock::iterator MBBI, unsigned ri10,
                        unsigned ri37, unsigned ri64) {

  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  int64_t offset = MI.getOperand(0).getImm();
  unsigned base = MI.getOperand(1).getReg();
  unsigned val = MI.getOperand(2).getReg();

  BuildMI(MBB, MBBI, DL, TII->get(GetImmOpCode(offset, ri10, ri37, ri64)))
      .addImm(offset)
      .addReg(base)
      .addReg(val, MI.getOperand(2).isKill() ? RegState::Kill : 0);

  MI.eraseFromParent();
  return true;
}

static bool expandLoad(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                       MachineBasicBlock::iterator MBBI, unsigned ri10,
                       unsigned ri37, unsigned ri64) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  unsigned outputReg = MI.getOperand(0).getReg();
  int64_t offset = MI.getOperand(1).getImm();
  unsigned base = MI.getOperand(2).getReg();
  int64_t variant = MI.getOperand(3).getImm();

  BuildMI(MBB, MBBI, DL, TII->get(GetImmOpCode(offset, ri10, ri37, ri64)),
          outputReg)
      .addImm(offset)
      .addReg(base)
      .addImm(variant);

  MI.eraseFromParent();
  return true;
}

static bool expandWideMatrixLoadsStores(const KVXInstrInfo *TII,
                                        MachineBasicBlock &MBB,
                                        MachineBasicBlock::iterator MBBI,
                                        unsigned ri10, unsigned ri37,
                                        unsigned ri64, bool IsStore = false) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  Register InOutReg, Base;
  int64_t Offset, VariantKill;
  if (IsStore) {
    Offset = MI.getOperand(0).getImm();
    Base = MI.getOperand(1).getReg();
    InOutReg = MI.getOperand(2).getReg();
    VariantKill = MI.getOperand(2).isKill() ? RegState::Kill : 0;
  } else {
    InOutReg = MI.getOperand(0).getReg();
    Offset = MI.getOperand(1).getImm();
    Base = MI.getOperand(2).getReg();
    VariantKill = MI.getOperand(3).getImm();
  }

  MachineFunction *MF = MBB.getParent();
  const KVXRegisterInfo *TRI =
      (const KVXRegisterInfo *)MF->getSubtarget().getRegisterInfo();

  LLVM_DEBUG(dbgs() << "Creating a " << (IsStore ? "store from" : "load to")
                    << " register: " << TRI->getRegAsmName(InOutReg) << '\n');

  Register VectorReg = TRI->getSubReg(InOutReg, KVX::sub_v0);
  LLVM_DEBUG(dbgs() << "The sub-register at index 1 is #:" << VectorReg << '('
                    << TRI->getRegAsmName(VectorReg) << ").\n");
  int End;
  if (KVX::MatrixRegRegClass.contains(InOutReg))
    End = 4;
  else if (KVX::WideRegRegClass.contains(InOutReg))
    End = 2;
  else
    report_fatal_error("Expanding a vector load that is not for wide or matrix "
                       "registers output.\n");

  LLVM_DEBUG(dbgs() << "It will require " << End << " lv operations\n");

  LLVM_DEBUG(dbgs() << "The first vector sub-register is: "
                    << TRI->getRegAsmName(VectorReg) << '\n');
  for (int C = 0; C < End; C++) {
    LLVM_DEBUG(dbgs() << "Acting in register #:" << VectorReg << '('
                      << TRI->getRegAsmName(VectorReg) << ").\n");

    if (!TRI->isSubRegister(InOutReg, VectorReg))
      report_fatal_error(
          "Vector register " + TRI->getRegAsmName(VectorReg.id()) +
          " is not a sub-register of " + TRI->getRegAsmName(InOutReg.id()));

    if (IsStore)
      BuildMI(MBB, MBBI, DL, TII->get(GetImmOpCode(Offset, ri10, ri37, ri64)))
          .addImm(Offset)
          .addReg(Base)
          .addReg(VectorReg, VariantKill);

    else
      BuildMI(MBB, MBBI, DL, TII->get(GetImmOpCode(Offset, ri10, ri37, ri64)),
              VectorReg)
          .addImm(Offset)
          .addReg(Base)
          .addImm(VariantKill);
    Offset += 32;
    VectorReg = VectorReg + 1;
  }
  MI.eraseFromParent();
  return true;
}

static bool expandMADDW(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                        MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  unsigned outputReg = MI.getOperand(0).getReg();
  unsigned aReg = MI.getOperand(1).getReg();
  unsigned bReg = MI.getOperand(2).getReg();
  unsigned cReg = 0;
  int64_t cVal;
  if (MI.getOperand(3).isReg())
    cReg = MI.getOperand(3).getReg();
  else
    cVal = MI.getOperand(3).getImm();

  if (outputReg == aReg) {
    if (cReg != 0)
      BuildMI(MBB, MBBI, DL, TII->get(KVX::MADDWrr), outputReg)
          .addReg(outputReg)
          .addReg(bReg)
          .addReg(cReg);
    else
      BuildMI(MBB, MBBI, DL, TII->get(KVX::MADDWri), outputReg)
          .addReg(outputReg)
          .addReg(bReg)
          .addImm(cVal);
  } else {
    if (cReg != 0)
      BuildMI(MBB, MBBI, DL, TII->get(KVX::MULWrr), outputReg)
          .addReg(bReg)
          .addReg(cReg);
    else
      BuildMI(MBB, MBBI, DL, TII->get(KVX::MULWri), outputReg)
          .addReg(bReg)
          .addImm(cVal);

    BuildMI(MBB, MBBI, DL, TII->get(KVX::ADDWrr), outputReg)
        .addReg(aReg)
        .addReg(outputReg);
  }

  MI.eraseFromParent();
  return true;
}

static bool expandEXTFZ(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                        MachineBasicBlock::iterator MBBI, bool Word) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  unsigned outputReg = MI.getOperand(0).getReg();
  unsigned valReg = MI.getOperand(1).getReg();
  int64_t andmask = MI.getOperand(2).getImm();
  int64_t shiftcount = MI.getOperand(3).getImm();

  int count = 0, maxcount = 0;
  int64_t mask = 1;
  int MaxBit = (Word ? 32 : 64) - shiftcount;
  for (int i = 0; i < MaxBit; i++) {
    if ((andmask & mask) != 0) {
      if (maxcount != 0) {
        maxcount = 0;
        count = 0;
        break;
      }
      count++;
    } else {
      if (i == 0)
        break;
      maxcount = count;
    }
    mask <<= 1;
  }
  if (maxcount == 0 && count > 0)
    maxcount = count;
  LLVM_DEBUG(dbgs() << "EXTFZ word: " << Word << " andmask: " << andmask
                    << " shiftcount: " << shiftcount
                    << " maxcount: " << maxcount << "\n");
  if (maxcount > 0) {
    BuildMI(MBB, MBBI, DL, TII->get(KVX::EXTFZ), outputReg)
        .addReg(valReg)
        .addImm(shiftcount + maxcount - 1)
        .addImm(shiftcount);
  } else {
    unsigned OpCode;
    BuildMI(MBB, MBBI, DL, TII->get(Word ? KVX::SRLWri : KVX::SRLDri),
            outputReg)
        .addReg(valReg)
        .addImm(shiftcount);

    if (Word)
      OpCode = GetImmOpCode(andmask, KVX::ANDWri10, KVX::ANDWri37, KVX::NOP);
    else
      OpCode =
          GetImmOpCode(andmask, KVX::ANDDri10, KVX::ANDDri37, KVX::ANDDri64);

    BuildMI(MBB, MBBI, DL, TII->get(OpCode), outputReg)
        .addReg(outputReg)
        .addImm(andmask);
  }

  MI.eraseFromParent();
  return true;
}

bool KVXPreEmitExpandPseudo::expandMI(MachineBasicBlock &MBB,
                                      MachineBasicBlock::iterator MBBI,
                                      MachineBasicBlock::iterator &NextMBBI) {
  switch (MBBI->getOpcode()) {
  case KVX::SELECTp:
    expandSELECT(TII, MBB, MBBI);
    return true;
  case KVX::ALOADADDp:
  case KVX::ALOADSUBp:
  case KVX::ALOADANDp:
  case KVX::ALOADORp:
  case KVX::ALOADXORp:
  case KVX::ALOADNANDp:
  case KVX::ALOADMINp:
  case KVX::ALOADMAXp:
  case KVX::ALOADUMINp:
  case KVX::ALOADUMAXp:
    return expandALOAD(MBBI->getOpcode(), TII, MBB, MBBI, NextMBBI);
  case KVX::ACMPSWAPp:
    return expandACMPSWAP(TII, MBB, MBBI, NextMBBI);
  case KVX::ASWAPp:
    return expandASWAP(TII, MBB, MBBI, NextMBBI);
  case KVX::ATASp:
    return expandATAS(TII, MBB, MBBI, NextMBBI);
  case KVX::FMULWCPp:
    expandRoundingPairInstrOpcodes(KVX::FMULWCrr, KVX::FMULWCrr, TII, MBB,
                                   MBBI);
    return true;
  case KVX::FMULCWCPp:
    expandRoundingPairInstrOpcodes(KVX::FMULCWCrr, KVX::FMULCWCrr, TII, MBB,
                                   MBBI);
    return true;
  case KVX::FMULDPp:
    expandRoundingPairInstrOpcodes(KVX::FMULDrr, KVX::FMULDrr, TII, MBB, MBBI);
    return true;
  case KVX::FMULDCp:
    expandFMULDCInstr(TII, MBB, MBBI);
    return true;
  case KVX::FMULCDCp:
    expandFMULCDCInstr(TII, MBB, MBBI);
    return true;
  case KVX::FFMAWQp:
    expandRoundingPairedRegInOutInstr(KVX::FFMAWPrr, TII, MBB, MBBI);
    return true;
  case KVX::FFMADPp:
    expandRoundingPairedRegInOutInstr(KVX::FFMADrr, TII, MBB, MBBI);
    return true;
  case KVX::FFMSWQp:
    expandRoundingPairedRegInOutInstr(KVX::FFMSWPrr, TII, MBB, MBBI);
    return true;
  case KVX::FFMSDPp:
    expandRoundingPairedRegInOutInstr(KVX::FFMSDrr, TII, MBB, MBBI);
    return true;
  case KVX::SBp:
    expandStore(TII, MBB, MBBI, KVX::SBri10, KVX::SBri37, KVX::SBri64);
    return true;
  case KVX::SHp:
    expandStore(TII, MBB, MBBI, KVX::SHri10, KVX::SHri37, KVX::SHri64);
    return true;
  case KVX::SWp:
    expandStore(TII, MBB, MBBI, KVX::SWri10, KVX::SWri37, KVX::SWri64);
    return true;
  case KVX::SDp:
    expandStore(TII, MBB, MBBI, KVX::SDri10, KVX::SDri37, KVX::SDri64);
    return true;
  case KVX::SQp:
    expandStore(TII, MBB, MBBI, KVX::SQri10, KVX::SQri37, KVX::SQri64);
    return true;
  case KVX::SOp:
    expandStore(TII, MBB, MBBI, KVX::SOri10, KVX::SOri37, KVX::SOri64);
    return true;
  case KVX::SVp:
    expandStore(TII, MBB, MBBI, KVX::SVri10, KVX::SVri37, KVX::SVri64);
    return true;
  case KVX::SWIDEp:
  case KVX::SMATRIXp:
    expandWideMatrixLoadsStores(TII, MBB, MBBI, KVX::SVri10, KVX::SVri37,
                                KVX::SVri64, true);
    return true;
  case KVX::LBSp:
    expandLoad(TII, MBB, MBBI, KVX::LBSri10, KVX::LBSri37, KVX::LBSri64);
    return true;
  case KVX::LBZp:
    expandLoad(TII, MBB, MBBI, KVX::LBZri10, KVX::LBZri37, KVX::LBZri64);
    return true;
  case KVX::LHSp:
    expandLoad(TII, MBB, MBBI, KVX::LHSri10, KVX::LHSri37, KVX::LHSri64);
    return true;
  case KVX::LHZp:
    expandLoad(TII, MBB, MBBI, KVX::LHZri10, KVX::LHZri37, KVX::LHZri64);
    return true;
  case KVX::LWSp:
    expandLoad(TII, MBB, MBBI, KVX::LWSri10, KVX::LWSri37, KVX::LWSri64);
    return true;
  case KVX::LWZp:
    expandLoad(TII, MBB, MBBI, KVX::LWZri10, KVX::LWZri37, KVX::LWZri64);
    return true;
  case KVX::LDp:
    expandLoad(TII, MBB, MBBI, KVX::LDri10, KVX::LDri37, KVX::LDri64);
    return true;
  case KVX::LQp:
    expandLoad(TII, MBB, MBBI, KVX::LQri10, KVX::LQri37, KVX::LQri64);
    return true;
  case KVX::LOp:
    expandLoad(TII, MBB, MBBI, KVX::LOri10, KVX::LOri37, KVX::LOri64);
    return true;
  case KVX::LVp:
    expandLoad(TII, MBB, MBBI, KVX::LVri10, KVX::LVri37, KVX::LVri64);
    return true;
  case KVX::LWIDEp:
  case KVX::LMATRIXp:
    expandWideMatrixLoadsStores(TII, MBB, MBBI, KVX::LVri10, KVX::LVri37,
                                KVX::LVri64);
    return true;
  case KVX::MADDWp:
    expandMADDW(TII, MBB, MBBI);
    return true;
  case KVX::EXTFZWp:
    expandEXTFZ(TII, MBB, MBBI, true);
    return true;
  case KVX::EXTFZDp:
    expandEXTFZ(TII, MBB, MBBI, false);
    return true;
  default:
    break;
  }

  return false;
}

} // end of anonymous namespace

INITIALIZE_PASS(KVXPreEmitExpandPseudo, "kvx-preemit-expand-pseudo",
                KVX_PREEMIT_EXPAND_PSEUDO_NAME, false, false)
namespace llvm {

FunctionPass *createKVXPreEmitExpandPseudoPass() {
  return new KVXPreEmitExpandPseudo();
}

} // end of namespace llvm
