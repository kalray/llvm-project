// RUN: not %clang_cc1 -ferror-limit 20 -O2 -triple kvx-kalray-cos -target-cpu kv3-2 -S -emit-llvm -o /dev/null %s 2>&1 | FileCheck %s

int acswapWD(int *p, int a, int b) {
  a = __builtin_kvx_acswapw(p, a, b, ".x");
  b = __builtin_kvx_acswapw(p, a, b);
  long c = __builtin_kvx_acswapd(p, a, b, ".s.v");
  c = __builtin_kvx_acswapd(p, a, b);
  return (int)(c);
}

// ; CHECK: {{.*}} error: This builtin accepts a modifier string composed by: ['', '.', '.v'], ['', '.', '.g']
// ; CHECK-NOT: {{.*}} error: Incorrect number of arguments to builtin
// ; CHECK: {{.*}} error: This builtin accepts a modifier string composed by: ['', '.', '.v'], ['', '.', '.g']
// ; CHECK-NOT: {{.*}} error: Incorrect number of arguments to builtin
