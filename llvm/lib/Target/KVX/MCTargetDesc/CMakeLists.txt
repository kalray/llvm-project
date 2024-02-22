add_llvm_component_library(LLVMKVXDesc
  KVXAsmBackend.cpp
  KVXMCTargetDesc.cpp
  KVXAsmInfo.cpp
  KVXTargetStreamer.cpp

  LINK_COMPONENTS
  MC
  KVXInfo
  KVXAsmPrinter
  Support

  ADD_TO_COMPONENT
  KVX
  )
