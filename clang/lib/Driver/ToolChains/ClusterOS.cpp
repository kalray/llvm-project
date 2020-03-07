//===--- ClusterOS.cpp - ClusterOS ToolChain Implementations ----*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "ClusterOS.h"
#include "CommonArgs.h"
#include "InputInfo.h"
#include "clang/Driver/Compilation.h"
#include "clang/Driver/Driver.h"
#include "clang/Driver/Options.h"
#include "llvm/ADT/SmallString.h"
#include "llvm/Option/ArgList.h"
#include "llvm/Support/Path.h"

using namespace clang::driver;
using namespace clang::driver::tools;
using namespace clang::driver::toolchains;
using namespace clang;
using namespace llvm::opt;

#define KVX_CLUSTEROS_GCC_VERSION "7.5.0"

void clusteros::Assembler::ConstructJob(Compilation &C, const JobAction &JA,
                                        const InputInfo &Output,
                                        const InputInfoList &Inputs,
                                        const ArgList &Args,
                                        const char *LinkingOutput) const {
  claimNoWarnArgs(Args);
  ArgStringList CmdArgs;

  Args.AddAllArgValues(CmdArgs, options::OPT_Wa_COMMA, options::OPT_Xassembler);

  CmdArgs.push_back("-o");
  CmdArgs.push_back(Output.getFilename());

  for (const auto &II : Inputs)
    CmdArgs.push_back(II.getFilename());

  const char *Exec =
      Args.MakeArgString(getToolChain().GetProgramPath("k1-cos-as"));
  C.addCommand(llvm::make_unique<Command>(JA, *this, Exec, CmdArgs, Inputs));
}

void clusteros::Linker::ConstructJob(Compilation &C, const JobAction &JA,
                                     const InputInfo &Output,
                                     const InputInfoList &Inputs,
                                     const ArgList &Args,
                                     const char *LinkingOutput) const {
  claimNoWarnArgs(Args);
  ArgStringList CmdArgs;

  Args.AddAllArgValues(CmdArgs, options::OPT_Wa_COMMA, options::OPT_Xassembler);

  CmdArgs.push_back("-o");
  CmdArgs.push_back(Output.getFilename());

  // Group all input files
  for (const auto &II : Inputs)
    if (II.isFilename())
      CmdArgs.push_back(II.getFilename());

  // Ensure that -l args are at the end of the cmd line
  for (const auto &II : Inputs) {
    if (II.isInputArg()) {
      const Arg &A = II.getInputArg();
      if (A.getOption().matches(options::OPT_l)) {
        std::string larg = std::string("-l") + std::string(A.getValue());
        CmdArgs.push_back(Args.MakeArgString(larg.c_str()));
      } else if (A.getOption().matches(options::OPT_Wl_COMMA)) {
        std::string Wlarg = std::string("-Wl,") + std::string(A.getValue());
        CmdArgs.push_back(Args.MakeArgString(Wlarg));
      } else if (A.getOption().matches(options::OPT_Z_reserved_lib_stdcxx)) {
        CmdArgs.push_back("-lstdc++");
      } else
        llvm_unreachable("unsupported input arg kind");
    }
  }

  // -nostdlib option management
  if (Args.hasArg(options::OPT_nostdlib))
    CmdArgs.push_back(Args.MakeArgString("-nostdlib"));

  // -shared option management
  if (Args.getLastArg(options::OPT_shared))
    CmdArgs.push_back(Args.MakeArgString("-shared"));

  if (Args.getLastArg(options::OPT_T)) {
    std::string Targ = std::string("-T") +
                       std::string(Args.getLastArg(options::OPT_T)->getValue());
    CmdArgs.push_back(Args.MakeArgString(Targ));
  }

  if (Args.hasArg(options::OPT_v))
    CmdArgs.push_back("-Wl,-v");

  const char *Exec = Args.MakeArgString(getToolChain().GetProgramPath(
      C.getDriver().CCCIsCXX() ? "k1-cos-g++" : "k1-cos-gcc"));
  C.addCommand(llvm::make_unique<Command>(JA, *this, Exec, CmdArgs, Inputs));
}

// ClusterOS - ClusterOS tool chain which can call as(1) and ld(1) directly.

ClusterOS::ClusterOS(const Driver &D, const llvm::Triple &Triple,
                     const ArgList &Args)
    : Generic_ELF(D, Triple, Args) {
  getFilePaths().push_back(getDriver().SysRoot + "/usr/lib");
}

std::string ClusterOS::getIncludeDirRoot() const {
  std::string GCCPath = GetProgramPath("k1-cos-gcc");
  StringRef GCCPrefix = llvm::sys::path::parent_path(GCCPath);
  return llvm::sys::path::parent_path(GCCPrefix).str() + "/k1-cos/include";
}

Tool *ClusterOS::buildAssembler() const {
  return new tools::clusteros::Assembler(*this);
}

Tool *ClusterOS::buildLinker() const {
  return new tools::clusteros::Linker(*this);
}

void ClusterOS::AddClangSystemIncludeArgs(const ArgList &DriverArgs,
                                          ArgStringList &CC1Args) const {
  if (DriverArgs.hasArg(options::OPT_nostdinc) ||
      DriverArgs.hasArg(options::OPT_nostdlibinc))
    return;

  addSystemInclude(DriverArgs, CC1Args, getIncludeDirRoot());
}

void ClusterOS::AddClangCXXStdlibIncludeArgs(const ArgList &DriverArgs,
                                             ArgStringList &CC1Args) const {
  if (DriverArgs.hasArg(options::OPT_nostdincxx) ||
      DriverArgs.hasArg(options::OPT_nostdlibinc))
    return;

  addSystemInclude(DriverArgs, CC1Args,
                   getIncludeDirRoot() + "/c++/" KVX_CLUSTEROS_GCC_VERSION);
  addSystemInclude(DriverArgs, CC1Args, getIncludeDirRoot() +
                                            "/c++/" KVX_CLUSTEROS_GCC_VERSION
                                            "/k1-cos");
  addSystemInclude(DriverArgs, CC1Args, getIncludeDirRoot() +
                                            "/c++/" KVX_CLUSTEROS_GCC_VERSION
                                            "/backward");
}

void
ClusterOS::addClangTargetOptions(const llvm::opt::ArgList &DriverArgs,
                                 llvm::opt::ArgStringList &CC1Args,
                                 Action::OffloadKind DeviceOffloadKind) const {
  CC1Args.push_back("-nostdsysteminc");

  if (DriverArgs.hasArg(options::OPT_fPIC))
    CC1Args.push_back("-ftls-model=local-exec");
}
