//===--- KVX.h - KVX -                 specific Tool Helpers ----*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_LIB_DRIVER_TOOLCHAINS_ARCH_KVX_H
#define LLVM_CLANG_LIB_DRIVER_TOOLCHAINS_ARCH_KVX_H

#include "clang/Driver/Driver.h"
#include "clang/Driver/Options.h"
#include "llvm/Option/ArgList.h"

namespace clang {
namespace driver {
namespace tools {
namespace KVX {
void getKVXTargetFeatures(const Driver &D, const llvm::Triple &Triple,
                           const llvm::opt::ArgList &Args,
                           llvm::opt::ArgStringList &CmdArgs,
                           std::vector<llvm::StringRef> &Features);

constexpr char GCC_VER[] = "13.2.1";
} // end namespace KVX
} // end namespace tools
} // end namespace driver
} // end namespace clang

#endif // LLVM_CLANG_LIB_DRIVER_TOOLCHAINS_ARCH_KVX_H
