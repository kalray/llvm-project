// RUN: %clang -### -S -o - -O3 %s 2>&1 | FileCheck %s --check-prefix=ARG
// RUN: %clang -### -S --target=kvx-kalray-mbr -o - -O3 %s 2>&1 | FileCheck %s --check-prefix=ARG
// RUN: %clang -S -emit-llvm -o - -O3 %s | FileCheck %s
// RUN: %clang -S --target=kvx-kalray-mbr -emit-llvm -o - -O3 %s | FileCheck %s

// ARG: "-cc1"
// ARG-SAME: "-ftls-model=local-exec"
// ARG-CHECK-NOT: "-ftls-model="

// CHECK: @_impure_ptr = external thread_local(localexec)

extern __thread int *_impure_ptr;
int **foo() {
	return &_impure_ptr;
}
