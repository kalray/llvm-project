//===--- K1ELF.cpp - Kalray ELF ToolChain Implementation -------*- C++//-*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "K1ELF.h"
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

void k1elf::Assembler::ConstructJob(Compilation &C, const JobAction &JA,
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
      Args.MakeArgString(getToolChain().GetProgramPath("k1-elf-as"));
  C.addCommand(llvm::make_unique<Command>(JA, *this, Exec, CmdArgs, Inputs));
}

void k1elf::Linker::ConstructJob(Compilation &C, const JobAction &JA,
                                 const InputInfo &Output,
                                 const InputInfoList &Inputs,
                                 const ArgList &Args,
                                 const char *LinkingOutput) const {
  claimNoWarnArgs(Args);
  ArgStringList CmdArgs;

  CmdArgs.push_back("-o");
  CmdArgs.push_back(Output.getFilename());

  std::string LDPath = getToolChain().GetProgramPath("k1-elf-ld");
  std::string LDPrefix = llvm::sys::path::parent_path(LDPath);

  if (!Args.hasArg(options::OPT_nostdlib)) {
    // crti.o
    // crtbegin.o
    CmdArgs.push_back(Args.MakeArgString(LDPrefix + "/../k1-elf/lib/crt0.o"));
  }

  for (const auto &II : Inputs)
    if (II.isFilename())
      CmdArgs.push_back(II.getFilename());

  if (!Args.hasArg(options::OPT_nostdlib)) {
    CmdArgs.push_back("-melf64k1");
    CmdArgs.push_back("-Tbare.ld");

    CmdArgs.push_back(Args.MakeArgString("-L" + LDPrefix + "/../k1-elf/lib"));

    CmdArgs.push_back("--start-group");
    CmdArgs.push_back("-lc");
    CmdArgs.push_back("-lgloss");
    CmdArgs.push_back("--end-group");

    Args.AddAllArgs(CmdArgs, options::OPT_T, options::OPT_L, options::OPT_l);

    // crtend.o
    // crtn.o
  }
  Args.AddAllArgValues(CmdArgs, options::OPT_Wl_COMMA);

  if (Args.hasArg(options::OPT_v))
    CmdArgs.push_back("-v");

  if (Args.getLastArg(options::OPT_shared))
    CmdArgs.push_back("-shared");

  const char *Exec =
      Args.MakeArgString(getToolChain().GetProgramPath("k1-elf-ld"));
  C.addCommand(llvm::make_unique<Command>(JA, *this, Exec, CmdArgs, Inputs));
}

K1ELF::K1ELF(const Driver &D, const llvm::Triple &Triple, const ArgList &Args)
    : Generic_ELF(D, Triple, Args) {
  getFilePaths().push_back(getDriver().SysRoot + "/usr/lib");
}

Tool *K1ELF::buildAssembler() const {
  return new tools::k1elf::Assembler(*this);
}

Tool *K1ELF::buildLinker() const { return new tools::k1elf::Linker(*this); }

void K1ELF::AddClangSystemIncludeArgs(const ArgList &DriverArgs,
                                      ArgStringList &CC1Args) const {
  if (DriverArgs.hasArg(options::OPT_nostdinc) ||
      DriverArgs.hasArg(options::OPT_nostdlibinc))
    return;

  std::string LDPath = GetProgramPath("k1-elf-ld");
  StringRef LDPrefix = llvm::sys::path::parent_path(LDPath);

  addSystemInclude(DriverArgs, CC1Args,
                   llvm::sys::path::parent_path(LDPrefix).str() +
                       "/k1-elf/include");
}
