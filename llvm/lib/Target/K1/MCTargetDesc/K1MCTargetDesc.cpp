#include "K1MCTargetDesc.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/Support/TargetRegistry.h"

#define GET_INSTRINFO_MC_DESC
#include "K1GenInstrInfo.inc"

#define GET_REGINFO_MC_DESC
#include "K1GenRegisterInfo.inc"

using namespace llvm;

static MCInstrInfo *createK1MCInstrInfo() {
    MCInstrInfo *X = new MCInstrInfo();
    InitK1MCInstrInfo(X);
    return X;
}

static MCRegisterInfo *createK1MCRegisterInfo(const Triple &TT) {
    MCRegisterInfo *X = new MCRegisterInfo();
    InitK1MCRegisterInfo(X, K1::R0); // ?!?
    return X;
}

extern "C" void LLVMInitializeK1TargetMC() {
    TargetRegistry::RegisterMCInstrInfo(getTheK1Target(), createK1MCInstrInfo);
    TargetRegistry::RegisterMCRegInfo(getTheK1Target(), createK1MCRegisterInfo);
}