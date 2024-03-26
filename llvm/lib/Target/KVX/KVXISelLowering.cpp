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
#include "KVXSubtarget.h"
#include "MCTargetDesc/KVXMCTargetDesc.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/CodeGen/CallingConvLower.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineJumpTableInfo.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/IntrinsicsKVX.h"
#include "llvm/Support/KnownBits.h"
#include "llvm/Target/TargetMachine.h"

using namespace llvm;

#define DEBUG_TYPE "KVXISelLowering"

STATISTIC(NumTailCalls, "Number of tail calls");

static cl::opt<int> MinimumJumpTablesEntries(
    "kvx-minimum-jump-tables-entries", cl::Hidden, cl::ZeroOrMore, cl::init(5),
    cl::desc("Set minimum jump tables entries count."), cl::cat(KVXclOpts));

static cl::opt<bool> UseVLIWSched("use-kvx-vliw-sched", cl::Hidden,
                                  cl::ZeroOrMore, cl::init(false),
                                  cl::desc("Use VLIW Scheduler."),
                                  cl::cat(KVXclOpts));

#include "KVXGenCallingConv.inc"

#ifndef NDEBUG
inline static StringRef getMVTName(const MVT &T) {
  switch (T.SimpleTy) {
  case MVT::Other:
    return "MVT::Other";
  case MVT::i1:
    return "MVT::i1";
  case MVT::i2:
    return "MVT::i2";
  case MVT::i4:
    return "MVT::i4";
  case MVT::i8:
    return "MVT::i8";
  case MVT::i16:
    return "MVT::i16";
  case MVT::i32:
    return "MVT::i32";
  case MVT::i64:
    return "MVT::i64";
  case MVT::i128:
    return "MVT::i128";
  case MVT::Any:
    return "MVT::Any";
  case MVT::iAny:
    return "MVT::iAny";
  case MVT::fAny:
    return "MVT::fAny";
  case MVT::vAny:
    return "MVT::vAny";
  case MVT::f16:
    return "MVT::f16";
  case MVT::bf16:
    return "MVT::bf16";
  case MVT::f32:
    return "MVT::f32";
  case MVT::f64:
    return "MVT::f64";
  case MVT::f80:
    return "MVT::f80";
  case MVT::f128:
    return "MVT::f128";
  case MVT::ppcf128:
    return "MVT::ppcf128";
  case MVT::x86mmx:
    return "MVT::x86mmx";
  case MVT::x86amx:
    return "MVT::x86amx";
  case MVT::Glue:
    return "MVT::Glue";
  case MVT::isVoid:
    return "MVT::isVoid";
  case MVT::v1i1:
    return "MVT::v1i1";
  case MVT::v2i1:
    return "MVT::v2i1";
  case MVT::v4i1:
    return "MVT::v4i1";
  case MVT::v8i1:
    return "MVT::v8i1";
  case MVT::v16i1:
    return "MVT::v16i1";
  case MVT::v32i1:
    return "MVT::v32i1";
  case MVT::v64i1:
    return "MVT::v64i1";
  case MVT::v128i1:
    return "MVT::v128i1";
  case MVT::v256i1:
    return "MVT::v256i1";
  case MVT::v512i1:
    return "MVT::v512i1";
  case MVT::v1024i1:
    return "MVT::v1024i1";
  case MVT::v2048i1:
    return "MVT::v2048i1";
  case MVT::v4096i1:
    return "MVT::v4096i1";
  case MVT::v1i8:
    return "MVT::v1i8";
  case MVT::v2i8:
    return "MVT::v2i8";
  case MVT::v4i8:
    return "MVT::v4i8";
  case MVT::v8i8:
    return "MVT::v8i8";
  case MVT::v16i8:
    return "MVT::v16i8";
  case MVT::v32i8:
    return "MVT::v32i8";
  case MVT::v64i8:
    return "MVT::v64i8";
  case MVT::v128i8:
    return "MVT::v128i8";
  case MVT::v256i8:
    return "MVT::v256i8";
  case MVT::v1i16:
    return "MVT::v1i16";
  case MVT::v2i16:
    return "MVT::v2i16";
  case MVT::v3i16:
    return "MVT::v3i16";
  case MVT::v4i16:
    return "MVT::v4i16";
  case MVT::v8i16:
    return "MVT::v8i16";
  case MVT::v16i16:
    return "MVT::v16i16";
  case MVT::v32i16:
    return "MVT::v32i16";
  case MVT::v64i16:
    return "MVT::v64i16";
  case MVT::v128i16:
    return "MVT::v128i16";
  case MVT::v1i32:
    return "MVT::v1i32";
  case MVT::v2i32:
    return "MVT::v2i32";
  case MVT::v3i32:
    return "MVT::v3i32";
  case MVT::v4i32:
    return "MVT::v4i32";
  case MVT::v5i32:
    return "MVT::v5i32";
  case MVT::v8i32:
    return "MVT::v8i32";
  case MVT::v16i32:
    return "MVT::v16i32";
  case MVT::v32i32:
    return "MVT::v32i32";
  case MVT::v64i32:
    return "MVT::v64i32";
  case MVT::v128i32:
    return "MVT::v128i32";
  case MVT::v256i32:
    return "MVT::v256i32";
  case MVT::v512i32:
    return "MVT::v512i32";
  case MVT::v1024i32:
    return "MVT::v1024i32";
  case MVT::v2048i32:
    return "MVT::v2048i32";
  case MVT::v1i64:
    return "MVT::v1i64";
  case MVT::v2i64:
    return "MVT::v2i64";
  case MVT::v4i64:
    return "MVT::v4i64";
  case MVT::v8i64:
    return "MVT::v8i64";
  case MVT::v16i64:
    return "MVT::v16i64";
  case MVT::v32i64:
    return "MVT::v32i64";
  case MVT::v64i64:
    return "MVT::v64i64";
  case MVT::v128i64:
    return "MVT::v128i64";
  case MVT::v256i64:
    return "MVT::v256i64";
  case MVT::v1i128:
    return "MVT::v1i128";
  case MVT::v2f16:
    return "MVT::v2f16";
  case MVT::v3f16:
    return "MVT::v3f16";
  case MVT::v4f16:
    return "MVT::v4f16";
  case MVT::v8f16:
    return "MVT::v8f16";
  case MVT::v16f16:
    return "MVT::v16f16";
  case MVT::v32f16:
    return "MVT::v32f16";
  case MVT::v64f16:
    return "MVT::v64f16";
  case MVT::v128f16:
    return "MVT::v128f16";
  case MVT::v2bf16:
    return "MVT::v2bf16";
  case MVT::v3bf16:
    return "MVT::v3bf16";
  case MVT::v4bf16:
    return "MVT::v4bf16";
  case MVT::v8bf16:
    return "MVT::v8bf16";
  case MVT::v16bf16:
    return "MVT::v16bf16";
  case MVT::v32bf16:
    return "MVT::v32bf16";
  case MVT::v64bf16:
    return "MVT::v64bf16";
  case MVT::v128bf16:
    return "MVT::v128bf16";
  case MVT::v1f32:
    return "MVT::v1f32";
  case MVT::v2f32:
    return "MVT::v2f32";
  case MVT::v3f32:
    return "MVT::v3f32";
  case MVT::v4f32:
    return "MVT::v4f32";
  case MVT::v5f32:
    return "MVT::v5f32";
  case MVT::v8f32:
    return "MVT::v8f32";
  case MVT::v16f32:
    return "MVT::v16f32";
  case MVT::v32f32:
    return "MVT::v32f32";
  case MVT::v64f32:
    return "MVT::v64f32";
  case MVT::v128f32:
    return "MVT::v128f32";
  case MVT::v256f32:
    return "MVT::v256f32";
  case MVT::v512f32:
    return "MVT::v512f32";
  case MVT::v1024f32:
    return "MVT::v1024f32";
  case MVT::v2048f32:
    return "MVT::v2048f32";
  case MVT::v1f64:
    return "MVT::v1f64";
  case MVT::v2f64:
    return "MVT::v2f64";
  case MVT::v4f64:
    return "MVT::v4f64";
  case MVT::v8f64:
    return "MVT::v8f64";
  case MVT::v16f64:
    return "MVT::v16f64";
  case MVT::v32f64:
    return "MVT::v32f64";
  case MVT::v64f64:
    return "MVT::v64f64";
  case MVT::v128f64:
    return "MVT::v128f64";
  case MVT::v256f64:
    return "MVT::v256f64";
  case MVT::nxv1i1:
    return "MVT::nxv1i1";
  case MVT::nxv2i1:
    return "MVT::nxv2i1";
  case MVT::nxv4i1:
    return "MVT::nxv4i1";
  case MVT::nxv8i1:
    return "MVT::nxv8i1";
  case MVT::nxv16i1:
    return "MVT::nxv16i1";
  case MVT::nxv32i1:
    return "MVT::nxv32i1";
  case MVT::nxv64i1:
    return "MVT::nxv64i1";
  case MVT::nxv1i8:
    return "MVT::nxv1i8";
  case MVT::nxv2i8:
    return "MVT::nxv2i8";
  case MVT::nxv4i8:
    return "MVT::nxv4i8";
  case MVT::nxv8i8:
    return "MVT::nxv8i8";
  case MVT::nxv16i8:
    return "MVT::nxv16i8";
  case MVT::nxv32i8:
    return "MVT::nxv32i8";
  case MVT::nxv64i8:
    return "MVT::nxv64i8";
  case MVT::nxv1i16:
    return "MVT::nxv1i16";
  case MVT::nxv2i16:
    return "MVT::nxv2i16";
  case MVT::nxv4i16:
    return "MVT::nxv4i16";
  case MVT::nxv8i16:
    return "MVT::nxv8i16";
  case MVT::nxv16i16:
    return "MVT::nxv16i16";
  case MVT::nxv32i16:
    return "MVT::nxv32i16";
  case MVT::nxv1i32:
    return "MVT::nxv1i32";
  case MVT::nxv2i32:
    return "MVT::nxv2i32";
  case MVT::nxv4i32:
    return "MVT::nxv4i32";
  case MVT::nxv8i32:
    return "MVT::nxv8i32";
  case MVT::nxv16i32:
    return "MVT::nxv16i32";
  case MVT::nxv32i32:
    return "MVT::nxv32i32";
  case MVT::nxv1i64:
    return "MVT::nxv1i64";
  case MVT::nxv2i64:
    return "MVT::nxv2i64";
  case MVT::nxv4i64:
    return "MVT::nxv4i64";
  case MVT::nxv8i64:
    return "MVT::nxv8i64";
  case MVT::nxv16i64:
    return "MVT::nxv16i64";
  case MVT::nxv32i64:
    return "MVT::nxv32i64";
  case MVT::nxv1f16:
    return "MVT::nxv1f16";
  case MVT::nxv2f16:
    return "MVT::nxv2f16";
  case MVT::nxv4f16:
    return "MVT::nxv4f16";
  case MVT::nxv8f16:
    return "MVT::nxv8f16";
  case MVT::nxv16f16:
    return "MVT::nxv16f16";
  case MVT::nxv32f16:
    return "MVT::nxv32f16";
  case MVT::nxv2bf16:
    return "MVT::nxv2bf16";
  case MVT::nxv4bf16:
    return "MVT::nxv4bf16";
  case MVT::nxv8bf16:
    return "MVT::nxv8bf16";
  case MVT::nxv1f32:
    return "MVT::nxv1f32";
  case MVT::nxv2f32:
    return "MVT::nxv2f32";
  case MVT::nxv4f32:
    return "MVT::nxv4f32";
  case MVT::nxv8f32:
    return "MVT::nxv8f32";
  case MVT::nxv16f32:
    return "MVT::nxv16f32";
  case MVT::nxv1f64:
    return "MVT::nxv1f64";
  case MVT::nxv2f64:
    return "MVT::nxv2f64";
  case MVT::nxv4f64:
    return "MVT::nxv4f64";
  case MVT::nxv8f64:
    return "MVT::nxv8f64";
  case MVT::token:
    return "MVT::token";
  case MVT::Metadata:
    return "MVT::Metadata";
  case MVT::iPTR:
    return "MVT::iPTR";
  case MVT::iPTRAny:
    return "MVT::iPTRAny";
  case MVT::Untyped:
    return "MVT::Untyped";
  case MVT::funcref:
    return "MVT::funcref";
  case MVT::externref:
    return "MVT::externref";
  default:
    llvm_unreachable("ILLEGAL VALUE TYPE!");
  }
}
#endif

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

  setBooleanVectorContents(ZeroOrNegativeOneBooleanContent);

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
  addRegisterClass(MVT::v8f16, &KVX::PairedRegRegClass);
  initializeTCARegisters();

  // Compute derived properties from the register classes
  computeRegisterProperties(Subtarget.getRegisterInfo());

  setStackPointerRegisterToSaveRestore(getSPReg());

  setMinFunctionAlignment(Align(64));
  setPrefFunctionAlignment(Align(64));
  setMinStackArgumentAlignment(Align(64));
  // TODO: VLIW allows better performances but not fully correct yet since
  // set/wfxm/wfxl builtins can be wrongly scheduled due to a SystemRegister
  // dependency issue, see T16482. Until we fix the VLIW scheduler to take into
  // account such kind of dependencies, a potential workaround could be to
  // switch back to VLIW by default and setting Source only when some assembly
  // inline is detected (since those builtins generate asm inline).
  if (UseVLIWSched)
    // Use -use-kvx-vliw-sched to keep old behavior.
    setSchedulingPreference(Sched::VLIW);
  else
    setSchedulingPreference(Sched::Source);

  initializeTCALowering();

  setOperationAction(ISD::TRAP, MVT::Other, Legal);

  const bool IsV1 = Subtarget.isV1();
  for (MVT VT : {MVT::i32, MVT::i64})
    for (auto I : {ISD::SDIV, ISD::SDIVREM, ISD::SREM, ISD::UDIV, ISD::UDIVREM,
                   ISD::UREM})
      setOperationAction(I, VT, LibCall);

  setLibcallName(RTLIB::SDIVREM_I32, "__divmodsi4");
  setLibcallName(RTLIB::UDIVREM_I32, "__udivmodsi4");
  setLibcallName(RTLIB::SDIVREM_I64, "__divmoddi4");
  setLibcallName(RTLIB::SDIVREM_I64, "__udivmoddi4");

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

  setOperationAction(ISD::EXTRACT_SUBVECTOR, MVT::v2i16, Legal);
  setOperationAction(ISD::EXTRACT_SUBVECTOR, MVT::v2f16, Legal);

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

  for (auto I : {ISD::CTTZ, ISD::CTLZ, ISD::CTPOP}) {
    // Dag combine will split vectors by half
    for (auto VT :
         {MVT::v4i8, MVT::v8i8, MVT::v4i16, MVT::v4i32, MVT::v2i64, MVT::v4i64})
      setOperationAction(I, VT, Expand);

    // These are native types
    for (auto VT : {MVT::v2i32, MVT::i64, MVT::i32})
      setOperationAction(I, VT, Legal);

    // CTPOP should be promoted
    // CTTZ and CTLZ have patterns as the promotion/extension are
    // produce inefficient code.
    for (auto VT : {MVT::v2i8, MVT::v2i16})
      if (I == ISD::CTPOP)
        setOperationPromotedToType(I, VT, MVT::v2i32);
      else
        setOperationAction(I, VT, Legal);
  }

  for (auto VT :
       {MVT::v4i64, MVT::v2i64, MVT::v4i32, MVT::v8i8, MVT::v2i8, MVT::v4i8}) {
    setOperationAction(ISD::SHL, VT, Expand);
    setOperationAction(ISD::SRL, VT, Expand);
    setOperationAction(ISD::SRA, VT, Expand);
  }

  setOperationAction(ISD::SHL, MVT::v8i8, Custom);
  setOperationAction(ISD::SRL, MVT::v8i8, Custom);
  setOperationAction(ISD::ROTL, MVT::v8i8, Custom);
  setOperationAction(ISD::ROTR, MVT::v8i8, Custom);

  setOperationPromotedToType(ISD::SHL, MVT::v4i8, MVT::v4i16);
  setOperationPromotedToType(ISD::SRL, MVT::v4i8, MVT::v4i16);
  setOperationPromotedToType(ISD::SRA, MVT::v4i8, MVT::v4i16);

  for (auto VT : {MVT::v2f64, MVT::v2i64, MVT::v4f64, MVT::v4i64, MVT::v8i8})
    setOperationAction(ISD::SETCC, VT, Expand);

  for (auto VT : {MVT::v4i32, MVT::v4f32, MVT::v8f16})
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
                  MVT::v2i64, MVT::v4f64, MVT::v4i64, MVT::v8f16}) {
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

  for (auto VT :
       {MVT::f16, MVT::f32, MVT::f64, MVT::v2f16, MVT::v2f32, MVT::v4f16}) {
    // See: T14224.
    setOperationAction(ISD::FMAXNUM, VT, Legal);
    setOperationAction(ISD::FMINNUM, VT, Legal);
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
                  MVT::v2f64, MVT::v4f16, MVT::v4f32, MVT::v4f64, MVT::v8f16}) {
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
  setOperationAction(ISD::FDIV, MVT::f16, Promote);
  setOperationAction(ISD::FSQRT, MVT::f16, Promote);

  for (auto VT :
       {MVT::v2f16, MVT::v2f32, MVT::v2f64, MVT::v2i8, MVT::v2i16, MVT::v2i32,
        MVT::v2i64, MVT::v4f16, MVT::v4f32, MVT::v4f64, MVT::v4i8, MVT::v4i16,
        MVT::v4i32, MVT::v4i64, MVT::v8i8, MVT::v8f16}) {
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

  setOperationAction(ISD::FP_ROUND, MVT::v2f32, Legal);
  setOperationAction(ISD::FP_ROUND, MVT::v4f32, Legal);

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

  for (auto I :
       {ISD::FP_TO_SINT, ISD::FP_TO_UINT, ISD::SINT_TO_FP, ISD::UINT_TO_FP}) {
    setOperationPromotedToType(I, MVT::v2i16, MVT::v2i32);
    setOperationPromotedToType(I, MVT::v4i16, MVT::v4i32);
  }

  for (auto I : {ISD::ABS, ISD::ADD, ISD::FP_TO_SINT, ISD::FP_TO_UINT, ISD::MUL,
                 ISD::SETCC, ISD::SINT_TO_FP, ISD::SMAX, ISD::SMIN, ISD::SUB,
                 ISD::UINT_TO_FP, ISD::UMAX, ISD::UMIN, ISD::VSELECT}) {
    setOperationPromotedToType(I, MVT::v2i8, MVT::v2i16);
    setOperationPromotedToType(I, MVT::v4i8, MVT::v4i16);
  }

  for (auto I :
       {ISD::ABS, ISD::ADD, ISD::FP_TO_SINT, ISD::FP_TO_UINT, ISD::SETCC,
        ISD::SINT_TO_FP, ISD::SUB, ISD::UINT_TO_FP, ISD::VSELECT})
    setOperationPromotedToType(I, MVT::v8i8, MVT::v8i16);

  for (auto I : {ISD::ABS, ISD::ADD, ISD::SUB})
    setOperationAction(I, MVT::v8i8, Legal);

  for (auto VT : {MVT::v2i64, MVT::v4i64})
    for (auto I : {ISD::AND, ISD::OR, ISD::XOR, ISD::ADD, ISD::SUB, ISD::MUL})
      setOperationAction(I, VT, Expand);

  for (auto VT : {MVT::v2i32, MVT::v4i32})
    for (auto I : {ISD::ADD, ISD::MUL, ISD::SUB, ISD::AND, ISD::OR, ISD::XOR})
      setOperationAction(I, VT, Legal);

  setOperationAction(ISD::ADD, MVT::v2i64, Custom);
  setOperationAction(ISD::SUB, MVT::v2i64, Custom);
  setOperationAction(ISD::ATOMIC_FENCE, MVT::Other, Custom);

  for (auto VT : {MVT::i32, MVT::i64, MVT::v2i16, MVT::v2i32, MVT::v4i16})
    setOperationAction(ISD::SSHLSAT, VT, Legal);

  setOperationAction(ISD::USHLSAT, MVT::i32, Legal);

  for (auto I : {ISD::ABS, ISD::SMAX, ISD::SMIN, ISD::UMAX, ISD::UMIN})
    setOperationAction(I, MVT::v4i32, Legal);

  if (!IsV1) {
    for (auto VT : {MVT::i32, MVT::i64, MVT::v2i8, MVT::v2i16, MVT::v2i32,
                    MVT::v4i8, MVT::v4i16, MVT::v8i8})
      for (auto I : {ISD::ABS, ISD::ADD, ISD::SADDSAT, ISD::SETCC, ISD::SMAX,
                     ISD::SMIN, ISD::SHL, ISD::SRA, ISD::SRL, ISD::SSHLSAT,
                     ISD::SSUBSAT, ISD::SUB, ISD::UADDSAT, ISD::UMAX, ISD::UMIN,
                     ISD::USHLSAT, ISD::USUBSAT, ISD::VSELECT})
        setOperationAction(I, VT, Legal);

    for (auto I : {ISD::ABS, ISD::ADD, ISD::SETCC, ISD::SHL, ISD::SRA, ISD::SRL,
                   ISD::SSHLSAT, ISD::SUB, ISD::UADDSAT, ISD::USHLSAT,
                   ISD::USUBSAT, ISD::VSELECT})
      setOperationAction(I, MVT::v8i8, Legal);

    setOperationAction(ISD::MULHU, MVT::v4i32, Legal);
    setOperationAction(ISD::MULHS, MVT::v4i32, Legal);

  } else {
    // Fall-back to hq in cv1 using dag-combine
    for (auto I : {ISD::FMA, ISD::FMUL, ISD::FSUB, ISD::FNEG, ISD::FADD})
      setOperationAction(I, MVT::v8f16, Expand);
  }
  for (auto I : {ISD::SDIV, ISD::SREM, ISD::SDIVREM, ISD::UDIV, ISD::UREM,
                 ISD::UDIVREM}) {
    for (MVT VT : {MVT::v2i8, MVT::v4i8, MVT::v8i8})
      setOperationAction(I, VT, Expand);

    for (MVT VT : {MVT::v4i16})
      setOperationAction(I, VT, Custom);
  }

  // Fall-back to hq using dag-combine
  for (auto I : {ISD::FABS, ISD::FCOPYSIGN})
    setOperationAction(I, MVT::v8f16, Expand);

  setOperationAction(ISD::SETCC, MVT::v8f16, Custom);
  setOperationAction(ISD::INSERT_VECTOR_ELT, MVT::v8f16, Legal);
  setOperationAction(ISD::CONCAT_VECTORS, MVT::v8f16, Legal);
  setOperationAction(ISD::EXTRACT_VECTOR_ELT, MVT::v8f16, Legal);
  setOperationAction(ISD::SELECT, MVT::v8f16, Custom);

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
                  MVT::v8i16, MVT::v16i8})
    setOperationAction(ISD::LOAD, VT, Custom);

  setMaxAtomicSizeInBitsSupported(64);
  setMinCmpXchgSizeInBits(32);

  setMinimumJumpTableEntries(MinimumJumpTablesEntries);

  setOperationAction(ISD::UINT_TO_FP, MVT::i64, Custom);
  setOperationAction(ISD::SINT_TO_FP, MVT::i64, Custom);

  setOperationAction(ISD::ADDRSPACECAST, MVT::i64, Custom);
  setOperationAction(ISD::DYNAMIC_STACKALLOC, MVT::i64,
                     hasStackLimitRegister() ? Custom : Expand);

  for (auto VT :
       {MVT::v2i16, MVT::v4i16, MVT::i32, MVT::v2i32, MVT::i64, MVT::v8i8})
    setOperationAction(ISD::SADDSAT, VT, Legal);

  for (auto VT : {MVT::v2i32, MVT::v2i8, MVT::v4i8, MVT::v8i8})
    setOperationAction(ISD::UADDSAT, VT, Legal);

  for (auto I : {MVT::v8i8, MVT::v4i16, MVT::v2i16, MVT::v2i32, MVT::i32,
                 MVT::i64, MVT::v4i32})
    setOperationAction(ISD::SSUBSAT, I, Legal);

  for (auto I : {MVT::v8i8, MVT::v2i32, MVT::v4i32})
    setOperationAction(ISD::USUBSAT, I, Legal);

  for (auto I :
       {ISD::AVGFLOORS, ISD::AVGFLOORU, ISD::AVGCEILS, ISD::AVGCEILU}) {
    for (auto VT : {MVT::i32, MVT::v2i16, MVT::v2i32, MVT::v4i16})
      setOperationAction(I, VT, Legal);

    auto Action = IsV1 ? Promote : Legal;
    for (auto VT : {MVT::v2i8, MVT::v4i8, MVT::v8i8})
      setOperationAction(I, VT, Action);
  }

  for (MVT VT : {MVT::v4i8, MVT::v8i8, MVT::v4i16, MVT::v4f16, MVT::v8f16,
                 MVT::v4f64, MVT::v4i64})
    setOperationAction(ISD::INSERT_SUBVECTOR, VT, Legal);

  // In CV1, fall back to hq with specialized patterns
  for (auto I : {ISD::SMAX, ISD::SMIN, ISD::UMAX, ISD::UMIN, ISD::MUL,
                 ISD::SADDSAT, ISD::SSUBSAT})
    setOperationAction(I, MVT::v8i8, Legal);

  setOperationAction(ISD::INTRINSIC_W_CHAIN, MVT::Other, Custom);
  setOperationAction(ISD::INTRINSIC_WO_CHAIN, MVT::Other, Custom);
  setOperationAction(ISD::INTRINSIC_VOID, MVT::Other, Custom);

  setOperationAction(ISD::EH_SJLJ_LONGJMP, MVT::Other, Custom);
  setOperationAction(ISD::EH_SJLJ_SETJMP, MVT::i32, Custom);
  setOperationAction(ISD::EH_SJLJ_SETUP_DISPATCH, MVT::Other, Custom);

  auto RedAction = IsV1 ? Expand : Legal;
  for (MVT VT : {MVT::v2i8, MVT::v4i8, MVT::v8i8, MVT::v2i16, MVT::v4i16,
                 MVT::v2i32, MVT::v4i32})
    for (auto I :
         {ISD::VECREDUCE_ADD, ISD::VECREDUCE_AND, ISD::VECREDUCE_OR,
          ISD::VECREDUCE_SMAX, ISD::VECREDUCE_SMIN, ISD::VECREDUCE_UMAX,
          ISD::VECREDUCE_UMIN, ISD::VECREDUCE_XOR})
      setOperationAction(I, VT, RedAction);

  for (auto I : {ISD::BUILD_VECTOR,
                 ISD::CTLZ,
                 ISD::CTPOP,
                 ISD::CTTZ,
                 ISD::FABS,
                 ISD::FADD,
                 ISD::FCOPYSIGN,
                 ISD::FMA,
                 ISD::FMUL,
                 ISD::FNEG,
                 ISD::FSUB,
                 ISD::INTRINSIC_WO_CHAIN,
                 ISD::LOAD,
                 ISD::MUL,
                 ISD::SDIV,
                 ISD::SDIVREM,
                 ISD::SETCC,
                 ISD::SHL,
                 ISD::SIGN_EXTEND,
                 ISD::SRA,
                 ISD::SREM,
                 ISD::SRL,
                 ISD::STORE,
                 ISD::TRUNCATE,
                 ISD::UDIV,
                 ISD::UDIVREM,
                 ISD::UREM,
                 ISD::VECREDUCE_ADD,
                 ISD::ZERO_EXTEND})
    setTargetDAGCombine(I);

  setLibcallName(RTLIB::UNWIND_RESUME, "_Unwind_SjLj_Resume");
}

EVT KVXTargetLowering::getSetCCResultType(const DataLayout &DL, LLVMContext &C,
                                          EVT VT) const {
  LLVM_DEBUG(dbgs() << "Obtaining setcc result type for: "
                    << getMVTName(VT.getSimpleVT()) << '\n');
  if (!VT.isVector())
    return MVT::i32;
  return EVT::getVectorVT(
      C, VT.getIntegerVT(C, VT.getVectorElementType().getSizeInBits()),
      VT.getVectorNumElements());
}

const char *KVXTargetLowering::getTargetNodeName(unsigned Opcode) const {
#define TARGET_NODE_CASE(NAME)                                                 \
  case KVXISD::NAME:                                                           \
    return "KVXISD::" #NAME;

  switch (Opcode) {
    TARGET_NODE_CASE(RET)
    TARGET_NODE_CASE(CALL)
    TARGET_NODE_CASE(AddrWrapper)
    TARGET_NODE_CASE(PICInternIndirection)
    TARGET_NODE_CASE(PICExternIndirection)
    TARGET_NODE_CASE(PICPCRelativeGOTAddr)
    TARGET_NODE_CASE(TAIL)
    TARGET_NODE_CASE(GetSystemReg)
    TARGET_NODE_CASE(COMP)
    TARGET_NODE_CASE(BRCOND)
    TARGET_NODE_CASE(EH_SJLJ_LONGJMP)
    TARGET_NODE_CASE(EH_SJLJ_SETUP_DISPATCH)
    TARGET_NODE_CASE(FENCE)
    TARGET_NODE_CASE(SEXT_MUL)
    TARGET_NODE_CASE(SRS)
    TARGET_NODE_CASE(SRSNEG)
    TARGET_NODE_CASE(SZ_MUL)
    TARGET_NODE_CASE(SZEXT_MUL)
    TARGET_NODE_CASE(VECREDUCE_ADD_SEXT)
    TARGET_NODE_CASE(VECREDUCE_ADD_ZEXT)
    TARGET_NODE_CASE(ZEXT_MUL)
  default:
    return NULL;
  }
}

MVT KVXTargetLowering::getRegisterTypeForCallingConv(LLVMContext &Context,
                                                     CallingConv::ID CC,
                                                     EVT VT) const {
  LLVM_DEBUG(dbgs() << "KVX CC: Get register type for: "
                    << (VT.isSimple() ? getMVTName(VT.getSimpleVT())
                                      : "Not a simple type")
                    << '\n');
  if (VT.isVector()) {
    if (VT.getVectorNumElements() == 1) {
      LLVM_DEBUG(dbgs() << "KVX CC: A vector of 1 element is like a scalar.\n");
      VT = VT.getScalarType();
    } else {
      LLVM_DEBUG(dbgs() << "KVX CC: It's a vector type, let the vector "
                           "breakdown solve that.\n");
      EVT IVT;
      MVT RVT;
      unsigned Ni;
      getVectorTypeBreakdownForCallingConv(Context, CC, VT, IVT, Ni, RVT);
      LLVM_DEBUG(dbgs() << "CC Reg type: " << getMVTName(RVT) << "\n");
      return RVT;
    }
  }
  if (VT.getSizeInBits() > 64) {
    LLVM_DEBUG(dbgs() << "CC type is larger than 64bits, use MVT::i64.\n");
    return MVT::i64;
  }
  if (isTypeLegal(VT)) {
    assert(VT.isSimple() && "CC: Legal type that is not simple!");
    LLVM_DEBUG(dbgs() << "CC: Legal type smaller-equals to 64 bits. Use it.\n");
    return VT.getSimpleVT();
  }
  if (!VT.isSimple()) {
    LLVM_DEBUG(
        dbgs() << "CC: Not a simple type, use i64 for register value.\n");
    return MVT::i64;
  }
  const auto SVT = VT.getSimpleVT();
  if (SVT == MVT::i1 || SVT == MVT::i8 || SVT == MVT::i16) {
    LLVM_DEBUG(dbgs() << "CC: MVT::i1/i8/i16 are passed as a MVT::i32.\n");
    return MVT::i32;
  }
  LLVM_DEBUG(dbgs() << "CC type fits in 64bits, use it.\n");
  return VT.getSimpleVT();
}

unsigned KVXTargetLowering::getNumRegistersForCallingConv(LLVMContext &Context,
                                                          CallingConv::ID CC,
                                                          EVT VT) const {
  if (VT.isVector()) {
    LLVM_DEBUG(dbgs() << "CC NumRegs: Vector type,"
                         " check in the Vector Breakdown.\n");
    EVT IVT;
    MVT RVT;
    unsigned Ni;
    unsigned Parts =
        getVectorTypeBreakdownForCallingConv(Context, CC, VT, IVT, Ni, RVT);
    LLVM_DEBUG(dbgs() << "CC NumRegs: " << Parts << "\n");
    return Parts;
  }

  if (!VT.isSimple()) {
    LLVM_DEBUG(dbgs() << "CC NumRegs: Not a simple type,"
                         " use default hander.\n");
    return TargetLowering::getNumRegistersForCallingConv(Context, CC, VT);
  }

  LLVM_DEBUG(dbgs() << "KVX CC: Discover number of regs for "
                    << getMVTName(VT.getSimpleVT()) << '\n');
  const TargetRegisterInfo *TRI = Subtarget.getRegisterInfo();
  unsigned RegSize = TRI->getRegSizeInBits(KVX::SingleRegRegClass);
  return (VT.getSizeInBits() + (RegSize - 1)) / RegSize;
}

unsigned KVXTargetLowering::getVectorTypeBreakdownForCallingConv(
    LLVMContext &Context, CallingConv::ID CC, EVT VT, EVT &IntermediateVT,
    unsigned &NumIntermediates, MVT &RegisterVT) const {
  assert(VT.isVector() && "CC: vector breakdown for a non vector type!\n");
  if (VT.getVectorNumElements() == 1) {
    LLVM_DEBUG(dbgs() << "KVX CC vector type breakdown: "
                      << " a vector of 1 element is just the element.\n");
    VT = VT.getScalarType();
    NumIntermediates = getNumRegistersForCallingConv(Context, CC, VT);
    RegisterVT = getRegisterType(Context, VT);
    IntermediateVT = EVT(RegisterVT);
    return NumIntermediates;
  }
  if (VT.getScalarType() == MVT::i1) {
    LLVM_DEBUG(dbgs() << "KVX CC vector type breakdown:"
                      << " i1 vectors are transformed to i8.\n");
    return getVectorTypeBreakdownForCallingConv(
        Context, CC,
        EVT::getVectorVT(Context, MVT::i8, VT.getVectorNumElements()),
        IntermediateVT, NumIntermediates, RegisterVT);
  }

  if (!VT.isSimple()) {
    auto SVT = VT.getScalarType();
    IntermediateVT = MVT::i64;
    if (SVT.getSizeInBits() == 64 && isTypeLegal(SVT)) {
      IntermediateVT = SVT;
      LLVM_DEBUG(
          dbgs() << "KVX CC vector type breakdown: can use element type.\n");
    } else if (SVT.getSizeInBits() < 64) {
      auto SubVT = EVT::getVectorVT(Context, SVT,
                                    ElementCount::getFixed(std::min(
                                        VT.getVectorNumElements(),
                                        (unsigned)(64 / SVT.getSizeInBits()))));
      if (isTypeLegal(SubVT)) {
        IntermediateVT = SubVT;
        LLVM_DEBUG(dbgs() << "KVX CC vector type breakdown: can use 64 bit "
                             "sub-vector type.\n");
      }
    } else {
      LLVM_DEBUG(
          dbgs() << "KVX CC vector type breakdown: Not a simple type vector "
                    "or suitable element/subvector, use i64 register type.\n");
    }
    NumIntermediates = (VT.getSizeInBits() + 63U) / 64U;
    RegisterVT = IntermediateVT.getSimpleVT();
    LLVM_DEBUG(dbgs() << "Number of parts: " << NumIntermediates << '\n');
    return NumIntermediates;
  }

  if (!VT.isPow2VectorType() && (VT.getSizeInBits() % 64)) {
    VT = VT.getPow2VectorType(Context);
    LLVM_DEBUG(
        dbgs() << "CC vector type has a non-power of 2 number of elements "
                  "smaller than 64 bits, using this value instead: "
               << getMVTName(VT.getSimpleVT()) << '\n');
  }

  LLVM_DEBUG(dbgs() << "KVX CC vector type breakdown for: "
                    << getMVTName(VT.getSimpleVT()) << '\n');
  if (VT.getSizeInBits() <= 64) {
    if (!isTypeLegal(VT)) {
      LLVM_DEBUG(dbgs() << "Not a legal type. Let generic code handle it.\n");
      auto Parts = TargetLowering::getVectorTypeBreakdownForCallingConv(
          Context, CC, VT, IntermediateVT, NumIntermediates, RegisterVT);
      LLVM_DEBUG(dbgs() << "Number of parts: " << Parts << '\n');
      return Parts;
    }
    LLVM_DEBUG(dbgs() << "Type fits in a SingleReg. Use just it.\n");
    IntermediateVT = VT;
    RegisterVT = VT.getSimpleVT();
    NumIntermediates = 1;
    return 1;
  }
  if (VT.getScalarSizeInBits() == 64) {
    LLVM_DEBUG(dbgs() << "Scalarize vector of 64 bits sized elements.\n");
    IntermediateVT = VT.getScalarType();
    RegisterVT = IntermediateVT.getSimpleVT();
    NumIntermediates = VT.getVectorNumElements();
    return NumIntermediates;
  }
  if (VT.getScalarSizeInBits() > 64) {
    LLVM_DEBUG(dbgs() << "Scalarize vector of elements larger than 64 bits.\n");
    RegisterVT = MVT::i64;
    IntermediateVT = EVT(MVT::i64);
    NumIntermediates = (VT.getSizeInBits() + 63) / 64;
    return NumIntermediates;
  }
  LLVM_DEBUG(dbgs() << "Split into smaller vectors.\n");
  IntermediateVT = EVT::getVectorVT(Context, VT.getScalarType(),
                                    64 / VT.getScalarSizeInBits());
  RegisterVT = IntermediateVT.getSimpleVT();
  NumIntermediates = (VT.getSizeInBits() + 63) / 64;
  LLVM_DEBUG(dbgs() << "IntermediateVT: "
                    << getMVTName(IntermediateVT.getSimpleVT())
                    << "\nRegisterVT: " << getMVTName(RegisterVT)
                    << "\nNumIntermediates: " << NumIntermediates << '\n');
  return NumIntermediates;
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

  unsigned InIdx = 0;
  KVXMachineFunctionInfo *KVXFI = MF.getInfo<KVXMachineFunctionInfo>();
  MachineFrameInfo &MFI = MF.getFrameInfo();

  LLVM_DEBUG(dbgs() << "KVXTargetLowering::LowerFormalArguments "
                    << ArgLocs.size() << " arguments to lower.\n");
  LLVM_DEBUG(dbgs() << "IsVarArg? " << IsVarArg << '\n');

  for (auto &VA : ArgLocs) {
    LLVM_DEBUG(dbgs() << "Argument LocInfo: " << VA.getLocInfo() << '\n');
    if (VA.isRegLoc()) {
      EVT RegVT = VA.getLocVT();
#ifndef NDEBUG
      LLVM_DEBUG(dbgs() << "Argument passed in register.\n");
      if (RegVT.isSimple())
        LLVM_DEBUG(dbgs() << "Argument type: "
                          << getMVTName(RegVT.getSimpleVT()) << '\n');
#endif

      unsigned VReg;
      VReg = RegInfo.createVirtualRegister(&KVX::SingleRegRegClass);

      if (Ins[InIdx].Flags.isSRet())
        KVXFI->setSRETReg(VReg);

      RegInfo.addLiveIn(VA.getLocReg(), VReg);
      SDValue ArgIn = DAG.getCopyFromReg(Chain, DL, VReg, RegVT);
      LLVM_DEBUG(dbgs() << "Create copy to virtual reg: ");
      LLVM_DEBUG(ArgIn.dump());
      InVals.push_back(ArgIn);
      ++InIdx;
      continue;
    }

    assert(VA.isMemLoc());
    LLVM_DEBUG(dbgs() << "Argument passed in memory.\n");

    unsigned Offset = VA.getLocMemOffset();
    unsigned StoreSize = VA.getValVT().getStoreSize();
    int FI = MFI.CreateFixedObject(StoreSize, Offset, false);
    InVals.push_back(
        DAG.getLoad(VA.getValVT(), DL, Chain,
                    DAG.getFrameIndex(FI, getPointerTy(MF.getDataLayout())),
                    MachinePointerInfo::getFixedStack(MF, FI)));

  }

  if (IsVarArg) {
    ArrayRef<MCPhysReg> ArgRegs = makeArrayRef(ArgGPRs);
    unsigned Idx = CCInfo.getFirstUnallocated(ArgRegs);
    int VarArgsOffset = CCInfo.getNextStackOffset();
    int VarArgsSaveSize = 0;
    const unsigned ArgRegsSize = ArgRegs.size();
    int FI;

    if (Idx >= ArgRegsSize) {
      FI = MFI.CreateFixedObject(8, VarArgsOffset, true);
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

  // All stores are grouped in one node to allow the matching between
  // the size of Ins and InVals. This only happens for vararg functions.
  if (!OutChains.empty()) {
    OutChains.push_back(Chain);
    Chain = DAG.getNode(ISD::TokenFactor, DL, MVT::Other, OutChains);
  }
  LLVM_DEBUG(DAG.dump());

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

SDValue KVXTargetLowering::LowerOperation(SDValue Op, SelectionDAG &DAG) const {
  const unsigned Opcode = Op.getOpcode();
  switch (Opcode) {
  default:
    report_fatal_error("unimplemented operand");
  case KVXISD::VECREDUCE_ADD_SEXT:
  case KVXISD::VECREDUCE_ADD_ZEXT: {
    auto Op0 = Op->getOperand(0);
    EVT IVT = Op0->getValueType(0);
    if (!IVT.isPow2VectorType())
      return SDValue();

    if (IVT.getFixedSizeInBits() <= 64)
      return Op;

    SDLoc Loc = SDLoc(Op);
    auto Halfs = DAG.SplitVector(Op0, Loc);
    auto VT = Op->getValueType(0);
    if (!Halfs.first->getValueType(0).isVector())
      return DAG.getNode(ISD::ADD, Loc, VT, {Halfs.first, Halfs.second});

    auto Lower = DAG.getNode(Opcode, Loc, VT, Halfs.first);
    auto Upper = DAG.getNode(Opcode, Loc, VT, Halfs.second);
    SDValue R = DAG.getNode(ISD::ADD, Loc, VT, {Lower, Upper});
    return R;
  }
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
  case ISD::SPLAT_VECTOR:
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
  case ISD::FDIV: {
    if (Op.getNode()->getFlags().hasAllowReciprocal())
      return Op;

    if (auto *FPN = dyn_cast<ConstantFPSDNode>(Op.getOperand(0))) {
      auto &APF = FPN->getValueAPF();
      if (APF.isExactlyValue(1.0) || APF.isExactlyValue(-1.0))
        return Op;
    }

    return SDValue();
  }
  case ISD::FSQRT:
    if (Op.getNode()->getFlags().hasAllowReciprocal())
      return Op;
    return SDValue();
  case ISD::DYNAMIC_STACKALLOC:
    return lowerStackCheckAlloca(Op, DAG);
  case ISD::SMUL_LOHI:
  case ISD::UMUL_LOHI:
    return lowerMulExtend(Op.getOpcode(), Op, DAG);

  case ISD::ROTL:
  case ISD::ROTR:
  case ISD::SHL:
  case ISD::SRA:
  case ISD::SRL:
  case ISD::SSHLSAT:
  case ISD::USHLSAT: {
    if (!(Op.getValueType().isSimple()))
      return SDValue();

    auto VT = Op.getSimpleValueType();
    if (VT.getSizeInBits() < 8)
      return SDValue();

    auto N1 = Op.getOperand(1);

    bool Ok = (N1.getOpcode() == ISD::SPLAT_VECTOR);
    unsigned EltSize = VT.getScalarSizeInBits();
    if (!Ok && N1.getOpcode() == ISD::VECTOR_SHUFFLE) {
      auto *SV = cast<ShuffleVectorSDNode>(N1);
      Ok = (SV->isSplat() || SV->isUndef());
    }
    if (!Ok && N1.getOpcode() == ISD::BUILD_VECTOR) {
      auto *BV = cast<BuildVectorSDNode>(N1);
      Ok = (BV->getSplatValue() != SDValue() ||
            (BV->isConstant() && Op->getOpcode() == ISD::SHL && EltSize > 8));
    }
    auto *Node = Op.getNode();
    if (!Ok)
      return DAG.UnrollVectorOp(Node, 0);

    if (VT.getFixedSizeInBits() <= 64)
      return Op;

    if (EltSize == 64)
      return DAG.UnrollVectorOp(Node, 0);

    return DAG.UnrollVectorOp(Node, 64 / EltSize);
  }
  case ISD::INTRINSIC_W_CHAIN:
    return LowerINTRINSIC(Op, DAG, &Subtarget, true);
  case ISD::INTRINSIC_VOID:
    return LowerINTRINSIC(Op, DAG, &Subtarget, Op->getNumValues());
  case ISD::INTRINSIC_WO_CHAIN:
    return LowerINTRINSIC(Op, DAG, &Subtarget, false);
  case ISD::EH_SJLJ_LONGJMP:
    return DAG.getNode(KVXISD::EH_SJLJ_LONGJMP, SDLoc(Op), MVT::Other,
                       Op.getOperand(0), Op.getOperand(1));
  case ISD::EH_SJLJ_SETJMP:
    return DAG.getNode(KVXISD::EH_SJLJ_SETJMP, SDLoc(Op),
                       DAG.getVTList(MVT::i32, MVT::Other), Op.getOperand(0),
                       Op.getOperand(1));
  case ISD::EH_SJLJ_SETUP_DISPATCH:
    return DAG.getNode(KVXISD::EH_SJLJ_SETUP_DISPATCH, SDLoc(Op), MVT::Other,
                       Op.getOperand(0));
  case ISD::SELECT: {
    if (!Op.getOperand(0).getValueType().isVector())
      return Op;
    LLVM_FALLTHROUGH;
  }
  case ISD::SETCC: {
    auto Evt = Op->getValueType(0);
    if (!Evt.isSimple())
      return SDValue();

    if (!Evt.isVector())
      return Op;

    const auto Sz = Evt.getSizeInBits();
    if (Sz <= 64)
      return Op;

    // Split vector op
    return DAG.UnrollVectorOp(Op.getNode(), Sz / 64);
  }
  case ISD::SDIV: {
    const LibCalls Sdivs = {
        {MVT::v4i16, "__divv4hi3"},
        {MVT::v8i16, "__divv8hi3"},
        {MVT::v16i16, "__divv16hi3"},
        {MVT::v8i32, "__divv8si3"},
    };
    return expandDivRemLibCall(Sdivs, Op, true, DAG);
  }
  case ISD::SREM: {
    const LibCalls Srems = {
        {MVT::v4i16, "__modv4hi3"},
        {MVT::v8i16, "__modv8hi3"},
        {MVT::v16i16, "__modv16hi3"},
        {MVT::v8i32, "__modv8si3"},
    };
    return expandDivRemLibCall(Srems, Op, true, DAG);
  }
  case ISD::UDIV: {
    const LibCalls Udivs = {
        {MVT::v4i16, "__udivv4hi3"},
        {MVT::v8i16, "__udivv8hi3"},
        {MVT::v16i16, "__udivv16hi3"},
        {MVT::v8i32, "__udivv8si3"},
    };
    return expandDivRemLibCall(Udivs, Op, true, DAG);
  }
  case ISD::UREM: {
    const LibCalls Urems = {
        {MVT::v4i16, "__umodv4hi3"},
        {MVT::v8i16, "__umodv8hi3"},
        {MVT::v16i16, "__umodv16hi3"},
        {MVT::v8i32, "__umodv8si3"},
    };
    return expandDivRemLibCall(Urems, Op, true, DAG);
  }
  }
}

bool KVXTargetLowering::shouldSplitVecBinOp(const unsigned Opc,
                                            const EVT VT) const {
  switch (Opc) {
  case ISD::SDIV:
  case ISD::UDIV:
  case ISD::SREM:
  case ISD::UREM:
  case ISD::SDIVREM:
  case ISD::UDIVREM: {
    if (VT == EVT(MVT::v4i16) || VT == EVT(MVT::v8i16) ||
        VT == EVT(MVT::v16i16) || VT == EVT(MVT::v8i32))
      return false;
  }
  }
  return true;
}

bool KVXTargetLowering::shouldProduceDivRem(const unsigned Opc,
                                            const EVT VT) const {
  return !shouldSplitVecBinOp(Opc, VT);
}

SDValue KVXTargetLowering::lowerMulExtend(const unsigned Opcode, SDValue Op,
                                          SelectionDAG &DAG) const {
  if (Op->getValueType(0).getSimpleVT() != MVT::i64)
    return SDValue();

  SDLoc Loc(Op);
  unsigned TargetInstruction = 0;
  SDValue Op1;
  auto *CN = dyn_cast<ConstantSDNode>(Op->getOperand(1));
  if (Opcode == ISD::SMUL_LOHI) {
    if (CN != nullptr && Subtarget.isV1()) {
      const APInt &AP = CN->getAPIntValue();
      unsigned NB = AP.getMinSignedBits();
      Op1 = DAG.getTargetConstant(AP.getSExtValue(), Loc, MVT::i64);
      TargetInstruction =
          GetImmOpCode(NB, KVX::MULDTri10, KVX::MULDTri37, KVX::MULDTri64);
    } else {
      TargetInstruction = KVX::MULDTrr;
      Op1 = Op.getOperand(1);
    }
  } else if (CN != nullptr && Subtarget.isV1()) {
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
  SDValue SubIdx0 = DAG.getTargetConstant(KVX::sub_d0, Loc, MVT::i32);
  SDValue SubIdx1 = DAG.getTargetConstant(KVX::sub_d1, Loc, MVT::i32);
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

Instruction *KVXTargetLowering::emitLeadingFence(IRBuilderBase &Builder,
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
  switch (Ord) {
  case AtomicOrdering::NotAtomic:
  case AtomicOrdering::Unordered:
  case AtomicOrdering::Monotonic:
  case AtomicOrdering::Acquire:
    return nullptr; // Nothing to do
  case AtomicOrdering::SequentiallyConsistent:
  case AtomicOrdering::Release:
  case AtomicOrdering::AcquireRelease:
    return Builder.CreateFence(Ord);
  }
}

Instruction *KVXTargetLowering::emitTrailingFence(IRBuilderBase &Builder,
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
  switch (Ord) {
  case AtomicOrdering::NotAtomic:
  case AtomicOrdering::Unordered:
  case AtomicOrdering::Monotonic:
  case AtomicOrdering::Release:
    return nullptr; // Nothing to do
  case AtomicOrdering::Acquire:
  case AtomicOrdering::AcquireRelease:
  case AtomicOrdering::SequentiallyConsistent:
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
    case GlobalValue::AvailableExternallyLinkage:
    case GlobalValue::ExternalWeakLinkage:
    case GlobalValue::WeakAnyLinkage:
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
  int Increment = (VT.getSizeInBits() + 63) / 64 * 8;
  EVT LVT = (Increment == 1) ? EVT(MVT::i64) : VT;
  SDValue NextPtr = DAG.getNode(ISD::ADD, DL, PtrVT, VAList,
                                DAG.getIntPtrConstant(Increment, DL));
  // Store the incremented VAList to the legalized pointer.
  InChain = DAG.getStore(VAList.getValue(1), DL, NextPtr, VAListPtr,
                         MachinePointerInfo(SV));
  // Load the actual argument out of the pointer VAList.
  // We can't count on greater alignment than the word size.
  auto V = DAG.getLoad(VT, DL, InChain, VAList, MachinePointerInfo(), 8);
  if (LVT == VT)
    return V;
  if (VT.getSizeInBits() == 64)
    return DAG.getBitcast(VT, V);
  EVT TmpVT(MVT::getIntegerVT(VT.getFixedSizeInBits()));
  V = DAG.getAnyExtOrTrunc(V, DL, TmpVT);
  if (TmpVT == VT)
    return V;
  return DAG.getBitcast(VT, V);
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
  static StringRef Dollar = "$";
  StringRef Str(RegName);

  if (Str[0] != '$')
    Str = StringRef(Dollar.str() + Str.str());

  unsigned RegNo = MatchRegisterName(Str);

  if (RegNo == 0)
    RegNo = MatchRegisterAltName(Str);

  if (RegNo == 0)
    report_fatal_error(StringRef("Could not get register by name: " +
                                 StringRef(RegName).str()));

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
    case MVT::i128:
    case MVT::v2i64:
    case MVT::v4i32:
    case MVT::v8i16:
    case MVT::v16i8:
    case MVT::v8f16:
    case MVT::v4f32:
    case MVT::v2f64:
      return std::make_pair(0U, &KVX::PairedRegRegClass);
    case MVT::v4i64:
    case MVT::v4f64:
    case MVT::v8f32:
    case MVT::v8i32:
    case MVT::v16i16:
    case MVT::v16f16:
    case MVT::v32i8:
      return std::make_pair(0U, &KVX::QuadRegRegClass);
    default:
      return TargetLowering::getRegForInlineAsmConstraint(TRI, Constraint, VT);
    }
  } else if (Constraint == "x") {
    switch (VT.SimpleTy) {
    case MVT::v64i1:
    case MVT::v128i1:
    case MVT::v256i1:
      return std::make_pair(0U, &KVX::VectorRegRegClass);
    case MVT::v512i1:
      return std::make_pair(0U, &KVX::WideRegRegClass);
    case MVT::v1024i1:
      return std::make_pair(0U, &KVX::MatrixRegRegClass);
    case MVT::v2048i1:
      return std::make_pair(0U, &KVX::Buffer8RegRegClass);
    case MVT::v4096i1:
      return std::make_pair(0U, &KVX::Buffer16RegRegClass);
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
  if (KVX::Buffer8RegRegClass.contains(RegNo))
    return std::make_pair(RegNo, &KVX::Buffer8RegRegClass);
  if (KVX::Buffer16RegRegClass.contains(RegNo))
    return std::make_pair(RegNo, &KVX::Buffer16RegRegClass);

  return TargetLowering::getRegForInlineAsmConstraint(TRI, Constraint, VT);
}

TargetLowering::ConstraintType
KVXTargetLowering::getConstraintType(StringRef Constraint) const {
  if (Constraint == "x")
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
  case MVT::v8f16:
  case MVT::v4i32:
  case MVT::v4f32:
    return lowerBUILD_VECTOR_128bit(Op, DAG);
  case MVT::v256i1:
  case MVT::v512i1:
  case MVT::v1024i1:
  case MVT::v2048i1:
  case MVT::v4096i1:
    return lowerTCAZeroInit(Op, DAG);
  }
}

SDValue KVXTargetLowering::lowerBUILD_VECTOR_128bit(SDValue Op,
                                                    SelectionDAG &DAG) const {
  BuildVectorSDNode *BVOp = cast<BuildVectorSDNode>(Op);
  auto VT = Op.getValueType();
  if (VT == MVT::v4f32 || VT == MVT::v4i32)
    if (BVOp->getSplatValue() != SDValue())
      return Op;

  LLVMContext &Ctx = *DAG.getContext();
  EVT HalfVT = VT.getHalfNumVectorElementsVT(Ctx);
  SDLoc DL(Op);
  unsigned HalfSz = Op->getNumOperands() / 2;
  auto Lo = Op->ops().drop_back(HalfSz);
  auto Hi = Op->ops().drop_front(HalfSz);
  SDValue VecLow = DAG.getNode(ISD::BUILD_VECTOR, DL, HalfVT, Lo);
  SDValue VecHi = DAG.getNode(ISD::BUILD_VECTOR, DL, HalfVT, Hi);

  return SDValue(
      DAG.getMachineNode(
          TargetOpcode::REG_SEQUENCE, DL, VT,
          {DAG.getTargetConstant(KVX::PairedRegRegClassID, DL, MVT::i64), VecHi,
           DAG.getTargetConstant(KVX::sub_d1, DL, MVT::i64), VecLow,
           DAG.getTargetConstant(KVX::sub_d0, DL, MVT::i64)}),
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

    if (VecVT == MVT::v4f32 || VecVT == MVT::v4i32 || VecVT == MVT::v8f16)
      return Op;

    if (VecVT == MVT::v2f64 || VecVT == MVT::v2i64 || VecVT == MVT::v4f64 ||
        VecVT == MVT::v4i64)
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
    SDLoc &DL, SelectionDAG &DAG, SDValue Vec, SDValue Val,
    uint64_t Index) const {
  SDValue SubRegIdx = DAG.getTargetConstant(Index + KVX::sub_d0, DL, MVT::i32);
  return SDValue(DAG.getMachineNode(TargetOpcode::INSERT_SUBREG, DL,
                                    Vec.getValueType(), {Vec, Val, SubRegIdx}),
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
  case MVT::v4f32:
  case MVT::v4i32:
  case MVT::v8i8:
  case MVT::v8f16:
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

static SDValue combineSETCC(SDNode *N, SelectionDAG &DAG) {
  auto VT = N->getValueType(0);
  if (!VT.isSimple() || VT.isVector())
    return SDValue();

  auto Cast = N->getOperand(0);
  if (Cast->getOpcode() != ISD::BITCAST)
    return SDValue();

  auto Setcc = Cast.getOperand(0);
  if (!((Setcc.getOpcode() == ISD::SETCC) &&
        (Setcc->getValueType(0).isVector())))
    return SDValue();

  auto Vec0 = Setcc->getOperand(0);
  auto Vec1 = Setcc.getOperand(1);

  auto Cond = N->getOperand(1);
  if (auto *Cst = dyn_cast<ConstantSDNode>(Cond)) {
    ISD::CondCode CC = cast<CondCodeSDNode>(N->getOperand(2))->get();
    if ((CC != ISD::SETEQ) && (CC != ISD::SETNE))
      report_fatal_error("Untreated vector set CC");

    auto API = Cst->getAPIntValue();
    if (!(API.isAllOnes() || API.isNullValue()))
      report_fatal_error("Untreated vector set CC constant condition value");

    //  EQ x  0 -> x = or_reduce
    //  EQ x -1 -> x = and_reduce
    // NEQ x  0 -> x = or_reduce
    // NEQ x -1 -> x = and_reduce
    auto VecTy = Vec0->getSimpleValueType(0);
    auto EltSz = VecTy.getScalarSizeInBits();
    if (EltSz > 64 || EltSz < 8)
      return SDValue();

    auto CCTy = VecTy.changeVectorElementTypeToInteger();
    auto CCI = cast<CondCodeSDNode>(Setcc->getOperand(2))->get();
    auto Result = DAG.getSetCC(SDLoc(Setcc), CCTy, Vec0, Vec1, CCI);
    unsigned VecSz = CCTy.getFixedSizeInBits();
    MVT CmpTy = MVT::getIntegerVT(std::min(VecSz, 64u));

    if (VecSz > 64) {
      if (CCTy.getScalarType() != MVT::i64)
        Result = DAG.getBitcast(MVT::getVectorVT(MVT::i64, VecSz / 64), Result);

      auto VecReduction =
          API.isAllOnes() ? ISD::VECREDUCE_AND : ISD::VECREDUCE_OR;
      Result = DAG.getNode(VecReduction, SDLoc(Cast), MVT::i64, Result);
    } else if (VecSz == 16) {
      assert(CCTy == MVT::v2i8 && "Untreated 16 bits wide vector!");
      CCTy = CCTy.changeVectorElementType(MVT::getIntegerVT(
          std::min(16u, 32 / CCTy.getVectorMinNumElements())));
      Result = DAG.getNode(ISD::SIGN_EXTEND, SDLoc(Result), CCTy, Result);
      CmpTy = MVT::getIntegerVT(CCTy.getFixedSizeInBits());
      Result = DAG.getBitcast(CmpTy, Result);
    } else
      Result = DAG.getBitcast(CmpTy, Result);

    auto NewCst = DAG.getConstant(Cst->getSExtValue(), SDLoc(Cond), CmpTy);
    Result = DAG.getSetCC(SDLoc(N), N->getValueType(0), Result, NewCst, CC);
    return Result;
  }
  report_fatal_error("Todo: Not a constant CC");
}

static SDValue combineBUILD_VECTOR(SDNode *N, SelectionDAG &DAG) {

  // Sanity check, we're dealing with a build_vector
  auto *BV = dyn_cast<BuildVectorSDNode>(N);
  if (!BV)
    return SDValue();

  auto VecT = BV->getValueType(0);
  if (VecT.getVectorMinNumElements() < 3 || VecT.isFloatingPoint() ||
      VecT.getVectorElementType().getSizeInBits() == 64 ||
      VecT.getSizeInBits() > 64)
    return SDValue();

  SDValue SplatV = BV->getSplatValue();
  if (!SplatV)
    return SDValue();

  // If we have undefs, normalize it, else do not change.
  if (!any_of(BV->ops(), [=](const SDUse &Op) { return Op.get()->isUndef(); }))
    return SDValue();

  return DAG.getSplatBuildVector(BV->getValueType(0), SDLoc(BV), SplatV);
}

static SDValue combineSRA(SDNode *N, SelectionDAG &DAG) {
  if (!N->getValueType(0).isSimple() ||
      N->getSimpleValueType(0).SimpleTy != MVT::i64)
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

static SDValue combineSIGN_EXTEND(SDNode *N, SelectionDAG &DAG) {
  auto Op = N->getOperand(0);
  auto VT = N->getValueType(0);
  if (N->getValueType(0).isVector() && Op.getOpcode() == ISD::SETCC &&
      Op->hasOneUse() &&
      VT == Op.getOperand(0)->getValueType(0).changeTypeToInteger())
    return DAG.getNode(ISD::SETCC, SDLoc(Op), VT, Op->ops());

  return SDValue();
}

static SDValue combineZext(SDNode *N, SelectionDAG &DAG) {
  SDValue N0 = N->getOperand(0);
  if (N0->isUndef())
    return SDValue();

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

static SDValue combineVecRedAdd(SDNode *N, SelectionDAG &DAG) {
  auto Op = N->getOperand(0);

  // Prevent to generate VECREDUCE_ADD_[SZ]EXT from bit-vectors
  if (!Op->ops().empty()) {
    auto Ty = Op->getOperand(0).getValueType();
    if (!Ty.isSimple() || Ty.getSimpleVT() == MVT::Other ||
        Ty.getScalarSizeInBits() == 1)
      return SDValue();
  }

  unsigned Opcode;
  switch (Op->getOpcode()) {
  case ISD::ANY_EXTEND:
  case ISD::ANY_EXTEND_VECTOR_INREG:
  case ISD::SIGN_EXTEND:
  case ISD::SIGN_EXTEND_INREG:
  case ISD::SIGN_EXTEND_VECTOR_INREG:
    Opcode = KVXISD::VECREDUCE_ADD_SEXT;
    break;
  case ISD::ZERO_EXTEND_VECTOR_INREG:
  case ISD::ZERO_EXTEND:
    Opcode = KVXISD::VECREDUCE_ADD_ZEXT;
    break;
  default:
    return SDValue();
  }

  Op = Op.getOperand(0);
  auto RedVT = N->getValueType(0);
  if (RedVT == MVT::i64 || RedVT == MVT::i32)
    return DAG.getNode(Opcode, SDLoc(N), RedVT, Op);

  auto Red = DAG.getNode(Opcode, SDLoc(N), MVT::i64, Op);
  return DAG.getZExtOrTrunc(Red, SDLoc(N), RedVT);
}

// This expands int_kvx_shl/int_kvx_shr nodes to sdnodes.
static SDValue combineShifts(SDNode *N, SelectionDAG &Dag,
                             const SmallVector<unsigned, 4> Opcodes) {
  auto OpcIndex = cast<ConstantSDNode>(N->getOperand(3))->getZExtValue();
  auto VT = N->getValueType(0);

  auto DL = SDLoc(N);
  auto ShiftAmount = N->getOperand(2);
  unsigned Opcode = Opcodes[OpcIndex];
  if (Opcode != KVXISD::SRS) {
    if (VT.isVector())
      ShiftAmount = Dag.getSplatBuildVector(VT, DL, ShiftAmount);
    else if (VT != ShiftAmount.getValueType())
      ShiftAmount = Dag.getAnyExtOrTrunc(ShiftAmount, DL, VT);
  }

  return Dag.getNode(Opcodes[OpcIndex], DL, VT, N->getOperand(1), ShiftAmount);
}

typedef enum { OpMulx, OpMaddx, OpMsbfx } MulSAOp;
static SDValue combineExtendMulSA(SDNode *N,
                                  TargetLowering::DAGCombinerInfo &DCI,
                                  SelectionDAG &Dag, MulSAOp Op) {
  const auto ExtTypePos = (Op == OpMulx) ? 3 : 4;
  auto ExtType =
      cast<ConstantSDNode>(N->getOperand(ExtTypePos))->getZExtValue();
  unsigned MulOpcode;
  switch (ExtType) {
  case 0:
    MulOpcode = KVXISD::SEXT_MUL;
    break;
  case 1:
    MulOpcode = KVXISD::SZEXT_MUL;
    break;
  case 2:
    MulOpcode = KVXISD::ZEXT_MUL;
    break;
  default:
    report_fatal_error(
        "Bad value for kvx-extend-multiply[add/sub] intrinsic.\n");
  }
  auto &Lhs = N->getOperand(1);
  auto &Rhs = N->getOperand(2);
  auto OutType = N->getValueType(0);
  auto DL = SDLoc(N);
  auto Mul = Dag.getNode(MulOpcode, DL, OutType, Lhs, Rhs);
  if (Op == OpMulx)
    return Mul;
  auto &Acc = N->getOperand(3);
  if (Op == OpMaddx)
    return Dag.getNode(ISD::ADD, DL, OutType, Acc, Mul);
  return Dag.getNode(ISD::SUB, DL, OutType, Acc, Mul);
}

static SDValue combineNarrowInt(SDNode *N, TargetLowering::DAGCombinerInfo &DCI,
                                SelectionDAG &Dag) {
  auto ExtType = cast<ConstantSDNode>(N->getOperand(2))->getZExtValue();
  auto &Op1 = N->getOperand(1);
  auto InType = Op1.getValueType();
  auto OutType = N->getValueType(0);
  auto DL = SDLoc(N);

  if (ExtType == 0) // modifier = "", normal truncate
    return Dag.getAnyExtOrTrunc(N->getOperand(1), DL, OutType);

  auto ShiftAmount =
      Dag.getConstant(OutType.getScalarSizeInBits(), DL, MVT::i32);

  if (InType.isVector())
    ShiftAmount = Dag.getSplatBuildVector(InType, DL, ShiftAmount);

  if (ExtType == 1) { // modifier = "q", truncate preserving upper halfs
    auto Shr = Dag.getNode(ISD::SRL, DL, InType, Op1, ShiftAmount);
    return Dag.getAnyExtOrTrunc(Shr, DL, OutType);
  }

  if (ExtType == 2) { // modifier = "s", sign-saturated truncate
    SDValue Satshl = Dag.getNode(ISD::SSHLSAT, DL, InType, Op1, ShiftAmount);
    SDValue Sat = Dag.getNode(ISD::SRL, DL, InType, Satshl, ShiftAmount);
    return Dag.getAnyExtOrTrunc(Sat, DL, OutType);
  }
  // modifier = "us", unsign-saturate signed value
  auto APIzero = APInt::getNullValue(InType.getScalarSizeInBits());
  auto APIlo = APInt::getLowBitsSet(InType.getScalarSizeInBits(),
                                    InType.getScalarSizeInBits() / 2);
  auto Zero = Dag.getConstant(APIzero, DL, InType);
  auto Max = Dag.getConstant(APIlo, DL, InType);
  // Saturate signed value minimum to zero
  SDValue SatMin = Dag.getNode(ISD::SMAX, DL, InType, Op1, Zero);
  // Saturate signed value maximum to usigned max of target size
  SDValue SatMax = Dag.getNode(ISD::SMIN, DL, InType, SatMin, Max);

  return Dag.getAnyExtOrTrunc(SatMax, DL, OutType);
}

typedef enum { WidenNormal, WidenE, WidenO } widen_t;

static SDValue combineWidenInt(SDNode *N, TargetLowering::DAGCombinerInfo &DCI,
                               SelectionDAG &Dag, widen_t WT = WidenNormal) {
  auto ExtType = cast<ConstantSDNode>(N->getOperand(2))->getZExtValue();
  auto OutType = N->getValueType(0);
  SDLoc DL(N);
  auto InVal = N->getOperand(1);
  if (WT == WidenNormal) {
    if (ExtType == 0) // "" modifier, sign-extend
      return Dag.getSExtOrTrunc(InVal, DL, OutType);

    auto Ext = Dag.getZExtOrTrunc(InVal, DL, OutType);
    if (ExtType == 1) // ".z" modifier, zero extend
      return Ext;

    // ExtType == 2, ".q" modifier, anyextend and shiftleft to upper bits half
    auto ShiftAmount =
        Dag.getConstant(OutType.getScalarSizeInBits() / 2, DL, MVT::i32);
    if (OutType.isVector())
      ShiftAmount = Dag.getSplatBuildVector(OutType, DL, ShiftAmount);

    return Dag.getNode(ISD::SHL, DL, OutType, Ext, ShiftAmount);
  }
  auto OrigVT = InVal.getValueType();
  InVal = Dag.getNode(ISD::BITCAST, DL, OutType, InVal);
  if (WT == WidenE) {   // Obtain the elements forming the lower half of the
                        // elements of the output vector
    if (ExtType == 0) { // "" modifier, sign-extend == sext_inreg
      if (OutType.isVector())
        return Dag.getNode(ISD::SIGN_EXTEND_INREG, DL, OutType, InVal,
                           Dag.getValueType(OrigVT.getHalfNumVectorElementsVT(
                               *Dag.getContext())));

      return Dag.getNode(ISD::SIGN_EXTEND_INREG, DL, OutType, InVal,
                         Dag.getValueType(OrigVT.getVectorElementType()));
    }
    if (ExtType == 1) { // zext == zero the upper bits
      auto V = APInt::getLowBitsSet(OutType.getScalarSizeInBits(),
                                    OrigVT.getScalarSizeInBits());
      return Dag.getNode(ISD::AND, DL, OutType, InVal,
                         Dag.getConstant(V, DL, OutType));
    }
    // move lower half to upper half
    return Dag.getNode(
        ISD::SHL, DL, OutType, InVal,
        Dag.getConstant(OrigVT.getScalarSizeInBits(), DL, OutType));
  }

  // WT == O, Obtain the elements forming the upper half of the elements of the
  // output vector
  if (ExtType == 0) // "" modifier, sign-extend
    return Dag.getNode(
        ISD::SRA, DL, OutType, InVal,
        Dag.getConstant(OrigVT.getScalarSizeInBits(), DL, OutType));

  if (ExtType == 1) // zext == zero the upper bits
    return Dag.getNode(
        ISD::SRL, DL, OutType, InVal,
        Dag.getConstant(OrigVT.getScalarSizeInBits(), DL, OutType));

  // zero the lower half
  auto V = APInt::getHighBitsSet(OutType.getScalarSizeInBits(),
                                 OrigVT.getScalarSizeInBits());
  return Dag.getNode(ISD::AND, DL, OutType, InVal,
                     Dag.getConstant(V, DL, OutType));
}

static SDValue combineAbd(SDNode *N, SelectionDAG &Dag) {
  unsigned NormalSatUn = cast<ConstantSDNode>(N->getOperand(3))->getZExtValue();
  auto VT = N->getValueType(0);
  auto Op0 = N->getOperand(1);
  auto Op1 = N->getOperand(2);
  SDLoc DL(N);

  if (NormalSatUn > 2)
    report_fatal_error("Got invalid modifier for kvx.abd intrinsic.\n");

  if (NormalSatUn == 1) { // modifier == ".s", sign-saturate
    auto Subsat = Dag.getNode(ISD::SSUBSAT, DL, VT, Op0, Op1);
    return Dag.getNode(ISD::ABS, DL, VT, Subsat);
  }

  if (NormalSatUn == 2) { // modifier == ".u", unsign-diff
    auto Umax = Dag.getNode(ISD::UMAX, DL, VT, Op0, Op1);
    auto Umin = Dag.getNode(ISD::UMIN, DL, VT, Op0, Op1);
    return Dag.getNode(ISD::SUB, DL, VT, Umax, Umin);
  }

  // NormalSatUn == 1 modifier == "", sign-diff
  auto Sub = Dag.getNode(ISD::SUB, DL, VT, Op0, Op1);
  SDNodeFlags Flags = Sub->getFlags(); // Avoid undefs optimisations.
  Flags.setNoSignedWrap(true);
  Sub->setFlags(Flags);
  return Dag.getNode(ISD::ABS, DL, VT, Sub);
}

static SDValue combineAbs(SDNode *N, SelectionDAG &Dag) {
  auto DoSat = cast<ConstantSDNode>(N->getOperand(2))->getZExtValue();
  auto VT = N->getValueType(0);
  auto Op = N->getOperand(1);
  SDLoc DL(N);

  if (DoSat) // ".s" modifier, do saturate
    Op = Dag.getNode(ISD::SSUBSAT, DL, VT, Dag.getConstant(0, DL, VT), Op);

  return Dag.getNode(ISD::ABS, DL, VT, Op);
}

static SDValue combineAvg(SDNode *N, SelectionDAG &Dag) {
  unsigned Type = cast<ConstantSDNode>(N->getOperand(3))->getZExtValue();
  auto VT = N->getValueType(0);
  auto Op0 = N->getOperand(1);
  auto Op1 = N->getOperand(2);
  SDLoc DL(N);

  if (Type > 3)
    report_fatal_error("Got invalid modifier for kvx.avg intrinsic.\n");

  auto Add = Dag.getNode(ISD::ADD, DL, VT, Op0, Op1);

  SDNodeFlags Flags = Add->getFlags();
  if (Type > 1) // modifier == .u or .ur, mark with no unsigned wrap
    Flags.setNoUnsignedWrap(true);
  else
    Flags.setNoSignedWrap(true);
  Add->setFlags(Flags);

  auto One = Dag.getConstant(1, DL, VT);
  if (Type & 1) { // modifier == .r or .ur, add 1
    Add = Dag.getNode(ISD::ADD, DL, VT, Add, One);
    Flags = Add->getFlags();
    if (Type > 1) // modifier == .u or .ur, mark with no unsigned wrap
      Flags.setNoUnsignedWrap(true);
    else
      Flags.setNoSignedWrap(true);
    Add->setFlags(Flags);
  }

  if (Type > 1) // unsigned, so logical shift right
    return Dag.getNode(ISD::SRL, DL, VT, Add, One);

  // signed, do an arithmetic shift right
  return Dag.getNode(ISD::SRA, DL, VT, Add, One);
}

typedef DenseMap<unsigned, unsigned> FromToTypeMap;
typedef FromToTypeMap::const_iterator FromTo_t;
static SDValue
bitcastTypesAndMachineOp(unsigned MachineOpcode, SDNode *N, SelectionDAG &Dag,
                         bool InPlace = true, unsigned Mods = 2,
                         const FromToTypeMap Map = {{MVT::v8f32, MVT::v4i64}}) {
  SmallVector<SDValue, 4> Args;
  SDLoc DL(N);
  for (auto A = 1U; A < N->getNumOperands() - Mods - InPlace; ++A) {
    SDValue Op = N->getOperand(A);
    EVT ArgVT = Op->getValueType(0);
    FromTo_t FromTo = Map.find(ArgVT.getSimpleVT().SimpleTy);
    if (FromTo == Map.end())
      Args.push_back(Op);
    else
      Args.push_back(
          Dag.getBitcast(MVT((MVT::SimpleValueType)FromTo->second), Op));
  }
  for (auto A = N->getNumOperands() - Mods; A < N->getNumOperands(); ++A)
    Args.push_back(Dag.getTargetConstant(
        cast<ConstantSDNode>(N->getOperand(A))->getZExtValue(), DL, MVT::i32));
  if (InPlace) {
    SDValue Op = N->getOperand(N->getNumOperands() - Mods - 1);
    EVT ArgVT = Op->getValueType(0);
    FromTo_t FromTo = Map.find(ArgVT.getSimpleVT().SimpleTy);
    if (FromTo == Map.end())
      Args.push_back(Op);
    else
      Args.push_back(
          Dag.getBitcast(MVT((MVT::SimpleValueType)FromTo->second), Op));
  }
  EVT ResVT = N->getValueType(0);
  FromTo_t FromTo = Map.find(ResVT.getSimpleVT().SimpleTy);
  if (FromTo == Map.end())
    return SDValue(Dag.getMachineNode(MachineOpcode, DL, ResVT, Args), 0);

  return Dag.getBitcast(
      ResVT,
      SDValue(Dag.getMachineNode(MachineOpcode, DL,
                                 (MVT::SimpleValueType)FromTo->second, Args),
              0));
}

static inline SDValue
cv2Intrinsic(unsigned KvxOpcode, SDNode *N, SelectionDAG &Dag,
             const KVXSubtarget &Subt, bool InPlace = true, unsigned Mods = 2,
             const FromToTypeMap Map = {{MVT::v8f32, MVT::v4i64}},
             MVT OutType = MVT::v4f32) {
  if (N->getValueType(0) != OutType)
    return SDValue();
  if (Subt.isV1())
    report_fatal_error("Can't emit a cv2 builtin for cv1");

  return bitcastTypesAndMachineOp(KvxOpcode, N, Dag, InPlace, Mods, Map);
}

static SDValue combineSplit(SDNode * N, TargetLowering::DAGCombinerInfo & DCI,
                              SelectionDAG & Dag) {
  auto VT = N->getValueType(0);
  LLVMContext &C = *Dag.getContext();
  const auto Opc = N->getOpcode();
  if (!VT.isVector() || VT.getVectorMinNumElements() == 1 ||
      !VT.isPow2VectorType())
    return SDValue();

  auto &TLI = Dag.getTargetLoweringInfo();
  if (TLI.getOperationAction(Opc, VT) != TargetLowering::Expand)
    return SDValue();

  auto HalfVT = VT.getVectorMinNumElements() == 2
                    ? VT.getScalarType()
                    : VT.getHalfNumVectorElementsVT(C);
  SmallVector<SDValue, 4> ArgsLo, ArgsHi;
  SDLoc DL(N);

  for (auto &Op : N->ops()) {
    auto OpVT = Op.getValueType();
    if (OpVT.isVector()) {
      if (OpVT.getVectorMinNumElements() == 2) {
        // Argument is broken into scalars
        Dag.ExtractVectorElements(Op, ArgsLo, 0, 1, OpVT.getScalarType());
        Dag.ExtractVectorElements(Op, ArgsHi, 1, 1, OpVT.getScalarType());
        continue;
      }
      // Argument is split by half sized vectors
      auto OpHalfVT = OpVT.getHalfNumVectorElementsVT(C);
      auto LoHi = Dag.SplitVector(Op, DL, OpHalfVT, OpHalfVT);
      ArgsLo.push_back(LoHi.first);
      ArgsHi.push_back(LoHi.second);
      continue;
    }
    // Argument is a scalar, replicate it
    ArgsLo.push_back(Op);
    ArgsHi.push_back(Op);
  }
  auto Lo = Dag.getNode(Opc, DL, HalfVT, ArgsLo);
  auto Hi = Dag.getNode(Opc, DL, HalfVT, ArgsHi);

  if (!HalfVT.isVector())
    return Dag.getNode(ISD::BUILD_VECTOR, DL, VT, Lo, Hi);

  return Dag.getNode(ISD::CONCAT_VECTORS, DL, VT, Lo, Hi);
}

static inline SDValue splitDownTo64Bits(SDNode *N,
                                        TargetLowering::DAGCombinerInfo &DCI,
                                        SelectionDAG &Dag) {
  auto T = N->getValueType(0);
  if (!T.isSimple() || !T.isVector())
    return SDValue();

  MVT VT = N->getSimpleValueType(0);
  if (VT.getSizeInBits() <= 64 || !VT.isPow2VectorType())
    return SDValue();

  return combineSplit(N, DCI, Dag);
}

static SDValue combineIntrinsic(SDNode *N, TargetLowering::DAGCombinerInfo &DCI,
                                SelectionDAG &Dag) {
  if (!isa<ConstantSDNode>(N->getOperand(0)))
    return SDValue();

  const auto &KVXSubtarget = (const class KVXSubtarget &)Dag.getSubtarget();
  auto Intr = cast<ConstantSDNode>(N->getOperand(0))->getZExtValue();
  switch (Intr) {
  case Intrinsic::KVXIntrinsics::kvx_abd:
    return combineAbd(N, Dag);
  case Intrinsic::KVXIntrinsics::kvx_abs:
    return combineAbs(N, Dag);
  case Intrinsic::KVXIntrinsics::kvx_avg:
    return combineAvg(N, Dag);
  case Intrinsic::KVXIntrinsics::kvx_narrowint:
    return combineNarrowInt(N, DCI, Dag);
  case Intrinsic::KVXIntrinsics::kvx_maddx:
    return combineExtendMulSA(N, DCI, Dag, OpMaddx);
  case Intrinsic::KVXIntrinsics::kvx_msbfx:
    return combineExtendMulSA(N, DCI, Dag, OpMsbfx);
  case Intrinsic::KVXIntrinsics::kvx_mulx:
    return combineExtendMulSA(N, DCI, Dag, OpMulx);
  case Intrinsic::KVXIntrinsics::kvx_shl:
    return combineShifts(N, Dag,
                         {ISD::SHL, ISD::SSHLSAT, ISD::USHLSAT, ISD::ROTL});
  case Intrinsic::KVXIntrinsics::kvx_shr:
    return combineShifts(N, Dag, {ISD::SRL, ISD::SRA, KVXISD::SRS, ISD::ROTR});
  case Intrinsic::KVXIntrinsics::kvx_widenint:
    return combineWidenInt(N, DCI, Dag);
  case Intrinsic::KVXIntrinsics::kvx_wideninte:
  case Intrinsic::KVXIntrinsics::kvx_widenintes:
    return combineWidenInt(N, DCI, Dag, WidenE);
  case Intrinsic::KVXIntrinsics::kvx_wideninto:
  case Intrinsic::KVXIntrinsics::kvx_widenintos:
    return combineWidenInt(N, DCI, Dag, WidenO);
  case Intrinsic::KVXIntrinsics::kvx_ffdma:
    return cv2Intrinsic(KVX::FFDMAWQ, N, Dag, KVXSubtarget, false);
  case Intrinsic::KVXIntrinsics::kvx_ffdmas:
    return cv2Intrinsic(KVX::FFDMASWQ, N, Dag, KVXSubtarget);
  case Intrinsic::KVXIntrinsics::kvx_ffdmda:
    return cv2Intrinsic(KVX::FFDMDAWQ, N, Dag, KVXSubtarget);
  case Intrinsic::KVXIntrinsics::kvx_ffdmds:
    return cv2Intrinsic(KVX::FFDMDSWQ, N, Dag, KVXSubtarget);
  case Intrinsic::KVXIntrinsics::kvx_ffdmsa:
    return cv2Intrinsic(KVX::FFDMSAWQ, N, Dag, KVXSubtarget);
  case Intrinsic::KVXIntrinsics::kvx_ffdms:
    return cv2Intrinsic(KVX::FFDMSWQ, N, Dag, KVXSubtarget, false);
  default:
    return SDValue();
  }
}

static SDValue combineMUL(SDNode *N, SelectionDAG &Dag) {
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

static SDValue combineTrunc(SDNode *N, SelectionDAG &DAG) {
  auto Ty = N->getValueType(0);
  if (!Ty.isSimple() || Ty.getSimpleVT() != MVT::v4i32)
    return SDValue();

  auto Srl = N->getOperand(0);
  if (Srl.getOpcode() != ISD::SRL)
    return SDValue();

  auto SZextMul = Srl.getOperand(0);
  unsigned OutOpcode = KVXISD::SZ_MUL;

  if (SZextMul->getOpcode() != KVXISD::SZEXT_MUL) {
    if (SZextMul->getOpcode() != ISD::MUL)
      return SDValue();

    SZextMul = combineMUL(SZextMul.getNode(), DAG);
    if (!SZextMul)
      return SDValue();

    if (SZextMul.getOpcode() != KVXISD::SZEXT_MUL)
      return SDValue();
  }

  auto *ShiftAmount = dyn_cast<BuildVectorSDNode>(Srl->getOperand(1));
  if (!ShiftAmount)
    return SDValue();

  auto *ShiftCst = dyn_cast<ConstantSDNode>(ShiftAmount->getSplatValue());
  if (!ShiftCst)
    return SDValue();

  unsigned Shift = ShiftCst->getZExtValue();
  if (Shift != Ty.getScalarSizeInBits() ||
      Shift != SZextMul.getOperand(0)->getValueType(0).getScalarSizeInBits())
    return SDValue();

  return DAG.getNode(OutOpcode, SDLoc(SZextMul), Ty, SZextMul->ops());
}

static SDValue splitLoad(LoadSDNode *LD, SelectionDAG &Dag, SDLoc DL) {
  SDValue BasePtr = LD->getBasePtr();
  EVT MemVT = LD->getMemoryVT();

  const MachinePointerInfo &SrcValue = LD->getMemOperand()->getPointerInfo();

  EVT LoVT, HiVT;
  EVT LoMemVT, HiMemVT;
  auto VT = LD->getValueType(0);

  std::tie(LoVT, HiVT) = Dag.GetSplitDestVTs(VT);
  std::tie(LoMemVT, HiMemVT) = Dag.GetSplitDestVTs(MemVT);

  unsigned Size = LoMemVT.getStoreSize();
  unsigned BaseAlign = LD->getAlignment();
  unsigned HiAlign = MinAlign(BaseAlign, Size);

  SDValue LoLoad = Dag.getExtLoad(ISD::NON_EXTLOAD, DL, LoVT, LD->getChain(),
                                  BasePtr, SrcValue, LoMemVT, BaseAlign,
                                  LD->getMemOperand()->getFlags());
  SDValue HiPtr = Dag.getObjectPtrOffset(DL, BasePtr, TypeSize::Fixed(Size));
  SDValue HiLoad =
      Dag.getExtLoad(ISD::NON_EXTLOAD, DL, HiVT, LD->getChain(), HiPtr,
                     SrcValue.getWithOffset(LoMemVT.getStoreSize()), HiMemVT,
                     HiAlign, LD->getMemOperand()->getFlags());

  SDValue Join = Dag.getNode(ISD::CONCAT_VECTORS, DL, VT, LoLoad, HiLoad);

  SDValue Ops[] = {Join, Dag.getNode(ISD::TokenFactor, DL, MVT::Other,
                                     LoLoad.getValue(1), HiLoad.getValue(1))};

  return Dag.getMergeValues(Ops, DL);
}

static SDValue combineLoad(SDNode *N, TargetLowering::DAGCombinerInfo &DCI,
                           SelectionDAG &Dag) {
  LoadSDNode *LD = dyn_cast<LoadSDNode>(N);
  if (!LD)
    return SDValue();

  auto VT = N->getValueType(0);
  if (!VT.isVector() || VT.getScalarType() == MVT::i64)
    return SDValue();

  unsigned Sz = VT.getSizeInBits();
  if (LD->isAtomic() || LD->getExtensionType() != ISD::NON_EXTLOAD)
    return SDValue();

  if (VT.getScalarType() == MVT::i1) {
    if (Sz == 256 || !DCI.isAfterLegalizeDAG())
      return SDValue();
    if (Sz > 256)
      return splitLoad(LD, Dag, SDLoc(N));
  }

  return SDValue(); // TODO: Do bitcast to non-tca types

  // EVT ToVT = (Sz <= 64)?
  //   EVT::getIntegerVT(*Dag.getContext(), Sz):
  //   EVT::getVectorVT(*Dag.getContext(), MVT::i64, ElementCount::getFixed(Sz /
  //   64));

  // SDLoc DL(N);
  // const MachinePointerInfo &SrcValue = LD->getMemOperand()->getPointerInfo();
  // SDValue BasePtr = LD->getBasePtr();
  // auto V = Dag.getExtLoad(ISD::NON_EXTLOAD, DL, ToVT, LD->getChain(),
  //                    BasePtr, SrcValue.getWithOffset(VT.getStoreSize()),
  //                    ToVT, LD->getAlign(), LD->getMemOperand()->getFlags());
  // auto BC = Dag.getBitcast(VT, V);
  // SDValue Ops[] = {BC, Dag.getNode(ISD::TokenFactor, DL, MVT::Other,
  //                                    V.getValue(1))};
  // return Dag.getMergeValues(Ops, DL);
}

SDValue SplitVectorStore(StoreSDNode *Store, SelectionDAG &Dag) {
  SDValue Val = Store->getValue();
  EVT VT = Val.getValueType();

  EVT MemVT = Store->getMemoryVT();
  SDValue Chain = Store->getChain();
  SDValue BasePtr = Store->getBasePtr();
  SDLoc SL(Store);

  EVT LoVT, HiVT;
  EVT LoMemVT, HiMemVT;
  SDValue Lo, Hi;

  std::tie(LoVT, HiVT) = Dag.GetSplitDestVTs(VT);
  if (LoVT.isVector() && (1 == LoVT.getVectorNumElements())) {
    LoVT = LoVT.getScalarType();
    HiVT = LoVT;
  }

  std::tie(LoMemVT, HiMemVT) = Dag.GetSplitDestVTs(MemVT);
  if (LoMemVT.isVector() && (1 == LoMemVT.getVectorNumElements())) {
    LoMemVT = LoMemVT.getScalarType();
    HiMemVT = LoMemVT;
  }

  std::tie(Lo, Hi) = Dag.SplitVector(Val, SL, LoVT, HiVT);

  SDValue HiPtr = Dag.getObjectPtrOffset(SL, BasePtr, LoMemVT.getStoreSize());

  const MachinePointerInfo &SrcValue = Store->getMemOperand()->getPointerInfo();
  unsigned BaseAlign = Store->getAlignment();
  unsigned Size = LoMemVT.getStoreSize();
  unsigned HiAlign = MinAlign(BaseAlign, Size);

  SDValue LoStore =
      Dag.getTruncStore(Chain, SL, Lo, BasePtr, SrcValue, LoMemVT, BaseAlign,
                        Store->getMemOperand()->getFlags());
  SDValue HiStore =
      Dag.getTruncStore(Chain, SL, Hi, HiPtr, SrcValue.getWithOffset(Size),
                        HiMemVT, HiAlign, Store->getMemOperand()->getFlags());

  return Dag.getNode(ISD::TokenFactor, SL, MVT::Other, LoStore, HiStore);
}

static SDValue combineStore(SDNode *N, TargetLowering::DAGCombinerInfo &DCI,
                            SelectionDAG &Dag) {
  StoreSDNode *ST = dyn_cast<StoreSDNode>(N);
  if (!ST)
    return SDValue();
  if (ST->isTruncatingStore())
    return SDValue();

  SDValue Value = ST->getValue();
  EVT VT = Value.getValueType();
  if (!VT.isSimple() || !isPowerOf2_32(VT.getSizeInBits()))
    return SDValue();

  unsigned Sz = VT.getSizeInBits();
  if (VT.getScalarType() == MVT::i1) {
    if (Sz <= 256 || !DCI.isAfterLegalizeDAG())
      return SDValue();
    return SplitVectorStore(ST, Dag);
  }

  if (Sz < 64)
    return SDValue();

  EVT ToVT = (Sz == 64) ? MVT::i64
                        : EVT::getVectorVT(*Dag.getContext(), MVT::i64,
                                           ElementCount::getFixed(Sz / 64));

  SDValue Chain = ST->getChain();
  SDValue Ptr = ST->getBasePtr();

  SDValue Cast = Dag.getBitcast(ToVT, Value);

  return Dag.getStore(Chain, SDLoc(N), Cast, Ptr, ST->getMemOperand());
}

// Called during lowering of vector [us](div|rem|divrem)
SDValue KVXTargetLowering::expandDivRemLibCall(const LibCalls &Names,
                                               SDValue &N, bool IsSigned,
                                               SelectionDAG &Dag,
                                               bool PackReminder) const {
  SDValue DivRem = expandVecLibCall(Names, N, IsSigned, Dag, false);

  if (!DivRem)
    return DivRem;

  auto DL = SDLoc(N);
  auto Rty0 = DivRem->getValueType(0);
  if (Rty0 != N->getValueType(0)) {
    auto Sz = Rty0.getSizeInBits();
    if (Sz == N->getValueSizeInBits(0))
      DivRem = Dag.getBitcast(N->getValueType(0), DivRem);

    // Don't know what is going on here, bail out
    // TODO: If RTy0 is not a vector, the vector was split down into elements.
    // At the moment we have no such case.
    if (Sz > N->getValueSizeInBits(0) || !Rty0.isVector())
      return SDValue();

    std::vector<SDValue> Args;
    for (int I = 0; I < (int)DivRem->getNumValues(); ++I)
      Args.push_back(DivRem.getValue(I));

    DivRem = Dag.getNode(ISD::CONCAT_VECTORS, DL, N->getValueType(0), Args);
  }

  return DivRem;
}

SDValue KVXTargetLowering::combineIntDivAlike(SDNode *N,
                                              SelectionDAG &Dag) const {
  if (!N->getValueType(0).isVector())
    return SDValue();

  LLVM_DEBUG(dbgs() << "KVX DagCombine DivAlike: "; N->dump(););
  auto Div = N->getOperand(1);
  if (isa<ConstantSDNode>(Div))
    return SDValue();

  if (auto *BV = dyn_cast<BuildVectorSDNode>(N)) {
    if (BV->isConstant())
      return SDValue();
  }

  SDValue R;
  LLVM_DEBUG(dbgs() << "KVX DagCombine divisor is not constant: ";
             Div->dump(););
  if (N->getOpcode() == ISD::SDIVREM || N->getOpcode() == ISD::UDIVREM) {
    // DIVREM nodes should be split into div + rem computation before
    // lowering them to a function call, as the DIVREM result is 2x as
    // big and would fail lowering for 2 x <8 x i32> nodes.
    auto DivOpc = N->getOpcode() == ISD::SDIVREM ? ISD::SDIV : ISD::UDIV;
    auto DL = SDLoc(N);
    auto VT = N->getValueType(0);
    SDValue Div = Dag.getNode(DivOpc, DL, VT);
    Div = LowerOperation(Div, Dag);
    if (!Div)
      return Div;
    SDValue Mul = Dag.getNode(ISD::MUL, DL, VT, Div, N->getOperand(1));
    SDValue Rem = Dag.getNode(ISD::SUB, DL, VT, N->getOperand(0), Mul);
    SDVTList VTs = Dag.getVTList(VT, VT);

    R = Dag.getNode(ISD::MERGE_VALUES, DL, VTs, Div, Rem);
  } else {
    R = LowerOperation(SDValue(N, 0), Dag);
    if (!R)
      return R;
  }
  LLVM_DEBUG(dbgs() << "KVX: After int division combine:"; Dag.dump());

  return R;
}

SDValue KVXTargetLowering::PerformDAGCombine(SDNode *N,
                                             DAGCombinerInfo &DCI) const {
  SelectionDAG &DAG = DCI.DAG;

  switch (N->getOpcode()) {
  default:
    break;
  case ISD::SETCC:
    return combineSETCC(N, DAG);
  case ISD::BUILD_VECTOR:
    return combineBUILD_VECTOR(N, DAG);
  case ISD::CTLZ:
  case ISD::CTTZ:
  case ISD::CTPOP:
  case ISD::FABS:
  case ISD::FADD:
  case ISD::FCOPYSIGN:
  case ISD::FMA:
  case ISD::FMUL:
  case ISD::FNEG:
  case ISD::FSUB:
    return combineSplit(N, DCI, DAG);
  case ISD::INTRINSIC_WO_CHAIN:
    return combineIntrinsic(N, DCI, DAG);
  case ISD::LOAD:
    return combineLoad(N, DCI, DAG);
  case ISD::MUL:
    return combineMUL(N, DAG);
  case ISD::SIGN_EXTEND:
    return combineSIGN_EXTEND(N, DAG);
  case ISD::STORE:
    return combineStore(N, DCI, DAG);
  case ISD::TRUNCATE:
    return (Subtarget.isV1()) ? SDValue() : combineTrunc(N, DAG);
  case ISD::ZERO_EXTEND:
    return combineZext(N, DAG);
  case ISD::VECREDUCE_ADD:
    return (Subtarget.isV1()) ? SDValue() : combineVecRedAdd(N, DAG);
  case ISD::SRA: {
    SDValue R = combineSRA(N, DAG);
    if (R)
      return R;
  }
    LLVM_FALLTHROUGH;
  case ISD::SHL:
  case ISD::SRL:
    return splitDownTo64Bits(N, DCI, DAG);

  case ISD::SDIV:
  case ISD::SREM:
  case ISD::SDIVREM:
  case ISD::UDIV:
  case ISD::UREM:
  case ISD::UDIVREM:
    if (DCI.isBeforeLegalize())
      return combineIntDivAlike(N, DAG);
    return SDValue();
  }

  return SDValue();
}

TargetLoweringBase::LegalizeTypeAction
KVXTargetLowering::getPreferredVectorAction(MVT VT) const {
  if (VT.SimpleTy == MVT::Other)
    return TargetLowering::getPreferredVectorAction(VT);

  switch (VT.SimpleTy) {
  case MVT::v8i1:
    if (!Subtarget.isV1())
      return TargetLowering::getPreferredVectorAction(VT);
    LLVM_FALLTHROUGH;
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

  if (BitcastVT.getScalarType() == MVT::i64)
    return true;
  return false;
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

bool KVXTargetLowering::shouldReplaceBy(SDNode *From, unsigned ToOpcode,
                                        SmallVector<SDValue> Ops) const {
  switch (ToOpcode) {
  default:
    return true;

  case ISD::CONCAT_VECTORS:
    return (Ops.empty() || Ops.size() == 2 ||
            Ops.begin()->getValueSizeInBits() == 64);

  // We prefer vector multiplies to vector shifts
  case ISD::SHL: {
    auto VT = From->getValueType(0);
    if (VT.isVector()) {
      // If not multiplied by a splat value, preserve the multiply
      switch (From->getOpcode()) {
      case ISD::MUL:
      case ISD::MULHS:
      case ISD::MULHU: {
        const auto *Op1 = From->getOperand(1).getNode();
        if (!isa<BuildVectorSDNode>(Op1))
          return false;
        auto *V = cast<BuildVectorSDNode>(Op1)->getConstantSplatNode();
        if (!V)
          return false;
        // Vector multiply is prefered over vector shift,
        // except for i8 vectors, as there are no such
        // operation. However, in CV1, it is expanded to
        // i16 vectors.
        return VT.getScalarType() == MVT::i8 && !Subtarget.isV1();
      }
      default:
        return true;
      }
    }

    // If the scalar mul is used in multiple places, convert to shift.
    if (!From->hasOneUse())
      return true;

    // Move to shifts before loads, stores and returns
    switch (From->use_begin()->getOpcode()) {
    case ISD::LOAD:
    case ISD::STORE:
    case ISD::CopyToReg: // Used before returns
      return true;
    case ISD::ADD:
      // A madd adding/subtractin an immediate needs a make
      auto User = From->use_begin();
      if (isa<ConstantSDNode>(User->getOperand(1)))
        return true;
    }

    switch (From->getOpcode()) {
    case ISD::MUL:
    case ISD::MULHS:
    case ISD::MULHU: {
      const auto *Op1 = From->getOperand(1).getNode();
      if (!isa<ConstantSDNode>(Op1))
        return false;
      return !Subtarget.isV1() &&
             !cast<ConstantSDNode>(Op1)->getAPIntValue().isSignedIntN(32);
    }
    default:
      return true;
    }
  }

  // Avoid infinite convertion ROTL <-> ROTR
  case ISD::ROTL:
  case ISD::ROTR:
    return false;
  }
}

MachineBasicBlock *
KVXTargetLowering::EmitInstrWithCustomInserter(MachineInstr &MI,
                                               MachineBasicBlock *BB) const {
  switch (MI.getOpcode()) {
  default:
    report_fatal_error("Unexpected instr type to insert");
  case KVX::KVX_eh_sjlj_setup_dispatch:
    return emitEHSjLjSetupDispatch(MI, BB);
  case KVX::KVX_eh_SjLj_LongJmp:
    return emitEHSjLjLongJmp(MI, BB);
  case KVX::KVX_eh_SjLj_SetJmp:
    return emitEHSjLjSetJmp(MI, BB);
  }
}

// Tries matching (i64 (and $a, $n)) for i16 and i8 types when appropriate
// Also tries matching (i64 (zextend $n)) for i32 type
static void tryMatchLoadStoreValue(llvm::SDValue &Sv, unsigned int Size) {
  MVT SvVt = Sv.getSimpleValueType();
  if (SvVt.SimpleTy == MVT::i64) {
    if (Sv.getOpcode() == ISD::AND) {
      auto *Mask = cast<ConstantSDNode>(Sv.getOperand(1));
      if ((Size == 8 && Mask->getZExtValue() == (1 << 8) - 1) ||
          (Size == 16 && Mask->getZExtValue() == (1 << 16) - 1))
        Sv = Sv.getOperand(0);
    } else if (Sv.getOpcode() == ISD::ZERO_EXTEND) {
      MVT SvOpVt = Sv.getOperand(0).getSimpleValueType();
      if (SvOpVt.getFixedSizeInBits() == Size)
        Sv = Sv.getOperand(0);
    }
  }
}

static SDValue getConstantFromOp(SelectionDAG &DAG, SDValue Op, unsigned Index,
                                 llvm::EVT VT) {
  SDValue Operand = Op->getOperand(Index);
  auto *OperandAsConst = dyn_cast<ConstantSDNode>(Operand);
  unsigned Value = OperandAsConst->getZExtValue();
  return DAG.getTargetConstant(Value, SDLoc(Operand), VT);
}

SDValue KVXTargetLowering::LowerINTRINSIC(SDValue Op, SelectionDAG &DAG,
                                          const KVXSubtarget *Subtarget,
                                          bool HasChain) const {
  MVT OutputVT = Op.getSimpleValueType();

  unsigned IID = HasChain ? 1 : 0;
  unsigned IntNo = cast<ConstantSDNode>(Op.getOperand(IID))->getZExtValue();
  unsigned OpStart = HasChain ? 2 : 1;

  SDLoc DL(Op);
  switch (IntNo) {
  default:
    return Op; // Don't interfere with other intrinsics.

  case Intrinsic::kvx_ready: {
    int ReadyInstrID[] = {KVX::READYp1r, KVX::READYp2r, KVX::READYp3r,
                          KVX::READYp4r};
    int NumActualOperands =
        Op->getNumOperands() - 1; // operand 0 is intrinsic ID
    int InstrID = ReadyInstrID[NumActualOperands - 1];
    SmallVector<SDValue, 4> MOps;
    for (int I = 1; I < NumActualOperands + 1; I++) {
      SDValue ThisOp = Op.getOperand(I);
      MVT OVT = ThisOp.getSimpleValueType();
      switch (OVT.SimpleTy) {
      case MVT::f16:
      case MVT::i32:
      case MVT::i64:
      case MVT::v2i64:
      case MVT::v4i64:
        break;
      default:
        return Op;
      }

      SDValue MatchedValue = ThisOp;

      // Trying to match (i64 (bitconvert (f64 (fpextend f32:$a)))))
      if (OVT.SimpleTy == MVT::i64) {
        if (ThisOp.getOpcode() == ISD::BITCAST) {
          SDValue FPExtend = ThisOp.getOperand(0);
          if (FPExtend.getSimpleValueType().SimpleTy == MVT::f64 &&
              FPExtend.getOpcode() == ISD::FP_EXTEND) {
            SDValue F32Op = FPExtend.getOperand(0);
            if (F32Op.getSimpleValueType().SimpleTy == MVT::f32)
              MatchedValue = F32Op;
          }
        }
      }

      MOps.push_back(MatchedValue);
    }
    auto *New = DAG.getMachineNode(InstrID, SDLoc(Op), OutputVT, MOps);
    return SDValue(New, 0);
  }

  case Intrinsic::eh_sjlj_lsda: {
    MachineFunction &MF = DAG.getMachineFunction();
    const TargetLowering &TLI = DAG.getTargetLoweringInfo();
    MVT PtrVT = TLI.getPointerTy(DAG.getDataLayout());
    auto &Context = MF.getMMI().getContext();
    // Our lsda symbol name must match the (hard-coded) one that
    // will be emmited by EHStreamer::emitExceptionTable()
    MCSymbol *S = Context.getOrCreateSymbol(Twine("GCC_except_table") +
                                            Twine(MF.getFunctionNumber()));

    if (isPositionIndependent()) {
      auto PcRel = DAG.getNode(KVXISD::PICPCRelativeGOTAddr, DL, PtrVT);
      return DAG.getNode(KVXISD::PICInternIndirection, DL, OutputVT, PcRel,
                         DAG.getMCSymbol(S, PtrVT));
    }
    return DAG.getNode(KVXISD::AddrWrapper, DL, OutputVT,
                       DAG.getMCSymbol(S, PtrVT));
  }

  case Intrinsic::kvx_wfx: {
    auto RegID = cast<ConstantSDNode>(Op->getOperand(2))->getZExtValue();

    MCRegister McReg = KVX::SystemRegRegClass.getRegister(RegID);

    if (!McReg.isValid())
      report_fatal_error("Invalid register in wfxl/wfxm builtin.\n");

    Register Reg = McReg.id();
    const StringRef RegStr = Subtarget->getRegisterInfo()->getName(Reg);
    if (!KVX::FxRegRegClass.contains(Reg))
      report_fatal_error("Invalid register in wfxl/wfxm builtin.\n");

    if (Subtarget->isV1()) {
      if (KVX::SetFxNotCV1RegRegClass.contains(Reg)) {
        errs() << "Register " << RegStr << "\n";
        report_fatal_error(
            "Can't generate wfxl/wfxm for the required register in Cv1");
      }
    } else if (KVX::GetSetFxNotCV2RegRegClass.contains(Reg)) {
      errs() << "Register " << RegStr << "\n";
      report_fatal_error(
          "Can't generate wfxl/wfxm for the required register in Cv2");
    }

    return Op;
  }

  case Intrinsic::kvx_store:
  case Intrinsic::kvx_store_vol: {
    bool Volatile = IntNo == Intrinsic::kvx_store_vol;
    unsigned InstrID = Volatile ? KVX::STOREpv : KVX::STOREp;

    SDValue Chain = Op->getOperand(0);
    SDValue Sv = Op->getOperand(OpStart);

    SDValue SizeInfoOp = Op->getOperand(OpStart + 2);
    auto *SizeInfoAsConst = dyn_cast<ConstantSDNode>(SizeInfoOp);
    unsigned Size = SizeInfoAsConst->getZExtValue();
    SDValue SizeInfo = DAG.getTargetConstant(Size, SDLoc(SizeInfoOp), MVT::i64);

    tryMatchLoadStoreValue(Sv, Size);

    SDValue Ptr = Op->getOperand(OpStart + 1);
    SDValue Ready = Op->getOperand(OpStart + 3);

    auto *New = DAG.getMachineNode(InstrID, SDLoc(Op), MVT::Other,
                                   {Ptr, Sv, SizeInfo, Ready, Chain});
    return SDValue(New, 0);
  }

  case Intrinsic::kvx_storec:
  case Intrinsic::kvx_storec_vol: {
    bool Volatile = IntNo == Intrinsic::kvx_storec_vol;
    unsigned InstrID = Volatile ? KVX::STORECpv : KVX::STORECp;
    SDValue Sv = Op->getOperand(OpStart);
    SDValue Chain = Op->getOperand(0);

    SDValue SizeInfoOp = Op->getOperand(OpStart + 2);
    auto *SizeInfoAsConst = dyn_cast<ConstantSDNode>(SizeInfoOp);
    unsigned Size = SizeInfoAsConst->getZExtValue();
    SDValue SizeInfo = DAG.getTargetConstant(Size, SDLoc(SizeInfoOp), MVT::i64);

    tryMatchLoadStoreValue(Sv, Size);

    SDValue Ptr = Op->getOperand(OpStart + 1);
    SDValue Cond = Op->getOperand(OpStart + 3);

    SDValue ScalarcondMod = getConstantFromOp(DAG, Op, OpStart + 4, MVT::i32);
    SDValue LsomaskMod = getConstantFromOp(DAG, Op, OpStart + 5, MVT::i32);

    SmallVector<SDValue, 8> NewOps = {Ptr,           Sv,        SizeInfo, Cond,
                                      ScalarcondMod, LsomaskMod};

    if (Op.getNumOperands() > OpStart + 6) {
      SDValue Ready = Op->getOperand(OpStart + 6);
      NewOps.push_back(Ready);
    }

    NewOps.push_back(Chain);

    auto *New = DAG.getMachineNode(InstrID, SDLoc(Op), MVT::Other, NewOps);
    return SDValue(New, 0);
  }

  case Intrinsic::kvx_loadc_u:
  case Intrinsic::kvx_loadc_u_vol: {
    bool Volatile = IntNo == Intrinsic::kvx_loadc_u_vol;
    unsigned InstrID = Volatile ? KVX::LOADCupv : KVX::LOADCup;

    SDValue Chain = Op->getOperand(0);
    SDValue Lv = Op->getOperand(OpStart);

    SDValue SizeInfoOp = Op->getOperand(OpStart + 2);
    auto *SizeInfoAsConst = dyn_cast<ConstantSDNode>(SizeInfoOp);
    unsigned Size = SizeInfoAsConst->getZExtValue();
    SDValue SizeInfo = DAG.getTargetConstant(Size, SDLoc(SizeInfoOp), MVT::i64);

    tryMatchLoadStoreValue(Lv, Size);

    SDValue Ptr = Op->getOperand(OpStart + 1);
    SDValue Cond = Op->getOperand(OpStart + 3);

    SDValue VariantMod = getConstantFromOp(DAG, Op, OpStart + 4, MVT::i32);
    SDValue ScalarcondMod = getConstantFromOp(DAG, Op, OpStart + 5, MVT::i32);
    SDValue LsomaskMod = getConstantFromOp(DAG, Op, OpStart + 6, MVT::i32);

    SmallVector<SDValue, 8> NewOps = {
        Ptr, Lv, SizeInfo, Cond, VariantMod, ScalarcondMod, LsomaskMod, Chain};

    auto *New = DAG.getMachineNode(InstrID, SDLoc(Op),
                                   {Op->getValueType(0), MVT::Other}, NewOps);
    return SDValue(New, 0);
  }
  }
}

MachineBasicBlock *
KVXTargetLowering::emitEHSjLjLongJmp(MachineInstr &MI,
                                     MachineBasicBlock *MBB) const {
  DebugLoc DL = MI.getDebugLoc();
  MachineFunction *MF = MBB->getParent();
  const TargetInstrInfo *TII = Subtarget.getInstrInfo();
  MachineRegisterInfo &MRI = MF->getRegInfo();

  // Memory Reference.
  SmallVector<MachineMemOperand *, 2> MMOs(MI.memoperands_begin(),
                                           MI.memoperands_end());
  Register BufReg = MI.getOperand(0).getReg();
  MachineInstrBuilder MIB;

  Register FP = KVX::R14;
  Register SP = KVX::R12;
  // Reload IP.
  Register LandingPad = MRI.createVirtualRegister(&KVX::SingleRegRegClass);
  MIB = BuildMI(*MBB, MI, DL, TII->get(KVX::LDri10), LandingPad)
            .addImm(8)
            .addReg(BufReg)
            .addImm(0)
            .setMemRefs(MMOs);

  // Reload FP.
  MIB = BuildMI(*MBB, MI, DL, TII->get(KVX::LDri10), FP);
  MIB.addImm(0);
  MIB.addReg(BufReg);
  MIB.addImm(0);
  MIB.setMemRefs(MMOs);

  // Reload SP.
  MIB = BuildMI(*MBB, MI, DL, TII->get(KVX::LDri10), SP);
  MIB.addImm(16);
  MIB.add(MI.getOperand(0)); // we can preserve the kill flags here.
  MIB.addImm(0);
  MIB.setMemRefs(MMOs);

  // Jump.
  BuildMI(*MBB, MI, DL, TII->get(KVX::IGOTO))
      .addReg(LandingPad, getKillRegState(true));

  MI.eraseFromParent();
  return MBB;
}

MachineBasicBlock *
KVXTargetLowering::emitEHSjLjSetJmp(MachineInstr &MI,
                                    MachineBasicBlock *MBB) const {
  DebugLoc DL = MI.getDebugLoc();
  MachineFunction *MF = MBB->getParent();
  const TargetInstrInfo *TII = Subtarget.getInstrInfo();
  MachineRegisterInfo &MRI = MF->getRegInfo();

  const BasicBlock *BB = MBB->getBasicBlock();
  MachineFunction::iterator I = ++MBB->getIterator();

  // Memory Reference.
  SmallVector<MachineMemOperand *, 2> MMOs(MI.memoperands_begin(),
                                           MI.memoperands_end());
  MachineBasicBlock *ThisMBB = MBB;
  MachineBasicBlock *MainMBB = MF->CreateMachineBasicBlock(BB);
  MachineBasicBlock *SinkMBB = MF->CreateMachineBasicBlock(BB);
  MachineBasicBlock *RestoreMBB = MF->CreateMachineBasicBlock(BB);
  MF->insert(I, MainMBB);
  MF->insert(I, SinkMBB);
  MF->push_back(RestoreMBB);
  RestoreMBB->setHasAddressTaken();

  // Transfer the remainder of BB and its successor edges to SinkMBB.
  SinkMBB->splice(SinkMBB->begin(), MBB,
                  std::next(MachineBasicBlock::iterator(MI)), MBB->end());
  SinkMBB->transferSuccessorsAndUpdatePHIs(MBB);

  // ThisMBB:
  auto Instr = isPositionIndependent() ? KVX::PICPCREL : KVX::MAKEi64;
  auto RestoreAddr = BuildMI(*MBB, MI, DL, TII->get(Instr),
                             MRI.createVirtualRegister(&KVX::SingleRegRegClass))
                         .addMBB(RestoreMBB);
  // Store IP in buf[1].
  auto MIB = BuildMI(*MBB, MI, DL, TII->get(KVX::SDri10))
                 .addImm(8)
                 .add(MI.getOperand(1)) // we can preserve the kill flags here.
                 .addReg(RestoreAddr.getReg(0), getKillRegState(true))
                 .setMemRefs(MMOs);

  // This tells the compiler that all registers must be
  // saved / restored before/after the SD instruction.
  const KVXRegisterInfo *RegInfo = Subtarget.getRegisterInfo();
  MIB.addRegMask(RegInfo->getNoPreservedMask());

  ThisMBB->addSuccessor(MainMBB);
  ThisMBB->addSuccessor(RestoreMBB);

  const auto *RC = &KVX::SingleRegRegClass;
  // MainMBB:
  auto MainRet = BuildMI(MainMBB, DL, TII->get(KVX::MAKEi16),
                         MRI.createVirtualRegister(RC))
                     .addImm(0);
  MainMBB->addSuccessor(SinkMBB);

  // RestoreMBB:
  auto RestRet = BuildMI(RestoreMBB, DL, TII->get(KVX::MAKEi16),
                         MRI.createVirtualRegister(RC))
                     .addImm(1);
  BuildMI(RestoreMBB, DL, TII->get(KVX::GOTO)).addMBB(SinkMBB);
  RestoreMBB->addSuccessor(SinkMBB);

  // SinkMBB:
  BuildMI(*SinkMBB, SinkMBB->begin(), DL, TII->get(KVX::PHI),
          MI.getOperand(0).getReg())
      .addReg(MainRet.getReg(0))
      .addMBB(MainMBB)
      .addReg(RestRet.getReg(0))
      .addMBB(RestoreMBB);

  MI.eraseFromParent();
  return SinkMBB;
}

// Create the MBBs for the dispatch code like following:
//
// BB:
//   Prepare DispatchBB address and store it to buf[1].
//   ...
//
// DispatchBB:
//   %s15 = GETGOT iff isPositionIndependent
//   %callsite = load callsite
//   CB %callsite > #size of callsites TrapBB
//
// DispContBB:
//   %breg = address of jump table
//   %npc = load and calculate next pc from %breg and %callsite
//   GOTO %npc
//
// TrapBB:
//   Call abort.
//
MachineBasicBlock *
KVXTargetLowering::emitEHSjLjSetupDispatch(MachineInstr &MI,
                                           MachineBasicBlock *BB) const {
  MachineFunction *MF = BB->getParent();

  // Get a mapping of the call site numbers to all of the landing pads they're
  // associated with.
  DenseMap<unsigned, SmallVector<MachineBasicBlock *, 2>> CallSiteNumToLPad;
  unsigned MaxCSNum = 0;
  for (auto &MBB : *MF) {
    if (!MBB.isEHPad())
      continue;

    MCSymbol *Sym = nullptr;
    for (const auto &MI : MBB) {
      if (MI.isDebugInstr())
        continue;

      assert(MI.isEHLabel() && "expected EH_LABEL");
      Sym = MI.getOperand(0).getMCSymbol();
      break;
    }

    if (!MF->hasCallSiteLandingPad(Sym))
      continue;

    for (unsigned CSI : MF->getCallSiteLandingPad(Sym)) {
      CallSiteNumToLPad[CSI].push_back(&MBB);
      MaxCSNum = std::max(MaxCSNum, CSI);
    }
  }

  // Get an ordered list of the machine basic blocks for the jump table.
  std::vector<MachineBasicBlock *> LPadList;
  SmallPtrSet<MachineBasicBlock *, 32> InvokeBBs;
  LPadList.reserve(CallSiteNumToLPad.size());

  for (unsigned CSI = 1; CSI <= MaxCSNum; ++CSI) {
    for (auto &LP : CallSiteNumToLPad[CSI]) {
      LPadList.push_back(LP);
      InvokeBBs.insert(LP->pred_begin(), LP->pred_end());
    }
  }

  if (LPadList.empty())
    report_fatal_error(
        "No landing pad destinations for the dispatch jump table!");

  // Create the MBBs for the dispatch code.
  const TargetRegisterClass *RC = &KVX::SingleRegRegClass;
  // Shove the dispatch's address into the return slot in the function context.
  MachineBasicBlock *DispatchBB = MF->CreateMachineBasicBlock();
  DispatchBB->setIsEHPad(true);

  const KVXInstrInfo *TII = Subtarget.getInstrInfo();
  const DebugLoc &DL = MI.getDebugLoc();
  MachineBasicBlock *TrapBB = MF->CreateMachineBasicBlock();
  BuildMI(TrapBB, DL, TII->get(KVX::ERROP));
  DispatchBB->addSuccessor(TrapBB, BranchProbability::getZero());

  MachineBasicBlock *DispContBB = MF->CreateMachineBasicBlock();
  DispatchBB->addSuccessor(DispContBB, BranchProbability::getOne());

  // Insert MBBs.
  MF->push_back(DispatchBB);
  MF->push_back(DispContBB);
  MF->push_back(TrapBB);

  // Insert code into the entry block that creates and registers the function
  // context.
  int FI = MF->getFrameInfo().getFunctionContextIndex();

  MachineRegisterInfo &MRI = MF->getRegInfo();
  // TODO: Check if needs doing different when positionIndependentCode is on.
  Register LabelAddr = MRI.createVirtualRegister(RC);
  BuildMI(*BB, MI, DL, TII->get(KVX::MAKEi64), LabelAddr).addMBB(DispatchBB);

  MachineFrameInfo &MFI = MF->getFrameInfo();
  // Store an address of DispatchBB to a given jmpbuf[1] where has next IC
  // referenced by longjmp (throw) later.
  static const int OffsetIC = 72;
  MachineMemOperand *MMO = MF->getMachineMemOperand(
      MachinePointerInfo::getFixedStack(*MF, FI, OffsetIC),
      MachineMemOperand::MOStore, MFI.getObjectSize(FI),
      MFI.getObjectAlign(FI));

  BuildMI(*BB, MI, DL, TII->get(KVX::SDp))
      .addImm(OffsetIC)
      .addFrameIndex(FI)
      .addMemOperand(MMO)
      .addReg(LabelAddr, getKillRegState(true));

  // Create the jump table and associated information
  unsigned JTE = getJumpTableEncoding();
  MachineJumpTableInfo *JTI = MF->getOrCreateJumpTableInfo(JTE);
  JTI->createJumpTableIndex(LPadList);

  const KVXRegisterInfo *RI = Subtarget.getRegisterInfo();
  // Add a register mask with no preserved registers.  This results in all
  // registers being marked as clobbered.
  BuildMI(DispatchBB, DL, TII->get(KVX::NOP))
      .addRegMask(RI->getNoPreservedMask());

  // IReg is used as an index in a memory operand and therefore can't be SP
  static const int OffsetCS = 8;
  Register IReg = MRI.createVirtualRegister(RC);
  MMO = MF->getMachineMemOperand(
      MachinePointerInfo::getFixedStack(*MF, FI, OffsetCS),
      MachineMemOperand::MOLoad, MFI.getObjectSize(FI), MFI.getObjectAlign(FI));

  BuildMI(DispatchBB, DL, TII->get(KVX::LDp), IReg)
      .addImm(OffsetCS)
      .addFrameIndex(FI)
      .addMemOperand(MMO)
      .addImm(KVXMOD::VARIANT_);

  auto CmpOpcode =
      (LPadList.size() < (1 << 9))
          ? KVX::COMPDri10
          : (LPadList.size() < (1L << 36)) ? KVX::COMPDri37 : KVX::COMPDri64;

  Register IReg2 = MRI.createVirtualRegister(RC);
  BuildMI(DispatchBB, DL, TII->get(CmpOpcode), IReg2)
      .addReg(IReg)
      .addImm(LPadList.size())
      .addImm(KVXMOD::COMPARISON_GTU);

  BuildMI(DispatchBB, DL, TII->get(KVX::CB))
      .addReg(IReg2, getKillRegState(false))
      .addMBB(TrapBB)
      .addImm(KVXMOD::SIMPLECOND_ODD);

  // Now add the code that branches to the correct landing pad, obtained
  // from a jump-table.
  Register JT = MRI.createVirtualRegister(RC);

  Register AddrIGOTO = MRI.createVirtualRegister(RC);
  switch (getJumpTableEncoding()) {
  default:
    llvm_unreachable_internal("We don't use any other jump-table encoding.");
  case MachineJumpTableInfo::EK_BlockAddress:
    // 1st step, put the jump-table (JT) address in a register, to be used in a
    // load.
    BuildMI(DispContBB, DL, TII->get(KVX::MAKEi64), JT).addJumpTableIndex(0);
    // Non-pic code, we just store the 64bit block address in the jump table.
    BuildMI(DispContBB, DL, TII->get(KVX::LDrr), AddrIGOTO)
        .addReg(IReg, getKillRegState(true))
        .addReg(JT, getKillRegState(true))
        .addImm(KVXMOD::VARIANT_)
        .addImm(KVXMOD::DOSCALE_XS);
    break;

  case MachineJumpTableInfo::EK_LabelDifference32:
    // pic code, the JT stores: (basic block address - JT address)
    // Must do:
    // pcrel $rA = @pcrel( .JumpTable ) == $rA = PC + .JumpTable
    // lws.xs $rB = Index [$rA]
    // AddrIGOTO = $rB + $rA

    BuildMI(DispContBB, DL, TII->get(KVX::PICPCREL), JT).addJumpTableIndex(0);

    Register OffsetBB = MRI.createVirtualRegister(RC);
    BuildMI(DispContBB, DL, TII->get(KVX::LWSrr), OffsetBB)
        .addReg(IReg, getKillRegState(true))
        .addReg(JT, getKillRegState(true))
        .addImm(KVXMOD::VARIANT_)
        .addImm(KVXMOD::DOSCALE_XS);

    BuildMI(DispContBB, DL, TII->get(KVX::ADDDrr), AddrIGOTO)
        .addReg(JT)
        .addReg(OffsetBB);
    break;
  }
  BuildMI(DispContBB, DL, TII->get(KVX::IGOTO))
      .addReg(AddrIGOTO, getKillRegState(true));

  // Add the jump table entries as successors to the MBB.
  SmallPtrSet<MachineBasicBlock *, 8> SeenMBBs;
  for (auto &LP : LPadList)
    if (SeenMBBs.insert(LP).second)
      DispContBB->addSuccessor(LP);

  // N.B. the order the invoke BBs are processed in doesn't matter here.
  SmallVector<MachineBasicBlock *, 64> MBBLPads;
  const MCPhysReg *SavedRegs = MF->getRegInfo().getCalleeSavedRegs();
  for (MachineBasicBlock *MBB : InvokeBBs) {
    // Remove the landing pad successor from the invoke block and replace it
    // with the new dispatch block.
    // Keep a copy of Successors since it's modified inside the loop.
    SmallVector<MachineBasicBlock *, 8> Successors(MBB->succ_rbegin(),
                                                   MBB->succ_rend());
    // FIXME: Avoid quadratic complexity. Acceptable as number of exception
    // handling landing pads are usually very small (number of catches for
    // a try in C++).
    for (auto *MBBS : Successors) {
      if (MBBS->isEHPad()) {
        MBB->removeSuccessor(MBBS);
        MBBLPads.push_back(MBBS);
      }
    }

    MBB->addSuccessor(DispatchBB);

    // Find the invoke call and mark all of the callee-saved registers as
    // 'implicit defined' so that they're spilled.  This prevents code from
    // moving instructions to before the EH block, where they will never be
    // executed.
    for (auto &II : reverse(*MBB)) {
      if (!II.isCall())
        continue;

      DenseMap<unsigned, bool> DefRegs;
      for (auto &MOp : II.operands())
        if (MOp.isReg())
          DefRegs[MOp.getReg()] = true;

      MachineInstrBuilder MIB(*MF, &II);
      for (unsigned RegIdx = 0; SavedRegs[RegIdx]; ++RegIdx) {
        unsigned Reg = SavedRegs[RegIdx];
        if (!DefRegs[Reg])
          MIB.addReg(Reg, RegState::ImplicitDefine | RegState::Dead);
      }

      break;
    }
  }

  // Mark all former landing pads as non-landing pads.  The dispatch is the only
  // landing pad now.
  for (auto &LP : MBBLPads)
    LP->setIsEHPad(false);

  // The instruction is gone now.
  MI.eraseFromParent();
  return BB;
}

unsigned
KVXTargetLowering::getInlineAsmMemConstraint(StringRef ConstraintCode) const {
  // A constraint m or `o` is the same in kvx
  if (ConstraintCode == "o")
    return InlineAsm::Constraint_m;

  return TargetLowering::getInlineAsmMemConstraint(ConstraintCode);
}

bool KVXTargetLowering::isExtractVecEltCheap(EVT VT, unsigned Index) const {
  EVT ElVt = VT.getScalarType();
  switch (ElVt.getSimpleVT().SimpleTy) {
  case MVT::i8:
  case MVT::i16:
    return false;
  default:
    break;
  }
  auto EltSz = VT.getScalarType().getSizeInBits();
  return (Index * EltSz % 64 == 0);
}

// BuildSDIVPow2 can be called by different SDIV alike functions.
// Only say we know how to generate optimimal code for SDIV.
SDValue
KVXTargetLowering::BuildSDIVPow2(SDNode *N, const APInt &Divisor,
                                 SelectionDAG &DAG,
                                 SmallVectorImpl<SDNode *> &Created) const {

  switch (N->getOpcode()) {
  case ISD::SDIV:
  case ISD::SREM:
    break;
  default:
    return SDValue();
  }

  if (!N->getValueType(0).isSimple())
    return TargetLowering::BuildSDIVPow2(N, Divisor, DAG, Created);

  switch (N->getSimpleValueType(0).SimpleTy) {
  case MVT::v2i8:
  case MVT::v4i8:
  case MVT::v8i8:
    if (Subtarget.isV1())
      return TargetLowering::BuildSDIVPow2(N, Divisor, DAG, Created);
    LLVM_FALLTHROUGH;
  case MVT::v2i16:
  case MVT::v4i16:
  case MVT::v2i32:
  case MVT::i32:
  case MVT::i64:
    break;
  default:
    return TargetLowering::BuildSDIVPow2(N, Divisor, DAG, Created);
  }

  // We can use SRS* instructions
  SDValue Div = N->getOperand(1);
  if (N->getSimpleValueType(0).isVector()) {
    auto *BV = dyn_cast<BuildVectorSDNode>(Div.getNode());

    if (!BV)
      return SDValue();

    Div = BV->getSplatValue();

    if (!Div)
      return SDValue();
  }

  // If dividing MIN_VALUE, we don't perform this, as the
  // compiler will optimise it (if not optimized before).
  if (Divisor.isAllOnesValue())
    return SDValue();

  SDLoc Loc(N);
  auto Opcode = Divisor.isNegative() ? KVXISD::SRSNEG : KVXISD::SRS;
  auto SRSCst =
      DAG.getConstant(Divisor.abs().countTrailingZeros(), Loc, MVT::i32);
  auto SRSVal =
      DAG.getNode(Opcode, Loc, N->getValueType(0), N->getOperand(0), SRSCst);
  Created.push_back(SRSCst.getNode());
  Created.push_back(SRSVal.getNode());

  return SRSVal;
}

bool KVXTargetLowering::hasPairedLoad(EVT VT, Align &Alg) const {
  if (!VT.isSimple())
    return false;

  Alg = Align(1);
  unsigned NumBits = VT.getSizeInBits();
  bool Ret = NumBits >= 64 && NumBits <= 128 && isPowerOf2_32(NumBits);
  return Ret;
}

bool KVXTargetLowering::isUsedByReturnOnly(SDNode *N, SDValue &Chain) const {
  if (N->getNumValues() != 1)
    return false;
  if (!N->hasNUsesOfValue(1, 0))
    return false;

  SDValue TCChain = Chain;
  SDNode *Copy = *N->use_begin();
  if (Copy->getOpcode() == ISD::CopyToReg) {
    // If the copy has a glue operand, we conservatively assume it isn't safe to
    // perform a tail call.
    if (Copy->getOperand(Copy->getNumOperands() - 1).getValueType() ==
        MVT::Glue)
      return false;
    TCChain = Copy->getOperand(0);
  } else if (Copy->getOpcode() == ISD::BITCAST) {
    // f32 returned in a single GPR.
    if (!Copy->hasOneUse())
      return false;
    Copy = *Copy->use_begin();
    if (Copy->getOpcode() != ISD::CopyToReg || !Copy->hasNUsesOfValue(1, 0))
      return false;
    // If the copy has a glue operand, we conservatively assume it isn't safe to
    // perform a tail call.
    if (Copy->getOperand(Copy->getNumOperands() - 1).getValueType() ==
        MVT::Glue)
      return false;
    TCChain = Copy->getOperand(0);
  } else
    return false;

  // If our copy of the resulting function is copied to a register but not used,
  // most probably it is in the live-out of the BB. Don't do TailCall.
  if (Copy->use_empty())
    return false;

  for (const SDNode *U : Copy->uses())
    if (U->getOpcode() != KVXISD::RET)
      return false;

  Chain = TCChain;
  return true;
}

// -----------------------------------------------------------------------------
//        Namespace KVX_LOW
// -----------------------------------------------------------------------------

// If AllowRepeatExtend, then it is allowed to have immediate vectors that
// repeat the first 64 bits.
uint64_t KVX_LOW::getImmVector(const llvm::BuildVectorSDNode *BV,
                               const llvm::SelectionDAG *CurDag,
                               unsigned long Negative, bool AllowRepeatExtend) {
  auto VT = BV->getValueType(0);
  auto NumElts = VT.getVectorNumElements();
  assert(NumElts == BV->getNumOperands() &&
         "Build vector and vector with distinct number of operands!");

  EVT ET = VT.getVectorElementType();
  bool IsFP = ET.isFloatingPoint();
  auto EltSize = ET.getSizeInBits();
  auto NumEltsToScan = NumElts;
  if (AllowRepeatExtend) {
    const auto TotalSize = NumElts * EltSize;
    if (TotalSize > 64) {
      assert(TotalSize % 64 == 0 && "Extension should be multiple of 64-bits");
      // e.g. for a 128-bit value, only return the first 64 bits
      NumEltsToScan /= TotalSize / 64;
    }
  }

  if (NumEltsToScan * EltSize > 64)
    report_fatal_error("getImmVector of vector larger than 64 bits!");

/* Extra check that, when AllowRepeatExtend is ON, the first 64 bits are
 * indeed repeated. If we do not check this we risk emitting wrong immediate
 * vectors. */
#ifndef NDEBUG
  if (AllowRepeatExtend) {
    std::vector<llvm::SDValue> BaseValues(NumEltsToScan);
    for (unsigned I = 0; I < NumEltsToScan; I++)
      BaseValues[I] = BV->getOperand(I);
    for (unsigned I = NumEltsToScan; I < NumElts; I++)
        assert((BaseValues[I % NumEltsToScan] == BV->getOperand(I) ||
                BaseValues[I % NumEltsToScan].isUndef() ||
                BV->getOperand(I).isUndef()) &&
               "The extension is not a repetition of the first 64 bits");
  }
#endif

  uint64_t EltMask = ~(((uint64_t)(-1)) << EltSize);
  uint64_t V = 0;
  unsigned long ShouldNegate = 1;
  for (unsigned I = 0; I < NumEltsToScan || (AllowRepeatExtend && I < NumElts);
       I++, ShouldNegate <<= 1) {
    auto Op = BV->getOperand(I);
    if (Op.isUndef())
      continue;

    auto RepeatI = I % NumEltsToScan;
    auto RepeatShouldNegate = ShouldNegate >> (I / NumEltsToScan);

    if (IsFP) {
      auto FPv = cast<ConstantFPSDNode>(Op)->getValueAPF();
      if (Negative & RepeatShouldNegate)
        FPv.changeSign();

      V |= (FPv.bitcastToAPInt().getZExtValue() & EltMask)
           << (EltSize * RepeatI);
    } else if (Negative & RepeatShouldNegate) {
      V |= (-cast<ConstantSDNode>(Op)->getSExtValue() & EltMask)
           << (EltSize * RepeatI);
    } else {
      V |= (cast<ConstantSDNode>(Op)->getSExtValue() & EltMask)
           << (EltSize * RepeatI);
    }
  }

  return V;
}

// Negative is a bitmask, telling which elements numbers must have
// their value negated.
SDValue KVX_LOW::buildImmVector(const llvm::SDNode &N,
                                llvm::SelectionDAG &CurDag,
                                unsigned long Negative,
                                bool AllowRepeatExtend) {
  auto *BV = dyn_cast<BuildVectorSDNode>(&N);
  if (!BV)
    return SDValue();

  auto VT = N.getValueType(0);
  auto VectorSize = VT.getSizeInBits();
  auto OutSize = (AllowRepeatExtend && VectorSize > 64) ? 64 : VectorSize;
  auto OutVT = MVT::getIntegerVT(OutSize);

  uint64_t V = getImmVector(BV, &CurDag, Negative, AllowRepeatExtend);
  return CurDag.getConstant(V, SDLoc(&N), OutVT, true);
}

llvm::SDValue KVX_LOW::buildFdotImm(llvm::SDNode &N, llvm::SelectionDAG &CurDag,
                                    bool SwapLoHi, unsigned long Negative) {
  if (N.getOpcode() != ISD::FMA)
    report_fatal_error(
        "Build fdot imm should be called from first matched FMA\n.");

  auto *LowValSD = dyn_cast<ConstantFPSDNode>(N.getOperand(1));
  if (!LowValSD)
    report_fatal_error(
        "Build fdot imm should be called in a FMA with a constant fp value\n.");
  APFloat LowVal = LowValSD->getValueAPF();

  SDValue Op2 = N.getOperand(2);
  if (Op2.getOpcode() != ISD::FMUL)
    report_fatal_error(
        "Build fdot imm should have the last operand as a FMUL\n.");

  auto *HiValSD = dyn_cast<ConstantFPSDNode>(Op2.getOperand(1));
  if (!HiValSD)
    report_fatal_error(
        "Build fdot imm did not find the second immediate in the FMUL\n.");

  APFloat HiVal = HiValSD->getValueAPF();
  if (SwapLoHi)
    std::swap(HiVal, LowVal);

  if (Negative & 1)
    LowVal = -LowVal;
  if (Negative & 2)
    HiVal = -HiVal;

  uint64_t V = HiVal.bitcastToAPInt().getZExtValue() << 32 |
               LowVal.bitcastToAPInt().getZExtValue();

  return CurDag.getConstant(V, SDLoc(&N), MVT::i64, true);
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

llvm::SDValue KVX_LOW::extractSplatNode(const llvm::SDNode *N,
                                        const llvm::SelectionDAG *CurDag) {
  assert(isSplatBuildVec(N, CurDag) && "N is not a splat build vector");
  const BuildVectorSDNode *BV = dyn_cast<BuildVectorSDNode>(N);

    return BV->getSplatValue();
  }

bool KVX_LOW::isSplatBuildVec(const llvm::SDNode *N,
                              const llvm::SelectionDAG *CurDag,
                              unsigned MakeImmSizeCheck) {
  const BuildVectorSDNode *BV = dyn_cast<BuildVectorSDNode>(N);
    SDValue SV = BV->getSplatValue();
    if (SV == SDValue())
      return false;

    if (SV->isUndef())
      return true;

    if (MakeImmSizeCheck == 0)
      return true;

    if (!BV->isConstant())
      return false;

  /* Check that the immediate encoding the build_vector fits in ImmSizeCheck */
    uint64_t V = getImmVector(BV, CurDag, 0, true);
    return isIntN(MakeImmSizeCheck, V);
  }

bool KVX_LOW::isKVXSplat32ImmVec(llvm::SDNode *N, llvm::SelectionDAG *CurDag,
                                 bool SplatAt, bool Negate) {
  const BuildVectorSDNode *BV = dyn_cast<BuildVectorSDNode>(N);
  if (!BV)
    return false;

  if (!BV->isConstant())
    return false;

  if (BV->isUndef() || ISD::isConstantSplatVectorAllZeros(BV))
    return true;

  auto VT = BV->getValueType(0);

  if (VT.getSizeInBits() > 64 || VT.getVectorNumElements() < 2 ||
      (VT.getSizeInBits() <= 32 && SplatAt))
    return false;

  if (VT.getSizeInBits() <= 32 && !SplatAt)
    return true;

  if (N->getOpcode() == ISD::SPLAT_VECTOR)
    return SplatAt;

  assert(VT.getSizeInBits() == 64 && "Not 64 bits vector");

  if (!SplatAt) {
    BitVector Undefs;
    SmallVector<APInt> Bits;

    auto AllOnes = [](const APInt &V) { return V.isAllOnesValue(); };
    auto AllZero = [](const APInt &V) { return V.isNullValue(); };

    BV->getConstantRawBits(true, VT.getScalarSizeInBits(), Bits, Undefs);
    auto Half = VT.getVectorNumElements() / 2 - 1;
    if (Undefs[Half]) {
      Negate = false;
      Bits[Half].clearAllBits();
    }

    if (Negate)
      for (auto &I : Bits)
        I.negate();

    auto F = (Bits[Half].isSignBitSet()) ? AllOnes : AllZero;
    for (auto End = VT.getVectorNumElements(); ++Half < End;)
      if (!(Undefs[Half] || F(Bits[Half])))
        return false;

    return true;
  }
  // From the start of 32 bits, check if the value is either
  // zero, for non-splat, for equals to the first half.
  // Undef is also accepted as a match in the second half.
  auto ElmCheck = 32 / VT.getVectorElementType().getSizeInBits();
  auto ElmEnd = BV->getNumOperands();
  for (unsigned FirstHalf = 0; ElmCheck != ElmEnd; ++ElmCheck, ++FirstHalf) {
    auto SecondHalf = BV->getOperand(ElmCheck);
    if (SecondHalf.isUndef())
      continue;

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

SDValue KVXTargetLowering::expandVecLibCall(const LibCalls &Names,
                                            SDValue &Node, bool IsSigned,
                                            SelectionDAG &DAG,
                                            const bool CanTailCall) const {
  auto Evt = Node.getValueType();
  if (!Evt.isSimple() || !Evt.isVector())
    return SDValue();

  auto Name = Names.find(Evt.getSimpleVT());
  if (Names.end() == Name)
    return SDValue();

  const StringRef LC = Name->second;
  TargetLowering::ArgListTy Args;
  TargetLowering::ArgListEntry Entry;

  for (const SDValue &Op : Node->op_values()) {
    EVT ArgVT = Op.getValueType();
    Type *ArgTy = ArgVT.getTypeForEVT(*DAG.getContext());
    Entry.Node = Op;
    Entry.Ty = ArgTy;
    Entry.IsSExt = shouldSignExtendTypeInLibCall(ArgVT, IsSigned);
    Entry.IsZExt = !shouldSignExtendTypeInLibCall(ArgVT, IsSigned);
    Args.push_back(Entry);
  }
  SDValue Callee =
      DAG.getExternalSymbol(LC.data(), getPointerTy(DAG.getDataLayout()));

  EVT RetVT = Node->getValueType(0);
  Type *RetTy = RetVT.getTypeForEVT(*DAG.getContext());

  // By default, the input chain to this libcall is the entry node of the
  // function. If the libcall is going to be emitted as a tail call then
  // isUsedByReturnOnly will change it to the right chain if the return
  // node which is being folded has a non-entry input chain.
  SDValue InChain = DAG.getEntryNode();

  // isTailCall may be true since the callee does not reference caller stack
  // frame. Check if it's in the right position and that the return types match.
  SDValue TCChain = InChain;
  const Function &F = DAG.getMachineFunction().getFunction();
  bool IsTailCall =
      CanTailCall && isInTailCallPosition(DAG, Node.getNode(), TCChain) &&
      (RetTy == F.getReturnType() || F.getReturnType()->isVoidTy());
  if (IsTailCall)
    InChain = TCChain;

  TargetLowering::CallLoweringInfo CLI(DAG);
  bool SignExtend = shouldSignExtendTypeInLibCall(RetVT, IsSigned);
  CLI.setDebugLoc(SDLoc(Node))
      .setChain(InChain)
      .setCallee(CallingConv::C, RetTy, Callee, std::move(Args))
      .setTailCall(IsTailCall)
      .setSExtResult(SignExtend)
      .setZExtResult(!SignExtend)
      .setIsPostTypeLegalization(true);

  std::pair<SDValue, SDValue> CallInfo = LowerCallTo(CLI);

  if (IsTailCall) {
    LLVM_DEBUG(dbgs() << "Created tailcall: "; DAG.getRoot().dump(&DAG));
    // It's a tailcall, return the chain (which is the DAG root).
    return DAG.getRoot();
  }

  LLVM_DEBUG(dbgs() << "Created libcall: "; CallInfo.first.dump(&DAG));
  return CallInfo.first;
}
