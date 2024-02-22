// RUN: %clang_cc1 -triple kvx-kalray-cos -S -O2 -emit-llvm -o - %s | FileCheck %s

// CHECK-LABEL: @await(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.await()
// CHECK-NEXT:    ret void
//
void await() {
  __builtin_kvx_await();
}

// CHECK-LABEL: @barrier(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.barrier()
// CHECK-NEXT:    ret void
//
void barrier(void) {
  __builtin_kvx_barrier();
}

// CHECK-LABEL: @get(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_volatile_register.i64(metadata !2)
// CHECK-NEXT:    [[CONV:%.*]] = trunc i64 [[TMP0]] to i32
// CHECK-NEXT:    ret i32 [[CONV]]
//
int get() {
  return __builtin_kvx_get(1);
}

// CHECK-LABEL: @wfxl(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.wfx(i32 1, i64 2, i32 0)
// CHECK-NEXT:    ret void
//
void wfxl() {
  __builtin_kvx_wfxl(1, 2);
}

// CHECK-LABEL: @wfxm(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.wfx(i32 1, i64 2, i32 1)
// CHECK-NEXT:    ret void
//
void wfxm() {
  __builtin_kvx_wfxm(1, 2);
}

// CHECK-LABEL: @set(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !2, i64 2)
// CHECK-NEXT:    ret void
//
void set() {
  __builtin_kvx_set(1, 2);
}

// CHECK-LABEL: @sleep(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.sleep()
// CHECK-NEXT:    ret void
//
void sleep(void) {
  __builtin_kvx_sleep();
}

// CHECK-LABEL: @stop(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.stop()
// CHECK-NEXT:    ret void
//
void stop(void) {
  __builtin_kvx_stop();
}

// CHECK-LABEL: @syncgroup(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.kvx.syncgroup(i64 [[SG:%.*]])
// CHECK-NEXT:    ret void
//
void syncgroup(unsigned long sg) {
  __builtin_kvx_syncgroup(sg);
}

// CHECK-LABEL: @waitit(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i32 @llvm.kvx.waitit(i64 [[SG:%.*]])
// CHECK-NEXT:    ret void
//
void waitit(unsigned long sg) {
  __builtin_kvx_waitit(sg);
}

// CHECK: !2 = !{!"$ps"}