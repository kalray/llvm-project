#include "llvm/Target/TargetMachine.h"
#include "llvm/Support/TargetRegistry.h"
using namespace llvm;

namespace llvm {
Target& getTheK1CTarget() {
    static Target TheK1CTarget;
    return TheK1CTarget;
}
} // namespace llvm

extern "C" void LLVMInitializeK1CTargetInfo() {
    RegisterTarget<Triple::k1c> X(getTheK1CTarget(), "k1c",
                                     "64bit K1C", "K1C");
}  