//===--- KVX.h - KVX -                 specific Tool Helpers ----*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "KVX.h"
#include "llvm/ADT/StringRef.h"

namespace clang {
namespace driver {
namespace tools {
namespace KVX {
void getKVXTargetFeatures(const Driver &D, const llvm::Triple &Triple,
                          const llvm::opt::ArgList &Args,
                          llvm::opt::ArgStringList &CmdArgs,
                          std::vector<llvm::StringRef> &Features) {
  if (const auto *A = Args.getLastArg(options::OPT_O_Group)) {
    if (A->getOption().matches(options::OPT_O0))
      return;

    bool AddO3Opts = A->getOption().matches(options::OPT_O4) ||
                     A->getOption().matches(options::OPT_Ofast) ||
                     (StringRef(A->getValue()) == "3");

    if (!AddO3Opts)
      return;

    // Fixme: They only should be added if not specified by the user
    CmdArgs.append({"-mllvm", "--enable-unroll-and-jam=true",
                    "-mllvm", "--enable-loop-flatten=true",
                    "-mllvm", "--enable-dfa-jump-thread=true"});

  }
}

} // end namespace KVX
} // end namespace tools
} // end namespace driver
} // end namespace clang
