// RUN: clang -target kvx-cos -S -O2 %s -o - |& FileCheck %s

int imm10(int *p) {
  return *p;
  // CHECK-LABEL: imm10:
  // CHECK-NEXT: lwz $r0 = 0[$r0]
  // CHECK-NEXT: ret
}

int imm37(int *p) {
  return *(p + 0xffffffff);
  // CHECK-LABEL: imm37:
  // CHECK-NEXT: lwz $r0 = 17179869180[$r0]
  // CHECK-NEXT: ret
}

int imm64(int *p) {
  return *(p + 0xffffffffffff);
  // CHECK-LABEL: imm64:
  // CHECK-NEXT: lwz $r0 = 1125899906842620[$r0]
  // CHECK-NEXT: ret
}

int reg(int *p, long a) {
  return *(p + a);
  // CHECK-LABEL: reg:
  // CHECK: lwz $r0 = $r1[$r0]
  // CHECK-NEXT: ret
}
