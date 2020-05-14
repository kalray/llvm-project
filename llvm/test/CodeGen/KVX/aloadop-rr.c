// RUN: clang -target kvx-cos -S -O2 %s -o - |& FileCheck %s

// Initially reported in T13217 and reduced to the test below.

long a;
int *b;

void foo32() {
  __sync_fetch_and_or(&b[a], 0);
  // CHECK-LABEL: foo32
  // CHECK: lwz.u {{\$r[0-9]+}} = $r0[$r1]
  // CHECK: acswapw $r0[$r1] = {{\$r[0-9]+r[0-9]+}}
  // CHECK: ret
}

long *c;

void foo64() {
  __sync_fetch_and_or(&c[a], 0);
  // CHECK-LABEL: foo64
  // CHECK: ld.u {{\$r[0-9]+}} = $r0[$r1]
  // CHECK: acswapd $r0[$r1] = {{\$r[0-9]+r[0-9]+}}
  // CHECK: ret
}
