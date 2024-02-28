// RUN: not %clang_cc1 -ferror-limit 20 -O2 -triple kvx-kalray-cos -target-cpu kv3-2 -S -emit-llvm -o /dev/null %s 2>&1 | FileCheck %s

void fence(const char *p) {
   __builtin_kvx_fence(p);
   __builtin_kvx_fence("", "");
   __builtin_kvx_fence(".allr");
}

// CHECK: {{.*}} error: This builtin accepts a modifier string composed by: ['', '.', '.all', '.r', '.w', '.wa']
// CHECK: {{.*}} error: cannot compile this builtin function yet
// CHECK: {{.*}} error: Incorrect number of arguments to builtin.
// CHECK: {{.*}} error: This builtin accepts a modifier string composed by: ['', '.', '.all', '.r', '.w', '.wa']
// CHECK: {{.*}} error: cannot compile this builtin function yet
