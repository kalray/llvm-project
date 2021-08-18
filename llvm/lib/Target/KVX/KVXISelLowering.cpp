//===-- KVXISelLowering.cpp - KVX DAG Lowering Implementation  ------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the KVXTargetLowering class.
//
//===----------------------------------------------------------------------===//

#include "KVXISelLowering.h"
#include "KVX.h"
#include "KVXMachineFunctionInfo.h"
#include "KVXTargetMachine.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/CodeGen/CallingConvLower.h"
#include "llvm/Support/KnownBits.h"

using namespace llvm;

#define DEBUG_TYPE "KVXISelLowering"

STATISTIC(NumTailCalls, "Number of tail calls");

static cl::opt<int> MinimumJumpTablesEntries(
    "kvx-minimum-jump-tables-entries", cl::Hidden, cl::ZeroOrMore, cl::init(5),
    cl::desc("Set minimum jump tables entries count."));

#include "KVXGenCallingConv.inc"

static bool CC_SRET_KVX(unsigned ValNo, MVT ValVT, MVT LocVT,
                        CCValAssign::LocInfo LocInfo, ISD::ArgFlagsTy ArgFlags,
                        CCState &State) {
  if (ArgFlags.isSRet()) {
    if (unsigned Reg = State.AllocateReg(KVX::R15)) {
      State.addLoc(CCValAssign::getReg(ValNo, ValVT, Reg, LocVT, LocInfo));
      return false;
    }
    return true;
  }

  return CC_KVX(ValNo, ValVT, LocVT, LocInfo, ArgFlags, State);
}

KVXTargetLowering::KVXTargetLowering(const TargetMachine &TM,
                                     const KVXSubtarget &STI)
    : TargetLowering(TM), Subtarget(STI) {
  setBooleanContents(ZeroOrOneBooleanContent);

  if (!STI.isV1())
    setBooleanVectorContents(ZeroOrNegativeOneBooleanContent);

  (void)Subtarget;
  // set up the register classes
  addRegisterClass(MVT::i32, &KVX::SingleRegRegClass);
  addRegisterClass(MVT::i64, &KVX::SingleRegRegClass);
  addRegisterClass(MVT::v2i8, &KVX::SingleRegRegClass);
  addRegisterClass(MVT::v2i16, &KVX::SingleRegRegClass);
  addRegisterClass(MVT::v2i32, &KVX::SingleRegRegClass);
  addRegisterClass(MVT::v2i64, &KVX::PairedRegRegClass);
  addRegisterClass(MVT::v4i8, &KVX::SingleRegRegClass);
  addRegisterClass(MVT::v4i16, &KVX::SingleRegRegClass);
  addRegisterClass(MVT::v4i32, &KVX::PairedRegRegClass);
  addRegisterClass(MVT::v4i64, &KVX::QuadRegRegClass);
  addRegisterClass(MVT::v8i8, &KVX::SingleRegRegClass);

  addRegisterClass(MVT::f16, &KVX::SingleRegRegClass);
  addRegisterClass(MVT::f32, &KVX::SingleRegRegClass);
  addRegisterClass(MVT::f64, &KVX::SingleRegRegClass);
  addRegisterClass(MVT::v2f16, &KVX::SingleRegRegClass);
  addRegisterClass(MVT::v2f32, &KVX::SingleRegRegClass);
  addRegisterClass(MVT::v2f64, &KVX::PairedRegRegClass);
  addRegisterClass(MVT::v4f16, &KVX::SingleRegRegClass);
  addRegisterClass(MVT::v4f32, &KVX::PairedRegRegClass);
  addRegisterClass(MVT::v4f64, &KVX::QuadRegRegClass);
  initializeTCARegisters();

  // Compute derived properties from the register classes
  computeRegisterProperties(STI.getRegisterInfo());

  setStackPointerRegisterToSaveRestore(getSPReg());

  setMinFunctionAlignment(Align(64));
  setPrefFunctionAlignment(Align(64));

  // TODO: VLIW allows better performances but not fully correct yet since
  // set/wfxm/wfxl builtins can be wrongly scheduled due to a SystemRegister
  // dependency issue, see T16482. Until we fix the VLIW scheduler to take into
  // account such kind of dependencies, a potential workaround could be to
  // switch back to VLIW by default and setting Source only when some assembly
  // inline is detected (since those builtins generate asm inline).
  setSchedulingPreference(Sched::Source);

  initializeTCALowering();

  setOperationAction(ISD::SDIV, MVT::i32, Promote);
  setOperationAction(ISD::SDIVREM, MVT::i32, Promote);
  setOperationAction(ISD::SREM, MVT::i32, Promote);
  setOperationAction(ISD::UDIV, MVT::i32, Promote);
  setOperationAction(ISD::UDIVREM, MVT::i32, Promote);
  setOperationAction(ISD::UREM, MVT::i32, Promote);

  setOperationAction(ISD::SDIV, MVT::i64, Expand);
  setOperationAction(ISD::SDIVREM, MVT::i64, Expand);
  setOperationAction(ISD::SREM, MVT::i64, Expand);
  setOperationAction(ISD::UDIV, MVT::i64, Expand);
  setOperationAction(ISD::UDIVREM, MVT::i64, Expand);
  setOperationAction(ISD::UREM, MVT::i64, Expand);

  setOperationAction(ISD::MULHU, MVT::v4i16, Custom);
  setOperationAction(ISD::MULHS, MVT::v4i16, Custom);
  setOperationAction(ISD::MULHU, MVT::v2i16, Custom);
  setOperationAction(ISD::MULHS, MVT::v2i16, Custom);
  setOperationAction(ISD::MULHU, MVT::v2i8, Custom);
  setOperationAction(ISD::MULHS, MVT::v2i8, Custom);
  setOperationAction(ISD::MULHU, MVT::v4i8, Custom);
  setOperationAction(ISD::MULHS, MVT::v4i8, Custom);
  setOperationAction(ISD::MULHU, MVT::v8i8, Custom);
  setOperationAction(ISD::MULHS, MVT::v8i8, Custom);

  setLoadExtAction(ISD::ZEXTLOAD, MVT::v2i16, MVT::v2i8, Expand);
  setLoadExtAction(ISD::EXTLOAD, MVT::v2i16, MVT::v2i8, Expand);
  setLoadExtAction(ISD::SEXTLOAD, MVT::v2i16, MVT::v2i8, Expand);

  setLoadExtAction(ISD::ZEXTLOAD, MVT::v2i32, MVT::v2i16, Expand);
  setLoadExtAction(ISD::EXTLOAD, MVT::v2i32, MVT::v2i16, Expand);
  setLoadExtAction(ISD::SEXTLOAD, MVT::v2i32, MVT::v2i16, Expand);

  setLoadExtAction(ISD::ZEXTLOAD, MVT::v2i32, MVT::v2i8, Expand);
  setLoadExtAction(ISD::EXTLOAD, MVT::v2i32, MVT::v2i8, Expand);
  setLoadExtAction(ISD::SEXTLOAD, MVT::v2i32, MVT::v2i8, Expand);

  setLoadExtAction(ISD::ZEXTLOAD, MVT::v4i16, MVT::v4i8, Expand);
  setLoadExtAction(ISD::EXTLOAD, MVT::v4i16, MVT::v4i8, Expand);
  setLoadExtAction(ISD::SEXTLOAD, MVT::v4i16, MVT::v4i8, Expand);

  setTruncStoreAction(MVT::v2i32, MVT::v2i16, Expand);
  setTruncStoreAction(MVT::v2i32, MVT::v2i8, Expand);
  setTruncStoreAction(MVT::v4i16, MVT::v4i8, Expand);
  setTruncStoreAction(MVT::v4i32, MVT::v4i16, Expand);
  setTruncStoreAction(MVT::v4i32, MVT::v4i8, Expand);

  setOperationAction(ISD::EXTRACT_SUBVECTOR, MVT::v2i16, Expand);
  setOperationAction(ISD::EXTRACT_SUBVECTOR, MVT::v2f16, Expand);

  setOperationAction(ISD::SIGN_EXTEND, MVT::v4i64, Expand);
  setOperationAction(ISD::ANY_EXTEND, MVT::v4i64, Expand);

  for (auto VT : {MVT::v4i32, MVT::v4i16, MVT::v2i16, MVT::v2i32, MVT::v2i64,
                  MVT::v4i64, MVT::v2i8, MVT::v4i8})
    setOperationAction(ISD::SIGN_EXTEND_INREG, VT, Expand);

  for (auto VT :
       {MVT::v2i8, MVT::v2f16, MVT::v2i16, MVT::v2i32, MVT::v2i64, MVT::v4i8,
        MVT::v4i16, MVT::v4f32, MVT::v4i32, MVT::v4i64, MVT::v8i8}) {
    setOperationAction(ISD::UDIV, VT, Expand);
    setOperationAction(ISD::SDIV, VT, Expand);
    // TODO: if one vector is undef and the type fits in a singleReg,
    // using sbmm8 might be profitable.
    setOperationAction(ISD::VECTOR_SHUFFLE, VT, Expand);
    // TODO: add tests for why we need to expand SCALAR_TO_VECTOR
    setOperationAction(ISD::SCALAR_TO_VECTOR, VT, Expand);

    setOperationAction(ISD::SDIVREM, VT, Expand);
    setOperationAction(ISD::SREM, VT, Expand);
    setOperationAction(ISD::UDIVREM, VT, Expand);
    setOperationAction(ISD::UREM, VT, Expand);

    setOperationAction(ISD::ROTL, VT, Expand);
    setOperationAction(ISD::ROTR, VT, Expand);
  }
  setOperationAction(ISD::ROTL, MVT::v2i32, Legal);
  setOperationAction(ISD::ROTR, MVT::v2i32, Legal);

  for (auto VT : {MVT::i8, MVT::i32, MVT::i64, MVT::v2i8, MVT::v2i16,
                  MVT::v2i32, MVT::v4i8, MVT::v4i16, MVT::v8i8})
    setOperationAction(ISD::BITREVERSE, VT, Legal);

  for (auto VT : {MVT::v2i8, MVT::v4i8, MVT::v8i8, MVT::v2i16, MVT::v4i16,
                  MVT::v4i32, MVT::v2i64, MVT::v4i64}) {
    setOperationAction(ISD::CTTZ, VT, Expand);
    setOperationAction(ISD::CTLZ, VT, Expand);
    setOperationAction(ISD::CTPOP, VT, Expand);
  }

  for (auto VT :
       {MVT::v4i64, MVT::v2i64, MVT::v4i32, MVT::v8i8, MVT::v2i8, MVT::v4i8}) {
    setOperationAction(ISD::SHL, VT, Expand);
    setOperationAction(ISD::SRL, VT, Expand);
    setOperationAction(ISD::SRA, VT, Expand);
  }

  for (auto VT : {MVT::v2f64, MVT::v2i64, MVT::v4f64, MVT::v4i64, MVT::v8i8})
    setOperationAction(ISD::SETCC, VT, Expand);

  for (auto VT : {MVT::v4i32, MVT::v4f32})
    setOperationAction(ISD::BUILD_VECTOR, VT, Custom);

  for (auto VT : {MVT::v2i16, MVT::v4i16, MVT::v2i32, MVT::v2i64, MVT::v4i32,
                  MVT::v2i8, MVT::v4i8, MVT::v8i8, MVT::v2f16, MVT::v4f16,
                  MVT::v2f32, MVT::v4f32, MVT::v2f64, MVT::v4f64, MVT::v4i64}) {
    setOperationAction(ISD::INSERT_VECTOR_ELT, VT, Custom);
    setOperationAction(ISD::EXTRACT_VECTOR_ELT, VT, Custom);
    setOperationAction(ISD::CONCAT_VECTORS, VT, Custom);
  }


  for (auto VT : {MVT::v2i8, MVT::v2f64,MVT::v2i64,
                  MVT::v4i8, MVT::v4f64, MVT::v4i64,
                  MVT::v8i8})

    setOperationAction(ISD::VSELECT, VT, Expand);

  setOperationAction(ISD::EXTRACT_SUBVECTOR, MVT::v2i32, Legal);

  setOperationAction(ISD::MULHU, MVT::v2i32, Expand);
  setOperationAction(ISD::MULHU, MVT::v2i64, Expand);
  setOperationAction(ISD::MULHU, MVT::v4i64, Expand);
  setOperationAction(ISD::MULHS, MVT::v2i32, Expand);
  setOperationAction(ISD::MULHS, MVT::v2i64, Expand);
  setOperationAction(ISD::MULHS, MVT::v4i64, Expand);
  setOperationAction(ISD::MULHU, MVT::v4i32, Expand);
  setOperationAction(ISD::MULHS, MVT::v4i32, Expand);

  for (auto VT : {MVT::v2f16, MVT::v2f32, MVT::v4f16, MVT::v4f32, MVT::v2f64,
                  MVT::v2i64, MVT::v4f64, MVT::v4i64}) {
    setOperationAction(ISD::VECTOR_SHUFFLE, VT, Expand);
    setOperationAction(ISD::SCALAR_TO_VECTOR, VT, Expand);
  }
  setOperationAction(ISD::FMUL, MVT::v4f64, Expand);
  setOperationAction(ISD::FMA, MVT::v4f64, Expand);

  for (auto VT : {MVT::v4f32, MVT::v2f64, MVT::v4f64})
    setOperationAction(ISD::FABS, VT, Expand);

  setOperationAction(ISD::SMUL_LOHI, MVT::v2i64, Expand);
  setOperationAction(ISD::UMUL_LOHI, MVT::v2i64, Expand);
  setOperationAction(ISD::SMUL_LOHI, MVT::v4i64, Expand);
  setOperationAction(ISD::UMUL_LOHI, MVT::v4i64, Expand);

  for (auto VT : {MVT::i32, MVT::i64}) {
    setOperationAction(ISD::SELECT_CC, VT, Expand);
    setOperationAction(ISD::BR_CC, VT, Custom);
  }
  setOperationAction(ISD::SMUL_LOHI, MVT::i64, Custom);
  setOperationAction(ISD::UMUL_LOHI, MVT::i64, Custom);

  setOperationAction(ISD::ROTL, MVT::i64, Expand);
  setOperationAction(ISD::ROTR, MVT::i64, Expand);

  setOperationAction(ISD::SHL_PARTS, MVT::i64, Expand);
  setOperationAction(ISD::SRL_PARTS, MVT::i64, Expand);
  setOperationAction(ISD::SRA_PARTS, MVT::i64, Expand);

  setOperationAction(ISD::BlockAddress, MVT::i64, Custom);
  setOperationAction(ISD::GlobalAddress, MVT::i64, Custom);
  setOperationAction(ISD::GlobalTLSAddress, MVT::i64, Custom);
  setOperationAction(ISD::VASTART, MVT::Other, Custom);
  setOperationAction(ISD::VAARG, MVT::Other, Custom);
  setOperationAction(ISD::VACOPY, MVT::Other, Expand);
  setOperationAction(ISD::VAEND, MVT::Other, Expand);

  setOperationAction(ISD::STACKSAVE, MVT::Other, Expand);
  setOperationAction(ISD::STACKRESTORE, MVT::Other, Expand);
  setOperationAction(ISD::DYNAMIC_STACKALLOC, MVT::i64, Expand);

  setOperationAction(ISD::BR_JT, MVT::Other, Expand);

  for (auto VT : { MVT::i32, MVT::i64 }) {
    setOperationAction(ISD::CTPOP, VT, Legal);
  }

  for (auto VT :
       {MVT::f16, MVT::f32, MVT::f64, MVT::v2f16, MVT::v2f32, MVT::v4f16}) {
    // Use hardware instructions f[min|max] for f[min|max]num iff -ffast-math
    // See: T14224.
    setOperationAction(ISD::FMINNUM, VT, Custom);
    setOperationAction(ISD::FMAXNUM, VT, Custom);
  }

  for (unsigned im = (unsigned)ISD::PRE_INC;
       im != (unsigned)ISD::LAST_INDEXED_MODE; ++im) {
    setIndexedLoadAction(im, MVT::i32, Legal);
    setIndexedStoreAction(im, MVT::i32, Legal);
  }

  for (auto VT : { MVT::f16, MVT::f32, MVT::f64 }) {
    setOperationAction(ISD::ConstantFP, VT, Legal);

    setOperationAction(ISD::FABS, VT, Legal);
    setOperationAction(ISD::BR_CC, VT, Expand);

    setOperationAction(ISD::FSUB, VT, Custom);
    setOperationAction(ISD::SELECT_CC, VT, Expand);
  }
  for (auto VT : {MVT::v2f16, MVT::v2f32, MVT::v4f16, MVT::v4f32, MVT::v2f64,
                  MVT::v2i64, MVT::v4f64, MVT::v4i64}) {
    setOperationAction(ISD::VECTOR_SHUFFLE, VT, Expand);
    setOperationAction(ISD::SCALAR_TO_VECTOR, VT, Expand);
  }

  for (auto VT : {MVT::v2f16, MVT::v2f32, MVT::v4f16, MVT::v4f32})
    setOperationAction(ISD::FCOPYSIGN, VT, Legal);

  for (auto VT : {MVT::f16, MVT::f32, MVT::f64, MVT::v2f16, MVT::v2f32,
                  MVT::v2f64, MVT::v4f16, MVT::v4f32, MVT::v4f64}) {
    auto Action = (VT == MVT::f16)
                      ? Promote
                      : ((VT > MVT::LAST_FP_VALUETYPE) ? Expand : LibCall);
    for (auto I :
         {ISD::FCEIL, ISD::FCOS, ISD::FDIV, ISD::FEXP, ISD::FEXP2, ISD::FFLOOR,
          ISD::FLOG, ISD::FLOG10, ISD::FLOG2, ISD::FNEARBYINT, ISD::FPOW,
          ISD::FPOWI, ISD::FREM, ISD::FRINT, ISD::FROUND, ISD::FSIN,
          ISD::FSINCOS, ISD::FSQRT, ISD::FTRUNC})
      setOperationAction(I, VT, Action);
  }

  setOperationAction(ISD::FDIV, MVT::f32, Custom);
  setOperationAction(ISD::FSQRT, MVT::f32, Custom);

  for (auto VT : {MVT::v2f16, MVT::v2f32, MVT::v2f64, MVT::v2i8, MVT::v2i16,
                  MVT::v2i32, MVT::v2i64, MVT::v4f16, MVT::v4f32, MVT::v4f64,
                  MVT::v4i8, MVT::v4i16, MVT::v4i32, MVT::v4i64, MVT::v8i8}) {
    setOperationAction(ISD::SELECT_CC, VT, Expand);
    setOperationAction(ISD::SELECT, VT, Legal);
  }

  for (auto VT : {MVT::v2i8, MVT::v4i8, MVT::v8i8}) {
    setOperationAction(ISD::FP_TO_SINT, VT, Expand);
    setOperationAction(ISD::FP_TO_UINT, VT, Expand);
  }

  setOperationAction(ISD::FP_TO_SINT, MVT::v8i8, Expand);
  setOperationAction(ISD::FP_TO_UINT, MVT::v8i8, Expand);

  for (auto VT : {MVT::v2i32, MVT::v2i64, MVT::v4i32, MVT::v4i64}) {
    setOperationAction(ISD::FP_TO_SINT, VT, Legal);
    setOperationAction(ISD::FP_TO_UINT, VT, Legal);
  }

  for (auto VT : {MVT::v2i64, MVT::v4i64, MVT::v8i8}) {
    setOperationAction(ISD::SINT_TO_FP, VT, Expand);
    setOperationAction(ISD::UINT_TO_FP, VT, Expand);
  }

  for (auto VT : {MVT::v2i32, MVT::v4i32}) {
    setOperationAction(ISD::SINT_TO_FP, VT, Custom);
    setOperationAction(ISD::UINT_TO_FP, VT, Custom);
  }

  setOperationAction(ISD::FP_ROUND, MVT::v2f32, Expand);
  setOperationAction(ISD::FP_ROUND, MVT::v4f32, Expand);

  setTruncStoreAction(MVT::v2i16, MVT::v2i8, Expand);
  setTruncStoreAction(MVT::v2i64, MVT::v2i8, Expand);
  setTruncStoreAction(MVT::v2i64, MVT::v2i16, Expand);
  setTruncStoreAction(MVT::v2f32, MVT::v2f16, Expand);
  setTruncStoreAction(MVT::v2i64, MVT::v2i32, Expand);

  setTruncStoreAction(MVT::v4i64, MVT::v4i8, Expand);
  setTruncStoreAction(MVT::v4i64, MVT::v4i16, Expand);
  setTruncStoreAction(MVT::v4i64, MVT::v4i32, Expand);

  setTruncStoreAction(MVT::v2f64, MVT::v2f16, Expand);
  setTruncStoreAction(MVT::v2f64, MVT::v2f32, Expand);
  setTruncStoreAction(MVT::v4f32, MVT::v4f16, Expand);
  setTruncStoreAction(MVT::v4f64, MVT::v4f16, Expand);
  setTruncStoreAction(MVT::v4f64, MVT::v4f32, Expand);

  for (auto VT : {MVT::i32, MVT::i64, MVT::v2i32, MVT::v2i16, MVT::v4i16}) {
    setOperationAction(ISD::SMIN, VT, Legal);
    setOperationAction(ISD::UMIN, VT, Legal);
    setOperationAction(ISD::SMAX, VT, Legal);
    setOperationAction(ISD::UMAX, VT, Legal);
    setOperationAction(ISD::ABS, VT, Legal);
  }

  for (auto VT : {MVT::v2i8, MVT::v4i8, MVT::v4i64}) {
    setOperationAction(ISD::SIGN_EXTEND, VT, Expand);
    setOperationAction(ISD::ZERO_EXTEND, VT, Expand);
    setOperationAction(ISD::ANY_EXTEND, VT, Expand);
  }

  setLoadExtAction(ISD::SEXTLOAD, MVT::v2i64, MVT::v2i8, Expand);
  setLoadExtAction(ISD::ZEXTLOAD, MVT::v2i64, MVT::v2i8, Expand);

  for (auto VT : {MVT::v4i8, MVT::v4i16, MVT::v4i32}) {
    setLoadExtAction(ISD::SEXTLOAD, MVT::v4i64, VT, Expand);
    setLoadExtAction(ISD::ZEXTLOAD, MVT::v4i64, VT, Expand);
  }

  setLoadExtAction(ISD::SEXTLOAD, MVT::v4i32, MVT::v4i8, Expand);
  setLoadExtAction(ISD::ZEXTLOAD, MVT::v4i32, MVT::v4i8, Expand);

  setLoadExtAction(ISD::EXTLOAD, MVT::v2f32, MVT::v2f16, Expand);
  setLoadExtAction(ISD::EXTLOAD, MVT::v2f64, MVT::v2f16, Expand);
  setLoadExtAction(ISD::EXTLOAD, MVT::v4f64, MVT::v4f16, Expand);

  setLoadExtAction(ISD::EXTLOAD, MVT::v4f32, MVT::v4f16, Expand);
  setLoadExtAction(ISD::EXTLOAD, MVT::v2f64, MVT::v2f32, Expand);
  setLoadExtAction(ISD::EXTLOAD, MVT::v4f64, MVT::v4f32, Expand);

  setOperationAction(ISD::JumpTable, MVT::i64, Custom);

  for (MVT VT : MVT::fp_valuetypes()) {
    setLoadExtAction(ISD::EXTLOAD, VT, MVT::f16, Expand);
    setLoadExtAction(ISD::EXTLOAD, VT, MVT::f32, Expand);
    setLoadExtAction(ISD::EXTLOAD, VT, MVT::f64, Expand);
  }

  for (auto I : {ISD::FP_TO_SINT, ISD::FP_TO_UINT, ISD::SINT_TO_FP,
                 ISD::UINT_TO_FP, ISD::CTPOP}) {
    setOperationPromotedToType(I, MVT::v2i16, MVT::v2i32);
    setOperationPromotedToType(I, MVT::v4i16, MVT::v4i32);
  }
  setOperationAction(ISD::CTPOP, MVT::v4i32, Legal);

  for (auto I : {ISD::ABS, ISD::ADD, ISD::FP_TO_SINT, ISD::FP_TO_UINT, ISD::MUL,
                 ISD::SETCC, ISD::SINT_TO_FP, ISD::SMAX, ISD::SMIN, ISD::SUB,
                 ISD::UINT_TO_FP, ISD::UMAX, ISD::UMIN, ISD::VSELECT}) {
    setOperationPromotedToType(I, MVT::v2i8, MVT::v2i16);
    setOperationPromotedToType(I, MVT::v4i8, MVT::v4i16);
    setOperationPromotedToType(I, MVT::v8i8, MVT::v8i16);
  }

  for (auto I : {ISD::ABS, ISD::ADD, ISD::SUB})
    setOperationAction(I, MVT::v8i8, Legal);

  for (auto VT : {MVT::v2i64, MVT::v4i32, MVT::v4i64})
    for (auto I : {ISD::AND, ISD::OR, ISD::XOR, ISD::ADD, ISD::SUB, ISD::MUL})
      setOperationAction(I, VT, Expand);

  for (auto VT : {MVT::v2i32, MVT::v4i32})
    for (auto I : {ISD::ADD, ISD::MUL, ISD::SUB})
      setOperationAction(I, VT, Legal);

  setOperationAction(ISD::ADD, MVT::v2i64, Custom);
  setOperationAction(ISD::SUB, MVT::v2i64, Custom);
  setOperationAction(ISD::ATOMIC_FENCE, MVT::Other, Custom);
  // NOTE: We could use ACSWAPW instruction with some shifts and masks to
  // support custom lowering of i8 and i16 operations. See ASWAPp for i8.
  for (auto VT : {MVT::i32, MVT::i64}) {
    setOperationAction(ISD::ATOMIC_LOAD_ADD, VT, Custom);
    setOperationAction(ISD::ATOMIC_LOAD_SUB, VT, Custom);
    setOperationAction(ISD::ATOMIC_LOAD_AND, VT, Custom);
    setOperationAction(ISD::ATOMIC_LOAD_CLR, VT, Custom);
    setOperationAction(ISD::ATOMIC_LOAD_OR, VT, Custom);
    setOperationAction(ISD::ATOMIC_LOAD_XOR, VT, Custom);
    setOperationAction(ISD::ATOMIC_LOAD_NAND, VT, Custom);
    setOperationAction(ISD::ATOMIC_LOAD_MIN, VT, Custom);
    setOperationAction(ISD::ATOMIC_LOAD_MAX, VT, Custom);
    setOperationAction(ISD::ATOMIC_LOAD_UMIN, VT, Custom);
    setOperationAction(ISD::ATOMIC_LOAD_UMAX, VT, Custom);
    // ATOMIC_SWAP is and AtomicRMW operation with XCHG operator.
    setOperationAction(ISD::ATOMIC_SWAP, VT, Custom);
  }

  for (auto VT : {MVT::v8f32, MVT::v8i32, MVT::v16f16, MVT::v16i16, MVT::v32i8,
                  MVT::v8f16, MVT::v8i16, MVT::v16i8})
    setOperationAction(ISD::LOAD, VT, Custom);

  setMaxAtomicSizeInBitsSupported(64);
  setMinCmpXchgSizeInBits(32);

  setMinimumJumpTableEntries(MinimumJumpTablesEntries);

  setOperationAction(ISD::UINT_TO_FP, MVT::i64, Custom);
  setOperationAction(ISD::SINT_TO_FP, MVT::i64, Custom);

  setOperationAction(ISD::ADDRSPACECAST, MVT::i64, Custom);
  setOperationAction(ISD::DYNAMIC_STACKALLOC, MVT::i64,
                     hasStackLimitRegister() ? Custom : Expand);

  for (auto I : {MVT::v2i16, MVT::v4i16, MVT::i32, MVT::v2i32, MVT::i64})
    setOperationAction(ISD::SADDSAT, I, Legal);

  setTargetDAGCombine(ISD::MUL);
  setTargetDAGCombine(ISD::SRA);
  setTargetDAGCombine(ISD::STORE);
  setTargetDAGCombine(ISD::ZERO_EXTEND);
}

EVT KVXTargetLowering::getSetCCResultType(const DataLayout &DL, LLVMContext &C,
                                          EVT VT) const {
  if (!VT.isVector())
    return MVT::i32;
  return EVT::getVectorVT(
      C, VT.getIntegerVT(C, VT.getVectorElementType().getSizeInBits()),
      VT.getVectorNumElements());
}

const char *KVXTargetLowering::getTargetNodeName(unsigned Opcode) const {
  switch (Opcode) {
  case KVXISD::RET:
    return "KVX::RET";
  case KVXISD::CALL:
    return "KVX::CALL";
  case KVXISD::AddrWrapper:
    return "KVX::AddrWrapper";
  case KVXISD::PICInternIndirection:
    return "KVX::PICInternIndirection";
  case KVXISD::PICExternIndirection:
    return "KVX::PICExternIndirection";
  case KVXISD::PICPCRelativeGOTAddr:
    return "KVX::PICPCRelativeGOTAddr";
  case KVXISD::TAIL:
    return "KVX::TAIL";
  case KVXISD::GetSystemReg:
    return "KVX::GetSystemReg";
  case KVXISD::COMP:
    return "KVX::COMP";
  case KVXISD::BRCOND:
    return "KVX::BRCOND";
  case KVXISD::FENCE:
    return "KVX::FENCE";
  case KVXISD::SEXT_MUL:
    return "KVX::SEXT_MUL";
  case KVXISD::SZEXT_MUL:
    return "KVX::SZEXT_MUL";
  case KVXISD::ZEXT_MUL:
    return "KVX::ZEXT_MUL";

  default:
    return NULL;
  }
}

MVT KVXTargetLowering::getRegisterTypeForCallingConv(LLVMContext &Context,
                                                     CallingConv::ID CC,
                                                     EVT VT) const {
  const TargetRegisterInfo *TRI = Subtarget.getRegisterInfo();
  unsigned RegSize = TRI->getRegSizeInBits(KVX::SingleRegRegClass);
  unsigned ScalarSize = VT.getScalarSizeInBits();

  if (VT.isVector() && VT.getSizeInBits() > RegSize && ScalarSize <= RegSize) {
    return ScalarSize == RegSize
               ? VT.getVectorElementType().getSimpleVT()
               : MVT::getVectorVT(VT.getVectorElementType().getSimpleVT(),
                                  RegSize / ScalarSize);
  }

  return TargetLowering::getRegisterTypeForCallingConv(Context, CC, VT);
}

unsigned KVXTargetLowering::getNumRegistersForCallingConv(LLVMContext &Context,
                                                          CallingConv::ID CC,
                                                          EVT VT) const {
  const TargetRegisterInfo *TRI = Subtarget.getRegisterInfo();
  unsigned RegSize = TRI->getRegSizeInBits(KVX::SingleRegRegClass);

  if (VT.isVector() && VT.getSizeInBits() > RegSize &&
      VT.getScalarSizeInBits() <= RegSize)
    return (VT.getSizeInBits() + RegSize - 1) / RegSize;

  return TargetLowering::getNumRegistersForCallingConv(Context, CC, VT);
}

unsigned KVXTargetLowering::getVectorTypeBreakdownForCallingConv(
    LLVMContext &Context, CallingConv::ID CC, EVT VT, EVT &IntermediateVT,
    unsigned &NumIntermediates, MVT &RegisterVT) const {

  const TargetRegisterInfo *TRI = Subtarget.getRegisterInfo();
  unsigned RegSize = TRI->getRegSizeInBits(KVX::SingleRegRegClass);

  if (VT.isVector() && VT.getSizeInBits() > RegSize &&
      VT.getScalarSizeInBits() <= RegSize) {
    RegisterVT =
        KVXTargetLowering::getRegisterTypeForCallingConv(Context, CC, VT);
    IntermediateVT = RegisterVT;
    NumIntermediates =
        KVXTargetLowering::getNumRegistersForCallingConv(Context, CC, VT);

    return NumIntermediates;
  }

  return TargetLowering::getVectorTypeBreakdownForCallingConv(
      Context, CC, VT, IntermediateVT, NumIntermediates, RegisterVT);
}

bool KVXTargetLowering::CanLowerReturn(
    CallingConv::ID CallConv, MachineFunction &MF, bool IsVarArg,
    const SmallVectorImpl<ISD::OutputArg> &Outs, LLVMContext &Context) const {

  return true;
}

SDValue
KVXTargetLowering::LowerReturn(SDValue Chain, CallingConv::ID CallConv,
                               bool IsVarArg,
                               const SmallVectorImpl<ISD::OutputArg> &Outs,
                               const SmallVectorImpl<SDValue> &OutVals,
                               const SDLoc &DL, SelectionDAG &DAG) const {

  SmallVector<CCValAssign, 16> RVLocs;

  CCState CCInfo(CallConv, IsVarArg, DAG.getMachineFunction(), RVLocs,
                 *DAG.getContext());

  CCInfo.AnalyzeReturn(Outs, RetCC_KVX);

  SDValue Flag;
  SmallVector<SDValue, 4> RetOps(1, Chain);

  for (unsigned int i = 0; i != RVLocs.size(); ++i) {
    CCValAssign &VA = RVLocs[i];
    assert(VA.isRegLoc() && "Can only return in registers!");
    SDValue Arg = OutVals[i];
    Chain = DAG.getCopyToReg(Chain, DL, VA.getLocReg(), Arg, Flag);
    Flag = Chain.getValue(1);
    RetOps.push_back(DAG.getRegister(VA.getLocReg(), VA.getLocVT()));
  }

  MachineFunction &MF = DAG.getMachineFunction();
  KVXMachineFunctionInfo *KVXFI = MF.getInfo<KVXMachineFunctionInfo>();

  if (MF.getFunction().hasStructRetAttr()) {
    auto PtrVT = getPointerTy(DAG.getDataLayout());
    SDValue Val = DAG.getCopyFromReg(Chain, DL, KVXFI->getSRETReg(), PtrVT);
    Chain = DAG.getCopyToReg(Chain, DL, KVX::R0, Val, Flag);
    Flag = Chain.getValue(1);
    RetOps.push_back(DAG.getRegister(KVX::R0, PtrVT));
  }

  RetOps[0] = Chain; // Update chain.

  // Add the glue if we have it.
  if (Flag.getNode())
    RetOps.push_back(Flag);

  return DAG.getNode(KVXISD::RET, DL, MVT::Other, RetOps);
}

static const MCPhysReg ArgGPRs[] = { KVX::R0, KVX::R1, KVX::R2,  KVX::R3,
                                     KVX::R4, KVX::R5, KVX::R6,  KVX::R7,
                                     KVX::R8, KVX::R9, KVX::R10, KVX::R11 };

SDValue KVXTargetLowering::LowerFormalArguments(
    SDValue Chain, CallingConv::ID CallConv, bool IsVarArg,
    const SmallVectorImpl<ISD::InputArg> &Ins, const SDLoc &DL,
    SelectionDAG &DAG, SmallVectorImpl<SDValue> &InVals) const {

  switch (CallConv) {
  default:
    report_fatal_error("Unsupported calling convention");
  case CallingConv::C:
  case CallingConv::Fast:
  case CallingConv::SPIR_KERNEL:
    break;
  }

  MachineFunction &MF = DAG.getMachineFunction();
  MachineRegisterInfo &RegInfo = MF.getRegInfo();
  std::vector<SDValue> OutChains;

  SmallVector<CCValAssign, 16> ArgLocs;
  CCState CCInfo(CallConv, IsVarArg, DAG.getMachineFunction(), ArgLocs,
                 *DAG.getContext());
  CCInfo.AnalyzeFormalArguments(Ins, CC_SRET_KVX);

  unsigned MemArgsSaveSize = 0;
  unsigned InIdx = 0;
  KVXMachineFunctionInfo *KVXFI = MF.getInfo<KVXMachineFunctionInfo>();

  for (auto &VA : ArgLocs) {
    if (VA.isRegLoc()) {
      EVT RegVT = VA.getLocVT();

      unsigned VReg;
      VReg = RegInfo.createVirtualRegister(&KVX::SingleRegRegClass);

      if (Ins[InIdx].Flags.isSRet())
        KVXFI->setSRETReg(VReg);

      RegInfo.addLiveIn(VA.getLocReg(), VReg);
      SDValue ArgIn = DAG.getCopyFromReg(Chain, DL, VReg, RegVT);

      InVals.push_back(ArgIn);
      ++InIdx;
      continue;
    }

    assert(VA.isMemLoc());

    unsigned Offset = VA.getLocMemOffset();
    unsigned StoreSize = VA.getValVT().getStoreSize();
    int FI = MF.getFrameInfo().CreateFixedObject(StoreSize, Offset, false);
    InVals.push_back(
        DAG.getLoad(VA.getValVT(), DL, Chain,
                    DAG.getFrameIndex(FI, getPointerTy(MF.getDataLayout())),
                    MachinePointerInfo::getFixedStack(MF, FI)));

    MemArgsSaveSize += StoreSize;
  }

  if (IsVarArg) {
    ArrayRef<MCPhysReg> ArgRegs = makeArrayRef(ArgGPRs);
    unsigned Idx = CCInfo.getFirstUnallocated(ArgRegs);
    int VarArgsOffset = CCInfo.getNextStackOffset();
    int VarArgsSaveSize = 0;
    MachineFrameInfo &MFI = MF.getFrameInfo();
    const unsigned ArgRegsSize = ArgRegs.size();
    int FI;

    if (Idx >= ArgRegsSize) {
      FI = MFI.CreateFixedObject(8, VarArgsOffset, true);
      MemArgsSaveSize += 8;
    } else {
      FI = -(int)(MFI.getNumFixedObjects() + 1);
      VarArgsOffset = (Idx - ArgRegs.size()) * 8;
      VarArgsSaveSize = -VarArgsOffset;
    }

    KVXFI->setVarArgsFrameIndex(FI);
    KVXFI->setVarArgsSaveSize(VarArgsSaveSize);

    // Copy the integer registers that may have been used for passing varargs
    // to the vararg save area.
    for (unsigned I = Idx; I < ArgRegs.size(); ++I, VarArgsOffset += 8) {
      const Register Reg =
          RegInfo.createVirtualRegister(&KVX::SingleRegRegClass);
      RegInfo.addLiveIn(ArgRegs[I], Reg);
      SDValue ArgValue = DAG.getCopyFromReg(Chain, DL, Reg, MVT::i64);
      int FI = MFI.CreateFixedObject(8, VarArgsOffset, true);
      SDValue PtrOff = DAG.getFrameIndex(FI, getPointerTy(DAG.getDataLayout()));
      SDValue Store = DAG.getStore(Chain, DL, ArgValue, PtrOff,
                                   MachinePointerInfo::getFixedStack(MF, FI));
      OutChains.push_back(Store);
    }
  }

  KVXFI->setMemArgsSaveSize(MemArgsSaveSize);

  // All stores are grouped in one node to allow the matching between
  // the size of Ins and InVals. This only happens for vararg functions.
  if (!OutChains.empty()) {
    OutChains.push_back(Chain);
    Chain = DAG.getNode(ISD::TokenFactor, DL, MVT::Other, OutChains);
  }

  return Chain;
}

SDValue KVXTargetLowering::LowerCall(CallLoweringInfo &CLI,
                                     SmallVectorImpl<SDValue> &InVals) const {
  SelectionDAG &DAG = CLI.DAG;
  SDLoc &DL = CLI.DL;
  SmallVectorImpl<ISD::OutputArg> &Outs = CLI.Outs;
  SmallVectorImpl<SDValue> &OutVals = CLI.OutVals;
  SmallVectorImpl<ISD::InputArg> &Ins = CLI.Ins;
  SDValue Chain = CLI.Chain;
  SDValue Callee = CLI.Callee;
  bool &IsTailCall = CLI.IsTailCall;
  CallingConv::ID CallConv = CLI.CallConv;
  bool isVarArg = CLI.IsVarArg;
  EVT PtrVT = getPointerTy(DAG.getDataLayout());
  MachineFunction &MF = DAG.getMachineFunction();
  KVXMachineFunctionInfo *FuncInfo = MF.getInfo<KVXMachineFunctionInfo>();

  // Analyze operands of the call, assigning locations to each operand.
  SmallVector<CCValAssign, 16> ArgLocs;
  CCState CCInfo(CallConv, isVarArg, DAG.getMachineFunction(), ArgLocs,
                 *DAG.getContext());
  CCInfo.AnalyzeCallOperands(Outs, CC_SRET_KVX);

  if (IsTailCall)
    IsTailCall = IsEligibleForTailCallOptimization(CCInfo, CLI, MF, ArgLocs);

  if (IsTailCall)
    ++NumTailCalls;
  else if (CLI.CB && CLI.CB->isMustTailCall())
    report_fatal_error("failed to perform tail call elimination on a call"
                       "site marked musttail");

  // Get the size of the outgoing arguments stack space requirement.
  unsigned ArgsSize = CCInfo.getNextStackOffset();

  if (!IsTailCall)
    Chain = DAG.getCALLSEQ_START(Chain, ArgsSize, 0, DL);

  SmallVector<std::pair<unsigned, SDValue>, 8> RegsToPass;
  SmallVector<SDValue, 8> MemOpChains;
  SDValue StackPtr;

  for (unsigned i = 0, e = ArgLocs.size(); i != e; ++i) {
    CCValAssign &VA = ArgLocs[i];
    SDValue ArgValue = OutVals[i];

    if (VA.isRegLoc()) {
      // Queue up the argument copies and emit them at the end.
      RegsToPass.push_back(std::make_pair(VA.getLocReg(), ArgValue));
    } else {
      assert(VA.isMemLoc() && "Argument not register or memory");
      assert(!IsTailCall && "Tail call not allowed if stack is used "
                            "for passing parameters");

      // Work out the address of the stack slot.
      if (!StackPtr.getNode())
        StackPtr = DAG.getCopyFromReg(Chain, DL, getSPReg(), PtrVT);

      // Create a store off the stack pointer for this argument.
      SDValue PtrOff = DAG.getIntPtrConstant(VA.getLocMemOffset(), DL);
      PtrOff = DAG.getNode(ISD::ADD, DL, MVT::i64, StackPtr, PtrOff);
      MemOpChains.push_back(
          DAG.getStore(Chain, DL, ArgValue, PtrOff, MachinePointerInfo()));
    }
  }

  FuncInfo->setOutgoingArgsMaxSize(ArgsSize);

  // Join the stores, which are independent of one another.
  if (!MemOpChains.empty())
    Chain = DAG.getNode(ISD::TokenFactor, DL, MVT::Other, MemOpChains);

  SDValue Glue;

  // Build a sequence of copy-to-reg nodes, chained and glued together.
  for (auto &Reg : RegsToPass) {
    Chain = DAG.getCopyToReg(Chain, DL, Reg.first, Reg.second, Glue);
    Glue = Chain.getValue(1);
  }

  if (ExternalSymbolSDNode *S = dyn_cast<ExternalSymbolSDNode>(Callee)) {
    Callee = DAG.getTargetExternalSymbol(S->getSymbol(), PtrVT, 0);
  }

  SmallVector<SDValue, 8> Ops;
  Ops.push_back(Chain);
  Ops.push_back(Callee);
  for (auto &Reg : RegsToPass)
    Ops.push_back(DAG.getRegister(Reg.first, Reg.second.getValueType()));

  if (!IsTailCall) {
    // Add a register mask operand representing the call-preserved registers.
    const TargetRegisterInfo *TRI = Subtarget.getRegisterInfo();
    const uint32_t *Mask = TRI->getCallPreservedMask(MF, CallConv);
    assert(Mask && "Missing call preserved mask for calling convention");
    Ops.push_back(DAG.getRegisterMask(Mask));
  }

  // Glue the call to the argument copies, if any.
  if (Glue.getNode())
    Ops.push_back(Glue);

  // Emit the call.
  SDVTList NodeTys = DAG.getVTList(MVT::Other, MVT::Glue);

  if (IsTailCall) {
    MF.getFrameInfo().setHasTailCall();
    return DAG.getNode(KVXISD::TAIL, DL, NodeTys, Ops);
  }

  Chain = DAG.getNode(KVXISD::CALL, DL, NodeTys, Ops);
  Glue = Chain.getValue(1);

  // Mark the end of the call, which is glued to the call itself.
  Chain = DAG.getCALLSEQ_END(Chain, DAG.getConstant(ArgsSize, DL, PtrVT, true),
                             DAG.getConstant(0, DL, PtrVT, true), Glue, DL);
  Glue = Chain.getValue(1);

  // Assign locations to each value returned by this call.
  SmallVector<CCValAssign, 16> RVLocs;
  CCState RetCCInfo(CallConv, CLI.IsVarArg, MF, RVLocs, *DAG.getContext());
  RetCCInfo.AnalyzeCallResult(Ins, RetCC_KVX);
  // analyzeInputArgs(MF, RetCCInfo, Ins, /*IsRet=*/true);

  // Copy all of the result registers out of their specified physreg.
  for (auto &VA : RVLocs) {
    // Copy the value out
    SDValue RetValue =
        DAG.getCopyFromReg(Chain, DL, VA.getLocReg(), VA.getLocVT(), Glue);
    // Glue the RetValue to the end of the call sequence
    Chain = RetValue.getValue(1);
    Glue = RetValue.getValue(2);

    InVals.push_back(RetValue);
  }

  return Chain;
}

// This expands the data type to the twice the size
static SDValue manualPromoteTruncOp(SDValue &Op, SelectionDAG &DAG,
                                    bool Uns = false) {
  EVT VT =
      Op->getValueType(0).widenVectorOrScalarElementType(*DAG.getContext());

  SmallVector<SDValue, 2> Ops;
  if (VT.isFloatingPoint())
    for (auto &Operand : Op->ops())
      Ops.push_back(DAG.getFPExtendOrRound(Operand, SDLoc(Operand), VT));
  else if (Uns)
    for (auto &Operand : Op->ops())
      Ops.push_back(DAG.getZExtOrTrunc(Operand, SDLoc(Operand), VT));
  else
    for (auto &Operand : Op->ops())
      Ops.push_back(DAG.getSExtOrTrunc(Operand, SDLoc(Operand), VT));
  SDValue Ext = DAG.getNode(Op->getOpcode(), SDLoc(Op), VT, Ops);
  if (VT.isFloatingPoint())
    return DAG.getFPExtendOrRound(Ext, SDLoc(Op), Op->getValueType(0));
  if (Uns)
    return DAG.getZExtOrTrunc(Ext, SDLoc(Op), Op->getValueType(0));
  return DAG.getSExtOrTrunc(Ext, SDLoc(Op), Op->getValueType(0));
}

SDValue KVXTargetLowering::LowerOperation(SDValue Op, SelectionDAG &DAG) const {
  switch (Op.getOpcode()) {
  default:
    report_fatal_error("unimplemented operand");
  case ISD::ADD: { // TODO: Add v4i64
    if (Op.getSimpleValueType() != MVT::v2i64)
      return SDValue();

    switch (Op.getOperand(0)->getOpcode()) {
    case KVXISD::SEXT_MUL:
    case KVXISD::ZEXT_MUL:
    case KVXISD::SZEXT_MUL:
      return Op;
    default:
      break;
    }

    switch (Op.getOperand(1)->getOpcode()) {
    case KVXISD::SEXT_MUL:
    case KVXISD::ZEXT_MUL:
    case KVXISD::SZEXT_MUL:
      return Op;
    default:
      return SDValue();
    }
  }

  case ISD::SUB: { // TODO: Add v4i64
    if (Op.getSimpleValueType() != MVT::v2i64)
      return SDValue();

    switch (Op.getOperand(1)->getOpcode()) {
    case KVXISD::SEXT_MUL:
    case KVXISD::ZEXT_MUL:
    case KVXISD::SZEXT_MUL:
      return Op;
    default:
      return SDValue();
    }
  }
  case ISD::RETURNADDR:
    return lowerRETURNADDR(Op, DAG);
  case ISD::GlobalAddress:
    return lowerGlobalAddress(Op, DAG);
  case ISD::GlobalTLSAddress:
    return lowerGlobalTLSAddress(Op, DAG);
  case ISD::VASTART:
    return lowerVASTART(Op, DAG);
  case ISD::VAARG:
    return lowerVAARG(Op, DAG);
  case ISD::FRAMEADDR:
    return lowerFRAMEADDR(Op, DAG);
  case ISD::FSUB:
    return lowerFSUB(Op, DAG);
  case ISD::MULHS:
    return lowerMULHVectorGeneric(Op, DAG, true);
  case ISD::MULHU:
    return lowerMULHVectorGeneric(Op, DAG, false);
  case ISD::BlockAddress:
    return lowerBlockAddress(Op, DAG);
  case ISD::BUILD_VECTOR:
    return lowerBUILD_VECTOR(Op, DAG);
  case ISD::INSERT_VECTOR_ELT:
    return lowerINSERT_VECTOR_ELT(Op, DAG);
  case ISD::EXTRACT_VECTOR_ELT:
    return lowerEXTRACT_VECTOR_ELT(Op, DAG);
  case ISD::CONCAT_VECTORS:
    return lowerCONCAT_VECTORS(Op, DAG);
  case ISD::BR_CC:
    return lowerBR_CC(Op, DAG);
  case ISD::JumpTable:
    return lowerJumpTable(Op, DAG);
  case ISD::UINT_TO_FP:
  case ISD::SINT_TO_FP:
    return lowerIntToFP(Op, DAG);
  case ISD::ATOMIC_FENCE:
    return lowerATOMIC_FENCE(Op, DAG);
  case ISD::ATOMIC_LOAD_ADD:
  case ISD::ATOMIC_LOAD_SUB:
  case ISD::ATOMIC_LOAD_AND:
  case ISD::ATOMIC_LOAD_CLR:
  case ISD::ATOMIC_LOAD_OR:
  case ISD::ATOMIC_LOAD_XOR:
  case ISD::ATOMIC_LOAD_NAND:
  case ISD::ATOMIC_LOAD_MIN:
  case ISD::ATOMIC_LOAD_MAX:
  case ISD::ATOMIC_LOAD_UMIN:
  case ISD::ATOMIC_LOAD_UMAX:
    // ATOMIC_SWAP can be seen as an ATOMIC_LOAD_XCHG.
  case ISD::ATOMIC_SWAP:
    return lowerATOMIC_LOAD_OP(Op, DAG);
  case ISD::ADDRSPACECAST:
    return lowerADDRSPACECAST(Op, DAG);
  case ISD::FDIV:
  case ISD::FSQRT:
    if (Op.getNode()->getFlags().hasAllowReciprocal())
      return Op;
    else
      return SDValue();
  case ISD::FMINNUM:
  case ISD::FMAXNUM: {
    if (Op.getNode()->getFlags().hasNoNaNs())
      return Op;

    switch (Op.getValueType().getSimpleVT().SimpleTy) {
    case MVT::f16:
    case MVT::v2f16:
    case MVT::v4f16:
      return manualPromoteTruncOp(Op, DAG);
    default:
      return SDValue();
    }
  }
  case ISD::DYNAMIC_STACKALLOC:
    return lowerStackCheckAlloca(Op, DAG);
  case ISD::STORE:
    return lowerSTORE(Op, DAG);
  case ISD::SMUL_LOHI:
  case ISD::UMUL_LOHI:
    return lowerMulExtend(Op.getOpcode(), Op, DAG);
  }
}

SDValue KVXTargetLowering::lowerMulExtend(const unsigned Opcode, SDValue Op,
                                          SelectionDAG &DAG) const {
  if (Op->getValueType(0).getSimpleVT() != MVT::i64)
    return SDValue();

  SDLoc Loc(Op);
  unsigned TargetInstruction = 0;
  SDValue Op1;
  if (Opcode == ISD::SMUL_LOHI) {
    if (auto *CN = dyn_cast<ConstantSDNode>(Op->getOperand(1))) {
      const APInt &AP = CN->getAPIntValue();
      unsigned NB = AP.getMinSignedBits();
      Op1 = DAG.getTargetConstant(AP.getSExtValue(), Loc, MVT::i64);
      TargetInstruction =
          GetImmOpCode(NB, KVX::MULDTri10, KVX::MULDTri37, KVX::MULDTri64);
    } else {
      TargetInstruction = KVX::MULDTrr;
      Op1 = Op.getOperand(1);
    }
  } else if (auto *CN = dyn_cast<ConstantSDNode>(Op->getOperand(1))) {
    const APInt &AP = CN->getAPIntValue();
    unsigned NB = AP.getMinSignedBits();
    Op1 = DAG.getTargetConstant(AP.getZExtValue(), Loc, MVT::i64);
    TargetInstruction =
        GetImmOpCode(NB, KVX::MULUDTri10, KVX::MULUDTri37, KVX::MULUDTri64);
  } else {
    TargetInstruction = KVX::MULUDTrr;
    Op1 = Op.getOperand(1);
  }

  SDValue MulExt =
      SDValue(DAG.getMachineNode(TargetInstruction, Loc, MVT::v2i64,
                                 Op.getOperand(0), Op1),
              0);
  SDValue SubIdx0 = DAG.getTargetConstant(KVX::sub_s0, Loc, MVT::i32);
  SDValue SubIdx1 = DAG.getTargetConstant(KVX::sub_s1, Loc, MVT::i32);
  SDValue Lo = SDValue(DAG.getMachineNode(TargetOpcode::EXTRACT_SUBREG, Loc,
                                          MVT::i64, {MulExt, SubIdx0}),
                       0);
  SDValue Hi = SDValue(DAG.getMachineNode(TargetOpcode::EXTRACT_SUBREG, Loc,
                                          MVT::i64, {MulExt, SubIdx1}),
                       0);
  DAG.ReplaceAllUsesOfValueWith(Op.getValue(0), Lo);
  DAG.ReplaceAllUsesOfValueWith(Op.getValue(1), Hi);
  return SDValue();
}

SDValue KVXTargetLowering::lowerSTORE(SDValue Op, SelectionDAG &DAG) const {
  SDValue STValue = Op->getOperand(1);
  auto VT = STValue.getSimpleValueType();
  if (!(VT == MVT::v512i1 || VT == MVT::v1024i1))
    return SDValue();

  SDValue Chain = Op.getOperand(0);
  int End = KVX::sub_v0 + (VT == MVT::v512i1 ? 1 : 3);
  auto Base = Op->getOperand(2).getValue(0);
  auto SDOffset = Op->getOperand(3);
  auto Offset = 0;
  SDLoc OffsetDL(SDOffset);
  if (!SDOffset->isUndef()) {
    if (auto *IntOffset = dyn_cast<ConstantSDNode>(SDOffset))
      Offset = IntOffset->getSExtValue();
    else
      Base = DAG.getNode(ISD::ADD, OffsetDL, Base.getValueType());
  }
  SDLoc DataDL(STValue);
  SDLoc StoreDL(Op);
  for (int Sub = KVX::sub_v0; Sub <= End; Sub++, Offset += 32) {
    SDValue SubIdx = DAG.getTargetConstant(Sub, DataDL, MVT::i32);
    SDValue NewOffset = DAG.getConstant(Offset, OffsetDL, MVT::i64);
    SDValue SubValue(DAG.getMachineNode(TargetOpcode::EXTRACT_SUBREG, DataDL,
                                        MVT::v256i1, {STValue, SubIdx}),
                     0);
    SDValue Ptr =
        DAG.getNode(ISD::ADD, OffsetDL, Base.getValueType(), {Base, NewOffset});
    Chain = DAG.getStore(Chain, StoreDL, SubValue, Ptr, MachinePointerInfo());
  }
  return Chain;
}

SDValue KVXTargetLowering::lowerStackCheckAlloca(SDValue Op,
                                                 SelectionDAG &DAG) const {
  SDValue Chain = Op.getOperand(0);
  SDValue Size = Op.getOperand(1);
  unsigned Align = cast<ConstantSDNode>(Op.getOperand(2))->getZExtValue();
  unsigned StackAlign = Subtarget.getFrameLowering()->getStackAlignment();
  EVT VT = Size->getValueType(0);
  SDLoc DL(Op);

  unsigned SPReg = getStackPointerRegisterToSaveRestore();

  SDValue SP = DAG.getCopyFromReg(Chain, DL, SPReg, VT);
  SDValue NewSP = DAG.getNode(ISD::SUB, DL, VT, SP, Size);
  if (Align > StackAlign)
    NewSP = DAG.getNode(ISD::AND, DL, VT, NewSP,
                        DAG.getConstant(-(uint64_t)Align, DL, VT));

  SDValue Limit = DAG.getCopyFromReg(Chain, DL, KVX::SR, VT);
  SDValue Check = DAG.getNode(ISD::SUB, DL, VT, Limit, NewSP);

  NewSP =
      SDValue(DAG.getMachineNode(KVX::SPCHECKp, DL, MVT::i64, NewSP, Check), 0);

  Chain = DAG.getCopyToReg(SP.getValue(1), DL, SPReg, NewSP);

  SDValue Ops[2] = {NewSP, Chain};
  return DAG.getMergeValues(Ops, DL);
}

bool KVXTargetLowering::shouldInsertFencesForAtomic(
    const Instruction *I) const {
  return isa<LoadInst>(I) || isa<StoreInst>(I) || isa<AtomicRMWInst>(I) ||
         isa<AtomicCmpXchgInst>(I);
}

Instruction *KVXTargetLowering::emitLeadingFence(IRBuilder<> &Builder,
                                                 Instruction *Inst,
                                                 AtomicOrdering Ord) const {
  unsigned AS;

  if (isa<LoadInst>(Inst))
    AS = static_cast<LoadInst *>(Inst)->getPointerAddressSpace();
  else if (isa<StoreInst>(Inst))
    AS = static_cast<StoreInst *>(Inst)->getPointerAddressSpace();
  else if (isa<AtomicRMWInst>(Inst))
    AS = static_cast<AtomicRMWInst *>(Inst)->getPointerAddressSpace();
  else if (isa<AtomicCmpXchgInst>(Inst))
    AS = static_cast<AtomicCmpXchgInst *>(Inst)->getPointerAddressSpace();
  else
    report_fatal_error("Unsupported atomic instruction");

  if (AS == 1) { // __global AS (opencl_global): emit a call to OS intrinsic.
    Module *M = Builder.GetInsertBlock()->getParent()->getParent();

    assert(M->getTargetTriple().find("cos") &&
           "This codegen is for ClusterOS only");

    FunctionCallee Fn = M->getOrInsertFunction(
        "__kvx_atomic_global_in", Type::getVoidTy(M->getContext()),
        Type::getInt32Ty(M->getContext()));

    CallInst *L2Bypass =
        Builder.CreateCall(Fn, Builder.getInt32((int)toCABI(Ord)));
    L2Bypass->setDebugLoc(Inst->getDebugLoc());

    return L2Bypass;
  } // Emit a fence.
  switch (toCABI(Ord)) {
  case AtomicOrderingCABI::relaxed:
  case AtomicOrderingCABI::release:
    return nullptr;
  case AtomicOrderingCABI::consume:
  case AtomicOrderingCABI::acquire:
  case AtomicOrderingCABI::acq_rel:
  case AtomicOrderingCABI::seq_cst:
    return Builder.CreateFence(Ord);
  }
}

Instruction *KVXTargetLowering::emitTrailingFence(IRBuilder<> &Builder,
                                                  Instruction *Inst,
                                                  AtomicOrdering Ord) const {
  unsigned AS;

  if (isa<LoadInst>(Inst))
    AS = static_cast<LoadInst *>(Inst)->getPointerAddressSpace();
  else if (isa<StoreInst>(Inst))
    AS = static_cast<StoreInst *>(Inst)->getPointerAddressSpace();
  else if (isa<AtomicRMWInst>(Inst))
    AS = static_cast<AtomicRMWInst *>(Inst)->getPointerAddressSpace();
  else if (isa<AtomicCmpXchgInst>(Inst)) {
    AS = static_cast<AtomicCmpXchgInst *>(Inst)->getPointerAddressSpace();
    // Ensure to use stronger ordering.
    Ord = static_cast<AtomicCmpXchgInst *>(Inst)->getSuccessOrdering();
  } else
    report_fatal_error("Unsupported atomic instruction");

  if (AS == 1) { // __global AS (opencl_global): emit a call to OS intrinsic.
    Module *M = Builder.GetInsertBlock()->getParent()->getParent();

    assert(M->getTargetTriple().find("cos") &&
           "This codegen is for ClusterOS only");

    FunctionCallee Fn = M->getOrInsertFunction(
        "__kvx_atomic_global_out", Type::getVoidTy(M->getContext()),
        Type::getInt32Ty(M->getContext()));

    CallInst *L2Bypass =
        Builder.CreateCall(Fn, Builder.getInt32((int)toCABI(Ord)));
    L2Bypass->setDebugLoc(Inst->getDebugLoc());

    return L2Bypass;
  } // Emit a fence.
  switch (toCABI(Ord)) {
  case AtomicOrderingCABI::relaxed:
  case AtomicOrderingCABI::acquire:
    return nullptr;
  case AtomicOrderingCABI::release:
  case AtomicOrderingCABI::acq_rel:
  case AtomicOrderingCABI::consume:
  case AtomicOrderingCABI::seq_cst:
    return Builder.CreateFence(Ord);
  }
}

bool KVXTargetLowering::isZExtFree(SDValue Val, EVT VT2) const {
  if (Val.getOpcode() == ISD::LOAD)
    return true; // KVX have a zero extended load for each data type.

  return false;
}

SDValue KVXTargetLowering::lowerRETURNADDR(SDValue Op,
                                           SelectionDAG &DAG) const {
  auto VT = getPointerTy(DAG.getDataLayout());
  SDLoc DL(Op);

  // This node takes one operand, the depth of the return address to return. A
  // depth of zero corresponds to the current function's return address, a depth
  // of one to the parent's return address, and so on.
  unsigned Depth = cast<ConstantSDNode>(Op.getOperand(0))->getZExtValue();
  if (Depth) {
    // Depth > 0 not supported yet
    report_fatal_error("Unsupported Depth for lowerRETURNADDR");
  }

  SDValue RAReg = DAG.getRegister(KVX::RA, VT);
  return DAG.getNode(KVXISD::GetSystemReg, DL, VT, RAReg);
}

SDValue KVXTargetLowering::lowerGlobalAddress(SDValue Op,
                                              SelectionDAG &DAG) const {
  LLVM_DEBUG(dbgs() << "== KVXTargetLowering::lowerGlobalAddress(Op, DAG)"
                    << '\n');
  LLVM_DEBUG(dbgs() << "Op: " << '\n'; Op.dump());
  LLVM_DEBUG(dbgs() << "DAG: " << '\n'; DAG.dump());

  SDLoc DL(Op);
  auto PtrVT = getPointerTy(DAG.getDataLayout());
  GlobalAddressSDNode *N = cast<GlobalAddressSDNode>(Op);
  const GlobalValue *GV = N->getGlobal();
  int64_t Offset = N->getOffset();
  SDValue Result;

  // -fPIC enabled
  if (isPositionIndependent()) {
    LLVM_DEBUG(dbgs() << "LT: " << GV->getLinkage()
                      << " isPrivate: " << GV->hasPrivateLinkage() << '\n');

    GlobalValue::LinkageTypes LT = GV->getLinkage();
    switch (LT) {
    case GlobalValue::ExternalWeakLinkage:
    case GlobalValue::LinkOnceODRLinkage:
    case GlobalValue::CommonLinkage:
    case GlobalValue::ExternalLinkage: {
      LLVM_DEBUG(dbgs() << "@got(sym)[gaddr]" << '\n');

      SDValue GlobalSymbol = DAG.getTargetGlobalAddress(GV, DL, PtrVT);

      // Indirect global symbol using GOT with
      // @got(GLOBALSYMBOL)[GOTADDR] asm macro.  Note: function
      // symbols don't need indirection since everything is handled by
      // the loader. Consequently, call indirections are ignored at
      // insn selection.
      SDValue DataPtr =
          DAG.getNode(KVXISD::PICExternIndirection, DL, PtrVT, GlobalSymbol);

      if (Offset != 0)
        Result = DAG.getNode(ISD::ADD, DL, PtrVT, DataPtr,
                             DAG.getConstant(Offset, DL, PtrVT));
      else
        Result = DataPtr;

    } break;
    case GlobalValue::InternalLinkage:
    case GlobalValue::PrivateLinkage: {
      LLVM_DEBUG(dbgs() << "@gotoff(sym)" << '\n');

      SDValue GlobalSymbol = DAG.getTargetGlobalAddress(GV, DL, PtrVT);
      SDValue GOTAddr = DAG.getNode(KVXISD::PICPCRelativeGOTAddr, DL, PtrVT);

      // Indirect global symbol using GOT with @gotoff(GLOBALSYMBOL)
      // asm macro.
      SDValue DataPtr = DAG.getNode(KVXISD::PICInternIndirection, DL, PtrVT,
                                    GOTAddr, GlobalSymbol);

      if (Offset != 0)
        Result = DAG.getNode(ISD::ADD, DL, PtrVT, DataPtr,
                             DAG.getConstant(Offset, DL, PtrVT));
      else
        Result = DataPtr;

    } break;
    default:
      report_fatal_error("Unsupported LinkageType");
    }
  } else {
    Result = DAG.getTargetGlobalAddress(GV, DL, PtrVT, 0);
    Result = DAG.getNode(KVXISD::AddrWrapper, DL, PtrVT, Result);

    if (Offset != 0) {
      SDValue PtrOff = DAG.getIntPtrConstant(Offset, DL);
      Result = DAG.getNode(ISD::ADD, DL, MVT::i64, Result, PtrOff);
    }
  }

  LLVM_DEBUG(dbgs() << "Result: " << '\n'; Result.dump());
  return Result;
}

SDValue KVXTargetLowering::lowerGlobalTLSAddress(SDValue Op,
                                                 SelectionDAG &DAG) const {

  MachineFunction &MF = DAG.getMachineFunction();
  GlobalAddressSDNode *N = cast<GlobalAddressSDNode>(Op);
  const GlobalValue *GV = N->getGlobal();
  TLSModel::Model model = DAG.getTarget().getTLSModel(GV);

  switch (model) {
  default:
    if (MF.getSubtarget().getTargetTriple().isOSClusterOS() ||
        MF.getSubtarget().getTargetTriple().isOSKVXOSPorting())
      report_fatal_error(
          "ClusterOS and KVXOSPorting only supports TLS model LocalExec");
    else
      report_fatal_error("Unknown TLSModel");
  case TLSModel::LocalExec:
    SDLoc DL(Op);
    int64_t Offset = N->getOffset();
    EVT PtrVT = getPointerTy(DAG.getDataLayout());

    SDValue Result = DAG.getTargetGlobalAddress(GV, DL, PtrVT, Offset);
    Result = DAG.getNode(KVXISD::AddrWrapper, DL, PtrVT, Result);
    Result = DAG.getNode(ISD::ADD, DL, PtrVT,
                         DAG.getRegister(KVX::R13, MVT::i64), Result);
    return Result;
  }

  return SDValue();
}

SDValue KVXTargetLowering::lowerVASTART(SDValue Op, SelectionDAG &DAG) const {
  MachineFunction &MF = DAG.getMachineFunction();
  KVXMachineFunctionInfo *FuncInfo = MF.getInfo<KVXMachineFunctionInfo>();

  SDLoc DL(Op);
  SDValue FI = DAG.getFrameIndex(FuncInfo->getVarArgsFrameIndex(),
                                 getPointerTy(MF.getDataLayout()));

  // vastart just stores the address of the VarArgsFrameIndex slot into the
  // memory location argument.
  const Value *SV = cast<SrcValueSDNode>(Op.getOperand(2))->getValue();
  return DAG.getStore(Op.getOperand(0), DL, FI, Op.getOperand(1),
                      MachinePointerInfo(SV));
}

SDValue KVXTargetLowering::lowerVAARG(SDValue Op, SelectionDAG &DAG) const {
  SDNode *Node = Op.getNode();
  EVT VT = Node->getValueType(0);
  SDValue InChain = Node->getOperand(0);
  SDValue VAListPtr = Node->getOperand(1);
  EVT PtrVT = VAListPtr.getValueType();
  const Value *SV = cast<SrcValueSDNode>(Node->getOperand(2))->getValue();
  SDLoc DL(Node);
  SDValue VAList =
      DAG.getLoad(PtrVT, DL, InChain, VAListPtr, MachinePointerInfo(SV));
  // Increment the pointer, VAList, to the next vaarg.
  // Increment va_list pointer to the next multiple of 64 bits / 8 bytes
  int increment = (VT.getSizeInBits() + 63) / 64 * 8;
  SDValue NextPtr = DAG.getNode(ISD::ADD, DL, PtrVT, VAList,
                                DAG.getIntPtrConstant(increment, DL));
  // Store the incremented VAList to the legalized pointer.
  InChain = DAG.getStore(VAList.getValue(1), DL, NextPtr, VAListPtr,
                         MachinePointerInfo(SV));
  // Load the actual argument out of the pointer VAList.
  // We can't count on greater alignment than the word size.
  return DAG.getLoad(VT, DL, InChain, VAList, MachinePointerInfo(), 8);
}

SDValue KVXTargetLowering::lowerFRAMEADDR(SDValue Op, SelectionDAG &DAG) const {
  MachineFunction &MF = DAG.getMachineFunction();
  MachineFrameInfo &MFI = MF.getFrameInfo();
  MFI.setFrameAddressIsTaken(true);
  unsigned FrameReg = getSPReg();
  int XLenInBytes = 8;

  EVT VT = Op.getValueType();
  SDLoc DL(Op);
  SDValue FrameAddr = DAG.getCopyFromReg(DAG.getEntryNode(), DL, FrameReg, VT);
  unsigned Depth = cast<ConstantSDNode>(Op.getOperand(0))->getZExtValue();
  while (Depth--) {
    int Offset = -(XLenInBytes * 2);
    SDValue Ptr = DAG.getNode(ISD::ADD, DL, VT, FrameAddr,
                              DAG.getIntPtrConstant(Offset, DL));
    FrameAddr =
        DAG.getLoad(VT, DL, DAG.getEntryNode(), Ptr, MachinePointerInfo());
  }
  return FrameAddr;
}

SDValue KVXTargetLowering::lowerFSUB(SDValue Op, SelectionDAG &DAG) const {
  switch (Op.getSimpleValueType().SimpleTy) {
  default:
    return Op;
  case MVT::f16:
  case MVT::f32:
  case MVT::f64:
    if (auto *ConstFPNode = dyn_cast<ConstantFPSDNode>(Op.getOperand(0))) {
      uint64_t Val = ConstFPNode->getValueAPF().bitcastToAPInt().getZExtValue();

      if (Val == 0)
        return DAG.getNode(ISD::FNEG, SDLoc(Op), Op.getValueType(),
                           Op.getOperand(1));
    }

    return Op;
  }
}

bool KVXTargetLowering::IsEligibleForTailCallOptimization(
    CCState &CCInfo, CallLoweringInfo &CLI, MachineFunction &MF,
    const SmallVector<CCValAssign, 16> &ArgsLocs) const {
  auto &Callee = CLI.Callee;
  auto CalleeCC = CLI.CallConv;
  auto IsVarArg = CLI.IsVarArg;
  auto &Outs = CLI.Outs;
  auto &Caller = MF.getFunction();
  auto CallerCC = Caller.getCallingConv();

  // Do not tail call opt functions with "disable-tail-calls" attribute.
  if (Caller.getFnAttribute("disable-tail-calls").getValueAsString() == "true")
    return false;

  // Do not tail call opt functions with varargs, unless arguments are all
  // passed in registers.
  if (IsVarArg)
    for (unsigned Idx = 0, End = ArgsLocs.size(); Idx != End; ++Idx)
      if (!ArgsLocs[Idx].isRegLoc())
        return false;

  // Do not tail call opt if the stack is used to pass parameters.
  if (CCInfo.getNextStackOffset() != 0)
    return false;

  // Do not tail call opt if either caller or callee uses struct return
  // semantics.
  auto IsCallerStructRet = Caller.hasStructRetAttr();
  auto IsCalleeStructRet = Outs.empty() ? false : Outs[0].Flags.isSRet();
  if (IsCallerStructRet || IsCalleeStructRet)
    return false;

  // Externally-defined functions with weak linkage should not be
  // tail-called. The behaviour of branch instructions in this situation (as
  // used for tail calls) is implementation-defined, so we cannot rely on the
  // linker replacing the tail call with a return.
  if (GlobalAddressSDNode *G = dyn_cast<GlobalAddressSDNode>(Callee)) {
    const GlobalValue *GV = G->getGlobal();
    if (GV->hasExternalWeakLinkage())
      return false;
  }

  // The callee has to preserve all registers the caller needs to preserve.
  if (CalleeCC != CallerCC) {
    const KVXRegisterInfo *TRI = Subtarget.getRegisterInfo();
    const uint32_t *CallerPreserved = TRI->getCallPreservedMask(MF, CallerCC);
    const uint32_t *CalleePreserved = TRI->getCallPreservedMask(MF, CalleeCC);
    if (!TRI->regmaskSubsetEqual(CallerPreserved, CalleePreserved))
      return false;
  }

  return true;
}

SDValue KVXTargetLowering::lowerBlockAddress(SDValue Op,
                                             SelectionDAG &DAG) const {
  BlockAddressSDNode *N = cast<BlockAddressSDNode>(Op);
  const BlockAddress *BA = N->getBlockAddress();
  int64_t Offset = N->getOffset();
  auto PtrVT = getPointerTy(DAG.getDataLayout());

  SDLoc DL(Op);

  SDValue Result = DAG.getTargetBlockAddress(BA, PtrVT, Offset);

  // -fPIC
  if (isPositionIndependent())
    Result = DAG.getNode(KVXISD::PICAddrWrapper, DL, PtrVT, Result);
  else
    Result = DAG.getNode(KVXISD::AddrWrapper, DL, PtrVT, Result);

  return Result;
}

#define GET_REGISTER_MATCHER
#include "KVXGenAsmMatcher.inc"

Register KVXTargetLowering::getRegisterByName(const char *RegName, LLT Ty,
                                              const MachineFunction &MF) const {
  unsigned RegNo = MatchRegisterName(RegName);
  if (RegNo == 0) {
    static StringRef Dollar = "$";
    RegNo = MatchRegisterName(Dollar.str() + StringRef(RegName).str());
  }
  return RegNo;
}

std::pair<unsigned, const TargetRegisterClass *>
KVXTargetLowering::getRegForInlineAsmConstraint(const TargetRegisterInfo *TRI,
                                                StringRef Constraint,
                                                MVT VT) const {
  if (Constraint == "r") {
    switch (VT.SimpleTy) {
    case MVT::i1:  // i1 is not a valid type though
    case MVT::i8:  // i8 is not a valid type though
    case MVT::i16: // i16 is not a valid type though
    case MVT::i32:
    case MVT::i64:
    case MVT::v2i8:
    case MVT::v4i8:
    case MVT::v8i8:
    case MVT::v2i16:
    case MVT::v2i32:
    case MVT::v4i16:
    case MVT::f16:
    case MVT::f32:
    case MVT::f64:
    case MVT::v4f16:
    case MVT::v2f16:
    case MVT::v2f32:
      return std::make_pair(0U, &KVX::SingleRegRegClass);
    case MVT::v2i64:
    case MVT::v4i32:
    case MVT::v4f32:
    case MVT::v2f64:
      return std::make_pair(0U, &KVX::PairedRegRegClass);
    case MVT::v4i64:
    case MVT::v4f64:
      return std::make_pair(0U, &KVX::QuadRegRegClass);
    default:
      return TargetLowering::getRegForInlineAsmConstraint(TRI, Constraint, VT);
    }
  } else if (Constraint == "w") {
    switch (VT.SimpleTy) {
    case MVT::v64i1:
    case MVT::v128i1:
    case MVT::v256i1:
      return std::make_pair(0U, &KVX::VectorRegRegClass);
    case MVT::v512i1:
      return std::make_pair(0U, &KVX::WideRegRegClass);
    case MVT::v1024i1:
      return std::make_pair(0U, &KVX::MatrixRegRegClass);
    default:
      return TargetLowering::getRegForInlineAsmConstraint(TRI, Constraint, VT);
    }
  }

  if (!(Constraint.size() >= 4 && Constraint.front() == '{' &&
        Constraint.back() == '}'))
    return TargetLowering::getRegForInlineAsmConstraint(TRI, Constraint, VT);

  StringRef RegName = Constraint.substr(1, Constraint.size() - 2);
  unsigned RegNo = MatchRegisterName(RegName);
  if (RegNo == 0) {
    RegNo = MatchRegisterAltName(RegName);
    if (RegNo == 0)
      return TargetLowering::getRegForInlineAsmConstraint(TRI, Constraint, VT);
  }
  if (KVX::SystemRegRegClass.contains(RegNo))
    return std::make_pair(RegNo, &KVX::SystemRegRegClass);
  if (KVX::SingleRegRegClass.contains(RegNo))
    return std::make_pair(RegNo, &KVX::SingleRegRegClass);
  if (KVX::PairedRegRegClass.contains(RegNo))
    return std::make_pair(RegNo, &KVX::PairedRegRegClass);
  if (KVX::QuadRegRegClass.contains(RegNo))
    return std::make_pair(RegNo, &KVX::QuadRegRegClass);
  if (KVX::CoproRegRegClass.contains(RegNo))
    return std::make_pair(RegNo, &KVX::CoproRegRegClass);
  if (KVX::BlockRegRegClass.contains(RegNo))
    return std::make_pair(RegNo, &KVX::BlockRegRegClass);
  if (KVX::VectorRegRegClass.contains(RegNo))
    return std::make_pair(RegNo, &KVX::VectorRegRegClass);
  if (KVX::WideRegRegClass.contains(RegNo))
    return std::make_pair(RegNo, &KVX::WideRegRegClass);
  if (KVX::MatrixRegRegClass.contains(RegNo))
    return std::make_pair(RegNo, &KVX::MatrixRegRegClass);

  return TargetLowering::getRegForInlineAsmConstraint(TRI, Constraint, VT);
}

TargetLowering::ConstraintType
KVXTargetLowering::getConstraintType(StringRef Constraint) const {
  if (Constraint == "w")
    return C_RegisterClass;

  return TargetLowering::getConstraintType(Constraint);
}

SDValue KVXTargetLowering::lowerMULHVectorGeneric(SDValue Op, SelectionDAG &DAG,
                                                  bool Signed) const {
  SDLoc DL(Op);

  ISD::NodeType ExtensionType = Signed ? ISD::SIGN_EXTEND : ISD::ZERO_EXTEND;

  EVT VectorType = Op.getValueType();
  unsigned VectorSize = VectorType.getVectorNumElements();
  const unsigned BitSize = VectorType.getScalarSizeInBits();
  EVT ScalarType = VectorType.getScalarType();

  SmallVector<SDValue, 8> RV;
  for (unsigned int i = 0; i < VectorSize; i++) {
    SDValue AVal =
        DAG.getNode(ISD::EXTRACT_VECTOR_ELT, DL, ScalarType,
                    { Op.getOperand(0), DAG.getConstant(i, DL, MVT::i64) });
    SDValue AValExt = DAG.getNode(ExtensionType, DL, MVT::i32, AVal);
    SDValue BVal =
        DAG.getNode(ISD::EXTRACT_VECTOR_ELT, DL, ScalarType,
                    { Op.getOperand(1), DAG.getConstant(i, DL, MVT::i64) });
    SDValue BValExt = DAG.getNode(ExtensionType, DL, MVT::i32, BVal);
    SDValue R =
        DAG.getNode(ISD::SRL, DL, MVT::i32,
                    DAG.getNode(ISD::MUL, DL, MVT::i32, { AValExt, BValExt }),
                    DAG.getConstant(BitSize, DL, MVT::i32));
    RV.push_back(R);
  }
  // Building a vector from the computed values
  return DAG.getBuildVector(VectorType, DL, RV);
}

static uint64_t selectMask(unsigned Size) {
  if (4 < Size && Size <= 64 && Size % 2 == 0)
    return Size == 64 ? UINT64_MAX : (1L << Size) - 1L;

  report_fatal_error("Unsupported size, cannot select mask!");
}

static SDValue getINSF(const SDLoc &DL, const SDValue &Vec, const SDValue &Val,
                       unsigned ElementBitSize, unsigned Pos, SelectionDAG &DAG,
                       EVT nodeType = MVT::i64) {
  const uint64_t StartBit = Pos * ElementBitSize;
  const uint64_t StopBit = StartBit + ElementBitSize - 1;

  return SDValue(DAG.getMachineNode(
                     KVX::INSF, DL, nodeType,
                     {Vec, Val, DAG.getTargetConstant(StopBit, DL, MVT::i64),
                      DAG.getTargetConstant(StartBit, DL, MVT::i64)}),
                 0);
}

SDValue KVXTargetLowering::lowerBUILD_VECTOR(SDValue Op,
                                             SelectionDAG &DAG) const {
  switch (Op.getSimpleValueType().SimpleTy) {
  default:
    report_fatal_error("Unsupported lowering build_vector for this type!");
  case MVT::v4i32:
  case MVT::v4f32:
    return lowerBUILD_VECTOR_V4_128bit(Op, DAG);
  case MVT::v256i1:
  case MVT::v512i1:
  case MVT::v1024i1:
    return lowerTCAZeroInit(Op, DAG);
  }
}

SDValue KVXTargetLowering::lowerBUILD_VECTOR_V2_64bit(SDValue Op,
                                                      SelectionDAG &DAG,
                                                      bool useINSF) const {
  SDLoc DL(Op);

  if (Op.isUndef())
    return Op;

  SDValue Op1 = Op.getOperand(0);
  SDValue Op2 = Op.getOperand(1);

  bool IsOp1Const = false;
  bool IsOp2Const = false;

  uint64_t Op1Val;
  uint64_t Op2Val;

  if (isa<ConstantSDNode>(Op1)) {
    auto *Op1Const = dyn_cast<ConstantSDNode>(Op1);
    Op1Val = Op1Const->getZExtValue();
    IsOp1Const = true;
  } else if (isa<ConstantFPSDNode>(Op1)) {
    auto *Op1Const = dyn_cast<ConstantFPSDNode>(Op1);
    Op1Val = Op1Const->getValueAPF().bitcastToAPInt().getZExtValue();
    IsOp1Const = true;
  }

  if (isa<ConstantSDNode>(Op2)) {
    auto *Op2Const = dyn_cast<ConstantSDNode>(Op2);
    Op2Val = Op2Const->getZExtValue();
    IsOp2Const = true;
  } else if (isa<ConstantFPSDNode>(Op2)) {
    auto *Op2Const = dyn_cast<ConstantFPSDNode>(Op2);
    Op2Val = Op2Const->getValueAPF().bitcastToAPInt().getZExtValue();
    IsOp2Const = true;
  }

  if (Op1.isUndef()) {
    Op1Val = 0;
    IsOp1Const = true;
  }

  if (Op2.isUndef()) {
    Op2Val = 0;
    IsOp2Const = true;
  }

  if (IsOp1Const && IsOp2Const) { // imm imm
    uint64_t R = ((Op2Val << 32) | (Op1Val & 0xFFFFFFFF));

    return DAG.getBitcast(Op.getValueType(), DAG.getConstant(R, DL, MVT::i64));
  }
  if (IsOp1Const) { // imm reg
    Op1Val &= 0xFFFFFFFF;

    SDValue ShiftedOp2 = DAG.getNode(
        ISD::SHL, DL, MVT::i64,
        {SDValue(DAG.getMachineNode(TargetOpcode::COPY, DL, MVT::i64,
                                    DAG.getBitcast(MVT::i32, Op2)),
                 0),
         DAG.getConstant(32, DL, MVT::i32)});

    return DAG.getBitcast(
        Op.getValueType(),
        DAG.getNode(ISD::OR, DL, MVT::i64,
                    {ShiftedOp2, DAG.getConstant(Op1Val, DL, MVT::i64)}));
  }
  if (IsOp2Const) { // reg imm
    Op2Val <<= 32;

    SDValue SDOp1Val = DAG.getNode(ISD::ZERO_EXTEND, DL, MVT::i64,
                                   DAG.getBitcast(MVT::i32, Op1));

    return DAG.getBitcast(
        Op.getValueType(),
        DAG.getNode(ISD::OR, DL, MVT::i64,
                    {SDOp1Val, DAG.getConstant(Op2Val, DL, MVT::i64)}));
  } // reg reg
  if (Op1.isUndef() && Op2.isUndef())
    return SDValue(
        DAG.getMachineNode(TargetOpcode::IMPLICIT_DEF, DL, Op.getValueType()),
        0);
  if (useINSF) {
    return SDValue(
        DAG.getMachineNode(KVX::INSF, DL, Op.getValueType(),
                           {Op1, Op2, DAG.getTargetConstant(63, DL, MVT::i64),
                            DAG.getTargetConstant(32, DL, MVT::i64)}),
        0);
  }
  SDValue ShiftedOp2 =
      DAG.getNode(ISD::SHL, DL, MVT::i64,
                  {SDValue(DAG.getMachineNode(TargetOpcode::COPY, DL, MVT::i64,
                                              DAG.getBitcast(MVT::i32, Op2)),
                           0),
                   DAG.getConstant(32, DL, MVT::i32)});
  SDValue SDOp1Val = DAG.getNode(ISD::ZERO_EXTEND, DL, MVT::i64,
                                 DAG.getBitcast(MVT::i32, Op1));

  return DAG.getBitcast(Op.getValueType(), DAG.getNode(ISD::OR, DL, MVT::i64,
                                                       {SDOp1Val, ShiftedOp2}));
}

SDValue
KVXTargetLowering::lowerBUILD_VECTOR_V4_128bit(SDValue Op,
                                               SelectionDAG &DAG) const {
  SDLoc DL(Op);
  SDValue V1 = Op.getOperand(0);
  SDValue V2 = Op.getOperand(1);
  SDValue V3 = Op.getOperand(2);
  SDValue V4 = Op.getOperand(3);

  EVT VT = Op.getValueType();
  LLVMContext &Ctx = *DAG.getContext();
  EVT HalfVT = VT.getHalfNumVectorElementsVT(Ctx);

  SDValue VecLow = DAG.getNode(ISD::BUILD_VECTOR, DL, HalfVT, {V1, V2});
  SDValue VecHi = DAG.getNode(ISD::BUILD_VECTOR, DL, HalfVT, {V3, V4});

  return SDValue(
      DAG.getMachineNode(
          TargetOpcode::REG_SEQUENCE, DL, VT,
          {DAG.getTargetConstant(KVX::PairedRegRegClassID, DL, MVT::i64), VecHi,
           DAG.getTargetConstant(KVX::sub_s1, DL, MVT::i64), VecLow,
           DAG.getTargetConstant(KVX::sub_s0, DL, MVT::i64)}),
      0);
}

static SDValue makeInsertConst(const SDLoc &DL, SDValue Vec, MVT Type,
                               uint64_t Mask, uint64_t ImmVal,
                               unsigned StartIdx, SelectionDAG &DAG) {
  Vec = DAG.getNode(
      ISD::AND, DL, Type,
      SDValue(DAG.getMachineNode(TargetOpcode::COPY, DL, Type, Vec), 0),
      DAG.getConstant(~(Mask << StartIdx), DL, Type));

  return DAG.getNode(
      ISD::OR, DL, Type,
      { Vec, DAG.getConstant((ImmVal & Mask) << StartIdx, DL, Type) });
}

static MVT selectType(unsigned Size) {
  switch (Size) {
  default:
    report_fatal_error("Unsupported type for this size!");
  case 8:
  case 16:
  case 32:
    return MVT::i32;
  case 64:
  case 128:
  case 256:
    return MVT::i64;
  }
}

SDValue KVXTargetLowering::lowerINSERT_VECTOR_ELT(SDValue Op,
                                                  SelectionDAG &DAG) const {
  SDValue Vec = Op.getOperand(0);
  SDValue Val = Op.getOperand(1);
  SDValue Idx = Op.getOperand(2);
  SDLoc DL(Op);
  EVT VecVT = Op.getValueType();

  if (ConstantSDNode *InsertPos = dyn_cast<ConstantSDNode>(Idx)) {

    if (Vec.getValueType() == MVT::v4f32 || Vec.getValueType() == MVT::v4i32)
      return Op;

    if (Vec.getValueType() == MVT::v2f64 || Vec.getValueType() == MVT::v2i64 ||
        Vec.getValueType() == MVT::v4f64 || Vec.getValueType() == MVT::v4i64)
      return lowerINSERT_VECTOR_ELT_64bit_elt(DL, DAG, Vec, Val,
                                              InsertPos->getZExtValue());

    unsigned ElementBitSize = VecVT.getScalarSizeInBits();
    uint64_t ImmVal;
    if (auto *OpConst = dyn_cast<ConstantSDNode>(Val))
      ImmVal = OpConst->getZExtValue();
    else if (auto *OpConst = dyn_cast<ConstantFPSDNode>(Val))
      ImmVal = OpConst->getValueAPF().bitcastToAPInt().getZExtValue();
    else
      return getINSF(DL, Vec, Val, ElementBitSize, InsertPos->getZExtValue(),
                     DAG, Op.getValueType());

    uint64_t Mask = selectMask(ElementBitSize);
    auto SizeType = selectType(VecVT.getSizeInBits());
    const unsigned StartBit = ElementBitSize * InsertPos->getZExtValue();
    // COPY is used here because bitcast is not possible for v2i8
    return SDValue(DAG.getMachineNode(TargetOpcode::COPY, DL, Op.getValueType(),
                                      makeInsertConst(DL, Vec, SizeType, Mask,
                                                      ImmVal, StartBit, DAG)),
                   0);
  }

  switch (VecVT.getSimpleVT().SimpleTy) {
  default:
    return SDValue();
  case MVT::v2i16:
  case MVT::v2f16:
  case MVT::v2i32:
  case MVT::v2f32:
  case MVT::v2f64:
  case MVT::v2i64:
  case MVT::v4f16:
  case MVT::v4i16:
  case MVT::v4f32:
  case MVT::v4i32:
  case MVT::v4f64:
  case MVT::v4i64:
    return Op;
  }
  return SDValue();
}

SDValue KVXTargetLowering::lowerINSERT_VECTOR_ELT_64bit_elt(
    SDLoc &dl, SelectionDAG &DAG, SDValue Vec, SDValue Val,
    uint64_t index) const {
  SDValue subRegIdx = DAG.getTargetConstant(index + KVX::sub_s0, dl, MVT::i32);
  return SDValue(DAG.getMachineNode(TargetOpcode::INSERT_SUBREG, dl,
                                    Vec.getValueType(), {Vec, Val, subRegIdx}),
                 0);
}

SDValue
KVXTargetLowering::lowerEXTRACT_VECTOR_ELT_REGISTER(SDValue Op,
                                                    SelectionDAG &DAG) const {
  SDValue Vec = Op.getOperand(0);
  SDValue Idx = Op.getOperand(1);
  SDLoc dl(Op);

  EVT VecVT = Vec.getValueType();
  switch (VecVT.getSimpleVT().SimpleTy) {
  default:
    break;
  case MVT::v2i8:
  case MVT::v2f16:
  case MVT::v2i16:
  case MVT::v2f32:
  case MVT::v2i32:
  case MVT::v2f64:
  case MVT::v2i64:
  case MVT::v4i8:
  case MVT::v4f16:
  case MVT::v4i16:
  case MVT::v8i8:
    return Op;
  }

  SDValue StackPtr = DAG.CreateStackTemporary(VecVT);
  SDValue Ch =
      DAG.getStore(DAG.getEntryNode(), dl, Vec, StackPtr, MachinePointerInfo());

  StackPtr = getVectorElementPointer(DAG, StackPtr, VecVT, Idx);

  SDValue NewLoad;

  if (Op.getValueType().isVector())
    NewLoad =
        DAG.getLoad(Op.getValueType(), dl, Ch, StackPtr, MachinePointerInfo());
  else
    NewLoad =
        DAG.getExtLoad(ISD::EXTLOAD, dl, Op.getValueType(), Ch, StackPtr,
                       MachinePointerInfo(), VecVT.getVectorElementType());

  DAG.ReplaceAllUsesOfValueWith(Ch, SDValue(NewLoad.getNode(), 1));

  SmallVector<SDValue, 6> NewLoadOperands(NewLoad->op_begin(),
                                          NewLoad->op_end());
  NewLoadOperands[0] = Ch;
  NewLoad =
      SDValue(DAG.UpdateNodeOperands(NewLoad.getNode(), NewLoadOperands), 0);
  return NewLoad;
}

SDValue KVXTargetLowering::lowerEXTRACT_VECTOR_ELT(SDValue Op,
                                                   SelectionDAG &DAG) const {
  SDValue Idx = Op.getOperand(1);

  if (isa<ConstantSDNode>(Idx)) {
    // use patterns in td
    return Op;
  }

  return lowerEXTRACT_VECTOR_ELT_REGISTER(Op, DAG);
}

SDValue KVXTargetLowering::lowerCONCAT_VECTORS(SDValue Op,
                                               SelectionDAG &DAG) const {
  auto OperandSize = Op.getOperand(0).getValueSizeInBits();
  auto ResultSize = Op.getValueSizeInBits();
  if (Op.getNumOperands() != 2)
    return SDValue();

  if ((ResultSize <= 64) || (OperandSize >= 64 && ResultSize <= 256))
    return Op;

  if (!((OperandSize == 16 && ResultSize == 32) ||
        (OperandSize == 16 && ResultSize == 64) ||
        (OperandSize == 32 && ResultSize == 64)))
    report_fatal_error("Unsupported concat for these types");

  SDLoc DL(Op);
  SDValue Out = SDValue(
      DAG.getMachineNode(TargetOpcode::IMPLICIT_DEF, DL, Op->getValueType(0)),
      0);
  EVT VT = Op.getValueType();

  for (unsigned i = 0, e = Op->getNumOperands(); i != e; ++i) {
    if (Op->getOperand(i).isUndef())
      continue;
    if (OperandSize == 16 || OperandSize == 32)
      Out = getINSF(DL, Out, Op->getOperand(i), OperandSize, i, DAG, VT);
  }

  return Out;
}

unsigned
KVXTargetLowering::getComparisonCondition(ISD::CondCode CCOpcode) const {
  unsigned Condition;

  switch (CCOpcode) {
  case ISD::SETEQ:
    Condition = KVXMOD::COMPARISON_EQ;
    break;
  case ISD::SETNE:
    Condition = KVXMOD::COMPARISON_NE;
    break;
  case ISD::SETLT:
    Condition = KVXMOD::COMPARISON_LT;
    break;
  case ISD::SETLE:
    Condition = KVXMOD::COMPARISON_LE;
    break;
  case ISD::SETGT:
    Condition = KVXMOD::COMPARISON_GT;
    break;
  case ISD::SETGE:
    Condition = KVXMOD::COMPARISON_GE;
    break;
  case ISD::SETULT:
    Condition = KVXMOD::COMPARISON_LTU;
    break;
  case ISD::SETULE:
    Condition = KVXMOD::COMPARISON_LEU;
    break;
  case ISD::SETUGT:
    Condition = KVXMOD::COMPARISON_GTU;
    break;
  case ISD::SETUGE:
    Condition = KVXMOD::COMPARISON_GEU;
    break;
  default:
    report_fatal_error("not an integer condition code");
  }

  return Condition;
}

unsigned KVXTargetLowering::getBranchCondition(ISD::CondCode CCOpcode,
                                               bool Word) const {
  unsigned Condition;
  unsigned WordAddend = KVXMOD::SCALARCOND_WEQZ - KVXMOD::SCALARCOND_DEQZ;

  switch (CCOpcode) {
  case ISD::SETEQ:
    Condition = KVXMOD::SCALARCOND_DEQZ;
    break;
  case ISD::SETNE:
    Condition = KVXMOD::SCALARCOND_DNEZ;
    break;
  case ISD::SETLT:
  case ISD::SETULT:
    Condition = KVXMOD::SCALARCOND_DLTZ;
    break;
  case ISD::SETLE:
  case ISD::SETULE:
    Condition = KVXMOD::SCALARCOND_DLEZ;
    break;
  case ISD::SETGT:
  case ISD::SETUGT:
    Condition = KVXMOD::SCALARCOND_DGTZ;
    break;
  case ISD::SETGE:
  case ISD::SETUGE:
    Condition = KVXMOD::SCALARCOND_DGEZ;
    break;
  default:
    report_fatal_error("not an integer condition code");
  }

  return Word ? Condition + WordAddend : Condition;
}

SDValue KVXTargetLowering::lowerBR_CC(SDValue Op, SelectionDAG &DAG) const {
  // BR_CC CC LHS RHS BB (compare LHS and RHS with condition CC,
  // branch to block BB if true)
  //
  // LHS is an AND TMP 1 and CC is NE or EQ:
  // -> generate one cb insn if RHS is 0: CB.[ODD|EVEN] TMP ? BB
  //
  // RHS is a constant equal to 0:
  // -> generate one cb insn: CB.CC LHS ? BB
  //
  // RHS is a constant equal to 1 and CC is LT:
  // -> generate one cb insn: CB.[W|D]LTE LHS ? BB
  //
  // RHS is a constant equal to -1 and CC is GT:
  // -> generate one cb insn: CB.[W|D]GTE LHS ? BB
  //
  // General case:
  // -> generate two insns: COMP[W|D].CC TMP = LHS, RHS
  //                        CB.ODD TMP ? BB

  SDLoc DL(Op);
  SDValue Chain = Op.getOperand(0);
  SDValue CC = Op.getOperand(1);
  SDValue LHS = Op.getOperand(2);
  SDValue RHS = Op.getOperand(3);
  SDValue BB = Op.getOperand(4);
  EVT Type = LHS.getSimpleValueType();
  MVT ModVT = MVT::i32;

  ISD::CondCode CCOpcode = cast<CondCodeSDNode>(CC)->get();
  SDValue CompCond =
      DAG.getConstant(getComparisonCondition(CCOpcode), DL, ModVT);
  SDValue CBCond = DAG.getConstant(
      getBranchCondition(CCOpcode, Type == MVT::i32), DL, ModVT);

  bool EmitComp = true;

  if (auto *Constant = dyn_cast<ConstantSDNode>(RHS)) {
    if (Constant->getSExtValue() == 0) {
      EmitComp = false;
      if (LHS->getOpcode() == ISD::AND &&
          isa<ConstantSDNode>(LHS->getOperand(1)) &&
          dyn_cast<ConstantSDNode>(LHS->getOperand(1))->getSExtValue() == 1 &&
          (CCOpcode == ISD::SETNE || CCOpcode == ISD::SETEQ)) {
        EmitComp = false;
        LHS = LHS->getOperand(0);
        CBCond =
            DAG.getConstant(CCOpcode == ISD::SETEQ ? KVXMOD::SCALARCOND_EVEN
                                                   : KVXMOD::SCALARCOND_ODD,
                            DL, ModVT);
      }
    } else if (Constant->getSExtValue() == 1 && CCOpcode == ISD::SETLT) {
      EmitComp = false;
      CBCond = DAG.getConstant(getBranchCondition(ISD::SETLE, Type == MVT::i32),
                               DL, ModVT);
    } else if (Constant->getSExtValue() == -1 && CCOpcode == ISD::SETGT) {
      EmitComp = false;
      CBCond = DAG.getConstant(getBranchCondition(ISD::SETGE, Type == MVT::i32),
                               DL, ModVT);
    }
  }

  if (EmitComp) {
    LHS = DAG.getNode(KVXISD::COMP, DL, Type, LHS, RHS, CompCond);
    CBCond = DAG.getConstant(KVXMOD::SCALARCOND_ODD, DL, ModVT);
  }

  return DAG.getNode(KVXISD::BRCOND, DL, Op.getValueType(), Chain, LHS, BB,
                     CBCond);
}

SDValue KVXTargetLowering::lowerJumpTable(SDValue Op, SelectionDAG &DAG) const {
  EVT VT = Op.getValueType();
  int Idx = cast<JumpTableSDNode>(Op)->getIndex();
  SDValue T = DAG.getTargetJumpTable(Idx, VT);

  if (isPositionIndependent()) {
    return DAG.getNode(KVXISD::JT_PCREL, SDLoc(Op), VT, T);
  }
  return DAG.getNode(KVXISD::JT, SDLoc(Op), VT, T);
}

SDValue KVXTargetLowering::lowerADDRSPACECAST(SDValue Op,
                                              SelectionDAG &DAG) const {
  SDLoc SL(Op);
  const AddrSpaceCastSDNode *ASC = cast<AddrSpaceCastSDNode>(Op);
  return DAG.getUNDEF(ASC->getValueType(0));
}

SDValue KVXTargetLowering::lowerIntToFP(SDValue Op, SelectionDAG &DAG) const {
  auto VT = Op.getValueType();
  if (VT.isVector()) {
    if (Op.getOperand(0).getScalarValueSizeInBits() == 32)
      return Op;
    return SDValue();
  }

  if (Op.getValueType() != MVT::f32)
    return Op;

  RTLIB::Libcall LC;
  if (Op.getOpcode() == ISD::SINT_TO_FP)
    LC = RTLIB::getSINTTOFP(Op.getOperand(0).getValueType(), Op.getValueType());
  else
    LC = RTLIB::getUINTTOFP(Op.getOperand(0).getValueType(), Op.getValueType());

  SmallVector<SDValue, 2> Ops(Op->op_begin(), Op->op_end());
  MakeLibCallOptions CallOptions;
  return makeLibCall(DAG, LC, MVT::f32, Ops, CallOptions, SDLoc(Op)).first;
}

SDValue KVXTargetLowering::lowerATOMIC_FENCE(SDValue Op,
                                             SelectionDAG &DAG) const {
  ConstantSDNode *SyncScopeIDNode = cast<ConstantSDNode>(Op.getOperand(2));
  auto SyncScopeID =
      static_cast<SyncScope::ID>(SyncScopeIDNode->getZExtValue());

  // KVX memory model is strong enough not to require any barrier in order to
  // synchronize a thread with itself. Do not emit anything for
  // SyncScope::SingleThread. Example of IR (generated by
  // __atomic_signal_fence(memory_order_acquire) for example):
  // fence syncscope("singlethread") acquire
  if (SyncScopeID != SyncScope::SingleThread) {
    // Always emit a fence for SyncScope::System (generated by
    // __atomic_thread_fence(memory_order_acquire) for example).
    return DAG.getNode(KVXISD::FENCE, SDLoc(Op), MVT::Other, Op.getOperand(0));
  }

  // Fallback: do not emit anything.
  return DAG.getUNDEF(MVT::Other);
}

SDValue KVXTargetLowering::lowerATOMIC_LOAD_OP(SDValue Op,
                                               SelectionDAG &DAG) const {
  EVT MemVT = cast<AtomicSDNode>(Op)->getMemoryVT();
  MVT LoadVT = MemVT.getSimpleVT();

  switch (LoadVT.SimpleTy) {
  default:
    break;
    // Expand all atomic_load operations to libcall for i8 and i16.
  case MVT::i8:
    // Except for ATOMIC_SWAP in order to support __atomic_test_and_set.
    if (Op.getOpcode() == ISD::ATOMIC_SWAP)
      return Op;
    LLVM_FALLTHROUGH;
  case MVT::i16:
    RTLIB::Libcall LC = RTLIB::getSYNC(Op.getOpcode(), LoadVT);
    SmallVector<SDValue, 2> Ops(Op->op_begin() + 1, Op->op_end());
    MakeLibCallOptions CallOptions;
    return makeLibCall(DAG, LC, MVT::i32, Ops, CallOptions, SDLoc(Op)).first;
  }

  return Op;
}

static SDValue combineSRA(SDNode *N, SelectionDAG &DAG) {
  if (N->getSimpleValueType(0).SimpleTy != MVT::i64)
    return SDValue();

  auto Op0 = N->getOperand(0);
  if (Op0->getOpcode() != ISD::SHL || !Op0->hasOneUse())
    return SDValue();

  auto *SHLszSD = dyn_cast<ConstantSDNode>(Op0->getOperand(1));
  if (!SHLszSD)
    return SDValue();

  auto *SRAszSD = dyn_cast<ConstantSDNode>(N->getOperand(1));
  if (!SRAszSD)
    return SDValue();

  int EltSz = 64 - SHLszSD->getSExtValue();

  MVT VT;
  switch (EltSz) {
  case 8:
    VT = MVT::i8;
    break;
  case 16:
    VT = MVT::i16;
    break;
  case 32:
    VT = MVT::i32;
    break;
  default:
    return SDValue();
  }

  auto SExt = DAG.getNode(ISD::SIGN_EXTEND_INREG, SDLoc(SDValue(N, 0)),
                          MVT::i64, Op0.getOperand(0), DAG.getValueType(VT));

  int SRAsz = SRAszSD->getSExtValue() - SHLszSD->getSExtValue();
  if (SRAsz == 0)
    return SExt;

  if (SRAsz > 0)
    return DAG.getNode(ISD::SRA, SDLoc(Op0), MVT::i64, SExt,
                       DAG.getConstant(SRAsz, SDLoc(SRAszSD), MVT::i64));

  return DAG.getNode(ISD::SHL, SDLoc(Op0), MVT::i64, SExt,
                     DAG.getConstant(-SRAsz, SDLoc(SRAszSD), MVT::i64));
}

static SDValue combineZext(SDNode *N, SelectionDAG &DAG) {
  SDValue N0 = N->getOperand(0);
  SDValue N00 = N0->getOperand(0);
  unsigned Opcode = N0->getOpcode();

  // Combine SETCC with ZEXT, except for f16, because it uses FCOMPNHQ
  // which negates the result, therefore zext is mandatory
  if (Opcode == ISD::SETCC && N00.getValueType() != MVT::f16)
    return DAG.getNode(ISD::ANY_EXTEND, SDLoc(N), N->getValueType(0), N0);

  if ((Opcode == ISD::AND || Opcode == ISD::OR) &&
      N0.getValueType() == MVT::i1 && N00->getOpcode() == ISD::SETCC &&
      N00->getOperand(0).getValueType() != MVT::f16)
    return DAG.getNode(ISD::ANY_EXTEND, SDLoc(N), N->getValueType(0), N0);

  return SDValue();
}

static SDValue combineMUL(SDNode *N, TargetLowering::DAGCombinerInfo &DCI,
                          SelectionDAG &Dag) {
  auto VT = N->getValueType(0);
  unsigned HalfSize;
  MVT HalfSizeVT;
  if (VT == MVT::i64) {
    HalfSize = 32;
    HalfSizeVT = MVT::i32;
  } else if (VT == MVT::i128) {
    HalfSize = 64;
    HalfSizeVT = MVT::i64;
  } else if (!VT.isVector() || !VT.isSimple())
    return SDValue();
  else {
    // We avoid converting vectors of non-legal number of
    // elements before they are legalized. Then we do
    // match at the second dag-combine execution.
    switch (VT.getSimpleVT().SimpleTy) {
    default:
      return SDValue();
    case MVT::v2i32:
    case MVT::v4i32:
    case MVT::v2i64:
    case MVT::v4i64:
      break;
    }
    HalfSize = VT.getScalarSizeInBits() >> 1;
    HalfSizeVT = MVT::getVectorVT(VT.getScalarType()
                                      .getHalfSizedIntegerVT(*Dag.getContext())
                                      .getSimpleVT(),
                                  VT.getVectorNumElements());
  }
  auto Op0 = N->getOperand(0);
  auto Op1 = N->getOperand(1);
  KnownBits V0 = Dag.computeKnownBits(Op0);
  KnownBits V1 = Dag.computeKnownBits(Op1);
  bool UnsCond0 = V0.Zero.countLeadingOnes() >= HalfSize;
  bool Op1IsSmallSConstant = false;
  bool Op1IsSmallUConstant = false;

  if (!VT.isVector()) {
    if (auto *Const1 = dyn_cast<ConstantSDNode>(Op1)) {
      if (VT == MVT::i64) {
        Op1IsSmallSConstant = isInt<32>(Const1->getSExtValue());
        Op1IsSmallUConstant = isUInt<32>(Const1->getZExtValue());
      } else
        Op1IsSmallSConstant = !Const1->getAPIntValue().isNegative();
    }
  }
  bool UnsCond1 = V1.Zero.countLeadingOnes() >= HalfSize || Op1IsSmallUConstant;

  unsigned Opcode = 0;
  bool SignCond0 = false;
  bool SignCond1 = false;
  if (UnsCond0 && UnsCond1)
    Opcode = KVXISD::ZEXT_MUL;
  else {
    SignCond0 = V0.One.countLeadingOnes() > HalfSize ||
                Op0->getOpcode() == ISD::SIGN_EXTEND ||
                Op0->getOpcode() == ISD::SIGN_EXTEND_INREG;

    if (!SignCond0 && Op0.getOpcode() == ISD::SRA)
      if (auto *I = dyn_cast<ConstantSDNode>(Op0.getOperand(1)))
        SignCond0 = I->getZExtValue() >= HalfSize;

    SignCond1 = Op1IsSmallSConstant || V1.One.countLeadingOnes() > HalfSize ||
                Op1->getOpcode() == ISD::SIGN_EXTEND ||
                Op1->getOpcode() == ISD::SIGN_EXTEND_INREG;

    if (!SignCond1 && Op1.getOpcode() == ISD::SRA)
      if (auto *I = dyn_cast<ConstantSDNode>(Op1.getOperand(1)))
        SignCond1 = I->getZExtValue() >= HalfSize;
  }

  // We have a sign/sign extend operation
  if (SignCond0 && SignCond1)
    Opcode = KVXISD::SEXT_MUL;
  else if ((SignCond0 && UnsCond1) ||
           (UnsCond0 && SignCond1 && !Op1IsSmallSConstant)) {
    // We have a mixed sign/zero extend operation
    if (UnsCond0)
      std::swap(Op0, Op1);
    Opcode = KVXISD::SZEXT_MUL;
  }

  if (!Opcode)
    return SDValue();

  SDValue T0 = Dag.getNode(ISD::TRUNCATE, SDLoc(Op0), HalfSizeVT, {Op0});
  SDValue T1 = Dag.getNode(ISD::TRUNCATE, SDLoc(Op1), HalfSizeVT, {Op1});
  if (VT != MVT::i128)
    return Dag.getNode(Opcode, SDLoc(N), VT, {T0, T1});

  // i128 is not legal, hide it in a v2i64 vector and bitcast it to i128.
  // The legalizer will just split the bitcast operation.
  SDValue Vec = SDValue(Dag.getNode(Opcode, SDLoc(N), MVT::v2i64, {T0, T1}));
  return Dag.getNode(ISD::BITCAST, SDLoc(N), MVT::i128, Vec);
}

static SDValue combineStore(SDNode *N, TargetLowering::DAGCombinerInfo &DCI,
                            SelectionDAG &Dag) {
  StoreSDNode *ST = dyn_cast<StoreSDNode>(N);
  if (!ST)
    return SDValue();
  SDValue Value = ST->getValue();
  EVT VT = Value.getValueType();
  if (!VT.isSimple())
    return SDValue();
  EVT ToVT;
  switch (VT.getSimpleVT().SimpleTy) {
  case MVT::v8f32:
  case MVT::v8i32:
  case MVT::v16f16:
  case MVT::v16i16:
  case MVT::v32i8:
    ToVT = EVT(MVT::v4i64);
    break;
  case MVT::v8f16:
  case MVT::v8i16:
  case MVT::v16i8:
    ToVT = EVT(MVT::v2i64);
    break;
  default:
    return SDValue();
  }
  SDValue Chain = ST->getChain();
  SDValue Ptr = ST->getBasePtr();

  SDValue Cast = Dag.getBitcast(ToVT, Value);

  return Dag.getStore(Chain, SDLoc(N), Cast, Ptr, ST->getMemOperand());
}

SDValue KVXTargetLowering::PerformDAGCombine(SDNode *N,
                                             DAGCombinerInfo &DCI) const {
  SelectionDAG &DAG = DCI.DAG;

  switch (N->getOpcode()) {
  default:
    break;
  case ISD::MUL:
    return combineMUL(N, DCI, DAG);
  case ISD::SRA:
    return combineSRA(N, DAG);
  case ISD::STORE:
    return combineStore(N, DCI, DAG);
  case ISD::ZERO_EXTEND:
    return combineZext(N, DAG);
  }

  return SDValue();
}

TargetLoweringBase::LegalizeTypeAction
KVXTargetLowering::getPreferredVectorAction(MVT VT) const {
  if (VT.SimpleTy == MVT::Other)
    return TargetLowering::getPreferredVectorAction(VT);

  switch (VT.SimpleTy) {
  case MVT::v8i1:
  case MVT::v8f16:
  case MVT::v8i16:
  case MVT::v8f32:
  case MVT::v8i32:

  case MVT::v16i1:
  case MVT::v16i8:
  case MVT::v16f16:
  case MVT::v16i16:

  case MVT::v32i1:
  case MVT::v32i8:
    return LegalizeTypeAction::TypeSplitVector;
  default:
    break;
  }

  return TargetLowering::getPreferredVectorAction(VT);
}

// isLegalAddressingMode - Return true if the addressing mode represented
// by AM is legal for this target, for a load/store of the specified type.
bool KVXTargetLowering::isLegalAddressingMode(const DataLayout &DL,
                                              const AddrMode &AM, Type *Ty,
                                              unsigned AS,
                                              Instruction *I) const {
  uint64_t NumBytes = 0;

  // KVX has 3 addressing modes:
  // reg + 64-bit signed offset
  // reg + reg
  // reg + reg * scale where scale is the size of the access

  // No global is ever allowed as a base.
  if (AM.BaseGV)
    return false;

  // No reg+reg+imm addressing.
  if (AM.HasBaseReg && AM.BaseOffs && AM.Scale)
    return false;

  if (Ty->isSized()) {
    uint64_t NumBits = DL.getTypeSizeInBits(Ty);
    NumBytes = NumBits / 8;
  }

  // All reg + imm are supported
  if (!AM.Scale)
    return true;

  // Check reg1 + scale*reg2 and reg1 + reg2
  return AM.Scale == 1 || (AM.Scale > 0 && (uint64_t)AM.Scale == NumBytes);

}

bool KVXTargetLowering::isLegalStoreImmediate(int64_t Imm) const {
  return false;
}

void KVXTargetLowering::ReplaceNodeResults(SDNode *N,
                                           SmallVectorImpl<SDValue> &Results,
                                           SelectionDAG &DAG) const {
  switch (N->getOpcode()) {
  case ISD::LOAD: {
    EVT ToVT;
    EVT VT = N->getValueType(0);
    if (!VT.isSimple())
      return;
    switch (VT.getSimpleVT().SimpleTy) {
    case MVT::v8f32:
    case MVT::v8i32:
    case MVT::v16f16:
    case MVT::v16i16:
    case MVT::v32i8:
      ToVT = EVT(MVT::v4i64);
      break;
    case MVT::v8f16:
    case MVT::v8i16:
    case MVT::v16i8:
      ToVT = EVT(MVT::v2i64);
      break;
    default:
      return;
    }
    auto *LDN = dyn_cast<LoadSDNode>(N);
    if (!LDN)
      return;

    SDValue Load =
        DAG.getLoad(ToVT, SDLoc(N), LDN->getChain(), LDN->getBasePtr(),
                    LDN->getPointerInfo(), LDN->getAlignment(),
                    LDN->getMemOperand()->getFlags(), LDN->getAAInfo());

    SDValue Cast = DAG.getBitcast(VT, Load);
    Results.append(1, Cast);
    Results.append(1, Load.getValue(1));
    return;
  }
  default:
    return;
  }
}

bool KVXTargetLowering::isStoreBitCastBeneficial(
    EVT StoreVT, EVT BitcastVT, const SelectionDAG &DAG,
    const MachineMemOperand &MMO) const {
  if (!BitcastVT.isSimple())
    return false;

  switch (BitcastVT.getSimpleVT().SimpleTy) {
  case MVT::v2i64:
  case MVT::v4i64:
    return true;
  default:
    return false;
  }
}

bool KVXTargetLowering::isOpFree(const SDNode *Node) const {
  switch (Node->getOpcode()) {
  case ISD::EXTRACT_SUBVECTOR:
  case ISD::EXTRACT_VECTOR_ELT:
    if (Node->getValueType(0).getFixedSizeInBits() % 64 == 0)
      return true;
  }
  return false;
}

bool KVXTargetLowering::isTruncateFree(Type *SrcTy, Type *DstTy) const {
  if (DstTy->isVectorTy() || (!(SrcTy->isIntegerTy() && DstTy->isIntegerTy())))
    return false;

  unsigned SrcBits = SrcTy->getPrimitiveSizeInBits();
  unsigned DestBits = DstTy->getPrimitiveSizeInBits();
  return (SrcBits > DestBits);
}

bool KVXTargetLowering::isTruncateFree(EVT SrcVT, EVT DstVT) const {
  if (SrcVT.isVector() || DstVT.isVector() || !SrcVT.isInteger() ||
      !DstVT.isInteger())
    return false;

  unsigned SrcBits = SrcVT.getSizeInBits();
  unsigned DestBits = DstVT.getSizeInBits();
  return (SrcBits > DestBits);
}

bool KVXTargetLowering::isFMAFasterThanFMulAndFAdd(const MachineFunction &MF,
                                                   EVT VT) const {
  return enableAggressiveFMAFusion(VT);
}

bool KVXTargetLowering::isFMAFasterThanFMulAndFAdd(const Function &F,
                                                   Type *Ty) const {
  switch (Ty->getScalarType()->getTypeID()) {
  case Type::HalfTyID:
  case Type::FloatTyID:
  case Type::DoubleTyID:
    return true;
  default:
    return false;
  }
}

bool KVXTargetLowering::hasAndNot(SDValue X) const {
  auto VT = X.getValueType();
  if (!(VT.isSimple()))
    return false;

  switch (VT.getSimpleVT().SimpleTy) {
  case MVT::i32:
  case MVT::i64:
    return true;
  default:
    return false;
  }
}

bool KVXTargetLowering::enableAggressiveFMAFusion(EVT VT) const {
  if (!VT.isSimple())
    return false;

  auto Simple = VT.getScalarType().getSimpleVT().SimpleTy;
  switch (Simple) {
  case MVT::f16:
  case MVT::f32:
  case MVT::f64:
    return true;
  default:
    return false;
  }
}

bool KVXTargetLowering::shouldReplaceBy(SDNode *From, unsigned ToOpcode) const {
  switch (ToOpcode) {
  default:
    return true;

  // We prefer vector multiplies to vector shifts
  case ISD::SHL:
    return !From->getValueType(0).isVector();
  }
}

// -----------------------------------------------------------------------------
//        Namespace KVX_LOW
// -----------------------------------------------------------------------------
// Negative is a bitmask, telling which elements numbers must have
// their value negated.

SDValue KVX_LOW::buildImmVector(llvm::SDNode &N, llvm::SelectionDAG &CurDag,
                                bool IsFP, unsigned long Negative) {

  auto *BV = dyn_cast<BuildVectorSDNode>(&N);
  if (!BV)
    return SDValue();

  auto VT = N.getValueType(0);
  auto NumElts = VT.getVectorNumElements();
  assert(NumElts == BV->getNumOperands() &&
         "Build vector and vector with distinct number of operands!");

  auto EltSize = VT.getVectorElementType().getSizeInBits();
  auto OutVT = MVT::getIntegerVT(VT.getSizeInBits());
  assert(EltSize <= 64);
  assert(NumElts * EltSize <= 64);
  uint64_t EltMask = ~(((uint64_t)(-1)) << EltSize);
  uint64_t V = 0;
  unsigned long ShouldNegate = 1;
  for (unsigned I = 0; I < NumElts; I++, ShouldNegate <<= 1) {
    auto Op = BV->getOperand(I);
    if (Op.isUndef())
      continue;

    if (IsFP) {
      auto FPv = cast<ConstantFPSDNode>(Op)->getValueAPF();
      if (Negative & ShouldNegate)
        FPv.changeSign();

      V |= (FPv.bitcastToAPInt().getZExtValue() & EltMask) << (EltSize * I);
    } else if (Negative & ShouldNegate) {
      V |= (-cast<ConstantSDNode>(Op)->getSExtValue() & EltMask)
           << (EltSize * I);
    } else {
      V |= (cast<ConstantSDNode>(Op)->getSExtValue() & EltMask)
           << (EltSize * I);
    }
  }

  return CurDag.getConstant(V, SDLoc(&N), OutVT, true);
}

bool KVX_LOW::isImmVecOfLeqNbits(llvm::SDNode *N, llvm::SelectionDAG *CurDag,
                                 unsigned short B) {
  const BuildVectorSDNode *BV = dyn_cast<BuildVectorSDNode>(N);
  if (!BV)
    return false;

  if (!BV->isConstant())
    return false;

  for (unsigned I = 0, E = BV->getNumOperands(); I != E; ++I) {
    auto Op = BV->getOperand(I);
    if (Op->isUndef())
      continue;

    if (auto *CSDN = dyn_cast<ConstantSDNode>(Op)) {
      if (!isUIntN(B, CSDN->getSExtValue()))
        return false;
    } else
      return false;
  }
  return true;
}

bool KVX_LOW::isKVXSplat32ImmVec(llvm::SDNode *N, llvm::SelectionDAG *CurDag,
                                 bool SplatAt) {
  const BuildVectorSDNode *BV = dyn_cast<BuildVectorSDNode>(N);
  if (!BV)
    return false;

  if (!BV->isConstant())
    return false;

  auto VT = BV->getValueType(0);

  if (VT.getSizeInBits() > 64 || VT.getVectorNumElements() < 2 ||
      (VT.getSizeInBits() <= 32 && SplatAt))
    return false;

  if (VT.getSizeInBits() <= 32 && !SplatAt)
    return true;

  // From the start of 32 bits, check if the value is either
  // zero, for non-splat, for equals to the first half.
  // Undef is also accepted as a match in the second half.
  auto ElmCheck = 32 / VT.getVectorElementType().getSizeInBits();
  auto ElmEnd = BV->getNumOperands();
  bool IsFP = VT.isFloatingPoint();
  for (unsigned FirstHalf = 0; ElmCheck != ElmEnd; ++ElmCheck, ++FirstHalf) {
    auto SecondHalf = BV->getOperand(ElmCheck);
    if (SecondHalf.isUndef())
      continue;

    if (!SplatAt) {
      if (IsFP) {
        if ((cast<ConstantFPSDNode>(SecondHalf))->isZero())
          continue;
      } else if ((cast<ConstantSDNode>(SecondHalf))->isNullValue())
        continue;
      return false;
    }

    if (SecondHalf != BV->getOperand(FirstHalf))
      return false;
  }

  return true;
}

bool KVX_LOW::isExtended(llvm::SDNode *N, llvm::SelectionDAG *CurDag,
                         bool SignExt) {
  if (SignExt)
    switch (N->getOpcode()) {
    default: {
      auto Ones = CurDag->computeKnownBits(SDValue(N, 0)).Zero;
      return Ones.countLeadingOnes() >= Ones.getBitWidth() / 2;
    }
    case ISD::SIGN_EXTEND:
    case ISD::SIGN_EXTEND_INREG:
      return true;
    case ISD::LOAD:
      return cast<LoadSDNode>(N)->getExtensionType() == ISD::SEXTLOAD;
    }
  switch (N->getOpcode()) {
  default: {
    auto Zeros = CurDag->computeKnownBits(SDValue(N, 0)).Zero;
    return Zeros.countLeadingOnes() >= Zeros.getBitWidth() / 2;
  }
  case ISD::ZERO_EXTEND:
    return true;
  case ISD::LOAD:
    return cast<LoadSDNode>(N)->getExtensionType() == ISD::ZEXTLOAD;
  }
}
