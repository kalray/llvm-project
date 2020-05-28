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
  // FIXME: once the algorithm is improved check for more lo
}
