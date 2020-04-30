// RUN: clang -mllvm --disable-kvx-loadstore-packing=false -S -O3 %s -o -

long *x;

void g(long *v);

void f(long *v) {
  long y[100];
  y[0] = v[0];
  y[1] = v[1];
  y[2] = v[2];
  y[3] = v[3];

  g(v);

  y[4] = v[4];
  y[5] = v[5];
  y[6] = v[6];
  y[7] = v[7];

  g(v);

  x[0] = y[0];
  x[1] = y[1];
  x[2] = y[2];
  x[3] = y[3];
  x[4] = y[4];
  x[5] = y[5];
  x[6] = y[6];
  x[7] = y[7];
}
