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

void clusteros::Assembler::ConstructJob(Compilation &C, const JobAction &JA,
                                        const InputInfo &Output,
                                        const InputInfoList &Inputs,
                                        const ArgList &Args,
                                        const char *LinkingOutput) const {
  claimNoWarnArgs(Args);
  ArgStringList CmdArgs;

  auto &CTC = static_cast<const toolchains::ClusterOS &>(getToolChain());

  if (CTC.GCCInstallationIsValid()) {
    CmdArgs.push_back(
        Args.MakeArgString("-march=" + CTC.getGCCMultilibArch().str()));
  } else {
    // GCCInstallation isn't valid, which means that the toolchain isn't
    // installed in /opt/kalray/accesscore nor the user didn't provided
    // --gcc-toolchain installation prefix. We guess here which march to use.
    const Arg *A = Args.getLastArg(options::OPT_march_EQ);
    if (A)
      CmdArgs.push_back(
          Args.MakeArgString("-march=" + std::string(A->getValue())));
  }

  Args.AddAllArgValues(CmdArgs, options::OPT_Wa_COMMA, options::OPT_Xassembler);

  CmdArgs.push_back("-o");
  CmdArgs.push_back(Output.getFilename());

  for (const auto &II : Inputs)
    CmdArgs.push_back(II.getFilename());

  const char *Exec = Args.MakeArgString(CTC.GetProgramPath("kvx-cos-as"));
  C.addCommand(std::make_unique<Command>(JA, *this, Exec, CmdArgs, Inputs));
}

void clusteros::Linker::ConstructJob(Compilation &C, const JobAction &JA,
                                     const InputInfo &Output,
                                     const InputInfoList &Inputs,
                                     const ArgList &Args,
                                     const char *LinkingOutput) const {

  auto &CTC = static_cast<const toolchains::ClusterOS &>(getToolChain());

  std::string LibDir, GCCLibDir, LLVMLibDir;
  if (CTC.GCCInstallationIsValid()) {
    LibDir = CTC.getGCCInstallPath().str() + "/../../../../kvx-cos/lib" +
             CTC.getGCCMultilibGCCSuffix().str();
    GCCLibDir =
        CTC.getGCCInstallPath().str() + CTC.getGCCMultilibGCCSuffix().str();
    LLVMLibDir = CTC.getGCCInstallPath().str() + "/../../../../lib/llvm/cos" +
                 CTC.getGCCMultilibGCCSuffix().str();
  } else {
    // GCCInstallation isn't valid, which means that the toolchain isn't
    // installed in /opt/kalray/accesscore nor the user didn't provided
    // --gcc-toolchain installation prefix. We guess default paths from
    // kvx-cos-ld program path.
    std::string LDPath = getToolChain().GetProgramPath("kvx-cos-ld");
    std::string LDPrefix = llvm::sys::path::parent_path(LDPath);

    const Arg *A = Args.getLastArg(options::OPT_march_EQ);
    if (A && strcmp(A->getValue(), "kv3-2") == 0) {
      LibDir = LDPrefix + "/../kvx-cos/lib/kv3-2";
      GCCLibDir = LDPrefix + "/../lib/gcc/kvx-cos/7.5.0/kv3-2";
      LLVMLibDir = LDPrefix + "/../lib/llvm/cos/kv3-2";
    } else {
      LibDir = LDPrefix + "/../kvx-cos/lib";
      GCCLibDir = LDPrefix + "/../lib/gcc/kvx-cos/7.5.0";
      LLVMLibDir = LDPrefix + "/../lib/llvm/cos";
    }
  }

  const Arg *A = Args.getLastArg(options::OPT_rtlib_EQ);
  StringRef LibName = A ? A->getValue() : "compiler-rt";

  // Keep old behavior when using libgcc.
  if (LibName == "libgcc") {
    claimNoWarnArgs(Args);
    ArgStringList CmdArgs;

    Args.AddAllArgValues(CmdArgs, options::OPT_Wa_COMMA,
                         options::OPT_Xassembler);

    CmdArgs.push_back("-o");
    CmdArgs.push_back(Output.getFilename());

    // Group all input files
    for (const auto &II : Inputs)
      if (II.isFilename())
        CmdArgs.push_back(II.getFilename());

    Args.AddAllArgs(CmdArgs, options::OPT_L, options::OPT_u);

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

    // -fopenmp option management
    if (Args.hasArg(options::OPT_fopenmp))
      CmdArgs.push_back("-lomp");

    // -nostdlib option management
    if (Args.hasArg(options::OPT_nostdlib))
      CmdArgs.push_back(Args.MakeArgString("-nostdlib"));

    // -shared option management
    if (Args.getLastArg(options::OPT_shared))
      CmdArgs.push_back(Args.MakeArgString("-shared"));

    if (Args.getLastArg(options::OPT_T)) {
      std::string Targ =
          std::string("-T") +
          std::string(Args.getLastArg(options::OPT_T)->getValue());
      CmdArgs.push_back(Args.MakeArgString(Targ));
    }

    if (Args.hasArg(options::OPT_v))
      CmdArgs.push_back("-Wl,-v");

    const char *Exec = Args.MakeArgString(getToolChain().GetProgramPath(
        C.getDriver().CCCIsCXX() ? "kvx-cos-g++" : "kvx-cos-gcc"));
    C.addCommand(std::make_unique<Command>(JA, *this, Exec, CmdArgs, Inputs));
  } else {
    assert(LibName == "compiler-rt" && "unsupported runtime library");

    claimNoWarnArgs(Args);
    ArgStringList CmdArgs;

    CmdArgs.push_back("-o");
    CmdArgs.push_back(Output.getFilename());

    Args.AddAllArgs(CmdArgs, options::OPT_u);

    if (!Args.hasArg(options::OPT_nostdlib)) {
      // TODO: crti.o, crtbegin.o, crtend.o, and crtn.o are currently provided
      // by GCC. Implement those files on newlib's libgloss side to finally be
      // GCC agnostic when using compiler-rt!
      // GCC's crti.o, see TODO comment above.
      CmdArgs.push_back(Args.MakeArgString(GCCLibDir + "/crti.o"));
      // GCC's crtbegin.o, see TODO comment above.
      CmdArgs.push_back(Args.MakeArgString(GCCLibDir + "/crtbegin.o"));
      // TODO: to remove after binutils update.
      CmdArgs.push_back(Args.MakeArgString(LibDir + "/crt0.o"));
    }

    // Keep same order as clang command line for all OPT_Wl_COMMA, OPT_l, OPT_L
    // arguments and input files.
    for (const auto &II : Inputs) {
      if (II.isInputArg()) {
        const Arg &A = II.getInputArg();
        if (A.getOption().matches(options::OPT_Wl_COMMA)) {
          for (unsigned i = 0; i < A.getNumValues(); i++)
	    CmdArgs.push_back(A.getValue(i));
        } else if (A.getOption().matches(options::OPT_l) ||
                   (A.getOption().matches(options::OPT_L))) {
          CmdArgs.push_back(
              Args.MakeArgString(A.getSpelling() + std::string(A.getValue())));
        }
      } else if (II.isFilename()) {
        CmdArgs.push_back(II.getFilename());
      }
    }

    CmdArgs.push_back(Args.MakeArgString("-L" + LibDir));
    CmdArgs.push_back(Args.MakeArgString("-L" + LLVMLibDir));

    CmdArgs.push_back("-melf64kvx");

    if (Args.hasArg(options::OPT_fopenmp))
      CmdArgs.push_back("-lomp");

    if (!Args.hasArg(options::OPT_nostdlib) &&
        !Args.hasArg(options::OPT_nodefaultlibs)) {
      if (C.getDriver().CCCIsCXX()) {
        CmdArgs.push_back("-lstdc++");
        CmdArgs.push_back(Args.MakeArgString("-L" + GCCLibDir));
        CmdArgs.push_back("-lgcc");
      }

      CmdArgs.push_back("-lclang_rt.builtins-kvx");
      CmdArgs.push_back("-lm");

      if (!Args.hasArg(options::OPT_nostdlib)) {
        CmdArgs.push_back("--start-group");
        CmdArgs.push_back("-lc");
        CmdArgs.push_back("-lmppacos");
        CmdArgs.push_back("-lmppa_rsrc");
        CmdArgs.push_back("-lgloss");
        CmdArgs.push_back("-lmppa_fdt");
        CmdArgs.push_back("--end-group");
      }

      CmdArgs.push_back("-lclang_rt.builtins-kvx");
    }

    if (!Args.hasArg(options::OPT_nostdlib)) {
      // GCC's crtend.o, see TODO comment above.
      CmdArgs.push_back(Args.MakeArgString(GCCLibDir + "/crtend.o"));
      // GCC's crtn.o, see TODO comment above.
      CmdArgs.push_back(Args.MakeArgString(GCCLibDir + "/crtn.o"));
    }

    if (Args.getLastArg(options::OPT_T)) {
      std::string Targ =
          std::string("-T") +
          std::string(Args.getLastArg(options::OPT_T)->getValue());
      CmdArgs.push_back(Args.MakeArgString(Targ));
    } else {
      CmdArgs.push_back("-Tmppacos.ld");
    }

    if (Args.hasArg(options::OPT_v))
      CmdArgs.push_back("-v");

    if (Args.getLastArg(options::OPT_shared))
      CmdArgs.push_back("-shared");

    const char *Exec =
        Args.MakeArgString(getToolChain().GetProgramPath("kvx-cos-ld"));
    C.addCommand(std::make_unique<Command>(JA, *this, Exec, CmdArgs, Inputs));
  }
}

// ClusterOS - ClusterOS tool chain which can call as(1) and ld(1) directly.

ClusterOS::ClusterOS(const Driver &D, const llvm::Triple &Triple,
                     const ArgList &Args)
    : Generic_ELF(D, Triple, Args) {
  getFilePaths().push_back(getDriver().SysRoot + "/usr/lib");

  GCCInstallation.init(Triple, Args, {"kvx-cos"});
}

std::string ClusterOS::getIncludeDirRoot() const {
  std::string GCCPath = GetProgramPath("kvx-cos-gcc");
  StringRef GCCPrefix = llvm::sys::path::parent_path(GCCPath);
  return llvm::sys::path::parent_path(GCCPrefix).str() + "/kvx-cos/include";
}

StringRef ClusterOS::getGCCMultilibArch() const {
  for (StringRef Flag : GCCInstallation.getMultilib().flags()) {
    if (Flag.startswith("+march="))
      return Flag.substr(7);
  }

  llvm_unreachable("Default multilib misses +march flag");
}

bool ClusterOS::GCCInstallationIsValid() const {
  return GCCInstallation.isValid();
}

StringRef ClusterOS::getGCCVersion() const {
  return GCCInstallation.isValid() ? GCCInstallation.getVersion().Text
                                   : "7.5.0";
}

StringRef ClusterOS::getGCCInstallPath() const {
  return GCCInstallation.getInstallPath();
}

StringRef ClusterOS::getGCCMultilibGCCSuffix() const {
  return GCCInstallation.getMultilib().gccSuffix();
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
                   getIncludeDirRoot() + "/c++/" + getGCCVersion().data());
  addSystemInclude(DriverArgs, CC1Args,
                   getIncludeDirRoot() + "/c++/" + getGCCVersion().data() +
                       "/kvx-cos");
  addSystemInclude(DriverArgs, CC1Args,
                   getIncludeDirRoot() + "/c++/" + +getGCCVersion().data() +
                       "/backward");
}

void
ClusterOS::addClangTargetOptions(const llvm::opt::ArgList &DriverArgs,
                                 llvm::opt::ArgStringList &CC1Args,
                                 Action::OffloadKind DeviceOffloadKind) const {
  CC1Args.push_back("-nostdsysteminc");

  // ClusterOS linker doesn't support init_array but old behavior with ctors/dtors
  if (!DriverArgs.hasFlag(options::OPT_fuse_init_array,
                          options::OPT_fno_use_init_array, false))
    CC1Args.push_back("-fno-use-init-array");

  if (DriverArgs.hasArg(options::OPT_fPIC))
    CC1Args.push_back("-ftls-model=local-exec");
}
