//===--- KVXOSPorting.cpp - Kalray OSPorting ToolChain Implem --*- C++//-*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "KVXOSPorting.h"
#include "CommonArgs.h"
#include "clang/Driver/Compilation.h"
#include "clang/Driver/Driver.h"
#include "clang/Driver/InputInfo.h"
#include "clang/Driver/Options.h"
#include "llvm/ADT/SmallString.h"
#include "llvm/Option/ArgList.h"
#include "llvm/Support/Path.h"

using namespace clang::driver;
using namespace clang::driver::tools;
using namespace clang::driver::toolchains;
using namespace clang;
using namespace llvm::opt;

void kvxosporting::Assembler::ConstructJob(Compilation &C, const JobAction &JA,
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
      Args.MakeArgString(getToolChain().GetProgramPath("kvx-elf-as"));
  C.addCommand(std::make_unique<Command>(
      JA, *this, ResponseFileSupport::AtFileCurCP(), Exec, CmdArgs, Inputs));
}

void kvxosporting::Linker::ConstructJob(Compilation &C, const JobAction &JA,
                                        const InputInfo &Output,
                                        const InputInfoList &Inputs,
                                        const ArgList &Args,
                                        const char *LinkingOutput) const {
  claimNoWarnArgs(Args);
  ArgStringList CmdArgs;

  CmdArgs.push_back("-o");
  CmdArgs.push_back(Output.getFilename());

  std::string LDPath = getToolChain().GetProgramPath("kvx-elf-ld");
  std::string LDPrefix = llvm::sys::path::parent_path(LDPath).str();

  if (!Args.hasArg(options::OPT_nostdlib)) {
    CmdArgs.push_back(
        Args.MakeArgString(LDPrefix + "/../kvx-llvm/elf/lib/crt0.o"));
  }

  for (const auto &II : Inputs)
    if (II.isFilename())
      CmdArgs.push_back(II.getFilename());

  if (!Args.hasArg(options::OPT_nostdlib)) {
    CmdArgs.push_back(
        Args.MakeArgString("-L" + LDPrefix + "/../kvx-llvm/elf/lib"));

    CmdArgs.push_back("-melf64kvx");
    CmdArgs.push_back("-Tbare.ld");
    CmdArgs.push_back("--start-group");
    CmdArgs.push_back("-lc");
    CmdArgs.push_back("-lgloss");
    CmdArgs.push_back("--end-group");

    Args.addAllArgs(CmdArgs, {options::OPT_T, options::OPT_L, options::OPT_l});
  }
  Args.AddAllArgValues(CmdArgs, options::OPT_Wl_COMMA);

  if (Args.hasArg(options::OPT_v))
    CmdArgs.push_back("-v");

  if (Args.getLastArg(options::OPT_shared))
    CmdArgs.push_back("-shared");

  const char *Exec =
      Args.MakeArgString(getToolChain().GetProgramPath("kvx-elf-ld"));
  C.addCommand(std::make_unique<Command>(
      JA, *this, ResponseFileSupport::AtFileCurCP(), Exec, CmdArgs, Inputs));
}

KVXOSPorting::KVXOSPorting(const Driver &D, const llvm::Triple &Triple,
                           const ArgList &Args)
    : Generic_ELF(D, Triple, Args) {
  getFilePaths().push_back(getDriver().SysRoot + "/usr/lib");
}

Tool *KVXOSPorting::buildAssembler() const {
  return new tools::kvxosporting::Assembler(*this);
}

Tool *KVXOSPorting::buildLinker() const {
  return new tools::kvxosporting::Linker(*this);
}

void KVXOSPorting::AddClangSystemIncludeArgs(const ArgList &DriverArgs,
                                             ArgStringList &CC1Args) const {
  CC1Args.push_back("-ftls-model=local-exec");
  if (DriverArgs.hasArg(options::OPT_nostdinc) ||
      DriverArgs.hasArg(options::OPT_nostdlibinc))
    return;

  std::string LDPath = GetProgramPath("kvx-elf-ld");
  StringRef LDPrefix = llvm::sys::path::parent_path(LDPath);

  addSystemInclude(DriverArgs, CC1Args,
                   llvm::sys::path::parent_path(LDPrefix).str() +
                       "/kvx-llvm/elf/include");
}
