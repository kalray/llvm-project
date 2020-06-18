// RUN: clang -target kvx-cos -S -O3 %s -o - | FileCheck %s

typedef char v2i8 __attribute__((vector_size(2)));
typedef char v3i8 __attribute__((vector_size(3)));
typedef char v4i8 __attribute__((vector_size(4)));
typedef char v8i8 __attribute__((vector_size(8)));

extern char bar2(v2i8);
extern char bar3(v3i8);
extern char bar4(v4i8);
extern char bar8(v8i8);

void foo() {
  v2i8 v2 = {-5, -6};
  v3i8 v3 = {-5, -6, -7};
  v4i8 v4 = {-5, -6, -7, -8};
  v8i8 v8 = {-5, -6, -7, -8, -9, -10, -11, -12};
  bar2(v2);
  bar3(v3);
  bar4(v4);
  bar8(v8);
  // CHECK-LABEL: foo:
  // CHECK: make $r0 = 64251
  // CHECK: call bar2
  // CHECK: orw $r0 = $r0, 16382715
  // CHECK: call bar3
  // CHECK: make $r0 = 4177132283
  // CHECK: call bar4
  // CHECK: make $r0 = -795458214266537221
  // CHECK: goto bar8
}
