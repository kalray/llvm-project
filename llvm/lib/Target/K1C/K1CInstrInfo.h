#ifndef LLVM_LIB_TARGET_K1C_K1CINSTRINFO_H
#define LLVM_LIB_TARGET_K1C_K1CINSTRINFO_H

#include "K1CRegisterInfo.h"
#include "llvm/CodeGen/TargetInstrInfo.h"

#define GET_INSTRINFO_HEADER
#include "K1CGenInstrInfo.inc"

namespace llvm {

class K1CInstrInfo : public K1CGenInstrInfo {

public:
  K1CInstrInfo();
};

} // namespace llvm

#endif