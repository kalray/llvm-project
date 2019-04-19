include "llvm/Target/Target.td"

include "K1CRegisterInfo.td"
include "K1CInstrInfo.td"
include "K1CPatterns.td"
include "K1CCallingConv.td"

def K1CInstrInfo : InstrInfo {
}

def K1CAsmWriter : AsmWriter {
    int PassSubtarget = 1;
}

def K1C : Target {
    let InstructionSet = K1CInstrInfo;
}

def : Processor<"generic", NoItineraries, []>;
