// RUN: clang -target kvx-cos -O2 -S %s -o - | FileCheck %s

extern void bar(int *);

int foo(int n, int m) {
  int t[n];
  bar(t);
  return t[m];
  // CHECK-LABEL: foo
  // CHECK: sd [[STACKSLOT:[0-9]+\[\$r12\]]] = $r14
  // CHECK: call bar
  // CHECK: ld $r14 = [[STACKSLOT]]
  // CHECK: ret
}
