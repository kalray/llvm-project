// RUN: not %clang_cc1 -ferror-limit 20 -O2 -triple kvx-kalray-cos -target-cpu kv3-2 -S -emit-llvm -o /dev/null %s 2>&1 | FileCheck %s

void dflushsw(unsigned long w, unsigned long s, __kvx_x256 *v) {
  __builtin_kvx_dflushsw(w, s, 0);
  __builtin_kvx_dflushsw(w, s, "..");
  __builtin_kvx_dflushsw(w, s, ".s");
  __builtin_kvx_dflushsw(w, s, ".l2.l1");
  *v = __builtin_kvx_xrecvo(".sdfsdf");
}

// ; CHECK-COUNT-4: {{.*}} error: This builtin accept a modifier string composed by: ['.l1', '.l2']
// ; CHECK: {{.*}} error: This builtin accept a modifier string composed by: ['.b', '.f']
