set(LLVM_TARGET_DEFINITIONS K1C.td)

tablegen(LLVM K1CGenAsmWriter.inc -gen-asm-writer)
tablegen(LLVM K1CGenRegisterInfo.inc -gen-register-info)
tablegen(LLVM K1CGenInstrInfo.inc -gen-instr-info)
tablegen(LLVM K1CGenDAGISel.inc -gen-dag-isel)
tablegen(LLVM K1CGenSubtargetInfo.inc -gen-subtarget)
tablegen(LLVM K1CGenMCPseudoLowering.inc -gen-pseudo-lowering)
tablegen(LLVM K1CGenCallingConv.inc -gen-callingconv)

add_public_tablegen_target(K1CCommonTableGen)

add_llvm_target(K1CCodeGen
    K1CISelDAGToDAG.cpp
    K1CISelLowering.cpp
    K1CAsmPrinter.cpp
    K1CExpandPseudoInsts.cpp
    K1CInstrInfo.cpp
    K1CRegisterInfo.cpp
    K1CTargetMachine.cpp
    K1CFrameLowering.cpp
    K1CTargetObjectFile.cpp
    K1CSubtarget.cpp
    K1CMCInstLower.cpp
    K1CLoadStorePacking.cpp
    )

add_subdirectory(TargetInfo)
add_subdirectory(MCTargetDesc)
add_subdirectory(InstPrinter)
