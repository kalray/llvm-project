//===--- KVXOSPorting.cpp - Kalray OSPorting ToolChain Implem --*- C++//-*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "KVXOSPorting.h"
#include "Arch/KVX.h"
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

static std::string getSubarchName(const ArgList &Args,
                                  bool IsIncludePath = false) {
  std::string March = "kv3-1";
  const Arg *A = Args.getLastArg(options::OPT_march_EQ);
  if (A) { // If passed -march to the driver, use that arch
    std::string ArgMarch = A->getValue();
    if (ArgMarch.size())
      March = ArgMarch;
  }

  if (IsIncludePath) {
    if (March == "kv3-1")
      return "";
    return (std::string("/") + March);
  }

  return March;
}

void kvxosporting::Assembler::ConstructJob(Compilation &C, const JobAction &JA,
                                           const InputInfo &Output,
                                           const InputInfoList &Inputs,
                                           const ArgList &Args,
                                           const char *LinkingOutput) const {
  claimNoWarnArgs(Args);
  ArgStringList CmdArgs;

  std::string March = getSubarchName(Args);

  CmdArgs.push_back(Args.MakeArgString("-march=" + March));

  Args.AddAllArgValues(CmdArgs, options::OPT_Wa_COMMA, options::OPT_Xassembler);

  CmdArgs.push_back("-o");
  CmdArgs.push_back(Output.getFilename());

  for (const auto &II : Inputs)
    CmdArgs.push_back(II.getFilename());

  const auto AsPath = getToolChain().GetProgramPath("kvx-mbr-as");
  if (AsPath.empty()) {
    llvm::errs() << "Can't find path for 'kvx-mbr-as'\n";
    C.setContainsError();
    return;
  }
  const char *Exec = Args.MakeArgString(AsPath);
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

  std::string LDPath = getToolChain().GetProgramPath("kvx-mbr-ld");
  if (LDPath.empty()) {
    llvm::errs() << "Can't find path for 'kvx-mbr-ld'\n";
    C.setContainsError();
    return;
  }

  const bool Mhal = (nullptr != Args.getLastArg(options::OPT_kvx_mhal));

  std::string LDPrefix = llvm::sys::path::parent_path(LDPath).str();
  std::string SYSROOT = llvm::sys::path::parent_path(LDPrefix).str();
  std::string ARCH = getSubarchName(Args, true);
  // kvx-mbr/lib/
  // For now using library compiled with gcc.
  // TODO: FIXME: Compile newlib and other dependencies with clang.
  if (!Args.hasArg(options::OPT_nostdlib)) {
    CmdArgs.push_back(Args.MakeArgString(SYSROOT + "/lib/gcc/kvx-mbr/" +
                                         KVX::GCC_VER + ARCH + "/crti.o"));
    CmdArgs.push_back(Args.MakeArgString(SYSROOT + "/lib/gcc/kvx-mbr/" +
                                         KVX::GCC_VER + ARCH + "/crtbegin.o"));
    CmdArgs.push_back(
        Args.MakeArgString(SYSROOT + "/kvx-mbr/lib" + ARCH + "/crt0.o"));
    CmdArgs.push_back(Args.MakeArgString(SYSROOT + "/lib/gcc/kvx-mbr/" +
                                         KVX::GCC_VER + ARCH + "/crtend.o"));
    CmdArgs.push_back(Args.MakeArgString(SYSROOT + "/lib/gcc/kvx-mbr/" +
                                         KVX::GCC_VER + ARCH + "/crtn.o"));
  }

  for (const auto &II : Inputs)
    if (II.isFilename())
      CmdArgs.push_back(II.getFilename());

  if (!Args.hasArg(options::OPT_nostdlib)) {
    CmdArgs.push_back(Args.MakeArgString("-L" + SYSROOT + "/lib/gcc/kvx-mbr/" +
                                         KVX::GCC_VER + ARCH + ""));
    CmdArgs.push_back(
        Args.MakeArgString("-L" + SYSROOT + "/kvx-mbr/lib" + ARCH + ""));
    CmdArgs.push_back(Args.MakeArgString("-L" + SYSROOT + "/lib/gcc/kvx-mbr/" +
                                         KVX::GCC_VER + ""));
    CmdArgs.push_back(Args.MakeArgString("-L" + SYSROOT + "/lib/gcc"));
    CmdArgs.push_back(Args.MakeArgString("-L" + SYSROOT + "/kvx-mbr/lib"));
    if (!Mhal) {
      CmdArgs.push_back("--defsym=exec_on_main=1");
      CmdArgs.push_back("--defsym=mppa_bare_runtime=1");
    }
    CmdArgs.push_back("--start-group");
    CmdArgs.push_back("-lmppahal");
    CmdArgs.push_back("-lmppabareruntime");
    CmdArgs.push_back("-lc");
    CmdArgs.push_back("-lgloss");
    CmdArgs.push_back("--end-group");
    CmdArgs.push_back(Mhal ? "-Tbare.ld" : "-Tmppabareruntime.ld");
    CmdArgs.push_back("-lgcc");

    Args.addAllArgs(CmdArgs, {options::OPT_T, options::OPT_L, options::OPT_l});
  }
  Args.AddAllArgValues(CmdArgs, options::OPT_Wl_COMMA);

  if (Args.hasArg(options::OPT_v))
    CmdArgs.push_back("-v");

  if (Args.getLastArg(options::OPT_shared))
    CmdArgs.push_back("-shared");

  const char *Exec =
      Args.MakeArgString(getToolChain().GetProgramPath("kvx-mbr-ld"));
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

  std::string LDPath = GetProgramPath("kvx-mbr-ld");
  StringRef LDPrefix = llvm::sys::path::parent_path(LDPath);

  addSystemInclude(DriverArgs, CC1Args,
                   llvm::sys::path::parent_path(LDPrefix).str() +
                       "/kvx-llvm/mbr/include");
}
