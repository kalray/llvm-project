add_llvm_component_group(KVX)

set(LLVM_TARGET_DEFINITIONS KVX.td)

tablegen(LLVM KVXGenAsmMatcher.inc -gen-asm-matcher)
tablegen(LLVM KVXGenAsmWriter.inc -gen-asm-writer)
tablegen(LLVM KVXGenRegisterInfo.inc -gen-register-info)
tablegen(LLVM KVXGenInstrInfo.inc -gen-instr-info)
tablegen(LLVM KVXGenDAGISel.inc -gen-dag-isel)
tablegen(LLVM KVXGenSubtargetInfo.inc -gen-subtarget)
tablegen(LLVM KVXGenMCPseudoLowering.inc -gen-pseudo-lowering)
tablegen(LLVM KVXGenCallingConv.inc -gen-callingconv)
tablegen(LLVM KVXGenDFAPacketizer.inc -gen-dfa-packetizer)

add_public_tablegen_target(KVXCommonTableGen)

add_llvm_target(KVXCodeGen
    KVXAsmPrinter.cpp
    KVXCodeGenPrepare.cpp
    KVXExpandPseudoInsts.cpp
    KVXFrameLowering.cpp
    KVXGenerated.cpp
    KVXHardwareLoops.cpp
    KVXHardwareLoopsPrepare.cpp
    KVXInstrInfo.cpp
    KVXISelDAGToDAG.cpp
    KVXISelLowering.cpp
    KVXLoadLatencyMutation.cpp
    KVXLoadStorePacking.cpp
    KVXMCInstLower.cpp
    KVXPostScheduler.cpp
    KVXRegisterInfo.cpp
    KVXSubtarget.cpp
    KVXTargetMachine.cpp
    KVXTargetObjectFile.cpp
    KVXTargetTransformInfo.cpp
    KVXTCAIselLowering.cpp
    KVXVLIWPacketizer.cpp

    LINK_COMPONENTS
    Analysis
    AsmPrinter
    CodeGen
    Core
    MC
    SelectionDAG
    Target
    Support
    KVXDesc
    KVXInfo
    KVXAsmPrinter

    ADD_TO_COMPONENT
    KVX
    )

add_subdirectory(TargetInfo)
add_subdirectory(MCTargetDesc)
add_subdirectory(InstPrinter)
