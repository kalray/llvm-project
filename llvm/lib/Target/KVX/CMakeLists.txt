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
    KVXISelDAGToDAG.cpp
    KVXISelLowering.cpp
    KVXAsmPrinter.cpp
    KVXExpandPseudoInsts.cpp
    KVXInstrInfo.cpp
    KVXRegisterInfo.cpp
    KVXTargetMachine.cpp
    KVXFrameLowering.cpp
    KVXTargetObjectFile.cpp
    KVXSubtarget.cpp
    KVXMCInstLower.cpp
    KVXLoadStorePacking.cpp
    KVXVLIWPacketizer.cpp
    KVXHardwareLoops.cpp
    KVXTargetTransformInfo.cpp
    )

add_subdirectory(TargetInfo)
add_subdirectory(MCTargetDesc)
add_subdirectory(InstPrinter)
