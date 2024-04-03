// RUN: not %clang_cc1 -ferror-limit 20 -O2 -triple kvx-kalray-cos -target-cpu kv3-2 -S -emit-llvm -o /dev/null %s 2>&1 | FileCheck %s

typedef struct {
  int a, b;
} thestruct;

long scall_errors(int id, thestruct s, __int128 i){
  return __builtin_kvx_scall(id, s) + __builtin_kvx_scall(id, i);
}

// CHECK: {{.*}} error: scall builtin does not support passing aggregate values
// CHECK: {{.*}} error: cannot compile this builtin function yet

// CHECK: {{.*}} error: scall builtin only supports scalars of size <= 64 bits
// CHECK: {{.*}} error: cannot compile this builtin function yet
