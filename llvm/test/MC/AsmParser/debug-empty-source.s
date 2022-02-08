// REQUIRES: default_triple
// RUN: llvm-mc %s -o -| FileCheck %s
// XFAIL: kvx
// KVX target does not support assembler parsing.

.file 1 "dir1" "foo" source ""

# CHECK: .file {{.*}} source ""
