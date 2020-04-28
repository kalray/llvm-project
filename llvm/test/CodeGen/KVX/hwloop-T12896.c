// RUN: clang -target kvx-cos -S %s -Wno-implicit-int -Wno-return-type -O2 -o - | FileCheck %s

// The test ensures no regressions after T12896 bugfix:
//   llvm: assertion error on `getNumber() >= 0 && "cannot get label for unreachable MBB"'

short a;
b;
c() {
  int d, e;
  d = 0;
  for (; d < b; d++)
    e >>= 6;
  a = e;
}

// For Release with no Assertions builds, check for illegal symbols:
// CHECK-NOT: {{LBB[0-9]+_-1}}
