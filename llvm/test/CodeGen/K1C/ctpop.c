// RUN: clang -target k1c-cos -S -O2 %s -o - | FileCheck %s

int cbsw(int a) {
  return __builtin_popcount(a);
  // CHECK: cbsw $r0 = $r0
}

long cbsdl(long a) {
  return __builtin_popcountl(a);
  // CHECK: cbsd $r0 = $r0
}

long long cbsdll(long a) {
  return __builtin_popcountll(a);
  // CHECK: cbsd $r0 = $r0
}

// TODO: cbswp can be matched via builtin and custom lowering
