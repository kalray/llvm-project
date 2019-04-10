set(LLVM_TARGET_DEFINITIONS K1.td)

#tablegen(LLVM K1GenDAGISel.inc -gen-dag-isel)
tablegen(LLVM K1GenInstrInfo.inc -gen-instr-info)
tablegen(LLVM K1GenRegisterInfo.inc -gen-register-info)
tablegen(LLVM K1GenSubtargetInfo.inc -gen-subtarget)

add_public_tablegen_target(K1CommonTableGen)

add_llvm_target(K1CodeGen
    K1AsmPrinter.cpp
    K1InstrInfo.cpp
    K1SelDAGToDag.cpp
    K1RegisterInfo.cpp
    K1TargetMachine.cpp
    K1FrameLowering.cpp
    )

add_subdirectory(TargetInfo)
add_subdirectory(MCTargetDesc)