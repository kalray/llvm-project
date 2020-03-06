// RUN: clang -target k1c-cos -S -O2 %s -o - | FileCheck %s

void await() {
  __builtin_k1_await();
  // CHECK: await:
  // CHECK-NEXT: await
}

char lbzu(char *p) {
  return __builtin_k1_lbzu(p);
  // CHECK: lbzu:
  // CHECK-NEXT: lbz.u $r0 = 0[$r0]
  // CHECK-NEXT: ret
}

short lhzu(short *p) {
  return __builtin_k1_lhzu(p);
  // CHECK: lhzu:
  // CHECK-NEXT: lhz.u $r0 = 0[$r0]
  // CHECK-NEXT: ret
}

int lwzu(int *p) {
  return __builtin_k1_lwzu(p);
  // CHECK: lwzu:
  // CHECK-NEXT: lwz.u $r0 = 0[$r0]
  // CHECK-NEXT: ret
}
