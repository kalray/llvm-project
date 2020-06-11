// RUN: clang -target kvx-cos -mllvm -disable-kvx-loadstore-packing=false -S -O2 %s -o - | FileCheck %s

// Reported in T12917.

a, b, c;
f() {
  double d;
  double **e = g();
  d = b = 0;
  for (; b < 4; b++) {
    c = 0;
    for (; c < 4; c++)
      d += e[b][c];
  }
  if (a)
    h(d);
  // CHECK: lo ${{[0-9|r]+}} = 0[$r0]
  // CHECK: lo $r32r33r34r35 = 0[$r0]
  // CHECK: lo $r8r9r10r11 = 0[$r1]
  // CHECK: lo $r4r5r6r7 = 0[$r2]
  // CHECK: lo $r0r1r2r3 = 0[$r3]
}
