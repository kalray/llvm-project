// RUN: clang -target kvx-cos -O3 -S -fPIC %s -o - | FileCheck %s

extern int g;
int mul(int num) {
  return num * g;
  // CHECK: mul
  // CHECK: pcrel {{\$r[0-9]+}} = @gotaddr()
  // CHECK ld {{\$r[0-9]+}} = @got( g )[{{\$r[0-9]+}}]
  // CHECK: ret
}

void f(int *x, int n);
int main() {
  int x[10];
  f(x, 5);

  return 0;
  // CHECK: main
  // CHECK-NOT: pcrel
  // CHECK: ret
}
