// RUN: %clang -target kvx-kalray-cos %s -S -o - -emit-llvm | FileCheck %s
// RUN: %clang -target kvx-kalray-cos -march=kv3-1 %s -S -o - -emit-llvm | FileCheck %s --check-prefix V1
// RUN: %clang -target kvx-kalray-cos -march=kv3-2 %s -S -o - -emit-llvm | FileCheck %s --check-prefix V2
// RUN: %clang -### -target kvx-kalray-cos -march=kv3-1 %s -S -o - |& FileCheck %s --check-prefix CC1V1
// RUN: %clang -### -target kvx-kalray-cos -march=kv3-2 %s -S -o - |& FileCheck %s --check-prefix CC1V2

// V1: attributes{{.*}}"target-cpu"="kv3-1"
// V2: attributes{{.*}}"target-cpu"="kv3-2"
// CHECK-NOT: attributes{{.*}}"target-cpu"="kv3-1"
// CHECK-NOT: attributes{{.*}}"target-cpu"="kv3-2"
// CC1V1: "-target-cpu" "kv3-1"
// CC1V2: "-target-cpu" "kv3-2"

void f(void) {
  return;
}
