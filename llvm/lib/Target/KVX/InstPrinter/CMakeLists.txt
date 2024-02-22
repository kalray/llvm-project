add_llvm_component_library(LLVMKVXAsmPrinter
  KVXInstPrinter.cpp

  LINK_COMPONENTS
  MC
  Support

  ADD_TO_COMPONENT
  KVX
  )
