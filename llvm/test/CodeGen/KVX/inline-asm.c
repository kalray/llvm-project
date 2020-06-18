// RUN: clang -target kvx-cos -O3 -S %s -o - | FileCheck %s

register unsigned long reg __asm__("r10"); // or $r10

unsigned long foo() {
  return reg;
  // CHECK-LABEL: foo:
  // CHECK: copyd $r0 = $r10
  // CHECK: ret
}
