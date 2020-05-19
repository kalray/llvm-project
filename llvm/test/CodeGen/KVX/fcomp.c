// RUN: clang -target kvx-cos -S -O2 %s -o - | FileCheck %s
// RUN: clang -target kvx-cos -S -O3 -ffast-math %s -o - | FileCheck %s -check-prefix=FASTMATH

int eq16(_Float16 x, _Float16 y) {
  // CHECK: eq16:
  // CHECK-NEXT: fcompnhq.oeq $r0 = $r0, $r1
  // CHECK: ret
  return x == y;
}

int ne16(_Float16 x, _Float16 y) {
  // CHECK: ne16:
  // CHECK-NEXT: fcompnhq.une $r0 = $r0, $r1
  // FASTMATH: fcompnhq.one $r0 = $r0, $r1
  // CHECK: ret
  return x != y;
}

int ge16(_Float16 x, _Float16 y) {
  // CHECK: ge16:
  // CHECK-NEXT: fcompnhq.oge $r0 = $r0, $r1
  // CHECK: ret
  return x >= y;
}

int lt16(_Float16 x, _Float16 y) {
  // CHECK: lt16:
  // CHECK-NEXT: fcompnhq.olt $r0 = $r0, $r1
  // CHECK: ret
  return x < y;
}

int gt16(_Float16 x, _Float16 y) {
  // CHECK: gt16:
  // CHECK-NEXT: fcompnhq.olt $r0 = $r1, $r0
  // CHECK: ret
  return x > y;
}

int le16(_Float16 x, _Float16 y) {
  // CHECK: le16:
  // CHECK-NEXT: fcompnhq.oge $r0 = $r1, $r0
  // CHECK: ret
  return x <= y;
}

int eq32(float x, float y) {
  // CHECK: eq32:
  // CHECK-NEXT: fcompw.oeq $r0 = $r0, $r1
  // CHECK: ret
  return x == y;
}

int ne32(float x, float y) {
  // CHECK: ne32:
  // CHECK-NEXT: fcompw.une $r0 = $r0, $r1
  // CHECK: ret
  return x != y;
}

int ge32(float x, float y) {
  // CHECK: ge32:
  // CHECK-NEXT: fcompw.oge $r0 = $r0, $r1
  // CHECK: ret
  return x >= y;
}

int lt32(float x, float y) {
  // CHECK: lt32:
  // CHECK-NEXT: fcompw.olt $r0 = $r0, $r1
  // CHECK: ret
  return x < y;
}

int gt32(float x, float y) {
  // CHECK: gt32:
  // CHECK-NEXT: fcompw.olt $r0 = $r1, $r0
  // CHECK: ret
  return x > y;
}

int le32(float x, float y) {
  // CHECK: le32:
  // CHECK-NEXT: fcompw.oge $r0 = $r1, $r0
  // CHECK: ret
  return x <= y;
}

int eq64(double x, double y) {
  // CHECK: eq64:
  // CHECK-NEXT: fcompd.oeq $r0 = $r0, $r1
  // CHECK: ret
  return x == y;
}

int ne64(double x, double y) {
  // CHECK: ne64:
  // CHECK-NEXT: fcompd.une $r0 = $r0, $r1
  // CHECK: ret
  return x != y;
}

int ge64(double x, double y) {
  // CHECK: ge64:
  // CHECK-NEXT: fcompd.oge $r0 = $r0, $r1
  // CHECK: ret
  return x >= y;
}

int lt64(double x, double y) {
  // CHECK: lt64:
  // CHECK-NEXT: fcompd.olt $r0 = $r0, $r1
  // CHECK: ret
  return x < y;
}

int gt64(double x, double y) {
  // CHECK: gt64:
  // CHECK-NEXT: fcompd.olt $r0 = $r1, $r0
  // CHECK: ret
  return x > y;
}

int le64(double x, double y) {
  // CHECK: le64:
  // CHECK-NEXT: fcompd.oge $r0 = $r1, $r0
  // CHECK: ret
  return x <= y;
}
