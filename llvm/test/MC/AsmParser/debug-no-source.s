// REQUIRES: default_triple
// RUN: llvm-mc %s | FileCheck %s
// XFAIL: kvx
// KVX target does not support assembler parsing.

.file 1 "dir1/foo"

# CHECK-NOT: .file {{.*}} source
