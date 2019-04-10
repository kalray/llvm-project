#ifndef LLVM_LIB_TARGET_K1_K1REGISTERINFO_H
#define LLVM_LIB_TARGET_K1_K1REGISTERINFO_H

#include "llvm/CodeGen/TargetRegisterInfo.h"

#define GET_REGINFO_HEADER
#include "K1GenRegisterInfo.inc"

namespace llvm {

struct K1RegisterInfo : public K1GenRegisterInfo {
    K1RegisterInfo();
};

} // end name space llvm

#endif // LLVM_LIB_TARGET_K1_K1REGISTERINFO_H