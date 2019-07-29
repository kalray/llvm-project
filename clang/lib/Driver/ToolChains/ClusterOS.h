//===--- ClusterOS.h - ClusterOS ToolChain Implementations ------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_LIB_DRIVER_TOOLCHAINS_COS_H
#define LLVM_CLANG_LIB_DRIVER_TOOLCHAINS_COS_H

#include "Gnu.h"
#include "clang/Driver/Tool.h"
#include "clang/Driver/ToolChain.h"

namespace clang {
namespace driver {
namespace tools {

/// ClusterOS -- Directly call GNU Binutils assembler and linker
namespace clusteros {
class LLVM_LIBRARY_VISIBILITY Assembler : public GnuTool {
public:
  Assembler(const ToolChain &TC)
      : GnuTool("clusteros::Assembler", "assembler", TC) {}

  bool hasIntegratedCPP() const override { return false; }

  void ConstructJob(Compilation &C, const JobAction &JA,
                    const InputInfo &Output, const InputInfoList &Inputs,
                    const llvm::opt::ArgList &TCArgs,
                    const char *LinkingOutput) const override;
};

class LLVM_LIBRARY_VISIBILITY Linker : public GnuTool {
public:
  Linker(const ToolChain &TC) : GnuTool("clusteros::Linker", "linker", TC) {}

  bool hasIntegratedCPP() const override { return false; }
  bool isLinkJob() const override { return true; }

  void ConstructJob(Compilation &C, const JobAction &JA,
                    const InputInfo &Output, const InputInfoList &Inputs,
                    const llvm::opt::ArgList &TCArgs,
                    const char *LinkingOutput) const override;
};
} // end namespace clusteros
} // end namespace tools

namespace toolchains {

class LLVM_LIBRARY_VISIBILITY ClusterOS : public Generic_ELF {
public:
  ClusterOS(const Driver &D, const llvm::Triple &Triple,
            const llvm::opt::ArgList &Args);

  void AddClangSystemIncludeArgs(const llvm::opt::ArgList &DriverArgs,
                                 llvm::opt::ArgStringList &CC1Args) const
      override;

  void AddClangCXXStdlibIncludeArgs(const llvm::opt::ArgList &DriverArgs,
                                    llvm::opt::ArgStringList &CC1Args) const
      override;

  void addClangTargetOptions(const llvm::opt::ArgList &DriverArgs,
                             llvm::opt::ArgStringList &CC1Args,
                             Action::OffloadKind DeviceOffloadKind) const
      override;

protected:
  Tool *buildAssembler() const override;
  Tool *buildLinker() const override;
};

} // end namespace toolchains
} // end namespace driver
} // end namespace clang

#endif // LLVM_CLANG_LIB_DRIVER_TOOLCHAINS_COS_H
