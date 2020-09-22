// RUN: clang -target kvx-cos -S -O2 %s -o - | FileCheck %s

void await() {
  __builtin_kvx_await();
  // CHECK-LABEL: await:
  // CHECK-NEXT: await
}

void barrier(void) {
  __builtin_kvx_barrier();
  // CHECK-LABEL: barrier:
  // CHECK-NEXT: barrier
  // CHECK: ret
}

int get() {
  return __builtin_kvx_get(1);
  // CHECK-LABEL: get:
  // CHECK-NEXT: get $r0 = $ps
  // CHECK: ret
}

void wfxl() {
  __builtin_kvx_wfxl(13, 2);
  // CHECK-LABEL: wfxl:
  // CHECK: wfxl $pm0, $r0
  // CHECK: ret
}

void wfxm() {
  __builtin_kvx_wfxm(13, 2);
  // CHECK-LABEL: wfxm:
  // CHECK: wfxm $pm0, $r0
  // CHECK: ret
}

void set() {
  __builtin_kvx_set(1, 2);
  // CHECK-LABEL: set:
  // CHECK: set $ps = $r0
  // CHECK: ret
}

void sleep(void) {
  __builtin_kvx_sleep();
  // CHECK-LABEL: sleep:
  // CHECK-NEXT: sleep
  // CHECK: ret
}

void stop(void) {
  __builtin_kvx_stop();
  // CHECK-LABEL: stop:
  // CHECK: stop
  // CHECK: ret
}

void syncgroup(unsigned long sg) {
  __builtin_kvx_syncgroup(sg);
  // CHECK-LABEL: syncgroup:
  // CHECK-NEXT: syncgroup $r0
  // CHECK: ret
}

void waitit(unsigned long sg) {
  __builtin_kvx_waitit(sg);
  // CHECK-LABEL: waitit:
  // CHECK-NEXT: waitit $r0
  // CHECK: ret
}
