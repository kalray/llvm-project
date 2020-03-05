//===--- KVXOSPorting.h - Kalray OSPorting ToolChain Implem ----*- C++//-*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_LIB_DRIVER_TOOLCHAINS_KVXOSPorting_H
#define LLVM_CLANG_LIB_DRIVER_TOOLCHAINS_KVXOSPorting_H

#include "Gnu.h"
#include "clang/Driver/Tool.h"
#include "clang/Driver/ToolChain.h"

namespace clang {
namespace driver {
namespace tools {

/// Kalray ELF -- Directly call GNU Binutils assembler and linker
namespace kvxosporting {
class LLVM_LIBRARY_VISIBILITY Assembler : public GnuTool {
public:
  Assembler(const ToolChain &TC)
      : GnuTool("kvxosporting::Assembler", "assembler", TC) {}

  bool hasIntegratedCPP() const override { return false; }

  void ConstructJob(Compilation &C, const JobAction &JA,
                    const InputInfo &Output, const InputInfoList &Inputs,
                    const llvm::opt::ArgList &TCArgs,
                    const char *LinkingOutput) const override;
};

class LLVM_LIBRARY_VISIBILITY Linker : public GnuTool {
public:
  Linker(const ToolChain &TC) : GnuTool("kvxosporting::Linker", "linker", TC) {}

  bool hasIntegratedCPP() const override { return false; }
  bool isLinkJob() const override { return true; }

  void ConstructJob(Compilation &C, const JobAction &JA,
                    const InputInfo &Output, const InputInfoList &Inputs,
                    const llvm::opt::ArgList &TCArgs,
                    const char *LinkingOutput) const override;
};
} // end namespace kvxosporting
} // end namespace tools

namespace toolchains {

class LLVM_LIBRARY_VISIBILITY KVXOSPorting : public Generic_ELF {
public:
  KVXOSPorting(const Driver &D, const llvm::Triple &Triple,
               const llvm::opt::ArgList &Args);

  void AddClangSystemIncludeArgs(const llvm::opt::ArgList &DriverArgs,
                                 llvm::opt::ArgStringList &CC1Args) const
      override;

protected:
  Tool *buildAssembler() const override;
  Tool *buildLinker() const override;
};

} // end namespace toolchains
} // end namespace driver
} // end namespace clang

#endif // LLVM_CLANG_LIB_DRIVER_TOOLCHAINS_KVXOSPorting_H
