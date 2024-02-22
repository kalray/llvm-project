// RUN: %clang_cc1 -triple kvx-kalray-cos -emit-llvm %s -O2 -o - | FileCheck %s
// This ensures that register names without $ are accepted by the compiler

register long fd asm("s6");
// CHECK-LABEL: @write(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    tail call void @llvm.write_register.i64(metadata !0, i64 [[V:%.*]])
// CHECK-NEXT:    ret void
//
void write(long v) {
  fd = v;
}

// CHECK-LABEL: @read(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_register.i64(metadata !0)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long read() {
  return fd;
}

register long r2 asm("r2") = 0;
// CHECK-LABEL: @doCopy(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.read_register.i64(metadata !1)
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long doCopy(long r, long v) {
  return r2;
}

// CHECK: !0 = !{!"s6"}
// CHECK: !1 = !{!"r2"}
