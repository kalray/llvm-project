// RUN: clang -target kvx-cos -S -O2 %s -o - |& FileCheck %s

#include <stdatomic.h>

int load8to32(_Atomic char *p) {
  return atomic_load(p);
  // CHECK-LABEL: load8to32
  // CHECK: lbz.u $r0 = 0[$r0]
}

short load8to16(_Atomic char *p) {
  return atomic_load(p);
  // CHECK-LABEL: load8to16
  // CHECK: lbz.u $r0 = 0[$r0]
}

long load8to64(_Atomic char *p) {
  return atomic_load(p);
  // CHECK-LABEL: load8to64
  // CHECK: lbz.u $r0 = 0[$r0]
}

int load16to32(_Atomic short *p) {
  return atomic_load(p);
  // CHECK-LABEL: load16to32
  // CHECK: lhz.u $r0 = 0[$r0]
}

long load16to64(_Atomic short *p) {
  return atomic_load(p);
  // CHECK-LABEL: load16to64
  // CHECK: lhz.u $r0 = 0[$r0]
}
