//===-- KVXTargetTransformInfo.h - KVX specific TTI -------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file a TargetTransformInfo::Concept conforming object specific
// to the KVX target machine. It uses the target's detailed
// information to provide more precise answers to certain TTI queries,
// while letting the target independent and default TTI
// implementations handle the rest.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_KVX_KVXTARGETTRANSFORMINFO_H
#define LLVM_LIB_TARGET_KVX_KVXTARGETTRANSFORMINFO_H

#include "KVX.h"
#include "KVXTargetMachine.h"
#include "llvm/Analysis/TargetTransformInfo.h"
#include "llvm/CodeGen/BasicTTIImpl.h"
#include "llvm/CodeGen/TargetLowering.h"

namespace llvm {

class KVXTTIImpl : public BasicTTIImplBase<KVXTTIImpl> {
  using BaseT = BasicTTIImplBase<KVXTTIImpl>;
  using TTI = TargetTransformInfo;

  friend BaseT;

  const KVXSubtarget *ST;
  const KVXTargetLowering *TLI;

  const KVXSubtarget *getST() const { return ST; }
  const KVXTargetLowering *getTLI() const { return TLI; }

public:
  explicit KVXTTIImpl(const KVXTargetMachine *TM, const Function &F)
      : BaseT(TM, F.getParent()->getDataLayout()), ST(TM->getSubtargetImpl(F)),
        TLI(ST->getTargetLowering()) {}

  void getUnrollingPreferences(Loop *L, ScalarEvolution &SE,
                               TTI::UnrollingPreferences &UP);
};

} // end namespace llvm

#endif // LLVM_LIB_TARGET_KVX_KVXTARGETTRANSFORMINFO_H
