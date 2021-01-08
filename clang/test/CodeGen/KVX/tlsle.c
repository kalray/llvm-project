// RUN: %clang -target kvx-kalray-cos -fPIC -S -O2 -v %s -o - |& FileCheck %s
// CHECK: -ftls-model=local-exec
__thread int tls;

int test(void) {
  return tls;
}
