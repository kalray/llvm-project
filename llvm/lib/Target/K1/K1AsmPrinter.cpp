#include "MCTargetDesc/K1MCTargetDesc.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

namespace {

class K1AsmPrinter : public AsmPrinter
{
public:
  explicit K1AsmPrinter(TargetMachine &TM,
                           std::unique_ptr<MCStreamer> Streamer)
      : AsmPrinter(TM, std::move(Streamer)) {}

  StringRef getPassName() const override { return "K1 Assembly Printer"; }
};

} // end of namespace

extern "C" void LLVMInitializeK1AsmPrinter() {
    RegisterAsmPrinter<K1AsmPrinter> X(getTheK1Target());
}