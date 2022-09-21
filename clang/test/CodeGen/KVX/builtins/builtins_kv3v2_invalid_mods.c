// RUN: not %clang_cc1 -ferror-limit 20 -O2 -triple kvx-kalray-cos -target-cpu kv3-2 -S -emit-llvm -o /dev/null %s 2>&1 | FileCheck %s

void dflushsw(unsigned long w, unsigned long s) {
  __builtin_kvx_dflushsw(w, s, 0);
  __builtin_kvx_dflushsw(w, s, "..");
  __builtin_kvx_dflushsw(w, s, ".s");
  __builtin_kvx_dflushsw(w, s, ".l2.l1");
}
// CHECK: {{.*}}builtins_kv3v2_invalid_mods.c:4:32: error: Must define cache level modifier.
// CHECK-NEXT:   __builtin_kvx_dflushsw(w, s, 0);

// CHECK: {{.*}}builtins_kv3v2_invalid_mods.c:4:3: error: cannot compile this builtin function yet
// CHECK-NEXT:   __builtin_kvx_dflushsw(w, s, 0);

// ; CHECK-COUNT-3: {{.*}} Invalid cache level modifer, should be one of: "", ".", ".l1", ".l2"
