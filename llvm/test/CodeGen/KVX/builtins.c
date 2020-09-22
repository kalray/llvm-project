// RUN: clang -target kvx-cos -S -O2 %s -o - | FileCheck %s

long clsd(long l) {
  // CHECK-LABEL: clsd:
  // CHECK-NEXT: clsd $r0 = $r0
  // CHECK-NEXT: ret
  return __builtin_kvx_clsd(l);
}

int clsw(int i) {
  // CHECK-LABEL: clsw:
  // CHECK-NEXT: clsw $r0 = $r0
  // CHECK-NEXT: ret
  return __builtin_kvx_clsw(i);
}

void errop(void) {
  // CHECK-LABEL: errop:
  // CHECK-NEXT: errop
  // CHECK: ret
  __builtin_kvx_errop();
}
