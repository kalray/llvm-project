#include "llvm/Target/TargetMachine.h"
#include "llvm/Support/TargetRegistry.h"
using namespace llvm;

namespace llvm {
Target& getTheK1Target() {
    static Target TheK1Target;
    return TheK1Target;
}
}

extern "C" void LLVMInitializeK1TargetInfo() {
    RegisterTarget<Triple::k1> X(getTheK1Target(), "K1",
                                     "K1", "K1");
}  