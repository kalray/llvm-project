// RUN: clang -mllvm -disable-kvx-hwloops=false -S -g -O2 %s -o - | FileCheck %s

void set(int *x, int num) {
  for (int i = 0; i != num; ++i)
    x[i] = i * i;
}

int f(int num) {
  int *x = alloca(num * 4);
  set(x, num);
  int *y = alloca(num * 8);
  set(y, num * 2);

  int sum = 0;
  for (int i = 0; i != num; ++i)
    sum += x[i] + y[i] + y[i + num];

  return sum;
}

// CHECK: loopdo
// CHECK: loopdo
// CHECK: loopdo
