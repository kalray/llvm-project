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
class LLVM_LIBRARY_VISIBILITY Assembler : public Tool {
public:
  Assembler(const ToolChain &TC)
      : Tool("kvxosporting::Assembler", "assembler", TC) {}

  bool hasIntegratedCPP() const override { return false; }

  void ConstructJob(Compilation &C, const JobAction &JA,
                    const InputInfo &Output, const InputInfoList &Inputs,
                    const llvm::opt::ArgList &TCArgs,
                    const char *LinkingOutput) const override;
};

class LLVM_LIBRARY_VISIBILITY Linker : public Tool {
public:
  Linker(const ToolChain &TC) : Tool("kvxosporting::Linker", "linker", TC) {}

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

  bool useIntegratedAs() const override { return false; }
  bool isCrossCompiling() const override { return true; }
  bool IsMathErrnoDefault() const override { return false; }
  bool SupportsProfiling() const override { return false; }
  unsigned GetDefaultDwarfVersion() const override { return 5; }
  /// IsIntegratedAssemblerDefault - Does this tool chain enable -integrated-as
  /// by default.
  bool IsIntegratedAssemblerDefault() const override { return false; }

  /// IsIntegratedBackendDefault - Does this tool chain enable
  /// -fintegrated-objemitter by default.
  bool IsIntegratedBackendDefault() const override { return false; }

  /// IsIntegratedBackendSupported - Does this tool chain support
  /// -fintegrated-objemitter.
  bool IsIntegratedBackendSupported() const override { return false; }

  /// IsNonIntegratedBackendSupported - Does this tool chain support
  /// -fno-integrated-objemitter.
  bool IsNonIntegratedBackendSupported() const override { return true; }

protected:
  Tool *buildAssembler() const override;
  Tool *buildLinker() const override;
};

} // end namespace toolchains
} // end namespace driver
} // end namespace clang

#endif // LLVM_CLANG_LIB_DRIVER_TOOLCHAINS_KVXOSPorting_H
