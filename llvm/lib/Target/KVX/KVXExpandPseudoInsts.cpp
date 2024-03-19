//===-- KVXExpandPseudoInsts.cpp - Expand pseudo instructions ------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains a pass that expands pseudo instructions into target
// instructions. This pass runs 3 times:
// - Before Register Allocator
// - Before the post-regalloc schedulling
// - Before packetizer
//===----------------------------------------------------------------------===//

#include "KVXMachineFunctionInfo.h"
#include "KVXSubtarget.h"

using namespace llvm;

#define KVX_PREEMIT_EXPAND_PSEUDO_NAME "KVX pseudo instruction expansion pass"
#define DEBUG_TYPE "kvx-expand-pseudo"

namespace {

class KVXExpandPseudo : public MachineFunctionPass {
public:
  const KVXInstrInfo *TII;
  static char ID;

  KVXExpandPseudo(KVX::STAGE S = KVX::PRE_RA)
      : MachineFunctionPass(ID), Stage(S) {
    initializeKVXExpandPseudoPass(*PassRegistry::getPassRegistry());
  }

  bool runOnMachineFunction(MachineFunction &MF) override;

  StringRef getPassName() const override {
    return KVX_PREEMIT_EXPAND_PSEUDO_NAME;
  }

private:
  const KVX::STAGE Stage;
  bool expandMBB(MachineBasicBlock &MBB);
  bool expandMI(MachineBasicBlock &MBB, MachineBasicBlock::iterator MBBI,
                MachineBasicBlock::iterator &NextMBBI);
};

char KVXExpandPseudo::ID = 0;

bool KVXExpandPseudo::runOnMachineFunction(MachineFunction &MF) {
  TII = static_cast<const KVXInstrInfo *>(MF.getSubtarget().getInstrInfo());
  bool Modified = false;
  for (auto &MBB : MF)
    Modified |= expandMBB(MBB);
  return Modified;
}

bool KVXExpandPseudo::expandMBB(MachineBasicBlock &MBB) {
  bool Modified = false;

  MachineBasicBlock::iterator MBBI = MBB.begin(), E = MBB.end();
  while (MBBI != E) {
    MachineBasicBlock::iterator NMBBI = std::next(MBBI);
    if (MBBI->isPseudo())
      Modified |= expandMI(MBB, MBBI, NMBBI);
    MBBI = NMBBI;
  }

  if (Stage == KVX::PRE_RA)
    return Modified;

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

static bool expandCacheInstruction(const KVXInstrInfo *TII,
                                   MachineBasicBlock &MBB,
                                   MachineBasicBlock::iterator MBBI) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();
  Register Base = MI.getOperand(1).getReg();

  bool OffsetIsReg = MI.getOperand(0).isReg();
  if (!(OffsetIsReg || MI.getOperand(0).isImm())) {
    MBBI->print(errs());
    report_fatal_error("Cache instruction operand unsupported");
  }

  unsigned OpCode;
  switch (MBBI->getOpcode()) {
  case KVX::DINVALLp:
    OpCode = OffsetIsReg
                 ? KVX::DINVALLrr
                 : GetImmOpCode(MI.getOperand(0).getImm(), KVX::DINVALLri10,
                                KVX::DINVALLri37, KVX::DINVALLri64);
    break;
  case KVX::DTOUCHLp:
    OpCode = OffsetIsReg
                 ? KVX::DTOUCHLrr
                 : GetImmOpCode(MI.getOperand(0).getImm(), KVX::DTOUCHLri10,
                                KVX::DTOUCHLri37, KVX::DTOUCHLri64);
    break;
  case KVX::DZEROLp:
    OpCode = OffsetIsReg
                 ? KVX::DZEROLrr
                 : GetImmOpCode(MI.getOperand(0).getImm(), KVX::DZEROLri10,
                                KVX::DZEROLri37, KVX::DZEROLri64);
    break;
  case KVX::I1INVALSp:
    OpCode = OffsetIsReg
                 ? KVX::I1INVALSrr
                 : GetImmOpCode(MI.getOperand(0).getImm(), KVX::I1INVALSri10,
                                KVX::I1INVALSri37, KVX::I1INVALSri64);
    break;
  default:
    report_fatal_error("Cache instruction not supported");
  }

  if (OffsetIsReg)
    BuildMI(MBB, MBBI, DL, TII->get(OpCode))
        .addReg(MI.getOperand(0).getReg())
        .addReg(Base);
  else
    BuildMI(MBB, MBBI, DL, TII->get(OpCode))
        .addImm(MI.getOperand(0).getImm())
        .addReg(Base);

  MI.eraseFromParent();
  return true;
}

// ========================================================================== //

// Return load opcode used by atomic operations.
unsigned getLOADOpcode(uint64_t Size, const MachineOperand MO) {
  switch (Size) {
  case 4:
    return MO.isReg() ? KVX::LWZrr : KVX::LWZp;
  case 8:
    return MO.isReg() ? KVX::LDrr : KVX::LDp;
  default:
    report_fatal_error("No LOAD Opcode for this Size");
  }
}

// Return acswap opcode used by atomic operations.
signed getACSWAPOpcode(uint64_t Size, const MachineOperand MO, bool IsCV1) {
  // When CV1:
  // Return -1 if MO is an immediate that doesn't fit in a 37-bit integer.
  // When CV2:
  // Return -1 if MO is an immediate not fitting in 54 bits
  // Return -2 if MO is a register
  if (IsCV1) {
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
      report_fatal_error("No ACSWAP Opcode for this Size");
    }
  } else {
    int ACSWAPrr, ACSWAPri27, ACSWAPri54;
    switch (Size) {
    case 4:
      ACSWAPrr = KVX::ACSWAPWr;
      ACSWAPri27 = KVX::ACSWAPWri27;
      ACSWAPri54 = KVX::ACSWAPWri54;
      break;
    case 8:
      ACSWAPrr = KVX::ACSWAPDr;
      ACSWAPri27 = KVX::ACSWAPDri27;
      ACSWAPri54 = KVX::ACSWAPDri54;
      break;
    default:
      report_fatal_error("No ACSWAP Opcode for this Size");
    }

    if (MO.isReg())
      return -2;

    int64_t Imm = MO.getImm();
    if (Imm == 0)
      return ACSWAPrr;
    if (isInt<27>(Imm))
      return ACSWAPri27;
    if (isInt<54>(Imm))
      return ACSWAPri54;

    return -1;
  }
}

// Return acswap opcode used by atomic operations. Modify memory addressing
// mode if it uses an immediate value that doesn't fix in a 37-bit integer.
signed getACSWAPOpcodeModifyAddr(const KVXInstrInfo *TII,
                                 MachineBasicBlock &MBB,
                                 MachineBasicBlock::iterator MBBI, DebugLoc DL,
                                 MachineOperand &Offset, Register Base,
                                 uint64_t Size, const MachineOperand MO) {
  bool IsV1 = TII->getSubtarget().isV1();
  signed ACSWAP = getACSWAPOpcode(Size, Offset, IsV1);

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
    ACSWAP = getACSWAPOpcode(Size, Offset, IsV1);
  } else if (ACSWAP == -2) {
    // Offset is a register. Do the same as above, but with the rr format
    BuildMI(MBB, MBBI, DL, TII->get(KVX::ADDDrr), Base)
        .addReg(Base)
        .addReg(Offset.getReg());
    auto ZeroOffset = MachineOperand::CreateImm(0);
    ACSWAP = getACSWAPOpcode(Size, ZeroOffset, IsV1);
  }

  return ACSWAP;
}

// Return operation opcode used by the atomic_load_operation operations.
unsigned getAtomicOPOpcode(uint64_t Size, unsigned Pseudo) {
  if (!(Size == 4 || Size == 8))
    report_fatal_error("Size isn't supported for AtomicOPOpcode");

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
    report_fatal_error("Invalid ALOADOP Pseudo opcode");
  }
}

static bool isGlobalAddrspace(const int AA) {
  return AA == KVX::AS_OCL_GLOBAL || AA == KVX::AS_BYPASS ||
         AA == KVX::AS_PRELOAD;
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

  if (!MI.getNumMemOperands()) {
    MBBI->print(errs());
    report_fatal_error("expandALOAD pseudo-instr expects MemOperands");
  }

  // NOTE: Some instructions can have more than 1 MemOperand. We assume that
  // the first one is the right one.
  MachineMemOperand &MO = *MI.memoperands()[0];
  uint64_t MOSize = MO.getSize().toRaw();

  if (!MO.isAtomic()) {
    MBBI->print(errs());
    report_fatal_error("MemOperand is not atomic");
  }
  if (!(MOSize == 4 || MOSize == 8)) {
    MBBI->print(errs());
    report_fatal_error("MemOperand size isn't supported");
  }

  LLVM_DEBUG(dbgs() << "  memoperand size: " << MOSize << '\n');

  Register Output = MI.getOperand(0).getReg();
  MachineOperand Offset = MI.getOperand(2);
  Register Base = MI.getOperand(3).getReg();
  Register Value = MI.getOperand(4).getReg();
  auto BaseState = getRegState(MI.getOperand(3));
  // .csloop
  //   load.u $fetch = $offset[$base]
  //   op $update = $value, $fetch            # value first for sbf instr
  //   acswap $offset[$base] = $update$fetch
  //   cb.even $update ? .csloop              # acswap boolean status is
  // .done                                    #   stored in $update
  //   copy $output = $fetch

  Register UpdateFetch = MI.getOperand(1).getReg();
  Register Update = TRI->getSubReg(UpdateFetch, KVX::sub_d0);
  Register Fetch = TRI->getSubReg(UpdateFetch, KVX::sub_d1);

  unsigned COPY = MOSize == 4 ? KVX::COPYW : KVX::COPYD;
  unsigned LOAD = getLOADOpcode(MOSize, Offset);
  unsigned OP = getAtomicOPOpcode(MOSize, Opcode);
  signed ACSWAP = getACSWAPOpcodeModifyAddr(TII, MBB, MBBI, DL, Offset, Base,
                                            MOSize, Offset);

  // Create and link new MBBs.
  auto *CSLoopMBB = MF->CreateMachineBasicBlock(MBB.getBasicBlock());
  auto *DoneMBB = MF->CreateMachineBasicBlock(MBB.getBasicBlock());

  MF->insert(++MBB.getIterator(), CSLoopMBB);
  MF->insert(++CSLoopMBB->getIterator(), DoneMBB);

  CSLoopMBB->addSuccessor(CSLoopMBB);
  CSLoopMBB->addSuccessor(DoneMBB);

  DoneMBB->transferSuccessors(&MBB);
  DoneMBB->addLiveIn(Fetch);
  DoneMBB->sortUniqueLiveIns();

  LLVM_DEBUG(dbgs() << "DoneMBB: "; DoneMBB->dump(); dbgs() << "--------\n");
  MBB.addSuccessor(CSLoopMBB);
  for (auto LI : MBB.liveins())
    CSLoopMBB->addLiveIn(LI);

  // Populate DoneMBB.
  //   copy $output = $fetch
  BuildMI(DoneMBB, DL, TII->get(COPY), Output).addReg(Fetch);
  DoneMBB->splice(DoneMBB->end(), &MBB, MI, MBB.end());

  // Populate CSLoopMBB.
  //   load.u $fetch = $offset[$base]
  if (Offset.isReg() && TII->getSubtarget().isV1())
    BuildMI(CSLoopMBB, DL, TII->get(LOAD), Fetch)
        .addReg(Offset.getReg())
        .addReg(Base)
        .addImm(KVXMOD::VARIANT_U)
        .addImm(KVXMOD::DOSCALE_);
  else if (Offset.isReg() && !TII->getSubtarget().isV1()) {
    // the offset already got added in Base by getACSWAPOpcodeModifyAddr
    auto ZeroImm = MachineOperand::CreateImm(0);
    LOAD = getLOADOpcode(MOSize, ZeroImm);
    BuildMI(CSLoopMBB, DL, TII->get(LOAD), Fetch)
        .addImm(ZeroImm.getImm())
        .addReg(Base)
        .addImm(KVXMOD::VARIANT_U);
  } else {
    assert(Offset.isImm());
    BuildMI(CSLoopMBB, DL, TII->get(LOAD), Fetch)
        .addImm(Offset.getImm())
        .addReg(Base)
        .addImm(KVXMOD::VARIANT_U);
  }
  //   op $update = $value, $fetch (or just equal to $value for KVX::ASWAPp)
  if (Opcode != KVX::ASWAPp)
    BuildMI(CSLoopMBB, DL, TII->get(OP), Update).addReg(Value).addReg(Fetch);
  else
    BuildMI(CSLoopMBB, DL, TII->get(OP), Update).addReg(Value);
  if (TII->getSubtarget().isV1()) {
    //   acswap $offset[$base] = $update$fetch
    if (Offset.isReg())
      BuildMI(CSLoopMBB, DL, TII->get(ACSWAP), UpdateFetch)
          .addReg(Offset.getReg(), getRegState(Offset))
          .addReg(Base, BaseState)
          .addReg(UpdateFetch, RegState::InternalRead)
          .addImm(KVXMOD::DOSCALE_);
    else
      BuildMI(CSLoopMBB, DL, TII->get(ACSWAP), UpdateFetch)
          .addImm(Offset.getImm())
          .addReg(Base, BaseState)
          .addReg(UpdateFetch);
  } else {
    //  acswap $update, $offset[$base] = $update$fetch
    int64_t Imm = Offset.isImm() ? Offset.getImm() : 0;
    auto I = BuildMI(CSLoopMBB, DL, TII->get(ACSWAP), Update);
    if (Imm != 0) {
      assert(ACSWAP == KVX::ACSWAPWri27 || ACSWAP == KVX::ACSWAPWri54 ||
             ACSWAP == KVX::ACSWAPDri27 || ACSWAP == KVX::ACSWAPDri54);
      I.addImm(Imm);
    } else {
      assert(ACSWAP == KVX::ACSWAPWr || ACSWAP == KVX::ACSWAPDr);
    }
    const auto MemMode = isGlobalAddrspace(MO.getAddrSpace())
                             ? KVXMOD::COHERENCY_G
                             : KVXMOD::COHERENCY_;

    I.addReg(Base).addReg(UpdateFetch).addImm(KVXMOD::BOOLCAS_).addImm(MemMode);
  }
  //   cb.even $update ? .csloop
  BuildMI(CSLoopMBB, DL, TII->get(KVX::CB))
      .addReg(Update, RegState::Kill)
      .addMBB(CSLoopMBB)
      .addImm(KVXMOD::SCALARCOND_EVEN);

  if (Offset.isReg())
    CSLoopMBB->addLiveIn(Offset.getReg());
  CSLoopMBB->addLiveIn(UpdateFetch);
  CSLoopMBB->addLiveIn(Base);
  CSLoopMBB->addLiveIn(Update);
  CSLoopMBB->sortUniqueLiveIns();
  NextMBBI = MBB.end();
  MI.eraseFromParent();
  LLVM_DEBUG(dbgs() << "Generated bb: "; CSLoopMBB->dump());
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

  if (!MI.getNumMemOperands()) {
    MBBI->print(errs());
    report_fatal_error("expandATAS pseudo-instr expects MemOperands");
  }

  MachineMemOperand *MO = MI.memoperands()[0];
  if (MO->getSize() != 1) {
    MBBI->print(errs());
    report_fatal_error("expandATAS only support atomicrmw xchg i8*, 1 "
                       "operation (test_and_set)");
  }

  DebugLoc DL = MI.getDebugLoc();
  MachineFunction *MF = MBB.getParent();
  const KVXRegisterInfo *TRI =
      (const KVXRegisterInfo *)MF->getSubtarget().getRegisterInfo();

  Register Output = MI.getOperand(0).getReg();
  Register Base = MI.getOperand(6).getReg();
  Register Value = MI.getOperand(7).getReg();

  Register UpdateFetch = MI.getOperand(1).getReg();
  Register Update = TRI->getSubReg(UpdateFetch, KVX::sub_d0);
  Register Fetch = TRI->getSubReg(UpdateFetch, KVX::sub_d1);

  Register Pos = MI.getOperand(2).getReg();
  Register Mask = MI.getOperand(3).getReg();
  Register Offset = MI.getOperand(5).isReg() ? MI.getOperand(5).getReg()
                                             : MI.getOperand(4).getReg();

  // CV1 code:
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
  //   sllw $mask = $value, $pos     # new value to set:
  //   orw $update = $fetch, $mask   #   $fetch | ($value << $pos)
  //   cb.wnez $output ? .done       # the byte is already set
  // .csloop2
  //   acswapw $offset[$base] = $update$fetch
  //   cb.even $update ? .csloop
  // .done

  // CV2 code:
  //   addd $pos = $base, $offset    # iff $offset != 0
  //   andd $pos = $pos, 3           # find the place of the byte to
  //                                 #   test_and_set in the memory word
  //                                 #   ($pos is 0, 1, 2, or 3)
  //   sbfd $offset = $pos, $offset  # the address of the memory word
  //                                 #   containing the byte is
  //                                 #   ($base + $offset - $pos)
  //   slld $pos = $pos, 3           # $pos in bits: $pos * 8
  //   addd $base = $base, $offset   # for lack of $reg[$reg] format in acswap
  // .csloop
  //   lwz.u $fetch = 0[$base]
  //   srlw $output = $fetch, $pos   # keep only the byte to test_and_set:
  //   andw $output = $output, 0xFF  #   ($fetch >> $pos) & 0xFF
  //   sllw $mask = $value, $pos     # new value to set:
  //   orw $update = $fetch, $mask   #   $fetch | ($value << $pos)
  //   cb.wnez $output ? .done       # the byte is already set
  // .csloop2
  //   acswapw $update, [$base] = $update$fetch
  //   cb.even $update ? .csloop
  // .done

  // Create and link new MBBs.
  auto *CSLoopMBB = MF->CreateMachineBasicBlock(MBB.getBasicBlock());
  auto *CSLoop2MBB = MF->CreateMachineBasicBlock(MBB.getBasicBlock());
  auto *DoneMBB = MF->CreateMachineBasicBlock(MBB.getBasicBlock());

  MF->insert(++MBB.getIterator(), CSLoopMBB);
  MF->insert(++CSLoopMBB->getIterator(), CSLoop2MBB);
  MF->insert(++CSLoop2MBB->getIterator(), DoneMBB);

  CSLoopMBB->addSuccessor(CSLoop2MBB);
  CSLoopMBB->addSuccessor(DoneMBB);
  CSLoop2MBB->addSuccessor(CSLoopMBB);
  CSLoop2MBB->addSuccessor(DoneMBB);

  DoneMBB->transferSuccessors(&MBB);
  MBB.addSuccessor(CSLoopMBB);

  // Populate DoneMBB.
  DoneMBB->splice(DoneMBB->end(), &MBB, MI, MBB.end());
  DoneMBB->setLabelMustBeEmitted();
  DoneMBB->addLiveIn(Output);
  LLVM_DEBUG(dbgs() << "DoneMBB: "; DoneMBB->dump(); dbgs() << "--------\n");
  const auto MemMode = isGlobalAddrspace(MO->getAddrSpace())
                           ? KVXMOD::COHERENCY_G
                           : KVXMOD::COHERENCY_;

  for (auto LI : MBB.liveins())
    CSLoopMBB->addLiveIn(LI);

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
  if (!TII->getSubtarget().isV1()) {
    // addd $base = $base, $offset   # no $reg[$reg] format in acswap, so we
    //                               # have to calculate it ourselves
    BuildMI(&MBB, DL, TII->get(KVX::ADDDrr), Base).addReg(Base).addReg(Offset);
  }
  //   slld $pos = $pos, 3           # $pos in bits: $pos * 8
  BuildMI(&MBB, DL, TII->get(KVX::SLLDri), Pos).addReg(Pos).addImm(3);

  // Populate CSLoopMBB (insns have been manually scheduled).
  //   lwz.u $fetch = $offset[$base]
  if (TII->getSubtarget().isV1())
    BuildMI(CSLoopMBB, DL, TII->get(KVX::LWZrr), Fetch)
        .addReg(Offset)
        .addReg(Base)
        .addImm(KVXMOD::VARIANT_U)
        .addImm(KVXMOD::DOSCALE_);
  else // Offset is already added in Base
    BuildMI(CSLoopMBB, DL, TII->get(KVX::LWZp), Fetch)
        .addImm(0)
        .addReg(Base)
        .addImm(KVXMOD::VARIANT_U);
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
  if (TII->getSubtarget().isV1())
    //   acswapw $offset[$base] = $update$fetch
    BuildMI(CSLoop2MBB, DL, TII->get(KVX::ACSWAPWrr), UpdateFetch)
        .addReg(Offset)
        .addReg(Base)
        .addReg(UpdateFetch)
        .addImm(KVXMOD::DOSCALE_);
  else
    //   acswapw $update, [$base] = $update$fetch
    BuildMI(CSLoop2MBB, DL, TII->get(KVX::ACSWAPWr), Update)
        .addReg(Base)
        .addReg(UpdateFetch)
        .addImm(KVXMOD::BOOLCAS_)
        .addImm(MemMode);
  //   cb.even $update ? .csloop
  BuildMI(CSLoop2MBB, DL, TII->get(KVX::CB))
      .addReg(Update)
      .addMBB(CSLoopMBB)
      .addImm(KVXMOD::SCALARCOND_EVEN);

  CSLoopMBB->addLiveIn(Offset);
  CSLoop2MBB->addLiveIn(Offset);
  CSLoopMBB->addLiveIn(UpdateFetch);
  CSLoop2MBB->addLiveIn(UpdateFetch);
  CSLoopMBB->addLiveIn(Base);
  CSLoop2MBB->addLiveIn(Base);
  CSLoop2MBB->addLiveIn(Update);
  CSLoopMBB->addLiveIn(Fetch);
  CSLoopMBB->addLiveIn(Pos);
  CSLoopMBB->addLiveIn(Value);
  CSLoop2MBB->addLiveIn(Output);
  CSLoopMBB->sortUniqueLiveIns();
  CSLoop2MBB->sortUniqueLiveIns();
  NextMBBI = MBB.end();
  MI.eraseFromParent();

  LLVM_DEBUG(dbgs() << "Generated CSLoopMBB: "; CSLoopMBB->dump();
             dbgs() << "--------\n");
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

  if (!MI.getNumMemOperands()) {
    MBBI->print(errs());
    report_fatal_error("expandALOAD pseudo-instr expects MemOperands");
  }

  // FIXME: Some instructions can have more than 1 MemOperand. We assume that
  // the first one is the right one.
  MachineMemOperand &MO = *MI.memoperands()[0];
  uint64_t MOSize = MO.getSize().toRaw();
  const auto MemMode = isGlobalAddrspace(MO.getAddrSpace())
                           ? KVXMOD::COHERENCY_G
                           : KVXMOD::COHERENCY_;

  Register Output = MI.getOperand(0).getReg();
  MachineOperand Offset = MI.getOperand(2);
  Register Base = MI.getOperand(3).getReg();
  Register Compare = MI.getOperand(4).getReg();
  Register Swap = MI.getOperand(5).getReg();

  Register DesiredExpected = MI.getOperand(1).getReg();
  Register Desired = TRI->getSubReg(DesiredExpected, KVX::sub_d0);
  Register Expected = TRI->getSubReg(DesiredExpected, KVX::sub_d1);

  //   copy $expected = $compare                  # iff $compare isn't a valid
  //                                              #   PairedReg subreg
  // .csloop
  //   copy $desired = $swap                      # restore $desired in case
  //                                              #   of loop
  //   acswap $offset[$base] = $desired$expected  # try the compare and swap
  //   cb.odd $desired ? .pass                    # return $expected
  //                                              #   on success
  // .csloop2
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
  auto *CSLoopMBB = MF->CreateMachineBasicBlock(MBB.getBasicBlock());
  auto *CSLoop2MBB = MF->CreateMachineBasicBlock(MBB.getBasicBlock());
  auto *PassMBB = MF->CreateMachineBasicBlock(MBB.getBasicBlock());
  auto *DoneMBB = MF->CreateMachineBasicBlock(MBB.getBasicBlock());

  MF->insert(++MBB.getIterator(), CSLoopMBB);
  MF->insert(++CSLoopMBB->getIterator(), CSLoop2MBB);
  MF->insert(++CSLoop2MBB->getIterator(), PassMBB);
  MF->insert(++PassMBB->getIterator(), DoneMBB);

  CSLoopMBB->addSuccessor(CSLoop2MBB);
  CSLoop2MBB->addSuccessor(CSLoopMBB);
  CSLoop2MBB->addSuccessor(DoneMBB);
  CSLoopMBB->addSuccessor(PassMBB);
  PassMBB->addSuccessor(DoneMBB);

  DoneMBB->transferSuccessors(&MBB);
  MBB.addSuccessor(CSLoopMBB);

  // Populate DoneMBB.
  DoneMBB->splice(DoneMBB->end(), &MBB, MI, MBB.end());
  DoneMBB->setLabelMustBeEmitted();

  // Populate MBB.
  //   copy $expected = $compare                  # iff $compare isn't a valid
  //                                              #   PairedReg subreg
  if (Desired != Swap || Expected != Compare)
    BuildMI(&MBB, DL, TII->get(COPY), Expected).addReg(Compare);

  // Populate CSLoopMBB.
  //   copy $desired = $swap                      # restore $desired in case
  //                                              #   of loop
  BuildMI(CSLoopMBB, DL, TII->get(COPY), Desired).addReg(Swap);
  if (TII->getSubtarget().isV1()) {
    //  acswap $offset[$base] = $desired$expected # try the compare and swap
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
  } else {
    //  acswap $desired, $offset[$base] = $desired$expected
    int64_t Imm = Offset.getImm() ? Offset.getImm() : 0;
    if (Imm == 0) {
      assert(ACSWAP == KVX::ACSWAPWr || ACSWAP == KVX::ACSWAPDr);
      BuildMI(CSLoopMBB, DL, TII->get(ACSWAP), Desired)
          .addReg(Base)
          .addReg(DesiredExpected)
          .addImm(KVXMOD::BOOLCAS_)
          .addImm(MemMode);
    } else {
      assert(ACSWAP == KVX::ACSWAPWri27 || ACSWAP == KVX::ACSWAPWri54 ||
             ACSWAP == KVX::ACSWAPDri27 || ACSWAP == KVX::ACSWAPDri54);
      BuildMI(CSLoopMBB, DL, TII->get(ACSWAP), Desired)
          .addImm(Imm)
          .addReg(Base)
          .addReg(DesiredExpected)
          .addImm(KVXMOD::BOOLCAS_)
          .addImm(MemMode);
    }
  }
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
  if (Offset.isReg() && TII->getSubtarget().isV1())
    BuildMI(CSLoop2MBB, DL, TII->get(LOAD), Output)
        .addReg(Offset.getReg())
        .addReg(Base)
        .addImm(KVXMOD::VARIANT_U)
        .addImm(KVXMOD::DOSCALE_);
  else if (Offset.isReg() && !TII->getSubtarget().isV1()) {
    // the offset already got added in Base by getACSWAPOpcodeModifyAddr
    auto ZeroImm = MachineOperand::CreateImm(0);
    LOAD = getLOADOpcode(MOSize, ZeroImm);
    BuildMI(CSLoop2MBB, DL, TII->get(LOAD), Output)
        .addImm(ZeroImm.getImm())
        .addReg(Base)
        .addImm(KVXMOD::VARIANT_U);
  } else {
    assert(Offset.isImm());
    BuildMI(CSLoop2MBB, DL, TII->get(LOAD), Output)
        .addImm(Offset.getImm())
        .addReg(Base)
        .addImm(KVXMOD::VARIANT_U);
  }
  //   comp.eq $desired = $output, $expected      # desired use as temp reg
  //                                              #   for comp
  BuildMI(CSLoop2MBB, DL, TII->get(COMP), Desired)
      .addReg(Output)
      .addReg(Expected)
      .addImm(KVXMOD::COMPARISON_EQ);
  //   cb.odd $desired ? .csloop
  BuildMI(CSLoop2MBB, DL, TII->get(KVX::CB))
      .addReg(Desired)
      .addMBB(CSLoopMBB)
      .addImm(KVXMOD::SCALARCOND_ODD);
  //   goto .done
  BuildMI(CSLoop2MBB, DL, TII->get(KVX::GOTO)).addMBB(DoneMBB);

  // Populate PassMBB.
  //   copy $output = $expected                   # output contains expected
  //                                              #   on success, loaded value
  //                                              #   on failure
  PassMBB->setLabelMustBeEmitted();
  BuildMI(PassMBB, DL, TII->get(COPY), Output).addReg(Expected);

  if (Offset.isReg()) {
    CSLoop2MBB->addLiveIn(Offset.getReg());
    CSLoopMBB->addLiveIn(Offset.getReg());
  }
  CSLoopMBB->addLiveIn(Swap);
  CSLoop2MBB->addLiveIn(Base);
  CSLoopMBB->addLiveIn(Base);
  CSLoop2MBB->addLiveIn(Expected);
  NextMBBI = MBB.end();
  MI.eraseFromParent();
  PassMBB->addLiveIn(Expected);
  DoneMBB->addLiveIn(Output);
  CSLoopMBB->sortUniqueLiveIns();
  CSLoop2MBB->sortUniqueLiveIns();

  LLVM_DEBUG(dbgs() << "Generated CSLoopMBB: "; CSLoopMBB->dump();
             dbgs() << "--------\n");
  LLVM_DEBUG(dbgs() << "Generated CSLoop2MBB: "; CSLoop2MBB->dump();
             dbgs() << "--------\n");
  LLVM_DEBUG(dbgs() << "Generated PassMBB: "; PassMBB->dump();
             dbgs() << "--------\n");
  LLVM_DEBUG(dbgs() << "Generated DoneMBB: "; DoneMBB->dump();
             dbgs() << "--------\n");
  return true;
}

static bool expandStore(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                        MachineBasicBlock::iterator MBBI, unsigned Ri10,
                        unsigned Ri37, unsigned Ri64) {

  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  int64_t Offset = MI.getOperand(0).getImm();
  Register Base = MI.getOperand(1).getReg();
  Register Val = MI.getOperand(2).getReg();

  BuildMI(MBB, MBBI, DL, TII->get(GetImmOpCode(Offset, Ri10, Ri37, Ri64)))
      .addImm(Offset)
      .addReg(Base)
      .addReg(Val, MI.getOperand(2).isKill() ? RegState::Kill : 0);

  MI.eraseFromParent();
  return true;
}

static bool expandLoad(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                       MachineBasicBlock::iterator MBBI, unsigned Ri10,
                       unsigned Ri37, unsigned Ri64) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  Register OutputReg = MI.getOperand(0).getReg();
  int64_t Offset = MI.getOperand(1).getImm();
  Register Base = MI.getOperand(2).getReg();
  int64_t Variant = MI.getOperand(3).getImm();

  BuildMI(MBB, MBBI, DL, TII->get(GetImmOpCode(Offset, Ri10, Ri37, Ri64)),
          OutputReg)
      .addImm(Offset)
      .addReg(Base)
      .addImm(Variant);

  MI.eraseFromParent();
  return true;
}

static bool expandEXTFZ(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                        MachineBasicBlock::iterator MBBI, bool Word) {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  Register OutputReg = MI.getOperand(0).getReg();
  Register ValReg = MI.getOperand(1).getReg();
  int64_t Andmask = MI.getOperand(2).getImm();
  int64_t Shiftcount = MI.getOperand(3).getImm();

  int Count = 0, Maxcount = 0;
  int64_t Mask = 1;
  int MaxBit = (Word ? 32 : 64) - Shiftcount;
  for (int I = 0; I < MaxBit; I++) {
    if ((Andmask & Mask) != 0) {
      if (Maxcount != 0) {
        Maxcount = 0;
        Count = 0;
        break;
      }
      Count++;
    } else {
      if (I == 0)
        break;
      Maxcount = Count;
    }
    Mask <<= 1;
  }
  if (Maxcount == 0 && Count > 0)
    Maxcount = Count;
  LLVM_DEBUG(dbgs() << "EXTFZ word: " << Word << " Andmask: " << Andmask
                    << " shiftcount: " << Shiftcount
                    << " maxcount: " << Maxcount << "\n");
  if (Maxcount > 0) {
    BuildMI(MBB, MBBI, DL, TII->get(KVX::EXTFZ), OutputReg)
        .addReg(ValReg)
        .addImm(Shiftcount + Maxcount - 1)
        .addImm(Shiftcount);
  } else {
    unsigned OpCode;
    BuildMI(MBB, MBBI, DL, TII->get(Word ? KVX::SRLWri : KVX::SRLDri),
            OutputReg)
        .addReg(ValReg)
        .addImm(Shiftcount);

    if (Word)
      OpCode = GetImmOpCode(Andmask, KVX::ANDWri10, KVX::ANDWri37, KVX::NOP);
    else
      OpCode =
          GetImmOpCode(Andmask, KVX::ANDDri10, KVX::ANDDri37, KVX::ANDDri64);

    BuildMI(MBB, MBBI, DL, TII->get(OpCode), OutputReg)
        .addReg(OutputReg)
        .addImm(Andmask);
  }

  MI.eraseFromParent();
  return true;
}

static bool expandTcaInplace(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                             MachineBasicBlock::iterator MBBI, unsigned SubReg,
                             unsigned Opcode) {
  MachineFunction *MF = MBB.getParent();
  const KVXRegisterInfo *TRI =
      (const KVXRegisterInfo *)MF->getSubtarget().getRegisterInfo();

  auto OutReg = TRI->getSubReg(MBBI->getOperand(0).getReg(), SubReg);

  LLVM_DEBUG(auto RName = TRI->getRegAsmName(OutReg.id());;
             dbgs() << "Expanding write to sub-register: " << RName
                    << " from pseudo: " << *MBBI);

  DebugLoc DL = MBBI->getDebugLoc();
  MachineInstrBuilder I = BuildMI(MBB, MBBI, DL, TII->get(Opcode), OutReg);
  for (unsigned Op = 2; Op < MBBI->getNumOperands(); Op++) {
    LLVM_DEBUG(dbgs() << "Adding operand: " << MBBI->getOperand(Op) << " to "
                      << *I.getInstr());
    I->addOperand(*MF, MBBI->getOperand(Op));
  }

  LLVM_DEBUG(dbgs() << "Converted to: " << *I.getInstr() << '\n');
  MBBI->eraseFromParent();
  return true;
}

static bool prefixLoopEndWithNop(const KVXInstrInfo *TII,
                                 MachineBasicBlock &MBB,
                                 MachineBasicBlock::iterator MBBI) {
  // If the loop_end position is not the first instruction of the basic block,
  // we don't have to look at predecessor blocks
  if (MBB.getFirstNonDebugInstr() != MBBI) {
    auto *PreviousInstr = MBBI->getPrevNode();
    if (PreviousInstr->isBranch()) {
      DEBUG_WITH_TYPE("hardware-loops",
                      dbgs()
                          << "Must emit a NOP instruction before the label.\n");
      BuildMI(MBB, MBBI, MBBI->getDebugLoc(), TII->get(KVX::NOP));
      return true; // we return because a nop has already been added
    }
    return false;
  }
  // If the block has more than a predecessor, there's necessarily a branch to
  // it, so a nop is needed.
  if (MBB.pred_size() > 1) {
    DEBUG_WITH_TYPE(
        "hardware-loops",
        dbgs() << "Must emit a NOP instruction before the label.\n");
    BuildMI(MBB, MBBI, MBBI->getDebugLoc(), TII->get(KVX::NOP));
    return true; // we return because a nop has already been added
  }
  // If the block has a single predecessor and it's a fallthrough, we check the
  // last instruction of this block to decide if a nop is needed
  auto *PredBB = *MBB.pred_begin();
  // If the block is empty or only has debug instructions
  if (PredBB->getLastNonDebugInstr() == PredBB->end()) {
    DEBUG_WITH_TYPE(
        "hardware-loops",
        dbgs() << "Must emit a NOP instruction before the label.\n");
    BuildMI(MBB, MBBI, MBBI->getDebugLoc(), TII->get(KVX::NOP));
    return true; // we return because a nop has already been added
  }
  auto LastInstInPred = PredBB->getLastNonDebugInstr();
  // we need a nop if single predecessors doesn't fallthrough, or if it falls
  // through but it's last instruction is a branch
  if (PredBB->getFallThrough() != &MBB || LastInstInPred->isBranch()) {
    DEBUG_WITH_TYPE(
        "hardware-loops",
        dbgs() << "Must emit a NOP instruction before the label.\n");
    BuildMI(MBB, MBBI, MBBI->getDebugLoc(), TII->get(KVX::NOP));
    return true; // we return because a nop has already been added
  }
  return false; // no nop was needed
}

static bool expandENDLOOP(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                          MachineBasicBlock::iterator MBBI) {

  MachineBasicBlock *ExitBB = MBBI->getOperand(1).getMBB();
  MCSymbol *ExitSymbol = MBBI->getOperand(2).getMCSymbol();

  DEBUG_WITH_TYPE("hardware-loops", dbgs() << "Expanding ENDLOOP: " << *MBBI);
  // First, must find where to emit the end-loop symbol.
  // In worst case, we'll have to ensure fallthrough the exit address by
  // inserting a NOP instruction before it.
  bool NeedsNOP = false;
  // If ENDLOOP is not the first instruction of the BB, it's safe to emit
  // replacing the pseudo. If this BB is not branched to, its also safe to
  // replace it.
  if (MBB.begin() != MBBI ||
      (!MBB.hasAddressTaken() && !MBB.hasLabelMustBeEmitted())) {
    BuildMI(MBB, MBBI, MBBI->getDebugLoc(), TII->get(TargetOpcode::EH_LABEL))
        .addSym(ExitSymbol);
    DEBUG_WITH_TYPE("hardware-loops", dbgs() << "Expanded label inplace.\n";
                    MBB.dump());
  } else if (MBB.pred_size() == 1) {
    // If this block has a single predecessor, try to add the symbol to the end
    // of it.
    auto *PredBB = *MBB.pred_begin();
    if (PredBB->empty()) {
      MBBI->print(errs());
      report_fatal_error("Did not expected an empty BB in the loop.\n");
    }
    auto InsPoint = PredBB->getLastNonDebugInstr();
    if (PredBB->succ_size() != 1 || InsPoint->isBranch()) {
      auto Stop = PredBB->getFirstTerminator();
      // Test all branch instructions to find out where to insert the
      // instruction
      while (true) {
        if (TII->getBranchDestBlock(*InsPoint) == &MBB)
          break;
        if (InsPoint == Stop) {
          InsPoint = PredBB->end();
          break;
        }
        --InsPoint;
      }
      if (InsPoint == PredBB->end())
        NeedsNOP = true;
    }
    if (!NeedsNOP) {
      BuildMI(*PredBB, InsPoint, MBBI->getDebugLoc(),
              TII->get(TargetOpcode::EH_LABEL))
          .addSym(ExitSymbol);
      DEBUG_WITH_TYPE("hardware-loops",
                      dbgs() << "Inserting symbol at predecessor end:\n";
                      PredBB->dump());
    }
  } else
    NeedsNOP = true;

  if (NeedsNOP) {
    DEBUG_WITH_TYPE(
        "hardware-loops",
        dbgs() << "Must emit a NOP instruction before the label.\n");
    BuildMI(MBB, MBBI, MBBI->getDebugLoc(), TII->get(KVX::NOP));
    BuildMI(MBB, MBBI, MBBI->getDebugLoc(), TII->get(TargetOpcode::EH_LABEL))
        .addSym(ExitSymbol);
  }
  if (!MBB.isLayoutSuccessor(ExitBB)) {
    BuildMI(MBB, MBBI, MBBI->getDebugLoc(), TII->get(KVX::GOTO))
        .addMBB(ExitBB)
        .getInstr();
  }
  MBBI->eraseFromParent();
  DEBUG_WITH_TYPE("hardware-loops", dbgs() << "Latch block after cleanup:";
                  MBB.dump());
  return true;
}

static bool expandSWAP64p(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                          MachineBasicBlock::iterator MBBI) {
  auto &DL = MBBI->getDebugLoc();
  const MCInstrDesc &CpDesc = TII->get(KVX::COPYD);
  Register R1, R2;
  switch (MBBI->getOpcode()) {
  // Put parallel assignment inside a bundle
  case KVX::SWAP64p:
    R1 = MBBI->getOperand(0).getReg();
    R2 = MBBI->getOperand(1).getReg();
    MachineInstr *IFirst, *ILast;
    IFirst =
        BuildMI(MBB, MBBI, DL, CpDesc).addDef(R1).addUse(R2, RegState::Kill);
    ILast =
        BuildMI(MBB, MBBI, DL, CpDesc).addDef(R2).addUse(R1, RegState::Kill);
    finalizeBundle(MBB, IFirst->getIterator(), std::next(ILast->getIterator()));
    MBB.erase(MBBI);
    return true;
  // Parallel assignment is already inside a bundle
  case KVX::BUNDLE:
    for (auto II = std::next(MBBI->getIterator());
         II != MBB.end() && II != std::next(MBBI); II = std::next(II)) {
      if (II->getOpcode() == KVX::SWAP64p) {
        R1 = II->getOperand(0).getReg();
        R2 = II->getOperand(1).getReg();
        BuildMI(MBB, II, DL, CpDesc).addDef(R1).addUse(R2, RegState::Kill);
        BuildMI(MBB, II, DL, CpDesc).addDef(R2).addUse(R1, RegState::Kill);
        MBB.erase(II);
        return true;
      }
    }
    return false;
  }
  assert(false && "Unexpected pseudo");
  return false;
}

static bool expandXSWAP256p(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                            MachineBasicBlock::iterator MBBI) {
  bool StandAlone = MBBI->getOpcode() == KVX::XSWAP256p;
  assert((StandAlone || MBBI->getOpcode() == KVX::BUNDLE) &&
         "Unexpected pseudo");
  auto I = MBBI->getIterator();
  MachineBasicBlock::iterator InsertHere = MBBI;
  if (!StandAlone) { // Search if we have a xswap256 inside
    auto E = MBBI->getParent()->instr_end();
    while (++I != E && I->isInsideBundle())
      if (I->isPseudo() && I->getOpcode() == KVX::XSWAP256p)
        break;
    if (I == E || !I->isInsideBundle())
      return false;
    InsertHere = std::next(InsertHere);
  }
  LLVM_DEBUG(dbgs() << "Expanding: "; I->dump());
  MachineInstr &MI = *I;
  MachineFunction *MF = MBB.getParent();
  const KVXRegisterInfo *TRI =
      (const KVXRegisterInfo *)MF->getSubtarget().getRegisterInfo();

  const auto &Subtarget = TII->getSubtarget();
  DebugLoc DL = MI.getDebugLoc();
  Register R = MI.getOperand(0).getReg();
  Register V = MI.getOperand(1).getReg();
  auto RName = TRI->getRegAsmName(R.id());
  auto VName = TRI->getRegAsmName(V.id());
  unsigned MOVEFO = Subtarget.isV1() ? KVX::MOVEFOro : KVX::XMOVEFO;

  if (!KVX::QuadRegRegClass.contains(R))
    report_fatal_error("First register of XSWAP256p (" + RName +
                       "is not a QuadReg.");

  if (Subtarget.isV1()) {
    if (KVX::VectorRegERegClass.contains(V))
      MOVEFO = KVX::MOVEFOre;
    else if (!KVX::VectorRegORegClass.contains(V))
      report_fatal_error("Second register of XSWAP256p (" + VName +
                         ") is not a VectorReg.");
  }

  auto VHi = TRI->getSubReg(V, KVX::sub_q1);
  auto VLo = TRI->getSubReg(V, KVX::sub_q0);
  auto R0 = TRI->getSubReg(R, KVX::sub_d0);
  auto R1 = TRI->getSubReg(R, KVX::sub_d1);
  auto R2 = TRI->getSubReg(R, KVX::sub_d2);
  auto R3 = TRI->getSubReg(R, KVX::sub_d3);

  unsigned E = Subtarget.isV1() ? KVX::MOVETQrrbe : KVX::XMOVETQrrbe;
  unsigned O = Subtarget.isV1() ? KVX::MOVETQrrbo : KVX::XMOVETQrrbo;
  if (StandAlone) {
    LLVM_DEBUG(
        dbgs() << "Adding bundle to perform Vector QuadReg swap of registers: "
               << RName << " <--> " << VName << "\n");
    BuildMI(MBB, InsertHere, DL, TII->get(KVX::BUNDLE));
  }
  BuildMI(MBB, InsertHere, DL, TII->get(MOVEFO), R).addReg(V, RegState::Kill);
  BuildMI(MBB, InsertHere, DL, TII->get(E), VLo)
      .addReg(R0, RegState::Kill)
      .addReg(R1, RegState::Kill);
  BuildMI(MBB, InsertHere, DL, TII->get(O), VHi)
      .addReg(R2, RegState::Kill)
      .addReg(R3, RegState::Kill);

  auto Pos = --InsertHere;
  if (StandAlone)
    MI.eraseFromParent();
  else
    MI.eraseFromBundle();
  if (!Pos->isBundledWithPred())
    Pos->bundleWithPred();
  --Pos;
  if (!Pos->isBundledWithPred())
    Pos->bundleWithPred();
  --Pos;
  if (!Pos->isBundledWithPred())
    Pos->bundleWithPred();
  LLVM_DEBUG(dbgs() << "Swap bundle:"; MBB.dump());
  return true;
}

static void removeInst(llvm::MachineInstr &MI) {
  if (MI.isInsideBundle())
    MI.eraseFromBundle();
  else
    MI.eraseFromParent();
}

static bool expandREADYp(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                         MachineInstr &MI) {
  auto MII = MI.getIterator();
  LLVM_DEBUG(dbgs() << "Expanding in expandREADYp: "; MI.dump());

  int NumOperands = MI.getNumOperands();

  MachineFunction *MF = MBB.getParent();
  const KVXRegisterInfo *TRI =
      (const KVXRegisterInfo *)MF->getSubtarget().getRegisterInfo();
  SmallVector<Register, 4> OutRegs;
  for (int I = 1; I < NumOperands; I++) {
    MachineOperand &InRegOp = MI.getOperand(I);
    if (!InRegOp.isReg())
      report_fatal_error("Operands of READYp must be registers");
    Register InReg = InRegOp.getReg();
    if (KVX::SingleRegRegClass.contains(InReg))
      OutRegs.push_back(InReg);
    else if (KVX::PairedRegRegClass.contains(InReg) ||
             KVX::QuadRegRegClass.contains(InReg))
      OutRegs.push_back(TRI->getSubReg(InReg, KVX::sub_d0));
    else
      report_fatal_error(
          "Operands of READYp must be either SingleReg, PairedReg or QuadReg");
  }

  if ((NumOperands - 1) % 2 == 1)
    OutRegs.push_back(OutRegs[0]);

  if (!MI.getOperand(0).isReg())
    report_fatal_error("Output of READYp must be a register");
  DebugLoc DL = MI.getDebugLoc();
  BuildMI(MBB, MII, DL, TII->get(KVX::ORDrr), MI.getOperand(0).getReg())
      .addReg(OutRegs[0])
      .addReg(OutRegs[1]);
  if (NumOperands > 3)
    BuildMI(MBB, MII, DL, TII->get(KVX::ORDrr), MI.getOperand(0).getReg())
        .addReg(OutRegs[2])
        .addReg(OutRegs[3]);

  // Remove the original pseudo instruction
  removeInst(MI);

  return true;
}

static Register getRegOrFail(MachineOperand &MO, StringRef ErrorMsg) {
  if (!MO.isReg())
    report_fatal_error(ErrorMsg);
  return MO.getReg();
}

static int64_t getImmOrFail(MachineOperand &MO, StringRef ErrorMsg) {
  if (!MO.isImm())
    report_fatal_error(ErrorMsg);
  return MO.getImm();
}

static bool expandSTOREp(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                         MachineInstr &MI) {
  auto MII = MI.getIterator();
  LLVM_DEBUG(dbgs() << "Expanding in expandSTOREp: "; MI.dump());

  if (MI.getNumOperands() < 3)
    report_fatal_error("At least 3 operands expected for STOREp");

  Register Ptr =
      getRegOrFail(MI.getOperand(0), "Operand 0 of STOREp must be a register");
  Register SV =
      getRegOrFail(MI.getOperand(1), "Operand 1 of STOREp must be a register");

  int64_t Size =
      getImmOrFail(MI.getOperand(2), "Operand 2 of STOREp must be an immediate"
                                     " (the size of the stored value)");

  unsigned IID;
  switch (Size) {
  case 8:
    IID = KVX::SBri10;
    break;
  case 16:
    IID = KVX::SHri10;
    break;
  case 32:
    IID = KVX::SWri10;
    break;
  case 64:
    IID = KVX::SDri10;
    break;
  case 128:
    IID = KVX::SQri10;
    break;
  case 256:
    IID = KVX::SOri10;
    break;
  default:
    report_fatal_error("Unhandled STOREp store-value size");
  }

  DebugLoc DL = MI.getDebugLoc();
  BuildMI(MBB, MII, DL, TII->get(IID)).addImm(0).addReg(Ptr).addReg(SV);

  // Remove the original pseudo instruction
  removeInst(MI);

  return true;
}

static bool expandSTORECp(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                          MachineInstr &MI) {
  auto MII = MI.getIterator();
  LLVM_DEBUG(dbgs() << "Expanding in expandSTORECp: "; MI.dump());

  Register Ptr =
      getRegOrFail(MI.getOperand(0), "Operand 0 of STORECp must be a register");
  Register SV =
      getRegOrFail(MI.getOperand(1), "Operand 1 of STORECp must be a register");

  int64_t Size =
      getImmOrFail(MI.getOperand(2), "Operand 2 of STORECp must be an immediate"
                                     " (the size of the stored value)");

  Register Cond =
      getRegOrFail(MI.getOperand(3), "Operand 3 of STORECp must be a register");
  int64_t ScalarcondMod =
      getImmOrFail(MI.getOperand(4),
                   "Operand 4 of STORECp must be an immediate (ScalarcondMod)");
  int64_t LsomaskMod =
      getImmOrFail(MI.getOperand(5),
                   "Operand 5 of STORECp must be an immediate (LsomaskMod)");

  if (ScalarcondMod >= 0 && LsomaskMod >= 0)
    report_fatal_error("ScalarcondMod and LsomaskMod cannot be both >= 0");
  bool HasLsomask = LsomaskMod >= 0;

  if (HasLsomask) {
    if (Size != 256)
      report_fatal_error(
          "LsomaskMod is only supported for 256-bit store value");
    if (!TII->getSubtarget().isV2())
      report_fatal_error("LsomaskMod is only supported on kv3-2");
  }

  unsigned IID;
  switch (Size) {
  case 8:
    IID = KVX::SBrrc;
    break;
  case 16:
    IID = KVX::SHrrc;
    break;
  case 32:
    IID = KVX::SWrrc;
    break;
  case 64:
    IID = KVX::SDrrc;
    break;
  case 128:
    IID = KVX::SQrrc;
    break;
  case 256:
    IID = HasLsomask ? KVX::SOrrm : KVX::SOrrc;
    break;
  }

  DebugLoc DL = MI.getDebugLoc();
  auto Mod = HasLsomask ? LsomaskMod : ScalarcondMod;
  BuildMI(MBB, MII, DL, TII->get(IID))
      .addReg(Ptr)
      .addReg(SV)
      .addImm(Mod)
      .addReg(Cond);

  // Remove the original pseudo instruction
  removeInst(MI);

  return true;
}

static bool expandLOADCup(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                          MachineInstr &MI) {
  auto MII = MI.getIterator();
  LLVM_DEBUG(dbgs() << "Expanding in expandLOADCup: "; MI.dump());

  constexpr unsigned InOpStart = 1;

  Register Ptr = getRegOrFail(MI.getOperand(InOpStart + 0),
                              "Input operand 0 of LOADCup must be a register");
  Register LV = getRegOrFail(MI.getOperand(InOpStart + 1),
                             "Input operand 1 of LOADCup must be a register");
  int64_t Size = getImmOrFail(MI.getOperand(InOpStart + 2),
                              "Input operand 2 of LOADCup must be an immediate "
                              "(the size of the loaded value)");
  Register Cond = getRegOrFail(MI.getOperand(InOpStart + 3),
                               "Input operand 3 of LOADCup must be a register");
  int64_t VariantMod = getImmOrFail(
      MI.getOperand(InOpStart + 4),
      "Input operand 4 of LOADCup must be an immediate (VariantMod)");
  int64_t ScalarcondMod = getImmOrFail(
      MI.getOperand(InOpStart + 5),
      "Input operand 5 of LOADCup must be an immediate (ScalarcondMod)");
  int64_t LsomaskMod = getImmOrFail(
      MI.getOperand(InOpStart + 6),
      "Input operand 6 of LOADCup must be an immediate (LsomaskMod)");

  if (ScalarcondMod >= 0 && LsomaskMod >= 0)
    report_fatal_error("ScalarcondMod and LsomaskMod cannot be both >= 0");
  bool HasLsomask = LsomaskMod >= 0;

  if (HasLsomask) {
    if (Size != 256)
      report_fatal_error(
          "LsomaskMod is only supported for 256-bit store value");
    if (!TII->getSubtarget().isV2())
      report_fatal_error("LsomaskMod is only supported on kv3-2");
  }

  unsigned IID;
  switch (Size) {
  case 8:
    IID = KVX::LBZrrc;
    break;
  case 16:
    IID = KVX::LHZrrc;
    break;
  case 32:
    IID = KVX::LWZrrc;
    break;
  case 64:
    IID = KVX::LDrrc;
    break;
  case 128:
    IID = KVX::LQrrc;
    break;
  case 256:
    IID = HasLsomask ? KVX::LOrrm : KVX::LOrrc;
    break;
  }

  DebugLoc DL = MI.getDebugLoc();
  auto CondOrMaskMod = HasLsomask ? LsomaskMod : ScalarcondMod;
  BuildMI(MBB, MII, DL, TII->get(IID), LV)
      .addReg(Ptr)
      .addImm(VariantMod)
      .addReg(LV)
      .addImm(CondOrMaskMod)
      .addReg(Cond);

  // Remove the original pseudo instruction
  removeInst(MI);

  return true;
}

static bool expandInBundle(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                           MachineBasicBlock::iterator MBBI) {
  auto I = MBBI->getIterator();
  auto E = MBBI->getParent()->instr_end();
  bool HasChanged = false;
  I++; // advance inside the bundle
  while (I != E && I->isInsideBundle()) {
    auto Next = std::next(I);
    if (I->isPseudo()) {
      switch (I->getOpcode()) {
      case KVX::XSWAP256p:
        return expandXSWAP256p(TII, MBB, MBBI);
      case KVX::READYp1r:
      case KVX::READYp2r:
      case KVX::READYp3r:
      case KVX::READYp4r:
        HasChanged |= expandREADYp(TII, MBB, *I);
        break;
      case KVX::STOREp:
      case KVX::STOREpv:
        HasChanged |= expandSTOREp(TII, MBB, *I);
        break;
      case KVX::STORECp:
      case KVX::STORECpv:
        HasChanged |= expandSTORECp(TII, MBB, *I);
        break;
      case KVX::LOADCup:
      case KVX::LOADCupv:
        HasChanged |= expandLOADCup(TII, MBB, *I);
        break;
      case KVX::SWAP64p:
        HasChanged |= expandSWAP64p(TII, MBB, MBBI);
        break;
      default:
        break;
      }
    }
    I = Next;
  }
  return HasChanged;
}

static bool expandSPCHECK(const KVXInstrInfo *TII, MachineBasicBlock &MBB,
                          MachineBasicBlock::iterator MBBI) {

  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();
  Register CheckReg = MI.getOperand(2).getReg();

  MachineFunction &MF = *MBB.getParent();

  auto *KVXFI = MF.getInfo<KVXMachineFunctionInfo>();
  MachineBasicBlock *OverflowMBB = KVXFI->getOverflowMBB();
  if (OverflowMBB == nullptr)
    report_fatal_error("call overflow mbb is missing");

  BuildMI(MBB, MBBI, DL, TII->get(KVX::CB))
      .addReg(CheckReg)
      .addMBB(OverflowMBB)
      .addImm(KVXMOD::SCALARCOND_DGTZ);

  MI.eraseFromParent();
  return true;
}

static bool expandWideMatrixLoadsStores(const KVXInstrInfo *TII,
                                        MachineBasicBlock &MBB,
                                        MachineBasicBlock::iterator MBBI,
                                        unsigned Ri10, unsigned Ri37,
                                        unsigned Ri64, bool IsStore = false) {
  LLVM_DEBUG(dbgs() << "Expanding: "; MBBI->dump());
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

  int End;
  if (KVX::MatrixRegRegClass.contains(InOutReg))
    End = 4;
  else if (KVX::WideRegRegClass.contains(InOutReg))
    End = 2;
  else
    report_fatal_error("Expanding a vector load that is not for wide or matrix "
                       "registers output.\n");

  LLVM_DEBUG(dbgs() << "It will require " << End << " lv operations\n");

  for (int C = 0, SubReg = KVX::sub_v0; C < End; C++, ++SubReg) {
    if (IsStore)
      BuildMI(MBB, MBBI, DL, TII->get(GetImmOpCode(Offset, Ri10, Ri37, Ri64)))
          .addImm(Offset)
          .addReg(Base)
          .addReg(InOutReg, VariantKill, SubReg);

    else
      BuildMI(MBB, MBBI, DL, TII->get(GetImmOpCode(Offset, Ri10, Ri37, Ri64)))
          .addReg(InOutReg, RegState::Define, SubReg)
          .addImm(Offset)
          .addReg(Base)
          .addImm(VariantKill);
    Offset += 32;
  }
  MI.eraseFromParent();
  return true;
}

bool KVXExpandPseudo::expandMI(MachineBasicBlock &MBB,
                               MachineBasicBlock::iterator MBBI,
                               MachineBasicBlock::iterator &NextMBBI) {
  LLVM_DEBUG(dbgs() << "Expanding pseudo: "; MBBI->dump());
  switch (MBBI->getOpcode()) {
  default:
    break;
  }

  if (Stage < KVX::PRE_SCHED2)
    return false;

  const auto &Subtarget = TII->getSubtarget();
  switch (MBBI->getOpcode()) {
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
  case KVX::ASWAPp:
    return expandASWAP(TII, MBB, MBBI, NextMBBI);
  case KVX::ATASp:
    return expandATAS(TII, MBB, MBBI, NextMBBI);
  case KVX::SBp:
    return expandStore(TII, MBB, MBBI, KVX::SBri10, KVX::SBri37, KVX::SBri64);
  case KVX::SHp:
    return expandStore(TII, MBB, MBBI, KVX::SHri10, KVX::SHri37, KVX::SHri64);
  case KVX::SWp:
    return expandStore(TII, MBB, MBBI, KVX::SWri10, KVX::SWri37, KVX::SWri64);
  case KVX::SDp:
    return expandStore(TII, MBB, MBBI, KVX::SDri10, KVX::SDri37, KVX::SDri64);
  case KVX::SQp:
    return expandStore(TII, MBB, MBBI, KVX::SQri10, KVX::SQri37, KVX::SQri64);
  case KVX::SOp:
    return expandStore(TII, MBB, MBBI, KVX::SOri10, KVX::SOri37, KVX::SOri64);
  case KVX::SVp:
    if (((const KVXSubtarget *)(&MBB.getParent()->getSubtarget()))->isV1())
      return expandStore(TII, MBB, MBBI, KVX::SVri10, KVX::SVri37, KVX::SVri64);
    return expandStore(TII, MBB, MBBI, KVX::XSOri10, KVX::XSOri37,
                       KVX::XSOri64);
  case KVX::SWIDEp:
  case KVX::SMATRIXp:
    if (((const KVXSubtarget *)(&MBB.getParent()->getSubtarget()))->isV1())
      return expandWideMatrixLoadsStores(TII, MBB, MBBI, KVX::SVri10,
                                         KVX::SVri37, KVX::SVri64, true);
    return expandWideMatrixLoadsStores(TII, MBB, MBBI, KVX::XSOri10,
                                       KVX::XSOri37, KVX::XSOri64, true);
  case KVX::LBSp:
    return expandLoad(TII, MBB, MBBI, KVX::LBSri10, KVX::LBSri37, KVX::LBSri64);
  case KVX::LBZp:
    return expandLoad(TII, MBB, MBBI, KVX::LBZri10, KVX::LBZri37, KVX::LBZri64);
  case KVX::LHSp:
    return expandLoad(TII, MBB, MBBI, KVX::LHSri10, KVX::LHSri37, KVX::LHSri64);
  case KVX::LHZp:
    return expandLoad(TII, MBB, MBBI, KVX::LHZri10, KVX::LHZri37, KVX::LHZri64);
  case KVX::LWSp:
    return expandLoad(TII, MBB, MBBI, KVX::LWSri10, KVX::LWSri37, KVX::LWSri64);
  case KVX::LWZp:
    return expandLoad(TII, MBB, MBBI, KVX::LWZri10, KVX::LWZri37, KVX::LWZri64);
  case KVX::LDp:
    return expandLoad(TII, MBB, MBBI, KVX::LDri10, KVX::LDri37, KVX::LDri64);
  case KVX::LQp:
    return expandLoad(TII, MBB, MBBI, KVX::LQri10, KVX::LQri37, KVX::LQri64);
  case KVX::LOp:
    return expandLoad(TII, MBB, MBBI, KVX::LOri10, KVX::LOri37, KVX::LOri64);
  case KVX::LVp:
    if (Subtarget.isV1())
      return expandLoad(TII, MBB, MBBI, KVX::LVri10, KVX::LVri37, KVX::LVri64);
    return expandLoad(TII, MBB, MBBI, KVX::XLOri10, KVX::XLOri37, KVX::XLOri64);
  case KVX::LWIDEp:
  case KVX::LMATRIXp:
    if (Subtarget.isV1())
      return expandWideMatrixLoadsStores(TII, MBB, MBBI, KVX::LVri10,
                                         KVX::LVri37, KVX::LVri64, false);
    return expandWideMatrixLoadsStores(TII, MBB, MBBI, KVX::XLOri10,
                                       KVX::XLOri37, KVX::XLOri64, false);
  case KVX::EXTFZWp:
    return expandEXTFZ(TII, MBB, MBBI, true);
  case KVX::EXTFZDp:
    return expandEXTFZ(TII, MBB, MBBI, false);
  case KVX::SPCHECKp:
    return expandSPCHECK(TII, MBB, MBBI);
  case KVX::CONVDHV0p:
    return expandTcaInplace(TII, MBB, MBBI, KVX::sub_q0, KVX::CONVDHV0);
  case KVX::CONVDHV1p:
    return expandTcaInplace(TII, MBB, MBBI, KVX::sub_q1, KVX::CONVDHV1);
  case KVX::FMMA242HW0p:
    return expandTcaInplace(TII, MBB, MBBI, KVX::sub_q0, KVX::FMMA242HW0);
  case KVX::FMMA242HW1p:
    return expandTcaInplace(TII, MBB, MBBI, KVX::sub_q1, KVX::FMMA242HW1);
  case KVX::FMMA242HW2p:
    return expandTcaInplace(TII, MBB, MBBI, KVX::sub_q0, KVX::FMMA242HW2);
  case KVX::FMMA242HW3p:
    return expandTcaInplace(TII, MBB, MBBI, KVX::sub_q1, KVX::FMMA242HW3);
  case KVX::CONVWBV0p:
    return expandTcaInplace(TII, MBB, MBBI, KVX::sub_d0, KVX::CONVWBV0);
  case KVX::CONVWBV1p:
    return expandTcaInplace(TII, MBB, MBBI, KVX::sub_d1, KVX::CONVWBV1);
  case KVX::CONVWBV2p:
    return expandTcaInplace(TII, MBB, MBBI, KVX::sub_d2, KVX::CONVWBV2);
  case KVX::CONVWBV3p:
    return expandTcaInplace(TII, MBB, MBBI, KVX::sub_d3, KVX::CONVWBV3);
  case KVX::MOVETOHIp:
    return expandTcaInplace(TII, MBB, MBBI, KVX::sub_q1, KVX::MOVETQrrbo);
  case KVX::MOVETOLOp:
    return expandTcaInplace(TII, MBB, MBBI, KVX::sub_q0, KVX::MOVETQrrbe);
  case KVX::DINVALLp:
  case KVX::DTOUCHLp:
  case KVX::DZEROLp:
  case KVX::I1INVALSp:
    return expandCacheInstruction(TII, MBB, MBBI);
  default:
    break;
  }

  if (Stage < KVX::PRE_BUNDLE)
    return false;

  switch (MBBI->getOpcode()) {
  case KVX::ACMPSWAPp:
    return expandACMPSWAP(TII, MBB, MBBI, NextMBBI);
  case KVX::ENDLOOP:
    return expandENDLOOP(TII, MBB, MBBI);
  default:
    break;
  }

  if (Stage < KVX::PRE_EMIT)
    return false;

  switch (MBBI->getOpcode()) {
  case KVX::BUNDLE:
    return expandInBundle(TII, MBB, MBBI);
  case KVX::STOREp:
  case KVX::STOREpv:
    return expandSTOREp(TII, MBB, *MBBI);
  case KVX::STORECp:
  case KVX::STORECpv:
    return expandSTORECp(TII, MBB, *MBBI);
  case KVX::LOADCup:
  case KVX::LOADCupv:
    return expandLOADCup(TII, MBB, *MBBI);
  case KVX::READYp1r:
  case KVX::READYp2r:
  case KVX::READYp3r:
  case KVX::READYp4r:
    return expandREADYp(TII, MBB, *MBBI);
  case KVX::SWAP64p:
    return expandSWAP64p(TII, MBB, MBBI);
  case KVX::XSWAP256p:
    return expandXSWAP256p(TII, MBB, MBBI);
  // Must expand LOOPDO_END label to add NOP if last bundle is a branch
  // instruction. This is done after PRE_EMIT when all CFG optimizations have
  // been run.
  case TargetOpcode::EH_LABEL: {
    if (MBBI->getOperand(0).getMCSymbol()->getName().contains(".__LOOPDO_")) {
      return prefixLoopEndWithNop(TII, MBB, MBBI);
    }
    return false;
  }
  default:
    return false;
  }
}

} // end of anonymous namespace

INITIALIZE_PASS(KVXExpandPseudo, "kvx-preemit-expand-pseudo",
                KVX_PREEMIT_EXPAND_PSEUDO_NAME, false, false)
namespace llvm {

FunctionPass *createKVXExpandPseudoPass(KVX::STAGE S) {
  return new KVXExpandPseudo(S);
}

} // end of namespace llvm
