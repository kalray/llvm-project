// RUN: clang -target k1c-cos -fPIC -S -O2 -v %s -o - |& FileCheck %s

// CHECK: -ftls-model=local-exec

__thread int tls;

int test(void) {
  return tls;
  // CHECK: test:
  // CHECK-NEXT: make $r0 = @tlsle( tls )
  // CHECK: addd $r0 = $r13, $r0
}
