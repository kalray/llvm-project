#include "K1CTargetStreamer.h"
#include "llvm/Support/FormattedStream.h"

using namespace llvm;

K1CTargetStreamer::K1CTargetStreamer(MCStreamer &S, formatted_raw_ostream &OS)
    : MCTargetStreamer(S), OS(OS) {
    }