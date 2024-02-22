// RUN: not %clang_cc1 -ferror-limit 20 -O2 -triple kvx-kalray-cos -target-cpu kv3-2 -S -emit-llvm -o /dev/null %s 2>&1 | FileCheck %s

void dflushsw(unsigned long w, unsigned long s, __kvx_x256 *v, __kvx_x512 *x, __kvx_x1024 *m) {
  __builtin_kvx_dflushsw(w, s, 0);
  __builtin_kvx_dflushsw(w, s, "..");
  __builtin_kvx_dflushsw(w, s, ".s");
  __builtin_kvx_dflushsw(w, s, ".l2.l1");
  __kvx_x256 t = __builtin_kvx_xrecvo(".sdfsdf");
  *m = __builtin_kvx_xcopyv(*m, ".ud");
  *x = __builtin_kvx_xcopyx(*x, ".i");
}

// ; CHECK-COUNT-4: {{.*}} error: This builtin accepts a modifier string composed by: ['.l1', '.l2']
// ; CHECK: {{.*}} error: This builtin accepts a modifier string composed by: ['.b', '.f']
// ; CHECK: {{.*}} error: This builtin accepts a modifier string composed by: ['', '.', '.td']
// ; CHECK: {{.*}} error: This builtin accepts a modifier string composed by: ['', '.', '.zw', '.tq', '.ud', '.tw', '.uw', '.zd']
