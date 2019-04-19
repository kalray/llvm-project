#include "K1CTargetObjectFile.h"
#include "K1CTargetMachine.h"

using namespace llvm;

void K1CELFTargetObjectFile::Initialize(MCContext &Ctx,
                                        const TargetMachine &TM) {
  TargetLoweringObjectFileELF::Initialize(Ctx, TM);
  InitializeELF(TM.Options.UseInitArray);
}
