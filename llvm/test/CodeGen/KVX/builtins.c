// RUN: clang -target kvx-cos -S -O2 %s -o - | FileCheck %s

void await() {
  __builtin_kvx_await();
  // CHECK: await:
  // CHECK-NEXT: await
}

char lbzu(char *p) {
  return __builtin_kvx_lbzu(p);
  // CHECK: lbzu:
  // CHECK-NEXT: lbz.u $r0 = 0[$r0]
  // CHECK-NEXT: ret
}

short lhzu(short *p) {
  return __builtin_kvx_lhzu(p);
  // CHECK: lhzu:
  // CHECK-NEXT: lhz.u $r0 = 0[$r0]
  // CHECK-NEXT: ret
}

int lwzu(int *p) {
  return __builtin_kvx_lwzu(p);
  // CHECK: lwzu:
  // CHECK-NEXT: lwz.u $r0 = 0[$r0]
  // CHECK-NEXT: ret
}
