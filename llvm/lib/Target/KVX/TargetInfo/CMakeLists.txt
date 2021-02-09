add_llvm_component_library(LLVMKVXInfo
  KVXTargetInfo.cpp

  LINK_COMPONENTS
  Support

  ADD_TO_COMPONENT
  KVX
  )
