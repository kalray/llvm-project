// RUN: clang -target kvx-cos -S -O2 %s -o - |& FileCheck %s

void imm10(int *p, int a) {
  *p = a;
  // CHECK-LABEL: imm10:
  // CHECK-NEXT: sw 0[$r0] = $r1
  // CHECK-NEXT: ret
}

void imm37(int *p, int a) {
  *(p + 0xffffffff) = a;
  // CHECK-LABEL: imm37:
  // CHECK-NEXT: sw 17179869180[$r0] = $r1
  // CHECK-NEXT: ret
}

void imm64(int *p, int a) {
  *(p + 0xffffffffffff) = a;
  // CHECK-LABEL: imm64:
  // CHECK-NEXT: sw 1125899906842620[$r0] = $r1
  // CHECK-NEXT: ret
}

void reg(int *p, long a, long b) {
  *(p + b) = a;
  // CHECK-LABEL: reg:
  // CHECK: sw $r2[$r0] = $r1
  // CHECK-NEXT: ret
}
